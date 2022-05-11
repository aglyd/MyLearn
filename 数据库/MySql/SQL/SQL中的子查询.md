# [SQL中的子查询](https://www.cnblogs.com/fzxey/p/10896244.html)



> z子查询就是将一个查询（子查询）的结果作为另一个查询（主查询）的数据来源或判断条件的查询。常见的子查询有WHERE子查询，HAVING子查询，FROM子查询，SELECT子查询，EXISTS子查询，子查询要使用小括号（）；

### WHERE子查询

> 在WHERE子句中进行使用查询

```sql
SELECT *
FROM EMP
WHERE SAL < (SELECT AVG(SAL) FROM EMP);
```

- 查询薪资比平均薪资低的员工信息

### HAVING子查询

> HAVING子句是对分组统计函数进行过滤的子句，也可以在HAVING子句中使用子查询

```sql
SELECT JOB,AVG(SAL)
FROM EMP
GROUP BY JOB
HAVING AVG(SAL) = (SELECT MAX(AVG(SAL)) FROM EMP GROUP BY JOB);
```

- 查询平均薪资最高的职位及其平均薪资

### FROM子查询

> FROM子查询就是将一个查询结构（一般多行多列）作为主查询的数据源

```sql
SELECT JOB,AVG(SAL)
FROM (SELECT JOB,AVG(SAL) AS AVGSAL FROM EMP GROUP BY JOB) TEMP
WHERE TEMP.AVGSAL>2000;
```

- 查询平均薪资高于2000的职位以及该职位的平均薪资

### SELECT子查询

> SELECT子查询在SELECT子句中使用查询的结果(一般会和dual空表一起使用)

```sql
SELECT (SELECT COUNT(*) FROM EMP WHERE JOB = 'SALESMAN')/(SELECT COUNT(*) FROM EMP)
FROM DUAL;
```

- 职位是SALESMAN的员工占总员工的比例

### EXISIT子查询

> 将主查询的数据带到子查询中验证，如果成功则返回true，否则发水false。主查询接收true是就会显示这条数据,flase就不会显示。

```sql
SELECT *
FROM EMP E
WHERE EXISIT (
	SELECT *
	FROM DEPT D
	WHERE E.DEPTNO = D.DEPTNO);
```

- 查询有部门的员工信息

### 查询薪资排名的员工信息（面试）

```sql
SELECT *
FROM EMP
WHERE SAL = (SELECT MIN(SAL) 
    		FROM (SELECT ROWNUM,SAL 
          		 FROM (SELECT SAL FROM EMP GROUP BY SAL ORDER BY SAL DESC)
            	 WHERE ROWNUM<=n));
```

- 查询薪资排名第n个员工的信息（包括并列排名）

> 思路：
> 1.先按薪资降序分组
> 2.再取前n名薪资中最低的薪资，即第n名的薪资。
> 3.最后在原表中找出薪资与最低薪资相同的员工信息。



----

# 二、[详解MySQL子查询（嵌套查询）、联结表、组合查询](https://www.jb51.net/article/158459.htm)

## **一、子查询**

MySQL 4.1版本及以上支持子查询

**子查询：**嵌套在其他查询中的查询。

子查询的作用：

### **1、进行过滤：**

实例1：检索订购物品TNT2的所有客户的ID

![img](SQL中的子查询.assets/201903260855159.png) = ![img](SQL中的子查询.assets/2019032608551510.png) + ![img](SQL中的子查询.assets/2019032608551511.png)

一般，在WHERE子句中对于能嵌套的子查询的数目没有限制，不过在实际使用时由于性能的限制，不能嵌套太多的子查询。
注意：列必须匹配 ——在WHERE子句中使用子查询（如这里所示），应该保证SELECT语句具有与WHERE子句中相同数目的列。通常，子查询将返回单个列并且与单个列匹配，但如果需要也可以使用多个列。

示例2:返回订购产品TNT2的客户列表

