# [mysql中with as的用法是什么](https://m.php.cn/article/487023.html)

## 原理

注：with 语法，**不适合 mysql 8.0 版本之前。**

WITH AS短语，也叫做子查询部分（subquery factoring），可以定义一个SQL片断，该SQL片断会被整个SQL语句用到。可以使SQL语句的可读性更高，**也可以在UNION ALL的不同部分，作为提供数据的部分。**with 其实就是一个子查询抽取出来，换了一个别名。

对于UNION ALL，使用WITH AS定义了一个UNION ALL语句，当该片断被调用2次以上，优化器会自动将该WITH AS短语所获取的数据放入一个Temp表中。而提示meterialize则是强制将WITH AS短语的数据放入一个全局临时表中。很多查询通过该方式都可以提高速度。

**因with as 子查询仅执行一次，将结果存储在用户临时表中，提高查询性能，所以适合多次引用的场景，**如：复杂的报表统计，分页查询，且需要拿到sum、count、avg这类结果作为筛选条件，对查询出的结果进行二次处理！大量的报表查询时, 使用 with as 可以提取出大量的子查询, 更加简洁。

**与中间表的区别：该临时表结果可被多次引用；中间表只能被使用一次；**

如果一整句查询中**多个子查询都需要使用同一个子查询**的结果，那么就可以用with as，将共用的子查询提取出来，加个别名。后面查询语句可以直接用，对于大量复杂的SQL语句起到了很好的优化作用。

注意：

- **相当于一个临时表，但是不同于视图，不会存储起来，要与select配合使用。**
- 同一个select前可以有多个临时表，写一个with就可以，用逗号隔开，最后一个with语句不要用逗号。
- with子句要用括号括起来。

特别对于union all比较有用。因为union all的每个部分可能相同，但是如果每个部分都去执行一遍的话，则成本太高

## 常用语法

–针对一个别名

```sql
`with` `tmp ``as` `(``select` `* ``from` `tb_name)`
```

–针对多个别名

```mysql
`with``tmp ``as` `(``select` `* ``from` `tb_name),``tmp2 ``as` `(``select` `* ``from` `tb_name2),``tmp3 ``as` `(``select` `* ``from` `tb_name3),``…`
```

–相当于建了个e临时表

```sql
`with` `e ``as` `(``select` `* ``from` `scott.emp e ``where` `e.empno=7499)``select` `* ``from` `e;`
```

–相当于建了e、d临时表

```sql
`with``e ``as` `(``select` `* ``from` `scott.emp),``d ``as` `(``select` `* ``from` `scott.dept)``select` `* ``from` `e, d ``where` `e.deptno = d.deptno;`
```

其实就是把一大堆重复用到的sql语句放在with as里面，取一个别名，后面的查询就可以用它，这样对于大批量的sql语句起到一个优化的作用，而且清楚明了。



## 简单使用示例

### 1.with 写法，让两个表的相同等级人数相除

统计出两张表每个等级的人数，再使用等级进行join，再计算。

```sql
with t1 as (
    select 
		    emp.emp_level as type,
	      count(emp.id) as n
	  from
		    emp
		group by
		    emp.emp_level
),
t2 as (
    select 
		    d.depot_level as type,
	      count(d.id) as n
	  from
		    depot as d
		group by
		    d.depot_level
)
select 
    t1.n/t2.n
from
    t1
left join
    t2
on t1.type = t2.type
```

