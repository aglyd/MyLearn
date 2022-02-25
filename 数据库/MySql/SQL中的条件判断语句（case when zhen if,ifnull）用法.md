# [SQL中的条件判断语句（case when zhen if,ifnull）用法](https://www.cnblogs.com/studynode/p/9881900.html)



# 简介：

case具有两种格式。简单case函数和case搜索函数。这两种方式，可以实现相同的功能。简单case函数的写法相对比较简洁，但是和case搜索函数相比，功能方面会有些限制，比如写判定式。还有一个需要注重的问题，case函数只返回第一个符合条件的值，剩下的case部分将会被自动忽略。

--简单case函数
case sex
 when '1' then '男'
 when '2' then '女’
 else '其他' end


--case搜索函数
case when sex = '1' then '男'
   when sex = '2' then '女'
   else '其他' end

 

--比如说，下面这段sql，你永远无法得到“第二类”这个结果
case when col_1 in ('a','b') then '第一类'
   when col_1 in ('a') then '第二类'
   else '其他' end  

# 示例：

如下users表：

![img](https://img-blog.csdn.net/20171124142759501?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQ2F0aHlMb3U=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

上表结果中的"sex"是用代码表示的，希望将代码用中文表示。可在语句中使用case语句：

![img](https://img-blog.csdn.net/20171124144004642?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQ2F0aHlMb3U=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

如果不希望列表中出现"sex"列，语句如下：

![img](https://img-blog.csdn.net/20171124144052713?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQ2F0aHlMb3U=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

 

将sum与case结合使用，可以实现分段统计。如果现在希望将上表中各种性别的人数进行统计，sql语句如下：

![img](https://img-blog.csdn.net/20171124144147567?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQ2F0aHlMb3U=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

 

MySQL的IF既可以作为表达式用，也可在存储过程中作为流程控制语句使用，如下是做为表达式使用：

## IF表达式

```
IF(expr1,expr2,expr3)
```

如果 expr1 是TRUE (expr1 <> 0 and expr1 <> NULL)，则 IF()的返回值为expr2; 否则返回值则为 expr3。IF() 的返回值为数字值或字符串值，具体情况视其所在语境而定。

```
SELECT IF(sva=1,"男","女") AS s FROM table_name 
WHERE sva != '';
```

## IFNULL(expr1,expr2)

假如expr1 不为 NULL，则 IFNULL() 的返回值为 expr1; 否则其返回值为 expr2。IFNULL()的返回值是数字或是字符串，具体情况取决于其所使用的语境。

```
 SELECT IFNULL(1,0);
 -> 1

SELECT IFNULL(NULL,10);
 -> 10

SELECT IFNULL(1/0,10);
-> 10

SELECT IFNULL(1/0,'yes');
-> 'yes'
```

