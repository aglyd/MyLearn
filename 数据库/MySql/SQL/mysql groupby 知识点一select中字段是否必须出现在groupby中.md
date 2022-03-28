# [mysql groupby 知识点一:select中字段是否必须出现在groupby中][https://blog.csdn.net/ljz1315/article/details/84890254]

基本共识:进行groupby时,groupby中的字段可以不出现在select中,但是select中只能有groupby中的字段和函数.

但如下示例sql,依然能正常执行:

数据表:



执行如下sql,发现能正常执行,而且groupby后默认取每组第一条数据

select * from user_info group by grade;

结果:



经查找资料,分析,与MySql数据库中sql_mode是否含有only_full_group_by有关.如果无only_full_group_by,则groupby不受上面的认知限制,否则,必须按上面的共识操作.

1、查看sql_mode

```sql
select @@sql_mode;
```

本地库:NO_ENGINE_SUBSTITUTION

其他库:

```
ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```

2、去掉ONLY_FULL_GROUP_BY，重新设置值

```sql
set @@sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER
,NO_ENGINE_SUBSTITUTION';
```

3、上面是改变了全局sql_mode，对于新建的数据库有效。对于已存在的数据库，则需要在对应的数据下执行

set sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';



-----



# [分组查询时，select的字段是否一定要都在group by中?][https://blog.csdn.net/qq_24432315/article/details/108162808]

  分组查询关键字group by通常和集合函数（MAX、MIN、COUNT、SUM、AVG）一起使用，它可以对一列或者多列结果集进行分组。例如要统计超市水果的种类，需要用count函数，要统计哪个水果价格最高，要用MAX（）函数。

一般情况下，我们在使用group by的时候，select中的列都要出现在group by中，比如select id,name,age from tuser group by id,name,age，那么我们是不是都要严格按照这种模式来写sql呢？下面我们来一起探索下。

数据准备

创建一张学生表

```sql
CREATE TABLE `student1` (  `id` int(11) NOT NULL COMMENT '学号',  `name` varchar(60) NOT NULL COMMENT '姓名',  `birth` date NOT NULL COMMENT '出生日期',  `sex` varchar(1) DEFAULT NULL,  `age` int(11) NOT NULL,  `score` int(11) NOT NULL,  PRIMARY KEY (`id`))
```

插入数据

insert into student values(1,'Tom','1998-10-01','男',23,96),(2,'Jim','1997-07-04','男',24,95),(3,'Lily','1999-11-12','女',21,99),(4,'Lilei','1996-09-21','男',25,90),(5,'Lucy','1999-12-02','女',21,93),(6,'Jack','1988-04-27','男',32,89),(7,'Liam','1991-09-08',' 男',28,100);
数据展示

```sql
mysql> select * from student;+----+-------+------------+------+-----+-------+| id | name  | birth      | sex  | age | score |+----+-------+------------+------+-----+-------+|  1 | Tom   | 1998-10-01 | 男   |  23 |    96 ||  2 | Jim   | 1997-07-04 | 男   |  24 |    95 ||  3 | Lily  | 1999-11-12 | 女   |  21 |    99 ||  4 | Lilei | 1996-09-21 | 男   |  25 |    90 ||  5 | Lucy  | 1999-12-02 | 女   |  21 |    93 ||  6 | Jack  | 1988-04-27 | 男   |  32 |    89 ||  7 | Liam  | 1991-09-08 | 男   |  28 |   100 |+----+-------+------------+------+-----+-------+7 rows in set (0.00 sec)
```

测试验证

1. select中的列都出现在group by中，通过下面的结果可以看出是可以正常执行的。

```sql
mysql> select id,name,score from student where score >95  group by id,name,score;
+----+------+-------+
| id | name | score |
+----+------+-------+
|  1 | Tom  |    96 |
|  3 | Lily |    99 |
|  7 | Liam |   100 |
+----+------+-------+
3 rows in set (0.01 sec)
```


2. group by中只保留score或者name

