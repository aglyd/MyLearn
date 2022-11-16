# DB2分页

## DB2查看系统版本

命令：

SQL语句查看:

`SELECT SERVICE_LEVEL FROM SYSIBMADM.ENV_INST_INFO`

命令查看:

```
用db2level查看

用db2licm-l查看
```

连接数据库套看：

```
db2 connect to db_name

Database server = DB2/6000 7.2.0(这里就是版本号)

SQL authorization ID = username

Local database alias = db_name
```

## db2使用limit报错

db2查询分页的方法：

`select * from sname.usertable fetch first 10 rows only`

> db2使用fetch first 10 rows only返回前10行数据；
> mysql使用limit 10 offset 0（=limit 0,10）返回前10行数据；
> oracle使用rownum>0 and rownum<=10返回前10行数据。

DB2 for Linux Unix Windows(LUW)和DB2 for iSeries是不同的产品.可能,DB2 for iSeries不支持DB2_COMPATIBILITY_VECTOR.我无法在iSeries信息中心找到它.

您可以使用FETCH FIRST 10 ROWS ONLY子句代替LIMIT.

**您应该能够使用带有[ROW_NUMBER olap函数](http://publib.boulder.ibm.com/infocenter/iseries/v5r4/index.jsp?topic=/sqlp/rbafyolap.htm)的子选择,而不是LIMIT和OFFSET**

**==row_number() OVER (PARTITION BY COL1 ORDER BY COL2 DESC) 表示根据COL1分组，在分组内部根据 COL2排序，而此函数计算的值就表示每组内部排序后的顺序编号（组内连续的唯一的)==**

使用案例：

offset：20
limit：20

```sql
--分页查询，方法一
select * from ( select ROW_NUMBER() OVER() as rownum_ , emp.* from
( SELECT * FROM BWQX.STC_YEAR_PLAN_FINANCIAL_INSTITUTION  order by PLAN_ID) emp
    ) as temp
where rownum_ <= 10 and rownum_ > 0;

--分页查询，方法二
select emp.* from (
select row_number() over (order by PLAN_ID) as rownum_,PLAN_ID,FINANCIAL_INSTITUTION_CODE
from BWQX.STC_YEAR_PLAN_FINANCIAL_INSTITUTION) emp
where rownum_ <= 10 and rownum_ > 0;
--order by放后面效果相同
select emp.* from (
select row_number() over () as rownum_,PLAN_ID,FINANCIAL_INSTITUTION_CODE
from BWQX.STC_YEAR_PLAN_FINANCIAL_INSTITUTION order by PLAN_ID) emp
where rownum_ <= 10 and rownum_ > 0;

--直接第一次查就加上分页条件会找不到排序字段rownum_，因为这个字段只有在第一次查询出来结果之后才会生成，所有要嵌套在子查询中
select row_number() over (order by PLAN_ID) as rownum_,PLAN_ID,FINANCIAL_INSTITUTION_CODE
from BWQX.STC_YEAR_PLAN_FINANCIAL_INSTITUTION
    where PLAN_ID <= '10' and rownum_ > 0 ;
```

```sql
--按照FINANCIAL_INSTITUTION_CODE分组，每组内部按照PLAN_ID重新从1开始排序（组内连续的唯一的)，选取每组中的前5条
select emp.* from (
select row_number() over (partition by FINANCIAL_INSTITUTION_CODE order by PLAN_ID) as rownum_,PLAN_ID,FINANCIAL_INSTITUTION_CODE
from BWQX.STC_YEAR_PLAN_FINANCIAL_INSTITUTION) emp
where rownum_ <= 5 and rownum_ > 0;
```

结果集：

```
rownum_,PLAN_ID,FINANCIAL_INSTITUTION_CODE
1,0001,1
2,1e8a7a1f-9ec7-4863-ae4f-6675c05dc1bf,1
3,26189926-71f4-46b0-be3e-324f9f4c7a8f,1
4,3cf792ef-2c9c-4ba8-80c6-b5b7bc2efd68,1
5,5a6b9944-ade8-4bcb-8552-8368db35ee80,1
1,91fb1d92-884d-4333-aa63-80e632c7e916,10
2,d919cb2b-82e9-4d55-b007-802090b94ef4,10
1,0001,2
2,1f1b380c-2799-4c5a-a892-9f0be09a1066,2
3,3cf792ef-2c9c-4ba8-80c6-b5b7bc2efd68,2
4,5a6b9944-ade8-4bcb-8552-8368db35ee80,2
5,d919cb2b-82e9-4d55-b007-802090b94ef4,2
1,0001,3
2,5a6b9944-ade8-4bcb-8552-8368db35ee80,3
1,fab5c3af-e9b4-49e1-b5c4-4164eceba44b,4
1,91fb1d92-884d-4333-aa63-80e632c7e916,8
1,26189926-71f4-46b0-be3e-324f9f4c7a8f,9
2,f23bef79-4f30-492e-bcdf-3c38c7c3abda,9
```



```sql
平台自动生成的sql
select * from ( select ROW_NUMBER() OVER() as rownum_ , row_.* from
( SELECT * FROM BWQX.STC_YEAR_PLAN_FINANCIAL_INSTITUTION  order by PLAN_ID
fetch first 20 rows only ) row_ ) as temp
where rownum_ <= 10 and rownum_ > 0
```



从IBM i 7.1 TR11或IBM i 7.2 TR3开始,现在支持使用`LIMIT`/的普通现代分页`OFFSET`:

ps：但是10版本验证无法使用，不知是否为版本或其他问题导致



# [DB2sql——fetch first n rows only](https://blog.csdn.net/weixin_30672295/article/details/99596455)

在db2中如果想获取前n行，只要加上fetch first n [rows](https://so.csdn.net/so/search?q=rows&spm=1001.2101.3001.7020) only 就可以了，但在oracle中没有fetch，网上很多人说可以用oracle的rownum<=n来替代db2的fetch first n rows only，但这样的替换，在对结果集需要进行order by之后再获取前n行时，是不对的。根据我的试验，rownum的顺序好像是和rowid相对应的，而rowid的顺序是根据插入表中的数据的顺序有关（不知道oracle真正的实现机制是不是这样，有时间找本oracle的书系统研究一下）。看下面oracle中的实例：

SQL>select rownum,id,age,name from loaddata;
     ROWNUM ID     AGE NAME
     ------- ------ --- ------
         1 200001 22   AAA
         2 200002 22   BBB
         3 200003 22   CCC
         4 200004 22 DDD
         5 200005 22   EEE
         6 200006 22   AAA

SQL>select rownum ,id,age,name from loaddata order by name;
     ROWNUM ID     AGE NAME
     ------- ------ --- ------
         1 200001 22   AAA
         6 200006 22   AAA
         2 200002 22   BBB
         3 200003 22   CCC
         4 200004 22   DDD
         5 200005 22   EEE

​    所以，要是想排序后在取前几行，可以用子查询select rownum ,id,age,name from (select * from loaddata order by name);

​    但我觉得既然要使用子查询，与其使用oracle的特定函数rownum，倒还不如使用标准sql的函数**row_number() over ()**。可以这样写select id,age,name from (select row_number() over (order by name) as row_number,id,age,name from loaddata ) where row_number<n; 这样的话就**不用考虑是在db2还是oracle下了，都一样用**