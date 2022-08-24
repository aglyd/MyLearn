# [Java CAS 原理详解](https://baijiahao.baidu.com/s?id=1721459510220070287&wfr=spider&for=pc)

## 1. 背景

在JDK 5之前Java语言是靠 synchronized 关键字保证同步的，这会导致有锁。锁机制存在以下问题：

- 在多线程竞争下，加锁、释放锁会导致比较多的上下文切换和调度延时，引起性能问题。
- 一个线程持有锁会导致其它所有需要此锁的线程挂起。
- 如果一个优先级高的线程等待一个优先级低的线程释放锁会导致优先级倒置，引起性能风险。

Volatile关键字能够在并发条件下，强制将修改后的值刷新到主内存中来保持内存的可见性。通过 CPU内存屏障禁止编译器指令性重排来保证并发操作的有序性

如果多个线程同时操作 Volatile 修饰的变量，也会造成数据的不一致。

```
public class Test {    public volatile int inc = 0;         public void increase() {        inc++;    }         public static void main(String[] args) {        final Test test = new Test();        for(int i=0;i<10;i++){            new Thread(){                public void run() {                    for(int j=0;j<1000;j++)                        test.increase();                };            }.start();        }            while(Thread.activeCount()>1)            Thread.yield();        System.out.println(test.inc);    }}
```

事实上运行它会发现每次运行结果都不一致，都是一个小于10000的数字。

假如某个时刻变量 inc 的值为10：

- 线程1对变量进行自增操作，线程1先读取了变量inc的原始值，然后线程1被阻塞了；
- 然后线程2对变量进行自增操作，线程2也去读取变量inc的原始值，由于线程1只是对变量inc进行读取操作，而没有对变量进行修改操作，所以不会导致线程2的工作内存中缓存变量inc的缓存行无效，所以线程2会直接去主存读取inc的值，发现inc的值时10，然后进行加1操作，并把11写入工作内存，最后写入主存。
- 然后线程1接着进行加1操作，由于已经读取了inc的值，注意此时在线程1的工作内存中inc的值仍然为10，所以线程1对inc进行加1操作后inc的值为11，然后将11写入工作内存，最后写入主存。
- 那么两个线程分别进行了一次自增操作后，inc只增加了1。

之所以出现还是 volatile 只是保证读写具有原子性，但是对于 ++ 操作的复合操作是不存在原子操作的。只能在有限的一些情形下使用 volatile 变量替代锁。要使 volatile 变量提供理想的线程安全，比如：**对变量的写操作不依赖于当前值。**

volatile 是不错的机制，但是 **volatile 不能保证原子性**。因此对于同步最终还是要回到锁机制上来。

独占锁是一种悲观锁，synchronized 就是一种独占锁，会导致其它所有需要锁的线程挂起，等待持有锁的线程释放锁。而另一个更加有效的锁就是乐观锁。所谓乐观锁就是，每次不加锁而是假设没有冲突而去完成某项操作，如果因为冲突失败就重试，直到成功为止。乐观锁用到的机制就是 CAS，Compare and Swap。



## 2. CAS 原理

CAS 全称是 compare and swap，是一种用于在多线程环境下实现同步功能的机制。CAS 操作包含三个操作数 -- 内存位置、预期数值和新值。CAS 的实现逻辑是将内存位置处的数值与预期数值想比较，若相等，则将内存位置处的值替换为新值。若不相等，则不做任何操作。

在 Java 中，Java 并没有直接实现 CAS，CAS 相关的实现是通过 C++ 内联汇编的形式实现的。Java 代码需通过 JNI 才能调用。

**CAS 是一条 CPU 的原子指令（cmpxchg指令），不会造成所谓的数据不一致问题**，Unsafe 提供的 CAS 方法（如compareAndSwapXXX）底层实现即为 CPU 指令 cmpxchg

对 java.util.concurrent.atomic 包下的原子类 AtomicInteger 中的 compareAndSet 方法进行分析，相关分析如下：

```java
  AtomicInteger  Number        Unsafe unsafe =               valueOffset =.getDeclaredField("value" (Exception ex) {       compareAndSet( expect,  update) {                 unsafe.compareAndSwapInt(            compareAndSwapInt(Object o,  offset,   expected,    }
```

