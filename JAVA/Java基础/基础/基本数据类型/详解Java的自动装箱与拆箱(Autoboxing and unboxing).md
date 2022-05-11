# [详解Java的自动装箱与拆箱(Autoboxing and unboxing)](https://www.cnblogs.com/wang-yaz/p/8516151.html)

## 一、什么是自动装箱拆箱 

很简单，下面两句代码就可以看到装箱和拆箱过程

```
1 //自动装箱
2 Integer total = 99;
3 
4 //自动拆箱
5 int totalprim = total;
```

简单一点说，装箱就是自动将基本数据类型转换为包装器类型；拆箱就是自动将包装器类型转换为基本数据类型。

下面我们来看看需要装箱拆箱的类型有哪些：

![这里写图片描述](https://img-blog.csdn.net/20160329101454749)

![这里写图片描述](https://img-blog.csdn.net/20150922151443893)

这个过程是自动执行的，那么我们需要看看它的执行过程：

```
1 public class Main {
2     public static void main(String[] args) {
3     //自动装箱
4     Integer total = 99;
5 
6     //自定拆箱
7     int totalprim = total;
8     }
9 }
```

反编译class文件之后得到如下内容：

 1 javap -c StringTest 

![这里写图片描述](https://img-blog.csdn.net/20150922153411441)

Integer total = 99; 
执行上面那句代码的时候，系统为我们执行了： 
Integer total = Integer.valueOf(99);

int totalprim = total; 
执行上面那句代码的时候，系统为我们执行了： 
int totalprim = total.intValue();

我们现在就以Integer为例，来分析一下它的源码： 
1、首先来看看Integer.valueOf函数

```
1 public static Integer valueOf(int i) {
2 return  i >= 128 || i < -128 ? new Integer(i) : SMALL_VALUES[i + 128];
3 }
```

它会首先判断i的大小：如果i小于-128或者大于等于128，就创建一个Integer对象，否则执行SMALL_VALUES[i + 128]。

首先我们来看看Integer的构造函数：

```
1 private final int value;
2 
3 public Integer(int value) {
4     this.value = value;
5 }
6 
7 public Integer(String string) throws NumberFormatException {
8     this(parseInt(string));
9 }
```

它里面定义了一个value变量，创建一个Integer对象，就会给这个变量初始化。第二个传入的是一个String变量，它会先把它转换成一个int值，然后进行初始化。

下面看看SMALL_VALUES[i + 128]是什么东西：

```
 1 private static final Integer[] SMALL_VALUES = new Integer[256]; 
```

它是一个静态的Integer数组对象，也就是说最终valueOf返回的都是一个Integer对象。

所以我们这里可以总结一点：装箱的过程会创建对应的对象，这个会消耗内存，所以装箱的过程会增加内存的消耗，影响性能。

2、接着看看intValue函数

```
1 @Override
2 public int intValue() {
3     return value;
4 }
```

这个很简单，直接返回value值即可。

## 二、相关问题 

上面我们看到在Integer的构造函数中，它分两种情况： 

1、i >= 128 || i < -128 =====> new Integer(i) 
2、i < 128 && i >= -128 =====> SMALL_VALUES[i + 128]

```
1 private static final Integer[] SMALL_VALUES = new Integer[256];
```

SMALL_VALUES本来已经被创建好，也就是说在i >= 128 || i < -128是会创建不同的对象，在i < 128 && i >= -128会根据i的值返回已经创建好的指定的对象。

说这些可能还不是很明白，下面我们来举个例子吧：

```
 1 public class Main {
 2     public static void main(String[] args) {
 3 
 4         Integer i1 = 100;
 5         Integer i2 = 100;
 6         Integer i3 = 200;
 7         Integer i4 = 200;
 8 
 9         System.out.println(i1==i2);  //true
10         System.out.println(i3==i4);  //false
11     }
12 }
```

代码的后面，我们可以看到它们的执行结果是不一样的，为什么，在看看我们上面的说明。 
1、i1和i2会进行自动装箱，执行了valueOf函数，它们的值在(-128,128]这个范围内，它们会拿到SMALL_VALUES数组里面的同一个对象SMALL_VALUES[228]，它们引用到了同一个Integer对象，所以它们肯定是相等的。

2、i3和i4也会进行自动装箱，执行了valueOf函数，它们的值大于128，所以会执行new Integer(200)，也就是说它们会分别创建两个不同的对象，所以它们肯定不等。

下面我们来看看另外一个例子：

```
 1 public class Main {
 2     public static void main(String[] args) {
 3 
 4         Double i1 = 100.0;
 5         Double i2 = 100.0;
 6         Double i3 = 200.0;
 7         Double i4 = 200.0;
 8 
 9         System.out.println(i1==i2); //false
10         System.out.println(i3==i4); //false
11     }
12 }
```

看看上面的执行结果，跟Integer不一样，这样也不必奇怪，因为它们的valueOf实现不一样，结果肯定不一样，那为什么它们不统一一下呢？ 
这个很好理解，因为对于Integer，在(-128,128]之间只有固定的256个值，所以为了避免多次创建对象，我们事先就创建好一个大小为256的Integer数组SMALL_VALUES，所以如果值在这个范围内，就可以直接返回我们事先创建好的对象就可以了。

但是对于Double类型来说，我们就不能这样做，因为它在这个范围内个数是无限的。 
总结一句就是：在某个范围内的整型数值的个数是有限的，而浮点数却不是。

所以在Double里面的做法很直接，就是直接创建一个对象，所以每次创建的对象都不一样。

```
1 public static Double valueOf(double d) {
2     return new Double(d);
3 }
```

下面我们进行一个归类： 
Integer派别：Integer、Short、Byte、Character、Long这几个类的valueOf方法的实现是类似的。 
Double派别：Double、Float的valueOf方法的实现是类似的。每次都返回不同的对象。

下面对Integer派别进行一个总结，如下图： 
![这里写图片描述](https://img-blog.csdn.net/20150922153039509)

下面我们来看看另外一种情况：

```
 1 public class Main {
 2     public static void main(String[] args) {
 3 
 4         Boolean i1 = false;
 5         Boolean i2 = false;
 6         Boolean i3 = true;
 7         Boolean i4 = true;
 8 
 9         System.out.println(i1==i2);//true
10         System.out.println(i3==i4);//true
11     }
12 }
```

可以看到返回的都是true，也就是它们执行valueOf返回的都是相同的对象。

```
1 public static Boolean valueOf(boolean b) {
2     return b ? Boolean.TRUE : Boolean.FALSE;
3 }
```

可以看到它并没有创建对象，因为在内部已经提前创建好两个对象，因为它只有两种情况，这样也是为了避免重复创建太多的对象。

```
1 public static final Boolean TRUE = new Boolean(true);
2 
3 public static final Boolean FALSE = new Boolean(false);
```

 

上面把几种情况都介绍到了，下面来进一步讨论其他情况。

```
1 Integer num1 = 400;  
2 int num2 = 400;  
3 System.out.println(num1 == num2); //true
说明num1 == num2进行了拆箱操作
1 Integer num1 = 100;  
2 int num2 = 100;  
3 System.out.println(num1.equals(num2));  //true
```

我们先来看看equals源码：

```
1 @Override
2 public boolean equals(Object o) {
3     return (o instanceof Integer) && (((Integer) o).value == value);
4 }
```

我们指定equal比较的是内容本身，并且我们也可以看到equal的参数是一个Object对象，我们传入的是一个int类型，所以首先会进行装箱，然后比较，之所以返回true，是由于它比较的是对象里面的value值。

```
1 Integer num1 = 100;  
2 int num2 = 100;  
3 Long num3 = 200l;  
4 System.out.println(num1 + num2);  //200
5 System.out.println(num3 == (num1 + num2));  //true
6 System.out.println(num3.equals(num1 + num2));  //false
```

1、当一个基础数据类型与封装类进行==、+、-、*、/运算时，会将封装类进行拆箱，对基础数据类型进行运算。 
2、对于num3.equals(num1 + num2)为false的原因很简单，我们还是根据代码实现来说明：

```
1 @Override
2 public boolean equals(Object o) {
3     return (o instanceof Long) && (((Long) o).value == value);
4 }
```

它必须满足两个条件才为true： 
1、类型相同 
2、内容相同 
上面返回false的原因就是类型不同。

```
1 Integer num1 = 100;
2 Ingeger num2 = 200;
3 Long num3 = 300l;
4 System.out.println(num3 == (num1 + num2)); //true
```

我们来反编译一些这个class文件：javap -c StringTest 
![这里写图片描述](https://img-blog.csdn.net/20150922153446481)

可以看到运算的时候首先对num3进行拆箱（执行num3的longValue得到基础类型为long的值300），然后对num1和mum2进行拆箱（分别执行了num1和num2的intValue得到基础类型为int的值100和200），然后进行相关的基础运算。

我们来对基础类型进行一个测试：

```
1 int num1 = 100;
2 int num2 = 200;
3 long mum3 = 300;
4 System.out.println(num3 == (num1 + num2)); //true
```

就说明了为什么最上面会返回true.

所以，当 “==”运算符的两个操作数都是 包装器类型的引用，则是比较指向的是否是同一个对象，而如果其中有一个操作数是表达式（即包含算术运算）则比较的是数值（即会触发自动拆箱的过程）。

陷阱1：

```
1  Integer integer100=null;  
2  int int100=integer100;
```

这两行代码是完全合法的，完全能够通过编译的，但是在运行时，就会抛出空指针异常。其中，integer100为Integer类型的对象，它当然可以指向null。但在第二行时，就会对integer100进行拆箱，也就是对一个null对象执行intValue()方法，当然会抛出空指针异常。所以，有拆箱操作时一定要特别注意封装类对象是否为null。

总结： 
1、需要知道什么时候会引发装箱和拆箱 
2、装箱操作会创建对象，频繁的装箱操作会消耗许多内存，影响性能，所以可以避免装箱的时候应该尽量避免。

3、equals(Object o) 因为原equals方法中的参数类型是封装类型，所传入的参数类型（a）是原始数据类型，所以会自动对其装箱，反之，会对其进行拆箱

4、当两种不同类型用比较时，包装器类的需要拆箱， 当同种类型用比较时，会自动拆箱或者装箱



---



# [【Java基础】自动拆装箱](https://blog.csdn.net/Elephant_King/article/details/122376120)

## 基本数据类型

### 八大数据类型

字符型                                                        char

布尔类型                                                     boolean

整数类型                                                     byte、short、int、long

浮点数类型                                                  float、double

### Java类型分类

####         基本类型：

​                在JVM栈中分配空间存值

#### 		引用类型：

​        	在堆中分配空间存值

### void类型

Java还存在一种基本类型void，对应的包装类为java.lang.Void，Void是不能被new出来的

![img](https://img-blog.csdnimg.cn/c2d67299b0c1436c9c7e235648adb386.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBARWxlcGhhbnRfS2luZw==,size_20,color_FFFFFF,t_70,g_se,x_16)

因此不能在堆中分配存储空间存储对应的值

### 使用基本数据类型的好处

在Jva语言中，new一个对象是存储在堆中的，我们通过栈中的引用来使用这些对象，是比较费资源的

而常用的基本数据类型，**不需要用new创建，数据直接存放在栈中，所以会更加高效**

 我们可以知道，在栈中每一个栈帧，都包含了**局部变量表**，这里局部变量中的数据，就是存储在局部变量表中的

![img](https://img-blog.csdnimg.cn/2cd888c898eb42be8a70a378239b29cc.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBARWxlcGhhbnRfS2luZw==,size_16,color_FFFFFF,t_70,g_se,x_16)

## 包装类型

| 基本数据类型 | 包装类    |
| :----------- | :-------- |
| byte         | Byte      |
| boolean      | Boolean   |
| short        | Short     |
| char         | Character |
| int          | Integer   |
| long         | Long      |
| float        | Float     |
| double       | Double    |

### 创建对象方法

Byte

```java
public class Test04 {
    public static void main(String[] args) {
        Byte a = 2;                                    //通过自动装箱赋值
        Byte b = new Byte(String.valueOf(1));         //通过String创建对象
    }
}
```

Boolean

```java
public class Test04 {
    public static void main(String[] args) {
        Boolean a = true;          //通过valueOf赋值
        Boolean c = new Boolean(String.valueOf(true));          //通过String
        Boolean b = new Boolean(true);                 //通过常数
    }
}
```

Short

```java
public class Test04 {
    public static void main(String[] args) {
        Short a = 1;                                    //通过自动装箱赋值
        Short b = new Short(String.valueOf(1));         //通过String创建对象
    }
}
```

Character

```java
public class Test04 {
    public static void main(String[] args) {
        Character a = '1';          //通过valueOf赋值
        Character b = new Character('1');                 //通过常数
    }
}
```

Integer

```java
public class Test04 {
    public static void main(String[] args) {
        Integer a = 2;                                    //通过自动装箱赋值
        Integer b = new Integer(1);                 //通过常数
        Integer c = new Integer(String.valueOf(1));       //通过String创建对象
    }
}
```

Long

```java
public class Test04 {
    public static void main(String[] args) {
        Long a = Long.valueOf(2);                   //通过valueOf赋值
        Long b = new Long(1);                 //通过常数
        Long c = new Long(String.valueOf(1));       //通过String创建对象
    }
}
```

Float

```java
public class Test04 {
    public static void main(String[] args) {
        Float a = Float.valueOf((float) 2.1);          //通过valueOf赋值
        Float b = new Float(1.5);                 //通过常数
        Float c = new Float(String.valueOf(1));       //通过String创建对象
    }
}
```

Double

```java
public class Test04 {
    public static void main(String[] args) {
        Double a = Double.valueOf((Double) 2.1);          //通过valueOf赋值
        Double b = new Double(1.5);                 //通过常数
        Double c = new Double(String.valueOf(1));       //通过String创建对象
    }
}
```

### 为什么需要包装类

Java是面向对象的语言，很多地方都是需要使用对象而不是剧本数据类型的

比如在集合类中，我们无法将int等数据类型放进去，因为集合的容器要求元素是Object类型

**为了让基本类型也具有对象特性，就出现了包装类型，丰富了基本类型的操作**



## 装箱与拆箱

​        装箱：
​                把基本类型转换为包装类的过程就是装箱

​    拆箱：
​            把包装类转换为基本数据类型就是拆箱

自动拆装箱
在JavaSE5中，为了减少开发人员的工作，Java提供了自动拆装箱功能

​    自动装箱：
​            将基本数据类型自动转化为对应的包装类

​    自动拆箱：
​            将包装类自动转化成对应的基本数据类型

自动拆装箱的实现原理
        自动装箱都是通过包装类的valueOf方法实现的

   	 自动装箱都是通过包装类对象xxxValue方法实现的(如intValue)

### 自动拆装箱使用场景

####     1.将基本类型放入集合类

​                集合类中都是对象类型，但是我们add(基本数据类型)也不会报错，是因为Java给我们做了自动装箱

####     2.包装类型和基本类型比较大小

​            包装类与基本数据类型进行比较运算，先将包装类进行拆箱成基本数据类型，然后比较

####     3.包装类型的运算

​            对两个包装类型进行运算，会将包装类型自动拆箱为基本类型进行

####     4.三目运算符的使用

​            如

```java
falg?i:j
```

####      5.函数参数与返回值

```java
//自动拆箱
public int getNum1(Integer num) {
 return num;
}
//自动装箱
public Integer getNum2(int num) {
 return num;
}
```

### 自动拆装箱与缓存

在Java SE5中，Integer操作引入了新功能来节省内存和提高性能

​    ==**1.适用于整数区间-128~+127**==

​    ==**2.只适用于自动装箱，使用构造函数创建对象不适用**==

​    ==**3.只适用于整形，浮点型不行**==

```java
public class Test04 {
    public static void main(String[] args) {
        //不创建对象且在-128~127中
        Integer a = 1;
        Integer b = 1;
        System.out.println(a == b);        //true
        //创建对象且在-128~127中
        Integer c = new Integer(1);
        Integer d = new Integer(1);
        System.out.println(c == d);        //fasle
        //不创建对象且不在-128~127中
        Integer e = 200;
        Integer f = 200;
        System.out.println(e == f);        //false
    }
}
```

 ==自动拆装箱带来的问题==
    ==**1.包装对象之间的数值比较不能简单的使用==，除了特殊情况(如Integer的-128~127),其他比较都需要使用equals比较**==

​    ==**2.如果包装类对象为NULL，那么自动拆箱就可能会抛出NPE**==

​    ==**3.如果一个for循环中有大量拆装箱操作，会浪费很多资源**==



-----



# [Java中的自动装箱与拆箱](https://www.cnblogs.com/jingzh/p/15414355.html)

# 1 自动装箱与拆箱

## 1.1 简单理解

自动装箱和拆箱从`Java 1.5`开始引入，目的是将原始类型值自动地转换成对应的对象。自动装箱与拆箱的机制可以让我们在`Java`的变量赋值或者是方法调用等情况下使用原始类型或者对象类型更加简单直接。

如果在`Java1.5`下进行过编程的话，你一定不会陌生这一点，你不能直接地向集合(`Collections`)中放入原始类型值，因为集合只接收对象。通常这种情况下的做法是，将这些原始类型的值转换成对象，然后将这些转换的对象放入集合中。使用`Integer,Double,Boolean`等这些类我们可以将原始类型值转换成对应的对象，但是从某些程度可能使得代码不是那么简洁精炼。为了让代码简练，`Java 1.5`引入了具有在原始类型和对象类型自动转换的装箱和拆箱机制。但是自动装箱和拆箱并非完美，在使用时需要有一些注意事项，如果没有搞明白自动装箱和拆箱，可能会引起难以察觉的`bug`。

## 1.2 什么是自动装箱和拆箱

自动装箱就是`Java`自动将原始类型值转换成对应的对象，比如将`int`的变量转换成`Integer`对象，这个过程叫做`装箱`，反之将`Integer`对象转换成`int`类型值，这个过程叫做`拆箱`。
因为这里的装箱和拆箱是自动进行的非人为转换，所以就称作为自动装箱和拆箱。原始类型`byte,short,char,int,long,float,double和boolean`对应的封装类分别为`Byte,Short,Character,Integer,Long,Float,Double,Boolean`

## 1.3 自动装箱拆箱要点

自动装箱拆箱要点：

- 自动装箱时编译器调用`valueOf`将原始类型值转换成对象，同时自动拆箱时，编译器通过调用类似`intValue()`,`doubleValue()`等这类的方法将对象转换成原始类型值。
- 自动装箱是将`boolean`值转换成`Boolean`对象，`byte`值转换成`Byte`对象，`char`转换成`Character`对象，`float`值转换成`Float`对象，`int`转换成`Integer`，`long`转换成`Long`，`short`转换成`Short`，自动拆箱则是相反的操作。

## 1.4 何时发生自动装箱和拆箱

自动装箱和拆箱在`Java`中很常见，比如我们有一个方法，接受一个对象类型的参数，如果我们传递一个原始类型值，那么`Java`会自动将这个原始类型值转换成与之对应的对象。最经典的一个场景就是当我们向`ArrayList`这样的容器中增加原始类型数据时或者是创建一个参数化的类，比如下面的`ThreadLocal`

```java
ArrayList<Integer> intList = new ArrayList<Integer>();
intList.add(1); //autoboxing - primitive to object
intList.add(2); //autoboxing

ThreadLocal<Integer> intLocal = new ThreadLocal<Integer>();
intLocal.set(4); //autoboxing

int number = intList.get(0); // unboxing
int local = intLocal.get(); // unboxing in Java
```

举例说明：
上面的部分我们介绍了自动装箱和拆箱以及它们何时发生，我们知道了自动装箱主要发生在两种情况，一种是`赋值`时，另一种是在`方法调用`的时候。为了更好地理解这两种情况，我们举例进行说明。

### 1.4.1 赋值时

这是最常见的一种情况，在`Java 1.5`以前需要手动地进行转换才行，而现在所有的转换都是由编译器来完成

```java
//before autoboxing
Integer iObject = Integer.valueOf(3);
Int iPrimitive = iObject.intValue()

//after java5
Integer iObject = 3; //autobxing - primitive to wrapper conversion
int iPrimitive = iObject; //unboxing - object to primitive conversion
```

### 1.4.2 方法调用时

这是另一个常用的情况，当在方法调用时，可以传入原始数据值或者对象，同样编译器会帮我们进行转换。

```java
public static Integer show(Integer iParam){
   System.out.println("autoboxing example - method invocation i: " + iParam);
   return iParam;
}

//autoboxing and unboxing in method invocation
show(3); //autoboxing
int result = show(3); //unboxing because return type of method is Integer
```

`show`方法接受`Integer`对象作为参数，当调用`show(3)`时，会将`int`值转换成对应的`Integer`对象，这就是所谓的自动装箱，`show`方法返回`Integer`对象，而`int result = show(3);`中`result`为`int`类型，所以这时候发生自动拆箱操作，将`show`方法的返回的`Integer`对象转换成`int`值。

## 1.5 自动装箱的弊端

自动装箱有一个问题，那就是在一个循环中进行自动装箱操作的情况，如下面的例子就会创建多余的对象，影响程序的性能。

```java
Integer sum = 0;
for(int i=1000; i<5000; i++){
   sum+=i;
}
```

上面的代码`sum+=i`可以看成`sum = sum + i`，但是`+`这个操作符不适用于`Integer`对象，首先`sum`进行自动拆箱操作，进行数值相加操作，最后发生自动装箱操作转换成`Integer`对象。其内部变化如下

```java
sum = sum.intValue() + i;
Integer sum = new Integer(result);
```

由于我们这里声明的`sum`为`Integer`类型，在上面的循环中会创建将近`4000`个无用的`Integer`对象，在这样庞大的循环中，会降低程序的性能并且加重了垃圾回收的工作量。因此在编程时，需要注意到这一点，正确地声明变量类型，避免因为自动装箱引起的性能问题。

因为自动装箱会隐式地创建对象，像前面提到的那样，如果在一个循环体中，会创建无用的中间对象，这样会增加`GC`压力，拉低程序的性能。所以在写循环时一定要注意代码，避免引入不必要的自动装箱操作

## 1.6 重载与自动装箱

当重载遇上自动装箱时，情况会比较有些复杂，可能会让人产生有些困惑。在`1.5`之前，`value(int)`和`value(Integer)`是完全不相同的方法，开发者不会因为传入是`int`还是`Integer`调用哪个方法困惑，但是由于自动装箱和拆箱的引入，处理重载方法时稍微有点复杂。一个典型的例子就是`ArrayList`的`remove`方法，它有`remove(index)`和`remove(Object)`两种重载，可能会有一点小小的困惑，其实这种困惑是可以验证并解开的，通过下面的例子我们可以看到，当出现这种情况时，不会发生自动装箱操作。

```java
private void add(Integer a){
        System.out.println("====");
    };
    private void add(int a){
        System.out.println("------");
    };
    @Test
    public void testOverride(){
        DateDemo test = new DateDemo();
        test.add(1);//------
        test.add(Integer.valueOf(1));//====
    }
```

重载时传入`int a`和`Integer a`是两个不同的方法，根据传入基本类型或者包装类型来判断走哪个方法

```java
public class AutoboxingTest {
    public static void main(String args[]) {
        // Example 1: == comparison pure primitive – no autoboxing
        int i1 = 1;
        int i2 = 1;
        System.out.println("i1==i2 : " + (i1 == i2)); // true

        // Example 2: equality operator mixing object and primitive
        Integer num1 = 1; // autoboxing
        int num2 = 1;
        System.out.println("num1 == num2 : " + (num1 == num2)); // true

        // Example 3: special case - arises due to autoboxing in Java
        Integer obj1 = 1; // autoboxing will call Integer.valueOf()
        Integer obj2 = 1; // same call to Integer.valueOf() will return same
                            // cached Object

        System.out.println("obj1 == obj2 : " + (obj1 == obj2)); // true

        // Example 4: equality operator - pure object comparison
        Integer one = new Integer(1); // no autoboxing
        Integer anotherOne = new Integer(1);
        System.out.println("one == anotherOne : " + (one == anotherOne)); // false

    }

}

Output:
i1==i2 : true
num1 == num2 : true
obj1 == obj2 : true
one == anotherOne : false
```

值得注意的是第三个小例子，这是一种极端情况。`obj1`和`obj2`的初始化都发生了自动装箱操作。但是处于节省内存的考虑，==**`JVM`会缓存`-128`到`127`的`Integer`对象**==。因为`obj1`和`obj2`实际上是同一个对象。所以使用`==`比较返回`true`。

## 1.7 容易混乱的对象和原始数据值

另一个需要避免的问题就是混乱使用对象和原始数据值，一个具体的例子就是当在一个原始数据值与一个对象进行比较时，如果这个对象没有进行初始化或者为`Null`，在自动拆箱过程中`obj.xxxValue`，会抛出`NullPointerException`,如下面的代码

```java
private static Integer count;

//NullPointerException on unboxing
if( count <= 0){
  System.out.println("Count is not started yet");
}
```

## 1.8 缓存的对象

这个问题就是我们上面提到的极端情况，在`Java`中，会对`-128`到`127`的`Integer`对象进行缓存，当创建新的`Integer`对象时，如果符合这个这个范围，并且已有存在的相同值的对象，则返回这个对象，否则创建新的`Integer`对象。

在`Java`中另一个节省内存的例子就是字符串常量池,感兴趣的同学可以了解一下[字符串详解](https://jingzh.blog.csdn.net/article/details/88333936)

