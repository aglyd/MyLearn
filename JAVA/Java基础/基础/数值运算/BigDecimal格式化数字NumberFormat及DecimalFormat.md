# 一、[BigDecimal保留两位小数及格式化成百分比](https://blog.csdn.net/m0_37044606/article/details/76461569)

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
       percent.setMaximumFractionDigits(2);		//用于设置数字的小数部分中允许的最大位数

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



## Java计算百分比补0和去0

```java
      //    getPercentInstance  百分比        
        DecimalFormat numberFormat=(DecimalFormat)NumberFormat.getPercentInstance(Locale.CHINA);
        //最多两个小数 大于两位小数最多显示两位    
        numberFormat.setMaximumFractionDigits(2);
        System.err.println("两位小数:"+numberFormat.format(0.9));	//结果 90%
		System.err.println("两位小数:"+numberFormat.format(0.092310));	//结果 9.23%

        //最少两个小数 不足两位小数必须补 0   
        numberFormat.setMinimumFractionDigits(2);
        System.err.println("两位小数:"+numberFormat.format(0.9));	//结果 90.00%

```



----



# 二、[BigDecimal千分位使用](https://blog.csdn.net/zflovecf/article/details/89145475)

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



-----

# 三、[java格式化数字 NumberFormat及DecimalFormat](https://blog.csdn.net/a1064072510/article/details/89887633)

## 前言

以前用到要对数字格式的地方，都是直接到网上搜一下。拿过来能用就行。因为平时用的不多。但是最近的项目对这个用的多了。网上拿来的不够用了。自己看了java源码把这方面恶补了。而且最近也好长时间没有写博客了。正好写一篇抛砖引玉吧。

如果你只想知道怎么用，可以直接看下面使用示例↓↓↓。三分钟速成。

## 正文

如果你对java源码比较了解。你会发现java对文字，数字的格式化，是有一个公共的父类的Format。
NumberFormat和DecimalFormat都是它的子类**==关于数字的==**。
DateFormat和SimpleDateFormat也是它的子类**==关于文字的==**。

当然今天只说NumberFormat和DecimalFormat。相信我，当你搞懂这两个以后，那么DateFormat和SimpleDateFormat也是肯定会的。

首先，要特别注意的是 **==NumberFormat和DecimalFormat是线程不安全的==**。 这意味你如果同时有多个线程操作一个format实例对象，会出现意想不到的结果。
解决方法有两个：

