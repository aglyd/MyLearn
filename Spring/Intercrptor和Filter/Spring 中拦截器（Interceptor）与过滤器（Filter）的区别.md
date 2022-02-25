# [Spring 中拦截器（Interceptor）与过滤器（Filter）的区别][[Spring 中拦截器（Interceptor）与过滤器（Filter）的区别_小爷欣欣-CSDN博客_spring拦截器和过滤器](https://blog.csdn.net/csdnliuxin123524/article/details/81950841)]

先通俗解释下：

**拦截器** ：是在面向切面编程的就是在你的service或者一个方法，前调用一个方法，或者在方法后调用一个方法比如动态代理就是拦截器的简单实现，在你调用方法前打印出字符串（或者做其它业务逻辑的操作），也可以在你调用方法后打印出字符串，甚至在你抛出异常的时候做业务逻辑的操作。

**过滤器**：是在javaweb中，你传入的request、response提前过滤掉一些信息，或者提前设置一些参数，然后再传入servlet或者struts的action进行业务逻辑，比如过滤掉非法url（不是login.do的地址请求，如果用户没有登陆都过滤掉），或者在传入servlet或者 struts的action前统一设置字符集，或者去除掉一些非法字符.。

**拦截器和过滤器比较**
①拦截器是基于[Java](http://lib.csdn.net/base/javase)的反射机制的，而过滤器是基于函数回调。
②拦截器不依赖与servlet容器，依赖于web框架，在SpringMVC中就是依赖于SpringMVC框架。过滤器依赖与servlet容器。
③拦截器只能对action（也就是controller）请求起作用，而过滤器则可以对几乎所有的请求起作用,并且可以对请求的资源进行起作用，但是缺点是一个过滤器实例只能在容器初始化时调用一次。
④拦截器可以访问action上下文、值栈里的对象，而过滤器不能访问。
⑤在action的生命周期中，拦截器可以多次被调用，而过滤器只能在容器初始化时被调用一次。
⑥拦截器可以获取IOC容器中的各个bean，而过滤器就不行，这点很重要，在拦截器里注入一个service，可以调用业务逻辑

## 从灵活性上说拦截器功能更强大些，Filter能做的事情，他都能做，而且可以在请求前，请求后执行，比较灵活。

|                | filter                                     | Interceptor                                             |
| -------------- | ------------------------------------------ | ------------------------------------------------------- |
| 多个的执行顺序 | 根据filter mapping配置的先后顺序           | 按照配置的顺序，但是可以通过order控制顺序               |
| 规范           | 在Servlet规范中定义的，是Servlet容器支持的 | Spring容器内的，是Spring框架支持的。                    |
| 使用范围       | 只能用于Web程序中                          | 既可以用于Web程序，也可以用于Application、Swing程序中。 |
| 深度           | Filter在只在Servlet前后起作用              | 拦截器能够深入到方法前后、异常抛出前后等                |

 

**拦截器的实现**
1.编写拦截器类实现HandlerInterceptor接口
三个必须实现的方法
preHandle(HttpServletRequest arg0, HttpServletResponse arg1, Object arg2) 
（第一步：在请求被处理之前进行调用 是否需要将当前的请求拦截下来，如果返回false，请求将会终止，返回true，请求将会继续Object arg2表示拦截的控制器的目标方法实例）

当进入拦截器链中的某个拦截器，并执行preHandle方法后

 

postHandle(HttpServletRequest arg0, HttpServletResponse arg1, Object arg2,ModelAndView arg3) 
（第二步：在请求被处理之后进行调用ModelAndView arg3是指将被呈现在网页上的对象，可以通过修改这个对象实现不同角色跳向不同的网页或不同的消息提示）

afterCompletion(HttpServletRequest arg0, HttpServletResponse arg1, Object arg2，Exception arg3) 
（第三步：在请求结束之后调用 一般用于关闭流、资源连接等 比较少用）

```java
package org.springframework.web.servlet;  



public interface HandlerInterceptor {  



    boolean preHandle(  



            HttpServletRequest request, HttpServletResponse response,   



            Object handler)   



            throws Exception;  



  



    void postHandle(  



            HttpServletRequest request, HttpServletResponse response,   



            Object handler, ModelAndView modelAndView)   



            throws Exception;  



  



    void afterCompletion(  



            HttpServletRequest request, HttpServletResponse response,   



            Object handler, Exception ex)  



            throws Exception;  
```





## [Interceptor（拦截器）][[Interceptor（拦截器）_sunshine_YG的专栏-CSDN博客](https://blog.csdn.net/sunshine_YG/article/details/85118801)]

拦截器是AOP实现的。

实现拦截器步骤：1、定义  2、注册

HandlerInterceptorAdapter与WebMvcConfigurerAdapter更方便些，不需要实现所有方法。

HandlerInterceptor与WebMvcConfigurer则需要实现所有方法

 定义一个拦截器
public class TokenInterceptor extends HandlerInterceptorAdapter {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        System.out.println("preHandler");
        return true;
    }

```java
@Override
public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
    System.out.println("postHandler");
}
```
}
注册拦截器 

```java
@Configuration
public class MyWebMvcConfigurerAdapter extends WebMvcConfigurerAdapter {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new TokenInterceptor()).addPathPatterns("/user/*").excludePathPatterns("/user/getone2");
    }
}
这样就添加了一个拦截器。 拦截除/user/getone2以外的与/user/*
```

匹配的域名，比如会拦截/user/getone1、/user/getone3。