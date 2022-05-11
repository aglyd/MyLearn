# 一、[带你读懂Spring 事务——事务的传播机制](https://zhuanlan.zhihu.com/p/148504094)

### 一、什么是事务的传播？

简单的理解就是多个事务方法相互调用时,事务如何在这些方法间传播。

> 举个栗子，方法A是一个事务的方法，方法A执行过程中调用了方法B，那么方法B有无事务以及方法B对事务的要求不同都会对方法A的事务具体执行造成影响，同时方法A的事务对方法B的事务执行也有影响，这种影响具体是什么就由两个方法所定义的事务传播类型所决定。

### 二、Spring事务传播类型枚举Propagation介绍

在Spring中对于事务的传播行为定义了七种类型分别是：**REQUIRED、SUPPORTS、MANDATORY、REQUIRES_NEW、NOT_SUPPORTED、NEVER、NESTED**。

在Spring源码中这七种类型被定义为了枚举。源码在org.springframework.transaction.annotation包下的Propagation，源码中注释很多，对传播行为的七种类型的不同含义都有解释，后文中锤子我也会给大家分析，我在这里就不贴所有的源码，只把这个类上的注解贴一下，翻译一下就是：*表示与TransactionDefinition接口相对应的用于@Transactional注解的事务传播行为的枚举。*

也就是说枚举类Propagation是为了结合@Transactional注解使用而设计的，这个枚举里面定义的事务传播行为类型与TransactionDefinition中定义的事务传播行为类型是对应的，所以在使用@Transactional注解时我们就要使用Propagation枚举类来指定传播行为类型，而不直接使用TransactionDefinition接口里定义的属性。

在TransactionDefinition接口中定义了Spring事务的一些属性，不仅包括事务传播特性类型，还包括了事务的隔离级别类型（事务的隔离级别后面文章会详细讲解），更多详细信息，大家可以打开源码自己翻译一下里面的注释

```java
package org.springframework.transaction.annotation;

import org.springframework.transaction.TransactionDefinition;

/**
 * Enumeration that represents transaction propagation behaviors for use
 * with the {@link Transactional} annotation, corresponding to the
 * {@link TransactionDefinition} interface.
 *
 * @author Colin Sampaleanu
 * @author Juergen Hoeller
 * @since 1.2
 */
public enum Propagation {
    ...
}
```

### 三、七种事务传播行为详解与示例

在介绍七种事务传播行为前，我们先设计一个场景，帮助大家理解，场景描述如下

> 现有两个方法A和B，方法A执行会在数据库ATable插入一条数据，方法B执行会在数据库BTable插入一条数据，伪代码如下:

```java
//将传入参数a存入ATable
pubilc void A(a){
    insertIntoATable(a);    
}
//将传入参数b存入BTable
public void B(b){
    insertIntoBTable(b);
}
```

接下来，我们看看在如下场景下，没有事务，情况会怎样

```java
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
}

public void testB(){
    B(b1);  //调用B入参b1
    throw Exception;     //发生异常抛出
    B(b2);  //调用B入参b2
}
```

在这里要做一个重要提示：**Spring中事务的默认实现使用的是AOP，也就是代理的方式，如果大家在使用代码测试时，同一个Service类中的方法相互调用需要使用注入的对象来调用，不要直接使用this.方法名来调用，this.方法名调用是对象内部方法调用，不会通过Spring代理，也就是事务不会起作用**

以上伪代码描述的一个场景，方法testMain和testB都没有事务，执行testMain方法，那么结果会怎么样呢？

相信大家都知道了，就是a1数据成功存入ATable表，b1数据成功存入BTable表，而在抛出异常后b2数据存储就不会执行，也就是b2数据不会存入数据库，这就是没有事务的场景。

可想而知，在上一篇文章（认识事务）中举例的转账操作，如果在某一步发生异常，且没有事务，那么钱是不是就凭空消失了，所以事务在数据库操作中的重要性可想而知。接下我们就开始理解七种不同事务传播类型的含义

### **REQUIRED(Spring默认的事务传播类型)**

**如果当前没有事务，则自己新建一个事务，如果当前存在事务，则加入这个事务**

源码说明如下：

```java
/**
     * Support a current transaction, create a new one if none exists.
     * Analogous to EJB transaction attribute of the same name.
     * <p>This is the default setting of a transaction annotation.
     */
    REQUIRED(TransactionDefinition.PROPAGATION_REQUIRED),
```

*(示例1)*根据场景举栗子,我们在testMain和testB上声明事务，设置传播行为REQUIRED，伪代码如下：

```java
@Transactional(propagation = Propagation.REQUIRED)
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
}
@Transactional(propagation = Propagation.REQUIRED)
public void testB(){
    B(b1);  //调用B入参b1
    throw Exception;     //发生异常抛出
    B(b2);  //调用B入参b2
}
```

该场景下执行testMain方法结果如何呢？

数据库没有插入新的数据，数据库还是保持着执行testMain方法之前的状态，没有发生改变。testMain上声明了事务，在执行testB方法时就加入了testMain的事务（**当前存在事务，则加入这个事务**），在执行testB方法抛出异常后事务会发生回滚，又testMain和testB使用的同一个事务，所以事务回滚后testMain和testB中的操作都会回滚，也就使得数据库仍然保持初始状态

*(示例2)*根据场景再举一个栗子,我们只在testB上声明事务，设置传播行为REQUIRED，伪代码如下：

```java
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
}
@Transactional(propagation = Propagation.REQUIRED)
public void testB(){
    B(b1);  //调用B入参b1
    throw Exception;     //发生异常抛出
    B(b2);  //调用B入参b2
}
```

这时的执行结果又如何呢？

数据a1存储成功，数据b1和b2没有存储。由于testMain没有声明事务，testB有声明事务且传播行为是REQUIRED，所以在执行testB时会自己新建一个事务（**如果当前没有事务，则自己新建一个事务**），testB抛出异常则只有testB中的操作发生了回滚，也就是b1的存储会发生回滚，但a1数据不会回滚，所以最终a1数据存储成功，b1和b2数据没有存储

### **SUPPORTS**

**当前存在事务，则加入当前事务，如果当前没有事务，就以非事务方法执行**

源码注释如下(太长省略了一部分)，其中里面有一个提醒翻译一下就是：“对于具有事务同步的事务管理器，SUPPORTS与完全没有事务稍有不同，因为它定义了可能应用同步的事务范围”。这个是与事务同步管理器相关的一个注意项，这里不过多讨论。

```java
/**
     * Support a current transaction, execute non-transactionally if none exists.
     * Analogous to EJB transaction attribute of the same name.
     * <p>Note: For transaction managers with transaction synchronization,
     * {@code SUPPORTS} is slightly different from no transaction at all,
     * as it defines a transaction scope that synchronization will apply for.
     ...
     */
    SUPPORTS(TransactionDefinition.PROPAGATION_SUPPORTS),
```

