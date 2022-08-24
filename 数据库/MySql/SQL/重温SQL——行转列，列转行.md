# 一、[重温SQL——行转列，列转行](https://www.cnblogs.com/kerrycode/archive/2010/07/28/1786547.html)

行转列，列转行是我们在开发过程中经常碰到的问题。==行转列一般通过CASE WHEN 语句来实现，也可以通过 SQL SERVER 2005 新增的运算符PIVOT来实现。==用传统的方法，比较好理解。层次清晰，而且比较习惯。 ==但是PIVOT 、UNPIVOT提供的语法比一系列复杂的SELECT...CASE 语句中所指定的语法更简单、更具可读性。==下面我们通过几个简单的例子来介绍一下列转行、行转列问题。

## 行转列 

### 使用case when

我们首先先通过一个老生常谈的例子，学生成绩表(下面简化了些)来形象了解下行转列 

```sql
CREATE  TABLE [StudentScores]
(
   [UserName]         NVARCHAR(20),        --学生姓名
    [Subject]          NVARCHAR(30),        --科目
    [Score]            FLOAT,               --成绩
)
 
INSERT INTO [StudentScores] SELECT 'Nick', '语文', 80
 
INSERT INTO [StudentScores] SELECT 'Nick', '数学', 90
 
INSERT INTO [StudentScores] SELECT 'Nick', '英语', 70
 
INSERT INTO [StudentScores] SELECT 'Nick', '生物', 85
 
INSERT INTO [StudentScores] SELECT 'Kent', '语文', 80
 
INSERT INTO [StudentScores] SELECT 'Kent', '数学', 90
 
INSERT INTO [StudentScores] SELECT 'Kent', '英语', 70
 
INSERT INTO [StudentScores] SELECT 'Kent', '生物', 85
```

如果我想知道每位学生的每科成绩，而且每个学生的全部成绩排成一行，这样方便我查看、统计，导出数据

```sql
SELECT 
      UserName, 
      MAX(CASE Subject WHEN '语文' THEN Score ELSE 0 END) AS '语文',
      MAX(CASE Subject WHEN '数学' THEN Score ELSE 0 END) AS '数学',
      MAX(CASE Subject WHEN '英语' THEN Score ELSE 0 END) AS '英语',
      MAX(CASE Subject WHEN '生物' THEN Score ELSE 0 END) AS '生物'
FROM dbo.[StudentScores]
GROUP BY UserName
 
查询结果如图所示，这样我们就能很清楚的了解每位学生所有的成绩了
```

 

