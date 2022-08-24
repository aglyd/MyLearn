# [理解Semaphore及其用法详解][https://blog.csdn.net/u013851082/article/details/70208246]

Semaphore也是一个线程同步的辅助类，可以维护当前访问自身的线程个数，并提供了同步机制。使用Semaphore可以控制同时访问资源的线程个数，例如，实现一个文件允许的并发访问数。

Semaphore的主要方法摘要：

　　void acquire():从此信号量获取一个许可，在提供一个许可前一直将线程阻塞，否则线程被中断。

　　void release():释放一个许可，将其返回给信号量。

　　int availablePermits():返回此信号量中当前可用的许可数。

　　boolean hasQueuedThreads():查询是否有线程正在等待获取。

下面是一个例子：

```java
package com.thread;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;

public class SemaphoreTest {
    public static void main(String[] args) {
        ExecutorService service = Executors.newCachedThreadPool();
        final  Semaphore sp = new Semaphore(3);//创建Semaphore信号量，初始化许可大小为3
        for(int i=0;i<10;i++){
            try {
                Thread.sleep(100);
            } catch (InterruptedException e2) {
                e2.printStackTrace();
            }
            Runnable runnable = new Runnable(){
                    public void run(){
                    try {
                        sp.acquire();//请求获得许可，如果有可获得的许可则继续往下执行，许可数减1。否则进入阻塞状态
                    } catch (InterruptedException e1) {
                        e1.printStackTrace();
                    }
                    System.out.println("线程" + Thread.currentThread().getName() + 
                            "进入，当前已有" + (3-sp.availablePermits()) + "个并发");
                    try {
                        Thread.sleep((long)(Math.random()*10000));
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println("线程" + Thread.currentThread().getName() + 
                            "即将离开");                    
                    sp.release();//释放许可，许可数加1
                    //下面代码有时候执行不准确，因为其没有和上面的代码合成原子单元
                    System.out.println("线程" + Thread.currentThread().getName() + 
                            "已离开，当前已有" + (3-sp.availablePermits()) + "个并发");                    
                }
            };
            service.execute(runnable);            
        }
    }

}
```


　　单个信号量的Semaphore对象可以实现互斥锁的功能，并且可以是由一个线程获得了“锁”，再由另一个线程释放“锁”，这可应用于死锁恢复的一些场合。

```java
import java.util.Date;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class LockTest {
     public static void main(String[] args) {
             final Business business = new Business();
            ExecutorService executor =  Executors.newFixedThreadPool(3);
              for(int i=0;i<10;i++)
              {
                  executor.execute(
                                       new Runnable()
                             {
                                     public void run()
                                     {
                                           business.service();
                                         }
                                 }

                       );
                  }
               executor.shutdown();
            }

         private static class Business
    {
               private int count;
                Lock lock = new ReentrantLock();
              Semaphore sp = new Semaphore(1);
               public void service()
           {
                      //lock.lock();
                     try {
                                sp.acquire(); //当前线程使用count变量的时候将其锁住，不允许其他线程访问
                            } catch (InterruptedException e1) {
                                e1.printStackTrace();
                            }
                    try {
                            count++;
                            try {
                                 Thread.sleep(1000);
                             } catch (InterruptedException e) {
                                 e.printStackTrace();
                             }
                            System.out.println(new Date().toString()+count);	//每隔一秒获取一次
                        } catch (RuntimeException e) {
                            e.printStackTrace();
                        }
                    finally
                    {
                            //lock.unlock();
                            sp.release();  //释放锁
                         }
                   }
         }

         }
```

------------------------------------------------



# [Semaphore 使用及原理][https://zhuanlan.zhihu.com/p/98593407]

### **1、Semaphore 是什么**

Semaphore 通常我们叫它信号量， 可以用来控制同时访问特定资源的线程数量，通过协调各个线程，以保证合理的使用资源。

