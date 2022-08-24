# [Redis 内存淘汰机制详解](https://mp.weixin.qq.com/s/tbBOApVBwo5ZLZsZvAafYA)

一般来说，缓存的容量是小于数据总量的，所以，当缓存数据越来越多，Redis 不可避免的会被写满，这时候就涉及到 Redis 的内存淘汰机制了。我们需要选定某种策略将“不重要”的数据从 Redis 中清除，为新的数据腾出空间。

**1、配置 Redis 内存大小**

我们应该为 Redis 设置多大的内存容量呢？

根据“八二原理“，即 80% 的请求访问了 20% 的数据，因此如果按照这个原理来配置，将 Redis 内存大小设置为数据总量的 20%，就有可能拦截到 80% 的请求。当然，只是有可能，对于不同的业务场景需要进行不同的配置，一般**建议把缓存容量设置为总数据量的 15% 到 30%，兼顾访问性能和内存空间开销**。

**配置方式**（以 5GB 为例，如果不带单位则默认单位是字节）：

- 命令行

  ```
  config set maxmemory 5gb
  ```

- 配置文件

  ![图片](https://mmbiz.qpic.cn/mmbiz_png/gjnldtnoHOormfJAjGbGFfPiadm68JAibEErZRX7OflOeFS3dllnQ7b1RhS5vtpIVW8uSqWt4JuK77dk4y65VTlQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

- 查看 maxmemory 命令

  ```
  config get maxmemory
  ```

**2、Redis 的内存淘汰策略**



在 Redis 4.0 版本之前有 6 种策略，4.0 增加了 2种，主要新增了 LFU 算法。

下图为 Redis 6.2.0 版本的配置文件：

![图片](https://mmbiz.qpic.cn/mmbiz_png/gjnldtnoHOormfJAjGbGFfPiadm68JAibE7cPicmvn2Ceam6Wia9bT2EyPMiaQTlgfezT0o01cvLRd5iaaicbyLBQojTg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

其中，默认的淘汰策略是 noevition，也就是不淘汰

我们可以对 8 种淘汰策略可以分为两大类：

- **不进行淘汰的策略**

- - noevition，此策略不会对缓存的数据进行淘汰，当内存不够了就会报错，因此，如果真实数据集大小大于缓存容量，就不要使用此策略了。

    ![图片](https://mmbiz.qpic.cn/mmbiz_png/gjnldtnoHOormfJAjGbGFfPiadm68JAibEfHBLhwzFo8vRR2ia1FTWzL04gQSW9LQ2Pcdn79MBtJsslfzxickBl3iaw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

- **会进行淘汰的策略**

- - allkeys-random：随机删除
  - allkeys-lru：使用 LRU 算法进行筛选删除
  - allkeys-lfu：使用 LFU 算法进行筛选删除
  - volatile-random：随机删除
  - volatile-ttl：根据过期时间先后进行删除，越早过期的越先被删除
  - volatile-lru：使用 LRU 算法进行筛选删除
  - volatile-lfu：使用 LFU 算法进行筛选删除
  - **在设置了过期时间的数据中筛选**
  - **在所有数据中筛选**

> 以 volatile 开头的策略只针对设置了过期时间的数据，即使缓存没有被写满，如果数据过期也会被删除。
>
> 以 allkeys 开头的策略是针对所有数据的，如果数据被选中了，即使过期时间没到，也会被删除。当然，如果它的过期时间到了但未被策略选中，同样会被删除。

那么我们如何配置过期策略呢？

- 命令行

  ```
  config set maxmemory-policy allkeys-lru
  ```

- 配置文件

  ![图片](https://mmbiz.qpic.cn/mmbiz_png/gjnldtnoHOormfJAjGbGFfPiadm68JAibEmSKxWnz8ibyNgZ6fCMqnLickLpfVVw7icEXn9Nmgw1xXPJ8B8GJTLs9KQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)





**3、LRU 算法**

**首先简单介绍一下 LRU 算法：**

LRU 全称是 Least Recently Used，即最近最少使用，会将最不常用的数据筛选出来，保留最近频繁使用的数据。

LRU 会把所有数据组成一个链表，链表头部称为 MRU，代表最近最常使用的数据；尾部称为 LRU代表最近最不常使用的数据；

**下图是一个简单的例子：**

![图片](https://mmbiz.qpic.cn/mmbiz_png/gjnldtnoHOormfJAjGbGFfPiadm68JAibEKuaBqPpgASiaAhU4GfcaZbLn1rMCW6p4aY5JtOksj8c2Xh33LCPkejA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

**但是，如果直接在 Redis 中使用 LRU 算法也会有一些问题：**

LRU 算法在实现过程中使用链表管理所有缓存的数据，这会给 Redis 带来额外的开销，而且，当有数据访问时就会有链表移动操作，进而降低 Redis 的性能。

于是，Redis 对 LRU 的实现进行了一些改变：

- 记录每个 key 最近一次被访问的时间戳（由键值对数据结构 RedisObject 中的 lru 字段记录）
- 在第一次淘汰数据时，会先随机选择 N 个数据作为一个候选集合，然后淘汰 lru 值最小的。（N 可以通过 `config set maxmemory-samples 100` 命令来配置）
- 后续再淘汰数据时，会挑选数据进入候选集合，进入集合的条件是：它的 lru 小于候选集合中最小的 lru。
- 如果候选集合中数据个数达到了 maxmemory-samples，Redis 就会将 lru 值小的数据淘汰出去。

**4、LFU 算法**



LFU 全称 Least Frequently Used，即最不经常使用策略，它是基于数据访问次数来淘汰数据的，在 Redis 4.0 时添加进来。它在 LRU 策略基础上，为每个数据增加了一个计数器，来统计这个数据的访问次数。

前面说到，LRU 使用了 RedisObject 中的 lru 字段记录时间戳，lru 是 24bit 的，LFU 将 lru 拆分为两部分：

- ldt 值：lru 字段的前 16bit，表示数据的访问时间戳
- counter 值：lru 字段的后 8bit，表示数据的访问次数

使用 LFU 策略淘汰缓存时，会把访问次数最低的数据淘汰，如果访问次数相同，再根据访问的时间，将访问时间戳最小的淘汰。

**为什么 Redis 有了 LRU 还需要 LFU 呢？**

在一些场景下，有些数据被访问的次数非常少，甚至只会被访问一次。当这些数据服务完访问请求后，如果还继续留存在缓存中的话，就只会白白占用缓存空间。

由于 LRU 是基于访问时间的，如果系统对大量数据进行单次查询，这些数据的 lru 值就很大，使用 LFU 算法就不容易被淘汰。