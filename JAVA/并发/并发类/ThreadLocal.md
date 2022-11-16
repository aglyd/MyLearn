# [知道ThreadLocal嘛？谈谈你对它的理解？（基于jdk1.8）](https://baijiahao.baidu.com/s?id=1653790035315010634&wfr=spider&for=pc)

在java的多线程模块中，ThreadLocal是经常被提问到的一个知识点，提问的方式有很多种，可能是循序渐进也可能是就像我的题目那样，因此只有理解透彻了，不管怎么问，都能游刃有余。

这篇文章主要从以下几个角度来分析理解

**1、ThreadLocal是什么**

**2、ThreadLocal怎么用**

**3、ThreadLocal源码分析**

**4、ThreadLocal内存泄漏问题**

下面我们带着这些问题，一点一点揭开ThreadLocal的面纱。若有不正之处请多多谅解，并欢迎批评指正。**以下源码均基于jdk1.8。**

## 一、ThreadLocal是什么

从名字我们就可以看到ThreadLocal叫做线程变量，意思是ThreadLocal中填充的变量属于**当前**线程，该变量对其他线程而言是隔离的。ThreadLocal为变量在每个线程中都创建了一个副本，那么每个线程可以访问自己内部的副本变量。

从字面意思来看非常容易理解，但是从实际使用的角度来看，就没那么容易了，作为一个面试常问的点，使用场景那也是相当的丰富：

**1、在进行对象跨层传递的时候，使用ThreadLocal可以避免多次传递，打破层次间的约束。**

**2、线程间数据隔离**

**3、进行事务操作，用于存储线程事务信息。**

**4、数据库连接，Session会话管理。**

现在相信你已经对ThreadLocal有一个大致的认识了，下面我们看看如何用？

## 二、ThreadLocal怎么用

既然ThreadLocal的作用是每一个线程创建一个副本，我们使用一个例子来验证一下：

