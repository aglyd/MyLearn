## 并发情况下你还在用Random生成随机数？

--敖丙

### 前言 

在代码中生成随机数，是一个非常常用的功能，并且JDK已经提供了一个现成的Random类来实现它，并且Random类是线程安全的。

下面是Random.next()生成一个随机整数的实现：

```
    protected int next(int bits) {
        long oldseed, nextseed;
        AtomicLong seed = this.seed;
        do {
            oldseed = seed.get();
            nextseed = (oldseed * multiplier + addend) & mask;
          //CAS 有竞争是效率低下
        } while (!seed.compareAndSet(oldseed, nextseed));
        return (int)(nextseed >>> (48 - bits));
    }
```

不难看到，上面的方法中使用CAS操作更新seed，在大量线程竞争的场景下，这个CAS操作很可能失败，失败了就会重试，而这个重试又会消耗CPU运算，从而使得性能大大下降了。

因此，虽然Random是线程安全的，但是并不是“高并发”的。

为了改进这个问题，增强随机数生成器在高并发环境中的性能，于是乎，就有了ThreadLocalRandom——一个性能强悍的高并发随机数生成器。

ThreadLocalRandom继承自Random，根据里氏代换原则，这说明ThreadLocalRandom提供了和Random相同的随机数生成功能，只是实现算法略有不同。

### 在Thread中的变量

为了应对线程竞争，Java中有一个ThreadLocal类，为每一个线程分配了一个独立的，互不相干的存储空间。

ThreadLocal的实现依赖于Thread对象中的`ThreadLocal.ThreadLocalMap threadLocals`成员字段。

与之类似，为了让随机数生成器只访问本地线程数据，从而避免竞争，在Thread中，又增加了3个成员：

```
    /** The current seed for a ThreadLocalRandom */
    @sun.misc.Contended("tlr")
    long threadLocalRandomSeed;
    /** Probe hash value; nonzero if threadLocalRandomSeed initialized */
    @sun.misc.Contended("tlr")
    int threadLocalRandomProbe;
    /** Secondary seed isolated from public ThreadLocalRandom sequence */
    @sun.misc.Contended("tlr")
    int threadLocalRandomSecondarySeed;
```

这3个字段作为Thread类的成员，便自然和每一个Thread对象牢牢得捆绑在一起，因此成为了名副其实的ThreadLocal变量，而依赖这几个变量实现的随机数生成器，也就成为了ThreadLocalRandom。

### 消除伪共享

不知道大家有没有注意到， 在这些变量上面，都带有一个注解@sun.misc.Contended，这个注解是干什么用的呢？要了解这个，大家得先知道一下并发编程中的一个重要问题——**伪共享**：

我们知道，CPU是不直接访问内存的，数据都是从高速缓存中加载到寄存器的，高速缓存又有L1，L2，L3等层级。在这里，我们先简化这些负责的层级关系，假设只有一级缓存和一个主内存。

CPU读取和更新缓存的时候，是以行为单位进行的，也叫一个cache line，一行一般64字节，也就是8个long的长度。

因此，问题就来了，一个缓存行可以放多个变量，如果多个线程同时访问的不同的变量，而这些不同的变量又恰好位于同一个缓存行，那会发生什么呢？

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpxaUoQVRSjZK3636HibBWr7h5EMh7jCMaqcguVdK9WhURQAP8ch8t4SQ7e7ExoF2icY8XVIXrZoDsGg/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

如上图所示，X,Y为相邻2个变量，位于同一个缓存行，两个CPU core1 core2都加载了他们，core1更新X，同时，core2更新Y，由于数据的读取和更新是以缓存行为单位的，这就意味着当这2件事同时发生时，就产生了竞争，导致core1和core2有可能需要重新刷新自己的数据（缓存行被对方更新了），这就导致系统的性能大大折扣，这就是伪共享问题。

那怎么改进呢？如下图：

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpxaUoQVRSjZK3636HibBWr7hG9lfTMTqP5xHEW3JRrf5axfBMEwoYANvPtZUum5DWn44rsicU2S4e3g/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