![img](https://img-blog.csdnimg.cn/20210512094315858.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxMzYxMTYy,size_16,color_FFFFFF,t_70)

### 2.这个写法等同于

![img](https://img-blog.csdnimg.cn/2021051209463523.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxMzYxMTYy,size_16,color_FFFFFF,t_70)

特别是从多张表中取数据时，而且每张表的数据量又很大时，使用with写法可以先筛选出来一张数据量较少的表，避免全表join。



# [mysql 递归函数with recursive的用法](https://blog.csdn.net/mjfppxx/article/details/124879326)

## AS 用法

AS在mysql用来给列/表起别名.
有时，列的名称是一些表达式，使查询的输出很难理解。要给列一个描述性名称，可以使用列别名。
要给列添加别名，可以使用AS关键词后跟别名

例子1:

```sql
SELECT 
 [column_1 | expression] AS col_name
FROM table_name;
```

如果别名包含空格，则必须引用以下内容：

例子2:

```sql
SELECT 
 [column_1 | expression] AS 'col name'
FROM table_name;
```

## with(Common Table Expressions/CTE)用法:

with在mysql中被称为公共表达式,可以作为一个临时表然后在其他结构中调用.如果是自身调用那么就是后面讲的递归.

**语法:**

```sql
with_clause:
    WITH [RECURSIVE]
        cte_name [(col_name [, col_name] ...)] AS (subquery)
        [, cte_name [(col_name [, col_name] ...)] AS (subquery)] ...
```

cte_name :公共表达式的名称,可以理解为表名,用来表示as后面跟着的子查询
col_name :公共表达式包含的列名,可以写也可以不写，**==注意：col_name和subquery里的字段是按照顺序一一填充的，也就是说不管subquery里的字段取什么别名filed1或者filed2，只要他和cte_name里的col_name字段顺序相同，该字段的值就会成为col_name的值==**

例子1:

```sql
WITH
  cte1 AS (SELECT a, b FROM table1),
  cte2 AS (SELECT c, d FROM table2)
SELECT b, d FROM cte1 JOIN cte2
WHERE cte1.a = cte2.c;
```

例子2:

```sql
WITH cte (col1, col2) AS
(
  SELECT 1, 2
  UNION ALL
  SELECT 3, 4
)
SELECT col1, col2 FROM cte;
```

例子3:

这里的第一个as后面接的是子查询,第二个as表示列名,而不是子查询.

```sql
WITH cte AS
(
  SELECT 1 AS col1, 2 AS col2
  UNION ALL
  SELECT 3, 4
)
SELECT col1, col2 FROM cte;
```

## with的合法用法:

- 在子查询(包括派生的表子查询)的开始处

```sql
SELECT ... WHERE id IN (WITH ... SELECT ...) ...
SELECT * FROM (WITH ... SELECT ...) AS dt ...
```

- 同一级别只允许一个WITH子句。同一级别的WITH后面跟着WITH是不允许的,下面是非法用法:

```sql
WITH cte1 AS (...) WITH cte2 AS (...) SELECT ...
```

改为合法用法：先查出cte1子查询再查询cte2

```sql
WITH cte1 AS (SELECT 1)
SELECT * FROM (WITH cte2 AS (SELECT 2) SELECT * FROM cte2 JOIN cte1) AS dt;
```

在这里面as代表列名,sql不是顺序执行的,这一点了解的话就很好理解这个as了

## 简单递归用法:

首先我们引出一个问题: **什么叫做递归?**
**递归：给定函数初始条件,然后反复调用自身直到终止条件.**

### 例子1:递归得到依次递增的序列:

```sql
WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 5
)
SELECT * FROM cte;
```

```
+------+
| n    |
+------+
|    1 |
|    2 |
|    3 |
|    4 |
|    5 |
+------+
```

官方文档中对于这个写法的解释:

At each iteration, that SELECT produces a row with a new value one greater than the value of n from the previous row set. The first iteration operates on the initial row set (1) and produces 1+1=2; the second iteration operates on the first iteration’s row set (2) and produces 2+1=3; and so forth. This continues until recursion ends, which occurs when n is no longer less than 5.

用python实现就是:

```python
def cte(n):
	print(n)
	if n<5:
		cte(n+1)
```

也就是说,一个with recursive 由两部分组成.第一部分是非递归部分(union all上方),第二部分是递归部分(union all下方).递归部分第一次进入的时候使用非递归部分传递过来的参数,也就是第一行的数据值,进而得到第二行数据值.然后根据第二行数据值得到第三行数据值.

### 例子2:递归得到不断复制的字符串

这里的as表示列名,表示说这个CTE有两个列,也可以写为with cte(n,str) as (subquery)

```sql
WITH RECURSIVE cte AS
(
  SELECT 1 AS n, 'abc' AS str
  UNION ALL
  SELECT n + 1, CONCAT(str, str) FROM cte WHERE n < 3
)
SELECT * FROM cte;
```

```
+------+------+
| n    | str  |
+------+------+
|    1 | abc  |
|    2 | abc  |
|    3 | abc  |
+------+------+
```

这里的话concat是每一次都连接一个str,这个str来自上一行的结果,但是最终输出却是每一行都没有变化的值,这是为什么?
这是因为我们在声明str的时候限制了它的字符长度,使用 类型转换CAST(‘abc’ AS CHAR(30)) 就可以得到复制的字符串了.
**注意:**这里也可能会报错,看mysql模式.在严格模式下这里会显示Error Code: 1406. Data too long for column 'str' at row 1
关于strict SQL mode和nonstrict SQL mode:[mysql 严格模式 Strict Mode说明](https://blog.csdn.net/fdipzone/article/details/50616247)

```sql
WITH RECURSIVE cte AS
(
  SELECT 1 AS n, CAST('abc' AS CHAR(20)) AS str
  UNION ALL
  SELECT n + 1, CONCAT(str, str) FROM cte WHERE n < 3
)
SELECT * FROM cte;
```

```
+------+--------------+
| n    | str          |
+------+--------------+
|    1 | abc          |
|    2 | abcabc       |
|    3 | abcabcabcabc |
+------+--------------+
```

当然,如果上一行的值有多个,我们还可以对多个值进行重新组合得到我们想要的结果,比如下面这个例子.

### 例子3:生成斐波那契数列

```sql
WITH RECURSIVE fibonacci (n, fib_n, next_fib_n) AS
(
  SELECT 1, 0, 1
  UNION ALL
  SELECT n + 1, next_fib_n, fib_n + next_fib_n
    FROM fibonacci WHERE n < 10
)
SELECT * FROM fibonacci;
```

```
+------+-------+------------+
| n    | fib_n | next_fib_n |
+------+-------+------------+
|    1 |     0 |          1 |
|    2 |     1 |          1 |
|    3 |     1 |          2 |
|    4 |     2 |          3 |
|    5 |     3 |          5 |
|    6 |     5 |          8 |
|    7 |     8 |         13 |
|    8 |    13 |         21 |
|    9 |    21 |         34 |
|   10 |    34 |         55 |
+------+-------+------------+
```

## 语法说明:

### UNION ALL与UNION DISTINCT

- UNION ALL:
  **非递归部分和递归部分用UNION ALL分隔,那么所有的行都会被加入到最后的表中**
- UNION DISTINCT:
  **非递归部分和递归部分用UNION DISTINCT分隔，重复的行被消除。这对于执行传递闭包的查询非常有用，以避免无限循环。**

### limit控制递归次数

### recursive(union后的select)不能使用的结构:

官网的描述:

- The recursive SELECT part must not contain these constructs:

  ```sql
  Aggregate functions such as SUM()
  
  Window functions
  
  GROUP BY
  
  ORDER BY
  
  DISTINCT
  ```

  

### 限制递归次数/时间:

当出现不符合设置情况的会报错,分为以下几种设置方法:

- **cte_max_recursion_depth :default 设置为1000,表达递归的层数**.可以使用如下语句修改这个值:

```sql
SET SESSION cte_max_recursion_depth = 10;      -- permit only shallow recursion
SET SESSION cte_max_recursion_depth = 1000000; -- permit deeper recursion
```

当然也可以设置为**global**,也就是set global cte_max_recursion_depth = 1000000;这样子就对全局的递归都有限制

- **max_execution_time :设置递归时间**

```sql
SET max_execution_time = 1000; -- impose one second timeout
```

- MAX_EXECUTION_TIME:设置全局的递归时间

官网文档说明如下:

- The cte_max_recursion_depth system variable enforces a limit on the
  number of recursion levels for CTEs. The server terminates execution
  of any CTE that recurses more levels than the value of this variable.

- The max_execution_time system variable enforces an execution timeout
  for SELECT statements executed within the current session.对于当前会话中执行的SELECT语句

- The MAX_EXECUTION_TIME optimizer hint enforces a per-query execution
  timeout for the SELECT statement in which it appears.强制每个查询执行SELECT语句中超时时间。

- limit：限制最大行的数量

  ```sql
  WITH RECURSIVE cte (n) AS
  (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM cte LIMIT 10000
  )
  SELECT * FROM cte;
  ```

  



# [Mysql高级查询：with](https://zhuanlan.zhihu.com/p/401434647)

昨日问over()里可以partition by几个字段，order by 几个字段？只要你能理解partition by和order by的组合含义，by几个都可以。

![img](https://pic2.zhimg.com/80/v2-ff33c70ab4522a253b807c4a4d11fa49_720w.jpg)

今天继续学习新的知识，又是一个新的高级特性，**with定义通用表达式**，可理解为一个可定义的对象，在sql代码中进行引用。

## 1、使用

![img](https://pic4.zhimg.com/80/v2-8c395281d4ad949c3d5eecda8cedcc93_720w.jpg)

![img](https://pic1.zhimg.com/80/v2-e7345f2fa16f4995ce7a0924d74b1ed0_720w.jpg)

![img](https://pic2.zhimg.com/80/v2-b224b277ac6179fa57c284f53fd44fad_720w.jpg)

![img](https://pic3.zhimg.com/80/v2-00bcc8bc4c9b8657a45321a7a5cb5876_720w.jpg)

![img](https://pic1.zhimg.com/80/v2-957511f6e851075aeb9ac0770a512990_720w.jpg)

## 2、总结

with cte极大提升代码可读性，可在sql头部编写；而中间表只能在sql中间被定义；

cte和中间表都需要as来给个名称

cte可被多次引用；中间表只能被使用一次；

cte可自我引用，用于递归recursive，这是非常灵活方便的一个功能，与窗口函数有过之无不及，相当于具备了编程语言的功能。那些具有层级关系的维度数据，就可用此法来实现便利的统计。





# [新特性解读 | MySQL 8.0 通用表达式（WITH）深入用法](https://zhuanlan.zhihu.com/p/373615507)

MySQL 8.0 发布已经好几年了，之前介绍过 WITH 语句（通用表达式）的简单用途以及使用场景，类似如下的语句：

**with tmp(a) as (select 1 union all select 2) select \* from tmp;**

正巧之前客户就咨询我，WITH 有没有可能和 UPDATE、DELETE 等语句一起来用？或者说有没有可以简化日常 SQL 的其他用法，有点迷惑，能否写几个例子简单说明下？

其实 WITH 表达式除了和 SELECT 一起用， 还可以有下面的组合：

insert with 、with update、with delete、with with、with recursive(可以模拟数字、日期等序列)、WITH 可以定义多张表

我们来一个一个看看：

## 1. 用 WITH 表达式来造数据

用 WITH 表达式来造数据，非常简单，比如下面例子：给表 y1 添加100条记录，日期字段要随机。

```sql
localhost:ytt>create table y1 (id serial primary key, r1 int,log_date date);
Query OK, 0 rows affected (0.09 sec)

localhost:ytt>INSERT y1 (r1,log_date)
    -> WITH recursive tmp (a, b) AS
    -> (SELECT
    ->   1,
    ->   '2021-04-20'
    -> UNION
    -> ALL
    -> SELECT
    ->   ROUND(RAND() * 10),
    ->   b - INTERVAL ROUND(RAND() * 1000) DAY
    -> FROM
    ->   tmp
    -> LIMIT 100) TABLE tmp;
Query OK, 100 rows affected (0.03 sec)
Records: 100  Duplicates: 0  Warnings: 0

localhost:ytt>table y1 limit 10;
+----+------+------------+
| id | r1   | log_date   |
+----+------+------------+
|  1 |    1 | 2021-04-20 |
|  2 |    8 | 2020-04-02 |
|  3 |    5 | 2019-05-26 |
|  4 |    1 | 2018-01-21 |
|  5 |    2 | 2016-09-08 |
|  6 |    9 | 2016-06-14 |
|  7 |    7 | 2016-02-06 |
|  8 |    6 | 2014-03-18 |
|  9 |    6 | 2011-08-25 |
| 10 |    9 | 2010-02-02 |
+----+------+------------+
10 rows in set (0.00 sec)
```

## 2. 用 WITH 表达式来更新表数据

WITH 表达式可以与 UPDATE 语句一起，来执行要更新的表记录：

```sql
localhost:ytt>WITH recursive tmp (a, b, c) AS
    -> (SELECT
    ->   1,
    ->   1,
    ->   '2021-04-20'
    -> UNION ALL
    -> SELECT
    ->   a + 2,
    ->   100,
    ->   DATE_SUB(
    ->     CURRENT_DATE(),
    ->     INTERVAL ROUND(RAND() * 1000, 0) DAY
    ->   )
    -> FROM
    ->   tmp
    -> WHERE a < 100)
    -> UPDATE
    ->   tmp AS a,
    ->   y1 AS b
    -> SET
    ->   b.r1 = a.b
    -> WHERE a.a = b.id;
Query OK, 49 rows affected (0.02 sec)
Rows matched: 50  Changed: 49  Warnings: 0

localhost:ytt>table y1 limit 10;
+----+------+------------+
| id | r1   | log_date   |
+----+------+------------+
|  1 |    1 | 2021-04-20 |
|  2 |    8 | 2019-12-26 |
|  3 |  100 | 2018-06-12 |
|  4 |    8 | 2017-07-11 |
|  5 |  100 | 2016-08-10 |
|  6 |    9 | 2015-09-14 |
|  7 |  100 | 2014-12-19 |
|  8 |    2 | 2014-08-13 |
|  9 |  100 | 2014-08-05 |
| 10 |    8 | 2011-11-12 |
+----+------+------------+
10 rows in set (0.00 sec)
```

## 3. 用 WITH 表达式来删除表数据

比如删除 ID 为奇数的行，可以用 WITH DELETE 形式的删除语句：

```sql
localhost:ytt>WITH recursive tmp (a) AS
    -> (SELECT
    ->   1
    -> UNION
    -> ALL
    -> SELECT
    ->   a + 2
    -> FROM
    ->   tmp
    -> WHERE a < 100)
    -> DELETE FROM y1 WHERE id IN (TABLE tmp);
Query OK, 50 rows affected (0.02 sec)

localhost:ytt>table y1 limit 10;
+----+------+------------+
| id | r1   | log_date   |
+----+------+------------+
|  2 |    6 | 2019-05-16 |
|  4 |    8 | 2015-12-07 |
|  6 |    2 | 2014-05-14 |
|  8 |    7 | 2010-05-07 |
| 10 |    3 | 2007-03-27 |
| 12 |    6 | 2006-12-14 |
| 14 |    3 | 2004-04-22 |
| 16 |    7 | 2001-09-16 |
| 18 |    7 | 2001-01-04 |
| 20 |    7 | 2000-02-12 |
+----+------+------------+
10 rows in set (0.00 sec)
```

与 DELETE 一起使用，要注意一点：WITH 表达式本身数据为只读，所以多表 DELETE 中不能包含 WITH 表达式。比如把上面的语句改成多表删除形式会直接报 WITH 表达式不可更新的错误。

```sql
localhost:ytt>WITH recursive tmp (a) AS
    ->  (SELECT
    ->    1
    ->  UNION
    ->  ALL
    ->  SELECT
    ->    a + 2
    ->  FROM
    ->    tmp
    ->  WHERE a < 100)
    ->  delete a,b from y1 a join tmp b where a.id = b.a;
ERROR 1288 (HY000): The target table b of the DELETE is not updatable
```

## 4. WITH 和 WITH 一起用

前提条件：**WITH 表达式不能在同一个层级，一个层级只允许一个 WITH 表达式**

```sql
localhost:ytt>SELECT * FROM  
    ->   (
    ->     WITH tmp1 (a, b, c) AS 
    ->     (
    ->       VALUES
    ->         ROW (1, 2, 3),
    ->         ROW (3, 4, 5),
    ->         ROW (6, 7, 8)
    ->     ) SELECT  * FROM
    ->         (
    ->           WITH tmp2 (d, e, f) AS (
    ->             VALUES
    ->               ROW (100, 200, 300),
    ->               ROW (400, 500, 600)
    ->             ) TABLE tmp2
    ->         ) X
    ->           JOIN tmp1 Y
    ->   ) Z ORDER BY a;
+-----+-----+-----+---+---+---+
| d   | e   | f   | a | b | c |
+-----+-----+-----+---+---+---+
| 400 | 500 | 600 | 1 | 2 | 3 |
| 100 | 200 | 300 | 1 | 2 | 3 |
| 400 | 500 | 600 | 3 | 4 | 5 |
| 100 | 200 | 300 | 3 | 4 | 5 |
| 400 | 500 | 600 | 6 | 7 | 8 |
| 100 | 200 | 300 | 6 | 7 | 8 |
+-----+-----+-----+---+---+---+
6 rows in set (0.01 sec)
```

## 5. WITH 多个表达式来 JOIN

用上面的例子，改写多个 WITH 为一个 WITH：

```sql
localhost:ytt>WITH 
    -> tmp1 (a, b, c) AS 
    -> (
    -> VALUES
    -> ROW (1, 2, 3),
    -> ROW (3, 4, 5),
    -> ROW (6, 7, 8)
    -> ),
    -> tmp2 (d, e, f) AS (
    ->     VALUES
    ->       ROW (100, 200, 300),
    ->       ROW (400, 500, 600)
    -> )
    -> SELECT * FROM  tmp2,tmp1 ORDER BY a;
+-----+-----+-----+---+---+---+
| d   | e   | f   | a | b | c |
+-----+-----+-----+---+---+---+
| 400 | 500 | 600 | 1 | 2 | 3 |
| 100 | 200 | 300 | 1 | 2 | 3 |
| 400 | 500 | 600 | 3 | 4 | 5 |
| 100 | 200 | 300 | 3 | 4 | 5 |
| 400 | 500 | 600 | 6 | 7 | 8 |
| 100 | 200 | 300 | 6 | 7 | 8 |
+-----+-----+-----+---+---+---+
6 rows in set (0.00 sec)
```

## 6. with 生成日期序列

用 WITH 表达式生成日期序列，类似于 POSTGRESQL 的 generate_series 表函数，比如，从 ‘2020-01-01’ 开始，生成一个月的日期序列：

```sql
localhost:ytt>WITH recursive seq_date (log_date) AS
    ->      (SELECT
    ->        '2020-01-01'
    ->      UNION
    ->      ALL
    ->      SELECT
    ->        log_date + INTERVAL 1 DAY
    ->      FROM
    ->        seq_date
    ->      WHERE log_date + INTERVAL 1 DAY < '2020-02-01')
    ->      SELECT
    ->        log_date
    ->      FROM
    ->        seq_date;
+------------+
| log_date   |
+------------+
| 2020-01-01 |
| 2020-01-02 |
| 2020-01-03 |
| 2020-01-04 |
| 2020-01-05 |
| 2020-01-06 |
| 2020-01-07 |
| 2020-01-08 |
| 2020-01-09 |
| 2020-01-10 |
| 2020-01-11 |
| 2020-01-12 |
| 2020-01-13 |
| 2020-01-14 |
| 2020-01-15 |
| 2020-01-16 |
| 2020-01-17 |
| 2020-01-18 |
| 2020-01-19 |
| 2020-01-20 |
| 2020-01-21 |
| 2020-01-22 |
| 2020-01-23 |
| 2020-01-24 |
| 2020-01-25 |
| 2020-01-26 |
| 2020-01-27 |
| 2020-01-28 |
| 2020-01-29 |
| 2020-01-30 |
| 2020-01-31 |
+------------+
31 rows in set (0.00 sec)
```

## 7. with 表达式做派生表

使用刚才那个日期列表，

```sql
localhost:ytt>SELECT
    ->        *
    ->      FROM
    ->        (
    ->          WITH recursive seq_date (log_date) AS
    ->          (SELECT
    ->            '2020-01-01'
    ->          UNION
    ->          ALL
    ->          SELECT
    ->            log_date + INTERVAL 1 DAY
    ->          FROM
    ->            seq_date
    ->          WHERE log_date+ interval 1 day  < '2020-02-01')
    ->  select * 
    ->          FROM
    ->            seq_date
    ->          ) X
    ->          LIMIT 10;
+------------+
| log_date   |
+------------+
| 2020-01-01 |
| 2020-01-02 |
| 2020-01-03 |
| 2020-01-04 |
| 2020-01-05 |
| 2020-01-06 |
| 2020-01-07 |
| 2020-01-08 |
| 2020-01-09 |
| 2020-01-10 |
+------------+
10 rows in set (0.00 sec)
```

WITH 表达式使用非常灵活，不同的场景可以有不同的写法，的确可以简化日常 SQL 的编写。



# db2使用with案例

## 递归调用查询子公司（union all分隔非递归和递归）

```sql
WITH orgTree(ARCHIVE_FLAG,
              ACCT_PERIOD_NO,
              NODE_ID,
              PARENT_NODE_ID,
              A_NODE_ID
             ) AS (
    SELECT
        ARCHIVE_FLAG,
        ACCT_PERIOD_NO,
        NODE_ID,
        PARENT_NODE_ID,
        'NODE_ID'
    FROM
        IPLATV63.TXSBK01
    WHERE
            NODE_ID = '002'
    UNION ALL
    SELECT
        b.ARCHIVE_FLAG,
        b.ACCT_PERIOD_NO,
        b.NODE_ID,
        b.PARENT_NODE_ID,
        a.NODE_ID
    FROM
        orgTree a,
        IPLATV63.TXSBK01 b
    WHERE
            b.PARENT_NODE_ID = a.NODE_ID)
SELECT DISTINCT
    ARCHIVE_FLAG,
    ACCT_PERIOD_NO,
    NODE_ID,
    PARENT_NODE_ID,
    A_NODE_ID
FROM
    orgTree order by NODE_ID;
```

```sql
ARCHIVE_FLAG|ACCT_PERIOD_NO|NODE_ID|PARENT_NODE_ID|A_NODE_ID
2,202208,002, ,NODE_ID
2,202208,002001,002,002
2,202208,002002,002,002
2,202208,002002001,002002,002002
2,202208,002002001001,002002001,002002001
1,202208,002002001002,002002001,002002001
2,202208,002002002,002002,002002
2,202208,002002002001,002002002,002002002
2,202208,002002002001001,002002002001,002002002001
1,202208,002002002001002,002002002001,002002002001
2,202208,002002002002,002002002,002002002
2,202208,002002002002001,002002002002,002002002002
2,202208,002002002002001001,002002002002001,002002002002001
1,202208,002002002002001002,002002002002001,002002002002001
2,202208,002002002002002,002002002002,002002002002
2,202208,002002002003,002002002,002002002
2,202208,002002002004,002002002,002002002
2,202208,002002002005,002002002,002002002
2,202208,002002002006,002002002,002002002
2,202208,002002002007,002002002,002002002
2,202208,002002002008,002002002,002002002
2,202208,002002002009,002002002,002002002
2,202208,002002002010,002002002,002002002
2,202208,002002002011,002002002,002002002
2,202208,002002002012,002002002,002002002
2,202208,002002002013,002002002,002002002
2,202208,002002002013001,002002002013,002002002013
2,202208,002002002013002,002002002013,002002002013
2,202208,002002002014,002002002,002002002
2,202208,002002002014001,002002002014,002002002014
2,202208,002002002014002,002002002014,002002002014
2,202208,002002002014003,002002002014,002002002014
2,202208,002002002015,002002002,002002002
2,202208,002002002016,002002002,002002002
2,202208,002002003,002002,002002
2,202208,002002004,002002,002002
2,202208,002002004001,002002004,002002004
1,202208,002002004002,002002004,002002004
2,202208,002002005,002002,002002
2,202208,002002005001,002002005,002002005
2,202208,002002005002,002002005,002002005
2,202208,002002005003,002002005,002002005
2,202208,002002005004,002002005,002002005
2,202208,002002005005,002002005,002002005
2,202208,002002005006,002002005,002002005
2,202208,002002005007,002002005,002002005
2,202208,002002005008,002002005,002002005
2,202208,002002005009,002002005,002002005
2,202208,002002005010,002002005,002002005
2,202208,002002005011,002002005,002002005
2,202208,002002005012,002002005,002002005
2,202208,002002005013,002002005,002002005
2,202208,002002005014,002002005,002002005
2,202208,002002005015,002002005,002002005
2,202208,002002005016,002002005,002002005
2,202208,002002005017,002002005,002002005
2,202208,002002005017001,002002005017,002002005017
1,202208,002002005017001001,002002005017001,002002005017001
2,202208,002002005017001002,002002005017001,002002005017001
2,202208,002002005017002,002002005017,002002005017
2,202208,002002005017003,002002005017,002002005017
```

**==db2没有用recursive也递归了，且 b.PARENT_NODE_ID = a.NODE_ID连结条件找到多条时，也每条记录都作为参数再调用了一次递归调用==**，如：结果中的b.PARENT_NODE_ID = a.NODE_ID=002002，找到两条NODE_ID=002002001、002002002

```sql
ARCHIVE_FLAG|ACCT_PERIOD_NO|NODE_ID|PARENT_NODE_ID|A_NODE_ID
2,202208,002002001,002002,002002
2,202208,002002002,002002,002002
```

NODE_ID=002002001、002002002再次作为参数A_NODE_ID=002002001、002002002递归调用查询到该两条记录下的子组织id：

```sql
ARCHIVE_FLAG|ACCT_PERIOD_NO|NODE_ID|PARENT_NODE_ID|A_NODE_ID
2,202208,002002001001,002002001,002002001
1,202208,002002001002,002002001,002002001
2,202208,002002002001,002002002,002002002
```



## 将as里的子查询字段加别名，更换部分字段顺序

```sql
WITH orgTree(ARCHIVE_FLAG,
              ACCT_PERIOD_NO,
              NODE_ID,
              PARENT_NODE_ID,
              A_NODE_ID
             ) AS (
    SELECT
        ARCHIVE_FLAG abz,
        ACCT_PERIOD_NO ads,
        NODE_ID,
        PARENT_NODE_ID,
        'NODE_ID' nodeid
    FROM
        IPLATV63.TXSBK01
    WHERE
            NODE_ID = '002'
    UNION ALL
    SELECT
        b.ACCT_PERIOD_NO ac,
        b.ARCHIVE_FLAG arc,
    
        b.NODE_ID,
        b.PARENT_NODE_ID,
        a.NODE_ID noda
    FROM
        orgTree a,
        IPLATV63.TXSBK01 b
    WHERE
            b.PARENT_NODE_ID = a.NODE_ID)
SELECT DISTINCT
    ARCHIVE_FLAG,
    ACCT_PERIOD_NO,
    NODE_ID,
    PARENT_NODE_ID,
    A_NODE_ID
FROM
    orgTree order by NODE_ID;
```

```sql
ARCHIVE_FLAG|ACCT_PERIOD_NO|NODE_ID|PARENT_NODE_ID|A_NODE_ID
2,202208,002, ,NODE_ID		//此纪录是union all上半部分唯一查询结果，下面都是下半部分的
202208,2,002001,002,002
202208,2,002002,002,002
202208,2,002002001,002002,002002
202208,2,002002001001,002002001,002002001
202208,1,002002001002,002002001,002002001
202208,2,002002002,002002,002002
202208,2,002002002001,002002002,002002002
202208,2,002002002001001,002002002001,002002002001
202208,1,002002002001002,002002002001,002002002001
202208,2,002002002002,002002002,002002002
202208,2,002002002002001,002002002002,002002002002
202208,2,002002002002001001,002002002002001,002002002002001
202208,1,002002002002001002,002002002002001,002002002002001
202208,2,002002002002002,002002002002,002002002002
202208,2,002002002003,002002002,002002002
202208,2,002002002004,002002002,002002002
202208,2,002002002005,002002002,002002002
202208,2,002002002006,002002002,002002002
202208,2,002002002007,002002002,002002002
202208,2,002002002008,002002002,002002002
202208,2,002002002009,002002002,002002002
202208,2,002002002010,002002002,002002002
202208,2,002002002011,002002002,002002002
202208,2,002002002012,002002002,002002002
202208,2,002002002013,002002002,002002002
202208,2,002002002013001,002002002013,002002002013
202208,2,002002002013002,002002002013,002002002013
202208,2,002002002014,002002002,002002002
202208,2,002002002014001,002002002014,002002002014
202208,2,002002002014002,002002002014,002002002014
202208,2,002002002014003,002002002014,002002002014
...
```

```
WITH orgTree(ARCHIVE_FLAG,
              ACCT_PERIOD_NO,
              NODE_ID,
              PARENT_NODE_ID,
              A_NODE_ID
             ) AS (
    SELECT
        ACCT_PERIOD_NO abz,
        ARCHIVE_FLAG ads,
        NODE_ID,
        PARENT_NODE_ID,
        'NODE_ID' nodeid
    FROM
        IPLATV63.TXSBK01
    WHERE
            NODE_ID = '002'
    UNION ALL
    SELECT
        b.ACCT_PERIOD_NO ac,
        b.ARCHIVE_FLAG arc,

        b.NODE_ID,
        b.PARENT_NODE_ID,
        a.NODE_ID noda
    FROM
        orgTree a,
        IPLATV63.TXSBK01 b
    WHERE
            b.PARENT_NODE_ID = a.NODE_ID)
SELECT DISTINCT
    ARCHIVE_FLAG,
    ACCT_PERIOD_NO,
    NODE_ID,
    PARENT_NODE_ID,
    A_NODE_ID
FROM
    orgTree order by NODE_ID;
```

```sql
ARCHIVE_FLAG|ACCT_PERIOD_NO|NODE_ID|PARENT_NODE_ID|A_NODE_ID
202208,2,002, ,NODE_ID		//此纪录是union all上半部分唯一查询结果，下面都是下半部分的
202208,2,002001,002,002
202208,2,002002,002,002
202208,2,002002001,002002,002002
202208,2,002002001001,002002001,002002001
202208,1,002002001002,002002001,002002001
202208,2,002002002,002002,002002
```



## 结论：

子查询中字段加别名没有影响，但是更换下半部分字段顺序结果的字段发生了变化，说明with后生成的临时表字段是按照子查询中字段的顺序一一对应取值的，名称没有影响