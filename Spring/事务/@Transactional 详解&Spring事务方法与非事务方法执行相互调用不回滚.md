# [@Transactional 详解][https://blog.csdn.net/jiangyu1013/article/details/84397366]

## @Transactional 是声明式事务管理 编程中使用的注解

**1 .添加位置**

1）接口实现类或接口实现方法上，而不是接口类中。
2）访问权限：public 的方法才起作用。@Transactional 注解应该只被应用到 public 方法上，这是由 Spring AOP 的本质决定的。
系统设计：将标签放置在需要进行事务管理的方法上，而不是放在所有接口实现类上：只读的接口就不需要事务管理，由于配置了@Transactional就需要AOP拦截及事务的处理，可能影响系统性能。

3）错误使用：

```java
1.接口中A、B两个方法，A无@Transactional标签，B有，上层通过A间接调用B，此时事务不生效。

2.接口中异常（运行时异常）被捕获而没有被抛出。
  默认配置下，spring 只有在抛出的异常为运行时 unchecked 异常时才回滚该事务，
  也就是抛出的异常为RuntimeException 的子类(Errors也会导致事务回滚)，
  而抛出 checked 异常则不会导致事务回滚 。可通过 @Transactional rollbackFor进行配置。

3.多线程下事务管理因为线程不属于 spring 托管，故线程不能够默认使用 spring 的事务,
  也不能获取spring 注入的 bean 。
  在被 spring 声明式事务管理的方法内开启多线程，多线程内的方法不被事务控制。
  一个使用了@Transactional 的方法，如果方法内包含多线程的使用，方法内部出现异常
  不会回滚线程中调用方法的事务。
```


**2.声明式事务管理实现方式：**
基于 tx 和 aop 名字空间的 xml 配置文件

```xml
// 基本配置
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc" xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:task="http://www.springframework.org/schema/task" xmlns:jms="http://www.springframework.org/schema/jms"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xsi:schemaLocation="http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-4.1.xsd
                          http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.1.xsd
                          http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.1.xsd
                          http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.1.xsd
                          http://www.springframework.org/schema/task http://www.springframework.org/schema/task/spring-task-4.1.xsd
                          http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.1.xsd
                          http://www.springframework.org/schema/jms http://www.springframework.org/schema/jms/spring-jms-4.1.xsd">
<bean name="transactionManager"
        class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="shardingDataSource"></property>
    </bean>
<tx:annotation-driven transaction-manager="transactionManager" proxy-target-class="true" />
// MyBatis 自动参与到 spring 事务管理中，无需额外配置，
只要 org.mybatis.spring.SqlSessionFactoryBean 引用的数据源与
DataSourceTransactionManager 引用的数据源一致即可，否则事务管理会不起作用。
// <annotation-driven> 标签的声明，
是在 Spring 内部启用 @Transactional 来进行事务管理，使用 @Transactional 前需要配置。
```


**3. @Transactional注解**
@Transactional 实质是使用了 JDBC 的事务来进行事务控制的
@Transactional 基于 Spring 的动态代理的机制


```
@Transactional 实现原理：
 
1) 事务开始时，通过AOP机制，生成一个代理connection对象，
   并将其放入 DataSource 实例的某个与 DataSourceTransactionManager 相关的某处容器中。
   在接下来的整个事务中，客户代码都应该使用该 connection 连接数据库，
   执行所有数据库命令。
   [不使用该 connection 连接数据库执行的数据库命令，在本事务回滚的时候得不到回滚]
  （物理连接 connection 逻辑上新建一个会话session；
   DataSource 与 TransactionManager 配置相同的数据源）
 
2) 事务结束时，回滚在第1步骤中得到的代理 connection 对象上执行的数据库命令，
   然后关闭该代理 connection 对象。
  （事务结束后，回滚操作不会对已执行完毕的SQL操作命令起作用）
```


**4.声明式事务的管理实现本质：**
事务的两种开启方式：
   显示开启 start transaction | begin，通过 commit | rollback 结束事务
   关闭数据库中自动提交 autocommit set autocommit = 0；MySQL 默认开启自动提交；通过手动提交或执行回滚操作来结束事务