为每个线程都创建一个 format实例，通过ThreadLocal 来给每个线程都产生一个本地实例。如果你对ThreadLocal不了解，可以看我这篇博客
[ThreadLocal 的用法以及内存泄露（内存溢出）](https://blog.csdn.net/a1064072510/article/details/87563169)
进行外部同步，这个就可以通过关键词 synchronized来进行同步。如果 你不了解synchronized，可以看我这篇博客[synchronized 参数 及其含义](https://blog.csdn.net/a1064072510/article/details/84065646)
上面的这两种方法呢，
第一种方法 **比较占用内存多，但是速度快，效率高。并发。**第二种方法 **占用内存少，效率低，耗费时间长，毕竟要排队嘛，串行。**具体取舍，看项目的情况。

## JavaAPI官方描述

### NumberFormat

NumberFormat帮助您格式化和解析任何区域设置的数字。您的代码可以完全独立于小数点，千位分隔符的区域设置约定，甚至是使用的特定十进制数字，或者数字格式是否为十进制。

### DecimalFormat

DecimalFormat是NumberFormat十进制数字格式的具体子类 。它具有多种功能，旨在解析和格式化任何语言环境中的数字，包括支持西方，阿拉伯语和印度语数字。它还支持不同类型的数字，包括整数（123），定点数（123.4），科学记数法（1.23E4），百分比（12％）和货币金额（123美元）。所有这些都可以本地化。

### NumberFormat

#### 获取NumberFormat实例

```java
//创建 一个整数格式 地区用系统默认的
NumberFormat integerNumber = NumberFormat.getIntegerInstance(Locale.getDefault());
```

使用getInstance或getNumberInstance获取正常的数字格式。
使用getIntegerInstance得到的整数格式。
使用getCurrencyInstance来获取货币数字格式。
使用getPercentInstance获取显示百分比的格式。

#### 常用方法

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190506135256366.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ExMDY0MDcyNTEw,size_16,color_FFFFFF,t_70)

由于API 的描述足够详细，所以我就直接截图上来了。

#### 使用示例

DecimalFormat是NumberFormat，所以，就不要单独的为NumberFormat写一个完整的示例了。只写一下配合FieldPosition怎么使用的示例：

```java
NumberFormat numberFormat = NumberFormat.getInstance(Locale.getDefault());
//整数部分不会每隔三个，就会有 " ,"
numberFormat.setGroupingUsed(false);
//线程安全的字符串缓冲类
StringBuffer stringBuffer = new StringBuffer();
//构造参数 是Format子类里面的 自己特有的参数，传入就行
//构造 小数部分的，所以开始 beginIndex（）是从小数点 后面算的，  但是0是从整个格式化数字，第一个算起， 包括 之间用于分组的 " ,"
FieldPosition fieldPosition = new FieldPosition(NumberFormat.FRACTION_FIELD);
stringBuffer = numberFormat.format(1234.56789, stringBuffer, fieldPosition);
System.out.println(stringBuffer.toString());	//1234.568
//小数部分， 所以 从5 开始
System.out.println(fieldPosition.getBeginIndex() + "   " + fieldPosition.getEndIndex());//5		8
//切割字符串
System.out.println(stringBuffer.toString().substring(fieldPosition.getBeginIndex()));//568
```

运行结果

### DecimalFormat

#### 获取DecimalFormat实例

要获取特定地区(包括默认地区)的NumberFormat，请调用NumberFormat的工厂方法之一，例如getInstance()。通常，不要直接调用DecimalFormat构造函数，因为NumberFormat工厂方法可能返回DecimalFormat之外的子类。如果需要自定义format对象，可以这样做:

```java
        try {
            NumberFormat f = NumberFormat.getInstance(Locale.getDefault());
            if (f instanceof DecimalFormat) {
                ((DecimalFormat) f).setDecimalSeparatorAlwaysShown(true);
                //写具体的代码
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
```

#### 设置Pattern

DecimalFormat作为NumberFormat的具体实现子类，最大的特点就是 可以使用Pattern。来实现最大程度的对数据格式进行定制。
一个Pattern中的许多字符是按字面意思理解的;它们在解析期间匹配，在格式化期间输出不变,就是字符在Pattern中 不影响最后的数字格式化另一方面，特殊字符代表其他字符、字符串或字符类。如果要以文字形式出现在前缀或后缀中，必须引用它们(除非另有说明)。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190506145233442.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ExMDY0MDcyNTEw,size_16,color_FFFFFF,t_70)

#### 子类特有的方法

因为懒，而且这玩意是在简单，大家就将就看个截图吧。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190506145317432.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ExMDY0MDcyNTEw,size_16,color_FFFFFF,t_70)

#### 使用示例

接下来就是万众瞩目的示例代码了，只要java基础可以，一开始看这个完全就可以学会用法。

通用格式

