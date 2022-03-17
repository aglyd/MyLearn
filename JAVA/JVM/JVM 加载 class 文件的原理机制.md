# 一、[描述一下 JVM 加载 class 文件的原理机制？](https://www.cnblogs.com/afei1013/p/12776776.html)

## 1、JVM 简介

　　JVM 是我们Javaer 的最基本功底了，刚开始学Java 的时候，一般都是从“Hello World ”开始的，然后会写个复杂点class ，然后再找一些开源框架，比如Spring ，Hibernate 等等，再然后就开发企业级的应用，比如网站、企业内部应用、实时交易系统等等，直到某一天突然发现做的系统咋就这么慢呢，而且时不时还来个内存溢出什么的，今天是交易系统报了StackOverflowError ，明天是网站系统报了个OutOfMemoryError ，这种错误又很难重现，只有分析Javacore 和dump 文件，运气好点还能分析出个结果，运行遭的点，就直接去庙里烧香吧！每天接客户的电话都是战战兢兢的，生怕再出什么幺蛾子了。我想Java 做的久一点的都有这样的经历，那这些问题的最终根结是在哪呢？—— JVM 。

　　JVM 全称是Java Virtual Machine ，Java 虚拟机，也就是在计算机上再虚拟一个计算机，这和我们使用 VMWare不一样，那个虚拟的东西你是可以看到的，这个JVM 你是看不到的，它存在内存中。我们知道计算机的基本构成是：运算器、控制器、存储器、输入和输出设备，那这个JVM 也是有这成套的元素，运算器是当然是交给硬件CPU 还处理了，只是为了适应“一次编译，随处运行”的情况，需要做一个翻译动作，于是就用了JVM 自己的命令集，这与汇编的命令集有点类似，每一种汇编命令集针对一个系列的CPU ，比如8086 系列的汇编也是可以用在8088 上的，但是就不能跑在8051 上，而JVM 的命令集则是可以到处运行的，因为JVM 做了翻译，根据不同的CPU ，翻译成不同的机器语言。

　　JVM 中我们最需要深入理解的就是它的存储部分，存储？硬盘？NO ，NO ， JVM 是一个内存中的虚拟机，那它的存储就是内存了，我们写的所有类、常量、变量、方法都在内存中，这决定着我们程序运行的是否健壮、是否高效，接下来的部分就是重点介绍之。

