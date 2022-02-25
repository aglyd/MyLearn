# 一、[MySQL索引使用说明(单列索引和多列索引)](https://www.jb51.net/article/133625.htm)

## 1. 单列索引

在性能优化过程中，选择在哪些列上创建索引是最重要的步骤之一。可以考虑使用索引的主要有两种类型的列：在Where子句中出现的列，在join子句中出现的列。请看下面这个查询：

```
Select age ## 不使用索引  
FROM people Where firstname='Mike' ## 考虑使用索引  
AND lastname='Sullivan' ## 考虑使用索引 
```

这个查询与前面的查询略有不同，但仍属于简单查询。由于age是在Select部分被引用，MySQL不会用它来限制列选择操作。因此，对于这个查询来说，创建age列的索引没有什么必要。

下面是一个更复杂的例子：

```
Select people.age, ##不使用索引  
town.name ##不使用索引  
FROM people LEFT JOIN town ON people.townid=town.townid ##考虑使用索引  
Where firstname='Mike' ##考虑使用索引  
AND lastname='Sullivan' ##考虑使用索引 
```

与前面的例子一样，由于firstname和lastname出现在Where子句中，因此这两个列仍旧有创建索引的必要。除此之外，由于town表的townid列出现在join子句中，因此我们需要考虑创建该列的索引。

那么，我们是否可以简单地认为应该索引Where子句和join子句中出现的每一个列呢？差不多如此，但并不完全。我们还必须考虑到对列进行比较的操作符类型。MySQL只有对以下操作符才使用索引：<，<=，=，>，>=，BETWEEN，IN，以及某些时候的LIKE。

可以在LIKE操作中使用索引的情形是指另一个操作数不是以通配符（%或者_）开头的情形。

例如：

```
Select peopleid FROM people Where firstname LIKE 'Mich%' 
```

这个查询将使用索引；但下面这个查询不会使用索引。

```
Select peopleid FROM people Where firstname LIKE '%ike'; 
```

## 2. 多列索引

索引可以是单列索引，也可以是多列索引。下面我们通过具体的例子来说明这两种索引的区别。假设有这样一个people表：

```sql
Create TABLE people (  
peopleid SMALLINT NOT NULL AUTO_INCREMENT,  
firstname CHAR(50) NOT NULL,  
lastname CHAR(50) NOT NULL,  
age SMALLINT NOT NULL,  
townid SMALLINT NOT NULL,  
PRIMARY KEY (peopleid) ); 
```

下面是我们插入到这个people表的数据：

这个数据片段中有四个名字为“Mikes”的人（其中两个姓Sullivans，两个姓McConnells），有两个年龄为17岁的人，还有一个名字与众不同的Joe Smith。

这个表的主要用途是根据指定的用户姓、名以及年龄返回相应的peopleid。例如，我们可能需要查找姓名为Mike Sullivan、年龄17岁用户的peopleid：

```sql
Select peopleid 
FROM people  
Where firstname='Mike'  
   AND lastname='Sullivan' AND age=17; 
```

由于我们不想让MySQL每次执行查询就去扫描整个表，这里需要考虑运用索引。

首先，我们可以考虑在单个列上创建索引，比如firstname、lastname或者age列。如果我们创建firstname列的索引（Alter TABLE people ADD INDEX firstname (firstname);），MySQL将通过这个索引迅速把搜索范围限制到那些firstname='Mike'的记录，然后再在这个“中间结果集”上进行其他条件的搜索：它首先排除那些lastname不等于“Sullivan”的记录，然后排除那些age不等于17的记录。当记录满足所有搜索条件之后，MySQL就返回最终的搜索结果。

由于建立了firstname列的索引，与执行表的完全扫描相比，MySQL的效率提高了很多，但我们要求MySQL扫描的记录数量仍旧远远超过了实际所需要的。虽然我们可以删除firstname列上的索引，再创建lastname或者age列的索引，但总地看来，不论在哪个列上创建索引搜索效率仍旧相似。

为了提高搜索效率，我们需要考虑运用多列索引。**如果为firstname、lastname和age这三个列创建一个多列索引，MySQL只需一次检索就能够找出正确的结果！**下面是创建这个多列索引的SQL命令：

```sql
Alter TABLE people  
ADD INDEX fname_lname_age (firstname,lastname,age); 
```

==由于索引文件以B-树格式保存，因此联合索引是有序的，不能跳过前面的索引查后面的索引（不是sql语句中where条件的前后顺序，而是不能跳过某个索引条件），MySQL能够立即转到合适的firstname，然后再转到合适的lastname，最后转到合适的age。在没有扫描数据文件任何一个记录的情况下，MySQL就正确地找出了搜索的目标记录！（oracle有索引跳跃式扫描，可以跳过前面的索引条件直接查后面的索引条件，例如where age也能使用联合索引）==

==那么，如果在firstname、lastname、age这三个列上分别创建单列索引，效果是否和创建一个firstname、lastname、age的多列索引一样呢？==

