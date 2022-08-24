## StampedLock

### 前言

在多线程开发中，为了控制线程同步，使用的最多的莫过于synchronized 关键字和重入锁。在JDK8中，又引入了一款新式武器StampedLock。这是一个什么东西呢？英文单词Stamp，意思是邮戳。那在这里有用什么含义呢？傻瓜，请看下面的分解。

面对临界区资源管理的问题，大体上有2套思路：

第一就是使用悲观的策略，悲观者这样认为：在每一次访问临界区的共享变量，总是有人会和我冲突，因此，每次访问我必须先锁住整个对象，完成访问后再解锁。

而与之相反的乐天派却认为，虽然临界区的共享变量会冲突，但是冲突应该是小概率事件，大部分情况下，应该不会发生，所以，我可以先访问了再说，如果等我用完了数据还没人冲突，那么我的操作就是成功；如果我使用完成后，发现有人冲突，那么我要么再重试一次，要么切换为悲观的策略。

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpyyvKLq0q32X9BqJI86tpGiaRDtHFJKHgIGwJf1OukibicZG2jd75HOsVlCwbhUtMbRR6TGCzwLOzIRA/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

从这里不难看到，重入锁以及synchronized 是一种典型的悲观策略。聪明的你一定也猜到了，StampedLock就是提供了一种乐观锁的工具，因此，它是对重入锁的一个重要的补充。

### StampedLock的基本使用

在StampedLock的文档中就提供了一个非常好的例子，让我们可以很快的理解StampedLock的使用。下面让我看一下这个例子，有关它的说明，都写在注释中了。

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpyyvKLq0q32X9BqJI86tpGia6dulIiaOhp7WbbicO143NDAP0Y1xC4ibD9Lib9nyRfMGPhDWjoKQut5YKA/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

这里再说明一下validate()方法的含义，函数签名长这样：

```
public boolean validate(long stamp)
```

它的接受参数是上次锁操作返回的邮戳，如果在调用validate()之前，这个锁没有写锁申请过，那就返回true，这也表示锁保护的共享数据并没有被修改，因此之前的读取操作是肯定能保证数据完整性和一致性的。

反之，如果锁在validate()之前有写锁申请成功过，那就表示，之前的数据读取和写操作冲突了，程序需要进行重试，或者升级为悲观锁。

#### 和重入锁的比较

从上面的例子其实不难看到，就编程复杂度来说，StampedLock其实是要比重入锁复杂的多，代码也没有以前那么简洁了。

**那么，我们为什么还要使用它呢？**

最本质的原因，就是为了提升性能！一般来说，这种乐观锁的性能要比普通的重入锁快几倍，而且随着线程数量的不断增加，性能的差距会越来越大。

简而言之，在大量并发的场景中StampedLock的性能是碾压重入锁和读写锁的。

但毕竟，世界上没有十全十美的东西，StampedLock也并非全能，它的缺点如下：

1. 编码比较麻烦，如果使用乐观读，那么冲突的场景要应用自己处理
2. 它是不可重入的，如果一不小心在同一个线程中调用了两次，那么你的世界就清净了。。。。。
3. 它不支持wait/notify机制

如果以上3点对你来说都不是问题，那么我相信StampedLock应该成为你的首选。

### 内部数据结构

为了帮助大家更好的理解StampedLock，这里再简单给大家介绍一下它的内部实现和数据结构。

在StampedLock中，有一个队列，里面存放着等待在锁上的线程。该队列是一个链表，链表中的元素是一个叫做WNode的对象：

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpyyvKLq0q32X9BqJI86tpGia1a5T8UAUUdoHXhRuibRAplSt2KgLXdwxtpiaLzJELmGNGX1ibkYFf1j8g/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

当队列中有若干个线程等待时，整个队列可能看起来像这样的：

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

除了这个等待队列，StampedLock中另外一个特别重要的字段就是long state， 这是一个64位的整数，StampedLock对它的使用是非常巧妙的。

state 的初始值是:

```
private static final int LG_READERS = 7;
private static final long WBIT  = 1L << LG_READERS;
private static final long ORIGIN = WBIT << 1;
```

