## 一、[Oracle用户创建及权限设置](https://www.cnblogs.com/buxingzhelyd/p/7865194.html)

权限：

　　create session 允许用户登录数据库权限

　　create table  允许用户创建表权限

　　unlimited tablespace 允许用户在其他表空间随意建表

角色：

- 　　**connect** 
- 　　**resource**
- 　　**dba**

 

　　**CONNECT角色：** --是授予最终用户的典型权利，最基本的权力，**能够连接到ORACLE数据库中，并在对其他用户的表有访问权限时，做SELECT、UPDATE、INSERTT等操作。**
    ALTER SESSION --修改会话
    CREATE CLUSTER --建立聚簇
    CREATE DATABASE LINK --建立数据库链接
    CREATE SEQUENCE --建立序列
    CREATE SESSION --建立会话
    CREATE SYNONYM --建立同义词
     CREATE VIEW --建立视图
    **RESOURCE角色：** --是授予开发人员的，**能在自己的方案中创建表、序列、视图等。**
    CREATE CLUSTER --建立聚簇
    CREATE PROCEDURE --建立过程
    CREATE SEQUENCE --建立序列
     CREATE TABLE --建表
    CREATE TRIGGER --建立触发器
     CREATE TYPE --建立类型

　　**DBA角色**，是授予系统管理员的，**拥有该角色的用户就能成为系统管理员了，它拥有所有的系统权限**

　　例：

　　#sqlplus /nolog

　　SQL> conn / as sysdba;

　　SQL>create user username identified by password --username/password都是用户自定义

　　SQL> grant dba to username;

　　SQL> conn username/password

　　SQL> select * from user_sys_privs;

　　我们将从创建Oracle用户权限表开始谈起，然后讲解登陆等一般性动作，使大家对Oracle用户权限表有个深入的了解。

## 　一、创建

　　sys;//系统管理员，拥有最高权限

　　system;//本地管理员，次高权限

　　scott;//普通用户，密码默认为tiger,默认未解锁

　　oracle有三个默认的用户名和密码~

　　1.用户名:sys密码:change_on_install

　　2.用户名:system密码:manager

　　3.用户名:scott密码:tiger

## 　二、登陆

　　sqlplus / as sysdba;//登陆sys帐户

　　sqlplus sys as sysdba;//同上

　　sqlplus scott/tiger;//登陆普通用户scott

## 　三、管理用户

　　create user zhangsan;//在管理员帐户下，创建用户zhangsan

　　alert user scott identified by tiger;//修改密码

## 　四，授予权限

### 　　1、默认的普通用户scott默认未解锁，不能进行那个使用，新建的用户也没有任何权限，必须授予权限

　　

　　grant create session to zhangsan;//授予zhangsan用户创建session的权限，即登陆权限，允许用户登录数据库

　　grant unlimited tablespace to zhangsan;//授予zhangsan用户使用表空间的权限

　　grant create table to zhangsan;//授予创建表的权限

　　grante drop table to zhangsan;//授予删除表的权限

　　grant insert table to zhangsan;//插入表的权限

　　grant update table to zhangsan;//修改表的权限

　　grant all to public;//这条比较重要，授予所有权限(all)给所有用户(public)

### 　　2、oralce对权限管理比较严谨，普通用户之间也是默认不能互相访问的，需要互相授权

　　

　　grant select on <tablename> to zhangsan;//授予zhangsan用户查看指定单表<表名>的权限

　　grant drop on <tablename> to zhangsan;//授予删除表的权限

　　grant insert on <tablename>to zhangsan;//授予插入的权限

　　grant update on <tablename>to zhangsan;//授予修改表的权限

　　grant insert(id) on <tablename>to zhangsan;

　　grant update(id) on <tablename>to zhangsan;//授予对指定表特定字段的插入和修改权限，注意，只能是insert和update

　　grant alert all table to zhangsan;//授予zhangsan用户alert任意表的权限

## 　五、撤销权限

　　基本语法同grant,关键字为revoke

## 　六、查看权限

　　**==select * from user_sys_privs;//查看当前用户所有权限**==

　　==**select * from user_tab_privs;//查看所用用户对表的权限**==

## 　七、操作表的用户的表

　　select * from zhangsan.tablename

## 　八、权限传递

　　即用户A将权限授予B，B可以将操作的权限再授予C，命令如下：

　　grant alert table on <tablename> to zhangsan with admin option;//关键字 with admin option

　　grant alert table on <tablename>  to zhangsan with grant option;//关键字 with grant option效果和admin类似

