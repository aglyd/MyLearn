# [Oracle中用exp/imp命令快速导入导出数据库或者导出指定用户下的部分表或数据](https://blog.csdn.net/weixin_47536319/article/details/122839558)

首先本地安装的有Oracle数据库Oracle安装目录d:\oracle\product\10.2.0\db_1\bin\下有exp.exe和imp.exe

然后win+R 打开运行命令即可

**自己用到的导入导出：**
exp tlzf/tlzf@192.168.0.0/orcl file=E:\tlzf.dmp owner=tlzf

exp ahtsp/ahtsp@106.12.129.118/orcl file=E:\ahtsp.dmp owner=ahtsp [rows](https://so.csdn.net/so/search?q=rows&spm=1001.2101.3001.7020)=n  --rows=n不导数据只导表结构

导入新数据库需要创建用户并赋权限。不会的可以查看-->plsql数据库创建新用户并且赋予dba权限

imp sxzf/sxzf@192.168.0.0/orcl file=E:\tlzf.dmp touser=sxzf  fromuser=tlzf

**【用exp数据库导出】：**
1 将数据库TEST完全导出,用户名system 密码manager 导出到D:\daochu.dmp中
  exp system/manager@TEST file=d:\daochu.dmp full=y
2 将数据库中system用户与sys用户的表导出
  exp system/manager@TEST file=d:\daochu.dmp owner=(system,sys)

3 将数据库中的表table1 、table2导出
  exp system/manager@TEST file=d:\daochu.dmp tables=(table1,table2)

4 将数据库中的表table1中的字段filed1以”00″打头的数据导出
  exp system/manager@TEST file=d:\daochu.dmp tables=(table1) query=\” where filed1like '00%'\”

**【用imp数据库导入】：**
1 将D:\daochu.dmp 中的数据导入 TEST数据库中。
  imp system/manager@TEST  file=d:\daochu.dmp
  上面可能有点问题，因为有的表已经存在，然后它就报错，对该表就不进行导入。
  在后面加上 ignore=y 就可以了。

2 将d:\daochu.dmp中的表table1 导入
imp system/manager@TEST  file=d:\daochu.dmp  tables=(table1)

**Exp命令导出指定用户下的部分表或数据**
在如下图的测试环境中，当前登录用户名为“jck”，该用户下有200多张表（如下图）

![img](https://img-blog.csdnimg.cn/20181227145747930)

 

**用Exp导出指定表（如上图红线框中的表）的全部数据**
exp jck/password file=d:\test.dmp statistics=none TABLES=(JSEBOTEST,NEWMAKT,TEST_ORG,TEST_SUBJECT,TEST_USER)

![img](https://img-blog.csdnimg.cn/20181227145747955)

 

如上图，指定部分表格导出

**用Exp导出指定表（如上图红线框中的表）中符合条件的数据**
exp jck/jck file=d:\test.dmp statistics=none TABLES=(JSEBOTEST,NEWMAKT,TEST_ORG,TEST_SUBJECT,TEST_USER)QUERY=\"WHERE rownum<11\"

![img](https://img-blog.csdnimg.cn/20181227145747972)



---

# [Oracle 导入、导出DMP(备份)文件](https://www.cnblogs.com/ggll611928/p/15845429.html)

首先说明dmp文件：

Oracle备份文件是以dmp结尾，这种文件是oracle的逻辑备份文件，常用于数据库逻辑备份，数据库迁移等操作。

 

一.Oracle导入备份文件步骤：我用的是Oracle 11g版本

1.把数据库的备份文件：xx.DMP  拷贝到oracle安装目录下的dpdump文件夹中，

比如我的路径是： D:\work\app\admin\orcl\dpdump 

 

在你的PLSQL Developer中 或者直接在cmd下登录sqlplus,  作如下操作：步骤2-4

2.创建表空间 tablespace_name.dbf 

create tablespace  tablespace_name  datafile 'D:\work\app\admin\orcl\dpdump\tablespace_name.dbf' size 500m 
reuse autoextend on next 10m maxsize unlimited extent management local autoallocate permanent online;

-- 指定表空间初始大小为500M，并且指定表空间满后每次增加的大小为10M。

 

*3.*创建用户

create user +用户名+ identified by +密码+ default tablespace +表空间名;  

--用户、密码指定表空间

 

*4.给用户**授权*

*grant connect,resource,dba to user_name;*

*-- 给用户user_name 授权。*

connect和resource是两个系统内置的角色，和dba是并列的关系。

 

DBA：拥有全部特权，是系统最高权限，只有DBA才可以创建数据库结构。

 

RESOURCE:拥有Resource权限的用户只可以创建实体，不可以创建数据库结构。

 

CONNECT：拥有Connect权限的用户只可以登录Oracle，不可以创建实体，不可以创建数据库结构。

 

 

*5.**cmd运行以下导入语句*

--导入数据库文件 
impdp user_name/pwd@orcl dumpfile=xx.DMP  log=xx.log

-- 将备份文件xx.DMP还原到user_name用户下，并创建名为xx的日志文件xx.log

 

二.Oracle导出备份文件：

 

expdp user_name/pwd@orcl  dumpfile =xx.dmp ;

-- 导出用户user_name下的所有对象，指定导出的备份文件名称为xx.dmp。导出的备份文件默认的存放位置为oracle安装目录下的dpdump文件夹中。

 

 

 

 

导出：

方法一：利用PL/SQL Developer工具导出：

菜单栏---->Tools---->Export Tables，如下图，设置相关参数即可：

 

![img](http://blog.csdn.net/lanpy88/article/details/7580691)

![img](https://images0.cnblogs.com/blog/348022/201306/05113013-5842be30eb464eeda42fba64825cdb25.jpg)

 

方法二：利用cmd的操作命令导入导出：

3：导入与导出，如下：

数据导出：
 1 将数据库TEST完全导出,用户名system 密码manager, 实例名TEST 导出到D:\daochu.dmp中
  exp [system/manager@TEST](mailto:system/manager@TEST) file=d:\daochu.dmp full=y
 2 将数据库中system用户与sys用户的表导出
  exp [system/manager@TEST](mailto:system/manager@TEST) file=d:\daochu.dmp owner=(system,sys)
 3 将数据库中的表table1 、table2导出
  exp [system/manager@TEST](mailto:system/manager@TEST) file=d:\daochu.dmp tables=(table1,table2) 
 4 将数据库中的表table1中的字段filed1以"00"打头的数据导出
  exp [system/manager@TEST](mailto:system/manager@TEST) file=d:\daochu.dmp tables=(table1) query=\" where filed1 like '00%'\"

   上面是常用的导出，对于压缩我不太在意，用winzip把dmp文件可以很好的压缩。
 不过在上面命令后面 加上 compress=y 就可以了 

----

# [oracle导入导出dmp文件](https://blog.csdn.net/weixin_49778600/article/details/124729697)

前言
imp和exp是oracle客户端安装目录下的一个exe文件，通过配置bin目录的环境变量可以直接在cmd窗口直接执行，而不是sqlplus.exe

exp导出语法说明
可输入 exp help=y查看详细参数说明

1.导出数据库全部数据
仅输入数据库连接串和文件导出路径就可以执行导出，导出文件后缀为dmp

exp  用户名/密码@IP  FILE=导出文件路径 

2.按用户名导出
可支持多用户同时导出

exp  用户名/密码@IP  FILE=导出文件路径  OWNER=(用户名1,用户名2)

3.按表名导出
可支持多表同时导出

exp  用户名/密码@IP  FILE=导出文件路径  TABLES=(表名1,表名2)

4.按查询条件导出
QUERY指定查询条件

exp  用户名/密码@IP  FILE=导出文件路径  TABLES=表名  QUERY=(where column_name1=1 and column_name2=2)

以下参数可根据实际需要选择，追加在后面即可

关键字 说明 默认值
FULL 导出整个文件 N
GRANTS 导出权限 Y
TRIGGERS 导出触发器 Y
INDEXES 导出索引 Y
CONSTRAINTS 导出约束 Y
ROWS 导出数据行 Y
LOG 日志文件输出 -

imp导入语法说明
可输入 imp help=y查看详细参数说明

1.导入整个文件

imp 用户名/密码@IP  FILE=导入文件路径  FULL=Y

2.按用户名导入
支持多用户名导入

imp  用户名/密码@IP  FILE=导入文件路径  FULL=Y FROMUSER=导出用户名 TOUSER=导入用户名

3.按表名导入
可支持多表同时导入

imp 用户名/密码@IP  FILE=导入文件路径  FULL=Y TABLES=(表名1,表名2)

以下参数可根据实际需要选择，追加在后面即可

关键字 说明 默认值
FULL 导入整个文件 N
GRANTS 导入权限 Y
TRIGGERS 导入触发器 Y
INDEXES 导入索引 Y
CONSTRAINTS 导入约束 Y
ROWS 导入数据行 Y
LOG 日志文件输出 -
DATA_ONLY 仅导入数据 N
IGNORE 忽略创建错误 N

其他说明
将dmp导入到远程oracle数据库中的方法尝试：
1.（失败） 在本地通过plsql或者命令窗口将dmp导入到oracle中：此方法未成功，非常遗憾，有大佬看到此问题请留言指教：本地没有安装oracle时通过plsql本地运行oracle导入dmp会找不到imp.exe(本地根本没有），如果从oracle服务器中拷贝一份imp.exe可执行文件回来执行plsql也会一闪而过，不执行导入功能
2. **（成功）**登录进入oracle所在服务器，进入cmd窗口直接执行导入导出命令（不要通过sqlplus进入SQL命令窗口），例如：cmd–>

C:\Users\Administrator>imp wyy/Sg_ay_wyy_95598 file=C:\....\file0509.dmp full=y