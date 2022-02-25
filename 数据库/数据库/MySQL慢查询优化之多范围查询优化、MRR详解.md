# 一、[MySQL慢查询优化之多范围查询优化](https://zhuanlan.zhihu.com/p/104267505)

## 慢查询分析

笔者在开发中有时候会遇到多范围查询，举一个相似的例子，比如查询2019年注册的18-25岁的年轻用户，查询sql如下所示

```sql
SELECT
	COUNT(*)
FROM
	tb_user 
WHERE
	age BETWEEN 18 
	AND 25 
	AND register_time BETWEEN 20190101 
	AND 20191231 
```

上述涉及的tb_user这张表是笔者在开发环境中自己创建的表，表中总共存在1000万数据量，在上述查询涉及的age和register_time上均已经创建了索引，使用explain分析慢查询，发现mysql使用了如下查询策略

```sql
+----+-------------+--------------+------------+-------+-----------------------------------------------------+------------------------+---------+------+---------+----------+-----------------------------------------------+
| id | select_type | table        | partitions | type  | possible_keys                                       | key                    | key_len | ref  | rows    | filtered | Extra                                         |
+----+-------------+--------------+------------+-------+-----------------------------------------------------+------------------------+---------+------+---------+----------+-----------------------------------------------+
|  1 | SIMPLE      | tb_user      | NULL       | range | age_idx,register_time_idx                           | age_idx                | 4       | NULL | 2245240 |   100.00 | Using index condition; Using where; Using MRR |
+----+-------------+--------------+------------+-------+-----------------------------------------------------+------------------------+---------+------+---------+----------+-----------------------------------------------+
```

因为mysql在执行查询的时候只会使用一个索引，所以虽然在age和register_time上均已经创建了索引，mysql查询优化器也只使用了age_idx索引，在Extra列中涉及的Using index condition指的是mysql先进行了age_idx索引条件过滤，而涉及的==Using MRR指的是mysql进行索引过滤后取得一批id再回表查找。==

笔者随后创建了age和register_time的复合索引，笔者希望mysql在执行查询的时候首先会对age进行范围索引扫描，然后在register_time上进行范围索引扫描所以笔者将register_time索引作为复合索引的第二列索引。

==原因：查询中某个列有范围查询，则其右边的所有列都无法使用索引查询（多列查询）==

笔者再次执行上述查询，发现mysql没有使用新创建的age_register_time_idx，笔者认为mysql查询优化器使用了错误的索引，于是笔者添加FORCE INDEX强制mysql使用age_register_time_idx索引。随后笔者再次执行查询，发现mysql执行仍然非常缓慢。使用Explain分析后发现Extra列有如下信息

```sql
Using where; Using index; 
```

Using index;说明了mysql使用了age_register_time_idx进行了条件过滤，但是Using where;说明mysql没有使用age_register_time_idx组合索引的register_time部分（使用索引查出来后再where 条件过滤除register_time部分）。查询资料后发现原因是mysql不支持松散索引扫描。也就无法实现从第一个范围age开始扫描到第一个范围age结束，然后扫描第二个register_time范围开始和第二个register_time范围结束。

思考之后，笔者有如下三种优化思路

## 优化方法一使用子查询

Mysql不支持松散索引扫描，每一个查询都只能使用一个索引进行范围扫描，那么我们是否可以将上述的查询拆分为两个子查询，其中一个子查询使用age索引进行范围扫描，而另一个子查询使用register_time索引进行范围扫描，然后取这两个子查询的交集id呢，然后在利用id回表查找用户信息。

```sql
SELECT
	count( * ) 
FROM
	tb_user 
WHERE
	id IN (
SELECT
	tb1.id 
FROM
	( SELECT id FROM tb_user FORCE INDEX ( `age_idx` ) WHERE age BETWEEN 18 AND 25 ) tb1
	INNER JOIN 
	( SELECT id FROM tb_user FORCE INDEX ( `register_time_idx` ) WHERE register_time BETWEEN 20190101 AND 20191231 ) tb2 
	ON tb1.id = tb2.id 
	)
```

笔者发现这个查询性能非常慢，执行时长超过了30秒。这种优化方式失败，原因是因为满足条件的tb1和满足条件的tb2数据量都非常大，对这样的大的临时表取交集性能自然就非常的差。

