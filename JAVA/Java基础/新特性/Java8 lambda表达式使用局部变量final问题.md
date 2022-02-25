# 一、[Java8 lambda表达式使用局部变量final问题](https://harmonyos.51cto.com/posts/783)

在使用lambda表达式的时候，经常会遇到一个问题，那就是在lambda表达式内部修改局部变量的的值时候，编译器会报错，说变量类型必须为final才可以使用，也就是说不让我们修改，这是为什么呢？


Lambda可以没有限制地捕获(也就是在其主体中引用)实例变量和静态变量。但局部变量必须显式声明为final， 或事实上是final。换句话说，Lambda表达式只能捕获指派给它们的局部变量一次。 例如，下面的代码无法编译，因为portNumber 变量被赋值两次:

 

```markup
int portNumber = 1337;
Runnable r = () -> System.out.println(portNumber);
portNumber = 31337;
1.2.3.
```

复制

 

编译第二行报错：Variable used in lambda expression should be final or effectively final.

 

**Lambda表达式规则**

 

- **只能引用标记了 final 的外层局部变量，这就是说不能在 lambda 内部修改定义在域外的局部变量，否则会编译错误。**
- **局部变量可以不用声明为 final，但是必须不可被后面的代码修改（即隐性的具有 final 的语义）**
- **不允许声明一个与局部变量同名的参数或者局部变量。**

 

**根据lanbda表达式规则可知**：lambda表达式内部引用的局部变量是隐式的final


所以无论Lambda表达式引用的局部变量无论是否声明final，均具有final特性！表达式内仅允许对变量引用（引用内部修改除外，比如list增删），禁止修改！

 

**为什么局部变量有这些限制？**

 

第一，实例变量和局部变量背后的实现有一个关键不同。实例变量都存储在堆中，堆是线程共享的。而局部变量则保存在栈上。如果Lambda可以直接访问局部变量，而且Lambda是在一个线程中使用的，则使用Lambda的线程，可能会在分配该变量的线程将这个变量收回之后，去访问该变量。因此，Java为避免这个问题，在访问自由局部变量时，实际上是在访问它的副本，而不是访问原始变量。为了保证局部变量和lambda中复制品 的数据一致性，就必须要这个限制。

 

第二，这一限制不鼓励你使用改变外部变量的典型命令式编程模式(这种模式会阻碍Java8很容易做到的并行处理)。



---

# 二、[匿名类中的局部变量](https://blog.csdn.net/qq_36221788/article/details/100584500)

## 场景描述

我们在使用Java8 lambda表达式的时候时不时会遇到这样的编译报错：

![场景描述](https://img-blog.csdnimg.cn/20190906181204304.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM2MjIxNzg4,size_16,color_FFFFFF,t_70)

这句话的意思是，**lambda 表达式中使用的变量应该是 final 或者有效的 final，**为什么会有这种规定？

## 匿名类中的局部变量

其实在 Java 8 之前，**匿名类中如果要访问局部变量的话，那个局部变量必须显式的声明为 final**，如下代码在 Java 7 中是编译不过的：

```java
@Test
public void demo() {
    String version = "1.8";
    foo(new Supplier() {
        @Override
        public String get() {
            return version; // 编译报错 Variable 'version' is accessed from within inner class, needs to be declared final
        }
    });
}
private void foo(Supplier supplier) {
    System.out.println(supplier.get());
}
//Java 7 要求 version 这个局部变量必须是 final 类型的，否则在匿名类中不可引用。
```
我们知道，**lambda 表达式是由匿名内部类演变过来的**，它们的作用都是实现接口方法，于是类比匿名内部类，lambda 表达式中使用的变量也需要是 final 类型。也就是说我们一开始图片中，i 这个变量需要声明为 final 类型，但是又发现个现象，如图：

![现象描述](https://img-blog.csdnimg.cn/20190906183537849.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM2MjIxNzg4,size_16,color_FFFFFF,t_70)

i 这个变量赋值给了 finalI 变量，但是 finalI 并没有声明为 final 类型，然而代码却能够编译通过，这是因为 **Java 8 之后，在匿名类或 Lambda 表达式中访问的局部变量，如果不是 final 类型的话，编译器自动加上 final 修饰符，即 Java8 新特性：effectively final。**

## 思考

**前面一直说 Lambda 表达式或者匿名内部类不能访问非 final 的局部变量，这是为什么呢？**

首先思考外部的局部变量 finalI 和匿名内部类里面的 finalI 是否是同一个变量？

> 我们知道，每个方法在执行的同时都会创建一个栈帧用于存储局部变量表、操作数栈、动态链接，方法出口等信息，每个方法从调用直至执行完成的过程，就对应着一个栈帧在虚拟机栈中入栈到出栈的过程（《 深入理解Java虚拟机》第2.2.2节 Java虚拟机栈）。

就是说在执行方法的时候，**局部变量会保存在栈中，方法结束局部变量也会出栈，随后会被垃圾回收掉**，而此时，内部类对象可能还存在，如果内部类对象这时直接去访问局部变量的话就会出问题，因为外部局部变量已经被回收了，解决办法就是把匿名内部类要访问的局部变量复制一份作为内部类对象的成员变量，查阅资料或者通过反编译工具对代码进行反编译会发现，底层确实定义了一个新的变量，通过内部类构造函数将外部变量复制给内部类变量。

为何**还需要用final修饰？**
其实复制变量的方式会造成一个数据不一致的问题，在**执行方法的时候局部变量的值改变了却无法通知匿名内部类的变量**，随着程序的运行，就会导致程序运行的结果与预期不同，于是使用final修饰这个变量，使它成为一个常量，这样就**保证了数据的一致性**。

