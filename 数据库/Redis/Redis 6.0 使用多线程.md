# 一、[谈谈Redis 6.0 之前为什么一直不使用多线程？](https://mp.weixin.qq.com/s/D-D0BCMXnnxjnp94OJZ0bg)

Redis作为一个基于内存的缓存系统，一直以高性能著称，因没有上下文切换以及无锁操作，即使在单线程处理情况下，读速度仍可达到11万次/s，写速度达到8.1万次/s。但是，单线程的设计也给Redis带来一些问题：

- 只能使用CPU一个核；
- 如果删除的键过大（比如Set类型中有上百万个对象），会导致服务端阻塞好几秒；
- QPS难再提高。

针对上面问题，Redis在4.0版本以及6.0版本分别引入了`Lazy Free`以及`多线程IO`，逐步向多线程过渡，下面将会做详细介绍。

## 单线程原理

都说Redis是单线程的，那么单线程是如何体现的？如何支持客户端并发请求的？为了搞清这些问题，首先来了解下Redis是如何工作的。

Redis服务器是一个事件驱动程序，服务器需要处理以下两类事件：

- `文件事件`：Redis服务器通过套接字与客户端（或者其他Redis服务器）进行连接，而文件事件就是服务器对套接字操作的抽象；服务器与客户端的通信会产生相应的文件事件，而服务器则通过监听并处理这些事件来完成一系列网络通信操作，比如连接`accept`，`read`，`write`，`close`等；`时间事件`：Redis服务器中的一些操作（比如serverCron函数）需要在给定的时间点执行，而时间事件就是服务器对这类定时操作的抽象，比如过期键清理，服务状态统计等。

  ![图片](https://mmbiz.qpic.cn/mmbiz_png/8Jeic82Or04llEANIyhbbU8fQky9ibXZ2icpEHuJb2zCKPEqRMDy3T9opkP1PfL1ngdibEEsxRHR3bbNgLOiaXvJEjg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

如上图，Redis将文件事件和时间事件进行抽象，时间轮训器会监听I/O事件表，一旦有文件事件就绪，Redis就会优先处理文件事件，接着处理时间事件。在上述所有事件处理上，Redis都是以`单线程`形式处理，所以说Redis是单线程的。此外，如下图，Redis基于Reactor模式开发了自己的I/O事件处理器，也就是文件事件处理器，Redis在I/O事件处理上，采用了I/O多路复用技术，同时监听多个套接字，并为套接字关联不同的事件处理函数，通过一个线程实现了多客户端并发处理。

![图片](https://mmbiz.qpic.cn/mmbiz_png/8Jeic82Or04llEANIyhbbU8fQky9ibXZ2ickK0dPfKCwgouHmQIXYaZgL0nMuibic551nxP5UW9icy54edXVC8buFzEg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

正因为这样的设计，在数据处理上避免了加锁操作，既使得实现上足够简洁，也保证了其高性能。当然，Redis单线程只是指其在事件处理上，实际上，Redis也并不是单线程的，比如生成RDB文件，就会fork一个子进程来实现，当然，这不是本文要讨论的内容。

## Lazy Free机制

如上所知，Redis在处理客户端命令时是以单线程形式运行，而且处理速度很快，期间不会响应其他客户端请求，但若客户端向Redis发送一条耗时较长的命令，比如删除一个含有上百万对象的Set键，或者执行flushdb，flushall操作，Redis服务器需要回收大量的内存空间，导致服务器卡住好几秒，对负载较高的缓存系统而言将会是个灾难。为了解决这个问题，在Redis 4.0版本引入了`Lazy Free`，将`慢操作`异步化，这也是在事件处理上向多线程迈进了一步。

如作者在其博客中所述，要解决`慢操作`，可以采用渐进式处理，即增加一个时间事件，比如在删除一个具有上百万个对象的Set键时，每次只删除大键中的一部分数据，最终实现大键的删除。但是，该方案可能会导致回收速度赶不上创建速度，最终导致内存耗尽。因此，Redis最终实现上是将大键的删除操作异步化，采用非阻塞删除（对应命令`UNLINK`），大键的空间回收交由单独线程实现，主线程只做关系解除，可以快速返回，继续处理其他事件，避免服务器长时间阻塞。

以删除（`DEL`命令）为例，看看Redis是如何实现的，下面就是删除函数的入口，其中，`lazyfree_lazy_user_del`是是否修改`DEL`命令的默认行为，一旦开启，执行`DEL`时将会以`UNLINK`形式执行。

```c
void delCommand(client *c) {
    delGenericCommand(c,server.lazyfree_lazy_user_del);
}

/* This command implements DEL and LAZYDEL. */
void delGenericCommand(client *c, int lazy) {
    int numdel = 0, j;

    for (j = 1; j < c->argc; j++) {
        expireIfNeeded(c->db,c->argv[j]);
        // 根据配置确定DEL在执行时是否以lazy形式执行
        int deleted  = lazy ? dbAsyncDelete(c->db,c->argv[j]) :
                              dbSyncDelete(c->db,c->argv[j]);
        if (deleted) {
            signalModifiedKey(c,c->db,c->argv[j]);
            notifyKeyspaceEvent(NOTIFY_GENERIC,
                "del",c->argv[j],c->db->id);
            server.dirty++;
            numdel++;
        }
    }
    addReplyLongLong(c,numdel);
}`
```

同步删除很简单，只要把key和value删除，如果有内层引用，则进行递归删除，这里不做介绍。下面看下异步删除，Redis在回收对象时，会先计算回收收益，只有回收收益在超过一定值时，采用封装成Job加入到异步处理队列中，否则直接同步回收，这样效率更高。回收收益计算也很简单，比如`String`类型，回收收益值就是1，而`Set`类型，回收收益就是集合中元素个数。

搜索侠梦的开发笔记公众号回复“赚钱”，送你一份惊喜礼包。

```c
/* Delete a key, value, and associated expiration entry if any, from the DB.
 * If there are enough allocations to free the value object may be put into
 * a lazy free list instead of being freed synchronously. The lazy free list
 * will be reclaimed in a different bio.c thread. */
#define LAZYFREE_THRESHOLD 64
int dbAsyncDelete(redisDb *db, robj *key) {
    /* Deleting an entry from the expires dict will not free the sds of
     * the key, because it is shared with the main dictionary. */
    if (dictSize(db->expires) > 0) dictDelete(db->expires,key->ptr);

    /* If the value is composed of a few allocations, to free in a lazy way
     * is actually just slower... So under a certain limit we just free
     * the object synchronously. */
    dictEntry *de = dictUnlink(db->dict,key->ptr);
    if (de) {
        robj *val = dictGetVal(de);
        // 计算value的回收收益
        size_t free_effort = lazyfreeGetFreeEffort(val);

        /* If releasing the object is too much work, do it in the background
         * by adding the object to the lazy free list.
         * Note that if the object is shared, to reclaim it now it is not
         * possible. This rarely happens, however sometimes the implementation
         * of parts of the Redis core may call incrRefCount() to protect
         * objects, and then call dbDelete(). In this case we'll fall
         * through and reach the dictFreeUnlinkedEntry() call, that will be
         * equivalent to just calling decrRefCount(). */
        // 只有回收收益超过一定值，才会执行异步删除，否则还是会退化到同步删除
        if (free_effort > LAZYFREE_THRESHOLD && val->refcount == 1) {
            atomicIncr(lazyfree_objects,1);
            bioCreateBackgroundJob(BIO_LAZY_FREE,val,NULL,NULL);
            dictSetVal(db->dict,de,NULL);
        }
    }

    /* Release the key-val pair, or just the key if we set the val
     * field to NULL in order to lazy free it later. */
    if (de) {
        dictFreeUnlinkedEntry(db->dict,de);
        if (server.cluster_enabled) slotToKeyDel(key->ptr);
        return 1;
    } else {
        return 0;
    }
}`
```

通过引入`a threaded lazy free`，Redis实现了对于`Slow Operation`的`Lazy`操作，避免了在大键删除，`FLUSHALL`，`FLUSHDB`时导致服务器阻塞。当然，在实现该功能时，不仅引入了`lazy free`线程，也对Redis聚合类型在存储结构上进行改进。因为Redis内部使用了很多共享对象，比如客户端输出缓存。当然，Redis并未使用加锁来避免线程冲突，锁竞争会导致性能下降，而是去掉了共享对象，直接采用数据拷贝，如下，在3.x和6.x中`ZSet`节点value的不同实现。

```c
// 3.2.5版本ZSet节点实现，value定义robj *obj
/* ZSETs use a specialized version of Skiplists */
typedef struct zskiplistNode {
    robj *obj;
    double score;
    struct zskiplistNode *backward;
    struct zskiplistLevel {
        struct zskiplistNode *forward;
        unsigned int span;
    } level[];
} zskiplistNode;

// 6.0.10版本ZSet节点实现，value定义为sds ele
/* ZSETs use a specialized version of Skiplists */
typedef struct zskiplistNode {
    sds ele;
    double score;
    struct zskiplistNode *backward;
    struct zskiplistLevel {
        struct zskiplistNode *forward;
        unsigned long span;
    } level[];
} zskiplistNode;`
```

去掉共享对象，不但实现了`lazy free`功能，也为Redis向多线程跨进带来了可能，正如作者所述：

> Now that values of aggregated data types are fully unshared, and client output buffers don’t contain shared objects as well, there is a lot to exploit. For example it is finally possible to implement threaded I/O in Redis, so that different clients are served by different threads. This means that we’ll have a global lock only when accessing the database, but the clients read/write syscalls and even the parsing of the command the client is sending, can happen in different threads.

## 多线程I/O及其局限性

Redis在4.0版本引入了`Lazy Free`，自此Redis有了一个`Lazy Free`线程专门用于大键的回收，同时，也去掉了聚合类型的共享对象，这为多线程带来可能，Redis也不负众望，在6.0版本实现了`多线程I/O`。

### 实现原理

正如官方以前的回复，Redis的性能瓶颈并不在CPU上，而是在内存和网络上。因此6.0发布的多线程并未将事件处理改成多线程，而是在I/O上，此外，如果把事件处理改成多线程，不但会导致锁竞争，而且会有频繁的上下文切换，即使用分段锁来减少竞争，对Redis内核也会有较大改动，性能也不一定有明显提升。

![图片](https://mmbiz.qpic.cn/mmbiz_png/8Jeic82Or04llEANIyhbbU8fQky9ibXZ2icyu7uVDFzJWNEr7qjXKXTuqf2bicHg1LZ8esnxIibgiaghHXmQiaymofCwQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

如上图红色部分，就是Redis实现的多线程部分，利用多核来分担I/O读写负荷。在`事件处理线程`每次获取到可读事件时，会将所有就绪的读事件分配给`I/O线程`，并进行等待，在所有`I/O线程`完成读操作后，`事件处理线程`开始执行任务处理，在处理结束后，同样将写事件分配给`I/O线程`，等待所有`I/O`线程完成写操作。

以读事件处理为例，看下`事件处理线程`任务分配流程：

```c
int handleClientsWithPendingReadsUsingThreads(void) {
    ...

    /* Distribute the clients across N different lists. */
    listIter li;
    listNode *ln;
    listRewind(server.clients_pending_read,&li);
    int item_id = 0;
    // 将等待处理的客户端分配给I/O线程
    while((ln = listNext(&li))) {
        client *c = listNodeValue(ln);
        int target_id = item_id % server.io_threads_num;
        listAddNodeTail(io_threads_list[target_id],c);
        item_id++;
    }

    ...

    /* Wait for all the other threads to end their work. */
    // 轮训等待所有I/O线程处理完
    while(1) {
        unsigned long pending = 0;
        for (int j = 1; j < server.io_threads_num; j++)
            pending += io_threads_pending[j];
        if (pending == 0) break;
    }

    ...

    return processed;
}`
```

`I/O线程`处理流程：

```c
void *IOThreadMain(void *myid) {
    ...

    while(1) {
        ...

        // I/O线程执行读写操作
        while((ln = listNext(&li))) {
            client *c = listNodeValue(ln);
            // io_threads_op判断是读还是写事件
            if (io_threads_op == IO_THREADS_OP_WRITE) {
                writeToClient(c,0);
            } else if (io_threads_op == IO_THREADS_OP_READ) {
                readQueryFromClient(c->conn);
            } else {
                serverPanic("io_threads_op value is unknown");
            }
        }
        listEmpty(io_threads_list[id]);
        io_threads_pending[id] = 0;

        if (tio_debug) printf("[%ld] Done\n", id);
    }
}`
```

### 局限性

从上面实现上看，6.0版本的多线程并非彻底的多线程，`I/O线程`只能同时执行读或者同时执行写操作，期间`事件处理线程`一直处于等待状态，并非流水线模型，有很多轮训等待开销。

### Tair多线程实现原理

相较于6.0版本的多线程，Tair的多线程实现更加优雅。如下图，Tair的`Main Thread`负责客户端连接建立等，`IO Thread`负责请求读取、响应发送、命令解析等，`Worker Thread`线程专门用于事件处理。`IO Thread`读取用户的请求并进行解析，之后将解析结果以命令的形式放在队列中发送给`Worker Thread`处理。`Worker Thread`将命令处理完成后生成响应，通过另一条队列发送给`IO Thread`。为了提高线程的并行度，`IO Thread`和`Worker Thread`之间采用无锁队列 和管道 进行数据交换，整体性能会更好。

![图片](https://mmbiz.qpic.cn/mmbiz_png/8Jeic82Or04llEANIyhbbU8fQky9ibXZ2ic74ZsicicibwYDlz8ko1iaicib2sPPzz75tb8JpXRMTPwcp07qcwXiajbbrd2A/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

## 小结

Redis 4.0引入`Lazy Free`线程，解决了诸如大键删除导致服务器阻塞问题，在6.0版本引入了`I/O Thread`线程，正式实现了多线程，但相较于Tair，并不太优雅，而且性能提升上并不多，压测看，多线程版本性能是单线程版本的2倍，Tair多线程版本则是单线程版本的3倍。在作者看来，Redis多线程无非两种思路，`I/O threading`和`Slow commands threading`，正如作者在其博客中所说：

> I/O threading is not going to happen in Redis AFAIK, because after much consideration I think it’s a lot of complexity without a good reason. Many Redis setups are network or memory bound actually. Additionally I really believe in a share-nothing setup, so the way I want to scale Redis is by improving the support for multiple Redis instances to be executed in the same host, especially via Redis Cluster.

> What instead I really want a lot is slow operations threading, and with the Redis modules system we already are in the right direction. However in the future (not sure if in Redis 6 or 7) we’ll get key-level locking in the module system so that threads can completely acquire control of a key to process slow operations. Now modules can implement commands and can create a reply for the client in a completely separated way, but still to access the shared data set a global lock is needed: this will go away.

Redis作者更倾向于采用集群方式来解决`I/O threading`，尤其是在6.0版本发布的原生Redis Cluster Proxy背景下，使得集群更加易用。

此外，作者更倾向于`slow operations threading`（比如4.0版本发布的`Lazy Free`）来解决多线程问题。后续版本，是否会将`IO Thread`实现的更加完善，采用Module实现对慢操作的优化，着实值得期待。

### Redis 6.0 为什么要引入多线程呢？

zRedis 的瓶颈并不在 CPU，而在内存和网络。

内存不够的话，可以加内存或者做数据结构优化和其他优化等，但网络的性能优化才是大头，网络 IO 的读写在 Redis 整个执行期间占用了大部分的 CPU 时间，如果把网络处理这部分做成多线程处理方式，那对整个 Redis 的性能会有很大的提升。

优化方向：

- 提高网络 IO 性能，典型的实现比如使用 DPDK 来替代内核网络栈的方式。
- 使用多线程充分利用多核，典型的实现比如 Memcached。

所以总结起来，Redis 支持多线程主要就是两个原因：

- 可以充分利用服务器 CPU 资源，目前主线程只能利用一个核。
- 多线程任务可以分摊 Redis 同步 IO 读写负荷。



----

## 二、[Redis 6.0在5.2号这个美好的日子里悄无声息的发布了，这次发布在IT圈犹如一颗惊雷一般，因为这是redis最大的一次改版，首次加入了**多线程**。](https://www.cnblogs.com/gz666666/p/12901507.html)

作者Antirez在RC1版本发布时在他的博客写下：

*the most “enterprise” Redis version to date // 最”企业级”的*

*the largest release of Redis ever as far as I can tell // 最大的*

*the one where the biggest amount of people participated // 参与人数最多的*

### 这次改变，性能有个飞速的提升~

先po出新版和旧版性能图

![img](https://img2020.cnblogs.com/blog/1712130/202005/1712130-20200516173630588-526817166.webp)

 

 

 ![img](https://img2020.cnblogs.com/blog/1712130/202005/1712130-20200516173641771-833825796.webp)

 

从上面可以看到 GET/SET 命令在 4 线程 IO 时性能相比单线程是几乎是翻倍了。另外，这些数据只是为了简单验证多线程 IO 是否真正带来性能优化，并没有针对严谨的延时控制和不同并发的场景进行压测。数据仅供验证参考而不能作为线上指标，且只是目前的 unstble分支的性能，不排除后续发布的正式版本的性能会更好。

### Redis 6.0 之前的版本真的是单线程吗？

Redis基于Reactor模式开发了网络事件处理器，这个处理器被称为文件事件处理器。它的组成结构为4部分：多个套接字、IO多路复用程序、文件事件分派器、事件处理器。因为文件事件分派器队列的消费是单线程的，所以Redis才叫单线程模型。

![img](https://img2020.cnblogs.com/blog/1712130/202005/1712130-20200516174325368-1460514173.jpg)

 

 

 

一般来说 Redis 的瓶颈并不在 CPU，而在内存和网络。如果要使用 CPU 多核，可以搭建多个 Redis 实例来解决。

其实，Redis 4.0 开始就有多线程的概念了，比如 Redis 通过多线程方式在后台删除对象、以及通过 Redis 模块实现的阻塞命令等。

 

### Redis 6.0 之前为什么一直不使用多线程？

使用了单线程后，可维护性高。多线程模型虽然在某些方面表现优异，但是它却引入了程序执行顺序的不确定性，带来了并发读写的一系列问题，增加了系统复杂度、同时可能存在线程切换、甚至加锁解锁、死锁造成的性能损耗。

Redis 通过 AE 事件模型以及 IO 多路复用等技术，处理性能非常高，因此没有必要使用多线程。

单线程机制使得 Redis 内部实现的复杂度大大降低，Hash 的惰性 Rehash、Lpush 等等 “线程不安全” 的命令都可以无锁进行。

### Redis 6.0 为什么要引入多线程呢？

之前的段落说了，Redis 的瓶颈并不在 CPU，而在内存和网络。

内存不够的话，可以加内存或者做数据结构优化和其他优化等，但网络的性能优化才是大头，网络 IO 的读写在 Redis 整个执行期间占用了大部分的 CPU 时间，如果把网络处理这部分做成多线程处理方式，那对整个 Redis 的性能会有很大的提升。

优化方向：

- 提高网络 IO 性能，典型的实现比如使用 DPDK 来替代内核网络栈的方式。
- 使用多线程充分利用多核，典型的实现比如 Memcached。

所以总结起来，Redis 支持多线程主要就是两个原因：

- 可以充分利用服务器 CPU 资源，目前主线程只能利用一个核。
- 多线程任务可以分摊 Redis 同步 IO 读写负荷。

### Redis 6.0 默认是否开启了多线程？

否，在conf文件进行配置

io-threads-do-reads yes

io-threads 线程数

官方建议：4 核的机器建议设置为 2 或 3 个线程，8 核的建议设置为 6 个线程，线程数一定要小于机器核数，尽量不超过8个。

### Redis 6.0 多线程的实现机制？

![img](https://img2020.cnblogs.com/blog/1712130/202005/1712130-20200516174816219-1469215261.jpg)

 

 

***流程简述如下\***：

- 主线程负责接收建立连接请求，获取 Socket 放入全局等待读处理队列。
- 主线程处理完读事件之后，通过 RR（Round Robin）将这些连接分配给这些 IO 线程。
- 主线程阻塞等待 IO 线程读取 Socket 完毕。
- 主线程通过单线程的方式执行请求命令，请求数据读取并解析完成，但并不执行。
- 主线程阻塞等待 IO 线程将数据回写 Socket 完毕。
- 解除绑定，清空等待队列。

### ![img](https://img2020.cnblogs.com/blog/1712130/202005/1712130-20200516174905348-1186276910.jpg)

 

 

该设计有如下特点：

- IO 线程要么同时在读 Socket，要么同时在写，不会同时读或写。
- IO 线程只负责读写 Socket 解析命令，不负责命令处理。

### 开启多线程后，是否会存在线程并发安全问题？

不会，Redis 的多线程部分只是用来处理网络数据的读写和协议解析，执行命令仍然是单线程顺序执行。

### Redis 线程中经常提到 IO 多路复用，如何理解？

这是 IO 模型的一种，即经典的 Reactor 设计模式，有时也称为异步阻塞 IO。

![img](https://img2020.cnblogs.com/blog/1712130/202005/1712130-20200516175103898-604996357.jpg)

 

 

多路指的是多个 Socket 连接，复用指的是复用一个线程。多路复用主要有三种技术：Select，Poll，Epoll。

Epoll 是最新的也是目前最好的多路复用技术。采用多路 I/O 复用技术可以让单个线程高效的处理多个连接请求（尽量减少网络 IO 的时间消耗），且 Redis 在内存中操作数据的速度非常快（内存内的操作不会成为这里的性能瓶颈），主要以上两点造就了 Redis 具有很高的吞吐量。