==答案是否定的，两者完全不同。当我们执行查询的时候，MySQL只能使用一个索引。如果你有三个单列的索引，**MySQL会试图选择一个限制最严格的索引。**但是，即使是限制最严格的单列索引，它的限制能力也肯定远远低于firstname、lastname、age这三个列上的多列索引。==

## 3. 多列索引中最左前缀（Leftmost Prefixing）

多列索引还有另外一个优点，它通过称为最左前缀（Leftmost Prefixing）的概念体现出来。继续考虑前面的例子，现在我们有一个firstname、lastname、age列上的多列索引，我们称这个索引为fname_lname_age。当搜索条件是以下各种列的组合时，MySQL将使用fname_lname_age索引：

firstname，lastname，age
firstname，lastname
firstname

==注意：Mysql不能跳过某个字段来进行查询,这样利用不到索引（如不查firstname直接查lastname），但sql中查询条件放置的顺序可以不按这个先后顺序排列（因为有查询优化器会优化最优查询，将最终的查询条件顺序排列为联合索引排列顺序）但是必须要有才能生效。但是Oracle此原则不生效，直接查lastname或者age也能用联合索引，因为Oracle有[索引跳跃式扫描（INDEX SKIP SCAN）](https://www.cnblogs.com/xqzt/p/4467482.html)==

从另一方面理解，它相当于我们创建了(firstname，lastname，age)、(firstname，lastname)以及(firstname)这些列组合上的索引。下面这些查询都能够使用这个fname_lname_age索引：

```sql
Select peopleid FROM people  
Where firstname='Mike' AND lastname='Sullivan' AND age='17';//firstname、lastname、age也可以不按此顺序查询，但是不能缺查询条件，如缺了lastname则age不会使用联合索引，而只有firstname使用联合索引

Select peopleid FROM people  
Where firstname='Mike' AND lastname='Sullivan';

Select peopleid FROM people  
Where firstname='Mike';
```

下面这些查询不能够使用这个`fname_lname_age`索引：

```sql
Select peopleid FROM people  
Where lastname='Sullivan';

Select peopleid FROM people  
Where age='17';

Select peopleid FROM people  
Where lastname='Sullivan' AND age='17';
```



---

# 二、[联合索引（多列索引）](https://blog.csdn.net/lm1060891265/article/details/81482328)

**如果索引方法是B+tree时：**

**联合索引是指对表上的多个列进行索引，联合索引也是一棵B+树，不同的是联合索引的键值数量不是1，而是大于等于2.**

**最左匹配原则**



假定上图联合索引的为（a,b）。==联合索引也是一棵B+树，不同的是B+树在对索引**a排序的基础上**，对索引b排序。==所以数据按照（1,1),(1,2)......顺序排放。

对于selete * from table where a=XX and b=XX，显然是可以使用(a,b)联合索引的，

对于selete * from table where a=XX，也是可以使用(a,b)联合索引的。因为在这两种情况下，叶子节点中的数据都是有序的。

但是，对于b列的查询，selete * from table where b=XX。则不可以使用这棵B+树索引。可以发现叶子节点的b值为1,2,1,4,1,2。显然不是有序的，因此不能使用(a,b)联合索引。

==By the way:selete * from table where b=XX and a=XX,也是可以使用到联合索引的，你可能会有疑问，这条语句并不符合最左匹配原则。这是由于查询优化器的存在，mysql查询优化器会判断纠正这条sql语句该以什么样的顺序执行效率最高，最后才生成真正的执行计划。所以，当然是我们能尽量的利用到索引时的查询顺序效率最高咯，所以mysql查询优化器会最终以这种顺序进行查询执行。==

==**优化：在联合索引中将选择性最高的列放在索引最前面。（创建联合索引时将选择性最多或查询最频繁的列放最前面）**==

例如：在一个公司里以age 和gender为索引，显然age要放在前面，因为性别就两种选择男或女，选择性不如age。



---

# 三、[mysql索引之五：多列索引](https://www.cnblogs.com/duanxz/p/5244737.html)

## 索引的三星原则

1.索引将相关的记录放到一起，则获得一星

2.如果索引中的数据顺序和查找中的排列顺序一致则获得二星

3.如果索引中的列包含了查询中的需要的全部列则获得三星

##  

## 多列索引

### 1.1、多个单列索引

　　很多人对多列索引的理解都不够。一个常见的错误就是，为每个列建立独立的索引，或者按照错误的顺序创建多列索引。

　　我们会在稍后的章节中单独讨论索引列的顺序问题。先来看第一个问题，为每个列创建独立的索引，从SHOW CREATE TABLE 中很容易看到这种情况：

```sql
CREATE TABLE t(
 　c1 INT,c2 INT , c3 INT ,KEY(c1),KEY(c2),KEY(c3)
);
```

　　这种索引策略，一般是由于人们听到一些专家诸如“把WHERE 条件里面的列都建上索引”这样模糊的建议导致的。实际上这个建议是非常错误的。这样一来最好的情况也只能是“一星”索引，其性能比起真正最有效的索引可能差几个数量级。有时如果无法设计出一个“三星”索引，那么不如忽略掉WHERE 子句，集中精力优化索引列的顺序，或者创建一个全覆盖索引。

**索引合并**

