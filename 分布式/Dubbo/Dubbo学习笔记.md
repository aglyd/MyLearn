# Dubbo学习笔记

## 一、了解dubbo

## 1、dubbo产生的原因：

随着系统服务越来越多，系统越来越复杂，系统架构从单一架构——>垂直架构——.....到分布式微服务系统架构的演变，迫切需要一种能高效实现远程服务调用的架构来为微服务系统做支撑。

### 系统架构的演变

随着互联网的发展，网站应用的规模不断扩大，常规的应用架构已无法应对，分布式服务架构以及微服务架构势在必行，亟需一个治理系统确保架构有条不紊的演进。

### 单体应用架构[#](https://www.cnblogs.com/yangjiaoshou/p/15064163.html#单体应用架构)

Web应用程序发展的早期，大部分web工程(包含前端页面,web层代码,service层代码,dao层代码)是将所有的功能模块,打包到一起并放在一个web容器中运行。

[![img](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727085322156-348042593.png)](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727085322156-348042593.png)

比如搭建一个电商系统：客户下订单，商品展示，用户管理。这种将所有功能都部署在一个web容器中运行的系统就叫做单体架构。

优点：

　　所有的功能集成在一个项目工程中

　　项目架构简单，前期开发成本低，周期短，小型项目的首选。

缺点：

　　全部功能集成在一个工程中，对于大型项目不易开发、扩展及维护。

　　系统性能扩展只能通过扩展集群结点，成本高、有瓶颈。

　　技术栈受限

### 垂直应用架构[#](https://www.cnblogs.com/yangjiaoshou/p/15064163.html#垂直应用架构)

　　当访问量逐渐增大，单一应用增加机器带来的加速度越来越小，将应用拆成互不相干的几个应用，以提升效率

[![img](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727085816193-143534893.png)](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727085816193-143534893.png)

优点：

　　项目架构简单，前期开发成本低，周期短，小型项目的首选。

　　通过垂直拆分，原来的单体项目不至于无限扩大

　　不同的项目可采用不同的技术。

缺点：

　　全部功能集成在一个工程中，对于大型项目不易开发、扩展及维护。

　　系统性能扩展只能通过扩展集群结点，成本高、有瓶颈。 

### 分布式SOA架构 [#](https://www.cnblogs.com/yangjiaoshou/p/15064163.html#分布式soa架构 )

#### 什么是SOA[#](https://www.cnblogs.com/yangjiaoshou/p/15064163.html#什么是soa)

SOA 全称为 Service-Oriented Architecture，即面向服务的架构。

　　它可以根据需求通过网络对松散耦合的粗粒度应用组件(服务)进行分布式部署、组合和使用。一个服务通常以独立的形式存在于操作系统进程中。

　　站在功能的角度:把业务逻辑抽象成可复用、可组装的服务，通过服务的编排实现业务的快速再生，

　　目的：把原先固有的业务功能转变为通用的业务服务，实现业务逻辑的快速复用。

通过上面的描述可以发现 SOA 有如下几个特点：分布式、可重用、扩展灵活、松耦合

####  SOA架构[#](https://www.cnblogs.com/yangjiaoshou/p/15064163.html# soa架构)

当垂直应用越来越多，应用之间交互不可避免，将核心业务抽取出来，作为独立的服务，逐渐形成稳定的服务中心，使前端应用能更快速的响应多变的市场需求:

[![img](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727090216270-701590563.png)](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727090216270-701590563.png)

优点：

　　抽取公共的功能为服务,提高开发效率

　　对不同的服务进行集群化部署解决系统压力

　　基于ESB/DUBBO减少系统耦合

缺点：

　　抽取服务的粒度较大

　　服务提供方与调用方接口耦合度较高 

### 微服务架构[#](https://www.cnblogs.com/yangjiaoshou/p/15064163.html#微服务架构)

[![img](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727090347201-758702317.png)](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727090347201-758702317.png)

优点：

　　通过服务的原子化拆分，以及微服务的独立打包、部署和升级，小团队的交付周期将缩短，运维成本也将大幅度下降

　　微服务遵循单一原则。微服务之间采用Restful等轻量协议传输。

缺点：

　　微服务过多，服务治理成本高，不利于系统维护。

　　分布式系统开发的技术成本高（容错、分布式事务等）。 

### SOA与微服务的关系[#](https://www.cnblogs.com/yangjiaoshou/p/15064163.html#soa与微服务的关系)

**SOA**（ Service Oriented Architecture ）“面向服务的架构”:他是一种设计方法，其中包含多个服务， 服务之间通过相互依赖最终提供一系列的功能。一个服务 通常以独立的形式存在与操作系统进程中。各个服务之间 通过网络调用。

 

**微服务架构**:==其实和 SOA 架构类似,微服务是在 SOA 上做的升华，微服务架构强调的一个重点是“业务需要彻底的组件化和服务化”，原有的单个业务系统会拆分为多个可以独立开发、设计、运行的小应用。这些小应用之间通过服务完成交互和集成。==