![img](https://pics0.baidu.com/feed/14ce36d3d539b600ff663d8e75a8c62fc75cb759.jpeg?token=44530368d6f896c24c1566224aa81a47&s=B8C3A144D2B4806F165DF8030000E0C1)

从结果我们可以看到，每一个线程都有各自的local值，我们设置了一个休眠时间，就是为了另外一个线程也能够及时的读取当前的local值。

这就是TheadLocal的基本使用，是不是非常的简单。那么为什么会在数据库连接的时候使用的比较多呢？

![img](https://pics6.baidu.com/feed/3c6d55fbb2fb43165898204f805cb52608f7d37a.jpeg?token=8af7124abdc7ed9108b00bba0a1b48fd&s=B8C1B34C43B4BD6C1E499C0E0200E081)

上面是一个数据库连接的管理类，我们使用数据库的时候首先就是建立数据库连接，然后用完了之后关闭就好了，这样做有一个很严重的问题，如果有1个客户端频繁的使用数据库，那么就需要建立多次链接和关闭，我们的服务器可能会吃不消，怎么办呢？如果有一万个客户端，那么服务器压力更大。

这时候最好ThreadLocal，因为ThreadLocal在每个线程中对连接会创建一个副本，且在线程内部任何地方都可以使用，线程之间互不影响，这样一来就不存在线程安全问题，也不会严重影响程序执行性能。是不是很好用。

以上主要是讲解了一个基本的案例，然后还分析了为什么在数据库连接的时候会使用ThreadLocal。下面我们从源码的角度来分析一下，ThreadLocal的工作原理。

## 三、ThreadLocal源码分析

在最开始的例子中，只给出了两个方法也就是get和set方法，其实还有几个需要我们注意。

![img](https://pics1.baidu.com/feed/5882b2b7d0a20cf4381d1f17d7f1b833aeaf9963.jpeg?token=354a91e3c84ef7cc069454f9842508b0&s=F0C0B14452F4887C1660DC0B0300E0C1)

方法这么多，我们主要来看set，然后就能认识到整体的ThreadLocal了：

**1、set方法**

![img](https://pics4.baidu.com/feed/d788d43f8794a4c24768d2b6aa0ce8d0af6e39e5.jpeg?token=be9e163f7bb852ae622cddfed4486dec&s=B8D1A14416F0AD685ADD80110000C0C1)

从set方法我们可以看到，首先获取到了当前线程t，然后调用getMap获取ThreadLocalMap，如果map存在，则将当前线程threadlocal对象作为key，要存储的对象作为value存到map里面去。如果该Map不存在，则初始化一个，这样每个不同线程间的key值虽然一样（都是local对象），但是对于不同的线程保存在各个独自的threallocalMap中，因此每次取出当前线程的threadlocalMap，从map中取出local为key的value即可取出自己的value。

OK，到这一步了，相信你会有几个疑惑了，ThreadLocalMap是什么，getMap方法又是如何实现的。带着这些问题，继续往下看。先来看ThreadLocalMap。

![img](https://pics4.baidu.com/feed/dcc451da81cb39dbc5179c0a76eefa21a9183091.jpeg?token=2022bfb126e4e2cdd0121264f6e3f3cf&s=BAC1A14C12A4BD6C4CD4D40F000070C1)

我们可以看到ThreadLocalMap其实就是ThreadLocal的一个静态内部类，里面定义了一个Entry来保存数据，而且还是继承的弱引用。在Entry内部使用ThreadLocal作为key，使用我们设置的value作为value。

还有一个getMap

ThreadLocalMap getMap(Thread t) {

return t.threadLocals;

}

调用当期线程t，返回当前线程t中的成员变量threadLocals。而threadLocals其实就是ThreadLocalMap。

**2、get方法**

![img](https://pics0.baidu.com/feed/1ad5ad6eddc451da407745971e05a163d21632c3.jpeg?token=f36e01b7c9667a23a5db8d5990af8721&s=BAC2A14C52F49C6B46D1BD130000E0C1)

通过上面ThreadLocal的介绍相信你对这个方法能够很好的理解了，首先获取当前线程，然后调用getMap方法获取一个ThreadLocalMap，如果map不为null，那就使用当前线程作为ThreadLocalMap的Entry的键，然后值就作为相应的的值，如果没有那就设置一个初始值。

如何设置一个初始值呢？

![img](https://pics5.baidu.com/feed/b03533fa828ba61e32d287deebcc640f314e5905.jpeg?token=a352851e04b75317b503ca85e954dc2d&s=B2D1A16C5AF4BC495AFC88110000C0C1)

原理很简单

**3、remove方法**

![img](https://pics0.baidu.com/feed/562c11dfa9ec8a13c0678a565bfb628aa1ecc002.jpeg?token=df21524a2c88859a18a3544caf773925&s=BAC1A14CCFE4BF700A49B403000030C3)

从我们的map移除即可。

OK，其实内部源码很简单，现在我们总结一波

（1）每个Thread维护着一个ThreadLocalMap的引用

（2）ThreadLocalMap是ThreadLocal的内部类，用Entry来进行存储

（3）ThreadLocal创建的副本是存储在自己的threadLocals中的，也就是自己的ThreadLocalMap。

（4）ThreadLocalMap的键值为ThreadLocal对象，而且可以有多个threadLocal变量，因此保存在map中

（5）在进行get之前，必须先set，否则会报空指针异常，当然也可以初始化一个，但是必须重写initialValue()方法。

（6）ThreadLocal本身并不存储值，它只是作为一个key来让线程从ThreadLocalMap获取value。

OK，现在从源码的角度上不知道你能理解不，对于ThreadLocal来说关键就是内部的ThreadLocalMap。

**四、ThreadLocal其他几个注意的点**

只要是介绍ThreadLocal的文章都会帮大家认识一个点，那就是内存泄漏问题。我们先来看下面这张图。

![img](https://pics3.baidu.com/feed/91ef76c6a7efce1b563edc5501a900dbb58f6512.jpeg?token=a6acac56e087a9c1581a7acfc867015d&s=A642F210061F6DCA0AF341C5030030BB)

上面这张图详细的揭示了ThreadLocal和Thread以及ThreadLocalMap三者的关系。

1、Thread中有一个map，就是ThreadLocalMap

2、ThreadLocalMap的key是ThreadLocal，值是我们自己设定的。

3、ThreadLocal是一个弱引用，当为null时，会被当成垃圾回收

**4、重点来了，突然我们ThreadLocal是null了，也就是要被垃圾回收器回收了，但是此时我们的ThreadLocalMap生命周期和Thread的一样，它不会回收，这时候就出现了一个现象。那就是ThreadLocalMap的key没了，但是value还在，这就造成了内存泄漏。**

**解决办法：使用完ThreadLocal后，执行remove操作，避免出现内存溢出情况。**

```java
public class ThreadLocal<T> {
   ...
       public void remove() {
        ThreadLocal.ThreadLocalMap var1 = this.getMap(Thread.currentThread());
        if (var1 != null) {
            var1.remove(this);
        }
    }
    ...
}
```



# [史上最全ThreadLocal 详解（一）](https://blog.csdn.net/u010445301/article/details/111322569)

## 一、ThreadLocal简介

ThreadLocal叫做线程变量，意思是ThreadLocal中填充的变量属于当前线程，该变量对其他线程而言是隔离的，也就是说该变量是当前线程独有的变量。ThreadLocal为变量在每个线程中都创建了一个副本，那么每个线程可以访问自己内部的副本变量。

ThreadLoal 变量，线程局部变量，同一个 ThreadLocal 所包含的对象，在不同的 Thread 中有不同的副本。这里有几点需要注意：

因为每个 Thread 内有自己的实例副本，且该副本只能由当前 Thread 使用。这是也是 ThreadLocal 命名的由来。
既然每个 Thread 有自己的实例副本，且其它 Thread 不可访问，那就不存在多线程间共享的问题。
ThreadLocal 提供了线程本地的实例。它与普通变量的区别在于，每个使用该变量的线程都会初始化一个完全独立的实例副本。ThreadLocal 变量通常被private static修饰。当一个线程结束时，它所使用的所有 ThreadLocal 相对的实例副本都可被回收。

总的来说，ThreadLocal 适用于每个线程需要自己独立的实例且该实例需要在多个方法中被使用，也即变量在线程间隔离而在方法或类间共享的场景

下图可以增强理解：

![img](https://img-blog.csdnimg.cn/20201217201331591.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTA0NDUzMDE=,size_16,color_FFFFFF,t_70)

​                                                             图1-1  ThreadLocal在使用过程中状态

## 二、ThreadLocal与Synchronized的区别

ThreadLocal<T>其实是与线程绑定的一个变量。ThreadLocal和Synchonized都用于解决多线程并发访问。

但是ThreadLocal与synchronized有本质的区别：

1、Synchronized用于线程间的数据共享，而ThreadLocal则用于线程间的数据隔离。

2、Synchronized是利用锁的机制，使变量或代码块在某一时该只能被一个线程访问。而ThreadLocal为每一个线程都提供了变量的副本

，使得每个线程在某一时间访问到的并不是同一个对象，这样就隔离了多个线程对数据的数据共享。

而Synchronized却正好相反，它用于在多个线程间通信时能够获得数据共享。

一句话理解ThreadLocal，threadlocl是作为当前线程中属性ThreadLocalMap集合中的某一个Entry的key值Entry（threadlocl,value），虽然不同的线程之间threadlocal这个key值是一样，但是不同的线程所拥有的ThreadLocalMap是独一无二的，也就是不同的线程间同一个ThreadLocal（key）对应存储的值(value)不一样，从而到达了线程间变量隔离的目的，但是在同一个线程中这个value变量地址是一样的。

## 三、ThreadLocal的简单使用

直接上代码：

```java
public class ThreadLocaDemo {
 
    private static ThreadLocal<String> localVar = new ThreadLocal<String>();
 
    static void print(String str) {
        //打印当前线程中本地内存中本地变量的值
        System.out.println(str + " :" + localVar.get());
        //清除本地内存中的本地变量
        localVar.remove();
    }
    public static void main(String[] args) throws InterruptedException {
 
        new Thread(new Runnable() {
            public void run() {
                ThreadLocaDemo.localVar.set("local_A");	//local_A是threadLocalMap的value
                print("A");
                //打印本地变量
                System.out.println("after remove : " + localVar.get());
               
            }
        },"A").start();
 
        Thread.sleep(1000);
 
        new Thread(new Runnable() {
            public void run() {
                ThreadLocaDemo.localVar.set("local_B");
                print("B");
                System.out.println("after remove : " + localVar.get());
              
            }
        },"B").start();
    }
}
 
A :local_A
after remove : null
B :local_B
after remove : null
```

从这个示例中我们可以看到，两个线程分表获取了自己线程存放的变量，他们之间变量的获取并不会错乱。这个的理解也可以结合图1-1，相信会有一个更深刻的理解。

## 四、ThreadLocal的原理

要看原理那么就得从源码看起。

###   4.1 ThreadLocal的set()方法：

```java
 public void set(T value) {
        //1、获取当前线程
        Thread t = Thread.currentThread();
        //2、获取线程中的属性 threadLocalMap ,如果threadLocalMap 不为空，
        //则直接更新要保存的变量值，否则创建threadLocalMap，并赋值
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            // 初始化thradLocalMap 并赋值
            createMap(t, value);
    }
```

 从上面的代码可以看出，ThreadLocal  set赋值的时候首先会获取当前线程thread,并获取thread线程中的ThreadLocalMap属性。如果map属性不为空，则直接更新value值，如果map为空，则实例化threadLocalMap,并将value值初始化。

那么ThreadLocalMap又是什么呢，还有createMap又是怎么做的，我们继续往下看。大家最后自己再idea上跟下源码，会有更深的认识。

```java
  static class ThreadLocalMap {
 
        /**
         * The entries in this hash map extend WeakReference, using
         * its main ref field as the key (which is always a
         * ThreadLocal object).  Note that null keys (i.e. entry.get()
         * == null) mean that the key is no longer referenced, so the
         * entry can be expunged from table.  Such entries are referred to
         * as "stale entries" in the code that follows.
         */
        static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;
 
            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
        
    }
```

可看出ThreadLocalMap是ThreadLocal的内部静态类，而它的构成主要是用Entry来保存数据 ，而且还是继承的弱引用。在Entry内部使用ThreadLocal作为key，使用我们设置的value作为value。详细内容要大家自己去跟。

### 4.2 ThreadLocal的get方法

```java
    public T get() {
        //1、获取当前线程
        Thread t = Thread.currentThread();
        //2、获取当前线程的ThreadLocalMap
        ThreadLocalMap map = getMap(t);
        //3、如果map数据不为空，
        if (map != null) {
            //3.1、获取threalLocalMap中存储的值
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        //如果是数据为null，则初始化，初始化的结果，TheralLocalMap中存放key值为threadLocal，值为null
        return setInitialValue();
    }
 
 
private T setInitialValue() {
        T value = initialValue();
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
        return value;
    }
```

### 4.3 ThreadLocal的remove方法

remove方法，直接将ThrealLocal 对应的值从当前相差Thread中的ThreadLocalMap中删除。为什么要删除，这涉及到内存泄露的问题。

实际上 ThreadLocalMap 中使用的 key 为 ThreadLocal 的弱引用，弱引用的特点是，如果这个对象只存在弱引用，那么在下一次垃圾回收的时候必然会被清理掉。

所以如果 ThreadLocal 没有被外部强引用的情况下，在垃圾回收的时候会被清理掉的，这样一来 ThreadLocalMap中使用这个 ThreadLocal 的 key 也会被清理掉。但是，value 是强引用，不会被清理，这样一来就会出现 key 为 null 的 value。

ThreadLocal其实是与线程绑定的一个变量，如此就会出现一个问题：如果没有将ThreadLocal内的变量删除（remove）或替换，它的生命周期将会与线程共存。通常线程池中对线程管理都是采用线程复用的方法，在线程池中线程很难结束甚至于永远不会结束，这将意味着线程持续的时间将不可预测，甚至与JVM的生命周期一致。举个例字，如果ThreadLocal中直接或间接包装了集合类或复杂对象，每次在同一个ThreadLocal中取出对象后，再对内容做操作，那么内部的集合类和复杂对象所占用的空间可能会开始持续膨胀。

**对于早期jdk的threadLocal设计：如果线程不是使用线程池管理不需要重复利用，则当子线程结束回收threadlocal中的key thread对象为null，而值value生命周期和threadLocal相同一直存在，每次调用新的子线程结束就会多一个空闲value，久而久之容易造成内存泄漏。但如果线程是采用线程池管理可重复利用则不会造成此问题。**

**对于jdk1.8的threadLocal：如果是采用线程池，ThreadLocalMap的生命周期跟 Thread 一样长。如果threadlocal变量被回收，那么当前线程的threadlocal 变量副本指向的就是key=null, 也即entry(null,value),那这个entry对应的value永远无法访问到，而线程池中的线程都是复用的，这样就可能导致非常多的entry(null,value)出现，从而导致内存泄露。如果不采用线程池则threadlocal为null，也会导致value无法访问可能造成内存泄漏，但子线程使用完可以回收，相对来说造成内存泄露的几率较小一点，但使用线程池也有使用线程池的好处。**

**总结：如果使用线程池，每次使用完threadLocal则手动remove当前线程的引用**

### 4.4、ThreadLocal与Thread，ThreadLocalMap之间的关系  

![img](https://img-blog.csdnimg.cn/20201218111045616.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTA0NDUzMDE=,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/202012181111507.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTA0NDUzMDE=,size_16,color_FFFFFF,t_70)


图4-1 Thread、THreadLocal、ThreadLocalMap之间啊的数据关系图

从这个图中我们可以非常直观的看出，ThreadLocalMap其实是Thread线程的一个属性值，而ThreadLocal是维护ThreadLocalMap这个属性指的一个工具类。Thread线程可以拥有多个ThreadLocal维护的自己线程独享的共享变量（这个共享变量只是针对自己线程里面共享）

## 五、ThreadLocal 常见使用场景

如上文所述，ThreadLocal 适用于如下两种场景

1、每个线程需要有自己单独的实例
2、实例需要在多个方法中共享，但不希望被多线程共享
对于第一点，每个线程拥有自己实例，实现它的方式很多。例如可以在线程内部构建一个单独的实例。ThreadLoca 可以以非常方便的形式满足该需求。

对于第二点，可以在满足第一点（每个线程有自己的实例）的条件下，通过方法间引用传递的形式实现。ThreadLocal 使得代码耦合度更低，且实现更优雅。

场景

1）存储用户Session

一个简单的用ThreadLocal来存储Session的例子：

```java
private static final ThreadLocal threadSession = new ThreadLocal();
 
    public static Session getSession() throws InfrastructureException {
        Session s = (Session) threadSession.get();
        try {
            if (s == null) {
                s = getSessionFactory().openSession();
                threadSession.set(s);
            }
        } catch (HibernateException ex) {
            throw new InfrastructureException(ex);
        }
        return s;
    }
```

场景二、数据库连接，处理数据库事务

场景三、数据跨层传递（controller,service, dao）

  每个线程内需要保存类似于全局变量的信息（例如在拦截器中获取的用户信息），可以让不同方法直接使用，避免参数传递的麻烦却不想被多线程共享（因为不同线程获取到的用户信息不一样）。

例如，用 ThreadLocal 保存一些业务内容（用户权限信息、从用户系统获取到的用户名、用户ID 等），这些信息在同一个线程内相同，但是不同的线程使用的业务内容是不相同的。

在线程生命周期内，都通过这个静态 ThreadLocal 实例的 get() 方法取得自己 set 过的那个对象，避免了将这个对象（如 user 对象）作为参数传递的麻烦。

比如说我们是一个用户系统，那么当一个请求进来的时候，一个线程会负责执行这个请求，然后这个请求就会依次调用service-1()、service-2()、service-3()、service-4()，这4个方法可能是分布在不同的类中的。这个例子和存储session有些像。

```java
package com.kong.threadlocal;
 
 
public class ThreadLocalDemo05 {
    public static void main(String[] args) {
        User user = new User("jack");
        new Service1().service1(user);
    }
 
}
 
class Service1 {
    public void service1(User user){
        //给ThreadLocal赋值，后续的服务直接通过ThreadLocal获取就行了。
        UserContextHolder.holder.set(user);
        new Service2().service2();
    }
}
 
class Service2 {
    public void service2(){
        User user = UserContextHolder.holder.get();
        System.out.println("service2拿到的用户:"+user.name);
        new Service3().service3();
    }
}
 
class Service3 {
    public void service3(){
        User user = UserContextHolder.holder.get();
        System.out.println("service3拿到的用户:"+user.name);
        //在整个流程执行完毕后，一定要执行remove
        UserContextHolder.holder.remove();
    }
}
 
class UserContextHolder {
    //创建ThreadLocal保存User对象
    public static ThreadLocal<User> holder = new ThreadLocal<>();
}
 
class User {
    String name;
    public User(String name){
        this.name = name;
    }
}
 
执行的结果：
 
service2拿到的用户:jack
service3拿到的用户:jack
```

场景四、Spring使用ThreadLocal解决线程安全问题 

我们知道在一般情况下，**只有无状态的Bean才可以在多线程环境下共享，在Spring中，绝大部分Bean都可以声明为singleton作用域。就是因为Spring对一些Bean（如RequestContextHolderTransactionSynchronizationManager、LocaleContextHolder等）中非线程安全的==“状态性对象”采用ThreadLocal进行封装，让它们也成为线程安全的“无状态性对象”，因此有状态的Bean就能够以singleton的方式在多线程中正常工作了。==** 

一般的Web应用划分为展现层、服务层和持久层三个层次，在不同的层中编写对应的逻辑，下层通过接口向上层开放功能调用。在一般情况下，从接收请求到返回响应所经过的所有程序调用都同属于一个线程，如图9-2所示。 

![img](https://img-blog.csdnimg.cn/img_convert/33d873ae0689a63fa99e093c6732c5b1.png)

这样用户就可以根据需要，将一些非线程安全的变量以ThreadLocal存放，在同一次请求响应的调用线程中，所有对象所访问的同一ThreadLocal变量都是当前线程所绑定的。

下面的实例能够体现Spring对有状态Bean的改造思路：


代码清单9-5  TopicDao：非线程安全

```java
 public class TopicDao {
   //①一个非线程安全的变量
   private Connection conn; 
   public void addTopic(){
        //②引用非线程安全变量
	   Statement stat = conn.createStatement();
	   …
   }
```

  由于①处的conn是成员变量，因为addTopic()方法是非线程安全的，必须在使用时创建一个新TopicDao实例（非singleton）。下面使用ThreadLocal对conn这个非线程安全的“状态”进行改造： 

代码清单9-6  TopicDao：线程安全   

```java
 
import java.sql.Connection;
import java.sql.Statement;
public class TopicDao {
 
  //①使用ThreadLocal保存Connection变量
private static ThreadLocal<Connection> connThreadLocal = new ThreadLocal<Connection>();
public static Connection getConnection(){
         
	    //②如果connThreadLocal没有本线程对应的Connection创建一个新的Connection，
        //并将其保存到线程本地变量中。
if (connThreadLocal.get() == null) {
			Connection conn = ConnectionManager.getConnection();
			connThreadLocal.set(conn);
              return conn;
		}else{
              //③直接返回线程本地变量
			return connThreadLocal.get();
		}
	}
	public void addTopic() {
 
		//④从ThreadLocal中获取线程对应的
         Statement stat = getConnection().createStatement();
	}
```

不同的线程在使用TopicDao时，先判断connThreadLocal.get()是否为null，如果为null，则说明当前线程还没有对应的Connection对象，这时创建一个Connection对象并添加到本地线程变量中；如果不为null，则说明当前的线程已经拥有了Connection对象，直接使用就可以了。这样，就保证了不同的线程使用线程相关的Connection，而不会使用其他线程的Connection。因此，这个TopicDao就可以做到singleton共享了。 

当然，这个例子本身很粗糙，将Connection的ThreadLocal直接放在Dao只能做到本Dao的多个方法共享Connection时不发生线程安全问题，但无法和其他Dao共用同一个Connection，要做到同一事务多Dao共享同一个Connection，必须在一个共同的外部类使用ThreadLocal保存Connection。但这个实例基本上说明了Spring对有状态类线程安全化的解决思路。在本章后面的内容中，我们将详细说明Spring如何通过ThreadLocal解决事务管理的问题。

## 六、ThreadLocal 内存泄露的原因及处理方式

### 1、ThreadLocal 使用原理

​       前文我们讲过ThreadLocal的主要用途是实现线程间变量的隔离，表面上他们使用的是同一个ThreadLocal， 但是实际上使用的值value却是自己独有的一份。用一图直接表示threadlocal 的使用方式。

图1

![img](https://img-blog.csdnimg.cn/e82f2120a5d34632bad3ca46ad7f1eb8.png)

从图中我们可以当线程使用threadlocal 时，是将threadlocal当做当前线程thread的属性ThreadLocalMap 中的一个Entry的key值，实际上存放的变量是Entry的value值，我们实际要使用的值是value值。value值为什么不存在并发问题呢，因为它只有一个线程能访问。threadlocal我们可以当做一个索引看待，可以有多个threadlocal 变量，不同的threadlocal对应于不同的value值，他们之间互不影响。ThreadLocal为每一个线程都提供了变量的副本，使得每个线程在某一时间访问到的并不是同一个对象，这样就隔离了多个线程对数据的数据共享。

### 2、ThreadLocal 内存泄露的原因

 Entry将ThreadLocal作为Key，值作为value保存，它继承自WeakReference，注意构造函数里的第一行代码super(k)，这意味着ThreadLocal对象是一个「弱引用」。可以看图1.

```java
static class Entry extends WeakReference<ThreadLocal<?>> {
    /** The value associated with this ThreadLocal. */
    Object value;
    Entry(ThreadLocal<?> k, Object v) {
        super(k);
        value = v;
    }
}
```

主要两个原因
1 . 没有手动删除这个 Entry
2 . CurrentThread 当前线程依然运行

​    第一点很好理解，只要在使用完下 ThreadLocal ，调用其 remove 方法删除对应的 Entry ，就能避免内存泄漏。
​    第二点稍微复杂一点，由于ThreadLocalMap 是 Thread 的一个属性，被当前线程所引用，所以ThreadLocalMap的生命周期跟 Thread 一样长。如果threadlocal变量被回收，那么当前线程的threadlocal 变量副本指向的就是key=null, 也即entry(null,value),那这个entry对应的value永远无法访问到。实际私用ThreadLocal场景都是采用线程池，而线程池中的线程都是复用的，这样就可能导致非常多的entry(null,value)出现，从而导致内存泄露。

综上， ThreadLocal 内存泄漏的根源是：
    **由于ThreadLocalMap 的生命周期跟 Thread 一样长，对于重复利用的线程来说，如果没有手动删除（remove()方法）对应 key 就会导致entry(null，value)的对象越来越多，从而导致内存泄漏．**

### 3、 为什么不将key设置为强引用

#### 3.1 、key 如果是强引用

​     那么为什么ThreadLocalMap的key要设计成弱引用呢？其实很简单，如果key设计成强引用且没有手动remove()，那么key会和value一样伴随线程的整个生命周期。

   1、假设在业务代码中使用完ThreadLocal, ThreadLocal ref被回收了，但是因为threadLocalMap的Entry强引用了threadLocal(key就是threadLocal), 造成ThreadLocal无法被回收。在没有手动删除Entry以及CurrentThread(当前线程)依然运行的前提下, 始终有强引用链CurrentThread Ref → CurrentThread →Map(ThreadLocalMap)-> entry, Entry就不会被回收( Entry中包括了ThreadLocal实例和value), 导致Entry内存泄漏也就是说: ThreadLocalMap中的key使用了强引用, 是无法完全避免内存泄漏的。请结合图1看。

#### 3.3  那么为什么 key 要用弱引用

​     **==事实上，在 ThreadLocalMap 中的set/getEntry 方法中，会对 key 为 null（也即是 ThreadLocal 为 null ）进行判断，如果为 null 的话，那么会把 value 置为 null 的．这就意味着使用threadLocal , CurrentThread 依然运行的前提下．就算忘记调用 remove 方法，弱引用比强引用可以多一层保障：弱引用的 ThreadLocal 会被回收．对应value在下一次 ThreadLocaI 调用 get()/set()/remove() 中的任一方法的时候会被清除，从而避免内存泄漏．==**

#### 3.4 如何正确的使用ThreadLocal

 1、将ThreadLocal变量定义成private static的，这样的话ThreadLocal的生命周期就更长，由于一直存在ThreadLocal的强引用，所以ThreadLocal也就不会被回收，也就能保证任何时候都能根据ThreadLocal的弱引用访问到Entry的value值，然后remove它，防止内存泄露


 2、**每次使用完ThreadLocal，都调用它的remove()方法，清除数据。**




# [ThreadLocal 详解](https://blog.csdn.net/silence_yb/article/details/124265702)

## ThreadLocal 概述

ThreadLocal类用来提供线程内部的局部变量，不同的线程之间不会相互干扰
这种变量在多线程环境下访问（通过get和set方法访问）时能保证各个线程的变量相对独立于其他线程内的变量
在线程的生命周期内起作用，可以减少同一个线程内多个函数或组件之间一些公共变量传递的复杂度
使用
常用方法
方法名	描述
ThreadLocal()	创建ThreadLocal对象
public void set( T value)	设置当前线程绑定的局部变量
public T get()	获取当前线程绑定的局部变量
public T remove()	移除当前线程绑定的局部变量，该方法可以帮助JVM进行GC
protected T initialValue()	返回当前线程局部变量的初始值
案例
场景：让每个线程获取其设置的对应的共享变量值
共享变量访问问题案例

```java
/**
 * 线程间访问共享变量之间问题
 * */
public class DemoQuestion {
    private String name;
    private int age;

    public static void main(String[] args) {
        DemoQuestion demoQuestion = new DemoQuestion();
        for (int i = 0; i < 5; i++) {
            // int j = i;
            new Thread(() ->{
                // demoQuestion.setAge(j);
                demoQuestion.setName(Thread.currentThread().getName() + "的数据");
                System.out.println("=================");
                System.out.println(Thread.currentThread().getName() + "--->" + demoQuestion.getName());
                // System.out.println(Thread.currentThread().getName() + "--->" + demoQuestion.getAge());
            },"t" + i).start();
        }
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getAge() {
        return age;
    }
    public void setAge(int age) {
        this.age = age;
    }
}
```

使用关键字 Synchronized 关键字加锁解决方案

```java
/**
 * 使用加锁的方式解决：线程间访问共享变量之间问题
 * 将对共享变量的操作进行加锁，保证其原子性
 * */
public class SolveDemoQuestionBySynchronized {
    private String name;
    private int age;

    public static void main(String[] args) {
        SolveDemoQuestionBySynchronized demoQuestion = new SolveDemoQuestionBySynchronized();
        for (int i = 0; i < 5; i++) {
            // int j = i;
            new Thread(() ->{
                synchronized (SolveDemoQuestionBySynchronized.class){
                    demoQuestion.setName(Thread.currentThread().getName() + "的数据");
                    System.out.println("=================");
                    System.out.println(Thread.currentThread().getName() + "--->" + demoQuestion.getName());
                }
            },"t" + i).start();
        }
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getAge() {
        return age;
    }
    public void setAge(int age) {
        this.age = age;
    }
}
```

- 使用 ThreadLocal 方式解决

  ```java
  public class SolveDemoQuestionByThreadLocal {
      private  ThreadLocal<String> name = new ThreadLocal<>();
      private int age;
  
      public static void main(String[] args) {
          SolveDemoQuestionByThreadLocal demoQuestion = new SolveDemoQuestionByThreadLocal();
          for (int i = 0; i < 5; i++) {
              new Thread(() ->{
                  demoQuestion.setName(Thread.currentThread().getName() + "的数据");
                  System.out.println("=================");
                  System.out.println(Thread.currentThread().getName() + "--->" + demoQuestion.getName());
              },"t" + i).start();
          }
      }
      public String getName() {
          return name.get();
      }
      private void setName(String content) {
          name.set(content);
      }
      public int getAge() {
          return age;
      }
      public void setAge(int age) {
          this.age = age;
      }
  }
  ```

  

## ThreadLocalMap 内部结果

**JDK8 之前的设计**
每个ThreadLocal都创建一个ThreadLocalMap，用线程作为ThreadLocalMap的key，要存储的局部变量作为ThreadLocalMap的value，这样就能达到各个线程的局部变量隔离的效果

![在这里插入图片描述](https://img-blog.csdnimg.cn/baa00cdb33a14aaeab7b453c1bb1469b.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Ly85a-S6Iul5pqW,size_20,color_FFFFFF,t_70,g_se,x_16)

**JDK8 之后的设计**

- 每个Thread维护一个ThreadLocalMap，这个ThreadLocalMap的key是ThreadLocal实例本身，value才是真正要存储的值Object
- 每个Thread线程内部都有一个ThreadLocalMap
- Map里面存储ThreadLocal对象（key）和线程的变量副本（value）
- Thread内部的Map是由ThreadLocal维护的，由ThreadLocal负责向map获取和设置线程的变量值
- 对于不同的线程，每次获取副本值时，别的线程并不能获取到当前线程的副本值，形成了副本的隔离，互不干扰

![在这里插入图片描述](https://img-blog.csdnimg.cn/5633b9ff01d84aaeb06b799d825e289e.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Ly85a-S6Iul5pqW,size_20,color_FFFFFF,t_70,g_se,x_16)



**JDK对ThreadLocal这样改造的好处**

- ==**减少ThreadLocalMap存储的Entry数量：因为之前的存储数量由Thread的数量决定，现在是由ThreadLocal的数量决定。在实际运用当中，往往ThreadLocal的数量要少于Thread的数量**==

- ==**当Thread销毁之后，对应的ThreadLocalMap也会随之销毁，能减少内存的使用（但是不能避免内存泄漏问题，解决内存泄漏问题应该在使用完后及时调用remove()对ThreadMap里的Entry对象进行移除，由于Entry继承了弱引用类，会在下次GC时被JVM回收）**==

  

## ThreadLocal相关方法源码解析

### set方法

源码及相关注释

```java
  /**
     * 设置当前线程对应的ThreadLocal的值
     * @param value 将要保存在当前线程对应的ThreadLocal的值
     */
    public void set(T value) {
        // 获取当前线程对象
        Thread t = Thread.currentThread();
        // 获取此线程对象中维护的ThreadLocalMap对象
        ThreadLocalMap map = getMap(t);
        // 判断map是否存在
        if (map != null)
            // 存在则调用map.set设置此实体entry,this这里指调用此方法的ThreadLocal对象
            map.set(this, value);
        else
            // 1）当前线程Thread 不存在ThreadLocalMap对象
            // 2）则调用createMap进行ThreadLocalMap对象的初始化
            // 3）并将 t(当前线程)和value(t对应的值)作为第一个entry存放至ThreadLocalMap中
            createMap(t, value);
    }

 /**
     * 获取当前线程Thread对应维护的ThreadLocalMap 
     * 
     * @param  t the current thread 当前线程
     * @return the map 对应维护的ThreadLocalMap 
     */
    ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }
    
	/**
     *创建当前线程Thread对应维护的ThreadLocalMap 
     * @param t 当前线程
     * @param firstValue 存放到map中第一个entry的值
     */
	void createMap(Thread t, T firstValue) {
        //这里的this是调用此方法的threadLocal
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
```

相关流程图

![在这里插入图片描述](https://img-blog.csdnimg.cn/2430f09d315e40769a63720f84a8a06c.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Ly85a-S6Iul5pqW,size_17,color_FFFFFF,t_70,g_se,x_16)

- 执行流程

1. 获取当前线程，并根据当前线程获取一个Map
2. 如果获取的Map不为空，则将参数设置到Map中（当前ThreadLocal的引用作为key）
3. 如果Map为空，则给该线程创建 Map，并设置初始值

### get()方法

- 源码及相关注释

```java
 /**
     * 返回当前线程中保存ThreadLocal的值
     * 如果当前线程没有此ThreadLocal变量，
     * 则它会通过调用{@link #initialValue} 方法进行初始化值
     * @return 返回当前线程对应此ThreadLocal的值
     */
    public T get() {
        // 获取当前线程对象
        Thread t = Thread.currentThread();
        // 获取此线程对象中维护的ThreadLocalMap对象
        ThreadLocalMap map = getMap(t);
        // 如果此map存在
        if (map != null) {
            // 以当前的ThreadLocal 为 key，调用getEntry获取对应的存储实体e
            ThreadLocalMap.Entry e = map.getEntry(this);
            // 对e进行判空 
            if (e != null) {
                @SuppressWarnings("unchecked")
                // 获取存储实体 e 对应的 value值,即为我们想要的当前线程对应此ThreadLocal的值
                T result = (T)e.value;
                return result;
            }
        }
        /*
        	初始化 : 有两种情况有执行当前代码
        	第一种情况: map不存在，表示此线程没有维护的ThreadLocalMap对象
        	第二种情况: map存在, 但是没有与当前ThreadLocal关联的entry
         */
        return setInitialValue();
    }

    /**
     * 初始化
     * @return the initial value 初始化后的值
     */
    private T setInitialValue() {
        // 调用initialValue获取初始化的值
        // 此方法可以被子类重写, 如果不重写默认返回null
        T value = initialValue();
        // 获取当前线程对象
        Thread t = Thread.currentThread();
        // 获取此线程对象中维护的ThreadLocalMap对象
        ThreadLocalMap map = getMap(t);
        // 判断map是否存在
        if (map != null)
            // 存在则调用map.set设置此实体entry
            map.set(this, value);
        else
            // 1）当前线程Thread 不存在ThreadLocalMap对象
            // 2）则调用createMap进行ThreadLocalMap对象的初始化
            // 3）并将 t(当前线程)和value(t对应的值)作为第一个entry存放至ThreadLocalMap中
            createMap(t, value);
        // 返回设置的值value
        return value;
    }
```

流程图

![在这里插入图片描述](https://img-blog.csdnimg.cn/a7e417b2719348729b4229071e4d3f4f.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Ly85a-S6Iul5pqW,size_20,color_FFFFFF,t_70,g_se,x_16)

执行流程

1. 获取当前线程, 根据当前线程获取一个Map
2. 如果获取的Map不为空，则在Map中以ThreadLocal的引用作为key来在Map中获取对应的Entrye，否则转到4
3. 如果e不为null，则返回e.value，否则转到4
4. Map为空或者e为空，则通过initialValue函数获取初始值value(=null)，然后用ThreadLocal的引用和value作为firstKey和firstValue创建一个新的Map
   

### remove方法

源码及相关注释

```java
/**
     * 删除当前线程中保存的ThreadLocal对应的实体entry
     */
     public void remove() {
        // 获取当前线程对象中维护的ThreadLocalMap对象
         ThreadLocalMap m = getMap(Thread.currentThread());
        // 如果此map存在
         if (m != null)
            // 存在则调用map.remove
            // 以当前ThreadLocal为key删除对应的实体entry
             m.remove(this);
     }
```

执行流程

1. 首先获取当前线程，并根据当前线程获取一个Map
2. 如果获取的Map不为空，则移除当前ThreadLocal对象对应的entry

### initialValue方法

此方法的作用是返回该线程局部变量的初始值
这个方法是一个延迟调用方法，从上面的代码我们得知，在set方法还未调用而先调用了get方法时才执行，并且仅执行1次
这个方法缺省实现直接返回一个null
如果想要一个除null之外的初始值，可以重写此方法。（备注： 该方法是一个protected的方法，显然是为了让子类覆盖而设计的）
源码及相关注释

```java
/**
  * 返回当前线程对应的ThreadLocal的初始值
  * 此方法的第一次调用发生在，当线程通过get方法访问此线程的ThreadLocal值时
  * 除非线程先调用了set方法，在这种情况下，initialValue 才不会被这个线程调用。
  * 通常情况下，每个线程最多调用一次这个方法。
  *
  * <p>这个方法仅仅简单的返回null {@code null};
  * 如果想ThreadLocal线程局部变量有一个除null以外的初始值，
  * 必须通过子类继承{@code ThreadLocal} 的方式去重写此方法
  * 通常, 可以通过匿名内部类的方式实现
  *
  * @return 当前ThreadLocal的初始值
  */
protected T initialValue() {
    return null;
}
```

## ThreadLocalMap 解析

### 内部结构

- ThreadLocalMap是ThreadLocal的内部类，没有实现Map接口，用独立的方式实现了Map的功能，其内部的Entry也是独立实现的，而Entry又是ThreadLocalMap的内部类，且集成弱引用(WeakReference)类。
- 成员变量
  

```java
			/**
         * The entries in this hash map extend WeakReference, using
         * its main ref field as the key (which is always a
         * ThreadLocal object).  Note that null keys (i.e. entry.get()
         * == null) mean that the key is no longer referenced, so the
         * entry can be expunged from table.  Such entries are referred to
         * as "stale entries" in the code that follows.
         * 
				* Entry继承WeakReference，并且用ThreadLocal作为key.
 				* 如果key为null(entry.get() == null)，意味着key不再被引用，
 				* 因此这时候entry也可以从table中清除。
         */
        static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }

 /**
     * 初始容量 —— 必须是2的整次幂
     *  The initial capacity -- MUST be a power of two.  
     */
    private static final int INITIAL_CAPACITY = 16;

    /**
     * 存放数据的table，Entry类的定义在下面分析
     * 同样，数组长度必须是2的整次幂。
     * The table, resized as necessary.
     * table.length MUST always be a power of two.
     */
    private Entry[] table;

    /**
     * 数组里面entrys的个数，可以用于判断table当前使用量是否超过阈值。
     * The number of entries in the table
     */
    private int size = 0;

    /**
     * 进行扩容的阈值，表使用量大于它的时候进行扩容。
     * The next size value at which to resize
     */
    private int threshold; // Default to 0
```

### 弱引用和内存泄漏

#### 弱引用相关概念

- 强引用（“Strong” Reference），就是我们最常见的普通对象引用，只要还有强引用指向一个对象，就能表明对象还“活着”，垃圾回收器就不会回收这种对象
- 弱引用（WeakReference），垃圾回收器一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存

#### 内存泄漏相关概念

- Memory overflow:内存溢出，没有足够的内存提供申请者使用
- Memory leak: 内存泄漏是指程序中己动态分配的堆内存由于某种原因程序未释放或无法释放，造成系统内存的浪费，导致程序运行速度减慢甚至系统崩溃等严重后果。内存泄漏的堆积终将导致内存溢出

#### 内存泄漏与强弱引用关系

- ThreadLocal 内存结构
  ![在这里插入图片描述](https://img-blog.csdnimg.cn/7476f5b3aec44f20b884e118880925b1.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Ly85a-S6Iul5pqW,size_20,color_FFFFFF,t_70,g_se,x_16)

- **如果key使用强引用**，也就是上图中的红色背景框部分

1. 业务代码中使用完ThreadLocal ，threadLocal Ref被回收了
2. 因为threadLocalMap的Entry强引用了threadLocal，造成threadLocal无法被回收
3. 在没有手动删除这个Entry以及CurrentThread依然运行的前提下，始终有强引用链 threadRef->currentThread->threadLocalMap->entry，Entry就不会被回收（Entry中包括了ThreadLocal实例和value），导致Entry内存泄漏

- **如果key使用弱引用**，也就是上图中的红色背景框部分

1. 业务代码中使用完ThreadLocal ，threadLocal Ref被回收了
2. 由于ThreadLocalMap只持有ThreadLocal的弱引用，没有任何强引用指向threadlocal实例, 所以threadlocal就可以顺利被gc回收，此时Entry中的key=null
3. 但是在没有手动删除这个Entry以及CurrentThread依然运行的前提下，也存在有强引用链 threadRef->currentThread->threadLocalMap->entry -> value ，value不会被回收， 而这块value永远不会被访问到了，导致value内存泄漏

- 出现内存泄漏的真实原因

1. 没有手动删除对应的Entry节点信息
2. ThreadLocal 对象使用完后，对应线程仍然在运行

- 避免内存泄漏的的两种方式

1. 使用完ThreadLocal，调用其remove方法删除对应的Entry

2. 使用完ThreadLocal，当前Thread也随之运行结束

   对于第一种方式很好控制，调用对应remove()方法即可，但是对于第二种方式，我们是很难控制的，正因为不好控制，这也是为什么ThreadLocalMap 里对应的Entry对象继承弱引用的原因，因为使用了弱引用，当ThreadLocal 使用完后，key的引用就会为null，而在调用ThreadLocal 中的get()/set()方法时，当判断key为null时会将value置为null，这就就会在jvm下次GC时将对应的Entry对象回收，从而避免内存泄漏问题的出现。

## hash冲突问题及解决方法

首先从ThreadLocal的set() 方法入手

```java
public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocal.ThreadLocalMap map = getMap(t);
        if (map != null)
            //调用了ThreadLocalMap的set方法
            map.set(this, value);
        else
            createMap(t, value);
    }
    
    ThreadLocal.ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }

    void createMap(Thread t, T firstValue) {
        	//调用了ThreadLocalMap的构造方法
        t.threadLocals = new ThreadLocal.ThreadLocalMap(this, firstValue);
    }
```

- 构造方法`ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue)`

```java
 /*
  * firstKey : 本ThreadLocal实例(this)
  * firstValue ： 要保存的线程本地变量
  */
ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
        //初始化table
        table = new ThreadLocal.ThreadLocalMap.Entry[INITIAL_CAPACITY];
        //计算索引(重点代码）
        int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
        //设置值
        table[i] = new ThreadLocal.ThreadLocalMap.Entry(firstKey, firstValue);
        size = 1;
        //设置阈值
        setThreshold(INITIAL_CAPACITY);
    }
```

造函数首先创建一个长度为16的Entry数组，然后计算出firstKey对应的索引，然后存储到table中，并设置size和threshold

- **分析：int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1)**

1. 关于：firstKey.threadLocalHashCode

```java
private final int threadLocalHashCode = nextHashCode();
    
    private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }
//AtomicInteger是一个提供原子操作的Integer类，通过线程安全的方式操作加减,适合高并发情况下的使用
    private static AtomicInteger nextHashCode =  new AtomicInteger();
     //特殊的hash值
    private static final int HASH_INCREMENT = 0x61c88647;

```

这里定义了一个AtomicInteger类型，每次获取当前值并加上HASH_INCREMENT，HASH_INCREMENT = 0x61c88647,这个值跟斐波那契数列（黄金分割数）有关，其主要目的就是为了让哈希码能均匀的分布在2的n次方的数组里, 也就是Entry[] table中，这样做可以尽量避免hash冲突

2. 关于：& (INITIAL_CAPACITY - 1)

**计算hash的时候里面采用了hashCode & (size - 1)的算法，这相当于==取模运算（取余数）==hashCode % size的一个更高效的实现。**正是因为这种算法，我们要求size必须是2的整次幂，这也能保证在索引不越界的前提下，使得hash发生冲突的次数减小
ThreadLocalMap中的set方法

```java
private void set(ThreadLocal<?> key, Object value) {
        ThreadLocal.ThreadLocalMap.Entry[] tab = table;
        int len = tab.length;
        //计算索引(重点代码，刚才分析过了）
        int i = key.threadLocalHashCode & (len-1);
        /**
         * 使用线性探测法查找元素（重点代码）
         */
        for (ThreadLocal.ThreadLocalMap.Entry e = tab[i];
             e != null;
             e = tab[i = nextIndex(i, len)]) {
            ThreadLocal<?> k = e.get();
            //ThreadLocal 对应的 key 存在，直接覆盖之前的值
            if (k == key) {
                e.value = value;
                return;
            }
            // key为 null，但是值不为 null，说明之前的 ThreadLocal 对象已经被回收了，
           // 当前数组中的 Entry 是一个陈旧（stale）的元素
            if (k == null) {
                //用新元素替换陈旧的元素，这个方法进行了不少的垃圾清理动作，防止内存泄漏
                replaceStaleEntry(key, value, i);
                return;
            }
        }
    
    	//ThreadLocal对应的key不存在并且没有找到陈旧的元素，则在空元素的位置创建一个新的Entry。
            tab[i] = new Entry(key, value);
            int sz = ++size;
            /**
             * cleanSomeSlots用于清除那些e.get()==null的元素，
             * 这种数据key关联的对象已经被回收，所以这个Entry(table[index])可以被置null。
             * 如果没有清除任何entry,并且当前使用量达到了负载因子所定义(长度的2/3)，那么进行				 * rehash（执行一次全表的扫描清理工作）
             */
            if (!cleanSomeSlots(i, sz) && sz >= threshold)
                rehash();
}

 /**
     * 获取环形数组的下一个索引
     */
    private static int nextIndex(int i, int len) {
        return ((i + 1 < len) ? i + 1 : 0);
    }
```

代码执行流程：

1. 首先还是根据key计算出索引 i，然后查找i位置上的Entry
2. 若是Entry已经存在并且key等于传入的key，那么这时候直接给这个Entry赋新的value值
3. 若是Entry存在，但是key为null，则调用replaceStaleEntry来更换这个key为空的Entry
4. 不断循环检测，直到遇到为null的地方，这时候要是还没在循环过程中return，那么就在这个null的位置新建一个Entry，并且插入，同时size增加1
5. 最后调用cleanSomeSlots，清理key为null的Entry，最后返回是否清理了Entry，接下来再判断sz 是否>= thresgold达到了rehash的条件，达到的话就会调用rehash函数执行一次全表的扫描清理
   


- 分析 ： ThreadLocalMap使用线性探测法来解决哈希冲突的

1. 该方法一次探测下一个地址，直到有空的地址后插入，若整个空间都找不到空余的地址，则产生溢出
2. 假设当前table长度为16，也就是说如果计算出来key的hash值为14，如果table[14]上已经有值，并且其key与当前key不一致，那么就发生了hash冲突，这个时候将14加1得到15，取table[15]进行判断，这个时候如果还是冲突会回到0，取table[0],以此类推，直到可以插入
3. 可以把Entry[] table看成一个环形数组





# [threadlocal中的hash](https://blog.csdn.net/zhangyingjie09/article/details/103101436)

threadlocal的内存分布如下图所示。

![img](https://img-blog.csdnimg.cn/20191117150732555.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5neWluZ2ppZTA5,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/20191117150452795.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5neWluZ2ppZTA5,size_16,color_FFFFFF,t_70)

每一个线程都有一个threadlocalmap(如上图所示)，threadlocalmap在threadlocal类中定义。threadlocalmap没有继承map而是自己写了一套类似map的容器。threadlocalmap中存放的是一个数组，名字叫table，table中放着一个个的Entry,Entry是以key-value的方式存储。key是threadlocal，value是线程内具体的值。

```java
 static class Entry extends WeakReference<ThreadLocal<?>> {
     Object value;
 
     Entry(ThreadLocal<?> k, Object v) {
         super(k);
         value = v;
     }
}
```

问：怎么确定key的存放位置呢？也就是threadlocal在table中的存放位置？

看源码不难发现，是通过 int i = key.threadLocalHashCode & (len-1)方法获得的，这里采用的斐波那契散列方法。

（注：[从 ThreadLocal 的实现看散列算法](https://blog.csdn.net/y4x5M0nivSrJaY3X92c/article/details/81124944)，这篇文章讲的特别棒，严重推荐）

简单说一下为什么用斐波那契散列方法呢？就是为了让存进去的值更加离散，为什么要让存进去的值，更加离散呢？目的是为了能更快找到存储位置，通过魔法值和AtomicIntger的getAndAdd方法得到nextHashCode再与table的长度做与操作

threadLocalHashCode方法最终调用的是nextHashCode()方法。而nextHashCode()方法如下面代码所示调用的是getAndAdd，这个方法的作用是让当前线程的nextHashCode这个值与魔法值HASH_INCREMENT相加。每调用一次加一次魔法值。也就是线程中每添加一个threadlocal，类静态属性AtomicInteger 类型的nextHashCode值就会增加一个HASH_INCREMENT。

魔法值：

ThreadLocal 中使用了斐波那契散列法，来保证哈希表的离散度。而它选用的乘数值即是2^32 * 黄金分割比。

private static final int HASH_INCREMENT = 0x61c88647;

![img](https://img-blog.csdnimg.cn/20191118093512489.png)


当thread的threadlocalmap的大小为16时，每添加一个threadlocal，在原来nextHashCode的基础上增加魔法值再与threadlocalmap的len-1做&操作后得到的如下所示的threadlocal在table中的索引。当扩容到32的时候时候每次得到的值就如下面所展示的顺序了

```
16：0 7 14 5 12 3 10 1 8 15 6 13 4 11 2 9 
32：0 7 14 21 28 3 10 17 24 31 6 13 20 27 2 9 16 23 30 5 12 19 26 1 8 15 22 29 4 11 18 25 
64：0 7 14 21 28 35 42 49 56 63 6 13 20 27 34 41 48 55 62 5 12 19 26 33 40 47 54 61 4 11 18 25 32 39 46 53 60 3 10 17 24 31 38 45 52 59 2 9 16 23 30 37 44 51 58 1 8 15 22 29 36 43 50 57 
```


采用不同位数的jvm，魔法值也不一样。如下所示

```java
private static AtomicInteger nextHashCode = new AtomicInteger();
private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }
```


最后发现通过调用AtomicInteger类的getAndAdd方法来得到位置的。

每一个threadlocal都有AtomicInteger类型的nextHashCode用于存放本threadlocal的哈希值。有个这个值之后再与table的长度进行与操作，获得threadlocal在table数组中的位置。

## 斐波那契散列法：

元素特征转变为数组下标的方法就是散列法。斐波那契散列法是常用的一种方法。

斐波那契散列法：让乘数乘上一个与它的位数相对应的斐波那契数，再进行散列。下图就是我们根据位数常用的斐波那契数。

![img](https://img-blog.csdnimg.cn/20191118111213544.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5neWluZ2ppZTA5,size_16,color_FFFFFF,t_70)

为什么叫斐波那契散列法呢？

因为这个斐波那契数的值与0.618相关，也就是上图所示的关系，那么0.618与斐波那契有什么关系呢？

斐波那契通过兔子的繁殖规律，发现了斐波那契数列，而斐波那契数列的前一项与后一项之比，随着数值的增大无线接近黄金分割比例(0.618)：

斐波那契数列又称黄金分割数列：1 1 2 3 5 8 13 21 34  55 89 144 233  ……

1÷1=1，1÷2=0.5，2÷3=0.666...，3÷5=0.6，5÷8=0.625…………，55÷89=0.617977……………144÷233=0.618025…46368÷75025=0.6180339886…...

黄金分割比例：在线段上取一个点将线段分成一长一短的两部分，长部分/总长=短部分/长部分，这个比例就是0.618

总之因为用到了黄金分割比例值，所以叫斐波那契散列法。

## 解决哈希冲突

有了上面的理解，刚开始的时候认为，每添加一个threadlocal，都会产生一个新的值，数组中被占用的位置达到某个比例后会自动扩容，怎么存在冲突呢？后来再次看源码发现是会冲突的。

当向table不断添加threadlocal，因为threadlocal是弱引用，所以可能被回收，因为没有达到扩容的标准，所以当计算出最后的位置为索引9后，再添加的时候就要向索引0位置添加，但是有可能索引0位置的threadlocal没有被回收，所以就出现了哈希冲突。这个时候就需要向下循环，看索引为1的位置是否有值，如果没有添加，如果有继续循环知道找到空的位置为止。这个方法叫开放地址法。





# [哈希表（散列表）原理详解](https://blog.csdn.net/duan19920101/article/details/51579136)

## 什么是哈希表？

   哈希表（Hash table，也叫散列表），是根据关键码值(Key value)而直接进行访问的数据结构。也就是说，它通过把关键码值映射到表中一个位置来访问记录，以加快查找的速度。这个映射函数叫做散列函数，存放记录的数组叫做散列表。

记录的存储位置=f(关键字)

这里的对应关系f称为散列函数，又称为哈希（Hash函数），采用散列技术将记录存储在一块连续的存储空间中，这块连续存储空间称为散列表或哈希表（Hash table）。

哈希表hashtable(key，value) 就是把Key通过一个固定的算法函数既所谓的哈希函数转换成一个整型数字，然后就将该数字对数组长度进行取余，取余结果就当作数组的下标，将value存储在以该数字为下标的数组空间里。（或者：把任意长度的输入（又叫做预映射， pre-image），通过散列算法，变换成固定长度的输出，该输出就是散列值。这种转换是一种压缩映射，也就是，散列值的空间通常远小于输入的空间，不同的输入可能会散列成相同的输出，而不可能从散列值来唯一的确定输入值。简单的说就是一种将任意长度的消息压缩到某一固定长度的消息摘要的函数。）
    而当使用哈希表进行查询的时候，就是再次使用哈希函数将key转换为对应的数组下标，并定位到该空间获取value，如此一来，就可以充分利用到数组的定位性能进行数据定位。

 

**数组的特点是：寻址容易，插入和删除困难；**

**而链表的特点是：寻址困难，插入和删除容易。**

那么我们能不能综合两者的特性，做出一种寻址容易，插入删除也容易的数据结构？答案是肯定的，这就是我们要提起的哈希表，哈希表有多种不同的实现方法，我接下来解释的是最常用的一种方法——**拉链法**，我们可以理解为“链表的数组”，如图：

![img](https://img-blog.csdn.net/20160603152626346?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)


左边很明显是个数组，数组的每个成员包括一个指针，指向一个链表的头，当然这个链表可能为空，也可能元素很多。我们**根据元素的一些特征把元素分配到不同的链表中去，也是根据这些特征，找到正确的链表，再从链表中找出这个元素。**

 

##  Hash的应用

1、Hash主要用于信息安全领域中加密算法，它把一些不同长度的信息转化成杂乱的128位的编码,这些编码值叫做Hash值. 也可以说，Hash就是找到一种数据内容和数据存放地址之间的映射关系。

2、查找：哈希表，又称为散列，是一种更加快捷的查找技术。我们之前的查找，都是这样一种思路：集合中拿出来一个元素，看看是否与我们要找的相等，如果不等，缩小范围，继续查找。而哈希表是完全另外一种思路：当我知道key值以后，我就可以直接计算出这个元素在集合中的位置，根本不需要一次又一次的查找！

举一个例子，假如我的数组A中，第i个元素里面装的key就是i，那么数字3肯定是在第3个位置，数字10肯定是在第10个位置。哈希表就是利用利用这种基本的思想，建立一个从key到位置的函数，然后进行直接计算查找。

3、**Hash表在海量数据处理中有着广泛应用。**

 

**Hash Table的查询速度非常的快，几乎是O(1)的时间复杂度。**

**hash就是找到一种数据内容和数据存放地址之间的映射关系。**

**散列法：元素特征转变为数组下标的方法。**

我想大家都在想一个很严重的问题：“如果两个字符串在哈希表中对应的位置相同怎么办？”,毕竟一个数组容量是有限的，这种可能性很大。解决该问题的方法很多，我首先想到的就是用“链表”。我遇到的很多算法都可以转化成链表来解决，只要在哈希表的每个入口挂一个链表，保存所有对应的字符串就OK了。

**散列表的查找步骤** 
当存储记录时，通过散列函数计算出记录的散列地址
当查找记录时，我们通过同样的是散列函数计算记录的散列地址，并按此散列地址访问该记录


关键字——散列函数（哈希函数）——散列地址

**优点**：一对一的查找效率很高；

**缺点**：一个关键字可能对应多个散列地址；需要查找一个范围时，效果不好。

散列冲突：不同的关键字经过散列函数的计算得到了相同的散列地址。

好的散列函数=计算简单+分布均匀（计算得到的散列地址分布均匀）

**哈希表是种数据结构，它可以提供快速的插入操作和查找操作。**

 

## 优缺点

优点：不论哈希表中有多少数据，查找、插入、删除（有时包括删除）只需要接近常量的时间即0(1）的时间级。实际上，这只需要几条机器指令。

哈希表运算得非常快，在计算机程序中，如果需要在一秒种内查找上千条记录通常使用哈希表（例如拼写检查器)哈希表的速度明显比树快，树的操作通常需要O(N)的时间级。哈希表不仅速度快，编程实现也相对容易。

**如果不需要有序遍历数据，并且可以提前预测数据量的大小。那么哈希表在速度和易用性方面是无与伦比的。**

**缺点：它是基于数组的，数组创建后难于扩展，某些哈希表被基本填满时，性能下降得非常严重，**所以程序员必须要清楚表中将要存储多少数据（或者准备好定期地把数据转移到更大的哈希表中，这是个费时的过程）。

##  散列法 

元素特征转变为数组下标的方法就是散列法。散列法当然不止一种，下面列出三种比较常用的：

### 1. 除法散列法 

最直观的一种，上图使用的就是这种散列法，公式： 
      index = value % 16 
学过汇编的都知道，求模数其实是通过一个除法运算得到的，所以叫“除法散列法”。

### 2. 平方散列法 

求index是非常频繁的操作，而乘法的运算要比除法来得省时（对现在的CPU来说，估计我们感觉不出来），所以我们考虑把除法换成乘法和一个位移操作。公式： 
      index = (value * value) >> 28   （右移，除以2^28。记法：左移变大，是乘。右移变小，是除。）
如果数值分配比较均匀的话这种方法能得到不错的结果，但我上面画的那个图的各个元素的值算出来的index都是0——非常失败。也许你还有个问题，value如果很大，value * value不会溢出吗？答案是会的，但我们这个乘法不关心溢出，因为我们根本不是为了获取相乘结果，而是为了获取index。

### 3. 斐波那契（Fibonacci）散列法

平方散列法的缺点是显而易见的，所以我们能不能找出一个理想的乘数，而不是拿value本身当作乘数呢？答案是肯定的。

1，对于16位整数而言，这个乘数是40503 
2，对于32位整数而言，这个乘数是2654435769 
3，对于64位整数而言，这个乘数是11400714819323198485

这几个“理想乘数”是如何得出来的呢？这跟一个法则有关，叫黄金分割法则，而描述黄金分割法则的最经典表达式无疑就是著名的斐波那契数列，即如此形式的序列：0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233,377, 610， 987, 1597, 2584, 4181, 6765, 10946，…。另外，斐波那契数列的值和太阳系八大行星的轨道半径的比例出奇吻合。

对我们常见的32位整数而言，公式： 
        index = (value * 2654435769) >> 28

如果用这种斐波那契散列法的话，那上面的图就变成这样了：

![img](https://img-blog.csdn.net/20160603152646248?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)


注：用斐波那契散列法调整之后会比原来的取摸散列法好很多。 

适用范围
    快速查找，删除的基本数据结构，通常需要总数据量可以放入内存。

基本原理及要点
    hash函数选择，针对字符串，整数，排列，具体相应的hash方法。 
碰撞处理，一种是open hashing，也称为拉链法；另一种就是closed hashing，也称开地址法，opened addressing。

 

## 散列冲突的解决方案：

1.建立一个缓冲区，把凡是拼音重复的人放到缓冲区中。当我通过名字查找人时，发现找的不对，就在缓冲区里找。

2.进行再探测。就是在其他地方查找。探测的方法也可以有很多种。

（1）在找到查找位置的index的index-1，index+1位置查找，index-2，index+2查找，依次类推。这种方法称为线性再探测。

（2）在查找位置index周围随机的查找。称为随机在探测。

（3）再哈希。就是当冲突时，采用另外一种映射方式来查找。

这个程序中是通过取模来模拟查找到重复元素的过程。对待重复元素的方法就是再哈希：对当前key的位置+7。最后，可以通过全局变量来判断需要查找多少次。我这里通过依次查找26个英文字母的小写计算的出了总的查找次数。显然，当总的查找次数/查找的总元素数越接近1时，哈希表更接近于一一映射的函数，查找的效率更高。

 

## 扩展 

​    d-left hashing中的d是多个的意思，我们先简化这个问题，看一看2-left hashing。2-left hashing指的是将一个哈希表分成长度相等的两半，分别叫做T1和T2，给T1和T2分别配备一个哈希函数，h1和h2。在存储一个新的key时，同 时用两个哈希函数进行计算，得出两个地址h1[key]和h2[key]。这时需要检查T1中的h1[key]位置和T2中的h2[key]位置，哪一个 位置已经存储的（有碰撞的）key比较多，然后将新key存储在负载少的位置。如果两边一样多，比如两个位置都为空或者都存储了一个key，就把新key 存储在左边的T1子表中，2-left也由此而来。在查找一个key时，必须进行两次hash，同时查找两个位置。

 

问题实例（海量数据处理） 
    我们知道hash 表在海量数据处理中有着广泛的应用，下面，请看另一道百度面试题：
题目：海量日志数据，提取出某日访问百度次数最多的那个IP。
方案：IP的数目还是有限的，最多2^32个，所以可以考虑使用hash将ip直接存入内存，然后进行统计。





# [从 ThreadLocal 的实现看散列算法](https://blog.csdn.net/y4x5M0nivSrJaY3X92c/article/details/81124944)

**引子**
最近在看 JDK 的 ThreadLocal 源码时，发现了一段有意思的代码，如下所示。

```java
	private final int threadLocalHashCode = nextHashCode();   
	/**    
    * The difference between successively generated hash codes - turns    
    * implicit sequential thread-local IDs into near-optimally spread    
    * multiplicative hash values for power-of-two-sized tables.    
    */ 
	private static final int HASH_INCREMENT = 0x61c88647 ; 
	/**    
    * Returns the next hash code.    
    */ 
private static int nextHashCode () { return nextHashCode . getAndAdd ( HASH_INCREMENT ); }
```


可以看到，其中定义了一个魔法值 HASH_INCREMENT = 0x61c88647，对于实例变量 threadLocalHashCode，每当创建 ThreadLocal 实例时这个值都会getAndAdd(0x61c88647)。

0x61c88647 转化成二进制即为 1640531527，它常用于在散列中增加哈希值。上面的代码注释中也解释到：**==HASH_INCREMENT 是为了让哈希码能均匀的分布在2的N次方的数组里。==**

那么 0x61c88647 是怎么起作用的呢？

## 什么是散列？

ThreadLocal 使用一个自定的的 Map —— ThreadLocalMap 来维护线程本地的值。首先我们先了解一下散列的概念。

散列（Hash）也称为哈希，就是把任意长度的输入，通过散列算法，变换成固定长度的输出，这个输出值就是散列值。

在实际使用中，不同的输入可能会散列成相同的输出，这时也就产生了冲突。通过上文提到的 HASH_INCREMENT 再借助一定的算法，就可以将哈希码能均匀的分布在 2 的 N 次方的数组里，保证了散列表的离散度，从而降低了冲突几率.

哈希表就是将数据根据散列函数 f(K) 映射到表中的特定位置进行存储。因此哈希表最大的特点就是可以根据 f(K) 函数得到其索引。

> HashMap 就是使用哈希表来存储的，并且采用了链地址法解决冲突。

**简单来说，哈希表的实现就是数组加链表的结合。在每个数组元素上都一个链表结构，当数据被 Hash 后，得到数组下标，把数据放在对应下标元素的链表上。**

## 散列算法

先来说一下散列算法。散列算法的宗旨就是：构造冲突较低的散列地址，保证散列表中数据的离散度。常用的有以下几种散列算法：

### 除法散列法

散列长度 m, 对于一个小于 m 的数 p 取模，所得结果为散列地址。对 p 的选择很重要，一般取素数或 m

公式：f(k) = k % p （p<=m）

因为求模数其实是通过一个除法运算得到的，所以叫“除法散列法”

### 平方散列法（平方取中法）

先通过求关键字的平方值扩大相近数的差别，然后根据表长度取中间的几位数作为散列函数值。又因为一个乘积的中间几位数和乘数的每一位都相关，所以由此产生的散列地址较为均匀。

公式：f(k) = ((k * k) >> X) << Y对于常见的32位整数而言，也就是 f(k) = (k * k) >> 28

### 斐波那契（Fibonacci）散列法

和平方散列法类似，此种方法使用斐波那契数列的值作为乘数而不是自己。

对于 16 位整数而言，这个乘数是 40503。

对于 32 位整数而言，这个乘数是 2654435769。

对于 64 位整数而言，这个乘数是 11400714819323198485。

具体数字是怎么计算得到的下文有介绍。


为什么使用斐波那契数列后散列更均匀，涉及到相关数学问题，此处不做更多解释。

公式：f(k) = ((k * 2654435769) >> X) << Y对于常见的32位整数而言，也就是 f(k) = (k * 2654435769) >> 28

这时我们可以隐隐感觉到 0x61c88647 与斐波那契数列有些关系。

### 随机数法

选择一随机函数，取关键字的随机值作为散列地址，通常用于关键字长度不同的场合。

公式：f(k) = random(k)

### 链地址法（拉链法）

懂了散列算法，我们再来了解下拉链法。拉链法是为了 HashMap 中降低冲突，除了拉链法，还可以使用开放寻址法、再散列法、链地址法、公共溢出区等方法。这里就只简单介绍了拉链法。

把具有相同散列地址的关键字(同义词)值放在同一个单链表中，称为同义词链表。有 m 个散列地址就有 m 个链表，同时用指针数组 T[0..m-1] 存放各个链表的头指针，凡是散列地址为 i 的记录都以结点方式插入到以 T[i] 为指针的单链表中。T 中各分量的初值应为空指针。

对于HashMap：

![640?wx_fmt=png](https://img-blog.csdnimg.cn/img_convert/0f1b4232c29dde7a250e697bc49135b0.png)

除法散列（k=16）：

![640?wx_fmt=jpeg](https://img-blog.csdnimg.cn/img_convert/b2d6c28aa6972f4368065d6ea5702d8f.png)

斐波那契散列：

![640?wx_fmt=jpeg](https://img-blog.csdnimg.cn/img_convert/959945399e636d0295649be2631dd3f0.png)

可以看出用斐波那契散列法调整之后会比原来的除法散列离散度好很多。

## ThreadLocalMap 的散列

认识完了散列，下面回归最初的问题：0x61c88647 是怎么起作用的呢？

先看一下 ThreadLocalMap 中的 set 方法

```java
private void set(ThreadLocal<?> key, Object value) {
    Entry[] tab = table;
    int len = tab.length;
    int i = key.threadLocalHashCode & (len-1);
    ...
}
```

**ThreadLocalMap 中 Entry[] table 的大小必须是 2 的 N 次方（len = 2^N）那 len-1 的二进制表示就是低位连续的 N 个 1， 那key.threadLocalHashCode & (len-1) 的值就是 threadLocalHashCode的低 N 位。**

然后我们通过代码测试一下，0x61c88647 是否能让哈希码能均匀的分布在 2 的 N 次方的数组里。

```java
public class MagicHashCode {
    private static final int HASH_INCREMENT = 0x61c88647;
public static void main(String[] args) {
    hashCode(16); //初始化16
    hashCode(32); //后续2倍扩容
    hashCode(64);
}

private static void hashCode(Integer length){
    int hashCode = 0;
    for(int i=0; i< length; i++){
        hashCode = i * HASH_INCREMENT+HASH_INCREMENT;//每次递增HASH_INCREMENT
        System.out.print(hashCode & (length-1));
        System.out.print(" ");
    }
    System.out.println();
}
}
```
结果：

```
7 14 5 12 3 10 1 8 15 6 13 4 11 2 9 0 
7 14 21 28 3 10 17 24 31 6 13 20 27 2 9 16 23 30 5 12 19 26 1 8 15 22 29 4 11 18 25 0 
7 14 21 28 35 42 49 56 63 6 13 20 27 34 41 48 55 62 5 12 19 26 33 40 47 54 61 4 11 18 25   32 39 46 53 60 3 10 17 24 31 38 45 52 59 2 9 16 23 30 37 44 51 58 1 8 15 22 29 36 43 50   57 0 
```


产生的哈希码分布确实是很均匀，而且没有任何冲突。再看下面一段代码：

```java
public class ThreadHashTest {
    public static void main(String[] args) {
        long l1 = (long) ((1L << 32) * (Math.sqrt(5) - 1)/2);
        System.out.println("as 32 bit unsigned: " + l1);
        int i1 = (int) l1;
        System.out.println("as 32 bit signed:   " + i1);
        System.out.println("MAGIC = " + 0x61c88647);
    }
}
```

结果：

```
as 32 bit unsigned: 2654435769		//10011110001101110111100110111001 无符号原码解释
as 32 bit signed:   -1640531527		//10011110001101110111100110111001 有符号补码解释，换算成原码即1640531527
MAGIC = 1640531527

Process finished with exit code 0
```

| 16进制     | 10进制     | 2进制                            | 补码                             |
| ---------- | ---------- | -------------------------------- | -------------------------------- |
| 0x61c88647 | 1640531527 | 01100001110010001000011001000111 | 10011110001101110111100110111001 |



可以发现 0x61c88647 与一个神奇的数字产生了关系，它就是 (Math.sqrt(5) - 1)/2。也就是传说中的黄金比例 0.618（0.618 只是一个粗略值），即**0x61c88647 = 2^32 * 黄金分割比**。同时也对应上了上文所提到的斐波那契散列法。

## 黄金比例与斐波那契数列

最后再简单介绍一下黄金比例，这个概念我们经常能听到，又称黄金分割点。

黄金分割具有严格的比例性、艺术性、和谐性，蕴藏着丰富的美学价值，而且呈现于不少动物和植物的外观。现今很多工业产品、电子产品、建筑物或艺术品均普遍应用黄金分割，展现其功能性与美观性。

对于斐波那契数列大家应该都很熟悉，也都写过递归实现的斐波那契数列。

斐波那契数列又称兔子数列：

第一个月初有一对兔子

第二个月之后（第三个月初），它们可以生育

每月每对可生育的兔子会诞生下一对新兔子

兔子永不死去

转化成数学公式即：

f(n) = f(n-1) + f(n-2) (n>1)

f(0) = 0

f(1) = 1

当n趋向于无穷大时，前一项与后一项的比值越来越逼近黄金比

最后总结下来看，ThreadLocal 中使用了斐波那契散列法，来保证哈希表的离散度。而它选用的乘数值即是2^32 * 黄金分割比。





# [ThreadLocal.hashCode有多厉害](https://www.modb.pro/db/129961)

上回书说道,`ThreadLocal`
到底哪里好. 最重要的是两点:

1. `ThreadLocalMap`
   被嵌入到了`Thread`
   , 从一个`Thread对象`
   找到他对应的`Map`
   ,不可能有任何手段比这个更快了. 的 Hash 都不行.
2. 内部`ThreadLocalMap`
   以`ThreadLocal对象`
   做`key`
   ,他有一个十分优秀的哈希函数.

第一条好处, 这个面子我们估计是没有,就不分析了.

第二条,这个哈希函数有多好, 上回我说了个不清不楚.估计诸位看官也闹了个糊里糊涂.所以, 这次老 K 准备了一点图, 来继续说道说道.

### ThreadLocal 的 Hash 函数

ThreadLocal 里的 hashCode 写法如下:

```java
public class ThreadLocal<T> {
    private final int threadLocalHashCode = nextHashCode();
    private static AtomicInteger nextHashCode = new AtomicInteger();
    private static final int HASH_INCREMENT = 0x61c88647;
    private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }
```

逐行来解释下.

Java 类中的`静态属性`
,会在`类加载`
时候初始化. 这句会产生一个`AtomicInteger 0`

```java
 private static AtomicInteger nextHashCode =
                             new AtomicInteger();
```

Java 类中的`普通属性`
,会在`new`
的时候初始化. 这句会获取一个`hashCode`

```java
private final int threadLocalHashCode = nextHashCode();
```

`AtomicInteger.getAndIncr`
会返回当前值, 并增加.

```java
private static int nextHashCode() {
   return nextHashCode.getAndAdd(HASH_INCREMENT);
}
```

#### 所有 ThreadLocal 变量的 hashCode 构成一个数列



有点太长了. 这里, 我们用  来代替 ,这个数列可以写作:



#### 通项公式

很明显这是个递增的数列, 通项公式也很简单,

那么, 真的是这样吗? 当然不是,这个是理想中的公式. 但是现实中,Java 的数字是 32 个 bit 表示的有符号数,能表示的最大正数是 , 这个写法会溢出.



真实的公式, 其实相当于 , 最后的结果,强转成(int)类型.

把这个公式容易理解的Java写法写一下..

```java
   for (int i = 0; i < 10; i++) {
      BigDecimal remainder = new BigDecimal(0x61c88647)
                    .multiply(new BigDecimal(i))
                    .remainder(new BigDecimal(1l << 32));
      System.out.println(remainder.intValue());
      System.out.println(0x61c88647*i);
}
```

输出结果

```java
0==0
1640531527==1640531527
-1013904242==-1013904242
626627285==626627285
-2027808484==-2027808484
-387276957==-387276957
1253254570==1253254570
-1401181199==-1401181199
239350328==239350328
1879881855==1879881855
```

####  数列在int空间里的分布

把这个数列,画到32bit能表示的有限数轴上, 是什么样子呢? 请看.

![img](https://oss-emcsprod-public.modb.pro/wechatSpider/modb_20211011_e67867f6-2a6b-11ec-8a44-fa163eb4f6be.png)Java int 数轴上的数列

这个就是`ThreadLocal`
的`hashCode`
数列的可视化. 实现的比较好的`hashCode`
都应该像这样, 在整个`int`
的空间里,较为均匀的分布.

接下来添加几个比较一般的`hashCode`
实现.这里还沿用  的通项公式,但是把常数从`0x61c88647`
加上`1000000,10000000,100000000`
, 并列4个画在一起对比下.

![img](https://oss-emcsprod-public.modb.pro/wechatSpider/modb_20211011_e6946168-2a6b-11ec-8a44-fa163eb4f6be.png)0x61c88647,1000000,10000000,100000000的数列

这张图, 应该能够表现出,对于这个  通项公式来说, 这个值,确实是能够让生成的数列更加均匀.

#### 0x61c88647是怎么求出来的?

这个值的求法要使用一个叫做`三距离定理`
的工具.

![img](https://oss-emcsprod-public.modb.pro/wechatSpider/modb_20211011_e73c590e-2a6b-11ec-8a44-fa163eb4f6be.png)

老K是没本事证明了,不过, 2008年时候, 曾经有一位大学生写了一篇有关这个定理的论文**《三距离定理及其连分数表示》**[1]。这篇论文在知网可以看到，感兴趣怎么证明的可以去下下来看看。

![img](https://oss-emcsprod-public.modb.pro/wechatSpider/modb_20211011_e75d28aa-2a6b-11ec-8a44-fa163eb4f6be.png)三距离定理及其连分数表示

最后可以得到的结论是, 当 或 时候可以做到对  的划分最为均匀.

当这个数值扩大  倍

```java
    BigDecimal divide = new BigDecimal(5).sqrt(MathContext.DECIMAL128).subtract(BigDecimal.ONE).divide(new BigDecimal(2));
        BigDecimal multiply = divide
                .multiply(new BigDecimal(1l << 32));
        System.out.println(multiply.longValue());
        System.out.println(multiply.intValue());
        multiply = divide.negate()
                .multiply(new BigDecimal(1l << 32));
        System.out.println(multiply.longValue());
        System.out.println(multiply.intValue());
```

就可以得到两个神奇的值.

用long表示, 就是上面的. 用int表示,就是下面的.

```java
2654435769
-1640531527
-2654435769
1640531527
```

0x61c88647的出处,其实就是黄金分割率在在32位int数字空间里的一个映射. 如果我们的hashCode是一个short类型的话, 这个神奇的值, 就会变成40503. 如果是long的话是多少, 不妨自己想一想.

好了, 今天就水到这里. 大家早点睡. 这张是上面4个数列跑了一阵子以后的样子.

![img](https://oss-emcsprod-public.modb.pro/wechatSpider/modb_20211011_e7b5717c-2a6b-11ec-8a44-fa163eb4f6be.png)



### 参考资料

[1]

《三距离定理及其连分数表示》: *https://kns.cnki.net/kcms/detail/detail.aspx?dbName=CMFD2010&filename=2009227426.nh*





# **==更详细的斐波那契数列散列法数学原理有待进一步研究！！==**