# 一、[Spring SchedulingConfigurer 实现动态定时任务](https://mp.weixin.qq.com/s/4jX7aU3M6Z-d1-AUX0qBIw)

## 一、前言



大家在日常工作中，一定使用过 Spring 的 `@Scheduled` 注解吧，通过该注解可以非常方便的帮助我们实现任务的定时执行。

但是该注解是不支持运行时动态修改执行间隔的，不知道你在业务中有没有这些需求和痛点：

•在服务运行时能够动态修改定时任务的执行频率和执行开关，而无需重启服务和修改代码•能够基于配置，在不同环境/机器上，实现定时任务执行频率的差异化

这些都可以通过 Spring 的 `SchedulingConfigurer` 注解来实现。

这个注解其实大家并不陌生，如果有使用过 @Scheduled 的话，因为 @Scheduled 默认是单线程执行的，因此如果存在多个任务同时触发，可能触发阻塞。使用 SchedulingConfigurer 可以配置用于执行 @Scheduled 的线程池，来避免这个问题。

```java
@Configuration
public class ScheduleConfig implements SchedulingConfigurer {
    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        //设定一个长度10的定时任务线程池
        taskRegistrar.setScheduler(Executors.newScheduledThreadPool(10));
    }
}
```

但其实这个接口，还可以实现动态定时任务的功能，下面来演示如何实现。



## 二、功能实现



> 后续定义的类开头的 `DS` 是 `Dynamic Schedule` 的缩写。

使用到的依赖，除了 Spring 外，还包括：

```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
</dependency>

<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-collections4</artifactId>
    <version>4.4</version>
</dependency>

<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <scope>provided</scope>
    <version>1.18.18</version>
</dependency>
```

### 2.1 @EnableScheduling

首先需要开启 `@EnableScheduling` 注解，直接在启动类添加即可：

```java
@EnableScheduling
@SpringBootApplication
public class DSApplication {
    public static void main(String[] args) {
        SpringApplication.run(DSApplication.class, args);
    }
}
```

### 2.2 IDSTaskInfo

定义一个任务信息的接口，后续所有用于动态调整的任务信息对象，都需要实现该接口。

•`id`：该任务信息的唯一 ID，用于唯一标识一个任务•`cron`：该任务执行的 cron 表达式。•`isValid`：任务开关•`isChange`：用于标识任务参数是否发生了改变

```java
public interface IDSTaskInfo {
    /**
     * 任务 ID
     */
    long getId();

    /**
     * 任务执行 cron 表达式
     */
    String getCron();

    /**
     * 任务是否有效
     */
    boolean isValid();

    /**
     * 判断任务是否发生变化
     */
    boolean isChange(IDSTaskInfo oldTaskInfo);
}
```

### 2.3 DSContainer

顾名思义，是存放 IDSTaskInfo 的容器。

具有以下成员变量：

•`scheduleMap`：用于暂存 IDSTaskInfo 和实际任务 ScheduledTask 的映射关系。其中：

•task_id：作为主键，确保一个 IDSTaskInfo 只会被注册进一次•T：暂存当初注册时的 IDSTaskInfo，用于跟最新的 IDSTaskInfo 比较参数是否发生变化•ScheduledTask：暂存当初注册时生成的任务，如果需要取消任务的话，需要拿到该对象•Semaphore：确保每个任务实际执行时只有一个线程执行，不会产生并发问题

•`taskRegistrar`：Spring 的任务注册管理器，用于注册任务到 Spring 容器中



具有以下成员方法：

•`void checkTask(final T taskInfo, final TriggerTask triggerTask)`：检查 IDSTaskInfo，判断是否需要注册/取消任务。具体的逻辑包括：

•如果任务已经注册：

•如果任务无效：则取消任务•如果任务有效：

•如果任务配置发生了变化：则取消任务并重新注册任务



•如果任务没有注册：

•如果任务有效：则注册任务





•`Semaphore getSemaphore()`：获取信号量属性。



```java
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.tuple.Pair;
import org.springframework.scheduling.config.ScheduledTask;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.config.TriggerTask;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Semaphore;

@Slf4j
public class DSContainer<T extends IDSTaskInfo> {
    /**
     * IDSTaskInfo和真实任务的关联关系
     *
     * <task_id, <Task, <Scheduled, Semaphore>>>
     */
    private final Map<Long, Pair<T, Pair<ScheduledTask, Semaphore>>> scheduleMap = new ConcurrentHashMap<>();

    private final ScheduledTaskRegistrar taskRegistrar;

    public DSContainer(ScheduledTaskRegistrar scheduledTaskRegistrar) {
        this.taskRegistrar = scheduledTaskRegistrar;
    }

    /**
     * 注册任务
     * @param taskInfo 任务信息
     * @param triggerTask 任务的触发规则
     */
    public void checkTask(final T taskInfo, final TriggerTask triggerTask) {
        final long taskId = taskInfo.getId();

        if (scheduleMap.containsKey(taskId)) {
            if (taskInfo.isValid()) {
                final T oldTaskInfo = scheduleMap.get(taskId).getLeft();

                if(oldTaskInfo.isChange(taskInfo)) {
                    log.info("DSContainer will register again because task config change, taskId: {}", taskId);
                    cancelTask(taskId);
                    registerTask(taskInfo, triggerTask);
                }
            } else {
                log.info("DSContainer will cancelTask because task not valid, taskId: {}", taskId);
                cancelTask(taskId);
            }
        } else {
            if (taskInfo.isValid()) {
                log.info("DSContainer will registerTask, taskId: {}", taskId);
                registerTask(taskInfo, triggerTask);
            }
        }
    }

    /**
     * 获取 Semaphore，确保任务不会被多个线程同时执行
     */
    public Semaphore getSemaphore(final long taskId) {
        return this.scheduleMap.get(taskId).getRight().getRight();
    }

    private void registerTask(final T taskInfo, final TriggerTask triggerTask) {
        final ScheduledTask latestTask = taskRegistrar.scheduleTriggerTask(triggerTask);
        this.scheduleMap.put(taskInfo.getId(), Pair.of(taskInfo, Pair.of(latestTask, new Semaphore(1))));
    }

    private void cancelTask(final long taskId) {
        final Pair<T, Pair<ScheduledTask, Semaphore>> pair = this.scheduleMap.remove(taskId);
        if (pair != null) {
            pair.getRight().getLeft().cancel();
        }
    }
}
```

### 2.4 AbstractDSHandler

下面定义实际的动态线程池处理方法，这里采用抽象类实现，将共用逻辑封装起来，方便扩展。

具有以下抽象方法：

