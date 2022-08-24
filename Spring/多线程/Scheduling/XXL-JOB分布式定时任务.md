# [XXLJOB任务调度中心-关于路由策略配置说明](https://www.jianshu.com/p/4e320a60bd0d)

**1.第一个：** 当选择该策略时，会选择执行器注册地址的第一台机器执行，如果第一台机器出现故障，则调度任务失败。

**2.最后一个：** 当选择该策略时，会选择执行器注册地址的最后台机器执行，如果第二台机器出现故障，则调度任务失败。

**3.轮询：** 当选择该策略时，会按照执行器注册地址轮询分配任务，如果其中一台机器出现故障，调度任务失败，任务不会转移（即该定时任务会执行失败，不会自动跳转到其他机器上执行）。（常用）
4.**随机**： 当选择该策略时，会按照执行器注册地址随机分配任务，如果其中一台机器出现故障，调度任务失败，任务不会转移。

5.**一致性HASH**： 当选择该策略时，每个任务按照Hash算法固定选择某一台机器。如果那台机器出现故障，调度任务失败，任务不会转移。配置阻塞处理策略为丢弃后续调度，多节点集群适用。

6.**最不经常使用**： 当选择该策略时，会优先选择使用频率最低的那台机器，如果其中一台机器出现故障，调度任务失败，任务不会转移。（实践表明效果和轮询策略一致）

7**.最近最久未使用：** 当选择该策略时，会优先选择最久未使用的机器，如果其中一台机器出现故障，调度任务失败，任务不会转移。（实践表明效果和轮询策略一致）

8.**故障转移**： 当选择该策略时，按照顺序依次进行心跳检测，如果其中一台机器出现故障，则会转移到下一个执行器，若心跳检测成功，会选定为目标执行器并发起调度。

9.**忙碌转移：** 当选择该策略时，按照顺序依次进行空闲检测，如果其中一台机器出现故障，则会转移到下一个执行器，若空闲检测成功，会选定为目标执行器并发起调度。

10.**分片广播：** 当选择该策略时，广播触发对应集群中所有机器执行一次任务，同时系统自动传递分片参数；可根据分片参数开发分片任务。如果其中一台机器出现故障，则该执行器执行失败，不会影响其他执行器。



# [XXL-JOB的路由策略](https://blog.csdn.net/abcd930704/article/details/123813422)

## 1.概述