![img](SQL中的子查询.assets/2019032608551512.png)

该实例更为有效的方法是采用联结进行查询：

![img](SQL中的子查询.assets/2019032608551513.png)

注意：具体关于联结的内容下文会整理到。

### **2、创建计算字段：**

相关子查询：涉及外部查询的子查询。当列名可能有多义性时必须使用该语法。
实例：显示customers 表中每个客户的订单总数

![img](SQL中的子查询.assets/2019032608551514.png)

总结：
子查询最常见的使用是在WHERE子句的IN操作符中，以及用来填充计算列
子查询建立（和测试）查询的最可靠的方法是逐渐进行， 这与MySQL处理它们的方法非常相同。首先，建立和测试最内层的查询。然后，用硬编码数据建立和测试外层查询，并且仅在确认它正常后才嵌入子查询。这时，再次测试它。对于要增加的每个查询，重复这些步骤。这样做仅给构造查询增加了一点点时间，但节省了以后（找出查询为什么不正常）的大量时间，并且极大地提高了查询一开始就正常工作的可能性。

## **二、联结表**

联结表是SQL最强大的功能之一

### **1、一些相关的基础知识储备：**

关系表：保证把信息分解成多个表，一类数据一个表。各表通过某些常用的值（即关系设计中的关系（relational））互相关联。节省时间和存储空间，同时方便数据的修改、更新。因此，关系数据库的可伸缩性远比非关系数据库要好。
可伸缩性(scale)：能够适应不断增加的工作量而不失败。设计良好的数据库或应用程序称之为可伸缩性好。
联结：联结是一种机制，用来在一条SELECT语句中关联表，可以联结多个表返回一组输出。

联结不是物理实体——它在实际的数据库表中不存在。联结由MySQL根据需要建立，它存在于查询的执行当中。
在使用关系表时，仅在关系列中插入合法的数据非常重要。为防止这种情况发生，需要维护引用完整性，它是通过在表的定义中指定主键和外键来实现的。

### **2、基础联结：**

 实例1：

![img](SQL中的子查询.assets/2019032608551515.png)

这两个表用WHERE子句正确联结：WHERE子句指示MySQL匹配vendors表中的vend_id和products表中的vend_id。注意：在引用的列可能出现二义性时，必须使用完全限定列名（用一个点分隔的表名和列名）。
在一条SELECT语句中联结几个表时，相应的关系是在运行中构造的，在数据库表的定义中不存在能指示MySQL如何对表进行联结的东西。在联结两个表时，实际上是将第一个表中的每一行与第二个表中的每一行配对。WHERE子句作为过滤条件，它只包含那些匹配给定条件（这里是联结条件）的行。没有WHERE子句，第一个表中的每个行将与第二个表中的每个行配对，而不管它们逻辑上是否可以配在一起。

笛卡儿积：由没有联结条件的表关系返回的结果。检索出的行的数目将是第一个表中的行数乘以第二个表中的行数。有时也被称为叉联结。

实例2：显示编号为20005的订单中的物品

![img](SQL中的子查询.assets/2019032608551516.png)

应该保证所有联结都有WHERE子句，否则MySQL将返回比想要的数据多得多的数据。
MySQL在运行时关联指定的每个表以处理联结。这种处理可能是非常耗费资源的，因此应该仔细，不要联结不必要的表。联结的表越多，性能下降越厉害。

等值联结：基于两个表之间的相等测试，也被称为内部联结。（最经常使用的联结方式）

实例：

![img](SQL中的子查询.assets/2019032608551517.png)

ANSI SQL规范首选INNER JOIN语法。此外，尽管使用WHERE子句定义联结的确比较简单，但是使用明确的联结语法能够确保不会忘记联结条件，有时候这样做也能影响性能。

### **3、高级联结：**

实例1：给表起别名（同给列起别名用法一样）

![img](SQL中的子查询.assets/2019032608551518.png)

