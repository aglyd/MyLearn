# [Spring注解@profile的使用][https://blog.csdn.net/weixin_43108539/article/details/90044758]

spring中@profile与maven中的profile很相似，通过配置来改变参数。

例如在开发环境与生产环境使用不同的参数，可以配置两套配置文件，通过@profile来激活需要的环境，但维护两套配置文件不如maven中维护一套配置文件，在pom中通过profile来修改配置文件的参数来的实惠。
也有例外，比如我在开发中调用商城接口经常不能返回我需要的数据，每次都需要mock数据，所以我写了一个mock参数的借口调用类,在开发环境中就使用这个类，测试环境与生产环境则使用正常的借口调用类，这样就不用每次开发的时候去手动改一些代码。

注：@profile在3.2以后的版本支持方法级别和类级别，3.1版本只支持类级别。

言归正传，说下@profile在spring mvc和spring boot的用法。

Spring mvc：
一、注解配置

/** 配置开发环境调用类  **/  

```
@service("product")  

@profile("dev")  

public class ProductRpcImpl implements ProductRpc  

      public String productBaseInfo(Long sku){  
      
         return productResource.queryBaseInfo(Long sku);  
        }  

   }  
```

/** 配置生产环境调用类  **/  

```
@service("product")  
@profile("prop")  
public class MockProductRpcImpl implements ProductRpc  

	   public String productBaseInfo(Long sku){  
	   
	    return “iphone7”;  
	   }  

  }  
```


二、xml配置

```
<!-- 开发环境 -->  

<beans profile="dev">  

<bean id="beanname" class="com.demo.Product"/>  

</beans>  


<!-- 生产环境 -->  

<beans profile="prop">  

<bean id="beanname" class="com.demo.MockProduct"/>  

</beans>  
```

三、激活配置

1.在servlet上下文中进行配置（web.xml）

```
<context-param>  

	<param-name>spring.profiles.default</param-name>  
	
	<param-value>dev</param-value>  

</context-param>  
```

2.作为DispatcherServlet的初始化参数

```
<servlet>  

	<servlet-name>springMVC</servlet-name>  
	
		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>  
	
		<init-param>  
	
			<param-name>contextConfigLocation</param-name>  
	
			<param-value>classpath:/spring-servlet.xml</param-value>  
	
		</init-param>  
	
		<init-param>  
	
			<param-name>spring.profiles.default</param-name>  
	
			<param-value>dev</param-value>  
	
		</init-param>  
	
	<load-on-startup>1</load-on-startup>  

</servlet>  
```

Spring boot：
1、注解配置（类似mvc）

```
//在这个例子中，我们就能为 SecurityConfig 加上 @Profile 注解：
@Profile("production")
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
...
}
```


2、配置和激活（在application.properities/application.yml中）
　　运行时设置 spring.profiles.active 属性就能激活Profile，任意设置配置属性的方式都能用于设置这个值。例如，在命令行里运行应用程序时，可以这样激活 production Profile：

$ java -jar readinglist-0.0.1-SNAPSHOT.jar --spring.profiles.active=production
1
也可以向application.properities/application.yml里添加 spring.profiles.active 属性：

```
spring:
	profiles:
		active: production

yml的配置切换：

logging:
  level:
```


    root: INFO
---
```
spring:
  profiles: development

logging:
  level:
```


    root: DEBUG
---
```
spring:
  profiles: production

logging:
  path: /tmp/
  file: BookWorm.log
  level:
    root: WARN
```

