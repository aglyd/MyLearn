# 一、[Java中double转BigDecima导致精度损失](https://blog.csdn.net/u013467442/article/details/89450580)

## 1.楔子

服务中如下的代码出现了诡异的不相等问题? 最后发现是[double](https://so.csdn.net/so/search?q=double&spm=1001.2101.3001.7020)转bigDecimal时精度损失导致。代码和现象如下：

```java
    @Test
public void doubleToDecimal() {
    double amountDouble = 16.67;
    BigDecimal amountDecimal = new BigDecimal("16.67");
    System.out.println(amountDecimal.compareTo(new BigDecimal(amountDouble)));

    System.out.println("amountDouble: " + amountDouble);
    System.out.println("amountDecimal: " + amountDecimal);
    System.out.println("new BigDecimal(amountDouble): " + new BigDecimal(amountDouble));
    System.out.println("BigDecimal.valueOf(amountDouble): " + BigDecimal.valueOf(amountDouble));
    System.out.println("new BigDecimal(Double.toString(amountDouble)): " + new BigDecimal(Double.toString(amountDouble)));
    System.out.println("new BigDecimal(String.valueOf(amountDouble)): " + new BigDecimal(String.valueOf(amountDouble)));
}
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190422140423607.png)

上面 16.67浮点数转为new BigDecimal()时出现了精度损失，可以看到16.67变为16.6700000000000017053025658242404460906982421875，这才导致compareTo不相等。

## 2.分析和正确使用姿势

float和double类型的主要设计目标是为了科学计算和工程计算。他们执行二进制浮点运算，这是为了在广域数值范围上提供较为精确的快速近似计算而精心设计的。然而，它们没有提供完全精确的结果，所以不应该被用于要求精确结果的场合。正式场合应该使用BigDecimal。

**因为十进制的16.67本身就是无法用二进制精确表示的，也就说无论你的精度是多少位，都无法用二进制来精确表示16.67，所以对于double数字只能接近表示，这就是二进制计算机的缺点，就如同十进制也也无法表示1/3，1/6一样。如果用这个double来初始化bigDecimal的话就会出现同样的问题。**

BigDecimal的构造函数public BigDecimal(double val)会损失了double 参数的精度。jdk中已经明确不建议使用new BigDecimal(double value)这种形式的构造函数，而是使用==new BigDecimal(Stringvalue) 或BigDecimal.valueof( double value)。==

new BigDecimal(double value) javadoc如下(已经说的很明确了，会出现不可预测的情况)，不推介使用：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190422135049799.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9qaWVuaXlpbWlhby5ibG9nLmNzZG4ubmV0,size_16,color_FFFFFF,t_70)

BigDecimal.valueof( double value) 源码如下：

![在这里插入图片描述](https://img-blog.csdnimg.cn/2019042213525186.png)

该方法是推荐的从double转为BigDecimal的方法。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190422135523632.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9qaWVuaXlpbWlhby5ibG9nLmNzZG4ubmV0,size_16,color_FFFFFF,t_70)

## 3.结论

不建议使用**new BigDecimal(double value)**这种形式的构造函数，而是使用**new BigDecimal(Stringvalue)** 或**BigDecimal.valueof( double value)**。

## 4.扩展阅读

MySQL定点数据类型（精确值）-DECIMAL



---

# 二、[BigDecimal加减乘除计算](https://blog.csdn.net/haiyinshushe/article/details/82721234)

前阵子做题遇到了大数的精确计算，再次认识了bigdecimal
关于Bigdecimal意外的有许多小知识点和坑，这里特此整理一下为方便以后学习，希望能帮助到其他的萌新

## BigDecimal的运算——加减乘除

首先是bigdecimal的初始化
这里对比了两种形式，第一种直接value写数字的值，第二种用string来表示

```java
    BigDecimal num1 = new BigDecimal(0.005);
    BigDecimal num2 = new BigDecimal(1000000);
    BigDecimal num3 = new BigDecimal(-1000000);
    //尽量用字符串的形式初始化
    BigDecimal num12 = new BigDecimal("0.005");
    BigDecimal num22 = new BigDecimal("1000000");
    BigDecimal num32 = new BigDecimal("-1000000");
```
我们对其进行加减乘除绝对值的运算

其实就是Bigdecimal的类的一些调用

加法 add()函数     减法subtract()函数

乘法multiply()函数    除法divide()函数    绝对值abs()函数

我这里承接上面初始化Bigdecimal分别用string和数进行运算对比

```java
    //加法
    BigDecimal result1 = num1.add(num2);
    BigDecimal result12 = num12.add(num22);
 
    //减法
    BigDecimal result2 = num1.subtract(num2);
    BigDecimal result22 = num12.subtract(num22);
 
    //乘法
    BigDecimal result3 = num1.multiply(num2);
    BigDecimal result32 = num12.multiply(num22);
 
    //绝对值
    BigDecimal result4 = num3.abs();
    BigDecimal result42 = num32.abs();
 
    //除法
    BigDecimal result5 = num2.divide(num1,20,BigDecimal.ROUND_HALF_UP);
    BigDecimal result52 = num22.divide(num12,20,BigDecimal.ROUND_HALF_UP);
```
我把result全部输出可以看到结果

这里出现了差异，这也是为什么初始化建议使用string的原因



※ 注意：
1）System.out.println()中的数字默认是double类型的，double类型小数计算不精准。

2）使用BigDecimal类构造方法传入double类型时，计算的结果也是不精确的！

**因为不是所有的浮点数都能够被精确的表示成一个double 类型值，有些浮点数值不能够被精确的表示成 double 类型值，因此它会被表示成与它最接近的 double 类型的值。必须改用传入String的构造方法。这一点在BigDecimal类的构造方法注释中有说明。**

完整的test代码如下：



```java
import java.math.BigDecimal;
import java.util.Scanner;

public class TestThree {
public static void main(String[] args) {
 
    BigDecimal num1 = new BigDecimal(0.005);
    BigDecimal num2 = new BigDecimal(1000000);
    BigDecimal num3 = new BigDecimal(-1000000);
    //尽量用字符串的形式初始化
    BigDecimal num12 = new BigDecimal("0.005");
    BigDecimal num22 = new BigDecimal("1000000");
    BigDecimal num32 = new BigDecimal("-1000000");
 
    //加法
    BigDecimal result1 = num1.add(num2);
    BigDecimal result12 = num12.add(num22);
    //减法
    BigDecimal result2 = num1.subtract(num2);
    BigDecimal result22 = num12.subtract(num22);
    //乘法
    BigDecimal result3 = num1.multiply(num2);
    BigDecimal result32 = num12.multiply(num22);
    //绝对值
    BigDecimal result4 = num3.abs();
    BigDecimal result42 = num32.abs();
    //除法
    BigDecimal result5 = num2.divide(num1,20,BigDecimal.ROUND_HALF_UP);
    BigDecimal result52 = num22.divide(num12,20,BigDecimal.ROUND_HALF_UP);
 
    System.out.println("加法用value结果："+result1);
    System.out.println("加法用string结果："+result12);
 
    System.out.println("减法value结果："+result2);// -999999
    System.out.println("减法用string结果："+result22);// -999999.995
 
    System.out.println("乘法用value结果："+result3);
    System.out.println("乘法用string结果："+result32);
 
    System.out.println("绝对值用value结果："+result4);
    System.out.println("绝对值用string结果："+result42);
 
    System.out.println("除法用value结果："+result5);//199999999.99999999583666365766
    System.out.println("除法用string结果："+result52);//200000000.00000000000000000000
}
}
```
除法divide()参数使用
使用除法函数在divide的时候要设置各种参数，要精确的小数位数和舍入模式，不然会出现报错

我们可以看到divide函数配置的参数如下



即为 （BigDecimal divisor 除数， int scale 精确小数位，  int roundingMode 舍入模式）
可以看到舍入模式有很多种BigDecimal.ROUND_XXXX_XXX, 具体都是什么意思呢



计算1÷3的结果（最后一种ROUND_UNNECESSARY在结果为无限小数的情况下会报错）



## 八种舍入模式解释如下

### 1、ROUND_UP

舍入远离零的舍入模式。

在丢弃非零部分之前始终增加数字(始终对非零舍弃部分前面的数字加1)。

注意，此舍入模式始终不会减少计算值的大小。

### 2、ROUND_DOWN

接近零的舍入模式。

在丢弃某部分之前始终不增加数字(从不对舍弃部分前面的数字加1，即截短)。

注意，此舍入模式始终不会增加计算值的大小。

### 3、ROUND_CEILING

接近正无穷大的舍入模式。

如果 BigDecimal 为正，则舍入行为与 ROUND_UP 相同;

如果为负，则舍入行为与 ROUND_DOWN 相同。

注意，此舍入模式始终不会减少计算值。

### 4、ROUND_FLOOR

接近负无穷大的舍入模式。

如果 BigDecimal 为正，则舍入行为与 ROUND_DOWN 相同;

如果为负，则舍入行为与 ROUND_UP 相同。

注意，此舍入模式始终不会增加计算值。

### 5、ROUND_HALF_UP

向“最接近的”数字舍入，如果与两个相邻数字的距离相等，则为向上舍入的舍入模式。

如果舍弃部分 >= 0.5，则舍入行为与 ROUND_UP 相同;否则舍入行为与 ROUND_DOWN 相同。

注意，这是我们大多数人在小学时就学过的舍入模式(四舍五入)。

### 6、ROUND_HALF_DOWN

向“最接近的”数字舍入，如果与两个相邻数字的距离相等，则为上舍入的舍入模式。

如果舍弃部分 > 0.5，则舍入行为与 ROUND_UP 相同;否则舍入行为与 ROUND_DOWN 相同(五舍六入)。

### 7、ROUND_HALF_EVEN

向“最接近的”数字舍入，如果与两个相邻数字的距离相等，则向相邻的偶数舍入。

如果舍弃部分左边的数字为奇数，则舍入行为与 ROUND_HALF_UP 相同;

如果为偶数，则舍入行为与 ROUND_HALF_DOWN 相同。

注意，在重复进行一系列计算时，此舍入模式可以将累加错误减到最小。

此舍入模式也称为“银行家舍入法”，主要在美国使用。四舍六入，五分两种情况。

如果前一位为奇数，则入位，否则舍去。

以下例子为保留小数点1位，那么这种舍入方式下的结果。

1.15>1.2 1.25>1.2

### 8、ROUND_UNNECESSARY

断言请求的操作具有精确的结果，因此不需要舍入。

如果对获得精确结果的操作指定此舍入模式，则抛出ArithmeticException。



---



# 三、[BigDecimal 工具类解决运算double数据精度丢失（加减乘除）](https://www.cnblogs.com/ChiRain/p/6211412.html)

```java
package com.qcloud.component.publicservice.util;

import java.math.BigDecimal;

/** 
* 由于Java的简单类型不能够精确的对浮点数进行运算，这个工具类提供精 
* 确的浮点数运算，包括加减乘除和四舍五入。 
*/
public class Arith {

    // 默认除法运算精度
    private static final int DEF_DIV_SCALE = 10;

    /** 
     * 提供精确的加法运算。 
     * @param v1 被加数 
     * @param v2 加数 
     * @return 两个参数的和 
     */
    public static double add(double v1, double v2) {

        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.add(b2).doubleValue();
    }

    /** 
     * 提供精确的减法运算。 
     * @param v1 被减数 
     * @param v2 减数 
     * @return 两个参数的差 
     */
    public static double sub(double v1, double v2) {

        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.subtract(b2).doubleValue();
    }

    /** 
     * 提供精确的乘法运算。 
     * @param v1 被乘数 
     * @param v2 乘数 
     * @return 两个参数的积 
     */
    public static double mul(double v1, double v2) {

        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.multiply(b2).doubleValue();
    }

    /** 
     * 提供（相对）精确的除法运算，当发生除不尽的情况时，精确到 
     * 小数点以后10位，以后的数字四舍五入。 
     * @param v1 被除数 
     * @param v2 除数 
     * @return 两个参数的商 
     */
    public static double div(double v1, double v2) {

        return div(v1, v2, DEF_DIV_SCALE);
    }

    /** 
     * 提供（相对）精确的除法运算。当发生除不尽的情况时，由scale参数指 
     * 定精度，以后的数字四舍五入。 
     * @param v1 被除数 
     * @param v2 除数 
     * @param scale 表示表示需要精确到小数点以后几位。 
     * @return 两个参数的商 
     */
    public static double div(double v1, double v2, int scale) {

        if (scale < 0) {
            throw new IllegalArgumentException("The scale must be a positive integer or zero");
        }
        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.divide(b2, scale, BigDecimal.ROUND_HALF_UP).doubleValue();
    }

    /** 
     * 提供精确的小数位四舍五入处理。 
     * @param v 需要四舍五入的数字 
     * @param scale 小数点后保留几位 
     * @return 四舍五入后的结果 
     */
    public static double round(double v, int scale) {

        if (scale < 0) {
            throw new IllegalArgumentException("The scale must be a positive integer or zero");
        }
        BigDecimal b = new BigDecimal(Double.toString(v));
        BigDecimal one = new BigDecimal("1");
        return b.divide(one, scale, BigDecimal.ROUND_HALF_UP).doubleValue();
    }
};
```



----



# 四、[BigDecimal保留两位小数及格式化成百分比](https://blog.csdn.net/m0_37044606/article/details/76461569)

在项目中经常会用到小数的一些计算，而float和double类型的主要设计目标是为了科学计算和工程计算。他们执行二进制浮点运算，这是为了在广域数值范围上提供较为精确的快速近似计算而精心设计的。然而，它们没有提供完全精确的结果，所以不应该被用于要求精确结果的场合。但是，商业计算往往要求结果精确。所以有时候必须要采用BigDecimal。

```java
public class Demo {
   public static void main(String[] args) {
  BigDecimal a =null;
  Integer faultRate = 6;
  a = BigDecimal.valueOf(faultRate.doubleValue()/3);
  BigDecimal  b =a.setScale(2, RoundingMode.HALF_UP);//保留两位小数
  System.out.println("结果是"+b);		//2.00
  //下面将结果转化成百分比
  NumberFormat percent = NumberFormat.getPercentInstance();
       percent.setMaximumFractionDigits(2);

   System.out.println(percent.format(b.doubleValue()));	//200%

}
}
```

运行结果是：



BigDecimal.setScale()方法用于格式化小数点
setScale(1)表示保留一位小数，默认用四舍五入方式 
setScale(1,BigDecimal.ROUND_DOWN)直接删除多余的小数位，如2.35会变成2.3 
setScale(1,BigDecimal.ROUND_UP)进位处理，2.35变成2.4 
setScale(1,BigDecimal.ROUND_HALF_UP)四舍五入，2.35变成2.4

setScaler(1,BigDecimal.ROUND_HALF_DOWN)四舍五入，2.35变成2.3，如果是5则向下舍

setScaler(1,BigDecimal.ROUND_CEILING)接近正无穷大的舍入

setScaler(1,BigDecimal.ROUND_FLOOR)接近负无穷大的舍入，数字>0和ROUND_UP作用一样，数字<0和ROUND_DOWN作用一样

setScaler(1,BigDecimal.ROUND_HALF_EVEN)向最接近的数字舍入，如果与两个相邻数字的距离相等，则向相邻的偶数舍入。



注释：
1：scale指的是你小数点后的位数。比如123.456则score就是3.
score()就是BigDecimal类中的方法啊。
比如:BigDecimal b = new BigDecimal("123.456");
b.scale(),返回的就是3.
2：roundingMode是小数的保留模式。它们都是BigDecimal中的常量字段,有很多种。
比如：BigDecimal.ROUND_HALF_UP表示的就是4舍5入。
3：**pubilc BigDecimal divide(BigDecimal divisor, int scale, int roundingMode)**
**的意思是说：我用一个BigDecimal对象除以divisor后的结果，并且要求这个结果保留有scale个小数位，roundingMode表示的就是保留模式是什么，是四舍五入啊还是其它的，你可以自己选！**
4：对于一般add、subtract、multiply方法的小数位格式化如下：

BigDecimal mData = new BigDecimal("9.655").setScale(2, BigDecimal.ROUND_HALF_UP);
        System.out.println("mData=" + mData);
----结果：----- mData=9.66



----



# 五、[BigDecimal千分位使用](https://blog.csdn.net/zflovecf/article/details/89145475)

```
package com.test;

import java.math.[BigDecimal](https://so.csdn.net/so/search?q=BigDecimal&spm=1001.2101.3001.7020);
import java.text.DecimalFormat;

public class test {undefined
  /*关于数字格式化：java.text.DecimalFormat;

  数字格式元素：
      \# 任意数字
      , 千分位
      . 小数点
      0 不够补0
    */

  public static void main(String[] args) {undefined
    //1.创建数字格式化对象
    //需求：加入千分位.
    DecimalFormat df = new DecimalFormat("###,###");
    //开始格式化
    System.out.println(df.format(1234567)); //"1,234,567"

​    //需求：加入千分位，保留2位小数
​    DecimalFormat df1 = new DecimalFormat("###,###.##");
​    System.out.println(df1.format(1234567.123)); //"1,234,567.12"

​    //需求：加入千分位，保留4位小数，并且不够补0
​    DecimalFormat df2 = new DecimalFormat("###,###.0000");
​    System.out.println(df2.format(1234567.123));//"1,234,567.1230"

​    //创建大数据.
​    BigDecimal v1 = new BigDecimal(10);
​    BigDecimal v2 = new BigDecimal(20);
​    //做加法运算
​    //v1 + v2; //错误:两个引用类型不能做加法运算.
​    //必须调用方法执行加法运算.
​    BigDecimal v3 = v1.add(v2);
​    System.out.println(v3); //30
  }
}
```

