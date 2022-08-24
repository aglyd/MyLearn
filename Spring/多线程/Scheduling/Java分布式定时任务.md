# [Java定时任务与分布式定时任务](https://blog.csdn.net/laravelchen/article/details/123483094)

业务场景：
订单下单之后15分钟后，用户未付款，系统需要自动取消订单。
红包24小时未被查收，需要延迟执退还业务；
超过7天，自动收货
## 1. JDK原生

使用`JUC` 提供的`newScheduledThreadPool`来执行定时任务

```java
public class ScheduledExecutor {
    public static void main(String[] args) {
        // 创建任务队列，起10个线程
        ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(10);
        // 执行任务：1秒 后开始执行，每5秒执行一次
        scheduledExecutorService.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                System.out.println("执行任务: "+new Date());
            }
        },1,5, TimeUnit.SECONDS);
    }
}
```

## 2. Spring

使用Spring提供的`@Scheduled` 配置任务类，在启动类上添加`@EnableScheduling`

```
@Component
public  class ScheduleWork {
    @Scheduled(cron = "5/3 * * * * ? ")
    public void doJob() {
        System.out.println("spring 定时器 ："+ new Date());
    }
}
// 启动类加上注解，表示启用定时任务
@EnableScheduling
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

或者使用`@Configuration`定义配置类注解，在任务类上同时使用`@EnableScheduling` 和`@Scheduled`

```java
@Configuration
@EnableScheduling
public class SomeJob {
    @Scheduled(cron = "5/3 * * * * ? ")
    public void someTask() {
        System.out.println("更改注解位置的方式  ");
    }
}
```

这种方式有个缺点，那就是执行周期写死在代码里了，没有办法动态改变，要想改变只能修改代码在重新部署启动微服务.

## 3.Spring + 数据库

- 启动类

```java
@EnableScheduling
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

配置类

```java
@Configuration
public class ScheduleConfig implements SchedulingConfigurer {
    @Autowired
    private ApplicationContext context;

    @Autowired
    private SpringScheduleService scheduleService;

    @Override
    public void configureTasks(ScheduledTaskRegistrar scheduledTaskRegistrar) {
        // 查询出所有的任务列表,这里使用的是mybatis，查询的MySQL数据库、
        List<SpringScheduledCron> workList = scheduleService.findAllWorkList();
        for (SpringScheduledCron scheduledCron : workList) {
            Class<?> clazz;
            Object task;

            try {
                // 使用反射获取Class类对象
                clazz = Class.forName(scheduledCron.getCronKey());
                // 获取spring容器中初始化的bean对象
                task  = context.getBean(clazz);
            } catch (ClassNotFoundException e) {
                throw new IllegalArgumentException("该class有误："+scheduledCron.getCronKey() + "----",e);
            }
         
            // 所有定时任务类在微服务启动的时候，就会被自动注册到Spring的定时任务里
             // 动态改变执行周期
            scheduledTaskRegistrar.addTriggerTask((Runnable) task,triggerContext -> {
                // 获取定时任务表达式,执行时间
                String cronExpression = scheduleService.findByCronKey(scheduledCron.getCronKey()).getCronExpression();
                return new CronTrigger(cronExpression).nextExecutionTime(triggerContext);
            });
        }

    }

    // 开启线程池，去处理多个定时任务
    @Bean
    public Executor taskExecutor() {
        return Executors.newScheduledThreadPool(10);
    }
}
```

任务类

```java
@Component
public class DynamicTask implements Runnable {
    private Logger logger =  LoggerFactory.getLogger(getClass());
    private int i;

    @Override
    public void run() {
        logger.info("Task---线程 id :{}, 任务执行 ：{}",Thread.currentThread().getId(),++i);
    }
}
```

## 4.Spring+Redis

同上，只是将原本放在关系型数据中的任务列表，存储在Redis中

## 5.分布式定时任务

**RabbitMQ**

最适合此类场景的，是使用消息队列的延迟队列。可以查看这篇文章：《RabbitMQ消息中间件技术精讲（五）》

**quartz**

依赖于MySQL，使用相对简单，可多节点部署，通过竞争数据库锁来保证只有一个节点执行任务。没有图形化管理页面，使用相对麻烦。

**elastic-job-lite**

依赖于Zookeeper，通过zookeeper的注册与发现，可以动态的添加服务器。

**xxl-job**

国产，依赖于MySQL,基于竞争数据库锁保证只有一个节点执行任务，支持水平扩容。可以手动增加定时任务，启动和暂停任务。

