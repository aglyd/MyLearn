# [浅谈springboot之JoinPoint的getSignature方法](https://www.jb51.net/article/215195.htm)

## JoinPoint的getSignature方法

在使用springboot写aop的时候，有个JoinPoint类，用来获取代理类和被代理类的信息。

这个文章记录一下JoinPoint的getSignature方法返回的是什么格式。

### 不废话，贴代码

```java
package org.aspectj.lang; 
public interface Signature {
    String toString(); 
    String toShortString(); 
    String toLongString(); 
    String getName(); 
    int getModifiers(); 
    Class getDeclaringType(); 
    String getDeclaringTypeName();
}
```

打印输出,getString是测试类的方法名，TestController是类名

```java
joinPoint.getSignature().toString():String com.fast.web.controller.TestController.getString()
joinPoint.getSignature().toShortString():TestController.getString()
joinPoint.getSignature().toLongString():public java.lang.String com.fast.web.controller.TestController.getString()
joinPoint.getSignature().getName():getString
joinPoint.getSignature().getModifiers():1
joinPoint.getSignature().getDeclaringType():class com.fast.web.controller.TestController
joinPoint.getSignature().getDeclaringTypeName():com.fast.web.controller.TestController
```

冒号前面是使用的方法，后面是本次测试输出的结果。

### 附上被测试的类：

```java
package com.fast.web.controller;
import com.fast.framework.dao.TestDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController; 
@RestController
public class TestController {
 
    @Autowired
    private TestDao testDao;
 
    @RequestMapping("/test")
    public String getString() {
        int i = testDao.selectBase();
        return String.valueOf(i);
    }
}
```

## springboot注解式AOP通过JoinPoint获取参数

之前开发时，需要获取切点注解的参数值，记录一下

### 切面注解 ：

@Aspect – 标识为一个切面供容器读取，作用于类

@Pointcut – (切入点):就是带有通知的连接点

@Before – 前置

@AfterThrowing – 异常抛出

@After – 后置

@AfterReturning – 后置增强，执行顺序在@After之后

@Around – 环绕

### 1.相关maven包

```xml
 <dependency>
     <groupId>org.springframework.boot</groupId>
     <artifactId>spring-boot-starter-aop</artifactId>
 </dependency>
```

### 2.自定义一个接口

```java
import java.lang.annotation.*;
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Action {
    String value() default "list";
}
```

### 3.定义切面类

```java
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
@Aspect
@Component
public class ActAspect {
 
 @AfterReturning("@annotation(包名.Action)")
    public void afterReturning(JoinPoint point){
    
  // 获取切入点方法名
  String methodName = point.getSignature().getName();
  
     // 获取切点中的信息值
        MethodSignature methodSignature = (MethodSignature)point.getSignature();	
        Method method = methodSignature.getMethod();
        // 获取注解Action 
        Action annotation = method.getAnnotation(Action.class);
        // 获取注解Action的value参数的值
        String value = annotation.value();
        
        // 获取切点方法入参列表
        Object[] objArray = point.getArgs();
        // 下面代码根据具体入参类型进行修改
        List<String> list = new ArrayList<>();
        for (Object obj: objArray) {
            if(obj instanceof Collection){
                list = (List<String>) obj;
            }
        }
    }    
}
```

