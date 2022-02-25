# 一、[辨析Java方法参数中的值传递和引用传递 ](https://www.cnblogs.com/lingyejun/p/11028808.html)

## 小方法大门道

小瓜瓜作为一个Java初学者，今天跟我说她想通过一个Java方法，将外部变量通过参数传递到方法中去，进行逻辑处理，方法执行完毕之后，再对修改过的变量进行判断处理，代码如下所示。

```java
public class MethodParamsPassValue {
 
    public static void doErrorHandle() {
        boolean a = false;
        int b = 5;
        passBaseValue(a, b);
        if (a == true || b == 10) {
            System.out.println("Execute Something");
        } else {
            System.out.println("param result wrong");
        }
    }
 
    public static void passBaseValue(boolean flg, int num) {
        flg = true;
        num = 10;
    }
 
    public static void main(String[] args) {
        doErrorHandle();
    }
}
```

 上述代码是有问题的，布尔变量a和整型变量b在方法操作之后，它们的值并没有发生变化，小瓜瓜事与愿违。

## 究其原因

在Java方法中参数列表有两种类型的参数，基本类型和引用类型。

**基本类型：**值存放在局部变量表中，无论如何修改只会修改当前栈帧的值，方法执行结束对方法外不会做任何改变；此时需要改变外层的变量，必须返回主动赋值。

**引用数据类型：**指针存放在局部变量表中，调用方法的时候，副本引用压栈，赋值仅改变副本的引用。但是如果通过操作副本引用的值，修改了引用地址的对象，此时方法以外的引用此地址对象当然被修改。（两个引用，同一个地址，任何修改行为2个引用同时生效）。

这两种类型都是将外面的参数变量拷贝一份到局部变量中，基本类型为值拷贝，引用类型就是将引用地址拷贝一份。

## 方法参数为基本类型的值传递

```java
public class MethodParamsPassValue {
 
    public static void passBaseValue(boolean flg, int num) {
        flg = true;
        num = 10;
    }
 
    public static void main(String[] args) {
        boolean a = false;
        int b = 5;
        System.out.println("a : " + a + " b : " + b);
        passBaseValue(a, b);
        System.out.println("a : " + a + " b : " + b);
    }
}
```

 返回结果

```
a : false b : 5
a : false b : 5
```

 

