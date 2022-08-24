# 一、[== 和 equals() 的区别](https://javaguide.cn/java/basis/java-basic-questions-01.html#hashcode-%E4%B8%8E-equals)

**`==`** 对于基本类型和引用类型的作用效果是不同的：

- 对于基本数据类型来说，`==` 比较的是值。
- 对于引用数据类型来说，`==` 比较的是对象的内存地址。

> 因为 Java 只有值传递，所以，对于 == 来说，不管是比较基本数据类型，还是引用数据类型的变量，其本质比较的都是值，只是引用类型变量存的值是对象的地址。

**`equals()`** 不能用于判断基本数据类型的变量，只能用来判断两个对象是否相等。`equals()`方法存在于`Object`类中，而`Object`类是所有类的直接或间接父类，因此所有的类都有`equals()`方法。

`Object` 类 `equals()` 方法：

```java
public boolean equals(Object obj) {
     return (this == obj);
}
```

`equals()` 方法存在两种使用情况：

- **类没有重写 `equals()`方法** ：通过`equals()`比较该类的两个对象时，等价于通过“==”比较这两个对象，使用的默认是 `Object`类`equals()`方法。
- **类重写了 `equals()`方法** ：一般我们都重写 `equals()`方法来比较两个对象中的属性是否相等；若它们的属性相等，则返回 true(即，认为这两个对象相等)。

举个例子（这里只是为了举例。实际上，你按照下面这种写法的话，像 IDEA 这种比较智能的 IDE 都会提示你将 `==` 换成 `equals()` ）：

```java
String a = new String("ab"); // a 为一个引用
String b = new String("ab"); // b为另一个引用,对象的内容一样
String aa = "ab"; // 放在常量池中
String bb = "ab"; // 从常量池中查找
System.out.println(aa == bb);// true
System.out.println(a == b);// false
System.out.println(a.equals(b));// true
System.out.println(42 == 42.0);// true
```

`String` 中的 `equals` 方法是被重写过的，因为 `Object` 的 `equals` 方法是比较的对象的内存地址，而 `String` 的 `equals` 方法比较的是对象的值。

当创建 `String` 类型的对象时，虚拟机会在常量池中查找有没有已经存在的值和要创建的值相同的对象，如果有就把它赋给当前引用。如果没有就在常量池中重新创建一个 `String` 对象。

`String`类`equals()`方法：

```java
public boolean equals(Object anObject) {
    if (this == anObject) {
        return true;
    }
    if (anObject instanceof String) {
        String anotherString = (String)anObject;
        int n = value.length;
        if (n == anotherString.value.length) {
            char v1[] = value;
            char v2[] = anotherString.value;
            int i = 0;
            while (n-- != 0) {
                if (v1[i] != v2[i])
                    return false;
                i++;
            }
            return true;
        }
    }
    return false;
}
```

### [#](https://javaguide.cn/java/basis/java-basic-questions-01.html#hashcode-与-equals)hashCode() 与 equals()

面试官可能会问你：“你重写过 `hashCode()` 和 `equals()`么?为什么重写 `equals()` 时必须重写 `hashCode()` 方法？”

一个非常基础的问题，面试中的重中之重，然而，很多求职者还是会回答不到点子上去。

#### [#](https://javaguide.cn/java/basis/java-basic-questions-01.html#hashcode-有什么用)hashCode() 有什么用？

`hashCode()` 的作用是获取哈希码（`int` 整数），也称为散列码。这个哈希码的作用是确定该对象在哈希表中的索引位置。

`hashCode()`定义在 JDK 的 `Object` 类中，这就意味着 Java 中的任何类都包含有 `hashCode()` 函数。另外需要注意的是： `Object` 的 `hashCode()` 方法是本地方法，也就是用 C 语言或 C++ 实现的，该方法通常用来将对象的内存地址转换为整数之后返回。

```java
public native int hashCode();
```

散列表存储的是键值对(key-value)，它的特点是：**能根据“键”快速的检索出对应的“值”。这其中就利用到了散列码！（可以快速找到所需要的对象）**

#### [#](https://javaguide.cn/java/basis/java-basic-questions-01.html#为什么要有-hashcode)为什么要有 hashCode？

我们以“`HashSet` 如何检查重复”为例子来说明为什么要有 `hashCode`？

下面这段内容摘自我的 Java 启蒙书《Head First Java》:

