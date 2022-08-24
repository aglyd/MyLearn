# [Java 多线程设置线程超时结束之 Callable实现和Future实现](https://blog.csdn.net/Hubz131/article/details/103096867)

## 一、FutureTask类同时又实现了Runnable接口，所以可以直接提交给Executor执行。

```java
import java.util.concurrent.*;
 
public class 进程超时结束 {
    public static void main(String[] args) {
        String result = null;
        ExecutorService executor = Executors.newSingleThreadExecutor();
        FutureTask<String> future = new FutureTask<String>(new Callable<String>() {//使用Callable接口作为构造参数
                    public String call() {
                        //真正的任务在这里执行，这里的返回值类型为String，可以为任意类型
                        try {
                            Thread.sleep(600);
                        } catch (InterruptedException e) {
                            System.out.println("InterruptedException");
                        }
                        return "Hello";
                    }});
        executor.execute(future);
        //在这里可以做别的任何事情
        try {
            //取得结果，同时设置超时执行时间为0.5秒。
            // 同样可以用future.get()，不设置执行超时时间取得结果
            result = future.get(500, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            System.out.println("InterruptedException");
            future.cancel(true);
        }
        catch(ExecutionException e){
            System.out.println("ExecutionException");
            future.cancel(true);
        }
        catch (TimeoutException e) {
            System.out.println("TimeOut Error");
            future.cancel(true);
        }
        catch(Exception e) {
            System.out.println(e.getMessage());
        }
        finally
        {
            executor.shutdown();
        }
        System.out.println(result);
    }
```

**二、不直接构造Future对象，也可以使用ExecutorService.submit方法来获得Future对象，submit方法即支持以 Callable接口类型，也支持Runnable接口作为参数，具有很大的灵活性。**

```java
import java.util.concurrent.*;
 
public class 进程超时结束 {
    public static void  main(String[] args){
        String result = null;
        TaskThread task = new TaskThread();   //实现Callable接口的任务线程类
        ExecutorService executor = Executors.newFixedThreadPool(1);
        //对task对象进行各种set操作以初始化任务
        Future<String> future = executor.submit(task);
        try {
            result = future.get(300, TimeUnit.MILLISECONDS);
        }
        catch(InterruptedException | TimeoutException | ExecutionException e){
            System.out.println("ERROR");
        }
        finally {
            executor.shutdownNow();
        }
        System.out.println(result);
    }
}
class TaskThread implements Callable{
    @Override
    public Object call() throws Exception {
        Thread.sleep(5000);
        return "Hello";
    }
}
```



# [Java多线程](https://blog.csdn.net/qq_44715943/article/details/116714584)

## 1、什么是进程？什么是线程？
进程是:一个应用程序（1个进程是一个软件）。

线程是：一个进程中的执行场景/执行单元。

注意：  **==一个进程可以启动多个线程。==**

eg.
对于java程序来说，当在DOS命令窗口中输入：
java HelloWorld 回车之后。会先启动JVM，而JVM就是一个进程。

JVM再启动一个主线程调用main方法（main方法就是主线程）。
同时再启动一个垃圾回收线程负责看护，回收垃圾。

最起码，现在的java程序中至少有两个线程并发，一个是 垃圾回收线程，一个是 执行main方法的主线程。

## 2、进程和线程是什么关系？

进程：可以看做是现实生活当中的公司。

线程：可以看做是公司当中的某个员工。

注意：
进程A和进程B的 内存独立不共享。

eg.
魔兽游戏是一个进程
酷狗音乐是一个进程
这两个进程是独立的，不共享资源。

线程A和线程B是什么关系？
在java语言中：

线程A和线程B，堆内存 和 方法区 内存共享。但是 栈内存 独立，一个线程一个栈。

eg.
假设启动10个线程，会有10个栈空间，每个栈和每个栈之间，互不干扰，各自执行各自的，这就是多线程并发。

eg.
火车站，可以看做是一个进程。
火车站中的每一个售票窗口可以看做是一个线程。
我在窗口1购票，你可以在窗口2购票，你不需要等我，我也不需要等你。所以多线程并发可以提高效率。

java中之所以有多线程机制，目的就是为了 提高程序的处理效率。

## 3、思考一个问题

使用了多线程机制之后，main方法结束，是不是有可能程序也不会结束？
main方法结束只是主线程结束了，主栈空了，其它的栈(线程)可能还在压栈弹栈。

4.分析一个问题
对于单核的CPU来说，真的可以做到真正的多线程并发吗？
对于多核的CPU电脑来说，真正的多线程并发是没问题的。4核CPU表示同一个时间点上，可以真正的有4个进程并发执行。

单核的CPU表示只有一个大脑：
不能够做到真正的多线程并发，但是可以做到给人一种“多线程并发”的感觉。

对于单核的CPU来说，在某一个时间点上实际上只能处理一件事情，但是由于CPU的处理速度极快，多个线程之间频繁切换执行，给别人的感觉是：多个事情同时在做！！！

eg.
线程A：播放音乐

线程B：运行魔兽游戏

线程A和线程B频繁切换执行，人类会感觉音乐一直在播放，游戏一直在运行，
给我们的感觉是同时并发的。（因为计算机的速度很快，我们人的眼睛很慢，所以才会感觉是多线程！）

## 4、什么是真正的多线程并发？

t1线程执行t1的。
t2线程执行t2的。
t1不会影响t2，t2也不会影响t1。这叫做真正的多线程并发。

## 5、关于线程对象的生命周期（附图)？★★★★★

新建状态
就绪状态
运行状态
阻塞状态
死亡状态

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210512173109590.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NzE1OTQz,size_16,color_FFFFFF,t_70)

线程构造方法

| 构造方法名                           | 备注           |
| ------------------------------------ | -------------- |
|                                      |                |
| Thread()                             |                |
| Thread(String name)                  | name为线程名字 |
| **创建线程第二种方式**               |                |
| Thread(Runnable target)              |                |
| Thread(Runnable target, String name) | name为线程名字 |

## 6、java语言中，实现线程有两种方式

### 第一种方式：

编写一个类，直接 继承 java.lang.Thread，重写 run方法。

怎么创建线程对象？ new继承线程的类。
怎么启动线程呢？ 调用线程对象的 start() 方法。
伪代码：

```java
// 定义线程类
public class MyThread extends Thread{
	public void run(){
	

}

}
// 创建线程对象
MyThread t = new MyThread();
// 启动线程。
t.start();
```

eg.

```java
public class ThreadTest02 {
    public static void main(String[] args) {
        MyThread t = new MyThread();
        // 启动线程
        //t.run(); // 不会启动线程，不会分配新的分支栈。（这种方式就是单线程。）
        t.start();
        // 这里的代码还是运行在主线程中。
        for(int i = 0; i < 1000; i++){
            System.out.println("主线程--->" + i);
        }
    }
}

class MyThread extends Thread {
    @Override
    public void run() {
        // 编写程序，这段程序运行在分支线程中（分支栈）。
        for(int i = 0; i < 1000; i++){
            System.out.println("分支线程--->" + i);
        }
    }
}

```


注意：

- t.run() 不会启动线程，只是普通的调用方法而已。**==不会分配新的分支栈。==**（这种方式就是单线程。）
- **t.start() 方法的作用是：启动一个分支线程，==在JVM中开辟一个新的栈空间==，这段代码任务完成之后，瞬间就结束了。**
  **这段代码的任务只是为了开启一个新的栈空间，只要新的栈空间开出来，start()方法就结束了。线程就启动成功了。**
  **启动成功的线程会自动调用run方法，并且run方法在分支栈的栈底部（压栈）。**
  **run方法在分支栈的栈底部，main方法在主栈的栈底部。run和main是平级的。**

调用run()方法内存图：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210512174955123.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NzE1OTQz,size_16,color_FFFFFF,t_70#pic_center)

**调用start()方法内存图：**

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210512175007490.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NzE1OTQz,size_16,color_FFFFFF,t_70#pic_center)

### 第二种方式：

编写一个类，实现 java.lang.Runnable 接口，实现run方法。

怎么创建线程对象？ new线程类传入可运行的类/接口。
怎么启动线程呢？ 调用线程对象的 start() 方法。
伪代码：

```java
// 定义一个可运行的类
public class MyRunnable implements Runnable {
	public void run(){
	

}

}
// 创建线程对象
Thread t = new Thread(new MyRunnable());
// 启动线程
t.start();
```


eg.

```java
public class ThreadTest03 {
    public static void main(String[] args) {
        Thread t = new Thread(new MyRunnable()); 
        // 启动线程
        t.start();
        

    for(int i = 0; i < 100; i++){
        System.out.println("主线程--->" + i);
    }
}

}

// 这并不是一个线程类，是一个可运行的类。它还不是一个线程。
class MyRunnable implements Runnable {
    @Override
    public void run() {
        for(int i = 0; i < 100; i++){
            System.out.println("分支线程--->" + i);
        }
    }
}
```

### 采用匿名内部类创建：

```java
public class ThreadTest04 {
    public static void main(String[] args) {
        // 创建线程对象，采用匿名内部类方式。
        Thread t = new Thread(new Runnable(){
            @Override
            public void run() {
                for(int i = 0; i < 100; i++){
                    System.out.println("t线程---> " + i);
                }
            }
        });


    // 启动线程
    t.start();

    for(int i = 0; i < 100; i++){
        System.out.println("main线程---> " + i);
    }
}


}
```

