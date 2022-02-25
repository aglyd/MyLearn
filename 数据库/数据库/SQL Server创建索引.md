# 一、[SQL Server创建索引](https://blog.csdn.net/lenotang/article/details/3329501)

什么是索引

拿汉语字典的目录页（索引）打比方：正如汉语字典中的汉字按页存放一样，SQL Server中的数据记录也是按页存放的，每页容量一般为4K 。为了加快查找的速度，汉语字（词）典一般都有按拼音、笔画、偏旁部首等排序的目录（索引），我们可以选择按拼音或笔画查找方式，快速查找到需要的字（词）。

同理，SQL Server允许用户在表中创建索引，指定按某列预先排序，从而大大提高查询速度。

•          SQL Server中的数据也是按页（ 4KB ）存放

•          索引：是SQL Server编排数据的内部方法。它为SQL Server提供一种方法来编排查询数据 。

•          索引页：数据库中存储索引的数据页；索引页类似于汉语字（词）典中按拼音或笔画排序的目录页。

•          索引的作用：通过使用索引，可以大大提高数据库的检索速度，改善数据库性能。

 

索引类型

•          唯一索引：唯一索引不允许两行具有相同的索引值

•          主键索引：为表定义一个主键将自动创建主键索引，主键索引是唯一索引的特殊类型。主键索引要求主键中的每个值是唯一的，并且不能为空

•          聚集索引(Clustered)：表中各行的物理顺序与键值的逻辑（索引）顺序相同，每个表只能有一个

•          非聚集索引(Non-clustered)：非聚集索引指定表的逻辑顺序。数据存储在一个位置，索引存储在另一个位置，索引中包含指向数据存储位置的指针。可以有多个，小于249个

 

索引类型：再次用汉语字典打比方，希望大家能够明白聚集索引和非聚集索引这两个概念。

 

唯一索引：

唯一索引不允许两行具有相同的索引值。

如果现有数据中存在重复的键值，则大多数数据库都不允许将新创建的唯一索引与表一起保存。当新数据将使表中的键值重复时，数据库也拒绝接受此数据。例如，如果在stuInfo表中的学员员身份证号(stuID) 列上创建了唯一索引，则所有学员的身份证号不能重复。

提示：创建了唯一约束，将自动创建唯一索引。尽管唯一索引有助于找到信息，但为了获得最佳性能，建议使用主键约束或唯一约束。

 

主键索引：

在数据库关系图中为表定义一个主键将自动创建主键索引，主键索引是唯一索引的特殊类型。主键索引要求主键中的每个值是唯一的。当在查询中使用主键索引时，它还允许快速访问数据。

 

聚集索引（clustered index）

在聚集索引中，表中各行的物理顺序与键值的逻辑（索引）顺序相同。表只能包含一个聚集索引。例如：汉语字（词）典默认按拼音排序编排字典中的每页页码。拼音字母a，b，c，d……x，y，z就是索引的逻辑顺序，而页码1，2，3……就是物理顺序。默认按拼音排序的字典，其索引顺序和逻辑顺序是一致的。即拼音顺序较后的字（词）对应的页码也较大。如拼音“ha”对应的字(词)页码就比拼音“ba” 对应的字(词)页码靠后。

 

非聚集索引(Non-clustered)

如果不是聚集索引，表中各行的物理顺序与键值的逻辑顺序不匹配。聚集索引比非聚集索引（nonclustered index）有更快的数据访问速度。例如，按笔画排序的索引就是非聚集索引，“1”画的字（词）对应的页码可能比“3”画的字（词）对应的页码大（靠后）。

提示：SQL Server中，一个表只能创建1个聚集索引，多个非聚集索引。设置某列为主键，该列就默认为聚集索引

 

如何创建索引

使用T-SQL语句创建索引的语法：

CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] 

    INDEX   index_name
    
     ON table_name (column_name…)
    
      [WITH FILLFACTOR=x]

q       UNIQUE表示唯一索引，可选

q       CLUSTERED、NONCLUSTERED表示聚集索引还是非聚集索引，可选

