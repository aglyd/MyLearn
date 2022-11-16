# [ON DUPLICATE KEY UPDATE 用法](https://blog.csdn.net/qq_38803590/article/details/124692041)

注意：ON DUPLICATE KEY UPDATE 是Mysql特有的语法，仅Mysql有效。

作用：当执行insert操作时，有已经存在的记录，执行update操作。

用法：

![img](https://img-blog.csdnimg.cn/cee3c56b159049fd9c1904a7a6480001.png)

有一个test表，id为主键。第一次插入数据

```
INSERT INTO test(id,name,age)VALUES(1,'2',3),(11,'22',33)
```

![img](https://img-blog.csdnimg.cn/95f675ce17524ce2bf018dbed7af693c.png)

此时表中数据增加了一条主键’id’为‘1’和‘11’的两条记录，当我们再次执行一条id为1的插入语句时，会发生什么呢？

```
INSERT INTO test(id,name,age)VALUES(1,'张三',13)
```

> 1062 - Duplicate entry '1' for key 'PRIMARY'
> 时间: 0.034s

Mysql告诉我们，我们的主键冲突了，看到这里我们是不是可以改变一下思路，当插入已存在主键的记录时，将插入操作变为修改：

```
-- 在原sql后面增加 ON DUPLICATE KEY UPDATE
INSERT INTO test ( id, NAME, age )
VALUES( 1, '张三', 13 ) 
	ON DUPLICATE KEY UPDATE id = 1,
	NAME = '张三',
	age = 13
```


 执行结果中受影响的行数是2。

> Affected rows: 2
> 时间: 0.18s

 执行上面的语句结果

![img](https://img-blog.csdnimg.cn/e275167bbfe44e90b6eb5397994c0ad8.png)

 此时我们如果再次插入( 1, '张三', 13 ) 的数据时会有什么结果

```
INSERT INTO test ( id, NAME, age )
VALUES( 1, '张三', 13 ) 
	ON DUPLICATE KEY UPDATE id = 1,
	NAME = '张三',
	age = 13
```

> Affected rows: 0
> 时间: 0.013s

可以看到影响的行数为0。插入的时候主键冲突，ON DUPLICATE KEY UPDATE会执行更新操作，更新为id = 1,NAME = '张三',age = 13 ，但是并没有我们想象的执行更新。

**==总结：ON DUPLICATE KEY UPDATE首先会检查插入的数据主键或者唯一索引是否冲突，如果冲突则执行更新操作，如果ON DUPLICATE KEY UPDATE的子句中要更新的值与原来的值都一样，则不更新。如果有一个值与原值不一样，则更新：==**



```
INSERT INTO test ( id, NAME, age )
VALUES( 1, '张三', 13 ) 
	ON DUPLICATE KEY UPDATE id = 1,
	NAME = '张三',
	age = 133
```

> Affected rows: 2
> 时间: 0.014s

 执行完毕，id为1的age值改为133

 ![img](https://img-blog.csdnimg.cn/2e3a0b5ee45d446193118ecd6d987df5.png)

目前id为1的数据age字段值为13，我们执行插入语句时只改变了其中一个值age=133,则影响行数为2。此时注意VALUES( 1, '张三', 13 )  中age值为13，ON DUPLICATE KEY UPDATE子句中age值为133。

如果插入的数据主键有冲突，则修改字段值以ON DUPLICATE KEY UPDATE子句的值为准。

ON DUPLICATE KEY UPDATE子句写的是固定值，怎么动态赋值呢？如果一次插入多条数据，怎么动态获取主键冲突所要更新的值呢？

——**==使用获取当前行的值values()==**，这样不会改变值

```
ON DUPLICATE KEY UPDATE age = VALUES(age)
```


 总结：

1. ON DUPLICATE KEY UPDATE检查主键或唯一索引字段是否冲突。

2. update的字段值与现存的字段值相同，则不更新。

3. 动态更新字段值用VALUES(字段名称)。




# [SQL语句中的ON DUPLICATE KEY UPDATE使用详解](https://blog.csdn.net/qq_43279637/article/details/92797641)

## 一：主键索引，唯一索引和普通索引的关系

### 主键索引

主键索引是唯一索引的特殊类型。 
数据库表通常有一列或列组合，其值用来唯一标识表中的每一行。该列称为表的主键。 
在数据库关系图中为表定义一个主键将自动创建主键索引，主键索引是唯一索引的特殊类型。主键索引要求主键中的每个值是唯一的。当在查询中使用主键索引时，它还允许快速访问数据。主键索引不能为空。每个表只能有一个主键

### 唯一索引

不允许两行具有相同的索引值。但可以都为NULL，笔者亲试。 
如果现有数据中存在重复的键值，则数据库不允许将新创建的唯一索引与表一起保存。当新数据将使表中的键值重复时，数据库也拒绝接受此数据。每个表可以有多个唯一索引

### 普通索引

一般的索引结构，可以在条件删选时加快查询效率，索引字段的值可以重复，可以为空值

## 二：ON DUPLICATE KEY UPDATE使用测试(MYSQL下的Innodb引擎)

上面介绍了索引的知识，是为了介绍这个ON DUPLICATE KEY UPDATE功能做铺垫。

### 1：ON DUPLICATE KEY UPDATE功能介绍：

有时候由于业务需求，可能需要先去根据某一字段值查询数据库中是否有记录，有则更新，没有则插入。你可能是下面这样写的

```sql
if not exists (select node_name from node_status where node_name = target_name)
      insert into node_status(node_name,ip,...) values('target_name','ip',...)
else
      update node_status set ip = 'ip',site = 'site',... where node_name = target_name
```


这样写在大多数情况下可以满足我们的需求，但是会有两个问题。

①性能带来开销，尤其是系统比较大的时候。

②在高并发的情况下会出现错误，可能需要利用事务保证安全。

有没有一种优雅的写法来实现有则更新，没有则插入的写法呢？ON DUPLICATE KEY UPDATE提供了这样的一个方式。

### 2：ON DUPLICATE KEY UPDATE测试样例+总结：

首先我们了解下这个简单的表结构id(主键)、code、name。

![img](https://img-blog.csdnimg.cn/20190618193159774.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

看下表中现有的数据：

![img](https://img-blog.csdnimg.cn/20190618193354683.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

执行以下实验进行分析：

实验一：含有ON DUPLICATE KEY UPDATE的INSERT语句中包含主键：

①插入更新都失败，原因是因为把主键id改成了已经存在的id

![img](https://img-blog.csdnimg.cn/20190618193934385.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

 ②执行更新操作。这里的数据还是四条。不过第四条的id由75变化为85

![img](https://img-blog.csdnimg.cn/20190618194542938.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

③执行更新操作。数据总量是四条

![img](https://img-blog.csdnimg.cn/20190618195253665.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

④insert语句中未包含主键，执行插入操作。数据量变为5条

![img](https://img-blog.csdnimg.cn/20190618195518688.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/20190618195642509.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

### 实验二：含有ON DUPLICATE KEY UPDATE的INSERT语句中包含唯一索引：

表结构中增加code的唯一索引，表中现有的数据：

![img](https://img-blog.csdnimg.cn/20190618200007805.png)

①插入更新都失败，原因是因为把code改成了已经存在的code值

![img](https://img-blog.csdnimg.cn/20190618200220988.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

②执行更新操作。这里的数据总量为5条。不过第五条的code由1000变化为1200

![img](https://img-blog.csdnimg.cn/20190618200345472.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/20190618200449778.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

③执行更新操作。数据总量五条，没有变化

![img](https://img-blog.csdnimg.cn/20190618200657286.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/2019061820073662.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

④insert语句中未包含唯一索引，执行插入操作。数据量变为6条

![img](https://img-blog.csdnimg.cn/20190618200851793.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzMjc5NjM3,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/20190618200914171.png)

总结：

**1：ON DUPLICATE KEY UPDATE需要有在INSERT语句中有存在主键或者唯一索引的列，并且对应的数据已经在表中才会执行更新操作。而且如果要更新的字段是主键或者唯一索引，不能和表中已有的数据重复，否则插入更新都失败。（如果你插入的记录导致一个UNIQUE索引或者primary key(主键)出现重复，那么就会认为该条记录存在，则执行update语句而不是insert语句，反之，则执行insert语句而不是更新语句）**。

2：不管是更新还是增加语句都不允许将主键或者唯一索引的对应字段的数据变成表中已经存在的数据。
