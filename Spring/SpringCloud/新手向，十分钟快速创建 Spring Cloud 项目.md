# [新手向，十分钟快速创建 Spring Cloud 项目](https://www.cnblogs.com/binyue/p/12079356.html)

一般来说，Intelij IDEA 可以通过 Maven Archetype 来快速生成Maven项目，其实 IDEA 集成了 Spring 官方提供的 Spring Initializr，可以非常方便的创建 Maven 项目，而且能自动生成启动类和单元测试代码。

下面我们学习如何快速搭建一个 Spring Cloud 工程，示例使用 Spring Boot 2.2.2 版本，使用少量的代码，可以在半小时内完成项目的搭建。

本文为新手向教程，帮助大家快速入门 Spring Cloud 开发，也作为「跟我学 Spring Cloud Alibaba」系列的补充文章，文章会在公众号「架构进化论」进行首发更新，欢迎关注。

## 一、创建一个新工程

1.创建一个新工程，选择maven，点击下一步

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222114148165-1943816207.jpg)

2.填写项目相关的信息，进到下一步

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222114209912-1948015024.jpg)

3.填写项目名和项目位置，命名为 spring cloud demo，点击 finish

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222114226836-460025685.jpg)

4.这样我们就创建好了一个普通项目，该项目是作为一个Parent project存在的，可以直接删除src文件

 

## 二、添加 EurekaServer 子项目

1.在项目上右键-->new-->module-->Spring Initializr-->next

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222131143166-2082975240.jpg) 

 

2.填写项目相关信息，这里命名为 eureka-server，进入下一步

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130204112-720936233.jpg)

 

3.选择Cloud Discovery-->Eureka Server，下一步

 ![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130130893-218468486.jpg)

 

4.填写项目名和项目位置等，完成

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130629268-853407848.jpg)

 

5.IDEA会自动生成Application类，添加@EnableEurekaServer，该注解表明标注类是一个Eureka Server

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130608139-1519164438.jpg)

 

6.修改配置，切换启动端口，默认生成的项目配置文件是 application.properties，这里我替换成application.yml

```
# 服务注册中心 (单节点)
server:
   port:  8761
eureka:
   instance:
   hostname: localhost
   client:
   fetch-registry: false  # 表示是否从Eureka Server获取注册信息,默认为``true``.因为这是一个单点的Eureka Server,不需要同步其他的Eureka Server节点的数据,这里设置为``false
   register-with-eureka: false  # 表示是否将自己注册到Eureka Server,默认为``true``.由于当前应用就是Eureka Server,故而设置为``false``，如果项目只为消费者也可不注册，因为消费者不需向外提供服务，只需拿到注册信息就行
   service-url:
     # 设置与Eureka Server的地址,查询服务和注册服务都需要依赖这个地址.默认是http://localhost:8761/eureka/;多个地址可使用','风格.
    defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
```

　　

eureka的配置信息可以查看 org.springframework.cloud.netflix.eureka. EurekaClientConfigBean ，参考源码了解含义。

 

7.启动项目，在浏览器中输入http://localhost:8761/ ，访问Eureka控制台，服务正常启动

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130102904-1550446554.jpg)

 

8.如果启动报错，配置文件未生效，检查下 target 目录下是否正确引用了 application.yml 文件。

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222131333483-1779642083.jpg)

###  

### 三、添加 EurekaProducer 服务生产者

1.按照同样的方式，创建一个项目，这里我们创建一个Spring Boot风格的服务，

创建时需要勾选 Spring Cloud Discover--> Eureka Discover Client 和 Spring Web 的依赖。

 ![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222131528799-1193055135.jpg)

2.在application启动类中加入注解@EnableEurekaClient，表明自己属于一个生产者。这里为了方便测试，直接使用@RestController获取返回值。

 ![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130047108-1329940898.jpg)

 

3.修改配置，注册到Eureka Server。

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222131629664-1595967566.jpg)

```
server:`` ``port: ``8765` `spring:`` ``application:``  ``name: eureka-producer` `eureka:`` ``client:``  ``service-url:``   ``defaultZone: http:``//localhost:8761/eureka # 指定服务注册中心
```

　　

4.启动应用，刷新Eureka控制台，可以看到服务已经注册到Eureka上

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130028228-1718903044.jpg)

 

5.如果启动有问题，检查是否缺少Spring Boot web的依赖包，可以尝试添加如下配置：

```xml
<dependency>      
<groupId>org.springframework.boot</groupId>      
<artifactId>spring-boot-starter-web</artifactId>    
</dependency>
```

　　

### 四、创建 Eureka Consumer 服务消费者

1.通过 Spring Initializr，创建一个 Eureka Discovery Client 模块，同时要勾选加入Spring Web依赖。

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222130016674-577749994.jpg)

 

2.修改原有配置，指定服务注册中心，这里还是使用yml文件。

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222131720974-1723314533.jpg)

```yaml
server: 
	port: 8763 
spring: 
	application:  
		name: eureka-consumer 
eureka: 
	client:  
		service-url:   
			defaultZone: http://localhost:8761/eureka # 指定服务注册中心
```

　　

2.在启动类中添加@EnableDiscoveryClient表明标注类是消费者，加入restTemplate来消费相关的服务。

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222125955603-467900968.jpg)

```
@SpringBootApplication``@EnableDiscoveryClient``public` `class` `EurekaClientApplication {` `  ``public` `static` `void` `main(String[] args) {``    ``SpringApplication.run(EurekaClientApplication.``class``, args);``  ``}` `  ``@Bean``  ``@LoadBalanced``  ``RestTemplate restTemplate()``  ``{``    ``return` `new` `RestTemplate();``  ``}` `}
```

　　

3.创建controller层，消费远程服务

```
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class DemoController {

    @Autowired
    RestTemplate restTemplate;

    @RequestMapping("greet")
    public String sayHello(@RequestParam String name){

        return restTemplate.getForObject("http://EUREKA-PRODUCER/sayHello?param=" + name, String.class);
    }

}
```

　　

4.配置完毕以后，启动服务消费者，刷新Eureka控制台，可以看到消费者已经注册。 ![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222125939877-2064057709.jpg)

 

5.打开浏览器输入localhost:{server.port}/path 进行服务调用，

这里我用 http://localhost:8763/greet?name=eureka ，可以看到请求正确返回，正确调用了服务提供者。

![img](https://img2018.cnblogs.com/blog/524341/201912/524341-20191222131908780-1607924733.jpg)

## 五、总结

本文通过IDEA的插件，快速创建了一个基于Eureka进行服务发现的Spring Cloud工程实例。
除了集成插件，也可以直接访问 [http://start.spring.io](http://start.spring.io/) ，通过引导，在脚手架中创建自己的项目，导入到开发工具中，感兴趣的同学可以去试下。