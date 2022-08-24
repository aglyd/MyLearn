# [db2建立schema](https://blog.csdn.net/weixin_36472962/article/details/116959038)

## 1.显式建立schema

执行create schema需要有DBADM权限

建立某个schema需要有SYSADM 和DBAMIN权限

总的来说就是需要SYSADM 和DBAMIN权限

--语法

```sql
CREATE SCHEMA <schemaname> AUTHORIZATION <username>

--如果不输入AUTHORIZATION，就是执行命令的本人拥有权限

db2 => create schema db2 authorization user12

DB20000I The SQL command completed successfully.

db2 => select SCHEMANAME,OWNER from syscat.schemata where schemaname='db2'

SCHEMANAME OWNER

------------------------------ -----------

db2 user12

1 record(s) selected.
```



## 2.隐式建立schema

如果你没有SYSADM,DBADMIN权限，但是你有IMPLICIT_SCHEMA，那么你也可以建立schema

```sql
--查询用户没有DBADMIN，但是有IMPLICIT_SCHEMA

db2 => GET AUTHORIZATIONS

Administrative Authorizations for

Current User

Direct SYSADM authority = NO

Direct SYSCTRL authority = NO

Direct SYSMAINT authority = NO

Direct DBADM authority = NO

Direct CREATETAB authority = NO

Direct BINDADD authority = NO

Direct CONNECT authority =

NO

Direct CREATE_NOT_FENC authority = NO

Direct IMPLICIT_SCHEMA authority = NO

Direct LOAD authority =

NO

Direct QUIESCE_CONNECT authority = NO

Direct CREATE_EXTERNAL_ROUTINE authority = NO

Direct SYSMON authority = NO

Indirect SYSADM authority = YES

Indirect SYSCTRL authority = NO

Indirect SYSMAINT authority = NO

Indirect DBADM authority = NO

Indirect CREATETAB authority = YES

Indirect BINDADD authority = YES

Indirect CONNECT authority =

YES

Indirect CREATE_NOT_FENC authority = NO

Indirect IMPLICIT_SCHEMA authority = YES

Indirect LOAD authority =

NO

Indirect QUIESCE_CONNECT authority = NO

Indirect CREATE_EXTERNAL_ROUTINE authority = NO

Indirect SYSMON authority = NO

--显式创立失败

db2 => create schema db2user11

DB21034E The command was processed as an SQL statement because it was not a

valid Command Line Processor command. During SQL processing it

returned:

SQL0552N "DB2USER1" does

not have the privilege to perform operation "CREATE

SCHEMA". SQLSTATE=42502

--隐式建立成功

db2 => create table db2user11.t1 (aaa integer)

DB20000I The SQL command completed successfully.

--再查询现在的schema和OWNER，可以发现owner是SYSIBM

db2 => select SCHEMANAME,OWNER

from syscat.schemata where schemaname='DB2USER11'

SCHEMANAME OWNER

\---------------

\-----------------------

DB2USER11 SYSIBM

1 record(s) selected.

--查询用户没有DBADMIN，但是有IMPLICIT_SCHEMA

db2 => GET AUTHORIZATIONS

Administrative Authorizations for Current User

Direct SYSADM authority = NO

Direct SYSCTRL authority = NO

Direct SYSMAINT authority = NO

Direct DBADM authority = NO

Direct CREATETAB authority = NO

Direct BINDADD authority = NO

Direct CONNECT authority = NO

Direct CREATE_NOT_FENC authority = NO

Direct IMPLICIT_SCHEMA authority = NO

Direct LOAD authority = NO

Direct QUIESCE_CONNECT authority = NO

Direct CREATE_EXTERNAL_ROUTINE authority = NO

Direct SYSMON authority = NO

Indirect SYSADM authority = YES

Indirect SYSCTRL authority = NO

Indirect SYSMAINT authority = NO

Indirect DBADM authority = NO

Indirect CREATETAB authority = YES

Indirect BINDADD authority = YES

Indirect CONNECT authority = YES

Indirect CREATE_NOT_FENC authority = NO

Indirect IMPLICIT_SCHEMA authority = YES

Indirect LOAD authority = NO

Indirect QUIESCE_CONNECT authority = NO

Indirect CREATE_EXTERNAL_ROUTINE authority = NO

Indirect SYSMON authority = NO

--显式创立失败

db2 => create schema db2user11

DB21034E The command was processed as an SQL statement because it was not a

valid Command Line Processor command. During SQL processing it returned:

SQL0552N "DB2USER1" does not have the privilege to perform operation "CREATE

SCHEMA". SQLSTATE=42502

--隐式建立成功

db2 => create table db2user11.t1 (aaa integer)

DB20000I The SQL command completed successfully.

--再查询现在的schema和OWNER，可以发现owner是SYSIBM

db2 => select SCHEMANAME,OWNER from syscat.schemata where schemaname='DB2USER11'

SCHEMANAME OWNER

--------------- -----------------------

DB2USER11 SYSIBM

1 record(s) selected.
```

## 3.查询现有的schema

语法

```sql
db2 => select schemaname from syscat.schemata

SCHEMANAME

\--------------------------------------------------------------------------------------------------------------------------------

DB2INST1

DB2USER1

DB2USER11

DB2USER12

NULLID

SQLJ

SYSCAT

SYSFUN

SYSIBM

SYSIBMADM

SYSIBMINTERNAL

SYSIBMTS

SYSPROC

SYSPUBLIC

SYSSTAT

SYSTOOLS

16 record(s) selected.

--查询有表的schema

db2 => SELECT distinct TABSCHEMA FROM SYSCAT.TABLES

TABSCHEMA

\--------------------------------------------------------------------------------------------------------------------------------

DB2INST1

DB2USER1

DB2USER11

SYSCAT

SYSIBM

SYSIBMADM

SYSPUBLIC

SYSSTAT

SYSTOOLS

9 record(s) selected.
```

## 4.删除schema

--语法

```sql
DROP SCHEMA <schemaname> RESTRICT
```

