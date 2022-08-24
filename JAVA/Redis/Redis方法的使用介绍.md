# [Redis中opsForValue()方法的使用介绍](https://blog.csdn.net/m0_55208404/article/details/113728643)

使用案例：

```java
package com.example.datestruct.utils;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

@Component
public class ApplicationTextUtils implements ApplicationContextAware {

    private static ApplicationContext context;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.context=applicationContext;
    }
    //传入注入SpringBoot容器中的类对象 传入对象名字 首字母小写
    public static Object getBeanObj(String BeanName){
        return context.getBean(BeanName);
    }
}
```

```java
package com.example.datestruct.utils;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.StringRedisSerializer;

public class redisUtils {
    //通过工厂类获取redisTemplete对象
    public static RedisTemplate getRedisTemplete(){

        RedisTemplate redisTemplate=(RedisTemplate) ApplicationTextUtils.getBeanObj("redisTemplate");
        redisTemplate.setHashKeySerializer(new StringRedisSerializer());
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        return redisTemplate;
    }
}
```

依赖：

```xml
<!-- redis -->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-redis</artifactId>
		</dependency>
```

配置：

```yaml
spring.redis.host=localhost
spring.redis.port=6379
spring.redis.pool.max-active=8
spring.redis.pool.max-idle=8
spring.redis.pool.min-idle=0
spring.redis.database=0
spring.redis.lettuce.pool.min-idle=1
spring.redis.lettuce.pool.max-idle=30
spring.redis.lettuce.pool.max-active=100
spring.redis.lettuce.pool.max_wait=PT10S
```

测试类：

测试：

```
package com.example.datestruct;

import com.example.datestruct.domain.student;
import com.example.datestruct.utils.redisUtils;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

@SpringBootTest
class DatestructApplicationTests {
    //切记 对象一定要序列化
    @Test
    public void test1(){
        redisUtils.getRedisTemplete().opsForValue().set("student",new student("1","2","3"));
    }

    @Test
    public void test9(){
        student stu=(student)redisUtils.getRedisTemplete().opsForValue().get("student");
        System.out.println(stu);
    }

    @Test
    public void test2(){
        redisUtils.getRedisTemplete().opsForHash().put("a","b","c");
        redisUtils.getRedisTemplete().opsForHash().put("a","b","c2");
        redisUtils.getRedisTemplete().opsForHash().put("a","b3","c2");
    }
   @Test
    public void test3(){
        RedisTemplate redisTemplate= (RedisTemplate)ApplicationTextUtils.getBeanObj("redisTemplateMsg");
        Set<String> HK=redisTemplate.opsForHash().keys("a");
        System.out.println(HK.toString());//[b1, b2, b3]map的key
        System.out.println(redisTemplate.opsForHash().values("a"));//[C1, c2, c3] map的values
        System.out.println(HK.size());

//        Iterator<String> it= HK.iterator();
//        while (it.hasNext()){
//            System.out.println(it.next());
//            System.out.println((student)redisTemplate.opsForHash().get("a","b"));
//            redisTemplate.opsForHash().get("a",it.next());
//        }
        
        
    }
    @Test
    public void test4(){
       List<String> lists=redisUtils.getRedisTemplete().opsForHash().values("a");
        System.out.println(lists.toString());
        System.out.println(lists.size());
    }
    @Test
    public void test5(){
        redisUtils.getRedisTemplete().opsForHash().delete("a","b");
    }
    @Test
    public void test6(){
        System.out.println(redisUtils.getRedisTemplete().opsForHash().get("a","b3"));
    }
}
```

## Redis中opsForValue()方法的使用介绍：

