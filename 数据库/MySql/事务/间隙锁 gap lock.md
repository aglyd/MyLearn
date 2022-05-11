# 一、[间隙锁 gap lock](https://www.jianshu.com/p/83a2ab3bc8ba)

# 锁们



![img](https:////upload-images.jianshu.io/upload_images/1233356-443ff9197c0c2c4e.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/640/format/webp)







# 什么是间隙锁？



间隙锁（Gap Lock）：锁加在不存在的空闲空间，可以是两个索引记录之间，也可能是第一个索引记录之前或最后一个索引之后的空间。







![img](https:////upload-images.jianshu.io/upload_images/1233356-2d64fd00d22d9034.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/590/format/webp)





当我们用范围条件而不是相等条件索引数据，并请求共享或排他锁时，InnoDB会给符合条件的已有数据记录的索引项枷锁；对于键值在条件范围内但并不存在的记录，叫做“间隙（GAP）”。

InnoDB也会对这个“间隙”枷锁，这种锁机制就是所谓的间隙锁（Next-Key锁）。



# 间隙锁的危害



因为Query执行过程中通过范围查找的话，他会锁定整个范围内所有的索引键值，即使这个键值并不存在。间隙锁有一个比较致命的弱点，就是当锁定一个范围键值之后，即使某些不存在的键值也会被无辜的锁定，也造成在锁定的时候无法插入锁定键值范围内的任何数据。在某些场景下这可能会对性能造成很大的危害。

# 间隙锁与死锁

最近用户反馈说系统老是出现insert时，等待超时了，最后发现是insert间隙锁！间隙锁是innodb中行锁的一种， 但是这种锁锁住的却不止一行数据，他锁住的是多行，是一个数据范围。间隙锁的主要作用是为了防止出现幻读，但是它会把锁定范围扩大，



有时候也会给我们带来麻烦，我们就遇到了。 在数据库参数中， 控制间隙锁的参数是：

innodb_locks_unsafe_for_binlog，

这个参数默认值是OFF， 也就是启用间隙锁， 他是一个bool值， 当值为true时表示disable间隙锁。



那为了防止间隙锁是不是直接将innodb_locaks_unsafe_for_binlog设置为true就可以了呢？ 不一定！



而且这个参数会影响到主从复制及灾难恢复， 这个方法还尚待商量。



间隙锁的出现主要集中在同一个事务中先delete后 insert的情况下， 当我们通过一个参数去删除一条记录的时候， 



如果参数在数据库中存在，那么这个时候产生的是普通行锁，锁住这个记录， 然后删除， 然后释放锁。如果这条记录不存在，



问题就来了， 数据库会扫描索引，发现这个记录不存在， 这个时候的delete语句获取到的就是一个间隙锁，然后数据库会向左扫描扫到第一个比给定参数小的值，向右扫描扫描到第一个比给定参数大的值， 然后以此为界，构建一个区间， 锁住整个区间内的数据， 一个特别容易出现死锁的间隙锁诞生了。



![img](https:////upload-images.jianshu.io/upload_images/1233356-7b3a152a5a7c83da.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/640/format/webp)





-----



# 二、[MySQL的锁机制 - 记录锁、间隙锁、临键锁](https://zhuanlan.zhihu.com/p/48269420)

## **前言**

前面小编已经学习了 [共享/排它锁](https://zhuanlan.zhihu.com/p/48127815) 和 [自增锁](https://zhuanlan.zhihu.com/p/48207652) 这两种锁的使用和注意事项，今天这篇文章，小编就来分享下近来学习的记录锁、间隙锁、临键锁这三种锁。

**注：小编觉得这是极其重要的一篇文章，跟前边的自增锁也有一定的关联**



## **记录锁(Record Locks)**

记录锁是 **封锁记录，记录锁也叫行锁**，例如：

```sql
SELECT * FROM `test` WHERE `id`=1 FOR UPDATE;
```

它会在 id=1 的记录上加上记录锁，以阻止其他事务插入，更新，删除 id=1 这一行。



**记录锁、间隙锁、临键锁都是排它锁**，而记录锁的使用方法跟之前的一篇文章 [共享/排它锁](https://zhuanlan.zhihu.com/p/48127815) 里的排它锁介绍一致，这里就不详细多讲。



## **间隙锁(Gap Locks)（重点）**

**间隙锁是封锁索引记录中的间隔**，或者第一条索引记录之前的范围，又或者最后一条索引记录之后的范围。



**产生间隙锁的条件（RR事务隔离级别下；）：**

1. 使用普通索引锁定；
2. 使用多列唯一索引；
3. 使用唯一索引锁定多行记录。

以上情况，都会产生间隙锁，下面是小编看了官方文档理解的：

> 对于使用唯一索引来搜索并给某一行记录加锁的语句，不会产生间隙锁。（这不包括搜索条件仅包括多列唯一索引的一些列的情况；在这种情况下，会产生间隙锁。）例如，如果id列具有唯一索引，则下面的语句仅对具有id值100的行使用记录锁，并不会产生间隙锁：

```sql
SELECT * FROM child WHERE id = 100 FOR UPDATE;
```

这条语句，就只会产生记录锁，不会产生间隙锁。



**打开间隙锁设置**

首先查看 innodb_locks_unsafe_for_binlog 是否禁用：

```sql
show variables like 'innodb_locks_unsafe_for_binlog';
```

查看结果：

![img](https://pic3.zhimg.com/80/v2-9bb40d42a78c91b10b95a65b2a684c66_720w.jpg)

innodb_locks_unsafe_for_binlog：默认值为OFF，即启用间隙锁。因为此参数是只读模式，如果想要禁用间隙锁，需要修改 my.cnf（windows是my.ini） 重新启动才行。

```sql
# 在 my.cnf 里面的[mysqld]添加
[mysqld]
innodb_locks_unsafe_for_binlog = 1
```



## **唯一索引的间隙锁**

**测试环境：**

环境：MySQL，InnoDB，默认的隔离级别（RR）

数据表：

```sql
CREATE TABLE `test` (
  `id` int(1) NOT NULL AUTO_INCREMENT,
  `name` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

数据：

```sql
INSERT INTO `test` VALUES ('1', '小罗');
INSERT INTO `test` VALUES ('5', '小黄');
INSERT INTO `test` VALUES ('7', '小明');
INSERT INTO `test` VALUES ('11', '小红');
```

在进行测试之前，我们先来看看test表中存在的隐藏间隙：

1. (-infinity, 1]
2. (1, 5]
3. (5, 7]
4. (7, 11]
5. (11, +infinity]



**只使用记录锁，不会产生间隙锁**

我们现在进行以下几个事务的测试：

```sql
/* 开启事务1 */
BEGIN;
/* 查询 id = 5 的数据并加记录锁 */
SELECT * FROM `test` WHERE `id` = 5 FOR UPDATE;
/* 延迟30秒执行，防止锁释放 */
SELECT SLEEP(30);

# 注意：以下的语句不是放在一个事务中执行，而是分开多次执行，每次事务中只有一条添加语句

/* 事务2插入一条 name = '小张' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (4, '小张'); # 正常执行

/* 事务3插入一条 name = '小张' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (8, '小东'); # 正常执行

/* 提交事务1，释放事务1的锁 */
COMMIT;
```

上诉的案例，由于主键是唯一索引，而且是只使用一个索引查询，并且只锁定一条记录，所以以上的例子，只会对 id = 5 的数据加上记录锁，而不会产生间隙锁。



**产生间隙锁**

我们继续在 id 唯一索引列上做以下的测试：

```sql
/* 开启事务1 */
BEGIN;
/* 查询 id 在 7 - 11 范围的数据并加记录锁 */
SELECT * FROM `test` WHERE `id` BETWEEN 5 AND 7 FOR UPDATE;
/* 延迟30秒执行，防止锁释放 */
SELECT SLEEP(30);

# 注意：以下的语句不是放在一个事务中执行，而是分开多次执行，每次事务中只有一条添加语句

/* 事务2插入一条 id = 3，name = '小张1' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (3, '小张1'); # 正常执行

/* 事务3插入一条 id = 4，name = '小白' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (4, '小白'); # 正常执行

/* 事务4插入一条 id = 6，name = '小东' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (6, '小东'); # 阻塞

/* 事务5插入一条 id = 8， name = '大罗' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (8, '大罗'); # 阻塞

/* 事务6插入一条 id = 9， name = '大东' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (9, '大东'); # 阻塞

/* 事务7插入一条 id = 11， name = '李西' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (11, '李西'); # 阻塞

/* 事务8插入一条 id = 12， name = '张三' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (12, '张三'); # 正常执行

/* 提交事务1，释放事务1的锁 */
COMMIT;
```

从上面我们可以看到，(5, 7]、(7, 11] 这两个区间，都不可插入数据，其它区间，都可以正常插入数据。所以我们可以得出结论：**当我们给 (5, 7] 这个区间加锁的时候，会锁住 (5, 7]、(7, 11] 这两个区间。**



我们再来测试如果我们锁住不存在的数据时，会怎样：

```sql
/* 开启事务1 */
BEGIN;
/* 查询 id = 3 这一条不存在的数据并加记录锁 */
SELECT * FROM `test` WHERE `id` = 3 FOR UPDATE;
/* 延迟30秒执行，防止锁释放 */
SELECT SLEEP(30);

# 注意：以下的语句不是放在一个事务中执行，而是分开多次执行，每次事务中只有一条添加语句

/* 事务2插入一条 id = 3，name = '小张1' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (2, '小张1'); # 阻塞

/* 事务3插入一条 id = 4，name = '小白' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (4, '小白'); # 阻塞

/* 事务4插入一条 id = 6，name = '小东' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (6, '小东'); # 正常执行

/* 事务5插入一条 id = 8， name = '大罗' 的数据 */
INSERT INTO `test` (`id`, `name`) VALUES (8, '大罗'); # 正常执行

/* 提交事务1，释放事务1的锁 */
COMMIT;
```

我们可以看出，指定查询某一条记录时，如果这条记录不存在，会产生间隙锁。



**结论**

1. 对于指定查询某一条记录的加锁语句，**如果该记录不存在，会产生记录锁和间隙锁，如果记录存在，则只会产生记录锁**，如：WHERE `id` = 5 FOR UPDATE;
2. 对于查找某一范围内的查询语句，会产生间隙锁，如：WHERE `id` BETWEEN 5 AND 7 FOR UPDATE;



## **普通索引的间隙锁**

**数据准备**

创建 test1 表：

```sql
# 注意：number 不是唯一值

CREATE TABLE `test1` (
  `id` int(1) NOT NULL AUTO_INCREMENT,
  `number` int(1) NOT NULL COMMENT '数字',
  PRIMARY KEY (`id`),
  KEY `number` (`number`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
```

在这张表上，我们有 id number 这两个字段，id 是我们的主键，我们在 number 上，建立了一个普通索引，为了方便我们后面的测试。现在我们要先加一些数据：

```sql
INSERT INTO `test1` VALUES (1, 1);
INSERT INTO `test1` VALUES (5, 3);
INSERT INTO `test1` VALUES (7, 8);
INSERT INTO `test1` VALUES (11, 12);
```

在进行测试之前，我们先来看看test1表中 number 索引存在的隐藏间隙：

1. (-infinity, 1]
2. (1, 3]
3. (3, 8]
4. (8, 12]
5. (12, +infinity]



**案例说明**

我们执行以下的事务（事务1最后提交），分别执行下面的语句：

```sql
/* 开启事务1 */
BEGIN;
/* 查询 number = 5 的数据并加记录锁 */
SELECT * FROM `test1` WHERE `number` = 3 FOR UPDATE;
/* 延迟30秒执行，防止锁释放 */
SELECT SLEEP(30);

# 注意：以下的语句不是放在一个事务中执行，而是分开多次执行，每次事务中只有一条添加语句

/* 事务2插入一条 number = 0 的数据 */
INSERT INTO `test1` (`number`) VALUES (0); # 正常执行

/* 事务3插入一条 number = 1 的数据 */
INSERT INTO `test1` (`number`) VALUES (1); # 被阻塞

/* 事务4插入一条 number = 2 的数据 */
INSERT INTO `test1` (`number`) VALUES (2); # 被阻塞

/* 事务5插入一条 number = 4 的数据 */
INSERT INTO `test1` (`number`) VALUES (4); # 被阻塞

/* 事务6插入一条 number = 8 的数据 */
INSERT INTO `test1` (`number`) VALUES (8); # 正常执行

/* 事务7插入一条 number = 9 的数据 */
INSERT INTO `test1` (`number`) VALUES (9); # 正常执行

/* 事务8插入一条 number = 10 的数据 */
INSERT INTO `test1` (`number`) VALUES (10); # 正常执行

/* 提交事务1 */
COMMIT;
```

我们会发现有些语句可以正常执行，有些语句被阻塞了。我们再来看看我们表中的数据：

![img](https://pic4.zhimg.com/80/v2-bd416a32e5f1740be516a61665ba285b_720w.jpg)执行之后的数据

这里可以看到，number (1 - 8) 的间隙中，插入语句都被阻塞了，而不在这个范围内的语句，正常执行，这就是因为有间隙锁的原因。我们再进行以下的测试，方便我们更好的理解间隙锁的区域（我们要将数据还原成原来的那样）：

```sql
/* 开启事务1 */
BEGIN;
/* 查询 number = 5 的数据并加记录锁 */
SELECT * FROM `test1` WHERE `number` = 3 FOR UPDATE;
/* 延迟30秒执行，防止锁释放 */
SELECT SLEEP(30);

/* 事务1插入一条 id = 2， number = 1 的数据 */
INSERT INTO `test1` (`id`, `number`) VALUES (2, 1); # 阻塞

/* 事务2插入一条 id = 3， number = 2 的数据 */
INSERT INTO `test1` (`id`, `number`) VALUES (3, 2); # 阻塞

/* 事务3插入一条 id = 6， number = 8 的数据 */
INSERT INTO `test1` (`id`, `number`) VALUES (6, 8); # 阻塞

/* 事务4插入一条 id = 8， number = 8 的数据 */
INSERT INTO `test1` (`id`, `number`) VALUES (8, 8); # 正常执行

/* 事务5插入一条 id = 9， number = 9 的数据 */
INSERT INTO `test1` (`id`, `number`) VALUES (9, 9); # 正常执行

/* 事务6插入一条 id = 10， number = 12 的数据 */
INSERT INTO `test1` (`id`, `number`) VALUES (10, 12); # 正常执行

/* 事务7修改 id = 11， number = 12 的数据 */
UPDATE `test1` SET `number` = 5 WHERE `id` = 11 AND `number` = 12; # 阻塞

/* 提交事务1 */
COMMIT;
```

我们来看看结果：

![img](https://pic1.zhimg.com/80/v2-60d83dfa236fb4a25ab4c3a5df45b0d0_720w.jpg)执行后的数据

这里有一个奇怪的现象：

- 事务3添加 id = 6，number = 8 的数据，给阻塞了；
- 事务4添加 id = 8，number = 8 的数据，正常执行了。
- 事务7将 id = 11，number = 12 的数据修改为 id = 11， number = 5的操作，给阻塞了；

这是为什么呢？我们来看看下边的图，大家就明白了。

![img](https://pic2.zhimg.com/80/v2-e5fe73d5f7fda8c298ce60fd35915885_720w.jpg)隐藏的间隙锁图

从图中可以看出，当 number 相同时，会根据主键 id 来排序，所以：

1. 事务3添加的 id = 6，number = 8，这条数据是在 （3, 8） 的区间里边，所以会被阻塞；
2. 事务4添加的 id = 8，number = 8，这条数据则是在（8, 12）区间里边，所以不会被阻塞；
3. 事务7的修改语句相当于在 （3, 8） 的区间里边插入一条数据，所以也被阻塞了。



**结论**

1. **在普通索引列上，不管是何种查询，只要加锁，都会产生间隙锁，这跟唯一索引不一样；**
2. 在普通索引跟唯一索引中，数据间隙的分析，数据行是优先根据普通索引排序，再根据唯一索引排序。



## **临键锁(Next-key Locks)**

**临键锁**，是**记录锁与间隙锁的组合**，它的封锁范围，既包含索引记录，又包含索引区间。



**注：**临键锁的主要目的，也是为了避免**幻读**(Phantom Read)。如果把事务的隔离级别降级为RC，临键锁则也会失效。



## **本文要点**

1. 记录锁、间隙锁、临键锁，都属于排它锁；
2. 记录锁就是锁住一行记录；
3. 间隙锁只有在事务隔离级别 RR 中才会产生；
4. 唯一索引只有锁住多条记录或者一条不存在的记录的时候，才会产生间隙锁，指定给某条存在的记录加锁的时候，只会加记录锁，不会产生间隙锁；
5. 普通索引不管是锁住单条，还是多条记录，都会产生间隙锁；
6. 间隙锁会封锁该条记录相邻两个键之间的空白区域，防止其它事务在这个区域内插入、修改、删除数据，这是为了防止出现 幻读 现象；
7. 普通索引的间隙，优先以普通索引排序，然后再根据主键索引排序（多普通索引情况还未研究）；
8. 事务级别是RC（读已提交）级别的话，间隙锁将会失效。



----



# 三、[MYSQL（04）-间隙锁详解](https://www.jianshu.com/p/32904ee07e56)

间隙锁（Gap Lock）是Innodb在![\color{red}{可重复读}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7B%E5%8F%AF%E9%87%8D%E5%A4%8D%E8%AF%BB%7D)提交下为了解决幻读问题时引入的锁机制，（下面的所有案例没有特意强调都使用可重复读隔离级别）幻读的问题存在是因为新增或者更新操作，这时如果进行范围查询的时候（加锁查询），会出现不一致的问题，这时使用不同的行锁已经没有办法满足要求，需要对一定范围内的数据进行加锁，间隙锁就是解决这类问题的。在可重复读隔离级别下，数据库是通过行锁和间隙锁共同组成的（next-key lock），来实现的

加锁规则有以下特性，我们会在后面的案例中逐一解释：

- 1.加锁的基本单位是（next-key lock）,他是前开后闭原则
- 2.插叙过程中访问的对象会增加锁
- 3.索引上的等值查询--给唯一索引加锁的时候，next-key lock升级为行锁
- 4.索引上的等值查询--向右遍历时最后一个值不满足查询需求时，next-key lock 退化为间隙锁
- 5.唯一索引上的范围查询会访问到不满足条件的第一个值为止

案例数据

| id(主键) | c（普通索引） | d（无索引） |
| -------- | ------------- | ----------- |
| 5        | 5             | 5           |
| 10       | 10            | 10          |
| 15       | 15            | 15          |
| 20       | 20            | 20          |
| 25       | 25            | 25          |

以上数据为了解决幻读问题，更新的时候不只是对上述的五条数据增加行锁，还对于中间的取值范围增加了6间隙锁，（-∞，5]（5，10]（10，15]（15，20]（20，25]（25，+supernum] （其中supernum是数据库维护的最大的值。为了保证间隙锁都是左开右闭原则。）

### 案例一：间隙锁简单案例

| 步骤 | 事务A                                             | 事务B                                                        |
| ---- | ------------------------------------------------- | ------------------------------------------------------------ |
| 1    | begin; select * from t where id = 11  for update; | -                                                            |
| 2    | -                                                 | insert into user value(12,12,12) ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) |
| 3    | commit;                                           | -                                                            |

当有如下事务A和事务B时，事务A会对数据库表增加（10，15]这个区间锁，这时insert id = 12 的数据的时候就会因为区间锁（10，15]而被锁住无法执行。

### 案例二： 间隙锁死锁问题

| 步骤 | 事务A                                                        | 事务B                                                        |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | begin; select * from t where id = 9  for update;             | -                                                            |
| 2    | -                                                            | begin; select * from t where id = 6  for update;             |
| 3    | -                                                            | insert into user value(7,7,7) ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) |
| 4    | insert into user value(7,7,7) ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) | -                                                            |

不同于写锁相互之间是互斥的原则，间隙锁之间不是互斥的，如果一个事务A获取到了（5,10]之间的间隙锁，另一个事务B也可以获取到（5,10]之间的间隙锁。这时就可能会发生死锁问题，如下案例。
 事务A获取到（5,10]之间的间隙锁不允许其他的DDL操作，在事务提交，间隙锁释放之前，事务B也获取到了间隙锁（5,10]，这时两个事务就处于死锁状态

### 案例三： 等值查询—唯一索引

| 步骤 | 事务A                                     | 事务B                                                        | 事务C                             |
| ---- | ----------------------------------------- | ------------------------------------------------------------ | --------------------------------- |
| 1    | begin; update u set d= d+ 1 where id = 7; | -                                                            | -                                 |
| 2    | -                                         | insert into u (8,8,8); ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) | -                                 |
| 4    | -                                         | -                                                            | update set d = d+ 1 where id = 10 |

1.加锁的范围是（5,10]的范围锁
 2.由于数据是等值查询，并且表中最后数据id = 10 不满足id= 7的查询要求，故id=10 的行级锁退化为间隙锁，（5,10）
 3.所以事务B中id=8会被锁住，而id=10的时候不会被锁住

### 案例四： 等值查询—普通索引

| 步骤 | 事务A                                                   | 事务B                               | 事务C                                                        |
| ---- | ------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------ |
| 1    | begin; select id form t where c = 5 lock in share mode; | -                                   | -                                                            |
| 2    | -                                                       | update t set d = d + 1 where id = 5 | -                                                            |
| 4    | -                                                       | -                                   | insert into values (7,7,7)![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) |

1.加锁的范围是（0,5]，（5,10]的范围锁
 2.由于c是普通索引，根据原则4，搜索到5后继续向后遍历直到搜索到10才放弃，故加锁范围为（5,10]
 3.由于查询是等值查询，并且最后一个值不满足查询要求，故间隙锁退化为（5,10）
 4.因为加锁是对普通索引c加锁，而且因为索引覆盖，没有对主键进行加锁，所以事务B执行正常
 5.因为加锁范围（5,10）故事务C执行阻塞
 6.需要注意的是，lock in share mode 因为覆盖索引故没有锁主键索引，如果使用for update 程序会觉得之后会执行更新操作故会将主键索引一同锁住

### 案例五： 范围查询—唯一索引

| 步骤 | 事务A                                                        | 事务B                                                        | 事务C                                                        |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | begin; select *  form t where id >= 10 and id <11  for update | -                                                            | -                                                            |
| 2    | -                                                            | insert into values(8,8,8)   insert into values(13,13,13) ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) | -                                                            |
| 4    | -                                                            | -                                                            | update t set d = d+ 1 where id = 15 ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) |

1. next-key lock 增加范围锁（5,10]
2. 根据原则5，唯一索引的范围查询会到第一个不符合的值位置，故增加（10，15]
    3.因为等值查询有id =10 根据原则3间隙锁升级为行锁，故剩余锁[10,15]
    4.因为查询并不是等值查询，故[10,15]不会退化成[10,15)
    5.故事务B（13,13,13）阻塞，事务C阻塞

### 案例六： 范围查询—普通索引

| 步骤 | 事务A                                                      | 事务B                                                        | 事务C                                                        |
| ---- | ---------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | begin; select *  form t where c >= 10 and c <11 for update | -                                                            | -                                                            |
| 2    | -                                                          | insert into values(8,8,8)   ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) | -                                                            |
| 4    | -                                                          | -                                                            | update t set d = d+ 1 where c = 15 ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) |

1. next-key lock 增加范围锁（5,10]，（10，15]
    2.因为c是非唯一索引，故（5,10]不会退化为10
    3.因为查询并不是等值查询，故[10,15]不会退化成[10,15)
    4.所以事务B和事务C全部堵塞

### 案例八： 普通索引-等值问题

上面的数据增加一行（30,10,30），这样在数据库中存在的c=10的就有两条记录

- ![img](https:////upload-images.jianshu.io/upload_images/14523959-09a3333e3017e0c7.png?imageMogr2/auto-orient/strip|imageView2/2/w/1056/format/webp)

| 步骤 | 事务A                             | 事务B                                                        | 事务C                                                        |
| ---- | --------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | begin; delete from t where c = 10 | -                                                            | -                                                            |
| 2    | -                                 | insert into values(12,12,12)   ![\color{red}{blocked}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bblocked%7D) | -                                                            |
| 4    | -                                 | -                                                            | update t set d = d+ 1 where c = 15 ![\color{red}{ok}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bok%7D) |

1. next-key lock 增加范围锁（5,10]，（10，15]
    2.因为是等值查询故退化为（5,10]，（10，15），故事务B阻塞，事务C执行成功
    加锁的范围如下图

- ![img](https:////upload-images.jianshu.io/upload_images/14523959-1f11482754c99ad4.png?imageMogr2/auto-orient/strip|imageView2/2/w/1069/format/webp)

### 案例九： 普通索引-等值Limit问题

| 步骤 | 事务A                                      | 事务B                                                        | 事务C                                                        |
| ---- | ------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | begin; delete from t where c = 10  limit 2 | -                                                            | -                                                            |
| 2    | -                                          | insert into values(12,12,12)   ![\color{red}{OK}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7BOK%7D) | -                                                            |
| 4    | -                                          | -                                                            | update t set d = d+ 1 where c = 15 ![\color{red}{ok}](https://math.jianshu.com/math?formula=%5Ccolor%7Bred%7D%7Bok%7D) |

1.根据上面案例8改造，将delete增加limit操作2的操作
 2.因为知道了数据加锁值加2条，故在加锁（5，10]之后发现已经有两条数据，故后面不在向后匹配加锁。所以事务B执行成功，加锁范围如下

- ![img](https:////upload-images.jianshu.io/upload_images/14523959-6445494dd3af0d44.png?imageMogr2/auto-orient/strip|imageView2/2/w/1007/format/webp)



-----



# 四、[MVCC我知道，但是为什么要设计间隙锁？](https://www.jianshu.com/p/fbec6d1fa16c)

> 从设计的角度上，为什么要设计出MVCC，且RC和RR的隔离级别到底有什么不同。

# MVCC作用

> MVCC使得大部分支持行锁的事务引擎，不再单纯的使用行锁来进行数据库的并发控制，**而是把数据库的行锁和行的版本号结合起来，只需要很小的开销，就可以实现非锁定读。**从而提高数据库的并发性能。

**MVCC是采用无锁的形式解决读-写冲突问题。这里的读是指的快照读。**即MVCC实现的快照读！！！

## 什么是MVCC

**多版本并发控制（MVCC）是一种解决读-写冲突的无锁并发控制。**

**每一行记录都有两个隐藏列：创建版本号和回滚指针。事务开启后存在一个事务id。多个并发事务同时操作某行，不同的事务对该行update操作会产生多个版本，然后通过回滚指针组成undo log链。而MVCC的快照读正是通过事务id和创建版本号从而实现的快照读。**

## MVCC与隔离级别的关系

> MVCC是为了解决读-写问题。且通过不同的配置，也可以解决事务开启后，**快照读不可重复读的问题。**

- 不可重复读：同一个事务中读取某些数据已经发生改变，或某些记录已经删除。
- 幻读：一个事务按照相同的查询条件重新读取以前检索过的数据，却发现其他事务插入了满足查询条件的新数据，这种现象被称为幻读。

**RC和RR均实现了MVCC，但是为什么RR解决了RC不可重复读的问题？**

你可以这样认为，RC之所以有不可重复读的问题，只是因为开发者有意设置的（设置多种隔离级别，用户可以根据情况设置）。本来数据都提交到数据库了，RC读取出来也没什么问题呀？况且Oracle数据库本身的隔离级别就是RC。

> READ-COMMITTED（读已提交）
>  读已提交RC，在这一隔离级别下，可以在SQL级别做到一致性读，每次SQL语句都会产生新的ReadView。这就意味着两次查询之间有别的事务提交了，是可以读到不一致的数据的。

> REPEATABLE-READ（可重复读）
>  可重复读RR，在第一次创建ReadView后，这个ReadView就会一直维持到事务结束，也就是说，在事务执行期间可见性不会发生变化，从而实现了事务内的可重复读。

## MVCC和间隙锁

**MVCC无锁解决了读-写冲突的问题。**并且解决了不可重复读问题。从而实现了RC和RR两个隔离级别。

而**间隙锁**本质上依旧是锁，会阻塞两个并发事务的执行。

**那么RR为什么还要进入间隙锁，难道仅仅为了解决幻读的问题吗？**

```
注意：只有RR隔离级别才存在间隙锁。
```

间隙锁在一定程度上可以解决幻读的问题，但是间隙锁的引入我觉得更多是为了处理binlog的statement模式的bug。

> mysql数据库的主从复制依靠的是binlog。而在mysql5.0之前，binlog模式只有statement格式。这种模式的特点：binlog的记录顺序是按照数据库事务commit顺序为顺序的。

**当不存在间隙锁的情况下，会有如下的场景：**
 master库有这么两个事务：

1、事务a先delete id<6，然后在commit前；
 2、事务b直接insert id=3，并且完成commit；
 3、事务a进行commit；
 此时binlog记录的日志是：事务b先执行，事务a在执行（binlog记录的是commit顺序）

那么主库此时表里面有id=3的记录，但是从库是先插入再删除，从库里面是没有记录的。

这就导致了主从数据不一致。

为了解决这个bug，所以RR级别引入了间隙锁。

## 推荐阅读

[聊一聊MVCC是怎么回事](https://links.jianshu.com/go?to=https%3A%2F%2Fzhuanlan.zhihu.com%2Fp%2F347587789)



----

# 五、[什么是间隙锁](https://www.cnblogs.com/phyger/p/14377651.html)

## 1、中心思想

间隙锁锁的是索引叶子节点的next指针。

## 2、意义

解决了mysql RR级别下是幻读的问题。

### 2.1、快照读

在RR隔离级别下：快照读有可能读到数据的历史版本，也有可能读到数据的当前版本。所以快照读无需用锁也不会发生幻读的情况。

### 2.2、当前读

当前读：select…lock in share mode,select…for update
当前读：update,delete,insert

读取的是记录的最新版本，所以所以就需要通过加锁（行锁 间隙锁 表锁）的方式，使得被当前读读过的数据不能被新增修改或者删除，换句话说再来一次当前读要返回相同的数据。

## 3、为什么需要间隙锁

### 3.1、数据表



```
CREATE TABLE `z` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `b` int(11) DEFAULT NULL,
  `c` int(255) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `b` (`b`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;


INSERT INTO `study`.`z` (`id`, `b`, `c`) VALUES ('1', '1', '0');
INSERT INTO `study`.`z` (`id`, `b`, `c`) VALUES ('3', '6', '1');
INSERT INTO `study`.`z` (`id`, `b`, `c`) VALUES ('5', '4', '2');
INSERT INTO `study`.`z` (`id`, `b`, `c`) VALUES ('7', '8', '3');
INSERT INTO `study`.`z` (`id`, `b`, `c`) VALUES ('8', '10', '4');
```

### 3.2、索引B结构

![img](间隙锁 gap lock.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzIxNzI5NDE5,size_16,color_FFFFFF,t_70-164888005161610.png)



### 3.3、锁加在哪里

begin; select * from z where b = 6 for update;

这条sql语句之后看看我们 需要做什么才能保证不发生幻读。

1不能插入b为6的数据

2不能删除b为6的数据

3不能修改b为6的数据

4不能把别的数据修改为b为6

突然一看挺复杂的，这个锁要怎么加呢，mysql大牛灵机一动，给叶子节点5的next指针加锁，给叶子节点3加行锁，给叶子节点3的next指针加锁。如下图所示

![img](间隙锁 gap lock.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzIxNzI5NDE5,size_16,color_FFFFFF,t_70-164888009290812.png)

这样不就能把上述四个问题解决了么，两个next指针锁解决了插入b为6或者把别的数据修改为b为6，行锁解决了修改b为6的行，但是呢也带来一些明显的副作用。

例如

INSERT INTO `study`.`z` (`id`, `b`, `c`) VALUES ('6', '4', '0'); 

 会bolck因为按照索引结构这条数据会插入到叶子结点5和3之间，会修改叶子节点5的next指针，虽然这条sql没有破坏上述的4个红色条件但是依然被阻塞了所以我叫它为副作用。

INSERT INTO `study`.`z` (`id`, `b`, `c`) VALUES ('4', '4', '0'); 

 插入成功因为这条数据会插入在1的后面5的前面。

现在大家是不是能理解间隙锁的怪异行为了呢。

## 4、间隙锁范围

begin; 
select * from z where id=4 for update;

会锁住主键索引叶子节点的3的next指针。（为啥呢，需要你自己画主键索引的图）

begin; 
select * from z where id=3 for update;

间隙锁会退化为行锁只锁叶子节点3 ,为什么因为没必要。不加间隙锁也不会打破上述的红色4个条件。

begin; 
select * from z where id>4 for update;

叶子节点3及之后所有节点会加行锁并且他们的next指针会加锁，

begin; 
select * from z where c=2 for update;

会发生锁表，因为c没有索引结构能存储行锁或者间隙锁。

 