```sql
mysql> select id,name,score from student where score >95  group by score;
ERROR 1055 (42000): Expression #1 of 
SELECT list is not in GROUP BY clause 
and contains nonaggregated column 
'test.student.id' which is not functionally 
dependent on columns in GROUP BY clause; 
this is incompatible with sql_mode=only_full_group_by
mysql> select id,name,score from student where score >95  group by name;
ERROR 1055 (42000): Expression #1 of 
SELECT list is not in GROUP BY clause 
and contains nonaggregated column 
'test.student.id' which is not functionally 
dependent on columnsin GROUP BY clause; 
this is incompatible with sql_mode=only_full_group_by
```


3. group by中只保留id

```sql
mysql> select id,name,score from student where score >95  group by id;
+----+------+-------+
| id | name | score |
+----+------+-------+
|  1 | Tom  |    96 |
|  3 | Lily |    99 |
|  7 | Liam |   100 |
+----+------+-------+
```

3 rows in set (0.00 sec)
通过这个实验可以看出group by中只保留id是可以正常执行的，为什么？id字段有什么特殊性呢？

通过表结构可以看出id字段是主键，查询官方文档，有针对主键列的解释。

SELECT name, address, MAX(age) FROM t GROUP BY name;
The query is valid if name is a primary key of t or is a unique NOT NULL column. In such cases,MySQL recognizes that the selected column is functionally dependent on a grouping column. Forexample, if name is a primary key, its value determines the value of address because each group has only one value of the primary key and thus only one row. As a result, there is no randomness in the choice of address value in a group and no need to reject the query.

The query is invalid if name is not a primary key of t or a unique NOT NULL column.

大致的意思是：如果name列是主键或者是唯一的非空列，name上面的查询是有效的。这种情况下，MySQL能够识别出select中的列依赖于group by中的列。比如说，如果name是主键，它的值就决定了address的值，因为每个组只有一个主键值，分组中的每一行都具有唯一性，因此也不需要拒绝这个查询。

4. 验证唯一非空索引

增加name字段的唯一性约束

```sql
alter table student add unique(name);mysql> select id,name,score from student where score >95  group by name;+----+------+-------+| id | name | score |+----+------+-------+|  7 | Liam |   100 ||  3 | Lily |    99 ||  1 | Tom  |    96 |+----+------+-------+3 rows in set (0.00 sec)
```

通过上面的例子也验证了，对于有唯一性约束的字段，也可以不用在group by中把select中的字段全部列出来。不过针对主键或者唯一性字段进行分组查询意义并不是很大，因为他们的每一行都是唯一的。

ONLY_FULL_GROUP_BY

    我们在上面提到select中的列都出现在group by中，其实在MySQL5.7.5之前是没有此类限制的，5.7.5版本在sql_mode中增加了ONLY_FULL_GROUP_BY参数，用来开启或者关闭针对group by的限制。下面我们在分别开启和关闭ONLY_FULL_GROUP_BY限制的情况下分别进行验证。

1. 我们先查询下sql_mode

```
mysql> select @@sql_mode;
+-------------------------------------------------------------------------------------------------------------------------------------------+| @@sql_mode                                                                                                                                
|+-------------------------------------------------------------------------------------------------------------------------------------------+
| ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,
NO_ZERO_IN_DATE,NO_ZERO_DATE,
ERROR_FOR_DIVISION_BY_ZERO,
NO_AUTO_CREATE_USER,
NO_ENGINE_SUBSTITUTION |
+-------------------------------------------------------------------------------------------------------------------------------------------++
1 row in set (0.00 sec)
```


2. sql_mode动态去除ONLY_FULL_GROUP_BY限制

mysql> SET @@sql_mode = sys.list_drop(@@sql_mode, 'ONLY_FULL_GROUP_BY');Query OK, 0 rows affected (0.05 sec)
再次执行分组查询

```
mysql> select id,name,score from student where score >95  group by score;+----+------+-------+| id | name | score |+----+------+-------+|  1 | Tom  |    96 ||  3 | Lily |    99 ||  7 | Liam |   100 |+----+------+-------+3 rows in set (0.00 sec)
```


3. sql_mode动态增加ONLY_FULL_GROUP_BY限制