![img](https://img2018.cnblogs.com/blog/1189489/201906/1189489-20190615235126801-1293925867.png)

 

\1. 方法参数flg被初始化为外部变量a的拷贝，值为false。参数num被初始化为外部变量b的拷贝，值为5。

\2. 执行方法逻辑，方法中的局部变量flg被改变为true，局部变量flg被改变为10。

3.方法执行完毕，不再局部变量不再被使用到，等待被GC回收。

 

**结论：当方法参数为基本类型时，是将外部变量值拷贝到局部变量中而进行逻辑处理的，故方法是不能修改原基本变量的。**

 

## 方法参数为包装类型的引用传递

```java
public class MethodParamsPassValue {
 
    public static void passReferenceValue(Boolean flg, Integer num) {
        flg = true;
        num = 10;
    }
 
    public static void main(String[] args) {
        Boolean a = false;
        Integer b = 5;
        System.out.println("a : " + a + " b : " + b);
        passReferenceValue(a, b);
        System.out.println("a : " + a + " b : " + b);
    }
}
```

 

结果为　　

```
a : false b : 5
a : false b : 5
```

当传入参数为包装类型时，为对象的引用地址拷贝。那么既然是引用拷贝为什么还是没有更改原来的包装类型的变量值呢？

![img](https://img2018.cnblogs.com/blog/1189489/201906/1189489-20190616075834971-917679680.png)

 

这是因为Java中的自动装箱机制，当在方法中执行 flg = true 时，实际在编译后执行的是 flg = Boolean.valueOf(true)，即又会产生一个新的Boolean对象。同理Integer num也是如此。

 

![img](https://img2018.cnblogs.com/blog/1189489/201906/1189489-20190615225402526-1346353319.png)

## 方法参数为类的对象引用时

```java
public class ParamObject {
 
    private boolean flg;
 
    private int num;
 
    public ParamObject(boolean flg, int num) {
        this.flg = flg;
        this.num = num;
    }
 
    public boolean isFlg() {
        return flg;
    }
 
    public void setFlg(boolean flg) {
        this.flg = flg;
    }
 
    public int getNum() {
        return num;
    }
 
    public void setNum(int num) {
        this.num = num;
    }
 
    @Override
    public String toString() {
        return "ParamObject{" +
                "flg=" + flg +
                ", num=" + num +
                '}';
    }
}
```

 

```java
public class MethodParamsPassValue {
 
    public static void passObjectValue(ParamObject paramObject) {
        paramObject.setFlg(true);
        paramObject.setNum(10);
    }
 
    public static void main(String[] args) {
        ParamObject a = new ParamObject(false, 5);
        System.out.println(a);
        passObjectValue(a);
        System.out.println(a);
    }
}　　
```

结果为

```
ParamObject{flg=false, num=5}
ParamObject{flg=true, num=10}
```

**结论：对于引用类型的方法参数，会将外部变量的引用地址，复制一份到方法的局部变量中，两个地址指向同一个对象。所以如果通过操作副本引用的值，修改了引用地址的对象，此时方法以外的引用此地址对象也会被修改。（两个引用，同一个地址，任何修改行为2个引用同时生效）。**

![img](https://img2018.cnblogs.com/blog/1189489/201906/1189489-20190615225431023-260029229.png)

##  脑筋急转弯之'交换两个对象'

```java
public class MethodParamsPassValue {
 
    public static void swapObjectReference(ParamObject object1, ParamObject object2) {
        ParamObject temp = object1;
        object1 = object2;
        object2 = temp;
    }
 
    public static void main(String[] args) {
        ParamObject a = new ParamObject(true, 1);
        ParamObject b = new ParamObject(false, 2);
        System.out.println("a : " + a + " b : " + b);
        swapObjectReference(a, b);
        System.out.println("a : " + a + " b : " + b);
    }
}　
```

结果为 

```
a : ParamObject{flg=true, num=1} b : ParamObject{flg=false, num=2}
a : ParamObject{flg=true, num=1} b : ParamObject{flg=false, num=2}
```

有了上面的知识之后，我们会发现这个方法中的引用地址交换，只不过是一个把戏而已，只是对方法中的两个局部变量的对象引用值进行了交换，不会对原变量引用产生任何影响的。

![img](https://img2018.cnblogs.com/blog/1189489/201906/1189489-20190615225854130-2057423924.png)

 

 

 

## 一个方法返回两个返回值

Java方法中只能Return一个返回值，那么如何在一个方法中返回两个或者多个返回值呢？我们可以通过使用泛型来定义一个二元组来达到我们的目的。

```java
public class TwoTuple<A, B> {
 
    public final A first;
 
    public final B second;
 
    public TwoTuple(A a, B b) {
        first = a;
        second = b;
    }
 
    public String toString() {
        return "(" + first + ", " + second + ")";
    }
}
```

　　

```java
public class MethodParamsPassValue {
 
    public static TwoTuple<Boolean, Integer> returnTwoResult(Boolean flg, Integer num) {
        flg = true;
        num = 10;
        return new TwoTuple<>(flg, num);
    }
 
    public static void main(String[] args) {
        TwoTuple<Boolean,Integer> result = returnTwoResult(false,5);
        System.out.println("first : " + result.first + ", second : " + result.second);
    }
}
```

　　 

## 完整代码

```java
package com.lingyejun.authenticator;
 
public class MethodParamsPassValue {
 
    public static void doErrorHandle() {
        boolean a = false;
        int b = 5;
        passBaseValue(a, b);
        if (a == true || b == 10) {
            System.out.println("Execute Something");
        } else {
            System.out.println("param result wrong");
        }
    }
 
    /**
     * 基本类型，赋值运算=，会直接改变变量的值，原来的值被覆盖掉
     * 引用类型，复制运算=，会改变引用中所保存的地址，旧地址被覆盖掉，但原来的对象不会改变。
     *
     * @param flg
     * @param num
     */
    public static void passBaseValue(boolean flg, int num) {
        flg = true;
        num = 10;
    }
 
    public static void passReferenceValue(Boolean flg, Integer num) {
        flg = true;
        num = 10;
    }
 
    public static void passObjectValue(ParamObject paramObject) {
        paramObject.setFlg(true);
        paramObject.setNum(10);
    }
 
    public static void swapObjectReference(ParamObject object1, ParamObject object2) {
        ParamObject temp = object1;
        object1 = object2;
        object2 = temp;
    }
 
    public static TwoTuple<Boolean, Integer> returnTwoResult(Boolean flg, Integer num) {
        flg = true;
        num = 10;
        return new TwoTuple<>(flg, num);
    }
 
    public static void main(String[] args) {
 
 
        doErrorHandle();
 
        System.out.println("============================");
 
        boolean initFlg = false;
        int initNum = 5;
 
        System.out.println("init flg : " + initFlg + " init num : " + initNum);
 
        passBaseValue(initFlg, initNum);
 
        System.out.println("init flg : " + initFlg + " init num : " + initNum);
 
        System.out.println("============================");
 
        Boolean referenceFlg = false;
        Integer referenceNum = 5;
 
        System.out.println("reference flg : " + referenceFlg + " reference num : " + referenceNum);
 
        passReferenceValue(referenceFlg, referenceNum);
 
        System.out.println("reference flg : " + referenceFlg + " reference num : " + referenceNum);
 
        System.out.println("============================");
 
        ParamObject paramObject = new ParamObject(false, 5);
 
        System.out.println(paramObject);
 
        passObjectValue(paramObject);
 
        System.out.println(paramObject);
 
        System.out.println("============================");
 
        ParamObject object1 = new ParamObject(true, 1);
        ParamObject object2 = new ParamObject(false, 2);
 
        System.out.println("object1 : " + object1 + " object2 : " + object2);
 
        swapObjectReference(object1, object2);
 
        System.out.println("object1 : " + object1 + " object2 : " + object2);
 
        System.out.println("============================");
 
        TwoTuple<Boolean,Integer> result = returnTwoResult(false,5);
 
        System.out.println("first : " + result.first + ", second : " + result.second);
    }
}	
```

参考文章：

https://blog.csdn.net/javazejian/article/details/51192130

https://blog.csdn.net/fenglllle/article/details/81389286

https://www.hollischuang.com/archives/2700

https://www.zhihu.com/question/31203609



----

# 二、什么是值传递，什么是引用传递？

值传递是对基本型变量而言的,传递的是该变量的一个副本,改变副本不影响原变量。引用传递一般是对于对象型变量而言的,传递的是该对象地址的一个副本, 并不是原对象本身 。一般认为,java内的基础类型数据传递都是值传递. java中实例对象的传递是引用传递   值传递和引用传递区别：

![ScreenClip1](辨析Java方法参数中的值传递和引用传递.assets/ScreenClip1.png)

![ScreenClip2](辨析Java方法参数中的值传递和引用传递.assets/ScreenClip2.png)

![ScreenClip3](辨析Java方法参数中的值传递和引用传递.assets/ScreenClip3.png)

![ScreenClip4](辨析Java方法参数中的值传递和引用传递.assets/ScreenClip4.png)

![ScreenClip4](辨析Java方法参数中的值传递和引用传递.assets/ScreenClip5.png)

**PS：String和StringBuilder、StringBuffer的区别？**

答：Java平台提供了两种类型的字符串：String和StringBuffer/StringBuilder，它们可以储存和操作字符串。其中String是只读字符串，也就意味着String引用的字符串内容是不能被改变的。而StringBuffer/StringBuilder类表示的字符串对象可以直接进行修改。StringBuilder是Java 5中引入的，它和StringBuffer的方法完全相同，区别在于它是在单线程环境下使用的，因为它的所有方面都没有被synchronized修饰，因此它的效率也比StringBuffer要高。

当对字符串进行修改的时候，需要使用 StringBuffer 和 StringBuilder 类。

和 String 类不同的是，StringBuffer 和 StringBuilder 类的对象能够被多次的修改，并且不产生新的未使用对象。

![img](辨析Java方法参数中的值传递和引用传递.assets/java-string-20201208.png)

在使用 StringBuffer 类时，每次都会对 StringBuffer 对象本身进行操作，而不是生成新的对象，所以如果需要对字符串进行修改推荐使用 StringBuffer。

StringBuilder 类在 Java 5 中被提出，它和 StringBuffer 之间的最大不同在于 StringBuilder 的方法不是线程安全的（不能同步访问）。

由于 StringBuilder 相较于 StringBuffer 有速度优势，所以多数情况下建议使用 StringBuilder 类。