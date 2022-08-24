# [浅析redis setIfAbsent的用法及在分布式锁上的应用及同步锁的缺陷](https://www.cnblogs.com/goloving/p/16026003.html)

## 一、业务场景：同步锁的问题与分布式锁的应用

1、redis的基本命令

（1）SETNX命令（SET if Not eXists）

　　语法：SETNX key value

　　功能：当且仅当 key 不存在，将 key 的值设为 value ，并返回1；若给定的 key 已经存在，则 SETNX 不做任何动作，并返回0。

（2）expire命令

　　语法：expire KEY seconds

　　功能：设置key的过期时间。如果key已过期，将会被自动删除。

（3）DEL命令

　　语法：DEL key [KEY …]

　　功能：删除给定的一个或多个 key，不存在的 key 会被忽略。

2、实现同步锁原理

（1）加锁：“锁”就是一个存储在redis里的key-value对，key是把一组操作用字符串来形成唯一标识，value其实并不重要，因为只要这个唯一的key-value存在，就表示这个操作已经上锁。

（2）解锁：既然key-value对存在就表示上锁，那么释放锁就自然是在redis里删除key-value对

（3）阻塞、非阻塞：阻塞式的实现，若线程发现已经上锁，会在特定时间内轮询锁。非阻塞式的实现，若发现线程已经上锁，则直接返回。

（4）处理异常情况：假设当投资操作调用其他平台接口出现等待时，自然没有释放锁，这种情况下加入锁超时机制，用redis的expire命令为key设置超时时长，过了超时时间redis就会将这个key自动删除，即强制释放锁

