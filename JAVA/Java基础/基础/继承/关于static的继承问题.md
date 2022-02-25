# [关于static的继承问题](https://www.cnblogs.com/xujingyang/p/6505197.html)

```java
//父类
package com.xujingyang.test;

public class Father {
    public static String staticString="父类中的静态变量";
    public  String str="父类中的非静态变量";

    public static  void staticMethod(){
        System.out.println("父类中的静态方法");
    }
    public   void nostaticMethod() {
        System.out.println("父类中的非静态方法");
    }
}


//子类
package com.xujingyang.test;

public class Son extends Father {
    public static String staticString="子类中的静态变量";
    public  String str="子类中的非静态变量";

    public static  void staticMethod(){
        System.out.println("子类中的静态方法");
    }
    public   void nostaticMethod() {
        System.out.println("子类中的非静态方法");
    }
}



//子类

package com.xujingyang.test;

public class A extends Father{

}




//测试方法
package com.xujingyang.test;

public class Test {
    public static void main(String[] args) {
        Son son=new Son();
        System.out.println(son.str);
        System.out.println(son.staticString);
        son.staticMethod();
        son.nostaticMethod();
        System.out.println("==============================");
        Father f=new Son();
        System.out.println(f.str);
        System.out.println(f.staticString);
        f.staticMethod();
        f.nostaticMethod();
        System.out.println("==============================");
        A f2=new A();
        System.out.println(f2.str);
        System.out.println(f2.staticString);
        f2.staticMethod();
        f2.nostaticMethod();
    }
}
```

结果如下:

![img](https://images2015.cnblogs.com/blog/784014/201703/784014-20170305134232548-300978206.png)

 

　　　　**得出如下结论:父类中的静态成员变量和方法是可以被子类继承的,但是不能被自己重写,无法形成多态.**

　　　　**我发现,变量时无法形成多态的,网上别人说,子类把父类的变量继承过来,内存中会存在两个同名的变量,父类的变量会出现在子类变量之前.如下图:**

　　　　![img](https://images2015.cnblogs.com/blog/784014/201703/784014-20170305134912751-920315340.png)

 



==父类静态方法可以被覆盖，允许在子类中定义同名的静态方法，但是没有多态。==



---

# [static与继承](https://blog.csdn.net/baidu_38400166/article/details/81393766)

```





静态代码块、代码块、构造方法的执行次序
  编译生成.class文件时，就确定程序运行所需要的所有文件。当程序运行时，虚拟机会优先加载程序运行所需要的类和文件。
  以类为例：
   a.程序运行会优先将父类加载进入方法区，父类中的静态代码块（包含静态变量、静态方法）会优先执行，然后执行子类的静态代码块。
   b.静态代码块的执行先于程序入口的执行。
   c.当创建子类对象时，会依据编译时生成的父子关系，优先创建父类对象。
   d.创建父类对象时，若父类中存在非静态代码块，则优先执行该代码块（代码块一般是对成员变量做初始化），然后执行类构造方法。
   e.父类构造方法执行结束，创建子类对象，同理，子类中若存在非静态代码块，则优先执行该代码块，然后执行类构造方法。
```

```java
class A {
    public A()
    {
        System.out.println("A构造");
    }
    {
        System.out.println("普通代码块A");
    }
    static{
        System.out.println("静态代码块A");
    }
}
class B extends A {
    public B(){
       // super();
        System.out.println("B构造");
    }
    {
        System.out.println("普通代码块B");
    }
    static {
        System.out.println("静态代码块B");
    }
 
    public static void main(String[] args) {
        System.out.println("主方法");
        new B();
    }
}
```

代码结果为：

   静态代码块A
   静态代码块B
   主方法
   普通代码块A
   A构造
   普通代码块B
   B构造