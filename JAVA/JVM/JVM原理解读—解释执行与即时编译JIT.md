# [JVM原理解读——即时编译](https://blog.csdn.net/weixin_39841589/article/details/112597193)

## 1、解释执行（只翻译部分字节码为机器码）

编译器（javac）将源文件（.java）编译成java字节码文件（.class）的步骤是前端编译。在前端编译将字节码放入JVM后，每次执行方法调用时，JVM都会将该方法的字节码翻译成机器码并执行的过程叫解释执行

**解释执行没有在启动时将字节码全部翻译成机器码，所以启动效率较高**

**但是由于执行时要进行翻译，所以执行效率相对较低**

## 2、编译执行（翻译全部字节码为机器码）

与解释执行相反，**JVM直接将第一次编译后的字节码转换为机器码，在执行方法调用时直接执行机器码**，这样的过程叫**编译执行**

**编译执行在启动时将字节码全部翻译成机器码，所以启动效率较低**

**但是执行时省去了翻译的步骤，所以执行效率相对较高（但是相对的内存占用就会很高，且容易造成内存浪费）**

## 3、即时编译

为了平衡启动和执行的效率，JVM结合解释执行和编译执行的特点，**进行解释执行（第一次加载时先使用解释器直接执行，保留高启动效率）并对热点代码进行编译优化（只翻译热点代码为机器码节省内存）**，这样的执行过程叫即时编译

### 3.1、即时编译器

JVM包含多个即时编译器，主要有C1和C2，还有个Graal是实验性的。他们都会对字节码进行优化并生成机器码

C1会对字节码进行简单可靠的优化，包括方法内联、去虚拟化、冗余消除等，编译速度较快，可以通过-client强制指定C1编译

C2会对字节码进行激进优化，包括分支频率预测、同步擦除等，可以通过-server强制指定C2编译

### 3.2、分层编译模式

JVM不会直接启用C2，而是先通过C1编译收集程序的运行状态，再根据分析结果判断是否启用C2。分层编译模式下的虚拟机执行状态由简到繁、由快到慢分为5层

1. 解释执行
2. 执行不带profile的C1编译的代码
3. 执行仅带有方法调用次数和循环执行次数的profile的C1编译的代码
4. 执行带所有类型profile的C1编译的代码
5. 执行C2编译的代码

### 3.3、profiling

profiling是C1在编译过程中收集程序执行状态的过程

收集的执行状态记录为profile，包括分支跳转频率、是否出现过空值和异常等，主要用于触发C2编译

### 3.4、C2触发时机

当方法调用次数profile或循环次数profile达到阈值时，会触发即时编译

阈值不仅需要通过-XX:TierXInvocationThreshold、-XX:TierXMINInvocationThreshold和-XX:TierXCompileThreshold设置，还跟待编译方法的数目和编译线程的总数有关。

编译线程的数量是处理器动态指定的，参数为-XX:+CICompilerCountPerCPU默认开启，可以通过-XX:+CICompilerCount=N强制指定编译线程总数。JVM会将这些线程以1:2的比例分配给C1和C2

### 3.5、去优化

去优化是当C2编译的机器码假设失败时，将即时编译切换回解释执行的过程

在C2编译生成机器码时，会在假设失败的一端设置一条指令。当假设失败时，调用指令让JVM将栈帧的方法返回地址从机器码所在的本地内存地址改回运行时常量池中的方法地址，并进行解释执行

## 4、方法内联

在即时编译方法时，将目标方法的方法体取代方法调用的过程叫方法内联，增加了编译的代码量，但是降低了方法调用带来的入栈出栈的成本

### 4.1、静态方法内联

即时编译器会根据方法调用层数，目标方法的调用次数及字节码大小等决定该方法是否允许被内联

-XX:CompileCommand配置中的inline指令指定的方法会被强制内联，dontinline和exclude指定的方法始终不会被内联
@ForceInline注解的jdk内部方法会被强制内联，@DontInline注解jdk内部方法始终不会被内联
方法的符号引用未被解析、目标方法所在类未被初始化、目标方法是native方法，都会导致方法无法内联
C2默认不支持9层以上的方法调用（-XX:MaxInlineLevel），以及1层的直接递归调用（-XX:MaxRecursiveInlineLevel）
自动拆箱总会被内联，Throwable类的方法不能被其他类内联等

### 4.2、动态方法内联

即时编译器需要将动态绑定的虚方法转化为直接调用，才能进行方法内联，这样的过程叫虚方法的去虚化

根据字节码生成的IR图确定调用者类型的过程叫基于类型推导的完全去虚化
根据JVM中已加载的类找到接口的唯一实现的过程叫基于类层次分析的完全去虚化
根据编译时收集的类型profile，依次匹配方法调用者的动态类型与profile中的类型

## 5、逃逸分析

当方法内部定义的对象被外部代码引用时，称为该对象逃逸，JVM对对象的分析过程叫逃逸分析

根据逃逸分析，即时编译器会在编译过程中对代码做如下优化：

锁消除：当一个锁对象只被一个线程加锁时，即时编译器会把锁去掉
栈上分配：当一个对象没有逃逸时，会将对象直接分配在栈上，随着线程回收，由于JVM的大量代码都是堆分配，所以目前JVM不支持栈上分配，而是采用标量替换
标量替换：当一个对象没有逃逸时，会将当前对象打散成若干局部变量，并分配在虚拟机栈的局部变量表中

## 6、即时编译的其他优化

字段读取优化：缓存多次读取的数据，减少出入栈次数

```
 public String register(User user,String username,String password){
       user.username = username;
       return user.username + password;
   }

   class User{
       private String username;
   }
```

```
public String register(User user,String username){
  			String s = user.username;//user.username被缓存成了s
        s = username;
        return s + password;
    }
```

字段存储优化：将被覆盖的赋值操作优化掉，减少无用的入栈

```
  private void test(){
        int a = 1;
        a = 2;
    }
```

```
  private void test(){
        int a = 2;//a=1被优化掉了
    }
```

循环无关代码外提：避免重复执行表达式，减少出入栈次数

```
  private void test(String s){
          String password;
          for (int i=0;i<10;i++){
              password = s.replaceAll("/","");
            	System.out.println(i);
          }
      }
```

```
private void test(String s){
          String password = s.replaceAll("/","");//与循环无关的代码被编译器外提了
          for (int i=0;i<10;i++){
            	System.out.println(i);
          }
      }
```


循环展开：将相同的循环逻辑多次重复在一次迭代中，以减少循环次数

```
  private void test(int[] arr){
          int sum=0;
          for (int i=0;i<8;i++){
              sum +=arr[i];
          }
      }
```

```
 private void test(int[] arr){
         int sum=0;
         for (int i=0;i<8;i+=2){//循环次数减少
             sum +=arr[i];
             sum +=arr[i+1];//重复循环体内相同逻辑
         }
     }
```


循环的自动向量化：对循环中地址连续的数组操作，会按顺序批量出入栈（这段是伪代码）

```
  private void test(int[] arr1,int[] arr2){
          for (int i=0;i<arr1.length;i++){
              arr1[i] = arr2[i];
          }
      }

```

