# [MySQL中的时间函数](https://blog.csdn.net/weixin_38192427/article/details/123365010)

## 1、获取系统当前时间

MySQL 版本为 5.7，详细的时间函数可以参考 MySQL 官方文档 在这里

### 1.1. 获取 YYYY-MM-DD HH:mm:ss

```
SELECT NOW(),CURRENT_TIMESTAMP(),SYSDATE(),CURRENT_TIMESTAMP;
```

NOW() 返回当前日期和时间
CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP 都是 NOW() 函数的同义词
NOW() 在执行开始时值就得到了
SYSDATE() 返回函数执行的时间，一般情况下很少用到

### 1.2. 获取 YYYY-MM-DD

```
SELECT CURRENT_DATE,CURRENT_DATE(),CURDATE(),DATE(NOW());
```

CURDATE() 返回当前日期
CURRENT_DATE(),CURRENT_DATE 都是 CURDATE() 的同义词
DATE() 提取日期或日期时间表达式的日期部分

### 1.3. 获取 HH:mm:ss

```
SELECT CURRENT_TIME,CURRENT_TIME(),CURTIME(),TIME(NOW());
```


CURTIME() 返回当前时间
CURRENT_TIME(),CURRENT_TIME 都是 CURTIME() 的同义词
TIME() 提取传递的表达式的时间部分
## 2、时间加减间隔函数

MySQL 中内置函数 DATE_ADD() 和 DATE_SUB() 能对指定的时间进行增加或减少一个指定的时间间隔，语法如下

DATE_ADD(date,INTERVAL expr type)
DATE_SUB(date,INTERVAL expr type)

date 是指定的日期
INTERVAL 为关键词
expr 是具体的时间间隔
type 是时间单位
注意：type 可以是复合型的，比如 YEAR_MONTH。如果 type 不是复合型的， DATE_ADD() 和 DATE_SUB() 其实可以通用，因为 expr 可以为一个负数。可用的 type 如下表

MICROSECOND	间隔单位：毫秒
SECOND	间隔单位：秒
MINUTE	间隔单位：分钟
HOUR	间隔单位：小时
DAY	间隔单位：天
WEEK	间隔单位：星期
MONTH	间隔单位：月
QUARTER	间隔单位：季度
YEAR	间隔单位：年
SECOND_MICROSECOND	复合型，间隔单位：秒、毫秒，expr可以用两个值来分别指定秒和毫秒
MINUTE_MICROSECOND	复合型，间隔单位：分、毫秒
MINUTE_SECOND	复合型，间隔单位：分、秒
HOUR_MICROSECOND	复合型，间隔单位：小时、毫秒
HOUR_SECOND	复合型，间隔单位：小时、秒
HOUR_MINUTE	复合型，间隔单位：小时分
DAY_MICROSECOND	复合型，间隔单位：天、毫秒
DAY_SECOND	复合型，间隔单位：天、秒
DAY_MINUTE	复合型，间隔单位：天、分
DAY_HOUR	复合型，间隔单位：天、小时
YEAR_MONTH	复合型，间隔单位：年、月


### 2.1. DATETIME 类型的加减

```
-- 给当前的时间日期增加一个月
SELECT DATE_ADD(NOW(),INTERVAL 1 MONTH), NOW(); 

-- 给当前的时间日期减少一个月
SELECT DATE_SUB(NOW(),INTERVAL 1 MONTH), NOW();
```



### 2.2. DATE 类型的加减

```
-- 给当前的日期增加 10 天
SELECT DATE_ADD(DATE(NOW()),INTERVAL 10 DAY), DATE(NOW());

-- 给当前的日期减少 10 天
SELECT DATE_SUB(DATE(NOW()),INTERVAL 10 DAY), DATE(NOW());
```




## 3、两个时间的相减

### 3.1. DATE 类型相减

DATEDIFF(date1, date2) 减去两个日期，比较的是天数，与时间无关 date1 - date2

```
SELECT DATEDIFF('2013-01-13','2012-10-01');

SELECT DATEDIFF('2013-01-13 13:13:13','2012-10-01 16:16:16');

SELECT DATEDIFF('13:13:13','16:16:16');
```



### 3.2. TIMESTAMP 类型

TIMESTAMPDIFF(type, ts1, ts2) : 根据 type，计算两个时间 ts2 - ts1 相差多少天、月、年等

```
SELECT TIMESTAMPDIFF(DAY, '2013-01-13','2012-10-01');

SELECT TIMESTAMPDIFF(MONTH, '2013-01-13 13:13:13','2012-10-01 16:16:16');

SELECT TIMESTAMPDIFF(HOUR, '13:13:13','16:16:16');
```

MySQL 关于时间函数的官方文档：https://dev.mysql.com/doc/refman/5.7/en/date-and-time-functions.html