[![img](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727090638297-1286000751.png)](https://img2020.cnblogs.com/blog/1731789/202107/1731789-20210727090638297-1286000751.png)

## 2、Dubbo是什么？

### 1、Dubbo定义

Dubbo是一个分布式服务框架，致力于提供高性能和透明化的RPC远程服务调用方案，以及SOA服务治理方案。
简单的说，dubbo就是个服务框架，如果没有分布式的需求，其实是不需要用的，只有在分布式的时候，才有dubbo这样的分布式服务框架的需求，并且本质上是个服务调用的东东~
说白了就是个远程服务调用的分布式框架（告别Web Service模式中的WSdl，以服务者与消费者的方式在dubbo上注册）

### 2、Dubbo能做什么？

1.透明化的远程方法调用，就像调用本地方法一样调用远程方法，只需简单配置，没有任何API侵入。      2.软负载均衡及容错机制，可在内网替代F5等硬件负载均衡器，降低成本，减少单点。3. 服务自动注册与发现，不再需要写死服务提供方地址，注册中心基于接口名查询服务提供者的IP地址，并且能够平滑添加或删除服务提供者。Dubbo采用全Spring配置方式，透明化接入应用，对应用没有任何API侵入，只需用Spring加载Dubbo的配置即可，Dubbo基于Spring的Schema扩展进行加载。

 提供了六大核心能力：面向接口代理的高性能RPC调用，智能容错和负载均衡，服务自动注册和发现，高度可扩展能力，运行期流量调度，可视化的服务治理与运维。

dubbo官网：https://dubbo.apache.org/zh/

dubbo功能https://zhuanlan.zhihu.com/p/374730808：

服务开发（rpc应用开发）

服务软负载均衡

服务依赖管理

服务监控

服务治理

![img](https://pic1.zhimg.com/80/v2-afaba34febeda3f0c433db18a2c3923c_720w.jpg)

参考：[http://dubbo.apache.org/zh-cn/docs/user/preface/requirements.html](https://link.zhihu.com/?target=http%3A//dubbo.apache.org/zh-cn/docs/user/preface/requirements.html)

在大规模服务化之前，应用可能只是通过 RMI 或 Hessian 等工具，简单的暴露和引用远程服务，通过配置服务的URL地址进行调用，通过 F5 等硬件进行负载均衡。

**当服务越来越多时，服务 URL 配置管理变得非常困难，F5 硬件负载均衡器的单点压力也越来越大。** 此时需要一个服务注册中心，动态地注册和发现服务，使服务的位置透明。并通过在消费方获取服务提供方地址列表，实现软负载均衡和 Failover，降低对 F5 硬件负载均衡器的依赖，也能减少部分成本。

**当进一步发展，服务间依赖关系变得错踪复杂，甚至分不清哪个应用要在哪个应用之前启动，架构师都不能完整的描述应用的架构关系。** 这时，需要自动画出应用间的依赖关系图，以帮助架构师理清理关系。

**接着，服务的调用量越来越大，服务的容量问题就暴露出来，这个服务需要多少机器支撑？什么时候该加机器？** 为了解决这些问题，第一步，要将服务现在每天的调用量，响应时间，都统计出来，作为容量规划的参考指标。其次，要可以动态调整权重，在线上，将某台机器的权重一直加大，并在加大的过程中记录响应时间的变化，直到响应时间到达阈值，记录此时的访问量，再以此访问量乘以机器数反推总容量。

以上是 Dubbo 最基本的几个需求。

### 3、dubbo架构图

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190725102713821.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MjY0MTkwOQ==,size_16,color_FFFFFF,t_70)

注意途中的构成部分、顺序。

**节点角色说明**

![img](https://pic2.zhimg.com/80/v2-515d0876cd8b9a22883def89db311a11_720w.jpg)

**调用关系说明**

\1. 服务容器负责启动，加载，运行服务提供者。

\2. 服务提供者在启动时，向注册中心注册自己提供的服务。

\3. 服务消费者在启动时，向注册中心订阅自己所需的服务。

\4. 注册中心返回服务提供者地址列表给消费者，如果有变更，注册中心将基于长连接推送变更数据给消费者。

\5. 服务消费者，从提供者地址列表中，基于软负载均衡算法，选一台提供者进行调用，如果调用失败，再选另一台调用。

\6. 服务消费者和提供者，在内存中累计调用次数和调用时间，定时每分钟发送一次统计数据到监控中心。

Dubbo 架构具有以下几个特点，分别是连通性、健壮性、伸缩性、以及向未来架构的升级性。

**连通性**

1. 注册中心负责服务地址的注册与查找，相当于目录服务，服务提供者和消费者只在启动时与注册中心交互，注册中心不转发请求，压力较小。
2. 监控中心负责统计各服务调用次数，调用时间等，统计先在内存汇总后每分钟一次发送到监控中心服务器，并以报表展示。
3. 服务提供者向注册中心注册其提供的服务，并汇报调用时间到监控中心，此时间不包含网络开销。
4. 服务消费者向注册中心获取服务提供者地址列表，并根据负载算法直接调用提供者，同时汇报调用时间到监控中心，此时间包含网络开销。
5. 注册中心，服务提供者，服务消费者三者之间均为长连接，监控中心除外。
6. 注册中心通过长连接感知服务提供者的存在，服务提供者宕机，注册中心将立即推送事件通知消费者。
7. 注册中心和监控中心全部宕机，不影响已运行的提供者和消费者，消费者在本地缓存了提供者列表。
8. 注册中心和监控中心都是可选的，服务消费者可以直连服务提供者。

**健壮性**

1. 监控中心宕掉不影响使用，只是丢失部分采样数据
2. 数据库宕掉后，注册中心仍能通过缓存提供服务列表查询，但不能注册新服务
3. 注册中心对等集群，任意一台宕掉后，将自动切换到另一台
4. 注册中心全部宕掉后，服务提供者和服务消费者仍能通过本地缓存通讯
5. 服务提供者无状态，任意一台宕掉后，不影响使用
6. 服务提供者全部宕掉后，服务消费者应用将无法使用，并无限次重连等待服务提供者恢复

**伸缩性**

1. 注册中心为对等集群，可动态增加机器部署实例，所有客户端将自动发现新的注册中心
2. 服务提供者无状态，可动态增加机器部署实例，注册中心将推送新的服务提供者信息给消费者

**升级性**

当服务集群规模进一步扩大，带动IT治理结构进一步升级，需要实现动态部署，进行流动计算，现有分布式服务架构不会带来阻力。下图是未来可能的一种架构：

![img](https://pic4.zhimg.com/80/v2-41c875fdce7a8bbae9525856b62b154f_720w.jpg)

**节点角色说明**

![img](https://pic3.zhimg.com/80/v2-c1bc08378acf3a0a19d84d20aaef486a_720w.jpg)

**服务调用工作流程**

![img](https://pic1.zhimg.com/80/v2-e7500436674fb5f2e2229bbf0ee61104_720w.jpg)

### 4、其他的RPC框架

gRPC

Thrift

HSF



## 3、dubbo[使用](https://zhuanlan.zhihu.com/p/374730808)

### 3.0 依赖说明

学习：[http://dubbo.apache.org/zh-cn/docs/user/dependencies.html](https://link.zhihu.com/?target=http%3A//dubbo.apache.org/zh-cn/docs/user/dependencies.html)

### 3.1 可以如何使用dubbo

服务提供端：

\1. 独立的服务（以普通的java程序形式）

\2. 集成在应用中（在应用中增加远程服务能力）

消费端：

\1. 在应用中调用远程服务。

\2. 也可是在服务提供者中调用远程服务。

### 3.2 dubbo的使用步骤

\1. 引入dubobo相关依赖

\2. 配置dubbo框架（提供了3中配置方式）

\3. 开发服务

\4. 配置服务

\5. 启动、调用

==前提：至少需要三个项目模块对象：创建 DubboDemo 项目，并创建 interface 项目模块（java工程，jar包）、provider 项目模块（web工程，war包）、consumer 项目模块（web工程，war包），它们都是 DubboDemo 的子模块。其中 interface 模块存放所有的接口、provider 模块提供服务、consumer 消费服务。==

**4.2.1 引入dubbo相关依赖**

```text
<dependencies>
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>dubbo</artifactId>
        <version>2.6.6</version>
    </dependency>
<!-- 这里我们使用netty -->
    <dependency>
        <groupId>io.netty</groupId>
        <artifactId>netty-all</artifactId>
        <version>4.1.32.Final</version>
    </dependency>
</dependencies>
```

#### 3.2.2 配置dubbo框架

Dubbo 采用全 Spring API 侵入，只需用 Spring加载 Dubbo 的配置即可，Dubbo 基于 Spring 的 Schema 扩展 进行加载。

如果不想使用 Spring 配置，可以通过 API 的方式 进行调用。

还可以在spring中基于注解的方式进行配置。

**4种配置方式**：

1. ==spring schema xml配置文件 方式 适用于spring应用（普通服务提供方或消费方，请采用XML 配置方式使用 Dubbo）==

2. ==注解方式annotation （Dubbo的@Service） 适用于spring应用， 需要 2.6.3 及以上版本==

3. ==API方式 APIOpenAPI, ESB, Test, Mock 等系统集成。==

4. ==properties 配置文件方式==

   更详细dubbo详情配置参考：https://www.cnblogs.com/chanshuyi/p/5144288.html
   

##### 3.2.2.1 spring Schema XML 方式

**服务提供者**

**示例服务：**

服务接口定义（该接口需单独打包，在服务提供方和消费方共享）：

DemoService.java

```java
public interface DemoService {
String sayHello(String name);
}
```

在服务提供方实现接口

DemoServiceImpl.java

```java
public class DemoServiceImpl implements DemoService {
    public String sayHello(String name) {
        return "Hello " + name;
    }
}
```

**用 Spring 配置声明暴露服务**

只有 group，interface，version 是服务的匹配条件，三者决定是不是同一个服务，其它配置项均为调优和治理参数。 [↩︎](https://dubbo.apache.org/zh/docs/references/xml/#fnref:2)

provider.xml（放在类目录下）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
xsi:schemaLocation="http://www.springframework.org/schema/beans 
      http://www.springframework.org/schema/beans/spring-beans-4.3.xsd 
      http://dubbo.apache.org/schema/dubbo 
      http://dubbo.apache.org/schema/dubbo/dubbo.xsd">
<!-- 提供方应用信息，用于计算依赖关系,声明服务提供者名称，保证他的唯一性，它是dubbo内部服务名称的唯一标识 -->
<dubbo:application name="hello-world-app"  />
<!-- 使用multicast广播注册中心暴露服务地址 -->
<dubbo:registry address="multicast://224.5.6.7:1234" />
<!-- 用dubbo协议在20880端口暴露服务 -->
<dubbo:protocol name="dubbo" port="20880" />
    
<!-- 声明需要暴露的服务接口:dubbo:service
 interface暴露服务的接口全限定类名
 ref 引用接口在spring容器中的标识名称
 registry 使用的注册方式：不写使用上面写的注册中心，“N/A”使用直连方式-->
<dubbo:service interface="com.study.mike.dubbo.DemoService" 
ref="demoService" />
<!--直连方式 <dubbo:service interface="com.study.mike.dubbo.DemoService" 
ref="demoService" registry="N/A" /> -->
<!-- 直连方式消费端需要手动指定url为dubbo服务地址    
<dubbo:referrence id="demoService" interface="com.study.mike.dubbo.DemoService"  
url="dubbo://localhost:20880"
registry="N/A"/>
-->
    
<!-- 和本地bean一样实现服务 -->
<bean id="demoService" 
class="com.study.mike.dubbo.provider.DemoServiceImpl" />
</beans>
```

注意dubbo命名空间的指定，以及配置了哪些项。

**启动服务程序（这里是作为独立的java程序启动）**

Provider.java：

```java
import org.springframework.context.support.ClassPathXmlApplicationContext;
public class Provider {
    public static void main(String[] args) throws Exception {
        ClassPathXmlApplicationContext context = new 
ClassPathXmlApplicationContext("provider.xml");
        context.start();
        System.in.read(); // 按任意键退出
    }
}
```

**服务消费者**

**通过 Spring 配置引用远程服务**

consumer.xml：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
xsi:schemaLocation="http://www.springframework.org/schema/beans
http://www.springframework.org/schema/beans/spring-beans-
4.3.xsd
http://dubbo.apache.org/schema/dubbo 
http://dubbo.apache.org/schema/dubbo/dubbo.xsd">
<!-- 消费方应用唯一标识名称，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->
<dubbo:application name="consumer-of-helloworld-app"  />
<!-- 使用multicast广播注册中心暴露发现服务地址 -->
<dubbo:registry address="multicast://224.5.6.7:1234" />
<!-- 生成远程服务代理，可以和本地bean一样使用demoService 
id 远程接口服务的代理对象名称
interface 接口的全限定类名
url 调用远程接口服务的url地址
registry 注册中心，不填默认为使用配置的注册中心，不使用注册中心用直连时可填registry="N/A"
-->
<dubbo:reference id="demoService" 
interface="com.study.mike.dubbo.DemoService" />
</beans>
```

```java
加载Spring配置，并调用远程服务
Consumer.java
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.apache.dubbo.demo.DemoService;
public class Consumer {
    public static void main(String[] args) throws Exception {
        ClassPathXmlApplicationContext context = new 
ClassPathXmlApplicationContext("consumer.xml");
        context.start();    
        DemoService demoService = (DemoService) 
context.getBean("demoService"); // 获取远程服务代理
        String hello = demoService.sayHello("world"); // 执行远程方法
        System.out.println(hello); // 显示调用结果
        context.close();
    }
}
```

##### 3.2.2.2 注解方式

需要 2.6.3 及以上版本

**服务提供方**

@Service 注解暴露服务，==注意是com.alibaba.dubbo.conﬁg.annotation.Service==

```java
import com.alibaba.dubbo.config.annotation.Service;
import com.study.mike.rpc.demo.DemoService;
@Service
public class DemoServiceImpl implements DemoService {
    public String sayHello(String name) {
        return "Hello " + name;
    }
}
```

增加应用共享配置：classpath:/dubbo/dubbo-provider.properties

```java
# dubbo-provider.properties 
dubbo.application.name=annotation-provider 
dubbo.registry.address=zookeeper://127.0.0.1:2181 
dubbo.protocol.name=dubbo 
dubbo.protocol.port=20880 
指定Spring扫描路径，启动服务
@Configuration 
@EnableDubbo(scanBasePackages = "com.study.mike.dubbo.provider ") 
@PropertySource("classpath:/dubbo/dubbo-provider.properties") 
public class AnnotationProviderConfiguration { 
public static void main(String[] args) throws Exception { 
AnnotationConfigApplicationContext context = new 
AnnotationConfigApplicationContext( 
AnnotationProviderConfiguration.class); 
context.start(); 
System.in.read(); // 按任意键退出
context.close(); 
} 
} 
```

**服务消费方**

Reference 注解引用服务

```java
@Component 
public class AnnotationDemoAction { 
@Reference 
private DemoService demoService; 
public String doSayHello(String name) { 
return demoService.sayHello(name); 
} 
} 
```

增加应用共享配置：classpath:/dubbo/dubbo-consumer.properties

\# dubbo-consumer.properties

```xml
dubbo.application.name=annotation-consumer 
dubbo.registry.address=zookeeper://127.0.0.1:2181 
dubbo.consumer.timeout=3000 
```

```java
指定Spring扫描路径，调用服务
@Configuration 
@EnableDubbo(scanBasePackages = "com.study.mike.dubbo.consumer") 
@PropertySource("classpath:/dubbo/dubbo-consumer.properties") 
@ComponentScan(value = { "com.study.mike.dubbo.consumer" }) 
public class AnnotationConsumerConfiguration { 
public static void main(String[] args) throws Exception { 
AnnotationConfigApplicationContext context = new 
AnnotationConfigApplicationContext( 
AnnotationConsumerConfiguration.class); 
context.start(); 
final AnnotationDemoAction annotationAction = 
context.getBean(AnnotationDemoAction.class); 
String hello = annotationAction.doSayHello("world"); 
System.out.println(hello); 
context.close(); 
} 
} 
```

注意：示例中使用了zookeeper来做注册中心，要引入zookeeper相关依赖

<!-- 默认使用的是第三方zookeeper客户端 curatorz的依赖 -->

```xml
<dependency> 
    <groupId>org.apache.curator</groupId> 
    <artifactId>curator-recipes</artifactId> 
    <version>4.2.0</version> 
    <!-- 如果你使用的zookeeper服务版本不是3.5的，请排除自动依赖，再单独引入
zookeeper依赖 --> 
    <exclusions> 
        <exclusion> 
<groupId>org.apache.zookeeper</groupId> 
<artifactId>zookeeper</artifactId> 
        </exclusion> 
    </exclusions> 
</dependency> 
<!-- 引入zookeeper服务对应版本的zookeeper jar --> 
<dependency> 
    <groupId>org.apache.zookeeper</groupId> 
    <artifactId>zookeeper</artifactId> 
    <version>3.4.11</version> 
</dependency> 
```

##### 3.2.2.3 API方式

API仅用于 OpenAPI, ESB, Test, Mock 等系统集成。

普通服务提供方或XML 配置方式使用 Dubbo

**服务提供者**

```java
import com.alibaba.dubbo.config.ApplicationConfig; 
import com.alibaba.dubbo.config.ProtocolConfig; 
import com.alibaba.dubbo.config.RegistryConfig; 
import com.alibaba.dubbo.config.ServiceConfig; 
import com.study.mike.rpc.demo.DemoService; 
public class ApiProviderConfiguration { 
public static void main(String[] args) throws Exception { 
// 服务实现
DemoService demoService = new DemoServiceImpl(); 
// 当前应用配置。  请学习ApplicationConfig的API 
ApplicationConfig application = new ApplicationConfig(); 
application.setName("hello-world-app"); 
// 连接注册中心配置。  请学习RegistryConfig的API 
RegistryConfig registry = new RegistryConfig("224.5.6.7:1234", 
"multicast"); 
// 服务提供者协议配置
ProtocolConfig protocol = new ProtocolConfig(); 
protocol.setName("dubbo"); 
protocol.setPort(12345); 
protocol.setThreads(200); 
// 注意：ServiceConfig为重对象，内部封装了与注册中心的连接，以及开启服务端口
// 服务提供者暴露服务配置。请学习ServiceConfig的API 
// 此实例很重，封装了与注册中心的连接，请自行缓存，否则可能造成内存和连接泄漏
ServiceConfig<DemoService> service = new ServiceConfig<DemoService>
(); 
service.setApplication(application); 
service.setRegistry(registry); // 多个注册中心可以用setRegistries() 
service.setProtocol(protocol); // 多个协议可以用setProtocols() 
service.setInterface(DemoService.class); 
service.setRef(demoService); 
service.setVersion("1.0.0"); 
// 暴露及注册服务
service.export(); 
System.in.read(); // 按任意键退出
} 
} 
```

**服务消费者**

```java
import com.alibaba.dubbo.config.ApplicationConfig; 
import com.alibaba.dubbo.config.ReferenceConfig; 
import com.alibaba.dubbo.config.RegistryConfig; 
import com.study.mike.rpc.demo.DemoService; 
public class ApiConsumerConfiguration { 
public static void main(String[] args) { 
// 当前应用配置
ApplicationConfig application = new ApplicationConfig(); 
application.setName("consumer-of-helloworld-app"); 
// 连接注册中心配置
RegistryConfig registry = new RegistryConfig("224.5.6.7:1234", 
"multicast"); 
// 注意：ReferenceConfig为重对象，内部封装了与注册中心的连接，以及与服务提供
方的连接
// 引用远程服务
// 此实例很重，封装了与注册中心的连接以及与提供者的连接，请自行缓存，否则可能造
成内存和连接泄漏
ReferenceConfig<DemoService> reference = new 
ReferenceConfig<DemoService>(); 
reference.setApplication(application); 
reference.setRegistry(registry); // 多个注册中心可以用setRegistries() 
reference.setInterface(DemoService.class); 
reference.setVersion("1.0.0"); 
// 和本地bean一样使用demoService 
DemoService demoService = reference.get(); // 注意：此代理对象内部封装
了所有通讯细节，对象较重，请缓存复用
String hello = demoService.sayHello("API demo"); 
System.out.println(hello); 
} 
} 
```

**特殊场景**

下面只列出不同的地方，其它参见上面的写法

**方法级设置**

...

// 方法级配置

```text
List<MethodConfig> methods = new ArrayList<MethodConfig>(); 
MethodConfig method = new MethodConfig(); 
method.setName("createXxx"); 
method.setTimeout(10000); 
method.setRetries(0); 
methods.add(method); 
// 引用远程服务
ReferenceConfig<XxxService> reference = new ReferenceConfig<XxxService>(); 
// 此实例很重，封装了与注册中心的连接以及与提供者的连接，请自行缓存，否则可能造成内存和连
接泄漏
... 
reference.setMethods(methods); // 设置方法级配置
... 
```

**点对点直连**

```text
... 
ReferenceConfig<XxxService> reference = new ReferenceConfig<XxxService>(); 
// 此实例很重，封装了与注册中心的连接以及与提供者的连接，请自行缓存，否则可能造成内存和连
接泄漏
// 如果点对点直连，可以用reference.setUrl()指定目标地址，设置url后将绕过注册中心，
// 其中，协议对应provider.setProtocol()的值，端口对应provider.setPort()的值，
// 路径对应service.setPath()的值，如果未设置path，缺省path为接口名
reference.setUrl("dubbo://10.20.130.230:20880/com.xxx.XxxService");  
... 
```

##### 3.3 配置项学习

[http://dubbo.apache.org/zh-cn/docs/user/references/xml/introduction.html](https://link.zhihu.com/?target=http%3A//dubbo.apache.org/zh-cn/docs/user/references/xml/introduction.html)

![img](Dubbo学习笔记.assets/v2-d66c6145ba367d58f2cbadcb05c725cc_720w.jpg)

**一定要了解各配置元素可配置属性。**

##### 3.4 spring boot中集成

###### 方式一：@EnableDubbo 注解

0、引入对应的jar

```xml
<dependency> 
    <groupId>com.alibaba</groupId> 
    <artifactId>dubbo</artifactId> 
    <version>2.6.6</version> <!--dubbo 2.6.0版本及以下注册中心依赖是用的zk-client包，2.6.2以上才是用的curator包-->
</dependency> 
<dependency> 
            <groupId>io.netty</groupId> 
            <artifactId>netty-all</artifactId> 
            <version>4.1.32.Final</version> 
        </dependency> 
        <!-- 默认使用的是第三方zookeeper客户端 curator --> 
        <dependency> 
            <groupId>org.apache.curator</groupId> 
            <artifactId>curator-recipes</artifactId> 
            <version>4.2.0</version> 
            <!-- 如果你使用的zookeeper服务版本不是3.5的，请排除自动依赖，再单独引入
zookeeper依赖 --> 
            <exclusions> 
                <exclusion> 
                    <groupId>org.apache.zookeeper</groupId> 
                    <artifactId>zookeeper</artifactId> 
                </exclusion> 
            </exclusions> 
        </dependency> 
        <!-- 引入zookeeper服务对应版本的zookeeper jar --> 
        <dependency> 
            <groupId>org.apache.zookeeper</groupId> 
            <artifactId>zookeeper</artifactId> 
            <version>3.4.11</version> 
        </dependency> 
```

1、在springboot 的启动类上加 @EnableDubbo 注解开启dubbo（服务提供者、消费者的是

一样的，扫描的包可能不一样）

```java
@SpringBootApplication 
@EnableDubbo(scanBasePackages = "com.study.mike.dubbo.provider") 
public class SpringBootDubboApplication { 
public static void main(String[] args) { 
SpringApplication.run(SpringBootDubboApplication.class, args); 
} 
} 
```

2、然后在application.yml中配置dubbo:

服务端示例：

\#服务提供者 application.yml

```yaml
spring: 
  main:  
    allow-bean-definition-overriding: true 
dubbo: 
  application: 
    name: service-app1 
  registry: 
    address: zookeeper://127.0.0.1:2181 
  protocol: 
    name: dubbo 
    port: 20880 
    
    
```

```yaml
消费者示例：
# 消费者 application.yml 
spring: 
  main:  
    allow-bean-definition-overriding: true 
server.port: 9000   #因在同一机器上跑spring-boot web，所以改下端口
dubbo: 
  application: 
    name: consumer-service-app1 
  registry: 
    address: zookeeper://127.0.0.1:2181 
  consumer:  
    timeout: 3000 
```

在消费者提供Controller，测试一下

AnnotationDemoAction.java

```java
@RestController 
public class AnnotationDemoAction { 
@Reference 
private DemoService demoService; 
@RequestMapping("/hello") 
public String doSayHello(String name) { 
return demoService.sayHello(name); 
} 
} 
```

###### 方式二：dubbo-spring-boot-starter方式

1、引入dubbo-spring-boot-starter 及对应的dubbo jar

```xml
<dependency> 
    <groupId>com.alibaba.boot</groupId> 
    <artifactId>dubbo-spring-boot-starter</artifactId> 
    <version>0.2.1.RELEASE</version> 
</dependency> 
<dependency> 
    <groupId>com.alibaba</groupId> 
    <artifactId>dubbo</artifactId> 
    <version>2.6.6</version> 
</dependency> 
<dependency> 
            <groupId>io.netty</groupId> 
            <artifactId>netty-all</artifactId> 
            <version>4.1.32.Final</version> 
        </dependency> 
        <!-- 默认使用的是第三方zookeeper客户端 curator --> 
        <dependency> 
            <groupId>org.apache.curator</groupId> 
            <artifactId>curator-recipes</artifactId> 
            <version>4.2.0</version> 
            <!-- 如果你使用的zookeeper服务版本不是3.5的，请排除自动依赖，再单独引入
zookeeper依赖 --> 
            <exclusions> 
                <exclusion> 
                    <groupId>org.apache.zookeeper</groupId> 
                    <artifactId>zookeeper</artifactId> 
                </exclusion> 
            </exclusions> 
        </dependency> 
        <!-- 引入zookeeper服务对应版本的zookeeper jar --> 
        <dependency> 
            <groupId>org.apache.zookeeper</groupId> 
            <artifactId>zookeeper</artifactId> 
            <version>3.4.11</version> 
        </dependency> 
```

2、配置

在application.yml完成和方式一相同的配置

在application.yml中通过dubbo.scan.base-packages参数指定dubbo扫描的包（服务提供

者、消费者设置方式一样）

\# application.yml

```yaml
spring: 
  main:  
    allow-bean-definition-overriding: true 
dubbo: 
  application: 
    name: service-app1 
  registry: 
    address: zookeeper://127.0.0.1:2181 
  protocol: 
    name: dubbo 
    port: 20880 
  scan:  
    base-packages: com.study.mike.dubbo.provider 
```

### 3.3 源码导读

#### 3.3.1 API方式工作过程解读

ServiceConﬁg

Invoker

Protocol

![img](Dubbo学习笔记.assets/v2-cfebc7d168fbcf7c3d30883c53b325bc_720w.jpg)

![img](Dubbo学习笔记.assets/v2-0f604cab19ad2f1457c3353d54364742_720w.jpg)

![img](Dubbo学习笔记.assets/v2-9c83a1838cbd5aa0b67e668edfa72d0a_720w.jpg)

![img](Dubbo学习笔记.assets/v2-9a6f7684f16e7b3a883b5a82d183acc8_720w.jpg)

![img](Dubbo学习笔记.assets/v2-8b440bebfd95fae61409499729420e9c_720w.jpg)

![img](Dubbo学习笔记.assets/v2-567df5bd5ab31d474a1fb8d130b9f068_720w.jpg)

![img](Dubbo学习笔记.assets/v2-eba99866801e9ff5402ac1906dc45775_720w.jpg)

#### 3.3.2 xml标签的解析

#### 3.3.3 注解方式的生效过程



### 3.4 SpringMVC的web工程使用dubbo

#### 3.4.1 依赖

1. dubbo依赖
2. Spring依赖
3. 接口工程
4. 注册中心依赖（zookeeper）

![image-20220119001356365](Dubbo学习笔记.assets/image-20220119001356365.png)

![image-20220119002709298](Dubbo学习笔记.assets/image-20220119002709298.png)

#### 3.4.2 服务提供者工程配置文件

注意dubbo本身暴露的服务端口地址是20880（是dubbo的端口），zookeeper注册中心提供给dubbo注册服务的端口是zookeeper的进程端口2181

![image-20220119001931239](Dubbo学习笔记.assets/image-20220119001931239.png)

![image-20220119002306554](Dubbo学习笔记.assets/image-20220119002306554.png)

服务提供者

spring MVC web工程项目，用xml配置后在WEB-INF下的web.xml里配置监听器加载（暴露）自定义dubbo配置文件：

![image-20220112221003488](Dubbo学习笔记.assets/image-20220112221003488.png)



#### 3.4.3 消费者工程配置文件

消费者依赖同提供者

消费者dubbo-consumer.xml:

![image-20220119003609683](Dubbo学习笔记.assets/image-20220119003609683.png)

因为consumer项目作为业务模块需要转跳页面，因此此消费者sprinmvc项目需要添加springmvc视图配置文件

回顾一下springMVC配置文件，除了web.xml外还可自定义配置文件springmvc.xml（配置springmvc视图配置）在resource下，如下springmvc配置文件

1、添加springmvc配置文件

![image-20220119003016576](Dubbo学习笔记.assets/image-20220119003016576.png)

2、编辑配置，配置页面文件的前缀（/）后缀（.jsp）

![image-20220113211501104](Dubbo学习笔记.assets/image-20220113211501104.png)

3、配置web.xml，配置中央调度器（servlet），且在启动servlet时添加启动配置springmvc.xml和dubbo-comsumer.xml配置文件

<load-on-startup>1</load-on-startup>：开启启动时加载

![image-20220119003345189](Dubbo学习笔记.assets/image-20220119003345189.png)

**注意<servlet>和 <servle-mapping>中的<servlet-name>两个名字要保持一致**

另：创建了一个java工程转为web工程：

打开项目结构添加modeles一个web启动

![image-20220119000328618](Dubbo学习笔记.assets/image-20220119000328618.png)

配置web启动

![image-20220119000231913](Dubbo学习笔记.assets/image-20220119000231913.png)

配置web.xml在webapp\WEB-INF下（先事先创建好此两个文件夹）

![image-20220119000421858](Dubbo学习笔记.assets/image-20220119000421858.png)

再配置web的resource目录为webapp

![image-20220119000618214](Dubbo学习笔记.assets/image-20220119000618214.png)



### 3.5 dubbo配置

#### 3.5.1 配置原则

在服务提供者配置访问参数，因为服务提供者更了解服务的各种参数。

### 3.5.2 关闭检查

==在消费者配置引用服务时配置关闭检查：原因：正常dubbo工程启动是按照先启动提供者再启动消费者，消费者在启动时dubbo会默认检查引用服务是否可用，不可用会报错。但是实际开发工作中可能会只需要启动消费者项目不需要用到某些提供者的服务，这时就要先关闭检查才能先启动消费者，不然启动会报错！，生产环境时会再去掉，因为如果报错会需要看到报错信息==

![image-20220120003659362](Dubbo学习笔记.assets/image-20220120003659362.png)

### 3.5.3 重试次数

提供者和消费者配置：<dubbo:service retries=“2” />、<dubbo:reference retries=“2” />

实际工作中一般不配置此参数，因为没有意义，且访问时间变长用户体验较差。

![image-20220120004444530](Dubbo学习笔记.assets/image-20220120004444530.png)

### 3.5.4 超时时间

单位毫秒：ms

提供者和消费者都可设置：

<dubbo:service timeout=“” />

<dubbo:reference timeout=“” /> 但是消费者一般不设置，只在提供者提供，直到提供者报超时返回，否则一直请求



### 3.5.5 版本号

每个接口都应定义版本号，为后续不兼容升级提供可能。当一个接口有不同实现，项目早期使用的一个实现类，之后有了新的接口实现类，就需要使用version来区分不同的接口实现类服务。消费者可以通过version来选择不同的接口服务版本。（**dubbo中接口+服务分组+版本号才能唯一确定一个服务） 。注意：提供者服务配置中加了version，则消费者引用该服务就也必须加上version参数才能定位到该服务，哪怕该接口服务只有一个版本也是**

![image-20220120222240027](Dubbo学习笔记.assets/image-20220120222240027.png)

消费者引用服务时可以写两个该接口引用服务，但是不推荐新旧都引用，因为在业务层controller中自动注入@Autowired时无法辨别注入的是哪个实现类对象

![image-20220120222647732](Dubbo学习笔记.assets/image-20220120222647732.png)

![image-20220120222851582](Dubbo学习笔记.assets/image-20220120222851582.png)



## 3.6 dubbo-admin监控中心使用

github上可下载各种dubbo-admin项目源码，下载后修改配置，dubbo.registry.address改成本机zookeeper服务地址就行，然后编译mvn clean install，如果是spring-boot项目会打成jar包

![image-20220120223904964](Dubbo学习笔记.assets/image-20220120223904964.png)

启动dubbo-admin项目：

1. 启动zookeeper注册中心，zkServer.cmd
2. 启动提供者项目
3. 进入dubbo-admin.jar目录下，cmd 输入java  -jar  dubbo-admin.jar启动
4. 访问http://localhost:7001