可以把它简单的理解成我们停车场入口立着的那个显示屏，每有一辆车进入停车场显示屏就会显示剩余车位减1，每有一辆车从停车场出去，显示屏上显示的剩余车辆就会加1，当显示屏上的剩余车位为0时，停车场入口的栏杆就不会再打开，车辆就无法进入停车场了，直到有一辆车从停车场出去为止。



### **2、使用场景**

通常用于那些资源有明确访问数量限制的场景，常用于限流 。

比如：数据库连接池，同时进行连接的线程有数量限制，连接不能超过一定的数量，当连接达到了限制数量后，后面的线程只能排队等前面的线程释放了数据库连接才能获得数据库连接。

比如：停车场场景，车位数量有限，同时只能容纳多少台车，车位满了之后只有等里面的车离开停车场外面的车才可以进入。



### **3、Semaphore常用方法说明**

```java
acquire()  
获取一个令牌，在获取到令牌、或者被其他线程调用中断之前线程一直处于阻塞状态。

acquire(int permits)  
获取一个令牌，在获取到令牌、或者被其他线程调用中断、或超时之前线程一直处于阻塞状态。
    
acquireUninterruptibly() 
获取一个令牌，在获取到令牌之前线程一直处于阻塞状态（忽略中断）。
    
tryAcquire()
尝试获得令牌，返回获取令牌成功或失败，不阻塞线程。

tryAcquire(long timeout, TimeUnit unit)
尝试获得令牌，在超时时间内循环尝试获取，直到尝试获取成功或超时返回，不阻塞线程。

release()
释放一个令牌，唤醒一个获取令牌不成功的阻塞线程。

hasQueuedThreads()
等待队列里是否还存在等待线程。

getQueueLength()
获取等待队列里阻塞的线程数。

drainPermits()
清空令牌把可用令牌数置为0，返回清空令牌的数量。

availablePermits()
返回可用的令牌数量。
```



### **4、用semaphore 实现停车场提示牌功能。**



每个停车场入口都有一个提示牌，上面显示着停车场的剩余车位还有多少，当剩余车位为0时，不允许车辆进入停车场，直到停车场里面有车离开停车场，这时提示牌上会显示新的剩余车位数。



**业务场景 ：**

1、停车场容纳总停车量10。

2、当一辆车进入停车场后，显示牌的剩余车位数响应的减1.

3、每有一辆车驶出停车场后，显示牌的剩余车位数响应的加1。

4、停车场剩余车位不足时，车辆只能在外面等待。



**代码：**

```java
public class TestCar {

    //停车场同时容纳的车辆10
    private  static  Semaphore semaphore=new Semaphore(10);

    public static void main(String[] args) {

        //模拟100辆车进入停车场
        for(int i=0;i<100;i++){

            Thread thread=new Thread(new Runnable() {
                public void run() {
                    try {
                        System.out.println("===="+Thread.currentThread().getName()+"来到停车场");
                        if(semaphore.availablePermits()==0){
                            System.out.println("车位不足，请耐心等待");
                        }
                        semaphore.acquire();//获取令牌尝试进入停车场
                        System.out.println(Thread.currentThread().getName()+"成功进入停车场");
                        Thread.sleep(new Random().nextInt(10000));//模拟车辆在停车场停留的时间
                        System.out.println(Thread.currentThread().getName()+"驶出停车场");
                        semaphore.release();//释放令牌，腾出停车场车位
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            },i+"号车");

            thread.start();

        }

    }
}

```



### **5、Semaphore实现原理**



### **(1)、Semaphore初始化。**



```java
Semaphore semaphore=new Semaphore(2);
```

1、当调用new Semaphore(2) 方法时，默认会创建一个非公平的锁的同步阻塞队列。

2、把初始令牌数量赋值给同步队列的state状态，state的值就代表当前所剩余的令牌数量。



**初始化完成后同步队列信息如下图：**



![img](理解Semaphore及其用法详解.assets/v2-5f78e28f05d2a656fa534b5a816c45ac_720w.jpg)







### **（2）获取令牌**



```java
semaphore.acquire();
```

