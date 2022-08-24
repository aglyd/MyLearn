# [【mySQL】mySQL动态语句（SQL语句中有变量）](https://blog.csdn.net/weixin_42319496/article/details/119372828)

mysql开发中文博客：<https://imysql.cn/>

动态表名列名：

```sql
delimiter //
create procedure oneKey(in newName varchar(250),in oldName varchar(250),in idNum INT)
BEGIN  
    SET @sqlStmt = CONCAT('insert into ',newName,' (`name`,`age`,`sex`,`major`,`pass`,`photo`)
        select `name`,`age`,`sex`,`major`,`pass`,`photo` from ',oldName,' where id = ',idNum);
    PREPARE stmt FROM @sqlStmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt; #释放连接
END;
//
delimiter ;
 
call oneKey('stu1','student',5);
```

动态变量：

<https://www.cnblogs.com/geaozhang/p/9891338.html>

例子： 

```sql
set @_sql = 'select ? + ?'; //预定义sql，？是占位符
set @a = 5;
set @b = 6;
PREPARE stmt from @_sql; // 预定义sql
EXECUTE stmt USING @a,@b;// 传入两个会话变量来填充sql中的 ?
DEALLOCATE PREPARE stmt; // 释放连接
```

说明：

基本语法:

```sql
PREPARE stmt from '你的sql语句';
EXECUTE stmt (如果sql有参数的话, USING xxx,xxx); // 这里USING的只能是会话变量
DEALLOCATE PREPARE stmt;
```

这三句话分别就是预定义好sql. 
执行预定义的sql 
释放掉数据库连接 
使用这个语法便可以在存储过程中写一些ddl语句，但是在网上看到的是在存储过程中最好是不要写ddl,因为ddl操作会锁表，总之就是不建议在存储过程中去更改表结构。不过我们这里是对临时表的改变，是不影响的啦。

3.还有什么用

扩展一下这个语法还有什么作用呢?

**他还可以在存储过程中动态的拼接表名，字段名，来达到动态查询的效果**
**sql语句中还可以用?来代表参数，这样可以有效的防止sql注入，但是用？传字符串作为动态字段名失败，会将''单引号也传入，但是作为where里的查询条件却是可以的，因为查询条件的字符串本来就需要加''单引号**

例：

```sql
mysql> set @supa1 = 'id';
Query OK, 0 rows affected (0.00 sec)

mysql> set @supa2 = 'name';
Query OK, 0 rows affected (0.00 sec)

mysql> prepare stmt1 from 'select ?,? from user';
Query OK, 0 rows affected (0.02 sec)
Statement prepared

mysql> execute stmt1 using @supa1,@supa2;
+----+------+
| ?  | ?    |
+----+------+
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
| id | name |
+----+------+
12 rows in set (0.00 sec)

mysql> deallocate prepare stmt1;
Query OK, 0 rows affected (0.00 sec)
```


4.实例用法

```
delimiter //
create procedure myTest()
begin
set @_sql = 'select ? + ?';
set @a = 5;
set @b = 6;
PREPARE stmt from @_sql; // 预定义sql
EXECUTE stmt USING @a,@b;// 传入两个会话变量来填充sql中的 ?
DEALLOCATE PREPARE stmt; // 释放连接
end //
```


调用上面的存储过程，会得到11的结果，就是这么简单，关于存储过程我的其他博客里面有，可以去看，值得一提的是，**==如果是要动态的选择表名（或字段名？），表名并不能用 ? 来当占位符。我们只能采用字符串拼接的方法。==**

```sql
delimiter //
create procedure myTest(in columnName varchar(32)) // 传入一个字符串
BEGIN
drop table if exists tmpTable; // 如果临时表存在先删除掉
set @_sql = concat('create temporary table if not exists tmpTable( ', columnName, ' varchar(32), id int(11), _name varchar(32));'); // 创建临时表的语法，我们把传入的参数拼接进来
PREPARE stmt from @_sql;    
EXECUTE stmt;
DEALLOCATE PREPARE stmt;  // 执行
desc tmpTable;
end //
```

 以上存储过程我们可以看到我们传入的字符串可以动态的添加到临时表里面去。
