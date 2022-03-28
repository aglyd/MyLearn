# 一、[重学MySQL系列01-揭开面纱，显露架构](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054134&idx=1&sn=79c0e8f7933815d822d9c2a36dc77401&scene=21#wechat_redirect)

## 前言 

目前大部分的后端开发人员对`MySQL`的理解可能停留在一个黑盒子阶段。

对`MySQL`基本使用没什么问题，比如建库、建表、建索引，执行各种增删改查。

所有很多后端开发人员眼中的`MySQL`如下图所示

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiao68hq0RskZ2zpWxl00W9WKpPPQ7MHGuK4p9moAfezSibJNUr8Y4yiaFQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

导致在实际工作中碰到`MySQL`中死锁异常、`SQL`性能太差、异常报错等问题时，直接百度搜索。

然后跟着博客捣鼓就解决了，可能自己都没搞明白里面的原理。

为了解决这种**知其然而不知其所以然**的问题，阿星的**重学MySQL系列**会带着大家去探索MySQL底层原理的方方面面。

这样大家碰到`MySQL`的一些异常或者问题时，能够直戳本质，快速地定位解决。

## 连接管理

系统（客户端）访问`MySQL`服务器前，做的第一件事就是建立`TCP`连接。

经过三次握手建立连接成功后，`MySQL`服务器对`TCP`传输过来的账号密码做身份认证、权限获取。

- **用户名或密码不对，会收到一个Access denied for user错误，客户端程序结束执行**
- **用户名密码认证通过，会从权限表查出账号拥有的权限与连接关联，之后的权限判断逻辑，都将依赖于此时读到的权限**

接着我们来思考一个问题

一个系统只会和`MySQL`服务器建立一个连接吗？

只能有一个系统和`MySQL`服务器建立连接吗？

当然不是，多个系统都可以和`MySQL`服务器建立连接，每个系统建立的连接肯定不止一个。

所以，为了解决`TCP`无限创建与`TCP`频繁创建销毁带来的资源耗尽、性能下降问题。

`MySQL`服务器里有专门的`TCP`连接池限制接数，采用长连接模式复用`TCP`连接，来解决上述问题。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiab08oUCH2Bo6h5beN4IAToLBYszia9icumYZsIBFB7icLnVmvt8WFznQTg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

`TCP`连接收到请求后，必须要分配给一个线程去执行，所以还会有个线程池，去走后面的流程。

这些内容我们都归纳到`MySQL`的**连接管理**组件中。

所以**连接管理**的职责是负责认证、管理连接、获取权限信息。

## 解析与优化

经过了连接管理，现在`MySQL`服务器已经获取到`SQL`字符串。

如果是查询语句，`MySQL`服务器会使用`select SQL`字符串作为`key`。

去缓存中获取，命中缓存，直接返回结果（**返回前需要做权限验证**），未命中执行后面的阶段，这个步骤叫**查询缓存**。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiap7tgOblicg4YxFribqHbzXN2vG18LJyPgcqZ6pJELkmMTnX5XjC38MTg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

需要注意，`select SQL`字符串要完全匹配，有任何不同的地方都会导致缓存不被命中（**空格、注释、大小写、某些系统函数**）。

> ==**小贴士：虽然查询缓存有时可以提升系统性能，但也不得不因维护这块缓存而造成一些开销，从MySQL 5.7.20开始，不推荐使用查询缓存，并在MySQL 8.0中删除。**==

没有命中缓存，或者非`select SQL`就来到**分析器**阶段了。

因为系统发送过来的只是一段文本字符串，所以`MySQL`服务器要按照`SQL`语法对这段文本进行解析。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiaicm6nh8rVmibE0oRr8nvTSgra5ptic7k0VwRDYzHqrOA9Uu18oEmff6vg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

如果你的`SQL`字符串不符合语法规范，就会收到`You have an error in your SQL syntax`错误提醒

通过了**分析器**，说明`SQL`字符串符合语法规范，现在`MySQL`服务器要执行`SQL`语句了。

`MySQL`服务器要怎么执行呢？

你需要产出执行计划，交给`MySQL`服务器执行，所以来到了**优化器**阶段。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiawPicQgxONOtb1T8R2zG6icMzyicbKGgsWBqJGpBVFialDtrWqsguQ6ymxg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

优化器不仅仅只是生成执行计划这么简单，这个过程它会帮你优化`SQL`语句。

如**外连接转换为内连接、表达式简化、子查询转为连接、连接顺序、索引选择**等一堆东西，优化的结果就是执行计划。

截止到现在，还没有真正去读写真实的表，仅仅只是产出了一个执行计划。

于是就进入了**执行器**阶段，`MySQL`服务器终于要执行`SQL`语句了。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiaAv6QqdfpRz2nN4c573GVrQ9eKfF8STslib8IUrAokibmOg9JG5LxFAEA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

开始执行的时候，要先判断一下对这个表有没有相应的权限，如果没有，就会返回权限错误。

如果有权限，根据执行计划调用存储引擎`API`对表进行的读写。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiaJice8RCjInQEFjEQWlrZQ1EscvOB3IX22WDqmytl4Hp86ERq4vUMRPQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

存储引擎`API`只是抽象接口，下面还有个**存储引擎层**，具体实现还是要看表选择的存储引擎。

讲到这里，上面提到的**查询缓存、分析器、优化器、执行器**都可以归纳到`MySQL`的**解析与优化**组件中。

所以**解析与优化**的职责如下：

- **缓存**
- **SQL语法解析验证**
- **SQL优化并生成执行计划**
- **根据执行计划调用存储引擎接口**

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiarGf6kibRqjyazon4ppMfzIEZBU45JkdCRGLToY9I8icr55vtp9zOt5JQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

其中**连接管理**与**解析与优化**处于`MySQL`架构中的`Server`层。

## 小结

在学习任何知识前，先不要着急的陷入细节，而是先了解大致脉络，有个全局观，之后再去深入相关的细节。

`MySql`架构分为`Servce`层与**存储引擎**层。

**连接管理、解析与优化**这些并不涉及读写表数据的组件划分到`Servce`层，读写表数据而是交给**存储引擎层**来做。

通过这种架构设计，我们发现`Servce`层其实就是公用层，**存储引擎层**就是多态层，按需选择具体的存储引擎。

再细想下，它和**模板方法设计模式**一摸一样，它们的执行流程是固定的，`Servce`层等于公用模板函数，**存储引擎层**等于抽象模板函数，按需子类实现。

阿星最后以一张`MySQL`简化版的架构图结束本文，我们下期再见~

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzDaJd7LOWUfTL7rtaKlqibiaEZ7rVZFTzf0ibGujepl10bViaDibjycgsaibakTpfLupqk0ibw0ohXA8h0w/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

站在巨人的肩膀上：

- 《MySQL实战45讲》
- 《从零开始带你成为MySQL实战优化高手》
- 《MySQL是怎样运行的：从根儿上理解MySQL》
- 《MySQL技术Innodb存储引擎》

## Java并发编程好文推荐

