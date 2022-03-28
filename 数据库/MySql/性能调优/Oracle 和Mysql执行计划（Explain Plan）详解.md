## 一、[Oracle 执行计划（Explain Plan）](https://www.cnblogs.com/xqzt/p/4467867.html)

执行计划：一条查询语句在ORACLE中的执行过程或访问路径的描述。即就是对一个查询任务，做出一份怎样去完成任务的详细方案。

如果要分析某条SQL的性能问题，通常我们要先看SQL的执行计划，看看SQL的每一步执行是否存在问题。 看懂执行计划也就成了SQL优化的先决条件。 通过执行计划定位性能问题，定位后就通过建立索引、修改sql等解决问题。

### 一、执行计划的查看

#### 1.1 设置autotrace

autotrace命令如下

| 序号 | 命令                        | 解释                             |
| ---- | --------------------------- | -------------------------------- |
| 1    | SET AUTOTRACE OFF           | 此为默认值，即关闭Autotrace      |
| 2    | SET AUTOTRACE ON EXPLAIN    | 只显示执行计划                   |
| 3    | SET AUTOTRACE ON STATISTICS | 只显示执行的统计信息             |
| 4    | SET AUTOTRACE ON            | 包含2,3两项内容                  |
| 5    | SET AUTOTRACE TRACEONLY     | 与ON相似，但不显示语句的执行结果 |