```java
1、set(K key, V value)
  新增一个字符串类型的值，key是键，value是值。

redisTemplate.opsForValue().set("stringValue","bbb");  
2、get(Object key)
  获取key键对应的值。

String stringValue = redisTemplate.opsForValue().get("key")
3、append(K key, String value)
在原有的值基础上新增字符串到末尾。

redisTemplate.opsForValue().append("key", "appendValue");
String stringValueAppend = redisTemplate.opsForValue().get("key");
System.out.println("通过append(K key, String value)方法修改后的字符串:"+stringValueAppend);  
4、get(K key, long start, long end)
截取key键对应值得字符串，从开始下标位置开始到结束下标的位置(包含结束下标)的字符串。

String cutString = redisTemplate.opsForValue().get("key", 0, 3);  
System.out.println("通过get(K key, long start, long end)方法获取截取的字符串:"+cutString);  
5、getAndSet(K key, V value)
  获取原来key键对应的值并重新赋新值。

String oldAndNewStringValue = redisTemplate.opsForValue().getAndSet("key", "ccc");  
System.out.print("通过getAndSet(K key, V value)方法获取原来的值：" + oldAndNewStringValue );  
String newStringValue = redisTemplate.opsForValue().get("key");  
System.out.println("修改过后的值:"+newStringValue);  
6、setBit(K key, long offset, boolean value)
  key键对应的值value对应的ascii码,在offset的位置(从左向右数)变为value。

redisTemplate.opsForValue().setBit("key",1,false);  
newStringValue = redisTemplate.opsForValue().get("key")+"";  
System.out.println("通过setBit(K key,long offset,boolean value)方法修改过后的值:"+newStringValue);  
 7、getBit(K key, long offset)
  判断指定的位置ASCII码的bit位是否为1。

boolean bitBoolean = redisTemplate.opsForValue().getBit("key",1);  
System.out.println("通过getBit(K key,long offset)方法判断指定bit位的值是:" + bitBoolean);  
​​​​​​​8、size(K key)

  获取指定字符串的长度

Long stringValueLength = redisTemplate.opsForValue().size("key");  
System.out.println("通过size(K key)方法获取字符串的长度:"+stringValueLength);  
​​​​​​​9、increment(K key, double delta)

  以增量的方式将double值存储在变量中。

double stringValueDouble = redisTemplate.opsForValue().increment("doubleKey",5);   
System.out.println("通过increment(K key, double delta)方法以增量方式存储double值:" + stringValueDouble);  
10、increment(K key, long delta)
  以增量的方式将long值存储在变量中。

double stringValueLong = redisTemplate.opsForValue().increment("longKey",6);   
System.out.println("通过increment(K key, long delta)方法以增量方式存储long值:" + stringValueLong);  
​​​​​​​11、setIfAbsent(K key, V value)

  如果键不存在则新增,存在则不改变已经有的值。

boolean absentBoolean = redisTemplate.opsForValue().setIfAbsent("absentKey","fff");  
System.out.println("通过setIfAbsent(K key, V value)方法判断变量值absentValue是否存在:" + absentBoolean);  
if(absentBoolean){  
    String absentValue = redisTemplate.opsForValue().get("absentKey")+"";  
    System.out.print(",不存在，则新增后的值是:"+absentValue);  
    boolean existBoolean = redisTemplate.opsForValue().setIfAbsent("absentKey","eee");  
    System.out.print(",再次调用setIfAbsent(K key, V value)判断absentValue是否存在并重新赋值:" + existBoolean);  
    if(!existBoolean){  
        absentValue = redisTemplate.opsForValue().get("absentKey")+"";  
        System.out.print("如果存在,则重新赋值后的absentValue变量的值是:" + absentValue);  
12、set(K key, V value, long timeout, TimeUnit unit)
  设置变量值的过期时间。

redisTemplate.opsForValue().set("timeOutKey", "timeOut", 5, TimeUnit.SECONDS);  
String timeOutValue = redisTemplate.opsForValue().get("timeOutKey")+"";  
System.out.println("通过set(K key, V value, long timeout, TimeUnit unit)方法设置过期时间，
过期之前获取的数据:"+timeOutValue);  
Thread.sleep(5*1000);  
timeOutValue = redisTemplate.opsForValue().get("timeOutKey")+"";  
System.out.print(",等待10s过后，获取的值:"+timeOutValue);  
13、set(K key, V value, long offset)
  覆盖从指定位置开始的值。

redisTemplate.opsForValue().set("absentKey","dd",1);  
String overrideString = redisTemplate.opsForValue().get("absentKey");  
System.out.println("通过set(K key, V value, long offset)方法覆盖部分的值:"+overrideString);  
​​​​​​​

14、multiSet(Map<? extends K,? extends V> map)
  设置map集合到redis。

Map valueMap = new HashMap();  
valueMap.put("valueMap1","map1");  
valueMap.put("valueMap2","map2");  
valueMap.put("valueMap3","map3");  
redisTemplate.opsForValue().multiSet(valueMap);  
15、multiGet(Collection<K> keys)
  根据集合取出对应的value值。

//根据List集合取出对应的value值  
List paraList = new ArrayList();  
paraList.add("valueMap1");  
paraList.add("valueMap2");  
paraList.add("valueMap3");  
List<String> valueList = redisTemplate.opsForValue().multiGet(paraList);  
for (String value : valueList){  
    System.out.println("通过multiGet(Collection<K> keys)方法获取map值:" + value);  
}
16、multiSetIfAbsent(Map<? extends K,? extends V> map)
Map valueMap = new HashMap();  
valueMap.put("valueMap1","map1");  
valueMap.put("valueMap2","map2");  
valueMap.put("valueMap3","map3");  
redisTemplate.opsForValue().multiSetIfAbsent(valueMap); 
```