*(示例3)*根据场景举栗子，我们只在testB上声明事务，设置传播行为SUPPORTS，伪代码如下：

```java
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
}
@Transactional(propagation = Propagation.SUPPORTS)
public void testB(){
    B(b1);  //调用B入参b1
    throw Exception;     //发生异常抛出
    B(b2);  //调用B入参b2
}
```

这种情况下，执行testMain的最终结果就是，a1，b1存入数据库，b2没有存入数据库。由于testMain没有声明事务，且testB的事务传播行为是SUPPORTS，所以执行testB时就是没有事务的（**如果当前没有事务，就以非事务方法执行**），则在testB抛出异常时也不会发生回滚，所以最终结果就是a1和b1存储成功，b2没有存储。

那么当我们在testMain上声明事务且使用REQUIRED传播方式的时候，这个时候执行testB就满足**当前存在事务，则加入当前事务**，在testB抛出异常时事务就会回滚，最终结果就是a1，b1和b2都不会存储到数据库

### **MANDATORY**

**当前存在事务，则加入当前事务，如果当前事务不存在，则抛出异常。**

源码注释如下：

```java
/**
     * Support a current transaction, throw an exception if none exists.
     * Analogous to EJB transaction attribute of the same name.
     */
    MANDATORY(TransactionDefinition.PROPAGATION_MANDATORY),
```

*(示例4)*场景举栗子，我们只在testB上声明事务，设置传播行为MANDATORY，伪代码如下：

```java
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
}
@Transactional(propagation = Propagation.MANDATORY)
public void testB(){
    B(b1);  //调用B入参b1
    throw Exception;     //发生异常抛出
    B(b2);  //调用B入参b2
}
```

这种情形的执行结果就是a1存储成功，而b1和b2没有存储。b1和b2没有存储，并不是事务回滚的原因，而是因为testMain方法没有声明事务，在去执行testB方法时就直接抛出事务要求的异常（**如果当前事务不存在，则抛出异常**），所以testB方法里的内容就没有执行。

那么如果在testMain方法进行事务声明，并且设置为REQUIRED，则执行testB时就会使用testMain已经开启的事务，遇到异常就正常的回滚了。

### **REQUIRES_NEW**

**创建一个新事务，如果存在当前事务，则挂起该事务。**

可以理解为设置事务传播类型为REQUIRES_NEW的方法，在执行时，不论当前是否存在事务，总是会新建一个事务。

源码注释如下

```java
/**
     * Create a new transaction, and suspend the current transaction if one exists.
     ...
     */
    REQUIRES_NEW(TransactionDefinition.PROPAGATION_REQUIRES_NEW),
```

*(示例5)*场景举栗子，为了说明设置REQUIRES_NEW的方法会开启新事务，我们把异常发生的位置换到了testMain，然后给testMain声明事务，传播类型设置为REQUIRED，testB也声明事务，设置传播类型为REQUIRES_NEW，伪代码如下

```java
@Transactional(propagation = Propagation.REQUIRED)
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
    throw Exception;     //发生异常抛出
}
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void testB(){
    B(b1);  //调用B入参b1
    B(b2);  //调用B入参b2
}
```

这种情形的执行结果就是a1没有存储，而b1和b2存储成功，因为testB的事务传播设置为REQUIRES_NEW,所以在执行testB时会开启一个新的事务，testMain中发生的异常时在testMain所开启的事务中，所以这个异常不会影响testB的事务提交，testMain中的事务会发生回滚，所以最终a1就没有存储，而b1和b2就存储成功了。

与这个场景对比的一个场景就是testMain和testB都设置为REQUIRED，那么上面的代码执行结果就是所有数据都不会存储，因为testMain和testMain是在同一个事务下的，所以事务发生回滚时，所有的数据都会回滚

### **NOT_SUPPORTED**

**始终以非事务方式执行,如果当前存在事务，则挂起当前事务**

可以理解为设置事务传播类型为NOT_SUPPORTED的方法，在执行时，不论当前是否存在事务，都会以非事务的方式运行。

源码说明如下

```java
/**
     * Execute non-transactionally, suspend the current transaction if one exists.
     ...
     */
    NOT_SUPPORTED(TransactionDefinition.PROPAGATION_NOT_SUPPORTED),
```

*(示例6)*场景举栗子，testMain传播类型设置为REQUIRED，testB传播类型设置为NOT_SUPPORTED，且异常抛出位置在testB中，伪代码如下

```java
@Transactional(propagation = Propagation.REQUIRED)
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
}
@Transactional(propagation = Propagation.NOT_SUPPORTED)
public void testB(){
    B(b1);  //调用B入参b1
    throw Exception;     //发生异常抛出
    B(b2);  //调用B入参b2
}
```

该场景的执行结果就是a1和b2没有存储，而b1存储成功。testMain有事务，而testB不使用事务，所以执行中testB的存储b1成功，然后抛出异常，此时testMain检测到异常事务发生回滚，但是由于testB不在事务中，所以只有testMain的存储a1发生了回滚，最终只有b1存储成功，而a1和b1都没有存储

### **NEVER**

**不使用事务，如果当前事务存在，则抛出异常**

很容易理解，就是我这个方法不使用事务，并且调用我的方法也不允许有事务，如果调用我的方法有事务则我直接抛出异常。

源码注释如下：

```java
/**
     * Execute non-transactionally, throw an exception if a transaction exists.
     * Analogous to EJB transaction attribute of the same name.
     */
    NEVER(TransactionDefinition.PROPAGATION_NEVER),
```

*(示例7)*场景举栗子，testMain设置传播类型为REQUIRED，testB传播类型设置为NEVER，并且把testB中的抛出异常代码去掉，则伪代码如下

```java
@Transactional(propagation = Propagation.REQUIRED)
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
}
@Transactional(propagation = Propagation.NEVER)
public void testB(){
    B(b1);  //调用B入参b1
    B(b2);  //调用B入参b2
}
```

该场景执行，直接抛出事务异常，且不会有数据存储到数据库。由于testMain事务传播类型为REQUIRED，所以testMain是运行在事务中，而testB事务传播类型为NEVER，所以testB不会执行而是直接抛出事务异常，此时testMain检测到异常就发生了回滚，所以最终数据库不会有数据存入。

### **NESTED**

**如果当前事务存在，则在嵌套事务中执行，否则REQUIRED的操作一样（开启一个事务）**

这里需要注意两点：

- 和REQUIRES_NEW的区别