上图中，我们把X单独占用一个缓存行，Y单独占用一个缓存行，这样各自更新和读取，都不会有任何影响了。

而上述代码中的==**@sun.misc.Contended("tlr")就会在虚拟机层面，帮助我们在变量的前后生成一些padding，使得被标注的变量位于同一个缓存行，不与其它变量冲突。**==

**==在Thread对象中，成员变量threadLocalRandomSeed，threadLocalRandomProbe，threadLocalRandomSecondarySeed被标记为同一个组tlr，使得这3个变量放置于一个单独的缓存行，而不与其它变量发生冲突，从而提高在并发环境中的访问速度。==**

### 反射的高效替代方案

随机数的产生需要访问Thread的threadLocalRandomSeed等成员，但是考虑到类的封装性，这些成员却是包内可见的。

很不幸，ThreadLocalRandom位于java.util.concurrent包，而Thread则位于java.lang包，因此，ThreadLocalRandom并没有办法访问Thread的threadLocalRandomSeed等变量。

这时，Java老鸟们可能就会跳出来说：这算什么，看我的反射大法，不管啥都能抠出来访问一下。

说的不错，反射是一种可以绕过封装，直接访问对象内部数据的方法，但是，反射的性能不太好，并不适合作为一个高性能的解决方案。

有没有什么办法可以让ThreadLocalRandom访问Thread的内部成员，同时又具有远超于反射的，且无限接近于直接变量访问的方法呢？答案是肯定的，这就是使用Unsafe类。

这里，就简单介绍一下用的两个Unsafe的方法：

```
public native long    getLong(Object o, long offset);
public native void    putLong(Object o, long offset, long x);
```

其中getLong()方法，会读取对象o的第offset字节偏移量的一个long型数据；putLong()则会将x写入对象o的第offset个字节的偏移量中。

这类类似C的操作方法，带来了极大的性能提升，更重要的是，由于它避开了字段名，直接使用偏移量，就可以轻松绕过成员的可见性限制了。

性能问题解决了，那下一个问题是，我怎么知道threadLocalRandomSeed成员在Thread中的偏移位置呢，这就需要用unsafe的objectFieldOffset()方法了，请看下面的代码：

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpxaUoQVRSjZK3636HibBWr7hPQQZNhia3EXu9s3vkgRru1MLBHkFw1dkOUfqiayH7Eiasr7LevD2zwlYg/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

上述这段static代码，==在ThreadLocalRandom类初始化的时候，就取得了Thread成员变量threadLocalRandomSeed，threadLocalRandomProbe，threadLocalRandomSecondarySeed在对象偏移中的位置。==

因此，只要ThreadLocalRandom需要使用这些变量，都可以通过unsafe的getLong()和putLong()来进行访问(也可能是getInt()和putInt())。

比如在生成一个随机数的时候：

```
    protected int next(int bits) {
        return (int)(mix64(nextSeed()) >>> (64 - bits));
    }
    final long nextSeed() {
        Thread t; long r; // read and update per-thread seed
        //在ThreadLocalRandom中，访问了Thread的threadLocalRandomSeed变量
        UNSAFE.putLong(t = Thread.currentThread(), SEED,
                       r = UNSAFE.getLong(t, SEED) + GAMMA);
        return r;
    }
```

这种Unsafe的方法掉地能有多快呢，让我们一起看做个试验看看：

这里，我们自己写一个ThreadTest类，使用反射和unsafe两种方法，来不停读写threadLocalRandomSeed成员变量，比较它们的性能差异，代码如下：

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpxaUoQVRSjZK3636HibBWr7hhYibn6PWf8sYib7tZ2WrUjOM79rzwbgeRZickZGOhDMJN950IN6iaV1rnw/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

上述代码中，分别使用反射方式byReflection() 和Unsafe的方式byUnsafe()来读写threadLocalRandomSeed变量1亿次，得到的测试结果如下：