- [33张图剖析ReentrantReadWriteLock源码](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652053599&idx=1&sn=682ebcdde60aeab9edd6b0fc62aef3d1&scene=21#wechat_redirect)
- [图文并茂的聊聊ReentrantReadWriteLock的位运算](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652049849&idx=1&sn=fe69e7e24a8aa56f8a420f2ce65fbae7&scene=21#wechat_redirect)
- [通俗易懂的ReentrantLock，不懂你来砍我](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652049208&idx=1&sn=efecf2d8c2c03e6ea2ad31af047fa06c&scene=21#wechat_redirect)
- [万字长文 | 16张图解开AbstractQueuedSynchronizer](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652048892&idx=1&sn=1b12dc819ec677a2af67875d7fbbe4a0&scene=21#wechat_redirect)
- [写给小白看的LockSupport](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652048811&idx=1&sn=7ee5246c1a006b502cc0c2850e4d6915&scene=21#wechat_redirect)
- [13张图，深入理解Synchronized](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652048775&idx=1&sn=fa4cca84abe9aa9c58ebb926f10141e4&scene=21#wechat_redirect)
- [由浅入深CAS，小白也能与BAT面试官对线](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652048732&idx=1&sn=9519a130bf9776555306af126c565a20&scene=21#wechat_redirect)0
- [小白也能看懂的Java内存模型](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652048697&idx=1&sn=82cd7cf5ab2ab9a34a4ca1e6e246f46e&scene=21#wechat_redirect)
- [保姆级教学，22张图揭开ThreadLocal](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652048380&idx=1&sn=d4420022dee3f10a39cbc8ca24fcf955&scene=21#wechat_redirect)
- [透彻Java线程状态转换](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652050137&idx=1&sn=3ce2d77b6185812f94ab8d957ca9936b&scene=21#wechat_redirect)
- [进程、线程与协程傻傻分不清？一文带你吃透！](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652047977&idx=1&sn=31d90d699597aa13bedbb34c32f1dbfc&scene=21#wechat_redirect)
- [什么是线程安全？一文带你深入理解](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652048438&idx=1&sn=772ffbe1c9b1dc30c74625eec4f77576&scene=21#wechat_redirect)



-----



# 1.1、[为什么MySQL8要无情的抛弃查询缓存？这里面到底发生了什么？](https://zhuanlan.zhihu.com/p/454274086)

MySQL的查询缓存，很多朋友应该听说或者使用过，因为以前流行的一句话：现在查询这么慢，你可以开启查询缓存试试，曾经作为MySQL性能提升的一个重要特征，查询缓存为什么会被MySQL8无情的抛弃呢？今天我们就来分析分析。

## 什么是查询缓存

对于这种专业概念，我们还是引入MySQL官方文档来说吧，这样要严谨一些。

> The query cache stores the text of a `SELECT` statement together with the corresponding result that was sent to the client. If an identical statement is received later, the server retrieves the results from the query cache rather than parsing and executing the statement again. The query cache is shared among sessions, so a result set generated by one client can be sent in response to the same query issued by another client.
> The query cache can be useful in an environment where you have tables that do not change very often and for which the server receives many identical queries. This is a typical situation for many Web servers that generate many dynamic pages based on database content.
> The query cache does not return stale data. When tables are modified, any relevant entries in the query cache are flushed.

从官方文档我们可以看到，查询缓存其实就是将SELECT的语句和相应的结果缓存起来并发送给客户端，如果同样的SELECT语句之后再过来，就直接返回缓存里面的查询结果，并且查询缓存是客户端共享的，一个客户端生成，其他客户端也有用。

但是需要说明一点，就是查询缓存不能够返回稳定的数据，如果表数据被修改，相关的条目将被清空，重新生成。

## 如果MySQL并发高会存在什么问题？

现在假设存在一种情况，就是MySQL的并发很高，针对查询缓存会出现什么问题？假设一个客户端进程读，另一个客户端进程写同一个数据表，这个时候，查询缓存是读还是不读呢？这一切的控制，让MySQL要花很大的精力去处理这种情况，比如引入锁，有变化了，就锁起来，不让读，然后变化完了，再重新生成缓存，给读端，相信并发高了，仅仅这个查询缓存都会成为MySQL性能最大问题，不仅仅没有帮我们提升性能，反而让我们的应用变得越来越慢都是有可能的。

## 对于查询缓存我们能够做的事情很少

使用过MySQL查询缓存的朋友应该知道，我们仅仅是通过MySQL提供的几个配置参数使用的，其他什么都做不了，也就是查询缓存控制，缓存命中率等，我们都无法去控制，这一切的控制都是MySQL自己去控制的，所以我们仅仅是一个使用者而已。

而这恰好不利于我们编程和业务发展的需要，对于我们来说，查询缓存犹如一个工具一样，我们遇到什么问题，只能够提交问题给MySQL，当然也可以修改MySQL的源代码，但是这需要的能力就非常高了。

## 将缓存放在客户端的好处其实很多

现在，我们发现Redis已经非常成熟了，在项目中多多少少都会引入Redis，比如APP登录状态的保存，手机短信验证码的保存、秒杀功能等等都可以用Redis来实现。

这里引入了一个问题，就是为什么我们可以用Redis来实现这么多功能呢？其中一个最重要的原因，就是，我们控制着这一切，我们可以决定什么时候缓存失效，缓存什么数据，删除某条或者替换某条缓存条目等，当然还有很多很多控制权限，而这一切，恰好是MySQL的查询缓存无法提供的，MySQL的查询缓存相对客户端的缓存来说，真的是鸡肋。



-----

# 1.2、mysql不要使用查询缓存

查询缓存的失效非常频繁，只要有对一个表的更新，这个表上所有的查询缓存都会被清空。因此很可能你费劲的把结果存起来，还没使用呢，就被更新全清空了。对于更新压力大的数据库来说，查询缓存的命中率非常低。除非你的业务就是有一张静态表，很长时间更新一次，比如，一个系统配置表，那这张表上的查询才适合使用查询缓存。
好在mysql也提供了这种按需使用的方式，你可以将参数query_cache_type设置成DEMAND 这样对于默认的sql语句都不使用查询缓存。而对于你确定要使用查询缓存的语句，可以用SQL_CACHE显示指定，像下面这个语句一样：

```sql
select SQL_CACHE * from T where ID=10;
```

MySQL 8.0 版本直接将查询缓存的整块功能删除。



----

# 1.3、[MySQL缓存推荐使用吗_Mysql 查询缓存利弊](https://blog.csdn.net/weixin_42492215/article/details/113146346)

Mysql 查询缓存总结

## MySQL查询缓存解释

缓存完整的SELECT查询结果，也就是查询缓存。保存查询返回的完整结果。当查询命中该缓存，mysql会立刻返回结果，跳过了解析、优化和执行阶段，

查询缓存系统会跟踪查询中涉及的每个表，如果这些表发生变化，那么和这个表相关的所有数据都将失效

**命中条件**

Mysql判断缓存命中的方法很简单：缓存存放在一个引用表中，通过一个哈希值引用，这个哈希值包括如下因素，即查询本身、当前要查询的数据库、客户端协议的版本等一些都有可能影响返回结果信息。



当判断查询缓存是否命中时，Mysql不会解析、正规化或者参数化的查询语句，而是直接使用Sql语句和客户端发送过来的其他原始信息(Sql)。任何字符上的不同，例如注释，任何的不同都会导致缓存不命中，所以在编写Sql语句的时候，需要特别注意这一点，通常使用统一的编码规则是一个好的习惯，在这里这个好习惯可能让你的系统运行的更快

当查询语句有一些不确定的数据时，则不会被缓存，例如白喊函数NOW()或者CURRENTDATE()的查询不会被缓存

如果查询语句中包含任何不确定的函数，那么在查询缓存中是不可能找到缓存结果的，即使之前刚刚执行这样的查询

**导致没有命中条件**

1、缓存碎片

2、内存不足

3、数据修改

特别注意

Mysql的查询缓存在很多时候可以提升查询性能，在使用的时候，有一些问题需要特别注意。首先，打开查询缓存对 读，写 操作都会带来额外的消耗：

1、读查询在开始之前必须先检查是否命中缓存

2、如果这个读查询可以被缓存，那么当完成执行后，Mysql若发现查询缓存中没有这个查询，会将其结果存入查询缓存，这会带来额外的系统开销

3、这对写操作也会影响，因为当向某个表写入数据的时候，Mysql必须将对应表的所有缓存都设置失效。

4、对于存储引擎InnoDB用户来说，事务的一些特性会限制查询缓存的作用。当一个语句在事务中修改某个表，Mysql会将这个表对应的查询缓存都设置失效。在事务提交前该表的查询都无法被缓存，只能在事务提交后才能被缓存。因此长时间运行的事务，会大大降低查询缓存的命中率

5、inner JOIN 和 其他连接 查询 如果其中一个表数据发生变化 则直接导致 缓存失效

## 缓存配置参数

query_cache_type: 是否打开缓存

可选项

1) OFF: 关闭

2) ON: 总是打开

3) DEMAND: 只有明确写了SQL_CACHE的查询才会吸入缓存

如果不想所有查询都进入查询缓存，但是又希望某些查询走查询缓存，那么可以将 query_cache_type 设置成  DEMAND ，然后在希望缓存的查询上加上SQL_CACHE。这虽然需要在查询中加入额外的语法，但是可以让你非常自由的控制那些查询需要被缓存。相反如果不希望缓存 加上SQL_NO_CACHE



------

# 1.4、[MySQL的查询缓存和Buffer Pool的区别](http://www.cppcns.com/shujuku/mysql/366413.html)

**==首先：查询缓存和Buffer Pool不是同一个东西，前者位于服务层，后者位于存储引擎层是InnoDB实现的缓冲池==**

**一、Caches - 查询缓存**

下图是[mysql](http://www.cppcns.com/shujuku/mysql/)官网给出的：MySQL架构体系图。

人们常说的查询缓存就是下图中的Cache部分。

如果将MySQL分成 Server层和存储引擎层两大部分，那么**==Caches位于Server层。==**

![MySQL的查询缓存和Buffer Pool](MySQL架构原理.assets/gfm3srwrcqf.png)

另外你还得知道：

当一个SQL打向MySQL Server之后，MySQL Server首选会从查询缓存中查看是否曾经执行过这个SQL，如果曾经执行过的话，之前执行的查询结果会以Key-Value的形式保存在查询缓存中。key是SQL语句，value是查询结果。我们将这个过程称为查询缓存！

如果查询缓存中没有你要找的数据的话，MySQL才会执行后续的逻辑，通过存储引擎将数据检索出来。并且查询缓存会被shared cache for sessions，是的，它会被所有的session共享。

查询缓存的缺点：

只要有一个sql update了该表，那么表的查询缓存就会失效。所以当你的业务对表CRUD的比例不相上下，那么查询缓存may be会影响应用的吞吐效率。

你可以通过参数 query_chache_type=demand禁用查询缓存。并且在mysql8.0的版本中，已经将查询缓存模块删除了。

所以，你可以根据自己的情况考虑一下有没有必要禁用个功能

![MySQL的查询缓存和Buffer Pool](MySQL架构原理.assets/re2d02euc2y.png)

**二、Buffer Pool**

还是那句话：如果将MySQL分成 Server层和存储引擎层两大部分，那么**==Buffer Pool位于存储引擎层。==**

其实大家都知道无论是连接池也好、缓存池也好，只要是XXX池，都是为加速而设计的。比如[操作系统](http://www.cppcns.com/os/)的文件系统为了加快数据的读取速度，每次都做低效率的磁盘随机IO设计了缓冲写机制。

![MySQL的查询缓存和Buffer Pool](MySQL架构原理.assets/bhsi0jbi550.png)

而Buffer Pool就是MySQL存储引擎为了加速数据的读取速度而设计的缓冲机制。下图中的灰色部分就是BufferPool的脑图。（字是真迹，非常之秀气！）

以上就是MySQL的查询缓存和Buffer Pool的详细内容，更多关于MySQL 查询缓存和Buffer Pool的资料请关注我们其它相关文章！



# 二、[InnoDB 对 Buffer Pool 的奇思妙想](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054938&idx=1&sn=3cf39464e9589caf9c1c34053372b8cd&scene=21#wechat_redirect)

## 前言 

相信很多小伙伴在面试中都被问过「为什么要用缓存？」，大部分人都是回答：「减少数据库的磁盘`IO`压力」。

但是`MySQL`真的有如此不堪吗？

每次增删改查都要去走磁盘`IO`吗？

今天就聊聊`InnoDB`对`Buffer Pool`的奇思妙想。

## Buffer Pool

先梳理出问题，再思考如何解决问题。

假设我们就是`InnoDB`，我们要如何去解决磁盘`IO`问题？

这个简单，做缓存就好了，所以`MySQL`需要申请一块内存空间，这块内存空间称为`Buffer Pool`。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzrwsV4W0iagzHRStB22JelLrTX4miaicVNyMG8OSAHG0KWrsoMica6nvvug/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

`Buffer Pool`是申请下来了，但是`Buffer Pool`里面放什么，要怎么规划？

## 缓存页

`MySQL`数据是以页为单位，每页默认`16KB`，称为数据页，在`Buffer Pool`里面会划分出若干**个缓存页**与数据页对应。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSz7UHKNLm8PaWmBEVHGJFxI7ib2JzsIETgtwpPxltetKVn3hs91ZXSn9Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

感觉还少了点什么，我们如何知道缓存页对应那个数据页呢？

## 描述数据

所有还需要缓存页的元数据信息，可以称为**描述数据**，它与缓存页一一对应，包含一些所属表空间、数据页的编号、`Buffer Pool`中的地址等等。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzpjGX3qfibNtulxQCjAMkTibvH3sKko21up0rjn4hRM8v3icrKQQvTN6CQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

后续对数据的增删改查都是在`Buffer Pool`里操作

- 查询：从磁盘加载到缓存，后续直接查缓存
- 插入：直接写入缓存
- 更新删除：缓存中存在直接更新，不存在加载数据页到缓存更新

可能有小伙伴担心，`MySQL`宕机了，数据不就全丢了吗？

这个不用担心，因为`InnoDB`提供了`WAL`技术（Write-Ahead Logging），通过`redo log`让`MySQL`拥有了崩溃恢复能力。

再配合空闲时，会有异步线程做缓存页刷盘，保证数据的持久性与完整性。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzVadY8m1MQ7KtjFzy5sEAdpLKIblbDQIEiauM7sKUUB5Emo3khh69uGA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

如果不能理解`redo log`是如何恢复数据的，可以看看阿星前面两篇文章

- [02.浅谈 MySQL InnoDB 的内存组件](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054485&idx=1&sn=cd6bead326dc5f5d8cf6af16893e9676&scene=21#wechat_redirect)
- [03.聊聊redo log是什么？](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054699&idx=1&sn=018017d9f3a61ca284970bbf65ea5138&scene=21#wechat_redirect)

另外，直接更新数据的缓存页称为**脏页**，缓存页刷盘后称为**干净页**

## Free链表

`MySQL`数据库启动时，按照设置的`Buffer Pool`大小，去找操作系统申请一块内存区域，作为`Buffer Pool`（**假设申请了512MB**）。

申请完毕后，会按照默认缓存页的`16KB`以及对应的`800Byte`的描述数据，在`Buffer Pool`中划分出来一个一个的缓存页和它们对应的描述数据。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzISr1h07a3KOvFYFOPlEALTBRicfCTX2RHemYVHeLnVdGLKsVj3H1PGQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

`MySQL`运行起来后，会不停的执行增删改查，需要从磁盘读取一个一个的数据页放入`Buffer Pool`对应的缓存页里，把数据缓存起来，以后就可以在内存里执行增删改查。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzYKwkB2bGugr1cTbe6YJztxrzwvwaZWkfWyN4mmhFhVia5lhU4qYVP6Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

但是这个过程必然涉及一个问题，**哪些缓存页是空闲的**？

为了解决这个问题，我们使用链表结构，把空闲缓存页的**描述数据**放入链表中，这个链表称为`free`链表。

针对`free`链表我们要做如下设计

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzwic43rpiawNO5ntkqpmymPK4ddYwgAIB1z173rD1vtzMuibMWicNkBibV2Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

- 新增`free`基础节点
- 描述数据添加`free`节点指针

最终呈现出来的，是由空闲缓存页的**描述数据**组成的`free`链表。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzW4KseSdGVoLm0DqrYC6N0kkW1ls2lOjdaibhFiaNr5MqD4Qbo6sQibAsA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

有了`free`链表之后，我们只需要从`free`链表获取一个**描述数据**，就可以获取到对应的缓存页。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzf4zVDNmqbKDXbl45VE4C9fRl7uLMlfibraBSQrl6Vyp8V8AYVmgdia3w/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

往**描述数据**与**缓存页**写入数据后，就将该**描述数据**移出`free`链表。

## 缓存页哈希表

数据页是缓存进去了，但是又一个问题来了。

下次查询数据时，如何在`Buffer Pool`里快速定位到对应的缓存页呢？

难道需要一个**非空闲的描述数据**链表，再通过**表空间号+数据页编号**遍历查找吗？

这样做也可以实现，但是效率不太高，时间复杂度是`O(N)`。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSz247HiaLyA5PGruyldYCAZ7TA5mZSqKAlwS3MbpKeVE7FNaoWiav55BYQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

所以我们可以换一个结构，使用哈希表来缓存它们间的映射关系，时间复杂度是`O(1)`。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzdaQ9TAP6m07jrcMAMGh8pUw8Hzlj1HBZ8XMrOXZfoicfIEoQ227KU2w/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

**表空间号+数据页号**，作为一个`key`，然后缓存页的地址作为`value`。

每次加载数据页到空闲缓存页时，就写入一条映射关系到**缓存页哈希表**中。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzPfxia6zvzUqI4SJD9PpSVavh5sEFF0HGkdR9gAWNA1Ooa3G3QYeouIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

后续的查询，就可以通过**缓存页哈希表**路由定位了。

## Flush链表

还记得之前有说过「**空闲时会有异步线程做缓存页刷盘，保证数据的持久性与完整性**」吗？

新问题来了，难道每次把`Buffer Pool`里所有的缓存页都刷入磁盘吗？

当然不能这样做，磁盘`IO`开销太大了，应该把**脏页**刷入磁盘才对（更新过的缓存页）。

可是我们怎么知道，那些缓存页是**脏页**？

很简单，参照`free`链表，弄个`flush`链表出来就好了，只要缓存页被更新，就将它的**描述数据**加入`flush`链表。

针对`flush`链表我们要做如下设计

- 新增`flush`基础节点
- 描述数据添加`flush`节点指针

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSz2k4gicPfHicSqcHqeTtFGH9Pb7n1Wxo0pRETAZJtszz9xhd3kULstz1Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

最终呈现出来的，是由更新过数据的缓存页**描述数据**组成的`flush`链表。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSz79jHx0d2xicwGHvdAFZlckSdwgoMWHbFTjwml1HmbVwcUrzFTJCTonA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

后续异步线程都从`flush`链表刷缓存页，当`Buffer Pool`内存不足时，也会优先刷`flush`链表里的缓存页。

## LRU链表

目前看来`Buffer Pool`的功能已经比较完善了。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzg2yibXsUFugyX1h0ZT1ct5ec4hWeqcUdlKEOHf9ic9Cc2EBIUXIvia4lA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

但是仔细思考下，发现还有一个问题没处理。

`MySQL`数据库随着系统的运行会不停的把磁盘上的数据页加载到空闲的缓存页里去，因此`free`链表中的空闲缓存页会越来越少，直到没有，最后磁盘的数据页无法加载。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzMcVVTk5SXaNgUppwdYRrXjE3bzFSg4vZeU8C5MdXukUicSzAItmEKqw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

为了解决这个问题，我们需要淘汰缓存页，腾出空闲缓存页。

可是我们要优先淘汰那些缓存页？总不能一股脑直接全部淘汰吧？

这里就要借鉴`LRU`算法思想，把最少使用的缓存页淘汰（命中率低），提供`LRU`链表出来。

针对`LRU`链表我们要做如下设计

- 新增`LRU`基础节点
- 描述数据添加`LRU`节点指针

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzOMdrlAGb7xNyibq6GrZicDsJbjg5P0HvRJnxENdZnD3icNC6bia1RBK5ZQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

实现思路也很简单，只要是查询或修改过缓存页，就把该缓存页的描述数据放入链表头部，也就说近期访问的数据一定在链表头部。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSz7baibQA3lUtkbvibOctreMl8wK21DBuTWvqfL12hSO3lwliajicAlZdA1Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

当`free`链表为空的时候，直接淘汰`LRU`链表尾部缓存页即可。

## LRU链表优化

麻雀虽小五脏俱全，基本`Buffer Pool`里与缓存页相关的组件齐全了。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzW0ToicMUfI2CjMJ6dsZcy3VvXF1RsWbQOIkmdB6LqqBib0G55ia7Tu1ng/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

但是缓存页淘汰这里还有点问题，如果仅仅只是使用`LRU`链表的机制，有两个场景会让**热点数据**被淘汰。

- **预读机制**
- **全表扫描**

预读机制是指`MySQL`加载数据页时，可能会把它相邻的数据页一并加载进来（局部性原理）。

这样会带来一个问题，预读进来的数据页，其实我们没有访问，但是它却排在前面。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSz9YnRHPpZBwCgics3UXVibtZdGOJnUfrvkdU2bmMZW0NPhUSj27P37vwg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

正常来说，淘汰缓存页时，应该把这个预读的淘汰，结果却把尾部的淘汰了，这是不合理的。

我们接着来看第二个场景全表扫描，如果**表数据量大**，大量的数据页会把空闲缓存页用完。

最终`LRU`链表前面都是全表扫描的数据，之前频繁访问的热点数据全部到队尾了，淘汰缓存页时就把**热点数据页**给淘汰了。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzN6rP6mMyb4Xm77xaq6uFMuibExtlXiaYt1PS3GSFWhLnB6wyXt8CMXoA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

为了解决上述的问题。

我们需要给`LRU`链表做冷热数据分离设计，把`LRU`链表按一定比例，分为冷热区域，热区域称为`young`区域，冷区域称为`old`区域。

**以7:3为例，young区域70%，old`区域30%**

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nzibSg1dO1RTZY5uYMEsAgSzk1DKfvTzGyQVv6ZKWmR7cFRSFy3B2VWNqksred9hUjw7vWic1iayUMjA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

如上图所示，数据页第一次加载进缓存页的时候，是先放入冷数据区域的头部，如果1秒后再次访问缓存页，则会移动到热区域的头部。

这样就保证了**预读机制**与**全表扫描**加载的数据都在链表队尾。

`young`区域其实还可以做一个小优化，为了防止`young`区域节点频繁移动到表头。

`young`区域前面`1/4`被访问不会移动到链表头部，只有后面的`3/4`被访问了才会。

> 记住是按照某个比例将`LRU`链表分成两部分，不是某些节点固定是`young`区域的，某些节点固定是`old`区域的，随着程序的运行，某个节点所属的区域也可能发生变化。

## 小结

其实`MySQL`就是这样实现`Buffer Pool`缓存页的，只不过它里面的链表全**是双向链表**，阿星这里偷个懒，但是不影响理解思路。

读到这里，我相信大家对`Buffer Pool`缓存页有了深刻的认知，也知道从一个增删改查开始，如何缓存数据、定位缓存、缓存刷盘、缓存淘汰。

这里留问题给大家思考，`Free、Flush、LRU`这三个链表之间的联系，随着`MySQL`一直在运行，它们会产生怎样的联动。

## MySQL好文推荐

- [1-CURD这么多年，你有了解过MySQL的架构设计吗？](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054134&idx=1&sn=79c0e8f7933815d822d9c2a36dc77401&scene=21#wechat_redirect)
- [2-浅谈 MySQL InnoDB 的内存组件](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054485&idx=1&sn=cd6bead326dc5f5d8cf6af16893e9676&scene=21#wechat_redirect)
- [3-聊聊redo log是什么？](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054699&idx=1&sn=018017d9f3a61ca284970bbf65ea5138&scene=21#wechat_redirect)
- [4-不会吧，不会吧，还有人不知道 binlog ？](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054835&idx=1&sn=cf863301f04d82f0c6ad4308ec8a55a3&scene=21#wechat_redirect)
- [5-redo log与binlog间的破事](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054869&idx=1&sn=b7ca964517c40a7ef990760ff659ac65&scene=21#wechat_redirect)



------

# 2.1、[缓冲池(buffer pool)，这次彻底懂了！！！](https://blog.csdn.net/wuhenyouyuyouyu/article/details/93377605)

![img](https://img-blog.csdnimg.cn/20190623074736592.jpg)

应用系统分层[架构](https://so.csdn.net/so/search?q=架构&spm=1001.2101.3001.7020)，为了加速数据访问，会把最常访问的数据，放在**缓存**(cache)里，避免每次都去访问数据库。

 

操作系统，会有**缓冲池**([buffer](https://so.csdn.net/so/search?q=buffer&spm=1001.2101.3001.7020) pool)机制，避免每次访问磁盘，以加速数据的访问。

 

MySQL作为一个存储系统，同样具有**缓冲池**(buffer pool)机制，以避免每次查询数据都进行磁盘IO。

 

今天，和大家聊一聊InnoDB的缓冲池。

 

## InnoDB的缓冲池缓存什么？有什么用？

缓存表数据与索引数据，把磁盘上的数据加载到缓冲池，避免每次访问都进行磁盘IO，起到加速访问的作用。

 

速度快，那**为啥不把所有数据都放到缓冲池里**？

凡事都具备两面性，抛开数据易失性不说，访问快速的反面是存储容量小：

（1）缓存访问快，但容量小，数据库存储了200G数据，缓存容量可能只有64G；

（2）内存访问快，但容量小，买一台笔记本磁盘有2T，内存可能只有16G；

因此，只能把“最热”的数据放到“最近”的地方，以“最大限度”的降低磁盘访问。

 

## 如何管理与淘汰缓冲池，使得性能最大化呢？

 

在介绍具体细节之前，先介绍下“预读”的概念。

 

### **什么是预读？**

磁盘读写，并不是按需读取，而是按页读取，一次至少读一页数据（一般是4K），如果未来要读取的数据就在页中，就能够省去后续的磁盘IO，提高效率。

 

### **预读为什么有效？**

数据访问，通常都遵循“集中读写”的原则，使用一些数据，大概率会使用附近的数据，这就是所谓的“局部性原理”，它表明提前加载是有效的，确实能够减少磁盘IO。

 

### **按页(4K)读取，和InnoDB的缓冲池设计有啥关系？**

（1）磁盘访问按页读取能够提高性能，所以缓冲池一般也是按页缓存数据；

（2）预读机制启示了我们，能把一些“可能要访问”的页提前加入缓冲池，避免未来的磁盘IO操作；

 

### **InnoDB是以什么算法，来管理这些缓冲页呢？**

最容易想到的，就是LRU(Least recently used)。

*画外音：memcache，OS都会用LRU来进行页置换管理，但MySQL的玩法并不一样。*

 

### **传统的LRU是如何进行缓冲页管理？**

 

最常见的玩法是，把入缓冲池的页放到LRU的头部，作为最近访问的元素，从而最晚被淘汰。这里又分两种情况：

（1）**页已经在缓冲池里**，那就只做“移至”LRU头部的动作，而没有页被淘汰；

（2）**页不在缓冲池里**，除了做“放入”LRU头部的动作，还要做“淘汰”LRU尾部页的动作；

 

![img](https://img-blog.csdnimg.cn/20190623074749333.jpg)

如上图，假如管理缓冲池的LRU长度为10，缓冲了页号为1，3，5…，40，7的页。

 

假如，接下来要访问的数据在页号为4的页中：

![img](https://img-blog.csdnimg.cn/20190623074758330.jpg)

（1）页号为4的页，本来就在缓冲池里；

（2）把页号为4的页，放到LRU的头部即可，没有页被淘汰；

*画外音：为了减少数据移动，LRU一般用链表实现。*

 

假如，再接下来要访问的数据在页号为50的页中：

![img](https://img-blog.csdnimg.cn/20190623074806789.jpg)

（1）页号为50的页，原来不在缓冲池里；

（2）把页号为50的页，放到LRU头部，同时淘汰尾部页号为7的页；

 

**传统的LRU缓冲池算法十分直观**，OS，memcache等很多软件都在用，**MySQL为啥这么矫情，不能直接用呢？**

这里有两个问题：

（1）预读失效；

（2）缓冲池污染；

 

### **什么是预读失效？**

由于预读(Read-Ahead)，提前把页放入了缓冲池，但最终MySQL并没有从页中读取数据，称为预读失效。

 

### **如何对预读失效进行优化？**

要优化预读失效，思路是：

（1）让预读失败的页，停留在缓冲池LRU里的时间尽可能短；

（2）让真正被读取的页，才挪到缓冲池LRU的头部；

以保证，真正被读取的热数据留在缓冲池里的时间尽可能长。

 

具体方法是：

（1）将LRU分为两个部分：

- 新生代(new sublist)
- 老生代(old sublist)

（2）新老生代收尾相连，即：新生代的尾(tail)连接着老生代的头(head)；

（3）新页（例如被预读的页）加入缓冲池时，只加入到老生代头部：

- 如果数据真正被读取（预读成功），才会加入到新生代的头部
- 如果数据没有被读取，则会比新生代里的“热数据页”更早被淘汰出缓冲池

 

![img](https://img-blog.csdnimg.cn/20190623074817728.jpg)

举个例子，整个缓冲池LRU如上图：

（1）整个LRU长度是10；

（2）前70%是新生代；

（3）后30%是老生代；

（4）新老生代首尾相连；

 

![img](https://img-blog.csdnimg.cn/20190623074827311.jpg)

假如有一个页号为50的新页被预读加入缓冲池：

（1）50只会从老生代头部插入，老生代尾部（也是整体尾部）的页会被淘汰掉；

（2）假设50这一页不会被真正读取，即预读失败，它将比新生代的数据更早淘汰出缓冲池；

 

![img](https://img-blog.csdnimg.cn/20190623074837532.jpg)

假如50这一页立刻被读取到，例如SQL访问了页内的行row数据：

（1）它会被立刻加入到新生代的头部；

（2）新生代的页会被挤到老生代，此时并不会有页面被真正淘汰；

 

改进版缓冲池LRU能够很好的解决“预读失败”的问题。

*画外音：但也不要因噎废食，因为害怕预读失败而取消预读策略，大部分情况下，局部性原理是成立的，预读是有效的。*

 

新老生代改进版LRU仍然解决不了缓冲池污染的问题。

 

### **什么是MySQL缓冲池污染？**

当某一个SQL语句，要批量扫描大量数据时，可能导致把缓冲池的所有页都替换出去，导致大量热数据被换出，MySQL性能急剧下降，这种情况叫缓冲池污染。

 

例如，有一个数据量较大的用户表，当执行：

select * from user where name like "%shenjian%";

虽然结果集可能只有少量数据，但这类like不能命中索引，必须全表扫描，就需要访问大量的页：

（1）把页加到缓冲池（插入老生代头部）；

（2）从页里读出相关的row（插入新生代头部）；

（3）row里的name字段和字符串shenjian进行比较，如果符合条件，加入到结果集中；

（4）…直到扫描完所有页中的所有row…

 

如此一来，所有的数据页都会被加载到新生代的头部，但只会访问一次，真正的热数据被大量换出。

 

### **怎么这类扫码大量数据导致的缓冲池污染问题呢？**

MySQL缓冲池加入了一个“老生代停留时间窗口”的机制：

（1）假设T=老生代停留时间窗口；

（2）插入老生代头部的页，即使立刻被访问，并不会立刻放入新生代头部；

（3）只有**满足**“被访问”并且“在老生代停留时间”大于T，才会被放入新生代头部；

 

![img](https://img-blog.csdnimg.cn/20190623074849150.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3d1aGVueW91eXV5b3V5dQ==,size_16,color_FFFFFF,t_70)

继续举例，假如批量数据扫描，有51，52，53，54，55等五个页面将要依次被访问。

 

![img](https://img-blog.csdnimg.cn/20190623074859563.jpg)

如果没有“老生代停留时间窗口”的策略，这些批量被访问的页面，会换出大量热数据。

 

![img](https://img-blog.csdnimg.cn/20190623074908860.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3d1aGVueW91eXV5b3V5dQ==,size_16,color_FFFFFF,t_70)

加入“老生代停留时间窗口”策略后，短时间内被大量加载的页，并不会立刻插入新生代头部，而是优先淘汰那些，短期内仅仅访问了一次的页。

 

![img](https://img-blog.csdnimg.cn/20190623074920619.jpg)

而只有在老生代呆的时间足够久，停留时间大于T，才会被插入新生代头部。

 

### **上述原理，对应InnoDB里哪些参数？**

有三个比较重要的参数。

![img](https://img-blog.csdnimg.cn/20190623074939211.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3d1aGVueW91eXV5b3V5dQ==,size_16,color_FFFFFF,t_70)

**参数**：innodb_buffer_pool_size

**介绍**：配置缓冲池的大小，在内存允许的情况下，DBA往往会建议调大这个参数，越多数据和索引放到内存里，数据库的性能会越好。

 

**参数**：innodb_old_blocks_pct

**介绍**：老生代占整个LRU链长度的比例，默认是37，即整个LRU中新生代与老生代长度比例是63:37。

*画外音：如果把这个参数设为100，就退化为普通LRU了。*

 

**参数**：innodb_old_blocks_time

**介绍**：老生代停留时间窗口，单位是毫秒，默认是1000，即同时满足“被访问”与“在老生代停留时间超过1秒”两个条件，才会被插入到新生代头部。

 

**总结**

（1）缓冲池(buffer pool)是一种**常见的降低磁盘访问的机制；**

（2）缓冲池通常**以页(page)为单位缓存数据；**

（3）缓冲池的**常见管理算法是LRU**，memcache，OS，InnoDB都使用了这种算法；

（4）InnoDB对普通LRU进行了优化：

- 将缓冲池分为**老生代和新生代**，入缓冲池的页，优先进入老生代，页被访问，才进入新生代，以解决预读失效的问题
- 页被访问，且在老生代**停留时间超过配置阈值**的，才进入新生代，以解决批量数据访问，大量热数据淘汰的问题



------

# 2.2、[理解Mysql中的Buffer pool](https://www.cnblogs.com/wxlevel/p/12995324.html)

### Buffer Pool在数据库里的地位

#### 1、回顾一下Buffer Pool是个什么东西？

数据库中的Buffer Pool是个什么东西？其实他是一个非常关键的组件，数据库中的数据实际上最终都是要存放在磁盘文件上的，如下图所示。

![img](MySQL架构原理.assets/565213-20200530221711156-63363016.png)

 

 

但是我们在对数据库执行增删改操作的时候，不可能直接更新磁盘上的数据的，因为如果你对磁盘进行随机读写操作，那速度是相当的慢，随便一个大磁盘文件的随机读写操作，可能都要几百毫秒。如果要是那么搞的话，可能你的数据库每秒也就只能处理几百个请求了！ 在对数据库执行增删改操作的时候，实际上主要都是针对内存里的Buffer Pool中的数据进行的，也就是实际上主要是对数据库的内存里的数据结构进行了增删改，如下图所示。

![img](MySQL架构原理.assets/565213-20200530221806004-1279067567.png)

 

 

其实每个人都担心一个事，就是你在数据库的内存里执行了一堆增删改的操作，内存数据是更新了，但是这个时候如果数据库突然崩溃了，那么内存里更新好的数据不是都没了吗？ MySQL就怕这个问题，所以引入了一个redo log机制，你在对内存里的数据进行增删改的时候，他同时会把增删改对应的日志写入redo log中，如下图。

![img](MySQL架构原理.assets/565213-20200530221829286-1677247683.png)

 

 

万一你的数据库突然崩溃了，没关系，只要从redo log日志文件里读取出来你之前做过哪些增删改操作，瞬间就可以重新把这些增删改操作在你的内存里执行一遍，这就可以恢复出来你之前做过哪些增删改操作了。 当然对于数据更新的过程，他是有一套严密的步骤的，还涉及到undo log、binlog、提交事务、buffer pool脏数据刷回磁盘，等等。

#### 2、Buffer Pool的一句话总结

Buffer Pool是数据库中我们第一个必须要搞清楚的核心组件，因为增删改操作首先就是针对这个内存中的Buffer Pool里的数据执行的，同时配合了后续的redo log、刷磁盘等机制和操作。

所以Buffer Pool就是数据库的一个内存组件，里面缓存了磁盘上的真实数据，然后我们的系统对数据库执行的增删改操作，其实主要就是对这个内存数据结构中的缓存数据执行的。

 

### Buffer Pool这个内存数据结构到底长个什么样子？

#### 1、如何配置你的Buffer Pool的大小？

我们应该如何配置你的Buffer Pool到底有多大呢？ 因为Buffer Pool本质其实就是数据库的一个内存组件，你可以理解为他就是一片内存数据结构，所以这个内存数据结构肯定是有一定的大小的，不可能是无限大的。 这个Buffer Pool默认情况下是128MB，还是有一点偏小了，我们实际生产环境下完全可以对Buffer Pool进行调整。 比如我们的数据库如果是16核32G的机器，那么你就可以给Buffer Pool分配个2GB的内存，使用下面的配置就可以了。 [server] innodb_buffer_pool_size = 2147483648 如果你不知道数据库的配置文件在哪里以及如何修改其中的配置，那建议可以先在网上搜索一些MySQL入门的资料去看看，其实这都是最基础和简单的。 我们先来看一下下面的图，里面就画了数据库中的Buffer Pool内存组件

![img](MySQL架构原理.assets/565213-20200530221911867-699778805.png)

 

 

#### 2、数据页：MySQL中抽象出来的数据单位

假设现在我们的数据库中一定有一片内存区域是Buffer Pool了，那么我们的数据是如何放在Buffer Pool中的？

我们都知道数据库的核心数据模型就是 **表+字段+行** 的概念，所以大家觉得我们的数据是一行一行的放在Buffer Pool里面的吗？ 这就明显不是了，实际上MySQL对数据抽象出来了一个数据页的概念，他是把很多行数据放在了一个数据页里，也就是说我们的磁盘文件中就是会有很多的数据页，每一页数据里放了很多行数据，如下图所示。

![img](MySQL架构原理.assets/565213-20200530221947855-1142259474.png)

 

 

所以实际上假设我们要更新一行数据，此时数据库会找到这行数据所在的数据页，然后从磁盘文件里把这行数据所在的数据页直接给加载到Buffer Pool里去。 也就是说，Buffer Pool中存放的是一个一个的数据页，如下图。

![img](MySQL架构原理.assets/565213-20200530222004474-2016283999.png)

 

 

 

#### 3、磁盘上的数据页和Buffer Pool中的缓存页是如何对应起来的？

实际上默认情况下，磁盘中存放的数据页的大小是16KB，也就是说，一页数据包含了16KB的内容。 而Buffer Pool中存放的一个一个的数据页，我们通常叫做缓存页，因为毕竟Buffer Pool是一个缓冲池，里面的数据都是从磁盘缓存到内存去的。 而Buffer Pool中默认情况下，一个缓存页的大小和磁盘上的一个数据页的大小是一一对应起来的，都是16KB。 我们看下图，我给图中的Buffer Pool标注出来了他的内存大小，假设他是128MB吧，然后数据页的大小是16KB。

![img](MySQL架构原理.assets/565213-20200530222026232-2083340759.png)

 

 

#### 4、缓存页对应的描述信息是什么？

对于每个缓存页，他实际上都会有一个描述信息，这个描述信息大体可以认为是用来描述这个缓存页的。 比如包含如下的一些东西：这个数据页所属的表空间、数据页的编号、这个缓存页在Buffer Pool中的地址以及别的一些杂七杂八的东西。 每个缓存页都会对应一个描述信息，这个描述信息本身也是一块数据，在Buffer Pool中，每个缓存页的描述数据放在最前面，然后各个缓存页放在后面。所以此时我们看下面的图，Buffer Pool实际看起来大概长这个样子 。

![img](MySQL架构原理.assets/565213-20200530222047437-1275962071.png)

 

 

而且这里我们要注意一点，Buffer Pool中的描述数据大概相当于缓存页大小的5%左右，也就是每个描述数据大概是800个字节左右的大小，然后假设你设置的buffer pool大小是128MB，**实际上Buffer Pool真正的最终大小会超出一些，可能有个130多MB的样子，因为他里面还要存放每个缓存页的描述数据。**

#### 思考

对于Buffer Pool而言，他里面会存放很多的缓存页以及对应的描述数据，那么假设Buffer Pool里的内存都用尽了，已经没有足够的剩余内存来存放缓存页和描述数据了，此时Buffer Pool里就一点内存都没有了吗？还是说Buffer Pool里会残留一些内存碎片呢？ 如果你觉得Buffer Pool里会有内存碎片的话，那么你觉得应该怎么做才能尽可能减少Buffer Pool里的内存碎片呢？

 >ps：查找自其他网址
 >
 >高性能之内存池（频繁使用malloc和new会降低性能）
 >内存池(Memory Pool)是一种内存分配方式。通常我们习惯直接使用new、malloc等API申请分配内存，这样做的缺点在于：由于所申请内存块的大小不定，当频繁使用时会造成大量的内存碎片并进而降低性能。内存池则是在真正使用内存之前，先申请分配一定数量的、大小相等(一般情况下)的内存块留作备用。当有新的内存需求时，就从内存池中分出一部分内存块，若内存块不够再继续申请新的内存。这样做的一个显著优点是尽量避免了内存碎片，使得内存分配效率得到提升。
 >
 >（1）针对特殊情况，例如需要频繁分配释放固定大小的内存对象时，不需要复杂的分配算法和多线程保护。也不需要维护内存空闲表的额外开销，从而获得较高的性能。
 >（2）由于开辟一定数量的连续内存空间作为内存池块，因而一定程度上提高了程序局部性，提升了程序性能。
 >（3）比较容易控制页边界对齐和内存字节对齐，没有内存碎片的问题。
 >（4）当需要分配管理的内存在100M一下的时候，采用内存池会节省大量的时间，否则会耗费更多的时间。
 >（5）内存池可以防止更多的内存碎片的产生



### 在生产环境中，如何基于机器配置来合理设置Buffer Pool？

 

#### 1、生产环境中应该给buffer pool设置多少内存？

今天这篇文章我们接着上一次讲解的Buffer Pool的一些内存划分的原理，来给大家最后总结一下，在生产环境中到底应该如何设置Buffer Pool的大小呢。 首先考虑第一个问题，我们现在数据库部署在一台机器上，这台机器可能有个8G、16G、32G、64G、128G的内存大小，那么此时buffer pool应该设置多大呢？ 有的人可能会想，假设我有32G内存，那么给buffer pool设置个30GB得了，这样的话，MySQL大量的crud操作都是基于内存来执行的，性能那是绝对高！ 这么想就大错特错了，虽然你的机器有32GB的内存，但是你的操作系统内核就要用掉起码几个GB的内存！你的机器上可能还有别的东西在运行！你的数据库里除了buffer pool是不是还有别的内存数据结构！ 所以上面那种想法是绝对不可取的！ 如果你胡乱设置一个特别大的内存给buffer，会导致你的mysql启动失败的，他启动的时候就发现操作系统的内存根本不够用！ 所以通常来说，我们建议一个比较合理的、健康的比例，是给buffer pool设置你的机器内存的50%~60%左右 比如你有32GB的机器，那么给buffer设置个20GB的内存，剩下的留给OS和其他人来用，这样比较合理一些。 假设你的机器是128GB的内存，那么buffer pool可以设置个80GB左右，大概就是这样的一个规则。

 

#### 2、buffer pool总大小=(chunk大小 * buffer pool数量)的2倍数

接着确定了buffer pool的总大小之后，就得考虑一下设置多少个buffer pool，以及chunk的大小。 此时有一个很关键的公式：buffer pool总大小 = (chunk大小 * buffer pool数量) 的倍数 比如默认的chunk大小是128MB，那么此时如果你的机器的内存是32GB，你打算给buffer pool总大小在20GB左右，此时你的buffer pool的数量应该是多少个呢？

假设你的buffer pool的数量是16个，这是没问题的，那么此时chunk大小 * buffer pool的数量 = 16 * 128MB = 2048MB，然后buffer pool总大小如果是20GB，此时buffer pool总大小就是2048MB的10倍，这就符合规则了。 当然，此时你可以设置多一些buffer pool数量，比如设置32个buffer pool，那么此时buffer pool总大小（20GB）就是（chunk大小128MB * 32个buffer pool）的5倍，也是可以的。 那么此时你的buffer pool大小就是20GB，然后buffer pool数量是32个，每个buffer pool的大小是640MB，然后每个buffer pool包含5个128MB的chunk，算下来就是这么一个结果了。

 

#### 3、一点总结

数据库在生产环境运行时，必须根据机器的内存设置合理的buffer pool的大小，然后设置buffer pool的数量，这样可以尽可能的保证你的数据库的高性能和高并发能力。 在线上运行时，buffer pool是有多个的，每个buffer pool里多个chunk但是共用一套链表数据结构，然后执 行crud的时候，就会不停的加载磁盘上的数据页到缓存页里来，然后会查询和更新缓存页里的数据，同时维护一系列的链表结构。 然后后台线程定时根据lru链表和flush链表，去把一批缓存页刷入磁盘释放掉这些缓存页，同时更新free链表。 如果执行crud的时候发现缓存页都满了，没法加载自己需要的数据页进缓存，此时就会把lru链表冷数据区域的缓存页刷入磁盘，然后加载自己需要的数据页进来。 整个buffer pool的结构设计以及工作原理，就是上面我们总结的这套东西了，大家只要理解了这个，首先你对MySQL执行crud的时候，是如何在内存里查询和更新数据的，你就彻底明白了。

接着我们后面继续探索undo log、redo log、事务机制、事务隔离、锁机制，这些东西，一点点就把MySQL他的数据更新、事务、锁这些原理，全部搞清楚了，同时中间再配合穿插一些生产经验、实战案例。

 

#### 4、SHOW ENGINE INNODB STATUS

当你的数据库启动之后，你随时可以通过上述命令，去查看当前innodb里的一些具体情况，执行SHOW ENGINE INNODB STATUS就可以了。此时你可能会看到如下一系列的东西：

```sql
Total memory allocated xxxx;
Dictionary memory allocated xxx
Buffer pool size xxxx
Free buffers xxx
Database pages xxx
Old database pages xxxx
Modified db pages xx
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young xxxx, not young xxx
xx youngs/s, xx non-youngs/s
Pages read xxxx, created xxx, written xxx
xx reads/s, xx creates/s, 1xx writes/s
Buffer pool hit rate xxx / 1000, young-making rate xxx / 1000 not xx / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: xxxx, unzip_LRU len: xxx
I/O sum[xxx]:cur[xx], unzip sum[16xx:cur[0]

```

下面解释一下这里的东西，主要讲解这里跟buffer pool相关的一些东西。

1. Total memory allocated，这就是说buffer pool最终的总大小是多少
2. Buffer pool size，这就是说buffer pool一共能容纳多少个缓存页
3. Free buffers，这就是说free链表中一共有多少个空闲的缓存页是可用的
4. Database pages和Old database pages，就是说lru链表中一共有多少个缓存页，以及冷数据区域里的缓存页数量
5. Modified db pages，这就是flush链表中的缓存页数量
6. Pending reads和Pending writes，等待从磁盘上加载进缓存页的数量，还有就是即将从lru链表中刷入磁盘的数量、即将从flush链表中刷入磁盘的数量
7. Pages made young和not young，这就是说已经lru冷数据区域里访问之后转移到热数据区域的缓存页的数 量，以及在lru冷数据区域里1s内被访问了没进入热数据区域的缓存页的数量
8. youngs/s和not youngs/s，这就是说每秒从冷数据区域进入热数据区域的缓存页的数量，以及每秒在冷数据区域里被访问了但是不能进入热数据区域的缓存页的数量
9. Pages read xxxx, created xxx, written xxx，xx reads/s, xx creates/s, 1xx writes/s，这里就是说已经读取、创建和写入了多少个缓存页，以及每秒钟读取、创建和写入的缓存页数量
10. Buffer pool hit rate xxx / 1000，这就是说每1000次访问，有多少次是直接命中了buffer pool里的缓存的
11. young-making rate xxx / 1000 not xx / 1000，每1000次访问，有多少次访问让缓存页从冷数据区域移动到了热数据区域，以及没移动的缓存页数量
12. LRU len：这就是lru链表里的缓存页的数量
13. I/O sum：最近50s读取磁盘页的总数
14. I/O cur：现在正在读取磁盘页的数量



---

# 2.3、[MySQL 8.0 Buffer pool 结构](https://zhuanlan.zhihu.com/p/146325697)

## Buffer Pool 简介

- CPU通过总线直接访问内存。CPU不能直接访问或修改数据库文件。

- 在操作数据前，数据必须从数据库文件加载到内存中。

- 每次要操作数据时，都从数据库文件中加载数据，效率低。

- 因此，在内存中缓存相关的数据，会是一个更好的选择。

- Innodb用buffer pool组件解决数据缓存的问题。Innodb中可以有多个buffer pool实例。

- page和frame中的数据相同。数据在数据库文件中，就叫page。数据在buffer pool中就叫frame。

- 每个buffer pool由以下几个组件构成:

- - 一个或多个buffer chunks: chunk中由多个frame（帧，一块内存），其能保存数据。每个帧由独立的控制块。
  - free list: 未被使用的frame都链在free list。
  - lru list: 所有保存数据的帧（未被修改或已被修改）都链在lru list。
  - flush list: 所有保存被修改的数据的帧都链在flush list。在flush list中的frame同样也在lru list中。
  - page hash表: hash表用于加速在lru list中查找帧。
  - 双写缓冲区double write buffer: 独立于buffer chunk的一块内存，保存将要被刷新到文件中的frame。
  - Mutexes: 在并发环境中保存上面的各种list。innodb没有直接使用系统提供的mutex（类型pthread），而是单独开发了一套复杂的mutex系统。
  - 页清理线程Page Cleaner Thread: 首先，它将脏frame刷新到double write buffer。用同步模式将这些frame刷新到文件中的专有空间。其次，用异步模式将它们写到数据库文件。
  - 预读Read ahead: 页预读提高读页效率。



![img](MySQL架构原理.assets/v2-2f17bca47125327206025fb8f45b29e7_720w.jpg)Logical Buffer pool 实例结构简图

## 读取数据

- 从buffer pool中读取一个page。
- 用一个简单的算法从page中获取，page所要在的buffer pool 实例。
- 如果page在buffer pool实例的page hash表中，就能立即找到它。这意味着，page就在lru list中。数据就在page中。
- 如果page不在page hash表中。需要将page从数据库文件中读入buffer pool中。
- We need a free frame from the free list that will hold the page firstly. 首先，要从free list中获取一个空闲的frame，用于放置page中的数据。
- 当没有空闲的frame时，读取过程会失败。后面会讲失败处理。
- 准备好一个空闲frame后，文件io会用数据库中的数据填充frame。

## LRU List

- 如果lru list的长度超过512，lru list的前5/8叫young section，后3/8叫old section。
- 如果lru list的长度小于512，就只有old section。
- young section的头部1/4区域叫hot data。
- 从文件中读取的frame，首先会被放到old section。
- 如果再次访问frame，frame会从old section移动到young section的头部。
- 但是，如果frame已在young section的hot section中，访问frame后，frame不会再移动到young section的头部。
- 只有当frame在young section的尾部，在访问frame后，frame才会被移动到young section的头部。

![img](MySQL架构原理.assets/v2-c2d9c68438e3db22ea46bd9ee73ee531_720w.jpg)lru list分区

## 取空闲frame

- 第0次迭代:

- - 如果free list有frame，取一个frame就成。
  - And we get the free frame again.如果没有，扫描lru list的尾部，找到一个未用的page。获取此page，并将其返回到free list中。
  - 这可能会再次失败。从lru list的尾部刷新一个page到文件中。将page放到free list中。再次取空闲frame。
  - 同样，可能会再次失败。进行下一个迭代。

- 第1次迭代: 与迭代0几乎相同，除了这次要扫描整个lru list。如果再找不到空闲frame。进行下一个迭代，并且再试一次。

- 大于1次迭代: 与迭代1几乎相同，除了在刷数据前先sleep 10ms。

- 大于20次迭代: Print the error log for an unavailable free frame. 为一个不可得的空闲frame输出错误信息。

## 驱逐frame

- 首先，尝试从unzip lru list中，取一个压缩块的解压page，将其释放掉。压缩page被保留。决定选择哪个解压page的算法很复杂。之后，尝试从lru list中释放一个干净的page。
- 如果用上面的算法，得不到空闲frame，此时需要刷脏frame。但是，在用户线程中，我们每次从lru list的尾部选择一个page。如果此page脏的，将其刷新并将其放入free list。

## 清理page

- page cleaner线程后台周期刷新page。
- It puts replaceable pages at the tail of the lru list to the free list and flushes dirty pages at the tail of the lru list to the disk, then puts pages into the free list. 它将lru list尾部的可替换page放到free list中，并且将lru list的尾部脏page刷到磁盘，之后将page放到free list。
- 有多个page cleaner线程。之一除了刷页之外还作管理，其它的都是工作线程。

## 双写缓冲区 Double Write Buffer

- 先将脏page刷入double write buffer。
- 用同步IO，将这些frame刷新到系统空间的文件中。
- 那么，系统空间的文件中就有了完整的frame。
- 再用异步IO将这些脏page刷新到表空间中。
- 异步IO完成刷新工作后，再检查数据的安全性，并将刷新过的page放到free list。

![img](MySQL架构原理.assets/v2-46f3528359b8b764cd5ad6c7293d35cf_720w.jpg)double write buffer内部分成两部分

## 文件IO

- 精心设计的文件io是Innodb的基础组件。
- 两种io模式：同步io和异步io。
- 同步io基于pread/pwrite函数，并总是被用户线程所执行。
- 异步io（AIO）有两种实现方法。模拟AIO和Linux系统AIO。
- 模拟AIO包括四种后台io线程，分别用于ibuf，log，读和写。异步请求被用户线程排队进入为io线程准备的独立数组。之后，用户线程返回。之后io线程会用同步io方式处理这些请求。
- libaio库，支持Linux上的AIO，也需要一个帮助线程，在后台，对四个数组进行处理。用户线程排队AIO请求并提交给系统。帮助线程仅需要收集完成的IO请求，并调用其上的完成回调函数。





-----

# 一、[InnoDB原理篇：如何用好索引](https://mp.weixin.qq.com/s/SvNp3Z9Z-tWcD5KNV53bIA)

# 前言

**大家好，我是阿星。**

上一篇文章【[InnoDB原理篇：为什么使用索引会变快?](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652055534&idx=1&sn=6bce05f55b7a290a16e71d3885bfbaf0&scene=21#wechat_redirect)】聊了下索引为什么快。

现在聊聊，我们如何用好索引

# InnoDB中索引分类

我们都知道`InnoDB`索引结构是`B+`树组织的，但是根据**数据存储形式不同**可以分为两类，分别是**聚簇索引**与**二级索引**。

ps：有些同学还听过**非聚簇索引**和**辅助索引**，其他它们都是一个意思，本文统一称为**二级索引**。

## 聚簇索引

**聚簇索引**默认是由**主键**构成，如果没有定义主键，`InnoDB`会选择非空的**唯一索引**代替，还是没有的话，`InnoDB`会**隐式**的定义一个主键来作为**聚簇索引**。

其实**聚簇索引**的本质就是**主键索引**。

因为每张表只能拥有一个**主键字段**，所以每张表只有一个**聚簇索引**。

另外**聚簇索引**还有一个特点，表的数据和主键是一起存储的，它的叶子节点存放的是整张表的行数据（树的最后一层），叶子节点又称为**数据页**。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnCokqrEIcR5dJlhRYFnibLvFhc5brYcesTylm4jVII5pSsHThC8ZCE5g/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

很简单记住一句话：**找到了索引就找到了行数据，那么这个索引就是聚簇索引。**

如果这里无法理解的话，可以去补下阿星的前两篇文章

- [InnoDB原理篇：聊聊数据页变成索引这件事](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652055534&idx=1&sn=6bce05f55b7a290a16e71d3885bfbaf0&scene=21#wechat_redirect)
- [InnoDB原理篇：为什么使用索引会变快?](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652055534&idx=1&sn=6bce05f55b7a290a16e71d3885bfbaf0&scene=21#wechat_redirect)

## 二级索引

知道了**聚簇索引**，再来看看**二级索引**是什么，简单概括，**除主键索引以外的索引，都是二级索引**，像我们平时建立的联合索引、前缀索引、唯一索引等。

**二级索引**的叶子节点存储的是索引值+主键`id`。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnwHXIAWOSKicebBuC23hWC2XJhoPq9UCYmKKQApNZfVwrEEYJmMr3FuQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

所以二级索引与聚簇索引的区别在于**叶子节点是否存放整行记录**。

也就意味着，仅仅靠二级索引无法拿到完整行数据，只能拿到`id`信息。

那二级索引应该如何拿到完整行数据呢？

# 索引的查询

假设，我们有一个主键列为`id`的表，表中有字段`k`，`k`上有索引。这个表的建表语句是：

```
create table T(
id int primary key, 
k int not null, 
name varchar(16),
index (k))engine=InnoDB;
```

表中有`5`条记录`(id,k)`，值分别为`(100,1)、(200,2)、(300,3)、(500,5)、(600,6)`，此时会有两棵树，分别是主键`id`的**聚簇索引**和字段`k`的**二级索引**，简化的树结构图如下

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnukAzowIcZrkkC1hBZtpiaeEaDLofTBiawC3fptuFNliaTyQogM2o6LF9g/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

## 回表

我们执行一条主键查询语句`select * from T where id = 100`，只需要搜索`id`聚簇索引树就能查询整行数据。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnH500qCDHricOl0O47iaSmS8vFLY9nePTeWEabUQm0nlJYBgcUBsO5glw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

接着再执行一条`select * from T where k = 1`，此时要搜索`k`的二级索引树，具体过程如下

- **在 k 索引树上找 k = 1的记录，取得 id = 100**
- **再到聚簇索引树查 id = 100 对应的行数据**
- **回到 k 索引树取下一个值 k = 2，不满足条件，循环结束**

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnnynibEsuLKiaicpH5CfttMJr6Ria5PNvKWwEkw37WjBCHDyJI0cicvUNEaQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

上图中，回到聚簇索引树搜索的过程，我们称为**回表**。

也就是说，基于**二级索引**的查询需要多扫描一棵**聚簇索引树**，因此在开发中尽量使用主键查询。

## 索引覆盖

可是有时候我们确实需要使用**二级索引查询**，有没有办法避免**回表**呢？

办法是有的，但需要结合业务场景来使用，比如本次查询只返回`id`值，查询语句可以这样写`select id from T where k = 1`，过程如下

- **在 k 索引树上找 k = 1的记录，取得 id = 100**
- **返回 id 值**
- **回到 k 索引树取下一个值 k = 2，不满足条件，循环结束**![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnAtic0CaEhUysVaJVGSxpwusw8pTiaL8HS2t3Dnt0qhA3fAXGx0hYYhSg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

在这个查询中，索引`k`已经**覆盖**了我们的查询需求，不需要回表，这个操作称为**覆盖索引**。

**由于覆盖索引可以减少树的搜索次数，显著提升查询性能，所以使用覆盖索引是一个常用的性能优化手段。**

假设现在有一个高频的业务场景，根据`k`查询，返回`name`，我们可以把`k`索引变更成`k`与`name`的联合索引。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnNMCqZFKOibYkkaune8KOvHd5y8pfUibUzibo8f7hKgjQJibsGlLHxYRdVQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

这个联合索引就有意义了，它可以在高频场景用到**覆盖索引**，不再需要**回表**查整行记录，减少语句的执行时间。

ps：**设计索引时，请遵守最左原则匹配**

## 索引下推

此时我们再建立一个`name`与`k`的联合索引。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnc1bDmdvyibmicmibkq1Yy9tEvbyHp2JrRfGCGwa9Rj3VjzmZicrse53l1A/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

执行`select k from T where name like '张%' and k = 2`语句。

首先会在`name`与`k`树中用**张**找到第一条件满足条件的记录`id = 100`，然后从`id = 100`开始遍历一个个**回表**，到**主键索引**上找出行记录，再对比`k`字段值，是不是十分操蛋。![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bn3QSfQSy8wTic2XJcaIicyalJqByUicOHIfHyFibKcia1lh0N6Sff8KFyBUg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

可以看到总共**回表**了`6`次

不过在`MySQL 5.6`版本引入的**索引下推**，可以在索引遍历过程中，对索引中包含的字段先做判断，直接过滤掉不满足条件的记录，减少**回表**次数。

![图片](https://mmbiz.qpic.cn/mmbiz_png/23OQmC1ia8nyAiajEJLPiaNySwgGgpCA5bnE0Xicz2cwplQNkM69evU6EYE8CDKkKl7XGCTcdMU6EVLHILGF2O8ELw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

总共回表`0`次。

# 小结

本篇文章到这里就结束了，今天和大家聊了聚簇索引、二级索引、回表、覆盖索引、索引下推等知识，可以看到，在满足语句需求的情况下，尽量少地访问资源是数据库设计的重要原则之一，由于篇幅有限，很多内容还没展开，后续阿星会和大家聊聊如何设计索引。

# MySQL好文推荐

- [CURD这么多年，你有了解过MySQL的架构设计吗？](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054134&idx=1&sn=79c0e8f7933815d822d9c2a36dc77401&scene=21#wechat_redirect)
- [浅谈 MySQL InnoDB 的内存组件](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054485&idx=1&sn=cd6bead326dc5f5d8cf6af16893e9676&scene=21#wechat_redirect)
- [聊聊redo log是什么？](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054699&idx=1&sn=018017d9f3a61ca284970bbf65ea5138&scene=21#wechat_redirect)
- [不会吧，不会吧，还有人不知道 binlog ？](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054835&idx=1&sn=cf863301f04d82f0c6ad4308ec8a55a3&scene=21#wechat_redirect)
- [redo log与binlog间的破事](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054869&idx=1&sn=b7ca964517c40a7ef990760ff659ac65&scene=21#wechat_redirect)
- [InnoDB原理篇：Buffer Pool为了让MySQL变快都做了什么](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652054938&idx=1&sn=3cf39464e9589caf9c1c34053372b8cd&scene=21#wechat_redirect)
- [InnoDB原理篇：聊聊数据页变成索引这件事](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652055534&idx=1&sn=6bce05f55b7a290a16e71d3885bfbaf0&scene=21#wechat_redirect)
- [**InnoDB原理篇：为什么使用索引会变快?**](https://mp.weixin.qq.com/s?__biz=MzAwMDg2OTAxNg==&mid=2652055560&idx=1&sn=74e296f195edea7caaff092565caec69&scene=21#wechat_redirect)

