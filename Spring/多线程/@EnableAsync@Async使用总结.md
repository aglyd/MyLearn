# [@EnableAsync@Async使用总结](https://www.cnblogs.com/hsug/p/13303018.html)

我们在使用多线程的时候，往往需要创建Thread类，或者实现Runnable接口，如果要使用到线程池，我们还需要来创建Executors，在使用spring中，已经给我们做了很好的支持。只要要@EnableAsync就可以使用多线程。使用@Async就可以定义一个线程任务。通过spring给我们提供的ThreadPoolTaskExecutor就可以使用线程池。

默认情况下，Spring将搜索相关的线程池定义：要么在上下文中搜索唯一的TaskExecutor bean，要么搜索名为“taskExecutor”的Executor bean。如果两者都无法解析，则将使用SimpleAsyncTaskExecutor来处理异步方法调用。

### 定义配置类

```java
@Configuration
@EnableAsync
public class ThreadPoolTaskConfig {
	
	private static final int corePoolSize = 10;       		// 核心线程数（默认线程数）
	private static final int maxPoolSize = 100;			    // 最大线程数
	private static final int keepAliveTime = 10;			// 允许线程空闲时间（单位：默认为秒）
	private static final int queueCapacity = 200;			// 缓冲队列数
	private static final String threadNamePrefix = "Async-Service-"; // 线程池名前缀
	
	@Bean("taskExecutor") // bean的名称，默认为首字母小写的方法名
	public ThreadPoolTaskExecutor getAsyncExecutor(){
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		executor.setCorePoolSize(corePoolSize);   
		executor.setMaxPoolSize(maxPoolSize);
		executor.setQueueCapacity(queueCapacity);
		executor.setKeepAliveSeconds(keepAliveTime);
		executor.setThreadNamePrefix(threadNamePrefix);
		
		// 线程池对拒绝任务的处理策略
		executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
		// 初始化
		executor.initialize();
		return executor;
	}
}
```

@Configuration用于定义配置类，被注解的类内部包含有一个或多个被@Bean注解的方法，这些方法将会被AnnotationConfigApplicationContext或AnnotationConfigWebApplicationContext类进行扫描，并用于构建bean定义，初始化Spring容器。

@EnableAsync开始对异步任务的支持

### 测试service

```java
@Service
public class testAsyncService {
	Logger log = LoggerFactory.getLogger(testAsyncService.class);
 
	// 发送提醒短信 1
	@Async("taskExecutor")
	public void service1() throws InterruptedException {
		log.info("--------start-service1------------");
		Thread.sleep(5000); // 模拟耗时
	    log.info("--------end-service1------------");
	}
	
	// 发送提醒短信 2
	@Async("taskExecutor")
	public void service2() throws InterruptedException {
		
		log.info("--------start-service2------------");
		Thread.sleep(2000); // 模拟耗时
	    log.info("--------end-service2------------");
 
	}
}
```

@Async注解来声明一个或多个异步任务，可以加在方法或者类上，加在类上表示这整个类都是使用这个自定义线程池进行操作

接着我们可以创建control类@Autowired这个service并且调用这其中两个方法，进行连续调用，会发现运行结果是

--------start-service1------------

--------start-service2------------

--------end-service2------------

--------end-service1------------

可以说明我们的异步运行成功了

如下方式会使@Async失效
一、异步方法使用static修饰
二、异步类没有使用@Component注解（或其他注解）导致spring无法扫描到异步类
三、异步方法不能与异步方法在同一个类中
四、类中需要使用@Autowired或@Resource等注解自动注入，不能自己手动new对象
五、如果使用SpringBoot框架必须在启动类中增加@EnableAsync注解
六、在Async 方法上标注@Transactional是没用的。 在Async 方法调用的方法上标注@Transactional 有效。
七、调用被@Async标记的方法的调用者不能和被调用的方法在同一类中不然不会起作用！！！！！！！
八、使用@Async时要求是不能有返回值的不然会报错的 因为异步要求是不关心结果的

下面关于线程池的配置还有一种方式，就是直接实现AsyncConfigurer接口，重写getAsyncExecutor方法即可，代码如下

```java
@Configuration
@EnableAsync
public class AppConfig implements AsyncConfigurer {

     @Override
     public Executor getAsyncExecutor() {
         ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
         executor.setCorePoolSize(7);
         executor.setMaxPoolSize(42);
         executor.setQueueCapacity(11);
         executor.setThreadNamePrefix("MyExecutor-");
         executor.initialize();
         return executor;
     }

     @Override
     public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
         return new MyAsyncUncaughtExceptionHandler();
     }
}
```

