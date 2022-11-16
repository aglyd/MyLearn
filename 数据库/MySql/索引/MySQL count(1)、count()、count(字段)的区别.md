# [MySQL count(1)、count(*)、count(字段)的区别](https://www.jb51.net/article/232645.htm)

关于数据库中行数统计，无论是MySQL还是Oracle，都有一个函数可以使用，那就是COUNT。

但是，就是这个常用的COUNT函数，却暗藏着很多玄机，尤其是在面试的时候，一不小心就会被虐。不信的话请尝试回答下以下问题：

> 1、COUNT有几种用法？
> 2、COUNT(字段名)和COUNT(*)的查询结果有什么不同？
> 3、COUNT(1)和COUNT(*)之间有什么不同？
> 4、COUNT(1)和COUNT(*)之间的效率哪个更高？
> 5、为什么《阿里巴巴Java开发手册》建议使用COUNT(*)
> 6、MySQL的MyISAM引擎对COUNT(*)做了哪些优化？
> 7、MySQL的InnoDB引擎对COUNT(*)做了哪些优化？
> 8、上面提到的MySQL对COUNT(*)做的优化，有一个关键的前提是什么？
> 9、SELECT COUNT(*) 的时候，加不加where条件有差别吗？
> 10、COUNT(*)、COUNT(1)和COUNT(字段名)的执行过程是怎样的？
以上10道题，如果可以全部准确无误的回答的话，那说明你真的很了解COUNT函数了。



## 1.初识COUNT 

1、COUNT(expr) ，返回SELECT语句检索的行中expr的值不为NULL的数量。结果是一个BIGINT值。

2、如果查询结果没有命中任何记录，则返回0

3、但是，值得注意的是，COUNT(*) 的统计结果中，会包含值为NULL的行数。

除了COUNT(id)和COUNT(*)以外，还可以使用COUNT(常量)（如COUNT(1)）来统计行数，那么这三条SQL语句有什么区别呢？到底哪种效率更高呢？为什么《阿里巴巴Java开发手册》中强制要求不让使用 COUNT(列名)或 COUNT(常量)来替代 COUNT(*)呢？



## 2.COUNT(字段)、COUNT(常量)和COUNT(*)之间的区别 

COUNT(常量) 和 COUNT(*) 表示的是直接查询符合条件的数据库表的行数。

而COUNT(列名)表示的是查询符合条件的列的值不为NULL的行数。

COUNT(*)是SQL92定义的标准统计行数的语法，因为是标准语法，所以MySQL数据库进行过很多优化。

> SQL92，是数据库的一个ANSI/ISO标准。它定义了一种语言（SQL）以及数据库的行为（事务、隔离级别等）。



## 3.COUNT(*)的优化 

MySQL主要使用2种执行引擎：

- InnoDB引擎
- MyISAM引擎

MyISAM不支持事务，MyISAM中的锁是表级锁；而InnoDB支持事务，并且支持行级锁。



### MyISAM 

MyISAM做了一个简单的优化，把表的总行数单独记录下来，如果执行count(*)时可以直接返回，前提是不能有where条件。MyISAM是表级锁，不会有并发的行操作，所以查到的结果是准确的。



### InnoDB 

InnoDB不能使用这种缓存操作，因为支持事务，大部分操作都是行级锁，行可能被并行修改，那么缓存记录不准确。

但是，InnoDB还是针对COUNT(*)语句做了些优化的。

通过低成本的索引进行扫表，而不关注表的具体内容。

InnoDB中索引分为聚簇索引（主键索引）和非聚簇索引（非主键索引），聚簇索引的叶子节点中保存的是整行记录，而非聚簇索引的叶子节点中保存的是该行记录的主键的值。

MySQL会优先选择最小的非聚簇索引来扫表。

优化的前提是查询语句中不包含where条件和group by条件。



## 4.COUNT(*)和COUNT(1) 

count(*)包括了所有的列（在搜索引擎优化之前），相当于行数，在统计结果的时候， 统计结果中会包含字段值为null的列。

count(1)包括了忽略所有列，用1代表代码行，在统计结果的时候，统计结果中会包含字段值为null的列。

1并不是表示第一个字段，而是表示一个固定值。

其实就可以想成表中有这么一个字段，这个字段就是固定值1，count(1)，就是计算一共有多少个1。



对于两个的区别，MySQL官方文档这么说：

> InnoDB handles SELECT COUNT(*) and SELECT COUNT(1) operations in the same way. There is no performance difference.

所以，对于count(1)和count(*)，MySQL的优化是完全一样的，根本不存在谁更快！

但依旧建议使用count(*)，因为这是SQL92定义的标准统计行数的语法。



`COUNT()`函数括号中的值到底代表什么含义？
 COUNT函数的意思是将括号中的值分配给每一行，然后计算被分配的次数，因此除了括号为空，其他*，1，2等值都会返回相同的结果；

建议使用`COUNT(*)`, 这种用法更加常见，也更清晰：用户能清楚的了解到这里是要统计表的行数。



## 5.COUNT(字段) 

进行全表扫描，判断指定字段的值是否为NULL，不为NULL则累加。

性能比count(1)和count(*)慢。



`COUNT(DISTINCT 列名)` 会将列名去重，即相同的数据只会统计一次



## 6.总结 

COUNT函数的用法，主要用于统计表行数。主要用法有COUNT(*)、COUNT(字段)和COUNT(1)。

**因为COUNT(*)是SQL92定义的标准统计行数的语法，所以MySQL对他进行了很多优化，MyISAM中会直接把表的总行数单独记录下来供COUNT(*)查询，而InnoDB则会在扫表的时候选择最小的索引来降低成本。当然，这些优化的前提都是没有进行where和group的条件查询。**

**在InnoDB中COUNT(*)和COUNT(1)实现上没有区别，而且效率一样，但是COUNT(字段)需要进行字段的非NULL判断，所以效率会低一些。**

因为COUNT(*)是SQL92定义的标准统计行数的语法，并且效率高，所以请直接使用COUNT(*)查询表的行数！



count执行效率

列名为主键，count(列名)比count(1)快；列名不为主键，count(1)会比count(列名)快；

如果表中多个列并且没有主键，则count(1)的执行效率优于count(*)；

如果有主键，则select count(主键)的执行效率是最优的，次之是count(1)和count(\*)差不多但建议用count(\*)；如果表中只有一个字段，则select  count(*)最优。