　　在多个列上建立独立的单列索引大部分情况下不能提高MySQL的查询性能。MySQL5.0和更高的版本引用了一种叫“**索引合并**”策略，一定程度上可以使用表上的多个单列索引来定位指定的行。更早版本的MySQL只能使用其中某一个单列索引，然而这种情况下没有哪一个独立索引是非常有效的。例如在film_actor在字段film_id和actor_id上各有一个单列索引。但是对于这个查询WHERE 条件，这两个单列索引都不是好的选择：

```sql
SELECT film_id ,actor_id FROM film_actor WHERE actor_id=1 or film_id =1;
```

　　在老的MySQL版本中，MySQL对于这个查询是会使用全表扫描的，除非改写成如下的两个查询UNION的方式：

```sql
SELECT film_id ,actor_id FROM film_actor WHERE actor_id=1
　　UNION ALL
　　SELECT film_id ,actor_id FROM film_actor WHERE film_id=1；
```

但是在MySQL5.0 和更高的版本中，查询能够同时使用者两个单列索引进行扫扫描，并将结果进行合并。这种算法有三个变种：OR条件的联合（union），AND条件的相交（intersection），组合前面两种情况的联合及相交。下面的查询就是使用了两个索引扫描的联合，通过EXPLAIN中的Extra列可以看出这点：

```sql
EXPLAIN SELECT film_id,actor_id FROM film_actor WHERE actor_id=1 or film_id = 1 \G
```

![img](MySQL多列索引.assets/285763-20170830112532999-497691568.png)　

MySQL会使用这类技术优化负责的查询，所以在某些语句的EXTRA列中还可以看到嵌套操作。

　　索引合并策略有时候是一种优化的结构，但实际上更多的时候说明了**表上的索引建的很糟糕**：

　　当出现服务器对多个索引做相交操作（通常有多个AND条件），通常意味着需要一个包含所有相关列的多个索引，而不是独立的单列索引。

　　**当服务器需要对多个索引做联合操作（通常有多个OR条件），通常需要耗费大量的cpu和内存资源在算法的缓冲，排序和合并的操作上。特别是当其中有些索引的选择性不高（命中索引的数据范围过宽也会查出大量数据）。需要合并扫描返回大量数据的时候(大量磁盘IO)。**

　　更重要的是，优化器不会吧这些成本算到“查询成本”中，游虎丘只关心随机页面读取。这会使得查询成本被低估，导致该执行计划还不如直接走全表扫描。这样做不但会消耗更多的cup和内存资源，还可能影响查询的并发性，但如果是单独鱼腥这样的查询则往往会忽略对并发现的影响。通常来说，还不弱在MySQL4.1或更早的时代一样，将查询改写成UNION的方式往往会更好。

**如果在Explain语句中看到索引合并，应该好好检查一下查询和表的结构。也可以通过参数optimizer_switch来关闭索引合并功能。也可以使用IGNORE_INDEX提示让优化器忽略掉某些索引。**



 

为了提高搜索效率，我们需要考虑运用多列mysql数据库索引。如果为firstname、lastname和age这三个列创建一个多列索引，MySQL只需一次检索就能够找出正确的结果！===下面是创建这个复合索引的SQL命令：

```sql
ALTER TABLE people ADD INDEX fname_lname_age (firstname,lastname,age)； 
```

由于索引文件以B-树格式保存，MySQL能够立即转到合适的firstname，然后再转到合适的lastname，最后转到合适的age。在没有扫描数据文件任何一个记录的情况下，MySQL就正确地找出了搜索的目标记录！

那么，如果在firstname、lastname、age这三个列上分别创建单列索引，效果是否和创建一个firstname、lastname、age的多列MySQL数据库索引一样呢？答案是否定的，两者完全不同。**当我们执行查询的时候，MySQL只能使用一个索引。如果你有三个单列的MySQL数据库索引，MySQL会试图选择一个限制最严格的索引。**

但是，即使是限制最严格的单列索引，它的限制能力也肯定远远低于firstname、lastname、age这三个列上的多列索引。

索引是快速搜索的关键。MySQL索引的建立对于MySQL的高效运行是很重要的。

### 1.2、复合索引