> 当你把对象加入 `HashSet` 时，`HashSet` 会先计算对象的 `hashCode` 值来判断对象加入的位置，同时也会与其他已经加入的对象的 `hashCode` 值作比较，如果没有相符的 `hashCode`，`HashSet` 会假设对象没有重复出现。但是如果发现有相同 `hashCode` 值的对象，这时会调用 `equals()` 方法来检查 `hashCode` 相等的对象是否真的相同。如果两者相同，`HashSet` 就不会让其加入操作成功。如果不同的话，就会重新散列到其他位置。这样我们就大大减少了 `equals` 的次数，相应就大大提高了执行速度。

其实， `hashCode()` 和 `equals()`都是用于比较两个对象是否相等。

**那为什么 JDK 还要同时提供这两个方法呢？**

这是因为在一些容器（比如 `HashMap`、`HashSet`）中，有了 `hashCode()` 之后，判断元素是否在对应容器中的效率会更高（参考添加元素进`HastSet`的过程）！

我们在前面也提到了添加元素进`HastSet`的过程，如果 `HashSet` 在对比的时候，同样的 `hashCode` 有多个对象，它会继续使用 `equals()` 来判断是否真的相同。也就是说 `hashCode` 帮助我们大大缩小了查找成本。

**那为什么不只提供 `hashCode()` 方法呢？**

这是因为两个对象的`hashCode` 值相等并不代表两个对象就相等。

**那为什么两个对象有相同的 `hashCode` 值，它们也不一定是相等的？**

因为 `hashCode()` 所使用的哈希算法也许刚好会让多个对象传回相同的哈希值。越糟糕的哈希算法越容易碰撞，但这也与数据值域分布的特性有关（所谓哈希碰撞也就是指的是不同的对象得到相同的 `hashCode` )。

总结下来就是 ：

- 如果两个对象的`hashCode` 值相等，那这两个对象不一定相等（哈希碰撞）。
- 如果两个对象的`hashCode` 值相等并且`equals()`方法也返回 `true`，我们才认为这两个对象相等。
- 如果两个对象的`hashCode` 值不相等，我们就可以直接认为这两个对象不相等。

相信大家看了我前面对 `hashCode()` 和 `equals()` 的介绍之后，下面这个问题已经难不倒你们了。

#### [#](https://javaguide.cn/java/basis/java-basic-questions-01.html#为什么重写-equals-时必须重写-hashcode-方法)为什么重写 equals() 时必须重写 hashCode() 方法？

因为两个相等的对象的 `hashCode` 值必须是相等。也就是说如果 `equals` 方法判断两个对象是相等的，那这两个对象的 `hashCode` 值也要相等。

如果重写 `equals()` 时没有重写 `hashCode()` 方法的话就可能会导致 `equals` 方法判断是相等的两个对象，`hashCode` 值却不相等。

**思考** ：重写 `equals()` 时没有重写 `hashCode()` 方法的话，使用 `HashMap` 可能会出现什么问题。

**总结** ：

- `equals` 方法判断两个对象是相等的，那这两个对象的 `hashCode` 值也要相等。
- 两个对象有相同的 `hashCode` 值，他们也不一定是相等的（哈希碰撞）。