注意：
第二种方式实现接口比较常用，因为一个类实现了接口，它还可以去继承其它的类，更灵活。

## 7、获取当前线程对象、获取线程对象名字、修改线程对象名字

| 方法名                        | 作用             |
| ----------------------------- | ---------------- |
| static Thread currentThread() | 获取当前线程对象 |
| String getName()              | 获取线程对象名字 |
| void setName(String name)     | 修改线程对象名字 |

当线程没有设置名字的时候，默认的名字是什么？

- Thread-0
- Thread-1
- Thread-2
- Thread-3
- …

eg.

```java
class MyThread2 extends Thread {
    public void run(){
        for(int i = 0; i < 100; i++){
            // currentThread就是当前线程对象。当前线程是谁呢？
            // 当t1线程执行run方法，那么这个当前线程就是t1
            // 当t2线程执行run方法，那么这个当前线程就是t2
            Thread currentThread = Thread.currentThread();
            System.out.println(currentThread.getName() + "-->" + i);

        //System.out.println(super.getName() + "-->" + i);
        //System.out.println(this.getName() + "-->" + i);
    }
}

}
```

## 8、关于线程的sleep方法

| 方法名                         | 作用                   |
| ------------------------------ | ---------------------- |
| static void sleep(long millis) | 让当前线程休眠millis秒 |

1. 静态方法：Thread.sleep(1000);
2. 参数是毫秒
3. 作用： 让当前线程进入休眠，进入“阻塞状态”，放弃占有CPU时间片，让给其它线程使用。
   这行代码出现在A线程中，A线程就会进入休眠。
   这行代码出现在B线程中，B线程就会进入休眠。
4. Thread.sleep()方法，可以做到这种效果：
   间隔特定的时间，去执行一段特定的代码，每隔多久执行一次。

eg.

```java
public class ThreadTest06 {
    public static void main(String[] args) {
    	//每打印一个数字睡1s
        for(int i = 0; i < 10; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);

        // 睡眠1秒
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

}
```

## 9、关于线程中断sleep()的方法

| 方法名           | 作用           |
| ---------------- | -------------- |
| void interrupt() | 终止线程的睡眠 |

eg.

9、关于线程中断sleep()的方法
方法名	作用
void interrupt()	终止线程的睡眠
eg.

```java
public class ThreadTest08 {
    public static void main(String[] args) {
        Thread t = new Thread(new MyRunnable2());
        t.setName("t");
        t.start();

​    // 希望5秒之后，t线程醒来（5秒之后主线程手里的活儿干完了。）
​    try {
​        Thread.sleep(1000 * 5);
​    } catch (InterruptedException e) {
​        e.printStackTrace();
​    }
​    // 终断t线程的睡眠（这种终断睡眠的方式依靠了java的异常处理机制。）
​    t.interrupt();
}

}

class MyRunnable2 implements Runnable {
    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + "---> begin");
        try {
            // 睡眠1年
            Thread.sleep(1000 * 60 * 60 * 24 * 365);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        //1年之后才会执行这里
        System.out.println(Thread.currentThread().getName() + "---> end");
}
```

## 10、补充：run()方法小知识点

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210512181620548.png)

### 为什么run()方法只能try…catch…不能throws？

**==因为run()方法在父类中没有抛出任何异常，子类不能比父类抛出更多的异常。==**

## 11、java中强行终止一个线程的执行（不推荐使用，了解即可！）

eg.

```java
public class ThreadTest09 {
    public static void main(String[] args) {
        Thread t = new Thread(new MyRunnable3());
        t.setName("t");
        t.start();

​    // 模拟5秒
​    try {
​        Thread.sleep(1000 * 5);
​    } catch (InterruptedException e) {
​        e.printStackTrace();
​    }
​    // 5秒之后强行终止t线程
​    t.stop(); // 已过时（不建议使用。）
}

}

class MyRunnable3 implements Runnable {

@Override
public void run() {
    for(int i = 0; i < 10; i++){
        System.out.println(Thread.currentThread().getName() + "--->" + i);
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

}
```


注意：

这种方式存在很大的缺点：**容易丢失数据。**

因为这种方式是**直接将线程杀死了，线程没有保存的数据将会丢失。不建议使用。**

## 12、Java中合理结束一个进程的执行（常用）

eg.

```java
public class ThreadTest10 {
    public static void main(String[] args) {
        MyRunable4 r = new MyRunable4();
        Thread t = new Thread(r);
        t.setName("t");
        t.start();

​    // 模拟5秒
​    try {
​        Thread.sleep(5000);
​    } catch (InterruptedException e) {
​        e.printStackTrace();
​    }
​    // 终止线程
​    // 你想要什么时候终止t的执行，那么你把标记修改为false，就结束了。
​    r.run = false;
}

}

class MyRunable4 implements Runnable {

// 打一个布尔标记
boolean run = true;

@Override
public void run() {
    for (int i = 0; i < 10; i++){
        if(run){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }else{
            // return就结束了，你在结束之前还有什么没保存的。
            // 在这里可以保存呀。
            //save....

            //终止当前线程
            return;
        }
    }
}

}
```

**为什么if()语句要在循环里面？**

由于一个线程一直运行此程序，要是if判断在外面只会在启动线程时判断并不会结束，因此需要每次循环判断一下标记。

### 补充小知识：线程调度（了解）

#### 1.常见的线程调度模型有哪些

- **抢占式**调度模型：
  那个线程的优先级比较高，抢到的CPU时间片的概率就高一些/多一些。
  **java采用的就是抢占式调度模型**。
- **均分式**调度模型：
  平均分配CPU时间片。每个线程占有的CPU时间片时间长度一样。
  平均分配，一切平等。
  有一些编程语言，线程调度模型采用的是这种方式。

#### 2.java中提供了哪些方法是和线程调度有关系的呢？

##### 2.1实例方法：

| 方法名                            | 作用           |
| --------------------------------- | -------------- |
| int getPriority()                 | 获得线程优先级 |
| void setPriority(int newPriority) | 设置线程优先级 |

**最低优先级1**
**默认优先级是5**
**最高优先级10**

优先级比较高的获取CPU时间片可能会多一些。（但也不完全是，大概率是多的。）

##### 2.2静态方法：

| 方法名              | 作用                                                 |
| ------------------- | ---------------------------------------------------- |
| static void yield() | 让位方法，当前线程暂停，回到就绪状态，让给其它线程。 |

yield()方法不是阻塞方法。让当前线程让位，让给其它线程使用。

yield()方法的执行会让当前线程从“**运行状态**”回到“**就绪状态**”。

注意：在回到就绪之后，**有可能还会再次抢到。**

##### 2.3实例方法：

| 方法名      | 作用                                                         |
| ----------- | ------------------------------------------------------------ |
| void join() | 将一个线程合并到当前线程中，当前线程受阻塞，加入的线程执行直到结束 |

eg.

```java
class MyThread1 extends Thread {
	public void doSome(){
		MyThread2 t = new MyThread2();
		t.join(); // 当前线程进入阻塞，t线程执行，直到t线程结束。当前线程才可以继续。
	}
}

class MyThread2 extends Thread{

}
```

## 13、Java进程的优先级

常量：

| 常量名                   | 备注             |
| ------------------------ | ---------------- |
| static int MAX_PRIORITY  | 最高优先级（10） |
| static int MIN_PRIORITY  | 最低优先级（1）  |
| static int NORM_PRIORITY | 默认优先级（5）  |

方法：

| 方法名                            | 作用           |
| --------------------------------- | -------------- |
| int getPriority()                 | 获得线程优先级 |
| void setPriority(int newPriority) | 设置线程优先级 |

```java
public class ThreadTest11 {
    public static void main(String[] args) {
        System.out.println("最高优先级：" + Thread.MAX_PRIORITY);//最高优先级：10
        System.out.println("最低优先级:" + Thread.MIN_PRIORITY);//最低优先级:1
        System.out.println("默认优先级:" + Thread.NORM_PRIORITY);//默认优先级:5
        

​    // main线程的默认优先级是：5
​    System.out.println(hread.currentThread().getName() + "线程的默认优先级是：" + currentThread.getPriority());

​    Thread t = new Thread(new MyRunnable5());
​    t.setPriority(10);
​    t.setName("t");
​    t.start();

​    // 优先级较高的，只是抢到的CPU时间片相对多一些。
​    // 大概率方向更偏向于优先级比较高的。
​    for(int i = 0; i < 10000; i++){
​        System.out.println(Thread.currentThread().getName() + "-->" + i);
​    }
}

}

class MyRunnable5 implements Runnable {
    @Override
    public void run() {
        for(int i = 0; i < 10000; i++){
            System.out.println(Thread.currentThread().getName() + "-->" + i);
        }
    }
}
```

注意：

**main线程的默认优先级是：5**
优先级较高的，只是抢到的CPU时间片相对多一些。大概率方向更偏向于优先级比较高的。

## 14、关于线程的yield()方法

| 方法名              | 作用                                             |
| ------------------- | ------------------------------------------------ |
| static void yield() | 让位，当前线程暂停，回到就绪状态，让给其它线程。 |

eg.

