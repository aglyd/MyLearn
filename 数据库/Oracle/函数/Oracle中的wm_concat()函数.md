# 一、[Oracle中的wm_concat()函数](https://www.cnblogs.com/afei1013/p/13467754.html)

   最近发现一个函数非常好用，有时候我们在项目中可能需要将一列值，统一查出来然后变成一个字符串进行展示，这时我们的合并列函数wm_concat的作用就凸显出来了，接下来让我们看看这个函数的妙用：

一、wm_concat()函数是oracle中独有的,mysql中有一个group_concat()函数。

这两个函数的作用是相同的，它们的功能是：实现合并列功能，即将查询出的某一列值使用逗号进行隔开拼接，成为一条数据。



---

# 二、[行列转换之字符串拼接（一）、WM_CONCAT函数](https://blog.csdn.net/yoursly/article/details/79673173)

字符串拼接和分离（String Aggregation Techniques）是数据处理时经常需要用到一个技术，比如需要按时间顺序拼装一个快递的运输记录，或者将流程中各个环节的处理人拼装为一个字符串。

Oracle中有多种方法来实现这个功能，这里罗列几种，详细用法可以参考下面的文章：
- WM_CONCAT函数
- LISTAGG函数
- 自定义聚合函数

0.测试样例
这里介绍第一种：WM_CONCAT，这个函数是Oracle内部函数，在官方文档里是没有说明（undocumented function），并且在Oracle12.2开始的版本里已经取消了WM_CONCAT函数。

从all_objects视图中取4个表记录和3个视图记录作为测试数据：

```sql
SQL> CREATE TABLE T_STRAGG AS
  2    select OBJECT_TYPE,CREATED,OBJECT_NAME from ALL_OBJECTS WHERE OBJECT_TYPE='TABLE' AND rownum<5
  3    UNION ALL
  4    select OBJECT_TYPE,CREATED,OBJECT_NAME from ALL_OBJECTS WHERE OBJECT_TYPE='VIEW' AND rownum<4;
Table created

SQL> select OBJECT_TYPE,TO_CHAR(CREATED,'YYYY-MM-DD HH24:MI:SS') CREATED,OBJECT_NAME from T_STRAGG;
OBJECT_TYPE         CREATED             OBJECT_NAME
------------------- ------------------- ------------------------------
TABLE               2013-10-09 18:23:43 DUAL
TABLE               2013-10-09 18:23:44 SYSTEM_PRIVILEGE_MAP
TABLE               2013-10-09 18:23:45 TABLE_PRIVILEGE_MAP
TABLE               2013-10-09 18:23:47 STMT_AUDIT_OPTION_MAP
VIEW                2013-10-09 18:23:53 ALL_XML_SCHEMAS
VIEW                2013-10-09 18:23:56 ALL_XML_SCHEMAS2
VIEW                2013-10-09 18:23:54 V_$ADVISOR_CURRENT_SQLPLAN
```

根据OBJECT_TYPE分组拼接OBJECT_NAME字符串的语法如下：

```sql
SQL> select object_type,WM_CONCAT(OBJECT_NAME) FROM T_STRAGG group by object_type;
OBJECT_TYPE         WM_CONCAT(OBJECT_NAME)

------------------- --------------------------------------------------------------------------------

TABLE               DUAL,STMT_AUDIT_OPTION_MAP,TABLE_PRIVILEGE_MAP,SYSTEM_PRIVILEGE_MAP
VIEW                ALL_XML_SCHEMAS,V_$ADVISOR_CURRENT_SQLPLAN,ALL_XML_SCHEMAS2
```