![clip_image001](https://images0.cnblogs.com/blog/733883/201504/300035311151935.png)

#### 1.2 使用SQL

在执行的sql前面加上EXPLAIN PLAN FOR

```
SQL> EXPLAIN PLAN FOR SELECT * FROM EMP;

已解释。

SQL> SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE'));

或者：

SQL> select * from table(dbms_xplan.display);
```

[![clip_image002](https://images0.cnblogs.com/blog/733883/201504/300035364114517.png)](https://images0.cnblogs.com/blog/733883/201504/300035338499433.png)

#### 1.3 使用PL/SQL Developer，Navicat, Toad等客户端工具

常见的客户端工具如PL/SQL Developer，Navicat, Toad都支持查看解释计划。

**Navicat**

[![clip_image003](https://images0.cnblogs.com/blog/733883/201504/300035383964645.png)](https://images0.cnblogs.com/blog/733883/201504/300035374118344.png)



```sql
[SQL] DELETE PLAN_TABLE

[SQL] EXPLAIN PLAN FOR SELECT * FROM EMP 

[SQL] SELECT LPAD(' ', LEVEL-1) || OPERATION || ' (' || OPTIONS || ')' "Operation", OBJECT_NAME "Object", OPTIMIZER "Optimizer", COST "Cost", CARDINALITY "Cardinality", BYTES "Bytes", PARTITION_START "Partition Start", PARTITION_ID "Partition ID" , ACCESS_PREDICATES "Access Predicates", FILTER_PREDICATES "Filter Predicates" FROM PLAN_TABLE START WITH ID = 0 CONNECT BY PRIOR ID=PARENT_ID

时间: 0.184s
```

**PL/SQL Developer**

[![clip_image004](https://images0.cnblogs.com/blog/733883/201504/300035487408650.png)](https://images0.cnblogs.com/blog/733883/201504/300035431617854.png)

### **二、如何读懂执行计划**

#### 2.1执行顺序的原则

执行顺序的原则是：由上至下，从右向左
由上至下：在执行计划中一般含有多个节点，相同级别(或并列)的节点，靠上的优先执行，靠下的后执行
从右向左：在某个节点下还存在多个子节点，先从最靠右的子节点开始执行。

**一般按缩进长度来判断，缩进最大的最先执行，如果有****2****行缩进一样，那么就先执行上面的。**

[![clip_image005](https://images0.cnblogs.com/blog/733883/201504/300035508804264.png)](https://images0.cnblogs.com/blog/733883/201504/300035499112193.png)

图片是Toad工具查看的执行计划。 在Toad 里面，很清楚的显示了执行的顺序。

 

以下面的sql为例(sakila样例数据库中的address city country连接查询)

```sql
select address.address, city.city, country.country
from address
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id;
```

[![clip_image006](https://images0.cnblogs.com/blog/733883/201504/300035571468916.png)](https://images0.cnblogs.com/blog/733883/201504/300035549435088.png)

#### 2.2 执行计划中字段解释

[![clip_image007](https://images0.cnblogs.com/blog/733883/201504/300035597861742.png)](https://images0.cnblogs.com/blog/733883/201504/300035578492302.png)

**ID**: 一个序号，但不是执行的先后顺序。执行的先后根据缩进来判断。

**Operation**： 当前操作的内容。

**Rows**： 当前操作的Cardinality，Oracle估计当前操作的返回结果集。

**Cost（CPU）：**Oracle 计算出来的一个数值（代价），用于说明SQL执行的代价。

**Time**：Oracle 估计当前操作的时间。

在看执行计划的时候，除了看执行计划本身，还需要看谓词和统计信息。 通过整体信息来判断SQL效率。

#### 2.3 谓词说明

[![clip_image008](https://images0.cnblogs.com/blog/733883/201504/300036015993156.png)](https://images0.cnblogs.com/blog/733883/201504/300036003967857.png)

**Access :**

- 通过某种方式定位了需要的数据，然后读取出这些结果集，叫做Access。
- 表示这个谓词条件的值将会影响数据的访问路劲（表还是索引）。

**Filter：**

- 把所有的数据都访问了，然后过滤掉不需要的数据，这种方式叫做filter 。
- 表示谓词条件的值不会影响数据的访问路劲，只起过滤的作用。

在谓词中主要注意access，要考虑谓词的条件，使用的访问路径是否正确。

#### 2.4 Statistics(统计信息)说明

[![clip_image009](https://images0.cnblogs.com/blog/733883/201504/300036038334039.png)](https://images0.cnblogs.com/blog/733883/201504/300036030835668.png)

| recursive calls                        | 产生的递归sql调用的条数。                               |
| -------------------------------------- | ------------------------------------------------------- |
| Db block gets:                         | 从buffer cache中读取的block的数量                       |
| consistent gets                        | 从buffer cache中读取的undo数据的block的数量             |
| physical reads                         | 从磁盘读取的block的数量                                 |
| redo size                              | DML生成的redo的大小                                     |
| bytes sent via SQL*Net to client       | 数据库服务器通过SQL*Net向查询客户端发送的查询结果字节数 |
| bytes received via SQL*Net from client | 通过SQL*Net接受的来自客户端的数据字节数                 |
| SQL*Net roundtrips to/from client      | 服务器和客户端来回往返通信的Oracle Net messages条数     |
| sorts (memory)                         | 在内存执行的排序量                                      |
| sorts (disk)                           | 在磁盘上执行的排序量                                    |
| rows processed                         | 处理的数据的行数                                        |

解释：

**Recursive Calls****：****Number of recursive calls generated at both the user and system level.**

Oracle Database maintains tables used for internal processing. When it needs to change these tables, Oracle Database generates an internal SQL statement, which in turn generates a recursive call. In short, recursive calls are basically SQL performed on behalf of your SQL. So, if you had to parse the query, for example, you might have had to run some other queries to get data dictionary information. These would be recursive calls. Space management, security checks, calling PL/SQL from SQL—all incur recursive SQL calls。

当执行一条SQL语句时，产生的对其他SQL语句的调用，这些额外的语句称之为''recursive calls''或''recursive SQL statements''. 我们做一条insert 时，没有足够的空间来保存row记录，Oracle 通过Recursive Call 来动态的分配空间。

**DB Block Gets：Number of times a CURRENT block was requested.**

Current mode blocks are retrieved as they exist right now, not in a consistent read fashion. Normally, blocks retrieved for a query are retrieved as they existed when the query began. Current mode blocks are retrieved as they exist right now, not from a previous point in time. During a SELECT, you might see current mode retrievals due to reading the data dictionary to find the extent information for a table to do a full scan (because you need the "right now" information, not the consistent read). During a modification, you will access the blocks in current mode in order to write to them.

DB Block Gets:请求的数据块在buffer能满足的个数

当前模式块意思就是在操作中正好提取的块数目，而不是在一致性读的情况下而产生的块数。正常的情况下，一个查询提取的块是在查询开始的那个时间点上存在的数据块，当前块是在这个时刻存在的数据块，而不是在这个时间点之前或者之后的数据块数目。

**Consistent Gets： Number of times a consistent read was requested for a block.**

This is how many blocks you processed in "consistent read" mode. This will include counts of blocks read from the rollback segment in order to roll back a block. This is the mode you read blocks in with a SELECT, for example. Also, when you do a searched UPDATE/DELETE, you read the blocks in consistent read mode and then get the block in current mode to actually do the modification.

(Consistent Gets: 数据请求总数在回滚段Buffer中的数据一致性读所需要的数据块)

这里的概念是在处理你这个操作的时候需要在一致性读状态上处理多少个块，这些块产生的主要原因是因为由于在你查询的过程中，由于其他会话对数据块进行操作，而对所要查询的块有了修改，但是由于我们的查询是在这些修改之前调用的，所以需要对回滚段中的数据块的前映像进行查询，以保证数据的一致性。这样就产 生了一致性读。

**Physical Reads：**

Total number of data blocks read from disk. This number equals the value of "physical reads direct" plus all reads into buffer cache.

(Physical Reads:实例启动后，从磁盘读到Buffer Cache数据块数量)

就是从磁盘上读取数据块的数量，其产生的主要原因是：

（1） 在数据库高速缓存中不存在这些块

（2） 全表扫描

（3） 磁盘排序

它们三者之间的关系大致可概括为：

逻辑读指的是Oracle从内存读到的数据块数量。一般来说是'consistent gets' + 'db block gets'。当在内存中找不到所需的数据块的话就需要从磁盘中获取，于是就产生了'physical reads'。

Physical Reads通常是我们最关心的，如果这个值很高，说明要从磁盘请求大量的数据到Buffer Cache里，通常意味着系统里存在大量全表扫描的SQL语句，这会影响到数据库的性能，因此尽量避免语句做全表扫描，对于全表扫描的SQL语句，建议增 加相关的索引，优化SQL语句来解决。

关于physical reads ，db block gets 和consistent gets这三个参数之间有一个换算公式：

数据缓冲区的使用命中率=1 - ( physical reads / (db block gets + consistent gets) )。

用以下语句可以查看数据缓冲区的命中率：

```sql
SQL>SELECT name, value FROM v$sysstat WHERE name IN ('db block gets', 'consistent gets','physical reads');
```

查询出来的结果Buffer Cache的命中率应该在90％以上，否则需要增加数据缓冲区的大小。

```sql
清空Buffer Cache和数据字典缓存

SQL> alter system flush shared_pool;  //请勿随意在生产环境执行此语句  
 
System altered  
 
SQL> alter system flush buffer_cache;  //请勿随意在生产环境执行此语句  
 
System altered  
```

**bytes sent via SQL\*Net to client:**

  Total number of bytes sent to the client from the foreground processes.

**bytes received via SQL\*Net from client:**

  Total number of bytes received from the client over Oracle Net.

**SQL\*Net roundtrips to/from client:**

Total number of Oracle Net messages sent to and received from the client.

Oracle Net是把Oracle网络粘合起来的粘合剂。它负责处理客户到服务器和服务器到客户通信，

**sorts (memory): 在内存里排序。**

Number of sort operations that were performed completely in memory and did not require any disk writes

You cannot do much better than memory sorts, except maybe no sorts at all. Sorting is usually caused by selection criteria specifications within table join SQL operations.

**Sorts(disk): 在磁盘上排序。**

  Number of sort operations that required at least one disk write. Sorts that require I/O to disk are quite resource intensive. Try increasing the size of the initialization parameter SORT_AREA_SIZE.

所有的sort都是优先在memory中做的，当要排序的内容太多，在sort area中放不下的时候，会需要临时表空间，产生sorts(disk)

rows processed

**The number of rows processed**

更多内容参考Oracle联机文档：[Statistics Descriptions](http://docs.oracle.com/database/121/REFRN/stats002.htm#i375475)

#### 2.5 动态分析

动态统计量收集是Oracle CBO优化器的一种特性。优化器生成执行计划是依据成本cost公式计算出的，如果相关数据表没有收集过统计量，又要使用CBO的机制，就会引起动态采样。

动态采样（dynamic sampling）就是在生成执行计划是，以一个很小的采用率现进行统计量收集。由于采样率低，采样过程快但是不精确，而且采样结果不会进入到数据字典中。

如果在执行计划中有如下提示：

```
Note
-------------dynamic sampling used for the statement
```

这提示用户CBO当前使用的技术，需要用户在分析计划时考虑到这些因素。 当出现这个提示，说明当前表使用了动态采样。 我们从而推断这个表可没有做过分析。

这里会出现两种情况：

（1） 如果表没有做过分析，那么CBO可以通过动态采样的方式来获取分析数据，也可以或者正确的执行计划。

（2） 如果表分析过，但是分析信息过旧，这时CBO就不会在使用动态采样，而是使用这些旧的分析数据，从而可能导致错误的执行计划。

更多参照[为准确生成执行计划更新统计信息-analyze与dbms_stats](http://www.cnblogs.com/xqzt/p/4467702.html)

### **三、**JOIN方式

#### 3.1 hash join

 

#### 3.2 merge join

 

#### 3.3 nested loop

 

参照：[Nested Loops，Hash Join , Sort Merge Join](http://www.cnblogs.com/xqzt/p/4469673.html)

### **四、表访问方式**

#### 4.1表访问方式---->全表扫描（Full Table Scans）

- [**表访问方式---->全表扫描（Full Table Scans, FTS）**](http://www.cnblogs.com/xqzt/p/4464120.html)

#### 4.2表访问方式---->通过ROWID访问表（table access by ROWID）

- #####  [表访问方式---->通过ROWID访问表（table access by ROWID）](http://www.cnblogs.com/xqzt/p/4464205.html)

#### 4.3索引扫描

- [**索引范围扫描(INDEX RANGE SCAN)**](http://www.cnblogs.com/xqzt/p/4464339.html)

- ##### [引唯一性扫描(INDEX UNIQUE SCAN)](http://www.cnblogs.com/xqzt/p/4464357.html)

- ##### [索引全扫描（INDEX FULL SCAN）](http://www.cnblogs.com/xqzt/p/4464486.html)

- ##### [索引快速扫描(index fast full scan)](http://www.cnblogs.com/xqzt/p/4467038.html)

- [**索引跳跃式扫描（INDEX SKIP SCAN）**](http://www.cnblogs.com/xqzt/p/4467482.html)

### 参考：

- [Oracle中的执行计划(原创)](http://czmmiao.iteye.com/blog/1471756)
- [Oracle 执行计划（Explain Plan） 说明](http://blog.csdn.net/tianlesoftware/article/details/5827245)
- [Oracle Recursive Calls 说明](http://www.cnblogs.com/springside-example/archive/2011/06/22/2529710.html)
- [Database SQL Language Reference – Contents Statistics Descriptions](http://docs.oracle.com/database/121/REFRN/stats002.htm%23i375475)
- [多表连接的三种方式详解 HASH JOIN MERGE JOIN NESTED LOOP](http://blog.csdn.net/tianlesoftware/article/details/5826546)
- [为准确生成执行计划更新统计信息-analyze](http://blog.sina.com.cn/s/blog_6d6e54f70100nhn7.html)
- http://docs.oracle.com/database/121/TGSQL/tgsql_stats.htm#TGSQL389

分类: [Oracle 基础](https://www.cnblogs.com/xqzt/category/669804.html)

标签: [Explain Plan](https://www.cnblogs.com/xqzt/tag/Explain Plan/)





----

# 二、[MySQL Explain详解](https://www.cnblogs.com/xuanzhi201111/p/4175635.html)

在日常工作中，我们会有时会开慢查询去记录一些执行时间比较久的SQL语句，找出这些SQL语句并不意味着完事了，些时我们常常用到explain这个命令来查看一个这些SQL语句的执行计划，查看该SQL语句有没有使用上了索引，有没有做全表扫描，这都可以通过explain命令来查看。所以我们深入了解MySQL的基于开销的优化器，还可以获得很多可能被优化器考虑到的访问策略的细节，以及当运行SQL语句时哪种策略预计会被优化器采用。（QEP：sql生成一个执行计划query Execution plan）

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
mysql> explain select * from servers;
+----+-------------+---------+------+---------------+------+---------+------+------+-------+
| id | select_type | table   | type | possible_keys | key  | key_len | ref  | rows | Extra |
+----+-------------+---------+------+---------------+------+---------+------+------+-------+
|  1 | SIMPLE      | servers | ALL  | NULL          | NULL | NULL    | NULL |    1 | NULL  |
+----+-------------+---------+------+---------------+------+---------+------+------+-------+
row in set (0.03 sec)
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

expain出来的信息有10列，分别是id、select_type、table、type、possible_keys、key、key_len、ref、rows、Extra,下面对这些字段出现的可能进行解释：

## 1、 **id**

   **我的理解是SQL执行的顺序的标识,SQL从大到小的执行**

\1. id相同时，执行顺序由上至下

\2. 如果是子查询，id的序号会递增，id值越大优先级越高，越先被执行

3.id如果相同，可以认为是一组，从上往下顺序执行；在所有组中，id值越大，优先级越高，越先执行

 

 

## 2、select_type

   ***\*示查询中每个select子句的类型\****

(1) SIMPLE(简单SELECT,不使用UNION或子查询等)

(2) PRIMARY(查询中若包含任何复杂的子部分,最外层的select被标记为PRIMARY)

(3) UNION(UNION中的第二个或后面的SELECT语句)

(4) DEPENDENT UNION(UNION中的第二个或后面的SELECT语句，取决于外面的查询)

(5) UNION RESULT(UNION的结果)

(6) SUBQUERY(子查询中的第一个SELECT)

(7) DEPENDENT SUBQUERY(子查询中的第一个SELECT，取决于外面的查询)

(8) DERIVED(派生表的SELECT, FROM子句的子查询)

(9) UNCACHEABLE SUBQUERY(一个子查询的结果不能被缓存，必须重新评估外链接的第一行)

 

## 3、table

显示这一行的数据是关于哪张表的，有时不是真实的表名字,看到的是derivedx(x是个数字,我的理解是第几步执行的结果)

```sql
mysql> explain select * from (select * from ( select * from t1 where id=2602) a) b;
+----+-------------+------------+--------+-------------------+---------+---------+------+------+-------+
| id | select_type | table      | type   | possible_keys     | key     | key_len | ref  | rows | Extra |
+----+-------------+------------+--------+-------------------+---------+---------+------+------+-------+
|  1 | PRIMARY     | <derived2> | system | NULL              | NULL    | NULL    | NULL |    1 |       |
|  2 | DERIVED     | <derived3> | system | NULL              | NULL    | NULL    | NULL |    1 |       |
|  3 | DERIVED     | t1         | const  | PRIMARY,idx_t1_id | PRIMARY | 4       |      |    1 |       |
+----+-------------+------------+--------+-------------------+---------+---------+------+------+-------+
```

 

## 4、type

表示MySQL在表中找到所需行的方式，又称“访问类型”。

常用的类型有： **ALL, index, range, ref, eq_ref, const, system, NULL（从左到右，性能从差到好）**

**Select_type 说明查询中使用到的索引类型，如果没有用有用到索引则为all**

ALL：Full Table Scan， MySQL将遍历全表以找到匹配的行

index: Full Index Scan，index与ALL区别为index类型只遍历索引树

range:只检索给定范围的行，使用一个索引来选择行

ref: 表示上述表的连接匹配条件，即哪些列或常量被用于查找索引列上的值

eq_ref: 类似ref，区别就在使用的索引是唯一索引，对于每个索引键值，表中只有一条记录匹配，简单来说，就是多表连接中使用primary key或者 unique key作为关联条件

const、system: 当MySQL对查询某部分进行优化，并转换为一个常量时，使用这些类型访问。如将主键置于where列表中，MySQL就能将该查询转换为一个常量,system是const类型的特例，当查询的表只有一行的情况下，使用system

NULL: MySQL在优化过程中分解语句，执行时甚至不用访问表或索引，例如从一个索引列里选取最小值可以通过单独索引查找完成。

 

## 5、possible_keys

**指出MySQL能使用哪个索引在表中找到记录，查询涉及到的字段上若存在索引，则该索引将被列出，但不一定被查询使用**

该列完全独立于EXPLAIN输出所示的表的次序。这意味着在possible_keys中的某些键实际上不能按生成的表次序使用。
如果该列是NULL，则没有相关的索引。在这种情况下，可以通过检查WHERE子句看是否它引用某些列或适合索引的列来提高你的查询性能。如果是这样，创造一个适当的索引并且再次用EXPLAIN检查查询

 

## 6、Key

**key列显示MySQL实际决定使用的键（索引）**

如果没有选择索引，键是NULL。要想强制MySQL使用或忽视possible_keys列中的索引，在查询中使用FORCE INDEX、USE INDEX或者IGNORE INDEX。

 

## 7、key_len

***\*表示索引中使用的字节数，可通过该列计算查询中使用的索引的长度（key_len显示的值为索引字段的最大可能长度，并非实际使用长度，即key_len是根据表定义计算而得，不是通过表内检索出的）\****

不损失精确性的情况下，长度越短越好 

 

## 8、ref

**表示上述表的连接匹配条件，即哪些列或常量被用于查找索引列上的值**

 

## 9、rows

 **表示MySQL根据表统计信息及索引选用情况，估算的找到所需的记录所需要读取的行数**

 

## 10、Extra

**该列包含MySQL解决查询的详细信息,有以下几种情况：**

Using where:列数据是从仅仅使用了索引中的信息而没有读取实际的行动的表返回的，这发生在对表的全部的请求列都是同一个索引的部分的时候，表示mysql服务器将在存储引擎检索行后再进行过滤，表示优化器需要通过索引回表查询数据；

Using temporary：表示MySQL需要使用临时表来存储结果集，常见于排序和分组查询

Using filesort：MySQL中无法利用索引完成的排序操作称为“文件排序”

(如果出现以上的两种的红色的Using temporary和Using filesort说明效率低)

Using join buffer：改值强调了在获取连接条件时没有使用索引，并且需要连接缓冲区来存储中间结果。如果出现了这个值，那应该注意，根据查询的具体情况可能需要添加索引来改进能。

Impossible where：这个值强调了where语句会导致没有符合条件的行。

Select tables optimized away：这个值意味着仅通过使用索引，优化器可能仅从聚合函数结果中返回一行

 (复合索引再使用时，尽量的考虑查询时，常用的排序方向和字段组合顺序)

 

## 总结：

• EXPLAIN不会告诉你关于触发器、存储过程的信息或用户自定义函数对查询的影响情况
• EXPLAIN不考虑各种Cache
• EXPLAIN不能显示MySQL在执行查询时所作的优化工作
• 部分统计信息是估算的，并非精确值
• EXPALIN只能解释SELECT操作，其他操作要重写为SELECT后查看执行计划。**

