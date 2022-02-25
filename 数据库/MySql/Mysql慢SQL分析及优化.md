# [Mysql慢SQL分析及优化][https://www.cnblogs.com/you-men/p/14919288.html]

**目录**

- [为何对慢SQL进行治理](https://www.cnblogs.com/you-men/p/14919288.html#_label0)
- [Mysql执行原理](https://www.cnblogs.com/you-men/p/14919288.html#_label1)
- [影响因素](https://www.cnblogs.com/you-men/p/14919288.html#_label2)
- [解决思路](https://www.cnblogs.com/you-men/p/14919288.html#_label3)
- 案例 (mysql数据高CPU问题定位和优化)
  - [开启慢查询](https://www.cnblogs.com/you-men/p/14919288.html#_label4_0)
  - [查询一张没有索引的100w数据的表](https://www.cnblogs.com/you-men/p/14919288.html#_label4_1)
  - [查看系统资源消耗](https://www.cnblogs.com/you-men/p/14919288.html#_label4_2)
  - [mysql查看连接线程](https://www.cnblogs.com/you-men/p/14919288.html#_label4_3)
  - [查看慢日志](https://www.cnblogs.com/you-men/p/14919288.html#_label4_4)
  - [分析慢日志](https://www.cnblogs.com/you-men/p/14919288.html#_label4_5)
  - [加索引](https://www.cnblogs.com/you-men/p/14919288.html#_label4_6)
- 优化方向和注意点
  - [cpu优化方向](https://www.cnblogs.com/you-men/p/14919288.html#_label5_0)
  - [mysql性能测试优化方向](https://www.cnblogs.com/you-men/p/14919288.html#_label5_1)
  - [不走索引的情况(开发规范)](https://www.cnblogs.com/you-men/p/14919288.html#_label5_2)
  - [数据库注意事项](https://www.cnblogs.com/you-men/p/14919288.html#_label5_3)

 

------

[回到顶部](https://www.cnblogs.com/you-men/p/14919288.html#_labelTop)

***1\***|***0\*****为何对慢SQL进行治理**

从数据库角度看：每个SQL执行都需要消耗一定I/O资源，SQL执行的快慢，决定资源被占用时间的长短。假设总资源是100，有一条慢SQL占用了30的资源共计1分钟。那么在这1分钟时间内，其他SQL能够分配的资源总量就是70，如此循环，当资源分配完的时候，所有新的SQL执行将会排队等待。
从应用的角度看：SQL执行时间长意味着等待，在OLTP应用当中，用户的体验较差
​

治理的优先级上

1. master数据库->slave数据库
   - 目前数据库基本上都是读写分离架构，读在从库（slave）上执行，写在主库（master）上执行。
   - 由于从库的数据都是从主库上复制过去的，主库等待较多的，会加大与从库的复制时延。
2. 执行次数多的SQL优先治理
3. 如果有一类SQL高并发集中访问某一张表，应当优先治理。

[回到顶部](https://www.cnblogs.com/you-men/p/14919288.html#_labelTop)

***2\***|***0\*****Mysql执行原理**

绿色部分为SQL实际执行部分，可以发现SQL执行2大步骤：解析，执行。

以com_query为例，dispatch_command会先调用alloc_query为query buffer分配内存，之后调用解析

解析：词法解析->语法解析->逻辑计划->查询优化->物理执行计划

检查是否存在可用查询缓存结果，如果没有或者缓存失效，则调用mysql_execute_command执行
执行：检查用户、表权限->表上加共享读锁->取数据到query cache->取消共享读锁
​

[![img](https://img2020.cnblogs.com/blog/1871335/202106/1871335-20210622165101236-2106838826.png)](https://img2020.cnblogs.com/blog/1871335/202106/1871335-20210622165101236-2106838826.png)

[回到顶部](https://www.cnblogs.com/you-men/p/14919288.html#_labelTop)

***3\***|***0\*****影响因素**

如不考虑MySQL数据库的参数以及硬件I/O的影响， 则影响SQL执行效率的因素主要是I/O和CPU的消耗量
总结：

1. 数据量：数据量越大需要的I/O次数越多
2. 取数据的方式
   - 数据在缓存中还是在磁盘上
   - 是否可以通过索引快速寻址
3. 数据加工的方式
   - 排序、子查询等，需要先把数据取到临时表中，再对数据进行加工
   - 增加了I/O，且消耗大量CPU资源

[回到顶部](https://www.cnblogs.com/you-men/p/14919288.html#_labelTop)

***4\***|***0\*****解决思路**

1. 将数据存放在更快的地方。
   - 如果数据量不大，变化频率不高，但访问频率很高，此时应该考虑将数据放在应用端的缓存当中或者Redis这样的缓存当中，以提高存取速度。如果数据不做过滤、关联、排序等操作，仅按照key进行存取，且不考虑强一致性需求，也可考虑选用NoSQL数据库。
2. 适当合并I/O
   - 分别执行select c1 from t1与select c2 from t1，与执行select c1,c2 from t1相比，后者开销更小。
   - 合并时也需要考虑执行时间的增加。
3. 利用分布式架构
   - 在面对海量的数据时，通常的做法是将数据和I/O分散到多台主机上去执行。

[回到顶部](https://www.cnblogs.com/you-men/p/14919288.html#_labelTop)

***5\***|***0\*****案例 (mysql数据高CPU问题定位和优化)*****5\***|***1\*****开启慢查询**



```
## 开关
slow_query_log=1 
## 文件位置及名字 
slow_query_log_file=/data/mysql/slow.log
## 设定慢查询时间
long_query_time=0.4
## 没走索引的语句也记录
log_queries_not_using_indexes

vim /etc/my.cnf
slow_query_log=1 
slow_query_log_file=/data/mysql/slow.log
long_query_time=0.1
log_queries_not_using_indexes

mysql> select @@long_query_time;	# 默认十秒才记录慢日志
  
mysql> show variables like 'slow_query_log%';
mysql>  show variables like 'long%';
mysql>  show variables like '%using_indexes%';
```

***5\***|***2\*****查询一张没有索引的100w数据的表**

**五十个并发查询十t100w表,**



```
mysqlslap --defaults-file=/etc/my.cnf \
--concurrency=50 --iterations=1 --create-schema='oldboy' \
--query="select * from oldboy.t_100w where k2='FGCD'" engine=innodb \
--number-of-queries=10 -uroot -pZHOUjian.22 -verbose

mysqlslap: [Warning] Using a password on the command line interface can be insecure.
Benchmark
	Running for engine rbose
	Average number of seconds to run all queries: 26.447 seconds
	Minimum number of seconds to run all queries: 26.447 seconds
	Maximum number of seconds to run all queries: 26.447 seconds
	Number of clients running queries: 50
	Average number of queries per client: 0
```

***5\***|***3\*****查看系统资源消耗**

[![img](https://img2020.cnblogs.com/blog/1871335/202106/1871335-20210622165110332-736638832.png)](https://img2020.cnblogs.com/blog/1871335/202106/1871335-20210622165110332-736638832.png)

***5\***|***4\*****mysql查看连接线程**

**1 . 通过 show processlist; 或 show full processlist; 命令查看当前执行的查询，如下图所示：**

[![img](https://img2020.cnblogs.com/blog/1871335/202106/1871335-20210622165118541-714200480.png)](https://img2020.cnblogs.com/blog/1871335/202106/1871335-20210622165118541-714200480.png)

“Sending data”官网解释：
The thread is reading and processing rows for a SELECT statement, and sending data to the client. Because operations occurring during this state tend to perform large amounts of disk access (reads), it is often the longest-running state over the lifetime of a given query.
​

状态的含义，原来这个状态的名称很具有误导性，所谓的“Sending data”并不是单纯的发送数据，而是包括“收集 + 发送 数据”。

体现在:

1.没有使用索引
2.mysql索引表结构，要是没有使用主键查询的话，需要进行回表操作，在返回客户端。
3.返回的行数太多，需要频繁io交互

Copying to tmp table，Copying to tmp table on disk：官网解释：
Copying to tmp table The server is copying to a temporary table in memory. Copying to tmp table on disk The server is copying to a temporary table on disk. The temporary result set has become too large
​

整体来说生成临时表内存空间，落磁盘临时表，临时表使用太
体现在 多表join，buffer_size设置不合理，alter algrithem copy等方式
​

Sorting result：
For a SELECT statement, this is similar to Creating sort index, but for nontemporary tables.
结果集使用大的排序，基本上SQL语句上order by 字段上没有索引
上述的情况大量堆积，就会发现CPU飙升的情况，当然也有并发量太高的情况。
优化方向:

1.添加索引，组合索引，坚持2张表以内的join方式 这样查询执行成本就会大幅减少。
2.隐私转换避免，系统时间函数的调用避免
3.相关缓存大小设置：join_buffer_size，sort_buffer_size，read_buffer_size ,read_rnd_buffer_size ，tmp_table_size。
在紧急情况下，无法改动下，通过参数控制并发度，执行时间 innodb_thread_concurrency ，max_execution_time都是有效的临时控制手段。

***5\***|***5\*****查看慢日志**



```
mysql> show variables like 'slow_query_log%';
+---------------------+----------------------+
| Variable_name       | Value                |
+---------------------+----------------------+
| slow_query_log      | ON                   |
| slow_query_log_file | /data/mysql/slow.log |
+---------------------+----------------------+
2 rows in set (0.00 sec)
```

***5\***|***6\*****分析慢日志**



```
[root@master1 ~]# mysqldumpslow -s c -t 10 /data/mysql/slow.log

Reading mysql slow query log from /data/mysql/slow.log
Count: 50  Time=27.10s (1354s)  Lock=0.42s (20s)  Rows=270.0 (13500), root[root]@localhost
  select * from oldboy.t_100w where k2='S'

Count: 3  Time=0.68s (2s)  Lock=0.00s (0s)  Rows=262.0 (786), root[root]@localhost
  select * from t_100w where k2='S'

Died at /usr/bin/mysqldumpslow line 167, <> chunk 53.
```

***5\***|***7\*****加索引**



```
alter table t_100w add index idx(k2);

[root@master1 ~]# mysqlslap --defaults-file=/etc/my.cnf --concurrency=50 --iterations=1 --create-schema='oldboy' --query="select * from oldboy.t_100w where k2='FGCD'" engine=innodb --number-of-queries=10 -uroot -pZHOUjian.22 -verbose
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
Benchmark
	Running for engine rbose
	Average number of seconds to run all queries: 0.075 seconds
	Minimum number of seconds to run all queries: 0.075 seconds
	Maximum number of seconds to run all queries: 0.075 seconds
	Number of clients running queries: 50
	Average number of queries per client: 0
```

**五千个并发查询一百t100w表,**



```
[root@master1 ~]# mysqlslap --defaults-file=/etc/my.cnf --concurrency=5000 --iterations=1 --create-schema='oldboy' --query="select * from oldboy.t_100w where k2='FGCD'" engine=innodb --number-of-queries=100 -uroot -pZHOUjian.22 -verbose
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
Benchmark
	Running for engine rbose
	Average number of seconds to run all queries: 6.285 seconds
	Minimum number of seconds to run all queries: 6.285 seconds
	Maximum number of seconds to run all queries: 6.285 seconds
	Number of clients running queries: 5000
	Average number of queries per client: 0
```

****

[回到顶部](https://www.cnblogs.com/you-men/p/14919288.html#_labelTop)

***6\***|***0\*****优化方向和注意点*****6\***|***1\*****cpu优化方向**

- 对于MySQL硬件环境资源，建议CPU起步8核开始，SSD硬盘；
- 索引 ，合理设计表结构，优化SQL。
- 读写分离，将对数据一致性不敏感的查询转移到只读实例上，分担主库压力。
- 对于由应用负载高导致的 CPU 使用率高的状况，从应用架构、实例规格等方面来解决。
- 使用 Memcache 或者 Redis缓存技术，尽量从缓存中获取常用的查询结果，减轻数据库的压力。

***6\***|***2\*****mysql性能测试优化方向**

- 系统参数：磁盘调度算，SHELL资源限制,numa架构，文件系统ext4，exfs
- 刷新mysql log相关刷新参数：
  临近页（innodb_flush_neighbors）
  死锁检查机制（innodb_deadlock_detect），
  双1刷新：sync_binlog，innodb_flush_log_at_trx_commit
- 并发参数: innodb_buffer_pool_instances, innodb_thread_concurrency 等
- 因为一些服务器的特性，导致cpu通道 和 内存协调存在一些问题，导致cpu性能上去得案例也存在

***6\***|***3\*****不走索引的情况(开发规范)**

**1 . 没有查询条件，或者查询条件没有建立索引**



```
select * from tab;       全表扫描。
select  * from tab where 1=1;
在业务数据库中，特别是数据量比较大的表。
是没有全表扫描这种需求。
1、对用户查看是非常痛苦的。
2、对服务器来讲毁灭性的。
（1）
select * from tab;
SQL改写成以下语句：
select  * from  tab  order by  price  limit 10 ;    需要在price列上建立索引
（2）
select  * from  tab where name='zhangsan'          name列没有索引
改：
1、换成有索引的列作为查询条件
2、将name列建立索引
```

**2 . 查询结果集是原表中的大部分数据，应该是25％以上**



```
查询的结果集，超过了总数行数25%，优化器觉得就没有必要走索引了。

假如：tab表 id，name    id:1-100w  ，id列有(辅助)索引
select * from tab  where id>500000;
如果业务允许，可以使用limit控制。
怎么改写 ？
结合业务判断，有没有更好的方式。如果没有更好的改写方案
尽量不要在mysql存放这个数据了。放到redis里面。
```

**3 . 索引本身失效，统计数据不真实**



```
索引有自我维护的能力。
对于表内容变化比较频繁的情况下，有可能会出现索引失效。
一般是删除重建

现象:
有一条select语句平常查询时很快,突然有一天很慢,会是什么原因
select?  --->索引失效,，统计数据不真实
DML ?   --->锁冲突
```

**4 . 查询条件使用函数在索引列上，或者对索引列进行运算，运算包括(+，-，\*，/，! 等)**



```
例子：
错误的例子：select * from test where id-1=9;
正确的例子：select * from test where id=10;
算术运算
函数运算
子查询
```

**5 . 隐式转换导致索引失效.这一点应当引起重视.也是开发中经常会犯的错误.**



```
这样会导致索引失效. 错误的例子：
mysql> alter table tab add index inx_tel(telnum);
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0
mysql>
mysql> desc tab;
+--------+-------------+------+-----+---------+-------+
| Field  | Type        | Null | Key | Default | Extra |
+--------+-------------+------+-----+---------+-------+
| id    | int(11)    | YES  |    | NULL    |      |
| name  | varchar(20) | YES  |    | NULL    |      |
| telnum | varchar(20) | YES  | MUL | NULL    |      |
+--------+-------------+------+-----+---------+-------+
3 rows in set (0.01 sec)
mysql> select * from tab where telnum='1333333';
+------+------+---------+
| id  | name | telnum  |
+------+------+---------+
|    1 | a    | 1333333 |
+------+------+---------+
1 row in set (0.00 sec)
mysql> select * from tab where telnum=1333333;
+------+------+---------+
| id  | name | telnum  |
+------+------+---------+
|    1 | a    | 1333333 |
+------+------+---------+
1 row in set (0.00 sec)
mysql> explain  select * from tab where telnum='1333333';
+----+-------------+-------+------+---------------+---------+---------+-------+------+-----------------------+
| id | select_type | table | type | possible_keys | key    | key_len | ref  | rows | Extra                |
+----+-------------+-------+------+---------------+---------+---------+-------+------+-----------------------+

|  1 | SIMPLE      | tab  | ref  | inx_tel      | inx_tel | 63      | const |    1 | Using index condition |
+----+-------------+-------+------+---------------+---------+---------+-------+------+-----------------------+
1 row in set (0.00 sec)
mysql> explain  select * from tab where telnum=1333333;
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra      |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
|  1 | SIMPLE      | tab  | ALL  | inx_tel      | NULL | NULL    | NULL |    2 | Using where |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
1 row in set (0.00 sec)
mysql> explain  select * from tab where telnum=1555555;
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra      |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
|  1 | SIMPLE      | tab  | ALL  | inx_tel      | NULL | NULL    | NULL |    2 | Using where |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
1 row in set (0.00 sec)
mysql> explain  select * from tab where telnum='1555555';
+----+-------------+-------+------+---------------+---------+---------+-------+------+-----------------------+
| id | select_type | table | type | possible_keys | key    | key_len | ref  | rows | Extra                |
+----+-------------+-------+------+---------------+---------+---------+-------+------+-----------------------+
|  1 | SIMPLE      | tab  | ref  | inx_tel      | inx_tel | 63      | const |    1 | Using index condition |
+----+-------------+-------+------+---------------+---------+---------+-------+------+-----------------------+
1 row in set (0.00 sec)
mysql>
```

**6 . <> ，not in 不走索引（辅助索引）**



```
EXPLAIN  SELECT * FROM teltab WHERE telnum  <> '110';
EXPLAIN  SELECT * FROM teltab WHERE telnum  NOT IN ('110','119');

mysql> select * from tab where telnum <> '1555555';
+------+------+---------+
| id  | name | telnum  |
+------+------+---------+
|    1 | a    | 1333333 |
+------+------+---------+
1 row in set (0.00 sec)
mysql> explain select * from tab where telnum <> '1555555';

单独的>,<,in 有可能走，也有可能不走，和结果集有关，尽量结合业务添加limit
or或in  尽量改成union
EXPLAIN  SELECT * FROM teltab WHERE telnum  IN ('110','119');
改写成：
EXPLAIN SELECT * FROM teltab WHERE telnum='110'
UNION ALL
SELECT * FROM teltab WHERE telnum='119'
```

**7 . like "%_" 百分号在最前面不走**



```
EXPLAIN SELECT * FROM teltab WHERE telnum LIKE '31%'  走range索引扫描
EXPLAIN SELECT * FROM teltab WHERE telnum LIKE '%110'  不走索引
%linux%类的搜索需求，可以使用elasticsearch+mongodb 专门做搜索服务的数据库产品
```

**建立外键的规则**

1. 父子表中建立外键的字段数据类型需要一致
2. 关联父表时，父表的字段需要为父表
3. 如果父表为联合主键需要从第一个字段开始关联
4. 书写问题
5. 存储引擎 只有innodb才支持外键，其他不行，否则外键建立不成功
   建立有外键的父子表中不允许使用truncate table 只能使用delete进行删除数据



```
父子表写入数据时，如果想给子表中的外键写入数据，需要保证写入的数据在父表的主键列拥有该数据才能进行添加是否添加失败，用来保证数据的一致性
```

外键在进行建立的过程中需要重新写一行进行添加，不能跟在数据类型的后面进行建立

**自增**



```
# 自增，如果为某列设置自增列，插入数据时无需设置此列的值，默认将自增（表中只能有一个自增列）
create table tb1(
    id int auto_increment primary key,
    age int not null
)

show variables like '%auto_increment_%';
auto_increment_increment | 1    # 每次按照指定的数量自增
auto_increment_offset    | 1    # 自增量的初始量
set auto_increment_increment=2;
```

**创建表定义一对多关系**



```
create table student(
    id1 int  auto_increment primary key,
    name varchar(12) not null,
    age int not null,
    phone char(11)
);

create table student2(
    id int auto_increment primary key,
    class_id int,
    foreign key(class_id) REFERENCES student(id1)
);
```

**添加主键**



```
alter table 表名 add primary key(列名);
alter table students add id int not null auto_increment, add primary key (id);
```

**删除主键**



```
alter table 表名 drop primary key;
# 删除主键属性，保留原值和列

alter table 表名  modify  列名 int, drop primary key;
```

***6\***|***4\*****数据库注意事项**

**1、重要的sql必须被索引，例如：**
**1）select、update、delete语句的where条件列；**
**2）order by、group by、distinct字段**
**2、mysql索引的限制：**
**1）mysql目前不支持函数索引**
**2）使用不等于（！=或者<>）的时候，mysql无法使用索引,**单独的>,<,in 有可能走，也有可能不走，和结果集有关，尽量结合业务添加limitor或in 尽量改成union
**3）过滤字段使用单行函数 (如 abs (column)) 后, MYSQL无法使用索引。**
**4） join语句中join条件字段类型不一致的时候MYSQL 无法使用索引**
**5）使用 LIKE 操作的时候如果条件以通配符开始 (如 ‘%abc…’)时, MYSQL无法使用索引。**
**6）使用非等值查询的时候, MYSQL 无法使用 Hash 索引。**
**7）BLOB 和 TEXT 类型的列只能创建前缀索引**
**3、mysql常见sql规范：**
**1）SQL语句尽可能简单 大SQL语句尽可能拆成小SQL语句，MySQL对复杂SQL支持不好。**
**2）事务要简单，整个事务的时间长度不要太长，SQL结束后及时提交。**
**3）限制单个事务所操作的数据集大小，不能超过 10000 条记录**
**4）禁止使用触发器、函数、存储过程。**
**5）降低业务耦合度，为scale out、sharding留有余地**
**6）避免在数据库中进行数学运算（数据库不擅长数学运算和逻辑判断）**
**7）避免使用select \*，需要查询哪几个字段就select这几个字段，避免buffer pool被无用数据填充。**
**8）条件中使用到OR的SQL语句必须改写成用IN()（OR的效率比IN低很多）**
**9）IN()里面的数据个数建议控制在 500 以内，可以用exist代替in，exist在某些场景比in效率高，尽量不使**
**用not in。**
**10）limit分页注意效率。 limit越大，效率越低。可以改写limit，例如：**
**select id from test limit 10000,10 可以改写为 select id from test where id > 10000 limit 10**
**11）当只要一行数据时使用LIMIT 1 。**
**12）获取大量数据时，建议分批次获取数据，每次获取数据少于 10000 条，结果集应小于 1M**
**13）避免使用大表做 JOIN，使用group by分组、自动排序**
**14）SQL语句禁止出现隐式转换，例如：select id from test where id=’1’，其中 id 列为 int** **等数字**
**类型。**
**15）在SQL中，尽量不使用like，且禁止使用前缀是%的like匹配。**
**16）合理选择union all与union**
**17）禁止在OLTP类型系统中使用没有where条件的查询。**
**18）使用 prepared statement 语句，只传参数，比传递 SQL 语句更高效；一次解析，多次使用；降低SQL**
**注入概率。**
**19）禁止使用 order by rand().**
**20）禁止单条 SQL 语句同时更新多个表。**
**21）不在业务高峰期批量更新或查询数据库，避免在业务高峰期alter表。**
**22）禁止在主库上执行 sum,count** **等复杂的统计分析语句，可以使用从库来执行。**