也就是 ...0001 0000 0000 (前面的0太多了，不写了，凑足64个吧~)，为什么这里不用0做初始值呢？因为0有特殊的含义，为了避免冲突，所以选择了一个非零的数字。

如果有写锁占用，那么就让第7位设置为1  ...0001 1000 0000，也就是加上WBIT。

每次释放写锁，就加1，但不是state直接加，而是去掉最后一个字节，只使用前面的7个字节做统计。因此，释放写锁后，state就变成了：...0010 0000 0000， 再加一次锁，又变成：...0010 1000 0000，以此类推。

**这里为什么要记录写锁释放的次数呢？**

这是因为整个state 的状态判断都是基于CAS操作的。而普通的CAS操作可能会遇到ABA的问题，如果不记录次数，那么当写锁释放掉，申请到，再释放掉时，我们将无法判断数据是否被写过。而这里记录了释放的次数，因此出现"释放->申请->释放"的时候，CAS操作就可以检查到数据的变化，从而判断写操作已经有发生，作为一个乐观锁来说，就可以准确判断冲突已经产生，剩下的就是交给应用来解决冲突即可。因此，这里记录释放锁的次数，是为了精确地监控线程冲突。

而state剩下的那一个字节的其中7位，用来记录读锁的线程数量，由于只有7位，因此只能记录可怜的126个,看下面代码中的RFULL，就是读线程满载的数量。超过了怎么办呢，多余的部分就记录在readerOverflow字段中。

```
    private static final long WBIT  = 1L << LG_READERS;
    private static final long RBITS = WBIT - 1L;
    private static final long RFULL = RBITS - 1L;
    private transient int readerOverflow;
```

总结一下，state变量的结构如下：

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

### 写锁的申请和释放

在了解了StampedLock的内部数据结构之后，让我们再来看一下有关写锁的申请和释放吧！首先是写锁的申请：

```
    public long writeLock() {
        long s, next;  
        return ((((s = state) & ABITS) == 0L &&  //有没有读写锁被占用，如果没有，就设置上写锁标记
                 U.compareAndSwapLong(this, STATE, s, next = s + WBIT)) ?
                //如果写锁占用成功范围next，如果失败就进入acquireWrite()进行锁的占用。
                next : acquireWrite(false, 0L));
    }
```

如果CAS设置state失败，表示写锁申请失败，这时，会调用acquireWrite()进行申请或者等待。acquireWrite()大体做了下面几件事情：

1. 入队

2. 1. 如果头结点等于尾结点`wtail == whead`， 表示快轮到我了，所以进行自旋等待，抢到就结束了
   2. 如果`wtail==null` ，说明队列都没初始化，就初始化一下队列
   3. 如果队列中有其他等待结点，那么只能老老实实入队等待了

3. 阻塞并等待

4. 1. 如果头结点等于前置结点`(h = whead) == p)`, 那说明也快轮到我了，不断进行自旋等待争抢
   2. 否则唤醒头结点中的读线程
   3. 如果抢占不到锁，那么就park()当前线程

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

简单地说，acquireWrite()函数就是用来争抢锁的，它的返回值就是代表当前锁状态的邮戳，同时，为了提高锁的性能，acquireWrite()使用大量的自旋重试，因此，它的代码看起来有点晦涩难懂。

写锁的释放如下所示，unlockWrite()的传入参数是申请锁时得到的邮戳：

```
    public void unlockWrite(long stamp) {
        WNode h;
        //检查锁的状态是否正常
        if (state != stamp || (stamp & WBIT) == 0L)
            throw new IllegalMonitorStateException();
        // 设置state中标志位为0，同时也起到了增加释放锁次数的作用
        state = (stamp += WBIT) == 0L ? ORIGIN : stamp;
        // 头结点不为空，尝试唤醒后续的线程
        if ((h = whead) != null && h.status != 0)
            //唤醒(unpark)后续的一个线程
            release(h);
    }
```

### 读锁的申请和释放

获取读锁的代码如下：

