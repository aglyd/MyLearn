# 一、[一张图告诉你SQL使用inner join，left join 等][https://blog.csdn.net/weixin_41796956/article/details/85044152]

## sql之left join、right join、inner join的区别

union、union all的区别跳转https://www.cnblogs.com/logon/p/3748020.html

SQL JOINS:

![img](https://img-blog.csdnimg.cn/img_convert/2a8f7e3f91d87f79009057f0a51a87e2.png)

 

Please refer the link : **https://www.codeproject.com/Articles/33052/Visual-Representation-of-SQL-Joins** 

 

如图：

![img](https://img-blog.csdnimg.cn/img_convert/86fb7a17f75ec38dd61f65ef2d542de5.png)

left join(左联接) 返回包括==左表中的所有记录和右表中联结字段相等==的记录 ，on后的条件只对右表记录生效
right join(右联接) 返回包括==右表中的所有记录和左表中联结字段相等==的记录，on后的条件只对左表记录生效
inner join(等值连接) 只返回==两个表中联结字段相等==的行，on后的条件对所有记录生效

举例如下： 
\--------------------------------------------
表A记录如下：
aID　　　　　aNum
1　　　　　a20050111
2　　　　　a20050112
3　　　　　a20050113
4　　　　　a20050114
5　　　　　a20050115

表B记录如下:
bID　　　　　bName
1　　　　　2006032401
2　　　　　2006032402
3　　　　　2006032403
4　　　　　2006032404
8　　　　　2006032408

\--------------------------------------------

### 1.left join

sql语句如下: 
select * from A
left join B 
on A.aID = B.bID

结果如下:
aID　　　　　aNum　　　　　bID　　　　　bName
1　　　　　a20050111　　　　1　　　　　2006032401
2　　　　　a20050112　　　　2　　　　　2006032402
3　　　　　a20050113　　　　3　　　　　2006032403
4　　　　　a20050114　　　　4　　　　　2006032404
5　　　　　a20050115　　　　NULL　　　　　NULL

（所影响的行数为 5 行）
结果说明:
left join是以A表的记录为基础的,A可以看成左表,B可以看成右表,left join是以左表为准的.
换句话说,左表(A)的记录将会全部表示出来,而右表(B)只会显示符合搜索条件的记录(例子中为: A.aID = B.bID).
B表记录不足的地方均为NULL.
\--------------------------------------------

### 2.right join

sql语句如下: 
select * from A
right join B 
on A.aID = B.bID

结果如下:
aID　　　　　aNum　　　　　bID　　　　　bName
1　　　　　a20050111　　　　1　　　　　2006032401
2　　　　　a20050112　　　　2　　　　　2006032402
3　　　　　a20050113　　　　3　　　　　2006032403
4　　　　　a20050114　　　　4　　　　　2006032404
NULL　　　　　NULL　　　　　8　　　　　2006032408

（所影响的行数为 5 行）
结果说明:
仔细观察一下,就会发现,和left join的结果刚好相反,这次是以右表(B)为基础的,A表不足的地方用NULL填充.
\--------------------------------------------

### 3.inner join

sql语句如下: 
select * from A
innerjoin B 
on A.aID = B.bID

结果如下:
aID　　　　　aNum　　　　　bID　　　　　bName
1　　　　　a20050111　　　　1　　　　　2006032401
2　　　　　a20050112　　　　2　　　　　2006032402
3　　　　　a20050113　　　　3　　　　　2006032403
4　　　　　a20050114　　　　4　　　　　2006032404

结果说明:
很明显,这里只显示出了 A.aID = B.bID的记录.这说明inner join并不以谁为基础,它只显示符合条件的记录.
\--------------------------------------------
注: 
LEFT JOIN操作用于在任何的 FROM 子句中，组合来源表的记录。使用 LEFT JOIN 运算来创建一个左边外部联接。左边外部联接将包含了从第一个（左边）开始的两个表中的全部记录，即使在第二个（右边）表中并没有相符值的记录。



----

# 二、[SQL中JOIN的几种常见用法](https://www.cnblogs.com/qunyang/archive/2012/08/27/2658507.html)

先假设有表a、b如下：

​      **表****a**                               **表****b**

**----------------------           --------------------------------**

| symbol | sname |         |  symbol | tdate | tclose |

--------------------------         -------------------------------------

|    A   |   B   |         |    A   |   C  |   D   |

|    G   |   H   |         |    X   |   E  |   F   |

--------------------------         ------------------------------------

 

## **内联接：**

### inner join

内连接，又叫等值连接，只返回两个表中连接字段相等的行。

SELECT a.symbol , a.sname , b.tdate , b.tclose

FROM a

   (INNER) JOIN b

   ON a.symbol = b.symbol

**==其中INNER关键字可以省略==**。

如：

SELECT a.symbol , a.sname , b.tdate , b.tclose

FROM a

   JOIN b

   ON a.symbol = b.symbol

此语句只有在表a和b中都有匹配行时，才返回。

所以本例中返回结果为：

​      **symbol  sname  tdate  tclose**

​        A     B     C     D    --这一行即满足a.symbol = b.symbol

 

 

## **外联接：**

SELECT a.symbol , a.sname , b.tdate , b.tclose

FROM a

   RIGHT | LEFT | FULL (OUTER) JOIN b

   ON a.symbol = b.symbol

**==其中OUTER关键词可以省略==**。

如：SELECT a.symbol , a.sname , b.tdate , b.tclose

FROM a

   RIGHT  JOIN b

   ON a.symbol = b.symbol

### **RIGHT JOIN**：

 右连接，返回右表中所有的记录以及左表中连接字段相等的记录。当右表格（即表b）中的行在左表中没有匹配行时，也返回。返回的记录中，选择的左表的列的内容为NULL。

  所以本例中返回结果为：

​     **symbol  sname  tdate  tclose**

​        A     B     C     D    --这一行即满足a.symbol = b.symbol

​       null    null     E     F    --这一行里，对应的b.symbol没有在表a中找到相同的a.symbol

 

### **LEFT JOIN**：

左连接，返回左表中所有的记录以及右表中连接字段相等的记录。当左表格（即表a）中的行在右表中没有匹配行时，也返回。返回的记录中，选择的右表的列的内容为NULL。

  所以本例中返回结果为：

​     **symbol  sname  tdate  tclose**

​        A     B     C    D    --这一行即满足a.symbol = b.symbol

​        G     H     null  null    --这一行里，对应的a.symbol没有在表b中找到相同的b.symbol

 

### **FULL JOIN**：

 外连接，返回两个表中的行：left join + right join。可以把它理解为LFET和RIGHT的集合，某表中某一行在另一表中无匹配行，则相应列的内容为NULL。

  所以本例中返回结果为：

​     **symbol  sname  tdate  tclose**

​        A     B     C    D    --这一行即满足a.symbol = b.symbol

​        G     H     null  null    --这一行里，对应的a.symbol没有在表b中找到相同的b.symbol

​       null    null     E     F    --这一行里，对应的b.symbol没有在表a中找到相同的a.symbol

​        A     B     C    D    --这一行即满足a.symbol = b.symbol



## **交叉联接：**

SELECT a.*,b.*

FROM a

   CROSS JOIN b

交叉联接返回左表中的所有行，左表中的每一行与右表中的所有行组合。交叉联接也称作笛卡尔积。

也就是相当于两个表中的所有行进行排列组合。

若表a有X行，表b有Y行，则将返回XY行记录。

  所以本例中返回结果为：

​     **symbol  sname  tdate  tclose**

​        A     B     C    D

​        G     H     C    D

​        A     B     E    F

​        G     H     E    F



----

# 三、[SQL JOIN 中 on 与 where 的区别](https://www.runoob.com/w3cnote/sql-join-the-different-of-on-and-where.html)

![img](SQL内、外连接查询详解.assets/1528881587-3295-201505.png)

- **left join** : 左连接，返回左表中所有的记录以及右表中连接字段相等的记录。
- **right join** : 右连接，返回右表中所有的记录以及左表中连接字段相等的记录。
- **inner join** : 内连接，又叫等值连接，只返回两个表中连接字段相等的行。
- **full join** : 外连接，返回两个表中的行：left join + right join。
- **cross join** : 结果是笛卡尔积，就是第一个表的行数乘以第二个表的行数。

### 关键字 on

数据库在通过连接两张或多张表来返回记录时，都会生成一张中间的临时表，然后再将这张临时表返回给用户。

在使用 **left jion** 时，**on** 和 **where** 条件的区别如下：

- 1、 **on** 条件是在生成临时表时使用的条件，它不管 **on** 中的条件是否为真，都会返回左边表中的记录。
- 2、**where** 条件是在临时表生成好后，再对临时表进行过滤的条件。这时已经没有 **left join** 的含义（必须返回左边表的记录）了，条件不为真的就全部过滤掉。

假设有两张表：

**表1：tab1**

| id   | size |
| ---- | ---- |
| 1    | 10   |
| 2    | 20   |
| 3    | 30   |

**表2：tab2**

| size | name |
| ---- | ---- |
| 10   | AAA  |
| 20   | BBB  |
| 20   | CCC  |

两条 SQL:

```sql
select * from tab1 left join tab2 on (tab1.size = tab2.size) where tab2.name='AAA'

select * from tab1 left join tab2 on (tab1.size = tab2.size and tab2.name='AAA')
```

```sql
第一条SQL的过程：

1、中间表
on条件:
tab1.size = tab2.size	
tab1.id	tab1.size	tab2.size	tab2.name
1	10	10	AAA
2	20	20	BBB
2	20	20	CCC
3	30	(null)	(null)
 
 	 
2、再对中间表过滤
where 条件：
tab2.name='AAA'	
tab1.id	tab1.size	tab2.size	tab2.name
1	10	10	AAA
 
 

第二条SQL的过程：
 
1、中间表
on条件:
tab1.size = tab2.size and tab2.name='AAA'
(条件不为真也会返回左表中的记录)	
tab1.id	tab1.size	tab2.size	tab2.name
1	10	10	AAA
2	20	(null)	(null)
3	30	(null)	(null)
 
```

其实以上结果的关键原因就是 **left join、right join、full join** 的特殊性，不管 **on** 上的条件是否为真都会返回 **left** 或 **right** 表中的记录，**full** 则具有 **left** 和 **right** 的特性的并集。 而 **inner jion** 没这个特殊性，则条件放在 **on** 中和 **where** 中，返回的结果集是相同的。



----

# 四、[Oracle LEFT JOIN中ON条件与WHERE条件的区别](https://blog.csdn.net/aqszhuaihuai/article/details/6238416)

Oracle LEFT JOIN中ON条件与WHERE条件的区别

JOIN中的ON条件与WHERE条件是一样的,而LEFT JOIN却不一样

SQL> create table t1 as select * from scott.emp;

 

表已创建。

 

SQL> create table t2 as select * from scott.dept;

 

表已创建。

 

SQL> delete t2 where deptno=30;

 

已删除 1行。

 

以下为使用where的查询结果与执行计划



![img](http://hi.csdn.net/attachment/201103/10/0_1299762687Z9zb.gif)

以下为使用on条件的查询结果与执行计划

![img](http://hi.csdn.net/attachment/201103/10/0_1299762743n49P.gif)

 

 oracle 对谓词and t1.job='CLERK'（on 后面的）,where t1.job='CLERK'的解析是不一样的。

使用where t1.job='CLERK':

1 - access("T1"."DEPTNO"="T2"."DEPTNO"(+))
2 - filter("T1"."JOB"='CLERK')

Oracle 先根据"T1"."JOB"='CLERK'对T1表进行过滤，然后与T2表进行左外连接

 

Oracle解析的谓词and t1.job='CLERK'（on 后面的）为：

1 - access("T1"."DEPTNO"="T2"."DEPTNO"(+) AND "T1"."JOB"=CASE  WHEN
           ("T2"."DEPTNO"(+) IS NOT NULL) THEN 'CLERK' ELSE 'CLERK' END )

代表什么意思呢？

oracle 对t1,t2进行全表扫描，之后进行左外连接（也可能是在扫描过程中进行连接），而and t1.job='CLERK'对连接之后的记录总数没有影响，只是对不符合and t1.job='CLERK'的记录中的部门名称置为空



**当on中对左表的非连接字段限制时 与 对右表的非连接字段限制时 是两种不同的情况，请注意。**

当on中对右表的非连接字段限制时(on (tab1.size1= tab2.size1 and tab2.name='AAA')) 相当于右表根据非连接字段限制获取结果，然后左表再与它关联。
select tab1.*,tab2.* from tab1 left join tab2 on (tab1.size1= tab2.size1 and tab2.name='AAA');
相当于
select tab1.*,t.* from tab1 left join (select * from tab2 where tab2.name='AAA') t on (tab1.size1= t.size1);