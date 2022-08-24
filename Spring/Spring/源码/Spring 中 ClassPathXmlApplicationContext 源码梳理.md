# [spring源码梳理（一）ClassPathXmlApplicationContext](https://www.jianshu.com/p/203bb56e2390)

**环境搭建**

1.在idea中创建一个maven工程

​       相信大家都很熟悉，所以本文中略过。

2.创建一个java类

![img](https:////upload-images.jianshu.io/upload_images/10134684-8529ad3eedc3dfc8.png?imageMogr2/auto-orient/strip|imageView2/2/w/835/format/webp)



3.创建SpringBean配置文件

![img](https:////upload-images.jianshu.io/upload_images/10134684-a97b9216617879b6.png?imageMogr2/auto-orient/strip|imageView2/2/w/859/format/webp)



4.pom文件

![img](https:////upload-images.jianshu.io/upload_images/10134684-dfe9881943e6a6de.png?imageMogr2/auto-orient/strip|imageView2/2/w/605/format/webp)



说明：项目目录如下：其中MyApp类是和App类类似可以不用管。

![img](https:////upload-images.jianshu.io/upload_images/10134684-0f084fc7ea48d681.png?imageMogr2/auto-orient/strip|imageView2/2/w/1110/format/webp)

进入spring源码--debug调试

首先我们要从main入口开始，进入ClassPathXmlApplicationContext类，如图：

![img](https:////upload-images.jianshu.io/upload_images/10134684-278d308b3de61f16.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



然后进入到如下如代码部分：

![img](https:////upload-images.jianshu.io/upload_images/10134684-cf823cd36c1c41bc.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



调用自己的构造函数，传入configLocation配置文件信息，此处configLocation=SpringBean.xml,一个refresh参数为true，还一个空的上下文对象，然后进入：

![img](https:////upload-images.jianshu.io/upload_images/10134684-6cc5fcd2017a58d7.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



这是refresh参数用到了，进入if逻辑，调用一个refresh方法，在此之前setConfigLocations主要是加载Spring配置文件的位置。下面是refresh方法代码如下：

![img](https:////upload-images.jianshu.io/upload_images/10134684-d3b8cf59740ccec1.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



其中，核心方法this.obtainFreshBeanFactory()，进入到这个方法代码如下：

![img](https:////upload-images.jianshu.io/upload_images/10134684-e0e647762533514c.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



主要有两个方法this.refreshBeanFactory()和this.getBeanFactory(),其中refreshBeanFactory()代码如下：

![img](https:////upload-images.jianshu.io/upload_images/10134684-b187b762474cd009.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



总的来说ClassPathXmlApplicationContext 这种形式的Spring配置文件的加载主要是下面的过程：

A：加载配置文件名到系统配置

B：销毁已有的Beans和BeanFactory

C：创建新的BeanFactory

D：加载Beans，分析Bean中的节点，然后加载到BeanFactory，BeanFactory生效。





# [Spring 中 ClassPathXmlApplicationContext 类的简单使用](https://blog.csdn.net/qq_37960603/article/details/82709660)

**博主的学习记录**

- [Docker汇总](https://kaven.blog.csdn.net/article/details/109941236)
- [Redis汇总](https://kaven.blog.csdn.net/article/details/109820272)
- [Vue汇总](https://kaven.blog.csdn.net/article/details/109508022)
- [MyBatis Plus汇总](https://kaven.blog.csdn.net/article/details/108982474)
- [微服务汇总](https://kaven.blog.csdn.net/article/details/109063924)
- [Java网络编程汇总](https://kaven.blog.csdn.net/article/details/104140118)
- [Java设计模式汇总](https://kaven.blog.csdn.net/article/details/104109975)
- [Java并发编程汇总](https://kaven.blog.csdn.net/article/details/104233588)
- [消息中间件汇总](https://kaven.blog.csdn.net/article/details/104223534)

[原文地址](http://www.blogjava.net/xcp/archive/2011/06/22/352821.html)

一、简单的用 [ApplicationContext](https://so.csdn.net/so/search?q=ApplicationContext&spm=1001.2101.3001.7020) 做测试的话 , 获得 Spring 中定义的 Bean 实例(对象) 可以用：

```java
ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
1
```

如果是两个以上 , 可以使用字符串数组 ：

```java
ApplicationContext context = new ClassPathXmlApplicationContext(new String[]{"applicationContext.xml","SpringTest.xml"});
1
```

或者可以使用通配符：

```java
ApplicationContext context = new ClassPathXmlApplicationContext("classpath:/*.xml");
1
```

对于 ClassPathXmlApplicationContext 的使用：

1. `classpath:` 前缀是可加可不加的 , 默认就是指项目的 classpath 路径下面。
2. 如果要使用绝对路径 , 需要加上 `file:` , 前缀表示这是绝对路径。

对于 FileSystemXmlApplicationContext 的使用：

1. 没有盘符的是项目工作路径 , 即项目的根目录。
2. 有盘符表示的是文件绝对路径 ，`file:` 可加可不加。
3. 如果要使用 classpath 路径 , 需要前缀 `classpath:`。

```java
public class SpringTest {
  public static void main(String[] args) {
    // 用classpath路径
    // ApplicationContext context = new ClassPathXmlApplicationContext("classpath:appcontext.xml");
    // ApplicationContext context = new ClassPathXmlApplicationContext("appcontext.xml");

    // ClassPathXmlApplicationContext使用了file前缀是可以使用绝对路径的
    // ApplicationContext context = new ClassPathXmlApplicationContext("file:F:/workspace/example/src/appcontext.xml");

    // 用文件系统的路径,默认指项目的根路径
    // ApplicationContext context = new FileSystemXmlApplicationContext("src/appcontext.xml");
    // ApplicationContext context = new FileSystemXmlApplicationContext("webRoot/WEB-INF/appcontext.xml");


    // 使用了classpath:前缀,这样,FileSystemXmlApplicationContext也能够读取classpath下的相对路径
    // ApplicationContext context = new FileSystemXmlApplicationContext("classpath:appcontext.xml");
    // ApplicationContext context = new FileSystemXmlApplicationContext("file:F:/workspace/example/src/appcontext.xml");

    // 不加file前缀
    ApplicationContext context = new FileSystemXmlApplicationContext("F:/workspace/example/src/appcontext.xml");
  }
}
```





# [classpath:和classpath*:的区别](https://blog.csdn.net/qq_42449963/article/details/105443891)

## 1、classpath是什么

classpath是指编译之后的target中的classes目录，该目录中存放的内容和源程序中对应的例子如下：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200410225549957.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQyNDQ5OTYz,size_16,color_FFFFFF,t_70)

## 2、classpath:和classpath*:的区别

**classpath： 只会到你的target下面的class路径中查找找文件**

**classpath*：**

**（1）不仅包含target下面的class路径，还包括jar文件中(target下面的class路径)进行查找；**

**（2）当项目中有多个classpath路径（不是xml文件，而是包含xml文件的路径），并同时加载多个classpath路径下的所有xml文件，就发挥了作用，如果不加*，也就是只使用classpath，则表示仅仅加载匹配到的第一个classpath路径**

## 3、总结

两者的区别可以用下面这三种情况概述：

如果类路径中没有通配符，那我们使用classpath就可以了；

如果类路径中有通配符，但是通配符只能匹配到一个类路径（类路径不是xml文件），那我们使用classpath就可以了；

如果类路径中有通配符，但是通配符可以匹配到多个类路径，那我们只能使用classpath*，它可以匹配全部的类路径中的xml文件，但是classpath只能匹配到第一个类路径中的所有xml文件

所以无论哪种情况，我们使用classpath*是没有错误的

下面是spring官网中的解释：

![在这里插入图片描述](https://img-blog.csdnimg.cn/e4a4a5426829411c9af9f535c91bf7f6.png)





