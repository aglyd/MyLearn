# JAVA 日期类DATE、Calender

###  Calender 设置时间

--------------------

### MONTH 月份

也是因为西方文化的原因，**一年的第一个月是从“0”开始算起的，一年中12个月份分别是：“0-11”，12指的是下一年的一月份**

```java
calendar.set(2016,12,9);
SimpleDateFormat format=new SimpleDateFormat("yyyy-MM-dd");
String date=format.format(calendar.getTime());<br>	//获得的结果是：2017-01-09,因为设置11才为12月，多一月自动叠加到下一年的下一月
Sysout(calendar.get(Calendar.YEAR)+"/"+calendar.get(Calendar.MONTH)+"/"+calendar.get(Calendar.DATE)) //打印：2017/0/9。calendar的时间已经是2017-01-09，但是获取month：01月是0表示
```

所以 :
**为 calendar.set() 设置“月份（MONTH）”时需要 “-1”**
**通过 calendar.get(Calendar.MONTH) 获取“月份（month）”时需要 “+1”**

**注意calendar.getTime()获取到时间的月份是真实的月份，不需要+1**

--------------------

### WEEK_OF_YEAR 一年中的第几周

由于西方的一周指的是：星期日-星期六，星期日是一周的第一天，星期六是一周的最后一天，

所以，使用 calendar.get(Calendar.WEEK_OF_YEAR) 时应该注意一周的开始应该是哪一天

```java
Calendar calendar=Calendar.getInstance();	//获取当前时间
calendar.get(Calendar.WEEK_OF_YEAR);     //获取该日在当前年中属于第几周
calendar.get(Calendar.WEEK_OF_MONTH);	//获取该日在当前月中属于第几周
```

如果一周的开始是星期一，那么可以进行如下操作：

```java
Calendar calendar=Calendar.getInstance();
calendar.set(2016,9,9);              //2016-10-09  这一天是星期日
long week1=calendar.get(Calendar.WEEK_OF_YEAR);
calendar.setFirstDayOfWeek(Calendar.MONDAY);         //设置一周的第一天是星期几
calendar.set(2016,9,9);          / /   一定要在calendar.setFirstDayOfWeek()；方法后重新设置一遍日期，否则无效
long week2=calendar.get(Calendar.WEEK_OF_YEAR);
```

**注意：一年有52个周，calendar.get(Calendar.WEEK_OF_YEAR);的取值范围是：“1-52”，所以当一年中最后的几天超过52周，进入第53周时，将以下一年的第一周来计算**

（跨年问题：跨年的那个星期获取 “WEEK_OF_YEAR” 得到的结果总是“1”，）

**如**

```java
calendar.setFirstDayOfWeek(Calendar.MONDAY);
calendar.set(2016,11,31);             //2016-12-31
long week=calendar.get(Calendar.WEEK_OF_YEAR);       //week= 1
```

-------------

### DAY_OF_WEEK 星期几

```java
String[] weeks = new String[]{"星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"};                    
int index=calendar.get(Calendar.DAY_OF_WEEK);         
String weekDay=weeks[index-1];
123
```

返回的是周几，取值为“1-7” 指的是 “星期日-星期六”，所以获取星期几时需要 “-1”

（这个值跟一周的第一天是星期几无关）

---------------

### SET() 方法

set(Calendar.DAY_OF_WEEK，Calendar.MONDAY)：设置日期（calendar）为日期所在周的周一的日期（可以获取日期所在周的周一的日期）

**注意：设置的值都为int或long**

```java
calendar.set(Calendar.DAY_OF_WEEK,Calendar.MONDAY);
String date=format.format(cal.getTime());
```

---------------

### Calender设置指定时间方法还可通过.setTime(Date date)

``` 
		String dateStr = "2020-02-01";
        SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        try {
             date = sf.parse(dateStr);
        } catch (Exception e) {
            e.printStackTrace();
        }
        c.setTime(date);
        System.out.println(c.get(Calendar.YEAR)+"-"+ c.get(Calendar.MONTH)+"-"+c.get(Calendar.DATE));

```

----------

### Calender.get()获取年份、月份、日

```
Calendar calendar=Calendar.getInstance(); //2021-03-26
calender.set(Calendar.YEAR,0101)
System.out.println(c.get(Calendar.YEAR)+"-"+ c.get(Calendar.MONTH)+"-"+c.get(Calendar.DATE));//101-3-26
Date date = c.getTime();
String dateStr = new SimpleDateFormat("yyyy-MM-dd").format(date);	//则获得0101-03-26
```

**注意：获取此方式到的月份需要+1，因为是0~11表示，返回的值类型都为int或long，如果年份是0101或月份是09的会去掉头部的0但.getTime()返回Date再用new SimpleDateFormat("yyyy-MM-dd")转换的时候不会去掉头部的0值**