[回到顶部](https://www.cnblogs.com/Qian123/p/5707562.html#_labelTop)

## 2、JVM 的组成部分

我们先把JVM 这个虚拟机画出来，如下图所示：

 ![img](JVM 加载 class 文件的原理机制.assets/690102-20160726145503372-1841575655-16470080031653.png)

从这个图中可以看到，JVM 是运行在操作系统之上的，它与硬件没有直接的交互。我们再来看下JVM 有哪些组成部分，如下图所示：

![img](JVM 加载 class 文件的原理机制.assets/690102-20160726145530263-378108880-16470080031655.png)

该图参考了网上广为流传的JVM 构成图，大家看这个图，整个JVM 分为四部分：

**## Class Loader 类加载器** 

类加载器的作用是加载类文件到内存，比如编写一个HelloWord.java 程序，然后通过**javac 编译成class 文件**，那怎么才能**加载到内存中被执行**呢？**Class Loader 承担的就是这个责任**，那不可能随便建立一个.class 文件就能被加载的，Class Loader 加载的class 文件是有格式要求，在《JVM Specification 》中式这样定义Class 文件的结构：

```
  ClassFile {
      u4 magic;
      u2 minor_version;
       u2 major_version;
      u2 constant_pool_count;
      cp_info constant_pool[constant_pool_count-1];
      u2 access_flags;
      u2 this_class;
      u2 super_class;
      u2 interfaces_count;
      u2 interfaces[interfaces_count];
      u2 fields_count;
      field_info fields[fields_count];
      u2 methods_count;
      method_info methods[methods_count];
      u2 attributes_count;
      attribute_info attributes[attributes_count];
    }
```

需要详细了解的话，可以仔细阅读《JVM Specification 》的第四章“The class File Format ”，这里不再详细说明。

友情提示：Class Loader 只管加载，只要符合文件结构就加载，至于说能不能运行，则不是它负责的，那是由Execution Engine 负责的。

**## Execution Engine 执行引擎** 

执行引擎也叫做解释器(Interpreter) ，负责解释命令，提交操作系统执行。

**## Native Interface 本地接口**

本地接口的作用是融合不同的编程语言为Java 所用，它的初衷是融合C/C++ 程序，Java 诞生的时候是C/C++ 横行的时候，要想立足，必须有一个聪明的、睿智的调用C/C++ 程序，于是就在内存中专门开辟了一块区域处理标记为native 的代码，它的具体做法是Native Method Stack 中登记native 方法，在Execution Engine 执行时加载native libraies 。目前该方法使用的是越来越少了，除非是与硬件有关的应用，比如通过Java 程序驱动打印机，或者Java 系统管理生产设备，在企业级应用中已经比较少见，因为现在的异构领域间的通信很发达，比如可以使用Socket 通信，也可以使用Web Service 等等，不多做介绍。

**## Runtime data area 运行数据区** 

运行数据区是整个JVM 的重点。我们所有写的程序都被加载到这里，之后才开始运行，Java 生态系统如此的繁荣，得益于该区域的优良自治。

 

整个JVM 框架由加载器加载文件，然后执行器在内存中处理数据，需要与异构系统交互是可以通过本地接口进行，瞧，一个完整的系统诞生了！

[回到顶部](https://www.cnblogs.com/Qian123/p/5707562.html#_labelTop)

## 3、JVM加载class文件的原理机制 

　　 Java中的所有类，都需要由类加载器装载到JVM中才能运行。类加载器本身也是一个类，而它的工作就是把class文件从硬盘读取到内存中。在写程序的时候，我们几乎不需要关心类的加载，因为这些都是隐式装载的，除非我们有特殊的用法，像是反射，就需要显式的加载所需要的类。

　　类装载方式，有两种 
  　　1.隐式装载， 程序在运行过程中当碰到通过new 等方式生成对象时，隐式调用类装载器加载对应的类到jvm中，
  　　2.显式装载， 通过class.forname()等方法，显式加载需要的类 
 　　隐式加载与显式加载的区别：两者本质是一样? 

   Java类的加载是动态的，它并不会一次性将所有类全部加载后再运行，而是保证程序运行的基础类(像是基类)完全加载到jvm中，至于其他类，则在需要的时候才加载。这当然就是为了节省内存开销。

 　Java的类加载器有三个，对应Java的三种类:（java中的类大致分为三种：  1.系统类  2.扩展类 3.由程序员自定义的类 ）

   Bootstrap Loader // 负责加载**系统类** (指的是内置类，像是String，对应于C#中的System类和C/C++标准库中的类)
      | 
     \- - ExtClassLoader  // 负责加载**扩展类**(就是继承类和实现类)
             | 
           \- - AppClassLoader  // 负责加载应用类(**程序员自定义的类**)

 三个加载器各自完成自己的工作，但它们是如何协调工作呢？哪一个类该由哪个类加载器完成呢？为了解决这个问题，Java采用了委托模型机制。

委托模型机制的工作原理很简单：当类加载器需要加载类的时候，先请示其Parent(即上一层加载器)在其搜索路径载入，如果找不到，才在自己的搜索路径搜索该类。这样的顺序其实就是加载器层次上自顶而下的搜索，因为加载器必须保证基础类的加载。之所以是这种机制，还有一个安全上的考虑：如果某人将一个恶意的基础类加载到jvm，委托模型机制会搜索其父类加载器，显然是不可能找到的，自然就不会将该类加载进来。

   我们可以通过这样的代码来获取类加载器:

```java
ClassLoader loader = ClassName.class.getClassLoader();
ClassLoader ParentLoader = loader.getParent();
```

注意一个很重要的问题，就是Java在逻辑上并不存在BootstrapKLoader的实体！因为它是用C++编写的，所以打印其内容将会得到null。


前面是对类加载器的简单介绍，它的原理机制非常简单，就是下面几个步骤:

1.装载:查找和导入class文件;

2.连接:

   (1)检查:检查载入的class文件数据的正确性;

   (2)准备:为类的静态变量分配存储空间;

   (3)解析:将符号引用转换成直接引用(这一步是可选的)

3.初始化:初始化静态变量，静态代码块。

   这样的过程在程序调用类的静态成员的时候开始执行，所以静态方法main()才会成为一般程序的入口方法。类的构造器也会引发该动作。



----



# 二、[Java中OutOfMemoryError(内存溢出)的三种情况及解决办法](https://blog.csdn.net/z453588/article/details/83743837) 

相信有一定java开发经验的人或多或少都会遇到OutOfMemoryError的问题，这个问题曾困扰了我很长时间，随着解决各类问题经验的积累以及对问题根源的探索，终于有了一个比较深入的认识。
在解决java内存溢出问题之前，需要对jvm（java虚拟机）的内存管理有一定的认识。jvm管理的内存大致包括三种不同类型的内存区域：Permanent Generation space（永久保存区域）、Heap space(堆区域)、Java Stacks(Java栈）。其中永久保存区域主要存放Class（类）和Meta的信息，Class第一次被Load的时候被放入PermGen space区域，Class需要存储的内容主要包括方法和静态属性。堆区域用来存放Class的实例（即对象），对象需要存储的内容主要是非静态属性。每次用new创建一个对象实例后，对象实例存储在堆区域中，这部分空间也被jvm的垃圾回收机制管理。而Java栈跟大多数编程语言包括汇编语言的栈功能相似，主要基本类型变量以及方法的输入输出参数。Java程序的每个线程中都有一个独立的堆栈。容易发生内存溢出问题的内存空间包括：Permanent Generation space和Heap space。

第一种OutOfMemoryError： PermGen space
发生这种问题的原意是程序中使用了大量的jar或class，使java虚拟机装载类的空间不够，与Permanent Generation space有关。解决这类问题有以下两种办法：
1. 增加java虚拟机中的XX:PermSize和XX:MaxPermSize参数的大小，其中XX:PermSize是初始永久保存区域大小，XX:MaxPermSize是最大永久保存区域大小。如针对tomcat6.0，在catalina.sh 或catalina.bat文件中一系列环境变量名说明结束处（大约在70行左右） 增加一行：
JAVA_OPTS=" -XX:PermSize=64M -XX:MaxPermSize=128m"
如果是windows服务器还可以在系统环境变量中设置。感觉用tomcat发布sprint+struts+hibernate架构的程序时很容易发生这种内存溢出错误。使用上述方法，我成功解决了部署ssh项目的tomcat服务器经常宕机的问题。
2. 清理应用程序中web-inf/lib下的jar，如果tomcat部署了多个应用，很多应用都使用了相同的jar，可以将共同的jar移到tomcat共同的lib下，减少类的重复加载。这种方法是网上部分人推荐的，我没试过，但感觉减少不了太大的空间，最靠谱的还是第一种方法。

第二种OutOfMemoryError：  Java heap space
发生这种问题的原因是java虚拟机创建的对象太多，在进行垃圾回收之间，虚拟机分配的到堆内存空间已经用满了，与Heap space有关。解决这类问题有两种思路：
1. 检查程序，看是否有死循环或不必要地重复创建大量对象。找到原因后，修改程序和算法。
我以前写一个使用K-Means文本聚类算法对几万条文本记录（每条记录的特征向量大约10来个）进行文本聚类时，由于程序细节上有问题，就导致了Java heap space的内存溢出问题，后来通过修改程序得到了解决。
2. 增加Java虚拟机中Xms（初始堆大小）和Xmx（最大堆大小）参数的大小。如：set JAVA_OPTS= -Xms256m -Xmx1024m

第三种OutOfMemoryError：unable to create new native thread
这种错误在Java线程个数很多的情况下容易发生，我暂时还没遇到过，发生原意和解决办法可以参考：http://hi.baidu.com/hexiong/blog/item/16dc9e518fb10c2542a75b3c.html



-----



# 三、[如何解决OutOfMemoryError](https://www.jianshu.com/p/3a98a5f3205a)

如果没遇到过OME错误，都不好意思说自己是做Java开发的。

![img](https:////upload-images.jianshu.io/upload_images/426671-68096794d6596a07.png?imageMogr2/auto-orient/strip|imageView2/2/w/519/format/webp)

JVM

最近更新文章的速度很慢，懒，另外我对时间的分配不太擅长，事情一旦多起来，就很容易焦头烂额，效率也变低，看起来一天忙忙碌碌，最后发现处理的事情并不多。但是在不多的事情中，每天其实在程序开发上都会遇到一些值得分享的事情，如果一直没有动笔记录，很多事情都慢慢的忘记了。所以不管怎么忙，我想还是把工作中遇到技术上的问题，拿出来分享给大家，帮大家少踩坑。也是自己工作的一次记录。

### OME的发生

OutOfMemoryError异常可以说是一个比较棘手的问题，Java中所有的对象都存储在堆中，通常如果JVM无法再分配新的内存，内存耗尽，垃圾回收无法及时回收内存，就会抛出OutOfMemoryError。

我这次遇到的OME错误如图：



![img](https:////upload-images.jianshu.io/upload_images/426671-524b11d4a99e7103.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

image.png

报错误的原因是因为: 执行垃圾收集的时间比例太大, 有效的运算量太小. 默认情况下, 如果GC花费的时间超过 98%, 并且GC回收的内存少于 2%, JVM就会抛出这个错误。

### 解决方案

都是自己写的程序，报这个错误，自己心里能没有点数吗，我里面写了一个大对象，实例化之后会不断的加载网络数据到内存中，并且我没有销毁这个对象，继续使用这个对象，同时设置了线程一直让此对象进行等待。

然后我修改大对象在使用之后指向null。压力就没这么大了。

### JVM内存区域

可能对JVM了解的不够清晰，下面再整理下JVM的一些常用知识点。

JVM的自动内存管理可以归结为两个问题：

- 给对象分配内存
- 回收分配的内存

经常变动堆内存区域为：新生代(Eden)，存活区(Survivor)，老年代(Old)
 Perm Gen：为持久带，主要存放Java类的类信息，与垃圾收集要收集的Java对象关系
 不大。
 Code Cache：主要存放代码缓存，它主要用于存放JIT所编译的代码，JIT编译器是在程序运行期间，将Java字节码编译成平台相关的二进制代码。正因为此编译行为发生在程序运行期间，所以该编译器被称为Just-In-Time编译器。JIT主要编译的是热点代码。



![img](https:////upload-images.jianshu.io/upload_images/426671-5a44a2ce0293c83f.png?imageMogr2/auto-orient/strip|imageView2/2/w/560/format/webp)

内存区域图

关键点：

- 大多数情况下，对象在新生代Eden区中分配，Eden区域不够的时候，虚拟机发动一次Minor GC，对象在发生Minor GC后仍能存活，那么对象将被移动到Suvivor空间中，每经过一次Minor GC，对象的年龄增加1岁，增加到一定的年龄(默认15岁)，就会晋升到老年代Old Gen。
- 大对象是指需要连续内存空间的Java对象，典型的大对象是那种很长的字符串及数组。大对象对内存分配来说就是一个坏消息。 像爬虫爬取的整个页面，分配成字符串就是占用内存很多的字符串。
- 在发生MinorGC之前，虚拟机会先检查老年代的最大可用连续空间十分大于新生代的所有对象空间，如果成了，那么Minor GC就是安全的。如果不是，那么检查HandlePromotionFailure是否允许担保失败，如果允许，那么检查老年代的最大可用空间是否大于之前晋升到老年代对象的平均大小，如果大于那么也尝试进行一次Minor GC。 如果小于，或者HandlePromotionFailure设置为不允许冒险，那么改成进行一次Minor GC。

两张Jconsole的JVM图：

![img](https:////upload-images.jianshu.io/upload_images/426671-f60836f19441c077.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

image.png

![img](https:////upload-images.jianshu.io/upload_images/426671-118ac050109e53f2.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

image.png

### 常见的JVM设置参数

可以在命令行直接查看可以设置的参数：



![img](https:////upload-images.jianshu.io/upload_images/426671-5f0ecb791b8e01e1.png?imageMogr2/auto-orient/strip|imageView2/2/w/900/format/webp)

java



![img](https:////upload-images.jianshu.io/upload_images/426671-9630ca9d1e7ecbb0.png?imageMogr2/auto-orient/strip|imageView2/2/w/1086/format/webp)

java -X



![img](https:////upload-images.jianshu.io/upload_images/426671-fea52c87c99a4c25.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

java -XX:+PrintFlagsFinal

-XX:NewRatio：年轻代(包括Eden和两个Survivor区)与年老代的比值(除去持久代)
 -XX:SurvivorRatio：Eden区与Survivor区的大小比值
 -XX:+DisableExplicitGC 关闭System.gc()
 -XX:MaxTenuringThread 对象在Suvivor区域中的年龄到达多少进入Old Gen
 -XX:PretenureSizeThreshold 另大于这个设置值的对象直接在老年代分配，避免Eden区和Suvivor区域之间大量的内存分配

这篇文章里面也列举了不少参数：
 https://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html



-----

# 四、[JVM系列三:JVM参数设置、分析](https://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html)

 不管是YGC还是Full GC,GC过程中都会对导致程序运行中中断,正确的选择[不同的GC策略](http://www.cnblogs.com/redcreen/archive/2011/05/04/2037029.html),调整JVM、GC的参数，可以极大的减少由于GC工作，而导致的程序运行中断方面的问题，进而适当的提高Java程序的工作效率。但是调整GC是以个极为复杂的过程，由于各个程序具备不同的特点，如：web和GUI程序就有很大区别（Web可以适当的停顿，但GUI停顿是客户无法接受的），而且由于跑在各个机器上的配置不同（主要cup个数，内存不同），所以使用的GC种类也会不同(如何选择见[GC种类及如何选择](http://www.cnblogs.com/redcreen/archive/2011/05/04/2037029.html))。本文将注重介绍JVM、GC的一些重要参数的设置来提高系统的性能。

​    JVM内存组成及GC相关内容请见之前的文章:[JVM内存组成](http://www.cnblogs.com/redcreen/archive/2011/05/04/2036387.html) [GC策略&内存申请](http://www.cnblogs.com/redcreen/archive/2011/05/04/2037056.html)。

## **JVM参数的含义** 实例见[实例分析](http://www.cnblogs.com/redcreen/archive/2011/05/05/2038331.html)

| **参数名称**                | **含义**                                                   | **默认值**           |                                                              |
| --------------------------- | ---------------------------------------------------------- | -------------------- | ------------------------------------------------------------ |
| -Xms                        | 初始堆大小                                                 | 物理内存的1/64(<1GB) | 默认(MinHeapFreeRatio参数可以调整)空余堆内存小于40%时，JVM就会增大堆直到-Xmx的最大限制. |
| -Xmx                        | 最大堆大小                                                 | 物理内存的1/4(<1GB)  | 默认(MaxHeapFreeRatio参数可以调整)空余堆内存大于70%时，JVM会减少堆直到 -Xms的最小限制 |
| -Xmn                        | 年轻代大小(1.4or lator)                                    |                      | **注意**：此处的大小是（eden+ 2 survivor space).与jmap -heap中显示的New gen是不同的。 整个堆大小=年轻代大小 + 年老代大小 + 持久代大小. 增大年轻代后,将会减小年老代大小.此值对系统性能影响较大,Sun官方推荐配置为整个堆的3/8 |
| -XX:NewSize                 | 设置年轻代大小(for 1.3/1.4)                                |                      |                                                              |
| -XX:MaxNewSize              | 年轻代最大值(for 1.3/1.4)                                  |                      |                                                              |
| -XX:PermSize                | 设置持久代(perm gen)初始值                                 | 物理内存的1/64       |                                                              |
| -XX:MaxPermSize             | 设置持久代最大值                                           | 物理内存的1/4        |                                                              |
| -Xss                        | 每个线程的堆栈大小                                         |                      | JDK5.0以后每个线程堆栈大小为1M,以前每个线程堆栈大小为256K.更具应用的线程所需内存大小进行 调整.在相同物理内存下,减小这个值能生成更多的线程.但是操作系统对一个进程内的线程数还是有限制的,不能无限生成,经验值在3000~5000左右 一般小的应用， 如果栈不是很深， 应该是128k够用的 大的应用建议使用256k。这个选项对性能影响比较大，需要严格的测试。（校长） 和threadstacksize选项解释很类似,官方文档似乎没有解释,在论坛中有这样一句话:"” -Xss is translated in a VM flag named ThreadStackSize” 一般设置这个值就可以了。 |
| -*XX:ThreadStackSize*       | Thread Stack Size                                          |                      | (0 means use default stack size) [Sparc: 512; Solaris x86: 320 (was 256 prior in 5.0 and earlier); Sparc 64 bit: 1024; Linux amd64: 1024 (was 0 in 5.0 and earlier); all others 0.] |
| -XX:NewRatio                | 年轻代(包括Eden和两个Survivor区)与年老代的比值(除去持久代) |                      | -XX:NewRatio=4表示年轻代与年老代所占比值为1:4,年轻代占整个堆栈的1/5 Xms=Xmx并且设置了Xmn的情况下，该参数不需要进行设置。 |
| -XX:SurvivorRatio           | Eden区与Survivor区的大小比值                               |                      | 设置为8,则两个Survivor区与一个Eden区的比值为2:8,一个Survivor区占整个年轻代的1/10 |
| -XX:LargePageSizeInBytes    | 内存页的大小不可设置过大， 会影响Perm的大小                |                      | =128m                                                        |
| -XX:+UseFastAccessorMethods | 原始类型的快速优化                                         |                      |                                                              |
| -XX:+DisableExplicitGC      | 关闭System.gc()                                            |                      | 这个参数需要严格的测试                                       |
| -XX:MaxTenuringThreshold    | 垃圾最大年龄                                               |                      | 如果设置为0的话,则年轻代对象不经过Survivor区,直接进入年老代. 对于年老代比较多的应用,可以提高效率.如果将此值设置为一个较大值,则年轻代对象会在Survivor区进行多次复制,这样可以增加对象再年轻代的存活 时间,增加在年轻代即被回收的概率 该参数只有在串行GC时才有效. |
| -XX:+AggressiveOpts         | 加快编译                                                   |                      |                                                              |
| -XX:+UseBiasedLocking       | 锁机制的性能改善                                           |                      |                                                              |
| -Xnoclassgc                 | 禁用垃圾回收                                               |                      |                                                              |
| -XX:SoftRefLRUPolicyMSPerMB | 每兆堆空闲空间中SoftReference的存活时间                    | 1s                   | softly reachable objects will remain alive for some amount of time after the last time they were referenced. The default value is one second of lifetime per free megabyte in the heap |
| -XX:PretenureSizeThreshold  | 对象超过多大是直接在旧生代分配                             | 0                    | 单位字节 新生代采用Parallel Scavenge GC时无效 另一种直接在旧生代分配的情况是大的数组对象,且数组中无外部引用对象. |
| -XX:TLABWasteTargetPercent  | TLAB占eden区的百分比                                       | 1%                   |                                                              |
| -XX:+*CollectGen0First*     | FullGC时是否先YGC                                          | false                |                                                              |

## **并行收集器相关参数**

| -XX:+UseParallelGC          | Full GC采用parallel MSC (此项待验证)              |      | 选择垃圾收集器为并行收集器.此配置仅对年轻代有效.即上述配置下,年轻代使用并发收集,而年老代仍旧使用串行收集.(此项待验证) |
| --------------------------- | ------------------------------------------------- | ---- | ------------------------------------------------------------ |
| -XX:+UseParNewGC            | 设置年轻代为并行收集                              |      | 可与CMS收集同时使用 JDK5.0以上,JVM会根据系统配置自行设置,所以无需再设置此值 |
| -XX:ParallelGCThreads       | 并行收集器的线程数                                |      | 此值最好配置与处理器数目相等 同样适用于CMS                   |
| -XX:+UseParallelOldGC       | 年老代垃圾收集方式为并行收集(Parallel Compacting) |      | 这个是JAVA 6出现的参数选项                                   |
| -XX:MaxGCPauseMillis        | 每次年轻代垃圾回收的最长时间(最大暂停时间)        |      | 如果无法满足此时间,JVM会自动调整年轻代大小,以满足此值.       |
| -XX:+UseAdaptiveSizePolicy  | 自动选择年轻代区大小和相应的Survivor区比例        |      | 设置此选项后,并行收集器会自动选择年轻代区大小和相应的Survivor区比例,以达到目标系统规定的最低相应时间或者收集频率等,此值建议使用并行收集器时,一直打开. |
| -XX:GCTimeRatio             | 设置垃圾回收时间占程序运行时间的百分比            |      | 公式为1/(1+n)                                                |
| -XX:+*ScavengeBeforeFullGC* | Full GC前调用YGC                                  | true | Do young generation GC prior to a full GC. (Introduced in 1.4.1.) |

## **CMS相关参数**

| -XX:+UseConcMarkSweepGC                | 使用CMS内存收集                           |      | 测试中配置这个以后,-XX:NewRatio=4的配置失效了,原因不明.所以,此时年轻代大小最好用-Xmn设置.??? |
| -------------------------------------- | ----------------------------------------- | ---- | ------------------------------------------------------------ |
| -XX:+AggressiveHeap                    |                                           |      | 试图是使用大量的物理内存 长时间大内存使用的优化，能检查计算资源（内存， 处理器数量） 至少需要256MB内存 大量的CPU／内存， （在1.4.1在4CPU的机器上已经显示有提升） |
| -XX:CMSFullGCsBeforeCompaction         | 多少次后进行内存压缩                      |      | 由于并发收集器不对内存空间进行压缩,整理,所以运行一段时间以后会产生"碎片",使得运行效率降低.此值设置运行多少次GC以后对内存空间进行压缩,整理. |
| -XX:+CMSParallelRemarkEnabled          | 降低标记停顿                              |      |                                                              |
| -XX+UseCMSCompactAtFullCollection      | 在FULL GC的时候， 对年老代的压缩          |      | CMS是不会移动内存的， 因此， 这个非常容易产生碎片， 导致内存不够用， 因此， 内存的压缩这个时候就会被启用。 增加这个参数是个好习惯。 可能会影响性能,但是可以消除碎片 |
| -XX:+UseCMSInitiatingOccupancyOnly     | 使用手动定义初始化定义开始CMS收集         |      | 禁止hostspot自行触发CMS GC                                   |
| -XX:CMSInitiatingOccupancyFraction=70  | 使用cms作为垃圾回收 使用70％后开始CMS收集 | 92   | 为了保证不出现promotion failed(见下面介绍)错误,该值的设置需要满足以下公式**[CMSInitiatingOccupancyFraction计算公式](https://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html#CMSInitiatingOccupancyFraction_value)** |
| -XX:CMSInitiatingPermOccupancyFraction | 设置Perm Gen使用到达多少比率时触发        | 92   |                                                              |
| -XX:+CMSIncrementalMode                | 设置为增量模式                            |      | 用于单CPU情况                                                |
| -XX:+CMSClassUnloadingEnabled          |                                           |      |                                                              |

## **辅助信息**

| -XX:+PrintGC                          |                                                          |      | 输出形式:[GC 118250K->113543K(130112K), 0.0094143 secs] [Full GC 121376K->10414K(130112K), 0.0650971 secs] |
| ------------------------------------- | -------------------------------------------------------- | ---- | ------------------------------------------------------------ |
| -XX:+PrintGCDetails                   |                                                          |      | 输出形式:[GC [DefNew: 8614K->781K(9088K), 0.0123035 secs] 118250K->113543K(130112K), 0.0124633 secs] [GC [DefNew: 8614K->8614K(9088K), 0.0000665 secs][Tenured: 112761K->10414K(121024K), 0.0433488 secs] 121376K->10414K(130112K), 0.0436268 secs] |
| -XX:+PrintGCTimeStamps                |                                                          |      |                                                              |
| -XX:+PrintGC:PrintGCTimeStamps        |                                                          |      | 可与-XX:+PrintGC -XX:+PrintGCDetails混合使用 输出形式:11.851: [GC 98328K->93620K(130112K), 0.0082960 secs] |
| -XX:+PrintGCApplicationStoppedTime    | 打印垃圾回收期间程序暂停的时间.可与上面混合使用          |      | 输出形式:Total time for which application threads were stopped: 0.0468229 seconds |
| -XX:+PrintGCApplicationConcurrentTime | 打印每次垃圾回收前,程序未中断的执行时间.可与上面混合使用 |      | 输出形式:Application time: 0.5291524 seconds                 |
| -XX:+PrintHeapAtGC                    | 打印GC前后的详细堆栈信息                                 |      |                                                              |
| -Xloggc:filename                      | 把相关日志信息记录到文件以便分析. 与上面几个配合使用     |      |                                                              |
| -XX:+PrintClassHistogram              | garbage collects before printing the histogram.          |      |                                                              |
| -XX:+PrintTLAB                        | 查看TLAB空间的使用情况                                   |      |                                                              |
| XX:+PrintTenuringDistribution         | 查看每次minor GC后新的存活周期的阈值                     |      | Desired survivor size 1048576 bytes, new threshold 7 (max 15) new threshold 7即标识新的存活周期的阈值为7。 |

## **GC性能方面的考虑**

​    对于GC的性能主要有2个方面的指标：吞吐量throughput（工作时间不算gc的时间占总的时间比）和暂停pause（gc发生时app对外显示的无法响应）。

\1. Total Heap

​    默认情况下，vm会增加/减少heap大小以维持free space在整个vm中占的比例，这个比例由MinHeapFreeRatio和MaxHeapFreeRatio指定。

一般而言，server端的app会有以下规则：

- 对vm分配尽可能多的memory；
- 将Xms和Xmx设为一样的值。如果虚拟机启动时设置使用的内存比较小，这个时候又需要初始化很多对象，虚拟机就必须重复地增加内存。
- 处理器核数增加，内存也跟着增大。

\2. The Young Generation

​    另外一个对于app流畅性运行影响的因素是young generation的大小。young generation越大，minor collection越少；但是在固定heap size情况下，更大的young generation就意味着小的tenured generation，就意味着更多的major collection(major collection会引发minor collection)。

​    NewRatio反映的是young和tenured generation的大小比例。NewSize和MaxNewSize反映的是young generation大小的下限和上限，将这两个值设为一样就固定了young generation的大小（同Xms和Xmx设为一样）。

​    如果希望，SurvivorRatio也可以优化survivor的大小，不过这对于性能的影响不是很大。SurvivorRatio是eden和survior大小比例。

一般而言，server端的app会有以下规则：

- 首先决定能分配给vm的最大的heap size，然后设定最佳的young generation的大小；
- 如果heap size固定后，增加young generation的大小意味着减小tenured generation大小。让tenured generation在任何时候够大，能够容纳所有live的data（留10%-20%的空余）。

## **经验&&规则**

1. 年轻代大小选择
   - 响应时间优先的应用:尽可能设大,直到接近系统的最低响应时间限制(根据实际情况选择).在此种情况下,年轻代收集发生的频率也是最小的.同时,减少到达年老代的对象.
   - 吞吐量优先的应用:尽可能的设置大,可能到达Gbit的程度.因为对响应时间没有要求,垃圾收集可以并行进行,一般适合8CPU以上的应用.
   - 避免设置过小.当新生代设置过小时会导致:1.YGC次数更加频繁 2.可能导致YGC对象直接进入旧生代,如果此时旧生代满了,会触发FGC.
2. 年老代大小选择
   1. 响应时间优先的应用:年老代使用并发收集器,所以其大小需要小心设置,一般要考虑并发会话率和会话持续时间等一些参数.如果堆设置小了,可以会造成内存碎 片,高回收频率以及应用暂停而使用传统的标记清除方式;如果堆大了,则需要较长的收集时间.最优化的方案,一般需要参考以下数据获得:
      并发垃圾收集信息、持久代并发收集次数、传统GC信息、花在年轻代和年老代回收上的时间比例。
   2. 吞吐量优先的应用:一般吞吐量优先的应用都有一个很大的年轻代和一个较小的年老代.原因是,这样可以尽可能回收掉大部分短期对象,减少中期的对象,而年老代尽存放长期存活对象.
3. 较小堆引起的碎片问题
   因为年老代的并发收集器使用标记,清除算法,所以不会对堆进行压缩.当收集器回收时,他会把相邻的空间进行合并,这样可以分配给较大的对象.但是,当堆空间较小时,运行一段时间以后,就会出现"碎片",如果并发收集器找不到足够的空间,那么并发收集器将会停止,然后使用传统的标记,清除方式进行回收.如果出现"碎片",可能需要进行如下配置:
   -XX:+UseCMSCompactAtFullCollection:使用并发收集器时,开启对年老代的压缩.
   -XX:CMSFullGCsBeforeCompaction=0:上面配置开启的情况下,这里设置多少次Full GC后,对年老代进行压缩
4. 用64位操作系统，Linux下64位的jdk比32位jdk要慢一些，但是吃得内存更多，吞吐量更大
5. XMX和XMS设置一样大，MaxPermSize和MinPermSize设置一样大，这样可以减轻伸缩堆大小带来的压力
6. 使用CMS的好处是用尽量少的新生代，经验值是128M－256M， 然后老生代利用CMS并行收集， 这样能保证系统低延迟的吞吐效率。 实际上cms的收集停顿时间非常的短，2G的内存， 大约20－80ms的应用程序停顿时间
7. 系统停顿的时候可能是GC的问题也可能是程序的问题，多用jmap和jstack查看，或者killall -3 java，然后查看java控制台日志，能看出很多问题。(相关工具的使用方法将在后面的blog中介绍)
8. 仔细了解自己的应用，如果用了缓存，那么年老代应该大一些，缓存的HashMap不应该无限制长，建议采用LRU算法的Map做缓存，LRUMap的最大长度也要根据实际情况设定。
9. 采用并发回收时，年轻代小一点，年老代要大，因为年老大用的是并发回收，即使时间长点也不会影响其他程序继续运行，网站不会停顿
10. JVM参数的设置(特别是 –Xmx –Xms –Xmn -XX:SurvivorRatio -XX:MaxTenuringThreshold等参数的设置没有一个固定的公式，需要根据PV old区实际数据 YGC次数等多方面来衡量。为了避免promotion faild可能会导致xmn设置偏小，也意味着YGC的次数会增多，处理并发访问的能力下降等问题。每个参数的调整都需要经过详细的性能测试，才能找到特定应用的最佳配置。

**promotion failed:**

垃圾回收时promotion failed是个很头痛的问题，一般可能是两种原因产生，第一个原因是救助空间不够，救助空间里的对象还不应该被移动到年老代，但年轻代又有很多对象需要放入救助空间；第二个原因是年老代没有足够的空间接纳来自年轻代的对象；这两种情况都会转向Full GC，网站停顿时间较长。

解决方方案一：

*第一个原因我的最终解决办法是去掉救助空间，设置-XX:SurvivorRatio=65536 -XX:MaxTenuringThreshold=0即可，第二个原因我的解决办法是设置CMSInitiatingOccupancyFraction为某个值（假设70），这样年老代空间到70%时就开始执行CMS，年老代有足够的空间接纳来自年轻代的对象。*

解决方案一的改进方案：

*又有改进了，上面方法不太好，因为没有用到救助空间，所以年老代容易满，CMS执行会比较频繁。我改善了一下，还是用救助空间，但是把救助空间加大，这样也不会有promotion failed。具体操作上，32位Linux和64位Linux好像不一样，64位系统似乎只要配置MaxTenuringThreshold参数，CMS还是有暂停。为了解决暂停问题和promotion failed问题，最后我设置-XX:SurvivorRatio=1 ，并把MaxTenuringThreshold去掉，这样即没有暂停又不会有promotoin failed，而且更重要的是，年老代和永久代上升非常慢（因为好多对象到不了年老代就被回收了），所以CMS执行频率非常低，好几个小时才执行一次，这样，服务器都不用重启了。*

-Xmx4000M -Xms4000M -Xmn600M -XX:PermSize=500M -XX:MaxPermSize=500M -Xss256K -XX:+DisableExplicitGC -XX:SurvivorRatio=1 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:LargePageSizeInBytes=128M -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC -Xloggc:log/gc.log

 

**CMSInitiatingOccupancyFraction值与Xmn的关系公式**

上面介绍了promontion faild产生的原因是EDEN空间不足的情况下将EDEN与From survivor中的存活对象存入To survivor区时,To survivor区的空间不足，再次晋升到old gen区，而old gen区内存也不够的情况下产生了promontion faild从而导致full gc.那可以推断出：eden+from survivor < old gen区剩余内存时，不会出现promontion faild的情况，即：
(Xmx-Xmn)*(1-CMSInitiatingOccupancyFraction/100)>=(Xmn-Xmn/(SurvivorRatior+2)) 进而推断出：

CMSInitiatingOccupancyFraction <=((Xmx-Xmn)-(Xmn-Xmn/(SurvivorRatior+2)))/(Xmx-Xmn)*100

例如：

当xmx=128 xmn=36 SurvivorRatior=1时 CMSInitiatingOccupancyFraction<=((128.0-36)-(36-36/(1+2)))/(128-36)*100 =73.913

当xmx=128 xmn=24 SurvivorRatior=1时 CMSInitiatingOccupancyFraction<=((128.0-24)-(24-24/(1+2)))/(128-24)*100=84.615…

当xmx=3000 xmn=600 SurvivorRatior=1时 CMSInitiatingOccupancyFraction<=((3000.0-600)-(600-600/(1+2)))/(3000-600)*100=83.33

CMSInitiatingOccupancyFraction低于70% 需要调整xmn或SurvivorRatior值。

令：

[网上一童鞋](http://bbs.weblogicfans.net/archiver/tid-2835.html)推断出的公式是：:(Xmx-Xmn)*(100-CMSInitiatingOccupancyFraction)/100>=Xmn 这个公式个人认为不是很严谨，在内存小的时候会影响xmn的计算。

 

关于实际环境的GC参数配置见:[实例分析](http://www.cnblogs.com/redcreen/archive/2011/05/05/2038331.html)  [监测工具见JVM监测](http://www.cnblogs.com/redcreen/archive/2011/05/09/2040977.html)

参考：

JAVA HOTSPOT VM（http://www.helloying.com/blog/archives/164）

[JVM 几个重要的参数](http://www.iteye.com/wiki/jvm/2870-JVM) (校长)

[java jvm 参数 -Xms -Xmx -Xmn -Xss 调优总结](http://hi.baidu.com/sdausea/blog/item/c599ef13fcd3a7dbf6039e12.html)

[Java HotSpot VM Options](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html)

http://bbs.weblogicfans.net/archiver/tid-2835.html

[Frequently Asked Questions About the Java HotSpot VM](http://www.oracle.com/technetwork/java/hotspotfaq-138619.html)

[Java SE HotSpot at a Glance](http://www.oracle.com/technetwork/java/javase/tech/index-jsp-136373.html)

[Java性能调优笔记](http://blog.csdn.net/yang_net/archive/2010/08/22/5830820.aspx)(内附测试例子 很有用)

[说说MaxTenuringThreshold这个参数](http://blog.bluedavy.com/?p=70)

 

相关文章推荐:

[GC调优方法总结](http://blog.csdn.net/pigeon21/archive/2011/01/27/6166217.aspx)

[Java 6 JVM参数选项大全（中文版）](http://kenwublog.com/docs/java6-jvm-options-chinese-edition.htm)