Spring 关闭数据库中自动提交：在方法执行前关闭自动提交，方法执行完毕后再开启自动提交

```java
 // org.springframework.jdbc.datasource.DataSourceTransactionManager.java 源码实现
 // switch to manual commit if necessary. this is very expensive in some jdbc drivers,
 // so we don't want to do it unnecessarily (for example if we've explicitly
 // configured the connection pool to set it already).
 if (con.getautocommit()) {
     txobject.setmustrestoreautocommit(true);
     if (logger.isdebugenabled()) {
         logger.debug("switching jdbc connection [" + con + "] to manual commit");
     }
     con.setautocommit(false);
 }
```

问题：

关闭自动提交后，若事务一直未完成，即未手动执行 commit 或 rollback 时如何处理已经执行过的SQL操作？

C3P0 默认的策略是回滚任何未提交的事务
C3P0 是一个开源的JDBC连接池，它实现了数据源和 JNDI 绑定，支持 JDBC3 规范和 JDBC2 的标准扩展。目前使用它的开源项目有 Hibernate，Spring等
JNDI(Java Naming and Directory Interface,Java命名和目录接口)是SUN公司提供的一种标准的Java命名系统接口，JNDI提供统一的客户端API，通过不同的访问提供者接口JNDI服务供应接口(SPI)的实现，由管理者将JNDI API映射为特定的命名服务和目录系统，使得Java应用程序可以和这些命名服务和目录服务之间进行交互

\-------------------------------------------------------------------------------------------------------------------------------
**5. spring 事务特性**
spring 所有的事务管理策略类都继承自 org.springframework.transaction.PlatformTransactionManager 接口

```
1. @Transactional(isolation = Isolation.READ_UNCOMMITTED)：读取未提交数据(会出现脏读,
 不可重复读) 基本不使用
 
2. @Transactional(isolation = Isolation.READ_COMMITTED)：读取已提交数据(会出现不可重复读和幻读)
 
3. @Transactional(isolation = Isolation.REPEATABLE_READ)：可重复读(会出现幻读)
 
4. @Transactional(isolation = Isolation.SERIALIZABLE)：串行化
```

**事务的隔离级别**：是指若干个并发的事务之间的隔离程度

```
1. TransactionDefinition.PROPAGATION_REQUIRED：
   如果当前存在事务，则加入该事务；如果当前没有事务，则创建一个新的事务。这是默认值。
 
2. TransactionDefinition.PROPAGATION_REQUIRES_NEW：
   创建一个新的事务，如果当前存在事务，则把当前事务挂起。
 
3. TransactionDefinition.PROPAGATION_SUPPORTS：
   如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
 
4. TransactionDefinition.PROPAGATION_NOT_SUPPORTED：
   以非事务方式运行，如果当前存在事务，则把当前事务挂起。
 
5. TransactionDefinition.PROPAGATION_NEVER：
   以非事务方式运行，如果当前存在事务，则抛出异常。
 
6. TransactionDefinition.PROPAGATION_MANDATORY：
   如果当前存在事务，则加入该事务；如果当前没有事务，则抛出异常。
 
7. TransactionDefinition.PROPAGATION_NESTED：
   如果当前存在事务，则创建一个事务作为当前事务的嵌套事务来运行；
   如果当前没有事务，则该取值等价于TransactionDefinition.PROPAGATION_REQUIRED。
```

**事务传播行为**：如果在开始当前事务之前，一个事务上下文已经存在，此时有若干选项可以指定一个事务性方法的执行行为

```xml
1. TransactionDefinition.PROPAGATION_REQUIRED：
   如果当前存在事务，则加入该事务；如果当前没有事务，则创建一个新的事务。这是默认值。
 
2. TransactionDefinition.PROPAGATION_REQUIRES_NEW：
   创建一个新的事务，如果当前存在事务，则把当前事务挂起。
 
3. TransactionDefinition.PROPAGATION_SUPPORTS：
   如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
 
4. TransactionDefinition.PROPAGATION_NOT_SUPPORTED：
   以非事务方式运行，如果当前存在事务，则把当前事务挂起。
 
5. TransactionDefinition.PROPAGATION_NEVER：
   以非事务方式运行，如果当前存在事务，则抛出异常。
 
6. TransactionDefinition.PROPAGATION_MANDATORY：
   如果当前存在事务，则加入该事务；如果当前没有事务，则抛出异常。
 
7. TransactionDefinition.PROPAGATION_NESTED：
   如果当前存在事务，则创建一个事务作为当前事务的嵌套事务来运行；
   如果当前没有事务，则该取值等价于TransactionDefinition.PROPAGATION_REQUIRED。
```

