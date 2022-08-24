# [使用java获取时间戳的方法有哪些](https://www.yisu.com/zixun/212673.html)

**一、java获取时间戳**

首先我们先拿上面的例子说起吧。如何获取今天零点以及明天零点的两个时间戳。

```java
public Long getToday(){
  DateTime now = new DateTime();
  return new DateTime(now.getYear(), now.getMonthOfYear(), now.getDayOfMonth(), 0, 0, 0, 0).getMillis();
 }
 
 public Long getTomorrow(){
  DateTime now = new DateTime();
  return new DateTime(now.getYear(), now.getMonthOfYear(), now.getDayOfMonth(), 0, 0, 0, 0).plusDays(1).getMillis();
 }
```

上面的方法中用到了DateTime中的plusDays（），同理，你如果需要获取下 个星期（年，月，时，分，秒，毫秒）前的时间戳，都有同样的plusYears（int X），plusMonths（int X）等等与之对应，如果要获取今天之前的就把传入一个负整数参数即可。

然而很多时候我们需要某个特定时间的时间戳，比如这个月5号14点23分6秒138毫秒的时间戳（这个时间并没有特殊的含义，随便选的）。

```java
public Long getTime(){
  Long now = new Date().getTime();
  Calendar calendar = Calendar.getInstance();
  calendar.setTimeInMillis(now);
  calendar.set(Calendar.DAY_OF_MONTH, 5);
  calendar.set(Calendar.HOUR, 14);
  calendar.set(Calendar.MINUTE, 23);
  calendar.set(Calendar.SECOND, 6);
  calendar.set(Calendar.MILLISECOND, 138);
  return calendar.getTimeInMillis();
 }
```

再比如我们可能需要知道这个星期二的10点10分10秒的时间戳。

```java
public Long getTime(){
  Long now = new Date().getTime();
  Calendar calendar = Calendar.getInstance();
  calendar.setTimeInMillis(now);
  calendar.set(Calendar.DAY_OF_WEEK, 2);
  calendar.set(Calendar.HOUR, 10);
  calendar.set(Calendar.MINUTE, 10);
  calendar.set(Calendar.SECOND, 10);
  return calendar.getTimeInMillis();
 }
```

**二、Java中两种获取精确到秒的时间戳的方法**

Java中的时间戳的毫秒主要通过最后的三位来进行计量的，下面给大家分享从网上整理的两种不同的方式将最后三位去掉。

**方法一：通过String.substring()方法将最后的三位去掉**

```java
/** 
* 获取精确到秒的时间戳 
* @return 
*/ 
public static int getSecondTimestamp(Date date){ 
if (null == date) { 
return 0; 
} 
String timestamp = String.valueOf(date.getTime()); 
int length = timestamp.length(); 
if (length > 3) { 
return Integer.valueOf(timestamp.substring(0,length-3)); 
} else { 
return 0; 
} 
}
```

**方法二：通过整除将最后的三位去掉
**

```java
/** 
* 获取精确到秒的时间戳 
* @param date 
* @return 
*/ 
public static int getSecondTimestampTwo(Date date){ 
if (null == date) { 
return 0; 
} 
String timestamp = String.valueOf(date.getTime()/1000); 
return Integer.valueOf(timestamp); 
}
```