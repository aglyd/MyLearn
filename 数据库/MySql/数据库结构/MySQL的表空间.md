# [MySQL的表空间是什么 ](https://www.cnblogs.com/better-farther-world2099/articles/14713523.html)

今天我要跟你分享的话题是：“大家常说的表空间到底是什么？究竟什么又是数据表？”

这其实是一个概念性的知识点，当作拓展知识。涉及到的概念大家了解一下就好，涉及的参数，留个印象就好。

　　从 InnoDB存储引擎的逻辑存储结构看,所有数据都被逻辑地存放在一个空间中,称之为表空间( tablespace)。**表空间又由段(segment)、区( extent)、页(page)组成**。页在一些文档中有时也称为块( block), InnoDB存储引擎的逻辑存储结构大致如图所示。

![img](https://img2020.cnblogs.com/blog/1401949/202105/1401949-20210517155217391-670216417.png)

## 一、什么是表？

但凡是用过MySQL都知道，直观上看，MySQL的数据都存在数据表中。

比如一条Update SQL：

```
update user set username = '白日梦' where id = 999;
```

它将user这张数据表中id为1的记录的username列修改成了‘白日梦'

这里的user其实就是数据表。当然这不是重点，重点是我想表达：数据表其实是逻辑上的概念。而下面要说的表空间是物理层面的概念。

## 二、什么是表空间？

不知道你有没有看到过这句话：“在innodb存储引擎中数据是按照表空间来组织存储的”。其实有个潜台词是：表空间是表空间文件是实际存在的物理文件。

大家不用纠结为啥它叫表空间、为啥表空间会对应着磁盘上的物理文件，因为MySQL就是这样设计、设定的。直接接受这个概念就好了。

MySQL有很多种表空间，下面一起来了解一下。

## 三、sys表空间

你可以像下面这样查看你的MySQL的系统表空间

![img](https://img2020.cnblogs.com/blog/1401949/202104/1401949-20210428115007582-342633677.png)

Value部分的的组成是：name:size:attributes

默认情况下，MySQL会初始化一个大小为12MB，名为ibdata1文件，并且随着数据的增多，它会自动扩容。

这个ibdata1文件是系统表空间，也是默认的表空间，也是默认的表空间物理文件，也是传说中的共享表空间。

> 关于这个共享表空间，直观上看，如果这个表空间能为multiple tables.存储数据，那么它就可以被称为共享表空间，所以你可以认为系统表空间是共享表空间。

## 四、配置sys表空间

系统表空间的数量和大小可以通过启动参数：innodb_data_file_path

```
# my.cnf
[mysqld]
innodb_data_file_path=/dir1/ibdata1:2000M;/dir2/ibdata2:2000M:autoextend
```

## 五、file per table 表空间

如果你想让每一个数据库表都有一个单独的表空间文件的话，可以通过参数innodb_file_per_table设置。

> 这个参数只有在MySQL5.6或者是更高的版本中才可以使用。

可以通过配置文件

```
[mysqld]
innodb_file_per_table=ON
```

也可以通过命令

```
mysql> SET GLOBAL innodb_file_per_table=ON; 
```

![img](https://img2020.cnblogs.com/blog/1401949/202104/1401949-20210428115220484-517665212.png)

让你将其设置为ON，那之后InnoDB存储引擎产生的表都会自己独立的表空间文件。

独立的表空间文件命名规则：表名.ibd

注意：

> 独立表空间文件中仅存放该表对应数据、索引、insert buffer bitmap。
>
> 其余的诸如：undo信息、insert buffer 索引页、double write buffer 等信息依然放在默认表空间，也就是共享表空间中。
>
> 需要先了解即使你设置了innodb_file_per_table=ON 共享表空间的体量依然会不断的增长，并且你即使你不断的使用undo进行rollback，共享表空间大小也不会缩减就好了。

查看我的表空间文件：

![img](https://img2020.cnblogs.com/blog/1401949/202104/1401949-20210428115314878-1424857128.png)

最后再简述一下这种file per table的优缺点：

优点：

- 提升容错率，表A的表空间损坏后，其他表空间不会收到影响。s
- 使用MySQL Enterprise Backup快速备份或还原在每表文件表空间中创建的表，不会中断其他InnoDB 表的使用

缺点：

对fsync系统调用来说不友好，如果使用一个表空间文件的话单次系统调用可以完成数据的落盘，但是如果你将表空间文件拆分成多个。原来的一次fsync可能会就变成针对涉及到的所有表空间文件分别执行一次fsync，增加fsync的次数。

## 六、临时表空间

临时表空间用于存放用户创建的临时表和磁盘内部临时表。

参数innodb_temp_data_file_path定义了临时表空间的一些名称、大小、规格属性如下图：

![img](https://img2020.cnblogs.com/blog/1401949/202104/1401949-20210428115429955-937790784.png)

查看临时表空间文件存放的目录

![img](https://img2020.cnblogs.com/blog/1401949/202104/1401949-20210428115450977-863579928.png)

## 七、undo表空间

相信你肯定听过说undolog，常见的当你的程序想要将事物rollback时，底层MySQL其实就是通过这些undo信息帮你回滚的。

在MySQL的设定中，有一个表空间可以专门用来存放undolog的日志文件。

然而，在MySQL的设定中，默认的会将undolog放置到系统表空间中。

如果你的MySQL是新安装的，那你可以通过下面的命令看看你的MySQL undo表空间的使用情况：

![img](https://img2020.cnblogs.com/blog/1401949/202104/1401949-20210428115522238-574575668.png)

大家可以看到，我的MySQL的undo log 表空间有两个。

也就是我的undo从默认的系统表空间中转移到了undo log专属表空间中了。

![img](https://img2020.cnblogs.com/blog/1401949/202104/1401949-20210428115544168-953999303.png)

那undo log到底是该使用默认的配置放在系统表空间呢？还是该放在undo表空间呢？

这其实取决服务器使用的存储卷的类型。

如果是SSD存储，那推荐将undo info存放在 undo表空间中。

## 八、mysql表碎片清理和表空间收缩

**mysql表碎片清理和表空间收缩(即清理碎片后report_site_day.ibd文件磁盘空间减小,该方案基于独立表空间存储方式)**

OPTIMIZETABLE [tablename],当然这种方式只适用于独立表空间

**清除碎片的优点:**

  　　降低访问表时的IO,提高mysql性能,释放表空间降低磁盘空间使用率。

 

　　OPTIMIZE TABLE ipvacloud.report_site_day;对myisam表有用  对innodb也有用，系统会自动把它转成 ALTER TABLE  report_site_day ENGINE = Innodb; 这是因为optimize table的本质，就是alter table

所以不管myisam引擎还是innodb引擎都可以使用OPTIMIZE TABLE回收表空间。

　　mysql innodb引擎 长时间使用后，数据文件远大于实际数据量(即report_site_day.ibd文件越来越大)，导致空间不足。

就是我的mysql服务器使用了很久之后，发现\data\ipvacloud\report_site_day.ibd  目录的空间占满了我系统的整个空间，马上就要满了。

**MySQL5.5默认是共享表空间 ，5.6中默认是独立表空间(表空间管理类型就这2种)**
独立表空间 就是采用和MyISAM 相同的方式, 每个表拥有一个独立的数据文件( .idb )

1.每个表都有自已独立的表空间。
2.每个表的数据和索引都会存在自已的表空间中。
3.可以实现单表在不同的数据库中移动(将一个库的表移动到另一个库里,可以正常使用)。
4.drop table自动回收表空间 ，删除大量数据后可以通过alter table XX engine = innodb;回收空间。

> **InnoDB引擎 frm ibd文件说明：**
>    1.frm ：描述表结构文件，字段长度等
>
>    2.ibd文件 
>          **a如果采用独立表存储模式(5.6)，data\a中还会产生report_site_day.ibd文件（存储数据信息和索引信息）**
>
> 
>
> ​         D:\java\mysql5.6\data\ipvacloudreport_site_day.frm 和
>
> ​         D:\java\mysql5.6\data\ipvacloud\report_site_day.ibd
>
>
> ​         **b如果采用共享存储模式(5.5)，数据信息和索引信息都存储在ibdata1中**
> ​          (其D:\java\mysql5.6\data\目录下没有.ibd文件,只有frm文件)
> ![img](https://img-blog.csdn.net/2018052415405770?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzI5ODgzMTgz/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
> ​          D:\java\mysql5.5\data\ipvacloudreport_site_day.frm

```
查看当前数据库的表空间管理类型(on表示独立表空间开启,5.6默认开启独立)

脚本：show variables like "innodb_file_per_table";


mysql> show variables like "innodb_file_per_table";
```

**1、小结**

　　结合mysql官方网站的信息，个人是这样理解的。当你删除数据时，mysql并不会回收，被已删除数据的占据的存储空间，以及索引位。而是空在那里，而是等待新的数据来弥补这个空缺，这样就有一个缺少，如果一时半会，没有数据来填补这个空缺，那这样就太浪费资源了。所以对于写比较频烦的表，要定期进行optimize，一个月一次，看实际情况而定了。

举个例子来说吧。有100个php程序员辞职了，但是呢只是人走了，php的职位还在那里，这些职位不会撤销，要等新的php程序来填补这些空位。招一个好的程序员，比较难。我想大部分时间会空在那里。哈哈。

　　当我们使用mysql进行delete数据，delete完以后，发现空间文件ibd并没有减少，这是因为碎片空间的存在，举个例子，一共公司有10号员工，10个座位，被开除了7个员工，但这些座位还是保留的，碎片整理就像，让剩下的3个员工都靠边坐，然后把剩下的7个作为给砸掉，这样就能释放出空间了

 

　　好处除了减少表数据与表索引的物理空间，还能降低访问表时的IO，这个比较理解，整理之前，取数据需要跨越很多碎片空间，这时需要时间的，整理后，想要的数据都放在一起了，直接拿就拿到了，效率提高。

**2、手册中关于OPTIMIZE的一些用法(标红的为应用场景)和描述**

　　OPTIMIZE  TABLE tbl_name [, tbl_name] ...

**如果您已经****删除了表的一大部分****，或者如果您已经对含有可变长度行的表（含有VARCHAR, BLOB或TEXT列的表）进行了很多更改，则应使用OPTIMIZE TABLE。被删除的记录被保持在链接清单中，后续的INSERT操作会重新使用旧的记录位置。您可以使用OPTIMIZE TABLE来重新利用未使用的空间，并整理数据文件的碎片。**

> **碎片产生的原因** 
>
>  (删除时留白, 插入时尝试使用留白空间 (当删除后并未将所有留空的都插入数据,既可以认为未被立即使用的留空就是碎片)
>
> （1）表的存储会出现碎片化，每当删除了一行内容，该段空间就会变为被留空，而在一段时间内的大量删除操作，会使这种留空的空间变得比存储列表内容所使用的空间更大；
>
>  
>
> （2）当执行插入操作时，MySQL会尝试使用空白空间，但如果某个空白空间一直没有被大小合适的数据占用，仍然无法将其彻底占用，就形成了碎片；
>
> 
> （3）当MySQL对数据进行扫描时，它扫描的对象实际是列表的容量需求上限，也就是数据被写入的区域中处于峰值位置的部分；
>
> 一个表有1万行，每行10字节，会占用10万字节存储空间，执行删除操作，只留一行，实际内容只剩下10字节，但MySQL在读取时，仍看做是10万字节的表进行处理，所以，碎片越多，会降低访问表时的IO,影响查询性能。

**3、备注：**
1.MySQL官方建议不要经常(每小时或每天)进行碎片整理，一般根据实际情况，只需要每周或者每月整理一次即可。
2.OPTIMIZE TABLE只对MyISAM，BDB和InnoDB表起作用，尤其是MyISAM表的作用最为明显。此外，并不是所有表都需要进行碎片整理，一般只需要对包含上述可变长度的文本数据类型的表进行整理即可。
3.在OPTIMIZE TABLE 运行过程中，MySQL会锁定表。
4.默认情况下，直接对InnoDB引擎的数据表使用OPTIMIZE TABLE，可能会显示「 Table does not support optimize, doing recreate + analyze instead」的提示信息。这个时候，我们可以用mysqld --skip-new或者mysqld --safe-mode命令来重启MySQL，以便于让其他引擎支持OPTIMIZE TABLE。

**OPTIMIZE 操作会暂时锁住表,而且数据量越大,耗费的时间也越长,它毕竟不是简单查询操作。**

比较好的方式就是做个shell,定期检查mysql中 information_schema.TABLES字段,查看 DATA_FREE 字段,大于0话,就表示有碎片。

------

 

**问题产生:** 例如你有1个表格里面有约10000000条，大概10G的数据，但是你手动删除了5000000条数据，即约5G的数据，但是删除后，你会发现系统的空间还是占用了10G，

**解决方案:** 表空间收缩即D:\java\mysql5.6\data\ipvacloud\report_site_day.ibd文件变小。

```sql
create database frag_test;  

use frag_test; 
create table frag_test (c1 varchar(64));  

insert into frag_test values ('this is row 1');
insert into frag_test values ('this is row 2');
insert into frag_test values ('this is row 3');
insert into frag_test values ('this is row 4');
insert into frag_test values ('this is row 5');
SELECT * FROM frag_test;
 
-- 碎片查看(即查看frag_test库下所有表的状态,1条记录是1个表)  frag_test是库名   
-- 需要注意的是，“data_free”一栏显示出了我们删除一行后所产生的留空空间  删除前 Data_free: 0字节 删除一条记录后再查看碎片  Data_free: 20字节 
-- 如果没有及时插入,那么删除一条记录后,留空的20字节就变成碎片; 现在如果你将两万条记录删到只剩一行，
-- 列表中有用的内容将只占二十字节，但MySQL在读取中会仍然将其视同于一个容量为四十万字节的列表进行处理，并且除二十字节以外，其它空间都被白白浪费了。        


-- 现在我们删除一行，并再次检测:
delete from frag_test where c1 = 'this is row 2';  


-- 删除一条记录后再查看碎片  Data_free: 20字节 即留空了20字节  data_free 是碎片空间
show table status from frag_test;


--字段解释：

--Data_length : 数据的大小。

--Index_length: 索引的大小。

--Data_free :数据在使用中的留存空间，如果经常删改数据表，会造成大量的Data_free  频繁 删除记录 或修改有可变长度字段的表


-- data_free碎片空间  TABLE_SCHEMA后等于表名   (data_length+index_length)数据和数据索引的之和的空间  data_free/data_length+index_length>0.30 的表认为是需要清理碎片的表
select table_schema db,table_name,engine,table_rows,data_free,data_length+index_length length from information_schema.tables where TABLE_SCHEMA='frag_test';

-- table_schema db, table_name, data_free, engine依次表示 数据库名称 表名称 碎片所占字节空间  表引擎名称
-- 列出所有已经产生碎片的表 ('information_schema', 'mysql'这两个库是mysql自带的库)
select table_schema db, table_name, data_free, engine,table_rows,data_length+index_length length 
from information_schema.tables   where table_schema not in ('information_schema', 'mysql') and data_free > 0;





-- 库名.表名   清理2个表的碎片(逗号隔开即可) OPTIMIZE TABLE ipvacloud.article,ipvacloud.aspnet_users_viewway;  
-- 存储过程里的table_schema就是数据库名称 虽然提示 Table does not support optimize, doing recreate + analyze instead  该命令执行完毕后   返回命令,虽然提示不支持optimize，但是已经进行重建和分析，空间已经回收(即碎片得到整理,表空间得到回收)。  原来对于InnoDB 通过该命令还是有用的，OPTIMIZE TABLE ipvacloud.article;
OPTIMIZE TABLE ipvacloud.article;


-- 清除碎片操作会暂时锁表，数据量越大，耗费的时间越长 可以做个脚本，例如每月凌晨3点，检查DATA_FREE字段，
-- 大于自己认为的警戒值(碎片空间占数据和数据索引空间之和的百分比>0.30)的话，就清理一次

/*
清理mysql下实例下表碎片(当碎片字节空间占 数据字节与索引字节空间 之和大于0.30时, 这些表的碎片都需要清理,使用游标遍历清理) 定时任务事件 每月凌晨4点调用此清理表碎片的任务
table_schema是数据库名 OPTIMIZE TABLE ipvacloud.article;
*/
DROP PROCEDURE IF EXISTS `optimize_table`;
DELIMITER ;;
CREATE  PROCEDURE `optimize_table`()
BEGIN
    DECLARE tableSchema VARCHAR(100);
    DECLARE tableName VARCHAR(100);
    DECLARE stopFlag INT DEFAULT 0;
    -- 大于30%碎片率的清理
    DECLARE rs CURSOR FOR SELECT table_schema,table_name FROM information_schema.tables WHERE ((data_free/1024)/((data_length+index_length+data_free)/1024)) > 0.30;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET stopFlag = 1;
    OPEN rs;
        WHILE stopFlag <> 1 DO     
        FETCH NEXT FROM rs INTO tableSchema,tableName;
            IF stopFlag<>1 THEN 
                -- SET @table_optimize = CONCAT('ALTER TABLE `',tableName,'` ENGINE = INNODB');
                SET @table_optimize = CONCAT('OPTIMIZE TABLE `',table_schema,'`.`',tableName,'`');
                PREPARE sql_optimize FROM @table_optimize;    
                EXECUTE sql_optimize;
            END IF;
        END WHILE;
    CLOSE rs;
    END
;;
DELIMITER ;



/*
此定时任务 事件每月凌晨4点清理mysql实例下的表碎片
*/
DROP EVENT IF EXISTS `event_optimize_table`;
DELIMITER ;;
CREATE EVENT `event_optimize_table` ON SCHEDULE EVERY 1 MONTH STARTS '2017-12-15 04:00:00' ON COMPLETION PRESERVE ENABLE DO CALL optimize_table()
;;

DELIMITER ;
```

如何缩小共享表空间  optimize table xxx; 对共享表空间不起作用

如果不把数据分开存放的话，这个文件的大小很容易就上了G，甚至几十G。对于某些应用来说，并不是太合适。因此要把此文件缩小。

无法自动收缩，必须数据导出，删除ibdata1，然后数据导入(数据库变为独享表空间)
解决方法：数据文件单独存放(共享表空间如何改为每个表独立的表空间文件)。

本地mysql5.5创建一个ipvacloud库,将其他服务的1张表数据传输到本地的ipvacloud 
ibdata1(ibdata1存放数据和索引等)文件从18M增加到178M   其ipvacloud文件下只新增了frm文件 即D:\java\mysql5.5\data\ipvacloud\report_site_day.frm

 导出数据(navicat导出或mysqldump)
 关闭MySQL服务：
 删除ibdat1、ib_log*和应用数据库目录
 更改myini文件(在最后一行添加innodb_file_per_table=1)
 启动mysql   使用此命令看(ibdata1又回到初始的18M,ipvacoud已是空的) 独立表空间是否开启成功(on表示开启成功)show variables like '%per_table%';
 导入数据库 .sql文件(导入数据成功后ibdat1从18M增加到34M, 独立表空间有ibd文件,来存放数据和索引信息)

将表由共享表空间迁移到了独立表空间中，同时也是对共享表空间"瘦身"
\>mysqldump -h192.168.2.227 -u root -p ipvacloud site_all_info > d:456.sql

 

 

参考文章：

https://www.jb51.net/article/200547.htm

https://blog.51cto.com/xiaocao13140/2127856



## 典型应用

典型应用一：控制用户所占用的表空间配额。

在一些大型的数据库应用中，我们需要控制某个用户或者某一组用户其所占用的磁盘空间。这就好像在文件[服务器](https://baike.baidu.com/item/服务器)中，需要为每个用户设置[磁盘配额](https://baike.baidu.com/item/磁盘配额)一样，以防止硬盘空间耗竭。所以，在数据库中，我们也需要限制用户所可以使用的磁盘空间大小。为了达到这个目的，我们就可以通过表空间来实现。

我们可以在[Oracle数据库](https://baike.baidu.com/item/Oracle数据库/3710800)中，建立不同的表空间，为其设置最大的存储容量，然后把用户归属于这个表空间。如此的话，这个用户的存储容量，就受到这个表空间大小的限制。

典型应用二：控制数据库所占用的磁盘空间。

有时候，在Oracle数据库服务器运行过程中，可能运行不止一个服务。除了[数据库服务器](https://baike.baidu.com/item/数据库服务器)外，可能还有[邮件服务器](https://baike.baidu.com/item/邮件服务器)等应用系统服务器。为此，就需要先对Oracle数据库的磁盘空间作个规划，否则，当多个[应用程序服务](https://baike.baidu.com/item/应用程序服务)所占用的磁盘空间都无限增加时，最后可能导致各个服务都因为硬盘空间的耗竭而停止。所以，在同一台服务器上使用多个应用程序服务时，我们需要先为各个应用服务规划分配磁盘空间，各服务的磁盘空间都不能够超过我们分配的最大限额，或者超过后及时地提醒我们。只有这样，才能够避免因为磁盘空间的耗竭而导致各种应用服务的崩溃。

典型应用三：灵活放置表空间，提高数据库的输入输出性能。

[数据库管理员](https://baike.baidu.com/item/数据库管理员)还可以将不同类型的数据放置到不同的表空间中，这样可以明显提高数据库输入输出性能，有利于数据的[备份](https://baike.baidu.com/item/备份)与恢复等管理工作。因为我们数据库管理员在备份或者恢复数据的时候，可以按表空间来备份数据。如在设计一个大型的[分销系统](https://baike.baidu.com/item/分销系统)[后台数据库](https://baike.baidu.com/item/后台数据库)的时候，我们可以按省份建立表空间。与浙江省相关的数据文件放置在浙江省的表空间中，北京发生业务记录，则记录在北京这个表空间中。如此，当浙江省的业务数据出现错误的时候，则直接还原浙江省的表空间即可。很明显，这样设计，当某个表空间中的数据出现错误需要恢复的时候，可以避免对其他表空间的影响。

另外，还可以对表空间进行独立备份。当数据库容量比较大的时候，若一下子对整个数据库进行[备份](https://baike.baidu.com/item/备份)，显然会占用比较多的时间。虽然说Oracle数据库支持[热备份](https://baike.baidu.com/item/热备份)，但是在备份期间，会占用比较多的系统资源，从而造成数据库性能的下降。为此，当数据库容量比较大的时候，我们就需要进行设置多个表空间，然后规划各个表空间的备份时间，从而可以提高整个数据库的备份效率，降低备份对于数据库正常运行的影响。

典型应用四：大表的排序操作。

我们都知道，当表中的记录比较多的时候，对他们进行查询，速度会比较慢。第一次查询成功后，若再对其进行第二次重新排序，仍然需要这么多的时间。为此，我们在[数据库设计](https://baike.baidu.com/item/数据库设计)的时候，针对这种容量比较大的表对象，往往把它放在一个独立的表空间，以提高数据库的性能。

典型应用五：日志文件与数据文件分开放，提高数据库安全性。

默认情况下，日志文件与数据文件存放在同一表空间。但是，这对于数据库安全方面来说，不是很好。所以，我们在数据库设计的过程中，往往喜欢把日志文件，特别是重要日志文件，放在一个独立的表空间中，然后把它存放在另外一块硬盘上。如此的话，当存放数据文件的硬盘出现故障时，能够马上通过存放在另一个表空间的重做日志文件，对数据库进行修复，以减少企业因为数据丢失所带来的损失。

当然，表空间的优势还不仅仅这些，企业对于数据库的性能要求越高，或者数据库容量越大，则表空间的优势就会越大。



## 顺序关系

编辑

 播报

**建立表空间与建立用户的顺序关系**

在[数据库设计](https://baike.baidu.com/item/数据库设计)的时候，我们建议[数据库管理员](https://baike.baidu.com/item/数据库管理员)按如下顺序设置表空间。

**第一步：建立表空间。**

在设计数据库的时候，首先需要设计表空间。我们需要考虑，是只建立一个表空间呢，还是需要建立多个表空间，以及各个表空间的存放位置、[磁盘限额](https://baike.baidu.com/item/磁盘限额)等等。

到底设计多少个表空间合理，没有统一的说法，这主要根据企业的实际需求去判断。如企业需要对用户进行磁盘限额控制的，则就需要根据用户的数量来设置表空间。当企业的数据容量比较大，而其又对数据库的性能有比较高的要求时，就需要根据不同类型的数据，设置不同的表空间，以提高其输入输出性能。

**第二步：建立用户，并制定用户的默认表空间。**

在建立用户的时候，我们建议[数据库管理员](https://baike.baidu.com/item/数据库管理员)要指定用户的默认表空间。因为我们在利用[CREATE语句](https://baike.baidu.com/item/CREATE语句/15682272)创建[数据库对象](https://baike.baidu.com/item/数据库对象)，如数据库表的时候，其默认是存储在数据库的当前默认空间。若不指定用户默认表空间的话，则用户每次创建数据库对象的时候，都要指定表空间，显然，这不是很合理。

另外要注意，不同的表空间有不同的权限控制。用户对于表空间A具有完全控制权限，可能对于表空间B就只有查询权限，甚至连连接的权限的都没有。所以，合理为用户配置表空间的访问权限，也是提高数据库安全性的一个方法。





# [MySQL表空间详解](https://blog.csdn.net/XueyinGuo/article/details/119223154)

## 1 表空间总览

![在这里插入图片描述](https://img-blog.csdnimg.cn/00b5116842dc45bca827b5804136674a.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)

## 2 页面结构

![在这里插入图片描述](https://img-blog.csdnimg.cn/e3e4f898201d4611bb665a7abbf9e973.png)


其中页面的通用部分有：File Header和 File Trailer。

### 2.1 File Header组成

check sum：校验和
page offset：页号
prev & next：前后指针
LSN：页面最后修改对应的LSN
type：页面类型
undo、溢出页、新分配、索引页（数据页）…
flush LSN：仅在系统表空间中第一页定义，代表文件至少被刷新到了对应的LSN
space ID：属于哪个表空间

## 3 区和组的概念

![在这里插入图片描述](https://img-blog.csdnimg.cn/342d80ae49454e3c9b889c78e3c2dd42.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)

连续64页为一个区，一个区就是1MB，256个区为一组



区的提出是想解决，**索引页（也就是数据页）双向链表相邻的两个页物理距离可能比较远，这样就导致去磁盘加载页面的时候需要重新定位磁头，导致随机I/O，如果尽量的让页面距离更近，就会把随机IO换成顺序IO，**从而提高查询速度。

## 4 段的概念

有了区的概念之后还没结束，因为不把叶子节点和非叶子节点区分开来扫描结果还是不太理想的。

想象一下B+树形成的过程，**插入记录不断有新的页面（叶子节点）产生，同时也产生了很多索引页面（非叶子节点），如果把这些页面统统放到一个区里，那么叶子节点还是存在物理距离的。所以有了段的概念。**

叶子节点有自己的区，非叶子节点有自己的区，分别的区集合就是段。

所以一个索引会产生两个段：**非叶子节点段 和 叶子节点段。**

对于数据量小的表来说，一次分配一整个区还是浪费空间的，因为一个区就是1MB，两个段就是至少两个区，一个小表至少需要使用2MB吗？所以又有了**碎片区**的概念。

该开始向表中插入数据，段是从某个碎片区以单个页面来分配存储空间的
当某个段占用了32个碎片区页面之后，则以完整的去为单位来分配存储空间。
所以段的更精准的定义应该是：某些零散的页面和一些完整的区的集合。

## 5 区详解

### 5.1 区的四种状态

空闲区：没有任何页面被使用（直属表空间）
有剩余页面的碎片区（直属表空间）
没有剩余页面的碎片区（直属表空间）
属于某个段的区

### 5.2 区的管理:XDES Entry

![在这里插入图片描述](https://img-blog.csdnimg.cn/5ec1f42da8684b58bf207f9ecf0ee88c.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)


用上边这个结构体来管理每个区，**每个区都有一个自己的结构体！**

- Segment ID：所在段的ID
- List Node：每个区的管理结构体穿成链表
- State：四种状态
- Page State Bit Map ：16字节，128位，一个区64页，每两个bit对应一个页面，第一位表示页面是否空闲，第二位没使用

### 5.3 插入数据过程重捋

当段中数据比较少时，首先去表空间直属的【还有空闲页面的碎片区】申请一个零散页面，如果现在的【碎片区】已满，就去表空间中新申请一个区，然后把这个区变为表空间直属的【碎片区】，此时可以申请到零散页面，从而插入数据。
早晚有一天，新申请的这个【碎片区】也会没有空闲页面，把它变为【没有空闲页面的碎片区】之后，新申请一个【碎片区】。
数据比较多的时候，就直接申请一个段所属的区。

### 5.4 XDES Entry链表

我们怎么知道哪些区的状态是【有可用】哪些状态是【没有可用空闲页】的呢？当数据量足够大的时候，不能每次都遍历所有的XDES Entry。

所以就用到了这个链表结构。

#### 5.4.1 直属表空间的碎片区链表

![在这里插入图片描述](https://img-blog.csdnimg.cn/4f0e275433eb47c48c9c561782a26683.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)

#### 5.4.2 属于某个段的链表

当某个段占用32个碎片页面之后，就直接申请完整的区了。此时的区不再是表空间直属的了。所以还需要使用链表管理只属于某个区的链表。

链表形式跟上边一样。

每个索引B+树有两个段，每个段还有三个链表。

![在这里插入图片描述](https://img-blog.csdnimg.cn/8f495d8233a54d1f85586e5dd6a8a7d8.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)

#### 5.4.3 链表基地址管理

每个链表对应一个链表基节点（List Base Node）

![在这里插入图片描述](https://img-blog.csdnimg.cn/3984dcb8e6184b72b243cdbc66ac16e4.png)

## 6 段的管理

### 6.1 INODE Entry

段的精准的定义是：32个零散的页面和一些完整的区的集合。

每个段都定义了一个INODE Entry的数据结构来管理段。

![在这里插入图片描述](https://img-blog.csdnimg.cn/c0ced5d725ee4b9d8da37e6ec1d6a9ef.png)

## 7 FSP_HDR页面类型

### 7.1 第一组第一个页面

表空间的第一个页面

存储了表空间一些整体属性和第一个组内的256个区对应的XDES Entry结构

![在这里插入图片描述](https://img-blog.csdnimg.cn/ef96216958fb46079ec501e1a4d4dc80.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)

## 8 XDES页面类型

### 8.1 组的第一个页面

![在这里插入图片描述](https://img-blog.csdnimg.cn/27f44eda4ca04eb7abbaaf8c6a0abbcd.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)

## 9 IBUF_BITMAP页面类型

### 9.1 Change Buffer相关

每插入一条记录其实都是想B+树中插入记录，插入过程是先把这个记录插入到聚簇索引的页面中，然后插入到二级索引页面中。

虽然每个索引中断都是距离尽可能进的，但是这些段属于不同的索引，所以这些页面在表空间中仍然是随机分布，仍然会产生随机I/O，严重影响性能。

所以有了Change Buffer。其实他本质上也是一个B+树。

### 9.2 Change Buffer作用

当页面仍然在磁盘上时，那么该修改将先被暂存在Change Buffer中，之后服务器空闲，或者页面从磁盘载入内存中时，再将其修改合并到对应页面。

## 10 INODE类型页面

### 10.1 第一分组中第三个页面

当页面中的段超过85个，也就是INODE Entry超过85个时，一个页就存不下了。就需要使用额外的INODE类型页面存储这些结构。

![在这里插入图片描述](https://img-blog.csdnimg.cn/cdf1537cefe84108934c9aad3099bc8d.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)

### 10.2 存储INODE Entry

先看看Free链表是否为空，如果不为空，则取出第一个链表节点，放入该页面。如果接入这个Entry之后页面正好满了，就把这个页面放入FULL链表。
如果链表为空，就需要从表空间中申请一个页面，页面类型修改为INODE类型，放入FREE链表，把Entry放入新申请的页面中。

![在这里插入图片描述](https://img-blog.csdnimg.cn/0f71a4d9cc5b4d8e993367c3f70f4865.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1h1ZXlpbkd1bw==,size_16,color_FFFFFF,t_70)



## Catalog详解

按照SQL标准的解释，在SQL环境下Catalog和Schema都属于抽象概念，可以把它们理解为一个容器或者数据库对象命名空间中的一个层次，主要用来解决命名冲突问题。从概念上说，一个数据库系统包含多个Catalog，每个Catalog又包含多个Schema，而每个Schema又包含多个数据库对象(表、视图、字段等)，反过来讲一个数据库对象必然属于一个Schema，而该Schema又必然属于一个Catalog，这样我们就可以得到该数据库对象的完全限定名称从而解决命名冲突的问题了；例如数据库对象表的完全限定名称就可以表示为：Catalog名称.Schema名称.表名称。这里还有一点需要注意的是，ＳＱＬ标准并不要求每个数据库对象的完全限定名称是唯一的，就象域名一样，如果喜欢的话，每个ＩＰ地址都可以拥有多个域名。
从实现的角度来看，各种数据库系统对Catalog和Schema的支持和实现方式千差万别，针对具体问题需要参考具体的产品说明书，比较简单而常用的实现方式是使用数据库名作为Catalog名，使用用户名作为Schema名。

最后一点需要注意的是Schema这个单词，它在SQL环境下的含义与其在数据建模领域中的含义是完全不同的。在SQL环境下，Schema是一组相关的数据库对象的集合，Schema的名字为该组对象定义了一个命名空间，而在数据建模领域，Schema(模式)表示的是用形式语言描述的数据库的结构；简单来说，可以这样理解，数据建模所讲的Schema保存在SQL环境下相应Catalog中一个Schema下的表中，同时可以通过查询该Catalog中的另一个Schema下的视图而获取，具体细节不再赘述。