## Redis中opsForHash()方法的使用

1、put(H var1, HK var2, HV var3)

> 新增hashMap值
>
> - var1 为Redis的key
> - var2 为key对应的map值的key
> - var3 为key对应的map值的值
> - var2相同替换var3

```java
redisTemplate.opsForHash().put("hashValue","map1","value1");
redisTemplate.opsForHash().put("hashValue","map2","value2");
```

### 2、get(H var1, Object var2)

> 获取key对应的map中，key为var2的map的对应的值

```java
Object o = redisTemplate.opsForHash().get("hashValue", "map1");
System.out.println("o = " + o);		// o = value1
```

### 3、entries(H key)

> 获取key对应的所有map键值对

```java
Map hashValue = redisTemplate.opsForHash().entries("hashValue");
System.out.println("hashValue = " + hashValue);
//hashValue = {map1=value1,map2=value2}
```

### 4、keys(H key)

> 获取key对应的map中所有的键

```java
Set hashValue = redisTemplate.opsForHash().keys("hashValue");
System.out.println("hashValue = " + hashValue);//hashValue=[map1,map2]
```

### 5、values(H key)

> 获取key对应的map中所有的值

```java
List hashValue = redisTemplate.opsForHash().values("hashValue");
System.out.println("hashValue = " + hashValue);//hashValue=[value1,value2]
```

### 6、hasKey(H key, Object var2)

> 判断key对应的map中是否有指定的键

```java
Boolean aBoolean = redisTemplate.opsForHash().hasKey("hashValue", "map1");
System.out.println("aBoolean = " + aBoolean);//true
```

### 7、size(H key)

> 获取key对应的map的长度

```java
Long hashValue = redisTemplate.opsForHash().size("hashValue");
System.out.println("hashValue = " + hashValue);//=2
```

### 8、putIfAbsent(H key, HK var2, HV var3)

> 如何key对应的map不存在，则新增到map中，存在则不新增也不覆盖

```java
redisTemplate.opsForHash().putIfAbsent("hashValue", "map3", "value3");
```

### 9、putAll(H key, Map<? extends HK, ? extends HV> map)

> 直接以map集合的方式添加key对应的值
>
> - map中key已经存在，覆盖替换
> - map中key不存在，新增

```java
Map newMap = new HashMap();
newMap.put("map4","map4");
newMap.put("map5","map5");
redisTemplate.opsForHash().putAll("hashValue",newMap);
```

### 10、multiGet(H key, Collection var2)

> 以集合的方式获取这些键对应的map

```java
List list = new ArrayList<>();
list.add("map1");
list.add("map2");
List hashValue = redisTemplate.opsForHash().multiGet("hashValue", list);
System.out.println("hashValue = " + hashValue);	//hashValue = [value1,value2]
```

### 11、lengthOfValue(H key, HK var2)

> 获取指定key对应的map集合中，指定键对应的值的长度

```java
Long aLong = redisTemplate.opsForHash().lengthOfValue("hashValue", "map1");
System.out.println("aLong = " + aLong);	//=6
```

### 12、increment(H key, HK var2, long long1)

> 使key对应的map中，键var2对应的值以long1自增

```java
Long increment = redisTemplate.opsForHash().increment("hashValue", "map7", 1);
System.out.println("increment = " + increment);//=1
//{map7=1}
```

### 13、increment(H key, HK var2, double d1)

> 使key对应的map中，键var2对应的值以double类型d1自增

```java
Double increment = redisTemplate.opsForHash().increment("hashValue", "map8", 1.2);
System.out.println("increment = " + increment);//increment=1.2
//{map8=1.2}
```

### 14、scan(H var1, ScanOptions var2)

> 匹配获取键值对
>
> - ScanOptions.NONE为获取全部键对
> - ScanOptions.scanOptions().match(“map1”).build()，匹配获取键位map1的键值对,不能模糊匹配

```java
Cursor<Map.Entry<Object,Object>> cursor = redisTemplate.opsForHash().scan("hashValue",ScanOptions.scanOptions().match("map1").build());
//Cursor<Map.Entry<Object,Object>> cursor = redisTemplate.opsForHash().scan("hashValue",ScanOptions.NONE);
    while (cursor.hasNext()) {
        Map.Entry<Object, Object> entry = cursor.next();
        System.out.println("entry.getKey() = " + entry.getKey());
        System.out.println("entry.getValue() = " + entry.getValue());
    }

输出：
entry.getKey() = map1
entry.getValue() = value1
```

