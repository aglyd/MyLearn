# 一、[mysql列名小写_MySQL表名、列名区分大小写详解](https://blog.csdn.net/weixin_35715118/article/details/113946744)

在刚开始使用mysql的时候，刚开始是想要区分列名大小写的问题，在网上看到很多办法，于是就

1、linux下mysql安装完后是默认：区分表名的大小写，不区分列名的大小写；

2、2、用root帐号登录后，在/etc/my.cnf 中的[mysqld]后添加添加lower_case_table_names=1，重启MYSQL服务，这时已设置成功：不区分表名的大小写；

lower_case_table_names参数详解：

lower_case_table_names = 0

其中 0：区分大小写，1：不区分大小写

MySQL在Linux下数据库名、表名、列名、别名大小写规则是这样的：

1、数据库名与表名是严格区分大小写的；

2、表的别名是严格区分大小写的；

3、列名与列的别名在所有的情况下均是忽略大小写的；

4、变量名也是严格区分大小写的；

MySQL在Windows下都不区分大小写。

在my.ini 中的[mysqld]后添加添加lower_case_table_names=1，重启MYSQL服务，这时已设置成功：不区分表名的大小写；

lower_case_table_names参数详解：

lower_case_table_names = 0

其中 0：区分大小写，1：不区分大小写

3、如果想在查询时区分字段值的大小写，则：字段值需要设置BINARY属性，设置的方法有多种：

A、创建时设置：

CREATE TABLE T(

A VARCHAR(10) BINARY

);

B、使用alter修改：

ALTER TABLE `tablename` MODIFY COLUMN `cloname` VARCHAR(45)BINARY;

C、mysql table editor中直接勾选BINARY项。

乱码解决，更详细的看下字符集设置这篇

在[mysqld] 下增加下句

default-character-set=utf8

但是经过本人的实践之后如果按此方法修改后表名的区分大小写指的是你创建一个表之后，它保留你创建时候的表名的原貌，但是在系统后台存储的时候此表是不区分大小写的，也就是说在创建一个表名仅大小写不一样的表是不可以的。

例如;

在修改为表名区分大小写之后，也就是  lower_case_table_names = 0 (不管是在哪个系统下)在mysql命令行界面下输入

CREATE TABLE TEST

(

Id int  not null primary key,

Namevarchar not null

);

之后你执行show tables;

会包含一个TEST表，表名保留原来的大小写，

你如果输入show tables like ‘t%’；是查不到这个新建的表的；

之后你在创建另外一个表，

CREATE TABLE test

(

Id int  not null primary key,

Namevarchar not null

);

系统会提示你，表test已经存在，不允许创建。
------------------------------------------------
## 二、[Mysql的表名/字段名/字段值是否区分大小写](https://www.cnblogs.com/457248499-qq-com/p/7360284.html)

1、[MySQL](http://lib.csdn.net/base/mysql)默认情况下是否区分大小写，使用show Variables like '%table_names'查看lower_case_table_names的值，0代表区分，1代表不区分。

2、[mysql](http://lib.csdn.net/base/mysql)对于类型为varchar数据默认不区分大小写，但如果该字段以“*_bin”编码的话会使mysql对其区分大小写。

3、mysql对于字段名的策略与varchar类型数据相同。即：默认不区分大小写，但如果该字段是以“*_bin”编码的话会使mysql对其区分大小写。

4、mysql对于表名的策略与varchar类型数据相同。即：默认不区分大小写，但如果该表是以“*_bin”编码的话会使mysql对其区分大小写。

5、如果按照第一项查看lower_case_table_names的值为0，但需要让mysql默认不区分大小写的话，需要在mysql配置文件中添加参数并重启mysql[数据库](http://lib.csdn.net/base/mysql)。mysql配置文件的修改内容如下：

[mysqld]
...
lower_case_table_names = 1

6、注意：表和字段的编码尽量继承数据库的编码（不明显指定即继承），以免引起混乱。

 

[Linux](http://lib.csdn.net/base/linux)下的MYSQL默认是要区分表名大小写的 ，而在windows下表名不区分大小写

　　让MYSQL不区分表名大小写的方法其实很简单：

　　1.用ROOT登录，修改/etc/my.cnf

　　2.在[mysqld]下加入一行：lower_case_table_names=1

　　3.重新启动数据库即可