![img](https://images.cnblogs.com/cnblogs_com/kerrycode/2010072801.gif) 

接下来我们来看看第二个小列子。有一个游戏玩家充值表（仅仅为了说明，举的一个小例子），

```sql
CREATE TABLE [Inpours]
(
   [ID]                INT IDENTITY(1,1), 
   [UserName]          NVARCHAR(20),  --游戏玩家
    [CreateTime]        DATETIME,      --充值时间    
    [PayType]           NVARCHAR(20),  --充值类型    
    [Money]             DECIMAL,       --充值金额
    [IsSuccess]         BIT,           --是否成功 1表示成功， 0表示失败
    CONSTRAINT [PK_Inpours_ID] PRIMARY KEY(ID)
)
 
INSERT INTO Inpours SELECT '张三', '2010-05-01', '支付宝', 50, 1
 
INSERT INTO Inpours SELECT '张三', '2010-06-14', '支付宝', 50, 1
 
INSERT INTO Inpours SELECT '张三', '2010-06-14', '手机短信', 100, 1
 
INSERT INTO Inpours SELECT '李四', '2010-06-14', '手机短信', 100, 1
 
INSERT INTO Inpours SELECT '李四', '2010-07-14', '支付宝', 100, 1
 
INSERT INTO Inpours SELECT '王五', '2010-07-14', '工商银行卡', 100, 1
 
INSERT INTO Inpours SELECT '赵六', '2010-07-14', '建设银行卡', 100, 1
```

 

下面来了一个统计数据的需求，要求按日期、支付方式来统计充值金额信息。这也是一个典型的行转列的例子。我们可以通过下面的脚本来达到目的

```sql
代码

SELECT CONVERT(VARCHAR(10), CreateTime, 120) AS CreateTime,        CASE PayType WHEN '支付宝'     THEN SUM(Money) ELSE 0 END AS '支付宝',
                 CASE PayType WHEN '手机短信'    THEN SUM(Money) ELSE 0 END AS '手机短信',
                 CASE PayType WHEN '工商银行卡'  THEN SUM(Money) ELSE 0 END AS '工商银行卡',
                 CASE PayType WHEN '建设银行卡'  THEN SUM(Money) ELSE 0 END AS '建设银行卡'
          FROM Inpours
          GROUP BY CreateTime, PayType
```

如图所示，我们这样只是得到了这样的输出结果，还需进一步处理，才能得到想要的结果

![img](https://images.cnblogs.com/cnblogs_com/kerrycode/2010072802.gif)

```sql
SELECT 
       CreateTime, 
       ISNULL(SUM([支付宝])    , 0)  AS [支付宝]    , 
       ISNULL(SUM([手机短信])  , 0)  AS [手机短信]   , 
       ISNULL(SUM([工商银行卡]), 0)  AS [工商银行卡] ,  
       ISNULL(SUM([建设银行卡]), 0)  AS [建设银行卡]
FROM
(
    SELECT CONVERT(VARCHAR(10), CreateTime, 120) AS CreateTime,
           CASE PayType WHEN '支付宝'     THEN SUM(Money) ELSE 0 END AS '支付宝' ,
           CASE PayType WHEN '手机短信'   THEN SUM(Money) ELSE 0 END AS '手机短信',
           CASE PayType WHEN '工商银行卡' THEN SUM(Money) ELSE 0 END AS '工商银行卡',
           CASE PayType WHEN '建设银行卡' THEN SUM(Money) ELSE 0 END AS '建设银行卡'
    FROM Inpours
    GROUP BY CreateTime, PayType
) T
GROUP BY CreateTime
```

其实行转列，关键是要理清逻辑，而且对分组（Group by）概念比较清晰。上面两个列子基本上就是行转列的类型了。但是有个问题来了，上面是我为了说明弄的一个简单列子。实际中，可能支付方式特别多，而且逻辑也复杂很多，可能涉及汇率、手续费等等(曾经做个这样一个)，如果支付方式特别多，我们的CASE WHEN 会弄出一大堆，确实比较恼火，而且新增一种支付方式，我们还得修改脚本如果把上面的脚本用动态SQL改写一下，我们就能轻松解决这个问题

```sql

DECLARE @cmdText    VARCHAR(8000); DECLARE @tmpSql        VARCHAR(8000);
          

          SET @cmdText = 'SELECT CONVERT(VARCHAR(10), CreateTime, 120) AS CreateTime,' + CHAR(10);
          SELECT @cmdText = @cmdText + ' CASE PayType WHEN ''' + PayType + ''' THEN SUM(Money) ELSE 0 END AS ''' + PayType                  + ''',' + CHAR(10)  FROM (SELECT DISTINCT PayType FROM Inpours ) T
          

          SET @cmdText = LEFT(@cmdText, LEN(@cmdText) -2) --注意这里，如果没有加CHAR(10) 则用LEFT(@cmdText, LEN(@cmdText) -1)
          
          SET @cmdText = @cmdText + ' FROM Inpours     GROUP BY CreateTime, PayType ';
          

          SET @tmpSql ='SELECT CreateTime,' + CHAR(10);
          SELECT @tmpSql = @tmpSql + ' ISNULL(SUM(' + PayType  + '), 0) AS ''' + PayType  + ''','  + CHAR(10)
                              FROM  (SELECT DISTINCT PayType FROM Inpours ) T
          

          SET @tmpSql = LEFT(@tmpSql, LEN(@tmpSql) -2) + ' FROM (' + CHAR(10);
          

          SET @cmdText = @tmpSql + @cmdText + ') T GROUP BY CreateTime ';
          PRINT @cmdText
          EXECUTE (@cmdText);
```

###  使用PIVOT

下面是通过PIVOT来进行行转列的用法，大家可以对比一下，确实要简单、更具可读性（呵呵，习惯的前提下）

会展示[支付宝], [手机短信], [工商银行卡], [建设银行卡] 下的sum(Money)为一行

```sql
SELECT          CreateTime, [支付宝] , [手机短信],
                  [工商银行卡] , [建设银行卡]
          FROM
          (

              SELECT CONVERT(VARCHAR(10), CreateTime, 120) AS CreateTime,PayType, Money
              FROM Inpours
          ) P

          PIVOT (

                      SUM(Money)
                      FOR PayType IN
                      ([支付宝], [手机短信], [工商银行卡], [建设银行卡])
                ) AS T
          ORDER BY CreateTime
```



有时可能会出现这样的错误：

消息 325，级别 15，状态 1，第 9 行

'PIVOT' 附近有语法错误。您可能需要将当前数据库的兼容级别设置为更高的值，以启用此功能。有关存储过程 sp_dbcmptlevel 的信息，请参见帮助。

这个是因为：==对升级到 SQL Server 2005 或更高版本的数据库使用 PIVOT 和 UNPIVOT 时，必须将数据库的兼容级别设置为 90 或更高。有关如何设置数据库兼容级别的信息，请参阅 sp_dbcmptlevel (Transact-SQL)==。 例如，只需在执行上面脚本前加上 EXEC sp_dbcmptlevel Test, 90; 就OK了， Test 是所在数据库的名称。

 

## 列转行

下面我们来看看列转行，主要是通过UNION ALL ,MAX来实现。假如有下面这么一个表

```sql
CREATE TABLE ProgrectDetail
          (

              ProgrectName         NVARCHAR(20), --工程名称
              OverseaSupply        INT,          --海外供应商供给数量
              NativeSupply         INT,          --国内供应商供给数量
              SouthSupply          INT,          --南方供应商供给数量
              NorthSupply          INT           --北方供应商供给数量
          )
          

          INSERT INTO ProgrectDetail
          SELECT 'A', 100, 200, 50, 50
          UNION ALL
          SELECT 'B', 200, 300, 150, 150
          UNION ALL
          SELECT 'C', 159, 400, 20, 320
          UNION ALL
          SELECT 'D', 250, 30, 15, 15
```

 

我们可以通过下面的脚本来实现，查询结果如下图所示

```sql
SELECT ProgrectName, 'OverseaSupply' AS Supplier,
                  MAX(OverseaSupply) AS 'SupplyNum'
          FROM ProgrectDetail
          GROUP BY ProgrectName
          UNION ALL
          SELECT ProgrectName, 'NativeSupply' AS Supplier,
                  MAX(NativeSupply) AS 'SupplyNum'
          FROM ProgrectDetail
          GROUP BY ProgrectName
          UNION ALL
          SELECT ProgrectName, 'SouthSupply' AS Supplier,
                  MAX(SouthSupply) AS 'SupplyNum'
          FROM ProgrectDetail
          GROUP BY ProgrectName
          UNION ALL
          SELECT ProgrectName, 'NorthSupply' AS Supplier,
                  MAX(NorthSupply) AS 'SupplyNum'
          FROM ProgrectDetail
          GROUP BY ProgrectName
```

 

 ![img](https://images.cnblogs.com/cnblogs_com/kerrycode/2010072803.gif)

用UNPIVOT 实现如下：

```sql
SELECT ProgrectName,Supplier,SupplyNum
          FROM  (

              SELECT ProgrectName, OverseaSupply, NativeSupply,
                     SouthSupply, NorthSupply

               FROM ProgrectDetail
          )T

          UNPIVOT  (

              SupplyNum FOR Supplier IN
              (OverseaSupply, NativeSupply, SouthSupply, NorthSupply )

          ) P
```



---

# 二、[Pivot 和 Unpivot](https://www.cnblogs.com/ljhdo/p/4995554.html)

==注意：Mysql没有pivot和unpivot函数，SQL Server和Oracle有，以下为SQL server用法==

在TSQL（T-SQL 即 Transact-SQL，是 SQL 在 Microsoft SQL Server 上的增强版，它是用来让应用程序与 SQL Server 沟通的主要语言）中，使用Pivot和Unpivot运算符将一个关系表转换成另外一个关系表，两个命令实现的操作是“相反”的，但是，pivot之后，不能通过unpivot将数据还原。这两个运算符的操作数比较复杂，记录一下自己的总结，以后用到时，作为参考。

## 1，Pivot用法

Pivot旋转的作用，是将关系表（table_source）中的列（pivot_column）的值，转换成另一个关系表（pivot_table）的列名：

```sql
table_source
pivot
(
  aggregation_function（aggregated_column）
  for pivot_column in ([pivot_column_value_list])
) as pivot_table_alias
```

**透视操作的处理流程是：**

1. ==对pivot_column和 aggregated_column的其余column进行分组，即，group by other_columns；==

2. ==当pivot_column值等于某一个指定值，计算aggregated_column的聚合值；==

   

   ==注意：这里的other_columns其余字段是指from table_source查出的所有字段中除pivot_column和 aggregated_column字段以外的所有字段。例如：如果直接from tablename，而不是指定from（select子查询），则会以tablename表中除pivot中以外的所有字段分组==

在使用透视命令时，需要注意：

- ==pivot将table_source旋转成透视表（pivot_table）之后，不能再被引用==
- ==pivot_column的列值，必须使用中括号（[]）界定符==
- ==必须显式命名pivot_table的别名==

### 1.1，创建示例数据

```sql
use tempdb
go 

drop table if exists dbo.usr
go

create table dbo.usr
(
    name varchar(10),
    score int,
    class varchar(8)
)
go

insert into dbo.usr
values('a',20,'math'),('b',21,'math'),('c',22,'phy'),('d',23,'phy')
,('a',22,'phy'),('b',23,'phy'),('c',24,'math'),('d',25,'math')
go
```



![img](重温SQL——行转列，列转行.assets/628084-20161130184313209-2094639455.png)

### 1.2，对name进行分组，对score进行聚合，将class列的值转换为列名

```sql
select p.name,p.math,p.phy
from dbo.usr u
pivot
(
    sum(score)
    for class in([math],[phy]) 
) as p
```



![img](重温SQL——行转列，列转行.assets/628084-20161130184558802-1425722655.png)

==行转列后，原来的某个列的值变做了列名，在这里就是原来WEEK列的值“math”,"phy"做了列名，而我们需要做的另一个工作就是计算这些列的值（这里的“计算”其实就是PIVOT里面的聚合函数(sum,avg等)）==

### 3，pivot的等价写法：使用case when语句实现

pivot命令的执行流程很简单，使用caseh when子句实现pivot的功能

```sql
select u.name,
    sum(case when u.class='math' then u.score else null end) as math,
    sum(case when u.class='phy' then u.score else null end) as phy
from dbo.usr u
group by u.name
```

使用group by子句对name列分组，使用 case when 语句将pivot_column的列值作为列名返回，并对aggregated_column计算聚合值。

### 4，动态Pivot写法

静态pivot写法的弊端是：如果pivot_column的列值发生变化，静态pivot不能对新增的列值进行透视，变通方法是使用动态sql，拼接列值

Script1，使用case-when子句实现



```sql
declare @sql nvarchar(max)
declare @columnlist nvarchar(max)

set @columnlist=N''

;with cte as
(
select distinct class
from dbo.usr
)
select @columnlist+='sum(case when u.class='''+cast(class as varchar(10))+N''' then u.score else null end) as ['+cast(class as varchar(10))+N'],'
from cte

select @columnlist=SUBSTRING(@columnlist,1,len(@columnlist)-1)

select @sql=
N'select u.name,'
    +@columnlist
+N'from dbo.usr u
group by u.name'

exec(@sql)
```



Script2，使用pivot子句实现

```sql
declare @sql nvarchar(max)
declare @classlist nvarchar(max)

set @classlist=N''

;with cte as
(
    select distinct class
    from dbo.usr
)
select @classlist+=N'['+cast(class as varchar(11))+N'],'
from cte

select     @classlist=SUBSTRING(@classlist,1,len(@classlist)-1)

select @sql=N'select p.name,'+@classlist+
N' from dbo.usr u
PIVOT
(
    sum(score) 
    for class in('+@classlist+N')
) as p'

exec (@sql)
```



## 2，Unpivot用法

unpivot是将列名转换为列值，列名做为列值，因此，会新增两个column：一个column用于存储列名，一个column用于存储列值

```sql
table_soucr
unpivot
(
newcolumn_store_unpivotcolumn_name for 
newcolumn_store_unpivotcolumn_value in (unpivotcolumn_name_list)  
)
```



**逆透视（unpivot）的处理流程是：**

1. unpivotcolumn_name_list是逆透视列的列表，其列值是相兼容的，能够存储在一个column中
2. 保持其他列（除unpivotcolumn_name_list之外的所有列）的列值不变
3. 依次将unpivotcolumn的列名存储到newcolumn_store_unpivotcolumn_name字段中，将unpivotcolumn的列值存储到newcolumn_store_unpivotcolumn_value字段中

### 2.1，创建示例数据

```sql
CREATE TABLE dbo.Venders 
(
    VendorID int, 
    Emp1 int, 
    Emp2 int,  
    Emp3 int, 
    Emp4 int, 
    Emp5 int
);  
GO 
 
INSERT INTO dbo.Venders VALUES (1,4,3,5,4,4);  
INSERT INTO dbo.Venders VALUES (2,4,1,5,5,5);  
INSERT INTO dbo.Venders VALUES (3,4,3,5,4,4);  
INSERT INTO dbo.Venders VALUES (4,4,2,5,5,4);  
INSERT INTO dbo.Venders VALUES (5,5,1,5,5,5);  
GO 
```

![img](重温SQL——行转列，列转行.assets/628084-20161130192801756-1977769302.png)

### 2.2，unpivot用法示例

将Emp1, Emp2, Emp3, Emp4, Emp5的列名和列值存储到字段：Employee和Orders中

```sql
SELECT VendorID, Employee, Orders  
FROM dbo.Venders as p 
UNPIVOT  
(Orders FOR Employee IN   
      (Emp1, Emp2, Emp3, Emp4, Emp5)  
)AS unpvt;  
GO 
```

![img](重温SQL——行转列，列转行.assets/628084-20161208124250132-1782168906-16425835464269.png)

### 2.3，unpivot等价写法：可以使用union all来实现

```sql
select VendorID, 'Emp1' as Employee, Emp1 as Orders
from dbo.Venders
union all 
select VendorID, 'Emp2' as Employee, Emp2 as Orders
from dbo.Venders
union all 
select VendorID, 'Emp3' as Employee, Emp3 as Orders
from dbo.Venders
union all
select VendorID, 'Emp4' as Employee, Emp4 as Orders
from dbo.Venders
union all
select VendorID, 'Emp5' as Employee, Emp5 as Orders
from dbo.Venders
```

### 2.4，动态unpivot的实现，使用动态sql语句

聪明如你，很容易实现，代码就不贴了....

## 3，性能讨论

pivot和unpivot的性能不是很好，不要用来处理海量的数据

 

参考文档：

[Using PIVOT and UNPIVOT](https://msdn.microsoft.com/en-us/library/ms177410.aspx)



## 4.Oracle的Pivot 和 Unpivot用法

## 4.1创建示例数据

```sql
create table TF_RP_F0101
(
    MONTH_WID                     NUMBER(10) not null,
    ORG_WID                       NUMBER(10) not null,
    ORGANIZATION_NAME             VARCHAR2(100),
    ORGANIZATION_CERTIFICATE_TYPE VARCHAR2(100),
    ORGANIZATION_CERTIFICATE_CODE VARCHAR2(100),
    PLACE_OF_REGISTRATION         VARCHAR2(100),
    ECONOMIC_COMPONENT            VARCHAR2(100),
    INDUSTRY_CLASSIFICATION       VARCHAR2(100),
    LISTED_OR_NOT                 VARCHAR2(100),
    POSTAL_CODE                   VARCHAR2(100),
    STATISTICS_NAME               VARCHAR2(100),
    DEPARTMENT_FAX                VARCHAR2(100),
    STATISTICS_MAILBOX            VARCHAR2(100),
    DEPARTMENT_NAME               VARCHAR2(100),
    DEPARTMENT_FIXED_LINE         VARCHAR2(100),
    DEPARTMENT_MOBILE_PHONE       VARCHAR2(100),
    STATISTICIAN_NAME             VARCHAR2(100),
    STATISTICIAN_WORKING_FIXED_LN VARCHAR2(100),
    STATISTICIAN_MOBILE           VARCHAR2(100),
    STATUS                        VARCHAR2(2),
    REVIEW_USER                   VARCHAR2(10),
    REVIEW_DATE                   DATE,
    REMARK1                       VARCHAR2(100),
    REMARK2                       VARCHAR2(100)
)
/

comment on table TF_RP_F0101 is '基本信息统计-母公司表'
/

comment on column TF_RP_F0101.MONTH_WID is '月ID'
/

comment on column TF_RP_F0101.ORG_WID is '成员公司WID'
/

comment on column TF_RP_F0101.ORGANIZATION_NAME is '机构名称'
/

comment on column TF_RP_F0101.ORGANIZATION_CERTIFICATE_TYPE is '机构证件类型'
/



INSERT INTO HBTZ_DW.TF_RP_F0101 (MONTH_WID, ORG_WID, ORGANIZATION_NAME, ORGANIZATION_CERTIFICATE_TYPE, ORGANIZATION_CERTIFICATE_CODE, PLACE_OF_REGISTRATION, ECONOMIC_COMPONENT, INDUSTRY_CLASSIFICATION, LISTED_OR_NOT, POSTAL_CODE, STATISTICS_NAME, DEPARTMENT_FAX, STATISTICS_MAILBOX, DEPARTMENT_NAME, DEPARTMENT_FIXED_LINE, DEPARTMENT_MOBILE_PHONE, STATISTICIAN_NAME, STATISTICIAN_WORKING_FIXED_LN, STATISTICIAN_MOBILE, STATUS, REVIEW_USER, REVIEW_DATE, REMARK1, REMARK2) VALUES (1, 2, 'A', 'm', null, null, null, null, '1', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
INSERT INTO HBTZ_DW.TF_RP_F0101 (MONTH_WID, ORG_WID, ORGANIZATION_NAME, ORGANIZATION_CERTIFICATE_TYPE, ORGANIZATION_CERTIFICATE_CODE, PLACE_OF_REGISTRATION, ECONOMIC_COMPONENT, INDUSTRY_CLASSIFICATION, LISTED_OR_NOT, POSTAL_CODE, STATISTICS_NAME, DEPARTMENT_FAX, STATISTICS_MAILBOX, DEPARTMENT_NAME, DEPARTMENT_FIXED_LINE, DEPARTMENT_MOBILE_PHONE, STATISTICIAN_NAME, STATISTICIAN_WORKING_FIXED_LN, STATISTICIAN_MOBILE, STATUS, REVIEW_USER, REVIEW_DATE, REMARK1, REMARK2) VALUES (1, 3, 'A', 'n', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
INSERT INTO HBTZ_DW.TF_RP_F0101 (MONTH_WID, ORG_WID, ORGANIZATION_NAME, ORGANIZATION_CERTIFICATE_TYPE, ORGANIZATION_CERTIFICATE_CODE, PLACE_OF_REGISTRATION, ECONOMIC_COMPONENT, INDUSTRY_CLASSIFICATION, LISTED_OR_NOT, POSTAL_CODE, STATISTICS_NAME, DEPARTMENT_FAX, STATISTICS_MAILBOX, DEPARTMENT_NAME, DEPARTMENT_FIXED_LINE, DEPARTMENT_MOBILE_PHONE, STATISTICIAN_NAME, STATISTICIAN_WORKING_FIXED_LN, STATISTICIAN_MOBILE, STATUS, REVIEW_USER, REVIEW_DATE, REMARK1, REMARK2) VALUES (1, 1, 'A', 'm', '1', null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
```

数据**select * from tf_rp_f0101;**

![image-20220119164600275](重温SQL——行转列，列转行.assets/image-20220119164600275.png)

## 4.2、pivot_column的列值，不是使用中括号（[]）界定符，而是‘value’ as colname

使用pivot查A下的m和n的和在一行显示：

```sql
SELECT ORGANIZATION_NAME,m,n
from (
select ORGANIZATION_NAME,org_wid,ORGANIZATION_CERTIFICATE_TYPE from tf_rp_f0101
) 
        pivot(
        sum(org_wid) for ORGANIZATION_CERTIFICATE_TYPE IN('m' AS m,'n' as n)	//需要加 as 而不是用[]框住字段，字符也要加''
        );      
```

结果：A	3	3



ps：注意不可写为：

```
SELECT ORGANIZATION_NAME,m,n
from tf_rp_f0101
        pivot(
        sum(org_wid) for ORGANIZATION_CERTIFICATE_TYPE IN('m' AS m,'n' as n)
        );
```

结果：

OR	 m	 n

A				3
A		2	
A		1	

==这样会按照tf_rp_f0101的所有字段group by，如果有pivot以外的字段值不同，则会分成不同的组分为不同行。==

因此需要

```
from (
select ORGANIZATION_NAME,org_wid,ORGANIZATION_CERTIFICATE_TYPE from tf_rp_f0101
)  //单独将要查的所有字段写出来，不相关的字段不查，则根据other_columns其余字段分组时不会有多余的字段
```



---

# 三、[SQL Server使用 PIVOT 和 UNPIVOT函数官方文档](https://docs.microsoft.com/zh-cn/previous-versions/sql/sql-server-2008-r2/ms177410(v=sql.105)?redirectedfrom=MSDN)

可以使用 PIVOT 和 UNPIVOT 关系运算符将表值表达式更改为另一个表。PIVOT 通过将表达式某一列中的唯一值转换为输出中的多个列来旋转表值表达式，并在必要时对最终输出中所需的任何其余列值执行聚合。UNPIVOT 与 PIVOT 执行相反的操作，将表值表达式的列转换为列值。

| ![注意](重温SQL——行转列，列转行.assets/ms166018.alert_note(zh-cn,sql.105).gif)**注意** |
| :----------------------------------------------------------- |
| 对升级到 SQL Server 2005 或更高版本的数据库使用 PIVOT 和 UNPIVOT 时，必须将数据库的兼容级别设置为 90 或更高。有关如何设置数据库兼容级别的信息，请参阅 [sp_dbcmptlevel (Transact-SQL)](https://docs.microsoft.com/zh-cn/previous-versions/sql/sql-server-2008-r2/ms178653(v=sql.105))。 |

PIVOT 提供的语法比一系列复杂的 SELECT...CASE 语句中所指定的语法更简单和更具可读性。有关 PIVOT 语法的完整说明，请参阅 [FROM (Transact-SQL)](https://docs.microsoft.com/zh-cn/previous-versions/sql/sql-server-2008-r2/ms177634(v=sql.105))。

以下是带批注的 PIVOT 语法。

SELECT <非透视的列>,

  [第一个透视的列] AS <列名称>,

  [第二个透视的列] AS <列名称>,

  ...

  [最后一个透视的列] AS <列名称>,

FROM

  (<生成数据的 SELECT 查询>)

  AS <源查询的别名>

PIVOT

(

  <聚合函数>(<要聚合的列>)

FOR

[<包含要成为列标题的值的列>]

  IN ( [第一个透视的列], [第二个透视的列],

  ... [最后一个透视的列])

) AS <透视表的别名>

<可选的 ORDER BY 子句>;

## 简单 PIVOT 示例



下面的代码示例生成一个两列四行的表。

```sql
USE AdventureWorks2008R2 ;
GO
SELECT DaysToManufacture, AVG(StandardCost) AS AverageCost 
FROM Production.Product
GROUP BY DaysToManufacture;
```

下面是结果集：

DaysToManufacture     AverageCost

0             5.0885

1             223.88

2             359.1082

4             949.4105

没有定义 DaysToManufacture 为 3 的产品。

以下代码显示相同的结果，该结果经过透视以使 DaysToManufacture 值成为列标题。提供一个列表示三 [3] 天，即使结果为 NULL。

```sql
-- Pivot table with one row and five columns
SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days, 
[0], [1], [2], [3], [4]
FROM
(SELECT DaysToManufacture, StandardCost 
    FROM Production.Product) AS SourceTable
PIVOT
(
AVG(StandardCost)
FOR DaysToManufacture IN ([0], [1], [2], [3], [4])
) AS PivotTable;
```

下面是结果集：

Cost_Sorted_By_Production_Days  0     1     2      3    4    

AverageCost            5.0885  223.88  359.1082  NULL  949.4105

## 复杂 PIVOT 示例



可能会用到 PIVOT 的常见情况是：需要生成交叉表格报表以汇总数据。例如，假设需要在 AdventureWorks2008R2 示例数据库中查询 PurchaseOrderHeader 表以确定由某些特定雇员所下的采购订单数。以下查询提供了此报表（按供应商排序）。

```sql
USE AdventureWorks2008R2;
GO
SELECT VendorID, [250] AS Emp1, [251] AS Emp2, [256] AS Emp3, [257] AS Emp4, [260] AS Emp5
FROM 
(SELECT PurchaseOrderID, EmployeeID, VendorID
FROM Purchasing.PurchaseOrderHeader) p
PIVOT
(
COUNT (PurchaseOrderID)
FOR EmployeeID IN
( [250], [251], [256], [257], [260] )
) AS pvt
ORDER BY pvt.VendorID;
```

以下为部分结果集。

VendorID  Emp1    Emp2    Emp3    Emp4    Emp5

1492    2      5      4      4      4

1494    2      5      4      5      4

1496    2      4      4      5      5

1498    2      5      4      4      4

1500    3      4      4      5      4

将在 EmployeeID 列上透视此嵌套 select 语句返回的结果。

```sql
SELECT PurchaseOrderID, EmployeeID, VendorID
FROM PurchaseOrderHeader;
```

这意味着 EmployeeID 列返回的唯一值自行变成了最终结果集中的字段。因此，在透视子句中指定的每个 EmployeeID 号都有相应的一列：在本例中为雇员 164、198、223、231 和 233。PurchaseOrderID 列作为值列，将根据此列对最终输出中返回的列（称为分组列）进行分组。在本例中，通过 COUNT 函数聚合分组列。请注意，将显示一条警告消息，指出为每个雇员计算 COUNT 时未考虑显示在 PurchaseOrderID 列中的任何空值。

| ![重要说明](重温SQL——行转列，列转行.assets/ms179530.alert_caution(zh-cn,sql.105).gif)**重要提示** |
| :----------------------------------------------------------- |
| ==如果聚合函数与 PIVOT 一起使用，则计算聚合时将不考虑出现在值列中的任何空值，即聚合函数中的字段不会统计空值，如上面的PurchaseOrderID== |

UNPIVOT 将与 PIVOT 执行几乎完全相反的操作，将列转换为行。假设以上示例中生成的表在数据库中存储为 pvt，并且您需要将列标识符 Emp1、Emp2、Emp3、Emp4 和 Emp5 旋转为对应于特定供应商的行值。这意味着必须标识另外两个列。包含要旋转的列值（Emp1、Emp2...）的列将被称为 Employee，将保存当前位于待旋转列下的值的列被称为 Orders。这些列分别对应于 Transact-SQL 定义中的 pivot_column 和 value_column。以下为该查询。

```sql
--Create the table and insert values as portrayed in the previous example.
CREATE TABLE pvt (VendorID int, Emp1 int, Emp2 int,
    Emp3 int, Emp4 int, Emp5 int);
GO
INSERT INTO pvt VALUES (1,4,3,5,4,4);
INSERT INTO pvt VALUES (2,4,1,5,5,5);
INSERT INTO pvt VALUES (3,4,3,5,4,4);
INSERT INTO pvt VALUES (4,4,2,5,5,4);
INSERT INTO pvt VALUES (5,5,1,5,5,5);
GO
--Unpivot the table.
SELECT VendorID, Employee, Orders
FROM 
   (SELECT VendorID, Emp1, Emp2, Emp3, Emp4, Emp5
   FROM pvt) p
UNPIVOT
   (Orders FOR Employee IN 
      (Emp1, Emp2, Emp3, Emp4, Emp5)
)AS unpvt;
GO
```

以下为部分结果集。

VendorID Employee Orders

---------- ---------- ------

1     Emp1    4

1     Emp2    3

1     Emp3    5

1     Emp4    4

1     Emp5    4

2     Emp1    4

2     Emp2    1

2     Emp3    5

2     Emp4    5

2     Emp5    5

...

请注意，UNPIVOT 并不完全是 PIVOT 的逆操作。PIVOT 会执行一次聚合，从而将多个可能的行合并为输出中的单个行。而 UNPIVOT 不会重现原始表值表达式的结果，因为行已经被合并了。另外，UNPIVOT 的输入中的空值不会显示在输出中，而在执行 PIVOT 操作之前，输入中可能有原始的空值。

AdventureWorks2008R2 示例数据库中的 Sales.vSalesPersonSalesByFiscalYears 视图将使用 PIVOT 返回每个销售人员在每个会计年度的总销售额。若要在 SQL Server Management Studio 中编写视图脚本，请在**“对象资源管理器”**中，在**“视图”**文件夹下找到 AdventureWorks2008R2 数据库对应的视图。右键单击该视图名称，再选择**“编写视图脚本为”**。

## 请参阅



#### 参考

[FROM (Transact-SQL)](https://docs.microsoft.com/zh-cn/previous-versions/sql/sql-server-2008-r2/ms177634(v=sql.105))

[CASE (Transact-SQL)](https://docs.microsoft.com/zh-cn/previous-versions/sql/sql-server-2008-r2/ms181765(v=sql.105))



----

# 四、[Oracle：Pivot 和 Unpivot 转多列并包含多个名称](https://blog.csdn.net/paopaopotter/article/details/81735922)

## Pivot

1、准备数据

```sql
create table t_demo(id int,name varchar(20),nums int);  ---- 创建表  
insert into t_demo values(1, '苹果', 1000);  
insert into t_demo values(2, '苹果', 2000);  
insert into t_demo values(3, '苹果', 4000);  
insert into t_demo values(4, '橘子', 5000);  
insert into t_demo values(5, '橘子', 3000);  
insert into t_demo values(6, '葡萄', 3500);  
insert into t_demo values(7, '芒果', 4200);  
insert into t_demo values(8, '芒果', 5500); 
```

![image-20220608180050097](重温SQL——行转列，列转行.assets/image-20220608180050097.png)

**==2、Pivot行转多列==**

```sql
select * 
from (select name, nums from t_demo) 
pivot (sum(nums) total,min(nums) min for name in ('苹果' apple, '橘子' orange, '葡萄' grape, '芒果' mango));
```

![image-20220608180016416](重温SQL——行转列，列转行.assets/image-20220608180016416.png)

例：

```mysql
select PROJECT,nvl("202112_AMT",0) AMT1,nvl("202112_RATIO",0) RATIO1,nvl("202201_AMT",0) AMT2,nvl("202201_RATIO",0) RATIO2 from (select PROJECT,TOTAL_RENT_RECEIVABLE,MONTH_WID,RATIO from TF_MRHBZL_YMZTZLZC where REPORT_TYPE = 2)
    pivot(max(TOTAL_RENT_RECEIVABLE) AMT,max(ratio) RATIO for MONTH_WID in(202201,202112)) order by PROJECT;
```

结果：

```
project    || AMT1 || RATIO1 || AMT2 	 || RATIO2
基础设施投资 || 0    ||  0	 || 23432.34 || 0.062
冶金建设	|| 0	||	0	  || 4324.43   ||0.021
```



## Unpivot

1、准备数据

```sql
CREATE TABLE t_demo_unpivot as
select * 
from (select name, nums from t_demo) 
pivot (sum(nums) total,min(nums) min for name in ('苹果' apple, '橘子' orange, '葡萄' grape, '芒果' mango));
```

![image-20220608180016416](重温SQL——行转列，列转行.assets/image-20220608180016416.png)

2.列转行

```sql
select * from t_demo_unpivot unpivot(nums for name in (APPLE_TOTAL,APPLE_MIN,ORANGE_TOTAL,ORANGE_MIN,GRAPE_TOTAL,GRAPE_MIN,MANGO_TOTAL,MANGO_MIN))
```

![img](重温SQL——行转列，列转行.assets/70.png)

3.转多列并包含多个名称

```sql
select * 
from t_demo_unpivot 
unpivot((total,min) for name in ((APPLE_TOTAL,APPLE_MIN) AS '苹果',
                                 (ORANGE_TOTAL,ORANGE_MIN) AS '橘子',
                                 (GRAPE_TOTAL,GRAPE_MIN) AS '葡萄',
                                 (MANGO_TOTAL,MANGO_MIN) AS '芒果'
                                ) 
        ) 


```

![image-20220608175946286](重温SQL——行转列，列转行.assets/image-20220608175946286.png)