•`ExecutorService getWorkerExecutor()`：提供用于真正执行任务时的线程池。•`List<T> listTaskInfo()`：获取所有的任务信息。•`void doProcess(T taskInfo)`：实现实际执行任务的业务逻辑。

具有以下公共方法：

•`void configureTasks(ScheduledTaskRegistrar taskRegistrar)`：创建 DSContainer 对象，并创建一个单线程的任务定时执行，调用 scheduleTask() 方法处理实际逻辑。•`void scheduleTask()`：首先加载所有任务信息，然后基于 cron 表达式生成 TriggerTask 对象，调用 checkTask() 方法确认是否需要注册/取消任务。当达到执行时间时，调用 execute() 方法，执行任务逻辑。•`void execute(final T taskInfo)`：获取信号量，成功后执行任务逻辑。

```java
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.config.TriggerTask;
import org.springframework.scheduling.support.CronTrigger;

import java.util.List;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

@Slf4j
public abstract class AbstractDSHandler<T extends IDSTaskInfo> implements SchedulingConfigurer {

    private DSContainer<T> dsContainer;

    private final String CLASS_NAME = getClass().getSimpleName();

    /**
     * 获取用于执行任务的线程池
     */
    protected abstract ExecutorService getWorkerExecutor();

    /**
     * 获取所有的任务信息
     */
    protected abstract List<T> listTaskInfo();

    /**
     * 做具体的任务逻辑
     */
    protected abstract void doProcess(T taskInfo);

    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        dsContainer = new DSContainer<>(taskRegistrar);
        // 每隔 100ms 调度一次，用于读取所有任务
        taskRegistrar.addFixedDelayTask(this::scheduleTask, 1000);
    }

    /**
     * 调度任务，加载所有任务并注册
     */
    private void scheduleTask() {
        CollectionUtils.emptyIfNull(listTaskInfo()).forEach(taskInfo -> 
                dsContainer.checkTask(taskInfo, new TriggerTask(() -> 
                        this.execute(taskInfo), triggerContext -> new CronTrigger(taskInfo.getCron()).nextExecutionTime(triggerContext)
                ))
        );
    }

    private void execute(final T taskInfo) {
        final long taskId = taskInfo.getId();

        try {
            Semaphore semaphore = dsContainer.getSemaphore(taskId);
            if (Objects.isNull(semaphore)) {
                log.error("{} semaphore is null, taskId: {}", CLASS_NAME, taskId);
                return;
            }
            if (semaphore.tryAcquire(3, TimeUnit.SECONDS)) {
                try {
                    getWorkerExecutor().execute(() -> doProcess(taskInfo));
                } finally {
                    semaphore.release();
                }
            } else {
                log.warn("{} too many executor, taskId: {}", CLASS_NAME, taskId);
            }
        } catch (InterruptedException e) {
            log.warn("{} interruptedException error, taskId: {}", CLASS_NAME, taskId);
        } catch (Exception e) {
            log.error("{} execute error, taskId: {}", CLASS_NAME, taskId, e);
        }
    }
}
```



## 三、快速测试



至此就完成了动态任务的框架搭建，下面让我们来快速测试下。为了尽量减少其他技术带来的复杂度，本次测试不涉及数据库和真实的定时任务，完全采用模拟实现。

### 3.1 模拟定时任务

为了模拟一个定时任务，我定义了一个 `foo()` 方法，其中只输出一句话。后续我将通过定时调用该方法，来模拟定时任务。

```java
import lombok.extern.slf4j.Slf4j;

import java.time.LocalTime;

@Slf4j
public class SchedulerTest {
    public void foo() {
        log.info("{} Execute com.github.jitwxs.sample.ds.test.SchedulerTest#foo", LocalTime.now());
    }
}
```

### 3.2 实现 IDSTaskInfo

首先定义 IDSTaskInfo，我这里想通过反射来实现调用 `foo()` 方法，因此 `reference` 表示的是要调用方法的全路径。另外我实现了 `isChange()` 方法，只要 cron、isValid、reference 发生了变动，就认为该任务的配置发生了改变。

```java
import com.github.jitwxs.sample.ds.config.IDSTaskInfo;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SchedulerTestTaskInfo implements IDSTaskInfo {
    private long id;

    private String cron;

    private boolean isValid;

    private String reference;

    @Override
    public boolean isChange(IDSTaskInfo oldTaskInfo) {
        if(oldTaskInfo instanceof SchedulerTestTaskInfo) {
            final SchedulerTestTaskInfo obj = (SchedulerTestTaskInfo) oldTaskInfo;
            return !this.cron.equals(obj.cron) || this.isValid != obj.isValid || !this.reference.equals(obj.getReference());
        } else {
            throw new IllegalArgumentException("Not Support SchedulerTestTaskInfo type");
        }
    }
}
```

### 3.3 实现 AbstractDSHandler

有几个需要关注的：

（1）`getWorkerExecutor()` 我随便写了个 2，其实 SchedulerTestTaskInfo 对象只有一个（即调用 foo() 方法的定时任务）。

（2）`listTaskInfo()` 返回值我使用了 volatile 变量，便于我修改它，模拟任务信息数据的改变。

（3）`doProcess()` 方法中，读取到 reference 后，使用反射进行调用，模拟定时任务的执行。

（4）额外实现了 `ApplicationListener` 接口，当服务启动后，每隔一段时间修改下任务信息，模拟业务中调整配置。

•服务启动后，foo() 定时任务将每 10s 执行一次。•10s 后，将 foo() 定时任务执行周期从每 10s 执行调整为 1s 执行。•10s 后，关闭 foo() 定时任务执行。•10s 后，开启 foo() 定时任务执行。