更多关于 `hashCode()` 和 `equals()` 的内容可以查看：[Java hashCode() 和 equals()的若干问题解答](https://www.cnblogs.com/skywang12345/p/3324958.html)



# 二、[Java中字符串相加和字符串常量相加区别](https://blog.csdn.net/u010775025/article/details/86507090)

有一道这样的程序：

 

```java
 1 public class TestStringDemo {
 2 
 3     public static void main(String[] args) {
 4 
 5         String s1 = "Programming";
 6         String s2 = new String("Programming");
 7         String s3 = "Program";
 8         String s4 = "ming";
 9         String s5 = "Program" + "ming";
10         String s6 = s3 + s4;
11         System.out.println(s1 == s2);	//false,字符串常量和字符串对象
12         System.out.println(s1 == s5);	//被编译器优化成了String s5 = "Programming"，返回同一字符串常量
13         System.out.println(s1 == s6);	//
17     }
 }
```

让自己跟着做一遍，加深印象.....

 

程序的输出：

```
false
true
false
```

第一个输出：false ,我们还可以理解；

第二输出：true，跟我们的结果不一样，为什么输出true，不是说好了吗？**[字符串](https://so.csdn.net/so/search?q=字符串&spm=1001.2101.3001.7020)的+操作其本质是new了StringBuilder对象进行append操作，拼接后调用toString()返回String对象**

我们可以用以下命令获得.class文件对应的JVM字节码指令

```
javap -c StringEqualTest.class
```

JVM字节码指令:

![img](https://images2018.cnblogs.com/blog/1275521/201809/1275521-20180906164331277-1277719658.png)

 

 第20~22行，我们通过对比知道，String s5 = "Program" + "ming";在被编译器优化成了String s5 = "Programming"; 

 **也可以得出字符串常量相加，不会用到StringBuilder对象**，有一点要注意的是：字符串常量和字符串是不同的概念，**字符串常量储存于方法区，而字符串储存于堆(heap)。**

 

第三个输出：false ;通过以上的分析，自然也就明白了为森马是false了

 我们来分析一下JVM字节码指令

![img](https://images2018.cnblogs.com/blog/1275521/201809/1275521-20180906175056454-1039539370.png)

1. 第24行：使用new 了 StringBuider对象
2. 第25行：进行StringBuider对象初始化
3. 第26行：使用append() 方法拼接s3的内容
4. 第27行：再使用append() 方法拼接s4的内容
5. 第28行：最后调用toString() 返回String对象

# **总结：**

- **两个或者两个以上的字符串常量相加，在预编译的时候“+”会被优化，相当于把两个或者两个以上字符串常量自动合成一个（方法区）字符串常量**
- **字符串的+操作其本质是new了StringBuilder对象进行append操作，拼接后调用toString()返回String(堆)对象**



# [Java中字符串的创建以及相加问题](https://blog.csdn.net/gu_woniu/article/details/79859314)

 这几天遇到一个字符串相加是否相等的问题，自己做了一些测试，发现和以前理解的不一样，于是搜索了一下，加上自己的理解，然后整理下来，方便以后自己学习。

主要做了一下几个测试：

```java
 String s1="happy";
 String s2="ha"+ new String("ppy");
 String s3="ha"+"ppy";
 String s4="happy";
 String s5=new String("happy");
 System.out.println(s1==s2);
 System.err.println(s1==s3);
 System.out.println(s1==s4);
 System.out.println(s1==s5);
```
输出的结果依次是：false，true，true，false；

1、字符串的创建过程

​    字符串也是类，可以通过构造方法创建，这个很明显是创建的类，分配了堆栈。那么字符串类型直接赋值是怎样一个过程呢？这里涉及到一个东西，就是常量池。常量池是为了避免频繁的创建和销毁对象而影响系统性能，其实现了对象的共享。具体搜索常量池很多相关知识。**这种直接赋值的创建方式会将值直接写入常量池中，再次赋值时，先去常量池找，如果有，就直接将内存地址给他，所以s1和s4是指向的同一对象**。而s5通过new直接创建对象，创建堆，栈等过程，不会在常量池中去寻找，所以s1和s5的内存是不同的，s5是从新开辟的内存地址。

2、字符串的相加问题

   （1）先看String s3="ha"+"ppy"，网上给的解释是：在编译期间，这种拼接会被优化，编译器直接帮你拼好，所以s3相当于直接赋值为“happy”，所以和上面的s4就一致了，直接去常量池中寻找到s1的内存地址，所以会出现s1==s3；

（2）**而相加的过程中一旦出现了对象，就不会做优化，因为这是一个对象，内存不是确定的，没有写死，无法实现优化。**而且在相加的过程中，java会先new出一个StringBuilder，然后调用append()方法来将+号两遍的字符串拼接起来，然后toString()之后返回给=号左边的变量，也就是说，最后得到的是一个new出来的字符串，肯定与s1内存地址不同，所以为false。

总结：看起来很简单的东西，其实内部做了很多的考虑和优化，没能真正的理解内部实现机制，就不能很好的分析问题。以上也只是一些肤浅的认识，但能帮我理解一些东西。继续深入的话还有很多知识，以后慢慢学习吧。

参考：https://blog.csdn.net/zhongbeizhoujie/article/details/44549749



----

# 三、[Long类型比较相等问题](https://blog.csdn.net/zhsh5395/article/details/80622757)

**一、问题描述**

```java
Long a = 100L;
Long b = 100L;
System.out.println(a == b);
System.out.println(a.equals(b));
System.out.println(a == 100);
System.out.println(a.equals(100));		
```

输出结果：

true
true
true
false

但是当Long类型大于127时：

```java
Long a = 128L;
Long b = 128L;
System.out.println(a == b);
System.out.println(a.equals(b));
System.out.println(a == 128);
System.out.println(a.equals(128));
```

输出结果：

false
true
true
false

 

二、问题分析

 查看源码：java.lang.Long.java





LongCache会预先缓存-128–127范围内的数，通过缓存频繁请求的值代来更好的空间和时间性能，

当数据超出此范围，则new一个Long对象；

“==”是比较的地址，超出此范围的数据地址不一致，所以范围内的比较是true，范围外的数据是false；

而a==100则实现了类型的自动向上转换，将int类型转换成Long进行对比，所以输出true；

 



在Long.java里重写了equals()方法，先进行类型对比，在进行值的对比，所以a.equals(100)输出false；

long的包装类：Long.equals()的 源码：

```java
public boolean equals(Object var1) {
        if (var1 instanceof Long) {
            return this.value == (Long)var1;
        } else {
            return false;
        }
    }
```

 

三、解决问题方案

1、对于Long类型的对比，不要用“==”，尽量避免Long类型的直接对比

将Long转换成基本类型再进行比较：a.longValue() == b.longValue()，或者0 == Long.compare(a, b)；

2、

-128–127范围内的数：可用“==”

3、统一用：.equals(xxxL)，如：

```java
Long a = 130L;
Long b = 130L;
System.out.println(a.equals(b));	//可行，true
System.out.println(a.equals(130L));	//可行，true，注意必须加“L”，不然会直接先比较type不一致返回false
System.out.println(a.equals(130));	//不可行，false，type为int，不会比较返回
```



----



# 四、[浅谈String.intern()方法](https://blog.csdn.net/u011635492/article/details/81048150)

## 1.[String类](https://so.csdn.net/so/search?q=String类&spm=1001.2101.3001.7020)型“==”比较样例代码如下：

```java
package com.luna.test;
public class StringTest {
	public static void main(String[] args) {
		String str1 = "todo";
        String str2 = "todo";
        String str3 = "to";
        String str4 = "do";
        String str5 = str3 + str4;
        String str6 = new String(str1);
 
        System.out.println("------普通String测试结果------");
        System.out.print("str1 == str2 ? ");
        System.out.println( str1 == str2);
        System.out.print("str1 == str5 ? ");
        System.out.println(str1 == str5);
        System.out.print("str1 == str6 ? ");
        System.out.print(str1 == str6);
        System.out.println();
 
        System.out.println("---------intern测试结果---------");
        System.out.print("str1.intern() == str2.intern() ? ");
        System.out.println(str1.intern() == str2.intern());
        System.out.print("str1.intern() == str5.intern() ? ");
        System.out.println(str1.intern() == str5.intern());
        System.out.print("str1.intern() == str6.intern() ? ");
        System.out.println(str1.intern() == str6.intern());
        System.out.print("str1 == str6.intern() ? ");
        System.out.println(str1 == str6.intern());
	}
}
```

  代码运行结果如下所示：

```java
------普通String测试结果------
str1 == str2 ? true
str1 == str5 ? false
str1 == str6 ? false
---------intern测试结果---------
str1.intern() == str2.intern() ? true
str1.intern() == str5.intern() ? true
str1.intern() == str6.intern() ? true
str1 == str6.intern() ? true
```

​      普通String代码结果分析：Java语言会使用常量池保存那些在编译期就已确定的已编译的class文件中的一份数据。主要有类、接口、方法中的常量，以及一些以文本形式出现的符号引用，如类和接口的全限定名、字段的名称和描述符、方法和名称和描述符等。因此在编译完Intern类后，生成的class文件中会在常量池中保存“todo”、“to”和“do”三个String常量。变量str1和str2均保存的是常量池中“todo”的引用，所以str1==str2成立；在执行 str5 = str3 + str4这句时，JVM会先创建一个StringBuilder对象，通过StringBuilder.append()方法将str3与str4的值拼接，然后通过StringBuilder.toString()返回一个堆中的String对象的引用，赋值给str5，因此str1和str5指向的不是同一个String对象，str1 == str5不成立；String str6 = new String(str1)一句显式创建了一个新的String对象，因此str1 == str6不成立便是显而易见的事了。

## 2.String.intern()使用原理

​      String.intern()是一个Native方法，底层调用C++的 StringTable::intern方法实现。当通过语句str.intern()调用intern()方法后，JVM 就会在当前类的常量池中查找是否存在与str等值的String，若存在则直接返回常量池中相应Strnig的引用；若不存在，则会在常量池中创建一个等值的String，然后返回这个String在常量池中的引用。因此，只要是等值的String对象，使用intern()方法返回的都是常量池中同一个String引用，所以，这些等值的String对象通过intern()后使用==是可以匹配的。由此就可以理解上面代码中------intern------部分的结果了。因为str1、str5和str6是三个等值的String，所以通过intern()方法，他们均会指向常量池中的同一个String引用，因此str1.intern() == str5.intern() == str6.intern()均为true。

## 3.String.intern() in JDK6

​      Jdk6中常量池位于PermGen（永久代）中，PermGen是一块主要用于存放已加载的类信息和字符串池的大小固定的区域。执行intern()方法时，若常量池中不存在等值的字符串，JVM就会在常量池中创建一个等值的字符串，然后返回该字符串的引用。除此以外，JVM 会自动在常量池中保存一份之前已使用过的字符串集合。Jdk6中使用intern()方法的主要问题就在于常量池被保存在PermGen中：首先，PermGen是一块大小固定的区域，一般不同的平台PermGen的默认大小也不相同，大致在32M到96M之间。所以不能对不受控制的运行时字符串（如用户输入信息等）使用intern()方法，否则很有可能会引发PermGen内存溢出；其次String对象保存在Java堆区，Java堆区与PermGen是物理隔离的，因此如果对多个不等值的字符串对象执行intern操作，则会导致内存中存在许多重复的字符串，会造成性能损失。

## 4.String.intern() in JDK7

​      **Jdk7将常量池从PermGen区（永久代）移到了Java堆区**，执行intern操作时，如果常量池已经存在该字符串，则直接返回字符串引用，否则复制该字符串对象的引用到常量池中并返回。堆区的大小一般不受限，**所以将常量池从PremGen区移到堆区使得常量池的使用不再受限于固定大小。除此之外，位于堆区的常量池中的对象可以被垃圾回收。**当常量池中的字符串不再存在指向它的引用时，JVM就会回收该字符串。可以使用 -XX:StringTableSize 虚拟机参数设置字符串池的map大小。字符串池内部实现为一个HashMap，所以当能够确定程序中需要intern的字符串数目时，可以将该map的size设置为所需数目*2（减少hash冲突），这样就可以使得String.intern()每次都只需要常量时间和相当小的内存就能够将一个String存入字符串池中。

## 5.intern()适用场景

​      Jdk6中常量池位于PermGen区，大小受限，所以不建议适用intern()方法，当需要字符串池时，需要自己使用HashMap实现。Jdk7、8中，常量池由PermGen区移到了堆区，还可以通过-XX:StringTableSize参数设置StringTable的大小，常量池的使用不再受限，由此可以重新考虑使用intern()方法。**intern(）方法优点：执行速度非常快，直接使用==进行比较要比使用equals(）方法快很多；内存占用少。**虽然intern()方法的优点看上去很诱人，但若不是在恰当的场合中使用该方法的话，便非但不能获得如此好处，反而还可能会有性能损失。下面程序对比了使用intern()方法和未使用intern()方法存储100万个String时的性能，从输出结果可以看出，若是单纯使用intern()方法进行数据存储的话，程序运行时间要远高于未使用intern()方法时：

```java
public class InternTest {
    public static void main(String[] args) {
        print("noIntern: " + noIntern());
        print("intern: " + intern());
    }
 
    private static long noIntern(){
        long start = System.currentTimeMillis();
        for (int i = 0; i < 1000000; i++) {
            int j = i % 100;
            String str = String.valueOf(j);
        }
        return System.currentTimeMillis() - start;
    }
 
    private static long intern(){
        long start = System.currentTimeMillis();
        for (int i = 0; i < 1000000; i++) {
            int j = i % 100;
            String str = String.valueOf(j).intern();
        }
        return System.currentTimeMillis() - start;
    }
}
```

 程序运行结果：

```
noIntern: 48    // 未使用intern方法时，存储100万个String所需时间
intern: 99      // 使用intern方法时，存储100万个String所需时间
```

​      **由于intern()操作每次都需要与常量池中的数据进行==比较以查看常量池中是否存在等值数据，==同时JVM需要确保常量池中的数据的唯一性，这就涉及到加锁机制，这些操作都是有需要占用CPU时间的，所以如果进行intern操作的是==大量不会被重复利用==的String的话，则有点得不偿失。**由此可见，**==String.intern()主要适用于只有有限值，并且这些有限值会被重复利用的场景，==**如数据库表中的列名、人的姓氏、编码类型等。

## 6.总结：

​      String.intern()方法是一种手动将字符串加入常量池中的方法，原理如下：如果在常量池中存在与调用intern()方法的字符串等值的字符串，就直接返回常量池中相应字符串的引用，否则在常量池中复制一份该字符串，并将其引用返回（Jdk7中会直接在常量池中保存当前字符串的引用）；J**dk6 中常量池位于PremGen区，大小受限，不建议使用String.intern()方法，**不过Jdk7 将常量池移到了Java堆区，大小可控，可以重新考虑使用String.intern()方法，但是由对比测试可知，使用该方法的耗时不容忽视，所以需要慎重考虑该方法的使用；**String.intern()方法主要适用于程序中需要保存有限个会被反复使用的值的场景，这样可以减少内存消耗，同时在进行比较操作时减少时耗，提高程序性能。**

------------------------------------------------


# 五、[Java常量池理解与总结](https://www.jianshu.com/p/c7f47de2ee80)

​	一.相关概念

------

## 1、什么是常量

 用final修饰的成员变量表示常量，值一旦给定就无法改变！（编译时就能确定值的）
 final修饰的变量有三种：静态变量、实例变量和局部变量，分别表示三种类型的常量。（编译时无法确定，或者值可能会发生改变的量）

## 2、Class文件中的常量池

 在Class文件结构中，最头的4个字节用于存储魔数Magic Number，用于确定一个文件是否能被JVM接受，再接着4个字节用于存储版本号，前2个字节存储次版本号，后2个存储主版本号，再接着是用于存放常量的常量池，由于常量的数量是不固定的，所以常量池的入口放置一个U2类型的数据(constant_pool_count)存储常量池容量计数值。
 常量池主要用于存放两大类常量：**字面量**(Literal)和**符号引用量**(Symbolic References)，字面量相当于Java语言层面常量的概念，如文本字符串，声明为final的常量值等，符号引用则属于编译原理方面的概念，包括了如下三种类型的常量：

- 类和接口的全限定名
- 字段名称和描述符
- 方法名称和描述符

1. **方法区中的运行时常量池**
    运行时常量池是方法区的一部分。
    CLass文件中除了有类的版本、字段、方法、接口等描述信息外，还有一项信息是常量池，用于存放编译期生成的各种字面量和符号引用，这部分内容将在类加载后进入方法区的运行时常量池中存放。
    运行时常量池相对于CLass文件常量池的另外一个重要特征是**具备动态性**，Java语言并不要求常量一定只有编译期才能产生，也就是并非预置入CLass文件中常量池的内容才能进入方法区运行时常量池，运行期间也可能将新的常量放入池中，这种特性被开发人员利用比较多的就是**String类的intern()**方法。
2. **常量池的好处**
    常量池是为了避免频繁的创建和销毁对象而影响系统性能，其实现了对象的共享。
    例如字符串常量池，在编译阶段就把所有的字符串文字放到一个常量池中。
    （1）节省内存空间：常量池中所有相同的字符串常量被合并，只占用一个空间。
    （2）节省运行时间：比较字符串时，==比equals()快。对于两个引用变量，只用==判断引用是否相等，也就可以判断实际值是否相等。
3. **双等号==的含义**
    **基本数据类型之间应用双等号，比较的是他们的数值。**
    复合数据类型(类)之间应用双等号，比较的是他们在**内存中的存放地址。**

## 3、8种基本类型的包装类和常量池

------

1. java中基本类型的包装类的大部分都实现了常量池技术，
    即Byte,Short,Integer,Long,Character,Boolean；



```java
  Integer i1 = 40;
  Integer i2 = 40;
  System.out.println(i1==i2);//输出TRUE
```

这5种包装类默认创建了数值[-128，127]的相应类型的缓存数据，但是超出此范围仍然会去创建新的对象。



```java
//Integer 缓存代码 ：
public static Integer valueOf(int i) {
        assert IntegerCache.high >= 127;
        if (i >= IntegerCache.low && i <= IntegerCache.high)
            return IntegerCache.cache[i + (-IntegerCache.low)];
        return new Integer(i);
    }
```



```java
  Integer i1 = 400;
  Integer i2 = 400;
  System.out.println(i1==i2);//输出false
```

1. **两种浮点数类型的包装类Float,Double并没有实现常量池技术。**

```java
   Double i1=1.2;
   Double i2=1.2;
   System.out.println(i1==i2);//输出false
```

1. **应用常量池的场景**
    (1)`Integer i1=40；`Java在编译的时候会直接将代码封装成`Integer i1=Integer.valueOf(40);`，从而使用常量池中的对象。
    (2)`Integer i1 = new Integer(40);`这种情况下会创建新的对象。



```java
  Integer i1 = 40;
  Integer i2 = new Integer(40);
  System.out.println(i1==i2);//输出false
```

1. **Integer比较更丰富的一个例子**



```java
  Integer i1 = 40;
  Integer i2 = 40;
  Integer i3 = 0;
  Integer i4 = new Integer(40);
  Integer i5 = new Integer(40);
  Integer i6 = new Integer(0);
  
  System.out.println("i1=i2   " + (i1 == i2));
  System.out.println("i1=i2+i3   " + (i1 == i2 + i3));
  System.out.println("i1=i4   " + (i1 == i4));
  System.out.println("i4=i5   " + (i4 == i5));
  System.out.println("i4=i5+i6   " + (i4 == i5 + i6));   
  System.out.println("40=i5+i6   " + (40 == i5 + i6));     
```



```java
i1=i2   true
i1=i2+i3   true
i1=i4   false
i4=i5   false
i4=i5+i6   true
40=i5+i6   true
```

解释：语句`i4 == i5 + i6`，因为+这个操作符不适用于Integer对象，首先i5和i6进行自动拆箱操作，进行数值相加，即`i4 == 40`。然后Integer对象无法与数值进行直接比较，所以i4自动拆箱转为int值40，最终这条语句转为`40 == 40`进行数值比较。
 [Java中的自动装箱与拆箱](https://link.jianshu.com?t=http://droidyue.com/blog/2015/04/07/autoboxing-and-autounboxing-in-java/)



## 4、String类和常量池

------

1. **String对象创建方式**



```dart
     String str1 = "abcd";
     String str2 = new String("abcd");
     System.out.println(str1==str2);//false
```

这两种不同的创建方法是有差别的，第一种方式是在常量池中拿对象，第二种方式是直接在堆内存空间创建一个新的对象。
 **只要使用new方法，便需要创建新的对象。**

1. **连接表达式 +**
    （1）只有使用**引号**包含文本的方式创建的String对象之间使用“+”连接产生的新对象才会被**加入字符串池中**。（直接+会生成常量）
    （2）**对于所有包含new方式新建对象（包括null）的“+”连接表达式，它所产生的新对象都不会被加入字符串池中。只会放入堆空间（间接+生成变量）**



```java
  String str1 = "str";
  String str2 = "ing";
  
  String str3 = "str" + "ing";		//直接+，常量
  String str4 = str1 + str2;		//间接+，变量
  System.out.println(str3 == str4);//false
  
  String str5 = "string";
  System.out.println(str3 == str5);//true
```

[java基础：字符串的拼接](https://www.jianshu.com/p/88aa19fc21c6)



- 特例1

```java
public static final String A = "ab"; // 常量A
public static final String B = "cd"; // 常量B
public static void main(String[] args) {
     String s = A + B;  // 将两个常量用+连接对s进行初始化 
     String t = "abcd";   
    if (s == t) {   
         System.out.println("s等于t，它们是同一个对象");   
     } else {   
         System.out.println("s不等于t，它们不是同一个对象");   
     }   
 } 
s等于t，它们是同一个对象
```

A和B都是常量，值是固定的，因此s的值也是固定的，它在**类被编译时就已经确定了**。也就是说：String s=A+B;  等同于：String s="ab"+"cd";



- 特例2

```java
public static final String A; // 常量A
public static final String B;    // 常量B
static {   
     A = "ab";   
     B = "cd";   
 }   
 public static void main(String[] args) {   
    // 将两个常量用+连接对s进行初始化   
     String s = A + B;   	//创建了一个堆对象，字符串不会放入常量池中
     String t = "abcd";   
    if (s == t) {   
         System.out.println("s等于t，它们是同一个对象");   
     } else {   
         System.out.println("s不等于t，它们不是同一个对象");   
     }   
 } 
s不等于t，它们不是同一个对象
```

A和B虽然被定义为常量，但是它们都没有马上被赋值。在运算出s的值之前，他们何时被赋值，以及被赋予什么样的值，都是个变数。因此A和B在被赋值之前，性质类似于一个变量。那么**s就不能在编译期被确定，而只能在运行时被创建了。**

1. `String s1 = new String("xyz");` **创建了几个对象？ **
    考虑类加载阶段和实际执行时。
    （1）类加载对一个类只会进行一次。"xyz"在类加载时就已经创建并驻留了（如果该类被加载之前已经有"xyz"字符串被驻留过则不需要重复创建用于驻留的"xyz"实例）。驻留的字符串是放在全局共享的字符串常量池中的。
    （2）在这段代码后续被运行的时候，"xyz"字面量对应的String实例已经固定了，不会再被重复创建。所以这段代码将常量池中的对象复制一份放到**heap**中，并且把heap中的这个对象的引用交给s1 持有。
    这条语句创建了2个对象。
2. **java.lang.String.intern()**
    运行时常量池相对于CLass文件常量池的另外一个重要特征是**具备动态性**，Java语言并不要求常量一定只有编译期才能产生，也就是并非预置入CLass文件中常量池的内容才能进入方法区运行时常量池，运行期间也可能将新的常量放入池中，这种特性被开发人员利用比较多的就是**String类的intern()**方法。
    String的intern()方法会查找在常量池中是否存在一份equal相等的字符串,如果有则返回该字符串的引用,如果没有则添加自己的字符串进入常量池。



```java
public static void main(String[] args) {    
      String s1 = new String("计算机");
      String s2 = s1.intern();
      String s3 = "计算机";
      System.out.println("s1 == s2? " + (s1 == s2));	//false
      System.out.println("s3 == s2? " + (s3 == s2));	//true
  }
```

```java
public class stringTest {
//    public static final String A= "ab"; // 常量A
//    public static final String B= "cd";    // 常量B
//    static {
//        A = "ab";
//        B = "cd";
//    }
public static void main(String[] args) {
String A = "ab";
String B = "cd";
// 将两个常量用+连接对s进行初始化
String s = A + B;
String t = "abcd";
if (s == t) {
System.out.println("s等于t，它们是同一个对象");
} else {
System.out.println("s不等于t，它们不是同一个对象");
}


        String str2 = new StringBuilder("计算机a").append("软件n").toString();
        System.out.println(str2.intern() == str2);  //该字符串首次出现会将自身地址放入常量池中
        String str1 = new StringBuilder("ab").append("cd").toString();
        System.out.println(str1.intern() == str1);  //abcd已经在常量池中有了地址，前者返回的是常量池地址，后者是堆中新创建的字符串对象地址
    }
}
```

1. **字符串比较更丰富的一个例子**



```java
public class Test {
 public static void main(String[] args) {   
      String hello = "Hello", lo = "lo";
      System.out.println((hello == "Hello") + " ");		//true,在同包同类下,引用自同一String对象.
      System.out.println((Other.hello == hello) + " ");	//true,在同包不同类下,引用自同一String对象.
      System.out.println((other.Other.hello == hello) + " ");//true,在不同包不同类下,依然引用自同一String对象.
      System.out.println((hello == ("Hel"+"lo")) + " ");//true,在编译成.class时能够识别为同一字符串的,自动优化成常量,引用自同一String对象.
      System.out.println((hello == ("Hel"+lo)) + " ");//false,在运行时创建的字符串具有独立的内存地址,所以不引用自同一String对象.
      System.out.println(hello == ("Hel"+lo).intern());//true,返回了常量池中相同字符串的地址，比较出了常量池中所有字符串的值找出来的该唯一对象
 }   
}
class Other { static String hello = "Hello"; }
package other;
public class Other { public static String hello = "Hello"; }
```



```rust
true true true true false true```
在同包同类下,引用自同一String对象.
在同包不同类下,引用自同一String对象.
在不同包不同类下,依然引用自同一String对象.
在编译成.class时能够识别为同一字符串的,自动优化成常量,引用自同一String对象.
在运行时创建的字符串具有独立的内存地址,所以不引用自同一String对象.


-----
[2015-08-26]
```

