# [oracle一次插入多条数据(insert all)][https://blog.csdn.net/gnail_oug/article/details/80005957]

问题
公司的项目，有个功能每次使用需要向数据库插入很多数据，导致页面等待很长时间才有结果。
数据库：oracle11g
id：采用sequence自增
每次循环，都会查询一次sequence，然后insert一条数据，性能非常低。

改进
改成一次插入多条数据，id通过触发器自动设置，不再每次先查询sequence，效率提高非常多。

oracle一次插入多条的方法
在oracle里面，==不支持像mysql那样直接在后面拼多个记录====：values(),(),()...==  。oracle中有两种方法达到批量插入的效果：

### 方法一：采用union all拼接查询方式

本文不做详细介绍，可在网上查看相关资料。

```xml
insert into pager (PAG_ID,PAG_PARENT,PAG_NAME,PAG_ACTIVE)
          select 8000,0,'Multi 8000',1 from dual
union all select 8001,0,'Multi 8001',1 from dual
```


##方法二：采用insert all的方式
由于insert all方式插入多条时，通过sequence获取的值是同一个，不会自动获取多个，所以id需要通过其他方式设置，(我这里采用触发器方式自动设置id)

1、创建测试表：

```
create table test_insert(
       data_id number(10) primary key,
       user_name varchar2(30),
       address varchar2(50)
)
```


data_id为主键，通过sequence产生主键值。

2、创建序列：

```
create sequence seq_test_insert 
minvalue 1
maxvalue 999999999999999999999999
start with 1
increment by 1
cache 20;

```

3、创建触发器
通过触发器自动给insert语句设置id值

```
create or replace trigger tr_test_insert
before insert on test_insert
for each row
begin
  select seq_test_insert.nextval into :new.data_id from dual;
end;  
```

4、插入测试数据：

```
insert all 
into test_insert(user_name,address) values('aaa','henan')
into test_insert(user_name,address) values('bbb','shanghai')
into test_insert(user_name,address) values('ccc','beijing')
select * from dual;
```


相当于下面三个insert into语句，但性能比单条高多了。

```
insert into test_insert(user_name,address) values('aaa','henan');
insert into test_insert(user_name,address) values('bbb','shanghai');
insert into test_insert(user_name,address) values('ccc','beijing');
```


需要注意的是，在insert all语句里不能直接使用seq_test_insert.nextval，因为即便每个into语句里都加上seq_test_insert.nextval也不会获得多个值。

5、查看测试数据

select * from test_insert;

结果如下图：

![这里写图片描述](https://img-blog.csdn.net/20180419153558923?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2duYWlsX291Zw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)


另外，insert all还支持往不同的表里插入数据，如：

```
insert all 
into table1(filed1,filed2)values('value1','value2')
into table2(字段1，字段2，字段3) values(值1，值2，值3)
select * from dual;
```


------------------------------------------------
## [ORACLE 批量插入(Insert)详解](https://www.cnblogs.com/hjm0928/p/10254894.html)

Oracle批量插入语句与其他数据库不同，下面列出不同业务需求的插入

假设有一张表Student

[![复制代码](oracle一次插入多条数据(insert all).assets/copycode.gif)](javascript:void(0);)

```
-- 学生表create table Student(
  id   Varchar2(11) primary key,
  name varchar2(32) not null,
  sex  varchar2(3)  not null,
  age  smallint,
  tel  varchar(16)
)
```

[![复制代码](oracle一次插入多条数据(insert all).assets/copycode.gif)](javascript:void(0);)

其中[]中代表可选;<>代表必须;table_column的数量必须和column_value一致，并且数据类型要相匹配

\1. 单条自定义记录插入

　　命令格式：

```
insert` `into` `table` `<tableName>[(<table_column1>,<table_column2>...)] ``values``([<column_value1>,<column_value2>...])
```

　　示例：insertinto *Student(id, name, sex, age, tel)* values *(*'13'*,* 'jack'*,* '男'*,* **13***,* '13345674567'*)*

2.多条自定义记录插入

　　命令格式1：

```
insert all
    into <tableName>[(<table_column1>,<table_column2>...)] values([<column_value1>,<column_value2>...]) 
[ into <tableName>[(<table_column1>,<table_column2>...)] values([<column_value1>,<column_value2>...])]...
select  <table_value1>[,<table_value2>...] from dual;
```

　　示例：

```
insert all into Student(id, name, sex, age, tel)
    into Student(id, name, sex, age, tel) values ('12', 'jack1', '男', 12, '13345674567' )
    into Student(id, name, sex, age, tel) values ('13', 'jack2', '男', 13, '13345674567')
    select '14', 'jack', '男', 13, '13345674567' from dual;
```

 　Note: 我也不知道为什么要加select <values> from dual语句，反正不加就报错

　　命令格式2：

```
 insert into <tableName>[(<table_column1>,<table_column2>...)] 
 select [<column_value1>,<column_value2>...] from dual
   [ union select [<column_value1>,<column_value2>...] from dual ]...
```

　　示例：

```
insert into Student(id, name, sex, age, tel)
select '24', 'jack', '男', 22, '13345674567' from dual
  union select '25', 'jack', '男', 22, '13345674567' from dual
  union select '26', 'jack', '男', 32, '13345674567' from dual
```

　3. 数据库记录插入

　　命令格式：

```
 insert into <tableName1>[(<table_column1>,<table_column2>...)] 
   select [<column_value1>,<column_value2>...] from <tableName2> [where [...]]
   union [ select [<column_value1>,<column_value2>...] from <tableName2> [where [...] ]]
```

　　示例：

```
insert into student(id, name, sex, age, tel)
  select (id-1)||'' as id, name, sex, age, tel from Student where id='11'
  union select id||'1' as id, name, sex, age, tel from Student where id like '1%'
  union select id||'2' as id, name, sex, age, tel from Student where id like '%1' and id/3 != 0
```

**Note:不推荐插入语句不写名字段，比如**

```
insert into student select * from student2； 
      into Student values ('12', 'jack', '男', 12, '13345674567' )  
```