注意：表别名只在查询执行中使用。与列别名不一样，表别名不返回到客户机。

使用表别名的主要原因之一是能在单条SELECT语句中不 止一次引用相同的表
实例2：查询生产ID为DTNTR的物品的供应商生产的其他物品

![img](SQL中的子查询.assets/2019032608551519.png)

上述解决方法为自联结，自联结通常作为外部语句用来替代从相同表中检索数据时使用的子查询语句。该实例也可用子查询来解决。虽然最终的结果是相同的，但有时候处理联结远比处理子查询快得多。在解决问题时，可以试一下两种方法，以确定哪一种的性能更好。

### **自然联结：**排除多次出现，使每个列只返回一次。一般我们用到的内部联结都是自然联结 

实例3：自然联结

![img](SQL中的子查询.assets/2019032608551520.png)

自然联结一般是通过对表使用通配符（SELECT *），对所有其他表的列使用明确的子集来完成的。

### **外部联结：**联结包含了那些在相关表中没有关联行的行。

实例4：检索所有客户，包括那些没有订单的客户

![img](SQL中的子查询.assets/2019032608551521.png)

用法与内部联结相似，使用了关键字OUTER JOIN来指定联结的类型。但是，与内部联结关联两个表中的行不同的是，外部联结还包括没有关联行的行。

存在两种基本的外部联结形式：左外部联结和右外部联结。在使用OUTER JOIN语法时，必须使用RIGHT或LEFT关键字指定包括其所有行的表（RIGHT指出的是OUTER JOIN右边的表，而LEFT 指出的是OUTER JOIN左边的表）。上面的例子使用LEFT OUTER JOIN从FROM 子句的左边表（customers表）中选择所有行。
注意：MySQL不支持简化字符*=和=*的使用，尽管这两种操作符在其他DBMS中很流行。

实例5：检索所有客户及每个客户所下的订单数（包括没有下任何订单的客户

![img](SQL中的子查询.assets/2019032608551522.png)

聚集函数可以方便地与各种联结类型一起使用

使用联结和联结条件：

1.  **注意所使用的联结类型。一般我们使用内部联结，但使用外部联 结也是有效的。**
2.  **保证使用正确的联结条件，否则将返回不正确的数据。**
3.  **应该总是提供联结条件，否则会得出笛卡儿积。**
4.  **在一个联结中可以包含多个表，甚至对于每个联结可以采用不同的联结类型。虽然这样做是合法的，一般也很有用，但应该在一起测试它们前，分别测试每个联结。这将使故障排除更为简单。**

## **三、组合查询**

组合查询：执行多个查询（多条SELECT语句），并将结果作为单个查询结果集返回。这些组合查询通常称为**并(union)或复合查询**。

为何需要组合查询？

1. **在单个查询中从不同的表返回类似结构的数据；**
2. **对单个表执行多个查询，按单个查询返回数据；**
3. **使用组合查询可极大地简化复杂的WHERE子句，简化从多个表中检索数据的工作。**

### **1、创建组合查询**

关键字：UNION操作符

实例1：得到价格小于等于5的所有物品的一个列表，并且包括供应商1001和1002生产的所有物品（不考虑价格）。

![img](SQL中的子查询.assets/2019032608551523.png)



UNION指示MySQL执行两条SELECT语句，**并把输出组合成单个查询结果集**。该解法与where prod_price<=5 OR vend_id in(1001,1002);等效
使用并时需要注意的规则：

1.  **UNION必须由两条或两条以上的SELECT语句组成，语句之间用关键字UNION分隔（因此，如果组合4条SELECT语句，将要使用3个UNION关键字）。**
2.  **UNION中的每个查询必须包含相同的列、表达式或聚集函数（不过各个列不需要以相同的次序列出）。**
3.  **列数据类型必须兼容：类型不必完全相同，但必须是DBMS可以隐含地转换的类型（例如，不同的数值类型或不同的日期类型）**
4.  **使用UNION的组合查询可以应用不同的表**

