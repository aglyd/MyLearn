# 一、[MySql读写分离是怎么实现的](https://zhuanlan.zhihu.com/p/343377249)

1. 主从复制：主数据库有写操作，从数据库自动同步。从数据库通过I/O线程去请求主数据库的binlog日志文件（二进制日志，包含SQL的增删改查等，用来做备份恢复等），并写到中继日志中，SQL线程会读取中继日志，并解析成具体操作同步数据到从数据库。

2. 读写分离：数据库层面：主数据库复制写，从数据库复制读。软件（代码）层面：通过读写分离中间间，比如MyCat、shardingsphere等实现。

## 具体实现

### 数据库层面

#### 　　1. 需要打开主库的二进制日志功能，通过配置文件修改。

（1）服务器ID命名

![img](https://pic1.zhimg.com/80/v2-2f19d0d25e8458b115a315edd91a8d48_720w.png)

（2）日志功能开启

![img](https://pic2.zhimg.com/80/v2-21e326ddcb1fc4f361f2ff0f583f0b01_720w.png)

修改完后，重启sql服务，通过命令查看日志状态

![img](https://pic1.zhimg.com/80/v2-6626872ac4ebe70a0ebb917680e96ae8_720w.jpg)



（3）创建一个用户，并赋予replication slave权限。

![img](https://pic1.zhimg.com/80/v2-f34d299e1881bae8d9fc178b356720a8_720w.png)



#### 　　2. 从库设置

（1）服务命名

![img](https://pic3.zhimg.com/80/v2-0dbb2694267c5305add607327d7a326e_720w.png)

（2）配置相关参数，重启服务

![img](https://pic4.zhimg.com/80/v2-f7d716e1fbd2ac0d21de5b9f0cf71157_720w.jpg)

（3）连接主机，执行同步命令

![img](https://pic4.zhimg.com/80/v2-d33d8d0fab6f07038880992bc77a1d97_720w.jpg)

### 代码程序层面

这里使用shardingsphere实现读写分离。

（1）相关jar引用

![img](https://pic3.zhimg.com/80/v2-18cec6b94e6854bebab2530bbc4a21d2_720w.jpg)

（2）读写分离配置

![img](https://pic3.zhimg.com/80/v2-801d986cc54af4d9a745506f665ac3de_720w.jpg)





-----



# 二、[高性能系统的读写分离怎么做？](https://zhuanlan.zhihu.com/p/86108084)

## **为什么要读写分离？**

我们先来看一个典型的读写分离架构图，如下：

![img](https://pic1.zhimg.com/80/v2-97db838b37e7b90f85a91851ab846f5c_720w.jpg)

这个架构图阐述了读写分离的标准常见，从主库写入，从库来读取，这种实现是在单机房场景下，我们再来演化一下，如果在多机房场景下又是怎样的呢？

![img](https://pic2.zhimg.com/80/v2-2f572e02eddb0aea6ecfb0be7e5cca19_720w.jpg)

多机房场景下还是一个主库，只是在另外一个机房多出了另外的一些从库，并且写入是直接跨机房连接到主库写入。

从以上两种类型的架构图，我们可以分析出如下几个使用读写分离的原因：

1、读写量很大，为了提升数据库读写性能，将读写进行分离；

2、多机房下如果写少读多，同时基于数据一致性考虑，只有一个主库存入所有的数据写入，本地再做从库提供读取，减少多机房间直接读取带来的时延。

## **读写分离实现方案**

如果要实现读写分离，我们首先就需要知道从业务层到数据库中间会有经过哪几层，了解了这几层，我们的思路就是分别从这些层去实现读写分离，这样就构成了我们不同的实现方案，对于语言我们选择Java来进行分析，其它的类似。

![img](https://pic1.zhimg.com/80/v2-365a54eaeee5ea6820feefb32b0bced0_720w.jpg)

这个图是从开发者的视角来看的，我们可以看出，从Service层一直到数据库，它会经历Dao（数据访问层）、JDBC(Java的数据库连接层)、DataSource(数据源)，那我们就从这三个层次分别来介绍它的方案实现。

### **DAO层**

在这一层做读写分离，很容易想到的方案就是初始化两个ORM操作，一个做读，另外一个做写，然后依据业务对数据库操作属性调用相应的ORM，我们举一个简单的例子来看下，例如一个Sample数据表，里面包含：id、名称、状态和创建时间几个字段，我们的例子主要包含：新增、获取、更新及获取操作，看看里面是怎么实现读写分离的（其中的JDBC采取了Spring的JdbcTemplate来实现，这里不做过多代码展示，如有疑问大家可以先查看JdbcTemplate相关技术介绍）

```java
@Repository
public class DaoImpl implements DaoInterFace {
	
	//读数据库连接
	@Autowired
	private Jdbc readJdbc;
	
	//写数据库连接
	@Autowired
	private Jdbc writeJdbc;

	@Override
	public boolean add(String appId, String name) {
		StringBuilder sql = new StringBuilder();
		sql.append(" insert into sample(app_id, name, status, create_time");
		sql.append(" values (?,?,?,?) ");
		
		StatementParameter param = new StatementParameter();
		param.setString(appId);
		param.setString(name);
		param.setBool(true);
		param.setDate(new Date());
		
		return writeJdbc.insertForBoolean(sql.toString(), param);
	}
	
	@Override
	public Sample get(long appId) {
		StringBuilder sql = new StringBuilder();
		sql.append(" select * from sample where app_id = ? ");
		
		StatementParameter param = new StatementParameter();
		param.setLong(appId);
	
		return readJdbc.query(sql.toString(), Sample.class, param);
	}

	@Override
	public Sample updateAndGet(String appId, boolean status) {
		StringBuilder writeSql = new StringBuilder();
		sql.append(" update sample set status = ? where id = ? and app_id = ?");
		
		StatementParameter readParam = new StatementParameter();
		readParam.setBool(status);
		readParam.setString(appId);
		
		writeJdbc.updateForBoolean(writeSql.toString(), readParam);
		
		StringBuilder readSql = new StringBuilder();
		sql.append(" select * from sample where app_id = ? ");
		
		StatementParameter readParam = new StatementParameter();
		readParam.setLong(appId);
		//读写窗口一致性，仍然需要采取写入Jdbc来进行读取，以防读库还没有同步到主库的数据
		return writeJdbc.query(readSql.toString(), Sample.class, readParam);
	}
} 
```

例子新建两个数据库连接JDBC，并且由业务实现人员来明确指定使用哪个JDBC来进行操作数据库，当写入后再读取的场景要保障都使用写入JDBC来实现。这个方案的优缺点我们总结如下：

优点：易于实现

缺点：1、侵入业务，每个数据操作层都需要额外考虑读写分离；

2、对于读写窗口一致性要求操作者自行实现，考虑不周就会导致数据读取失败。

### **JDBC层**

由于DAO层的做法对业务侵入很大，读写分离都需要业务方自行实现，对业务实现方有一定的要求，如果处理不当还有可能出现错误读取，那么我们考虑既然读写分离是一种公共的技术诉求，是否可以再到上面一层做一个封装，将这些内部实现全部封装起来，业务调用方仍然只需关注一个链接，具体里面什么时候读写分离，内部自行实现。这就是JDBC层实现读写分离的价值了，我们先看下它的架构图。

![img](https://pic1.zhimg.com/80/v2-6dbff5ab1ae7f17493837e9a74f6ac44_720w.jpg)

从架构图可以看出，需要将JDBC层的接口函数进行重写，会有一个对业务层暴露的JDBCProxy，它通过读写决策器进行选择此时是使用读还是写连接，JDBCWriter以及JDBCReader都是对JDBC接口的一个实现。我们来看下这种方案的几个重要实现类和方法：

```java
public class JdbcProxyImpl implements Jdbc {
	private final static Logger logger = LoggerFactory
			.getLogger(JdbcProxyImpl.class);
	
	//读写JDBC实现
	private JdbcReaderImpl jdbcReaderImpl;
	private JdbcWriterImpl jdbcWriterImpl;
	
	public void setJdbcReaderImpl(JdbcReaderImpl jdbcReaderImpl) {
		this.jdbcReaderImpl = jdbcReaderImpl;
	}

	public void setJdbcWriterImpl(JdbcWriterImpl jdbcWriterImpl) {
		this.jdbcWriterImpl = jdbcWriterImpl;
	}
	
	//更新的时候首先需要标记为写入，再调用写JDBC来实现更新
    @Override
	public int update(String sql) {
		ReadWriteDataSourceDecision.markWrite();
		return jdbcWriterImpl.update(sql);
	}

    //查询的时候首先是要判断在当前线程下是否有写入操作，如果有就直接使用写JDBC来读取，否则才使用读JDBC
	@Override
	public <T> T query(String sql, Class<T> elementType) {
		if(ReadWriteDataSourceDecision.isChoiceWrite()){
			return jdbcWriterImpl.query(sql, elementType);
		}
		return jdbcReaderImpl.query(sql, elementType);
	}
	
	//事务提交属于写入操作属性
	@Override
	public boolean commit() {
		return jdbcWriterImpl.commit();
	}
}
```

对于查询操作时会从ReadWriteDataSourceDecision（读写决策器中进行判断），那么读写决策器如何来保存当前线程下的读写操作呢？

```java
public class ReadWriteDataSourceDecision {
	public enum DataSourceType {
        write, read;
    }
	
	//所有读写操作的标记会被记录在这里ThreadLocal，线程安全的
    private static final ThreadLocal<DataSourceType> holder = new ThreadLocal<DataSourceType>();

    public static void markWrite() {
        holder.set(DataSourceType.write);
    }
    
    public static void markRead() {
        holder.set(DataSourceType.read);
    }
    
    public static void reset() {
        holder.set(null);
    }
    
    public static boolean isChoiceNone() {
        return null == holder.get(); 
    }
    
    public static boolean isChoiceWrite() {
        return DataSourceType.write == holder.get();
    }
    
    public static boolean isChoiceRead() {
        return DataSourceType.read == holder.get();
    }
}
```

从源码我们可以看出这里有一个比较巧妙的设计，那就是采取了ThreadLocal来存储当前线程下的读写属性，它可以识别出当前线程操作下是否有写入操作，如果有就直接使用写入JDBC来进行读取，保障了读写窗口的一致性。

### **DataSource层**

JDBC层可以很好的解决侵入性以及窗口一致性问题，但是我们在配置的时候仍然是需要为proxy配置两个JDBC，相应的参数都需要完整的设置一遍，还是会比较麻烦，程序猿的使命就是追究极简，有没有我只需要告诉它读写分离的JDBCurl，剩下的一个组件内部全部搞定呢？另外如果主从复制时延较大，如果当前线程是纯读取，也要看是否时延超过了容忍阈值，如果超过了则仍然需要强制从主库读取，这就是我们现在要介绍的dataSource层的方案了。

![img](https://pic1.zhimg.com/80/v2-61e875b3d02cbc29cfd6addd6743ecd0_720w.jpg)

**读写分离**：通过实现dataSorce的connection以及statement，当jdbc请求执行sql时会首先获取connection，通过解析sql判断是查询还是更新来选择连接池的读写连接类型，同时需要结合主从复制检测的结果进行综合判断来实现读写连接分离。而读写的链接都是从读写的dataSorce中获取。

**读写窗口一致性**：通过重写dataSource的connection，如果当前连接已经存在写连接请求就强制采用写连接。

**主从复制时延智能切换**：通过启动单线程检测master与slave数据是否存在时延，来决策系统主从是否存在时延，如果存在时延强制系统本次执行主库查询。

我们看下connection里面几个重要方法的实现：

```java
public PreparedStatement prepareStatement(String sql, int resultSetType,
			int resultSetConcurrency) throws SQLException {
		//通过sql解析是否是读请求，并且时延没有超过指定阈值，则请求读连接，否则取写连接
		if (SqlUtil.isReadRequest(sql) && !datasource.getMdsm().isDelay()) {
            return getReadConnection().prepareStatement(sql, resultSetType, resultSetConcurrency);
        } else {
            return getWriteConnection().prepareStatement(sql, resultSetType, resultSetConcurrency);
        }
	}
```

而getReadConnection的方法逻辑如下：

```java
Connection getReadConnection() throws SQLException {
	        if (writeConn != null) {
	         // 如果是读数据，并且已有写连接，那么强制返回这个写链接。
	            return writeConn;
	        }

	        if (readConn != null) {
	            return readConn;
	        } else {
	            readConn = datasource.getReadConnection(username, password);
	        }
	        return readConn;
	    }
```

我们从开发者视角来阐述了基于DAO/JDBC以及dataSource的三个读写分离方案，各有优势，大家可以按需自行选择对应方案在业务中实现读写分离。





-----

# 三、[读写分离实现方式](https://www.cnblogs.com/tilamisu007/p/9360664.html)

引用：https://blog.csdn.net/zbw18297786698/article/details/54343188

​      https://blog.csdn.net/jack85986370/article/details/51559232

​      http://www.cnblogs.com/boothsun/p/7454901.html

很多大型网站，所处理的业务中，有大约70%是查询（select）相关的业务操作，而剩下的30%是写操作（insert、delete、update），故可使用读写分离的方式提升数据库的负载能力。

将所有的查询处理都放到从服务器上，写处理放在主服务器。

## 一、使用Spring基于应用层实现

![img](https://images2018.cnblogs.com/blog/1396730/201807/1396730-20180724145811993-1434977379.png)

在进入Service之前，使用AOP来做出判断，是使用写库还是读库，判断依据可以根据方法名判断，比如说以query、find、get等开头的就走读库，其他的走写库。

### 继承AbstractRoutingDataSource实现动态数据源切换

#### mybatis配置文件

```xml
<bean id="masterDataSource" class="com.alibaba.druid.pool.DruidDataSource" init-method="init" destroy-method="close">
        <!-- 基本属性 url、user、password -->
        <property name="url" value="${jdbc.url}" />
        <property name="username" value="${jdbc.username}" />
        <property name="password" value="${jdbc.password}" />

        <!-- 配置初始化大小、最小、最大 -->
        <property name="initialSize" value="1" />
        <property name="minIdle" value="1" />
        <property name="maxActive" value="20" />

        <!-- 配置获取连接等待超时的时间 -->
        <property name="maxWait" value="60000" />

        <!-- 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒 -->
        <property name="timeBetweenEvictionRunsMillis" value="60000" />

        <!-- 配置一个连接在池中最小生存的时间，单位是毫秒 -->
        <property name="minEvictableIdleTimeMillis" value="300000" />

        <property name="validationQuery" value="SELECT 'x'" />
        <property name="testWhileIdle" value="true" />
        <property name="testOnBorrow" value="false" />
        <property name="testOnReturn" value="false" />

        <!-- 打开PSCache，并且指定每个连接上PSCache的大小 -->
        <property name="poolPreparedStatements" value="true" />
        <property name="maxPoolPreparedStatementPerConnectionSize" value="20" />
</bean>

<bean id="slaveDataSource" class="com.alibaba.druid.pool.DruidDataSource" init-method="init" destroy-method="close">
    <!-- 基本属性 url、user、password -->
    <property name="url" value="${jdbc.r.url}" />
    <property name="username" value="${jdbc.r.username}" />
    <property name="password" value="${jdbc.r.password}" />

    <!-- 配置初始化大小、最小、最大 -->
    <property name="initialSize" value="1" />
    <property name="minIdle" value="1" />
    <property name="maxActive" value="20" />

    <!-- 配置获取连接等待超时的时间 -->
    <property name="maxWait" value="60000" />

    <!-- 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒 -->
    <property name="timeBetweenEvictionRunsMillis" value="60000" />

    <!-- 配置一个连接在池中最小生存的时间，单位是毫秒 -->
    <property name="minEvictableIdleTimeMillis" value="300000" />

    <property name="validationQuery" value="SELECT 'x'" />
    <property name="testWhileIdle" value="true" />
    <property name="testOnBorrow" value="false" />
    <property name="testOnReturn" value="false" />

    <!-- 打开PSCache，并且指定每个连接上PSCache的大小 -->
    <property name="poolPreparedStatements" value="true" />
    <property name="maxPoolPreparedStatementPerConnectionSize" value="20" />
</bean>

<bean id="dynamicDataSource" class="com.boothsun.util.datasource.DynamicDataSource">
    <property name="targetDataSources">
        <map key-type="java.lang.String">
            <!-- write -->
            <entry key="master" value-ref="masterDataSource"/>
            <!-- read -->
            <entry key="slave" value-ref="slaveDataSource"/>
        </map>
    </property>
    <property name="defaultTargetDataSource" ref="masterDataSource"/>
</bean>

<!-- MyBatis配置 -->
<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
    <property name="dataSource" ref="dynamicDataSource"/>	<!-- 放入数据源为动态数据源 -->
    <!-- 显式指定Mapper文件位置 -->
    <property name="mapperLocations" value="classpath*:xmlmapper/*.xml"/>
</bean>

<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
    <property name="basePackage" value="com.boothsun.mybatismapper"/>
    <property name="sqlSessionFactoryBeanName" value="sqlSessionFactory"/>
</bean>

<bean id="transactionManager"
      class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dynamicDataSource"/>
</bean>
<tx:annotation-driven transaction-manager="transactionManager" proxy-target-class="false"/>
```

#### spring获取数据源的源码：

![img](https://images2018.cnblogs.com/blog/1396730/201808/1396730-20180802142025192-822921616.png)

 

#### DynamicDataSource方法：

```java
public class DynamicDataSource extends AbstractRoutingDataSource {
    @Override
    protected Object determineCurrentLookupKey() {
        return DbContextHolder.getDbType();
    }
}
```

#### DbContextHolder方法

```java
public class DbContextHolder {
// 注意：数据源标识保存在线程变量中，避免多线程操作数据源时互相干扰
private static final ThreadLocal<String> contextHolder=new ThreadLocal<String>(); 
    
    public static void setDbType(String dbType){    
        contextHolder.set(dbType); 
    } 
    public static String getDbType(){  
        String dbType=(String) contextHolder.get();   
        return dbType; 
    } 
    public static void clearDbType(){  contextHolder.remove(); }
}
```

**使用ThreadLocal实现简单的读写分离**

```java
@Component
@Aspect
public class DataSourceMethodInterceptor {

    @Before("execution(* com.xxx.xxx.xxx.xxx.service.impl.*.*(..))")
    public void dynamicSetDataSoruce(JoinPoint joinPoint) throws Exception {
        String methodName = joinPoint.getSignature().getName();
        // 查询读从库
        if (methodName.startsWith("select") || methodName.startsWith("load") || methodName.startsWith("get") || methodName.startsWith("count") || methodName.startsWith("is")) {
            DynamicDataSourceHolder.setDataSource("slave");
        } else { // 其他读主库
            DynamicDataSourceHolder.setDataSource("master");
        }
    }

}
```

 

优点：

1、多数据源切换方便，由程序自动完成；

2、不需要引入中间件；

3、理论上支持任何数据库；

缺点：

1、由程序员完成，运维参与不到；

2、不能做到动态增加数据源；

## 二、使用中间件实现读写分离

要求：

1. 一主两从，做读写分离。
2. 多个从库之间实现负载均衡。
3. 可手动强制部分读请求到主库上。(因为主从同步有延迟，对实时性要求高的系统，可以将部分读请求也走主库)

#### mybatis配置文件

```xml
<bean id="master" class="com.alibaba.druid.pool.DruidDataSource" init-method="init"
      destroy-method="close">
    <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
    <property name="url" value="${jdbc.url.master}"></property>
    <property name="username" value="${jdbc.username.master}"></property>
    <property name="password" value="${jdbc.password.master}"></property>
    <property name="maxActive" value="100"/>
    <property name="initialSize" value="10"/>
    <property name="maxWait" value="60000"/>
    <property name="minIdle" value="5"/>
</bean>

<bean id="slave1" class="com.alibaba.druid.pool.DruidDataSource" init-method="init"
      destroy-method="close">
    <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
    <property name="url" value="${jdbc.url.slave1}"></property>
    <property name="username" value="${jdbc.username.slave1}"></property>
    <property name="password" value="${jdbc.password.slave1}"></property>
    <property name="maxActive" value="100"/>
    <property name="initialSize" value="10"/>
    <property name="maxWait" value="60000"/>
    <property name="minIdle" value="5"/>
</bean>

<bean id="slave2" class="com.alibaba.druid.pool.DruidDataSource" init-method="init"
      destroy-method="close">
    <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
    <property name="url" value="${jdbc.url.slave2}"></property>
    <property name="username" value="${jdbc.username.slave2}"></property>
    <property name="password" value="${jdbc.password.slave2}"></property>
    <property name="maxActive" value="100"/>
    <property name="initialSize" value="10"/>
    <property name="maxWait" value="60000"/>
    <property name="minIdle" value="5"/>
</bean>

<bean id="randomStrategy" class="io.shardingjdbc.core.api.algorithm.masterslave.RandomMasterSlaveLoadBalanceAlgorithm" />

<master-slave:data-source id="shardingDataSource" master-data-source-name="master" slave-data-source-names="slave1,slave2" strategy-ref="randomStrategy" />
```

### 强制路由

使用读写分离，可能会有主从同步延迟的问题，对于一些实时性要求比较高的业务，需强制部分读请求访问主库。

### HintManager 分片键值管理器

我们可使用*hintManager.setMasterRouteOnly()* .

```java
@Test
public void HintManagerTest() {

    HintManager hintManager = HintManager.getInstance();
    hintManager.setMasterRouteOnly();

    OrderExample example = new OrderExample();
    example.createCriteria().andBusinessIdEqualTo(112);
    List<Order> orderList = orderMapper.selectByExample(example);
    System.out.println(JSONObject.toJSONString(orderList));

    hintManager.close();
}
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

阿里的mycat或360的Atlas也可以实现分库分表，读写分离和负载均衡等处理。

引用：https://www.cnblogs.com/liujiduo/p/5004691.html





-----

# 四、[基于注解的Spring多数据源配置和使用](https://www.cnblogs.com/liujiduo/p/5004691.html)

前一段时间研究了一下spring多数据源的配置和使用，为了后期从多个数据源拉取数据定时进行数据分析和报表统计做准备。由于之前做过的项目都是单数据源的，没有遇到这种场景，所以也一直没有去了解过如何配置多数据源。
后来发现其实基于spring来配置和使用多数据源还是比较简单的，因为spring框架已经预留了这样的接口可以方便数据源的切换。
先看一下spring获取数据源的源码：

![img](https://images2015.cnblogs.com/blog/597127/201601/597127-20160112164824397-2119962260.png)

可以看到AbstractRoutingDataSource获取数据源之前会先调用determineCurrentLookupKey方法查找当前的lookupKey，这个lookupKey就是数据源标识。
因此通过重写这个查找数据源标识的方法就可以让spring切换到指定的数据源了。
第一步：创建一个DynamicDataSource的类，继承AbstractRoutingDataSource并重写determineCurrentLookupKey方法，代码如下：

```java
public class DynamicDataSource extends AbstractRoutingDataSource {

    @Override
    protected Object determineCurrentLookupKey() {
        // 从自定义的位置获取数据源标识
        return DynamicDataSourceHolder.getDataSource();
    }

}
```



第二步：创建DynamicDataSourceHolder用于持有当前线程中使用的数据源标识，代码如下：

```java
public class DynamicDataSourceHolder {
    /**
     * 注意：数据源标识保存在线程变量中，避免多线程操作数据源时互相干扰
     */
    private static final ThreadLocal<String> THREAD_DATA_SOURCE = new ThreadLocal<String>();

    public static String getDataSource() {
        return THREAD_DATA_SOURCE.get();
    }

    public static void setDataSource(String dataSource) {
        THREAD_DATA_SOURCE.set(dataSource);
    }

    public static void clearDataSource() {
        THREAD_DATA_SOURCE.remove();
    }

}
```



第三步：配置多个数据源和第一步里创建的DynamicDataSource的bean，简化的配置如下：

```xml
<!--创建数据源1，连接数据库db1 -->
<bean id="dataSource1" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
    <property name="driverClassName" value="${db1.driver}" />
    <property name="url" value="${db1.url}" />
    <property name="username" value="${db1.username}" />
    <property name="password" value="${db1.password}" />
</bean>
<!--创建数据源2，连接数据库db2 -->
<bean id="dataSource2" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
    <property name="driverClassName" value="${db2.driver}" />
    <property name="url" value="${db2.url}" />
    <property name="username" value="${db2.username}" />
    <property name="password" value="${db2.password}" />
</bean>
<!--创建数据源3，连接数据库db3 -->
<bean id="dataSource3" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
    <property name="driverClassName" value="${db3.driver}" />
    <property name="url" value="${db3.url}" />
    <property name="username" value="${db3.username}" />
    <property name="password" value="${db3.password}" />
</bean>

<bean id="dynamicDataSource" class="com.test.context.datasource.DynamicDataSource">
    <property name="targetDataSources">
        <map key-type="java.lang.String">
            <!-- 指定lookupKey和与之对应的数据源 -->
            <entry key="dataSource1" value-ref="dataSource1"></entry>
            <entry key="dataSource2" value-ref="dataSource2"></entry>
            <entry key="dataSource3 " value-ref="dataSource3"></entry>
        </map>
    </property>
    <!-- 这里可以指定默认的数据源 -->
    <property name="defaultTargetDataSource" ref="dataSource1" />
</bean>
```



到这里已经可以使用多数据源了，在操作数据库之前只要DynamicDataSourceHolder.setDataSource("dataSource2")即可切换到数据源2并对数据库db2进行操作了。

示例代码如下：

```java
@Service
public class DataServiceImpl implements DataService {
    @Autowired
    private DataMapper dataMapper;

    @Override
    public List<Map<String, Object>> getList1() {
        // 没有指定，则默认使用数据源1
        return dataMapper.getList1();
    }

    @Override
    public List<Map<String, Object>> getList2() {
        // 指定切换到数据源2
        DynamicDataSourceHolder.setDataSource("dataSource2");
        return dataMapper.getList2();
    }

    @Override
    public List<Map<String, Object>> getList3() {
        // 指定切换到数据源3
        DynamicDataSourceHolder.setDataSource("dataSource3");
        return dataMapper.getList3();
    }
}
```



--------------------------------------------------------------------------------------华丽的分割线--------------------------------------------------------------------------------------------------

但是问题来了，如果每次切换数据源时都调用DynamicDataSourceHolder.setDataSource("xxx")就显得十分繁琐了，而且代码量大了很容易会遗漏，后期维护起来也比较麻烦。能不能直接通过注解的方式指定需要访问的数据源呢，比如在dao层使用@DataSource("xxx")就指定访问数据源xxx？当然可以！前提是，再加一点额外的配置^_^。
首先，我们得定义一个名为DataSource的注解，代码如下：

```java
1 @Target({ TYPE, METHOD })
2 @Retention(RUNTIME)
3 public @interface DataSource {
4     String value();
5 }
```

然后，定义AOP切面以便拦截所有带有注解@DataSource的方法，取出注解的值作为数据源标识放到DynamicDataSourceHolder的线程变量中：

```java
public class DataSourceAspect {

    /**
     * 拦截目标方法，获取由@DataSource指定的数据源标识，设置到线程存储中以便切换数据源
     *
     * @param point
     * @throws Exception
     */
    public void intercept(JoinPoint point) throws Exception {
        Class<?> target = point.getTarget().getClass();
        MethodSignature signature = (MethodSignature) point.getSignature();
        // 默认使用目标类型的注解，如果没有则使用其实现接口的注解
        for (Class<?> clazz : target.getInterfaces()) {
            resolveDataSource(clazz, signature.getMethod());	//如果目标类上没有注解数据源，则该方式生效，走接口上的切换数据源注解
        }
        resolveDataSource(target, signature.getMethod());	//始终优先走目标类上获取到的切换数据源注解
    }

    /**
     * 提取目标对象方法注解和类型注解中的数据源标识
     *
     * @param clazz
     * @param method
     */
    private void resolveDataSource(Class<?> clazz, Method method) {
        try {
            Class<?>[] types = method.getParameterTypes();
            // 默认使用类型注解
            if (clazz.isAnnotationPresent(DataSource.class)) {
                DataSource source = clazz.getAnnotation(DataSource.class);
                DynamicDataSourceHolder.setDataSource(source.value());
            }
            // 方法注解可以覆盖类型注解
            Method m = clazz.getMethod(method.getName(), types);
            if (m != null && m.isAnnotationPresent(DataSource.class)) {
                DataSource source = m.getAnnotation(DataSource.class);
                DynamicDataSourceHolder.setDataSource(source.value());
            }
        } catch (Exception e) {
            System.out.println(clazz + ":" + e.getMessage());
        }
    }

}
```

最后在spring配置文件中配置拦截规则就可以了，比如拦截service层或者dao层的所有方法：

```xml
<bean id="dataSourceAspect" class="com.test.context.datasource.DataSourceAspect" />
    <aop:config>
        <aop:aspect ref="dataSourceAspect">
            <!-- 拦截所有service方法 -->
            <aop:pointcut id="dataSourcePointcut" expression="execution(* com.test.*.dao.*.*(..))"/>
            <aop:before pointcut-ref="dataSourcePointcut" method="intercept" />
        </aop:aspect>
    </aop:config>
</bean>
```

OK，这样就可以直接在类或者方法上使用注解@DataSource来指定数据源，不需要每次都手动设置了。

示例代码如下：

```java
@Service
// 默认DataServiceImpl下的所有方法均访问数据源1
@DataSource("dataSource1")
public class DataServiceImpl implements DataService {
    @Autowired
    private DataMapper dataMapper;

    @Override
    public List<Map<String, Object>> getList1() {
        // 不指定，则默认使用数据源1
        return dataMapper.getList1();
    }

    @Override
    // 覆盖类上指定的，使用数据源2
    @DataSource("dataSource2")
    public List<Map<String, Object>> getList2() {
        return dataMapper.getList2();
    }

    @Override
    // 覆盖类上指定的，使用数据源3
    @DataSource("dataSource3")
    public List<Map<String, Object>> getList3() {
        return dataMapper.getList3();
    }
}
```



**提示：注解@DataSource既可以加在方法上，也可以加在接口或者接口的实现类上，优先级别：==方法>实现类>接口==。也就是说如果接口、接口实现类以及方法上分别加了@DataSource注解来指定数据源，则优先以方法上指定的为准。**





----

# 五、[Spring 实现数据库读写分离](https://www.cnblogs.com/surge/p/3582248.html)

现在大型的电子商务系统，在数据库层面大都采用读写分离技术，就是一个Master数据库，多个Slave数据库。Master库负责数据更新和实时数据查询，Slave库当然负责非实时数据查询。因为在实际的应用中，数据库都是读多写少（读取数据的频率高，更新数据的频率相对较少），而读取数据通常耗时比较长，占用数据库服务器的CPU较多，从而影响用户体验。我们通常的做法就是把查询从主库中抽取出来，采用多个从库，使用负载均衡，减轻每个从库的查询压力。

　　采用读写分离技术的目标：有效减轻Master库的压力，又可以把用户查询数据的请求分发到不同的Slave库，从而保证系统的健壮性。我们看下采用读写分离的背景。

　　随着网站的业务不断扩展，数据不断增加，用户越来越多，数据库的压力也就越来越大，采用传统的方式，比如：数据库或者SQL的优化基本已达不到要求，这个时候可以采用读写分离的策 略来改变现状。

　　具体到开发中，如何方便的实现读写分离呢?目前常用的有两种方式：

　　1 第一种方式是我们最常用的方式，就是定义2个数据库连接，一个是MasterDataSource,另一个是SlaveDataSource。更新数据时我们读取MasterDataSource，查询数据时我们读取SlaveDataSource。这种方式很简单，我就不赘述了。

　　2 第二种方式动态数据源切换，就是在程序运行时，把数据源动态织入到程序中，从而选择读取主库还是从库。主要使用的技术是：**annotation，Spring AOP ，反射**。下面会详细的介绍实现方式。

　　　在介绍实现方式之前，我们先准备一些必要的知识，spring 的AbstractRoutingDataSource 类

　　  AbstractRoutingDataSource这个类 是spring2.0以后增加的，我们先来看下AbstractRoutingDataSource的定义：

　　　　public abstract class AbstractRoutingDataSource extends AbstractDataSource implements InitializingBean {}


　　 AbstractRoutingDataSource继承了AbstractDataSource ，而AbstractDataSource 又是DataSource 的子类。DataSource  是javax.sql 的数据源接口，定义如下：

```java
public interface DataSource  extends CommonDataSource,Wrapper {

  /**
   * <p>Attempts to establish a connection with the data source that
   * this <code>DataSource</code> object represents.
   *
   * @return  a connection to the data source
   * @exception SQLException if a database access error occurs
   */
  Connection getConnection() throws SQLException;

  /**
   * <p>Attempts to establish a connection with the data source that
   * this <code>DataSource</code> object represents.
   *
   * @param username the database user on whose behalf the connection is
   *  being made
   * @param password the user's password
   * @return  a connection to the data source
   * @exception SQLException if a database access error occurs
   * @since 1.4
   */
  Connection getConnection(String username, String password)
    throws SQLException;

}
```

DataSource 接口定义了2个方法，都是获取数据库连接。我们在看下AbstractRoutingDataSource 如何实现了DataSource接口：

```java
public Connection getConnection() throws SQLException {
        return determineTargetDataSource().getConnection();
    }

    public Connection getConnection(String username, String password) throws SQLException {
        return determineTargetDataSource().getConnection(username, password);
    }
```

 

　　很显然就是调用自己的determineTargetDataSource() 方法获取到connection。determineTargetDataSource方法定义如下：

```java
protected DataSource determineTargetDataSource() {
        Assert.notNull(this.resolvedDataSources, "DataSource router not initialized");
        Object lookupKey = determineCurrentLookupKey();
        DataSource dataSource = this.resolvedDataSources.get(lookupKey);
        if (dataSource == null && (this.lenientFallback || lookupKey == null)) {
            dataSource = this.resolvedDefaultDataSource;
        }
        if (dataSource == null) {
            throw new IllegalStateException("Cannot determine target DataSource for lookup key [" + lookupKey + "]");
        }
        return dataSource;
    }
```



 　我们最关心的还是下面2句话：

　　  Object lookupKey = determineCurrentLookupKey();
     DataSource dataSource = this.resolvedDataSources.get(lookupKey);

  determineCurrentLookupKey方法返回lookupKey,resolvedDataSources方法就是根据lookupKey从Map中获得数据源。resolvedDataSources 和determineCurrentLookupKey定义如下：

　　private Map<Object, DataSource> resolvedDataSources;

　　protected abstract Object determineCurrentLookupKey()

　　看到以上定义，我们是不是有点思路了，resolvedDataSources是Map类型，我们可以把MasterDataSource和SlaveDataSource存到Map中，如下：

　　　　key　　　　　　　　value

　　　　master　　      MasterDataSource

　　　　slave          SlaveDataSource

　　我们在写一个类DynamicDataSource 继承AbstractRoutingDataSource，实现其determineCurrentLookupKey() 方法，该方法返回Map的key，master或slave。

 

　　好了，说了这么多，有点烦了，下面我们看下怎么实现。

 　上面已经提到了我们要使用的技术，我们先看下annotation的定义：

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface DataSource {
    String value();
}
```

  我们还需要实现spring的抽象类AbstractRoutingDataSource，就是实现determineCurrentLookupKey方法：

```java
public class DynamicDataSource extends AbstractRoutingDataSource {

    @Override
    protected Object determineCurrentLookupKey() {
        // TODO Auto-generated method stub
        return DynamicDataSourceHolder.getDataSouce();
    }

}


public class DynamicDataSourceHolder {
    public static final ThreadLocal<String> holder = new ThreadLocal<String>();

    public static void putDataSource(String name) {
        holder.set(name);
    }

    public static String getDataSouce() {
        return holder.get();
    }
}
```

 

  从DynamicDataSource 的定义看出，他返回的是DynamicDataSourceHolder.getDataSouce()值，我们需要在程序运行时调用DynamicDataSourceHolder.putDataSource()方法，对其赋值。下面是我们实现的核心部分，也就是AOP部分，DataSourceAspect定义如下:

```java
public class DataSourceAspect {

    public void before(JoinPoint point)
    {
        Object target = point.getTarget();
        String method = point.getSignature().getName();//getSignature获取切入点的代理信息，获取切入点方法名，等同与.getSignature().getMethod().getName()

        Class<?>[] classz = target.getClass().getInterfaces(); //获取被代理类的接口信息

        Class<?>[] parameterTypes = ((MethodSignature) point.getSignature())
                .getMethod().getParameterTypes();
        try {
            Method m = classz[0].getMethod(method, parameterTypes);
            if (m != null && m.isAnnotationPresent(DataSource.class)) {		//A.isAnnotationPresent(B.class)；意思就是：注释B是否在此A上,是则返回true
                DataSource data = m
                        .getAnnotation(DataSource.class);	//从m上得到目标注解类实例
                DynamicDataSourceHolder.putDataSource(data.value());
                System.out.println(data.value());
            }
            
        } catch (Exception e) {
            // TODO: handle exception
        }
    }
}
```



  为了方便测试，我定义了2个数据库，shop模拟Master库，test模拟Slave库，shop和test的表结构一致，但数据不同，数据库配置如下：

```xml
<bean id="masterdataSource"
        class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://127.0.0.1:3306/shop" />
        <property name="username" value="root" />
        <property name="password" value="yangyanping0615" />
    </bean>

    <bean id="slavedataSource"
        class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://127.0.0.1:3306/test" />
        <property name="username" value="root" />
        <property name="password" value="yangyanping0615" />
    </bean>
    
        <beans:bean id="dataSource" class="com.air.shop.common.db.DynamicDataSource">
        <property name="targetDataSources">  
              <map key-type="java.lang.String">  
                  <!-- write -->
                 <entry key="master" value-ref="masterdataSource"/>  
                 <!-- read -->
                 <entry key="slave" value-ref="slavedataSource"/>  
              </map>  
              
        </property>  
        <property name="defaultTargetDataSource" ref="masterdataSource"/>  
    </beans:bean>

    <bean id="transactionManager"
        class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource" />
    </bean>


    <!-- 配置SqlSessionFactoryBean -->
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource" />
        <property name="configLocation" value="classpath:config/mybatis-config.xml" />
    </bean>
```

 

　　在spring的配置中增加aop配置

```xml
<!-- 配置数据库注解aop -->
    <aop:aspectj-autoproxy></aop:aspectj-autoproxy>
    <beans:bean id="manyDataSourceAspect" class="com.air.shop.proxy.DataSourceAspect" />
    <aop:config>
        <aop:aspect id="c" ref="manyDataSourceAspect">
            <aop:pointcut id="tx" expression="execution(* com.air.shop.mapper.*.*(..))"/>
            <aop:before pointcut-ref="tx" method="before"/>
        </aop:aspect>
    </aop:config>
    <!-- 配置数据库注解aop -->
```

　　 下面是MyBatis的UserMapper的定义，为了方便测试，登录读取的是Master库，用户列表读取Slave库：

```java
public interface UserMapper {
    @DataSource("master")
    public void add(User user);

    @DataSource("master")
    public void update(User user);

    @DataSource("master")
    public void delete(int id);

    @DataSource("slave")
    public User loadbyid(int id);

    @DataSource("master")
    public User loadbyname(String name);
    
    @DataSource("slave")
    public List<User> list();
}
```



 

-----

# 六、[springboot实现读写分离(基于Mybatis，mysql)](https://www.cnblogs.com/wuyoucao/p/10965903.html)

完整代码：https://github.com/FleyX/demo-project/tree/master/dxfl

## 1、背景

  一个项目中数据库最基础同时也是最主流的是单机数据库，读写都在一个库中。当用户逐渐增多，单机数据库无法满足性能要求时，就会进行读写分离改造（适用于读多写少），写操作一个库，读操作多个库，通常会做一个数据库集群，开启主从备份，一主多从，以提高读取性能。当用户更多读写分离也无法满足时，就需要分布式数据库了（可能以后会学习怎么弄）。

  正常情况下读写分离的实现，首先要做一个一主多从的数据库集群，同时还需要进行数据同步。这一篇记录如何用 mysql 搭建一个一主多次的配置，下一篇记录代码层面如何实现读写分离。

## 2、搭建一主多从数据库集群

  主从备份需要多台虚拟机，我是用 wmware 完整克隆多个实例，注意直接克隆的虚拟机会导致每个数据库的 uuid 相同，需要修改为不同的 uuid。修改方法参考这个：[点击跳转](https://blog.csdn.net/pratise/article/details/80413198)。

- 主库配置

  主数据库（master）中新建一个用户用于从数据库（slave）读取主数据库二进制日志，sql 语句如下：

  ```sql
  mysql> CREATE USER 'repl'@'%' IDENTIFIED BY '123456';#创建用户
  mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';#分配权限
  mysql>flush privileges;   #刷新权限
  ```

  同时修改 mysql 配置文件开启二进制日志，新增部分如下：

  ```sql
  [mysqld]
  server-id=1
  log-bin=master-bin
  log-bin-index=master-bin.index
  ```

  然后重启数据库，使用`show master status;`语句查看主库状态，如下所示：

![主库状态](https://raw.githubusercontent.com/FleyX/files/master/blogImg/%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB/20190107101953.png)

- 从库配置

  同样先新增几行配置：

  ```sql
  [mysqld]
  server-id=2
  relay-log-index=slave-relay-bin.index
  relay-log=slave-relay-bin
  ```

  然后重启数据库，使用如下语句连接主库：

  ```sql
  CHANGE MASTER TO
           MASTER_HOST='192.168.226.5',
           MASTER_USER='root',
           MASTER_PASSWORD='123456',
           MASTER_LOG_FILE='master-bin.000003',
           MASTER_LOG_POS=154;
  ```

  接着运行`start slave;`开启备份,正常情况如下图所示：Slave_IO_Running 和 Slave_SQL_Running 都为 yes。

  

可以用这个步骤开启多个从库。

  默认情况下备份是主库的全部操作都会备份到从库，实际可能需要忽略某些库，可以在主库中增加如下配置：

```sql
# 不同步哪些数据库
binlog-ignore-db = mysql
binlog-ignore-db = test
binlog-ignore-db = information_schema
 
# 只同步哪些数据库，除此之外，其他不同步
binlog-do-db = game
```

## 3、代码层面进行读写分离

  代码环境是 springboot+mybatis+druib 连接池。想要读写分离就需要配置多个数据源，在进行写操作是选择写的数据源，读操作时选择读的数据源。其中有两个关键点：

- 如何切换数据源
- 如何根据不同的方法选择正确的数据源

### 1)、如何切换数据源

  通常用 springboot 时都是使用它的默认配置，只需要在配置文件中定义好连接属性就行了，但是现在我们需要自己来配置了，spring 是支持多数据源的，多个 datasource 放在一个 HashMap`TargetDataSource`中，通过`dertermineCurrentLookupKey`获取 key 来觉定要使用哪个数据源。因此我们的目标就很明确了，建立多个 datasource 放到 TargetDataSource 中，同时重写 dertermineCurrentLookupKey 方法来决定使用哪个 key。

### 2)、如何选择数据源

  事务一般是注解在 Service 层的，因此在开始这个 service 方法调用时要确定数据源，有什么通用方法能够在开始执行一个方法前做操作呢？相信你已经想到了那就是**切面 **。怎么切有两种办法：

- 注解式，定义一个只读注解，被该数据标注的方法使用读库
- 方法名，根据方法名写切点，比如 getXXX 用读库，setXXX 用写库

### 3)、代码编写

#### a、编写配置文件，配置两个数据源信息

  只有必填信息，其他都有默认设置

```yml
mysql:
  datasource:
    #读库数目
    num: 1
    type-aliases-package: com.example.dxfl.dao
    mapper-locations: classpath:/mapper/*.xml
    config-location: classpath:/mybatis-config.xml
    write:
      url: jdbc:mysql://192.168.226.5:3306/test?useUnicode=true&characterEncoding=utf-8&useSSL=true
      username: root
      password: 123456
      driver-class-name: com.mysql.jdbc.Driver
    read:
      url: jdbc:mysql://192.168.226.6:3306/test?useUnicode=true&characterEncoding=utf-8&useSSL=true
      username: root
      password: 123456
      driver-class-name: com.mysql.jdbc.Driver
```

#### b、编写 DbContextHolder 类

  这个类用来设置数据库类别，其中有一个 ThreadLocal 用来保存每个线程的是使用读库，还是写库。代码如下：

```java
/**
 * Description 这里切换读/写模式
 * 原理是利用ThreadLocal保存当前线程是否处于读模式（通过开始READ_ONLY注解在开始操作前设置模式为读模式，
 * 操作结束后清除该数据，避免内存泄漏，同时也为了后续在该线程进行写操作时任然为读模式
 * @author fxb
 * @date 2018-08-31
 */
public class DbContextHolder {
 
    private static Logger log = LoggerFactory.getLogger(DbContextHolder.class);
    public static final String WRITE = "write";
    public static final String READ = "read";
 
    private static ThreadLocal<String> contextHolder= new ThreadLocal<>();
 
    public static void setDbType(String dbType) {
        if (dbType == null) {
            log.error("dbType为空");
            throw new NullPointerException();
        }
        log.info("设置dbType为：{}",dbType);
        contextHolder.set(dbType);
    }
 
    public static String getDbType() {
        return contextHolder.get() == null ? WRITE : contextHolder.get();
    }
 
    public static void clearDbType() {
        contextHolder.remove();
    }
}
```

#### c、重写 determineCurrentLookupKey 方法

  spring 在开始进行数据库操作时会通过这个方法来决定使用哪个数据库，因此我们在这里调用上面 DbContextHolder 类的`getDbType()`方法获取当前操作类别,同时可进行读库的负载均衡，代码如下：

```java
public class MyAbstractRoutingDataSource extends AbstractRoutingDataSource {
 
    @Value("${mysql.datasource.num}")
    private int num;
 
    private final Logger log = LoggerFactory.getLogger(this.getClass());
 
    @Override
    protected Object determineCurrentLookupKey() {
        String typeKey = DbContextHolder.getDbType();
        if (typeKey == DbContextHolder.WRITE) {
            log.info("使用了写库");
            return typeKey;
        }
        //使用随机数决定使用哪个读库
        int sum = NumberUtil.getRandom(1, num);
        log.info("使用了读库{}", sum);
        return DbContextHolder.READ + sum;
    }
}
```

#### d、编写配置类

  由于要进行读写分离，不能再用 springboot 的默认配置，我们需要手动来进行配置。首先生成数据源，使用@ConfigurProperties 自动生成数据源：

```java
@Configuration
public class DruidConfig
{
	/**
     * 写数据源
     *
     * @Primary 标志这个 Bean 如果在多个同类 Bean 候选时，该 Bean 优先被考虑。
     * 多数据源配置的时候注意，必须要有一个主数据源，用 @Primary 标志该 Bean
     */
    @Primary
    @Bean
    @ConfigurationProperties(prefix = "mysql.datasource.write")
    public DataSource writeDataSource() {
        return new DruidDataSource();
    }
    
    /**
    读数据源类似，注意有多少个读库就要设置多少个读数据源，Bean 名为 read+序号。
  然后设置数据源，使用的是我们之前写的 MyAbstractRoutingDataSource 类
  **/
    	/**
     * 设置数据源路由，通过该类中的determineCurrentLookupKey决定使用哪个数据源
     */
    @Bean
    public AbstractRoutingDataSource routingDataSource() {
        MyAbstractRoutingDataSource proxy = new MyAbstractRoutingDataSource();
        Map<Object, Object> targetDataSources = new HashMap<>(2);
        targetDataSources.put(DbContextHolder.WRITE, writeDataSource());
        targetDataSources.put(DbContextHolder.READ+"1", read1());
        proxy.setDefaultTargetDataSource(writeDataSource());
        proxy.setTargetDataSources(targetDataSources);
        return proxy;
    }
    
    /**
     * 多数据源需要自己设置sqlSessionFactory
     */
    @Bean
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
        bean.setDataSource(routingDataSource());
        ResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        // 实体类对应的位置
        bean.setTypeAliasesPackage(typeAliasesPackage);
        // mybatis的XML的配置
        bean.setMapperLocations(resolver.getResources(mapperLocation));
        bean.setConfigLocation(resolver.getResource(configLocation));
        return bean.getObject();
    }
    
     /**
     * 最后还得配置下事务，否则事务不生效
     * 设置事务，事务需要知道当前使用的是哪个数据源才能进行事务处理
     */
    @Bean
    public DataSourceTransactionManager dataSourceTransactionManager() {
        return new DataSourceTransactionManager(routingDataSource());
    }
}
```

### 4)、选择数据源

  多数据源配置好了，但是代码层面如何选择选择数据源呢？这里介绍两种办法：

#### a、注解式

  首先定义一个只读注解，被这个注解方法使用读库，其他使用写库，如果项目是中途改造成读写分离可使用这个方法，无需修改业务代码，只要在只读的 service 方法上加一个注解即可。

```java
@Target({ElementType.METHOD,ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface ReadOnly {
}
```

  然后写一个切面来切换数据使用哪种数据源，重写 getOrder 保证本切面优先级高于事务切面优先级，在启动类加上`@EnableTransactionManagement(order = 10)`,为了代码如下：

```java
@Aspect
@Component
public class ReadOnlyInterceptor implements Ordered {
    private static final Logger log= LoggerFactory.getLogger(ReadOnlyInterceptor.class);
 
    @Around("@annotation(readOnly)")
    public Object setRead(ProceedingJoinPoint joinPoint,ReadOnly readOnly) throws Throwable{
        try{
            DbContextHolder.setDbType(DbContextHolder.READ);
            return joinPoint.proceed();
        }finally {
            //清楚DbType一方面为了避免内存泄漏，更重要的是避免对后续在本线程上执行的操作产生影响
            DbContextHolder.clearDbType();
            log.info("清除threadLocal");
        }
    }
 
    @Override
    public int getOrder() {
        return 0;
    }
}
```

#### b、方法名式

  这种方法不许要注解，但是需要service中方法名称按一定规则编写，然后通过切面来设置数据库类别，比如`setXXX`设置为写、`getXXX`设置为读，代码我就不写了，应该都知道怎么写。

## 4、测试

读写分离只是数据库扩展的一个临时解决办法，并不能一劳永逸，随着负载进一步增大，只有一个库用于写入肯定是不够的，而且单表的数据库是有上限的，mysql 最多千万级别的数据能保持较好的查询性能。最终还是会变成--**分库分表**架构的。分库分表可以看看这一篇：[https:/blog.fleyx.com/blog/detail/2019-03-20-10-38/](https://blog.fleyx.com/blog/detail/2019-03-20-10-38/)

**本文原创发布于：**[blog.fleyx.com/blog/detail/2018-09-10-10-38](https://www.cnblogs.com/wuyoucao/p/blog.fleyx.com/blog/detail/2018-09-10-10-38/)





----

# 七、[超详细sharding-jdbc分库分表实现（基于spring-boot)](https://blog.fleyx.com/blog/detail/2019-03-20-10-38/) 

**demo 地址：**https://github.com/FleyX/demo-project/tree/master/spring-boot/sjdemo

**部分内容参考 ShardingSphere 官方文档：**[官方文档](https://shardingsphere.apache.org/document/current/cn/overview/)

  最近工作任务比较轻，又到了充电时间，所以就花了几天来研究分库分表相关的。呕心沥血输出了这篇博文和一个 demo 项目，基本涵盖了一般的分库分表场景。

## 背景

  传统应用通常将数据集中存储在单一的数据节点中，已经越来越不能满足现代互联网的海量数据场景。随着用于用户的增长，对并发性能要求越来越高，系统后台服务可以很容易的进行扩容（负载均衡等），这样最终的瓶颈就是数据库了，单一的数据节点或者简单的主从结构是难以承受的。

  尽管目前已经有 nosql/newsql 能够支撑海量的数据，但是其对传统 sql 是不兼容的，而且生态圈页不太完善，关系型数据库的地位还是无法撼动的。

  由此产生了数据分片的概念。按照某个分片维度将存放在单一数据库中的数据分散地存放至多个数据库或表中以提升性能。数据分片的拆分方式分为：垂直分片和水平分片两种。



## 垂直分片

  按照业务逻辑拆分的方式称为垂直分片，又称为纵向拆分。核心理念就是专库专用。将一个大的数据库按照业务逻辑分类，拆分为多个小的数据库，每个业务逻辑使用各自的数据库，从而将压力分散到不同的数据库中。垂直分片往往需要对架构和设计进行调整，类似微服务的概念。但是垂直拆分只能属于一个治标不治本的办法，随着业务量进一步加大，超过了单个表能承受的阈值，还是会出现性能问题。然后就需要水平分片来进一步处理了。
[![垂直分片概念](https://raw.githubusercontent.com/FleyX/files/master/blogImg/20190326150742.png)](https://raw.githubusercontent.com/FleyX/files/master/blogImg/20190326150742.png)

垂直分片概念



## 水平分片

  水平分片又称横向分片。相对于垂直分片，不根据业务逻辑分，而是通过某个（几个）字段，根据某种规则将数据分散到多个库或表中，每个分片仅包含数据的一部分。例如根据用户主键分片，对 2 取余为 0 的放入 0 库（或表），为 1 的放入 1 库（或表）。如下所示：
[![水平分片](https://raw.githubusercontent.com/FleyX/files/master/blogImg/20190326152512.png)](https://raw.githubusercontent.com/FleyX/files/master/blogImg/20190326152512.png)

水平分片


从理论上来说水平分片是可以无限拓展的，属于分库分表的标准解决办法。



  但是有利就会有弊，虽然分片解决了性能问题，但是分布式的架构页引入了新的问题。

  首先面对的就是数据库的运维管理更加复杂，之前只是单库有限的几张表，现在数据被分散到了多库多表中，难以运维。

  其次就是很多之前能够正常运行的 sql 语句，在水平分片后无法正常运行，比如分页、排序、聚合分组等操作。

  最后就是分布式事务。跨库事务目前任然是一个较为棘手的事情。主要有两种解决办法：基于 XA 的分布式事务和最终一致性的柔性事务。

## 实战

  了解了分库分表的概念下面就是实战了，最初是考虑使用 Mycat 的，但最终没有采用的原因主要是以下两点：

- Mycat 较为混乱，没有明确的开发计划和完善的文档（文档是一本书）。而且首页看着像是 90 年代的页面。
- 最关键的一点，Mycat 已经很久没有更新了，自从 17 年发布了最后一个版本就再没有动静了（官网说的是筹备 2.0 中）

  在查找资料的过程中了解到当当的一款开源分库分表产品–sharding-jdbc.目前已经迁移到 apache 孵化中心，首页也相应的换了，[现在的官网首页](https://shardingsphere.apache.org/),同时也改名了：ShardingSphere。目前最新的发布版本是 3.1，有以下三个产品：

- Sharding-JDBC。ShardingSphere 就是在此基础上发展来的。仅支持 java，属于轻量级 java 框架，在 java 的 JDBC 层提高额外服务，相当于加强版 JDBC 驱动，因此可以与任何上层 ORM 框架配合使用，支持任意的数据库连接池，支持任意实现 JDBC 规范的数据库。本篇代码就是基于 Sharding—JDBC。
- Sharding-Proxy:跟 MyCat 一样属于数据库代理，对代码透明，目前仅支持 MySQL 数据库。
- Sharding-Sidecar:规划中的产品，定位为云原生数据库代理。

  下面开始基于 Spring-boot 的实战。总体如下：

- 分库分表使用
- 广播表使用
- 默认库使用

（PS：官方也有使用示例：https://github.com/apache/incubator-shardingsphere-example

## 建立数据表

  本例中共用到三个库四个表,如下：

- ds0:
  - user(分库不分表)
  - order(分库分表)
  - order_item(分库分表)
  - dictionary(广播表，不分库不分表在，在所有库中都有相同的数据)
- ds1:(同上)
  - user
  - order
  - order_item
  - dictionary
- ds2:(默认数据库，除上面的表外其他的表)
  - other_table

建表语句在此：https://github.com/FleyX/demo-project/tree/master/spring-boot/sjdemo/init

## POM 依赖

  springboot 主要依赖如下(完整依赖请在 github 中查看）：

```xml
<!--这里有个大坑，版本过高使用xa事务会报错未指定数据库，参见:https://github.com/apache/incubator-shardingsphere/issues/1842-->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.24</version>
</dependency>
<dependency>
    <groupId>io.shardingsphere</groupId>
    <artifactId>sharding-jdbc-spring-boot-starter</artifactId>
    <version>3.1.0</version>
</dependency>
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid</artifactId>
    <version>1.1.14</version>
</dependency>
<!--  -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.56</version>
</dependency>

<!--xa分布式事务-->
<dependency>
    <groupId>io.shardingsphere</groupId>
    <artifactId>sharding-transaction-2pc-xa</artifactId>
    <version>3.1.0</version>
</dependency>

<dependency>
    <groupId>io.shardingsphere</groupId>
    <artifactId>sharding-transaction-spring-boot-starter</artifactId>
    <version>3.1.0</version>
</dependency>
```

## yaml 配置

```yaml
# application.yml
spring:
  profiles:
    active: sharding
mybatis:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.fanxb.sjdemo.entity
  # 开启mybatis sql打印
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

这里是关键，分库分表配置。需要将所有的表列出（包含广播表），未列出的表将使用默认库。
需给所有配置了分库分表的数据表加上一个 userId 字段，因为要根据 userId 来判断写入到哪个库中，否则回向所有库插入。

```yaml
sharding:
  jdbc:
    datasource:
      # 配置数据源
      names: ds0,ds1,ds2
      ds0:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://10.82.27.177:3306/ds0
        username: root
        password: 123456
      ds1:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://10.82.27.177:3306/ds1
        username: root
        password: 123456
      ds2:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://10.82.27.177:3306/ds2
        username: root
        password: 123456
    config:
      sharding:
        # 默认数据源，可以将不分库分表的数据表放在这里(此处的表需与已经分库分表的表完全没有关联，不会产生联表查询操作，因为跨库连表查询是没办法实现的)
        # 3.1.0版本中dql查询存在bug，不使用默认库.会在下个版本中修复
        default-data-source-name: ds2
        # 默认分库策略,根据userId对2取余确定库
        default-database-strategy:
          inline:
            sharding-column: userId
            algorithm-expression: ds$->{userId % 2}
        # 配置表策略
        tables:
          # 公共表(比如字典表,角色表，权限表等),不分库分表,数据将发送到所有库中,方便联表查询
          dictionary:
            # 配置主键，以便sharding-jdbc生成主键
            key-generator-column-name: dictionaryId
            actual-data-nodes: ds$->{0..1}.dictionary
          # user 已经根据userId分库，因此user表不进行分表
          user:
            key-generator-column-name: userId
            actual-data-nodes: ds$->{0..1}.user
          order:
            key-generator-column-name: orderId
            actual-data-nodes: ds$->{0..1}.order$->{0..1}
            table-strategy:
              inline:
                # 设置分片键，相同分片键的连表查询不会出现笛卡儿积
                sharding-column: orderId
                # 设置分表规则,根据订单id对2取余分两个表
                algorithm-expression: order$->{orderId%2}
          order_item:
            key-generator-column-name: orderItemId
            actual-data-nodes: ds$->{0..1}.order_item$->{0..1}
            table-strategy:
              inline:
                sharding-column: orderId
                # 设置分表规则,根据订单id对2取余分两个表
                algorithm-expression: order_item$->{orderId%2}
      # 打印sql解析过程
      props:
        sql.show: true

```

  到这里就算配置完毕了，剩下的过程和普通 spring boot+mybatis 项目一样，不再赘述。

## 事务处理

  默认使用的是本地事务，但是如果业务逻辑抛出错误，还是会对所有的库进行回退操作的，只是如果出现断电断网的情况会导致数据不一致。详见：[官方文档](https://shardingsphere.apache.org/document/current/cn/features/transaction/local-transaction/).

  可通过`@ShardingTransactionType(TransactionType.XA)`注解，切换为 XA 事务或者柔性事务（示例中未配置，切换为柔性事务会报错）。

## 测试

  运行`com.fanxb.sjdemo.MainTest`查看测试结果。





-----

# 八、[java读写分离的实现](https://www.cnblogs.com/ngy0217/p/8987508.html)

## 1. 背景

我们一般应用对[数据库](http://lib.csdn.net/base/mysql)而言都是“读多写少”，也就说对数据库读取数据的压力比较大，有一个思路就是说采用数据库集群的方案，

其中一个是主库，负责写入数据，我们称之为：写库；

其它都是从库，负责读取数据，我们称之为：读库；

 

那么，对我们的要求是：

1、读库和写库的数据一致；（这个是很重要的一个问题，处理业务逻辑要放在service层去处理，不要在dao或者mapper层面去处理）

2、写数据必须写到写库；

3、读数据必须到读库；

 

## 2. 方案

解决读写分离的方案有两种：应用层解决和中间件解决。

 

### 2.1. 应用层解决：

![img](https://images2018.cnblogs.com/blog/430076/201805/430076-20180503205400899-1017355842.png)

优点：

1、多数据源切换方便，由程序自动完成；

2、不需要引入中间件；

3、理论上支持任何数据库；

缺点：

1、由程序员完成，运维参与不到；

2、不能做到动态增加数据源；

 

### 2.2. 中间件解决

 

![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717103011472-1425487246.png)

优缺点：

 

优点：

1、源程序不需要做任何改动就可以实现读写分离；

2、动态添加数据源不需要重启程序；

 

缺点：

1、程序依赖于中间件，会导致切换数据库变得困难；

2、由中间件做了中转代理，性能有所下降；

 

## 3. 使用Spring基于应用层实现

### 3.1. 原理

![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717103216394-922436981.png)

 

### 3.2. DynamicDataSource

```java
 import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;
/**
 * 定义动态数据源，实现通过集成Spring提供的AbstractRoutingDataSource，只需要实现determineCurrentLookupKey方法即可
 * 
 * 由于DynamicDataSource是单例的，线程不安全的，所以采用ThreadLocal保证线程安全，由DynamicDataSourceHolder完成。
 * 
 * @author zhijun
 *
 */
public class DynamicDataSource extends AbstractRoutingDataSource{

    @Override
    protected Object determineCurrentLookupKey() {
        // 使用DynamicDataSourceHolder保证线程安全，并且得到当前线程中的数据源key
        return DynamicDataSourceHolder.getDataSourceKey();
    }

}
```



### 3.3. DynamicDataSourceHolder

```java
<pre name="code" class="java">/**
 * 
 * 使用ThreadLocal技术来记录当前线程中的数据源的key
 * 
 * @author zhijun
 *
 */
public class DynamicDataSourceHolder {
    
    //写库对应的数据源key
    private static final String MASTER = "master";

    //读库对应的数据源key
    private static final String SLAVE = "slave";
    
    //使用ThreadLocal记录当前线程的数据源key
    private static final ThreadLocal<String> holder = new ThreadLocal<String>();

    /**
     * 设置数据源key
     * @param key
     */
    public static void putDataSourceKey(String key) {
        holder.set(key);
    }

    /**
     * 获取数据源key
     * @return
     */
    public static String getDataSourceKey() {
        return holder.get();
    }
    
    /**
     * 标记写库
     */
    public static void markMaster(){
        putDataSourceKey(MASTER);
    }
    
    /**
     * 标记读库
     */
    public static void markSlave(){
        putDataSourceKey(SLAVE);
    }

}
```



### 3.4. DataSourceAspect切面类

```java
import org.apache.commons.lang3.StringUtils;
import org.aspectj.lang.JoinPoint;

/**
 * 定义数据源的AOP切面，通过该Service的方法名判断是应该走读库还是写库
 * 
 * @author zhijun
 *
 */
public class DataSourceAspect {

    /**
     * 在进入Service方法之前执行
     * 
     * @param point 切面对象
     */
    public void before(JoinPoint point) {
        // 获取到当前执行的方法名
        String methodName = point.getSignature().getName();
        if (isSlave(methodName)) {
            // 标记为读库
            DynamicDataSourceHolder.markSlave();
        } else {
            // 标记为写库
            DynamicDataSourceHolder.markMaster();
        }
    }

    /**
     * 判断是否为读库
     * 
     * @param methodName
     * @return
     */
    private Boolean isSlave(String methodName) {
        // 方法名以query、find、get开头的方法名走从库
        return StringUtils.startsWithAny(methodName, "query", "find", "get");
    }

}
```



### 3.5. 配置2个数据源

#### 3.5.1. jdbc.properties

```properties
jdbc.master.driver=com.mysql.jdbc.Driver
jdbc.master.url=jdbc:mysql://127.0.0.1:3306/mybatis_1128?useUnicode=true&characterEncoding=utf8&autoReconnect=true&allowMultiQueries=true
jdbc.master.username=root
jdbc.master.password=123456


jdbc.slave01.driver=com.mysql.jdbc.Driver
jdbc.slave01.url=jdbc:mysql://127.0.0.1:3307/mybatis_1128?useUnicode=true&characterEncoding=utf8&autoReconnect=true&allowMultiQueries=true
jdbc.slave01.username=root
jdbc.slave01.password=123456
```

#### 3.5.2. 定义连接池

```xml
<!-- 配置连接池 -->
    <bean id="masterDataSource" class="com.jolbox.bonecp.BoneCPDataSource"
        destroy-method="close">
        <!-- 数据库驱动 -->
        <property name="driverClass" value="${jdbc.master.driver}" />
        <!-- 相应驱动的jdbcUrl -->
        <property name="jdbcUrl" value="${jdbc.master.url}" />
        <!-- 数据库的用户名 -->
        <property name="username" value="${jdbc.master.username}" />
        <!-- 数据库的密码 -->
        <property name="password" value="${jdbc.master.password}" />
        <!-- 检查数据库连接池中空闲连接的间隔时间，单位是分，默认值：240，如果要取消则设置为0 -->
        <property name="idleConnectionTestPeriod" value="60" />
        <!-- 连接池中未使用的链接最大存活时间，单位是分，默认值：60，如果要永远存活设置为0 -->
        <property name="idleMaxAge" value="30" />
        <!-- 每个分区最大的连接数 -->
        <property name="maxConnectionsPerPartition" value="150" />
        <!-- 每个分区最小的连接数 -->
        <property name="minConnectionsPerPartition" value="5" />
    </bean>
    
    <!-- 配置连接池 -->
    <bean id="slave01DataSource" class="com.jolbox.bonecp.BoneCPDataSource"
        destroy-method="close">
        <!-- 数据库驱动 -->
        <property name="driverClass" value="${jdbc.slave01.driver}" />
        <!-- 相应驱动的jdbcUrl -->
        <property name="jdbcUrl" value="${jdbc.slave01.url}" />
        <!-- 数据库的用户名 -->
        <property name="username" value="${jdbc.slave01.username}" />
        <!-- 数据库的密码 -->
        <property name="password" value="${jdbc.slave01.password}" />
        <!-- 检查数据库连接池中空闲连接的间隔时间，单位是分，默认值：240，如果要取消则设置为0 -->
        <property name="idleConnectionTestPeriod" value="60" />
        <!-- 连接池中未使用的链接最大存活时间，单位是分，默认值：60，如果要永远存活设置为0 -->
        <property name="idleMaxAge" value="30" />
        <!-- 每个分区最大的连接数 -->
        <property name="maxConnectionsPerPartition" value="150" />
        <!-- 每个分区最小的连接数 -->
        <property name="minConnectionsPerPartition" value="5" />
    </bean>
```

#### 3.5.3. 定义DataSource

```xml
<!-- 定义数据源，使用自己实现的动态数据源 -->
    <bean id="dataSource" class="cn.itcast.usermanage.spring.DynamicDataSource">
        <!-- 设置多个数据源 -->
        <property name="targetDataSources">
            <map key-type="java.lang.String">
                <!-- 这个key需要和程序中的key一致 -->
                <entry key="master" value-ref="masterDataSource"/>
                <entry key="slave" value-ref="slave01DataSource"/>
            </map>
        </property>
        <!-- 设置默认的数据源，这里默认走写库 -->
        <property name="defaultTargetDataSource" ref="masterDataSource"/>
    </bean>
```



### 3.6. 配置事务管理以及动态切换数据源切面

#### 3.6.1. 定义事务管理器

```xml
<!-- 定义事务管理器 -->
    <bean id="transactionManager"
        class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource" />
    </bean>
```

 

#### 3.6.2. 定义事务策略

```xml
<!-- 定义事务策略 -->
    <tx:advice id="txAdvice" transaction-manager="transactionManager">
        <tx:attributes>
            <!--定义查询方法都是只读的 -->
            <tx:method name="query*" read-only="true" />
            <tx:method name="find*" read-only="true" />
            <tx:method name="get*" read-only="true" />

            <!-- 主库执行操作，事务传播行为定义为默认行为 -->
            <tx:method name="save*" propagation="REQUIRED" />
            <tx:method name="update*" propagation="REQUIRED" />
            <tx:method name="delete*" propagation="REQUIRED" />

            <!--其他方法使用默认事务策略 -->
            <tx:method name="*" />
        </tx:attributes>
    </tx:advice>
```



#### 3.6.3. 定义切面

```xml
<!-- 定义AOP切面处理器 -->
    <bean class="cn.itcast.usermanage.spring.DataSourceAspect" id="dataSourceAspect" />

    <aop:config>
        <!-- 定义切面，所有的service的所有方法 -->
        <aop:pointcut id="txPointcut" expression="execution(* xx.xxx.xxxxxxx.service.*.*(..))" />
        <!-- 应用事务策略到Service切面 -->
        <aop:advisor advice-ref="txAdvice" pointcut-ref="txPointcut"/>
        
        <!-- 将切面应用到自定义的切面处理器上，-9999保证该切面优先级最高执行 -->
        <aop:aspect ref="dataSourceAspect" order="-9999">
            <aop:before method="before" pointcut-ref="txPointcut" />
        </aop:aspect>
    </aop:config>
```

 

## 4. 改进切面实现，使用事务策略规则匹配

之前的实现我们是将通过方法名匹配，而不是使用事务策略中的定义，我们使用事务管理策略中的规则匹配。

#### 4.1. 改进后的配置

```xml
   <!-- 定义AOP切面处理器 -->
   <bean class="cn.itcast.usermanage.spring.DataSourceAspect" id="dataSourceAspect">
        <!-- 指定事务策略 -->
        <property name="txAdvice" ref="txAdvice"/>
        <!-- 指定slave方法的前缀（非必须） -->
        <property name="slaveMethodStart" value="query,find,get"/>
    </bean>
```

#### 4.2. 改进后的实现

```java
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.aspectj.lang.JoinPoint;
import org.springframework.transaction.interceptor.NameMatchTransactionAttributeSource;
import org.springframework.transaction.interceptor.TransactionAttribute;
import org.springframework.transaction.interceptor.TransactionAttributeSource;
import org.springframework.transaction.interceptor.TransactionInterceptor;
import org.springframework.util.PatternMatchUtils;
import org.springframework.util.ReflectionUtils;

/**
 * 定义数据源的AOP切面，该类控制了使用Master还是Slave。
 * 
 * 如果事务管理中配置了事务策略，则采用配置的事务策略中的标记了ReadOnly的方法是用Slave，其它使用Master。
 * 
 * 如果没有配置事务管理的策略，则采用方法名匹配的原则，以query、find、get开头方法用Slave，其它用Master。
 * 
 * @author zhijun
 *
 */
public class DataSourceAspect {

    private List<String> slaveMethodPattern = new ArrayList<String>();
    
    private static final String[] defaultSlaveMethodStart = new String[]{ "query", "find", "get" };
    
    private String[] slaveMethodStart;

    /**
     * 读取事务管理中的策略
     * 
     * @param txAdvice
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
    public void setTxAdvice(TransactionInterceptor txAdvice) throws Exception {
        if (txAdvice == null) {
            // 没有配置事务管理策略
            return;
        }
        //从txAdvice获取到策略配置信息
        TransactionAttributeSource transactionAttributeSource = txAdvice.getTransactionAttributeSource();
        if (!(transactionAttributeSource instanceof NameMatchTransactionAttributeSource)) {
            return;
        }
        //使用反射技术获取到NameMatchTransactionAttributeSource对象中的nameMap属性值
        NameMatchTransactionAttributeSource matchTransactionAttributeSource = (NameMatchTransactionAttributeSource) transactionAttributeSource;
        Field nameMapField = ReflectionUtils.findField(NameMatchTransactionAttributeSource.class, "nameMap");
        nameMapField.setAccessible(true); //设置该字段可访问
        //获取nameMap的值
        Map<String, TransactionAttribute> map = (Map<String, TransactionAttribute>) nameMapField.get(matchTransactionAttributeSource);

        //遍历nameMap
        for (Map.Entry<String, TransactionAttribute> entry : map.entrySet()) {
            if (!entry.getValue().isReadOnly()) {//判断之后定义了ReadOnly的策略才加入到slaveMethodPattern
                continue;
            }
            slaveMethodPattern.add(entry.getKey());
        }
    }

    /**
     * 在进入Service方法之前执行
     * 
     * @param point 切面对象
     */
    public void before(JoinPoint point) {
        // 获取到当前执行的方法名
        String methodName = point.getSignature().getName();

        boolean isSlave = false;

        if (slaveMethodPattern.isEmpty()) {
            // 当前Spring容器中没有配置事务策略，采用方法名匹配方式
            isSlave = isSlave(methodName);
        } else {
            // 使用策略规则匹配
            for (String mappedName : slaveMethodPattern) {
                if (isMatch(methodName, mappedName)) {
                    isSlave = true;
                    break;
                }
            }
        }

        if (isSlave) {
            // 标记为读库
            DynamicDataSourceHolder.markSlave();
        } else {
            // 标记为写库
            DynamicDataSourceHolder.markMaster();
        }
    }

    /**
     * 判断是否为读库
     * 
     * @param methodName
     * @return
     */
    private Boolean isSlave(String methodName) {
        // 方法名以query、find、get开头的方法名走从库
        return StringUtils.startsWithAny(methodName, getSlaveMethodStart());
    }

    /**
     * 通配符匹配
     * 
     * Return if the given method name matches the mapped name.
     * <p>
     * The default implementation checks for "xxx*", "*xxx" and "*xxx*" matches, as well as direct
     * equality. Can be overridden in subclasses.
     * 
     * @param methodName the method name of the class
     * @param mappedName the name in the descriptor
     * @return if the names match
     * @see org.springframework.util.PatternMatchUtils#simpleMatch(String, String)
     */
    protected boolean isMatch(String methodName, String mappedName) {
        return PatternMatchUtils.simpleMatch(mappedName, methodName);
    }

    /**
     * 用户指定slave的方法名前缀
     * @param slaveMethodStart
     */
    public void setSlaveMethodStart(String[] slaveMethodStart) {
        this.slaveMethodStart = slaveMethodStart;
    }

    public String[] getSlaveMethodStart() {
        if(this.slaveMethodStart == null){
            // 没有指定，使用默认
            return defaultSlaveMethodStart;
        }
        return slaveMethodStart;
    }
    
}
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

 

## 5. 一主多从的实现

很多实际使用场景下都是采用“一主多从”的[架构](http://lib.csdn.net/base/architecture)的，所以我们现在对这种架构做支持，目前只需要修改DynamicDataSource即可。

 

![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717104154300-352314030.png)

 

 

### 5.1. 实现

```java
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;
import org.springframework.util.ReflectionUtils;

/**
 * 定义动态数据源，实现通过集成Spring提供的AbstractRoutingDataSource，只需要实现determineCurrentLookupKey方法即可
 * 
 * 由于DynamicDataSource是单例的，线程不安全的，所以采用ThreadLocal保证线程安全，由DynamicDataSourceHolder完成。
 * 
 * @author zhijun
 *
 */
public class DynamicDataSource extends AbstractRoutingDataSource {

    private static final Logger LOGGER = LoggerFactory.getLogger(DynamicDataSource.class);

    private Integer slaveCount;

    // 轮询计数,初始为-1,AtomicInteger是线程安全的
    private AtomicInteger counter = new AtomicInteger(-1);

    // 记录读库的key
    private List<Object> slaveDataSources = new ArrayList<Object>(0);

    @Override
    protected Object determineCurrentLookupKey() {
        // 使用DynamicDataSourceHolder保证线程安全，并且得到当前线程中的数据源key
        if (DynamicDataSourceHolder.isMaster()) {
            Object key = DynamicDataSourceHolder.getDataSourceKey(); 
            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("当前DataSource的key为: " + key);
            }
            return key;
        }
        Object key = getSlaveKey();
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("当前DataSource的key为: " + key);
        }
        return key;

    }

    @SuppressWarnings("unchecked")
    @Override
    public void afterPropertiesSet() {
        super.afterPropertiesSet();

        // 由于父类的resolvedDataSources属性是私有的子类获取不到，需要使用反射获取
        Field field = ReflectionUtils.findField(AbstractRoutingDataSource.class, "resolvedDataSources");
        field.setAccessible(true); // 设置可访问

        try {
            Map<Object, DataSource> resolvedDataSources = (Map<Object, DataSource>) field.get(this);
            // 读库的数据量等于数据源总数减去写库的数量
            this.slaveCount = resolvedDataSources.size() - 1;
            for (Map.Entry<Object, DataSource> entry : resolvedDataSources.entrySet()) {
                if (DynamicDataSourceHolder.MASTER.equals(entry.getKey())) {
                    continue;
                }
                slaveDataSources.add(entry.getKey());
            }
        } catch (Exception e) {
            LOGGER.error("afterPropertiesSet error! ", e);
        }
    }

    /**
     * 轮询算法实现
     * 
     * @return
     */
    public Object getSlaveKey() {
        // 得到的下标为：0、1、2、3……
        Integer index = counter.incrementAndGet() % slaveCount;
        if (counter.get() > 9999) { // 以免超出Integer范围
            counter.set(-1); // 还原
        }
        return slaveDataSources.get(index);
    }

} 
```

 

## 6. MySQL主从复制

### 6.1. 原理

 

![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717104311535-1945008797.jpg)

 

mysql主(称master)从(称slave)复制的原理：

1、master将数据改变记录到二进制日志(binarylog)中,也即是配置文件log-bin指定的文件(这些记录叫做二进制日志事件，binary log events)

2、slave将master的binary logevents拷贝到它的中继日志(relay log)

3、slave重做中继日志中的事件,将改变反映它自己的数据(数据重演)

### 6.2. 主从配置需要注意的地方

1、主DB server和从DB server数据库的版本一致

2、主DB server和从DB server数据库数据一致[ 这里就会可以把主的备份在从上还原，也可以直接将主的数据目录拷贝到从的相应数据目录]

3、主DB server开启二进制日志,主DB server和从DB server的server_id都必须唯一

### 6.3. 主库配置（windows，Linux下也类似）

可能有些朋友主从数据库的ip地址、用户名和账号配置不是很清楚，下面是我测试的主从配置，ip都是127.0.0.1，我在讲完自己的例子后，还会写

一个主从ip是不相同的配置的例子，大家可以通过这个例子去更加直观的了解配置方法。

在my.ini [mysqld] 下面修改（从库也是如此）：

 

*#开启主从复制，主库的配置*

*log-bin= mysql3306-bin*

*#指定主库serverid*

*server-id=101*

*#指定同步的数据库，如果不指定则同步全部数据库*

*binlog-do-db=mybatis_1128*

 （my.ini中输入的这些命令一定要和下面有一行空格，不然MySQL不识别）

执行SQL语句查询状态：
*SHOW MASTER STATUS*

 

*![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717104400988-1537673469.png)*

 

 需要记录下Position值，需要在从库中设置同步起始值。

 

 

 另外我再说一点，如果您在mysql执行*SHOW MASTER STATUS*  发现配置在my.ini中的内容没有起到效果，可能原因是并没有选择对my.ini文件，也可能是您没有重启服务，很大概率是后者造成的原因，

要想使配置生效，必须关掉MySQL服务，再重新启动。

关闭服务的方法：

win键打开，输入services.msc调出服务：

 

![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717161211081-1894274147.png)

 

 

![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717161337925-1559319177.png)

 

再启动SQLyog，发现配置已经生效了。

 

### 6.4. 在主库创建同步用户

\#授权用户slave01使用123456密码登录mysql

grant replication slave on *.* to 'slave01'@'127.0.0.1'identified by '123456';

flush privileges;

### 6.5. 从库配置

在my.ini修改：

 

\#指定serverid，只要不重复即可，从库也只有这一个配置，其他都在SQL语句中操作

server-id=102

 

以下执行SQL（使用从机的root账户执行）：

*CHANGE MASTER TO*

 *master_host='127.0.0.1',//主机的ip地址*

 *master_user='slave01',//主机的用户（就是刚刚在主机通过sql创建出来的账户）*

 *master_password='123456',*

 *master_port=3306,*

 *master_log_file='mysql3306-bin.000006',//File*

 *master_log_pos=1120;//Position*

 

*#启动slave同步*

*START SLAVE;*

 

*#查看同步状态*

*SHOW SLAVE STATUS;*

 

*![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717104501800-282064484.png)*

 

 

 

下面是ip不同的两台电脑的主从配置方法：

主数据库所在的操作系统：win7

　　主数据库的版本：5.0

　　主数据库的ip地址：192.168.1.111

　　从数据库所在的操作系统：linux

　　从数据的版本：5.0

　　从数据库的ip地址：192.168.1.112

**介绍完了环境，就聊聊配置步骤：**

　　**1、确保主数据库与从数据库一模一样。**

　　　　例如：主数据库里的a的数据库里有b，c，d表，那从数据库里的就应该有一个模子刻出来的a的数据库和b，c，d表


　　**2、在主数据库上创建同步账号。**

　　　　GRANT REPLICATION SLAVE,FILE ON *.* TO 'mstest'@'192.168.1.112' IDENTIFIED BY '123456';

　　　　192.168.1.112：是运行使用该用户的ip地址

　　　　mstest：是新创建的用户名

　　　　123456：是新创建的用户名的密码

　　　　以上命令的详细解释，最好百度一下，写太多反到更加更不清思路。

　　**3、配置主数据库的my.ini(因为是在window下，所以是my.ini不是my.cnf)。**

　　　  [mysqld]

　　　　server-id=1
　　　　log-bin=log
　　　　binlog-do-db=mstest   //要同步的mstest数据库,要同步多个数据库，就多加几个binlog-do-db=数据库名

　　　　binlog-ignore-db=mysql //要忽略的数据库

　　**4、配置从数据库的my.cnf。**
　　　　[mysqld]

　　　　server-id=2
　　　　master-host=192.168.1.111
　　　　master-user=mstest   　　//第一步创建账号的用户名
　　　　master-password=123456  //第一步创建账号的密码
　　　　master-port=3306
　　　　master-connect-retry=60
　　　　replicate-do-db=mstest    //要同步的mstest数据库,要同步多个数据库，就多加几个replicate-do-db=数据库名
　　　　replicate-ignore-db=mysql　 //要忽略的数据库　

 

　　**5、验证是否成功**

 ![img](https://images2015.cnblogs.com/blog/1167306/201707/1167306-20170717174012175-1033973296.png)

 

 

进入mysql，后输入命令:show slave status\G。将显示下图。如果slave_io_running和slave_sql_running都为yes，那么表明可以成功同步了

**6、测试同步数据。**

　　　　进入主数据库输入命令:insert into one(name) values('beijing');

　　　　然后进入从数据库输入命令：select * from one;

　　　　如果此时从数据库有获取到数据，说明同步成功了，主从也就实现了

 

 

在进入Service之前，使用AOP来做出判断，是使用写库还是读库，判断依据可以根据方法名判断，比如说以query、find、get等开头的就走读库，其他的走写库。

 

-----



# 九、[高并发场景下基于 Spring Boot 框架来实现 MySQL 读写分离（附源码）](https://mp.weixin.qq.com/s/NyziGYyXCqgMlNdBgI27qw)

## 前言

首先思考一个问题:在高并发的场景中,关于数据库都有哪些优化的手段？常用的有以下的实现方法:读写分离、加缓存、主从架构集群、分库分表等，在互联网应用中,大部分都是读多写少的场景,设置两个库,主库和读库,主库的职能是负责写,从库主要是负责读,可以建立读库集群,通过读写职能在数据源上的隔离达到减少读写冲突、释压数据库负载、保护数据库的目的。在实际的使用中,凡是涉及到写的部分直接切换到主库，读的部分直接切换到读库，这就是典型的读写分离技术。本篇博文将聚焦读写分离,探讨如何实现它。

![图片](SpringAOP实现读写分离、分库分表.assets/640.png)

主从同步的局限性：这里分为主数据库和从数据库,主数据库和从数据库保持数据库结构的一致,主库负责写,当写入数据的时候,会自动同步数据到从数据库；从数据库负责读,当读请求来的时候,直接从读库读取数据,主数据库会自动进行数据复制到从数据库中。

不过本篇博客不介绍这部分配置的知识,因为它更偏运维工作一点。

这里涉及到一个问题：主从复制的延迟问题,当写入到主数据库的过程中,突然来了一个读请求,而此时数据还没有完全同步,就会出现读请求的数据读不到或者读出的数据比原始值少的情况。

具体的解决方法最简单的就是将读请求暂时指向主库,但是同时也失去了主从分离的部分意义。

也就是说在严格意义上的数据一致性场景中,读写分离并非是完全适合的,注意更新的时效性是读写分离使用的缺点。

好了,这部分只是了解,接下来我们看下具体如何通过java代码来实现读写分离:

该项目需要引入如下依赖：springBoot、spring-aop、spring-jdbc、aspectjweaver等。

## 一、主从数据源的配置

我们需要配置主从数据库,主从数据库的配置一般都是写在配置文件里面。通过@ConfigurationProperties注解,可以将配置文件(一般命名为:application.Properties)里的属性映射到具体的类属性上,从而读取到写入的值注入到具体的代码配置中,按照习惯大于约定的原则,主库我们都是注为master,从库注为slave,本项目采用了阿里的druid数据库连接池,使用build建造者模式创建DataSource对象,DataSource就是代码层面抽象出来的数据源,接着需要配置sessionFactory、sqlTemplate、事务管理器等。

```java
/**
 * 主从配置
 *
 * @author wyq
 * @date 2020年07月24日01:24:42
 */
@Configuration
@MapperScan(basePackages = "com.wyq.mysqlreadwriteseparate.mapper", sqlSessionTemplateRef = "sqlTemplate")
public class DataSourceConfig {

    /**
     * 主库
     */
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.master")
    public DataSource master() {
        return DruidDataSourceBuilder.create().build();
    }

    /**
     * 从库
     */
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.slave")
    public DataSource slaver() {
        return DruidDataSourceBuilder.create().build();
    }


    /**
     * 实例化数据源路由
     */
    @Bean
    public DataSourceRouter dynamicDB(@Qualifier("master") DataSource masterDataSource,
                                      @Autowired(required = false) @Qualifier("slaver") DataSource slaveDataSource) {
        DataSourceRouter dynamicDataSource = new DataSourceRouter();
        Map<Object, Object> targetDataSources = new HashMap<>();
        targetDataSources.put(DataSourceEnum.MASTER.getDataSourceName(), masterDataSource);
        if (slaveDataSource != null) {
            targetDataSources.put(DataSourceEnum.SLAVE.getDataSourceName(), slaveDataSource);
        }
        dynamicDataSource.setTargetDataSources(targetDataSources);
        dynamicDataSource.setDefaultTargetDataSource(masterDataSource);
        return dynamicDataSource;
    }


    /**
     * 配置sessionFactory
     * @param dynamicDataSource
     * @return
     * @throws Exception
     */
    @Bean
    public SqlSessionFactory sessionFactory(@Qualifier("dynamicDB") DataSource dynamicDataSource) throws Exception {
        SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
        bean.setMapperLocations(
                new PathMatchingResourcePatternResolver().getResources("classpath*:mapper/*Mapper.xml"));
        bean.setDataSource(dynamicDataSource);
        return bean.getObject();
    }


    /**
     * 创建sqlTemplate，若没有特别配置则可不写此方法，因为SpringBoot会默认会加载一个SqlSessionTemplate的Bean，使用默认配置好的SqlSessionFactory
     * @param sqlSessionFactory
     * @return
     */
    @Bean
    public SqlSessionTemplate sqlTemplate(@Qualifier("sessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }


    /**
     * 事务配置
     *
     * @param dynamicDataSource，若无特殊配置可不写，SpringBoot会默认配置（为默认数据源配置默认事务），若不是动态切换数据源而是要多个数据源同时生效，则需要为各个不同的数据源配置不同事务管理器，需要写多个事务配置的Bean
     * @return
     */
    @Bean(name = "dataSourceTx")
    public DataSourceTransactionManager dataSourceTransactionManager(@Qualifier("dynamicDB") DataSource dynamicDataSource) {
        DataSourceTransactionManager dataSourceTransactionManager = new DataSourceTransactionManager();
        dataSourceTransactionManager.setDataSource(dynamicDataSource);
        return dataSourceTransactionManager;
    }
}
```



## 二、数据源路由的配置

路由在主从分离是非常重要的,基本是读写切换的核心。

Spring提供了AbstractRoutingDataSource 根据用户定义的规则选择当前的数据源，作用就是在执行查询之前，设置使用的数据源,实现动态路由的数据源，在每次数据库查询操作前执行它的抽象方法 determineCurrentLookupKey() 决定使用哪个数据源,为了能有一个全局的数据源管理器,此时我们需要引入DataSourceContextHolder这个数据库上下文管理器,可以理解为全局的变量,随时可取(见下面详细介绍),它的主要作用就是保存当前的数据源;

```java
public class DataSourceRouter extends AbstractRoutingDataSource {

    /**
     * 最终的determineCurrentLookupKey返回的是从DataSourceContextHolder中拿到的,因此在动态切换数据源的时候注解
     * 应该给DataSourceContextHolder设值
     *
     * @return
     */
    @Override
    protected Object determineCurrentLookupKey() {
        return DataSourceContextHolder.get();

    }
}
```

## 三、数据源上下文环境

数据源上下文保存器,便于程序中可以随时取到当前的数据源,它主要利用ThreadLocal封装,因为ThreadLocal是线程隔离的,天然具有线程安全的优势。这里暴露了set和get、clear方法，set方法用于赋值当前的数据源名,get方法用于获取当前的数据源名称,clear方法用于清除ThreadLocal中的内容,因为ThreadLocal的key是weakReference是有内存泄漏风险的,通过remove方法防止内存泄漏；

```java
/**
 * 利用ThreadLocal封装的保存数据源上线的上下文context
 */
public class DataSourceContextHolder {

    private static final ThreadLocal<String> context = new ThreadLocal<>();

    /**
     * 赋值
     *
     * @param datasourceType
     */
    public static void set(String datasourceType) {
        context.set(datasourceType);
    }

    /**
     * 获取值
     * @return
     */
    public static String get() {
        return context.get();
    }

    public static void clear() {
        context.remove();
    }
}
```

## 四、切换注解和Aop配置

首先我们来定义一个@DataSourceSwitcher注解,拥有两个属性①当前的数据源②是否清除当前的数据源,并且只能放在方法上,(不可以放在类上,也没必要放在类上,因为我们在进行数据源切换的时候肯定是方法操作),该注解的主要作用就是进行数据源的切换,在dao层进行操作数据库的时候,可以在方法上注明表示的是当前使用哪个数据源;

 **@DataSourceSwitcher注解的定义:**

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Documented
public @interface DataSourceSwitcher {
    /**
     * 默认数据源
     * @return
     */
    DataSourceEnum value() default DataSourceEnum.MASTER;
    /**
     * 清除
     * @return
     */
    boolean clear() default true;

}
```

**DataSourceAop配置**

为了赋予@DataSourceSwitcher注解能够切换数据源的能力,我们需要使用AOP,然后使用@Aroud注解找到方法上有@DataSourceSwitcher.class的方法,然后取注解上配置的数据源的值,设置到DataSourceContextHolder中,就实现了将当前方法上配置的数据源注入到全局作用域当中;

```java
@Slf4j
@Aspect
@Order(value = 1)
@Component
public class DataSourceContextAop {

    @Around("@annotation(com.wyq.mysqlreadwriteseparate.annotation.DataSourceSwitcher)")
    public Object setDynamicDataSource(ProceedingJoinPoint pjp) throws Throwable {
        boolean clear = false;
        try {
            Method method = this.getMethod(pjp);
            DataSourceSwitcher dataSourceSwitcher = method.getAnnotation(DataSourceSwitcher.class);
            clear = dataSourceSwitcher.clear();
            DataSourceContextHolder.set(dataSourceSwitcher.value().getDataSourceName());
            log.info("数据源切换至：{}", dataSourceSwitcher.value().getDataSourceName());
            return pjp.proceed();
        } finally {
            if (clear) {
                DataSourceContextHolder.clear();
            }

        }
    }

    private Method getMethod(JoinPoint pjp) {
        MethodSignature signature = (MethodSignature) pjp.getSignature();
        return signature.getMethod();
    }

}
```

##  五、用法以及测试

 在配置好了读写分离之后,就可以在代码中使用了,一般而言我们使用在service层或者dao层,在需要查询的方法上添加@DataSourceSwitcher(DataSourceEnum.SLAVE),它表示该方法下所有的操作都走的是读库;在需要update或者insert的时候使用@DataSourceSwitcher(DataSourceEnum.MASTER)表示接下来将会走写库。

其实还有一种更为自动的写法,可以根据方法的前缀来配置AOP自动切换数据源,比如update、insert、fresh等前缀的方法名一律自动设置为写库,select、get、query等前缀的方法名一律配置为读库,这是一种更为自动的配置写法。缺点就是方法名需要按照aop配置的严格来定义,否则就会失效

```
@Service
public class OrderService {

    @Resource
    private OrderMapper orderMapper;


    /**
     * 读操作
     *
     * @param orderId
     * @return
     */
    @DataSourceSwitcher(DataSourceEnum.SLAVE)
    public List<Order> getOrder(String orderId) {
        return orderMapper.listOrders(orderId);

    }

    /**
     * 写操作
     *
     * @param orderId
     * @return
     */
    @DataSourceSwitcher(DataSourceEnum.MASTER)
    public List<Order> insertOrder(Long orderId) {
        Order order = new Order();
        order.setOrderId(orderId);
        return orderMapper.saveOrder(order);
    }
}
```

##  六、总结

![图片](SpringAOP实现读写分离、分库分表.assets/640.png)

上面是基本流程简图,本篇博客介绍了如何实现数据库读写分离,注意读写分离的核心点就是数据路由,需要继承AbstractRoutingDataSource,复写它的determineCurrentLookupKey方法,同时需要注意全局的上下文管理器DataSourceContextHolder,它是保存数据源上下文的主要类,也是路由方法中寻找的数据源取值,相当于数据源的中转站.再结合jdbc-Template的底层去创建和管理数据源、事务等，我们的数据库读写分离就完美实现了。

> 作者：Yrion
>
> cnblogs.com/wyq178/p/13352707.html



往期推荐

[开源项目-轻量级Java权限认证框架！](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489953&idx=1&sn=c12dc4986edd4a250fde0d85e9525314&chksm=fc44ec98cb33658e7b21fd8c721c772b2b2f51a04f41723d9809ed076041d2d3c309ba8e7981&scene=21#wechat_redirect)

[嚣张：分库分表就能无限扩容吗？](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489953&idx=2&sn=e9938276baf87ecace33a17245beb847&chksm=fc44ec98cb33658e1dfd7c6673fa28bea21a8841db35daa479bc3f6bc579852a4e19cca0acb9&scene=21#wechat_redirect)

[Netty 实现百万连接的难点和优化点](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489933&idx=1&sn=f7e9029d3ac5ccf07e723daeaa9f7701&chksm=fc44ecb4cb3365a2979fbbea11a03340913ee614c594a8a9b767a04aac0a2e982cf72f0cbb4d&scene=21#wechat_redirect)

[面试官：说一下线程池内部工作原理？](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489933&idx=2&sn=546277dbe1ed85f7f74c7a22c783e8a5&chksm=fc44ecb4cb3365a20848dbd7c70bdc538bb904e2d92a408dfaba2e3c0445bb031aa39de8e413&scene=21#wechat_redirect)

[产品需求：用java做一个长链接转短链的微服务](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489911&idx=1&sn=fd587cc24b56b4c79431c6efe3ee64c3&chksm=fc44ec4ecb336558c4ab1ea71982984ca0935fa355b23707e2dbbf38e48b88ea29d0387f8195&scene=21#wechat_redirect)

[【elasticsearch】数据早8小时or晚8小时，你知道为什么吗？附解决方案](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489911&idx=2&sn=b22411aea5b6f4660e200d6f53f7b467&chksm=fc44ec4ecb3365583d1edd3cf070cedbc443439b0fce6a6ef70b25169fad51dbb3385edb7444&scene=21#wechat_redirect)

[java项目，这样优雅的处理 Exception 实践，客户都给你点赞](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489866&idx=1&sn=0a45b43ef5c24ec3ce852e973bef1c59&chksm=fc44ec73cb3365658ea7013c5e2c0e35fb8acc9d03b7b43c5015bcab1c4b467d87e6eaebac7e&scene=21#wechat_redirect)

[大实话：等电梯的时候，90%的程序员都想过调度算法](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489858&idx=2&sn=5a2bf75e333fba2d67bb4a043d421088&chksm=fc44ec7bcb33656d274611e70048cfba05ae34ae2382d84aae01e9fcdfb30a1e4dad7bcd5153&scene=21#wechat_redirect)

[SpringBoot实现API接口多版本支持](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489811&idx=1&sn=6029b7b8d82753efa260d0c7ee093a3d&chksm=fc44ec2acb33653c3fda67373cddeba16cb07c7baf87d3e879a494e486f3a4eacb74ba68a3e8&scene=21#wechat_redirect)

[太多项目使用MyBatis，你理解它的架构和原理吗？](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489807&idx=1&sn=11a0903158c30553a8d4ee7664ff13c7&chksm=fc44ec36cb3365201cf9fdaaf57be38c72de39612cc07b9f2de2eeb1e9c13512140b9ffe01c1&scene=21#wechat_redirect)

[干了这么些年程序员，这7种软件架构模式必须得掌握了](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489805&idx=1&sn=22ea9c5be2461e34a1fc7ed3437b3045&chksm=fc44ec34cb33652220f4c5d538936efcc00c1d6e3d1033023026c6a30ac32b0adaa1cd721493&scene=21#wechat_redirect)

[前端入门攻略，高效！](http://mp.weixin.qq.com/s?__biz=MzU2NDc4MjE2Ng==&mid=2247489803&idx=1&sn=89b05314da4c54b9d1d5d7b15480de0e&chksm=fc44ec32cb336524509d81b999c99419da4683862842297436aca7572bc39f76bc2265df061e&scene=21#wechat_redirect)