联合索引又叫复合索引。对于复合索引：Mysql从左到右的使用索引中的字段，一个查询可以只使用索引中的一部份，但只能是最左侧部分。例如索引是key index （a,b,c）。 可以支持a | a,b| a,b,c 3种组合进行查找，但不支持 b,c进行查找 .当最左侧字段是常量引用时，索引就十分有效。两个或更多个列上的索引被称作复合索引。

 **见《[mysql索引之四：复合索引之最左前缀原理，索引选择性，索引优化策略之前缀索引](http://www.cnblogs.com/duanxz/p/5244736.html)》**



---

# 四、[介绍mysql的索引类型,再讲mysql索引的利与弊,以及建立索引时需要注意的地方](https://www.cnblogs.com/chenshishuo/p/5030029.html)

首先:先假设有一张表,表的数据有10W条数据,其中有一条数据是nickname='css',如果要拿这条数据的话需要些的sql是 SELECT * FROM award WHERE nickname = 'css'

一般情况下,在没有建立索引的时候,mysql需要扫描全表及扫描10W条数据找这条数据,如果我在nickname上建立索引,那么mysql只需要扫描一行数据及为我们找到这条nickname='css'的数据,是不是感觉性能提升了好多咧....

mysql的索引分为单列索引(主键索引,唯索引,普通索引)和组合索引.

单列索引:一个索引只包含一个列,一个表可以有多个单列索引.

组合索引:一个组合索引包含两个或两个以上的列,

本文使用的案例的表

```sql
CREATE TABLE `award` (
   `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
   `aty_id` varchar(100) NOT NULL DEFAULT '' COMMENT '活动场景id',
   `nickname` varchar(12) NOT NULL DEFAULT '' COMMENT '用户昵称',
   `is_awarded` tinyint(1) NOT NULL DEFAULT 0 COMMENT '用户是否领奖',
   `award_time` int(11) NOT NULL DEFAULT 0 COMMENT '领奖时间',
   `account` varchar(12) NOT NULL DEFAULT '' COMMENT '帐号',
   `password` char(32) NOT NULL DEFAULT '' COMMENT '密码',
   `message` varchar(255) NOT NULL DEFAULT '' COMMENT '获奖信息',
   `created_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
   `updated_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='获奖信息表';
```

## (一)索引的创建

### 1.单列索引

#### 1-1)   普通索引,这个是最基本的索引,

其sql格式是 CREATE INDEX IndexName ON `TableName`(`字段名`(length)) 或者 ALTER TABLE TableName ADD INDEX IndexName(`字段名`(length))

**第一种方式 :**

```sql
  CREATE INDEX account_Index ON `award`(`account`);
```

**第二种方式:** 

```sql
ALTER TABLE award ADD INDEX account_Index(`account`)
```

 

**如果是CHAR,VARCHAR,类型,length可以小于字段的实际长度,如果是BLOB和TEXT类型就必须指定长度**



在执行CREATE TABLE语句时可以创建索引，也可以单独用CREATE INDEX或ALTER TABLE来为表增加索引。
**(1)．ALTER TABLE**
**ALTER TABLE用来创建普通索引、UNIQUE索引或PRIMARY KEY索引。**
ALTER TABLE table_name ADD INDEX index_name (column_list)
ALTER TABLE table_name ADD UNIQUE (column_list)
ALTER TABLE table_name ADD PRIMARY KEY (column_list)
其中table_name是要增加索引的表名，column_list指出对哪些列进行索引，多列时各列之间用逗号分隔。
**索引名index_name可选，缺省时，MySQL将根据第一个索引列赋一个名称。**
==另外，ALTER TABLE允许在单个语句中更改多个表，因此可以在同时创建多个索引。==
**(2)．CREATE INDEX**
**CREATE INDEX可对表增加普通索引或UNIQUE索引。**
CREATE INDEX index_name ON table_name (column_list)
CREATE UNIQUE INDEX index_name ON table_name (column_list)
table_name、index_name和column_list具有与ALTER TABLE语句中相同的含义，**索引名不可选，MySQL将根据第一个索引列赋一个名称。**
==另外，不能用CREATE INDEX语句创建PRIMARY KEY索引。==
**(3)．索引类型**
在创建索引时，可以规定索引能否包含重复值。如果不包含，则索引应该创建为PRIMARY KEY或UNIQUE索引。
对于单列惟一性索引，这保证单列不包含重复的值。对于多列惟一性索引，保证多个值的组合不重复。
PRIMARY KEY索引和UNIQUE索引非常类似。
**事实上，PRIMARY KEY索引仅是一个具有名称PRIMARY的UNIQUE索引。**
**这表示一个表只能包含一个PRIMARY KEY，因为一个表中不可能具有两个同名的索引。**

#### 1-2)   唯一索引,与普通索引类似,但是不同的是唯一索引要求所有的类的值是唯一的,这一点和主键索引一样.但是他允许有空值,

其sql格式是 CREATE UNIQUE INDEX IndexName ON `TableName`(`字段名`(length)); 或者 ALTER TABLE TableName ADD UNIQUE (column_list)  

```sql
CREATE UNIQUE INDEX account_UNIQUE_Index ON `award`(`account`);
ALTER TABLE `award` ADD UNIQUE (`account`);
```

#### 1-3)   主键索引,不允许有空值,(在B+TREE中的InnoDB引擎中,主键索引起到了至关重要的地位)

主键索引建立的规则是 int优于varchar,一般在建表的时候创建,最好是与表的其他字段不相关的列或者是业务不相关的列.一般会设为 int 而且是 AUTO_INCREMENT自增类型的

#### **1-4）查看目标表中已添加的索引**

```sql
--在数据库中查找表名
select * from user_tables where  table_name like 'tablename%';
--查看该表的所有索引
select * from all_indexes where table_name = 'tablename';
 --查看该表的所有索引列
select* from all_ind_columns where table_name = 'tablename';
```



### 2.组合索引

一个表中含有多个单列索引不代表是组合索引,通俗一点讲 组合索引是:包含多个字段但是只有索引名称

其sql格式是 CREATE INDEX IndexName On `TableName`(`字段名`(length),`字段名`(length),...);

```sql
 CREATE INDEX nickname_account_createdTime_Index ON `award`(`nickname`, `account`, `created_time`);
```

 

![img](MySQL多列索引.assets/825922-20151208174949261-1124930886.png)

如果你建立了 组合索引(nickname_account_createdTime_Index) 那么他实际包含的是3个索引 (nickname) (nickname,account)(nickname,account,created_time)

在使用查询的时候遵循mysql组合索引的"最左前缀",下面我们来分析一下 什么是最左前缀:及索引where时的条件要按照建立索引的时候字段的排序方式

1、==不能跳过索引字段查询（多列索引），因为索引文件是B+tree排列，下一索引都是在上一索引基础上排列的。但是会尽量匹配到能匹配的索引== 例如index(‘c1’, ‘c2’, ‘c3’) where ‘c2’ = ‘aaa’ 不使用索引,where `c2` = `aaa` and `c3`=`sss` 不能使用索引，但是where c1=‘xxx’ and c3=‘xxx’，能索引到c1。

2、==查询中某个列有（>、>=、<、<=）和like ‘%xx’的范围查询条件，则其后面的所有索引列都无法使用查询（多列查询），因为索引对此范围查询无效，如果联合索引的某个索引卡住了会导致下一索引也无法进行（联合索引是B+tree排列的，下一索引是在上一索引的基础上建立的）==

- Where c1= ‘xxx’ and c2 like = ‘%aa’ and c3=’sss’，只会查c1索引 ，因为like ‘’%xx’无法使用索引范围查询

- 而Where c1= ‘xxx’ and c2 like = ‘aa%’ and c3=’sss’ 查询则会使用索引中的前两列，因为like ‘xxx%’还会先查找等于xxx的条件（此时可使用索引），再在此基础上进行范围查询匹配，因此like ‘xxx%’会使用到索引

- ,比如我的sql 是 explain select * from `award` where nickname > 'rSUQFzpkDz3R' and account = 'DYxJoqZq2rd7' and created_time = 1449567822; 那么这时候他使用不到其组合索引，因为第一个索引nickname就无法使用索引卡住了，

  因为我的索引是 (nickname, account, created_time),如果第一个字段nickname出现 范围符号（>）的查找,那么将不会用到索引,后面的索引更无法进行，如果我是第二个或者第三个字段使用范围符号的查找,那么他会利用索引，利用的索引是该范围查找索引之前的索引（会尽量用到能用到的索引）



因为上面说了建立组合索引(nickname, account, created_time), 会出现三个索引

![img](MySQL多列索引.assets/825922-20151208175655246-167975238.png)

 ![img](MySQL多列索引.assets/825922-20151214150122302-1869707260.png)

(3)全文索引

文本字段上(text)如果建立的是普通索引,那么只有对文本的字段内容前面的字符进行索引,其字符大小根据索引建立索引时申明的大小来规定.

如果文本中出现多个一样的字符,而且需要查找的话,那么其条件只能是 where column lick '%xxxx%' 这样做会让索引失效

.这个时候全文索引就祈祷了作用了

```
ALTER TABLE tablename ADD FULLTEXT(column1, column2)
```

有了全文索引，就可以用SELECT查询命令去检索那些包含着一个或多个给定单词的数据记录了。

```
ELECT * FROM tablename
WHERE MATCH(column1, column2) AGAINST(‘xxx′, ‘sss′, ‘ddd′)
```

这条命令将把column1和column2字段里有xxx、sss和ddd的数据记录全部查询出来。

 

## **(二)索引的删除**

利用ALTER TABLE或DROP INDEX语句来删除索引。
类似于CREATE INDEX语句，DROP INDEX可以在ALTER TABLE内部作为一条语句处理，
语法如下:
DROP INDEX index_name ON talbe_name
ALTER TABLE table_name DROP INDEX index_name
ALTER TABLE table_name DROP PRIMARY KEY
其中，前两条语句是等价的，删除掉table_name中的索引index_name。
第3条语句只在删除PRIMARY KEY索引时使用，因为一个表只可能有一个PRIMARY KEY索引，因此不需要指定索引名。
如果没有创建PRIMARY KEY索引，但表具有一个或多个UNIQUE索引，则MySQL将删除第一个UNIQUE索引。
如果从表中删除了某列，则索引会受到影响。
对于多列组合的索引，如果删除其中的某列，则该列也会从索引中删除。如果删除组成索引的所有列，则整个索引将被删除。

## **(三)使用索引的优点**

1.可以通过建立唯一索引或者主键索引,保证数据库表中每一行数据的唯一性.
2.建立索引可以大大提高检索的数据,以及减少表的检索行数
3.在表连接的连接条件 可以加速表与表直接的相连
4.在分组和排序字句进行数据检索,可以减少查询时间中 分组 和 排序时所消耗的时间(数据库的记录会重新排序)
5.建立索引,在查询中使用索引 可以提高性能

 可以利用索引进行有序查找（如二分查找法），并快速定位到匹配的值，以节省大量搜索时间。

索引列上，除了上面提到的有序查找之外，数据库利用各种各样的快速定位技术，能够大大提高查询效率。
特别是当数据量非常大，查询涉及多个表时，使用索引往往能使查询速度加快成千上万倍。
例如，有3个未索引的表t1、t2、t3，分别只包含列c1、c2、c3，每个表分别含有1000行数据组成，指为1～1000的数值，
查找对应值相等行的查询如下所示。
SELECT c1,c2,c3 FROM t1,t2,t3 WHERE c1=c2 AND c1=c3
此查询结果应该为1000行，每行包含3个相等的值。在无索引的情况下处理此查询，必须寻找3个表所有的组合，
以便得出与WHERE子句相配的那些行。而可能的组合数目为1000×1000×1000（十亿），显然查询将会非常慢。
如果对每个表进行索引（==重点：关联字段上==），就能极大地加速查询进程。利用索引的查询处理如下。
（1）从表t1中选择第一行，查看此行所包含的数据。
（2）==使用表t2上的索引，直接定位t2中与t1的值匹配的行==。类似，利用表t3上的索引，直接定位t3中与来自t1的值匹配的行。
（3）扫描表t1的下一行并重复前面的过程，直到遍历t1中所有的行。
在此情形下，仍然对表t1执行了一个完全扫描，但能够在表t2和t3上进行索引查找直接取出这些表中的行，比未用索引时要快一百万倍。
利用索引，MySQL加速了WHERE子句满足条件行的搜索，而在多表连接查询时，在执行连接时加快了与其他表中的行匹配的速度。

## **(四)使用索引的缺点**

1.在创建索引和维护索引 会耗费时间,随着数据量的增加而增加
2.索引文件会占用物理空间,除了数据表需要占用物理空间之外,每一个索引还会占用一定的物理空间
3.当对表的数据进行 INSERT,UPDATE,DELETE 的时候,索引也要动态的维护,这样就会降低数据的维护速度,(建立索引会占用磁盘空间的索引文件。一般情况这个问题不太严重，但如果你在一个大表上创建了多种组合索引，索引文件的会膨胀很快)。==**解决办法：分库分表，分为读库和写库，只对读库建立索引而写库不建立索引**==

## **(五)==使用索引需要注意的地方==**

在建立索引的时候应该考虑索引应该建立在数据库表中的某些列上面 哪一些索引需要建立,哪一些索引是多余的.
一般来说,
1.在经常需要搜索的列上,可以加快索引的速度
2.主键列上可以确保列的唯一性
3.**在表与表的而连接条件上加上索引,可以加快连接查询的速度（关联查询时直接关联索引查询，不再需要全表扫描取出字段再比对）**
4.在经常需要排序(order by),分组(group by)和的distinct 列上加索引 可以加快排序查询的时间,  (**单独order by 用不了索引，索引考虑加where 或加limit)**
5.在一些where 之后的 <、 <=、 >、 >= 、BETWEEN IN 以及某个情况下的like 建立字段的索引(B-TREE)

6.**like语句的 如果你对nickname字段建立了一个索引.当查询的时候的语句是 nickname lick '%ABC%' 那么这个索引讲不会起到作用.而nickname lick =='ABC%'== 那么将可以用到索引**

7.**==索引不会包含NULL列,如果列中包含NULL值都将不会被包含在索引中,复合索引中如果有一列含有NULL值那么这个组合索引都将失效,一般需要给默认值0或者 ' '字符串==**

8.使用短索引,如果你的一个字段是Char(32)或者int(32),在创建索引的时候指定前缀长度 比如前10个字符 (==前提是多数值是唯一的..，只需要前面几个字符即可唯一确定==)那么短索引可以提高查询速度,并且可以减少磁盘的空间,也可以减少I/0操作.

9.不要在列上进行运算,这样会使得mysql索引失效,也会进行全表扫描

10==.选择越小的数据类型==越好,因为通常越小的数据类型通常在磁盘,内存,cpu,缓存中 占用的空间很少,处理起来更快

11.==**选择性越高的列建立索引越好，选择性越低，索引对应的数据量比例越高，索引越无效（有没有都无所谓），选择性越高索引的作用越高（因为需要查找越多的数据，通过索引可以更快查找到）**==

## **(六)什么情况下不创建索引**

1.查询中很少使用到的列 不应该创建索引,如果建立了索引然而还会降低mysql的性能和增大了空间需求.
2.很少选择性数据的列（值比较单一）也不应该建立索引,比如 一个性别字段 0或者1,在查询中,结果集的数据占了表中数据行的比例比较大,mysql需要扫描的行数很多,增加索引,并不能提高效率，相反选择性越高的列建立索引越好。
3.**定义为text和image和bit数据类型的列不应该增加索引**
4.当表的修改(UPDATE,INSERT,DELETE)操作远远大于检索(SELECT)操作时不应该创建索引,这两个操作是互斥的关系



----

# 五、[最左前缀匹配原则](https://www.cnblogs.com/ljl150/p/12934071.html)

**最左前缀匹配原则：**在MySQL建立联合索引时会遵守最左前缀匹配原则，即最左优先，在检索数据时从联合索引的最左边开始匹配。

　　要想理解联合索引的最左匹配原则，先来理解下索引的底层原理。索引的底层是一颗B+树，那么联合索引的底层也就是一颗B+树，只不过联合索引的B+树节点中存储的是键值。由于构建一棵B+树只能根据一个值来确定索引关系，所以数据库依赖联合索引最左的字段来构建。

举例：创建一个（a,b）的联合索引，那么它的索引树就是下图的样子。

![img](MySQL多列索引.assets/1804577-20200521182659976-48843100.png)

 　可以看到a的值是有顺序的，1，1，2，2，3，3，而b的值是没有顺序的1，2，1，4，1，2。但是我们又可发现a在等值的情况下，b值又是按顺序排列的，但是这种顺序是相对的。这是因为MySQL创建联合索引的规则是首先会对联合索引的最左边第一个字段排序，在第一个字段的排序基础上，然后在对第二个字段进行排序。所以b=2这种查询条件没有办法利用索引。

　　由于整个过程是基于explain结果分析的，那接下来在了解下explain中的type字段和key_lef字段。

　　**1.type**：**联接类型。下面给出各种联接类型,按照从最佳类型到最坏类型进行排序:（重点看ref,rang,index）**

　　　　system：表只有一行记录（等于系统表），这是const类型的特例，平时不会出现，可以忽略不计
　　　　const：表示通过索引一次就找到了，const用于比较primary key 或者 unique索引。因为只需匹配一行数据，所有很快。如果将主键置于where列表中，mysql就能将该查询转换为一个const
　　　　eq_ref：唯一性索引扫描，对于每个索引键，表中只有一条记录与之匹配。常见于主键 或 唯一索引扫描。
　　　　注意：ALL全表扫描的表记录最少的表如t1表
　　　　**ref**：非唯一性索引扫描，返回匹配某个单独值的所有行。本质是也是一种索引访问，它返回所有匹配某个单独值的行，然而他可能会找到多个符合条件的行，所以它应该属于查找和扫描的混合体。
　　　　**range**：==只检索给定范围的行，使用一个索引来选择行。key列显示使用了那个索引。一般就是在where语句中出现了bettween、<、>、in等的查询。这种索引列上的范围扫描比全索引扫描要好。只需要开始于某个点，结束于另一个点，不用扫描全部索引。==
　　　　**index**：Full Index Scan，index与ALL区别为index类型只遍历索引树。这通常为ALL块，应为索引文件通常比数据文件小。（Index与ALL虽然都是读全表，但index是从索引中读取，而ALL是从硬盘读取）
　　　　ALL：Full Table Scan，遍历全表以找到匹配的行

　　**2.key_len**：**显示MySQL实际决定使用的索引的长度。如果索引是NULL，则长度为NULL。如果不是NULL，则为使用的索引的长度。所以通过此字段就可推断出使用了那个索引。**

　　　　计算规则：

　　　　1.定长字段，int占用4个字节，date占用3个字节，char(n)占用n个字符。

　　　　2.变长字段varchar(n)，则占用n个字符+两个字节。

　　　　3.不同的字符集，一个字符占用的字节数是不同的。Latin1编码的，一个字符占用一个字节，gdk编码的，一个字符占用两个字节，utf-8编码的，一个字符占用三个字节。

　　　　（由于我数据库使用的是Latin1编码的格式，所以在后面的计算中，一个字符按一个字节算）

　　　　4.对于所有的索引字段，如果设置为NULL，则还需要1个字节。

接下来进入正题！！！

示例：

首先创建一个表

![img](MySQL多列索引.assets/1804577-20200521193154655-543474107.png)

 该表中对id列.name列.age列建立了一个联合索引 id_name_age_index，实际上相当于建立了三个索引（id）（id_name）（id_name_age）。

下面介绍下可能会使用到该索引的几种情况：

**1.全值匹配查询时**

![img](MySQL多列索引.assets/1804577-20200521202947593-2126832810.png)

![img](MySQL多列索引.assets/1804577-20200521203003652-366842075.png)

![img](MySQL多列索引.assets/1804577-20200521203020127-1655735915.png)

　　通过观察上面的结果图可知，where后面的查询条件，不论是使用（id，age，name）（name，id，age）还是（age，name，id）顺序，在查询时都使用到了联合索引，可能有同学会疑惑，为什么底下两个的搜索条件明明没有按照联合索引从左到右进行匹配，却也使用到了联合索引？ 这是因为**MySQL中有查询优化器explain**，所以sql语句中字段的顺序不需要和联合索引定义的字段顺序相同，查询优化器会判断纠正这条SQL语句以什么样的顺序执行效率高，最后才能生成真正的执行计划，所以不论以何种顺序都可使用到联合索引。另外通过观察上面三个图中的key_len字段，也可说明在搜索时使用的联合索引中的（id_name_age）索引，因为id为int型，允许null，所以占5个字节，name为char(10)，允许null，又使用的是latin1编码，所以占11个字节，age为int型允许null，所以也占用5个字节，所以该索引长度为21（5+11+5），而上面key_len的值也正好为21，可证明使用的（id_name_age）索引。

**2.匹配最左边的列时**

 

**![img](MySQL多列索引.assets/1804577-20200521202447168-1029938685.png)**

　　该搜索是遵循最左匹配原则的，通过key字段也可知，在搜索过程中使用到了联合索引，且使用的是联合索引中的（id）索引，因为key_len字段值为5，而id索引的长度正好为5（因为id为int型，允许null，所以占5个字节）。

![img](MySQL多列索引.assets/1804577-20200521202737461-1486677111.png)

　　由于id到name是从左边依次往右边匹配，这两个字段中的值都是有序的，所以也遵循最左匹配原则，通过key字段可知，在搜索过程中也使用到了联合索引，但使用的是联合索引中的（id_name）索引，因为key_len字段值为16，而(id_name)索引的长度正好为16（因为id为int型，允许null，所以占5个字节，name为char(10)，允许null，又使用的是latin1编码，所以占11个字节）。

![img](MySQL多列索引.assets/1804577-20200521202810363-1061003410.png)

　　由于上面三个搜索都是从最左边id依次向右开始匹配的，所以都用到了id_name_age_index联合索引。

　　那如果不是依次匹配呢？

![img](MySQL多列索引.assets/1804577-20200521204203700-302471529.png)

　　通过key字段可知，在搜索过程中也使用到了联合索引，但使用的是联合索引中的（id）索引，从key_len字段也可知。因为联合索引树是按照id字段创建的，但age相对于id来说是无序的，只有id只有序的，所以他只能使用联合索引中的id索引。

![img](MySQL多列索引.assets/1804577-20200521203757147-65081383.png)

　　通过观察发现上面key字段发现在搜索中也使用了id_name_age_index索引，可能许多同学就会疑惑它并没有遵守最左匹配原则，按道理会索引失效，为什么也使用到了联合索引？因为没有从id开始匹配，且name单独来说是无序的，所以它确实不遵循最左匹配原则，然而从type字段可知，它虽然使用了联合索引，但是它是对整个索引树进行了扫描，正好匹配到该索引，与最左匹配原则无关，一般只要是某联合索引的一部分，但又不遵循最左匹配原则时，都可能会采用index类型的方式扫描，但它的效率远不如最做匹配原则的查询效率高，index类型类型的扫描方式是从索引第一个字段一个一个的查找，直到找到符合的某个索引，与all不同的是，index是对所有索引树进行扫描，而all是对整个磁盘的数据进行全表扫描。

**==ps：此处实际练习时不符合，直接跳过第一索引查第二索引没有使用任何索引，本文关于index全索引扫描解释有待考证==**

![img](MySQL多列索引.assets/1804577-20200521203731486-172947522.png)

![img](MySQL多列索引.assets/1804577-20200521203818877-809915868.png)

 　这两个结果跟上面的是同样的道理，由于它们都没有从最左边开始匹配，所以没有用到联合索引，使用的都是index全索引扫描。

练习：查(name_remark_class)索引

SELECT * from usr where `class` = '1';

![image-20220121175006598](MySQL多列索引.assets/image-20220121175006598.png)

**3.匹配列前缀**

　　如果id是字符型，那么前缀匹配用的是索引，中坠和后缀用的是全表扫描。

```
select * from staffs where id like 'A%';//前缀都是排好序的，使用的都是联合索引
select * from staffs where id like '%A%';//全表查询
select * from staffs where id like '%A';//全表查询
```

**4.匹配范围值**

==**ps：实际练习时使用范围查询时未使用到任何联合索引，以下解释有待考证**==

![img](MySQL多列索引.assets/1804577-20200521210125009-1177423028.png)

 　在匹配的过程中遇到<>=号，就会停止匹配，但id本身就是有序的，所以通过possible_keys字段和key_len 字段可知，在该搜索过程中使用了联合索引的id索引（因为id为int型，允许null，所以占5个字节），且进行的是rang范围查询。

![img](MySQL多列索引.assets/1804577-20200522115901524-226070462.png)

　　由于不遵循最左匹配原则，且在id<4的范围中，age是无序的，所以使用的是index全索引扫描。

![img](MySQL多列索引.assets/1804577-20200521210146172-1428008775.png)

 　不遵循最左匹配原则，但在数据库中id<2的只有一条（id），所以在id<2的范围中，age是有序的，所以使用的是rang范围查询。

![img](MySQL多列索引.assets/1804577-20200521210203002-1943736888.png)

 　不遵循最左匹配原则，而age又是无序的，所以进行的全索引扫描。

**5.准确匹配第一列并范围匹配其他某一列**

**![img](MySQL多列索引.assets/1804577-20200521210726024-2037980339.png)**

　　由于搜索中有id=1，所以在id范围内age是无序的，所以只使用了联合索引中的id索引。



练习：查范围查询是否使用索引(name_remark_class)  

SELECT * from usr where name > '1' and remark = '1';

![image-20220121174950956](MySQL多列索引.assets/image-20220121174950956.png)



-----

# [数据库索引在什么场景下会失效？](https://mp.weixin.qq.com/s/fImvWWS3vlBW1p7hQErfMg)