```
private void test(int[] arr1,int[] arr2){
        for (int i=0;i<arr1.length;i+=4){
            arr1[i:i+4] = arr2[i:i+4];//可以看成是在循环展开的基础上，将多个数组一块出入栈
        }
    }
```



----

# [jvm：即时编译（JIT）](https://blog.csdn.net/weixin_38750084/article/details/83349912)

什么是JIT

1、动态编译（dynamic compilation）指的是“在运行时进行编译”；与之相对的是事前编译（ahead-of-time compilation，简称AOT），也叫静态编译（[static](https://so.csdn.net/so/search?q=static&spm=1001.2101.3001.7020) compilation）。

2、JIT编译（just-in-time compilation）狭义来说是当某段代码即将第一次被执行时进行编译，因而叫“即时编译”。JIT编译是动态编译的一种特例。JIT编译一词后来被泛化，时常与动态编译等价；但要注意广义与狭义的JIT编译所指的区别。
3、自适应动态编译（adaptive dynamic compilation）也是一种动态编译，但它通常执行的时机比JIT编译迟，先让程序“以某种式”先运行起来，收集一些信息之后再做动态编译。这样的编译可以更加优化。

概述

[JVM](https://so.csdn.net/so/search?q=JVM&spm=1001.2101.3001.7020)运行原理

在部分商用虚拟机中（如HotSpot），Java程序最初是通过解释器（Interpreter）进行解释执行的，当虚拟机发现某个方法或代码块的运行特别频繁时，就会把这些代码认定为“热点代码”。为了提高热点代码的执行效率，在运行时，虚拟机将会把这些代码编译成与本地平台相关的机器码，并进行各种层次的优化，完成这个任务的编译器称为即时编译器（Just In Time Compiler，下文统称JIT编译器）。

即时编译器并不是虚拟机必须的部分，Java虚拟机规范并没有规定Java虚拟机内必须要有即时编译器存在，更没有限定或指导即时编译器应该如何去实现。但是，即时编译器编译性能的好坏、代码优化程度的高低却是衡量一款商用虚拟机优秀与否的最关键的指标之一，它也是虚拟机中最核心且最能体现虚拟机技术水平的部分。

由于Java虚拟机规范并没有具体的约束规则去限制即使编译器应该如何实现，所以这部分功能完全是与虚拟机具体实现相关的内容，如无特殊说明，我们提到的编译器、即时编译器都是指Hotspot虚拟机内的即时编译器，虚拟机也是特指HotSpot虚拟机。

为什么HotSpot虚拟机要使用解释器与编译器并存的架构？

尽管并不是所有的Java虚拟机都采用解释器与编译器并存的架构，但许多主流的商用虚拟机（如HotSpot），都同时包含解释器和编译器。解释器与编译器两者各有优势：当程序需要迅速启动和执行的时候，解释器可以首先发挥作用，省去编译的时间，立即执行。在程序运行后，随着时间的推移，编译器逐渐发挥作用，把越来越多的代码编译成本地代码之后，可以获取更高的执行效率。当程序运行环境中内存资源限制较大（如部分嵌入式系统中），可以使用解释器执行节约内存，反之可以使用编译执行来提升效率。此外，如果编译后出现“罕见陷阱”，可以通过逆优化退回到解释执行。

编译的时间开销

解释器的执行，抽象的看是这样的：
输入的代码 -> [ 解释器 解释执行 ] -> 执行结果
而要JIT编译然后再执行的话，抽象的看则是：
输入的代码 -> [ 编译器 编译 ] -> 编译后的代码 -> [ 执行 ] -> 执行结果
说JIT比解释快，其实说的是“执行编译后的代码”比“解释器解释执行”要快，并不是说“编译”这个动作比“解释”这个动作快。
JIT编译再怎么快，至少也比解释执行一次略慢一些，而要得到最后的执行结果还得再经过一个“执行编译后的代码”的过程。
所以，对“只执行一次”的代码而言，解释执行其实总是比JIT编译执行要快。
怎么算是“只执行一次的代码”呢？粗略说，下面两个条件同时满足时就是严格的“只执行一次”
1、只被调用一次，例如类的构造器（class initializer，<clinit>()）
2、没有循环
**对只执行一次的代码做JIT编译再执行，可以说是得不偿失。**
**对只执行少量次数的代码，JIT编译带来的执行速度的提升也未必能抵消掉最初编译带来的开销。**

**只有对频繁执行的代码，JIT编译才能保证有正面的收益。**

编译的空间开销

对一般的Java方法而言，编译后代码的大小相对于字节码的大小，膨胀比达到10x是很正常的。同上面说的时间开销一样，这里的空间开销也是，只有对执行频繁的代码才值得编译，如果把所有代码都编译则会显著增加代码所占空间，导致“代码爆炸”。

这也就解释了为什么有些JVM会选择不总是做JIT编译，而是选择用解释器+JIT编译器的混合执行引擎。
为何HotSpot虚拟机要实现两个不同的即时编译器？

HotSpot虚拟机中内置了两个即时编译器：Client Complier和Server Complier，简称为C1、C2编译器，分别用在客户端和服务端。目前主流的HotSpot虚拟机中默认是采用解释器与其中一个编译器直接配合的方式工作。程序使用哪个编译器，取决于虚拟机运行的模式。HotSpot虚拟机会根据自身版本与宿主机器的硬件性能自动选择运行模式，用户也可以使用“-client”或“-server”参数去强制指定虚拟机运行在Client模式或Server模式。

用Client Complier获取更高的编译速度，用Server Complier 来获取更好的编译质量。为什么提供多个即时编译器与为什么提供多个垃圾收集器类似，都是为了适应不同的应用场景。

哪些程序代码会被编译为本地代码？如何编译为本地代码？

程序中的代码只有是热点代码时，才会编译为本地代码，那么什么是热点代码呢？

运行过程中会被即时编译器编译的“热点代码”有两类：
1、被多次调用的方法。

2、被多次执行的循环体。

两种情况，编译器都是以整个方法作为编译对象。 这种编译方法因为编译发生在方法执行过程之中，因此形象的称之为栈上替换（On Stack Replacement，OSR），即方法栈帧还在栈上，方法就被替换了。

如何判断方法或一段代码或是不是热点代码呢？

要知道方法或一段代码是不是热点代码，是不是需要触发即时编译，需要进行Hot Spot Detection（热点探测）。

目前主要的热点探测方式有以下两种：
（1）基于采样的热点探测
采用这种方法的虚拟机会周期性地检查各个线程的栈顶，如果发现某些方法经常出现在栈顶，那这个方法就是“热点方法”。这种探测方法的好处是实现简单高效，还可以很容易地获取方法调用关系（将调用堆栈展开即可），缺点是很难精确地确认一个方法的热度，容易因为受到线程阻塞或别的外界因素的影响而扰乱热点探测。
(2)基于计数器的热点探测

采用这种方法的虚拟机会为每个方法（甚至是代码块）建立计数器，统计方法的执行次数，如果执行次数超过一定的阀值，就认为它是“热点方法”。这种统计方法实现复杂一些，需要为每个方法建立并维护计数器，而且不能直接获取到方法的调用关系，但是它的统计结果相对更加精确严谨。

HotSpot虚拟机中使用的是哪钟热点检测方式呢？

在HotSpot虚拟机中使用的是第二种——基于计数器的热点探测方法，因此它为每个方法准备了两个计数器：方法调用计数器和回边计数器。在确定虚拟机运行参数的前提下，这两个计数器都有一个确定的阈值，当计数器超过阈值溢出了，就会触发JIT编译。

方法调用计数器

顾名思义，这个计数器用于统计方法被调用的次数。
当一个方法被调用时，会先检查该方法是否存在被JIT编译过的版本，如果存在，则优先使用编译后的本地代码来执行。如果不存在已被编译过的版本，则将此方法的调用计数器值加1，然后判断方法调用计数器与回边计数器值之和是否超过方法调用计数器的阈值。如果超过阈值，那么将会向即时编译器提交一个该方法的代码编译请求。
如果不做任何设置，执行引擎并不会同步等待编译请求完成，而是继续进行解释器按照解释方式执行字节码，直到提交的请求被编译器编译完成。当编译工作完成之后，这个方法的调用入口地址就会系统自动改写成新的，下一次调用该方法时就会使用已编译的版本。

回边计数器

它的作用就是统计一个方法中循环体代码执行的次数，在字节码中遇到控制流向后跳转的指令称为“回边”。


如何编译为本地代码？

Server Compiler和Client Compiler两个编译器的编译过程是不一样的。

对Client Compiler来说，它是一个简单快速的编译器，主要关注点在于局部优化，而放弃许多耗时较长的全局优化手段。

而Server Compiler则是专门面向服务器端的，并为服务端的性能配置特别调整过的编译器，是一个充分优化过的高级编译器。

参考

《深入理解Java虚拟机》

http://blog.csdn.net/u010412719/article/details/47008717

https://zhuanlan.zhihu.com/p/19977592

http://www.zhihu.com/question/37389356/answer/73820511



----

# [【详解】JVM中，编译器和解释器的作用和区别](https://blog.csdn.net/Sunshineoe/article/details/114978448)

二、编译器和解释器之间的区别
Java编译器：将Java源文件，也就是.java文件编译成字节码.class文件（二进制字节码文件），java.exe可以简单的看成是Java编译器。

Java解释器：就是把java虚拟机上运行的.class字节码解释成机器指令，让CPU识别运行。即jdk和jre中bin目录下的java.exe文件。Java解释器用来解释执行Java编译器编译后的.class文件。java.exe可以简单的看成Java的解释器。

简单的说：Java解释器是执行Java编译器编译后的程序。Java编程人员在编写完代码后，通过Java编译器将源代码编译成JVM字节代码。任何一台机器主要配备了Java解释器，就可以运行这个程序。Java的解释器只是一个基于虚拟机JVM平台的程序。解释器像是一个中间人，编译器已经把程序文件打包好，解释器只需要在JVM环境下执行就可以了，期间不需要依赖任何的编译器

![img](https://img-blog.csdnimg.cn/20210318151150678.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1N1bnNoaW5lb2U=,size_16,color_FFFFFF,t_70)

当程序需要首次启动和执行的时候，解释器可以首次发挥作用，一行一行代码的直接转义执行，但是执行效率低下（启动效率高，不需要翻译全部字节码为机器码）。当多次调用方法或者循环体的时候，JIT（即时编译器）就可以发挥作用，**把越来越多的代码编译成本地机器码**，之后可以获得更高的执行效率。

   JIT是即时编译器 – 在执行本机之前，**将给定的字节码指令序列编译为运行时的机器码。以方法为单位，一次性的将整个方法的字节码编译成本地机器码**，机器码供CPU运行。它的主要目的是在性能上做大量的优化。（执行效率提升，保留热点代码的机器码到jvm缓存，不需要Java解释器再翻译一次字节码为机器码了，执行时间时间更短）

   JVM负责运行字节码：**JVM把每一条要执行的字节码交给解释器，翻译成对应的机器码，然后由解释器执行。JVM解释执行字节码文件就是JVM操作Java解释器进行解释执行字节码文件的过程。**

   JVM是一种能够运行Java字节码（Java bytecode）的虚拟机。



-----



# [【JVM】浅谈java编译和执行过程](https://www.jianshu.com/p/a64ff243ce86)

### [【JVM】JAVA大致的编译过程](https://limingxie.github.io/java/compile_java/)

我们先简单的了解一下java编译到执行的过程。
后续我会详细的介绍具体详细的方式。

[图片备用地址](https://limingxie.github.io/images/java/compile/java_simple_complie.png)
![java_complie](https://mingxie-blog.oss-cn-beijing.aliyuncs.com/image/java/compile/java_simple_complie.png)

当我们执行代码的时候是如图所示，执行以下步骤。

1. Java Source(xxx.java file) 文件 通过 javac命令编译。
2. 经过一些验证和编译创建字节码(Byte Code)xxx.class file。.class不是机器语言，所以电脑不能直接识别。
3. 使用java命令执行 xxx.class文件。
4. JVM通过类加载器(class loader)读取xxx.class文件。这时可以读取本地的文件，也有可能通过网络获取文件。
5. Byte Code Verfier 先验证xxx.class文件是否合法。java有比较严谨的安全规则。
6. 解释器(Interpreter)把xxx.class文件转换成可识别的机器码(Binary Code)。
7. Runtime执行。（执行有3种方式: 1.解释执行, 2.JIT编译执行, 3.混合执行。在这里指的是第一种模式。）


 这里稍微再详细点说明其编译和执行过程。

## 1. java代码到执行

java是高级语言(High-level programming language)。
 【**执行**】需【**编译**】成机器语言才能执行，如下所示。



```dart
java代码 => 编译 => 执行
```

其中编译的内容我们需要用【**class loader**】加载到【**JVM(Java Virtual Machine)**】里才能执行。
 把这些过程也加进去的话是如下的过程了。



```dart
java代码 => 编译 => 读取(class loader) => JVM环境 => 执行
```

我们在上面的基础上再详细的了解这些过程。
 Java代码编译以后将会生成【**.class文件**】。(详细的javac编译过程可以参考[【JVM】javac的编译过程](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fjava%2Fjava_javac_compiler%2F))
 类加载器(class loader)读取.class文件到JVM。
 这时【**执行引擎(execution engine)**】把这些文件解析成【**机器码(Binary Code)**】,
 存放到JVM的【**运行数据区Runtime Data Area**】后，执行程序。

这一过程可以如下图标是。

[图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fcompile%2Fjava_compile_execut.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-d0205ed9de199867?imageMogr2/auto-orient/strip|imageView2/2/w/502/format/webp)

java_compile_execut



## 2. 类加载器Class Loader

.java文件编译后生成.class文件。
 类加载器Class Loader的工作就是把.class文件读取到JVM中。
 这过程类加载器Class Loader会做三件事情 1.加载 2.链接 3.初始化

### 2.1 加载Loading

一般情况下类加载器分3层结构。

**2.1.1. 引导(启动)类加载器Bootstrap ClassLoader**

- 最上层类。加载<JAVA_HOME>/jre/lib内容。用Native C编写。

**2.1.2. 扩展类加载器Extension ClassLoader**

- 加载<JAVA_HOME>/jre/lib/ext内容。用Java编写。

**2.1.3. 应用程序类加载器Application ClassLoader**

- 加载 -classpath(或 -cp)的内容。用Java编写。

这3层结构准守一下原则。

> 1. Delegation Principle => 从上到下委派加载任务。
> 2. Visibility Principle => 子类加载可以使用父类加载，相反是不可以。
> 3. Uniqueness Principle => 子类加载时不会再次加载父类加载的内容。

### 2.2 链接Linking

加载完成以后，会做链接Linking。
 链接也分3个步骤进行。

**2.2.1. 验证Verify**

- 确保加载的内容的正确性和安全性。

**2.2.2. 准备Prepare**

- 为类的静态变量分配内存，并设置默认初始值。

**2.2.3. 解析Resolve**

- 将常量池内的符号引用转换为直接引用的过程。

### 2.3 初始化

初始化是为类的静态变量赋予正确的初始值。
 这个初始化不需要定义，是javac编译器自动收集类中的所有类变量的赋值和静态代码。
 有父类先执行父类的初始化方法，再执行子类的初始化方法。

[图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fjvm%2Fclass_loader.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-72f3707089c75a6f?imageMogr2/auto-orient/strip|imageView2/2/w/464/format/webp)

class_loader



## 3.执行引擎Execution Engine

用于执行字节码或者本地方法。
 执行的过程一般会用解释模式和JIT编译模式的混合模式。

[图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fjvm%2Fjava_version.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-328a218e7508ca81.png?imageMogr2/auto-orient/strip|imageView2/2/w/655/format/webp)

java_version



### 3.1 解释器Interpreter

执行引擎会把类加载器读取过来的.class文件的字节码，
 效验合法性和安全性后，边读取边执行。

### 3.2 JIT编译器JIT(just in time) Compiler

**当解释模式运行的代码满足一定的条件以后，会编译到JVM的缓存中。
 下一次执行的时候因为不需要在编译提高执行速度。**

> 如果偶尔执行一次的代码或是只执行一次的话解释模式执行的速度会更快。
>  频繁的调用执行的代码的话，JIT编译模式下第一次执行速度会比较慢，后续会提高执行速度。
>  大部分情况下都会有混合模式。适用JIT编译模式的条件可以在不同的场景下需要做一些调整。

### 3.3 垃圾回收器Garbage Collector

执行引擎还跟垃圾回收器Garbage Collector有关。
 一般情况下垃圾回收期会回收运行数据区Runtime Data Area的堆内存。
 它会释放栈区里已经用完，找不到相对应地址的堆内存。
 这些内存会分伊甸区，幸存区，老年区... 用一些算法来管理和清理回收内存。
 这些细节会再后续的文章里再做分析讨论~

**其实执行引擎是操控着这些编译和回收器，而不是它们属于执行引擎**   
 [图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fjvm%2Fexecution_engine.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-3ead71e4a842f611.png?imageMogr2/auto-orient/strip|imageView2/2/w/317/format/webp)

execution_engine



## 4. 运行数据区Runtime Data Area

为了执行程序，给JVM分配的内存空间。
 可以分 共享线程区(堆区，方法区，直接内存区）和私有线程区(栈区，程序计数器，本地方法栈)

### 4.1 方法区Method Area

是各个线程共享的内存区域，它用于存储已被JVM加载的
 类class，函数function，常量final variable，静态变量static variable，实例变量member variable
 以及被即时编译器(JIT)编译后的代码都会存放在这里。
 方法区有时被称为持久代（PermGen）。

### 4.2 堆Heap

通过 New 创建的实例instance，队列等引用reference类型，Method Area的class才能声明在这里。
 此内存区域就是存放对象实例，几乎所有的对象实例都在这里分配内存。
 Java堆是垃圾收集器管理的主要区域，因此很多时候也被称做“GC堆”。
 如果从内存回收的角度看，由于现在收集器基本都是采用的分代收集算法，
 所以Java堆中还可以细分为：新生代和老年代；再细致一点的有Eden空间、From Survivor空间、To Survivor空间等。
 如果在堆中没有内存完成实例分配，并且堆也无法再扩展时，将会抛出OutOfMemoryError异常。

[图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fjvm%2Fheap_memory.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-357b0a3a1ef48bba.png?imageMogr2/auto-orient/strip|imageView2/2/w/479/format/webp)

heap_memory



### 4.3 直接内存(堆外内存)Direct Memory

在JDK1.4中新加入了NIO(New INput/Output)类，其实不完全的被JVM所控制。
 它可以使用Native函数库直接分配堆外内存，避免堆和Native堆来回复制数据，提高性能。

### 4.4 栈Stack

它的生命周期与线程相同是一个临时储存空间。
 存变量(boolean、byte、char、short、int、float、long、double)，返回值，
 对象引用类型(指向一条字节码指令的地址，其实体是存在堆Heap区域)
 这些值遵守LIFO(Last In First Out) 当函数执行完成以后会删除掉。

### 4.5 PC寄存器Program Counter Register

每个线程thread都有一个。记录每个线程用哪个指令执行哪部分的内容，存储着现在执行中的JVM命令地址。
 若该方法为native的，则PC寄存器中不存储任何信息。
 Java多线程情况下，每个线程都有一个自己的PC，以便完成不同线程上下文环境的切换。

### 4.6 本地方法栈Native Method Stack

为了调用java以外的其它语言的方法分配的空间。
 java调用C/C++方法是使用的stack领域就是这里。

**其实直接内存不是完全属于JVM的运行数据区Runtime Data Area**  
 [图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fjvm%2Fruntime_data_area.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-772e2a275c12bc3d.png?imageMogr2/auto-orient/strip|imageView2/2/w/1077/format/webp)

runtime_data_area



## 5. JVM(Java Virtual Machine)

把上面的就是全部都结合起来就是JVM的结构了。
 如下图所示:
 [图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fjvm%2Fjava_compile_runtime_detail.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-f7fa8d0bad85c4bb.png?imageMogr2/auto-orient/strip|imageView2/2/w/1143/format/webp)

java_compile_runtime_detail



## 6. 举例说明

一堆理论和概念会让人都晕的...^^;;
 下面举一个例子，简单的说明一下这一过程。



```java
import java.util.ArrayList;
import java.util.List;

public class Prodcut {
    int ID;
    String Code;
    String Name;
    List<String> Tags;

    public List<Prodcut> getProdcuts() {
        int ProductID = 1;
        String ProductCode = "ProductCode";
        Tags = new ArrayList<String>();
        Tags.add("tag1");
        Tags.add("tag2");

        System.out.println("查询商品");
        return null;
    }

    public void insertProdcuts(List<Prodcut> prodcuts) {
        System.out.println("保存商品");
    }
}
```



```kotlin
首先product.java通过java编译成product.class    
然后Class Loader会把product.class和prodcut引用的Class Library加载到JVM环境。  
这时Execution Engine做一些列验证和解析后(混合模式下，第一次不会直接走JIT编译)    
把类信息和方法存放到Runtime Data Area的Method Area里。  

当程序调用方法时，先把变量以及局部变量以及返回值加载到JVM的stack区域，    
之后用New方式声明的实例或排列是存放到Heap区域，stack区域只保存对应的内存地址。  
等方法结束后stack区域的值是跟着方法结束会一起清空，    
但是heap区域的空间是需要等Garbage Collector来回收。  
```

[图片备用地址](https://links.jianshu.com/go?to=https%3A%2F%2Flimingxie.github.io%2Fimages%2Fjava%2Fjvm%2Fjava_code_compile_runtime.png)  

![img](https:////upload-images.jianshu.io/upload_images/10948402-77921ed1ac0a2652.png?imageMogr2/auto-orient/strip|imageView2/2/w/577/format/webp)

java_code_compile_runtime



## 7. 结语

我了解JVM的过程中发现它不可能用一遍文章说清楚。
 只能说是了解了一点皮毛，每一块都有很多内容去了解。
 比如加载程序，垃圾回收，编译过程等等... ...
 后续看看能不能每个模块都深入的去了解一下。



-----

# [JVM详解（二）—— 编译过程](https://blog.csdn.net/X_lsod/article/details/120455149)

## 一、编译过程

> Java 语言的「编译期」其实是一段「不确定」的操作过程。
>
> - 因为它可能是一个**前端编译器**（如 Javac）把 *.java 文件编译成 *.class 文件的过程；
> - 也可能是程序运行期的**即时编译器**（JIT [编译器](https://so.csdn.net/so/search?q=编译器&spm=1001.2101.3001.7020)，Just In Time Compiler）把字节码文件编译成机器码的过程；
> - 还可能是静态提前编译器（AOT 编译器，Ahead Of Time Compiler）直接把 *.java 文件编译成本地机器码的过程。

Javac 这类编译器对代码的运行效率几乎没有任何优化措施，虚拟机设计团队把对性能的优化都放到了后端的**即时编译器**中，这样可以让那些不是由 Javac 产生的 class 文件（如 Groovy、Kotlin 等语言产生的 class 文件）也能享受到编译器优化带来的好处。但是 Javac 做了很多针对 Java 语言编码过程的优化措施来改善程序员的编码风格、提升编码效率。相当多新生的 Java 语法特性，都是靠编译器的**「语法糖」**来实现的，而不是依赖虚拟机的底层改进来支持。

> **语法糖：**
>
> 指计算机语言中添加的某种语法，这种语法对语言的功能并没有影响，但是更方便程序员使用。通常来说使用语法糖能够增加程序的可读性，从而减少程序代码出错的机会。

### 1、早期编译

#### 1.1、Javac编译器

> Javac 编译器的编译过程大致可分为 1个准备过程3个处理过程 ：
>
> - 初始化插入式注解处理器（一个准备）
>
> 1. 解析与填充符号表；
> 2. 插入式注解处理器的注解处理；
> 3. 分析与字节码生成。

这 3 个步骤之间的关系如下图所示：

![img](https://img-blog.csdnimg.cn/img_convert/d421822593c2fffca803a9968dd2102c.png)

##### 1.1.1、解析与填充符号表

> 解析步骤包含了经典程序编译原理中的**词法分析**和**语法分析**两个过程；

> **词法分析**是将源代码的字符流转变为标记（Token）集合的过程，单个字符是程序写时的最小元素，但标记才是编译时的最小元素。关键字、变量名、字面量、运算符都可以作为标记，如“int a=b+2”这句代码中就包含了6个标记，分别是int、a、=、b、+、1虽然关键字int由3个字符构成，但是它只是一个独立的标记，不可以再拆分。

> **语法分析**是根据标记序列构造抽象语法树的过程，抽象语法树是一种用来描述程序代码语法结构的树形表示方式，抽象语法树的每一个节点都代表者程序代码中的一个语法结构。例如包、类型、修饰符、运算符、接口返回值甚至连代码注释等都可以是一种特定的语法结构。

###### **填充符号表**

完成词法分析和语法分析之后，下一步就是填充符号表的过程。符号表是由一组符号地址和符号信息构成的表格。在语义分析中，符号表所登记的内容将用于语义检查和产生中间代码。在目标代码生成阶段，当对符号名进行地址分配时，符号表是地址分配的依据。

##### 1.1.2、注解处理器

**注解（Annotation）**是在 JDK 1.5 中新增的，注解在设计上原本是与普通代码一样，只在运行期间发挥作用。

但是在JDK1.6中，**插入式注解处理器**可以提前至编译期对代码中的特点注解进行处理，从而影响到前端编译器的工作过程。**我们可以把插入式注解处理器看作是一组编译器的插件，当这些插件工作时，允许读取、修改、添加抽象语法树中的任意元素。\**如果这些插件在处理注解期间对语法树进行过修改，编译器将回到解析及填充符号表的过程重新处理，直到所有插入式注解处理器都没有再对语法树进行修改为止，每一次循环过程称为一个轮次（Round），这也就对应着\**上图**的那个回环过程有了编译器注解处理过程。Lombok就是依赖于插入式注解器实现的。

##### 1.1.3、语义分析与[字节码](https://so.csdn.net/so/search?q=字节码&spm=1001.2101.3001.7020)生成

语法分析之后，编译器获得了程序代码的抽象语法树表示，语法树能表示一个结构正确的源程序的抽象，但无法保证源程序是符合逻辑的。而**语义分析的主要任务是对结构上正确的源程序进行上下文有关性质的审查，比如进行类型检查，控制流检查，数据流检查，解语发糖。**

**字节码生成是 Javac 编译过程的最后一个阶段，字节码生成阶段不仅仅是把前面各个步骤所生成的信息（语法树、符号表）转化成字节码写到磁盘中，编译器还进行了少量的代码添加和转换工作。**如前面提到的`<init> ()` 方法和`<clinit>()`方法 就是在这一阶段添加到语法树中的。

在字节码生成阶段，除了生成构造器以外，还有一些其它的代码替换工作用于优化程序的实现逻辑，如把字符串的加操作替换为 StringBiulder 或 StringBuffer。

**完成了对语法树的遍历和调整之后，就会把填充了所需信息的符号表交给 com.sun.tools.javac.jvm.ClassWriter 类，由这个类的 writeClass() 方法输出字节码，最终生成字节码文件**，到此为止整个编译过程就结束了。

#### 1.2、Java语法糖

Java 中提供了有很多语法糖来方便程序开发，虽然语法糖不会提供实质性的功能改进，但是它能提升开发效率、语法的严谨性、减少编码出错的机会。下面我们来了解下语法糖背后我们看不见的东西。

##### 1.2.1、泛型与类型擦除

泛型顾名思义就是类型泛化，本质是参数化类型的应用，也就是说操作的数据类型被指定为一个参数。**这种参数可以用在类、接口和方法的创建中，分别称为泛型类、泛型接口和泛型方法。**

在 Java 语言还没有泛型的时候，只能通过 Object 是所有类型的父类和强制类型转换两个特点的配合来实现类型泛化。例如 HashMap 的 get() 方法返回的就是一个 Object 对象，那么只有程序员和运行期的虚拟机才知道这个 Object 到底是个什么类型的对象。在编译期间，编译器无法检查这个 Object 的强制类型转换是否成功，如果仅仅依赖程序员去保障这项操作的正确性，许多 ClassCastException 的风险就会转嫁到程序运行期。

Java 语言中泛型只在程序源码中存在，在编译后的字节码文件中，就已经替换为原来的原生类型，并且在相应的地方插入了强制类型转换的代码。因此对于运行期的 Java 语言来说， `ArrayList<int>` 与 `ArrayList<String>` 是同一个类型，所以泛型实际上是 Java 语言的一个语法糖，这种泛型的实现方法称为类型擦除。

##### 1.2.2、自动装箱、拆箱与遍历循环

> 简单一点说，装箱就是自动将基本数据类型转换为包装器类型；拆箱就是自动将包装器类型转换为基本数据类型。

自动装箱、拆箱与遍历循环是 Java 语言中用得最多的语法糖。这块比较简单，我们直接看代码：

```java
public class SyntaxSugars {

    public static void main(String[] args){

        List<Integer> list = Arrays.asList(1,2,3,4,5);

        int sum = 0;
        for(int i : list){
            sum += i;
        }
        System.out.println("sum = " + sum);
    }
}
```

自动装箱、拆箱与遍历循环编译之后：

```java
public class SyntaxSugars {

    public static void main(String[] args) {

        List list = Arrays.asList(new Integer[]{
                Integer.valueOf(1),
                Integer.valueOf(2),
                Integer.valueOf(3),
                Integer.valueOf(4),
                Integer.valueOf(5)
        });

        int sum = 0;
        for (Iterator iterable = list.iterator(); iterable.hasNext(); ) {
            int i = ((Integer) iterable.next()).intValue();
            sum += i;
        }
        System.out.println("sum = " + sum);
    }
}
```

第一段代码包含了泛型、自动装箱、自动拆箱、遍历循环和变长参数 5 种语法糖，第二段代码则展示了它们在编译后的变化。

###### 1.2.2.1、例子

看如下例子：包含了自动装箱、拆箱以及foreach循环的过程

```java
public static void main(String[] args) {
    List<Integer> list = Arrays.asList(1, 2, 3, 4);
    // 如果在JDK 1.7中，还有另外一颗语法糖 ，
    // 能让上面这句代码进一步简写成List<Integer> list = [1, 2, 3, 4];
    int sum = 0;
    for (int i : list) {
        sum += i;
    }
    System.out.println(sum);
}
```

上面的程序内部编译后如下：

```java
public static void main(String[] args) {
    List list = Arrays.asList( new Integer[] {
         Integer.valueOf(1),
         Integer.valueOf(2),
         Integer.valueOf(3),
         Integer.valueOf(4) });
         int sum = 0;
         for (Iterator localIterator = list.iterator(); localIterator.hasNext(); ) {
             int i = ((Integer)localIterator.next()).intValue();
             sum += i;
         }
         System.out.println(sum);
}
```

上述代码一共包含了泛型、自动装箱、自动拆箱、遍历循环与变长参数5中语法糖，第二份代码是他们编译后的变化。泛型在编译过程中会进行擦除，将泛型参数去除；自动装箱、拆箱在变之后被转化成了对应的包装盒还原方法，如Integer.valueOf()与Integer.intValue()方法；而遍历循环则被还原成了迭代器的实现，这也是为什么遍历器循环需要被遍历的类实现Iterator接口的原因。

这些语法糖虽然看起来很简单，但也有一些应该注意容易犯错的地方。看如下代码：

```java
public static void main(String[] args) {
    Integer a = 1;
    Integer b = 2;
    Integer c = 3;
    Integer d = 3;
    Integer e = 321;
    Integer f = 321;
    Long g = 3L;
    System.out.println(c == d);	//true
    System.out.println(e == f);	//false
    System.out.println(c == (a + b));	//true
    System.out.println(c.equals(a + b));	//true
    System.out.println(g == (a + b));	//true
    System.out.println(g.equals(a + b));	//false
    String str1 = "hello";
    String str2 = "hello";
    System.out.println(str1 == str2);	//true
}
运行结果：
true
false
true
true
true
false
true
```

首先注意两点：

> - “==”运算在不遇到算术运算的情况下不会自动拆箱
> - equals()方法不处理数据转型的问题。

分析：

为什么会出现c == d为true，e==f为false的原因？First，Integer c = 3这句代码的内部实现是Integer c = Integer.valueOf(3)，那么接下我们看一下Integer.valueOf()的方法内部是如何实现的，如下代码：

```java
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)
        return IntegerCache.cache[i + (-IntegerCache.low)];
    return new Integer(i);
}

static final int low = -128;
static final int high = 127;
```

从上面代码可以知道，在Java运行时内存的常量池里面有一个int类型的常量池，常量池里数据的大小在-128~127之间。所以c和d都指向常量池里的同一个数据。

为什么g == (a + b)为true，而g.equals(a + b)为false？
首先Long.longValue(g) == (a + b)编译后为g.longValue() == (long)(Integer.intValue(a) + Integer.intValue(a))，由于包装类的””右边遇到了运算符，所以对于””左边的Long型会自动拆箱为long基本数据类型，而右边首先对a、b进行自动拆箱，相加后自动类型转换为long型(==数据转型)。所以输出为true。

而对于g.equals(a + b)而言，a+b直接自动拆箱进行相加，之后进行装箱为**Integer**类型，不同类型的包装类不能相互转换，而Long的**equals()方法的不处理数据类型的转型关系**。实现如下：

```java
public boolean equals(Object obj) {
    if (obj instanceof Long) {
        return value == ((Long)obj).longValue();
    }
    return false;
}
```

##### 1.2.3、条件编译

Java 语言中条件编译的实现也是一颗语法糖，根据布尔常量值的真假，编译器会把分支中不成立的代码块消除。

```java
public static void main(String[] args) {
    if (true) {
        System.out.println("block 1");
    } else {
        System.out.println("block 2");
    }
}
```

上述代码经过编译后 class 文件的反编译结果：

```java
public static void main(String[] args) {
    System.out.println("block 1");
}
```

### 2、后端编译与优化

目前主流的两款商用Java虚拟机（Hotspot、Open9）里，Java程序最初都是通过解释器（Interpreter [ɪnˈtɜːprətə®]）进行解释执行的。在javac编译过后产生的字节码Class文件：源码在编译的过程中，进行「词法分析 → 语法分析 → 生成目标代码」等过程，完成生成字节码文件的工作。然后在后面交由解释器）解释执行，省去前面预编译的开销。java.exe可以简单看成是Java解释器。

#### 2.1 HotSpot 虚拟机内的即时编译器

**当虚拟机发现某个方法或者代码块的运行特别频繁时，就会把这些代码认定为「热点代码」**（Hot Spot Code）。为了提高热点代码的执行效率，在运行时，虚拟机将会把这些代码编译成与本地平台相关的机器码，并进行各种层次的优化，完成这个任务的编译器称为**即时编译器（JIT）。**

即时编译器不是虚拟机必须的部分，Java 虚拟机规范并没有规定虚拟机内部必须要有即时编译器存在，更没有限定或指导即时编译器应该如何实现。但是 JIT 编译性能的好坏、代码优化程度的高低却是衡量一款商用虚拟机优秀与否的最关键指标之一。

##### 2.1.1、解释器与编译器

尽管并不是所有的 Java 虚拟机都采用解释器与编译器并存的架构，但许多主流的商用虚拟机，如 HotSpot、J9 等，都同时包含解释器与编译器。

**编译器 [kəmˈpaɪlə®] ：**负责把一种编程语言编写的源码转换成另外一种计算机代码，后者往往是以二进制的形式被称为目标代码(object code)。这个转换的过程通常的目的是生成可执行的程序。编译器，往往是在「执行」之前完成，产出是一种可执行或需要再编译或者解释的「代码」。

**解释器：**它直接执行由编程语言或脚本语言编写的代码，并不会把源代码预编译成机器码。它是把程序源代码一行一行的读懂然后执行，发生在运行时，产物是「运行结果」。

解释器与编译器两者各有优势：

- 当程序需要迅速启动和执行的时候，解释器可以首先发挥作用，省去编译的时间，立即执行。在程序运行后，随着时间的推移，编译器逐渐发挥作用，把越来越多的代码编译成本地机器码之后，可以获得更高的执行效率。
- 当程序运行环境中内存资源限制较大（如部分嵌入式系统），可以使用解释器执行来节约内存，反之可以使用编译执行来提升效率。

同时，解释器还可以作为编译器激进优化时的一个「逃生门」，当编译器根据概率选择一些大多数时候都能提升运行速度的优化手段，当激进优化的假设不成立，如加载了新的类后类型继承结构出现变化、出现「罕见陷阱」时可以通过逆优化退回到解释状态继续执行。

[![image-20200826153023981](https://img-blog.csdnimg.cn/img_convert/5ec387bd874388477ea4ae38b250dff9.png)](http://codeduck.top/md/imagesimage-20200826153023981.png)

##### 2.1.2、编译对象与触发条件

程序在运行过程中会被即时编译器编译的「热点代码」有两类：

- 被多次调用的方法；
- 被多次执行的循环体。

这两种被多次重复执行的代码，称之为「热点代码」。

- 对于被多次调用的方法，方法体内的代码自然会被执行多次，理所当然的就是热点代码。
- 而对于多次执行的循环体则是为了解决一个方法只被调用一次或者少量几次，但是方法体内部存在循环次数较多的循环体问题，这样循环体的代码也被重复执行多次，因此这些代码也是热点代码。

对于第一种情况，由于是方法调用触发的编译，因此编译器理所当然地会以整个方法作为编译对象，这种编译也是虚拟机中标准的 JIT 编译方式。而对于后一种情况，尽管编译动作是由循环体所触发的，但是编译器依然会以整个方法（而不是单独的循环体）作为编译对象。这种编译方式因为发生在方法执行过程中，因此形象地称之为栈上替换（On Stack Replacement，简称 OSR 编译，即方法栈帧还在栈上，方法就被替换了）。

我们反复提到多次，可是多少次算多次呢？虚拟机如何统计一个方法或一段代码被执行过多少次呢？回答了这两个问题，也就回答了即时编译器的触发条件。

判断一段代码是不是热点代码，是不是需要触发即时编译，这样的行为称为「热点探测」。其实进行热点探测并不一定需要知道方法具体被调用了多少次，目前主要的热点探测判定方式有两种。

- 基于采样的热点探测：采用这种方法的虚拟机会周期性地检查各个线程栈顶，如果发现某个（或某些）方法经常出现在栈顶，那这个方法就是「热点方法」。基于采样的热点探测的好处是实现简单、高效，还可以很容易地获取方法调用关系（将调用栈展开即可），缺点是很难精确地确认一个方法的热度，容易因为受到线程阻塞或别的外界因数的影响而扰乱热点探测。
- 基于计数器的热点探测：采用这种方法的虚拟机会为每个方法（甚至代码块）建立计数器，统计方法的执行次数，如果执行次数超过一定的阈值就认为它是「热点方法」。这种统计方法实现起来麻烦一些，需要为每个方法建立并维护计数器，而且不能直接获取到方法的调用关系，但是统计结果相对来说更加精确和严谨。

HotSpot 虚拟机采用的是第二种：基于计数器的热点探测。因此它为每个方法准备了两类计数器：方法调用计数器（Invocation Counter）和回边计数器（Back Edge Counter）。

在确定虚拟机运行参数的情况下，这两个计数器都有一个确定的阈值，当计数器超过阈值就会触发 JIT 编译。

###### 2.1.2.1、方法调用计数器

顾名思义，这个计数器用于统计方法被调用的次数。当一个方法被调用时，会首先检查该方法是否存在被 JIT 编译过的版本，如果存在，则优先使用编译后的本地代码来执行。如果不存在，则将此方法的调用计数器加 1，然后判断方法调用计数器与回边计数器之和是否超过方法调用计数器的阈值。如果超过阈值，将会向即时编译器提交一个该方法的代码编译请求。

如果不做任何设置，执行引擎不会同步等待编译请求完成，而是继续进入解释器按照解释方式执行字节码，直到提交的请求被编译器编译完成。当编译完成后，这个方法的调用入口地址就会被系统自动改写成新的，下一次调用该方法时就会使用已编译的版本。

[![image-20200825174629326](https://img-blog.csdnimg.cn/img_convert/ae8b6593c3b8fbfbd5d9139e0f806fe0.png)](http://codeduck.top/md/imagesimage-20200825174629326.png)

如果不做任何设置，方法调用计数器统计的并不是方法被调用的绝对次数，而是一个相对的执行频率，即一段时间内方法调用的次数。当超过一定的时间限度，如果方法的调用次数仍然不足以让它提交给即时编译器编译，那这个方法的调用计数器值就会被减少一半，这个过程称为方法调用计数器热度的衰减，而这段时间就称为此方法统计的半衰期。

进行热度衰减的动作是在虚拟机进行 GC 时顺便进行的，可以设置虚拟机参数来关闭热度衰减，让方法计数器统计方法调用的绝对次数，这样，只要系统运行时间足够长，绝大部分方法都会被编译成本地代码。此外还可以设置虚拟机参数调整半衰期的时间。

###### 2.1.2.2、回边计数器

回边计数器的作用是统计一个方法中循环体代码执行的次数，在字节码中遇到控制流向后跳转的指令称为「回边」（Back Edge）。建立回边计数器统计的目的是为了触发 OSR 编译。

当解释器遇到一条回边指令时，会先查找将要执行的代码片段是否已经有编译好的版本，如果有，它将优先执行已编译的代码，否则就把回边计数器值加 1，然后判断方法调用计数器和回边计数器值之和是否超过计数器的阈值。当超过阈值时，将会提交一个 OSR 编译请求，并且把回边计数器的值降低一些，以便继续在解释器中执行循环，等待编译器输出编译结果。

[![image-20200825174219351](https://img-blog.csdnimg.cn/img_convert/0d1a06f85fea764d3a9bb41918159162.png)](http://codeduck.top/md/imagesimage-20200825174219351.png)

与方法计数器不同，回边计数器没有计算热度衰减的过程，因此这个计数器统计的就是该方法循环执行的绝对次数。当计数器溢出时，它还会把方法计数器的值也调整到溢出状态，这样下次再进入该方法的时候就会执行标准编译过程。

#### 2.2 编译优化技术

我们都知道，以编译方式执行本地代码比解释执行方式更快，一方面是因为节约了虚拟机解释执行字节码额外消耗的时间；另一方面是因为虚拟机设计团队几乎把所有对代码的优化措施都集中到了即时编译器中。这一小节我们来介绍下 HotSpot 虚拟机的即时编译器在编译代码时采用的优化技术。

##### 2.2.1、优化技术概览

代码优化技术有很多，实现这些优化也很有难度，但是大部分还是比较好理解的。为了便于介绍，我们先从一段简单的代码开始，看看虚拟机会做哪些代码优化。

```java
static class B {
    int value;
    final int get() {
        return value;
    }
}

public void foo() {
    y = b.get();
    z = b.get();
    sum = y + z;
}
```

首先需要明确的是，这些代码优化是建立在代码的某种中间表示或者机器码上的，绝不是建立在 Java 源码上。这里之所使用 Java 代码来介绍是为了方便演示。

上面这段代码看起来简单，但是有许多可以优化的地方。

第一步是进行**方法内联（Method Inlining）**，方法内联的重要性要高于其它优化措施。方法内联的目的主要有两个，一是去除方法调用的成本（比如建立栈帧），二是为其它优化建立良好的基础，方法内联膨胀之后可以便于更大范围上采取后续的优化手段，从而获得更好的优化效果。因此，各种编译器一般都会把内联优化放在优化序列的最前面。内联优化后的代码如下：

```java
public void foo() {
    y = b.value;
    z = b.value;
    sum = y + z;
}
```

第二步进行**冗余消除**，代码中「z = b.value;」可以被替换成「z = y」。这样就不用再去访问对象 b 的局部变量。如果把 b.value 看做是一个表达式，那也可以把这项优化工作看成是公共子表达式消除。优化后的代码如下：

```java
public void foo() {
    y = b.value;
    z = y;
    sum = y + z;
}
```

第三步进行**复写传播**，因为这段代码里没有必要使用一个额外的变量 z，它与变量 y 是完全等价的，因此可以使用 y 来代替 z。复写传播后的代码如下：

```java
public void foo() {
    y = b.value;
    y = y;
    sum = y + y;
}
```

第四步进行**无用代码消除**。无用代码可能是永远不会执行的代码，也可能是完全没有意义的代码。因此，又被形象的成为「Dead Code」。上述代码中 y = y 是没有意义的，因此进行无用代码消除后的代码是这样的：

```java
public void foo() {
    y = b.value;
    sum = y + y;
}
```

经过这四次优化后，最新优化后的代码和优化前的代码所达到的效果是一致的，但是优化后的代码执行效率会更高。编译器的这些优化技术实现起来是很复杂的，但是想要理解它们还是很容易的。接下来我们再讲讲如下几项最有代表性的优化技术是如何运作的，它们分别是：

> - 公共子表达式消除；
> - 数组边界检查消除；
> - 方法内联；
> - 逃逸分析。

##### 2.2.2、公共子表达式消除

如果一个表达式 E 已经计算过了，并且从先前的计算到现在 E 中所有变量的值都没有发生变化，那么 E 的这次出现就成了公共子表达式。对于这种表达式，没有必要花时间再对它进行计算，只需要直接使用前面计算过的表达式结果代替 E 就好了。如果这种优化仅限于程序的基本块内，便称为局部公共子表达式消除，如果这种优化的范围覆盖了多个基本块，那就称为全局公共子表达式消除。

##### 2.2.3、数组边界检查消除

如果有一个数组 array[]，在 Java 中访问数组元素 array[i] 的时候，系统会自动进行上下界的范围检查，即检查 i 必须满足 i >= 0 && i < array.length，否则会抛出一个运行时异常：java.lang.ArrayIndexOutOfBoundsException，这就是数组边界检查。

对于虚拟机执行子系统来说，每次数组元素的读写都带有一次隐含的条件判定操作，对于拥有大量数组访问的程序代码，这是一种不小的性能开销。为了安全，数组边界检查是必须做的，但是数组边界检查并不一定每次都要进行。比如在循环的时候访问数组，如果编译器只要通过数据流分析就知道循环变量是不是在区间 [0, array.length] 之内，那在整个循环中就可以把数组的上下界检查消除。

##### 2.2.4、方法内联

方法内联前面已经通过代码分析介绍过，这里就不再赘述了。

##### 2.2.5、逃逸分析

逃逸分析不是直接优化代码的手段，而是为其它优化手段提供依据的分析技术。逃逸分析的基本行为就是分析对象的动态作用域：当一个对象在方法中被定义后，它可能被外部方法所引用，例如作为调用参数传递到其它方法中，称为方法逃逸。甚至还有可能被外部线程访问到，例如赋值给类变量或可以在其他线程中访问的实例变量，称为线程逃逸。

如果能证明一个对象不会逃逸到方法或者线程之外，也就是别的方法和线程无法通过任何途径访问到这个方法，则可能为这个变量进行一些高效优化。比如：

1. 栈上分配：如果确定一个对象不会逃逸到方法之外，那么就可以在栈上分配内存，对象所占的内存空间就可以随栈帧出栈而销毁。通常，不会逃逸的局部对象所占的比例很大，如果能栈上分配就会大大减轻 GC 的压力。
2. 同步消除：如果逃逸分析能确定一个变量不会逃逸出线程，无法被其它线程访问，那这个变量的读写就不会有多线程竞争的问题，因而变量的同步措施也就可以消除了。
3. 标量替换：标量是指一个数据无法再拆分成更小的数据来表示了，Java 虚拟机中的原始数据类型都不能再进一步拆分，所以它们就是标量。相反，一个数据可以继续分解，那它就称作**聚合量**，Java 中的对象就是聚合量。如果把一个 Java 对象拆散，根据访问情况将其使用到的成员变量恢复成原始类型来访问，就叫**标量替换**。如果逃逸分析证明一个对象不会被外部访问，并且这个对象可以被拆散，那程序执行的时候就可能不创建这个对象，而改为直接创建它的若干个被这个方法使用到的成员变量来替代。对象被拆分后，除了可以让对象的成员变量在栈上分配和读写，还可以为后续进一步的优化手段创造条件。