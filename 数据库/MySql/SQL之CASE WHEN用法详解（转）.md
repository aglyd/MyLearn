# [SQL之CASE WHEN用法详解（转）](https://www.cnblogs.com/lsgsanxiao/p/10897613.html)

当我们需要从数据源上 直接判断数据显示代表的含义的时候 ,就可以在SQL语句中使用 Case When这个函数了.

Case具有两种格式。简单Case函数和Case搜索函数。

------

 第一种 格式 : 简单Case函数 :

格式说明   

　　　　case 列名

　　　　when  条件值1  then  选择项1

　　　　when  条件值2   then  选项2.......

　　　　else   默认值    end

eg:

　　　　select
　　　　case 　　job_level
　　　　when   '1'   then   '1111'
　　　　when　  '2'   then   '1111'
　　　　when　  '3'   then   '1111'
　　　　else    'eee' end
　　　　from   dbo.employee

------

 第二种  格式 :Case搜索函数

格式说明   

　　　　case  

　　　　when  列名= 条件值1  then  选择项1

　　　　when  列名=条件值2   then  选项2.......

　　　　else   默认值 end

eg:

　　　　update  employee
　　　　set     e_wage =
　　　　case
　　　　when  job_level = '1'   then e_wage*1.97
　　　　when  job_level = '2'  then e_wage*1.07
　　　　when  job_level = '3'  then e_wage*1.06
　　　　else   e_wage*1.05
　　　　end

------

提示:通常我们在写Case When的语句的时候,会容易忘记 end 这个结束,一定要记得哟!

比较: 两种格式，可以实现相同的功能。

 　　简单Case函数的写法相对比较简洁，但是和Case搜索函数相比，功能方面会有些限制，比如写判断式。还有一个需要注意的问题，Case函数只返回第一个符合条件的   值，剩下的Case部分将会被自动忽略。



-----



# [SQL之CASE WHEN用法详解][https://blog.csdn.net/rongtaoup/article/details/82183743]

简单CASE WHEN函数：

```
CASE SCORE WHEN 'A' THEN '优' ELSE '不及格' END
CASE SCORE WHEN 'B' THEN '良' ELSE '不及格' END
CASE SCORE WHEN 'C' THEN '中' ELSE '不及格' END
```

 等同于，使用CASE WHEN条件表达式函数实现：

```
CASE WHEN SCORE = 'A' THEN '优'
     WHEN SCORE = 'B' THEN '良'
     WHEN SCORE = 'C' THEN '中' ELSE '不及格' END
```

 **THEN后边的值与ELSE后边的值类型应一致，否则会报错。如下：**

```
CASE SCORE WHEN 'A' THEN '优' ELSE 0 END
```

'优'和0数据类型不一致则报错： 

**[Err] ORA-00932: 数据类型不一致: 应为 CHAR, 但却获得 NUMBER**

简单CASE WHEN函数只能应对一些简单的业务场景，而CASE WHEN条件表达式的写法则更加灵活。

CASE WHEN条件表达式函数：类似JAVA中的IF ELSE语句。

格式：

```
CASE WHEN condition THEN result

[WHEN...THEN...]

ELSE result

END
```

condition是一个返回布尔类型的表达式，如果表达式返回true，则整个函数返回相应result的值，如果表达式皆为false，则返回ElSE后result的值，**如果省略了ELSE子句，则返回NULL。**

下面介绍几种常用场景。

> ==场景1：有分数score，score<60返回不及格，score>=60返回及格，score>=80返回优秀==



```
SELECT
    STUDENT_NAME,
    (CASE WHEN score < 60 THEN '不及格'
        WHEN score >= 60 AND score < 80 THEN '及格'
        WHEN score >= 80 THEN '优秀'
        ELSE '异常' END) AS REMARK
FROM
    TABLE
```

 注意：如果你想判断score是否null的情况，WHEN score = null THEN '缺席考试'，这是一种错误的写法，正确的写法应为：

```
CASE WHEN score IS NULL THEN '缺席考试' ELSE '正常' END
```



> ==场景2：现老师要统计班中，有多少男同学，多少女同学，并统计男同学中有几人及格，女同学中有几人及格，要求用一个SQL输出结果。==

表结构如下：其中STU_SEX字段，0表示男生，1表示女生。