```java
public class ThreadTest12 {
    public static void main(String[] args) {
        Thread t = new Thread(new MyRunnable6());
        t.setName("t");
        t.start();

​    for(int i = 1; i <= 10000; i++) {
​        System.out.println(Thread.currentThread().getName() + "--->" + i);
​    }
}

}

class MyRunnable6 implements Runnable {

@Override
public void run() {
    for(int i = 1; i <= 10000; i++) {
        //每100个让位一次。
        if(i % 100 == 0){
            Thread.yield(); // 当前线程暂停一下，让给主线程。
        }
        System.out.println(Thread.currentThread().getName() + "--->" + i);
    }
}

}
```


注意： 并不是每次都让成功的，有可能它又抢到时间片了。

## 15、关于线程的join()方法

| 方法名                            | 作用                                                         |
| --------------------------------- | ------------------------------------------------------------ |
| void join()                       | 将一个线程合并到当前线程中，当前线程受阻塞，加入的线程执行直到结束 |
| void join(long millis)            | 接上条，等待该线程终止的时间最长为 millis 毫秒               |
| void join(long millis, int nanos) | 接第一条，等待该线程终止的时间最长为 millis 毫秒 + nanos 纳秒 |

```java
public class ThreadTest13 {
    public static void main(String[] args) {
        System.out.println("main begin");

​    Thread t = new Thread(new MyRunnable7());
​    t.setName("t");
​    t.start();

​    //合并线程
​    try {
​        t.join(); // t合并到当前线程中，当前线程受阻塞，t线程执行直到结束。
​    } catch (InterruptedException e) {
​        e.printStackTrace();
​    }

​    System.out.println("main over");
}

}

class MyRunnable7 implements Runnable {

@Override
public void run() {
    for(int i = 0; i < 10000; i++){
        System.out.println(Thread.currentThread().getName() + "--->" + i);
    }
}

}
```

**==注意： 一个线程.join()，当前线程会进入”阻塞状态“。等待加入线程执行完！==**

## 补充小知识：多线程并发环境下，数据的安全问题（重点）

### 1.为什么这个是重点？

以后在开发中，我们的项目都是运行在服务器当中，而服务器已经将线程的定义，线程对象的创建，线程的启动等，都已经实现完了。这些代码我们都不需要编写。

**最重要的是： 你要知道，你编写的程序需要放到一个多线程的环境下运行，你更需要关注的是这些数据在多线程并发的环境下是否是安全的。（重点：★★★★★）**

### 2.什么时候数据在多线程并发的环境下会存在安全问题呢？★★★★★

**满足三个条件：**

- 条件1：**==多线程并发。==**
- 条件2：**==有共享数据。==**
- 条件3：==**共享数据有修改的行为。**==

满足以上3个条件之后，就会存在线程安全问题。

### 3.怎么解决线程安全问题呢？

当**多线程并发的环境下，有共享数据，并且这个数据还会被修改**，此时就存在线程安全问题，怎么解决这个问题？

**线程排队执行。（不能并发）**。用排队执行解决线程安全问题。

这种机制被称为：**线程同步机制。**

专业术语叫做：**==线程同步==**，实际上就是线程不能并发了，线程必须排队执行。

线程同步就是线程排队了，线程排队了就会 **==牺牲一部分效率==** ，没办法，数据安全第一位，只有数据安全了，我们才可以谈效率。数据不安全，没有效率的事儿。

### 4.两个专业术语：

#### 异步编程模型：

线程t1和线程t2，各自执行各自的，t1不管t2，t2不管t1，谁也不需要等谁，这种编程模型叫做：异步编程模型。

其实就是：多线程并发（效率较高。）

**==异步就是并发。==**

#### 同步编程模型：

线程t1和线程t2，在线程t1执行的时候，必须等待t2线程执行结束，或者说在t2线程执行的时候，必须等待t1线程执行结束，两个线程之间发生了等待关系，这就是同步编程模型。

效率较低。线程排队执行。

**==同步就是排队。==**

## 16、线程安全

### 16.1、synchronized-线程同步

线程同步机制的语法是：

```java
synchronized(){
	// 线程同步代码块。
}
```

重点：
synchronized后面小括号() 中传的这个“数据”是相当关键的。这个数据必须是 **==多线程共享==** 的数据。才能达到多线程排队。

### 16.1.1 ()中写什么？

那要看你想让哪些线程同步。

假设t1、t2、t3、t4、t5，有5个线程，你只希望t1 t2 t3排队，t4 t5不需要排队。怎么办？

你一定要在()中写一个t1 t2 t3共享的对象。而这个对象对于t4 t5来说不是共享的。

这里的共享对象是：账户对象。
账户对象是共享的，那么this就是账户对象！！！
**()不一定是this，这里只要是多线程共享的那个对象就行。**

注意：
在java语言中，任何一个对象都有“一把锁”，其实这把锁就是标记。（只是把它叫做锁。）
**100个对象，100把锁。1个对象1把锁。**

### 16.1.2 以下代码的执行原理？（★★★★★）

1、假设t1和t2线程并发，开始执行以下代码的时候，肯定有一个先一个后。

2、假设t1先执行了，遇到了**synchronized**，这个时候自动找“后面共享对象”的对象锁，
找到之后，并占有这把锁，然后执行同步代码块中的程序，在程序执行过程中一直都是
占有这把锁的。**直到同步代码块代码结束，这把锁才会释放。**

3、假设t1已经占有这把锁，此时t2也遇到synchronized关键字，也会去占有后面
共享对象的这把锁，结果这把锁被t1占有，t2只能在同步代码块外面等待t1的结束，
直到t1把同步代码块执行结束了，t1会归还这把锁，此时t2终于等到这把锁，然后
t2占有这把锁之后，进入同步代码块执行程序。

4、这样就达到了**线程排队**执行。

**重中之重：**
**这个共享对象一定要选好了。这个共享对象一定是你需要排队**
**执行的这些线程对象所共享的。**

```java
class Account {
    private String actno;
    private double balance; //实例变量。

//对象
Object o= new Object(); // 实例变量。（Account对象是多线程共享的，Account对象中的实例变量obj也是共享的。）

public Account() {
}

public Account(String actno, double balance) {
    this.actno = actno;
    this.balance = balance;
}

public String getActno() {
    return actno;
}

public void setActno(String actno) {
    this.actno = actno;
}

public double getBalance() {
    return balance;
}

public void setBalance(double balance) {
    this.balance = balance;
}

//取款的方法
public void withdraw(double money){
    /**

- 以下可以共享,金额不会出错
   以下这几行代码必须是线程排队的，不能并发。
  - 一个线程把这里的代码全部执行结束之后，另一个线程才能进来。
    /
        synchronized(this) {
        //synchronized(actno) {
        //synchronized(o) {

​    /**

- 以下不共享，金额会出错
  /
    /*Object obj = new Object();
  synchronized(obj) { // 这样编写就不安全了。因为obj2不是共享对象。
  synchronized(null) {//编译不通过
  String s = null;
  synchronized(s) {//java.lang.NullPointerException*/
  double before = this.getBalance();
  double after = before - money;
  try {
      Thread.sleep(1000);
  } catch (InterruptedException e) {
      e.printStackTrace();
  }
  this.setBalance(after);
      //}
  }

}

class AccountThread extends Thread {
    // 两个线程必须共享同一个账户对象。
    private Account act;

// 通过构造方法传递过来账户对象
public AccountThread(Account act) {
    this.act = act;
}

public void run(){
    double money = 5000;
    act.withdraw(money);
    System.out.println(Thread.currentThread().getName() + "对"+act.getActno()+"取款"+money+"成功，余额" + act.getBalance());
}

}

public class Test {
    public static void main(String[] args) {
        // 创建账户对象（只创建1个）
        Account act = new Account("act-001", 10000);
        // 创建两个线程，共享同一个对象
        Thread t1 = new AccountThread(act);
        Thread t2 = new AccountThread(act);

​    t1.setName("t1");
​    t2.setName("t2");
​    t1.start();
​    t2.start();
}

}
```

以上代码锁**==this、实例变量actno、实例变量o==**都可以！因为这三个是线程共享！

### 16.1.3 在实例方法上可以使用synchronized

**synchronized出现在实例方法上，一定锁的是 ==this。==**

**没得挑。只能是this。不能是其他的对象了（因为是实例对象的方法，所以该实例对象是唯一共享对象）**。所以这种方式不灵活。

### 16.1.3.1 缺点

**synchronized出现在实例方法上，表示整个方法体都需要同步，可能会无故扩大同步的范围，导致程序的执行效率降低。所以这种方式不常用。**

### 16.1.3.2 优点

代码写的少了。节俭了。

### 16.1.3.3 总结

如果共享的对象就是**this**，并且需要**同步的代码块是整个方法体**，建议使用这种方式。、

eg.

```java
public synchronized void withdraw(double money){
    double before = this.getBalance();
    double after = before - money;
    try {
        Thread.sleep(1000);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    this.setBalance(after);
}
```

### 16.1.4 在方法调用处使用synchronized

eg.