## 　九、角色

　　角色即权限的集合，可以把一个角色授予给用户

　　create role myrole;//创建角色

　　grant create session to myrole;//将创建session的权限授予myrole

　　grant myrole to zhangsan;//授予zhangsan用户myrole的角色

　　drop role myrole;删除角色



---

# 二、[Oracle 把一个用户所有表的读权限授予另一个用户](https://www.cnblogs.com/sweet22353/p/9105459.html)

create user <USER_NAME> identified by <PASSWORD>;

grant create session TO <USER_NAME>;

 

## 方法一 

有权限的用户执行

declare
cursor tab_names is select table_name from user_tables;
begin
for tab in tab_names loop
execute immediate 'GRANT SELECT ON '||tab.table_name||' to ==<USER_NAME>==';
end loop;
end;

\----------------------------------------------------------------------

## 方法二

用dba权限用户执行

select 'grant select on user1.'||table_name||' to user2;'
from all_tables
where owner = 'user1';

生成授权语句,再执行生成语句.



方法一成功将hbtz_dw表和hbtz_ods表互相授予select权限，方法二可执行但0 rows返回，

方法二在用方法一授权后再执行能返回授权语句

```sql
SQL>select 'grant select on hbtz_dw.'||table_name||' to hbtz_ods;'
from all_tables
where owner = 'HBTZ_DW';	//注意这里owner填'hbtz_dw'无法找到，区分大小写，此处也可写in ('HBTZ_DW');
```

```sql
SQL>grant select on hbtz_dw.TF_RP_F0801 to hbtz_ods;
SQL>grant select on hbtz_dw.LS_CUST to hbtz_ods;
SQL>grant select on hbtz_dw.SOLARDATA to hbtz_ods;
SQL>grant select on hbtz_dw.TA_CREDIT_MONTH to hbtz_ods;
SQL>grant select on hbtz_dw.TF_BS to hbtz_ods;
SQL>grant select on hbtz_dw.TF_CREDIT to hbtz_ods;
SQL>grant select on hbtz_dw.TF_CREDIT_MONTH to hbtz_ods;
SQL>grant select on hbtz_dw.TF_CUST to hbtz_ods;
SQL>grant select on hbtz_dw.TF_CUST_TOP to hbtz_ods;
.........
```

再将上面返回的授权语句逐一执行

这种方法的缺点是要执行比较多的语句，如果有100个表，就得执行100个grant语句；
另外scott新建的表不在被授权的范围内，新建的表要想被userA访问，也得执行grant语句:
grant select on 新建的表 to userA;

--------------------------------

# 三、[Oracle赋予用户查询另一个用户所有表的权限](https://www.cnblogs.com/qianj/p/13578227.html)

==此方法没有成功，有待验证==

用户：UserA，UserB

场景：用户UserA只有用户UserB指定表的查询权限。

解决方案：

**1.给他一些权限，包括连接权限，因为他要创建同义词，还需要给他同义词**

grant connect to UserA;
grant create synonym to UserA;
grant create session to UserA;

**2.因为需要把UserB的所有表的查询权限给UserA。所以需要所有表的grant select on table_name to UserA语句，不可能一句一句去写，因此用select 吧所有的grant语句查出来直接执行**

select 'grant select on '||owner||'.'||object_name||' to UserA;'
from dba_objects
where owner in ('UserB')
and object_type='TABLE';

把所有结果复制出来，在UserB 下执行一遍

grant select on UserB.Table1 to UserA;

grant select on UserB.Table2 to UserA;

grant select on UserB.Table3 to UserA;

3.需要给UserB用户下所有表创建同义词，但是考虑到之前已经创建过一些表的同义词，因此把所有创建同义词的语句select出来在UserA用户下执行。

SELECT 'create or replace SYNONYM UserA. ' || object_name|| ' FOR ' || owner || '.' || object_name|| ';'
from dba_objects
where owner in ('UserB')
and object_type='TABLE';

把所有结果复制出来登录UserA用户执行

create or replace SYNONYM UserA. T_KDXF_ACCOUNT FOR UserB.Table1 ;

create or replace SYNONYM UserA. T_KDXF_ACCOUNT FOR UserB.Table2 ;

create or replace SYNONYM UserA. T_KDXF_ACCOUNT FOR UserB.Table3 ;



----

# 四、[Oracle授权A用户查询B用户的所有表](https://blog.csdn.net/kepa520/article/details/81746322)