xxl-job就是因为内涵丰富的调度策略，使得[框架](https://so.csdn.net/so/search?q=框架&spm=1001.2101.3001.7020)的多样性，灵活性更高。现在就开始讲解xxl-job的核心路由策略算法，总共有10种路由策略，对于以后想从事分布式微服务开发，任务调度的学习是很有必要的。

## 2.路由策略种类

第一个
最后一个
随机选取
轮询选取
一致性hash
最不经常使用 (LFU)
最近最久未使用（LRU）
故障转移
忙碌转移
分片广播
以上就是xxl-job内部封装的路由策略算法，也是很常见的路由算法，学习掌握之后对自己设计[分布式](https://so.csdn.net/so/search?q=分布式&spm=1001.2101.3001.7020)架构很有帮助。

## 3.xxl-job路由策略源码实现

### 3.1第一个

```java
package com.xxl.job.admin.core.route.strategy;
 
import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;
 
import java.util.List;
 
/**
 \* Created by xuxueli on 17/3/10.
 */
public class ExecutorRouteFirst extends ExecutorRouter {
 
    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList){
        return new ReturnT<String>(addressList.get(0));
    }
 
}
```


看代码就很容易理解，获取当前传入的执行器的注册地址集合的第一个。

### 3.2最后一个

```java
package com.xxl.job.admin.core.route.strategy;
 
import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;
 
import java.util.List;
 
/**
 \* Created by xuxueli on 17/3/10.
 */
public class ExecutorRouteLast extends ExecutorRouter {
 
    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {
        return new ReturnT<String>(addressList.get(addressList.size()-1));
    }
 
}
```


这个也很容易理解，选取当前传入得执行器的注册地址集合的最后一个，下标从0开始   最后一个为addressList.size()-1

### 3.3随机选取

```java
package com.xxl.job.admin.core.route.strategy;
 
import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;
 
import java.util.List;
import java.util.Random;
 
/**
 \* Created by xuxueli on 17/3/10.
 */
public class ExecutorRouteRandom extends ExecutorRouter {
 
    private static Random localRandom = new Random();
 
    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {
        String address = addressList.get(localRandom.nextInt(addressList.size()));
        return new ReturnT<String>(address);
    }
 
}
```


整个算法核心部分就是通过一个Random对象的nextInt方法在求出[0,addressList.size()）区间内的任意一个地址

### 3.4轮询选取

```java
package com.xxl.job.admin.core.route.strategy;
 
import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;
 
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.IntStream;
 
/**
 \* Created by xuxueli on 17/3/10.
 */
public class ExecutorRouteRound extends ExecutorRouter {
 
    private static ConcurrentMap<Integer, AtomicInteger> routeCountEachJob = new ConcurrentHashMap<>();
    private static long CACHE_VALID_TIME = 0;
 
    private static int count(int jobId) {
        // cache clear
        if (System.currentTimeMillis() > CACHE_VALID_TIME) {
            routeCountEachJob.clear();
            CACHE_VALID_TIME = System.currentTimeMillis() + 1000*60*60*24;
        }
 
        AtomicInteger count = routeCountEachJob.get(jobId);
        if (count == null || count.get() > 1000000) {
            // 初始化时主动Random一次，缓解首次压力
            count = new AtomicInteger(new Random().nextInt(100));
        } else {
            // count++
            count.addAndGet(1);
        }
        routeCountEachJob.put(jobId, count);
        return count.get();
    }
 
    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {
        String address = addressList.get(count(triggerParam.getJobId())%addressList.size());
        return new ReturnT<String>(address);
    }
}
```


这里注意到创建了一个静态的ConcurrentMap对象，这个routeCountEachJob就是用来存放路由任务的，而且还设置了缓存时间，有效期为24小时，当超过24小时的时候，自动的清空当前的缓存。

其中ConcurrentMap的key为jobId，value为当前jobId所对应的计数器，每访问一次就自增一，最大增到100000，然后又从[0，100)的随机数开始重新自增。

这个算法的思想就是取余数，每次先计算出当前jobId所对应的计数器的值，然后 计数器的值 % addressList.size() 求得这一次轮询的地址。

### 3.5一致性hash

```java
package com.xxl.job.admin.core.route.strategy;

import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

/**

- 分组下机器地址相同，不同JOB均匀散列在不同机器上，保证分组下机器分配JOB平均；且每个JOB固定调度其中一台机器；
- a、virtual node：解决不均衡问题
- b、hash method replace hashCode：String的hashCode可能重复，需要进一步扩大hashCode的取值范围
- Created by xuxueli on 17/3/10.
  */
  public class ExecutorRouteConsistentHash extends ExecutorRouter {

    private static int VIRTUAL_NODE_NUM = 100;

    /**
     * get hash code on 2^32 ring (md5散列的方式计算hash值)
     * @param key
     * @return
     */
        private static long hash(String key) {

        // md5 byte
        MessageDigest md5;
        try {
            md5 = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5 not supported", e);
        }
        md5.reset();
        byte[] keyBytes = null;
        try {
            keyBytes = key.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("Unknown string :" + key, e);
        }

        md5.update(keyBytes);
        byte[] digest = md5.digest();

        // hash code, Truncate to 32-bits
        long hashCode = ((long) (digest[3] & 0xFF) << 24)
                | ((long) (digest[2] & 0xFF) << 16)
                | ((long) (digest[1] & 0xFF) << 8)
                | (digest[0] & 0xFF);

        //通过md5算出的hashcode % 2^32 余数，将hash值散列在一致性hash环上  这个环分了2^32个位置
        long truncateHashCode = hashCode & 0xffffffffL;
        return truncateHashCode;
    }

    public String hashJob(int jobId, List<String> addressList) {

        // ------A1------A2-------A3------
        // -----------J1------------------
        TreeMap<Long, String> addressRing = new TreeMap<Long, String>();
        for (String address: addressList) {
            for (int i = 0; i < VIRTUAL_NODE_NUM; i++) {
                //为每一个注册的节点分配100个虚拟节点，并算出这些节点的一致性hash值，存放到TreeMap中
                long addressHash = hash("SHARD-" + address + "-NODE-" + i);
                addressRing.put(addressHash, address);
            }
        }
        //第二步求出job的hash值 通过jobId计算
        long jobHash = hash(String.valueOf(jobId));
        //通过treeMap性质，所有的key都按照从小到大的排序，即按照hash值从小到大排序,通过tailMap 求出>=hash(jobId)的剩余一部分map，该方法调用返回此映射，其键大于或等于jobHash的部分视图。
        SortedMap<Long, String> lastRing = addressRing.tailMap(jobHash);
        if (!lastRing.isEmpty()) {
            //若找到则取第一个key，为带路由的地址
            return lastRing.get(lastRing.firstKey());
        }
        //若本身hash(jobId)为treeMap的最后一个key，则找当前treeMap的第一个key
        return addressRing.firstEntry().getValue();
    }

    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {
        String address = hashJob(triggerParam.getJobId(), addressList);
        return new ReturnT<String>(address);
    }

}
```


一致哈希 是一种特殊的哈希算法。在使用一致哈希算法后，哈希表槽位数（大小）的改变平均只需要对 K/n 个关键字重新映射，其中K是关键字的数量， n是槽位数量。然而在传统的哈希表中，添加或删除一个槽位的几乎需要对所有关键字进行重新映射。

为什么要引入这个算法那，这个算法就是为了解决目前分布式所存在的问题，举个例子：

现在我们有三台Redis服务器,假设编号为0,1,2，每台服务器都缓存了当前最热门的商品详情信息,我们的映射规则是按照 hash(商品的id)%(redis服务器数量)的结果来映射到某一台编号的redis服务器中，

但是突然由于有一天公司商品越来越多，客户流量也越来越大，三台服务器扛不住怎么办啊，那我们就加一台服务器，那么服务器数量就发生了变动，那肯定我们的取余数这个算法重新计算映射的编号就发生了变动，很容易造成大面积缓存失效，造成缓存雪崩，

把所有请求都请求到后端数据库，造成压力过大。为了解决这个问题，就引入了一致性hash算法，即服务节点的变更不会造成大量的哈希重定位。一致性哈希算法由此而生~。

​       这个一致性hash引入之后，若服务器节点数量过少，有几率出现数据倾斜的情况，既大量的数据映射到某一区间，其它区间没有数据映射，造成了资源分配不均匀，为了解决这个问题，xxl-job源码引入了虚拟节点,既将每台服务器的节点都生成所对应的100个虚拟节点，这应少量的服务器节点通过引入虚拟节点，就会加大节点的数量，**==这样大量的节点分配到hash环上是比较均匀的，从而很容易的解决数据分配不均匀问题。==**

### 3.6最不经常使用 (LFU)

**按照频率来排序，取使用频率最小的**

```java
package com.xxl.job.admin.core.route.strategy;

import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**

- 单个JOB对应的每个执行器，使用频率最低的优先被选举
- a(*)、LFU(Least Frequently Used)：最不经常使用，频率/次数
- b、LRU(Least Recently Used)：最近最久未使用，时间
   *
- 算法思想：
- 构建一个作业和地址map    jobid -> addressList
- 第一次随机的将任务所对应的执行器的注册地址编一个序列号
- 然后将执行器的注册地址按照从小到大进行排序
- 筛选过程找第一个序列号最小的作为下一次的路由地址
- 随后将当前选中的地址编号值+1
- 这样最终我们都会挑选编号最小的注册器地址作为下一个路由地址，既最不常使用的
   *
- Created by xuxueli on 17/3/10.
  */
  public class ExecutorRouteLFU extends ExecutorRouter {

    private static ConcurrentMap<Integer, HashMap<String, Integer>> jobLfuMap = new ConcurrentHashMap<Integer, HashMap<String, Integer>>();
    private static long CACHE_VALID_TIME = 0;

    public String route(int jobId, List<String> addressList) {

        // cache clear
        if (System.currentTimeMillis() > CACHE_VALID_TIME) {
            jobLfuMap.clear();
            //有效缓存时间为一天
            CACHE_VALID_TIME = System.currentTimeMillis() + 1000*60*60*24;
        }

        // lfu item init
        HashMap<String, Integer> lfuItemMap = jobLfuMap.get(jobId);     // Key排序可以用TreeMap+构造入参Compare；Value排序暂时只能通过ArrayList；
        if (lfuItemMap == null) {
            lfuItemMap = new HashMap<String, Integer>();
            jobLfuMap.putIfAbsent(jobId, lfuItemMap);   // 避免重复覆盖
        }

        // put new
        for (String address: addressList) {
            if (!lfuItemMap.containsKey(address) || lfuItemMap.get(address) >1000000 ) {
                lfuItemMap.put(address, new Random().nextInt(addressList.size()));  // 初始化时主动Random一次，缓解首次压力
            }
        }
        // remove old
        List<String> delKeys = new ArrayList<>();
        for (String existKey: lfuItemMap.keySet()) {
            if (!addressList.contains(existKey)) {
                delKeys.add(existKey);
            }
        }
        if (delKeys.size() > 0) {
            for (String delKey: delKeys) {
                lfuItemMap.remove(delKey);
            }
        }

        // load least userd count address
        List<Map.Entry<String, Integer>> lfuItemList = new ArrayList<Map.Entry<String, Integer>>(lfuItemMap.entrySet());	//lfuItemMap迭代类-->entry.getKey(),entry.getValue()
        Collections.sort(lfuItemList, new Comparator<Map.Entry<String, Integer>>() {
            @Override
            public int compare(Map.Entry<String, Integer> o1, Map.Entry<String, Integer> o2) {
                return o1.getValue().compareTo(o2.getValue());
            }
        });

        Map.Entry<String, Integer> addressItem = lfuItemList.get(0);
        String minAddress = addressItem.getKey();
        addressItem.setValue(addressItem.getValue() + 1);

        return addressItem.getKey();
    }

    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {
        String address = route(triggerParam.getJobId(), addressList);
        return new ReturnT<String>(address);
    }

}
```

### 3.7最近最久未使用（LRU）

**==按照最近一次使用时间来排序，每次put或get一个元素访问就把该元素放在LinkedHashMap链表最尾部，反之最长时间没访问到的就是最近最久未使用的元素==**

```java
package com.xxl.job.admin.core.route.strategy;

import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**

- 单个JOB对应的每个执行器，最久为使用的优先被选举
- a、LFU(Least Frequently Used)：最不经常使用，频率/次数
- b(*)、LRU(Least Recently Used)：最近最久未使用，时间
   *
- Created by xuxueli on 17/3/10.
  */
  public class ExecutorRouteLRU extends ExecutorRouter {

    private static ConcurrentMap<Integer, LinkedHashMap<String, String>> jobLRUMap = new ConcurrentHashMap<Integer, LinkedHashMap<String, String>>();
    private static long CACHE_VALID_TIME = 0;

    public String route(int jobId, List<String> addressList) {

        // cache clear
        if (System.currentTimeMillis() > CACHE_VALID_TIME) {
            jobLRUMap.clear();
            CACHE_VALID_TIME = System.currentTimeMillis() + 1000*60*60*24;
        }

        // init lru
        LinkedHashMap<String, String> lruItem = jobLRUMap.get(jobId);
        if (lruItem == null) {
            /**

- LinkedHashMap
  accessOrder：true=访问顺序排序（get/put时排序）；false=插入顺序排序；
  - b、removeEldestEntry：新增元素时将会调用，返回true时会删除最老元素；可封装LinkedHashMap并重写该方法，比如定义最大容量，超出是返回true即可实现固定长度的LRU算法；
                 */
                lruItem = new LinkedHashMap<String, String>(16, 0.75f, true);
                jobLRUMap.putIfAbsent(jobId, lruItem);
            }

        // put new
        for (String address: addressList) {
            if (!lruItem.containsKey(address)) {
                lruItem.put(address, address);
            }
        }
        // remove old
        List<String> delKeys = new ArrayList<>();
        for (String existKey: lruItem.keySet()) {
            if (!addressList.contains(existKey)) {
                delKeys.add(existKey);
            }
        }
        if (delKeys.size() > 0) {
            for (String delKey: delKeys) {
                lruItem.remove(delKey);
            }
        }

        // load
        String eldestKey = lruItem.entrySet().iterator().next().getKey();
        String eldestValue = lruItem.get(eldestKey);
        return eldestValue;
    }

    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {
        String address = route(triggerParam.getJobId(), addressList);
        return new ReturnT<String>(address);
    }

}
```

### [关于LinkedHashMap中accessOrder属性的理解](https://blog.csdn.net/qq_35634181/article/details/103833875)

今天学习了使用LinkedHashMap来实现LRU算法，具体的关于LinkedHashMap的深入了解可以查看：Java集合详解5：深入理解LinkedHashMap和LRU缓存这篇文章，在介绍accessOrder属性的时候说accessOrder设置为false时，按照插入顺序，设置为true时，按照访问顺序，不过我在查看JDK1.8的LinkedHashMap的put方法时没有看到关于将节点插入到链表尾部的操作，经过一番查看还是找到了这个操作。

        LinkedHashMap没有对put方法进行重写，使用的是HashMap里面的put方法。

```java
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable {
 
    /**省略无关紧要的代码*/
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
 
    /**
     * Implements Map.put and related methods
     *
     * @param hash hash for key
     * @param key the key
     * @param value the value to put
     * @param onlyIfAbsent if true, don't change existing value
     * @param evict if false, the table is in creation mode.
     * @return previous value, or null if none
     */
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e); //该方法HashMap并没有具体实现，而是LinkedHashMap实现了该方法
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict); //该方法HashMap并没有具体实现，而是LinkedHashMap实现了该方法
        return null;
    }
 
    // Callbacks to allow LinkedHashMap post-actions
    void afterNodeAccess(Node<K,V> p) { }  //这三个方法在HashMap均没有具体的实现
    void afterNodeInsertion(boolean evict) { }
    void afterNodeRemoval(Node<K,V> p) { }
}
```

   在afterNodeAccess和afterNodeInsertion方法中没有找到将节点插入到双向链表的操作，而在afterNodeAccess方法中，会判断accessOrder是否为true，然后将该节点放到尾部(JDK1.8中最后插入的元素放在尾部)。所以可以判断在afterNodeAccess方法之前已经将该节点插入到了双向链表。具体的afterNodeAccess如下：

```java
void afterNodeAccess(Node<K,V> e) { // move node to last
        LinkedHashMap.Entry<K,V> last;
        if (accessOrder && (last = tail) != e) {  //是否按顺序访问，而且判断尾节点是否是当前节点
            LinkedHashMap.Entry<K,V> p =
                (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;
            p.after = null;
            if (b == null) 
                head = a;
            else
                b.after = a;
            if (a != null) 
                a.before = b;
            else
                last = b;
            if (last == null)
                head = p;
            else {
                p.before = last;
                last.after = p;
            }
            tail = p;    //将当前节点置位尾节点
            ++modCount;
        }
    }
```

​        我们可以查看一下LinkedHashMap的newNode方法，该方法重写了HashMap的newNode方法，

```java
    Node<K,V> newNode(int hash, K key, V value, Node<K,V> e) {
        LinkedHashMap.Entry<K,V> p =
            new LinkedHashMap.Entry<K,V>(hash, key, value, e);
        linkNodeLast(p);
        return p;
    }
 
 
    // link at the end of list
    private void linkNodeLast(LinkedHashMap.Entry<K,V> p) {  //该方法会将节点放到双向链表的尾部，也就是最近访问的一个
        LinkedHashMap.Entry<K,V> last = tail;	//引用传递的是对象地址值
        tail = p;				//改变tail为p的地址，并没有改变last的值
        if (last == null)		//如果之前tail为null，tail=p之后last依旧为null不变
            head = p;
        else {
            p.before = last;
            last.after = p;
        }
    }
```

​      这样我们再看一下LinkedHashMap的put方法（也就是HashMap的put方法）

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);  //在此步骤会创建新的节点，因为LinkedHashMap重写了newNode方法，所以会调用LinkedHashMap的newNode方法
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

   这样就知道了在创建新节点的时候，把该节点放到了尾部。**==所以我们就清楚了当accessOrder设置为false时，会按照插入顺序进行排序，当accessOrder为true是，会按照访问顺序（也就是插入和访问都会将当前节点放置到尾部，尾部代表的是最近访问过的数据，反之第一个数据就是最久没访问过的，这和JDK1.6是反过来的，jdk1.6头部是最近访问的）。==**

### [Java LinkedHashMap removeEldestEntry（）方法与示例](https://blog.csdn.net/cumt30111/article/details/107766994)

- **removeEldestEntry() method** is available in java.util package.

  **removeEldestEntry()方法**在java.util包中可用。

- **removeEldestEntry() method** is used to check whether the eldest entry is to be removed or not.

  **removeEldestEntry()方法**用于检查是否删除最旧的条目。

- **removeEldestEntry() method** is a non-static method, it is accessible with the class object only and if we try to access the method with the class name then we will get an error.

  **removeEldestEntry()方法**是一种非静态方法，只能通过类对象访问，如果尝试使用类名称访问该方法，则会收到错误消息。

- **removeEldestEntry() method** does not throw an exception at the time of removing the older entry.

  **removeEldestEntry()方法**在删除较旧的条目时不会引发异常。

**Syntax:**

**句法：**

```typescript
    public boolean removeEldestEntry(Map.Entry ele_entry);
```

**Parameter(s):**

**参数：**

- Map.Entry ele_entry – represents the eldest entry or least recently entry to be removed from this LinkedHashMap.

  Map.Entry ele_entry –表示要从此LinkedHashMap中删除的最旧的条目或最近的条目。

**Return value:**

**返回值：**

The return type of the method is boolean, it returns true when the eldest entry should be deleted from the Map otherwise it returns false.

方法的返回类型为boolean ，当应从Map中删除最旧的条目时返回true，否则返回false。

**Example:**

例：

```java
// Java program to demonstrate the example 
// of boolean removeEldestEntry(Map.Entry ele_entry)
// method of  LinkedHashMap 
 
import java.util.*;
 
public class RemoveEldestEntryOfLinkedHashMap {
    public static void main(String[] args) {
        final int MAX_S = 5;
 
        // Instantiates a LinkedHashMap object
        Map < Integer, String > map = new LinkedHashMap < Integer, String > () {
            protected boolean removeEldestEntry(Map.Entry < Integer, String > eldest) {
                return size() > MAX_S;	//put元素时会调用该方法，检查当前元素个数是否大于MAX_S（put后），若返回true则会删除最早的元素
            }
        };
 
        // By using put() method is to add
        // key-value pairs in a LinkedHashMap
        map.put(10, "C");
        map.put(20, "C++");
        map.put(50, "JAVA");
        map.put(40, "PHP");
        map.put(30, "SFDC");
 
        //Display LinkedHashMap
        System.out.println("LinkedHashMap: " + map);
 
        // By using removeEldestEntry() method is to
        // remove the eldest entry and inserted new 
        // one in this LinkedHashMap
        map.put(60, "ANDROID");
 
        //Display LinkedHashMap
        System.out.println("LinkedHashMap: " + map);
    }
}
```

**Output**

**输出量**

```java
LinkedHashMap: {10=C, 20=C++, 50=JAVA, 40=PHP, 30=SFDC}
LinkedHashMap: {20=C++, 50=JAVA, 40=PHP, 30=SFDC, 60=ANDROID}
```



### 3.8故障转移

```java
package com.xxl.job.admin.core.route.strategy;

import com.xxl.job.admin.core.scheduler.XxlJobScheduler;
import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.admin.core.util.I18nUtil;
import com.xxl.job.core.biz.ExecutorBiz;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;

import java.util.List;

/**

- Created by xuxueli on 17/3/10.
- 故障转移路由策略
- 思想：遍历所有的该组下的所有注册节点地址集合，然后分别进行心跳处理，直到找到一个发送心跳成功的节点作为下一次路由的节点
  */
  public class ExecutorRouteFailover extends ExecutorRouter {

    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {

        StringBuffer beatResultSB = new StringBuffer();
        for (String address : addressList) {
            // beat
            ReturnT<String> beatResult = null;
            try {
                ExecutorBiz executorBiz = XxlJobScheduler.getExecutorBiz(address);
                beatResult = executorBiz.beat();
            } catch (Exception e) {
                logger.error(e.getMessage(), e);
                beatResult = new ReturnT<String>(ReturnT.FAIL_CODE, ""+e );
            }
            beatResultSB.append( (beatResultSB.length()>0)?"<br><br>":"")
                    .append(I18nUtil.getString("jobconf_beat") + "：")
                    .append("<br>address：").append(address)
                    .append("<br>code：").append(beatResult.getCode())
                    .append("<br>msg：").append(beatResult.getMsg());

            // beat success
            if (beatResult.getCode() == ReturnT.SUCCESS_CODE) {

                beatResult.setMsg(beatResultSB.toString());
                beatResult.setContent(address);
                return beatResult;
            }
        }
        return new ReturnT<String>(ReturnT.FAIL_CODE, beatResultSB.toString());

    }
}
```


这个算法很好理解，就是过滤所有故障的节点，找到一个健康节点运行任务，算法很简单，就是拿到节点的地址集合，然后一个个发心跳，若收到正常的心跳响应，则选择此节点作为执行任务的节点

### 4.9忙碌转移

```java
package com.xxl.job.admin.core.route.strategy;

import com.xxl.job.admin.core.scheduler.XxlJobScheduler;
import com.xxl.job.admin.core.route.ExecutorRouter;
import com.xxl.job.admin.core.util.I18nUtil;
import com.xxl.job.core.biz.ExecutorBiz;
import com.xxl.job.core.biz.model.IdleBeatParam;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.biz.model.TriggerParam;

import java.util.List;

/**

- Created by xuxueli on 17/3/10.
- 忙碌转移
- 原理遍历所有的执行器，对所有执行器发送空闲心跳数据包
- 收集所有的返回信息，若当前机器繁忙则响应getCode==500 否则空闲则getCode==200
- 找到空闲的机器则返回该空闲机器的地址
  */
  public class ExecutorRouteBusyover extends ExecutorRouter {

    @Override
    public ReturnT<String> route(TriggerParam triggerParam, List<String> addressList) {
        StringBuffer idleBeatResultSB = new StringBuffer();
        for (String address : addressList) {
            // beat
            ReturnT<String> idleBeatResult = null;
            try {
                ExecutorBiz executorBiz = XxlJobScheduler.getExecutorBiz(address);
                idleBeatResult = executorBiz.idleBeat(new IdleBeatParam(triggerParam.getJobId()));
            } catch (Exception e) {
                logger.error(e.getMessage(), e);
                idleBeatResult = new ReturnT<String>(ReturnT.FAIL_CODE, ""+e );
            }
            idleBeatResultSB.append( (idleBeatResultSB.length()>0)?"<br><br>":"")
                    .append(I18nUtil.getString("jobconf_idleBeat") + "：")
                    .append("<br>address：").append(address)
                    .append("<br>code：").append(idleBeatResult.getCode())
                    .append("<br>msg：").append(idleBeatResult.getMsg());

            // beat success
            if (idleBeatResult.getCode() == ReturnT.SUCCESS_CODE) {
                idleBeatResult.setMsg(idleBeatResultSB.toString());
                idleBeatResult.setContent(address);
                return idleBeatResult;
            }
        }

        return new ReturnT<String>(ReturnT.FAIL_CODE, idleBeatResultSB.toString());
    }

}
```


忙碌转移也很容易理解，就是发送idleBeat（空闲心跳包）,检测当前机器是否空闲，怎么判断当前机器是否空闲那，

就是EmbedServer来处理这个请求，判断当前执行器节点是否执行当前任务或者当前执行器节点的任务队列是否为空，若既不是执行当前任务的节点或者任务队列为空则返回SUCCESS，以下代码就是上述所说。

直到筛选出一个空闲节点为止，就选择当前空闲节点为下一个需要执行任务的节点





# [什么是一致性hash算法？](https://blog.csdn.net/mo71105731/article/details/123364539)

## 一、什么是hash算法？

以分布式缓存为例，假设现在有3台缓存服务器(S0，S1，S2)，要将一些图片尽可能平均地分配到不同的服务器上，hash算法的做法是：

(1) 以图片的名称作为key，然后对其做hash运算。

(2) 将hash值对服务器数量进行求余，得到服务器编号，最后存入即可。

举个栗子：

csdn.jpg 需要存入， 我们就得到hash(csdn.jpg) = 5 -------> 5%3 = 2 得到数据存入S2

思考:

上面的算法好像可以把图片均衡地分配到不同的服务器，当获取数据的时候也可以根据同样的思路访问对应的服务器，避免全局扫描。但是，这个时候服务器进行了扩容，加入了S4，我们还能否正常获取数据呢？

假设还是根据同样的思路获取csdn.jpg，我们就会得到 hash(csdn.jpg)%4 = 1。显然，我们去S1是无法获取数据的，这个时候就有可能会引发缓存的血崩，大量的请求落到数据库上。

那应该怎么办呢？

## 二、一致性hash算法

一致性hash算法会建立一个有2^32个槽点(0 - 2^32-1)的hash环，假设现在有A、B、C三台服务器，以A为栗，会进行hash(A)%2^32，得到一个0 - 2^32-1之间的数，然后映射到hash环上，如图所示：

​                      ![img](https://img-blog.csdnimg.cn/c08323ab752f47d597355748bd09f96e.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Y-r5oiR5ouW6Z6L5ZOl,size_20,color_FFFFFF,t_70,g_se,x_16)    

 接下来，我们同样以csdn.jpg为例，我们照样算出hash(csdn.jpg)%2^32的值，然后映射到hash环上，然后以该点出发，顺时针遇到的第一个服务器，即为数据即将存储的服务器。

​              ![img](https://img-blog.csdnimg.cn/0059405a45674e1899e88826c11139f4.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Y-r5oiR5ouW6Z6L5ZOl,size_20,color_FFFFFF,t_70,g_se,x_16)

 这时增加了服务器D又会发生什么事情呢?

如果这个时候在A - C之间插入了服务器D，请求获取getKey(csdn.jpg)时，顺时针获得的服务器是D，从D上获取数据理所当然会失败，因为数据存在A上缓存。这样看缓存好像还是失效了。

那么做成hash环有什么好处呢？

虽然增加了节点D后，csdn.jpg的缓存失效了，但是，分布在 A-B，B-C 以及 D-A上面的数据仍然有效，失效的只是C-D段的数据(数据存在A节点，但是顺时针获取的服务器是D)。这样就保证了缓存数据不会像hash算法那样大面积失效，同样起到减轻数据库压力的效果。

思考：

既然hash环能保证在服务器节点发生变化的情况下，数据只会部分失效，那一致性hash是不是就结束了呢？

### 什么是hash偏斜?

A、B、C服务节点，如果像上图那样接近于将hash环平均分配那固然理想，但是如果他们hash值十分相近，会发生什么呢?

​                          ![img](https://img-blog.csdnimg.cn/357f5e806115406c86735cc7680d52ae.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Y-r5oiR5ouW6Z6L5ZOl,size_20,color_FFFFFF,t_70,g_se,x_16)   

 上图这种情况称之为hash偏斜，在这种情况下，大部分数据都会分部在C-A段，这个时候去A节点被删除，会有大量请求涌向B节点，给B节点带来巨大的压力，同时这部分缓存也会全部失效，有可能引发缓存雪崩。

怎么办呢?

这个时候我们可能会想到一句老话: 人多力量大。

如果我们的节点足够多，就应该可以防止服务器节点分布不均的问题了。

所以引入了虚拟节点的概念，以A节点为例，虚拟构造出(A0,A1,A2....AN)，只要是落在这些虚拟节点上的数据，都存入A节点。读取时也相同，顺时针获取的是A0虚拟节点，就到A节点上获取数据，这样就能解决数据分布不均的问题。如图所示：    

![img](https://img-blog.csdnimg.cn/b0df81265950488690d7b4c05df54821.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBA5Y-r5oiR5ouW6Z6L5ZOl,size_20,color_FFFFFF,t_70,g_se,x_16)

虚拟节点读写大概流程为:   数据读写 -> 虚拟节点 -> 真实节点 -> 读写



# [一致性hash](https://blog.csdn.net/qq_34679704/article/details/120816037)

## 概述

一致性 hash 是传统 hash 算法的增强版。

多用于分布式数据存储场景，在集群节点数量发生变化时，提升集群适应变化的能力。

传统hash
假设当前服务集群中存在 3 个节点：Node-A，Node-B， Node-C；而客户端存在 Key1，Key2，Key3 需要映射到对应的服务节点。

传统 hash 算法思路：

先计算 key 对应的 hash 值
将 hash 值和服务节点的数量取模，算出对应节点的下标，即 Hash(Key) % NodeSize
如下图，通过传统 hash 计算出的映射关系：

Key1 -> Node-A
Key2 -> Node-B
Key3 -> Node-C


如果 Node-C 节点宕机了，Hash(Key) % NodeSize 公式的取模对象发生变化，最终可能导致 Key1，Key2 的映射到的服务节点都发生变化（Key3 肯定会改变）。

原本 Key1 映射到 Node-A 变为映射到 Node-B，因为数据之前存储在 Node-A，则导致 Key1 无法正常命中数据；Key2，Key3 … KeyN 都可能出现这种情况。



传统 hash算法的局限性主要体现在：

节点数量发生变化，导致 key -> 节点的映射关系发生变化，最终导致数据存储服务不可用（之前存储的 key 无法正常命中数据）
节点数量发生变化，整体数据 Rehash 的成本较高
而一致性 hash 算法则是将这种因节点数量变化所需要花费的调整成本，降至最低。

## 一致性hash

一致性 hash 引入了哈希环的概念，核心思路：

规定了一个哈希环，环的元素由 [0, 2^32 -1] 范围的整数组成
将 key，服务节点通过计算映射到哈希环上
顺时针方向为 key 寻找相邻的第一台服务节点，完成 key -> node 的关系映射


通过上述哈希环计算出来的映射关系：

Key1 -> Node-A
Key2 -> Node-B
Key3 -> Node-C
如果此时 Node-C 宕机了，则受影响的数据范围仅仅是 Node-B 到 Node-C 之间的数据，即 Key3 改为映射到 Node-A。



对于节点新增的场景也同理。

## 虚拟节点

上述的一致性 hash 确实能够降低节点数量变化对集群整体造成的影响，但存在数据倾斜问题。

假设集群中只存在两个节点 Node-A，Node-B且它们如下图分布于哈希环上。

即使 hash 算法足够平衡，但明显 Node-A -> Node-B 的这段区间长度更大，因此大部分 Key 会落在这个区间，最终导致大量数据都倾斜在了 Node-B 存储。



而虚拟节点的引入，能够最大程度使节点数据分布均匀，解决数据倾斜的问题。它的核心：

将一个物理节点分化成多个虚拟节点
将虚拟节点映射到哈希环上
当 key 命中虚拟节点后，通过虚拟节点找到其所属的物理节点
如下图：



可以看到 Node-A，Node-B 分别分化出了两个虚拟节点，使得数据分布更加平衡。

另外通过虚拟节点，在新增节点的情况下也使得新机器能够帮助集群承担更多的数据压力。

## 算法实现

使用 TreeMap 存储哈希环上数据，key 为 hash 值，value 则对应服务节点的信息。

![img](https://img-blog.csdnimg.cn/img_convert/7fc5bf764713e3f384bac477f3fde9be.png)

**采用 FNV-Hash 算法**，这种算法的特点是：**能快速hash大量数据并保持较小的冲突率**。

它的高度分散使它适用于hash一些非常相近的字符串，比如URL，hostname，文件名，text，IP地址等。

![img](https://img-blog.csdnimg.cn/img_convert/fdd6a6c3e729a39fa05711edec887785.png)

总结
本文主要讲述了：

传统 hash 算法在分布式环境下的局限性
一致性 hash 算法的实现思路，以及最终解决的问题
一致性 hash 算法的代码实现



百度百科：

## 工作原理

一致性哈希算法是当前较主流的[分布式](https://baike.baidu.com/item/分布式/19276232)[哈希表](https://baike.baidu.com/item/哈希表/5981869)协议之一，它对简单哈希算法进行了修正，解决了热点(hotPot)问题，它的原理分为两步 [5]  ：

首先，对存储节点的哈希值进行计算，其将存储空间抽象为一个环，将存储节点配置到环上。环上所有的节点都有一个值。其次，对数据进行哈希计算，按顺时针方向将其映射到离其最近的节点上去。当有节点出现故障离线时，按照算法的映射方法，受影响的仅仅为环上故障节点开始逆时针方向至下一个节点之间区间的数据对象，而这些对象本身就是映射到故障节点之上的。当有节点增加时，比如，在节点A和B之间重新添加一个节点H，受影响的也仅仅是节点H逆时针遍历直到B之间的数据对象，将这些重新映射到H上即可，因此，当有节点出现变动时，不会使得整个存储空间上的数据都进行重新映射，解决了简单哈希算法增删节点，重新映射所有数据带来的效率低下的问题 [5]  。

一致性哈希算法作为[分布式](https://baike.baidu.com/item/分布式/19276232)存储领域的一个重要算法，它基本解决了以[P2P](https://baike.baidu.com/item/P2P/139810)为代表的存储环境中一个关键的问题——如何在动态的[网络拓扑](https://baike.baidu.com/item/网络拓扑/4804125)中对数据进行分发和选择路由。在算法所构成的存储拓扑中，每个存储节点仅需维护少量相邻节点的信息，并且在节点加入/退出系统时，仅有相关的少量节点参与到拓扑的维护中，这使得一致性哈希算法成为一个具有实用意义的DHT（DistributedHashTable，分布式哈希表）算法。但是一致性哈希算法尚有不足之处。第一，在查询过程中，查询消息要经过O(n)步(n代表系统内的节点总数)才能到达被查询的节点。不难想象，当系统规模非常大时，节点数量可能超过百万，这样的查询效率显然难以满足使用的需要。第二，当应用一致性哈希算法的[分布式存储系统](https://baike.baidu.com/item/分布式存储系统/6608875)中添加或者删除新的物理节点时，要将下一个节点与之相关的数据迁移过来，查询命中率和存储效率下降，影响系统的整体性能 [5]  。

## 与哈希算法的关系

一致性哈希算法是在[哈希算法](https://baike.baidu.com/item/哈希算法/4960188)基础上提出的，在动态变化的[分布式](https://baike.baidu.com/item/分布式/19276232)环境中，哈希算法应该满足的几个条件:平衡性、单调性和分散性 [4]  。

①平衡性是指hash的结果应该平均分配到各个节点，这样从算法上解决了[负载均衡](https://baike.baidu.com/item/负载均衡/932451)问题 [4]  。

②单调性是指在新增或者删减节点时，不影响系统正常运行 [4]  。

③分散性是指数据应该分散地存放在分布式集群中的各个节点(节点自己可以有备份)，不必每个节点都存储所有的数据

## 优点

- 可扩展性。一致性哈希算法保证了增加或减少[服务器](https://baike.baidu.com/item/服务器/100571)时，数据存储的改变最少，相比传统哈希算法大大节省了数据移动的开销 [2]  。
- 更好地适应数据的快速增长。采用一致性哈希算法分布数据，当数据不断增长时，部分虚拟节点中可能包含很多数据、造成数据在虚拟节点上分布不均衡，此时可以将包含数据多的虚拟节点分裂，这种分裂仅仅是将原有的虚拟节点一分为二、不需要对全部的数据进行重新哈希和划分。虚拟节点分裂后，如果物理服务器的负载仍然不均衡，只需在服务器之间调整部分虚拟节点的存储分布。这样可以随数据的增长而动态的扩展物理服务器的数量，且代价远比传统哈希算法重新分布所有数据要小很多 [2]  。