1、当前线程会尝试去同步队列获取一个令牌，获取令牌的过程也就是使用原子的操作去修改同步队列的state ,获取一个令牌则修改为state=state-1。

2、 当计算出来的state<0，则代表令牌数量不足，此时会创建一个Node节点加入阻塞队列，挂起当前线程。

3、当计算出来的state>=0，则代表获取令牌成功。



源码：

```java
/**
     *  获取1个令牌
     */
    public void acquire() throws InterruptedException {
        sync.acquireSharedInterruptibly(1);
    }
```



```java
/**
     * 共享模式下获取令牌，获取成功则返回，失败则加入阻塞队列，挂起线程
     * @param arg
     * @throws InterruptedException
     */
    public final void acquireSharedInterruptibly(int arg)
            throws InterruptedException {
        if (Thread.interrupted())
            throw new InterruptedException();
        //尝试获取令牌，arg为获取令牌个数，当可用令牌数减当前令牌数结果小于0,则创建一个节点加入阻塞队列，挂起当前线程。
        if (tryAcquireShared(arg) < 0)
            doAcquireSharedInterruptibly(arg);
    }
```



```java
/**
     * 1、创建节点，加入阻塞队列，
     * 2、重双向链表的head，tail节点关系，清空无效节点
     * 3、挂起当前节点线程
     * @param arg
     * @throws InterruptedException
     */
    private void doAcquireSharedInterruptibly(int arg)
        throws InterruptedException {
        //创建节点加入阻塞队列
        final Node node = addWaiter(Node.SHARED);
        boolean failed = true;
        try {
            for (;;) {
                //获得当前节点pre节点
                final Node p = node.predecessor();
                if (p == head) {
                    int r = tryAcquireShared(arg);//返回锁的state
                    if (r >= 0) {
                        setHeadAndPropagate(node, r);
                        p.next = null; // help GC
                        failed = false;
                        return;
                    }
                }
                //重组双向链表，清空无效节点，挂起当前线程
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    throw new InterruptedException();
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }
```





**线程1、线程2、线程3、分别调用semaphore.acquire(),整个过程队列信息变化如下图：**

![img](理解Semaphore及其用法详解.assets/v2-698639f5f06e35b648ad7f1eb41b04b0_720w.jpg)







### **(3)、释放令牌**



```java
 semaphore.release();
```

当调用semaphore.release() 方法时

1、线程会尝试释放一个令牌，释放令牌的过程也就是把同步队列的state修改为state=state+1的过程

2、释放令牌成功之后，同时会唤醒同步队列中的一个线程。

3、被唤醒的节点会重新尝试去修改state=state-1 的操作，如果state>=0则获取令牌成功，否则重新进入阻塞队列，挂起线程。



**源码：**

```java
 /**
     * 释放令牌
     */
    public void release() {
        sync.releaseShared(1);
    }
```



```java
/**
     *释放共享锁，同时会唤醒同步队列中的一个线程。
     * @param arg
     * @return
     */
    public final boolean releaseShared(int arg) {
        //释放共享锁
        if (tryReleaseShared(arg)) {
            //唤醒所有共享节点线程
            doReleaseShared();
            return true;
        }
        return false;
    }
```



```java
 /**
     * 唤醒同步队列中的一个线程
     */
    private void doReleaseShared() {
        for (;;) {
            Node h = head;
            if (h != null && h != tail) {
                int ws = h.waitStatus;
                if (ws == Node.SIGNAL) {//是否需要唤醒后继节点
                    if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))//修改状态为初始0
                        continue;
                    unparkSuccessor(h);//唤醒h.nex节点线程
                }
                else if (ws == 0 &&
                         !compareAndSetWaitStatus(h, 0, Node.PROPAGATE));
            }
            if (h == head)                   // loop if head changed
                break;
        }
    }
```



**继上面的图，当我们线程1调用semaphore.release(); 时候整个流程如下图：**

![img](https://pic2.zhimg.com/80/v2-03aa28cc53dfe6820d46d8517c1e1e59_720w.jpg)