```java
public void run(){
    double money = 5000;
    // 取款
    // 多线程并发执行这个方法。
    //synchronized (this) { //这里的this是AccountThread对象，这个对象不共享！
    synchronized (act) { // 这种方式也可以，只不过扩大了同步的范围，效率更低了。
        act.withdraw(money);
    }

    System.out.println(Thread.currentThread().getName() + "对"+act.getActno()+"取款"+money+"成功，余额" + act.getBalance());
}
```
**这种方式也可以，只不过扩大了同步的范围，效率更低了。**

## 17、Java中有三大变量？★★★★★

- **实例变量：在堆中。**
- **静态变量：在方法区。**
- **局部变量：在栈中。**

以上三大变量中：

**==局部变量永远都不会存在线程安全问题。==**

- 因为局部变量不共享。（一个线程一个栈。）

- 局部变量在栈中。所以局部变量永远都不会共享。

- 实例变量在堆中，堆只有1个。

- 静态变量在方法区中，方法区只有1个。

  

**==堆和方法区都是多线程共享的，所以可能存在线程安全问题。==**

**总结：**

- ==**局部变量+常量：不会有线程安全问题。**==
- ==**成员变量（实例+静态）：可能会有线程安全问题。**==

## 18、以后线程安全和非线程安全的类如何选择？

**如果使用局部变量的话**：

建议使用：**StringBuilder**。

因为局部变量**不存在线程安全问题。选择StringBuilder。**

StringBuffer效率比较低。

反之：

使用StringBuffer（线程安全）。

ArrayList是非线程安全的。
Vector是线程安全的。
HashMap HashSet是非线程安全的（单线程，效率快）。
Hashtable是线程安全的。

## 19、总结synchronized

synchronized有三种写法：

### 第一种：同步代码块

灵活

```
synchronized(线程共享对象){
	同步代码块;
}
```

### 第二种：在实例方法上使用synchronized

表示共享对象一定是 this 并且同步代码块是整个方法体。

### 第三种：在静态方法上使用synchronized

**表示找 类锁。类锁永远只有1把。**

**就算创建了100个对象，那类锁也只有1把。（锁了class对象）**

注意区分：

- 对象锁：1个对象1把锁，100个对象100把锁。
- 类锁：100个对象，也可能只是1把类锁。

## 20、我们以后开发中应该怎么解决线程安全问题？

是一上来就选择线程同步吗？synchronized

不是，synchronized会让程序的执行效率降低，用户体验不好。
系统的用户吞吐量降低。用户体验差。在不得已的情况下再选择线程同步机制。

- 第一种方案：尽量使用**==局部变量==** 代替 ==**“实例变量和静态变量”。**==
- 第二种方案：如果必须是**==实例变量==**，那么可以考虑**==创建多个对象==**，这样实例变量的内存就不共享了。（一个线程对应1个对象，100个线程对应100个对象，对象不共享，就没有数据安全问题了。）
- 第三种方案：如果不能使用局部变量，对象也不能创建多个，这个时候就只能选择synchronized了。线程同步机制。

## 21、死锁（DeadLock）

死锁代码要会写。一般面试官要求你会写。
只有会写的，才会在以后的开发中注意这个事儿。
因为死锁很难调试。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210512224504688.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NzE1OTQz,size_16,color_FFFFFF,t_70)

```java
/**

- 比如：t1想先穿衣服在穿裤子
- t2想先穿裤子在传衣服
- 此时：t1拿到衣服，t2拿到裤子；
- 由于t1拿了衣服，t2找不到衣服；t2拿了裤子，t1找不到裤子
- 就会导致死锁的发生！
  */
  public class Thread_DeadLock {
  public static void main(String[] args) {
      Dress dress = new Dress();
      Trousers trousers = new Trousers();
      //t1、t2共享dress和trousers。
      Thread t1 = new Thread(new MyRunnable1(dress, trousers), "t1");
      Thread t2 = new Thread(new MyRunnable2(dress, trousers), "t2");
      t1.start();
      t2.start();
  }
  }

class MyRunnable1 implements Runnable{
    Dress dress;
    Trousers trousers;

public MyRunnable1() {
}

public MyRunnable1(Dress dress, Trousers trousers) {
    this.dress = dress;
    this.trousers = trousers;
}

@Override
public void run() {
    synchronized(dress){
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        synchronized (trousers){
            System.out.println("--------------");
        }
    }
}

}

class MyRunnable2 implements Runnable{
    Dress dress;
    Trousers trousers;

public MyRunnable2() {
}

public MyRunnable2(Dress dress, Trousers trousers) {
    this.dress = dress;
    this.trousers = trousers;
}

@Override
public void run() {
    synchronized(trousers){
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        synchronized (dress){
            System.out.println("。。。。。。。。。。。。。。");
        }
    }
}

}

class Dress{

}

class Trousers{

}
```

## 22、守护线程

### 22.1java语言中线程分为两大类：

一类是：**用户线程**
一类是：**守护线程（后台线程）**
其中具有代表性的就是：**垃圾回收线程（守护线程）。**

### 22.2守护线程的特点：

一般守护线程是一个**死循环**，**所有的用户线程只要结束，守护线程自动结束。**

注意：主线程main方法是一个用户线程。

### 22.3守护线程用在什么地方呢？

每天00:00的时候系统数据自动备份。
这个需要使用到定时器，并且我们可以将定时器设置为守护线程。
一直在那里看着，没到00:00的时候就备份一次。所有的用户线程如果结束了，守护线程自动退出，没有必要进行数据备份了。

### 22.4方法

| 方法名                     | 作用                             |
| -------------------------- | -------------------------------- |
| void setDaemon(boolean on) | on为true表示把线程设置为守护线程 |

eg.

```java
public class ThreadTest14 {
    public static void main(String[] args) {
        Thread t = new BakDataThread();
        t.setName("备份数据的线程");

​    // 启动线程之前，将线程设置为守护线程
​    t.setDaemon(true);

​    t.start();

​    // 主线程：主线程是用户线程
​    for(int i = 0; i < 10; i++){
​        System.out.println(Thread.currentThread().getName() + "--->" + i);
​        try {
​            Thread.sleep(1000);
​        } catch (InterruptedException e) {
​            e.printStackTrace();
​        }
​    }
}

}

class BakDataThread extends Thread {
    public void run(){
        int i = 0;
        // 即使是死循环，但由于该线程是守护者，当用户线程结束，守护线程自动终止。
        while(true){
            System.out.println(Thread.currentThread().getName() + "--->" + (++i));
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
```

## 23、定时器

### 23.1定时器的作用：

**间隔特定的时间，执行特定的程序。**

eg.
每周要进行银行账户的总账操作。
每天要进行数据的备份操作。

在实际的开发中，每隔多久执行一段特定的程序，这种需求是很常见的，那么在java中其实可以采用多种方式实现：

1. **==可以使用sleep方法==**，睡眠，设置睡眠时间，没到这个时间点醒来，执行任务。这种方式是最原始的定时器。（比较low）
2. 在java的类库中已经写好了一个定时器：**==java.util.Timer==**，可以直接拿来用。
   不过，这种方式在目前的开发中也很少用，因为现在有很多高级框架都是支持定时任务的。

**==在实际的开发中，目前使用较多的是Spring框架中提供的SpringTask框架，这个框架只要进行简单的配置，就可以完成定时器的任务。==**

#### 构造方法

|| 构造方法名																		 ||									备注										||

| Timer()                              | 创建一个定时器                   |
| ------------------------------------ | -------------------------------- |
| Timer(boolean isDaemon)              | isDaemon为true为守护线程定时器   |
| Timer(String name)                   | 创建一个定时器，其线程名字为name |
| Timer(String name, boolean isDaemon) | 结合2、3                         |

#### 方法

| 方法名                                                     | 作用                                                 |
| ---------------------------------------------------------- | ---------------------------------------------------- |
| void schedule(TimerTask task, Date firstTime, long period) | 安排指定的任务在指定的时间开始进行重复的固定延迟执行 |
| void cancel()                                              | 终止定时器                                           |

## 24、使用定时器实现日志备份

### 正常方式：

```java
class TimerTest01{
    public static void main(String[] args) {
        Timer timer = new Timer();
//        Timer timer = new Timer(true);//守护线程
        String firstTimeStr = "2021-05-09 17:27:00";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            Date firstTime = sdf.parse(firstTimeStr);
            timer.schedule(new MyTimerTask(), firstTime, 1000 * 5);//每5s执行一次
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }
}

class MyTimerTask extends TimerTask{
    @Override
    public void run() {
        Date d = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String time = sdf.format(d);
        System.out.println(time + ":备份日志一次！");
    }
}
```

### 匿名内部类方式：

```java
class TimerTest02{
    public static void main(String[] args) {
        Timer timer = new Timer();
        String firstTimeStr = "2021-05-09 17:56:00";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            Date firstTime = sdf.parse(firstTimeStr);
            timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    Date d = new Date();
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    String time = sdf.format(d);
                    System.out.println(time + ":备份日志一次！");
                }
            }, firstTime, 1000 * 5);
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }
}
```

## 25、实现线程的第三种方式：实现Callable接口（JDK8新特性）

这种方式实现的线程**==可以获取线程的返回值。==**

之前讲解的那两种方式是**==无法获取线程返回值的，因为run方法返回void。==**

任务需求：
系统委派一个线程去执行一个任务，该线程执行完任务之后，可能会有一个执行结果，我们怎么能拿到这个执行结果呢？
使用第三种方式：实现Callable接口方式。（除非执行器用.submit()方法返回Future类对象，future.get()获取执行结果，如果执行完毕返回null）

