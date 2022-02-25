# [mybatis 中的 update 返回值你真的明白吗][https://www.jianshu.com/p/80270b93082a]

如果定义一个如下的`update`函数，那么这个函数的返回值到底是啥意思呢？是受影响的行数吗？

![img](https:////upload-images.jianshu.io/upload_images/1987914-c00407eb8855286f.png?imageMogr2/auto-orient/strip|imageView2/2/w/633/format/webp)

函数定义

验证之前我们先看看数据库中的数据记录。总共两条数据记录！

![img](https:////upload-images.jianshu.io/upload_images/1987914-c1c579072a0fc78b.png?imageMogr2/auto-orient/strip|imageView2/2/w/271/format/webp)

数据记录

数据库链接配置为：



```cpp
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/ssm
jdbc.username=root
jdbc.password=123456
```

下面看看我们的单元测试类。



![img](https:////upload-images.jianshu.io/upload_images/1987914-27b65c70072c499c.png?imageMogr2/auto-orient/strip|imageView2/2/w/538/format/webp)

单元测试类

我们根据 ID 获取记录，然把用户名由 root 改为 root001。如果说返回值是影响的行数的话，那么应该返回 1.跟我们的预期结果 1 是相符的。单元测试会通过。

![img](https:////upload-images.jianshu.io/upload_images/1987914-7b69bb9971ab44e8.png?imageMogr2/auto-orient/strip|imageView2/2/w/1000/format/webp)

单元测试通过

单元测试通过，我们看看数据库中的记录有没有变化。

![img](https:////upload-images.jianshu.io/upload_images/1987914-1bf2e6d49949dcc5.png?imageMogr2/auto-orient/strip|imageView2/2/w/296/format/webp)

数据库记录

看起来貌似没有任何问题。单元测试通过，数据库的确是只有一条记录更改了。这说明 mybatis 的 update 操作返回值的确是受影响的行数。

**真的是这样吗**

我们知道当数据库中的记录被修改之后，我们在次执行相同的 update 语句将不会影响到数据记录行数。

![img](https:////upload-images.jianshu.io/upload_images/1987914-736e8c546fc62403.png?imageMogr2/auto-orient/strip|imageView2/2/w/708/format/webp)

按照这个逻辑来讲的话，在此执行此单元测试，返回值应该为 0，跟我们的预期值 1 不同，单元测试应该不通过。再次运行单元测试：

![img](https:////upload-images.jianshu.io/upload_images/1987914-7edea70011953f86.png?imageMogr2/auto-orient/strip|imageView2/2/w/1009/format/webp)

单元测试通过

我去，单元测试居然神奇般的通过了。。。请注意看，我们在命令行执行 update 语句那张图，返回的 matched 数量为 1。所以默认情况下，==mybatis 的 update 操作的返回值是 matched 的记录数（即符合where 条件找到的数据条数，这里找到了一条id = 1的数据），并不是受影响的记录数。==

==严格意义上来将，这并不是 mybatis 的返回值，mybatis 仅仅只是返回的数据库连接驱动（通常是 JDBC ）的返回值，也就是说，如果驱动告知更新 2 条记录受影响，那么我们将得到 mybatis 的返回值就会是 2 和 mybatis 本身是没有关系的。== [https://www.cnblogs.com/jpfss/p/8918315.html]

那么有没有办法让 mybatis 的 update 操作的返回值是受影响的行数呢。因为我们业务逻辑中有时会根据这个返回值做业务判断。答案当然是有的。
 修改数据库链接配置为：增加了 useAffectedRows 字段信息。



```ruby
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/ssm?useAffectedRows=true
jdbc.username=root
jdbc.password=123456
```

再次运行单元测试：

![img](https:////upload-images.jianshu.io/upload_images/1987914-60dfe3b77fda04ad.png?imageMogr2/auto-orient/strip|imageView2/2/w/993/format/webp)

单元测试失败

从报错信息可以清晰的看出，返回值是 0，跟我们的预期值 1 不同。



---



# [Mybatis执行Update返回行数为负数][https://blog.csdn.net/accountwcx/article/details/48025959]

获取mybatis的update行数，总是返回负数。后来在官网上找到原因，是由于defaultExecutorType的引起的，defaultExecutorType有三个执行器SIMPLE、REUSE和BATCH。其中BATCH可以批量更新操作缓存SQL以提高性能，但是有个缺陷就是无法获取update、delete返回的行数。defaultExecutorType的默认执行器是SIMPLE。

名称	描述
SIMPLE	执行器执行其它语句
REUSE	可能重复使用prepared statements 语句
BATCH	可以重复执行语句和批量更新


由于项目配置中启用了BATCH执行器，UPDATE和DELETE返回的行数就丢失了，把执行器改为SIMPLE即可。

```
<?xml version="1.0" encoding="UTF-8" ?> 

<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <!-- 全局映射器启用缓存 -->
        <setting name="cacheEnabled" value="true" />
        <!-- 查询时，关闭关联对象即时加载以提高性能 -->
        <setting name="lazyLoadingEnabled" value="true" />
        <!-- 设置关联对象加载的形态，此处为按需加载字段(加载字段由SQL指 定)，不会加载关联表的所有字段，以提高性能 -->
        <setting name="aggressiveLazyLoading" value="false" />
        <!-- 对于未知的SQL查询，允许返回不同的结果集以达到通用的效果 -->
        <setting name="multipleResultSetsEnabled" value="true" />
        <!-- 允许使用列标签代替列名 -->
        <setting name="useColumnLabel" value="true" />
        <!-- 允许使用自定义的主键值(比如由程序生成的UUID 32位编码作为键值)，数据表的PK生成策略将被覆盖 -->
        <setting name="useGeneratedKeys" value="true" />
        <!-- 给予被嵌套的resultMap以字段-属性的映射支持 -->
        <setting name="autoMappingBehavior" value="FULL" />
        <!-- 对于批量更新操作缓存SQL以提高性能 -->
        <!-- defaultExecutorType设置为BATCH有个缺陷就是无法获取update、delete返回的行数 -->
        <!-- <setting name="defaultExecutorType" value="BATCH" />-->
        <!-- 数据库超过25000秒仍未响应则超时 -->
        <setting name="defaultStatementTimeout" value="25000" />
        <!-- 日志 -->
        <!-- <setting name="logImpl" value="SLF4J"/> -->
    </settings>


    <!-- 注册mybatis插件 -->
    <plugins>
        <!-- mysql分页插件 -->
        <plugin interceptor="com.rvho.mybatis.interceptor.MybatisPageInterceptor">
            <property name="databaseType" value="mysql"/>
        </plugin>
    </plugins>

</configuration>
```



# [mysql update返回负数_Mybatis 更新时返回值是负数，但数据更新成功问题分析解决...][https://blog.csdn.net/weixin_39820588/article/details/113296092]

今天碰到一个问题：mybatis 更新时。虽然数据更新成功了，但是返回值是负数(-2147482646)，影响了到了程序里面业务的进行，经过分析查阅测试，做如下总结：

Mybatis 内置的 ExecutorType 有3种

SIMPLE [默认]，

BATCH

REUSE

SimpleExecutor ： 该模式下每执行一次update或select，就开启一个Statement对象，用完立刻关闭Statement对象。(可以是Statement或PrepareStatement对象)。

BatchExecutor ： 执行update(没有select，JDBC批处理不支持select)，将所有sql都添加到批处理中(addBatch())，等待统一执行(executeBatch())，它缓存了多个Statement对象，每个Statement对象都是addBatch()完毕后，等待逐一执行executeBatch()批处理的；BatchExecutor相当于维护了多个桶，每个桶里都装了很多属于自己的SQL，就像苹果蓝里装了很多苹果，番茄蓝里装了很多番茄，最后，再统一倒进仓库。(可以是Statement或PrepareStatement对象)。

ReuseExcutor ： 执行update或select，以sql作为key查找Statement对象，存在就使用，不存在就创建，用完后，不关闭Statement对象，而是放置于Map内，供下一次使用。(可以是Statement或PrepareStatement对象)。

原因分析：返回负数，是由于org.mybatis.spring.SqlSessionTemplate类 中的ExecutorType 设置的引起的，检查下自己的SqlSessionTemplate bean 配置是不是配置成了 BATCH，如果是请继续往下看。

解决方式：

在 Spring 配置文件中，做如下修改

另外提一点：

在默认情况下，mybatis 的 update 操作返回值是记录的 matched 的条数，并不是影响的记录条数。mybatis 仅仅只是返回的数据库连接驱动(通常是 JDBC )的返回值，也就是说返回值并不一定是受影响的数据条数。

我们可以通过对 JDBC URL 显式的指定 useAffectedRows 选项，我们将可以得到受影响的记录的条数：

jdbc:mysql://${jdbc.host}/${jdbc.db}?useAffectedRows=true

例如：

jdbc:mysql://localhost:3306/test?useAffectedRows=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&useSSL=false