## 优化方式二之使用散列值

Mysql不支持松散索引扫描，所以优化的思路是将多个范围查询优化为一个范围查询。对于上述这个例子来说，我们可以将age字段使用in来代替，如此便可以避免其中一个字段的范围查询

```sql
SELECT
	COUNT(*)
FROM
	tb_user 
WHERE
	age IN ( 18, 19, 20, 21, 22, 23, 24, 25 ) 
	AND register_time BETWEEN 20190101 AND 20191231
```

优化之后，该查询使用了age_register_time_idx索引，该查询耗时为100ms左右。Explain分析如下

```sql
+----+-------------+--------------+------------+-------+-----------------------------------------------------+------------------------+---------+------+-------+----------+--------------------------+
| id | select_type | table        | partitions | type  | possible_keys                                       | key                    | key_len | ref  | rows  | filtered | Extra                    |
+----+-------------+--------------+------------+-------+-----------------------------------------------------+------------------------+---------+------+-------+----------+--------------------------+
|  1 | SIMPLE      | tb_user      | NULL       | range | age_idx,register_time_idx,age_register_time_idx     | age_register_time_idx  | 8       | NULL | 16940 |   100.00 | Using where; Using index |
+----+-------------+--------------+------------+-------+-----------------------------------------------------+------------------------+---------+------+-------+----------+--------------------------+
```

上述的Explain分析有一个奇怪的地方在于Extra信息中涉及到where，按道理讲mysql count在索引就可以完成，没有必要回表，难道是mysql只使用了组合索引的前半部分age么？笔者强制上述查询使用age索引进行了验证，如果查询使用age索引和查询使用age_register_time_idx索引性能一样说明mysql只使用了组合索引age_register_time的前半部分。

```sql
mysql> SELECT
    -> count(*) 
    -> FROM
    -> tb_user FORCE INDEX(`age_idx`)
    -> WHERE
    -> age IN ( 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ) 
    ->  AND register_time BETWEEN 20190101  AND 20191231;
+----------+
| count(*) |
+----------+
|    16940 |
+----------+
1 row in set (6.76 sec)

mysql> SELECT
    -> count(*) 
    -> FROM
    -> tb_user FORCE INDEX(`age_register_time_idx`)
    -> WHERE
    -> age IN ( 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ) 
    ->  AND register_time BETWEEN 20190101  AND 20191231;
+----------+
| count(*) |
+----------+
|    16940 |
+----------+
1 row in set (0.01 sec)
```

## 优化方式三之使用冗余字段

冗余字段是解决慢查询的利器，上述的业务是查询2019注册的年轻用户的总数。我们也可以利用两个冗余字段，比如加入一个age_type字段，1代表年轻用户，2代表中年用户，3代表老年用户。同时创建一个age_type和register_time的复合索引，需要注意的是mysql不支持松散索引扫描，所以要将范围扫描的register_time字段放在组合索引的后半部分。查询语句如下所示

```sql
SELECT
	COUNT(*)
FROM
	tb_user 
WHERE
	age_type = 1
	AND register_time BETWEEN 20190101 AND 20191231
```

虽然冗余字段为我们带来了便利，但是也为我们带来了管理上的麻烦。我们如何维护age_type字段呢？MySQL自带的触发器是一个比较好的方法，在age字段被更新的时候，触发器同时更新age_type字段。但是触发器可维护性比较差，我们也可以在业务层面手动维护age_type。这个业务需求实时性不是很高，我们可以开启一个异步线程每天凌晨扫描一遍表，更新错误的age_type字段。



---

# 二、[MySQL 的 MRR 到底是什么？](https://zhuanlan.zhihu.com/p/110154066)

MRR，全称「Multi-Range Read Optimization」。

简单说：**MRR 通过把「随机磁盘读」，转化为「顺序磁盘读」，从而提高了索引查询的性能。**

至于：

- 为什么要把随机读转化为顺序读？
- 怎么转化的？
- 为什么顺序读就能提升读取性能？

咱们开始吧。

## 磁盘：苦逼的底层劳动人民

执行一个范围查询：