> REQUIRES_NEW是新建一个事务并且新开启的这个事务与原有事务无关，而NESTED则是当前存在事务时（我们把当前事务称之为父事务）会开启一个嵌套事务（称之为一个子事务）。
> 在NESTED情况下父事务回滚时，子事务也会回滚，而在REQUIRES_NEW情况下，原有事务回滚，不会影响新开启的事务。

- 和REQUIRED的区别

> REQUIRED情况下，调用方存在事务时，则被调用方和调用方使用同一事务，那么被调用方出现异常时，由于共用一个事务，所以无论调用方是否catch其异常，事务都会回滚
> 而在NESTED情况下，被调用方发生异常时，调用方可以catch其异常，这样只有子事务回滚，父事务不受影响

**==NESTED可用于批量插入事务，父事务回滚子事务都回滚，子事务异常捕获，父事务不回滚==**

*(示例8)*场景举栗子，testMain设置为REQUIRED，testB设置为NESTED，且异常发生在testMain中，伪代码如下

```java
@Transactional(propagation = Propagation.REQUIRED)
public void testMain(){
    A(a1);  //调用A入参a1
    testB();    //调用testB
    throw Exception;     //发生异常抛出
}
@Transactional(propagation = Propagation.NESTED)
public void testB(){
    B(b1);  //调用B入参b1
    B(b2);  //调用B入参b2
}
```

该场景下，所有数据都不会存入数据库，因为在testMain发生异常时，父事务回滚则子事务也跟着回滚了，可以与*(示例5)*比较看一下，就找出了与REQUIRES_NEW的不同

*(示例9)*场景举栗子，testMain设置为REQUIRED，testB设置为NESTED，且异常发生在testB中，伪代码如下

```java
@Transactional(propagation = Propagation.REQUIRED)
public void testMain(){
    A(a1);  //调用A入参a1
    try{
        testB();    //调用testB
    }catch（Exception e){

    }
    A(a2);
}
@Transactional(propagation = Propagation.NESTED)
public void testB(){
    B(b1);  //调用B入参b1
    throw Exception;     //发生异常抛出
    B(b2);  //调用B入参b2
}
```

这种场景下，结果是a1,a2存储成功，b1和b2存储失败，因为调用方catch了被调方的异常，所以只有子事务回滚了。

同样的代码，如果我们**把testB的传播类型改为REQUIRED，结果也就变成了：没有数据存储成功。就算在调用方catch了异常，整个事务还是会回滚，因为，调用方和被调方共用的同一个事务。如果testB是REQUIRES_NEW，catch了可以防止testB内层异常抛出导致testMain外层事务也回滚**





-----

# 二、[Spring五个事务隔离级别和七个事务传播行为](https://www.cnblogs.com/wj0816/p/8474743.html)

#### Spring五个事务隔离级别和七个事务传播行为

\1. 脏读 ：脏读就是指当一个事务正在访问数据，并且对数据进行了修改，而这种修改还没有提交到数据库中，这时，另外一个事务也访问这个数据，然后使用了这个数据。