分类: [Springboot](https://www.cnblogs.com/hsug/category/1813419.html)

标签: [SpringBoot](https://www.cnblogs.com/hsug/tag/SpringBoot/)





---

# [@EnableAsync@Async基本使用方法](https://www.cnblogs.com/fzhblog/p/14012401.html)

自己的学习记录，方便复习，这里只介绍基本的使用方式

## **一. 基本介绍**

@Async是spring为了方便开发人员进行异步调用的出现的，在方法上加入这个注解，spring会从线程池中获取一个新的线程来执行方法，实现异步调用

@EnableAsync表示开启对异步任务的支持，可以放在springboot的启动类上，也可以放在自定义线程池的配置类上，具体看下文

## 二.最简单的使用

在springboot项目中，直接在启动类上加上@EnableAsync，然后在service层的方法上对于需要异步调用的方法加上@Async，

那么当controller层调用这个方法的时候，就会在主线程外自动新建线程执行该方法，具体看下图demo

1.springboot启动类开启异步支持

![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120172501343-819386528.png)

 

 

 2.service层的方法加@Async，如果在类上加该注解表示整个类的方法都异步执行，建议加到具体的某个方法上

![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120172629039-1438798617.png)

 

 

 3.controller层调用service层的异步方法，这里用主线程在异步方法前后执行了2次打印输出

![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120172829098-1695232104.png)

 

 

 4.调用的结果

首先看看没有异步执行，正常的顺序执行的结果

可以看到，按顺序执行，全部是main线程http-nio-8181-exec-124执行，并且service方法的执行结果在中间，如下所示

![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120173338192-439867772.png)

 

 

 由于我们的方法使用了@Async注解，所以主线程http-nio-8181-exec-124不等异步方法完成，先结束了，异步线程task-1继续执行

 ![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120173058550-763193821.png)

### tips：没有自定义线程池@Async默认的线程池是SimpleAsyncTaskExecutor

## 三.自定义线程池来使用@Async

1.新建一个线程池配置类，@EnableAsync在配置类上加，不用在启动类上加也行，可以配置不同的线程池，用bean的name做区分

 

 ![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120175214476-1350239216.png)

 

 2.@Async的使用一样是在service层的方法上加，如果配置了多个线程池，可以用@Async("name")，那么表示线程池的@Bean的name，来指定用哪个线程池处理

假如只配置了一个线程池，直接用@Async就会用自定义的线程池执行

假如配置了多个线程池，用@Async没指定用哪个线程池，会用默认的SimpleAsyncTaskExecutor来处理

![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120175610207-1724190433.png)

 

 假如配置了多个线程池，用@Async("name")，会用指定的线程池处理

比如service层方法上指定pool1线程池

![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120180028229-1591693804.png)

 

 执行结果，异步线程名是pool配置的fzhThread

 ![img](https://img2020.cnblogs.com/blog/2219757/202011/2219757-20201120180106346-848716098.png)

 

##  四.注解没生效的原因

1.异步方法使用static修饰

2.异步方法类没有使用@Service注解（或其他注解）导致spring无法扫描到异步类

3.controller中需要使用@Autowired或@Resource等注解自动注入service类，不能自己手动new对象



----



# [大家都说不建议直接使用 @Async 注解？为什么？？][https://www.cnblogs.com/wlandwl/p/async.html]

本文讲述`@Async`注解，在Spring体系中的应用。

本文仅说明`@Async`注解的应用规则，对于原理，调用逻辑，源码分析，暂不介绍。对于异步方法调用，从Spring3开始提供了`@Async`注解，该注解可以被标注在方法上，以便异步地调用该方法。调用者将在调用时立即返回，方法的实际执行将提交给Spring TaskExecutor的任务中，由指定的线程池中的线程执行。

**在项目应用中，`@Async`调用线程池，推荐使用自定义线程池的模式。**

自定义线程池常用方案：重新实现接口AsyncConfigurer。

## 简介

### 应用场景

**同步：** 同步就是整个处理过程顺序执行，当各个过程都执行完毕，并返回结果。

**异步：** 异步调用则是只是发送了调用的指令，调用者无需等待被调用的方法完全执行完毕；而是继续执行下面的流程。

例如， 在某个调用中，需要顺序调用 A, B, C三个过程方法；如他们都是同步调用，则需要将他们都顺序执行完毕之后，方算作过程执行完毕；如B为一个异步的调用方法，则在执行完A之后，调用B，并不等待B完成，而是执行开始调用C，待C执行完毕之后，就意味着这个过程执行完毕了。

在Java中，一般在处理类似的场景之时，都是基于创建独立的线程去完成相应的异步调用逻辑，通过主线程和不同的业务子线程之间的执行流程，从而在启动独立的线程之后，主线程继续执行而不会产生停滞等待的情况。

### Spring 已经实现的线程池

1. `SimpleAsyncTaskExecutor`：不是真的线程池，这个类不重用线程，默认每次调用都会创建一个新的线程。
2. `SyncTaskExecutor`：这个类没有实现异步调用，只是一个同步操作。只适用于不需要多线程的地方。
3. `ConcurrentTaskExecutor`：Executor的适配类，不推荐使用。如果ThreadPoolTaskExecutor不满足要求时，才用考虑使用这个类。
4. `SimpleThreadPoolTaskExecutor`：是Quartz的SimpleThreadPool的类。线程池同时被quartz和非quartz使用，才需要使用此类。
5. `ThreadPoolTaskExecutor` ：最常使用，推荐。其实质是对`java.util.concurrent.ThreadPoolExecutor`的包装。

### 异步的方法有：

1. 最简单的异步调用，返回值为void
2. 带参数的异步调用，异步方法可以传入参数
3. 存在返回值，常调用返回Future

## Spring中启用@Async

```java
// 基于Java配置的启用方式：
@Configuration
@EnableAsync
public class SpringAsyncConfig { ... }

// Spring boot启用：
@EnableAsync
@EnableTransactionManagement
public class SettlementApplication {
    public static void main(String[] args) {
        SpringApplication.run(SettlementApplication.class, args);
    }
}
```

## @Async应用默认线程池

Spring应用默认的线程池，指在`@Async`注解在使用时，不指定线程池的名称。查看源码，`@Async`的默认线程池为SimpleAsyncTaskExecutor。

Spring Boot 基础就不介绍了，推荐下这个实战教程：https://github.com/javastacks/spring-boot-best-practice

**无返回值调用**

基于`@Async`无返回值调用，直[接在使用类，使用方法（建议在使用方法）上，加上注解。若需要抛出异常，需手动new一个异常抛出。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
/**
 * 带参数的异步调用 异步方法可以传入参数
 *  对于返回值是void，异常会被AsyncUncaughtExceptionHandler处理掉
 * @param s
 */
@Async
public void asyncInvokeWithException(String s) {
    log.info("asyncInvokeWithParameter, parementer={}", s);
    throw new IllegalArgumentException(s);
}
```

[**有返回值Future调用**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
/**
 * 异常调用返回Future
 *  对于返回值是Future，不会被AsyncUncaughtExceptionHandler处理，需要我们在方法中捕获异常并处理
 *  或者在调用方在调用Futrue.get时捕获异常进行处理
 *
 * @param i
 * @return
 */
@Async
public Future<String> asyncInvokeReturnFuture(int i) {
    log.info("asyncInvokeReturnFuture, parementer={}", i);
    Future<String> future;
    try {
        Thread.sleep(1000 * 1);
        future = new AsyncResult<String>("success:" + i);
        throw new IllegalArgumentException("a");
    } catch (InterruptedException e) {
        future = new AsyncResult<String>("error");
    } catch(IllegalArgumentException e){
        future = new AsyncResult<String>("error-IllegalArgumentException");
    }
    return future;
}
```

[**有返回值CompletableFuture调用**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[CompletableFuture 并不使用@Async注解，可达到调用系统线程池处理业务的功能。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[JDK5新增了Future接口，用于描述一个异步计算的结果。虽然 Future 以及相关使用方法提供了异步执行任务的能力，但是对于结果的获取却是很不方便，只能通过阻塞或者轮询的方式得到任务的结果。阻塞的方式显然和我们的异步编程的初衷相违背，轮询的方式又会耗费无谓的 CPU 资源，而且也不能及时地得到计算结果。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- CompletionStage代表异步计算过程中的某一个阶段，一个阶段完成以后可能会触发另外一个阶段
- 一个阶段的计算执行可以是一个Function，Consumer或者Runnable。比如：`stage.thenApply(x -> square(x)).thenAccept(x -> System.out.print(x)).thenRun(() -> System.out.println())`
- 一个阶段的执行可能是被单个阶段的完成触发，也可能是由多个阶段一起触发

[在Java8中，CompletableFuture提供了非常强大的Future的扩展功能，可以帮助我们简化异步编程的复杂性，并且提供了函数式编程的能力，可以通过回调的方式处理计算结果，也提供了转换和组合 CompletableFuture 的方法。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- [它可能代表一个明确完成的Future，也有可能代表一个完成阶段（ CompletionStage ），它支持在计算完成以后触发一些函数或执行某些动作。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
- [它实现了Future和CompletionStage接口](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
/**
 * 数据查询线程池
 */
private static final ThreadPoolExecutor SELECT_POOL_EXECUTOR = new ThreadPoolExecutor(10, 20, 5000,
        TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>(1024), new ThreadFactoryBuilder().setNameFormat("selectThreadPoolExecutor-%d").build());

// tradeMapper.countTradeLog(tradeSearchBean)方法表示，获取数量，返回值为int
// 获取总条数
    CompletableFuture<Integer> countFuture = CompletableFuture
            .supplyAsync(() -> tradeMapper.countTradeLog(tradeSearchBean), SELECT_POOL_EXECUTOR);
// 同步阻塞
CompletableFuture.allOf(countFuture).join();
// 获取结果
int count = countFuture.get();
```

[**默认线程池的弊端**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

[**在线程池应用中，参考阿里巴巴java开发规范：线程池不允许使用Executors去创建，不允许使用系统默认的线程池，推荐通过ThreadPoolExecutor的方式，这样的处理方式让开发的工程师更加明确线程池的运行规则，规避资源耗尽的风险。** Executors各个方法的弊端：](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- [newFixedThreadPool和newSingleThreadExecutor：主要问题是堆积的请求处理队列可能会耗费非常大的内存，甚至OOM。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
- newCachedThreadPool和newScheduledThreadPool：要问题是线程数最大数是`Integer.MAX_VALUE`，可能会创建数量非常多的线程，甚至OOM。

@Async默认异步配置使用的是SimpleAsyncTaskExecutor，该线程池默认来一个任务创建一个线程，若系统中不断的创建线程，最终会导致系统占用内存过高，引发OutOfMemoryError错误。

针对线程创建问题，SimpleAsyncTaskExecutor提供了限流机制，通过concurrencyLimit属性来控制开关，当`concurrencyLimit>=0`时开启限流机制，默认关闭限流机制即`concurrencyLimit=-1`，当关闭情况下，会不断创建新的线程来处理任务。基于默认配置，SimpleAsyncTaskExecutor并不是严格意义的线程池，达不到线程复用的功能。最新 Spring 面试题整理好了，点击[Java面试库](https://mp.weixin.qq.com/s/Ah6dKs0IXe3_eYbtWR-ezA)小程序在线刷题。

## @Async应用自定义线程池

自定义线程池，可对系统中线程池更加细粒度的控制，方便调整线程池大小配置，线程执行异常控制和处理。在设置系统自定义线程池代替默认线程池时，虽可通过多种模式设置，但替换默认线程池最终产生的线程池有且只能设置一个（不能设置多个类继承AsyncConfigurer）。自定义线程池有如下模式：

- 重新实现接口AsyncConfigurer
- 继承AsyncConfigurerSupport
- 配置由自定义的TaskExecutor替代内置的任务执行器

通过查看Spring源码关于`@Async`的默认调用规则，会优先查询源码中实现AsyncConfigurer这个接口的类，实现这个接口的类为AsyncConfigurerSupport。但默认配置的线程池和异步处理方法均为空，所以，无论是继承或者重新实现接口，都需指定一个线程池。且重新实现 `public Executor getAsyncExecutor()`方法。

[**实现接口AsyncConfigurer**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
@Configuration
public class AsyncConfiguration implements AsyncConfigurer {
   @Bean("kingAsyncExecutor")
   public ThreadPoolTaskExecutor executor() {
       ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
       int corePoolSize = 10;
       executor.setCorePoolSize(corePoolSize);
       int maxPoolSize = 50;
       executor.setMaxPoolSize(maxPoolSize);
       int queueCapacity = 10;
       executor.setQueueCapacity(queueCapacity);
       executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
       String threadNamePrefix = "kingDeeAsyncExecutor-";
       executor.setThreadNamePrefix(threadNamePrefix);
       executor.setWaitForTasksToCompleteOnShutdown(true);
       // 使用自定义的跨线程的请求级别线程工厂类19         int awaitTerminationSeconds = 5;
       executor.setAwaitTerminationSeconds(awaitTerminationSeconds);
       executor.initialize();
       return executor;
   }

   @Override
   public Executor getAsyncExecutor() {
       return executor();
   }

   @Override
   public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
       return (ex, method, params) -> ErrorLogger.getInstance().log(String.format("执行异步任务'%s'", method), ex);
   }
}
```

[**继承AsyncConfigurerSupport**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
@Configuration
@EnableAsync
class SpringAsyncConfigurer extends AsyncConfigurerSupport {

    @Bean
    public ThreadPoolTaskExecutor asyncExecutor() {
        ThreadPoolTaskExecutor threadPool = new ThreadPoolTaskExecutor();
        threadPool.setCorePoolSize(3);
        threadPool.setMaxPoolSize(3);
        threadPool.setWaitForTasksToCompleteOnShutdown(true);
        threadPool.setAwaitTerminationSeconds(60 * 15);
        return threadPool;
    }

    @Override
    public Executor getAsyncExecutor() {
        return asyncExecutor;
}

  @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
    return (ex, method, params) -> ErrorLogger.getInstance().log(String.format("执行异步任务'%s'", method), ex);
}
}
```

[**配置自定义的TaskExecutor**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

由于AsyncConfigurer的默认线程池在源码中为空，Spring通过`beanFactory.getBean(TaskExecutor.class)`先查看是否有线程池，未配置时，通过`beanFactory.getBean(DEFAULT_TASK_EXECUTOR_BEAN_NAME, Executor.class)`，又查询是否存在默认名称为TaskExecutor的线程池。

所以可以在项目中，定义名称为TaskExecutor的bean生成一个默认线程池。也可不指定线程池的名称，申明一个线程池，本身底层是基于`TaskExecutor.class`便可。

比如：

```java
Executor.class:ThreadPoolExecutorAdapter->ThreadPoolExecutor->AbstractExecutorService->ExecutorService->Executor
```

这样的模式，最终底层为`Executor.class`，在替换默认的线程池时，需设置默认的线程池名称为TaskExecutor

```java
TaskExecutor.class:ThreadPoolTaskExecutor->SchedulingTaskExecutor->AsyncTaskExecutor->TaskExecutor
```

这样的模式，最终底层为`TaskExecutor.class`，在替换默认的线程池时，可不指定线程池名称。最新面试题整理好了，点击[Java面试库](https://mp.weixin.qq.com/s/Ah6dKs0IXe3_eYbtWR-ezA)小程序在线刷[题。](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
@EnableAsync
@Configuration
public class TaskPoolConfig {
   @Bean(name = AsyncExecutionAspectSupport.DEFAULT_TASK_EXECUTOR_BEAN_NAME)
   public Executor taskExecutor() {
       ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        //核心线程池大小
       executor.setCorePoolSize(10);
       //最大线程数
       executor.setMaxPoolSize(20);
       //队列容量
       executor.setQueueCapacity(200);
       //活跃时间
       executor.setKeepAliveSeconds(60);
       //线程名字前缀
       executor.setThreadNamePrefix("taskExecutor-");
       executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
       return executor;
   }
  @Bean(name = "new_task")
   public Executor taskExecutor() {
       ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        //核心线程池大小
       executor.setCorePoolSize(10);
       //最大线程数
       executor.setMaxPoolSize(20);
       //队列容量
       executor.setQueueCapacity(200);
       //活跃时间
       executor.setKeepAliveSeconds(60);
       //线程名字前缀
       executor.setThreadNamePrefix("taskExecutor-");
       executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
       return executor;
   }
}
```

[**多个线程池**](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

`@Async`注解，使用系统默认或者自定义的线程池（代替默认线程池）。可在项目中设置多个线程池，在异步调用时，指明需要调用的线程池名称，如`@Async("new_task")`。

关注公众号，学习更多 Java 干货！![图片](640.webp)



**Java大后端**

专注分享Java后端技术，包括Spring Boot、Spring Cloud、MyBatis、MySQL、Dubbo、Zookeeper、ES、K8S、Docker、Redis、MQ、分布式、微服务等主流后端技术。



公众号

## @Async部分重要源码解析 

源码-获取线程池方法

![img](626790-20191121202005815-1837055625.jpg)

 源码-设置默认线程池defaultExecutor，默认是空的，当重新实现接口AsyncConfigurer的getAsyncExecutor()时，可以设置默认的线程池。

![img](626790-20191121202459652-968586266.jpg)

![img](626790-20191121202157561-2139658328.jpg)

源码-寻找系统默认线程池

![img](626790-20191121202529152-2113105894.jpg)

源码-都没有找到项目中设置的默认线程池时，采用spring 默认的线程池

![img](626790-20191121202704321-787495959.jpg)