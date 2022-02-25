# [Java之泛型 T与T的用法](https://www.cnblogs.com/jpfss/p/9929108.html)

> `<T> T`表示返回值是一个泛型，传递啥，就返回啥类型的数据，而单独的`T`就是表示限制你传递的参数类型，这个案例中，通过一个泛型的返回方式，获取每一个集合中的第一个数据， 通过返回值`<T> T` 和`T`的两种方法实现

## `<T> T` 用法

这个`<T> T` 表示的是返回值T是泛型，T是一个占位符，用来告诉编译器，这个东西先给我留着，等我编译的时候，告诉你。

```
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

```
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