\2. 不可重复读 ：是指在一个事务内，多次读同一数据。在这个事务还没有结束时，另外一个事务也访问该同一数据。那么，在第一个事务中的两 次读数据之间，由于第二个事务的修改，那么第一个事务两次读到的的数据可能是不一样的。这样就发生了在一个事务内两次读到的数据是不一样的，因此称为是不 可重复读。例如，一个编辑人员两次读取同一文档，但在两次读取之间，作者重写了该文档。当编辑人员第二次读取文档时，文档已更改。原始读取不可重复。如果 只有在作者全部完成编写后编辑人员才可以读取文档，则可以避免该问题。![spacer.gif](http://blog.yemou.net/static/plugins/ueditor1_4_3-utf8-jsp/themes/default/images/spacer.gif) …数据库事务和Spring事务是一般面试都会被提到，很多朋友写惯了代码，很少花时间去整理归纳这些东西，结果本来会的东西，居然吞吞吐吐答不上来。

下面是我收集到一些关于Spring事务的问题，希望能帮助大家过关。

\3. 幻读 : 是指当事务不是独立执行时发生的一种现象，例如第一个事务对一个表中的数据进行了修改，这种修改涉及到表中的全部数据行。 同时，第二个事务也修改这个表中的数据，这种修改是向表中插入一行新数据。那么，以后就会发生操作第一个事务的用户发现表中还有没有修改的数据行，就好象 发生了幻觉一样。例如，一个编辑人员更改作者提交的文档，但当生产部门将其更改内容合并到该文档的主复本时，发现作者已将未编辑的新材料添加到该文档中。 如果在编辑人员和生产部门完成对原始文档的处理之前，任何人都不能将新材料添加到文档中，则可以避免该问题。

补充 : 基于元数据的 Spring 声明性事务 :

Isolation 属性一共支持五种事务设置，具体介绍如下：

<!—->l     <!—->DEFAULT 使用数据库设置的隔离级别 ( 默认 ) ，由 DBA 默认的设置来决定隔离级别 .

<!—->l     <!—->READ_UNCOMMITTED 会出现脏读、不可重复读、幻读 ( 隔离级别最低，并发性能高 )

<!—->l     <!—->READ_COMMITTED 会出现不可重复读、幻读问题（锁定正在读取的行）

<!—->l     <!—->REPEATABLE_READ 会出幻读（锁定所读取的所有行）

<!—->l     <!—->SERIALIZABLE 保证所有的情况不会发生（锁表）

不可重复读的重点是修改 : 
同样的条件 ,  你读取过的数据 ,  再次读取出来发现值不一样了 
幻读的重点在于新增或者删除 
同样的条件 ,  第 1 次和第 2 次读出来的记录数不一样

Spring在TransactionDefinition接口中定义这些属性

在TransactionDefinition接口中定义了五个不同的事务隔离级别

ISOLATION_DEFAULT 这是一个PlatfromTransactionManager默认的隔离级别，使用数据库默认的事务隔离级别.另外四个与JDBC的隔离级别相对应 
ISOLATION_READ_UNCOMMITTED 这是事务最低的隔离级别，它充许别外一个事务可以看到这个事务未提交的数据。这种隔离级别会产生脏读，不可重复读和幻像读

ISOLATION_READ_COMMITTED 保证一个事务修改的数据提交后才能被另外一个事务读取。另外一个事务不能读取该事务未提交的数据。这种事务隔离级别可以避免脏读出现，但是可能会出现不可重复读和幻像读。

ISOLATION_REPEATABLE_READ 这种事务隔离级别可以防止脏读，不可重复读。但是可能出现幻像读。它除了保证一个事务不能读取另一个事务未提交的数据外，还保证了避免下面的情况产生(不可重复读)。

ISOLATION_SERIALIZABLE 这是花费最高代价但是最可靠的事务隔离级别。事务被处理为顺序执行。除了防止脏读，不可重复读外，还避免了幻像读。

 

在TransactionDefinition接口中定义了七个事务传播行为。

PROPAGATION_REQUIRED 如果存在一个事务，则支持当前事务。如果没有事务则开启一个新的事务。

PROPAGATION_SUPPORTS 如果存在一个事务，支持当前事务。如果没有事务，则非事务的执行。但是对于事务同步的事务管理器，PROPAGATION_SUPPORTS与不使用事务有少许不同。

PROPAGATION_MANDATORY 如果已经存在一个事务，支持当前事务。如果没有一个活动的事务，则抛出异常。

PROPAGATION_REQUIRES_NEW 总是开启一个新的事务。如果一个事务已经存在，则将这个存在的事务挂起。

PROPAGATION_NOT_SUPPORTED 总是非事务地执行，并挂起任何存在的事务。

PROPAGATION_NEVER 总是非事务地执行，如果存在一个活动事务，则抛出异常

PROPAGATION_NESTED如果一个活动的事务存在，则运行在一个嵌套的事务中. 如果没有活动事务, 则按TransactionDefinition.PROPAGATION_REQUIRED 属性执行

事务是逻辑处理原子性的保证手段，通过使用事务控制，可以极大的避免出现逻辑处理失败导致的脏数据等问题。

事务最重要的两个特性，是事务的传播级别和数据隔离级别。传播级别定义的是事务的控制范围，事务隔离级别定义的是事务在数据库读写方面的控制范围。

事务的7种传播级别：

1） PROPAGATION_REQUIRED ，默认的spring事务传播级别，使用该级别的特点是，如果上下文中已经存在事务，那么就加入到事务中执行，如果当前上下文中不存在事务，则新建事务执行。所以这个级别通常能满足处理大多数的业务场景。

2）PROPAGATION_SUPPORTS ，从字面意思就知道，supports，支持，该传播级别的特点是，如果上下文存在事务，则支持事务加入事务，如果没有事务，则使用非事务的方式执行。所以说，并非所有的包在transactionTemplate.execute中的代码都会有事务支持。这个通常是用来处理那些并非原子性的非核心业务逻辑操作。应用场景较少。

3）PROPAGATION_MANDATORY ， 该级别的事务要求上下文中必须要存在事务，否则就会抛出异常！配置该方式的传播级别是有效的控制上下文调用代码遗漏添加事务控制的保证手段。比如一段代码不能单独被调用执行，但是一旦被调用，就必须有事务包含的情况，就可以使用这个传播级别。

4）PROPAGATION_REQUIRES_NEW ，从字面即可知道，new，每次都要一个新事务，该传播级别的特点是，每次都会新建一个事务，并且同时将上下文中的事务挂起，执行当前新建事务完成以后，上下文事务恢复再执行。

这是一个很有用的传播级别，举一个应用场景：现在有一个发送100个红包的操作，在发送之前，要做一些系统的初始化、验证、数据记录操作，然后发送100封红包，然后再记录发送日志，发送日志要求100%的准确，如果日志不准确，那么整个父事务逻辑需要回滚。
怎么处理整个业务需求呢？就是通过这个PROPAGATION_REQUIRES_NEW 级别的事务传播控制就可以完成。发送红包的子事务不会直接影响到父事务的提交和回滚。

5）PROPAGATION_NOT_SUPPORTED ，这个也可以从字面得知，not supported ，不支持，当前级别的特点就是上下文中存在事务，则挂起事务，执行当前逻辑，结束后恢复上下文的事务。

这个级别有什么好处？可以帮助你将事务极可能的缩小。我们知道一个事务越大，它存在的风险也就越多。所以在处理事务的过程中，要保证尽可能的缩小范围。比如一段代码，是每次逻辑操作都必须调用的，比如循环1000次的某个非核心业务逻辑操作。这样的代码如果包在事务中，势必造成事务太大，导致出现一些难以考虑周全的异常情况。所以这个事务这个级别的传播级别就派上用场了。用当前级别的事务模板抱起来就可以了。

6）PROPAGATION_NEVER ，该事务更严格，上面一个事务传播级别只是不支持而已，有事务就挂起，而PROPAGATION_NEVER传播级别要求上下文中不能存在事务，一旦有事务，就抛出runtime异常，强制停止执行！这个级别上辈子跟事务有仇。

7）PROPAGATION_NESTED ，字面也可知道，nested，嵌套级别事务。该传播级别特征是，如果上下文中存在事务，则嵌套事务执行，如果不存在事务，则新建事务。

那么什么是嵌套事务呢？很多人都不理解，我看过一些博客，都是有些理解偏差。

嵌套是子事务套在父事务中执行，子事务是父事务的一部分，在进入子事务之前，父事务建立一个回滚点，叫save point，然后执行子事务，这个子事务的执行也算是父事务的一部分，然后子事务执行结束，父事务继续执行。重点就在于那个save point。看几个问题就明了了：

如果子事务回滚，会发生什么？

父事务会回滚到进入子事务前建立的save point，然后尝试其他的事务或者其他的业务逻辑，父事务之前的操作不会受到影响，更不会自动回滚。

如果父事务回滚，会发生什么？

父事务回滚，子事务也会跟着回滚！为什么呢，因为父事务结束之前，子事务是不会提交的，我们说子事务是父事务的一部分，正是这个道理。那么：

事务的提交，是什么情况？

是父事务先提交，然后子事务提交，还是子事务先提交，父事务再提交？答案是第二种情况，还是那句话，子事务是父事务的一部分，由父事务统一提交。

现在你再体会一下这个”嵌套“，是不是有那么点意思？

以上是事务的7个传播级别，在日常应用中，通常可以满足各种业务需求，但是除了传播级别，在读取数据库的过程中，如果两个事务并发执行，那么彼此之间的数据是如何影响的呢？

这就需要了解一下事务的另一个特性：数据隔离级别

数据隔离级别分为不同的四种：

1、Serializable ：最严格的级别，事务串行执行，资源消耗最大；

2、REPEATABLE READ ：保证了一个事务不会修改已经由另一个事务读取但未提交（回滚）的数据。避免了“脏读取”和“不可重复读取”的情况，但是带来了更多的性能损失。

3、READ COMMITTED :大多数主流数据库的默认事务等级，保证了一个事务不会读到另一个并行事务已修改但未提交的数据，避免了“脏读取”。该级别适用于大多数系统。

4、Read Uncommitted ：保证了读取过程中不会读取到非法数据。

上面的解释其实每个定义都有一些拗口，其中涉及到几个术语：脏读、不可重复读、幻读。
这里解释一下：

脏读 :所谓的脏读，其实就是读到了别的事务回滚前的脏数据。比如事务B执行过程中修改了数据X，在未提交前，事务A读取了X，而事务B却回滚了，这样事务A就形成了脏读。

不可重复读 ：不可重复读字面含义已经很明了了，比如事务A首先读取了一条数据，然后执行逻辑的时候，事务B将这条数据改变了，然后事务A再次读取的时候，发现数据不匹配了，就是所谓的不可重复读了。

幻读 ：小的时候数手指，第一次数十10个，第二次数是11个，怎么回事？产生幻觉了？
幻读也是这样子，事务A首先根据条件索引得到10条数据，然后事务B改变了数据库一条数据，导致也符合事务A当时的搜索条件，这样事务A再次搜索发现有11条数据了，就产生了幻读。

一个对照关系表：
                    Dirty reads     non-repeatable reads      phantom reads
Serializable             不会            不会                      不会
REPEATABLE READ       不会            不会                      会
READ COMMITTED       不会            会                        会
Read Uncommitted       会              会                        会

所以最安全的，是Serializable，但是伴随而来也是高昂的性能开销。
另外，事务常用的两个属性：readonly和timeout
一个是设置事务为只读以提升性能。
另一个是设置事务的超时时间，一般用于防止大事务的发生。还是那句话，事务要尽可能的小！

最后引入一个问题：
一个逻辑操作需要检查的条件有20条，能否为了减小事务而将检查性的内容放到事务之外呢？

很多系统都是在DAO的内部开始启动事务，然后进行操作，最后提交或者回滚。这其中涉及到代码设计的问题。小一些的系统可以采用这种方式来做，但是在一些比较大的系统，
逻辑较为复杂的系统中，势必会将过多的业务逻辑嵌入到DAO中，导致DAO的复用性下降。所以这不是一个好的实践。

来回答这个问题：能否为了缩小事务，而将一些业务逻辑检查放到事务外面？答案是：对于核心的业务检查逻辑，不能放到事务之外，而且必须要作为分布式下的并发控制！
一旦在事务之外做检查，那么势必会造成事务A已经检查过的数据被事务B所修改，导致事务A徒劳无功而且出现并发问题，直接导致业务控制失败。
所以，在分布式的高并发环境下，对于核心业务逻辑的检查，要采用加锁机制。
比如事务开启需要读取一条数据进行验证，然后逻辑操作中需要对这条数据进行修改，最后提交。
这样的一个过程，如果读取并验证的代码放到事务之外，那么读取的数据极有可能已经被其他的事务修改，当前事务一旦提交，又会重新覆盖掉其他事务的数据，导致数据异常。
所以在进入当前事务的时候，必须要将这条数据锁住，使用for update就是一个很好的在分布式环境下的控制手段。

一种好的实践方式是使用编程式事务而非生命式，尤其是在较为规模的项目中。对于事务的配置，在代码量非常大的情况下，将是一种折磨，而且人肉的方式，绝对不能避免这种问题。
将DAO保持针对一张表的最基本操作，然后业务逻辑的处理放入manager和service中进行，同时使用编程式事务更精确的控制事务范围。
特别注意的，对于事务内部一些可能抛出异常的情况，捕获要谨慎，不能随便的catch Exception 导致事务的异常被吃掉而不能正常回滚。

Spring配置声明式事务：

\* 配置DataSource
\* 配置事务管理器
\* 事务的传播特性
\* 那些类那些方法使用事务

Spring配置文件中关于事务配置总是由三个组成部分，分别是DataSource、TransactionManager和代理机制这三部分，无论哪种配置方式，一般变化的只是代理机制这部分。

  DataSource、TransactionManager这两部分只是会根据数据访问方式有所变化，比如使用Hibernate进行数据访问 时，DataSource实际为SessionFactory，TransactionManager的实现为 HibernateTransactionManager。

根据代理机制的不同，Spring事务的配置又有几种不同的方式：

第一种方式：每个Bean都有一个代理

 第二种方式：所有Bean共享一个代理基类

第三种方式：使用拦截器

第四种方式：使用tx标签配置的拦截器

第五种方式：全注解

1、spring事务控制放在service层，在service方法中一个方法调用service中的另一个方法，默认开启几个事务？

spring的事务传播方式默认是PROPAGATION_REQUIRED，判断当前是否已开启一个新事务，有则加入当前事务，否则新开一个事务（如果没有就开启一个新事务），所以答案是开启了一个事务。

2、spring 什么情况下进行事务回滚？

Spring、EJB的声明式事务默认情况下都是在抛出unchecked exception后才会触发事务的回滚

unchecked异常,即运行时异常runntimeException 回滚事务;

checked异常,即Exception可try{}捕获的不会回滚.当然也可配置spring参数让其回滚.

spring的事务边界是在调用业务方法之前开始的，业务方法执行完毕之后来执行commit or rollback(Spring默认取决于是否抛出runtime异常).
如果抛出runtime exception 并在你的业务方法中没有catch到的话，事务会回滚。
一般不需要在业务方法中catch异常，如果非要catch，在做完你想做的工作后（比如关闭文件等）一定要抛出runtime exception，否则spring会将你的操作commit,这样就会产生脏数据.所以你的catch代码是画蛇添足。





----

# 三、try catch 对事务的影响，[spring事务管理中，用try-catch处理了异常，事务也会回滚？][https://blog.csdn.net/C_AJing/article/details/106054265]

spring 的默认事务机制，当出现unchecked异常时候回滚，checked异常的时候不会回滚；

异常中unchecked异常包括error和runtime异常，需要try catch或向上抛出的异常为checked异常比如IOException，也就是说程序抛出runtime异常的时候才会进行回滚，其他异常不回滚，可以配置设置所有异常回滚： 

@Transactional(rollbackFor = { Exception.class }) 

当有try catch后捕获了异常，事务不会回滚，如果不得不在service层写try catch 需要catch后 throw new RuntimeException 让事务回滚； 

Spring的AOP即声明式事务管理**默认是针对unchecked exception回滚**。**也就是默认对RuntimeException()异常或是其子类进行事务回滚；checked异常,即Exception可try{}捕获的不会回滚，如果使用try-catch捕获抛出的unchecked异常后没有在catch块中采用页面硬编码的方式使用spring api对事务做显式的回滚，则事务不会回滚， “将异常捕获,并且在catch块中不对事务做显式提交=生吞掉异常”** ，要想捕获非运行时异常则需要如下配置





我们知道在平时的开发中，如果在事务方法中开发人员自己用try-catch处理了异常，那么spring aop就捕获不到异常信息，从而会导致spring不能对事务方法正确的进行管理，不能及时回滚错误信息。

下面用代码演示一下：

```java
@Override
@Transactional(rollbackFor = Exception.class)
public int doSaveUser() throws Exception {
    int result = 0;
    UserEntity u = new UserEntity();
    u.setUserSex("男");
    u.setUserName("AAA");
    try {
        result = userMapper.insertUser(u);
        int i = 1 / 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return result;
}
```

控制台报错：![在这里插入图片描述](Spring 事务的传播机制.assets/20200511145546432.png)

数据库：![在这里插入图片描述](Spring 事务的传播机制.assets/20200511145622666.png)



可以看到程序虽然报错了，但是事务并没有回滚，这就是由于我们自己处理了异常信息。

可是，只要是我们自己处理了异常，事务就一定不会回滚吗？答案是不一定的，下面用两段代码对比一下：

代码一：

```java
public class User2ServiceImpl implements User2Service {
    @Autowired
    private UserService userService;
    @Autowired
    private UserMapper userMapper;
    
@Override
@Transactional(rollbackFor = Exception.class)
public int doSaveUser() throws Exception {
    int result = 0;
    UserEntity u = new UserEntity();
    u.setUserSex("男");
    u.setUserName("小A");
    userMapper.insertUser(u);
    try {
        u.setUserName("小B");
        result = userService.insertUser(u); //此时调用的方法没有加事务
    } catch (Exception e) {
        e.printStackTrace();
    }
    return result;
}
}
```


```java
@Service
public class UserServiceImpl implements UserService {
@Autowired
private UserMapper userMapper;

@Override
public int insertUser(UserEntity user) throws Exception {
    int i = 1 / 0;
    return userMapper.insertUser(user);
}
}
```


异常信息：![在这里插入图片描述](Spring 事务的传播机制.assets/20200511150703518.png)

数据库：![在这里插入图片描述](Spring 事务的传播机制.assets/20200511150738370.png)



可以看到由于我们自己处理了保存小B时抛出的异常，事务方法没有受到影响，依然正常的保存了小A，并没有回滚事务。

代码二：



```java
@Service
public class User2ServiceImpl implements User2Service {
    @Autowired
    private UserService userService;
    @Autowired
    private UserMapper userMapper;
    
@Override
@Transactional(rollbackFor = Exception.class)
public int doSaveUser() throws Exception {
    int result = 0;
    UserEntity u = new UserEntity();
    u.setUserSex("男");
    u.setUserName("小C");
    userMapper.insertUser(u);		//将会回滚
    try {
        u.setUserName("小D");
        result = userService.insertUser(u); //此时调用的方法加上事务
    } catch (Exception e) {
        e.printStackTrace();
    }
    return result;
}
}
@Service
public class UserServiceImpl implements UserService {
@Autowired
private UserMapper userMapper;

@Override
@Transactional(rollbackFor = Exception.class, propagation = Propagation.REQUIRED)	//加入了上一个事务
public int insertUser(UserEntity user) throws Exception {
    int i = 1 / 0;
    return userMapper.insertUser(user);
}}
```

异常信息：![在这里插入图片描述](Spring 事务的传播机制.assets/20200511152435353.png)

此时数据库里面一条记录也没有，也就是是说doSaveUser()方法也进行了事务回滚，我们已经用try-catch处理了异常了，为什么还会事务回滚呢？

我们此时把insertUser方法稍微修改一下：

```java
   @Override
   @Transactional(rollbackFor = Exception.class, propagation = Propagation.REQUIRES_NEW)//新事务且抛出异常到上一事务，所以如果上层调用中如果不tryCatch则外层事务也会回滚
    public int insertUser(UserEntity user) throws Exception {
        int i = 1 / 0;
        return userMapper.insertUser(user);
    }

```

此时数据库多了一条记录：

![在这里插入图片描述](Spring 事务的传播机制.assets/20200511161126567.png)

这里，我**把spring事务传播机制从REQUIRED改成了REQUIRES_NEW，doSaveUser()方法就没有进行事务回滚了**，到这里你应该能猜到了，spring事务传播机制默认是REQUIRED，也就是说支持当前事务，如果当前没有事务，则新建事务，如果当前存在事务，则加入当前事务，合并成一个事务，当insertUser方法有事务且事务传播机制为REQUIRED时，会和doSaveUser()方法的事务合并成一个事务，此时insertUser方法发生异常，spring捕获异常后，事务将会被设置全局rollback，而最外层的事务方法执行commit操作，这时由于事务状态为rollback（内层事务为rollback，视为外层也rollback），spring认为不应该commit提交该事务，就会回滚该事务，这就是为什么doSaveUser()方法的事务也被回滚了。

下面我们再看一下spring的事务传播机制：

1.REQUIRED (默认)：支持当前事务，如果当前没有事务，则新建事务，如果当前存在事务，则加入当前事务，合并成一个事务，如果一个方法发生异常回滚，则整个事务回滚。

2.REQUIRES_NEW：新建事务，如果当前存在事务，则把当前事务挂起，这个方法会独立提交事务，不受调用者的事务影响，父级异常，它也是正常提交，但如果是此方法发生异常未被捕获处理，且异常满足父级事务方法回滚规则，则父级方法事务会被回滚。

3.NESTED：如果当前存在事务，它将会成为父级事务的一个子事务，方法结束后并没有提交，只有等父事务结束才提交，如果当前没有事务，则新建事务（此时，类似于REQUIRED ），如果它异常，它本身进行事务回滚，父级可以捕获它的异常而不进行回滚，正常提交，但如果父级异常，它必然回滚。

4.SUPPORTS：如果当前存在事务，则加入事务，如果当前不存在事务，则以非事务方式运行。

5.NOT_SUPPORTED：以非事务方式运行，如果当前存在事务，则把当前事务挂起。

6.MANDATORY：如果当前存在事务，则运行在当前事务中，如果当前无事务，则抛出异常，即父级方法（调用此方法的方法）必须有事务。

7.NEVER：以非事务方式运行，如果当前存在事务，则抛出异常，即父级方法必须无事务。



---

# 四、[spring事务传播行为之使用REQUIRES_NEW不回滚](https://www.cnblogs.com/whwei-blog/p/10708926.html)

最近写spring事务时用到REQUIRES_NEW遇到一些不回滚的问题,所以就记录一下。

## 场景1:由于同一个Service不同事务的嵌套会出现调用的对象不是代理对象的问题

在一个服务层里面方法1和方法2都加上事务,其中方法二设置上propagation=Propagation.REQUIRES_NEW,方法1调用方法2并且在执行完方法2后抛出一个异常，

如下代码

```java
@Service
public class BookServiceImpl implements BookService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional(timeout=4)
    public void update() {
        // TODO Auto-generated method stub
        //售卖  扣除库存数量
        String sellSql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
        //入账的sql  将赚到的钱添加到account表中的balance
        String addRmbSql = "UPDATE account SET balance = balance + ? * (SELECT price FROM book WHERE NAME = ?)";
        Object []params = {1,"Spring"};

        jdbcTemplate.update(sellSql, params);

        testUpdate();

        jdbcTemplate.update(addRmbSql, params);

        throw new RuntimeException("故意的一个异常");
    }
    @Transactional(propagation=Propagation.REQUIRES_NEW)
    public void testUpdate() {
        //这个业务没什么意义,只是用来测试REQUIRES_NEW的 当执行后SpringMVC这本书库存-1
        String sql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
        Object []params = {1,"SpringMVC"};
        jdbcTemplate.update(sql, params);

    }
```

![img](Spring 事务的传播机制.assets/1517282-20190415093348072-883208447.png)![img](Spring 事务的传播机制.assets/1517282-20190415093354909-2105527042.png)![img](Spring 事务的传播机制.assets/1517282-20190415093359254-1204944376.png)

三张表分别是对应account表,book表,book_stock表

```java
private static  ClassPathXmlApplicationContext ac = new ClassPathXmlApplicationContext("classpath:spring/*.xml");

    @Test
    public void testREQUIRES_NEW() {

        BookService bean = ac.getBean(BookService.class);

        bean.update();
    }
```

结果是无论是方法1还是方法2都回滚了,那么REQUIRES_NEW就不起作用了,为了探索原因我修改了一下代码

在第5行的地方打印出对象的类型是什么

```java
@Test
    public void testREQUIRES_NEW() {

        BookService bean = ac.getBean(BookService.class);
        System.out.println("update的调用者:"+bean.getClass());
        bean.update();
    }
```

在第11行的地方打印对象类型

```java
@Transactional(timeout=4)
    public void update() {
        // TODO Auto-generated method stub
        //售卖
        String sellSql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
        //入账的sql
        String addRmbSql = "UPDATE account SET balance = balance + ? * (SELECT price FROM book WHERE NAME = ?)";
        Object []params = {1,"Spring"};

        jdbcTemplate.update(sellSql, params);
        System.out.println("testUpdate的调用者:"+this.getClass());
        testUpdate();

        jdbcTemplate.update(addRmbSql, params);

        throw new RuntimeException("故意的一个异常");
    }
```

运行结果是

![img](Spring 事务的传播机制.assets/1517282-20190415132759939-353281249.png)

显然调用update的对象是一个代理对象,调用testUpdate的对象不是一个代理对象,这就是为什么添加REQUIRES_NEW不起作用，想要让注解生效就要用代理对象的方法，不能用原生对象的.

解决方法：在配置文件中添加标签<aop:aspectj-autoproxy  expose-proxy="true"></aop:aspectj-autoproxy>将代理暴露出来，使AopContext.currentProxy()获取当前代理

将代码修改为

```xml
  <!-- 开启事务注解 -->
<tx:annotation-driven transaction-manager="transactionManager"/>
<!-- 将代理暴露出来 -->
<aop:aspectj-autoproxy   expose-proxy="true"></aop:aspectj-autoproxy>
```

　　11 12行将this替换为((BookService)AopContext.currentProxy())

```java
@Transactional(timeout=4)
    public void update() {
        // TODO Auto-generated method stub
        //售卖
        String sellSql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
        //入账的sql
        String addRmbSql = "UPDATE account SET balance = balance + ? * (SELECT price FROM book WHERE NAME = ?)";
        Object []params = {1,"Spring"};

        jdbcTemplate.update(sellSql, params);
        System.out.println("testUpdate的调用者:"+((BookService)AopContext.currentProxy()).getClass());
        ((BookService)AopContext.currentProxy()).testUpdate();

        jdbcTemplate.update(addRmbSql, params);

        throw new RuntimeException("故意的一个异常");
    }
```

运行结果

调用的对象变成代理对象了 那么结果可想而知第一个事务被挂起,第二个事务执行完提交了 然后异常触发,事务一回滚 SpringMVC这本书库存-1,其他的不变

![img](Spring 事务的传播机制.assets/1517282-20190415134919004-1232686346.png)![img](Spring 事务的传播机制.assets/1517282-20190415135427399-2064061103.png)![img](Spring 事务的传播机制.assets/1517282-20190415135440514-539154623.png)![img](Spring 事务的传播机制.assets/1517282-20190415135446183-671010702.png)

我还看到过另一种解决方法 

**在第7行加一个BookService类型的属性并且给个set方法,目的就是将代理对象传递过来...  看26 27行显然就是用代理对象去调用的方法  所以就解决问题了  不过还是用第一个方案好**

```java
@Service
public class BookServiceImpl implements BookService {
@Autowired
private JdbcTemplate jdbcTemplate;

private BookService proxy;

public void setProxy(BookService proxy) {
    this.proxy = proxy;
}

@Transactional(timeout=4)
public void update() {
    // TODO Auto-generated method stub
    //售卖
    String sellSql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
    //入账的sql
    String addRmbSql = "UPDATE account SET balance = balance + ? * (SELECT price FROM book WHERE NAME = ?)";
    Object []params = {1,"Spring"};

    jdbcTemplate.update(sellSql, params);
/*    System.out.println("testUpdate的调用者:"+((BookService)AopContext.currentProxy()).getClass());
    ((BookService)AopContext.currentProxy()).testUpdate();*/

    System.out.println(proxy.getClass());
    proxy.testUpdate();

    jdbcTemplate.update(addRmbSql, params);

    throw new RuntimeException("故意的一个异常");
}
```

OK这个问题解决那就下一个

## 场景2:在一个服务层里面方法1和方法2都加上事务,其中方法二设置上propagation=Propagation.REQUIRES_NEW,方法1调用方法2并且在执行方法2时抛出一个异常 

  没注意看是不是觉得两个场景是一样的,因为我是拷贝下来改的...  差别就是在哪里抛出异常 这次是在方法2里面抛出异常, 我将代码还原至场景1的第一个解决方案，然后在方法2里面抛出异常 代码如下

```java
@Service
public class BookServiceImpl implements BookService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional(timeout=4)
    public void update() {
        // TODO Auto-generated method stub
        //售卖
        String sellSql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
        //入账的sql
        String addRmbSql = "UPDATE account SET balance = balance + ? * (SELECT price FROM book WHERE NAME = ?)";
        Object []params = {1,"Spring"};

        jdbcTemplate.update(sellSql, params);

        System.out.println("testUpdate的调用者:"+((BookService)AopContext.currentProxy()).getClass());
        ((BookService)AopContext.currentProxy()).testUpdate();

        jdbcTemplate.update(addRmbSql, params);

    }
    @Transactional(propagation=Propagation.REQUIRES_NEW)
    public void testUpdate() {
        //这个业务没什么意义,只是用来测试REQUIRES_NEW的
        String sql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
        Object []params = {1,"SpringMVC"};
        jdbcTemplate.update(sql, params);

        throw new RuntimeException("在方法二里面抛出一个异常");
    }
```

预期结果是testUpdate这个事务是要回滚的,update这个方法的事务正常执行,所以数据库的变化是balance字段的钱要+60 Spring这本书的库存-1,但是结果是数据库完全没有变化

![img](Spring 事务的传播机制.assets/1517282-20190415142309176-1918521429.png)![img](Spring 事务的传播机制.assets/1517282-20190415142314507-2120358464.png)![img](Spring 事务的传播机制.assets/1517282-20190415142318916-1373417599.png)

分析:在testUpdate方法内抛异常被spring aop捕获,捕获后异常又被抛出,那么异常抛出后,是不是update方法没有手动捕获,而是让spring aop自动捕获,所以在update方法内也捕获到了异常,因此都回滚了

这张图片的代码是我debug模式下 在testUpdate方法中执行到抛出异常的地方 再点step over 跳到的地方  **==显然spring aop捕获到了异常后,再次抛出（抛出到了上层调用处）==**,**这就是为什么update方法会捕获到异常**

 ![img](Spring 事务的传播机制.assets/1517282-20190415144440642-1289805084.png)

OK问题很简单  解决方案也很简单  **==只需要手动捕获该异常,不让spring aop捕获就OK了==**

将update方法改为

```java
@Transactional(timeout=4)
    public void update() {
        // TODO Auto-generated method stub
        //售卖
        String sellSql = "UPDATE book_stock SET stock = stock - ? WHERE isbn = (SELECT isbn FROM book WHERE NAME = ?)";
        //入账的sql
        String addRmbSql = "UPDATE account SET balance = balance + ? * (SELECT price FROM book WHERE NAME = ?)";
        Object []params = {1,"Spring"};

        jdbcTemplate.update(sellSql, params);

        try {
            System.out.println("testUpdate的调用者:"+((BookService)AopContext.currentProxy()).getClass());
            ((BookService)AopContext.currentProxy()).testUpdate();
        } catch (RuntimeException e) {
            // TODO Auto-generated catch block
            System.out.println(e.getMessage());
            e.printStackTrace();
        }

        jdbcTemplate.update(addRmbSql, params);

    }
```

执行结果  update执行成功  testUpdate回滚

![img](Spring 事务的传播机制.assets/1517282-20190415145655172-619078964.png)![img](Spring 事务的传播机制.assets/1517282-20190415145658522-2033614985.png)![img](Spring 事务的传播机制.assets/1517282-20190415145701971-239992116.png)![img](Spring 事务的传播机制.assets/1517282-20190415145705312-1570682782.png)

##  总结

1. ==**同一个Service不同事务的嵌套会出现调用的对象不是代理对象的问题,如果是多个不同Service的不同事务嵌套就没有这个问题。**==
2. ==**场景2的要记得手动捕获异常,不然全回滚了.至于为什么调用testUpdate方法的对象不是代理对象,可能还要看源码**==





----

# 五、[REQUIRES_NEW不起作用导致整个事务回滚——Spring事务传播机制](https://blog.csdn.net/L_BestCoder/article/details/80176034)

1、Propagation.REQUIRES_NEW的作用
假设有个对象A，有a()方法，有个对象B，有b()方法。在a方法中调用了b方法，b方法被称为内嵌事务，不管a方法是否开启事务，只要b方法的事务的隔离级别为REQUIRES_NEW，则一定会在调用b方法时产生一个新的事务。

2、一个场景
A的a()方法：

```java
@Transactional
public void a() {
    doSomething4A();
    B.b();//可能会抛出运行时异常
}
```

内嵌在A中的B.b()方法：

```java
@Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = RuntimeException.class)
@Override
public void b() {
    doSomething4B();
    throw new RuntimeException();//故意抛出运行时异常，观察两个事务的回滚情况
}
```

在这时你肯定会想，doSomething4A会执行成功，而doSomething4B会回滚，因为我们的内嵌事务b方法的隔离级别是REQUIRES_NEW，这个方法是在一个新的事务中，回滚之后不会影响外部事务。

错错错！

事实上的运行结果是两个事务都回滚了！为什么？难道是REQUIRES_NEW失效了？

不是！仔细观察这段代码，**b方法抛出异常后，并没有显示捕获，而是抛到了a方法里，a方法执行中遇到了运行时异常，也回滚了**！所以b方法正确的写法应该是这样的：

```java
@Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = RuntimeException.class)
@Override
public void b() {
    try {
        doSomething4B();
        throw new RuntimeException();//故意抛出运行时异常，观察两个事务的回滚情况
    }catch (Exception e){
        //异常处理,但捕获后也要向上抛出才能回滚此事务
    }
}


//另一更好的解决办法是在b正常抛出回滚，a中catch后不回滚a（前提b是不和a同事务，如果b事务加入了a事务则catch了b也会回滚a）
@Transactional
public void a() {
    doSomething4A();
    try{
         B.b();//可能会抛出运行时异常
    }catch(Exception e){
        //
    }
}
```

这样写后，REQUIRES_NEW就能起到这个作用啦！



----



# 六、[Java异常类][https://blog.csdn.net/michaelgo/article/details/82790253]

一、异常实现及分类
1.先看下异常类的结构图

![img](Spring 事务的传播机制.assets/70.png)

上图可以简单展示一下异常类实现结构图，当然上图不是所有的异常，用户自己也可以自定义异常实现。上图已经足够帮我们解释和理解异常实现了：

1.所有的异常都是从Throwable继承而来的，是所有异常的共同祖先。

2.Throwable有两个子类，Error和Exception。其中Error是错误，对于所有的编译时期的错误以及系统错误都是通过Error抛出的。这些错误表示故障发生于虚拟机自身、或者发生在虚拟机试图执行应用时，如Java虚拟机运行错误（Virtual MachineError）、类定义错误（NoClassDefFoundError）等。这些错误是不可查的，因为它们在应用程序的控制和处理能力之 外，而且绝大多数是程序运行时不允许出现的状况。对于设计合理的应用程序来说，即使确实发生了错误，本质上也不应该试图去处理它所引起的异常状况。在 Java中，错误通过Error的子类描述。

3.Exception，是另外一个非常重要的异常子类。它规定的异常是程序本身可以处理的异常。异常和错误的区别是，异常是可以被处理的，而错误是没法处理的。 

4.Checked Exception

可检查的异常，这是编码时非常常用的，所有checked exception都是需要在代码中处理的。它们的发生是可以预测的，正常的一种情况，可以合理的处理。比如IOException，或者一些自定义的异常。除了RuntimeException及其子类以外，都是checked exception。

5.Unchecked Exception

RuntimeException及其子类都是unchecked exception。比如NPE空指针异常，除数为0的算数异常ArithmeticException等等，这种异常是运行时发生，无法预先捕捉处理的。Error也是unchecked exception，也是无法预先处理的。

