# [Java中可变长参数的使用及注意事项](https://www.cnblogs.com/lanxuezaipiao/p/3190673.html)

在Java5 中提供了变长参数（varargs），也就是在方法定义中可以使用个数不确定的参数，对于同一方法可以使用不同个数的参数调用，例如print("hello");print("hello","lisi");print("hello","张三", "alexia");下面介绍如何定义可变长参数 以及如何使用可变长参数。

1. **可变长参数的定义**

**使用...表示可变长参数**，例如

print(String... args){

  ...

}

在具有可变长参数的方法中可以把参数当成数组使用，例如可以循环输出所有的参数值。

print(String... args){

  for(String temp:args)

   System.out.println(temp);

}

2. **可变长参数的方法的调用**

调用的时候可以给出任意多个参数也可不给参数，例如：

print();

print("hello");

print("hello","lisi");

print("hello","张三", "alexia")

\3. 可变长参数的使用规则

**3.1 在调用方法的时候，如果能够和固定参数的方法匹配，也能够与可变长参数的方法匹配，则选择固定参数的方法。看下面代码的输出：**



```
package com;

// 这里使用了静态导入
import static java.lang.System.out;

public class VarArgsTest {

    public void print(String... args) {
        for (int i = 0; i < args.length; i++) {
            out.println(args[i]);
        }
    }

    public void print(String test) {
        out.println("----------");
    }

    public static void main(String[] args) {
        VarArgsTest test = new VarArgsTest();
        test.print("hello");
        test.print("hello", "alexia");
    }
}
```



![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAPgAAABMCAIAAADP6O0/AAACNUlEQVR4nO3dQXKqQBSGUdfVC3I9vRo2w2LMRBGlaZBS817+c0YpUpEMPqmbpG/ldIEAp9/+BuAbhE4EoRNB6EQQOhE6oQ/n05Pz8Jev85d5ohNB6EQQOhGETgShE0HoRBA6EYROBKETQehEEDoRhE6E1dDHWl4+7nQ7LlXquOs6fEvviT7WcuBc31hLM+i16/AFQifCVui1luWh7XG6eDqVuvyq/aHfX2jxOvBGG6FPc/U803mxYy1Pg/z+0Gu5T+1jLVrnc3aPLsP5GvT8cd7a0Nkb+mIwGs5GGz7lUOjdR6/Q+Qe9HvrlsphWnr9q9+gyvzCcjS58zMbv0a9zybRPfA38cb/4Gujry8iPU5AVZT7HX0aJIHQiCJ0IQieC0IkgdCIInQhCJ8Kh0C1S8L85/kR/1/ny4ewNw8f9fujwBd3QZ6dUlk03Qm8uZNwuljpOHz8dmVnbMTUd8S790IfpnNXyxGL/NOLDQsZ4W7EYa1kc3mq8Ybr3hQP2PtGXpwsb58s7CxnXzzYe0K3Qe/eFA9ZDf1ySmx1Hv3/+OfT1A+XTu2B7BNq6LxzQDf1xzt4xurSjnO+DzvdE26+zdV84oDe6zH8mLGWaIjr/1a2xkNFc4Ch17LzOyn3hOH8ZJYLQiSB0IgidCEIngtCJIHQiCJ0IQieC0IkgdCIInQhCJ4LQiSB0IgidCEIngtCJIHQiCJ0IQieC0IkgdCIInQhCJ4LQiSB0IgidCEIngtCJIHQi/ABvACclY6uKBQAAAABJRU5ErkJggg==)

**3.2 如果要调用的方法可以和两个可变参数匹配，则出现错误，例如下面的代码：**



```
package com;

// 这里使用了静态导入
import static java.lang.System.out;

public class VarArgsTest1 {

    public void print(String... args) {
        for (int i = 0; i < args.length; i++) {
            out.println(args[i]);
        }
    }

    public void print(String test,String...args ){
          out.println("----------");
    }

    public static void main(String[] args) {
        VarArgsTest1 test = new VarArgsTest1();
        test.print("hello");
        test.print("hello", "alexia");
    }
}
```