在一些简单的例子中，使用UNION可能比使用WHERE子句更为复杂。 但对于更复杂的过滤条件，或者从多个表（而不是单个表）中检索数据的情形，使用UNION可能会使处理更简单。
**UNION默认从查询结果集中自动去除重复的行，如果 想返回所有匹配行，可使用UNION ALL而不实UNION。**

注意：**UNION几乎总是完成与多个WHERE(OR)条件相同的工作。UNION ALL为UNION的一种形式，它完成WHERE子句完成不了的工作。如果确实需要每个条件的匹配行全部出现（包括重复行），则必须使用UNION ALL而不是WHERE**

实例2：对组合查询结果排序

![img](SQL中的子查询.assets/2019032608551524.png)

在用UNION组合查询时，**只能使用一条ORDER BY子句，它必须出现在最后一条SELECT语句之后**。对于结果集，不存在用一种方式排序一部分，而又用另一种方式排序另一部分的情况，因此不允许使用多条ORDER BY子句。**该ORDER BY子句对所有SELECT语句返回的所有结果进行排序。**



-----

# 三、[子查询（7种类型）](https://blog.csdn.net/qq_39380737/article/details/81127497)

## where型子查询：

查出每个栏目最新的商品(以good_id为最大为最新商品)：
goods货物表，good_id表的主键,cat_id栏目的编号

```
select cat_id,good_id,good_name from goods where good_id in(selct max(good_id) from goods group by cat_id);
```

## form型子查询：

查出每个栏目最新的商品(以good_id为最大为最新商品)：

```
select * from (select cat_id,good_id,good_name from goods order by cat_id asc, good_id desc) as tep group by cat_id;
```

## from和where型综合练习：

查出挂科2门及以上同学的平均分：

![20180720142006199](SQL中的子查询.assets/20180720142006199.png)

思路讲解：

```sql
-- 1.先求出挂科两门以上及两门的同学
-- select name,count(*) as gk from stu where score<60 group by name having gk>=2;
-- 2.去除多余的一行
-- select name from (select name,count(*) as gk from stu where score<60 group by name having gk>=2)as tmp;
--3.最终结果
select name ,avg(score) as '平均分' from stu where name in(select name from (select name,count(*) as gk from stu where score<60 group by name having gk>=2)as tmp)
group by name;
```

查询结果：

![20180720144111776](SQL中的子查询.assets/20180720144111776.png)

其余5种：
department表：

![3](SQL中的子查询.assets/3.png)

employee表：



## in子查询：查询年龄为20岁的员工部门

```sql
 select * from department where did in(SELECT did from employee where age=20);
```



## exists子查询:

查询是否存在年龄大于21岁的员工

```sql
select * from department where EXISTS (SELECT did from employee where age>21);
```



## any子查询：

查询满足条件的部门

```sql
select * from department where did> any (SELECT did from employee );
```



## all子查询：

查询满足条件的部门

```sql
select * from department where did> all(SELECT did from employee );
```



## 比较运算符子查询：

查询赵四是哪个部门的

```sql
select * from department where did= all(SELECT did from employee where name='赵四'); 
```



## 总结：

  **where型子查询：**指把内部查询的结果作为外层查询的比较条件。
  **from型子查询：**把内层的查询结果当成临时表，供外层sql再次查询。
  **in子查询：**内层查询语句仅返回一个数据列，这个数据列的值将供外层查询语句进行比较。
  **exists子查询：**把外层的查询结果，拿到内层，看内层是否成立，简单来说后面的返回true,外层（也就是前面的语句）才会执行，否则不执行。
  **any子查询：**只要满足内层子查询中的**任意一个比较条件**，就返回一个结果作为外层查询条件。
  **all子查询**：内层子查询返回的结果需同时**满足所有内层查询条件**。
  **比较运算符子查询：**子查询中可以使用的比较运算符如 “>” “<” “= ” “!=”