![img](https://img-blog.csdnimg.cn/2018112316373648.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTEzMTQ0NDI=,size_16,color_FFFFFF,t_70)

上表字段说明：

```
1. value ：主要用来指定不同的事务管理器；
   主要用来满足在同一个系统中，存在不同的事务管理器。
   比如在Spring中，声明了两种事务管理器txManager1, txManager2.然后，
   用户可以根据这个参数来根据需要指定特定的txManager.
 
2. value 适用场景：在一个系统中，需要访问多个数据源或者多个数据库，
   则必然会配置多个事务管理器的
 
3. REQUIRED_NEW：内部的事务独立运行，在各自的作用域中，可以独立的回滚或者提交；
   而外部的事务将不受内部事务的回滚状态影响。
 
4. ESTED 的事务，基于单一的事务来管理，提供了多个保存点。
   这种多个保存点的机制允许内部事务的变更触发外部事务的回滚。
   而外部事务在混滚之后，仍能继续进行事务处理，即使部分操作已经被混滚。 
   由于这个设置基于 JDBC 的保存点，所以只能工作在 JDB C的机制。
 
5. rollbackFor：让受检查异常回滚；即让本来不应该回滚的进行回滚操作。
 
6. noRollbackFor：忽略非检查异常；即让本来应该回滚的不进行回滚操作。
```

![img](https://img-blog.csdnimg.cn/20181123164237116.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTEzMTQ0NDI=,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/20181123164317723.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTEzMTQ0NDI=,size_16,color_FFFFFF,t_70)![img](https://img-blog.csdnimg.cn/20181123164340152.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTEzMTQ0NDI=,size_16,color_FFFFFF,t_70)

**6.其他：**

```
1. 事务方法的嵌套调用会产生事务传播。
2. spring 的事务管理是线程安全的
3. 父类的声明的 @Transactional 会对子类的所有方法进行事务增强；
   子类覆盖重写父类方式可覆盖其 @Transactional 中的声明配置。
 
4. 类名上方使用 @Transactional，类中方法可通过属性配置来覆盖类上的 @Transactional 配置；
   比如：类上配置全局是可读写，可在某个方法上改为只读。
```

![img](https://img-blog.csdnimg.cn/20181123173515259.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTEzMTQ0NDI=,size_16,color_FFFFFF,t_70)

如果不对运行时异常进行处理，那么出现运行时异常之后，要么是线程中止，要么是主程序终止。 
如果不想终止，则必须捕获所有的运行时异常，决不让这个处理线程退出。队列里面出现异常数据了，正常的处理应该是把异常数据舍弃，然后记录日志。不应该由于异常数据而影响下面对正常数据的处理。


非运行时异常是RuntimeException以外的异常，类型上都属于Exception类及其子类。如IOException、SQLException等以及用户自定义的Exception异常。对于这种异常，JAVA编译器强制要求我们必需对出现的这些异常进行catch并处理，否则程序就不能编译通过。所以，面对这种异常不管我们是否愿意，只能自己去写一大堆catch块去处理可能的异常。

![img](https://img-blog.csdnimg.cn/20181123164638554.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTEzMTQ0NDI=,size_16,color_FFFFFF,t_70)
\--------------------- 

转自：https://blog.csdn.net/mingyundezuoan/article/details/79017659 

https://www.cnblogs.com/clwydjgs/p/9317849.html



-----



# [透彻的掌握 Spring 中@transactional 的使用](https://www.cnblogs.com/xd502djj/p/10940627.html)

事务管理是应用系统开发中必不可少的一部分。Spring 为事务管理提供了丰富的功能支持。Spring 事务管理分为编码式和声明式的两种方式。编程式事务指的是通过编码方式实现事务；声明式事务基于 AOP,将具体业务逻辑与事务处理解耦。声明式事务管理使业务代码逻辑不受污染, 因此在实际使用中声明式事务用的比较多。声明式事务有两种方式，一种是在配置文件（xml）中做相关的事务规则声明，另一种是基于@Transactional 注解的方式。注释配置是目前流行的使用方式，因此本文将着重介绍基于@Transactional 注解的事务管理。

## @Transactional 注解管理事务的实现步骤

使用@Transactional 注解管理事务的实现步骤分为两步。第一步，在 xml 配置文件中添加如清单 1 的事务配置信息。除了用配置文件的方式，@EnableTransactionManagement 注解也可以启用事务管理功能。这里以简单的 DataSourceTransactionManager 为例。

#### 清单 1. 在 xml 配置中的事务配置信息

```
<tx:annotation-driven />
<bean id="transactionManager"
class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
<property name="dataSource" ref="dataSource" />
</bean>
```

第二步，将@Transactional 注解添加到合适的方法上，并设置合适的属性信息。@Transactional 注解的属性信息如表 1 展示。

##### 表 1. @Transactional 注解的属性信息

| 属性名           | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| name             | 当在配置文件中有多个 TransactionManager , 可以用该属性指定选择哪个事务管理器。 |
| propagation      | 事务的传播行为，默认值为 REQUIRED。                          |
| isolation        | 事务的隔离度，默认值采用 DEFAULT。                           |
| timeout          | 事务的超时时间，默认值为-1。如果超过该时间限制但事务还没有完成，则自动回滚事务。 |
| read-only        | 指定事务是否为只读事务，默认值为 false；为了忽略那些不需要事务的方法，比如读取数据，可以设置 read-only 为 true。 |
| rollback-for     | 用于指定能够触发事务回滚的异常类型，如果有多个异常类型需要指定，各类型之间可以通过逗号分隔。 |
| no-rollback- for | 抛出 no-rollback-for 指定的异常类型，不回滚事务。            |

除此以外，@Transactional 注解也可以添加到类级别上。当把@Transactional 注解放在类级别时，表示所有该类的公共方法都配置相同的事务属性信息。见清单 2，EmployeeService 的所有方法都支持事务并且是只读。当类级别配置了@Transactional，方法级别也配置了@Transactional，应用程序会以方法级别的事务属性信息来管理事务，换言之，方法级别的事务属性信息会覆盖类级别的相关配置信息。

#### 清单 2. @Transactional 注解的类级别支持

```
@Transactional(propagation= Propagation.SUPPORTS,readOnly=true)
@Service(value ="employeeService")
public class EmployeeService
```

到此，您会发觉使用@Transactional 注解管理事务的实现步骤很简单。但是如果对 Spring 中的 @transaction 注解的事务管理理解的不够透彻，就很容易出现错误，比如事务应该回滚（rollback）而没有回滚事务的问题。接下来，将首先分析 Spring 的注解方式的事务实现机制，然后列出相关的注意事项，以最终达到帮助开发人员准确而熟练的使用 Spring 的事务的目的。

## Spring 的注解方式的事务实现机制

在应用系统调用声明@Transactional 的目标方法时，Spring Framework 默认使用 AOP 代理，在代码运行时生成一个代理对象，根据@Transactional 的属性配置信息，这个代理对象决定该声明@Transactional 的目标方法是否由拦截器 TransactionInterceptor 来使用拦截，在 TransactionInterceptor 拦截时，会在在目标方法开始执行之前创建并加入事务，并执行目标方法的逻辑, 最后根据执行情况是否出现异常，利用抽象事务管理器(图 2 有相关介绍)AbstractPlatformTransactionManager 操作数据源 DataSource 提交或回滚事务, 如图 1 所示。

##### 图 1. Spring 事务实现机制

![img](@Transactional 详解.assets/image001.jpg)

Spring AOP 代理有 CglibAopProxy 和 JdkDynamicAopProxy 两种，图 1 是以 CglibAopProxy 为例，对于 CglibAopProxy，需要调用其内部类的 DynamicAdvisedInterceptor 的 intercept 方法。对于 JdkDynamicAopProxy，需要调用其 invoke 方法。

正如上文提到的，事务管理的框架是由抽象事务管理器 AbstractPlatformTransactionManager 来提供的，而具体的底层事务处理实现，由 PlatformTransactionManager 的具体实现类来实现，如事务管理器 DataSourceTransactionManager。不同的事务管理器管理不同的数据资源 DataSource，比如 DataSourceTransactionManager 管理 JDBC 的 Connection。

PlatformTransactionManager，AbstractPlatformTransactionManager 及具体实现类关系如图 2 所示。

##### 图 2. TransactionManager 类结构

![img](@Transactional 详解.assets/image002.jpg)

## 注解方式的事务使用注意事项

当您对 Spring 的基于注解方式的实现步骤和事务内在实现机制有较好的理解之后，就会更好的使用注解方式的事务管理，避免当系统抛出异常，数据不能回滚的问题。

### 正确的设置@Transactional 的 propagation 属性

需要注意下面三种 propagation 可以不启动事务。本来期望目标方法进行事务管理，但若是错误的配置这三种 propagation，事务将不会发生回滚。

1. TransactionDefinition.PROPAGATION_SUPPORTS：如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
2. TransactionDefinition.PROPAGATION_NOT_SUPPORTED：以非事务方式运行，如果当前存在事务，则把当前事务挂起。
3. TransactionDefinition.PROPAGATION_NEVER：以非事务方式运行，如果当前存在事务，则抛出异常。

### 正确的设置@Transactional 的 rollbackFor 属性

默认情况下，如果在事务中抛出了未检查异常（继承自 RuntimeException 的异常）或者 Error，则 Spring 将回滚事务；除此之外，Spring 不会回滚事务。

如果在事务中抛出其他类型的异常，并期望 Spring 能够回滚事务，可以指定 rollbackFor。例：

@Transactional(propagation= Propagation.REQUIRED,rollbackFor= MyException.class)

通过分析 Spring 源码可以知道，若在目标方法中抛出的异常是 rollbackFor 指定的异常的子类，事务同样会回滚。

##### 清单 3. RollbackRuleAttribute 的 getDepth 方法

```
private int getDepth(Class<?> exceptionClass, int depth) {
        if (exceptionClass.getName().contains(this.exceptionName)) {
            // Found it!
            return depth;
}
        // If we've gone as far as we can go and haven't found it...
        if (exceptionClass == Throwable.class) {
            return -1;
}
return getDepth(exceptionClass.getSuperclass(), depth + 1);
}
```

### @Transactional 只能应用到 public 方法才有效

只有@Transactional 注解应用到 public 方法，才能进行事务管理。这是因为在使用 Spring AOP 代理时，Spring 在调用在图 1 中的 TransactionInterceptor 在目标方法执行前后进行拦截之前，DynamicAdvisedInterceptor（CglibAopProxy 的内部类）的的 intercept 方法或 JdkDynamicAopProxy 的 invoke 方法会间接调用 AbstractFallbackTransactionAttributeSource（Spring 通过这个类获取表 1. @Transactional 注解的事务属性配置属性信息）的 computeTransactionAttribute 方法。

#### 清单 4. AbstractFallbackTransactionAttributeSource

```
protected TransactionAttribute computeTransactionAttribute(Method method,
    Class<?> targetClass) {
        // Don't allow no-public methods as required.
        if (allowPublicMethodsOnly() && !Modifier.isPublic(method.getModifiers())) {
return null;}
```

这个方法会检查目标方法的修饰符是不是 public，若不是 public，就不会获取@Transactional 的属性配置信息，最终会造成不会用 TransactionInterceptor 来拦截该目标方法进行事务管理。

### 避免 Spring 的 AOP 的自调用问题

在 Spring 的 AOP 代理下，只有目标方法由外部调用，目标方法才由 Spring 生成的代理对象来管理，这会造成自调用问题。若同一类中的其他没有@Transactional 注解的方法内部调用有@Transactional 注解的方法，有@Transactional 注解的方法的事务被忽略，不会发生回滚。见清单 5 举例代码展示。

#### 清单 5.自调用问题举例

```
@Service
-->public class OrderService {
    private void insert() {
insertOrder();
}
@Transactional
    public void insertOrder() {
        //insert log info
        //insertOrder
        //updateAccount
       }
}
```

insertOrder 尽管有@Transactional 注解，但它被内部方法 insert 调用，事务被忽略，出现异常事务不会发生回滚。

上面的两个问题@Transactional 注解只应用到 public 方法和自调用问题，是由于使用 Spring AOP 代理造成的。为解决这两个问题，使用 AspectJ 取代 Spring AOP 代理。

需要将下面的 AspectJ 信息添加到 xml 配置信息中。

#### 清单 6. AspectJ 的 xml 配置信息

```
<tx:annotation-driven mode="aspectj" />
<bean id="transactionManager"
class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
<property name="dataSource" ref="dataSource" />
</bean>
</bean
class="org.springframework.transaction.aspectj.AnnotationTransactionAspect"
factory-method="aspectOf">
<property name="transactionManager" ref="transactionManager" />
</bean>
```

同时在 Maven 的 pom 文件中加入 spring-aspects 和 aspectjrt 的 dependency 以及 aspectj-maven-plugin。

#### 清单 7. AspectJ 的 pom 配置信息

```
<dependency>
<groupId>org.springframework</groupId>
<artifactId>spring-aspects</artifactId>
<version>4.3.2.RELEASE</version>
</dependency>
<dependency>
<groupId>org.aspectj</groupId>
<artifactId>aspectjrt</artifactId>
<version>1.8.9</version>
</dependency>
<plugin>
<groupId>org.codehaus.mojo</groupId>
<artifactId>aspectj-maven-plugin</artifactId>
<version>1.9</version>
<configuration>
<showWeaveInfo>true</showWeaveInfo>
<aspectLibraries>
<aspectLibrary>
<groupId>org.springframework</groupId>
<artifactId>spring-aspects</artifactId>
</aspectLibrary>
</aspectLibraries>
</configuration>
<executions>
<execution>
<goals>
<goal>compile</goal>
<goal>test-compile</goal>
</goals>
</execution>
</executions>
</plugin>
```

## 总结

通过本文的介绍，相信读者能够清楚的了解基于@Transactional 注解的实现步骤，能够透彻的理解的 Spring 的内部实现机制，并有效的掌握相关使用注意事项，从而能够正确而熟练的使用基于@Transactional 注解的事务管理方式。

 转自 https://www.ibm.com/developerworks/cn/java/j-master-spring-transactional-use/index.html



----------------

# [Spring事务方法与非事务方法执行相互调用不回滚，你踩过这个坑没？][https://blog.csdn.net/weixin_36380516/article/details/117094776]

### 项目环境 sprinigboot

下面开始问题描述，发生的过程有点长，想直接看方案的直接跳过哦~;

最近在做项目中有个业务是每天定时更新xx的数据，某条记录更新中数据出错，不影响整体数据，只需记录下来并回滚当条记录所关联的表数据;

好啊，这个简单，接到任务后，楼主我三下五除二就写完了，由于这个业务还是有些麻烦，我就在一个service里拆成了两个方法去执行，一个方法(A)是查询数据与验证组装数据，另外一个方法(B)更新这条数据所对应的表(执行的时候是方法A中调用方法B);

由于这个数据是循环更新，所以我想的是，一条数据更新失败直接回滚此条数据就是，不会影响其他数据，其他的照常更新，所以我就在方法B上加了事务，方法A没有加; 以为很完美，自测一下正常，ok通过，再测试一下报错情况，是否回滚，一测，没回滚，懵圈儿?

以为代码写错了，改了几处地方，再测了几次，均没回滚。这下是真难受了。

好啦，写到这里，相信各位看官心里肯定在嘲讽老弟了，spring的传播机制都没搞明白(/难受);

下面开始一步步分析解决问题:

首先我们来看下spring事务的传播机制及原因分析;

- `PROPAGATION_REQUIRED`：支持当前事务，如果当前没有事务，就新建一个事务。这是最常见的选择。
- `PROPAGATION_SUPPORTS`：支持当前事务，如果当前没有事务，就以非事务方式执行。
- `PROPAGATION_MANDATORY`：支持当前事务，如果当前没有事务，就抛出异常。
- `PROPAGATION_REQUIRES_NEW`：新建事务，如果当前存在事务，把当前事务挂起。
- `PROPAGATION_NOT_SUPPORTED`：以非事务方式执行操作，如果当前存在事务，就把当前事务挂起。
- `PROPAGATION_NEVER`：以非事务方式执行，如果当前存在事务，则抛出异常。
- `PROPAGATION_NESTED`：如果当前存在事务，则在嵌套事务内执行。如果当前没有事务，则进行与PROPAGATION_REQUIRED类似的操作。

spring默认的是`PROPAGATION_REQUIRED`机制，如果方法A标注了注解`@Transactional` 是完全没问题的，执行的时候传播给方法B，因为方法A开启了事务，线程内的connection的属性`autoCommit=false`，并且执行到方法B时，事务传播依然是生效的，得到的还是方法A的connection，autoCommit还是为false，所以事务生效。

反之，如果方法A没有注解`@Transactional` 时，是不受事务管理的，`autoCommit=true`，那么传播给方法B的也为true，执行完自动提交，即使B标注了`@Transactional`;

**在一个Service内部，事务方法之间的嵌套调用，普通方法和事务方法之间的嵌套调用，都不会开启新的事务。是因为spring采用动态代理机制来实现事务控制，而动态代理最终都是要调用原始对象的，而原始对象在去调用方法时，是不会再触发代理了！**

所以以上就是为什么我在没有标注事务注解的方法A里去调用标注有事务注解的方法B而没有事务滚回的原因;

看到这里，有的看官可能在想，你在方法A上标个注解不就完了吗?为什么非要标注在方法B上?

由于我这里是循环更新数据，调用一次方法B就更新一次数据，涉及到几张表，需要执行几条update sql，一条数据更新失败不影响所有数据，所以说一条数据更新执行完毕后就提交一次事务，如果标注在方法A上，要所有的都执行完毕了才提交事务，这样子是有问题滴。

先上代码:

方法A:无事务控制

![img](@Transactional 详解.assets/66c984fedc368e69705907f8a43c6b6f.png)

方法B:有事务控制

![img](@Transactional 详解.assets/9706ef8c6f83cc071fe9ea57bbce20b4.png)

方法B处理失败手动抛出异常触发回滚:

![img](@Transactional 详解.assets/77fc30ba252c7664b29f9c33893afa56.png)

方法A调用方法B:

![img](@Transactional 详解.assets/ac941f353c64dcdab1468444bbccf789.png)

从上图可以看到，如果方法B中User更新出错后需要回滚RedPacket数据，所以User更新失败就抛出了继承自RuntimeException的自定义异常，并且在调用方把这个异常catch到重新抛出，触发事务回滚，但是并没有执行;

下面是解决方案:

**1，把方法B抽离到另外一个XXService中去，并且在这个Service中注入XXService，使用XXService调用方法B;**

显然，这种方式一点也不优雅，且要产生很多冗余文件，看起来很烦，实际开发中也几乎没人这么做吧?。反正我不建议采用此方案;

**2，通过在方法内部获得当前类代理对象的方式，通过代理对象调用方法B**

上面说了:动态代理最终都是要调用原始对象的，而原始对象在去调用方法时，是不会再触发代理了！

所以我们就使用代理对象来调用，就会触发事务;

综上解决方案，我觉得第二种方式简直方便到炸。 那怎么获取代理对象呢? 这里提供两种方式:

1. 使用 ApplicationContext 上下文对象获取该对象;
2. 使用 AopContext。currentProxy() 获取代理对象，但是需要配置exposeProxy=true

我这里使用的是第二种解决方案，具体操作如下:

springboot启动类加上注解:`@EnableAspectJAutoProxy(exposeProxy = true)`

![img](@Transactional 详解.assets/340f3357c45c5a57d756a057bb7a2fc3.png)

方法内部获取代理对象调用方法

![img](@Transactional 详解.assets/39708f11dc1633306ffef7d55bfdbc92.png)

完了后再测试，数据顺利回滚。至此，问题得到解决!

都是事务这块儿基础太差的错啊~~希望各位遇到这种问题的兄弟些都好好的去研究研究spring这块儿



----

# AopContext.currentProxy()用法



在同一个类中，非事务方法A调用事务方法B，事务失效，得采用AopContext.currentProxy().xx()来进行调用，事务才能生效。

> B方法被A调用，对B方法的切入失效，但加上AopContext.currentProxy()创建了代理类，在代理类中调用该方法前后进行切入。对于B方法![proxy.B，执行的过程是先记录日志后调用方法体，但在A方法](@Transactional 详解&Spring事务方法与非事务方法执行相互调用不回滚.assets/mathformula=proxy.B，执行的过程是先记录日志后调用方法体，但在A方法)proxyA中调用只能对A进行增强，A里面调用B使用的是对象.B(),而不是$proxy.B(),所以对B的切入无效。

AopContext.currentProxy()使用了ThreadLocal保存了代理对象，因此
 AopContext.currentProxy().B()就能解决。

在不同类中，非事务方法A调用事务方法B，事务生效。
 在同一个类中，事务方法A调用非事务方法B，事务具有传播性，事务生效
 在不同类中，事务方法A调用非事务方法B，事务生效。



原来在springAOP的用法中，只有代理的类才会被切入，我们在controller层调用service的方法的时候，是可以被切入的，但是如果我们在service层 A方法中，调用B方法，切点切的是B方法，那么这时候是不会切入的，解决办法就是如上所示，在A方法中使用((Service)AopContext.currentProxy()).B() 来调用B方法，这样一来，就能切入了！

### AopContext.currentProxy()该用法的意义

具体的用法在下面的代码中可以体会：



```java
@Configuration
@ComponentScan("com.dalianpai.spring5.aop")
@EnableAspectJAutoProxy(exposeProxy = true)//开启spring注解aop配置的支持
public class SpringConfiguration {
}



public class User implements Serializable {
    private String id;
    private String username;
    private String password;
    private String email;
    private Date birthday;
    private String gender;
    private String mobile;
    private String nickname;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Date getBirthday() {
        return birthday;
    }

    public void setBirthday(Date birthday) {
        this.birthday = birthday;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
}


@Service("userService")
public class UserServiceImpl implements UserService {

    @Override
    public void saveUser(User user) {
        System.out.println("执行了保存用户"+user);
    }

    @Override
    public void saveAllUser(List<User> users) {
        for(User user : users){
            UserService proxyUserServiceImpl = (UserService)AopContext.currentProxy();
            proxyUserServiceImpl.saveUser(user);
        }
    }
}


public interface UserService {

    /**
     * 模拟保存用户
     * @param user
     */
    void saveUser(User user);

    /**
     * 批量保存用户
     * @param users
     */
    void saveAllUser(List<User> users);
}


@Component
@Aspect//表明当前类是一个切面类
public class LogUtil {

    /**
     * 用于配置当前方法是一个前置通知
     */
    @Before("execution(* com.dalianpai.spring5.aop.service.impl.*.saveUser(..))")
    public void printLog(){
        System.out.println("执行打印日志的功能");
    }
}
```

测试类：



```java
public class SpringEnableAspecctJAutoProxyTest {

    public static void main(String[] args) {
        //1.创建容器
        AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(SpringConfiguration.class);
        //2.获取对象
        UserService userService = ac.getBean("userService",UserService.class);
        //3.执行方法
        User user = new User();
        user.setId("1");
        user.setUsername("test");
        List<User> users = new ArrayList<>();
        users.add(user);

        userService.saveAllUser(users);
    }
}
```

[![img](@Transactional 详解&Spring事务方法与非事务方法执行相互调用不回滚.assets/image-20200921231626082.png)](https://typora-oss.oss-cn-beijing.aliyuncs.com/image-20200921231626082.png)

如果去掉这行`UserService proxyUserServiceImpl = (UserService)AopContext.currentProxy();`

[![img](@Transactional 详解&Spring事务方法与非事务方法执行相互调用不回滚.assets/image-20200921231738938.png)](https://typora-oss.oss-cn-beijing.aliyuncs.com/image-20200921231738938.png)