### 25.1优点

可以获取到线程的执行结果。

### 25.2缺点

效率比较低，在获取t线程执行结果的时候，当前线程受阻塞，效率较低。

eg.

```java
public class ThreadTest15 {
    public static void main(String[] args) throws Exception {

​    // 第一步：创建一个“未来任务类”对象。
​    // 参数非常重要，需要给一个Callable接口实现类对象。
​    FutureTask task = new FutureTask(new Callable() {
​        @Override
​        public Object call() throws Exception { // call()方法就相当于run方法。只不过这个有返回值
​            // 线程执行一个任务，执行之后可能会有一个执行结果
​            // 模拟执行
​            System.out.println("call method begin");
​            Thread.sleep(1000 * 10);
​            System.out.println("call method end!");
​            int a = 100;
​            int b = 200;
​            return a + b; //自动装箱(300结果变成Integer)
​        }
​    });

​    // 创建线程对象
​    Thread t = new Thread(task);

​    // 启动线程
​    t.start();

​    // 这里是main方法，这是在主线程中。
​    // 在主线程中，怎么获取t线程的返回结果？
​    // get()方法的执行会导致“当前线程阻塞”
​    Object obj = task.get();
​    System.out.println("线程执行结果:" + obj);

​    // main方法这里的程序要想执行必须等待get()方法的结束
​    // 而get()方法可能需要很久。因为get()方法是为了拿另一个线程的执行结果
​    // 另一个线程执行是需要时间的。
​    System.out.println("hello world!");
}

}
```

## 26、关于Object类的wait()、notify()、notifyAll()方法

### 26.1方法

| 方法名           | 作用                                                     |
| ---------------- | -------------------------------------------------------- |
| void wait()      | 让活动在当前对象的线程无限等待（释放之前占有的锁）       |
| void notify()    | 唤醒当前对象正在等待的线程（只提示唤醒，不会释放锁）     |
| void notifyAll() | 唤醒当前对象全部正在等待的线程（只提示唤醒，不会释放锁） |

### 26.2方法详解

第一：==**wait和notify方法不是线程对象的方法，是java中任何一个java对象都有的方法，因为这两个方法是 Object类中自带 的。**==
==**wait方法和notify方法不是通过线程对象调用，**==
不是这样的：线程对象t.wait()，也不是这样的：t.notify()…不对。

第二：wait()方法作用？

```java
Object o = new Object();

o.wait();
```

表示：
==**让正在o对象上（共享对象）活动的线程进入等待状态，无期限等待，直到被唤醒为止。**==

==**表示：**==
==**让正在o对象上活动的线程进入等待状态，无期限等待，直到被唤醒为止。**==

==**o.wait();方法的调用，会让“当前线程（正在o对象上活动的线程）”进入等待状态。**==

第三：notify()方法作用？

```java
Object o = new Object();

o.notify();
```

表示：
**唤醒正在o对象上等待的线程。**

第四：notifyAll() 方法 作用？

```java
Object o = new Object();

o.notifyAll();
```

表示：
**这个方法是唤醒o对象上处于等待的所有线程。**

### 26.3图文

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210513171514417.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NzE1OTQz,size_16,color_FFFFFF,t_70)

#### 26.4总结 ★★★★★（呼应生产者消费者模式）

1、wait和notify方法不是**线程对象的方法，是普通java对象都有的方法。**

2、wait方法和notify方法建立在 **==线程同步==** 的基础之上。因为**==多线程要同时操作一个仓库（共享对象）。有线程安全问题。==**

3、wait方法作用：**o.wait() 让正在o对象上活动的线程t进入等待状态，==并且释放掉t线程之前占有的o对象的锁。==**

4、notify方法作用：**o.notify() 让正在o对象上等待的线程唤醒，==只是通知，不会释放o对象上之前占有的锁。==**

## 27、生产者消费者模式（wait()和notify()）

### 27.1什么是“生产者和消费者模式”？

生产线程负责生产，消费线程负责消费。
生产线程和消费线程要达到均衡。
这是一种特殊的业务需求，在这种特殊的情况下需要使用**wait方法和notify方法。**

### 27.2模拟一个业务需求

模拟这样一个需求：

- 仓库我们采用List集合。
- List集合中假设只能存储1个元素。
- 1个元素就表示仓库满了。
- 如果List集合中元素个数是0，就表示仓库空了。
- 保证List集合中永远都是最多存储1个元素。
- 必须做到这种效果：生产1个消费1个。

### 27.3图文

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210513172048589.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NzE1OTQz,size_16,color_FFFFFF,t_70#pic_center)

eg.

**使用wait方法和notify方法实现“生产者和消费者模式”**

```java
public class ThreadTest16 {
    public static void main(String[] args) {
        // 创建1个仓库对象，共享的。
        List list = new ArrayList();
        // 创建两个线程对象
        // 生产者线程
        Thread t1 = new Thread(new Producer(list));
        // 消费者线程
        Thread t2 = new Thread(new Consumer(list));

​    t1.setName("生产者线程");
​    t2.setName("消费者线程");

​    t1.start();
​    t2.start();
}

}

// 生产线程
class Producer implements Runnable {
    // 仓库
    private List list;

public Producer(List list) {
    this.list = list;
}
@Override
public void run() {
    // 一直生产（使用死循环来模拟一直生产）
    while(true){
        // 给仓库对象list加锁。
        synchronized (list){
            if(list.size() > 0){ // 大于0，说明仓库中已经有1个元素了。
                try {
                    // 当前线程进入等待状态，并且释放Producer之前占有的list集合的锁。
                    list.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            // 程序能够执行到这里说明仓库是空的，可以生产
            Object obj = new Object();
            list.add(obj);
            System.out.println(Thread.currentThread().getName() + "--->" + obj);
            // 唤醒消费者进行消费
            list.notifyAll();
        }
    }
}

}

// 消费线程
class Consumer implements Runnable {
    // 仓库
    private List list;

public Consumer(List list) {
    this.list = list;
}

@Override
public void run() {
    // 一直消费
    while(true){
        synchronized (list) {
            if(list.size() == 0){
                try {
                    // 仓库已经空了。
                    // 消费者线程等待，释放掉list集合的锁
                    list.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            // 程序能够执行到此处说明仓库中有数据，进行消费。
            Object obj = list.remove(0);
            System.out.println(Thread.currentThread().getName() + "--->" + obj);
            // 唤醒生产者生产。
            list.notifyAll();
        }
    }
}

}
```

注意：
生产者消费者模式貌似只能使用wait()和notify()实现！

## 附录：测试代码（可不看）

### Thread

