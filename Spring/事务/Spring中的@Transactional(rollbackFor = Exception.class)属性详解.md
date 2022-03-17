# 一、[Spring中的@Transactional(rollbackFor = Exception.class)属性详解](https://www.cnblogs.com/clwydjgs/p/9317849.html)

### 序言

今天我在写代码的时候，看到了。一个注解@Transactional(rollbackFor = Exception.class)，今天就和大家分享一下，这个注解的用法；

![img](https://images2018.cnblogs.com/blog/1416523/201807/1416523-20180716145500174-544418190.png)

 

### 异常

如下图所示，我们都知道Exception分为运行时异常RuntimeException和非运行时异常

error是一定会回滚的

![img](https://images2018.cnblogs.com/blog/1416523/201807/1416523-20180716145710583-1342649521.png)

如果不对运行时异常进行处理，那么出现运行时异常之后，要么是线程中止，要么是主程序终止。 
如果不想终止，则必须捕获所有的运行时异常，决不让这个处理线程退出。队列里面出现异常数据了，正常的处理应该是把异常数据舍弃，然后记录日志。不应该由于异常数据而影响下面对正常数据的处理。


非运行时异常是RuntimeException以外的异常，类型上都属于Exception类及其子类。如IOException、SQLException等以及用户自定义的Exception异常。对于这种异常，JAVA编译器强制要求我们必需对出现的这些异常进行catch并处理，否则程序就不能编译通过。所以，面对这种异常不管我们是否愿意，只能自己去写一大堆catch块去处理可能的异常。

 

### **事务管理方式**  

事务管理对于企业应用来说是至关重要的，即使出现异常情况，它也可以保证数据的一致性。

spring支持编程式事务管理和声明式事务管理两种方式。

　　 编程式事务管理使用TransactionTemplate或者直接使用底层的PlatformTransactionManager。对于编程式事务管理，spring推荐使用TransactionTemplate。

　　声明式事务管理建立在AOP之上的。其本质是对方法前后进行拦截，然后在目标方法开始之前创建或者加入一个事务，在执行完目标方法之后根据执行情况提交或者回滚事务。

　　声明式事务管理也有两种常用的方式，一种是基于tx和aop名字空间的xml配置文件，另一种就是基于@Transactional注解。显然基于注解的方式更简单易用，更清爽。

 

### 使用说明

当作用于类上时，该类的所有 public 方法将都具有该类型的事务属性，同时，我们也可以在方法级别使用该标注来覆盖类级别的定义。

在项目中，@Transactional(rollbackFor=Exception.class)，如果类加了这个注解，那么这个类里面的方法抛出异常，就会回滚，数据库里面的数据也会回滚。

**在@Transactional注解中如果不配置rollbackFor属性,那么事物只会在遇到RuntimeException的时候才会回滚,加上rollbackFor=Exception.class,可以让事物在遇到非运行时异常时也回滚**

 

***@Transactional注解的全部属性详解\***

*@Transactional属性*

| 属性                   | 类型                               | 描述                                   |
| ---------------------- | ---------------------------------- | -------------------------------------- |
| value                  | String                             | 可选的限定描述符，指定使用的事务管理器 |
| propagation            | enum: Propagation                  | 可选的事务传播行为设置                 |
| isolation              | enum: Isolation                    | 可选的事务隔离级别设置                 |
| readOnly               | boolean                            | 读写或只读事务，默认读写               |
| timeout                | int (in seconds granularity)       | 事务超时时间设置                       |
| rollbackFor            | Class对象数组，必须继承自Throwable | 导致事务回滚的异常类数组               |
| rollbackForClassName   | 类名数组，必须继承自Throwable      | 导致事务回滚的异常类名字数组           |
| noRollbackFor          | Class对象数组，必须继承自Throwable | 不会导致事务回滚的异常类数组           |
| noRollbackForClassName | 类名数组，必须继承自Throwable      | 不会导致事务回滚的异常类名字数组       |

 

==总结：程序出现运行时异常或者非运行时异常都会终止程序，需要catch，而@Transactional如果不加rollbackFor则只会回滚运行时异常，因此为了让所有异常都能回滚需加上@Transactional（rollbackFor=Exception.class）==



----



# 二、[你知道阿里规范为什么在 @Transactional 事务注解中指定 rollbackFor吗？](https://mp.weixin.qq.com/s/Rp-HMfnKJpRwmytnFF04Gw)

- 1.异常的分类
- 2.@Transactional 的写法

![图片](Spring中的@Transactional(rollbackFor = Exception.class)属性详解.assets/640.png)



------

java阿里巴巴规范提示：方法【edit】需要在Transactional注解指定rollbackFor或者在方法中显示的rollback。

## 1.异常的分类

先来看看异常的分类

![图片](Spring中的@Transactional(rollbackFor = Exception.class)属性详解.assets/640.jpeg)

error是一定会回滚的

这里Exception是异常，他又分为运行时异常RuntimeException和非运行时异常

![图片](Spring中的@Transactional(rollbackFor = Exception.class)属性详解.assets/640.png)

- 可查的异常（checked exceptions）:Exception下除了RuntimeException外的异常
- 不可查的异常（unchecked exceptions）:RuntimeException及其子类和错误（Error）

如果不对运行时异常进行处理，那么出现运行时异常之后，要么是线程中止，要么是主程序终止。如果不想终止，则必须捕获所有的运行时异常，决不让这个处理线程退出。队列里面出现异常数据了，正常的处理应该是把异常数据舍弃，然后记录日志。不应该由于异常数据而影响下面对正常数据的处理。

非运行时异常是RuntimeException以外的异常，类型上都属于Exception类及其子类。如IOException、SQLException等以及用户自定义的Exception异常。对于这种异常，JAVA编译器强制要求我们必需对出现的这些异常进行catch并处理，否则程序就不能编译通过。所以，面对这种异常不管我们是否愿意，只能自己去写一大堆catch块去处理可能的异常。

## 2.@Transactional 的写法

开始主题@Transactional如果只这样写，

Spring框架的事务基础架构代码将默认地只在抛出运行时和unchecked exceptions时才标识事务回滚。也就是说，当抛出个`RuntimeException` 或其子类例的实例时。（`Errors` 也一样 - 默认地 - 标识事务回滚。）从事务方法中抛出的Checked exceptions将不被标识进行事务回滚。

1. 让checked例外也回滚：在整个方法前加上 `@Transactional(rollbackFor=Exception.class)`
2. 让unchecked例外不回滚：`@Transactional(notRollbackFor=RunTimeException.class)`
3. 不需要事务管理的(只查询的)方法：`@Transactional(propagation=Propagation.NOT_SUPPORTED)`

**注意：如果异常被 `try {} catch {}` 了，事务就不回滚了，如果想让事务回滚必须再往外抛 `try {} catch {throw Exception}` 。**

## 3. 注意

1、Spring团队的建议是你在具体的类（或类的方法）上使用 @Transactional 注解，而不要使用在类所要实现的任何接口上。

你当然可以在接口上使用 @Transactional 注解，但是这将只能当你设置了基于接口的代理时它才生效。因为注解是不能继承的，这就意味着如果你正在使用基于类的代理时，那么事务的设置将不能被基于类的代理所识别，而且对象也将不会被事务代理所包装（将被确认为严重的）。

因此，请接受Spring团队的建议并且在具体的类上使用 @Transactional 注解。

2、@Transactional 注解标识的方法，处理过程尽量的简单。

尤其是带锁的事务方法，能不放在事务里面的最好不要放在事务里面。

可以将常规的数据库查询操作放在事务前面进行，而事务内进行增、删、改、加锁查询等操作。
