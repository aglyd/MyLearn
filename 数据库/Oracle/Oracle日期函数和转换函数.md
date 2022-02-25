# [ORACLE 中如何截取到时间的年月日中的年、月、日](https://www.cnblogs.com/wuxu/p/12870194.html)

在Oracle中，要获得日期中的年份，例如把sysdate中的年份取出来，并不是一件难事。
常用的方法是：Select to_number(to_char(sysdate,'yyyy')) from dual
而实际上，oracle本身有更好的方法，那就是使用Extract函数，使用方法是：Select Extract(year from sysdate) from dual，
这种方法省掉了类型转换，看上去更加简洁。
相应的
取得月份select extract (month from sysdate) from dual
取得日select extract (day from sysdate) from dual



----

# [Oracle to_date()函数的用法介绍](https://www.cnblogs.com/cxxjohnson/p/4824405.html)

to_date()是Oracle数据库函数的代表函数之一，下文对Oracle to_date()函数的几种用法作了详细的介绍说明,需要的朋友可以参考下

在Oracle数据库中，Oracle to_date()函数是我们经常使用的函数，下面就为您详细介绍Oracle to_date()函数的用法，希望可以对您有所启迪。

to_date()与24小时制表示法及mm分钟的显示：

**一、在使用Oracle的to_date函数来做日期转换时，很多Java程序员也许会直接的采用"yyyy-MM-dd HH:mm:ss"的格式作为格式进行转换，但是在Oracle中会引起错误："ORA 01810 格式代码出现两次"。**

select to_date('2005-01-01 13:14:20','yyyy-MM-dd HH24:mm:ss') from dual;

如：
原因是SQL中不区分大小写，MM和mm被认为是相同的格式代码，所以Oracle的SQL采用了mi代替分钟。

select to_date('2005-01-01 13:14:20','yyyy-MM-dd HH24:mi:ss') from dual;

**二、另要以24小时的形式显示出来要用HH24**

select to_char(sysdate,'yyyy-MM-dd HH24:mi:ss') from dual;//mi是分钟
select to_char(sysdate,'yyyy-MM-dd HH24:mm:ss') from dual;//mm会显示月份 

oracle中的to_date参数含义

1.日期格式参数 含义说明 

D 一周中的星期几 
DAY 天的名字，使用空格填充到9个字符 
DD 月中的第几天 
DDD 年中的第几天 
DY 天的简写名 
IW ISO标准的年中的第几周 
IYYY ISO标准的四位年份 
YYYY 四位年份 
YYY,YY,Y 年份的最后三位，两位，一位 
HH 小时，按12小时计 
HH24 小时，按24小时计 
MI 分 
SS 秒 
MM 月 
Mon 月份的简写 
Month 月份的全名 
W 该月的第几个星期 
WW 年中的第几个星期 1.日期时间间隔操作
当前时间减去7分钟的时间
select sysdate,sysdate - interval '7' MINUTE from dual
当前时间减去7小时的时间
select sysdate - interval '7' hour from dual
当前时间减去7天的时间
select sysdate - interval '7' day from dual
当前时间减去7月的时间
select sysdate,sysdate - interval '7' month from dual
当前时间减去7年的时间
select sysdate,sysdate - interval '7' year from dual
时间间隔乘以一个数字
select sysdate,sysdate - 8 *interval '2' hour from dual

2.日期到字符操作

```
select sysdate,to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual   
select sysdate,to_char(sysdate,'yyyy-mm-dd hh:mi:ss') from dual   
select sysdate,to_char(sysdate,'yyyy-ddd hh:mi:ss') from dual   
select sysdate,to_char(sysdate,'yyyy-mm iw-d hh:mi:ss') from dual
```

