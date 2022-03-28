# [Mysql 查询优化之 Using filesort](https://zhuanlan.zhihu.com/p/101571164)

最近在优化分页查询的时候，遇到了一个问题，如下（基于Mysql Innodb）

我们先建一个user表，其中有自增主键、user_id 也建立索引，create_date暂时不建索引，省略其他字段。

```text
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '员工id',
  `create_date` datetime NOT NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建日期',
   省略其他字段
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
```

当分页查询的时候，打印执行计划，Extra 一栏出现了 Using filesort。

```text
explain SELECT * FROM user ORDER BY create_date DESC limit 20.40;
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows  | Extra          |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
|  1 | SIMPLE      | user  | ALL  | NULL          | NULL | NULL    | NULL | 22686 | Using filesort |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
```



**Using filesort** 是什么意思？

官方的定义是，MySQL must do an extra pass to find out how to retrieve the rows in sorted order. The sort is done by going through all rows according to the join type and storing the sort key and pointer to the row for all rows that match the WHERE clause . The keys then are sorted and the rows are retrieved in sorted order。

MySQL需要**额外的一次传递**，以找出如何按排序顺序检索行。通过根据联接类型浏览所有行并为所有匹配WHERE子句的行保存排序关键字和行的指针来完成排序。然后关键字被排序，并按排序顺序检索行。标红，重点。



filesort 有两种排序方式

1. 对需要排序的记录生成 **<sort_key,rowid>** 的元数据进行排序，该元数据仅包含排序字段和rowid。排序完成后只有按字段排序的rowid，因此还需要通过rowid进行**回表操作获取所需要的列的值**，可能会导致**大量的随机IO读消耗**；
2. 对需要排序的记录生成 **<sort_key,additional_fields>** 的元数据，该元数据包含排序字段和需要返回的所有列。排序完后不需要回表，但是元数据要比第一种方法长得多，**需要更多的空间用于排序**。

**优化方法**

**filesort** 使用的算法是QuickSort，即对需要排序的记录生成元数据进行分块排序，然后再使用mergesort方法合并块。其中filesort可以使用的**内存空间**大小为参数 sort_buffer_size 的值，默认为2M。当排序记录太多 **sort_buffer_size** 不够用时，mysql会使用**临时文件来存放各个分块**，然后各个分块排序后再多次合并分块最终全局完成排序。可以增大 **sort_buffer_size** 来解决 filesort 慢问题，也就是上面的第二种排序。

当 排序元组中的extra列的总大小不超过 max_length_for_sort_data 系统变量值的时候，我们如何优化 Using filesort 中的 回表操作 呢？

文件排序优化不仅用于记录排序关键字和行的位置，并且还记录查询需要的列。这样可以避免两次读取行。

我们都知道，Mysql Innodb 下使用的是聚集索引。PRIMARY KEY 的叶子节点存储的是数据，其他索引的叶子节点存储的是PRIMARY KEY.

![img](https://pic1.zhimg.com/80/v2-147159186d7ba73fac3bdce91cb70684_720w.jpg)



当我们使用非PRIMARY KEY 查询的时候，查询1会进行回表操作，也就是额外的一次查询，去查询表中的其他数据，而查询2会直接返回id和user_id。

```text
查询1：select * from user where user_id=1;
查询2：select user_id,id from user where user_id=1;
```

好，下面我们通过例子来理解一下Using filesort 的形成

我们先来看第一条查询，根据create_date 排序，由于create_date 没有建索引，

```text
explain SELECT create_date,id FROM user ORDER BY create_date DESC;
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows  | Extra          |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
|  1 | SIMPLE      | user  | ALL  | NULL          | NULL | NULL    | NULL | 22686 | Using filesort |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
```

当使用没有索引字段的时候，会出现 Using filesort。那我们建立 create_date 索引之后呢，看下结果。

```text
explain SELECT create_date,id FROM user ORDER BY create_date DESC;
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows  | Extra          |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
|  1 | SIMPLE      | user  | ALL  | NULL          | NULL | NULL    | NULL | 22686 | Using index    |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
```

如果我想把 user_id 也查询出来呢，看下结果。聚集索引，想查询user_id 还是要进行回表操作的。

```text
explain SELECT create_date,user_id FROM user ORDER BY create_date DESC;
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows  | Extra          |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
|  1 | SIMPLE      | user  | ALL  | NULL          | NULL | NULL    | NULL | 22686 | Using filesort |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------+
```



回到开篇，我们如何优化这个查询呢。

```text
select * from (select id from user order by create_date DESC limit 20.40) a left join user b on a.id=b.id;
```

利用mysql聚集索引的性质，分页查询id，避免了Using filesort，这个查询是很快的。而在分页的数据量上，再去查询所有数据，性能就很高了。