```java
        //创建一个默认的通用格式
        NumberFormat numberFormat = NumberFormat.getInstance();
        DecimalFormat numberDecimalFormat;
        //捕捉异常，以防强制类型转换出错
        try {
            //强制转换成DecimalFormat
            numberDecimalFormat = (DecimalFormat) numberFormat;
            //保留小数点后面三位，不足的补零,前面整数部分 每隔四位 ，用 “,” 符合隔开
            numberDecimalFormat.applyPattern("#,####.000");
            //设置舍入模式 为DOWN,否则默认的是HALF_EVEN
            numberDecimalFormat.setRoundingMode(RoundingMode.DOWN);
            //设置 要格式化的数 是正数的时候。前面加前缀
            numberDecimalFormat.setPositivePrefix("Prefix  ");
            System.out.println("正数前缀  "+numberDecimalFormat.format(123456.7891));
            //设置 要格式化的数 是正数的时候。后面加后缀
            numberDecimalFormat.setPositiveSuffix("  Suffix");
            System.out.println("正数后缀  "+numberDecimalFormat.format(123456.7891));
            //设置整数部分的最大位数
            numberDecimalFormat.setMaximumIntegerDigits(3);
            System.out.println("整数最大位数 "+numberDecimalFormat.format(123456.7891));
            //设置整数部分最小位数
            numberDecimalFormat.setMinimumIntegerDigits(10);
            System.out.println("整数最小位数 "+numberDecimalFormat.format(123456.7891));
            //设置小数部分的最大位数
            numberDecimalFormat.setMaximumFractionDigits(2);
            System.out.println("小数部分最大位数 "+numberDecimalFormat.format(123.4));
            //设置小数部分的最小位数
            numberDecimalFormat.setMinimumFractionDigits(6);
            System.out.println("小数部分最小位数 "+numberDecimalFormat.format(123.4));
        }catch (Exception e){
            e.printStackTrace();
        }

```

运行结果
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190506160849756.png)

## 获取百分比格式

对数字 进行 百分比 格式化

```java
        //创建一个中国地区的 百分比格式
        NumberFormat perFormat = NumberFormat.getPercentInstance(Locale.CHINA);
        DecimalFormat percentFormat;
        try {
            percentFormat = (DecimalFormat) perFormat;
            //设置Pattern 会使百分比格式，自带格式失效
//            percentFormat.applyPattern("##.00");
            //设置小数部分 最小位数为2
            percentFormat.setMinimumFractionDigits(2);
            System.out.println(percentFormat.format(0.912345));
        } catch (Exception e) {
            e.printStackTrace();
        }
```

运行结果：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190506162612849.png)

## 货币格式

```java
        //创建一个中国地区的 货币格式
        NumberFormat curFormat = NumberFormat.getCurrencyInstance(Locale.CHINA);
        DecimalFormat currencyFormat;
        try {
            currencyFormat = (DecimalFormat) curFormat;
            //设置Pattern 会使百分比格式，自带格式失效
//            currencyFormat.applyPattern("##.00");
            System.out.println(currencyFormat.format(0.912345));
            //乘法 数乘以多少 这个方法是 百分比时候 设置成100   km时候 是1000
            currencyFormat.setMultiplier(100);
            System.out.println(currencyFormat.format(0.912345));
        } catch (Exception e) {
            e.printStackTrace();
        }
```

运行结果：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190506163801854.png)

## 整数格式

因为它很简单，作用就是只解析 整数部分的。小数部分的会被舍入。
例如 “3456.78”→3456（并且在索引6之后保留解析位置）



----

# 四、函数 toPlainString() 和 toString()区别

对得到的数据用科学计数法就用：String toPlainString() 返回不带指数字段的此 BigDecimal 的字符串表示形式。**通俗来讲就是直接显示，不用科学计数法表示。**

```java
import java.math.BigDecimal;
public class BigDecimalDemo {
    public static void main(String[] args) {
        BigDecimal bg = new BigDecimal("1E11");	
        System.out.println(bg.toEngineeringString());	//100E+9
        System.out.println(bg.toPlainString());		// 100000000000
        System.out.println(bg.toString());			//1E+11
    }
}
```



----

# 五、[BigDecimal去掉小数点后无用的0](https://blog.csdn.net/qq_31564573/article/details/105534900)

比如：数据库存储的是Decimal(5,2)类型保留两位数。
如果展示数据5.00，5.10等字样感觉很不爽，如何做呢？
只战术5和5.1

解决：BigDecimal，有方法解决stripTrailingZeros()

看源码：