```
// unsafe.cpp/* * 这个看起来好像不像一个函数，不过不用担心，不是重点。UNSAFE_ENTRY 和 UNSAFE_END 都是宏， * 在预编译期间会被替换成真正的代码。下面的 jboolean、jlong 和 jint 等是一些类型定义（typedef）： *  * jni.h *     typedef unsigned char   jboolean; *     typedef unsigned short  jchar; *     typedef short           jshort; *     typedef float           jfloat; *     typedef double          jdouble; *  * jni_md.h *     typedef int jint; *     #ifdef _LP64 // 64-bit *     typedef long jlong; *     #else *     typedef long long jlong; *     #endif *     typedef signed char jbyte; */UNSAFE_ENTRY(jboolean, Unsafe_CompareAndSwapInt(JNIEnv *env, jobject unsafe, jobject obj, jlong offset, jint e, jint x))  UnsafeWrapper("Unsafe_CompareAndSwapInt");  oop p = JNIHandles::resolve(obj);    // 根据偏移量，计算 value 的地址。这里的 offset 就是 AtomaicInteger 中的 valueOffset  jint* addr = (jint *) index_oop_from_field_offset_long(p, offset);    // 调用 Atomic 中的函数 cmpxchg，该函数声明于 Atomic.hpp 中  return (jint)(Atomic::cmpxchg(x, addr, e)) == e;UNSAFE_END atomic.cppunsigned Atomic::cmpxchg(unsigned int exchange_value,  volatile unsigned int* dest, unsigned int compare_value) {  assert(sizeof(unsigned int) == sizeof(jint), "more work to do");    /*   * 根据操作系统类型调用不同平台下的重载函数，这个在预编译期间编译器会决定调用哪个平台下的重载   * 函数。相关的预编译逻辑如下：   *    * atomic.inline.hpp：   *    #include "runtime/atomic.hpp"   *       *    // Linux   *    #ifdef TARGET_OS_ARCH_linux_x86   *    # include "atomic_linux_x86.inline.hpp"   *    #endif   *      *    // 省略部分代码   *       *    // Windows   *    #ifdef TARGET_OS_ARCH_windows_x86   *    # include "atomic_windows_x86.inline.hpp"   *    #endif   *       *    // BSD   *    #ifdef TARGET_OS_ARCH_bsd_x86   *    # include "atomic_bsd_x86.inline.hpp"   *    #endif   *    * 接下来分析 atomic_windows_x86.inline.hpp 中的 cmpxchg 函数实现   */  return (unsigned int)Atomic::cmpxchg((jint)exchange_value, (volatile jint*)dest,  (jint)compare_value);}
```

上面的分析看起来比较多，不过主流程并不复杂。如果不纠结于代码细节，还是比较容易看懂的。接下来，我会分析 Windows 平台下的 Atomic::cmpxchg 函数。继续往下看吧。

```
// atomic_windows_x86.inline.hpp#define LOCK_IF_MP(mp) __asm cmp mp, 0  \                       __asm je L0      \                       __asm _emit 0xF0 \                       __asm L0:              inline jint Atomic::cmpxchg (jint exchange_value, volatile jint* dest, jint compare_value) {  // alternative for InterlockedCompareExchange  int mp = os::is_MP();  __asm {    mov edx, dest    mov ecx, exchange_value    mov eax, compare_value    LOCK_IF_MP(mp)    cmpxchg dword ptr [edx], ecx  }}
```

上面的代码由 LOCK_IF_MP 预编译标识符和 cmpxchg 函数组成。为了看到更清楚一些，我们将 cmpxchg 函数中的 LOCK_IF_MP 替换为实际内容。如下：