![img](https://img2022.cnblogs.com/blog/1158910/202203/1158910-20220319130046926-1102259642.png)

3、使用redis锁还是出现同步问题

　　一种可能是，2台机器同时访问，一台访问，还没有把锁设置过去的时候，另一台也查不到就会出现这个问题。

　　解决方法：这跟写代码的方式有关。先查，如果不存在就set，这种方式有极微小的可能存在时间差，导致锁set了2次。

　　**推荐使用 setIfAbsent 这样在 redis set 的时候是单线程的，不会存在重复的问题**。

## 二、setIfAbsent的使用

1、作用：如果为空就set值，并返回1；如果存在(不为空)不进行操作，并返回0。

　　很明显，比get和set要好。因为先判断get，再set的用法，有可能会重复set值。

2、setIfAbsent 和 setnx

　　**setIfAbsent 是java中的方法（redisTemplate.setlfAbsent）**

　　**setnx 是 redis命令中的方法（直接在redis客户端执行的命令行）**

```sql
redis> SETNX mykey "Hello"  // 不存在mykey，设置值并返回1
(integer) 1
redis> SETNX mykey "World"  // 存在mykey，不处理并返回0
(integer) 0
redis> GET mykey
"Hello"
```

```java
BoundValueOperations boundValueOperations = this.redisTemplate.boundValueOps(redisKey);
flag = boundValueOperations.setIfAbsent(value); // flag 表示是否set
boundValueOperations.expire(seconds, TimeUnit.SECONDS);
if(!flag){ // 重复
    repeatSerial.add(serialNo);
    continue;
}else{// 没有重复
    norepeatSerial.add(serialNo);
}
```

3、需要注意的是以前 stringRedisTemplate.setIfAbsent()  在服务器是由2个命令组成的  完成一个setnx时候在设置 expire 时候中间中断了，无法保证原子性。

　　故需要使用 4 个参数的那个重载方法，**这个底层是 set key value [EX seconds] [PX milliseconds] [NX|XX] 是原子性的**

```java
public Boolean setIfAbsent(K key, V value, long timeout, TimeUnit unit) {
  byte[] rawKey = rawKey(key);
  byte[] rawValue = rawValue(value);
  Expiration expiration = Expiration.from(timeout, unit);
  return execute(connection -> connection.set(rawKey, rawValue, expiration, SetOption.ifAbsent()), true);
} 
```

## 三、如何使用呢？分布式锁

1、应用场景：比如我们有2台服务器，4个镜像节点，那么就会有4个负载均衡的后台服务，如果你需要在代码里加一个定时任务。那么最后4个后台服务都会执行这个定时任务，就会重复4次。

2、怎么办呢？加分布式锁，就会用到上面的方法咯。

3、分布式锁实现中可能遇到的问题：看这篇文章，关于stringRedisTemplate.setIfAbsent()并设置过期时间遇到的问题：关于stringRedisTemplate.setIfAbsent()并设置过期时间遇到的问题[https://blog.csdn.net/weixin_34419326/article/details/88677793]，主要注意一下几点：

## 关于stringRedisTemplate.setIfAbsent()并设置过期时间遇到的问题

spring-date-redis版本：1.6.2
场景：在使用`setIfAbsent(key,value)`时，想对key设置一个过期时间，同时需要用到`setIfAbsent`的返回值来指定之后的流程，所以使用了以下代码：

```java
boolean store = stringRedisTemplate.opsForValue().setIfAbsent(key,value);
if(store){
  stringRedisTemplate.expire(key,timeout); 
  // todo something...  
}
```

这段代码是有问题的：==**当setIfAbsent成功之后发生异常连接断开，下面设置过期时间的代码` stringRedisTemplate.expire(key,timeout); `是无法执行的，这时候就会有大量没有过期时间的数据存在数据库。想到一个办法就是添加事务管理，让set和expire绑定为一个原子性操作**==，修改后的代码如下：

```java
stringRedisTemplate.setEnableTransactionSupport(true);
stringRedisTemplate.multi();	//事务开启
boolean store = stringRedisTemplate.opsForValue().setIfAbsent(key,value);
if(store){
  stringRedisTemplate.expire(key,timeout);   
}
stringRedisTemplate.exec();		//开始执行事务
if(store){
    // todo something...
}
```

这样就保证了整个流程的一致性。本因为这样就可以了，可是事实总是不尽人意，因为我在文档中发现了以下内容：
![图片描述](https://image-static.segmentfault.com/245/056/2450560702-5c4085a839298_articlex)

==**加了事务管理之后，setIfAbsent的返回值竟然是null（因为加了事务的set不会立即执行，只有.exec才会开始执行事务里的所有操作）**==，这样就没办法再进行之后的判断了。

好吧，继续解决：

```java
stringRedisTemplate.setEnableTransactionSupport(true);
stringRedisTemplate.multi();
String result = stringRedisTemplate.opsForValue().get(key);
if(StringUtils.isNotBlank(result)){
    return false;
}
// 锁的过期时间为1小时
stringRedisTemplate.opsForValue().set(key, value,timeout);
stringRedisTemplate.exec();
 
// todo something...
```

**上边的代码其实还是有问题的，当出现并发时，`String result = stringRedisTemplate.opsForValue().get(key);` 这里就会有多个线程同时拿到为空的key，然后同时写入脏数据。**

**最终解决方法：**

1. 使用`stringRedisTemplate.exec();`的返回值判断setIfAbsent是否成功

```java
stringRedisTemplate.setEnableTransactionSupport(true);
stringRedisTemplate.multi();	//事务开启
stringRedisTemplate.opsForValue().setIfAbsent(lockKey,JSON.toJSONString(event));
stringRedisTemplate.expire(lockKey,Constants.REDIS_KEY_EXPIRE_SECOND_1_HOUR, TimeUnit.SECONDS);
List result = stringRedisTemplate.exec(); // 开始执行事务，这里result会返回事务内每一个操作的结果，如果setIfAbsent操作失败后，result[0]会为false。
if(true == result[0]){
  // todo something...
}
```

2、将redis版本升级到2.1以上，然后使用，**（推荐）**

![图片描述](https://image-static.segmentfault.com/226/472/2264721493-5c4087e785d20_articlex)
直接在setIfAbsent中设置过期时间

**update :**
java 使用redis的事务时不能直接用Api中的multi()和exec()，这样multi()和exec()两次使用的stringRedisTemplate不是一个connect，会导致死锁，正确方式如下：

```java
    private Boolean setLock(RecordEventModel event) {
        String lockKey = event.getModel() + ":" + event.getAction() + ":" + event.getId() + ":" + event.getMessage_id();
        log.info("lockKey : {}" , lockKey);
        SessionCallback<Boolean> sessionCallback = new SessionCallback<Boolean>() {
            List<Object> exec = null;
            @Override
            @SuppressWarnings("unchecked")
            public Boolean execute(RedisOperations operations) throws DataAccessException {
                operations.multi();
                stringRedisTemplate.opsForValue().setIfAbsent(lockKey,JSON.toJSONString(event));
                stringRedisTemplate.expire(lockKey,Constants.REDIS_KEY_EXPIRE_SECOND_1_HOUR, TimeUnit.SECONDS);
                exec = operations.exec();
                if(exec.size() > 0) {
                    return (Boolean) exec.get(0);
                }
                return false;
            }
        };
        return stringRedisTemplate.execute(sessionCallback);
    }
```




  