```java


/**
     * Returns a string representation of this {@code BigDecimal}
     * without an exponent field.  For values with a positive scale,
     * the number of digits to the right of the decimal point is used
     * to indicate scale.  For values with a zero or negative scale,
     * the resulting string is generated as if the value were
     * converted to a numerically equal value with zero scale and as
     * if all the trailing zeros of the zero scale value were present
     * in the result.
     *
     * The entire string is prefixed by a minus sign character '-'
     * (<tt>'&#92;u002D'</tt>) if the unscaled value is less than
     * zero. No sign character is prefixed if the unscaled value is
     * zero or positive.
     *
     * Note that if the result of this method is passed to the
     * {@linkplain #BigDecimal(String) string constructor}, only the
     * numerical value of this {@code BigDecimal} will necessarily be
     * recovered; the representation of the new {@code BigDecimal}
     * may have a different scale.  In particular, if this
     * {@code BigDecimal} has a negative scale, the string resulting
     * from this method will have a scale of zero when processed by
     * the string constructor.
     *
     * (This method behaves analogously to the {@code toString}
     * method in 1.4 and earlier releases.)
     *
     * @return a string representation of this {@code BigDecimal}
     * without an exponent field.
     * @since 1.5
     * @see #toString()
     * @see #toEngineeringString()
     */
    public String toPlainString() {
        if(scale==0) {
            if(intCompact!=INFLATED) {
                return Long.toString(intCompact);
            } else {
                return intVal.toString();
            }
        }
        if(this.scale<0) { // No decimal point
            if(signum()==0) {
                return "0";
            }
            int tailingZeros = checkScaleNonZero((-(long)scale));
            StringBuilder buf;
            if(intCompact!=INFLATED) {
                buf = new StringBuilder(20+tailingZeros);
                buf.append(intCompact);
            } else {
                String str = intVal.toString();
                buf = new StringBuilder(str.length()+tailingZeros);
                buf.append(str);
            }
            for (int i = 0; i < tailingZeros; i++)
                buf.append('0');
            return buf.toString();
        }
        String str ;
        if(intCompact!=INFLATED) {
            str = Long.toString(Math.abs(intCompact));
        } else {
            str = intVal.abs().toString();
        }
        return getValueString(signum(), str, scale);
    }
 /**
     * Returns a {@code BigDecimal} which is numerically equal to
     * this one but with any trailing zeros removed from the
     * representation.  For example, stripping the trailing zeros from
     * the {@code BigDecimal} value {@code 600.0}, which has
     * [{@code BigInteger}, {@code scale}] components equals to
     * [6000, 1], yields {@code 6E2} with [{@code BigInteger},
     * {@code scale}] components equals to [6, -2].  If
     * this BigDecimal is numerically equal to zero, then
     * {@code BigDecimal.ZERO} is returned.
     *
     * @return a numerically equal {@code BigDecimal} with any
     * trailing zeros removed.
     * @since 1.5
     */
    public BigDecimal stripTrailingZeros() {
        if (intCompact == 0 || (intVal != null && intVal.signum() == 0)) {
            return BigDecimal.ZERO;
        } else if (intCompact != INFLATED) {
            return createAndStripZerosToMatchScale(intCompact, scale, Long.MIN_VALUE);
        } else {
            return createAndStripZerosToMatchScale(intVal, scale, Long.MIN_VALUE);
        }
    }

```

## demo

```java
public class StringUtils {

    public static void main(String[] args) {
        System.out.println(BigDecimal.ZERO);		//0
        System.out.println(new BigDecimal("2.0"));	//2.0
        System.out.println(new Double("0"));		//0.0
        System.out.println(new BigDecimal("2.00"));	//2.00
        String d = new BigDecimal("100.10").stripTrailingZeros().toPlainString();
        System.out.println(d);		//100.1
        System.out.println(new BigDecimal("100.10").stripTrailingZeros().toPlainString());	//100.1
    }
}
```
## 方法二：

```java
 private static final DecimalFormat decimalFormat = new DecimalFormat("###################.###########");

    public static void main(String[] args) throws Exception{
        System.out.print( "格式化结果:");
        System.out.println(decimalFormat.format(new BigDecimal("10.10")));		//10.1
    }
```