```java
package javase;


import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.*;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

public class ThreadTest {
    public static void main(String[] args) {

    }
}

//创建线程的第一种方法：继承Thread类
class ThreadTest01{
    public static void main(String[] args) {
        MyThread01 t = new MyThread01();
        t.setName("t");
        t.start();//启动线程
        for (int i = 0; i < 1000; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

class MyThread01 extends Thread{
    @Override
    public void run() {
        for (int i = 0; i < 1000; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

//创建线程的第二种方法：实现Runnable接口
class ThreadTest02{
    public static void main(String[] args) {
        Thread t = new Thread(new MyRunnable01(), "t");//创建线程并设置名字
        t.start();
        for (int i = 0; i < 1000; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

// 这并不是一个线程类，是一个可运行的类。它还不是一个线程。
class MyRunnable01 implements Runnable{
    @Override
    public void run() {
        for (int i = 0; i < 1000; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

//创建线程的第二种方法：实现Runnable接口（采用匿名内部类）
class ThreadTest03{
    public static void main(String[] args) {
        //匿名内部类
        Thread t = new Thread(new Runnable() {
            @Override
            public void run() {
                for (int i = 0; i < 1000; i++){
                    System.out.println(Thread.currentThread().getName() + "--->" + i);
                }
            }
        });

        t.setName("t");
        t.start();
        for (int i = 0; i < 1000; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

/**
 * Thread.currentThread()获取当前线程对象（静态方法）
 * 线程.getName()获取当前线程名字
 * 线程.setName()设置当前线程名字
 */
class ThreadTest04{
    public static void main(String[] args) {
        System.out.println(Thread.currentThread().getName());//当前线程名字 main
        MyThread01 t1 = new MyThread01();
        MyThread01 t2 = new MyThread01();
        t1.setName("t1");
        t2.setName("t2");
        t1.start();
        t2.start();
        for (int i = 0; i < 1000; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

//sleep(long millis)（静态方法）
class ThreadTest05{
    public static void main(String[] args) {
        for (int i = 0; i < 10; i++){
            try {
                Thread.sleep(1000);//睡眠1s
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

//interrupt()中断正在睡眠的线程（不推荐使用，了解即可）
class ThreadTest06 {
    public static void main(String[] args) {
        MyThread02 t = new MyThread02();
        t.setName("t");
        t.start();

        try {
            Thread.sleep(1000 * 5);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("hello world");
        t.interrupt();
    }
}

class MyThread02 extends Thread{
    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + "--->begin" );
        try {
            Thread.sleep(1000 * 60 * 60 * 24 * 365);//睡一年
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName() + "--->end" );
    }
}

//stop()终止一个线程执行（不推荐使用，可能导致数据丢失）
class ThreadTest07{
    public static void main(String[] args) {
        MyThread03 t = new MyThread03();
        t.setName("t");
        t.start();
        try {
            Thread.sleep(1000 * 5);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        t.stop();
    }
}

class MyThread03 extends Thread{
    @Override
    public void run() {
        for (int i = 0; i < 100; i++){
            System.out.println(Thread.currentThread().getName() + "--->" + i);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

//合理终止一个线程：设置一个标记
class ThreadTest08{
    public static void main(String[] args) {
        MyThread04 t = new MyThread04();
        t.setName("t");
        t.start();
        try {
            Thread.sleep(1000 * 5);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("hello world");
        // 终止线程
        // 你想要什么时候终止t的执行，那么你把标记修改为false，就结束了。
        t.flag = true;
    }
}

class MyThread04 extends Thread{
    boolean flag = false;
    @Override
    public void run() {
        if (this.flag){
            return ;
        }
        for (int i = 0; i < 1000; i++){
            if (this.flag){//由于一个线程一直运行此程序，要是判断在外面只会在启动线程时判断并不会结束，因此需要每次循环判断一下标记。
                /**
                 * 这里可以保存东西
                 */
                return ;
            }
            System.out.println(Thread.currentThread().getName() + "--->" + i);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

/*//MyThread04另一种写法
class MyThread04 extends Thread{
    boolean flag = false;
    @Override
    public void run() {
        for (int i = 0; i < 1000; i++){
            if (!this.flag){
                System.out.println(Thread.currentThread().getName() + "--->" + i);
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }else{
                return;
            }

        }
    }
}*/

/**关于线程的优先级
 *getPriority()获得线程优先级
 *setPriority()设置线程优先级
 */
class ThreadTest09{
    public static void main(String[] args) {
        System.out.println("最高优先级：" + Thread.MAX_PRIORITY);//最高优先级：10
        System.out.println("最低优先级:" + Thread.MIN_PRIORITY);//最低优先级:1
        System.out.println("默认优先级:" + Thread.NORM_PRIORITY);//默认优先级:5

        MyThread01 t1 = new MyThread01();
        MyThread01 t2 = new MyThread01();
        MyThread01 t3 = new MyThread01();
        t1.setName("t1");
        t2.setName("t2");
        t3.setName("t3");
        t1.setPriority(Thread.MAX_PRIORITY);
        t2.setPriority(Thread.MIN_PRIORITY);
        t3.setPriority(Thread.NORM_PRIORITY);
        t1.start();
        t2.start();
        t3.start();

        try {
            Thread.sleep(1000 * 5);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("t1的优先级：" + t1.getPriority());//t1的优先级：10
        System.out.println("t2的优先级：" + t2.getPriority());//t2的优先级：1
        System.out.println("t3的优先级：" + t3.getPriority());//t3的优先级：5
    }
}

//yield()让位，当前线程暂停，回到就绪状态，让给其它线程（静态方法）
class ThreadTest10{
    public static void main(String[] args) {
        Thread t1 = new Thread(new MyRunnable02(), "t1");
        Thread t2 = new Thread(new MyRunnable02(), "t2");
        t1.start();
        t2.start();
    }
}

class MyRunnable02 implements Runnable{

    @Override
    public void run() {
        for (int i = 0; i < 1000; i++){
            //每100个让位一次。
            if (i % 100 == 0){
                Thread.yield();// 当前线程暂停一下，让给主线程。
            }
            System.out.println(Thread.currentThread().getName() + "--->" + i);
        }
    }
}

//join()线程合并。将一个线程合并到当前线程中，当前线程受阻塞，加入的线程执行直到结束。
class ThreadTest11{
    public static void main(String[] args) {
        System.out.println("main begin");
        MyThread01 t1 = new MyThread01();
        t1.setName("t1");
        t1.start();
        try {
            t1.join();//t合并到当前线程中，当前线程受阻塞，t线程执行直到结束。
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("main end");
    }
}

//守护线程
class ThreadTest12{
    public static void main(String[] args) {
        MyThread05 t = new MyThread05();
        t.setName("t");
        t.setDaemon(true);//设置守护线程
        t.start();
        for (int i = 0; i < 10; i++) {
            System.out.println(Thread.currentThread().getName() + "--->" + i);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class MyThread05 extends Thread{
    @Override
    public void run() {
        int i = 0;
        while (true){
            System.out.println(Thread.currentThread().getName() + "--->" + i++);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

//使用定时器实现日志备份
class TimerTest01{
    public static void main(String[] args) {
        Timer timer = new Timer();
//        Timer timer = new Timer(true);//守护线程
        String firstTimeStr = "2021-05-09 17:27:00";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            Date firstTime = sdf.parse(firstTimeStr);
            timer.schedule(new MyTimerTask(), firstTime, 1000 * 5);//每5s执行一次
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }
}

class MyTimerTask extends TimerTask{
    @Override
    public void run() {
        Date d = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String time = sdf.format(d);
        System.out.println(time + ":备份日志一次！");
    }
}

class TimerTest02{
    public static void main(String[] args) {
        Timer timer = new Timer();
        String firstTimeStr = "2021-05-09 17:56:00";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            Date firstTime = sdf.parse(firstTimeStr);
            timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    Date d = new Date();
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    String time = sdf.format(d);
                    System.out.println(time + ":备份日志一次！");
                }
            }, firstTime, 1000 * 5);
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }
}

//实现线程的第三种方式：实现Callable接口
class ThreadTest13{
    public static void main(String[] args) {
        System.out.println("main begin");
        FutureTask task = new FutureTask(new MyCallable());
        Thread t = new Thread(task, "t");
        t.start();
        try {
            Object o = task.get();//会导致main线程阻塞
            System.out.println("task线程运行结果：" + o);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
        System.out.println("main end");
    }
}

class MyCallable implements Callable{
    @Override
    public Object call() throws Exception {//相当于run()方法,不过这个有返回值
        System.out.println("MyCallable begin");
        Thread.sleep(1000 * 5);
        System.out.println("MyCallable end");
        return 1;
    }
}

/**
 * 生产者消费者模式
 */
class Thread14{
    public static void main(String[] args) {
        List<Object> list = new ArrayList<>();
        Thread producer = new Producer(list);
        Thread consumer = new Consumer(list);
        producer.setName("生产者线程");
        consumer.setName("消费者线程");
        producer.start();
        try {
            Thread.sleep(1000);//睡眠1s保证producer线程先执行
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        consumer.start();
    }
}

/**
 * Producer类和Consumer类run()方法没有synchronized
 * 如果生产者线程和消费者线程同时进入run()方法就会引起
 * java.lang.IllegalMonitorStateException异常
 * （两个线程无限等待）
 */
class Producer extends Thread{
    List<Object> list;

    public Producer() {
    }

    public Producer(List<Object> list) {
        this.list = list;
    }

    @Override
    public void run() {
        while(true){
            synchronized (list) {//this是当前对象，锁的是list，不是当前对象
                if (list.size() > 0) {
                    try {
                        list.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                Object obj = new Object();
                list.add(obj);
                System.out.println(Thread.currentThread().getName() + "生产：" + obj);
                list.notifyAll();
            }
        }
    }
}

class Consumer extends Thread{
    List<Object> list;

    public Consumer() {
    }

    public Consumer(List<Object> list) {
        this.list = list;
    }

    @Override
    public void run() {
        while (true){
            synchronized (list) {
                if (list.size() == 0) {
                    try {
                        list.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                Object obj = list.get(0);
                list.remove(0);
                System.out.println(Thread.currentThread().getName() + "消费：" + obj);
                list.notifyAll();
            }
        }
    }
}

/**
 * 循环模拟生产者消费者模式
 */
class PC{
    public static void main(String[] args) {
        List<Object> list = new ArrayList<>();

        while (true){
            if (list.size() > 1){
                continue;
            }else{
                Object o = new Object();
                list.add(o);
                System.out.println("生产：" + o);
            }

            if (list.size() == 0){
                continue;
            }else{
                Object o = list.get(0);
                list.remove(0);
                System.out.println("消费：" + o);
            }
        }
    }
}
```

ThreadSafe-1

```java
package javase;

/**
 *     不使用线程同步机制，多线程对同一个账户进行取款，出现线程安全问题。
 */
public class ThreadSafe01 {
    public static void main(String[] args) {
        Account01 act = new Account01("act-001", 10000);
        Thread t1 = new Thread(new AccountRunnable01(act), "t1");
        Thread t2 = new Thread(new AccountRunnable01(act), "t2");
        t1.start();
        t2.start();
    }
}

class Account01{
    private String actno;
    private double balance;

    public Account01() {
    }

    public Account01(String actno, double balance) {
        this.actno = actno;
        this.balance = balance;
    }

    public String getActno() {
        return actno;
    }

    public void setActno(String actno) {
        this.actno = actno;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    /**
     * // t1和t2并发这个方法。。。。（t1和t2是两个栈。两个栈操作堆中同一个对象。）
     * @param money
     */
    public void withdraw(double money){
        /*this.setBalance(this.getBalance() - money);//这样写不会出问题*/

        //以下代码，只要t1没有执行完this.setBalance(after);，t2进来执行都会导致数据错误！
        double before = this.getBalance();
        double after = before - money;
        //模拟网络延迟
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        this.setBalance(after);
    }
}

class AccountRunnable01 implements Runnable{
    private Account01 act;

    public AccountRunnable01() {
    }

    public AccountRunnable01(Account01 act) {
        this.act = act;
    }

    public Account01 getAct() {
        return act;
    }

    public void setAct(Account01 act) {
        this.act = act;
    }

    @Override
    public void run() {
        act.withdraw(5000);
        System.out.println(Thread.currentThread().getName() + "取款5000，还剩余额：" + act.getBalance());
    }
}

```