```sql
mysql > explain select * from stu where age between 10 and 20;
+----+-------------+-------+-------+------+---------+------+------+-----------------------+
| id | select_type | table | type  | key  | key_len | ref  | rows | Extra                 |
+----+-------------+-------+-------+----------------+------+------+-----------------------+
|  1 | SIMPLE      |  stu  | range | age  | 5       | NULL |  960 | Using index condition |
+----+-------------+-------+-------+----------------+------+------+-----------------------+
```

当这个 sql 被执行时，MySQL 会按照下图的方式，去磁盘读取数据（假设数据不在数据缓冲池里）：

![img](https://pic3.zhimg.com/80/v2-fb6e74daed175cd327b8d7cdfa2d6dbe_720w.jpg)

图中红色线就是整个的查询过程，蓝色线则是磁盘的运动路线。

这张图是按照 Myisam 的索引结构画的，不过对于 Innodb 也同样适用。

对于 Myisam，左边就是字段 age 的二级索引，右边是存储完整行数据的地方。

先到左边的二级索引找，找到第一条符合条件的记录（实际上每个节点是一个页，一个页可以有很多条记录，这里我们假设每个页只有一条），接着到右边去读取这条数据的完整记录。

读取完后，回到左边，继续找下一条符合条件的记录，找到后，再到右边读取，这时发现这条数据跟上一条数据，在物理存储位置上，离的贼远！

咋办，没办法，只能让磁盘和磁头一起做**机械运动**，去给你读取这条数据。

第三条、第四条，都是一样，每次读取数据，磁盘和磁头都得跑好远一段路。

> MySQL 其实是以「页」为单位读取数据的，这里咱们假设这几条数据都恰好位于不同的页上。另外「页」的思想其实是来源于操作系统的非连续内存管理机制，类似的还有「段」。

磁盘的简化结构可以看成这样：

![img](https://pic3.zhimg.com/80/v2-025c101a602a44dad3ff76754a71dba2_720w.jpg)

![img](https://pic1.zhimg.com/80/v2-a17e84c94d065adf934681ae23fe2184_720w.jpg)

**可以想象一下，为了执行你这条 sql 语句，磁盘要不停的旋转，磁头要不停的移动，这些机械运动，都是很费时的。**

10,000 RPM（Revolutions Per Minute，即转每分） 的机械硬盘，每秒大概可以执行 167 次磁盘读取，所以在极端情况下，MySQL 每秒只能给你返回 167 条数据，这还不算上 CPU 排队时间。

> *上面讲的都是机械硬盘，SSD 的土豪，请随意 - -*

对于 Innodb，也是一样的。 Innodb 是聚簇索引（cluster index），所以只需要把右边也换成一颗叶子节点带有完整数据的 B+ tree 就可以了。

## 顺序读：一场狂风暴雨般的革命

到这里你知道了磁盘随机访问是多么奢侈的事了，所以，很明显，要把随机访问转化成顺序访问：

```sql
mysql > set optimizer_switch='mrr=on';
Query OK, 0 rows affected (0.06 sec)

mysql > explain select * from stu where age between 10 and 20;
+----+-------------+-------+-------+------+---------+------+------+----------------+
| id | select_type | table | type  | key  | key_len | ref  | rows | Extra          |
+----+-------------+-------+-------+------+---------+------+------+----------------+
|  1 | SIMPLE      | tbl   | range | age  |    5    | NULL |  960 | ...; Using MRR |
+----+-------------+-------+-------+------+---------+------+------+----------------+
```

我们开启了 MRR，重新执行 sql 语句，发现 Extra 里多了一个「Using MRR」。

这下 MySQL 的查询过程会变成这样：

![img](https://pic3.zhimg.com/80/v2-1470b535530f67fad4f265d480e9569e_720w.jpg)

**对于 Myisam，在去磁盘获取完整数据之前，会先按照 rowid 排好序，再去顺序的读取磁盘。**

**对于 Innodb，则会按照聚簇索引键值排好序，再顺序的读取聚簇索引。**

顺序读带来了几个好处：

**1、磁盘和磁头不再需要来回做机械运动；**

**2、可以充分利用磁盘预读**

比如在客户端请求一页的数据时，可以把后面几页的数据也一起返回，放到数据缓冲池中，这样如果下次刚好需要下一页的数据，就不再需要到磁盘读取。这样做的理论依据是计算机科学中著名的局部性原理：

> *当一个数据被用到时，其附近的数据也通常会马上被使用。*

**3、在一次查询中，每一页的数据只会从磁盘读取一次**

MySQL 从磁盘读取页的数据后，会把数据放到数据缓冲池，下次如果还用到这个页，就不需要去磁盘读取，直接从内存读。

但是如果不排序，可能你在读取了第 1 页的数据后，会去读取第2、3、4页数据，接着你又要去读取第 1 页的数据，这时你发现第 1 页的数据，已经从缓存中被剔除了，于是又得再去磁盘读取第 1 页的数据。

而转化为顺序读后，你会连续的使用第 1 页的数据，这时候按照 MySQL 的缓存剔除机制，这一页的缓存是不会失效的，直到你利用完这一页的数据，由于是顺序读，在这次查询的余下过程中，你确信不会再用到这一页的数据，可以和这一页数据说告辞了。

**顺序读就是通过这三个方面，最大的优化了索引的读取。**

**别忘了，索引本身就是为了减少磁盘 IO，加快查询，而 MRR，则是把索引减少磁盘 IO 的作用，进一步放大。**

## 一些关于这场革命的配置

[和 MRR 相关的配置](https://link.zhihu.com/?target=https%3A//dev.mysql.com/doc/refman/5.6/en/switchable-optimizations.html)有两个：

- mrr: on/off
- mrr_cost_based: on/off

第一个就是上面演示时用到的，用来打开 MRR 的开关：

mysql **>** **set** optimizer_switch**=**'mrr=on';

如果你不打开，是一定不会用到 MRR 的。

另一个，则是用来告诉优化器，要不要基于使用 MRR 的成本，考虑使用 MRR 是否值得（cost-based choice），来决定具体的 sql 语句里要不要使用 MRR。

很明显，对于只返回一行数据的查询，是没有必要 MRR 的，而如果你把 mrr_cost_based 设为 off，那优化器就会通通使用 MRR，这在有些情况下是很 stupid 的，所以建议这个配置还是设为 on，毕竟优化器在绝大多数情况下都是正确的。

另外还有一个配置 [read_rnd_buffer_size](https://link.zhihu.com/?target=https%3A//dev.mysql.com/doc/refman/5.6/en/server-system-variables.html%23sysvar_read_rnd_buffer_size) ，是用来设置用于给 rowid 排序的内存的大小。

显然，**MRR 在本质上是一种用空间换时间的算法**。MySQL 不可能给你无限的内存来进行排序，如果 read_rnd_buffer 满了，就会先把满了的 rowid 排好序去磁盘读取，接着清空，然后再往里面继续放 rowid，直到 read_rnd_buffer 又达到 read_rnd_buffe 配置的上限，如此循环。

另外 MySQL 的其中一个分支 Mariadb 对 MySQL 的 MRR 做了很多优化，有兴趣的同学可以看下文末的推荐阅读。

## 尾声

你也看出来了，MRR 跟索引有很大的关系。

索引是 MySQL 对查询做的一个优化，把原本杂乱无章的数据，用有序的结构组织起来，让全表扫描变成有章可循的查询。

**而我们讲的 MRR，则是 MySQL 对基于索引的查询做的一个的优化，可以说是对优化的优化了。**

要优化 MySQL 的查询，就得先知道 MySQL 的查询过程；而要优化索引的查询，则要知道 MySQL 索引的原理。

**就像之前在「**[如何学习 MySQL](https://zhuanlan.zhihu.com/p/108421544)**」里说的，要优化一项技术、学会调优，首先得先弄懂它的原理，这两者是不同的 Level。**

推荐阅读：

- [MySQL MRR](https://link.zhihu.com/?target=https%3A//dev.mysql.com/doc/refman/5.6/en/mrr-optimization.html)
- [Mariadb MRR](https://link.zhihu.com/?target=https%3A//mariadb.com/kb/en/multi-range-read-optimization/)
- [MySQL索引背后的数据结构及算法原理](https://link.zhihu.com/?target=http%3A//blog.codinglabs.org/articles/theory-of-mysql-index.html)
- [MySQl MRR 源码分析](https://link.zhihu.com/?target=http%3A//mysql.taobao.org/monthly/2016/01/04/)