```
    public long readLock() {
        long s = state, next;  
        //如果队列中没有写锁，并且读线程个数没有超过126，直接获得锁，并且读线程数量加1
        return ((whead == wtail && (s & ABITS) < RFULL &&
                 U.compareAndSwapLong(this, STATE, s, next = s + RUNIT)) ?
                //如果争抢失败，进入acquireRead()争抢或者等待
                next : acquireRead(false, 0L));
    }
```

acquireRead()的实现相当复杂，大体上分为这么几步：

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

总之，就是自旋，自旋再自旋，通过不断的自旋来尽可能避免线程被真的挂起，只有当自旋充分失败后，才会真正让线程去等待。

下面是释放读锁的过程：

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

### StampedLock悲观读占满CPU的问题

StampedLock固然是个好东西，但是由于它特别复杂，难免也会出现一些小问题。下面这个例子，就演示了StampedLock悲观锁疯狂占用CPU的问题：

```
public class StampedLockTest {
    public static void main(String[] args) throws InterruptedException {
        final StampedLock lock = new StampedLock();
        Thread t1 = new Thread(() -> {
            // 获取写锁
            lock.writeLock();
            // 模拟程序阻塞等待其他资源
            LockSupport.park();
        });
        t1.start();
        // 保证t1获取写锁
        Thread.sleep(100);
        Thread t2 = new Thread(() -> {
            // 阻塞在悲观读锁
            lock.readLock();
        });
        t2.start();
        // 保证t2阻塞在读锁
        Thread.sleep(100);
        // 中断线程t2,会导致线程t2所在CPU飙升
        t2.interrupt();
        t2.join();
    }
}
```

上述代码中，在中断t2后，t2的CPU占用率就会沾满100%。而这时候，t2正阻塞在readLock()函数上，换言之，在受到中断后，StampedLock的读锁有可能会占满CPU。这是什么原因呢？机制的小傻瓜一定想到了，这是因为StampedLock内太多的自旋引起的！没错，你的猜测是正确的。

**具体原因如下：**

如果没有中断，那么阻塞在readLock()上的线程在经过几次自旋后，会进入park()等待，一旦进入park()等待，就不会占用CPU了。但是park()这个函数有一个特点，就是一旦线程被中断，park()就会立即返回，返回还不算，它也不给你抛点异常啥的，那这就尴尬了。本来呢，你是想在锁准备好的时候，unpark()的线程的，但是现在锁没好，你直接中断了，park()也返回了，但是，毕竟锁没好，所以就又去自旋了。

转着转着，又转到了park()函数，但悲催的是，线程的中断标记一直打开着，park()就阻塞不住了，于是乎，下一个自旋又开始了，没完没了的自旋停不下来了，所以CPU就爆满了。

要解决这个问题，本质上需要在StampedLock内部，在park()返回时，需要判断中断标记为，并作出正确的处理，比如，退出，抛异常，或者把中断位给清理一下，都可以解决问题。

但很不幸，至少在JDK8里，还没有这样的处理。因此就出现了上面的，中断readLock()后，CPU爆满的问题。请大家一定要注意。

## 写在最后

今天，我们比较仔细地介绍了StampedLock的使用和主要实现思想，StampedLock是一种重入锁和读写锁的重要补充。

它提供了一种乐观锁的策略，是一种与众不同的锁实现。当然了，就编程难度而言，StampedLock会比重入锁和读写锁稍微繁琐一点，但带来的却是性能的成倍提升。

这里给大家提一些小意见，如果我们的应用线程数量可控，并且不多，竞争不太激烈，那么就可以直接使用简单的synchronized,重入锁，读写锁就好了；如果应用线程数量多，竞争激烈，并且对性能敏感，那么还是需要我们劳神费力，用一下比较复杂的StampedLock，来提高一下程序的吞吐量。

使用StampedLock还需要特别注意两点：第一StampedLock不是可重入的，千万不要单线程自己和自己搞死锁了，第二，StampedLock没有等待/通知机制，如果一定需要这个功能的话，也只能绕行啦！