参考文章：
[《在Spring Boot中优雅的实现定时任务》](https://zhuanlan.zhihu.com/p/79644891)
[《【每日鲜蘑】分布式环境下的定时任务》](https://juejin.cn/post/6930912870058328071)



-----

# [Java中定时任务的6种实现方式，你知道几种？](https://juejin.cn/post/6992719702032121864#heading-15)

几乎在所有的项目中，定时任务的使用都是不可或缺的，如果使用不当甚至会造成资损。还记得多年前在做金融系统时，出款业务是通过定时任务对外打款，当时由于银行接口处理能力有限，外加定时任务使用不当，导致发出大量重复出款请求。还好在后面环节将交易卡在了系统内部，未发生资损。

所以，系统的学习一下定时任务，是非常有必要的。这篇文章就带大家整体梳理学习一下Java领域中常见的几种定时任务实现。

## 线程等待实现

先从最原始最简单的方式来讲解。可以先创建一个thread，然后让它在while循环里一直运行着，通过sleep方法来达到定时任务的效果。

```java
public class Task {

    public static void main(String[] args) {
        // run in a second
        final long timeInterval = 1000;
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                while (true) {
                    System.out.println("Hello !!");
                    try {
                        Thread.sleep(timeInterval);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        };
        Thread thread = new Thread(runnable);
        thread.start();
    }
}
复制代码
```

这种方式简单直接，但是能够实现的功能有限，而且需要自己来实现。

## JDK自带Timer实现

目前来看，JDK自带的Timer API算是最古老的定时任务实现方式了。Timer是一种定时器工具，用来在一个后台线程计划执行指定任务。它可以安排任务“执行一次”或者定期“执行多次”。

在实际的开发当中，经常需要一些周期性的操作，比如每5分钟执行某一操作等。对于这样的操作最方便、高效的实现方式就是使用java.util.Timer工具类。

### 核心方法

Timer类的核心方法如下：

```scss
// 在指定延迟时间后执行指定的任务
schedule(TimerTask task,long delay);

// 在指定时间执行指定的任务。（只执行一次）
schedule(TimerTask task, Date time);

// 延迟指定时间（delay）之后，开始以指定的间隔（period）重复执行指定的任务
schedule(TimerTask task,long delay,long period);

// 在指定的时间开始按照指定的间隔（period）重复执行指定的任务
schedule(TimerTask task, Date firstTime , long period);

// 在指定的时间开始进行重复的固定速率执行任务
scheduleAtFixedRate(TimerTask task,Date firstTime,long period);

// 在指定的延迟后开始进行重复的固定速率执行任务
scheduleAtFixedRate(TimerTask task,long delay,long period);

// 终止此计时器，丢弃所有当前已安排的任务。
cancal()；

// 从此计时器的任务队列中移除所有已取消的任务。
purge()；
复制代码
```

### 使用示例

下面用几个示例演示一下核心方法的使用。首先定义一个通用的TimerTask类，用于定义用执行的任务。

```typescript
public class DoSomethingTimerTask extends TimerTask {

    private String taskName;

    public DoSomethingTimerTask(String taskName) {
        this.taskName = taskName;
    }

    @Override
    public void run() {
        System.out.println(new Date() + " : 任务「" + taskName + "」被执行。");
    }
}
复制代码
```

#### 指定延迟执行一次

在指定延迟时间后执行一次，这类是比较常见的场景，比如：当系统初始化某个组件之后，延迟几秒中，然后进行定时任务的执行。

```typescript
public class DelayOneDemo {

    public static void main(String[] args) {
        Timer timer = new Timer();
        timer.schedule(new DoSomethingTimerTask("DelayOneDemo"),1000L);
    }
}
复制代码
```

执行上述代码，延迟一秒之后执行定时任务，并打印结果。其中第二个参数单位为毫秒。

#### 固定间隔执行

在指定的延迟时间开始执行定时任务，定时任务按照固定的间隔进行执行。比如：延迟2秒执行，固定执行间隔为1秒。

```typescript
public class PeriodDemo {

    public static void main(String[] args) {
        Timer timer = new Timer();
        timer.schedule(new DoSomethingTimerTask("PeriodDemo"),2000L,1000L);
    }
}
复制代码
```

执行程序，会发现2秒之后开始每隔1秒执行一次。

#### 固定速率执行

在指定的延迟时间开始执行定时任务，定时任务按照固定的速率进行执行。比如：延迟2秒执行，固定速率为1秒。

```typescript
public class FixedRateDemo {

    public static void main(String[] args) {
        Timer timer = new Timer();
        timer.scheduleAtFixedRate(new DoSomethingTimerTask("FixedRateDemo"),2000L,1000L);
    }
}
复制代码
```

执行程序，会发现2秒之后开始每隔1秒执行一次。

此时，你是否疑惑schedule与scheduleAtFixedRate效果一样，为什么提供两个方法，它们有什么区别？

### schedule与scheduleAtFixedRate区别

在了解schedule与scheduleAtFixedRate方法的区别之前，先看看它们的相同点：

- 任务执行未超时，下次执行时间 = 上次执行开始时间 + period；
- 任务执行超时，下次执行时间 = 上次执行结束时间；

在任务执行未超时时，它们都是上次执行时间加上间隔时间，来执行下一次任务。而执行超时时，都是立马执行。

它们的不同点在于侧重点不同，schedule方法侧重保持间隔时间的稳定，而scheduleAtFixedRate方法更加侧重于保持执行频率的稳定。

#### schedule侧重保持间隔时间的稳定

schedule方法会因为前一个任务的延迟而导致其后面的定时任务延时。计算公式为scheduledExecutionTime(第n+1次) = realExecutionTime(第n次) + periodTime。

也就是说如果第n次执行task时，由于某种原因这次执行时间过长，执行完后的systemCurrentTime>= scheduledExecutionTime(第n+1次)，则此时不做时隔等待，立即执行第n+1次task。

而接下来的第n+2次task的scheduledExecutionTime(第n+2次)就随着变成了realExecutionTime(第n+1次)+periodTime。这个方法更注重保持间隔时间的稳定。

#### scheduleAtFixedRate保持执行频率的稳定

scheduleAtFixedRate在反复执行一个task的计划时，每一次执行这个task的计划执行时间在最初就被定下来了，也就是scheduledExecutionTime(第n次)=firstExecuteTime +n*periodTime。

如果第n次执行task时，由于某种原因这次执行时间过长，执行完后的systemCurrentTime>= scheduledExecutionTime(第n+1次)，则此时不做period间隔等待，立即执行第n+1次task。

接下来的第n+2次的task的scheduledExecutionTime(第n+2次)依然还是firstExecuteTime+（n+2)*periodTime这在第一次执行task就定下来了。说白了，这个方法更注重保持执行频率的稳定。

如果用一句话来描述任务执行超时之后schedule和scheduleAtFixedRate的区别就是：schedule的策略是错过了就错过了，后续按照新的节奏来走；scheduleAtFixedRate的策略是如果错过了，就努力追上原来的节奏（制定好的节奏）。

### Timer的缺陷

Timer计时器可以定时（指定时间执行任务）、延迟（延迟5秒执行任务）、周期性地执行任务（每隔个1秒执行任务）。但是，Timer存在一些缺陷。首先Timer对调度的支持是基于绝对时间的，而不是相对时间，所以它对系统时间的改变非常敏感。

其次Timer线程是不会捕获异常的，如果TimerTask抛出的了未检查异常则会导致Timer线程终止，同时Timer也不会重新恢复线程的执行，它会错误的认为整个Timer线程都会取消。同时，已经被安排单尚未执行的TimerTask也不会再执行了，新的任务也不能被调度。故如果TimerTask抛出未检查的异常，Timer将会产生无法预料的行为。

## JDK自带ScheduledExecutorService

ScheduledExecutorService是JAVA 1.5后新增的定时任务接口，它是基于线程池设计的定时任务类，每个调度任务都会分配到线程池中的一个线程去执行。也就是说，任务是并发执行，互不影响。

需要注意：只有当执行调度任务时，ScheduledExecutorService才会真正启动一个线程，其余时间ScheduledExecutorService都是出于轮询任务的状态。

ScheduledExecutorService主要有以下4个方法：

```java
ScheduledFuture<?> schedule(Runnable command,long delay, TimeUnit unit);
<V> ScheduledFuture<V> schedule(Callable<V> callable,long delay, TimeUnit unit);
ScheduledFuture<?> scheduleAtFixedRate(Runnable command,long initialDelay,long period,TimeUnitunit);
ScheduledFuture<?> scheduleWithFixedDelay(Runnable command,long initialDelay,long delay,TimeUnitunit);
复制代码
```

其中scheduleAtFixedRate和scheduleWithFixedDelay在实现定时程序时比较方便，运用的也比较多。

ScheduledExecutorService中定义的这四个接口方法和Timer中对应的方法几乎一样，只不过Timer的scheduled方法需要在外部传入一个TimerTask的抽象任务。 而ScheduledExecutorService封装的更加细致了，传Runnable或Callable内部都会做一层封装，封装一个类似TimerTask的抽象任务类（ScheduledFutureTask）。然后传入线程池，启动线程去执行该任务。

### scheduleAtFixedRate方法

scheduleAtFixedRate方法，按指定频率周期执行某个任务。定义及参数说明：

```java
public ScheduledFuture<?> scheduleAtFixedRate(Runnable command,
				long initialDelay,
				long period,
				TimeUnit unit);
复制代码
```

参数对应含义：command为被执行的线程；initialDelay为初始化后延时执行时间；period为两次开始执行最小间隔时间；unit为计时单位。

使用实例：

```java
public class ScheduleAtFixedRateDemo implements Runnable{

    public static void main(String[] args) {
        ScheduledExecutorService executor = Executors.newScheduledThreadPool(1);
        executor.scheduleAtFixedRate(
                new ScheduleAtFixedRateDemo(),
                0,
                1000,
                TimeUnit.MILLISECONDS);
    }

    @Override
    public void run() {
        System.out.println(new Date() + " : 任务「ScheduleAtFixedRateDemo」被执行。");
        try {
            Thread.sleep(2000L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
复制代码
```

上面是scheduleAtFixedRate方法的基本使用方式，但当执行程序时会发现它并不是间隔1秒执行的，而是间隔2秒执行。

这是因为，scheduleAtFixedRate是以period为间隔来执行任务的，如果任务执行时间小于period，则上次任务执行完成后会间隔period后再去执行下一次任务；但如果任务执行时间大于period，则上次任务执行完毕后会不间隔的立即开始下次任务。

### scheduleWithFixedDelay方法

scheduleWithFixedDelay方法，按指定频率间隔执行某个任务。定义及参数说明：

```java
public ScheduledFuture<?> scheduleWithFixedDelay(Runnable command,
				long initialDelay,
				long delay,
				TimeUnit unit);
```

参数对应含义：command为被执行的线程；initialDelay为初始化后延时执行时间；period为前一次执行结束到下一次执行开始的间隔时间（间隔执行延迟时间）；unit为计时单位。

使用实例：

```typescript
public class ScheduleAtFixedRateDemo implements Runnable{

    public static void main(String[] args) {
        ScheduledExecutorService executor = Executors.newScheduledThreadPool(1);
        executor.scheduleWithFixedDelay(
                new ScheduleAtFixedRateDemo(),
                0,
                1000,
                TimeUnit.MILLISECONDS);
    }

    @Override
    public void run() {
        System.out.println(new Date() + " : 任务「ScheduleAtFixedRateDemo」被执行。");
        try {
            Thread.sleep(2000L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
复制代码
```

上面是scheduleWithFixedDelay方法的基本使用方式，但当执行程序时会发现它并不是间隔1秒执行的，而是间隔3秒。

这是因为scheduleWithFixedDelay是不管任务执行多久，都会等上一次任务执行完毕后再延迟delay后去执行下次任务。

## Quartz框架实现

除了JDK自带的API之外，我们还可以使用开源的框架来实现，比如Quartz。

Quartz是Job scheduling（作业调度）领域的一个开源项目，Quartz既可以单独使用也可以跟spring框架整合使用，在实际开发中一般会使用后者。使用Quartz可以开发一个或者多个定时任务，每个定时任务可以单独指定执行的时间，例如每隔1小时执行一次、每个月第一天上午10点执行一次、每个月最后一天下午5点执行一次等。

Quartz通常有三部分组成：调度器（Scheduler）、任务（JobDetail）、触发器（Trigger，包括SimpleTrigger和CronTrigger）。下面以具体的实例进行说明。

### Quartz集成

要使用Quartz，首先需要在项目的pom文件中引入相应的依赖：

```xml
<dependency>
    <groupId>org.quartz-scheduler</groupId>
    <artifactId>quartz</artifactId>
    <version>2.3.2</version>
</dependency>
<dependency>
    <groupId>org.quartz-scheduler</groupId>
    <artifactId>quartz-jobs</artifactId>
    <version>2.3.2</version>
</dependency>
复制代码
```

定义执行任务的Job，这里要实现Quartz提供的Job接口：

```java
public class PrintJob implements Job {
    @Override
    public void execute(JobExecutionContext jobExecutionContext) throws JobExecutionException {
        System.out.println(new Date() + " : 任务「PrintJob」被执行。");
    }
}
复制代码
```

创建Scheduler和Trigger，并执行定时任务：

```scss
public class MyScheduler {

    public static void main(String[] args) throws SchedulerException {
        // 1、创建调度器Scheduler
        SchedulerFactory schedulerFactory = new StdSchedulerFactory();
        Scheduler scheduler = schedulerFactory.getScheduler();
        // 2、创建JobDetail实例，并与PrintJob类绑定(Job执行内容)
        JobDetail jobDetail = JobBuilder.newJob(PrintJob.class)
                .withIdentity("job", "group").build();
        // 3、构建Trigger实例，每隔1s执行一次
        Trigger trigger = TriggerBuilder.newTrigger().withIdentity("trigger", "triggerGroup")
                .startNow()//立即生效
                .withSchedule(SimpleScheduleBuilder.simpleSchedule()
                        .withIntervalInSeconds(1)//每隔1s执行一次
                        .repeatForever()).build();//一直执行

        //4、Scheduler绑定Job和Trigger，并执行
        scheduler.scheduleJob(jobDetail, trigger);
        System.out.println("--------scheduler start ! ------------");
        scheduler.start();
    }
}
复制代码
```

执行程序，可以看到每1秒执行一次定时任务。

在上述代码中，其中Job为Quartz的接口，业务逻辑的实现通过实现该接口来实现。

JobDetail绑定指定的Job，每次Scheduler调度执行一个Job的时候，首先会拿到对应的Job，然后创建该Job实例，再去执行Job中的execute()的内容，任务执行结束后，关联的Job对象实例会被释放，且会被JVM GC清除。

Trigger是Quartz的触发器，用于通知Scheduler何时去执行对应Job。SimpleTrigger可以实现在一个指定时间段内执行一次作业任务或一个时间段内多次执行作业任务。

CronTrigger功能非常强大，是基于日历的作业调度，而SimpleTrigger是精准指定间隔，所以相比SimpleTrigger，CroTrigger更加常用。CroTrigger是基于Cron表达式的。

常见的Cron表达式示例如下：

![cron](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6767cd5aa8b040178fb9b054fdc856a2~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp)

可以看出，基于Quartz的CronTrigger可以实现非常丰富的定时任务场景。

## Spring Task

从Spring 3开始，Spring自带了一套定时任务工具Spring-Task，可以把它看成是一个轻量级的Quartz，使用起来十分简单，除Spring相关的包外不需要额外的包，支持注解和配置文件两种形式。通常情况下在Spring体系内，针对简单的定时任务，可直接使用Spring提供的功能。

基于XML配置文件的形式就不再介绍了，直接看基于注解形式的实现。使用起来非常简单，直接上代码：

```typescript
@Component("taskJob")
public class TaskJob {

    @Scheduled(cron = "0 0 3 * * ?")
    public void job1() {
        System.out.println("通过cron定义的定时任务");
    }

    @Scheduled(fixedDelay = 1000L)
    public void job2() {
        System.out.println("通过fixedDelay定义的定时任务");
    }

    @Scheduled(fixedRate = 1000L)
    public void job3() {
        System.out.println("通过fixedRate定义的定时任务");
    }
}
复制代码
```

如果是在Spring Boot项目中，需要在启动类上添加@EnableScheduling来开启定时任务。

上述代码中，@Component用于实例化类，这个与定时任务无关。@Scheduled指定该方法是基于定时任务进行执行，具体执行的频次是由cron指定的表达式所决定。关于cron表达式上面CronTrigger所使用的表达式一致。与cron对照的，Spring还提供了fixedDelay和fixedRate两种形式的定时任务执行。

### fixedDelay和fixedRate的区别

fixedDelay和fixedRate的区别于Timer中的区别很相似。

fixedRate有一个时刻表的概念，在任务启动时，T1、T2、T3就已经排好了执行的时刻，比如1分、2分、3分，当T1的执行时间大于1分钟时，就会造成T2晚点，当T1执行完时T2立即执行。（单线程）

fixedDelay比较简单，表示上个任务结束，到下个任务开始的时间间隔。无论任务执行花费多少时间，两个任务间的间隔始终是一致的。

### Spring Task的缺点

Spring Task 本身不支持持久化，也没有推出官方的分布式集群模式，只能靠开发者在业务应用中自己手动扩展实现，无法满足可视化，易配置的需求。

## 分布式任务调度

以上定时任务方案都是针对单机的，只能在单个JVM进程中使用。而现在基本上都是分布式场景，需要一套在分布式环境下高性能、高可用、可扩展的分布式任务调度框架。

### Quartz分布式

首先，Quartz是可以用于分布式场景的，但需要基于数据库锁的形式。简单来说，quartz的分布式调度策略是以数据库为边界的一种异步策略。各个调度器都遵守一个基于数据库锁的操作规则从而保证了操作的唯一性，同时多个节点的异步运行保证了服务的可靠。

因此，Quartz的分布式方案只解决了任务高可用（减少单点故障）的问题，处理能力瓶颈在数据库，而且没有执行层面的任务分片，无法最大化效率，只能依靠shedulex调度层面做分片，但是调度层做并行分片难以结合实际的运行资源情况做最优的分片。

### 轻量级神器XXL-Job

XXL-JOB是一个轻量级分布式任务调度平台。特点是平台化，易部署，开发迅速、学习简单、轻量级、易扩展。由调度中心和执行器功能完成定时任务的执行。调度中心负责统一调度，执行器负责接收调度并执行。

针对于中小型项目，此框架运用的比较多。

### 其他框架

除此之外，还有Elastic-Job、Saturn、SIA-TASK等。

Elastic-Job具有高可用的特性，是一个分布式调度解决方案。

Saturn是唯品会开源的一个分布式任务调度平台，在Elastic Job的基础上进行了改造。

SIA-TASK是宜信开源的分布式任务调度平台。

## 小结

通过本文梳理了6种定时任务的实现，就实践场景的运用来说，目前大多数系统已经脱离了单机模式。对于并发量并不是太高的系统，xxl-job或许是一个不错的选择。

源码地址：[github.com/secbr/java-…](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fsecbr%2Fjava-schedule)



----

# [一文搞懂⭐java中的定时任务框架-分布式(xxl-job)](https://juejin.cn/post/7043966654534909988)

# 阅读收获

✔️1. 了解常用的分布式应用定时任务框架

✔️2. 掌握xxl-job定时任务框架搭建及使用

# 常用的分布式任务调度系统

- `xxl-job`: 是大众点评员工徐雪里于2015年发布的分布式任务调度平台，是一个轻量级分布式任务调度框架，其核心设计目标是开发迅速、学习简单、轻量级、易扩展。
- `Quartz`：Java事实上的定时任务标准。但Quartz关注点在于定时任务而非数据，并无一套根据数据处理而定制化的流程。虽然Quartz可以基于数据库实现作业的高可用，但缺少分布式并行调度的功能
- `TBSchedule`：阿里早期开源的分布式任务调度系统。代码略陈旧，使用timer而非线程池执行任务调度。众所周知，timer在处理异常状况时是有缺陷的。而且TBSchedule作业类型较为单一，只能是获取/处理数据一种模式。还有就是文档缺失比较严重
- `elastic-job（E-Job）`：当当开发的弹性分布式任务调度系统，功能丰富强大，采用zookeeper实现分布式协调，实现任务高可用以及分片，目前是版本2.15，并且可以支持云开发
- `Saturn`：是唯品会自主研发的分布式的定时任务的调度平台，基于当当的elastic-job 版本1开发，并且可以很好的部署到docker容器上。

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b44774734c724be885de7aaa668da890~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

- 共同点： 
  - E-Job和X-job都有广泛的用户基础和完整的技术文档，都能满足定时任务的基本功能需求。
- 不同点 
  - X-Job 侧重的业务实现的简单和管理的方便，学习成本简单，失败策略和路由策略丰富。推荐使用在“用户基数相对少，服务器数量在一定范围内”的情景下使用
  - E-Job 关注的是数据，增加了弹性扩容和数据分片的思路，以便于更大限度的利用分布式服务器的资源。但是学习成本相对高些，推荐在“数据量庞大，且部署服务器数量较多”时使用

# xxl-job

设计思想：

- 将调度行为抽象形成“调度中心”公共平台，而平台自身并不承担业务逻辑，“调度中心”负责发起调度请求。
- 将任务抽象成分散的JobHandler，交由“执行器”统一管理，“执行器”负责接收调度请求并执行对应的JobHandler中业务逻辑。
- 因此，“调度”和“任务”两部分可以相互解耦，提高系统整体稳定性和扩展性；
- `本文使用版本为2.3.0`

## 1.下载**源码**

- [github下载地址](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fxuxueli%2Fxxl-job%2F)
- [gitee下载地址](https://link.juejin.cn?target=https%3A%2F%2Fgitee.com%2Fxuxueli0323%2Fxxl-job)

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b9f4468d9da94308b9941b99b458155e~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

## 2. 初始化**数据库**

- 执行tables_xxl_job.sql文件初始化
- 调度中心支持集群部署，集群情况下各节点务必连接同一个mysql实例;
- 如果mysql做主从,调度中心集群节点务必强制走主库; 
  - xxl_job_lock：任务调度锁表；
  - xxl_job_group：执行器信息表，维护任务执行器信息；
  - xxl_job_info：调度扩展信息表： 用于保存XXL-JOB调度任务的扩展信息，如任务分组、任务名、机器地址、执行器、执行入参和报警邮件等等；
  - xxl_job_log：调度日志表： 用于保存XXL-JOB任务调度的历史信息，如调度结果、执行结果、调度入参、调度机器和执行器等等；
  - xxl_job_log_report：调度日志报表：用户存储XXL-JOB任务调度日志的报表，调度中心报表功能页面会用到；
  - xxl_job_logglue：任务GLUE日志：用于保存GLUE更新历史，用于支持GLUE的版本回溯功能；
  - xxl_job_registry：执行器注册表，维护在线的执行器和调度中心机器地址信息；
  - xxl_job_user：系统用户表；

## 3. 配置部署**调度中心**

- 调度中心项目：xxl-job-admin
- 作用：**统一管理任务调度平台上调度任务，负责触发调度执行，并且提供任务管理平台。** 3.1 主要修改配置：
- 修改数据源
- 修改报警邮箱
- 调度中心通讯TOKEN

```properties
### xxl-job, datasource
spring.datasource.url=jdbc:mysql://localhost:3306/xxl_job?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

### xxl-job, email
spring.mail.host=smtp.qq.com
spring.mail.port=25
spring.mail.username=xxx@qq.com
spring.mail.from=xxx@qq.com
spring.mail.password=你的mail token
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.starttls.required=true
spring.mail.properties.mail.smtp.socketFactory.class=javax.net.ssl.SSLSocketFactory

### 调度中心通讯TOKEN [选填]：非空时启用；
### xxl-job, access token
xxl.job.accessToken=ljwtoken
复制代码
```

3.2. 打包部署“调度中心”

- mvn clean package  -Dmaven.test.skip=true

3.3. 访问调度中心

- 调度中心访问地址：[http://localhost:8080/xxl-job-admin](https://link.juejin.cn?target=http%3A%2F%2Flocalhost%3A8080%2Fxxl-job-admin) (`该地址执行器配置文件xxl.job.admin.addresses将会使用到，作为回调地址`)
- 默认登录账号 “admin/123456”, 登录后运行界面如下图所示。
- [调度中心集群部署参考](https://link.juejin.cn?target=https%3A%2F%2Fwww.xuxueli.com%2Fxxl-job%2F%23%E6%AD%A5%E9%AA%A4%E4%B8%89%EF%BC%9A%E8%B0%83%E5%BA%A6%E4%B8%AD%E5%BF%83%E9%9B%86%E7%BE%A4%EF%BC%88%E5%8F%AF%E9%80%89%EF%BC%89%EF%BC%9A)

## 4. 配置部署**执行器项目**

- “执行器”项目：xxl-job-executor-sample-springboot (提供多种版本执行器供选择，现以 springboot 版本为例，`可直接使用，也可以参考其并将现有项目改造成执行器`)
- 作用：**负责接收“调度中心”的调度并执行；可直接部署执行器，也可以将执行器集成到现有业务项目中。**
- 原理： 
  - 执行器实际上是一个内嵌的Server，默认端口9999（配置项：xxl.job.executor.port）。
  - 在项目启动时，执行器会通过“@JobHandler”识别Spring容器中“Bean模式任务”，以注解的value属性为key管理起来。
  - “执行器”接收到“调度中心”的调度请求时，如果任务类型为“Bean模式”，将会匹配Spring容器中的“Bean模式任务”，然后调用其execute方法，执行任务逻辑。如果任务类型为“GLUE模式”，将会加载GLue代码，实例化Java对象，注入依赖的Spring服务（注意：Glue代码中注入的Spring服务，必须存在与该“执行器”项目的Spring容器中），然后调用execute方法，执行任务逻辑。

4.1 maven依赖

- 执行器项目需要引入 “xxl-job-core” 的maven依赖，版本要和注册中心版本一致

```xml
<dependency>
    <groupId>com.xuxueli</groupId>
    <artifactId>xxl-job-core</artifactId>
    <version>${project.parent.version}</version>
</dependency>
复制代码
```

4.2 修改配置文件：

- xxl-job-executor-sample-springboot/src/main/resources/application.properties
- 修改调度中心部署跟地址
- 需修改或自定义 
  - xxl.job.admin.addresses 地址
  - xxl.job.executor.appname 自定义名称，后台配置必须对应
  - xxl.job.executor.ip 当前电脑Ip，或部署项目的电脑Ip
  - xxl.job.executor.port 端口
  - xxl.job.accessToken 自定义的token，要和admin模块配置的一致

```properties
### 调度中心部署跟地址 [选填]：如调度中心集群部署存在多个地址则用逗号分隔。执行器将会使用该地址进行"执行器心跳注册"和"任务结果回调"；为空则关闭自动注册；
xxl.job.admin.addresses=http://127.0.0.1:8080/xxl-job-admin

### xxl-job, access token 自定义的token，要和admin模块配置的一致
xxl.job.accessToken=ljwtoken

### xxl-job executor appname 自定义名称，后台配置必须对应
xxl.job.executor.appname=xxl-job-executor-sample
### xxl-job executor registry-address: default use address to registry , otherwise use ip:port if address is null
xxl.job.executor.address=
### xxl-job executor server-info
xxl.job.executor.ip=127.0.0.1
xxl.job.executor.port=9999
```

4.3  执行器组件配置 要配置执行器组件，配置文件参考地址：`/xxl-job/xxl-job-executor-samples/xxl-job-executor-sample-springboot/src/main/java/com/xxl/job/executor/core/config/XxlJobConfig.java`

```java
@Bean
public XxlJobSpringExecutor xxlJobExecutor() {
    logger.info(">>>>>>>>>>> xxl-job config init.");
    XxlJobSpringExecutor xxlJobSpringExecutor = new XxlJobSpringExecutor();
    xxlJobSpringExecutor.setAdminAddresses(adminAddresses);
    xxlJobSpringExecutor.setAppname(appname);
    xxlJobSpringExecutor.setAddress(address);
    xxlJobSpringExecutor.setIp(ip);
    xxlJobSpringExecutor.setPort(port);
    xxlJobSpringExecutor.setAccessToken(accessToken);
    xxlJobSpringExecutor.setLogPath(logPath);
    xxlJobSpringExecutor.setLogRetentionDays(logRetentionDays);

    return xxlJobSpringExecutor;
}
复制代码
```

4.4  部署执行器项目

- 如果已经正确进行上述配置，将执行器项目编译打部署，我们使用springboot项目，打包运行xxl-job-executor-sample-springboot即可
- mvn clean package  -Dmaven.test.skip=true
- [执行器项目集群部署参考](https://link.juejin.cn?target=https%3A%2F%2Fwww.xuxueli.com%2Fxxl-job%2F%23%E6%AD%A5%E9%AA%A4%E4%B8%89%EF%BC%9A%E8%B0%83%E5%BA%A6%E4%B8%AD%E5%BF%83%E9%9B%86%E7%BE%A4%EF%BC%88%E5%8F%AF%E9%80%89%EF%BC%89%EF%BC%9A)

## 5. GLUE模式(Java)开发一个任务

- **GLUE模式(Java)原理：任务以源码方式维护在调度中心；该模式的任务实际上是一段继承自IJobHandler的Java类代码并 "groovy" 源码方式维护，它在执行器项目中运行，==可使用@Resource/@Autowire注入执行器里中的其他服务（请确保Glue代码中的服务和类引用在“执行器”项目中存在，业务逻辑类）==，然后调用该对象的execute方法，执行任务逻辑。**
- GLUE模式(Java)就是在界面编写代码即可，不用在执行器项目中编写代码

**5.1 新建任务**

- 登录调度中心，点击下图所示“新增”按钮，新建示例任务。然后，参考下面截图中任务的参数配置，点击保存。

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6ffd72e8fa084fc09400cb7c18ecb3dd~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

**5.2 “GLUE模式(Java)” 任务开发**

- 请点击任务右侧 “GLUE IDE” 按钮，进入 “GLUE编辑器开发界面” ，见下图。“GLUE模式(Java)” 运行模式的任务默认已经初始化了示例任务代码，即打印Hello World。

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5e1f0339f3840d3957e0d59df39113f~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

**5.3 触发执行**

- 请点击任务右侧 “执行一次” 按钮，可手动触发一次任务执行（通常情况下，通过配置Cron表达式进行任务调度触发）。

**5.4  查看日志：**

- 请点击任务右侧 “调度日志” 按钮，可前往任务日志界面查看任务日志。
- 在任务日志界面中，可查看该任务的历史调度记录以及每一次调度的任务调度信息、执行参数和执行信息。运行中的任务点击右侧的“执行日志”按钮，可进入日志控制台查看实时执行日志。

## 6. BEAN模式开发一个任务

- **BEAN模式原理：任务以JobHandler方式维护在执行器端；需要结合 "JobHandler" ，任务类需要加“@JobHandler(value="名称")”注解，因为“执行器”会根据该注解识别Spring容器中的任务。任务类需要继承统一接口“IJobHandler”，任务逻辑在execute方法中开发，因为“执行器”在接收到调度中心的调度请求时，将会调用“IJobHandler”的execute方法，执行任务逻辑。**

### 6.1 类形式

**6.1.1 优缺点**

- Bean模式任务，支持基于类的开发方式，每个任务对应一个Java类。 
  - 优点： 
    - 不限制项目环境，兼容性好。即使是无框架项目，如main方法直接启动的项目也可以提供支持
  - 缺点： 
    - 每个任务需要占用一个Java类，造成类的浪费；
    - 不支持自动扫描任务并注入到执行器容器，需要手动注入。

**6.1.2 执行器项目中，开发Job类**

- 1、开发一个继承自"com.xxl.job.core.handler.IJobHandler"的JobHandler类，实现其中任务方法。
- 2、手动通过如下方式注入到执行器容器。 
  - ：XxlJobExecutor.registJobHandler("demoJobHandler", new DemoJobHandler());

注：`版本v2.2.0 移除旧类注解@JobHandler，推荐使用基于方法注解@XxlJob的方式进行任务开发；(如需保留类注解JobHandler使用方式，可以参考旧版逻辑定制开发);`

```java
public class MyJobHandler extends IJobHandler {
    @Override
    public void execute() throws Exception {
        XxlJobHelper.log("11==============MyJobHandler=================");
        System.out.println("22==============MyJobHandler=================");
    }
}
复制代码
```

手动注入myJobHandler：（版本v2.2.0 以前可用类注解@JobHandler自动注入）

```java
@SpringBootApplication
public class XxlJobExecutorApplication {

    public static void main(String[] args) {
        SpringApplication.run(XxlJobExecutorApplication.class, args);

        XxlJobExecutor.registJobHandler("myJobHandler", new MyJobHandler());
    }

}
```

**6.1.3  调度中心，新建调度任务**

- JobHandler填写@JobHandler的value值 ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fbbd6b1e14f247308c85bd0f5386fbb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)
- 新建后可以测试运行一次查看日志是否成功

### 6.2 方法形式

作用和类形式同，只是不用每个任务再开发一个JobHandler类，都共用一个类，在方法上加@XxlJob注解即可实现一个执行器。

**6.2.1 优缺点**

- 基于方法开发的任务，底层会生成JobHandler代理，和基于类的方式一样，任务也会以JobHandler的形式存在于执行器任务容器中。 
  - 优点： 
    - 每个任务只需要开发一个方法，并添加@XxlJob注解即可，更加方便、快速。
    - 支持自动扫描任务并注入到执行器容器。
  - 缺点：要求Spring容器环境

**6.2.2 执行器项目中，开发Job方法**

- 1. 任务开发：在Spring Bean实例中，开发Job方法
- 1. 注解配置：为Job方法添加注解 "@XxlJob(value="自定义jobhandler名称", init = "JobHandler初始化方法", destroy = "JobHandler销毁方法")"，注解value值对应的是调度中心新建任务的JobHandler属性的值。
- 1. 执行日志：需要通过 "XxlJobHelper.log" 打印执行日志
- 1. 任务结果：**默认任务结果为 "成功" 状态，不需要主动设置；如有诉求，比如设置任务结果为失败，可以通过 "XxlJobHelper.handleFail/handleSuccess" 自主设置任务结果**

```java
@Configuration
public class MyXxlJobConfig {

    @XxlJob("myXxlJobConfig")
    public boolean demoJobHandler() throws Exception {
        XxlJobHelper.log("========myXxlJobConfig============");
        System.out.println("========myXxlJobConfig============");
        //ReturnT无作用
        //return new ReturnT(200, "hahahahah");
        return XxlJobHelper.handleSuccess("myXxlJobConfig hello world");
    }


    @XxlJob("myfaile")
    public boolean myfaile() throws Exception {
        XxlJobHelper.log("========myfaile============");
        System.out.println("========myfaile============");
        return XxlJobHelper.handleFail("myfaile hello world");
    }
    
 
    /**
     * 5、生命周期任务示例：任务初始化与销毁时，支持自定义相关逻辑；init只在第一次调度时执行一次。destroy每次调度都执行
     */
    @XxlJob(value = "demoJobHandler2", init = "init", destroy = "destroy")
    public void demoJobHandler2() throws Exception {
        System.out.println("========demoJobHandler2============");
        XxlJobHelper.log("XXL-JOB, Hello World.");
    }

    public void init() {
        System.out.println("========init============");
        logger.info("init");
    }

    public void destroy() {
        System.out.println("========destory============");
        logger.info("destory");
    }

}
复制代码
```

**6.2.3 调度中心，新建调度任务**

- 修改JobHandler为@XxlJob("myfaile")名称即可，其他照样新建任务就行 ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d8ae0b03056c48a38b81214bd39d01f5~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)
- 新建后可以测试运行一次查看日志是否成功
- myfaile方法返回为return XxlJobHelper.handleFail("myfaile hello world");是错误的，但是任务是调度成功的 ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/11bbfa0f526b4d5daa110d1cefd0f503~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

注：

- [配置属性详细说明](https://link.juejin.cn?target=https%3A%2F%2Fwww.xuxueli.com%2Fxxl-job%2F%23%E4%B8%89%E3%80%81%E4%BB%BB%E5%8A%A1%E8%AF%A6%E8%A7%A3)

## 任务执行结果说明

系统根据以下标准判断任务执行结果

- 任务执行成功：XxlJobHelper.handleSuccess()
- 任务执行失败：XxlJobHelper.handleFail()
- 注：任务调度室成功的，这里只是业务返回结果的判断

## 终止运行中的任务

仅针对执行中的任务。 在任务日志界面，点击右侧的“终止任务”按钮，将会向本次任务对应的执行器发送任务终止请求，将会终止掉本次任务，同时会清空掉整个任务执行队列。

![输入图片说明](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8d61ec9e2776478cbcbf5aa2b514d7df~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp)

任务终止时通过 "interrupt" 执行线程的方式实现, 将会触发 "InterruptedException" 异常。因此如果JobHandler内部catch到了该异常并消化掉的话, 任务终止功能将不可用。

因此, 如果遇到上述任务终止不可用的情况, 需要在JobHandler中应该针对 "InterruptedException" 异常进行特殊处理 (向上抛出) , 正确逻辑如下:

```java
try{
    // do something
} catch (Exception e) {
    if (e instanceof InterruptedException) {
        throw e;
    }
    logger.warn("{}", e);
}
复制代码
```

而且，在JobHandler中开启子线程时，子线程也不可catch处理"InterruptedException"，应该主动向上抛出。

任务终止时会执行对应JobHandler的"destroy()"方法，可以借助该方法处理一些资源回收的逻辑。

## 任务超时控制

- 支持设置任务超时时间，任务运行超时的情况下，将会主动中断任务；
- 需要注意的是，任务超时中断时与任务终止机制（可查看章节“终止运行中的任务”）类似，也是通过 "interrupt" 中断任务，因此业务代码需要将 "InterruptedException" 外抛，否则功能不可用。



# [实际项目使用Xxl-job](https://blog.csdn.net/m0_68064743/article/details/123763621)

等我工作了之后，我学到了一个新的名词「分布式定时任务框架」。等我踏入职场了以后，我才发现原来定时任务这么好使！

列举下我真实工作时使用定时任务的常见姿势：

1、动态创建定时任务推送运营类的消息（定时推送消息）

2、广告结算定时任务扫表找到对应的可结算记录（定时扫表更新状态）

3、每天定时更新数据记录（定时更新数据）

还很多人问我有没有用过分布式事务，我往往会回答：没有啊，我们都是扫表一把梭保证数据最终一致性的当然了，如果是面试的时候被问到，可以吹吹分布式事务。实际上是怎么扫表的呢？就是定时扫的咯。

另外，我当时简单看了下公司自研的分布式定时任务框架是怎么做的，我记得是基于Quartz进行扩展的，扩展有failover、分片等等机制。

一般来说，使用定时任务就是在应用启动或者提前在Web页面配置好定时任务（定时任务框架都是支持cron表达式的，所以是周期或者定时的任务)，这种场景是最最最多的。



## 为什么分布式定时任务

在前面提到Timer/ScheduledExecutorService/SpringTask(@Schedule)都是单机的，但我们一旦上了生产环境，应用部署往往都是集群模式的。

在集群下，我们一般是希望某个定时任务只在某台机器上执行，那这时候，单机实现的定时任务就不太好处理了。

Quartz是有集群部署方案的，所以有的人会利用数据库行锁或者使用Redis分布式锁来自己实现定时任务跑在某一台应用机器上；做肯定是能做的，包括有些挺出名的分布式定时任务框架也是这样做的，能解决问题。

但我们遇到的问题不单单只有这些，比如我想要支持容错功能（失败重试）、分片功能、手动触发一次任务、有一个比较好的管理定时任务的后台界面、路由负载均衡等等。这些功能，就是作为「分布式定时任务框架」所具备的。

既然现在已经有这么多的轮子了，那我们作为使用方/需求方就没必要自己重新实现一套了，用现有的就好了，我们可以学习现有轮子的实现设计思想。

### 分布式定时任务基础

Quartz是优秀的开源组件，它将定时任务抽象了三个角色：调度器、执行器和任务，以至于市面上的分布式定时任务框架都有类似角色划分。

![image](https://img-blog.csdnimg.cn/img_convert/c47a7e1e67438eae2115205e42a20ff9.png)

对于我们使用方而言，一般是引入一个client包，然后根据它的规则（可能是使用注解标识，又或是实现某个接口），随后自定义我们自己的定时任务逻辑。

![image](https://img-blog.csdnimg.cn/img_convert/5b6af2fdcbc6adbe3a2753147b48229c.png)

看着上面的执行图对应的角色抽象以及一般使用姿势，应该还是比较容易理解这个过程的。我们又可以再稍微思考两个问题：

1、 任务信息以及调度的信息是需要存储的，存储在哪？调度器是需要「通知」执行器去执行的，那「通知」是以什么方式去做？

2、调度器是怎么找到即将需要执行的任务的呢？

针对第一个问题，分布式定时任务框架又可以分成了两个流派：中心化和去中心化

所谓的「中心化」指的是：调度器和执行器分离，调度器统一进行调度，通知执行器去执行定时任务
所谓的「去中心化」指的是：调度器和执行器耦合，自己调度自己执行
对于「中心化」流派来说，存储相关的信息很可能是在数据库（DataBase），而我们引入的client包实际上就是执行器相关的代码。调度器实现了任务调度的逻辑，远程调用执行器触发对应的逻辑。

![image](https://img-blog.csdnimg.cn/img_convert/aa6673ff8b42da544dd890b44bb45b1b.png)

调度器「通知」执行器去执行任务时，可以是通过「RPC」调用，也可以是把任务信息写入消息队列给执行器消费来达到目的。

![image](https://img-blog.csdnimg.cn/img_convert/936bfb41284fce9f7f256698f82aeb2a.png)

对于「去中心化」流派来说存储相关的信息很可能是在注册中心（Zookeeper），而我们引入的client包实际上就是执行器+调度器相关的代码。

依赖注册中心来完成任务的分配，「中心化」流派在调度的时候是需要保证一个任务只被一台机器消费，这就需要在代码里写分布式锁相关逻辑进行保证，而「去中心化」依赖注册中心就免去了这个环节。

![image](https://img-blog.csdnimg.cn/img_convert/9838132965fc14151dcc9b546f6cf6b0.png)

针对第二个问题，调度器是怎么找到即将需要执行的任务的呢？现在一般较新的分布式定时任务框架都用了「时间轮」。

1、如果我们日常要找到准备要执行的任务，可能会把这些任务放在一个List里然后进行判断，那此时查询的时间复杂度为O(n)

2、稍微改进下，我们可能把这些任务放在一个最小堆里（对时间进行排序），那此时的增删改时间复杂度为O(logn)，而查询是O(1)

3、再改进下，我们把这些任务放在一个环形数组里，那这时候的增删改查时间复杂度都是O(1)。但此时的环形数组大小决定着我们能存放任务的大小，超出环形数组的任务就需要用另外的数组结构存放。

4、最后再改进下，我们可以有多层环形数组，不同层次的环形数组的精度是不一样的，使用多层环形数组能大大提高我们的精度。

![image](https://img-blog.csdnimg.cn/img_convert/92434fb4822f39934640c2c449e5b597.png)

## 分布式定时任务框架选型

分布式定时任务框架现在可选择的还是挺多的，比较出名的有：` XXL-JOB/Elastic-Job/LTS/SchedulerX/Saturn/PowerJob`等等等。有条件的公司可能会基于Quartz进行拓展，自研一套符合自己的公司内的分布式定时任务框架。

我并不是做这块出身的，对于我而言，我的austin项目技术选型主要会关注两块（其实跟选择apollo作为分布式配置中心的理由是一样的）：成熟、稳定、社区是否活跃。

这一次我选择了xxl-job作为austin的分布式任务调度框架。xxl-job已经有很多公司都已经接入了（说明他的开箱即用还是很到位的）。不过最新的一个版本在2021-02，近一年没有比较大的更新了。

![image](https://img-blog.csdnimg.cn/img_convert/dc49b89c177f7acb25f7d0dc854f04a0.png)

## 为什么austin需要分布式定时任务框架

回到austin的系统架构上，austin-admin后台管理页面已经被我造出来了，这个后台管理系统会提供「消息模板」的管理功能。

![image](https://img-blog.csdnimg.cn/img_convert/6b3b648b54211af80cb239a09c0262da.png)

那发送一条消息不单单是「技术侧」调用接口进行发送的，还有很多是「运营侧」通过设置定时进而推送。

![image](https://img-blog.csdnimg.cn/img_convert/d9e9992bf3abf7b2390bfea0c1238486.png)



而这个功能，就需要用到分布式定时任务框架作为中间件支撑我的业务，并且很重要的一点：分布式定时任务框架需要支持动态创建定时任务的功能。

当在页面点击「启动」的时候，就需要创建一个定时任务，当在页面点击「暂停」的时候，就需要停止定时任务，当在页面点击「删除」模板的时候，如果曾经有过定时任务，就需要把它给一起删掉。当在页面点击「编辑」并保存的时候，也需要把停止定时任务。

嗯，所需要的流程就这些了

## austin接入xxl-job

接入xxl-job分布式定时任务框架的步骤还是蛮简单的（看下文档基本就会了），我简单说下吧。接入具体的代码大家可以拉ausitn的下来看看，我会重点讲讲我接入时的感受。

**==1、自己项目上引入xxl-job-core的maven依赖==**

==**2、在MySQL中执行/xxl-job/doc/db/tables_xxl_job.sql的SQL脚本**==

==**3、从Gitee或GitHub下载xxl-job的源码，修改xxl-job-admin调度中心的数据库配置，启动xxl-job-admin项目。**==

==**4、在自己项目上添加xxl-job相关的配置信息**==

==**5、使用@XxlJob注解修饰方法编写定时任务的相关逻辑**==

![image](https://img-blog.csdnimg.cn/img_convert/f5dc292df8c316797d986fb012331a55.png)

从接入或者已经看过文档的小伙伴应该就很容易发现，xxl-job它是属于「中心化」流派的分布式定时任务框架，调度器和执行器是分离的。

![image](https://img-blog.csdnimg.cn/img_convert/8ccc289622ae7d18d38fad8c2af29f06.png)

在前面我提到了austin需要动态增删改定时任务，而xxl-job是支持的，但我觉得没封装得足够好，只在调度器上给出了http接口。而调用http接口是相对麻烦的，很多相关的JavaBean都没有在core包定义，只能我自己再写一次。

所以，我花了挺长的时间和挺多的代码去完成动态增删改定时任务这个工作。

![image](https://img-blog.csdnimg.cn/img_convert/cad25a06c80be7768964032b06479d3c.png)

调度器和执行器是分开部署的，意味着，调度器和执行器的网络是必须可通的：原本我在本地是没有装任何的环境的，包括MySQL我都是连接云服务器的，但是现在我要调试就必须在网络可通的环境内，所以我不得不在本地启动xxl-job-admin调度中心来调试。

在启动执行器的时候，会开一个新的端口给xxl-job-admin调度中心调用而不是复用SpringBoot默认端口也是挺奇怪的？



**总结**
这篇文章主要讲了什么是定时任务、为什么要用定时任务、在Java领域中如果有定时任务相关的需求可以用什么来实现、分布式定时任务的基础知识以及如何接入XXL-JOB

相信大家对分布式定时任务框架有了个基本的了解，如果感兴趣可以挑个开源框架去学学，在此我向大家推荐一个架构学习交流圈。交流学习伪鑫：539413949（里面有大量的面试题及答案）里面会分享一些资深架构师录制的视频录像：有Spring，MyBatis，Netty源码分析，高并发、高性能、分布式、微服务架构的原理，JVM性能优化、分布式架构等这些成为架构师必备的知识体系。还能领取免费的学习资源，目前受益良多



-----

# [利用redis分布式锁执行定时任务的问题｜ Java Debug 笔记](https://juejin.cn/post/6961043636918157319)

## 前言

昨天我写了微信获取token接口超限制问题，然后我给出的解决方案虽热把问题解决了，但是现在看来这个解决方案有点愚蠢，也许只有我这种笨人才会想出来的方法，很不优雅，今天用户**小眼睛聊技术**在文章下评论了代码用lock锁实现手动加锁，获取完手动释放锁的机制优雅的解决了该问题，顿时让我恍然大悟，菜是原罪呀，这种多线程的编程我还是接触的少，就是压根没想过用锁解决，一旦点明顿时眼前一亮，最后我准备按这位小伙伴的方案改，在基础上优化了存每个token的时候需要加过期时间的随机数，不能让所有token在相同时间全部过期，如果全部过期加锁的方案就会有问题，这次我真的体会到了掘金真的是个**帮助开发者成长的社区**，非常感谢小伙伴**小眼睛聊技术**，我不在社区写这个bug我一直都得不到这种优雅的解法，写的不对，写的菜没关系，能成长就是最大的收获，所以我今天又来写bug了。可能改完还是个bug。

## 问题

突然有一天好好的定时任务不执行了，项目重启也不执行，在做在线作业的时候有个需求是每周天下午四点统计本周的学生做作业情况，然后发现周报停留在某一周，这之后就没有周报的数据统计了。

## 分析问题

直接打开执行周报的定时任务代码，这个代码不是我写的，我贴下原代码。由于是部署了多个节点，所以用了redis的分布式锁，如果不用分布式锁，那么每个节点都执行一次定时任务，那么周报肯定执行重复了。代码如下：

```csharp
private static final String LOCK = "task0-job-lock-on";

private static final String KEY = "task0lock-on";
@Scheduled(cron="${data.sync.cron}")
public void studentWeeklyReport(){
    boolean lock = false;
    try {
        lock = redisTemplate.opsForValue().setIfAbsent(KEY, LOCK);
        if (lock) {
            System.out.println("start student Weekly Report!" + new Date());
            //调用业务逻辑代码
            System.out.println("end student Weekly Report!！" + new Date());
        } else {
            logger.info("未获取到锁，不执行定时任务");
        }
    } finally {
        if (lock) {
            redisTemplate.delete(KEY);
            logger.info("任务结束，释放锁!");
        } else {
            logger.info("没有获取到锁，无需释放锁!");
        }
    }
}
复制代码
```

说明：data.sync.cron是配置执行定时任务的Cron表达式，整个逻辑很简单，通过`redisTemplate.opsForValue().setIfAbsent(KEY, LOCK)`判断redis是否存在absentValue为LOCK的值，如果不存在返回true，并把当前值放进redis，那么下次调用的时候如果没有删除当前key的时候，获取到的是false。如果为true在执行业务代码生成周报，执行完之后在finally又判断了lock是否存在，如果还是true那么删除key。

看完代码第一感觉，可以直接改成如下代码：

```csharp
@Scheduled(cron = "${data.sync.cron}")
public void studentWeeklyReport() {
    boolean lock = false;
    try {
        lock = redisTemplate.opsForValue().setIfAbsent(KEY, LOCK);
        if (lock) {
            System.out.println("start student Weekly Report!" + new Date());
            //调用业务逻辑代码
            System.out.println("end student Weekly Report!！" + new Date());
        }
    } finally {
        redisTemplate.delete(KEY);
        logger.info("任务结束，释放锁!");
    }
}

复制代码
```

这个代码和上面的代码逻辑完全没变，但是这个代码肯定解决不了问题，如果代码在执行业务逻辑代码的时候，恰好服务器宕机了，或者上线停机重启，那么redis里面会永远存在absentValue的值，下次定时任务进来直接就退出了，那么解决方法就是加一个过期时间，如果出现宕机的时候，到时间会自动过期，那么就不存在这种问题，对于加过期时间，不建议使用如下写法。

```csharp
 @Scheduled(cron = "${data.sync.cron}")
    public void studentWeeklyReport() {
        boolean lock = false;
        try {
            lock = redisTemplate.opsForValue().setIfAbsent(KEY, LOCK);
            redisTemplate.expire(KEY, 60, TimeUnit.SECONDS);
            if (lock) {
                System.out.println("start student Weekly Report!" + new Date());
                //调用业务逻辑代码
                System.out.println("end student Weekly Report!！" + new Date());
            }
        } finally {
            redisTemplate.delete(KEY);
            logger.info("任务结束，释放锁!");
        }
    }
复制代码
```

在`setIfAbsent()`下一行设置key的过期时间`redisTemplate.expire(KEY, 60, TimeUnit.SECONDS)`这两步不是原子性操作，在刚好执行到这两行中间如果服务宕机了，那么和上面情况一样，redis永久存在absentValue的值。redis提供了设置值和过期时间具有原子性的方法。那么修改如下：

```csharp
  @Scheduled(cron = "${data.sync.cron}")
  public void studentWeeklyReport() {
        boolean lock = redisTemplate.opsForValue().setIfAbsent(KEY, LOCK, 1000 * 60, TimeUnit.MILLISECONDS);
        if (!lock) {
            return;
        }
        
        try {

            System.out.println("start student Weekly Report!" + new Date());
            //调用业务逻辑代码
            System.out.println("end student Weekly Report!！" + new Date());

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            redisTemplate.delete(KEY);
            logger.info("任务结束，释放锁!");
        }
    }
复制代码
```

这样在存值的时候同时设置了过期时间，即使业务执行过程中出现宕机，那么redis里面的值到了过期时间也会自动删除，不影响下次的定时任务执行。

注意：设置超时时间一定要大于你真实执行任务的时间，如果小余，前面的任务还没执行完，redis的key自动过期，那么下一次的任务就会进来，导致任务重复执行。那么还是有问题，这个时间我暂时不知道怎么去设置合理，对与我这个业务执行周期是一周，这个过期时间很好预估，但是精确的去判断是否过期我还没思路。

这个项目最后交给别的项目组维护了，我也再没跟这个定时任务，不知道这样修改还有其他啥问题没，如果有更好的解决方案欢迎讨论。

## 总结

想了想，有一种情况如果别人知道我的key的值，我自己线程没有删除，我的key被别的线程误删除，那么也有问题，这种可以用ThreadLocal实现来解决问题。思路就是哪个线程放的key哪个线程才能删除key，其他线程不让删除。具体实现我再去研究下，今天的bug先到这。我去研究下ThreadLocal....

