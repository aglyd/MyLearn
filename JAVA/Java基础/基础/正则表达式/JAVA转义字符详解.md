# 一、[JAVA转义字符详解](https://blog.csdn.net/xxdw1992/article/details/105899612)

## 1、JAVA中反斜杠“\”的作用

在不同的系统中，路径的分隔符不同，故需要做出判断，并切换分隔符

VBS代码中确实不用转义，但是在JAVA或JS中，它采用的是C语言的语法，所以要转义，引号内要双写\\表示一个反\。

① java 把字符串中的反斜杠（\）替换成（\\）

replaceAll里面用的是正则表达式，所以字符串转义一次，正则转义一次，所以一个斜扛要写4个，用replaceAll( "\\\\ ",   "\\\\\\\\ ");

## 2、split("\\.")什么意思

1. 首先要明白split方法的参数含义：
public String[] split(String regex)根据给定的正则表达来式的匹配来拆分此字符串

2. 然后就要明确正则表达式的含义了：

'.'点 匹配除“\n”和"\r"之外的任何单个字符。

'\'表示转义字符

\\会转义成反斜杠，反斜杠本身就是转义符，所有就成了“\.”，在进行转义就是.，所以\\.实际上是“.”

## 3、正则表达式

正则表达式，又称规则表达式。（英语：Regular Expression，在代码中常简写为regex、regexp或RE），计算机科学的一个概念。正则表达式通常被用来检索、替换那些符合某个模式(规则)的文本。

许多程序设专计语言都支持利用正则表达式进行字符串操作。例如，在Perl中就内建了一个功能强大的正则表达式引擎。正则表达式这个概念最初是由属Unix中的工具软件（例如sed和grep）普及开的。正则表达式通常缩写成“regex”，单数有regexp、regex，复数有regexps、regexes、regexen。

## 4、Java中转义字符反斜杠 \ 的代替方法 | repalceAll 内涵解析

### 4.1需求

现有一个字符串str

String str = "{\\\"name\\\":\\\"spy\\\",\\\"id\\\\":\\\"123456\\\"}";
System.out.println("str = " + str);
在控制台的输出为:

str = {\"name\":\"spy\",\"id\":\"123456\"}
目标：将str转化为标准的json格式串str1，以调用JsonUtil的方法，将字符串转为map。即目标str1为：

str1 = {"name":"spy","id":"123456"}

### 4.2实现方法

![watermar](JAVA转义字符详解.assets/watermar.png)

### 4.3Java 的replaceAll 内涵解析

使用Java的replaceAll(String regex, String replacement)函数，即用replacement替换所有的regex匹配项，regex是一个正则表达式，replacement是字符串。

String str = "{\\\"name\\\":\\\"spy\\\",\\\"id\\\\":\\\"123456\\\"}";

（1）对于串str，Java将其进行转义，\\ 表示 \ ，\” 表示 ” ，故而在Java内存中即为：
{\”name\”:\”spy\”,\”id\”:\”123456\”}，然而，我们的目标是 {“name”:”spy”,”id”:”123456”}，即将转义字符 \ 替换为空。

（2）**Java的replaceAll(String regex, String replacement)函数，第一个参数是一个正则表达式。在正则表达式中的“\”与后面紧跟的那个字符构成一个转义字符，代表着特殊的意义，比如”\n”表示换行符等。所以，如果要在正则表达式中表示一个反斜杠\，则应当用\\表达 。但参数regex 首先会经过Java的一次转义，若想表达两个反斜杠 \\，则需四个反斜杠。**

综上所述**：replaceAll 的第一个参数是正则表达式，故而要经过两次转义，一次Java、一次正则。**因此就需要四个反斜杠才可以匹配一个反斜杠。故而，替换一个反斜杠为空的replaceAll的代码即为：
str1 = str.replaceAll("\\\\","");

### 4.4补充说明

![img](JAVA转义字符详解.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3h4ZHcxOTky,size_16,color_FFFFFF,t_70.png)


参考网址：

https://blog.csdn.net/proteen/article/details/78885867

https://blog.csdn.net/north_easter/article/details/7904865

五.网址带中文问题
java.net.URLEncoder.encode(“xxxx”,“utf-8”)将中文转为16进制字符。

java.net.URLDncoder.decode(“xxxx”,“utf-8”)将16进制字符转为中文。

5.1实战
后台传回的网址：http://192.168.1.17:8096/detection-admin\video\2020\11\4\浙B99939\3604252011040004\浙B99939_1_PDASP_01.mp4

通过工具类转换：

```java
/**
 * @author Longchengbin
 * @description 将网址反斜杠转成正斜杠并将中文转为16进制字符
 * @since 2020-11-4 16:33
 **/
public static String decode(String url) {
    String[] strings = url.split("\\\\");
    String s1 = strings[strings.length - 1];
    String s2 = strings[strings.length - 3];
    String s = "";
    try {
        //将反斜杠替换成正斜杠
        s = url.replaceAll("\\\\", "/").
                //将中文转成16进制字符
                        replace(s1, URLEncoder.encode(s1, "utf-8")).replace(s2, URLEncoder.encode(s2, "utf-8"));
        LogUtils.w(s);
    } catch (UnsupportedEncodingException e) {
        LogUtils.e("网址转换报错：" + e.toString());
    }
    return s;
}
```
转换后：

http://192.168.1.17:8096/detection-admin/video/2020/11/4/%E6%B5%99B99939/3604252011040004/%E6%B5%99B99939_1_PDASP_01.mp4