```
byUnsafe spend :171ms
byReflection spend :645ms
```

不难看到，使用Unsafe的方法远远优于反射的方法，这也是JDK内部，大量使用Unsafe来替代反射的原因之一。

### 随机数种子

我们知道，伪随机数生成都需要一个种子，threadLocalRandomSeed和threadLocalRandomSecondarySeed就是这里的种子。其中threadLocalRandomSeed是long型的，threadLocalRandomSecondarySeed是int。

threadLocalRandomSeed是使用最广泛的大量的随机数其实都是基于threadLocalRandomSeed的。而threadLocalRandomSecondarySeed只是某些特定的JDK内部实现中有使用，使用并不广泛。

初始种子默认使用的是系统时间：

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/uChmeeX1FpxaUoQVRSjZK3636HibBWr7hmEnId4ibibcSM6aF3Wd7SyoDPnNqCp9TJ8s7GK65JvJfKXJkCyfJryQQ/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

上述代码中完成了种子的初始化，并将初始化的种子通过UNSAFE存在SEED的位置（即threadLocalRandomSeed）。

接着就可以使用nextInt()方法获得随机整数了：

```
    public int nextInt() {
        return mix32(nextSeed());
    }    
    final long nextSeed() {
        Thread t; long r; // read and update per-thread seed
        UNSAFE.putLong(t = Thread.currentThread(), SEED,
                       r = UNSAFE.getLong(t, SEED) + GAMMA);
        return r;
    }
```

每一次调用nextInt()都会使用nextSeed()更新threadLocalRandomSeed。由于这是一个线程独有的变量，因此完全不会有竞争，也不会有CAS的重试，性能也就大大提高了。

### 探针Probe的作用

除了种子外，还有一个threadLocalRandomProbe探针变量，这个变量是用来做什么的呢？

我们可以把threadLocalRandomProbe 理解为一个针对每个Thread的Hash值（不为0），它可以用来作为一个线程的特征值，基于这个值可以为线程在数组中找到一个特定的位置。

```
static final int getProbe() {
    return UNSAFE.getInt(Thread.currentThread(), PROBE);
}
```

来看一个代码片段：

```
        CounterCell[] as; long b, s;
        if ((as = counterCells) != null ||
            !U.compareAndSwapLong(this, BASECOUNT, b = baseCount, s = b + x)) {
            CounterCell a; long v; int m;
            boolean uncontended = true;
            if (as == null || (m = as.length - 1) < 0 ||
                // 使用probe，为每个线程找到一个在数组as中的位置
                // 由于每个线程的probe值不一样，因此大概率 每个线程对应的数组中的元素也是不一样的
                // 每个线程对应了不同的元素，就可以没有冲突的进行完全的并发操作
                // 因此探针probe在这里 就起到了防止冲突的作用
                (a = as[ThreadLocalRandom.getProbe() & m]) == null ||
                !(uncontended =
                  U.compareAndSwapLong(a, CELLVALUE, v = a.value, v + x))) {
```

在具体的实现中，如果上述代码发生了冲突，那么，还可以使用`ThreadLocalRandom.advanceProbe()`方法来修改一个线程的探针值，这样可以进一步避免未来可能得冲突，从而减少竞争，提高并发性能。

```
    static final int advanceProbe(int probe) {
        //根据当前探针值，计算一个更新的探针值
        probe ^= probe << 13;   // xorshift
        probe ^= probe >>> 17;
        probe ^= probe << 5;
        //更新探针值到线程对象中 即修改了threadLocalRandomProbe变量
        UNSAFE.putInt(Thread.currentThread(), PROBE, probe);
        return probe;
    }
```

## 总结

今天，我们介绍了ThreadLocalRandom对象，这是一个高并发环境中的，高性能的随机数生成器。

我们不但介绍了ThreadLocalRandom的功能和内部实现原理，还介绍介绍了ThreadLocalRandom对象是如何达到高性能的（比如通过伪共享，Unsafe等手段），希望大家可以将这些技术灵活运用到自己的工程中。