需求：
新建的用户userA，要授权给他访问用户scott的所有表

有三种两方法：

## （1）直接授权所有权限

SQL> conn / as sysdba;
SQL> grant select any table on userA

这种方法的缺点是授予的权限过大，userA不仅可以访问scott下的所有表，也可以访问其他用户包括sys,system下的所有表。

## （2）生成授权语句

SQL> conn scott/tiger;
SQL> select 'GRANT SELECT ON' || table_name || 'to userA;'  from user_tables
得到的结果如下
grant select on emp to userA;
grant select on dept to userA;
grant select on bonus to userA;
grant select on loc to userA;

再把上面得到的结果逐一执行一遍:
SQL> grant select on emp to userA;
SQL> grant select on dept to userA;
SQL> grant select on bonus to userA;
SQL> grant select on loc to userA;

这种方法的缺点是要执行比较多的语句，如果有100个表，就得执行100个grant语句；
另外scott新建的表不在被授权的范围内，新建的表要想被userA访问，也得执行grant语句:
grant select on 新建的表 to userA;

## （3）使用游标

先创建两个用户test1 、test2 
SQL> create user test1 identified by [oracle](https://so.csdn.net/so/search?q=oracle&spm=1001.2101.3001.7020);
User created.

SQL> create user test2 identified by oracle;
User created.

授权角色connect, resource
SQL> grant connect, resource to test1;
Grant succeeded.

SQL> grant connect, resource to test2;
Grant succeeded.

在test2下建立一个表作测试用
SQL> conn test2/oracle;
Connected.

SQL> create table t(id number);
Table created.

创建角色并用游标给角色授权
SQL> conn /as sysdba;
Connected.

创建角色

SQL> create role **select_all_test2_tab**;
Role created

给角色授权

SQL> 
declare
 CURSOR c_tabname is select table_name from dba_tables where owner = 'TEST2';
 v_tabname dba_tables.table_name%TYPE;
 sqlstr  VARCHAR2(200);

begin
 open c_tabname;
 loop
  fetch c_tabname into v_tabname;
  exit when c_tabname%NOTFOUND;
  sqlstr := 'grant select on test2.' || v_tabname ||' to select_all_test2_tab';
  execute immediate sqlstr;
 end loop;
 close c_tabname;
end;
/

PL/SQL procedure successfully completed.

把角色授权给test1
SQL> grant select_all_test2_tab to test1;
Grant succeeded.

尝试用test1访问test2的表
SQL> conn test1/oracle;
Connected.

SQL> select * from test2.t;
no rows selected

在test2下新建表
SQL> conn test2/oracle;
Connected.
SQL> create table ta(id number);
Table created.

尝试用test1访问新建的表
SQL> conn test1/oracle;
Connected.
SQL> select * from test2.ta;
select * from test2.ta
          
ERROR at line 1:
ORA-00942: table or view does not exist

结论：与第二种方案相比，用这种方式不需逐一把test2下的表授权给test1访问，**但test2新建的表无法被test1访问。**



---

### 查看权限表

```
　select * from user_sys_privs;//查看当前用户所有权限

　select * from user_tab_privs;//查看所用用户对表的权限
```

```
HBTZ_DW,HBTZ_ODS,GEN_TABLE,HBTZ_ODS,SELECT,NO,NO
HBTZ_DW,HBTZ_ODS,GEN_TABLE_COLUMN,HBTZ_ODS,SELECT,NO,NO
HBTZ_DW,HBTZ_ODS,SYS_CONFIG,HBTZ_ODS,SELECT,NO,NO
HBTZ_DW,HBTZ_ODS,SYS_DEPT,HBTZ_ODS,SELECT,NO,NO
HBTZ_DW,HBTZ_ODS,SYS_DICT_DATA,HBTZ_ODS,SELECT,NO,NO
HBTZ_DW,HBTZ_ODS,SYS_DICT_TYPE,HBTZ_ODS,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,SYS_USER_POST,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,SYS_USER_ROLE,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TA_CREDIT_MONTH,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TA_ORG_DAY,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TD_CTRL,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TD_CUST,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TD_DAY,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TF_RP_F0203,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TF_RP_F0301,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TF_RP_F0302,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TF_RP_F0303,HBTZ_DW,SELECT,NO,NO
HBTZ_ODS,HBTZ_DW,TF_RP_F0304,HBTZ_DW,SELECT,NO,NO
```

![image-20220215152626772](Oracle用户权限设置.assets/image-20220215152626772.png)