```java
import com.github.jitwxs.sample.ds.config.AbstractDSHandler;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.LockSupport;

@Component
public class SchedulerTestDSHandler extends AbstractDSHandler<SchedulerTestTaskInfo> implements ApplicationListener {
    public volatile List<SchedulerTestTaskInfo> taskInfoList = Collections.singletonList(
            SchedulerTestTaskInfo.builder()
                    .id(1)
                    .cron("0/10 * * * * ? ")
                    .isValid(true)
                    .reference("com.github.jitwxs.sample.ds.test.SchedulerTest#foo")
                    .build()
    );

    @Override
    protected ExecutorService getWorkerExecutor() {
        return Executors.newFixedThreadPool(2);
    }

    @Override
    protected List<SchedulerTestTaskInfo> listTaskInfo() {
        return taskInfoList;
    }

    @Override
    protected void doProcess(SchedulerTestTaskInfo taskInfo) {
        final String reference = taskInfo.getReference();
        final String[] split = reference.split("#");
        if(split.length != 2) {
            return;
        }

       try {
           final Class<?> clazz = Class.forName(split[0]);
           final Method method = clazz.getMethod(split[1]);
           method.invoke(clazz.newInstance());
       } catch (Exception e) {
           e.printStackTrace();
       }
    }

    @Override
    public void onApplicationEvent(ApplicationEvent applicationEvent) {
        Executors.newScheduledThreadPool(1).scheduleAtFixedRate(() -> {
            LockSupport.parkNanos(TimeUnit.SECONDS.toNanos(10));

            // setting 1 seconds execute
            taskInfoList = Collections.singletonList(
                    SchedulerTestTaskInfo.builder()
                            .id(1)
                            .cron("0/1 * * * * ? ")
                            .isValid(true)
                            .reference("com.github.jitwxs.sample.ds.test.SchedulerTest#foo")
                            .build()
            );

            LockSupport.parkNanos(TimeUnit.SECONDS.toNanos(10));

            // setting not valid
            taskInfoList = Collections.singletonList(
                    SchedulerTestTaskInfo.builder()
                            .id(1)
                            .cron("0/1 * * * * ? ")
                            .isValid(false)
                            .reference("com.github.jitwxs.sample.ds.test.SchedulerTest#foo")
                            .build()
            );

            LockSupport.parkNanos(TimeUnit.SECONDS.toNanos(10));

            // setting valid
            taskInfoList = Collections.singletonList(
                    SchedulerTestTaskInfo.builder()
                            .id(1)
                            .cron("0/1 * * * * ? ")
                            .isValid(true)
                            .reference("com.github.jitwxs.sample.ds.test.SchedulerTest#foo")
                            .build()
            );
        }, 12, 86400, TimeUnit.SECONDS);
    }
}
```

### 3.4 运行程序

整个应用包结构如下：