### ThreadSafe-2

```java
package javase;

/**
 * 使用线程同步机制，解决线程安全问题。
 */
public class ThreadSafe02 {
    public static void main(String[] args) {
        Account02 act = new Account02("act-001", 10000);
        Thread t1 = new Thread(new AccountRunnable02(act), "t1");
        Thread t2 = new Thread(new AccountRunnable02(act), "t2");
        t1.start();
        t2.start();
    }
}

class Account02{
    private String actno;
    private double balance;

    Object o = new Object();

    public Account02() {
    }

    public Account02(String actno, double balance) {
        this.actno = actno;
        this.balance = balance;
    }

    public String getActno() {
        return actno;
    }

    public void setActno(String actno) {
        this.actno = actno;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public void withdraw(double money){
        /**
         * 以下可以共享,金额不会出错
         */
        synchronized(this) {
        //synchronized(actno) {
        //synchronized(o) {
        /**
         * 以下不共享，金额会出错
         */
/*        Object obj = new Object();
        synchronized(obj) {
        synchronized(null) {//编译不通过
        String s = null;
        synchronized(s) {//java.lang.NullPointerException*/
        double before = this.getBalance();
            double after = before - money;
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            this.setBalance(after);
        }
    }
}

class AccountRunnable02 implements Runnable{
    private Account02 act;

    public AccountRunnable02() {
    }

    public AccountRunnable02(Account02 act) {
        this.act = act;
    }

    public Account02 getAct() {
        return act;
    }

    public void setAct(Account02 act) {
        this.act = act;
    }

    @Override
    public void run() {
        //synchronized (act) { 这种方式也可以，只不过扩大了同步的范围，效率更低了
            act.withdraw(5000);
        //}
        System.out.println(Thread.currentThread().getName() + "取款5000，还剩余额：" + act.getBalance());
    }
}
```

### ThreadSafe-3

```java
package javase;

public class ThreadSafe03 {
    public static void main(String[] args) {
        Account03 act = new Account03("act-001", 10000);
        Thread t1 = new Thread(new AccountRunnable03(act), "t1");
        Thread t2 = new Thread(new AccountRunnable03(act), "t2");
        t1.start();
        t2.start();
    }
}

class Account03{
    private String actno;
    private double balance;

    public Account03() {
    }

    public Account03(String actno, double balance) {
        this.actno = actno;
        this.balance = balance;
    }

    public String getActno() {
        return actno;
    }

    public void setActno(String actno) {
        this.actno = actno;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    /**
     * synchronized出现在实例方法上，一定锁的是this。
     * @param money
     */
    public synchronized void withdraw(double money){
        double before = this.getBalance();
        double after = before - money;
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        this.setBalance(after);
    }
}

class AccountRunnable03 implements Runnable{
    private Account03 act;

    public AccountRunnable03() {
    }

    public AccountRunnable03(Account03 act) {
        this.act = act;
    }

    public Account03 getAct() {
        return act;
    }

    public void setAct(Account03 act) {
        this.act = act;
    }

    @Override
    public void run() {
        act.withdraw(5000);
        System.out.println(Thread.currentThread().getName() + "取款5000，还剩余额：" + act.getBalance());
    }
}
```

### DeadLock

```java
package javase;

/**
 * 比如：t1想先穿衣服在穿裤子
 *       t2想先穿裤子在传衣服
 * 此时：t1拿到衣服，t2拿到裤子；
 * 由于t1拿了衣服，t2找不到衣服；t2拿了裤子，t1找不到裤子
 * 就会导致死锁的发生！
 */
public class Thread_DeadLock {
    public static void main(String[] args) {
        Dress dress = new Dress();
        Trousers trousers = new Trousers();
        //t1、t2共享dress和trousers。
        Thread t1 = new Thread(new MyRunnable1(dress, trousers), "t1");
        Thread t2 = new Thread(new MyRunnable2(dress, trousers), "t2");
        t1.start();
        t2.start();
    }
}

class MyRunnable1 implements Runnable{
    Dress dress;
    Trousers trousers;

    public MyRunnable1() {
    }

    public MyRunnable1(Dress dress, Trousers trousers) {
        this.dress = dress;
        this.trousers = trousers;
    }

    @Override
    public void run() {
        synchronized(dress){
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            synchronized (trousers){
                System.out.println("--------------");
            }
        }
    }
}

class MyRunnable2 implements Runnable{
    Dress dress;
    Trousers trousers;

    public MyRunnable2() {
    }

    public MyRunnable2(Dress dress, Trousers trousers) {
        this.dress = dress;
        this.trousers = trousers;
    }

    @Override
    public void run() {
        synchronized(trousers){
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            synchronized (dress){
                System.out.println("。。。。。。。。。。。。。。");
            }
        }
    }
}

class Dress{

}

class Trousers{

}
```





-----

# [Java Object 的 notify() 方法](https://blog.csdn.net/qq_22076345/article/details/107881591)

我们都知道Java Object 中的 wait() 和 notify() 方法可以进行线程间的通信。

wait() 方法： 当前线程释放对象锁(监视器)的拥有权，在其他线程调用此对象的 notify() 方法或 notifyAll() 方法前，当前线程处于等待状态。

notify() 方法：唤醒在此对象锁(监视器)上等待的单个线程。如果有多个线程都在此对象上等待，则会选择唤醒其中一个线程。选择是任意性的，并且根据实现进行选择。

   这里说的一点就是，**调用当前线程 noitfy() 后，等待的获取对象锁的其他线程(可能有多个)不会立即从 wait() 处返回，而是需要调用 notify() 的当前线程释放锁（退出同步块，执行完synchronized释放对象锁）之后，等待线程才有机会从 wait() 返回（等待线程才能重新获取对象锁继续执行）。**这点自己之前理解得不清晰，举个例子加深一下：

等待线程：

```java
public class WaitThread implements Runnable{
    Object lock;
 
    public WaitThread(Object lock){
        this.lock = lock;
    }
 
    public void run() {
        String threadName = Thread.currentThread().getName();
        synchronized (lock){
            System.out.println(threadName + "开始进入同步代码块区域");
            try {
                lock.wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(threadName + "准备离开同步代码块区域");
        }
    }
}
```

**唤醒线程**：

```java
public class NotifyThread implements Runnable{
 
    Object lock;
 
    public NotifyThread(Object lock){
        this.lock = lock;
    }
 
    public void run() {
        String threadName = Thread.currentThread().getName();
        synchronized (lock){
            System.out.println(threadName + "开始进入同步代码块区域");
            lock.notify();
            try {
                System.out.println(threadName + "业务处理开始");
                // 暂停 2s 表示业务处理
                Thread.sleep(2000);
                System.out.println(threadName + "业务处理结束");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(threadName + "准备离开同步代码块区域");
            //lock.notify();放在这一行唤醒，效果一样
        }
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(threadName + "退出同步代码块后续操作");
    }
}
```

**==注意：lock.notify() 的位置和放在注释的位置，效果一样的，线程都会在执行完synchronized同步代码块之后才会释放锁，其他处于 wait() 线程才有可能被唤醒。==**

**主程序**：

```java
public class Test {
    public static void main(String[] args) throws InterruptedException {
        Object lock = new Object();
        Thread waitThread = new Thread(new WaitThread(lock), "waitThread");
        Thread notifyThread = new Thread(new NotifyThread(lock), "notifyThread");
        waitThread.start();
        Thread.sleep(1000);
        notifyThread.start();
    }
}
```

**输出结果**：

```
waitThread开始进入同步代码块区域
notifyThread开始进入同步代码块区域
notifyThread业务处理开始
notifyThread业务处理结束
notifyThread准备离开同步代码块区域
waitThread准备离开同步代码块区域
notifyThread退出同步代码块后续操作
```

可以看到waitThread线程必须等到notifyThread线程退出同步块释放锁之后，才会从 wait() 处返回。lock.notify() 放在注释掉的那一行，输出结果不变。不过在平常工作中，还是建议把 notify() 放在容易理解的位置。



-----

# [Java Object notify() 方法](https://www.runoob.com/java/java-object-notify.html)

Object notify() 方法用于唤醒一个在此对象监视器上等待的线程。

如果所有的线程都在此对象上等待，那么只会选择一个线程，选择是任意性的，并在对实现做出决定时发生。

一个线程在对象监视器上等待可以调用 wait() 方法。

notify() 方法只能被作为此对象监视器的所有者的线程来调用。

一个线程要想成为对象监视器的所有者，可以使用以下 3 种方法：

- 执行对象的同步实例方法
- 使用 synchronized 内置锁
- 对于 Class 类型的对象，执行同步静态方法

一次只能有一个线程拥有对象的监视器。