![这里写图片描述](https://img-blog.csdn.net/20180323210501212?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3lvdXJzbHk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

这里我们发现了WM_CONCAT函数的几个特征（或问题）：

## 1.返回值只能用逗号分隔的

这一点无法改变

## 2.返回值是CLOB类型

在11g之前返回的是VARCHAR2类型。
这有个优点，能支持很长的字符串拼接，短了可以TO_CHAR展示
但也有缺点，就是大大增大了临时段的读写，数据量大时可能会出现错误
ORA-01652:unable to extend temp segment by 128 in tablespace name
( 无法通过 128 (在表空间 TEMP 中) 扩展 temp 段)

## 3.没法排序

比如，我想按照created先后进行排序，产生这样的结果:

>DUAL创建于2013-10-09 18:23:43，SYSTEM_PRIVILEGE_MAP创建于2013-10-09
18:23:44…..

虽然WM_CONCAT函数本身不支持排序，但是还是有变通的办法来解决排序问题：

```sql
SQL> select object_type,TXT from
  2  (
  3  select object_type
  4         ,WM_CONCAT(OBJECT_NAME||'创建于'||TO_CHAR(CREATED,'YYYY-MM-DD HH24:MI:SS')) OVER (PARTITION BY OBJECT_TYPE ORDER BY CREATED) AS TXT
  5         ,ROW_NUMBER() OVER (PARTITION BY OBJECT_TYPE ORDER BY CREATED DESC) RN
  6    FROM T_STRAGG
  7  ) WHERE RN=1;
OBJECT_TYPE         TXT

------------------- --------------------------------------------------------------------------------

TABLE               DUAL创建于2013-10-09 18:23:43,SYSTEM_PRIVILEGE_MAP创建于2013-10-09 18:23:44,TABLE_PRIV
VIEW                ALL_XML_SCHEMAS创建于2013-10-09 18:23:53,V_$ADVISOR_CURRENT_SQLPLAN创建于2013-10-09 18
```

网上有些文章并没有使用row_number()来取数，而是用MAX函数取最大值
事实上在oracle11g里会报ORA-00932错:

```sql
SQL> select object_type,MAX(TXT) from
  2  (
  3  select object_type
  4         ,WM_CONCAT(OBJECT_NAME||'创建于'||TO_CHAR(CREATED,'YYYY-MM-DD HH24:MI:SS')) OVER (PARTITION BY OBJECT_TYPE ORDER BY CREATED) AS TXT
  5    FROM T_STRAGG
  6  ) GROUP BY OBJECT_TYPE;

ORA-00932: inconsistent datatypes: expected - got CLOB
```

原因是clob字段不支持max函数，网上的文章是基于oracle11g之前的环境，那时WM_CONCAT函数返回的是VARCHAR2类型。

原因是clob字段不支持max函数，网上的文章是基于oracle11g之前的环境，那时WM_CONCAT函数返回的是VARCHAR2类型。

## 4.对DISTINCT的部分支持

在sql环境中，WM_CONCAT是支持DISTINCT的，比如：

```sql
SQL> insert into t_stragg select * from t_stragg where OBJECT_NAME='DUAL';
1 row inserted

SQL> select * from t_stragg where OBJECT_NAME='DUAL';
OBJECT_TYPE         CREATED     OBJECT_NAME
------------------- ----------- ------------------------------
TABLE               2013/10/9 1 DUAL
TABLE               2013/10/9 1 DUAL

SQL> select object_type,WM_CONCAT(DISTINCT OBJECT_NAME) AS TXT
  2    FROM T_STRAGG
  3   GROUP BY OBJECT_TYPE;
OBJECT_TYPE         TXT
------------------- --------------------------------------------------------------------------------
TABLE               DUAL,STMT_AUDIT_OPTION_MAP,SYSTEM_PRIVILEGE_MAP,TABLE_PRIVILEGE_MAP
VIEW                ALL_XML_SCHEMAS,ALL_XML_SCHEMAS2,V_$ADVISOR_CURRENT_SQLPLAN
```

**但是在PLSQL环境中，WM_CONCAT使用distinct会报错**
ORA-30482: DISTINCT option not allowed for this function
这就是我所说的部分支持。

```sql
SQL> create or replace function F_WMCONCAT(V_OBJTYPE VARCHAR2) return clob is
  2    FunctionResult clob;
  3  begin
  4    select WM_CONCAT(DISTINCT OBJECT_NAME) AS TXT
  5  
  6     INTO FunctionResult
  7     FROM T_STRAGG
  8     WHERE OBJECT_TYPE=V_OBJTYPE;
  9  
 10     return(FunctionResult);
 11  end F_WMCONCAT;
 12  /
Warning: Function created with compilation errors

SQL> SHOW ERR
Errors for FUNCTION DONGFENG.F_WMCONCAT:
LINE/COL ERROR
-------- ----------------------------------------------------------------
4/10     PL/SQL: ORA-30482: DISTINCT option not allowed for this function
4/3      PL/SQL: SQL Statement ignored
```

**当然，这个也有办法解决：**

**1. 解决办法之一是先做distinct，再wm_concat；**
**2. 解决办法之二是用动态SQL方式，规避PLSQL编译。**

比如：

```sql
SQL> create or replace function F_WMCONCAT(V_OBJTYPE VARCHAR2) return clob is
  2    FunctionResult clob;
  3  begin
  4  execute immediate
  5   'select WM_CONCAT(DISTINCT OBJECT_NAME) AS TXT
  6     FROM T_STRAGG
  7     WHERE OBJECT_TYPE='''||V_OBJTYPE||''''
  8     INTO FunctionResult;
  9  
 10     return(FunctionResult);
 11  end F_WMCONCAT;
 12  /
Function created

SQL> select F_WMCONCAT('TABLE') from DUAL;
F_WMCONCAT('TABLE')
--------------------------------------------------------------------------------
DUAL,STMT_AUDIT_OPTION_MAP,SYSTEM_PRIVILEGE_MAP,TABLE_PRIVILEGE_MAP
```

## 建议

1. Oracle官方并不推荐使用WM_CONCAT函数，因此尽量少用



----

# 三、[Oracle wm_concat（）函数](https://www.cnblogs.com/qianyuliang/p/6649983.html)

  在日常的数据查询过程中，经常遇到一条信息分多条记录存储，并以同一个ID关联的情况，比如常见的房产证权利人信息，因为共有权人可能有很多，不可能把所有的权利人都放到权利人表的权利人字段，把所有权利人的证件号都放到权利人证件号字段，所以在数据库设计时候，会采用一个权利人一条记录，并以权利ID关联的方式存放。

但是在数据查询时候，有时候又希望将所有权利人信息一起展示，这里可能就会用到Oracle的wm_concat函数

oracle wm_concat(column)函数使我们经常会使用到的，下面就教您如何使用[oracle](http://database.51cto.com/art/201009/228094.htm)wm_concat(column)函数实现字段合并

如：

```
shopping:

\-----------------------------------------

u_id    goods       num

\------------------------------------------

1         苹果         2
2         梨子        5
1         西瓜        4
3         葡萄        1
3         香蕉         1
1         橘子         3

======================

想要的结果为:

\--------------------------------

u_id      goods_sum

____________________

1        苹果,西瓜,橘子
2        梨子
3        葡萄,香蕉

---------------------------------

select u_id, wmsys.wm_concat(goods) goods_sum  from shopping  group by u_id  
```

```
想要的结果2:

\--------------------------------

u_id      goods_sum

____________________

1        苹果(2斤),西瓜(4斤),橘子(3斤)

2        梨子(5斤)

3        葡萄(1斤),香蕉(1斤)

\---------------------------------
使用oracle wm_concat(column)函数实现：

select u_id, wmsys.wm_concat(goods || '(' || num || '斤)' ) goods_sum  from shopping  group by u_id  
```