### 15、delete(H key, Object… var2)

> 删除key对应的map中的键值对

```java
Long delete = redisTemplate.opsForHash().delete("hashValue", "map1", "map2");
System.out.println("delete = " + delete);	//true
```

### 16、拓展

> map中存储对象、对象集合时最好转为JSON字符串，容易解析
>
> map中键值对都可以存为对象、对象集合JSON字符串，具体看实际应用存储

```java
List<MPEntity> list = mpService.list();
redisTemplate.opsForHash().put("hashValue",JSON.toJSONString(list),JSON.toJSONString(list));
//或者mapKey用redisTemplate.opsForHash().put("hashValue","objectKey",JSON.toJSONString(list));
```

![image-20211031141646718](https://img-blog.csdnimg.cn/img_convert/c24612e02f8e8c1e495a7d0b3dc06bbb.png)





-----

# [Java中使用Redis][https://blog.csdn.net/zspppppp/article/details/84847323]

**redis的安装(windows)**
安装版和解压版,解压版需要配置环境变量
下载地址 : https://github.com/MSOpenTech/redis/releases

**启动redis**
cmd窗口中输入 redis-server.exe (确保redis路径已加入环境变量中)

启动成功后显示,此窗口关闭redis服务器也就会关闭 默认端口6379

**连接redis**
此时打开另一个cmd窗口,输入 redis-cli.exe -h 127.0.0.1 -p 6379

显示host和端口号即为成功
简单的redis操作可以参考 http://doc.redisfans.com/

## java中利用jedis连接redis

maven依赖如下 此处为jdk1.7 redis3.2 jedis2.4是没有问题的(如有报错尝试更换版本)

```xml
        <!-- 引入redis客户端依赖 -->
 		<dependency>
		    <groupId>redis.clients</groupId>
		    <artifactId>jedis</artifactId>
		    <version>2.4.2</version>
		</dependency>
```

测试类如下:

```java
package com.zzipsun.test;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import redis.clients.jedis.Jedis;

/**
 * @author zs
 */
public class RedisTest {

	    public static void main(String[] args) {
	        //连接本地的 Redis 服务
	        Jedis jedis = new Jedis("localhost");
	        System.out.println("连接成功");
	        //查看服务是否运行
	        System.out.println("服务正在运行: "+jedis.ping());
	        //存储数据到列表中
	        jedis.lpush("site-list", "Runoob");
	        jedis.lpush("site-list", "Google");
	        jedis.lpush("site-list", "Taobao");
	        // 获取存储的数据并输出
	        List<String> list = jedis.lrange("site-list", 0 ,0);
	        for(int i=0; i<list.size(); i++) {
	            System.out.println("列表项为: "+list.get(i));
	        }
	        // 获取数据并输出
	        Set<String> keys = jedis.keys("*"); 
	        Iterator<String> it=keys.iterator() ;   
	        while(it.hasNext()){   
	            String key = it.next();   
	            System.out.println(key);   
	        }
	    }
}
```

成功输出即为连接成功
![在这里插入图片描述](https://img-blog.csdnimg.cn/img_convert/08521055822327751399173163da1d30.png)

## spring集成redis

(1)
***(此处因与spring(4.1)版本和redis-client(2.4.2)版本可能会出现较多问题,此处版本组合是没有问题的,如有问题尝试更换版本…)***
引入spring-data-redis.jar包

```xml
<!-- spring-redis实现 -->
	<dependency>
        <groupId>org.springframework.data</groupId>
        <artifactId>spring-data-redis</artifactId>
        <version>1.3.4.RELEASE</version>
    </dependency>     
```
(2)
redis.properties 配置文件

```yaml
#访问地址
host=127.0.0.1
#访问端口
port=6379
#注意，如果没有password，此处不设置值，但这一项要保留
password=
 #数据库下标
 dbIndex=0
#最大空闲数，数据库连接的最大空闲时间。超过空闲时间，数据库连接将被标记为不可用，然后被释放。设为0表示无限制。
maxIdle=300
#连接池的最大数据库连接数。设为0表示无限制
maxActive=600
#最大建立连接等待时间。如果超过此时间将接到异常。设为-1表示无限制。
maxWait=1000
#在borrow一个jedis实例时，是否提前进行alidate操作；如果为true，则得到的jedis实例均是可用的；
testOnBorrow=true
```

(3)
spring-redis配置文件(此处包含了数据库和mybatis的配置)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:context="http://www.springframework.org/schema/context" 
	xmlns:jdbc="http://www.springframework.org/schema/jdbc"  
	xmlns:jee="http://www.springframework.org/schema/jee" 
	xmlns:tx="http://www.springframework.org/schema/tx"
	xmlns:aop="http://www.springframework.org/schema/aop" 
	xmlns:mvc="http://www.springframework.org/schema/mvc"
	xmlns:util="http://www.springframework.org/schema/util"
	xmlns:jpa="http://www.springframework.org/schema/data/jpa"
	xsi:schemaLocation="
		http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.1.xsd
		http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.1.xsd
		http://www.springframework.org/schema/jdbc http://www.springframework.org/schema/jdbc/spring-jdbc-4.1.xsd
		http://www.springframework.org/schema/jee http://www.springframework.org/schema/jee/spring-jee-4.1.xsd
		http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.1.xsd
		http://www.springframework.org/schema/data/jpa http://www.springframework.org/schema/data/jpa/spring-jpa-1.3.xsd
		http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.1.xsd
		http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-4.1.xsd
		http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util-4.1.xsd">
	
	<!-- 配置 spring-mybatis.xml -->
	<!-- 读取配置文件 -->
 	<util:properties id="redis"
		location="classpath:conf/redis.properties"/> 	 
	<util:properties id="jdbc"
		location="classpath:conf/jdbc.properties"/> 

	<!-- 配置数据库连接池 -->
	<bean id="dataSource"
		class="org.apache.commons.dbcp.BasicDataSource"
		destroy-method="close"> 
		<property name="driverClassName"
			value="#{jdbc.driver}"/>
		<property name="url"
			value="#{jdbc.url}"/>
		<property name="username"
			value="#{jdbc.user}"/>
		<property name="password"
			value="#{jdbc.password}"/>
		<property name="maxIdle"
			value="#{jdbc.maxIdle}"/>
		<property name="maxWait"
			value="#{jdbc.maxWait}"/>						
		<property name="maxActive"
			value="#{jdbc.maxActive}"/>
		<property name="defaultAutoCommit"
			value="#{jdbc.defaultAutoCommit}"/>
		<property name="defaultReadOnly"
			value="#{jdbc.defaultReadOnly}"/>
		<property name="testOnBorrow"
			value="#{jdbc.testOnBorrow}"/>			
		<property name="validationQuery"
			value="#{jdbc.validationQuery}"/>	
	</bean>
	
	<!-- 配置MyBatis的 SessionFactory -->
	<bean id="sqlSessionFactory"
		class="org.mybatis.spring.SqlSessionFactoryBean">
		<property name="dataSource"
			 ref="dataSource"/>
		
		<property name="mapperLocations"
			value="classpath:mapper/*.xml"/>

	</bean>
	<!-- Mapper接口组件扫描 -->
	<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
		<property name="basePackage" 
			value="com.zzipsun.dao"/>
	</bean>
	
	<!--  transaction config related... -->	
	<bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
		<property name="dataSource"
			ref="dataSource"/>
	</bean>
	<!-- 设置 注解驱动的事务管理  -->
	<tx:annotation-driven 
		transaction-manager="txManager"/>
		
		
    <!-- redis config start -->
    <!-- 配置JedisPoolConfig实例 -->
     <bean id="poolConfig" class="redis.clients.jedis.JedisPoolConfig">
        <property name="maxIdle" value="#{redis.maxIdle}" />
        <property name="maxTotal" value="#{redis.maxActive}" />
        <property name="maxWaitMillis" value="#{redis.maxWait}" />
        <property name="testOnBorrow" value="#{redis.testOnBorrow}" />
    </bean>

   <!--  配置JedisConnectionFactory -->
    <bean id="jedisConnectionFactory"
        class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
        <property name="hostName" value="#{redis.host}" />
        <property name="port" value="#{redis.port}" />
       <!--  <property name="password" value="#{redis.password}" /> -->
        <property name="database" value="#{redis.dbIndex}" />
        <property name="poolConfig" ref="poolConfig" />
    </bean>
    <!-- 配置RedisTemplate -->
     <bean id="redisTemplate" class="org.springframework.data.redis.core.RedisTemplate">
        <property name="connectionFactory" ref="jedisConnectionFactory" />
                <!--     如果不配置Serializer，那么存储的时候只能使用String，如果用对象类型存储，那么会提示错误 can't cast to String！！！-->
        <property name="keySerializer">
            <bean class="org.springframework.data.redis.serializer.StringRedisSerializer"/>
        </property>
        <property name="valueSerializer">
            <bean class="org.springframework.data.redis.serializer.JdkSerializationRedisSerializer"/>
        </property>
    </bean> 

    <!--自定义redis工具类,在需要缓存的地方注入此类  -->
    <bean id="redisUtil" class="com.zzipsun.util.RedisUtil">
    	<property name="redisTemplate" ref="redisTemplate" />
    </bean>
	
</beans>
```

(4)
redis工具类(此处try catch为防止redis宕机等问题时 方法可以继续执行)

```java
package com.zzipsun.util;
 
 
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
 
/**
 * 
 * @author 
 * 基于spring和redis的redisTemplate工具类
 * 针对所有的hash 都是以h开头的方法
 * 针对所有的Set 都是以s开头的方法                    不含通用方法
 * 针对所有的List 都是以l开头的方法
 */
@Component("redisUtil")
public class RedisUtil {
 
 
	private RedisTemplate<String, Object> redisTemplate;
	
	public void setRedisTemplate(RedisTemplate<String, Object> redisTemplate) {
		this.redisTemplate = redisTemplate;
	}
	//=============================common============================
	/**
	 * 指定缓存失效时间
	 * @param key 键
	 * @param time 时间(秒)
	 * @return
	 */
	public boolean expire(String key,long time){
		try {
			if(time>0){
				redisTemplate.expire(key, time, TimeUnit.SECONDS);
			}
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/**
	 * 根据key 获取过期时间
	 * @param key 键 不能为null
	 * @return 时间(秒) 返回0代表为永久有效
	 */
	public long getExpire(String key){
		return redisTemplate.getExpire(key,TimeUnit.SECONDS);
	}
	
	/**
	 * 判断key是否存在
	 * @param key 键
	 * @return true 存在 false不存在
	 */
	public boolean hasKey(String key){
		try {
			return redisTemplate.hasKey(key);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/**
	 * 删除缓存
	 * @param key 可以传一个值 或多个
	 */
	@SuppressWarnings("unchecked")
	public void del(String ... key){
		if(key!=null&&key.length>0){
			if(key.length==1){
				redisTemplate.delete(key[0]);
			}else{
				redisTemplate.delete(CollectionUtils.arrayToList(key));
			}
		}
	}
	
	//============================String=============================
	/**
	 * 普通缓存获取
	 * @param key 键
	 * @return 值
	 */
	public Object get(String key){
		return key==null?null:redisTemplate.opsForValue().get(key);
	}
	
	/**
	 * 普通缓存放入
	 * @param key 键
	 * @param value 值
	 * @return true成功 false失败
	 */
	public boolean set(String key,Object value) {
		 try {
			redisTemplate.opsForValue().set(key, value);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		
	}
	
	/**
	 * 普通缓存放入并设置时间
	 * @param key 键
	 * @param value 值
	 * @param time 时间(秒) time要大于0 如果time小于等于0 将设置无限期
	 * @return true成功 false 失败
	 */
	public boolean set(String key,Object value,long time){
		try {
			if(time>0){
				redisTemplate.opsForValue().set(key, value, time, TimeUnit.SECONDS);
			}else{
				set(key, value);
			}
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/**
	 * 递增
	 * @param key 键
	 * @param by 要增加几(大于0)
	 * @return
	 */
	public long incr(String key, long delta){  
		if(delta<0){
			throw new RuntimeException("递增因子必须大于0");
		}
		return redisTemplate.opsForValue().increment(key, delta);
    }
	
	/**
	 * 递减
	 * @param key 键
	 * @param by 要减少几(小于0)
	 * @return
	 */
	public long decr(String key, long delta){  
		if(delta<0){
			throw new RuntimeException("递减因子必须大于0");
		}
        return redisTemplate.opsForValue().increment(key, -delta);  
    }  
	
	//================================Map=================================
	/**
	 * HashGet
	 * @param key 键 不能为null
	 * @param item 项 不能为null
	 * @return 值
	 */
	public Object hget(String key,String item){
		try {
			return redisTemplate.opsForHash().get(key, item);
		} catch (Exception e) {
			return  null;
		}
	}
	
	/**
	 * 获取hashKey对应的所有键值
	 * @param key 键
	 * @return 对应的多个键值
	 */
	public Map<Object,Object> hmget(String key){
		return redisTemplate.opsForHash().entries(key);
	}
	
	/**
	 * HashSet
	 * @param key 键
	 * @param map 对应多个键值
	 * @return true 成功 false 失败
	 */
	public boolean hmset(String key, Map<String,Object> map){  
        try {
			redisTemplate.opsForHash().putAll(key, map);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
    }
	
	/**
	 * HashSet 并设置时间
	 * @param key 键
	 * @param map 对应多个键值
	 * @param time 时间(秒)
	 * @return true成功 false失败
	 */
    public boolean hmset(String key, Map<String,Object> map, long time){  
        try {
			redisTemplate.opsForHash().putAll(key, map);
			if(time>0){
				expire(key, time);
			}
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
    }
	
	/**
	 * 向一张hash表中放入数据,如果不存在将创建
	 * @param key 键
	 * @param item 项
	 * @param value 值
	 * @return true 成功 false失败
	 */
	public boolean hset(String key,String item,Object value) {
		 try {
			redisTemplate.opsForHash().put(key, item, value);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/**
	 * 向一张hash表中放入数据,如果不存在将创建
	 * @param key 键
	 * @param item 项
	 * @param value 值
	 * @param time 时间(秒)  注意:如果已存在的hash表有时间,这里将会替换原有的时间
	 * @return true 成功 false失败
	 */
	public boolean hset(String key,String item,Object value,long time) {
		 try {
			redisTemplate.opsForHash().put(key, item, value);
			if(time>0){
				expire(key, time);
			}
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/**
	 * 删除hash表中的值
	 * @param key 键 不能为null
	 * @param item 项 可以使多个 不能为null
	 */
    public void hdel(String key, Object... item){  
		redisTemplate.opsForHash().delete(key,item);
    } 
    
    /**
     * 判断hash表中是否有该项的值
     * @param key 键 不能为null
     * @param item 项 不能为null
     * @return true 存在 false不存在
     */
    public boolean hHasKey(String key, String item){
		return redisTemplate.opsForHash().hasKey(key, item);
    } 
	
	/**
	 * hash递增 如果不存在,就会创建一个 并把新增后的值返回
	 * @param key 键
	 * @param item 项
	 * @param by 要增加几(大于0)
	 * @return
	 */
	public double hincr(String key, String item,double by){  
        return redisTemplate.opsForHash().increment(key, item, by);
    }
	
	/**
	 * hash递减
	 * @param key 键
	 * @param item 项
	 * @param by 要减少记(小于0)
	 * @return
	 */
	public double hdecr(String key, String item,double by){  
        return redisTemplate.opsForHash().increment(key, item,-by);  
    }  
	
	//============================set=============================
	/**
	 * 根据key获取Set中的所有值
	 * @param key 键
	 * @return
	 */
	public Set<Object> sGet(String key){
		try {
			return redisTemplate.opsForSet().members(key);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * 根据value从一个set中查询,是否存在
	 * @param key 键
	 * @param value 值
	 * @return true 存在 false不存在
	 */
	public boolean sHasKey(String key,Object value){
		try {
			return redisTemplate.opsForSet().isMember(key, value);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/**
	 * 将数据放入set缓存
	 * @param key 键
	 * @param values 值 可以是多个
	 * @return 成功个数
	 */
	public long sSet(String key, Object...values) {
        try {
            return redisTemplate.opsForSet().add(key, values);
        } catch (Exception e) {
        	e.printStackTrace();
        	return 0;
        }
    }
	
	/**
	 * 将set数据放入缓存
	 * @param key 键
	 * @param time 时间(秒)
	 * @param values 值 可以是多个
	 * @return 成功个数
	 */
	public long sSetAndTime(String key,long time,Object...values) {
        try {
        	Long count = redisTemplate.opsForSet().add(key, values);
        	if(time>0) expire(key, time);
            return count;
        } catch (Exception e) {
        	e.printStackTrace();
        	return 0;
        }
    }
	
	/**
	 * 获取set缓存的长度
	 * @param key 键
	 * @return
	 */
	public long sGetSetSize(String key){
		try {
			return redisTemplate.opsForSet().size(key);
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}
	
	/**
	 * 移除值为value的
	 * @param key 键
	 * @param values 值 可以是多个
	 * @return 移除的个数
	 */
	public long setRemove(String key, Object ...values) {
        try {
            Long count = redisTemplate.opsForSet().remove(key, values);
            return count;
        } catch (Exception e) {
        	e.printStackTrace();
        	return 0;
        }
    }
    //===============================list=================================
    
	/**
	 * 获取list缓存的内容
	 * @param key 键
	 * @param start 开始
	 * @param end 结束  0 到 -1代表所有值
	 * @return
	 */
	public List<Object> lGet(String key,long start, long end){
		try {
			return redisTemplate.opsForList().range(key, start, end);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * 获取list缓存的长度
	 * @param key 键
	 * @return
	 */
	public long lGetListSize(String key){
		try {
			return redisTemplate.opsForList().size(key);
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}
	
	/**
	 * 通过索引 获取list中的值
	 * @param key 键
	 * @param index 索引  index>=0时， 0 表头，1 第二个元素，依次类推；index<0时，-1，表尾，-2倒数第二个元素，依次类推
	 * @return
	 */
	public Object lGetIndex(String key,long index){
		try {
			return redisTemplate.opsForList().index(key, index);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * 将list放入缓存
	 * @param key 键
	 * @param value 值
	 * @param time 时间(秒)
	 * @return
	 */
	public boolean lSet(String key, Object value) {
        try {
            redisTemplate.opsForList().rightPush(key, value);
            return true;
        } catch (Exception e) {
        	e.printStackTrace();
        	return false;
        }
    }
	
	/**
	 * 将list放入缓存
	 * @param key 键
	 * @param value 值
	 * @param time 时间(秒)
	 * @return
	 */
	public boolean lSet(String key, Object value, long time) {
        try {
            redisTemplate.opsForList().rightPush(key, value);
            if (time > 0) expire(key, time);
            return true;
        } catch (Exception e) {
        	e.printStackTrace();
        	return false;
        }
    }
	
	/**
	 * 将list放入缓存
	 * @param key 键
	 * @param value 值
	 * @param time 时间(秒)
	 * @return
	 */
	public boolean lSet(String key, List<Object> value) {
	    try {
			redisTemplate.opsForList().rightPushAll(key, value);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
    }
	
	/**
	 * 将list放入缓存
	 * @param key 键
	 * @param value 值
	 * @param time 时间(秒)
	 * @return
	 */
	public boolean lSet(String key, List<Object> value, long time) {
	    try {
			redisTemplate.opsForList().rightPushAll(key, value);
			if (time > 0) expire(key, time);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
    }
	
	/**
	 * 根据索引修改list中的某条数据
	 * @param key 键
	 * @param index 索引
	 * @param value 值
	 * @return
	 */
	public boolean lUpdateIndex(String key, long index,Object value) {
	    try {
			redisTemplate.opsForList().set(key, index, value);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
    } 
	
	/**
	 * 移除N个值为value 
	 * @param key 键
	 * @param count 移除多少个
	 * @param value 值
	 * @return 移除的个数
	 */
	public long lRemove(String key,long count,Object value) {
		try {
			Long remove = redisTemplate.opsForList().remove(key, count, value);
			return remove;
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}
}
```

(5)
将spring-redis.xml包含到web.xml中

```xml
  <servlet>
    <description></description>
    <display-name>DispatcherServlet</display-name>
    <servlet-name>DispatcherServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
      <description></description>
      <param-name>contextConfigLocation</param-name>
      <param-value>classpath:conf/spring-*.xml</param-value>  --此处包含所有spring配置文件
    </init-param>
    <load-on-startup>1</load-on-startup>
  </servlet>
```

(6)
在需要redis的业务类中注入redisUtil
此处用一个方法理解redis的使用

```java
/**
 * ArticleServiceImp.java
 */
package com.zzipsun.service.imp;

import java.sql.Array;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.zzipsun.dao.ArticleDao;
import com.zzipsun.entity.Article;
import com.zzipsun.service.base.ArticleService;
import com.zzipsun.util.Log4JUtil;
import com.zzipsun.util.RedisUtil;

/**
 * @author zs
 *
 */
@Service("articleService")
public class ArticleServiceImp implements ArticleService {
	Logger log=Logger.getLogger(ArticleServiceImp.class);
@Resource
ArticleDao  articleDao;
@Value("#{jdbc.pagesize}")
int  pageSize;
@Resource
RedisUtil redisUtil;

	/* (non-Javadoc)
	 * @see com.zzipsun.service.base.ArticleService#findArticleById(java.lang.String)
	 */
	//查看一个文章
	public Article findArticleById(String articleId) {
		if(articleId.trim()==""||articleId==null) {
			throw new RuntimeException("您查看的文章找不到了");
		}
		//尝试从redis缓冲中获取map中的article实体对象
		Article article=(Article)redisUtil.hget("article", articleId);
		if(article!=null) {
			log.debug("redis中的id为"+articleId+"的article标题为"+article.getTitle());
		}
		//如果redis缓存中不存在此文章
		if(article==null) {
			//数据库查询
			article=articleDao.findArticleById(articleId);
			//存入redis中
			redisUtil.hset("article", articleId, article);
		}
		return article;
	}
}
```