```
inline jint Atomic::cmpxchg (jint exchange_value, volatile jint* dest, jint compare_value) {    // 判断是否是多核 CPU  int mp = os::is_MP();  __asm {    // 将参数值放入寄存器中    mov edx, dest    // 注意: dest 是指针类型，这里是把内存地址存入 edx 寄存器中    mov ecx, exchange_value    mov eax, compare_value        // LOCK_IF_MP    cmp mp, 0    /*     * 如果 mp = 0，表明是线程运行在单核 CPU 环境下。此时 je 会跳转到 L0 标记处，     * 也就是越过 _emit 0xF0 指令，直接执行 cmpxchg 指令。也就是不在下面的 cmpxchg 指令     * 前加 lock 前缀。     */    je L0    /*     * 0xF0 是 lock 前缀的机器码，这里没有使用 lock，而是直接使用了机器码的形式。至于这样做的     * 原因可以参考知乎的一个回答：     *     https://www.zhihu.com/question/50878124/answer/123099923     */     _emit 0xF0L0:    /*     * 比较并交换。简单解释一下下面这条指令，熟悉汇编的朋友可以略过下面的解释:     *   cmpxchg: 即“比较并交换”指令     *   dword: 全称是 double word，在 x86/x64 体系中，一个      *          word = 2 byte，dword = 4 byte = 32 bit     *   ptr: 全称是 pointer，与前面的 dword 连起来使用，表明访问的内存单元是一个双字单元     *   [edx]: [...] 表示一个内存单元，edx 是寄存器，dest 指针值存放在 edx 中。     *          那么 [edx] 表示内存地址为 dest 的内存单元     *               * 这一条指令的意思就是，将 eax 寄存器中的值（compare_value）与 [edx] 双字内存单元中的值     * 进行对比，如果相同，则将 ecx 寄存器中的值（exchange_value）存入 [edx] 内存单元中。     */    cmpxchg dword ptr [edx], ecx  }}
```

到这里 CAS 的实现过程就讲完了，CAS 的实现离不开处理器的支持。如上面源代码所示，程序会根据当前处理器的类型来决定是否为 cmpxchg 指令添加 lock 前缀。如果程序是在多处理器上运行，就为 cmpxchg 指令加上 lock 前缀（lock cmpxchg）。反之，如果程序是在单处理器上运行，就省略 lock 前缀（单处理器自身会维护单处理器内的顺序一致性，不需要 lock 前缀提供的内存屏障效果）。

intel 的手册对 lock 前缀的说明如下：

- 确保对内存的读 - 改 - 写操作原子执行。在 Pentium 及 Pentium 之前的处理器中，带有 lock 前缀的指令在执行期间会锁住总线，使得其他处理器暂时无法通过总线访问内存。很显然，这会带来昂贵的开销。从 Pentium 4，Intel Xeon 及 P6 处理器开始，intel 在原有总线锁的基础上做了一个很有意义的优化：**==如果要访问的内存区域（area of memory）在 lock 前缀指令执行期间已经在处理器内部的缓存中被锁定（即包含该内存区域的缓存行当前处于独占或以修改状态），并且该内存区域被完全包含在单个缓存行（cache line）中，那么处理器将直接执行该指令。由于在指令执行期间该缓存行会一直被锁定，其它处理器无法读 / 写该指令要访问的内存区域（相当于缩小了锁定的内存区域范围，只锁缓存行中的内存，而锁住总线就无法访问任何内存了），因此能保证指令执行的原子性。这个操作过程叫做缓存锁定（cache locking），缓存锁定将大大降低 lock 前缀指令的执行开销，但是当多处理器之间的竞争程度很高或者指令访问的内存地址未对齐时，仍然会锁住总线。==**
- 禁止该指令与之前和之后的读和写指令重排序。
- 把写缓冲区中的所有数据刷新到内存中。

上面的第 2 点和第 3 点所具有的内存屏障效果，足以同时实现 volatile 读和 volatile 写的内存语义。

经过上面的这些分析，现在我们终于能明白为什么 JDK 文档说 CAS 同时具有 volatile 读和 volatile 写的内存语义了。



Java 的 CAS 会使用现代处理器上提供的高效机器级别原子指令，这些原子指令以原子方式对内存执行读 - 改 - 写操作，这是在**多处理器中实现同步的关键**（从本质上来说，能够支持原子性读 - 改 - 写指令的计算机器，是顺序计算图灵机的异步等价机器，因此任何现代的多处理器都会去支持某种能对内存执行原子性读 - 改 - 写操作的原子指令）。同时，volatile 变量的读 / 写和 CAS 可以实现线程之间的通信。把这些特性整合在一起，就形成了整个 concurrent 包得以实现的基石。如果我们仔细分析 concurrent 包的源代码实现，会发现一个通用化的实现模式：