![图片](https://mmbiz.qpic.cn/mmbiz_png/xicWYTSICzRvOt5JNlYl94ElfxIHXthTu4H90acp0MzhquaFUAkCWjvwSIibTu4hIUNqvvlibWYYThwMFlQicYHLMw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

运行程序后，在控制台可以观测到如下输出：

![图片](https://mmbiz.qpic.cn/mmbiz_png/xicWYTSICzRvOt5JNlYl94ElfxIHXthTus62Za5PbBLjcy9Rriba7J4icBicru15JaQiclAwltKrloB071wzibiceZ8bQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



## 四、后记



以上完成了动态定时任务的介绍，你能够根据本篇文章，实现以下需求吗：

•本文基于 cron 表达式实现了频率控制，你能改用 fixedDelay 或 fixedRate 实现吗？•基于数据库/配置文件/配置中心，实现对服务中定时任务的动态频率调整和任务的启停。•开发一个数据表历史数据清理功能，能够动态配置要清理的表、清理的规则、清理的周期。•开发一个数据表异常数据告警功能，能够动态配置要扫描的表、告警的规则、扫描的周期。



-----

# [Spring定时器配置方式](https://www.iteye.com/blog/wugaokai-1160424)

## 方式一:自定义定时器类和定时器方法，好处是不用继承 java.util.TimerTask

​		或者org.springframework.scheduling.quartz.QuartzJobBean

```java
public class TestTask1 {  
        private static final  Logger log=Logger.getLogger(TestTask1.class);  
          
        public void tasktrigger(){  
            log.info("TestTask1定时器触发..........");  
        }  
}  
```

 Spring上下文配置：

​	<!-- TestTask1定时器配置 -->

```xml
<span>  <bean id="testTimer" class="com.square.usermodule.timertask.TestTimer"></bean>  
  
    <bean id="testJobDetail"  
        class="org.springframework.scheduling.quartz.MethodInvokingJobDetailFactoryBean">  
        <!-- 目标对象 -->  
        <property name="targetObject" ref="testTimer"></property>  
        <!-- 目标方法 -->  
        <property name="targetMethod">  
            <value>tasktrigger</value>  
        </property>  
    </bean>  
  
    <!-- 配置定时器 -->  
    <bean id="testCronTrigger" class="org.springframework.scheduling.quartz.CronTriggerBean">  
        <property name="jobDetail" ref="testJobDetail"></property>  
        <property name="cronExpression">  
</span><span><span style="white-space: pre;">           </span><!-- 每10秒触发一次 -->  
            <value>0/10 * * ? * *</value>  
        </property>  
    </bean>  
      
    <!-- 启动定时器 -->  
    <bean class="org.springframework.scheduling.quartz.SchedulerFactoryBean">  
    <!-- 定时器列表  -->  
        <property name="triggers">  
            <list>  
                <ref local="testCronTrigger"/>  
            </list>  
        </property>  
    </bean></span>  
```

tomcat服务器启动：1分钟结果

INFO [DefaultQuartzScheduler_Worker-7] TestTimer.tasktrigger(10) | TestTask1定时器触发..........

INFO [DefaultQuartzScheduler_Worker-7] TestTimer.tasktrigger(10) | TestTask1定时器触发..........

INFO [DefaultQuartzScheduler_Worker-7] TestTimer.tasktrigger(10) | TestTask1定时器触发..........

INFO [DefaultQuartzScheduler_Worker-7] TestTimer.tasktrigger(10) | TestTask1定时器触发..........

INFO [DefaultQuartzScheduler_Worker-7] TestTimer.tasktrigger(10) | TestTask1定时器触发..........

INFO [DefaultQuartzScheduler_Worker-7] TestTimer.tasktrigger(10) | TestTask1定时器触发..........

 

## 方式二：继承org.springframework.scheduling.quartz.QuartzJobBean实现executeInternal方法

```java
public class TestTask2 extends QuartzJobBean {  
    private static final Logger log = Logger.getLogger(TestTask2.class);  
    private String message;  
  
    public String getMessage() {  
        return message;  
    }  
  
    public void setMessage(String message) {  
        this.message = message;  
    }  
  
    @Override  
    protected void executeInternal(JobExecutionContext arg0)  
            throws JobExecutionException {  
        log.info(message);  
    }  
}  
```

上下文配置：

```xml
<span><!-- TestTask2定时器配置 -->  
    <bean id="testJobDetail2" class="org.springframework.scheduling.quartz.JobDetailBean">  
    <!-- 应该是适配器模式，通过jobClass属性找到TestTask2类返回JobDetail对象 -->  
        <property name="jobClass">  
            <value>packageName.TestTask2</value>  
        </property>  
        <!-- TestTask2类与他的message属性是间接设置的，通过键值对方式对属性注入 -->  
        <property name="jobDataAsMap">  
            <map>  
                <entry key="message">  
                    <value>TestTask2定时器触发......</value>  
                </entry>  
            </map>  
        </property>  
    </bean>  
      
    <!-- 配置定时器TestTask2 -->  
    <bean id="testCronTrigger2" class="org.springframework.scheduling.quartz.CronTriggerBean">  
        <property name="jobDetail" ref="testJobDetail2"></property>  
        <property name="cronExpression">  
</span><span><span style="white-space: pre;">           </span></span><!-- 每10秒触发一次 --><span>  
            <value>0/10 * * ? * *</value>  
        </property>  
    </bean>  
      
    <!-- 启动定时器 -->  
    <bean class="org.springframework.scheduling.quartz.SchedulerFactoryBean">  
    <!-- 定时器列表  -->  
        <property name="triggers">  
            <list>  
                <ref local="testCronTrigger2"/>  
            </list>  
        </property>  
    </bean></span>  
```

 tomcat服务器启动：1分钟结果

 

INFO [DefaultQuartzScheduler_Worker-9] TestTask2.executeInternal(23) | TestTask2定时器触发......

INFO [DefaultQuartzScheduler_Worker-9] TestTask2.executeInternal(23) | TestTask2定时器触发......

INFO [DefaultQuartzScheduler_Worker-9] TestTask2.executeInternal(23) | TestTask2定时器触发......

INFO [DefaultQuartzScheduler_Worker-9] TestTask2.executeInternal(23) | TestTask2定时器触发......

INFO [DefaultQuartzScheduler_Worker-9] TestTask2.executeInternal(23) | TestTask2定时器触发......

INFO [DefaultQuartzScheduler_Worker-9] TestTask2.executeInternal(23) | TestTask2定时器触发......

 

## 方式三：继承java.util.TimerTask类实现run方法

（不建议采用，因为在spring3.0中org.springframework.scheduling.timer包

已标志过时）

```java
public class TestTask3 extends TimerTask {  
    private static final Logger log=Logger.getLogger(TestTask3.class);  
  
    @Override  
    public void run() {  
        log.info("TestTask3定时器触发");  
    }  
}  
```

 上下文配置：

```xml
<bean id="testTask3" class="com.square.usermodule.timertask.TestTask3"></bean>  
<!--配置定时器-->  
    <bean id="testTimer" class="org.springframework.scheduling.timer.ScheduledTimerTask">  
        <property name="timerTask" ref="testTask3" />  
        <property name="period">  
            <value>10000</value>  
        </property>  
    </bean>  
<!--启动定时器-->  
<bean class="org.springframework.scheduling.timer.TimerFactoryBean">  
        <property name="scheduledTimerTasks">  
            <list>  
                <ref bean="testTimer" />  
            </list>  
        </property>  
    </bean>  
```

tomcat服务器启动：1分钟结果 

INFO [Timer-0] TestTask3.run(13) | TestTask3定时器触发

INFO [Timer-0] TestTask3.run(13) | TestTask3定时器触发

INFO [Timer-0] TestTask3.run(13) | TestTask3定时器触发

INFO [Timer-0] TestTask3.run(13) | TestTask3定时器触发

INFO [Timer-0] TestTask3.run(13) | TestTask3定时器触发

 

## 方式四：注解支持@Scheduled

这个是转载http://zywang.iteye.com/blog/949123

```java
@Component  
public class TestTask4 {  
    private static Logger log=Logger.getLogger(TestTask4.class);  
      
//  这表示延迟执行，每5秒执行一次，也就是不确定开始时间  
    @Scheduled(fixedDelay=5000)  
    public void doSomethingWithDelay(){  
        log.info("I'm doing with delay now!");  
    }  
      
//  表示服务器启动的时候立即执行，每5秒执行一次  
    @Scheduled(fixedRate=5000)  
    public void doSomethingWithRate(){  
        log.info("I'm doing with rate now!");  
    }  
      
//  cron表达式，表示每5秒执行一次  
    @Scheduled(cron="0/5 * * ? * *")  
    public void doSomethingWithCron(){  
        log.info("I'm doing with cron now!");  
    }  
}  
```

上下文配置：

```xml
<beans xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   
    xmlns:context="http://www.springframework.org/schema/context"  
    xmlns:task="http://www.springframework.org/schema/task"  
    xsi:schemaLocation="    
          http://www.springframework.org/schema/beans     
          http://www.springframework.org/schema/beans/spring-beans-2.0.xsd    
          http://www.springframework.org/schema/context    
          http://www.springframework.org/schema/context/spring-context-2.5.xsd  
          http://www.springframework.org/schema/task   
          http://www.springframework.org/schema/task/spring-task-3.0.xsd">  
<!--注解驱动会去这个包找到bean类-->  
<context:component-scan base-package="定时类所在的包名" />      
  
<!--这个应该是开启Spring 的@Scheduled 注解编程吧-->  
<!-- Enables the Spring Task @Scheduled programming model -->    
    <task:executor id="executor" pool-size="5" />    
    <task:scheduler id="scheduler" pool-size="10" />    
    <task:annotation-driven executor="executor" scheduler="scheduler" /> 
```

或者

#### SpringBoot启动类注解

```java
@EnableScheduling //开启基于注解的定时任务
```



tomcat服务器启动：结果如下

 3219 INFO  [scheduler-2]   com.wgk.demo1.timertask.TestTask4   - I'm doing with cron now!

6390 INFO  [scheduler-3]   com.wgk.demo1.timertask.TestTask4   - I'm doing with rate now!

6406 INFO  [scheduler-4]   com.wgk.demo1.timertask.TestTask4   - I'm doing with delay now!

8219 INFO  [scheduler-1]   com.wgk.demo1.timertask.TestTask4   - I'm doing with cron now!

11422 INFO  [scheduler-2]   com.wgk.demo1.timertask.TestTask4   - I'm doing with rate now!

11437 INFO  [scheduler-1]   com.wgk.demo1.timertask.TestTask4   - I'm doing with delay now!

13250 INFO  [scheduler-2]   com.wgk.demo1.timertask.TestTask4   - I'm doing with cron now!

16422 INFO  [scheduler-2]   com.wgk.demo1.timertask.TestTask4   - I'm doing with rate now!

16437 INFO  [scheduler-4]   com.wgk.demo1.timertask.TestTask4   - I'm doing with delay now!

 

## Cron表达式简单例子：

```
<beans>       
<!--  
一个cron表达式有至少6个（也可能是7个）由空格分隔的时间元素。从左至右，这些元素的定义如下：  
1．秒（0–59）  
2．分钟（0–59）  
3．小时（0–23）  
4．月份中的日期（1–31）  
5．月份（1–12或JAN–DEC）  
6．星期中的日期（1–7或SUN–SAT）  
7．年份（1970–2099）  
          秒 0-59 , - * /   
          分 0-59 , - * /   
          小时 0-23 , - * /   
          日期 1-31 , - * ? / L W C   
          月份 1-12 或者 JAN-DEC , - * /   
          星期 1-7 或者 SUN-SAT , - * ? / L C #   
          年（可选）留空, 1970-2099 , - * /   
          表达式意义   
          "0 0 12 * * ?" 每天中午12点触发   
"0 15 10 ? * *" 每天上午10:15触发   
"0 15 10 * * ?" 每天上午10:15触发   
"0 15 10 * * ? *" 每天上午10:15触发   
"0 15 10 * * ? 2005" 2005年的每天上午10:15触发   
"0 * 14 * * ?" 在每天下午2点到下午2:59期间的每1分钟触发   
"0 0/5 14 * * ?" 在每天下午2点到下午2:55期间的每5分钟触发   
"0 0/5 14,18 * * ?" 在每天下午2点到2:55期间和下午6点到6:55期间的每5分钟触发   
"0 0-5 14 * * ?" 在每天下午2点到下午2:05期间的每1分钟触发   
"0 10,44 14 ? 3 WED" 每年三月的星期三的下午2:10和2:44触发   
"0 15 10 ? * MON-FRI" 周一至周五的上午10:15触发   
"0 15 10 15 * ?" 每月15日上午10:15触发   
"0 15 10 L * ?" 每月最后一日的上午10:15触发   
"0 15 10 ? * 6L" 每月的最后一个星期五上午10:15触发   
"0 15 10 ? * 6L 2002-2005" 2002年至2005年的每月的最后一个星期五上午10:15触发   
"0 15 10 ? * 6#3" 每月的第三个星期五上午10:15触发   
每天早上6点   
0 6 * * *   
每两个小时   
0 */2 * * *   
晚上11点到早上7点之间每两个小时，早上八点   
0 23-7/2，8 * * *   
每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点   
0 11 4 * 1-3   
1月1日早上4点   
0 4 1 1 *  
-->  
</beans>  
```



# cron表达式详解，cron表达式写法，cron表达式例子

（cron = "* * * * * *")


cron表达式格式：
{秒数} {分钟} {小时} {日期} {月份} {星期} {年份(可为空)}
例  "0 0 12 ? * WED" 在每星期三下午12:00 执行（年份通常 省略）
先了解每个位置代表的含义，在了解每个位置允许的范围，以及一些特殊写法，还有常用的案例，足够你掌握cron表达式

## 一：每个字段的允许值

字段 允许值 允许的特殊字符 
秒 0-59 , - * / 
分 0-59 , - * / 
小时 0-23 , - * / 
日期 1-31 , - * ? / L W C 
月份 1-12 或者 JAN-DEC , - * / 
星期 1-7 或者 SUN-SAT , - * ? / L C # 
年（可选） 留空, 1970-2099 , - * / 

## 二：允许值的意思：

Seconds (秒)         ：可以用数字0－59 表示，


Minutes(分)          ：可以用数字0－59 表示，


Hours(时)             ：可以用数字0-23表示,


Day-of-Month(天) ：可以用数字1-31 中的任一一个值，但要注意一些特别的月份


Month(月)            ：可以用0-11 或用字符串  “JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV and DEC” 表示

Day-of-Week(每周)：可以用数字1-7表示（1 ＝ 星期日）或用字符口串“SUN, MON, TUE, WED, THU, FRI and SAT”表示

## 三：每个符号的意义：

*：表示所有值； 
? ：表示未说明的值，即不关心它为何值； 

-：表示一个指定的范围； 
, ：表示附加一个可能值； 
/ ：符号前表示开始时间，符号后表示每次递增的值； 
L("last") ：("last") "L" 用在day-of-month字段意思是 "这个月最后一天"；用在 day-of-week字段, 它简单意思是 "7" or "SAT"。 如果在day-of-week字段里和数字联合使用，它的意思就是 "这个月的最后一个星期几" – 例如： "6L" means "这个月的最后一个星期五". 当我们用“L”时，不指明一个列表值或者范围是很重要的，不然的话，我们会得到一些意想不到的结果。 
W("weekday")： 只能用在day-of-month字段。用来描叙最接近指定天的工作日（周一到周五）。例如：在day-of-month字段用“15W”指“最接近这个 月第15天的工作日”，即如果这个月第15天是周六，那么触发器将会在这个月第14天即周五触发；如果这个月第15天是周日，那么触发器将会在这个月第 16天即周一触发；如果这个月第15天是周二，那么就在触发器这天触发。注意一点：这个用法只会在当前月计算值，不会越过当前月。“W”字符仅能在 day-of-month指明一天，不能是一个范围或列表。也可以用“LW”来指定这个月的最后一个工作日。 

#：只能用在day-of-week字段。用来指定这个月的第几个周几。例：在day-of-week字段用"6#3"指这个月第3个周五（6指周五，3指第3个）。如果指定的日期不存在，触发器就不会触发。 

C： 指和calendar联系后计算过的值。例：在day-of-month 字段用“5C”指在这个月第5天或之后包括calendar的第一天；在day-of-week字段用“1C”指在这周日或之后包括calendar的第一天。

## 四：一些cron表达式案例

*/5 * * * * ? 每隔5秒执行一次
 0 */1 * * * ? 每隔1分钟执行一次
 0 0 5-15 * * ? 每天5-15点整点触发
 0 0/3 * * * ? 每三分钟触发一次
 0 0-5 14 * * ? 在每天下午2点到下午2:05期间的每1分钟触发 
 0 0/5 14 * * ? 在每天下午2点到下午2:55期间的每5分钟触发
 0 0/5 14,18 * * ? 在每天下午2点到2:55期间和下午6点到6:55期间的每5分钟触发
 0 0/30 9-17 * * ? 朝九晚五工作时间内每半小时
 0 0 10,14,16 * * ? 每天上午10点，下午2点，4点 

 0 0 12 ? * WED 表示每个星期三中午12点
 0 0 17 ? * TUES,THUR,SAT 每周二、四、六下午五点
 0 10,44 14 ? 3 WED 每年三月的星期三的下午2:10和2:44触发 
 0 15 10 ? * MON-FRI 周一至周五的上午10:15触发
 0 0 23 L * ? 每月最后一天23点执行一次
 0 15 10 L * ? 每月最后一日的上午10:15触发 
 0 15 10 ? * 6L 每月的最后一个星期五上午10:15触发 
 0 15 10 * * ? 2005 2005年的每天上午10:15触发 
 0 15 10 ? * 6L 2002-2005 2002年至2005年的每月的最后一个星期五上午10:15触发 
 0 15 10 ? * 6#3 每月的第三个星期五上午10:15触发

"30 * * * * ?" 每半分钟触发任务
"30 10 * * * ?" 每小时的10分30秒触发任务
"30 10 1 * * ?" 每天1点10分30秒触发任务
"30 10 1 20 * ?" 每月20号1点10分30秒触发任务
"30 10 1 20 10 ? *" 每年10月20号1点10分30秒触发任务
"30 10 1 20 10 ? 2011" 2011年10月20号1点10分30秒触发任务
"30 10 1 ? 10 * 2011" 2011年10月每天1点10分30秒触发任务
"30 10 1 ? 10 SUN 2011" 2011年10月每周日1点10分30秒触发任务
"15,30,45 * * * * ?" 每15秒，30秒，45秒时触发任务
"15-45 * * * * ?" 15到45秒内，每秒都触发任务
"15/5 * * * * ?" 每分钟的每15秒开始触发，每隔5秒触发一次
"15-30/5 * * * * ?" 每分钟的15秒到30秒之间开始触发，每隔5秒触发一次
"0 0/3 * * * ?" 每小时的第0分0秒开始，每三分钟触发一次
"0 15 10 ? * MON-FRI" 星期一到星期五的10点15分0秒触发任务
"0 15 10 L * ?" 每个月最后一天的10点15分0秒触发任务
"0 15 10 LW * ?" 每个月最后一个工作日的10点15分0秒触发任务
"0 15 10 ? * 5L" 每个月最后一个星期四的10点15分0秒触发任务
"0 15 10 ? * 5#3" 每个月第三周的星期四的10点15分0秒触发任务

## 五：表达式生成器

有很多的cron表达式在线生成器，这里给大家推荐几款

http://www.pdtools.net/tools/becron.jsp
或者

http://cron.qqe2.com/



----

# [springMVC中实现定时器可在Controller中配置定时器](https://blog.csdn.net/qq_24651739/article/details/60867987)

## 定时器所需jar

aopalliance-1.0.jar

## 步骤

### 1、[springMVC](https://so.csdn.net/so/search?q=springMVC&spm=1001.2101.3001.7020)-servlet.xml	

```xml
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:p="http://www.springframework.org/schema/p"  
    xmlns:context="http://www.springframework.org/schema/context"  
    xmlns:mvc="http://www.springframework.org/schema/mvc" xmlns:task="http://www.springframework.org/schema/task"  
    xsi:schemaLocation="    
    http://www.springframework.org/schema/beans     
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd    
    http://www.springframework.org/schema/context    
    http://www.springframework.org/schema/context/spring-context-3.0.xsd    
    http://www.springframework.org/schema/mvc    
    http://www.springframework.org/schema/mvc/spring-mvc-3.0.xsd    
    http://www.springframework.org/schema/task     
    http://www.springframework.org/schema/task/spring-task-3.0.xsd">  
    <!-- 默认扫描的包路径 -->  
    <context:component-scan base-package="*" />  
  
    <!-- 添加注解驱动 -->  
    <mvc:annotation-driven />  
  
    <!-- 定义跳转的文件的前后缀 -->  
    <bean id="viewResolver"  
        class="org.springframework.web.servlet.view.InternalResourceViewResolver">  
        <property name="prefix" value="/WEB-INF/views/" />  
        <property name="suffix" value=".jsp" />  
    </bean>  
  
    <task:executor id="executor" pool-size="5" />  
    <task:scheduler id="schedule" pool-size="10" />  
    <task:annotation-driven executor="executor"  
    scheduler="schedule" />  
  
</beans>  
```

注：添加了task

### 2、VendorTask.java

```java
package net.csdn.blog.springmvc.timer;  
  
import org.springframework.scheduling.annotation.Scheduled;  
import org.springframework.stereotype.Component;  
  
@Component  
public class VendorTask {  
  
    // private static Logger log = Logger.getLogger(VendorTask.class);  
  
    @Scheduled(fixedDelay = 5000)  
    public void doSomethingWithDelay() {  
        System.out.println("I'm doing with delay now!");  
    }  
  
    @Scheduled(fixedRate = 5000)  
    public void doSomethingWithRate() {  
        System.out.println("I'm doing with rate now!");  
    }  
  
    @Scheduled(cron = "0/5 * * ? * *")  
    public void doSomethingWithCron() {  
        System.out.println("I'm doing with cron now!");  
    }  
  
}  
```

注：cron效果为服务器启动之后每过5s钟执行一次，具体的写法可参考[Spring定时器配置方式](http://wugaokai.iteye.com/blog/1160424)



-----

# [java定时器的几种实现方式](https://javaforall.cn/156893.html)

转自：<https://www.cnkirito.moe/timer/>

## 1 前言

在开始正题之前，先闲聊几句。有人说，计算机科学这个学科，软件方向研究到头就是数学，硬件方向研究到头就是物理，最轻松的是中间这批使用者，可以不太懂物理，不太懂数学，依旧可以使用计算机作为自己谋生的工具。这个规律具有普适应，看看“定时器”这个例子，往应用层研究，有 Quartz，Spring Schedule 等框架；往分布式研究，又有 SchedulerX，ElasticJob 等分布式任务调度；往底层实现看，又有多种定时器实现方案的原理、工作效率、数据结构可以深究…简单上手使用一个框架，并不能体现出个人的水平，如何与他人构成区分度？我觉得至少要在某一个方向有所建树：

1. 深入研究某个现有框架的实现原理，例如：读源码
2. 将一个传统技术在分布式领域很好地延伸，很多成熟的传统技术可能在单机 work well，但分布式场景需要很多额外的考虑。
3. 站在设计者的角度，如果从零开始设计一个轮子，怎么利用合适的算法、数据结构，去实现它。

回到这篇文章的主题，我首先会围绕第三个话题讨论：设计实现一个定时器，可以使用什么算法，采用什么数据结构。接着再聊聊第一个话题：探讨一些优秀的定时器实现方案。



## 2 理解定时器

很多场景会用到定时器，例如

1. 使用 TCP 长连接时，客户端需要定时向服务端发送心跳请求。
2. 财务系统每个月的月末定时生成对账单。
3. 双 11 的 0 点，定时开启秒杀开关。

定时器像水和空气一般，普遍存在于各个场景中，一般定时任务的形式表现为：经过固定时间后触发、按照固定频率周期性触发、在某个时刻触发。定时器是什么？可以理解为这样一个数据结构：

> 存储一系列的任务集合，并且 Deadline 越接近的任务，拥有越高的执行优先级
> 在用户视角支持以下几种操作：
> NewTask：将新任务加入任务集合
> Cancel：取消某个任务
> 在任务调度的视角还要支持：
> Run：执行一个到期的定时任务

判断一个任务是否到期，基本会采用轮询的方式， **每隔一个时间片** 去检查 **最近的任务** 是否到期，并且，在 NewTask 和 Cancel 的行为发生之后，任务调度策略也会出现调整。

> 说到底，定时器还是靠线程轮询实现的。

## 3 数据结构

我们主要衡量 NewTask（新增任务），Cancel（取消任务），Run（执行到期的定时任务）这三个指标，分析他们使用不同数据结构的时间 / 空间复杂度。

### 3.1 双向有序链表

在 Java 中，`LinkedList` 是一个天然的双向链表

> NewTask：O(N)
> Cancel：O(1)
> Run：O(1)
> N：任务数

NewTask O(N) 很容易理解，按照 expireTime 查找合适的位置即可；Cancel O(1) ，任务在 Cancel 时，会持有自己节点的引用，所以不需要查找其在链表中所在的位置，即可实现当前节点的删除，这也是为什么我们使用双向链表而不是普通链表的原因是 ；Run O(1)，由于整个双向链表是基于 expireTime 有序的，所以调度器只需要轮询第一个任务即可。

### 3.2 堆

在 Java 中，`PriorityQueue` 是一个天然的堆，可以利用传入的 `Comparator` 来决定其中元素的优先级。

> NewTask：O(logN)
> Cancel：O(logN)
> Run：O(1)
> N：任务数

expireTime 是 `Comparator` 的对比参数。NewTask O(logN) 和 Cancel O(logN) 分别对应堆插入和删除元素的时间复杂度 ；Run O(1)，由 expireTime 形成的小根堆，我们总能在堆顶找到最快的即将过期的任务。

堆与双向有序链表相比，NewTask 和 Cancel 形成了 trade off，但考虑到现实中，定时任务取消的场景并不是很多，所以堆实现的定时器要比双向有序链表优秀。（logN比N复杂度更好，几乎可忽略Cancel的影响）

### 3.3 时间轮

Netty 针对 I/O 超时调度的场景进行了优化，实现了 `HashedWheelTimer` 时间轮算法。

`HashedWheelTimer` 是一个环形结构，可以用时钟来类比，钟面上有很多 bucket ，每一个 bucket 上可以存放多个任务，使用一个 List 保存该时刻到期的所有任务，同时一个指针随着时间流逝一格一格转动，并执行对应 bucket 上所有到期的任务。任务通过 `取模` 决定应该放入哪个 bucket 。和 HashMap 的原理类似，newTask 对应 put，使用 List 来解决 Hash 冲突。

以上图为例，假设一个 bucket 是 1 秒，则指针转动一轮表示的时间段为 8s，假设当前指针指向 0，此时需要调度一个 3s 后执行的任务，显然应该加入到 (0+3=3) 的方格中，指针再走 3 次就可以执行了；如果任务要在 10s 后执行，应该等指针走完一轮零 2 格再执行，因此应放入 2，同时将 round（1）保存到任务中。检查到期任务时只执行 round 为 0 的， bucket 上其他任务的 round 减 1。

再看图中的 bucket5，我们可以知道在 $1*8+5=13s$ 后，有两个任务需要执行，在 $2*8+5=21s$ 后有一个任务需要执行。

> NewTask：O(1)
> Cancel：O(1)
> Run：O(M)
> Tick：O(1)
> M： bucket ，M ~ N/C ，其中 C 为单轮 bucket 数，Netty 中默认为 512

时间轮算法的复杂度可能表达有误，比较难算，仅供参考。另外，其复杂度还受到多个任务分配到同一个 bucket 的影响。并且多了一个转动指针的开销。

> 传统定时器是面向任务的，时间轮定时器是面向 bucket 的。

构造 Netty 的 `HashedWheelTimer` 时有两个重要的参数：`tickDuration` 和 `ticksPerWheel`。

1. `tickDuration`：即一个 bucket 代表的时间，默认为 100ms，Netty 认为大多数场景下不需要修改这个参数；
2. `ticksPerWheel`：一轮含有多少个 bucket ，默认为 512 个，如果任务较多可以增大这个参数，降低任务分配到同一个 bucket 的概率。

### 3.4 层级时间轮

Kafka 针对时间轮算法进行了优化，实现了层级时间轮 `TimingWheel`

如果任务的时间跨度很大，数量也多，传统的 `HashedWheelTimer` 会造成任务的 `round` 很大，单个 bucket 的任务 List 很长，并会维持很长一段时间。这时可将轮盘按时间粒度分级：

[![层级时间轮](http://qn.javajgs.com/20220708/b18cc178-f868-4077-bc56-6e3aee00290120220708cba60b2d-4636-4305-aceb-d72f6a3384991.jpg)](https://kirito.iocoder.cn/7f03c027b1de345a0b1e57239d73de74.png)层级时间轮

现在，每个任务除了要维护在当前轮盘的 `round`，还要计算在所有下级轮盘的 `round`。当本层的 `round` 为 0 时，任务按下级 `round` 值被下放到下级轮子，最终在最底层的轮盘得到执行。

> NewTask：O(H)
> Cancel：O(H)
> Run：O(M)
> Tick：O(1)
> H：层级数量

设想一下一个定时了 3 天，10 小时，50 分，30 秒的定时任务，在 tickDuration = 1s 的单层时间轮中，需要经过：$3*24*60*60+10*60*60+50*60+30$ 次指针的拨动才能被执行。但在 wheel1 tickDuration = 1 天，wheel2 tickDuration = 1 小时，wheel3 tickDuration = 1 分，wheel4 tickDuration = 1 秒 的四层时间轮中，只需要经过 $3+10+50+30$ 次指针的拨动！

相比单层时间轮，层级时间轮在时间跨度较大时存在明显的优势。

## 4 常见实现

### 4.1 Timer

JDK 中的 `Timer` 是非常早期的实现，在现在看来，它并不是一个好的设计。

```java
// 运行一个一秒后执行的定时任务
Timer timer = new Timer();
timer.schedule(new TimerTask() {
    @Override
    public void run() {
        // do sth
    }
}, 1000);
```

使用 `Timer` 实现任务调度的核心是 `Timer` 和 `TimerTask`。其中 `Timer` 负责设定 `TimerTask` 的起始与间隔执行时间。使用者只需要创建一个 `TimerTask` 的继承类，实现自己的 `run` 方法，然后将其丢给 `Timer` 去执行即可。

```java
public class Timer {
    private final TaskQueue queue = new TaskQueue();
    private final TimerThread thread = new TimerThread(queue);
}
```

其中 TaskQueue 是使用数组实现的一个简易的堆。另外一个值得注意的属性是 `TimerThread`，`Timer` 使用唯一的线程负责轮询并执行任务。`Timer` 的优点在于简单易用，但也因为所有任务都是由同一个线程来调度，因此整个过程是串行执行的，同一时间只能有一个任务在执行，前一个任务的延迟或异常都将会影响到之后的任务。

> 轮询时如果发现 currentTime < heapFirst.executionTime，可以 wait(executionTime – currentTime) 来减少不必要的轮询时间。这是普遍被使用的一个优化。

1. `Timer` 只能被单线程调度
2. `TimerTask` 中出现的异常会影响到 `Timer` 的执行。

由于这两个缺陷，JDK 1.5 支持了新的定时器方案 `ScheduledExecutorService`。

### 4.2 ScheduledExecutorService

```java
// 运行一个一秒后执行的定时任务
ScheduledExecutorService service = Executors.newScheduledThreadPool(10);
service.scheduleA(new Runnable() {
    @Override
    public void run() {
        //do sth
    }
}, 1, TimeUnit.SECONDS);
```

**相比 `Timer`，`ScheduledExecutorService` ==利用多线程解决了同一个定时器调度多个任务的阻塞问题==，并且任务异常不会中断 `ScheduledExecutorService`。**

`ScheduledExecutorService` 提供了两种常用的周期调度方法 ScheduleAtFixedRate 和 ScheduleWithFixedDelay。

ScheduleAtFixedRate 每次执行时间为上一次任务开始起向后推一个时间间隔，即每次执行时间为 : $initialDelay$, $initialDelay+period$, $initialDelay+2*period$, …

ScheduleWithFixedDelay 每次执行时间为上一次任务结束起向后推一个时间间隔，即每次执行时间为：$initialDelay$, $initialDelay+executeTime+delay$, $initialDelay+2*executeTime+2*delay$, …

**由此可见，ScheduleAtFixedRate 是基于固定时间间隔进行任务调度，ScheduleWithFixedDelay 取决于每次任务执行的时间长短，是基于不固定时间间隔的任务调度。**

`ScheduledExecutorService` 底层使用的数据结构为 `PriorityQueue`，任务调度方式较为常规，不做特别介绍。

### 4.3 HashedWheelTimer

```java
Timer timer = new HashedWheelTimer();
// 等价于 Timer timer = new HashedWheelTimer(100, TimeUnit.MILLISECONDS, 512);
timer.newTimeout(new TimerTask() {
    @Override
    public void run(Timeout timeout) throws Exception {
        //do sth
    }
}, 1, TimeUnit.SECONDS);
```

前面已经介绍过了 Netty 中 `HashedWheelTimer` （单层时间轮）内部的数据结构，默认构造器会配置轮询周期为 100ms，bucket 数量为 512。其使用方法和 JDK 的 `Timer` 十分相似。

```java
private final Worker worker = new Worker();// Runnable
private final Thread workerThread;// Thread
```

由于篇幅限制，我并不打算做详细的源码分析，但上述两行来自 `HashedWheelTimer` 的代码阐释了一个事实：`HashedWheelTimer` 内部也同样是使用单个线程进行任务调度。==**与 JDK 的 `Timer` 一样，存在”前一个任务执行时间过长，影响后续定时任务执行“的问题。**==

> 理解 HashedWheelTimer 中的 ticksPerWheel，tickDuration，对二者进行合理的配置，可以使得用户在合适的场景得到最佳的性能。

## 5 最佳实践

### 5.1 选择合适的定时器

毋庸置疑，JDK 的 `Timer` 使用的场景是最窄的，完全可以被后两者取代。如何在 `ScheduledExecutorService` 和 `HashedWheelTimer` 之间如何做选择，需要区分场景，做一个简单的对比：

1. `ScheduledExecutorService` 是面向任务的，当任务数非常大时，使用堆 (PriorityQueue) 维护任务的新增、删除会导致性能下降，而 `HashedWheelTimer` 面向 bucket，设置合理的 ticksPerWheel，tickDuration ，可以不受任务量的限制。所以在任务非常多时，`HashedWheelTimer` 可以表现出它的优势。
2. 相反，如果任务量少，`HashedWheelTimer` 内部的 Worker 线程依旧会不停的拨动指针，虽然不是特别消耗性能，但至少不能说：`HashedWheelTimer` 一定比 `ScheduledExecutorService` 优秀。
3. `HashedWheelTimer` 由于开辟了一个 bucket 数组，占用的内存会稍大。

上述的对比，让我们得到了一个最佳实践：在任务非常多时，使用 `HashedWheelTimer` 可以获得性能的提升。例如服务治理框架中的心跳定时任务，服务实例非常多时，每一个客户端都需要定时发送心跳，每一个服务端都需要定时检测连接状态，这是一个非常适合使用 `HashedWheelTimer` 的场景。

### 5.2 单线程与业务线程池

我们需要注意 `HashedWheelTimer` 使用单线程来调度任务，如果任务比较耗时，应当设置一个业务线程池，将 `HashedWheelTimer` 当做一个定时触发器，任务的实际执行，交给业务线程池。

> 如果所有的任务都满足： taskNStartTime – taskN-1StartTime > taskN-1CostTime，即任意两个任务的间隔时间小于先执行任务的执行时间，则无需担心这个问题。

### 5.3 全局定时器

实际使用 `HashedWheelTimer` 时， **==应当将其当做一个全局的任务调度器，例如设计成 static== **。时刻谨记一点：`HashedWheelTimer` 对应一个线程，如果每次实例化 `HashedWheelTimer`，首先是线程会很多，其次是时间轮算法将会完全失去意义。

### 5.4 为 HashedWheelTimer 设置合理的参数

**ticksPerWheel，tickDuration 这两个参数尤为重要，==ticksPerWheel 控制了时间轮中 bucket 的数量，决定了冲突发生的概率，tickDuration 决定了指针拨动的频率，一方面会影响定时的精度，一方面决定 CPU 的消耗量。==当任务数量非常大时，考虑增大 ticksPerWheel；当时间精度要求不高时，可以适当加大 tickDuration，**不过大多数情况下，不需要 care 这个参数。

### 5.5 什么时候使用层级时间轮

当时间跨度很大时，增大单层时间轮的 tickDuration 可以减少空转次数，但会导致时间精度变低，层级时间轮既可以避免精度降低，又避免了指针空转的次数。如果有时间跨度较长的定时任务，则可以交给层级时间轮去调度。此外，**也可以按照定时精度实例化多个不同作用的单层时间轮，dayHashedWheelTimer、hourHashedWheelTimer、minHashedWheelTimer，配置不同的 tickDuration，**此法虽 low，但不失为一个解决方案。Netty 设计的 `HashedWheelTimer` 是专门用来优化 I/O 调度的，场景较为局限，所以并没有实现层级时间轮；而在 Kafka 中定时器的适用范围则较广，所以其实现了层级时间轮，以应对更为复杂的场景。