对于上面的代码，main方法中的两个调用都不能编译通过，因为编译器不知道该选哪个方法调用，如下所示：

![img](data:image/png;base64,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)

**3.3 一个方法只能有一个可变长参数，并且这个可变长参数必须是该方法的最后一个参数**

以下两种方法定义都是错误的。

```
 public void test(String... strings,ArrayList list){
 
 }
 
 public void test(String... strings,ArrayList... list){
 
 }
```



**4. 可变长参数的使用规范**

**4.1 避免带有可变长参数的方法重载：如3.1中，编译器虽然知道怎么调用，但人容易陷入调用的陷阱及误区**

**4.2 别让null值和空值威胁到变长方法，如3.2中所示，为了说明null值的调用，重新给出一个例子：**



```
package com;public class VarArgsTest1 {

    public void print(String test, Integer... is) {
        
    }

    public void print(String test,String...args ){
          
    }

    public static void main(String[] args) {
        VarArgsTest1 test = new VarArgsTest1();
        test.print("hello");
        test.print("hello", null);
    }
}
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

这时会发现两个调用编译都不通过：

![img](data:image/png;base64,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)

因为两个方法都匹配，编译器不知道选哪个，于是报错了，这里同时还有个非常不好的编码习惯，即调用者隐藏了实参类型，这是非常危险的，不仅仅调用者需要“猜测”该调用哪个方法，而且被调用者也可能产生内部逻辑混乱的情况。对于本例来说应该做如下修改：

```
    public static void main(String[] args) {
        VarArgsTest1 test = new VarArgsTest1();
        String[] strs = null;
        test.print("hello", strs);
    }
```

**4.3 覆写变长方法也要循规蹈矩**

下面看一个例子，大家猜测下程序能不能编译通过：



```
package com;

public class VarArgsTest2 {

    /**
     * @param args
     */
    public static void main(String[] args) {
        // TODO Auto-generated method stub
        // 向上转型
        Base base = new Sub();
        base.print("hello");
        
        // 不转型
        Sub sub = new Sub();
        sub.print("hello");
    }

}

// 基类
class Base {
    void print(String... args) {
        System.out.println("Base......test");
    }
}

// 子类，覆写父类方法
class Sub extends Base {
    @Override
    void print(String[] args) {
        System.out.println("Sub......test");
    }
}
```



答案当然是编译不通过，是不是觉得很奇怪？

![img](data:image/png;base64,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)

 

第一个能编译通过，这是为什么呢？事实上，base对象把子类对象sub做了向上转型，形参列表是由父类决定的，当然能通过。而看看子类直接调用的情况，这时编译器看到子类覆写了父类的print方法，因此肯定使用子类重新定义的print方法，尽管参数列表不匹配也不会跑到父类再去匹配下，因为找到了就不再找了，因此有了类型不匹配的错误。

这是个特例，覆写的方法参数列表竟然可以与父类不相同，这违背了覆写的定义，并且会引发莫名其妙的错误。

这里，总结下覆写必须满足的条件：

（1）重写方法不能缩小访问权限；

**（2）参数列表必须与被重写方法相同（包括显示形式）；**

（3）返回类型必须与被重写方法的相同或是其子类；

（4）重写方法不能抛出新的异常，或者超过了父类范围的异常，但是可以抛出更少、更有限的异常，或者不抛出异常。

 

最后，给出一个有陷阱的例子，大家应该知道输出结果：



```
package com;

public class VarArgsTest {
    public static void m1(String s, String... ss) {
        for (int i = 0; i < ss.length; i++) {
            System.out.println(ss[i]);
        }
    }

    public static void main(String[] args) {

        m1("");
        m1("aaa");
        m1("aaa", "bbb");
    }
}
```