参考oracle的相关关文档(ORACLE901DOC/SERVER.901/A90125/SQL_ELEMENTS4.HTM#48515)

3. 字符到日期操作

select to_date('2003-10-17 21:15:37','yyyy-mm-dd hh24:mi:ss') from dual

具体用法和上面的to_char差不多。

4. trunk/ ROUND函数的使用

```
select trunc(sysdate ,'YEAR') from dual   
select trunc(sysdate ) from dual   
select to_char(trunc(sysdate ,'YYYY'),'YYYY') from dual
```

5.oracle有毫秒级的数据类型

```
--返回当前时间 年月日小时分秒毫秒  
select to_char(current_timestamp(5),'DD-MON-YYYY HH24:MI:SSxFF') from dual;  
--返回当前 时间的秒毫秒，可以指定秒后面的精度(最大=9)  
select to_char(current_timestamp(9),'MI:SSxFF') from dual;
```

6.计算程序运行的时间(ms)

```sql
declare  
type rc is ref cursor;   
l_rc rc;   
l_dummy all_objects.object_name%type;   
l_start number default dbms_utility.get_time;   
begin  
for I in 1 .. 1000   
loop   
open l_rc for  
'select object_name from all_objects '||   
'where object_id = ' || i;   
fetch l_rc into l_dummy;   
close l_rc;   
end loop;   
dbms_output.put_line   
( round( (dbms_utility.get_time-l_start)/100, 2 ) ||   
' seconds...' );   
end;
```



----



# 三、[Oracle日期函数和转换函数](https://blog.csdn.net/weixin_44563573/article/details/89525979)

## 1、日期函数

日期函数用于处理date类型的数据，两个日期相减返回日期之间相差的天数。日期不允许做加法运算，无意义。
常见代表符号：yyyy 年，mm 月，dd 日，hh 小时，mi 分钟，ss 秒，day 星期
默认情况下日期格式是dd-mon-yy即12-3月-19
（1）sysdate: 该函数返回系统时间
（2）months_between(m,n)日期m和日期n相差多少月数
（3）add_months(d,n)在日期d上增加n个月数
（4）next_day(d, ‘星期*’) 指定日期d下一个星期*对应的日期
（5）last_day(d)：返回指定日期d所在月份的最后一天
（6）extract(month from d)从日期d上提取月份数
（7）round(d,time)日期的四舍五入
（8）trunc(d,time)日期的截断
以下是日期函数的一些例子及效果图：

各种情况	例子	结果
months_between	select months_between(‘01-9月-95’,‘11-1月-94’) from dual;	19.6774193548387
add_months	select add_months(‘11-2月-18’,6) from dual;	2018/8/11
next_day	select next_day(‘11-2月-18’,‘星期六’) from dual;	2018/2/17
last_day	select last_day(‘11-2月-18’) from dual;	2018/2/28
round 四舍五入月份 25-7月-18	select round(to_date(‘25-7月-2018’),‘month’) from dual;	2018/8/1
round 四舍五入年份 25-7月-18	select round(to_date(‘25-7月-2018’),‘year’) from dual;	2019/1/1
trunc 截断月份 25-7月-18	select trunc(to_date(‘25-7月-2018’),‘month’) from dual;	2018/7/1
trunc 截断年份 25-7月-18	select trunc(to_date(‘25-7月-2018’),‘year’) from dual;	2018/1/1

```
eg：查找已经入职8个月多的员工
SQL>

select * from emp
where sysdate>=add_months(hiredate,8);
```

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)

eg：显示满10年服务年限的员工的姓名和受雇日期。
SQL>

```
select ename, hiredate from emp
where sysdate>=add_months(hiredate,12*10);
```



![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)

eg：对于每个员工，显示其加入公司的天数。
SQL> `select floor(sysdate-hiredate),ename from emp;`
![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)
或者
SQL> `select trunc(sysdate-hiredate),ename from emp;` ![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)

eg：找出各月倒数第3天受雇的所有员工。
SQL>

```
 select hiredate,ename from emp
where last_day(hiredate)-2=hiredate;
12
```

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/20190425204626590.png)



## 2、转换函数

转换函数用于将数据类型从一种转为另外一种。在某些情况下，oracle server允许值的数据类型和实际的不一样，这时oracle server会隐含的转化数据类型
我们要说的是尽管oracle可以进行隐含的数据类型的转换，但是它并不适应所有的情况，为了提高程序的可靠性，我们应该使用转换函数进行转换。

### （1）to_char函数

格式: to_char(date,‘format’)
1、必须包含在单引号中而且大小写敏感。
2、可以包含任意的有效的日期格式。
3、日期之间用逗号隔开。
eg：日期是否可以显示 时/分/秒

```
SQL> select ename, to_char(hiredate,'yyyy-mm-dd hh24:mi:ss') from emp; 
```

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)

eg：薪水是否可以显示指定的货币符号
SQL> select sal,to_char(sal,'$999,999.99') from emp; 

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)

yy：两位数字的年份2004–>04
yyyy：四位数字的年份 2004年
mm：两位数字的月份 8月–>08
dd：两位数字的天 30号–>30
hh24： 8点–>20
hh12：8点–>08
mi、ss–>显示分钟/秒
9：显示数字，并忽略前面0
0：显示数字，如位数不足，则用0补齐
.：（小数点）在指定位置显示小数点
,：（千位符）在指定位置显示逗号
$：（美元符）在数字前加美元
L：（本地货币符）在数字前面加本地货币符号
C：（国际货币符)在数字前面加国际货币符号

eg：显示薪水的时候，把本地货币单位加在前面
SQL> select ename, to_char(sal,'L99999.99')from emp; 

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)



eg：显示1980年入职的所有员工
SQL> select * from emp where to_char(hiredate, 'yyyy')=1980;

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/20190425204932399.png)



eg：显示所有12月份入职的员工
SQL> select * from emp where to_char(hiredate, 'mm')=12; 

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)

这里的12和1980是数字，可以加 ’ ’ 也可以不加，因为Oracle会自动转换，但是最好加。
eg：显示姓名、hiredate和雇员开始工作日是星期几
SQL> select ename,hiredate,to_char(hiredate,'day') from emp; 

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDU2MzU3Mw==,size_16,color_FFFFFF,t_70.png)

### （2）to_date函数

格式：to_date(string,‘format’)
函数to_date用于将字符串转换成date类型的数据。
eg：把字符串2015-03-18 13:13:13转换成日期格式，
SQL> select to_date('2015-03-18 13:13:13','yyyy-mm-dd hh24:mi:ss') from dual;

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/20190425205022100.png)

### （3）to_number函数

格式：to_number(char,‘format’)
使用to_number函数将字符转换成日期。
SQL> select to_number('￥1,234,567,890.00','L999,999,999,999.99') from dual;

![在这里插入图片描述](ORACLE 中如何截取到时间的年月日中的年、月、日.assets/20190425205104789.png)