```
SET @@sql_mode = sys.list_add(@@sql_mode, 'ONLY_FULL_GROUP_BY');
```

再次执行分组查询

```sql
mysql> select id,name,score from student where score >95  group by score;
ERROR 1055 (42000): Expression #1 of 
SELECT list is not in GROUP BY clause 
and contains nonaggregated column 
'test.student.id' which is not functionally 
dependent on columns in GROUP BY clause; 
this is incompatible with sql_mode=only_full_group_by。
```



----



# [MySQL教程之concat以及group_concat的用法][https://baijiahao.baidu.com/s?id=1595349117525189591&wfr=spider&for=pc]

本文中使用的例子均在下面的数据库表tt2下执行：

![img](u=2135681378,882006691&fm=173&app=25&f=JPEG.jpeg)

**一、concat()函数**

1、功能：将多个字符串连接成一个字符串。

2、语法：concat(str1, str2,...)

返回结果为连接参数产生的字符串，如果有任何一个参数为null，则返回值为null。

3、举例：

例1:select concat (id, name, score) as info from tt2;

![img](u=2595155708,2358396591&fm=173&app=25&f=JPEG.jpeg)

中间有一行为null是因为tt2表中有一行的score值为null。

例2：在例1的结果中三个字段id，name，score的组合没有分隔符，我们可以加一个逗号作为分隔符：

![img](u=1672024340,2156616330&fm=173&app=25&f=JPEG.jpeg)

这样看上去似乎顺眼了许多～～

但是输入sql语句麻烦了许多，三个字段需要输入两次逗号，如果10个字段，要输入九次逗号...麻烦死了啦，有没有什么简便方法呢？——于是可以指定参数之间的分隔符的concat_ws()来了！！！

**二、concat_ws()函数**

1、功能：和concat()一样，将多个字符串连接成一个字符串，但是可以一次性指定分隔符～（concat_ws就是concat with separator）

2、语法：concat_ws(separator, str1, str2, ...)

说明：第一个参数指定分隔符。需要注意的是分隔符不能为null，如果为null，则返回结果为null。

3、举例：

例3:我们使用concat_ws()将 分隔符指定为逗号，达到与例2相同的效果：

![img](u=2392333863,2848031567&fm=173&app=25&f=JPEG.jpeg)

例4：把分隔符指定为null，结果全部变成了null：

![img](u=2939311110,2367424453&fm=173&app=25&f=JPEG.jpeg)

**三、group_concat()函数**

前言：在有group by的查询语句中，select指定的字段要么就包含在group by语句的后面，作为分组的依据，要么就包含在聚合函数中。（有关group by的知识请戳：浅析SQL中Group By的使用）。

例5：

![img](u=2727993136,2316749965&fm=173&app=25&f=JPEG.jpeg)

该例查询了name相同的的人中最小的id。如果我们要查询name相同的人的所有的id呢？

当然我们可以这样查询：

例6：

![img](u=739574379,3307690858&fm=173&app=25&f=JPEG.jpeg)

但是这样同一个名字出现多次，看上去非常不直观。有没有更直观的方法，既让每个名字都只出现一次，又能够显示所有的名字相同的人的id呢？——使用group_concat()

1、功能：将group by产生的同一个分组中的值连接起来，返回一个字符串结果。

2、语法：group_concat( [distinct] 要连接的字段 [order by 排序字段 asc/desc ] [separator '分隔符'] )

说明：通过使用distinct可以排除重复值；如果希望对结果中的值进行排序，可以使用order by子句；separator是一个字符串值，缺省为一个逗号。

3、举例：

例7：使用group_concat()和group by显示相同名字的人的id号：

![img](u=53485535,941408993&fm=173&app=25&f=JPEG.jpeg)

例8：将上面的id号从大到小排序，且用'_'作为分隔符：

![img](u=433900724,427703971&fm=173&app=25&f=JPEG.jpeg)

例9：上面的查询中显示了以name分组的每组中所有的id。接下来我们要查询以name分组的所有组的id和score：

![img](u=3763989288,3669329342&fm=173&app=25&f=JPEG.jpeg)