| STU_CODE | STU_NAME | STU_SEX | STU_SCORE |
| :------- | :------- | :------ | :-------- |
| XM       | 小明     | 0       | 88        |
| XL       | 小磊     | 0       | 55        |
| XF       | 小峰     | 0       | 45        |
| XH       | 小红     | 1       | 66        |
| XN       | 晓妮     | 1       | 77        |
| XY       | 小伊     | 1       | 99        |

```
SELECT 
	SUM (CASE WHEN STU_SEX = 0 THEN 1 ELSE 0 END) AS MALE_COUNT,
	SUM (CASE WHEN STU_SEX = 1 THEN 1 ELSE 0 END) AS FEMALE_COUNT,
	SUM (CASE WHEN STU_SCORE >= 60 AND STU_SEX = 0 THEN 1 ELSE 0 END) AS MALE_PASS,
	SUM (CASE WHEN STU_SCORE >= 60 AND STU_SEX = 1 THEN 1 ELSE 0 END) AS FEMALE_PASS
FROM 
	THTF_STUDENTS
```

输出结果如下：

```
MALE_COUNT	FEMALE_COUNT	MALE_PASS	FEMALE_PASS
3	3	1	3
```



> ==场景3：经典行转列，并配合聚合函数做统计==

#42a5f5

现要求统计各个城市，总共使用了多少水耗、电耗、热耗，使用一条SQL语句输出结果

有能耗表如下：其中，E_TYPE表示能耗类型，0表示水耗，1表示电耗，2表示热耗

| E_CODE | E_VALUE | E_TYPE |
| :----- | :------ | :----- |
| 北京   | 28.50   | 0      |
| 北京   | 23.51   | 1      |
| 北京   | 28.12   | 2      |
| 北京   | 12.30   | 0      |
| 北京   | 15.46   | 1      |
| 上海   | 18.88   | 0      |
| 上海   | 16.66   | 1      |
| 上海   | 19.99   | 0      |
| 上海   | 10.05   | 0      |

```
SELECT 
	E_CODE,
	SUM(CASE WHEN E_TYPE = 0 THEN E_VALUE ELSE 0 END) AS WATER_ENERGY,--水耗
	SUM(CASE WHEN E_TYPE = 1 THEN E_VALUE ELSE 0 END) AS ELE_ENERGY,--电耗
	SUM(CASE WHEN E_TYPE = 2 THEN E_VALUE ELSE 0 END) AS HEAT_ENERGY--热耗
FROM 
	THTF_ENERGY_TEST
GROUP BY
	E_CODE
```

 输出结果如下：

```
E_CODE	WATER_ENERGY	ELE_ENERGY	HEAT_ENERGY
北京	40.80	38.97	28.12
上海	48.92	16.66	0
```



> ==场景4：====CASE WHEN中使用子查询==

根据城市用电量多少，计算用电成本。假设电能耗单价分为三档，根据不同的能耗值，使用相应价格计算成本。

 价格表如下：

| P_PRICE | P_LEVEL | P_LIMIT |
| :------ | :------ | :------ |
| 1.20    | 0       | 10      |
| 1.70    | 1       | 30      |
| 2.50    | 2       | 50      |

当能耗值小于10时，使用P_LEVEL=0时的P_PRICE的值，能耗值大于10小于30使用P_LEVEL=1时的P_PRICE的值...

```
CASE WHEN energy <= (SELECT P_LIMIT FROM TABLE_PRICE WHERE P_LEVEL = 0) THEN (SELECT P_PRICE FROM TABLE_PRICE WHERE P_LEVEL = 0)
    WHEN energy > (SELECT P_LIMIT FROM TABLE_PRICE WHERE P_LEVEL = 0) AND energy <= (SELECT P_LIMIT FROM TABLE_PRICE WHERE P_LEVEL = 1) THEN (SELECT P_PRICE FROM TABLE_PRICE WHERE P_LEVEL = 1)
    WHEN energy > (SELECT P_LIMIT FROM TABLE_PRICE WHERE P_LEVEL = 1) AND energy <= (SELECT P_LIMIT FROM TABLE_PRICE WHERE P_LEVEL = 2) THEN (SELECT P_PRICE FROM TABLE_PRICE WHERE P_LEVEL = 2)
```



> ==场景5：结合max聚合函数==



![img](SQL之CASE WHEN用法详解（转）.assets/20181106153915152.png)

![img](SQL之CASE WHEN用法详解（转）.assets/20181106153952438.png)

CASE WHEN 函数使用起来简单易懂，此篇文章只作了简单的使用介绍，还需在实际工作中根据业务场景不同来灵活使用。