- 首先，声明共享变量为 volatile；
- 然后，使用 CAS 的原子条件更新来实现线程之间的同步；
- 同时，配合以 volatile 的读 / 写和 CAS 所具有的 volatile 读和写的内存语义来实现线程之间的通信。



AQS，非阻塞数据结构和原子变量类（java.util.concurrent.atomic 包中的类），这些 concurrent 包中的基础类都是使用这种模式来实现的，而 concurrent 包中的高层类又是依赖于这些基础类来实现的。从整体来看，concurrent 包的实现示意图如下：



![img](https://pics6.baidu.com/feed/9a504fc2d5628535c6e1bda9c6bec2cfa6ef638b.jpeg?token=0e7d0196fa19d00c95c815c53cf20b3c)



JVM中的CAS（堆中对象的分配）：　

Java 调用 new object() 会创建一个对象，这个对象会被分配到 JVM 的堆中。那么这个对象到底是怎么在堆中保存的呢？

首先，new object() 执行的时候，这个对象需要多大的空间，其实是已经确定的，因为 java 中的各种数据类型，占用多大的空间都是固定的（对其原理不清楚的请自行Google）。那么接下来的工作就是在堆中找出那么一块空间用于存放这个对象。

在单线程的情况下，一般有两种分配策略：

1. 指针碰撞：这种一般适用于内存是绝对规整的（内存是否规整取决于内存回收策略），分配空间的工作只是将指针像空闲内存一侧移动对象大小的距离即可。
2. 空闲列表：这种适用于内存非规整的情况，这种情况下JVM会维护一个内存列表，记录哪些内存区域是空闲的，大小是多少。给对象分配空间的时候去空闲列表里查询到合适的区域然后进行分配即可。



但是JVM不可能一直在单线程状态下运行，那样效率太差了。**==由于再给一个对象分配内存的时候不是原子性的操作，至少需要以下几步：查找空闲列表、分配内存、修改空闲列表等等，这是不安全的。（如A线程生成一个新对象申请内存区域1，而同时B线程也执行相同操作，此时内存1到底分配给了A还是B会有冲突，因此需要锁定内存）==**解决并发时的安全问题也有两种策略：

1. **CAS**：实际上虚拟机采用CAS配合上失败重试的方式保证更新操作的原子性，原理和上面讲的一样。
2. **TLAB**：如果使用CAS其实对性能还是会有影响的，所以 JVM 又提出了一种更高级的优化策略：每个线程在 Java 堆中预先分配一小块内存，称为本地线程分配缓冲区（TLAB），线程内部需要分配内存时直接在 TLAB 上分配就行，避免了线程冲突。只有当缓冲区的内存用光需要重新分配内存的时候才会进行CAS操作分配更大的内存空间。

**虚拟机是否使用TLAB，可以通过-XX:+/-UseTLAB参数来进行配置（jdk5及以后的版本默认是启用TLAB的）。**



## 3. CAS存在的问题

### 3.1 ABA 问题

谈到 CAS，基本上都要谈一下 CAS 的 ABA 问题。CAS 由三个步骤组成，分别是“读取-比较-写回”。考虑这样一种情况，线程1和线程2同时执行 CAS 逻辑，两个线程的执行顺序如下：

- 时刻1：线程1执行读取操作，获取原值 A，然后线程被切换走
- 时刻2：线程2执行完成 CAS 操作将原值由 A 修改为 B
- 时刻3：线程2再次执行 CAS 操作，并将原值由 B 修改为 A
- 时刻4：线程1恢复运行，将比较值(compareValue)与原值(oldValue)进行比较，发现两个值相等。

然后用新值(newValue)写入内存中，完成 CAS 操作

如上流程，线程1并不知道原值已经被修改过了，在它看来并没什么变化，所以它会继续往下执行流程。对于 ABA 问题，通常的处理措施是对每一次 CAS 操作设置版本号。

ABA问题的解决思路其实也很简单，就是使用版本号。在变量前面追加上版本号，每次变量更新的时候把版本号加1，那么A→B→A就会变成1A→2B→3A了。

java.util.concurrent.atomic 包下提供了一个可处理 ABA 问题的原子类 **AtomicStampedReference，**

**从Java1.5开始JDK的atomic包里提供了一个类AtomicStampedReference来解决ABA问题。这个类的compareAndSet方法作用是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如果全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。**

### 3.2 循环时间长开销大

**自旋CAS（不成功，就一直循环执行，直到成功） 如果长时间不成功，会给 CPU 带来非常大的执行开销。**如果JVM能支持处理器提供的 pause 指令那么效率会有一定的提升，pause指令有两个作用，第一它可以延迟流水线执行指令（de-pipeline），使 CPU 不会消耗过多的执行资源，延迟的时间取决于具体实现的版本，在一些处理器上延迟时间是零。第二它可以避免在退出循环的时候因内存顺序冲突（memory order violation）而引起 CPU 流水线被清空（CPU pipeline flush），从而提高 CPU 的执行效率。

### 3.3 只能保证一个共享变量的原子操作

当对一个共享变量执行操作时，我们可以使用循环 CAS 的方式来保证原子操作，但是对多个共享变量操作时，循环 CAS 就无法保证操作的原子性，这个时候就可以用锁，或者有一个取巧的办法，就是把多个共享变量合并成一个共享变量来操作。比如有两个共享变量 i＝2，j=a，合并一下 ij=2a，然后用CAS来操作ij。从Java1.5开始JDK提供了 AtomicReference 类来保证引用对象之间的原子性，你可以把多个变量放在一个对象里来进行 CAS 操作。

CAS 与 Synchronized 的使用情景：　　　

1. ==**对于资源竞争较少（线程冲突较轻）的情况，使用synchronized同步锁进行线程阻塞和唤醒切换以及用户态内核态间的切换操作额外浪费消耗cpu资源；而CAS基于硬件实现，不需要进入内核，不需要切换线程，操作自旋几率较少，因此可以获得更高的性能。**==
2. ==**对于资源竞争严重（线程冲突严重）的情况，CAS自旋的概率会比较大，从而浪费更多的CPU资源，效率低于synchronized。**==

补充： **==synchronized 在 jdk1.6 之后，已经改进优化。synchronized 的底层实现主要依靠 Lock-Free 的队列，基本思路是自旋后阻塞，竞争切换后继续竞争锁，稍微牺牲了公平性，但获得了高吞吐量。在线程冲突较少的情况下，可以获得和 CAS 类似的性能；而线程冲突严重的情况下，性能远高于 CAS。==**



### 其他

### 什么是happen-before

JMM 可以通过 happens-before 关系向程序员提供跨线程的内存可见性保证（如果 A 线程的写操作 a 与 B 线程的读操作 b 之间存在 happens-before 关系，尽管 a 操作和 b 操作在不同的线程中执行，但 JMM 向程序员保证 a 操作将对 b 操作可见）。

具体的定义为：

- 如果一个操作happens-before另一个操作，那么第一个操作的执行结果将对第二个操作可见，而且第一个操作的执行顺序排在第二个操作之前。
- 两个操作之间存在happens-before关系，并不意味着Java平台的具体实现必须要按照happens-before关系指定的顺序来执行。如果重排序之后的执行结果，与按happens-before关系来执行的结果一致，那么这种重排序并不非法（也就是说，JMM允许这种重排序）。



具体的规则：

1. 程序顺序规则：一个线程中的每个操作，happens-before于该线程中的任意后续操作。
2. 监视器锁规则：对一个锁的解锁，happens-before于随后对这个锁的加锁。
3. volatile变量规则：对一个volatile域的写，happens-before于任意后续对这个volatile域的读。
4. 传递性：如果A happens-before B，且B happens-before C，那么A happens-before C。
5. start()规则：如果线程A执行操作ThreadB.start()（启动线程B），那么A线程的ThreadB.start()操作happens-before于线程B中的任意操作。
6. Join()规则：如果线程A执行操作ThreadB.join()并成功返回，那么线程B中的任意操作happens-before于线程A从ThreadB.join()操作成功返回。
7. 程序中断规则：对线程interrupted()方法的调用先行于被中断线程的代码检测到中断时间的发生。
8. 对象finalize规则：一个对象的初始化完成（构造函数执行结束）先行于发生它的finalize()方法的开始。

该段描述摘自《happen-before原则》；原文链接：https://blog.csdn.net/ma_chen_qq/article/details/82990603



### volatile

volatile修饰的变量变化过程：

- 第一：使用 volatile 关键字会强制将修改的值立即写入主存；
- 第二：使用 volatile 关键字的话，当线程 2 进行修改时，会导致线程1的工作内存中缓存变量的缓存行无效；
- 第三：由于线程1的工作内存中缓存变量的缓存行无效，所以线程 1 再次读取变量的值时会去主存读取。

可见性和原子性：

- 可见性：对一个 volatile 变量的读，总是能看到（任意线程）对这个 volatile 变量最后的写入。
- 原子性：对任意单个 volatile 变量的读/写具有原子性，但类似于 volatile++ 这种复合操作不具有原子性。



来源：https://www.cnblogs.com/huansky/p/15746624.html





---

# [java CAS详解](https://blog.csdn.net/qq_33404773/article/details/117304756)

**CAS解释：**
CAS(compare and swap),比较并交换。可以解决多线程并行情况下使用锁造成性能损耗的一种机制.CAS 操作包含三个操作数—内存位置（V）、预期原值（A）和新值(B)。如果内存位置的值与预期原值相匹配，那么处理器会自动将该位置值更新为新值。否则，处理器不做任何操作。一个线程从主内存中得到num值，并对num进行操作，写入值的时候，线程会把第一次取到的num值和主内存中num值进行比较，如果相等，就会将改变后的num写入主内存，如果不相等，则一直循环对比，知道成功为止。

**CAS产生：**
在修饰共享变量的时候经常使用volatile关键字，但是volatile值有可见性和禁止指令重拍（有序性），无法保证原子性。虽然在单线程中没有问题，但是多线程就会出现各种问题，造成现场不安全的现象。所以jdk1.5后产生了CAS利用CPU原语（不可分割，连续不中断）保证现场操作原子性。

**CAS应用：**
在JDK1.5 中新增java.util.concurrent(JUC)就是建立在CAS之上的。相对于对于synchronized这种锁机制，CAS是非阻塞算法的一种常见实现。所以JUC在性能上有了很大的提升。

比如AtomicInteger类，**AtomicInteger是线程安全的的**，下面是源码

![img](https://img-blog.csdnimg.cn/20210526203442988.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMzNDA0Nzcz,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/2021052620344333.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMzNDA0Nzcz,size_16,color_FFFFFF,t_70)



进入unsafe看到do while自循环，这里的自循环，就是在 判断预期原值 如果与原来的值不符合，会再循环取原值，再走CAS流程，直到能够把新值赋值成功。

**CAS优点**
cas是一种乐观锁的思想，而且是一种非阻塞的轻量级的乐观锁，非阻塞式是指一个线程的失败或者挂起不应该影响其他线程的失败或挂起的算法。

**CAS 缺点**
循环时间长开销大，占用CPU资源。如果自旋锁长时间不成功，会给CPU带来很大的开销。如果JVM能支持处理器提供的pause指令那么效率会有一定的提升，pause指令有两个作用，第一它可以延迟流水线执行指令（de-pipeline）,使CPU不会消耗过多的执行资源，延迟的时间取决于具体实现的版本，在一些处理器上延迟时间是零。第二它可以避免在退出循环的时候因内存顺序冲突（memory order violation）而引起CPU流水线被清空（CPU pipeline flush），从而提高CPU的执行效率。
只能保证一个共享变量的原子操作。当对一个共享变量执行操作时，我们可以使用循环CAS的方式来保证原子操作，但是对多个共享变量操作时，循环CAS就无法保证操作的原子性，这个时候就可以用锁，或者有一个取巧的办法，就是把多个共享变量合并成一个共享变量来操作。比如有两个共享变量i＝2,j=a，合并一下ij=2a，然后用CAS来操作ij。从Java1.5开始JDK提供了AtomicReference类来保证引用对象之间的原子性，你可以把多个变量放在一个对象里来进行CAS操作。
ABA问题
      解决ABA问题（如果值考虑收尾，不考虑过程可以忽略改问题）

添加版本号
**AtomicStampedReference**

![img](https://img-blog.csdnimg.cn/20210526204415235.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzMzNDA0Nzcz,size_16,color_FFFFFF,t_70)

 从Java1.5开始JDK的atomic包里提供了一个类AtomicStampedReference来解决ABA问题。这个类的compareAndSet方法作用是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如 全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。

**CAS使用的时机**
**线程数较少、等待时间短可以采用自旋锁进行CAS尝试拿锁，较于synchronized高效。**
**线程数较大、等待时间长，不建议使用自旋锁，占用CPU较高**



-----

# [Java中CAS详解](https://blog.csdn.net/zp1455604302/article/details/118756918)

在JDK 5之前Java语言是靠synchronized关键字保证同步的，这会导致有锁
锁机制存在以下问题：

（1）在多线程竞争下，加锁、释放锁会导致比较多的上下文切换和调度延时，引起性能问题。

（2）一个线程持有锁会导致其它所有需要此锁的线程挂起。

（3）如果一个优先级高的线程等待一个优先级低的线程释放锁会导致优先级倒置，引起性能风险。

volatile是不错的机制，但是volatile不能保证原子性。因此对于同步最终还是要回到锁机制上来。

独占锁是一种悲观锁，synchronized就是一种独占锁，会导致其它所有需要锁的线程挂起，等待持有锁的线程释放锁。而另一个更加有效的锁就是乐观锁。所谓乐观锁就是，每次不加锁而是假设没有冲突而去完成某项操作，如果因为冲突失败就重试，直到成功为止。乐观锁用到的机制就是CAS，Compare and Swap。

**CAS的全称为Compare-And-Swap，它是一条CPU并发原语。**
它的功能是判断内存某个位置的值是否为预期值，如果是则更改为新的值，这个过程是原子的。
CAS并发原语体现在JAVA语言中就是sun.misc.Unsafe类中的各个方法。调用UnSafe类中的CAS方法，JVM会帮我们实现出CAS汇编指令。这是一种完全依赖于硬件的功能，通过它实现了原子操作。再次强调，由于CAS是一种系统原语，原语属于操作系统用语范畴，是由若干条指令组成的，用于完成某个功能的一个过程，并且原语的执行必须是连续的，在执行过程中不允许被中断，也就是说CAS是一条CPU的原子指令，不会造成所谓的数据不一致问题。
**CAS通俗的解释就是：**
比较当前工作内存中的值和主内存中的值，如果相同则执行规定操作，否则继续比较直到主内存和工作内存中的值一致为止.
**CAS应用**
CAS有3个操作数，内存值V，旧的预期值A，要修改的更新值B。
当且仅当预期值A和内存值V相同时，将内存值V修改为B，否则什么都不做。
**CAS为什么能保证原子操作呐？**
这个就关系到了CAS底层所用到的Unsafe类，Unsafe是CAS的核心类，由于Java方法无法直接访问底层系统，需要通过本地(native)方法来访问，Unsafe相当于一个后门，基于该类可以直接操作特定内存的数据。Unsafe类存在于sun.misc包中，其内部方法操作可以像C的指针一样直接操作内存，因为Java中CAS操作的执行依赖于Unsafe类的方法。

**下面是AtomicInteger类的getAndSet方法**

```java
public final int getAndSet(int var1) {
        return unsafe.getAndSetInt(this, valueOffset, var1);
    }


var1 Atomiclnteger对象本身。
var2该对象值得引用地址。
var4需要变动的数量。
var5是用过var1 var2找出的主内存中真实的值。
用该对象当前的值与var5比较:
如果相同，更新var5+var4并且返回true,
如果不同，继续取值然后再比较，直到更新完成。

 public final int getAndSetInt(Object var1, long var2, int var4) {
        int var5;
        do {
            var5 = this.getIntVolatile(var1, var2);
        } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

        return var5;
    }

```

**多线程它是怎么保证数据的原子性的哪？**
举个例子:
假设线程A和线程B两个线程同时执行getAndAddlInt操作（分别跑在不同CPU上) :

(一). AtomicInteger里面的value原始值为3，即主内存中Atomiclnteger的value为3，根据JMM模型，线程A和线程B各自持有一份值为3的value的副本分别到各自的工作内存。

(二).线程A通过getIntVolatile(var1, var2)拿到value值3，这时线程A被挂起。

(三)线程B也通过getlntVolatile(var1, var2)方法获取到value值3，此时刚好线程B没有被挂起并执行compareAndSwaplnt方法比较内存值也为3，成功修改内存值为4，线程B打完收工，一切OK。

(四).这时线程A恢复，执行compareAndSwaplnt方法比较，发现自己手里的值数字3和主内存的值数字4不一致，说明该值己经被其它线程抢先一步修改过了，那A线程本次修改失败，只能重新读取重新来一遍了。

(五).线程A重新获取value值，因为变量value被volatle修饰，所以其它线程对它的修改，线程A总是能够看到，线程A继续执行compareAndSwaplnt进行比较替换，直到成功。

**CAS存在的问题**

CAS虽然很高效的解决原子操作，但是CAS仍然存在三大问题。ABA问题，循环时间长开销大和只能保证一个共享变量的原子操作

ABA问题。因为CAS需要在操作值的时候检查下值有没有发生变化，如果没有发生变化则更新，但是如果一个值原来是A，变成了B，又变成了A，那么使用CAS进行检查时会发现它的值没有发生变化，但是实际上却变化了。ABA问题的解决思路就是使用版本号。在变量前面追加上版本号，每次变量更新的时候把版本号加一，那么A－B－A 就会变成1A - 2B－3A。

循环时间长开销大。自旋CAS如果长时间不成功，会给CPU带来非常大的执行开销。如果JVM能支持处理器提供的pause指令那么效率会有一定的提升，pause指令有两个作用，第一它可以延迟流水线执行指令（de-pipeline）,使CPU不会消耗过多的执行资源，延迟的时间取决于具体实现的版本，在一些处理器上延迟时间是零。第二它可以避免在退出循环的时候因内存顺序冲突（memory order violation）而引起CPU流水线被清空（CPU pipeline flush），从而提高CPU的执行效率。

**ABA问题怎么解决？**

从Java1.5开始JDK的atomic包里提供了一个类AtomicStampedReference来解决ABA问题。这个类的compareAndSet方法作用是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如果全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。

```java
public class CASDemo {

    //AtomicStampedReference 注意，如果泛型是一个包装类，注意对象的引用问题

    // 正常在业务操作，这里面比较的都是一个个对象
    static AtomicStampedReference<Integer> atomicStampedReference = new AtomicStampedReference<>(1,1);

    // CAS  compareAndSet : 比较并交换！
    public static void main(String[] args) {

        new Thread(()->{
            int stamp = atomicStampedReference.getStamp(); // 获得版本号
            System.out.println("a1=>"+stamp);

            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            Lock lock = new ReentrantLock(true);

            atomicStampedReference.compareAndSet(1, 2,
                    atomicStampedReference.getStamp(), atomicStampedReference.getStamp() + 1);

            System.out.println("a2=>"+atomicStampedReference.getStamp());


            System.out.println(atomicStampedReference.compareAndSet(2, 1,
                    atomicStampedReference.getStamp(), atomicStampedReference.getStamp() + 1));

            System.out.println("a3=>"+atomicStampedReference.getStamp());

        },"a").start();


        // 乐观锁的原理相同！
        new Thread(()->{
            int stamp = atomicStampedReference.getStamp(); // 获得版本号
            System.out.println("b1=>"+stamp);

            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            System.out.println(atomicStampedReference.compareAndSet(1, 6,
                    stamp, stamp + 1));

            System.out.println("b2=>"+atomicStampedReference.getStamp());

        },"b").start();

    }
}

```