如果当前线程不是此对象监视器的所有者的话会抛出 **IllegalMonitorStateException** 异常。

### 语法

```
public final void notify()
```

### 参数

- **无** 。

### 返回值

没有返回值。

### 实例

以下实例演示了 notify() 方法的使用：

```java
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
 
public class RunoobTest {
 
    private List synchedList;
 
    public RunoobTest() {
        // 创建一个同步列表
        synchedList = Collections.synchronizedList(new LinkedList());
    }
 
    // 删除列表中的元素
    public String removeElement() throws InterruptedException {
        synchronized (synchedList) {
 
            // 列表为空就等待
            while (synchedList.isEmpty()) {
                System.out.println("List is empty...");
                synchedList.wait();
                System.out.println("Waiting...");
            }
            String element = (String) synchedList.remove(0);
 
            return element;
        }
    }
 
    // 添加元素到列表
    public void addElement(String element) {
        System.out.println("Opening...");
        synchronized (synchedList) {
 
            // 添加一个元素，并通知元素已存在
            synchedList.add(element);
            System.out.println("New Element:'" + element + "'");
 
            synchedList.notifyAll();
            System.out.println("notifyAll called!");
        }
        System.out.println("Closing...");
    }
 
    public static void main(String[] args) {
        final RunoobTest demo = new RunoobTest();
 
        Runnable runA = new Runnable() {
 
            public void run() {
                try {
                    String item = demo.removeElement();
                    System.out.println("" + item);
                } catch (InterruptedException ix) {
                    System.out.println("Interrupted Exception!");
                } catch (Exception x) {
                    System.out.println("Exception thrown.");
                }
            }
        };
 
        Runnable runB = new Runnable() {
 
            // 执行添加元素操作，并开始循环
            public void run() {
                demo.addElement("Hello!");
            }
        };
 
        try {
            Thread threadA1 = new Thread(runA, "Google");
            threadA1.start();
 
            Thread.sleep(500);
 
            Thread threadA2 = new Thread(runA, "Runoob");
            threadA2.start();
 
            Thread.sleep(500);
 
            Thread threadB = new Thread(runB, "Taobao");
            threadB.start();
 
            Thread.sleep(1000);
 
            threadA1.interrupt();
            threadA2.interrupt();
        } catch (InterruptedException x) {
        }
    }
}
```

以上程序执行结果为：

```
List is empty...
List is empty...
Opening...
New Element:'Hello!'
notifyAll called!
Closing...
Waiting...
Waiting...
List is empty...
Hello!
Interrupted Exception!
```



-----

# [Java 多线程编程](https://www.runoob.com/java/java-multithreading.html)

Java 给多线程编程提供了内置的支持。 一条线程指的是进程中一个单一顺序的控制流，一个进程中可以并发多个线程，每条线程并行执行不同的任务。

多线程是多任务的一种特别的形式，但多线程使用了更小的资源开销。

这里定义和线程相关的另一个术语 - 进程：一个进程包括由操作系统分配的内存空间，包含一个或多个线程。一个线程不能独立的存在，它必须是进程的一部分。一个进程一直运行，直到所有的非守护线程都结束运行后才能结束。

多线程能满足程序员编写高效率的程序来达到充分利用 CPU 的目的。

------

## 一个线程的生命周期

https://www.runoob.com/wp-content/uploads/2014/01/java-thread.jpg

- 新建状态:

  使用 **new** 关键字和 **Thread** 类或其子类建立一个线程对象后，该线程对象就处于新建状态。它保持这个状态直到程序 **start()** 这个线程。

- 就绪状态:

  当线程对象调用了start()方法之后，该线程就进入就绪状态。就绪状态的线程处于就绪队列中，要等待JVM里线程调度器的调度。

- 运行状态:

  如果就绪状态的线程获取 CPU 资源，就可以执行 **run()**，此时线程便处于运行状态。处于运行状态的线程最为复杂，它可以变为阻塞状态、就绪状态和死亡状态。

- 阻塞状态:

  如果一个线程执行了sleep（睡眠）、suspend（挂起）等方法，失去所占用资源之后，该线程就从运行状态进入阻塞状态。在睡眠时间已到或获得设备资源后可以重新进入就绪状态。可以分为三种：

  - 等待阻塞：运行状态中的线程执行 wait() 方法，使线程进入到等待阻塞状态。
  - 同步阻塞：线程在获取 synchronized 同步锁失败(因为同步锁被其他线程占用)。
  - 其他阻塞：通过调用线程的 sleep() 或 join() 发出了 I/O 请求时，线程就会进入到阻塞状态。当sleep() 状态超时，join() 等待线程终止或超时，或者 I/O 处理完毕，线程重新转入就绪状态。

- 死亡状态:

  一个运行状态的线程完成任务或者其他终止条件发生时，该线程就切换到终止状态。

## 线程的优先级

每一个 Java 线程都有一个优先级，这样有助于操作系统确定线程的调度顺序。

Java 线程的优先级是一个整数，其取值范围是 1 （Thread.MIN_PRIORITY ） - 10 （Thread.MAX_PRIORITY ）。

默认情况下，每一个线程都会分配一个优先级 NORM_PRIORITY（5）。

具有较高优先级的线程对程序更重要，并且应该在低优先级的线程之前分配处理器资源。但是，线程优先级不能保证线程执行的顺序，而且非常依赖于平台。

------

## 创建一个线程

Java 提供了三种创建线程的方法：

- 通过实现 Runnable 接口；

- 通过继承 Thread 类本身；

- 通过 Callable 和 Future 创建线程。

  

创建一个线程，最简单的方法是创建一个实现 Runnable 接口的类。

为了实现 Runnable，一个类只需要执行一个方法调用 run()，声明如下：

```
public void run()
```

你可以重写该方法，重要的是理解的 run() 可以调用其他方法，使用其他类，并声明变量，就像主线程一样。

在创建一个实现 Runnable 接口的类之后，你可以在类中实例化一个线程对象。

Thread 定义了几个构造方法，下面的这个是我们经常使用的：

```
Thread(Runnable threadOb,String threadName);
```

这里，threadOb 是一个实现 Runnable 接口的类的实例，并且 threadName 指定新线程的名字。

新线程创建之后，你调用它的 start() 方法它才会运行。

```
void start();
```

## 通过继承Thread来创建线程

创建一个线程的第二种方法是创建一个新的类，该类继承 Thread 类，然后创建一个该类的实例。

继承类必须重写 run() 方法，该方法是新线程的入口点。它也必须调用 start() 方法才能执行。

该方法尽管被列为一种多线程实现方式，但是本质上也是实现了 Runnable 接口的一个实例。

## Thread 方法

下表列出了Thread类的一些重要方法：

| **序号** |                         **方法描述**                         |
| :------- | :----------------------------------------------------------: |
| 1        | **public void start()** 使该线程开始执行；**Java** 虚拟机调用该线程的 run 方法。 |
| 2        | **public void run()** 如果该线程是使用独立的 Runnable 运行对象构造的，则调用该 Runnable 对象的 run 方法；否则，该方法不执行任何操作并返回。 |
| 3        | **public final void setName(String name)** 改变线程名称，使之与参数 name 相同。 |
| 4        | **public final void setPriority(int priority)**  更改线程的优先级。 |
| 5        | **public final void setDaemon(boolean on)** 将该线程标记为守护线程或用户线程。 |
| 6        | **public final void join(long millisec)** 等待该线程终止的时间最长为 millis 毫秒。 |
| 7        |            **public void interrupt()** 中断线程。            |
| 8        | **public final boolean isAlive()** 测试线程是否处于活动状态。 |

上述方法是被 Thread 对象调用的，下面表格的方法是 Thread 类的静态方法。

| **序号** |                         **方法描述**                         |
| :------- | :----------------------------------------------------------: |
| 1        | **public static void yield()** 暂停当前正在执行的线程对象，并执行其他线程。 |
| 2        | **public static void sleep(long millisec)** 在指定的毫秒数内让当前正在执行的线程休眠（暂停执行），此操作受到系统计时器和调度程序精度和准确性的影响。 |
| 3        | **public static boolean holdsLock(Object x)** 当且仅当当前线程在指定的对象上保持监视器锁时，才返回 true。 |
| 4        | **public static Thread currentThread()** 返回对当前正在执行的线程对象的引用。 |
| 5        | **public static void dumpStack()** 将当前线程的堆栈跟踪打印至标准错误流。 |

## 通过 Callable 和 Future 创建线程

1. 创建 Callable 接口的实现类，并实现 call() 方法，该 call() 方法将作为线程执行体，并且有返回值。
2.  创建 Callable 实现类的实例，使用 FutureTask 类来包装 Callable 对象，该 FutureTask 对象封装了该 Callable 对象的 call() 方法的返回值。
3. 使用 FutureTask 对象作为 Thread 对象的 target 创建并启动新线程。
4. 调用 FutureTask 对象的 get() 方法来获得子线程执行结束后的返回值。

## 创建线程的三种方式的对比

-  采用实现 Runnable、Callable 接口的方式创建多线程时，线程类只是实现了 Runnable 接口或 Callable 接口，还可以继承其他类。
- 使用继承 Thread 类的方式创建多线程时，编写简单，如果需要访问当前线程，则无需使用 Thread.currentThread() 方法，直接使用 this 即可获得当前线程。

