# @PostConstruct

@PostConstruct注解好多人以为是Spring提供的。其实是Java自己的注解。

1、从Java EE5规范开始，Servlet中增加了两个影响Servlet生命周期的注解，@PostConstruct和@PreDestroy，这两个注解被用来修饰**一个非静态的void（）方法**。写法有如下两种方式：



@PostConstruct

public void someMethod(){}

或者

public @PostConstruct void someMethod(){}

被@PostConstruct修饰的方法会在服务器加载Servlet的时候运行，并且只会被服务器执行一次。PostConstruct在构造函数之后执行，init（）方法之前执行。PreDestroy（）方法在destroy（）方法知性之后执行

![img](https:////upload-images.jianshu.io/upload_images/7987747-143d3cc59a925d87.png?imageMogr2/auto-orient/strip|imageView2/2/w/228/format/webp)

该注解的方法在整个Bean初始化中的执行顺序：

spring中Constructor、@Autowired、@PostConstruct的顺序

Constructor(构造方法) -> @Autowired(依赖注入) -> @PostConstruct(注释的方法)

###  作用：

@PostConstruct注解的方法在项目启动的时候执行这个方法，也可以理解为在spring容器启动的时候执行，可作为一些数据的常规化加载，比如数据字典之类的。

其实从依赖注入的字面意思就可以知道，要将对象p注入到对象a，那么首先就必须得生成对象a和对象p，才能执行注入。所以，如果一个类A中有个成员变量p被@Autowried注解，那么@Autowired注入是发生在A的构造方法执行完之后的。

如果想在生成对象时完成某些初始化操作，而偏偏这些初始化操作又依赖于依赖注入，那么就无法在构造函数中实现。为此，可以使用@PostConstruct注解一个方法来完成初始化，@PostConstruct注解的方法将会在依赖注入完成后被自动调用。

Constructor >> @Autowired >> @PostConstruct

举个栗子：

```java
public Class AAA {

  @Autowired

  private BBB b;



  public AAA() {

​    System.out.println("此时b还未被注入: b = " + b);

  }

  @PostConstruct

  private void init() {

​    System.out.println("@PostConstruct将在依赖注入完成后被自动调用: b = " + b);

  }

}
```

项目启动时（容器启动加载时），依赖注入完成后被自动调用该方法