创建临时表时还可以直接从结果集创建。 create temporary table tmpTable select * from tableName;

摘自：https://blog.csdn.net/lqx_sunhan/article/details/79852063

三、预处理 SQL 使用注意点
==**1、stmt_name 作为 preparable_stmt 的接收者，唯一标识，不区分大小写。**==
==**2、preparable_stmt 语句中的 ? 是个占位符，所代表的是一个字符串，不需要将 ? 用引号包含起来。但是？不能占位表名**==
==**3、定义一个已存在的 stmt_name ，原有的将被立即释放，类似于变量的重新赋值。**==
==**4、PREPARE stmt_name 的作用域是session级**==


可以通过 max_prepared_stmt_count 变量来控制全局最大的存储的预处理语句。

```sql
mysql> show variables like 'max_prepared%';
+-------------------------+-------+
| Variable_name           | Value |
+-------------------------+-------+
| max_prepared_stmt_count | 16382 |
+-------------------------+-------+
1 row in set (0.00 sec)
```

预处理编译 SQL 是占用资源的，所以在使用后注意及时使用 DEALLOCATE PREPARE 释放资源，这是一个好习惯。

脚本记录：

```sql
#DELETE FROM event_log WHERE lIndex NOT IN ( SELECT temp.mid FROM ( SELECT MIN(lIndex) as mid FROM event_log  GROUP BY lEventTime,nEventCode,ucPowerStage,ucDevFrom,ucConvFrom) AS temp)
 
set @tb ='d300901890000000010';
set @id_name ='Id';
set @uiq_key ='device_code,ec_type,point_number';
SET @sqlStmt = CONCAT('DELETE FROM ',@tb,' WHERE ',@id_name,' NOT IN ( SELECT temp.mid FROM ( SELECT MIN(',@id_name,')',' AS mid FROM ',@tb,' GROUP BY ',@uiq_key,' ) AS temp)');
 
PREPARE stmt from @sqlStmt; # 预定义sql
EXECUTE stmt;# 传入两个会话变量来填充sql中的 ?
DEALLOCATE PREPARE stmt; # 释放连接
```

修改字段类型：

```sql
create procedure chng_col_type(in tb_name varchar(50),in col_name varchar(50),in col_type varchar(50))
BEGIN  
    #ALTER TABLE L10020745 CHANGE column ec_type  ec_type varchar(50)
    SET @sqlStmt = CONCAT('ALTER TABLE ',tb_name,' CHANGE column ',col_name,' ',col_name,' ',col_type,' NOT NULL ');
    PREPARE stmt FROM @sqlStmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt; #释放连接
END;
 
 
SET @tb_name = 'L10020745';
CALL chng_col_type(@tb_name,'ec_type','varchar(50)');
CALL chng_col_type(@tb_name,'point_number','varchar(50)');
CALL chng_col_type(@tb_name,'line','varchar(50)');
CALL chng_col_type(@tb_name,'flight_size','varchar(5)');
CALL chng_col_type(@tb_name,'flight_length','INT(11)');
CALL chng_col_type(@tb_name,'first_torsion','INT(11)');
CALL chng_col_type(@tb_name,'first_speed','INT(11)');
CALL chng_col_type(@tb_name,'first_turns_num','INT(11)');
CALL chng_col_type(@tb_name,'second_torsion','INT(11)');
CALL chng_col_type(@tb_name,'second_speed','INT(11)');
CALL chng_col_type(@tb_name,'second_turns_num','INT(11)');
CALL chng_col_type(@tb_name,'third_torsion','INT(11)');
CALL chng_col_type(@tb_name,'third_speed','INT(11)');
CALL chng_col_type(@tb_name,'third_turns_num','INT(11)');
CALL chng_col_type(@tb_name,'require_turns','INT(11)');
CALL chng_col_type(@tb_name,'turns_tolerance','INT(11)');
CALL chng_col_type(@tb_name,'moment_tolerance','INT(11)');
CALL chng_col_type(@tb_name,'keep_time','INT(11)');
```






