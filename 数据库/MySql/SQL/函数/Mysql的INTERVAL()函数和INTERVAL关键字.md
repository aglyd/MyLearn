# [Mysql的INTERVAL()函数和INTERVAL关键字](https://blog.csdn.net/lkforce/article/details/109537645)

### 一，INTERVAL()函数

INTERVAL()函数可以返回分段后的结果，语法如下：

**INTERVAL(N,N1,N2,N3,..........)**

其中，N是要判断的数值，N1,N2,N3,...是分段的间隔。

这个函数的返回值是段的位置：

如果N<N1，则返回0，

如果N1<=N<N2，则返回1，

如果N2<=N<N3，则返回2。

所以，区间是前闭后开的。

 

举个例子：

有这样的数据：

![img](https://img-blog.csdnimg.cn/20201106191750315.png)

然后执行以下sql：

```sql
SELECT id,percent,INTERVAL(percent,25,50) from test;
```

执行结果如下：

![img](https://img-blog.csdnimg.cn/20201106191815607.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xrZm9yY2U=,size_16,color_FFFFFF,t_70)

意思大概是这样的：percent字段参与判断，设定的区段是25,50，那么小于25的值返回0，大于等于25小于50的值返回1，大于等于50的值返回2。

 

还可以把INTERVAL()函数用在GROUP BY中：

执行这样的sql：

```sql
SELECT
	INTERVAL (percent, 0, 26, 51),
	COUNT(1)
FROM
	test
GROUP BY
	INTERVAL (percent, 0, 26, 51);
```

执行结果如下：

![img](https://img-blog.csdnimg.cn/20201106191859876.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xrZm9yY2U=,size_16,color_FFFFFF,t_70)

 

### 二，INTERVAL关键字

INTERVAL关键字可以用于计算时间间隔，可以有以下用法。

 

**1，直接计算时间间隔。**

例1：查询当前时间之前2个小时的日期：

```sql
SELECT NOW()-INTERVAL '2' HOUR;
```

例2：

有这样的表：

![img](https://img-blog.csdnimg.cn/20201106192009366.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xrZm9yY2U=,size_16,color_FFFFFF,t_70)

执行这样的sql：

```sql
SELECT
	id,
	percent,
	t_date,
	t_date - INTERVAL 2 HOUR
FROM
	test
where t_date - INTERVAL 2 HOUR>'2020-11-02';
```

执行结果：

![img](https://img-blog.csdnimg.cn/20201106192050399.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xrZm9yY2U=,size_16,color_FFFFFF,t_70)

注：INTERVAL后面的数字可以用数字格式或者字符格式，当时间单位是YEAR_MONTH这种时，必须用字符格式。

 

**2，用在时间函数中**

INTERVAL关键字可以用在DATE_SUB(),SUBDATE(),ADDDATE()等函数中。

例1：查询两天前的时间：

```sql
SELECT NOW(),SUBDATE(NOW(),INTERVAL 2 DAY);
//等效于 SELECT NOW(),NOW()-INTERVAL 2 DAY;
```

```text
NOW()  ||  SUBDATE(NOW(),INTERVAL 2 DAY)
2022-11-01 22:15:52	2022-10-30 22:15:52
```

```sql
select now(),left(now(),14),concat(left(now(),14),'00:00') - interval 23 hour from dual;
```

```text
2022-11-01 22:16:41  ||	2022-11-01 22:  ||	2022-10-31 23:00:00
```

例2：执行这样的sql：

```sql
SELECT
	id,
	percent,
	t_date,
	DATE_SUB(t_date, INTERVAL 2 HOUR)
FROM
	test
WHERE
	DATE_SUB(t_date, INTERVAL 2 HOUR) > '2020-11-02';
```

执行结果：

![img](https://img-blog.csdnimg.cn/20201106192237560.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xrZm9yY2U=,size_16,color_FFFFFF,t_70)

 

可用的时间单位：

> - MICROSECOND
> - SECOND
> - MINUTE
> - HOUR
> - DAY
> - WEEK
> - MONTH
> - QUARTER
> - YEAR
> - SECOND_MICROSECOND
> - MINUTE_MICROSECOND
> - MINUTE_SECOND
> - HOUR_MICROSECOND
> - HOUR_SECOND
> - HOUR_MINUTE
> - DAY_MICROSECOND
> - DAY_SECOND
> - DAY_MINUTE
> - DAY_HOUR
> - YEAR_MONTH

重点关注一下YEAR_MONTH这种格式的单位，以YEAR_MONTH为例，代表几年又几个月的时间间隔。

比如查询当前时间前一年又三个月的时间，可以这样：

```sql
SELECT NOW(),NOW()-INTERVAL '1 3' YEAR_MONTH;
```

执行结果：

![img](https://img-blog.csdnimg.cn/20201106192338514.png)

其中：

**'1 3' YEAR_MONTH**的配置就是代表1年3个月，两个数字之间的间隔符用等号，空格，下划线，中划线等等的都可以。

同理，**'2 1 3 4' DAY_SECOND**就代表2天1小时3分4秒：

![img](https://img-blog.csdnimg.cn/20201106192407589.png)

另外，在Oracle中，INTERVAL关键字还有专门的语法，可以起到MySQL中YEAR_MONTH关键字差不多的功能：

**INTERVAL 'integer [- integer]' {YEAR | MONTH} [(precision)]\[TO {YEAR | MONTH}]**