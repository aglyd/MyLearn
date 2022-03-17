# [Java之泛型 T与T的用法](https://www.cnblogs.com/jpfss/p/9929108.html)

> `<T> T`表示返回值是一个泛型，传递啥，就返回啥类型的数据，而单独的`T`就是表示限制你传递的参数类型，这个案例中，通过一个泛型的返回方式，获取每一个集合中的第一个数据， 通过返回值`<T> T` 和`T`的两种方法实现

## `<T> T` 用法

这个`<T> T` 表示的是返回值T是泛型，T是一个占位符，用来告诉编译器，这个东西先给我留着，等我编译的时候，告诉你。

```java
package com.yellowcong.test;

import java.util.ArrayList;
import java.util.List;

import org.apache.poi.ss.formula.functions.T;

public class Demo {

    public static void main(String[] args) {

        Demo demo = new Demo();

        //获取string类型
        List<String> array = new ArrayList<String>();
        array.add("test");
        array.add("doub");
        String str = demo.getListFisrt(array);
        System.out.println(str);

        //获取nums类型
        List<Integer> nums = new ArrayList<Integer>();
        nums.add(12);
        nums.add(13);

        Integer num = demo.getListFisrt(nums);
        System.out.println(num);
    }

    /**
     * 这个<T> T 可以传入任何类型的List
     * 参数T
     *     第一个 表示是泛型
     *     第二个 表示返回的是T类型的数据
     *     第三个 限制参数类型为T
     * @param data
     * @return
     */
    private <T> T getListFisrt(List<T> data) {
        if (data == null || data.size() == 0) {
            return null;
        }
        return data.get(0);
    }

}
```

## T 用法

返回值，直接写`T`表示限制参数的类型，这种方法一般多用于共同操作一个类对象，然后获取里面的集合信息啥的。

```java
package com.yellowcong.test;

import java.util.ArrayList;
import java.util.List;

public class Demo2<T> {

    public static void main(String[] args) {

        //限制T 为String 类型
        Demo2<String> demo = new Demo2<String>();

        //获取string类型
        List<String> array = new ArrayList<String>();
        array.add("test");
        array.add("doub");
        String str = demo.getListFisrt(array);
        System.out.println(str);

        //获取Integer类型 T 为Integer类型
        Demo2<Integer> demo2 = new Demo2<Integer>();
        List<Integer> nums = new ArrayList<Integer>();
        nums.add(12);
        nums.add(13);
        Integer num = demo2.getListFisrt(nums);
        System.out.println(num);
    }

    /**
     * 这个只能传递T类型的数据
     * 返回值 就是Demo<T> 实例化传递的对象类型
     * @param data
     * @return
     */
    private T getListFisrt(List<T> data) {
        if (data == null || data.size() == 0) {
            return null;
        }
        return data.get(0);
    }
}
```

![微信截图_20210521160047](C:\Users\sever\Desktop\微信截图_20210521160047.png)



## 类型擦除原则







---

# 二、[Java中的泛型方法](https://www.cnblogs.com/iyangyuan/archive/2013/04/09/3011274.html)

 泛型是什么意思在这就不多说了，而Java中泛型类的定义也比较简单，例如：public class Test<T>{}。这样就定义了一个泛型类Test，在实例化该类时，必须指明泛型T的具体类型，例如：Test<Object> t = new Test<Object>();，指明泛型T的类型为Object。

​    但是Java中的泛型方法就比较复杂了。

​    泛型类，是在实例化类的时候指明泛型的具体类型；泛型方法，是在调用方法的时候指明泛型的具体类型。

 

​    **定义泛型方法**语法格式如下：

![img](Java之泛型 T与T的用法.assets/09221852-b0d764f4340946baa1a063da5a0d993e.png)

   

​    **调用泛型方法**语法格式如下：

![img](Java之泛型 T与T的用法.assets/09222350-5e3bf238febe4b2ebba99973c69e0054.png)

 

​    说明一下，定义泛型方法时，必须在返回值前边加一个<T>，来声明这是一个泛型方法，持有一个泛型T，然后才可以用泛型T作为方法的返回值。

​    Class<T>的作用就是指明泛型的具体类型，而Class<T>类型的变量c，可以用来创建泛型类的对象。

​    为什么要用变量c来创建对象呢？既然是泛型方法，就代表着我们不知道具体的类型是什么，也不知道构造方法如何，因此没有办法去new一个对象，但可以利用变量c的newInstance方法去创建对象，也就是利用反射创建对象。

​    泛型方法要求的参数是Class<T>类型，而Class.forName()方法的返回值也是Class<T>，因此可以用Class.forName()作为参数。其中，forName()方法中的参数是何种类型，返回的Class<T>就是何种类型。在本例中，forName()方法中传入的是User类的完整路径，因此返回的是Class<User>类型的对象，因此调用泛型方法时，变量c的类型就是Class<User>，因此泛型方法中的泛型T就被指明为User，因此变量obj的类型为User。

​    当然，泛型方法不是仅仅可以有一个参数Class<T>，可以根据需要添加其他参数。

​    为什么要使用泛型方法呢？因为泛型类要在实例化的时候就指明类型，如果想换一种类型，不得不重新new一次，可能不够灵活；而泛型方法可以在调用的时候指明类型，更加灵活。

 

**附：Java****泛型方法演示代码。**

[点击下载](http://pan.baidu.com/share/link?shareid=383851&uk=1394763765)



----

# 三、[Java 泛型方法](https://blog.csdn.net/weixin_43819113/article/details/91042598)
