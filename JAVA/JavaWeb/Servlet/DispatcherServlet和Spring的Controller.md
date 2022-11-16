# [Servlet 和 Controller](https://www.cnblogs.com/huainanyin/p/15936212.html)

先上结论：

Controller是spring 的一个bean，由spring的IOC来管理的一个bean

Servlet是一个接口或者接口的实现（常见的是GenericServlet 和 HttpServlet）

 

HttpServlet做的事情：

首先，有一个映射关系servlet-mapping，url的endpoint 对应的具体的servlet， 比如规定'/lalala' 映射到KevinServlet（继承自HttpServlet，重写doGet，doPost等方法）

传送门（https://blog.csdn.net/zj12352123/article/details/80576748）,映射规则的定义，如果是老的Spring项目的话是写在web.xml

![img](https://img2022.cnblogs.com/blog/2306836/202202/2306836-20220225142546585-1492548115.png)

 

那你在浏览器地址栏输入localhost:8088/lalala   , 这个请求就会执行到KevinServlet的doGet方法，经过一系列逻辑，最终将要返回给浏览器的数据写入HttpServletResponse，这样浏览器就能收到结果。

 

而Controller，只是一个bean，方法上可以加上注解GetMapping，PostMapping等，标注映射的url的endpoint

![img](https://img2022.cnblogs.com/blog/2306836/202202/2306836-20220225142915669-1123276756.png)

 

 那请求是怎么到达Controller的具体某个方法的呢

Servlet容器（Tomcat等）接收到请求以后，将请求交给DispatcherServlet的service方法来处理，servlet会在doDispatch里面先找到mappedHandler ，然后找到HandlerAdapter

```java
mappedHandler = this.getHandler(processedRequest);
HandlerAdapter ha = this.getHandlerAdapter(mappedHandler.getHandler());
```

调用HandlerAdapter 的handle方法，其实应该是AbstractHandlerMethodAdapter，
然后调用到RequestMappingHandlerAdapter的handleInternal，最终调用到invokeAndHandle，反射调用controller的方法

具体的时序图
https://blog.csdn.net/caoyuanyenang/article/details/114401414

找到endpoint对应的bean的方法，并调用。

容器==》DispatcherServlet (service方法) ==》 doDispatcher ==》HandlerAdapter （handle）=》AbstractHandlerMethodAdapter==》RequestMappingHandlerAdapter

 ==》invokeAndHandle==》反射具体的controller方法

 

handlerMappings  代码中所有的controller的带MappingRequest注解的方法
HandlerExecutionChain getHandler 根据请求中的endpoint，匹配到controller的带MappingRequest注解的方法



# [Spring提供的DispatcherServlet是怎么调用我们的Controller里的业务接口的？](https://blog.csdn.net/caoyuanyenang/article/details/114401414)



# [DispatcherServlet详解](https://blog.csdn.net/weixin_44399827/article/details/119279667)