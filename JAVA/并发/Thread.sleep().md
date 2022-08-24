# [Thread.sleep()和Thread.currentThread().sleep()区别](https://blog.csdn.net/weinihecaihktk/article/details/79565267)

为什么要用sleep，主要是为了暂停当前线程，把cpu片段让出给其他线程，减缓当前线程的执行。

两种方式：
第一种方式是只调用sleep静态方法；第二种是获取对象后再调用sleep静态方法。第二种方式效率要低一些，因为多了一次函数调用，而且通过对象调用静态方法也不太符合“静态”的定义（静态成员最好通过类名直接访问），但功能上是一致的。当需要调用非静态方法时使用第二种方式，否则直接使用第一种方式。



线程可以用继承[Thread类](https://so.csdn.net/so/search?q=Thread类&spm=1001.2101.3001.7020)或者实现Runnable接口来实现.

**Thread.sleep()是Thread类的方法,只对当前线程起作用,睡眠一段时间.**

**如果线程是通过继承Thread实现的话这2个方法没有区别；**

**如果线程是通过实现Runnable接口来实现的,则不是Thread类,不能直接使用Thread.sleep()**

**必须使用Thread.currentThread()来得到当前线程的引用才可以调用sleep(),**

所以要用Thread.currentThread().sleep()来睡眠...

```java
/**
 * 消息管理类
 * @author CheerForU
 * 
 */
public class MsgManage {
    public static void main(final String[] args) {
        try {
            init();
            //循环等待消息，一直监听，捕捉到异常退出
            while (true) {
                Thread.sleep(30000);
            }
        } catch (final Exception e) {
            e.printStackTrace();
            destroy();
        }
    }

    //消息初始化
    public static void init() {
        init();
    }

    //消息销毁
    public static void destroy() {
        destroy();
    }
}

```

```java
    new Thread( new Runnable() {
        
        @Override
        public void run() {
            // TODO Auto-generated method stub
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }).start();
    }
```





----

# [Thread.sleep()概述](https://blog.csdn.net/selftaught0424/article/details/112727328)

sleep
Thread.sleep()被用来暂停当前线程的执行,会通知线程调度器把当前线程在指定的时间周期内置为wait状态。当wait时间结束，线程状态重新变为Runnable并等待CPU的再次调度执行。所以线程sleep的实际时间取决于线程调度器，而这是由操作系统来完成的。
一个进程在运行态时调用sleep()，进入等待态，睡眠结束以后，并不是直接回到运行态，而是进入就绪队列,要等到其他进程放弃时间片后才能重新进入运行态。所以sleep(1000),在1000ms以后，线程不一定会被唤醒。sleep(0)可以看成一个运行态的进程产生一个中断，由运行态直接转入就绪态。这样做是给其他就绪态进程使用时间片的机会。总之，还是操作系统中运行态、就绪态和等待态相互转化的问题。

功能介绍：
让当前线程由运行状态进入到阻塞状态，进而使其他线程有机会继续执行任务。虽然使线程休眠，但是并不释放对象锁，所以说如果在同步块中使用sleep()，其他线程仍然无法获得执行权限。

注意：sleep()方法定义在Thread类中，会调用sleep(millis)这个本地方法，抛出InterruptedException异常，因此需要捕获该异常

```
Thread sleep(long millis)  
暂停当前线程的执行，暂停时间由方法参数指定，单位为毫秒。
注意参数不能为负数，否则程序将会抛出IllegalArgumentException。

Thread sleep(long millis, int nanos)  
暂停当前线程的执行，暂停时间为millis毫秒数加上nanos纳秒数。
纳秒允许的取值范围为0~999999.

```

例：

```java
public class Dome {
    public static void main(String[] args) throws InterruptedException {
        for (int i = 0; i < 10; i++) {
            System.out.println(i);
            //每隔一秒钟进行一次循环输出
            Thread.sleep(1000);//单位：毫秒
        }
    }
}
运行结果：
0
1
2
3
4
```

总结

它只用于暂停当前线程的执行。
线程被wake up并开始执行的实际时间取决于操作系统的CPU时间片长度及调度策略。对于相对空闲的系统来说，sleep的实际时间与指定的sleep时间相近，但对于操作繁忙的系统，这个时间将会显得略长一些。
3.其他的任意线程都能中断当前sleep的线程，并会抛出InterruptedException。
4.sleep()是Thread类的Static(静态)的方法，因此他不能改变对象的机锁，所以当在一个Synchronized块中调用Sleep()方法是，线程虽然休眠了，但是对象的机锁并木有被释放，其他线程无法访问这个对象（即使睡着也持有对象锁）。
5.在sleep()休眠时间期满后，该线程不一定会立即执行，这是因为其它线程可能正在运行而且没有被调度为放弃执行，除非此线程具有更高的优先级。
6.当一个线程执行代码的时候调用了sleep方法后，线程处于睡眠状态，需要设置一个睡眠时间，此时有其他线程需要执行时就会造成线程阻塞，而且sleep方法被调用之后，线程不会释放锁对象，但是锁还在该线程手里,等睡眠一段时间后，该线程就会进入就绪状态。
线程阻塞：
通常是指一个线程在执行过程中暂停，以等待某个条件的触发。可以简单理解为所有比较消耗线程时间的操作。如：常见的文件读取、接受用户输入。