q       FILLFACTOR表示填充因子，指定一个0到100之间的值，该值指示索引页填满的空间所占的百分比

 

在stuMarks表的writtenExam列创建索引：

USE stuDB

GO

IF EXISTS (SELECT name FROM sysindexes

          WHERE name = 'IX_writtenExam')

   DROP INDEX stuMarks.IX_writtenExam 

/*--笔试列创建非聚集索引：填充因子为30％--*/

CREATE NONCLUSTERED INDEX IX_writtenExam

     ON stuMarks(writtenExam)
    
          WITH FILLFACTOR= 30

GO

/*-----指定按索引 IX_writtenExam 查询----*/

SELECT * FROM stuMarks  (INDEX=IX_writtenExam)

    WHERE writtenExam BETWEEN 60 AND 90

虽然我们可以指定SQL Server按哪个索引进行数据查询，但一般不需要我们人工指定。SQL Server将会根据我们创建的索引，自动优化查询 。

 

索引的优缺点

•          优点

–         加快访问速度

–         加强行的唯一性

•          缺点

–         带索引的表在数据库中需要更多的存储空间

–         操纵数据的命令需要更长的处理时间，因为它们需要对索引进行更新

 

创建索引的指导原则

•          请按照下列标准选择建立索引的列。

–         该列用于频繁搜索

–         该列用于对数据进行排序

•          请不要使用下面的列创建索引：

–         列中仅包含几个不同的值。

–         表中仅包含几行。为小型表创建索引可能不太划算，因为SQL Server在索引中搜索数据所花的时间比在表中逐行搜索所花的时间更长



----

# 二、[SQL 添加索引](https://www.cnblogs.com/daimaxuejia/p/7865300.html)

```sql
使用CREATE 语句创建索引

CREATE INDEX index_name ON table_name(column_name,column_name) include(score)

普通索引

CREATE UNIQUE INDEX index_name ON table_name (column_name) ;

非空索引

CREATE PRIMARY KEY INDEX index_name ON table_name (column_name) ;

主键索引
 
使用ALTER TABLE语句创建索引

alter table table_name add index index_name (column_list) ;
alter table table_name add unique (column_list) ;
alter table table_name add primary key (column_list) ;


删除索引

drop index index_name on table_name ;
alter table table_name drop index index_name ;
alter table table_name drop primary key ;
```

如果您希望以*降序*索引某个列中的值，您可以在列名称之后添加保留字 *DESC*：

```sql
CREATE INDEX PersonIndex
ON Person (LastName DESC) 
```

假如您希望索引不止一个列，您可以在括号中列出这些列的名称，用逗号隔开：

```sql
CREATE INDEX PersonIndex
ON Person (LastName, FirstName)
```



----

# 三、[SQL---约束---add constraint方法添加约束](https://blog.csdn.net/qq_34564959/article/details/84580221)

SQL—约束—add constraint方法添加约束
1.主键约束：

格式为：
alter table 表格名称 add constraint 约束名称 增加的约束类型 （列名）

例子：
alter table emp add constraint ppp primary key (id);

2.check约束：就是给一列的数据进行了限制
格式：
alter table 表名称 add constraint 约束名称 增加的约束类型 （列名）

例子：
alter table emp add constraint xxx check(age>20);

3.[unique](https://so.csdn.net/so/search?q=unique&spm=1001.2101.3001.7020)约束：这样的约束就是给列的数据追加的不重复的约束类型

格式：
alter table 表名 add constraint 约束名称 约束类型（列名）
例子：
alter table emp add constraint qwe unique(ename);

4.默认约束：意思很简单就是让此列的数据默认为一定的数据

格式：
alter table 表名称 add constraint 约束名称 约束类型 默认值） for 列名

例子:

alter table emp add constraint jfsddefault 10000 for gongzi;

5.外键约束：
格式：
alter table 表名 add constraint 约束名称 约束类型 (列名) references 被引用的表名称 （列名）

例子：
alter table emp add constraint jfkdsj foreign key (did) references dept (id);