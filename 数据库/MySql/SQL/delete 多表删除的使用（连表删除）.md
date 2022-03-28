# 一、[delete 多表删除的使用（连表删除）](https://blog.csdn.net/weixin_42030357/article/details/107741056)

DELETE删除多表数据，怎样才能同时删除多个关联表的数据呢？这里做了深入的解释：

```sql
delete from t1 where 条件
delete t1 from t1 where 条件
delete t1 from t1,t2 where 条件
delete t1,t2 from t1,t2 where 条件
```

前 3者是可行的，第4者不可行。
也就是简单用delete语句无法进行多表删除数据操作，不过可以建立[级联](https://so.csdn.net/so/search?q=级联&spm=1001.2101.3001.7020)删除，在两个表之间建立级联删除关系，则可以实现删除一个表的数据时，同时删除另一个表中相关的数据。

## 1、从数据表t1中把那些id值在数据表t2里有匹配的记录全删除掉(只删除一个表中的数据)

```sql
DELETE t1 FROM t1,t2 WHERE t1.id=t2.id
```

或

```sql
DELETE FROM t1 USING t1,t2 WHERE t1.id=t2.id
```

## 2、从数据表t1里在数据表t2里没有匹配的记录查找出来并删除掉(只删除一个表中的数据)

```sql
DELETE t1 FROM t1 LEFT JOIN T2 ON t1.id=t2.id WHERE t2.id IS NULL
```

或

```sql
DELETE FROM t1,USING t1 LEFT JOIN T2 ON t1.id=t2.id WHERE t2.id IS NULL
```

## 3、 从两个表中找出相同记录的数据并把两个表中的数据都删除掉

```sql
DELETE t1,t2 from t1 LEFT JOIN t2 ON t1.id=t2.id WHERE t1.id=25
```

注意此处的delete t1,t2 from 中的**t1,t2不能是别名**

如：

```sql
delete t1,t2 from table_name as t1 left join table2_name as t2 on t1.id=t2.id where table_name.id=25
```

**在数据里面执行是错误的（MYSQL 版本不小于5.0在5.0中是可以的）**

上述语句改 写成

```sql
delete table_name,table2_name from table_name as t1 left join table2_name as t2 on t1.id=t2.id where table_name.id=25
```

在数据里面执行是错误的**（加别名在MYSQL 版本小于5.0在5.0中是可以的）**

