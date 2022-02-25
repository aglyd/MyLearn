## [各种Oracle索引类型介绍](https://www.cnblogs.com/zszitman/p/9841105.html)

```
逻辑上：
Single column 单行索引
Concatenated 多行索引
Unique 唯一索引
NonUnique 非唯一索引
Function-based函数索引
Domain 域索引
 
物理上：
Partitioned 分区索引
NonPartitioned 非分区索引
B-tree：
Normal 正常型B树
Rever Key 反转型B树 
Bitmap 位图索引
 
索引结构：
B-tree：
适合与大量的增、删、改（OLTP）；
不能用包含OR操作符的查询；
适合高基数的列（唯一值多）
典型的树状结构；
每个结点都是数据块；
大多都是物理上一层、两层或三层不定，逻辑上三层；
叶子块数据是排序的，从左向右递增；
在分支块和根块中放的是索引的范围；
Bitmap:
适合与决策支持系统；
做UPDATE代价非常高；
非常适合OR操作符的查询； 
基数比较少的时候才能建位图索引；
 
树型结构：
索引头 
开始ROWID，结束ROWID（先列出索引的最大范围）
BITMAP
每一个BIT对应着一个ROWID，它的值是1还是0，如果是1，表示着BIT对应的ROWID有值
1. b-tree索引
Oracle数据库中最常见的索引类型是b-tree索引，也就是B-树索引，以其同名的计算科学结构命名。CREATE 
INDEX语句时，默认就是在创建b-tree索引。没有特别规定可用于任何情况。
2. 位图索引(bitmap index)
位图索引特定于该列只有几个枚举值的情况，比如性别字段，标示字段比如只有0和1的情况。
3. 基于函数的索引
比如经常对某个字段做查询的时候是带函数操作的，那么此时建一个函数索引就有价值了。
4. 分区索引和全局索引
这2个是用于分区表的时候。前者是分区内索引，后者是全表索引
5. 反向索引（REVERSE）
这个索引不常见，但是特定情况特别有效，比如一个varchar(5)位字段(员工编号)含值
（10001,10002,10033,10005,10016..）
这种情况默认索引分布过于密集，不能利用好服务器的并行
但是反向之后10001,20001,33001,50001,61001就有了一个很好的分布，能高效的利用好并行运算。
6.HASH索引
HASH索引可能是访问数据库中数据的最快方法，但它也有自身的缺点。集群键上不同值的数目必须在创建HASH集群之前就要知道。需要在创建HASH集群的时候指定这个值。使用HASH索引必须要使用HASH集群。
```

## 1.逻辑结构：

所谓逻辑结构就是数据与数据之间的关联关系，准确的说是数据元素之间的关联关系。

注：所有的数据都是由数据元素构成，数据元素是数据的基本构成单位。而数据元素由多个数据项构成。

逻辑结构有四种基本类型：集合结构、线性结构、树状结构和网络结构。也可以统一的分为线性结构和非线性结构。

## 2.物理结构：

数据的物理结构就是数据存储在磁盘中的方式。官方语言为：数据结构在计算机中的表示（又称映像）称为数据的物理结构，或称存储结构。它所研究的是数据结构在计算机中的实现方法，包括数据结构中元素的表示及元素间关系的表示。

而物理结构一般有四种：顺序存储，链式存储，散列，索引

## 3.逻辑结构的物理表示：

线性表的顺序存储则可以分为静态和非静态：静态存储空间不可扩展，初始时就定义了存储空间的大小，故而容易造成内存问题。

线性表的链式存储：通过传递地址的方式存储数据。

单链表：节点存储下一个节点的地址-------------->单循环链表：尾节点存储头结点的地址

双链表：节点存储前一个和后一个节点的地址，存储两个地址。---------------->双循环链表：尾节点存储头结点的地址。

## 4.高级语言应用：

数组是顺序存储

指针则是链式存储



---

# 二、[Oracle查询优化](https://blog.csdn.net/jinghwm/article/details/83495069)

## 五、索引Index的优化设计

### 1、管理组织索引

         索引可以大大加快数据库的查询速度，索引把表中的逻辑值映射到安全的RowID，因此索引能进行快速定位数据的物理地址。但是有些DBA发现，对一个大 型表建立的索引，并不能改善数据查询速度，反而会影响整个数据库的性能。这主要是和SGA的数据管理方式有关。ORACLE在进行数据块高速缓存管理时， 索引数据比普通数据具有更高的驻留权限，在进行空间竞争时，ORACLE会先移出普通数据。对一个建有索引的大型表的查询时，索引数据可能会用完所有的数 据块缓存空间，ORACLE不得不频繁地进行磁盘读写来获取数据，因此在对一个大型表进行分区之后，可以根据相应的分区建立分区索引。如果对这样大型表的 数据查询比较频繁，或者干脆不建索引。另外，DBA创建索引时，应尽量保证该索引最可能地被用于where子句中，如果对查询只简单地制定一个索引，并不 一定会加快速度，因为索引必须指定一个适合所需的访问路径。

### 2、聚簇的使用

Oracle提供了另一种方法来提高查询速度，就是聚簇（Cluster）。所谓聚簇，简单地说就是把几个表放在一起，按一定公共属性混合存放。聚簇根 据共同码值将多个表的数据存储在同一个Oracle块中，这时检索一组Oracle块就同时得到两个表的数据，这样就可以减少需要存储的Oracle块， 从而提高应用程序的性能。

### 3、优化设置的索引，

就必须充分利用才能加快数据库访问速度。ORACLE要使用一个索引， 有一些最基本的条件：1）、where子名中的这个字段，必须是复合索引的第一个字段；2）、where子名中的这个字段，不应该参与任何形式的计算。 Sal*(2*90/100)

## 六、多CPU和并行查询PQO(Parallel Query Option)方式的利用

### 1、尽量利用多个CPU处理器来执行事务处理和查询

CPU的快速发展使得ORACLE越来越重视对多CPU的并行技术的应用，一个数据库的访问工作可以用多个CPU相互配合来完成，加上分布式计算已经相 当普遍，只要可能，应该将数据库服务器和应用程序的CPU请求分开，或将CPU请求从一个服务器移到另一个服务器。对于多CPU系统尽量采用 Parallel Query Option(PQO,并行查询选项)方式进行数据库操作。

### 2、使用Parallel Query Option(PQO,并行查询选择)方式进行数据查询

   使用PQO方式不仅可以在多个CPU间分配SQL语句的请求处理，当所查询的数据处于不同的磁盘时，一个个独立的进程可以同时进行数据读取。

### 3、使用SQL*Loader Direct Path选项进行大量数据装载

使用该方法进行数据装载时，程序创建格式化数据块直接写入数据文件中，不要求数据库内核的其他I/O。

## 七、实施系统资源管理分配计划

ORACLE提供了Database Resource Manager（DRM,数据库资源管理器）来控制用户的资源分配，DBA可以用它分配用户类和作业类的系统资源百分比。在一个OLDP系统中，可给联机 用户分配75%的CPU资源，剩下的25%留给批用户。另外，还可以进行CPU的多级分配。除了进行CPU资源分配外，DRM还可以对资源用户组执行并行 操作的限制。

## 八、使用最和SQL优化方优的数据库连接案

### 1、使用直接的OLE DB数据库连接方式。

通过ADO可以使用两种方式连接数据库，一种是传统的ODBC方式，一种是OLE DB方式。ADO是建立在OLE DB技术上的，为了支持ODBC，必须建立相应的OLE DB到ODBC的调用转换，而使用直接的OLE DB方式则不需转换，从而提高处理速度。

### 2、使用Connection Pool机制

在数据库处理中，资源花销最大的是建立数据库连接，而且用户还会有一个较长的连接等待时间。解决的办法就是复用现有的Connection，也就是使用Connection Pool对象机制。

Connection Pool的原理是：IIS+ASP体系中维持了一个连接缓冲池，这样，当下一个用户访问时，直接在连接缓冲池中取得一个数据库连接，而不需重新连接数据库，因此可以大大地提高系统的响应速度。

### 3、高效地进行SQL语句设计

通常情况下，可以采用下面的方法优化SQL对数据操作的表现：

（1）减少对数据库的查询次数，即减少对系统资源的请求，使用快照和显形图等分布式数据库对象可以减少对数据库的查询次数。

（2）尽量使用相同的或非常类似的SQL语句进行查询，这样不仅充分利用SQL共享池中的已经分析的语法树，要查询的数据在SGA中命中的可能性也会大大增加。

（3）限制动态SQL的使用，虽然动态SQL很好用，但是即使在SQL共享池中有一个完全相同的查询值，动态SQL也会重新进行语法分析。

（4）避免不带任何条件的SQL语句的执行。没有任何条件的SQL语句在执行时，通常要进行FTS，数据库先定位一个数据块，然后按顺序依次查找其它数据，对于大型表这将是一个漫长的过程。

（5）如果对有些表中的数据有约束，最好在建表的SQL语句用描述完整性来实现，而不是用SQL程序中实现。

（6）可以通过取消自动提交模式，将SQL语句汇集一组执行后集中提交，程序还可以通过显式地用COMMIT和ROLLBACL进行提交和回滚该事务。

（7）检索大量数据时费时很长，设置行预取数则能改善系统的工作表现，设置一个最大值，当SQL语句返回行超过该值，数值库暂时停止执行，除非用户发出新的指令，开始组织并显示数据，而不是让用户继续等待。

## 九、充分利用数据的后台处理方案减少网络流量

### 1、合理创建临时表或视图

所谓创建临时表或视图，就是根据需要在数据库基础上创建新表或视图，对于多表关联后再查询信息的可建新表，对于单表查询的可创建视图，这样可充分利用数 据库的容量大、可扩充性强等特点，所有条件的判断、数值计算统计均可在数据库服务器后台统一处理后追加到临时表中，形成数据结果的过程可用数据库的过程或 函数来实现。

### 2、数据库打包技术的充分利用

利用数据库描述语言编写数据库的过程或函数，然后把过程或函数打成包在数据库后台统一运行包即可。

### 3、数据复制、快照、视图，远程过程调用技术的运用

数据复制，即将数据一次复制到本地，这样以后的查询就使用本地数据，但是只适合那些变化不大的数据。使用快照也可以在分布式数据库之间动态复制数据，定义 快照的自动刷新时间或手工刷新，以保证数据的引用参照完整性。调用远程过程也会大大减少因频繁的SQL语句调用而带来的网络拥挤。

总之，对所有的性能问题，没有一个统一的解决方法，但ORACLE提供了丰富的选择环境，可以从ORACLE数据库的体系结构、软件结构、模式对象 以及具体的业务和技术实现出发，进行统筹考虑。提高系统性能需要一种系统的整体的方法，在对数据库进行优化时，应对应用程序、I/O子系统和操作系统 （OS）进行相应的优化。优化是有目的地更改系统的一个或多个组件，使其满足一个或多个目标的过程。对Oracle来说，优化是进行有目的的调整组件级以 改善性能，即增加吞吐量，减少响应时间。如果DBA能从上述九个方面综合考虑优化方案，相信多数ORACLE应用可以做到按最优的方式来存取数据。



 我们要做到不但会写SQL,还要做到写出性能优良的SQL,以下为笔者学习、摘录、并汇总部分资料与大家分享！

（1）      选择最有效率的表名顺序(只在基于规则的优化器中有效)：

ORACLE的解析器按照从右到左的顺序处理FROM子句中的表名，FROM子句中写在最后的表(基础表 driving table)将被最先处理，在FROM子句中包含多个表的情况下,你必须选择记录条数最少的表作为基础表。

如果有3个以上的表连接查询, 那就需要选择交叉表(intersection table)作为基础表, 交叉表是指那个被其他表所引用的表.把数据少的表放在FROM后面的最后

（2）      WHERE子句中的连接顺序．：

ORACLE采用自下而上的顺序解析WHERE子句,根据这个原理,表之间的连接必须写在其他WHERE条件之前, 那些可以过滤掉最大数量记录的条件必须写在WHERE子句的末尾.

（3）      SELECT子句中避免使用 ‘ * ‘：

ORACLE在解析的过程中, 会将'*' 依次转换成所有的列名, 这个工作是通过查询数据字典完成的, 这意味着将耗费更多的时间

（4）      减少访问数据库的次数：

ORACLE在内部执行了许多工作: 解析SQL语句, 估算索引的利用率, 绑定变量 , 读数据块等；

（5）      在SQL*Plus , SQL*Forms和Pro*C中重新设置ARRAYSIZE参数, 可以增加每次数据库访问的检索数据量 ,建议值为200

（6）      使用DECODE函数来减少处理时间：******************************

使用DECODE函数可以避免重复扫描相同记录或重复连接相同的表.

 

```sql
decode (expression, search_1, result_1)
decode (expression, search_1, result_1, search_2, result_2)
decode (expression, search_1, result_1, search_2, result_2, ...., search_n, result_n)

 

decode (expression, search_1, result_1, default)
decode (expression, search_1, result_1, search_2, result_2, default)
decode (expression, search_1, result_1, search_2, result_2, ...., search_n, result_n, default)
```

decode函数比较表达式和搜索字，如果匹配，返回结果；如果不匹配，返回default值；如果未定义default值，则返回空值。

以下是一个简单测试，用于说明Decode函数的用法:

 

```
SQL> create table t as select username,default_tablespace,lock_date from dba_users;

 

Table created.

 

SQL> select * from t;

USERNAME                       DEFAULT_TABLESPACE             LOCK_DATE

------------------------------ ------------------------------ ---------

SYS                            SYSTEM

SYSTEM                         SYSTEM

OUTLN                          SYSTEM

CSMIG                          SYSTEM

SCOTT                           SYSTEM

EYGLE                          USERS

DBSNMP                         SYSTEM

WMSYS                          SYSTEM                         20-OCT-04

 

8 rows selected.

 

 

SQL> select username,decode(lock_date,null,'unlocked','locked') status from t;

 

USERNAME                       STATUS

------------------------------ --------

SYS                            unlocked

SYSTEM                         unlocked

OUTLN                          unlocked

CSMIG                          unlocked

SCOTT                          unlocked

EYGLE                          unlocked

DBSNMP                         unlocked

WMSYS                          locked

 

8 rows selected.

 

SQL> select username,decode(lock_date,null,'unlocked') status from t;

 

USERNAME                       STATUS

------------------------------ --------

SYS                            unlocked

SYSTEM                         unlocked

OUTLN                          unlocked

CSMIG                          unlocked

SCOTT                           unlocked

EYGLE                          unlocked

DBSNMP                         unlocked

WMSYS

8 rows selected.
```

（7）      整合简单,无关联的数据库访问：

如果你有几个简单的数据库查询语句,你可以把它们整合到一个查询中(即使它们之间没有关系)

（8）      删除重复记录：

最高效的删除重复记录方法 ( 因为使用了ROWID)例子：

DELETE FROM EMP E WHERE E.ROWID > (SELECT MIN(X.ROWID)

FROM EMP X WHERE X.EMP_NO = E.EMP_NO);

（9）      用TRUNCATE替代DELETE：

当删除表中的记录时,在通常情况下, 回滚段(rollback segments ) 用来存放可以被恢复的信息. 如果你没有COMMIT事务,ORACLE会将数据恢复到删除之前的状态(准确地说是恢复到执行删除命令之前的状况) 而当运用TRUNCATE时, 回滚段不再存放任何可被恢复的信息.当命令运行后,数据不能被恢复.因此很少的资源被调用,执行时间也会很短. (译者按: TRUNCATE只在删除全表适用,TRUNCATE是DDL不是DML)

（10） 尽量多使用COMMIT：

只要有可能,在程序中尽量多使用COMMIT, 这样程序的性能得到提高,需求也会因为COMMIT所释放的资源而减少:

COMMIT所释放的资源:

a. 回滚段上用于恢复数据的信息.

b. 被程序语句获得的锁

c. redo log buffer 中的空间

d. ORACLE为管理上述3种资源中的内部花费

（11） 用Where子句替换HAVING子句：

避免使用HAVING子句, HAVING 只会在检索出所有记录之后才对结果集进行过滤. 这个处理需要排序,总计等操作. 如果能通过WHERE子句限制记录的数目,那就能减少这方面的开销. (非oracle中)on、where、having这三个都可以加条件的子句中，on是最先执行，where次之，having最后，因为on是先把不 符合条件的记录过滤后才进行统计，它就可以减少中间运算要处理的数据，按理说应该速度是最快的，where也应该比having快点的，因为它过滤数据后 才进行sum，在两个表联接时才用on的，所以在一个表的时候，就剩下where跟having比较了。在这单表查询统计的情况下，如果要过滤的条件没有 涉及到要计算字段，那它们的结果是一样的，只是where可以使用rushmore技术，而having就不能，在速度上后者要慢如果要涉及到计算的字 段，就表示在没计算之前，这个字段的值是不确定的，根据上篇写的工作流程，where的作用时间是在计算之前就完成的，而having就是在计算后才起作 用的，所以在这种情况下，两者的结果会不同。在多表联接查询时，on比where更早起作用。系统首先根据各个表之间的联接条件，把多个表合成一个临时表 后，再由where进行过滤，然后再计算，计算完后再由having进行过滤。由此可见，要想过滤条件起到正确的作用，首先要明白这个条件应该在什么时候 起作用，然后再决定放在那里

（12） 减少对表的查询：

在含有子查询的SQL语句中,要特别注意减少对表的查询.例子：

                SELECT TAB_NAME FROM TABLES WHERE (TAB_NAME,DB_VER) = ( SELECT

TAB_NAME,DB_VER FROM TAB_COLUMNS WHERE VERSION = 604)

（13） 通过内部函数提高SQL效率.：

复杂的SQL往往牺牲了执行效率. 能够掌握上面的运用函数解决问题的方法在实际工作中是非常有意义的

（14） 使用表的别名(Alias)：

当在SQL语句中连接多个表时, 请使用表的别名并把别名前缀于每个Column上.这样一来,就可以减少解析的时间并减少那些由Column歧义引起的语法错误.

（15） 用EXISTS替代IN、用NOT EXISTS替代NOT IN：

在许多基于基础表的查询中,为了满足一个条件,往往需要对另一个表进行联接.在这种情况下, 使用EXISTS(或NOT EXISTS)通常将提高查询的效率. 在子查询中,NOT IN子句将执行一个内部的排序和合并. 无论在哪种情况下,NOT IN都是最低效的 (因为它对子查询中的表执行了一个全表遍历). 为了避免使用NOT IN ,我们可以把它改写成外连接(Outer Joins)或NOT EXISTS.

例子：

```sql
（高效）SELECT * FROM EMP (基础表) WHERE EMPNO > 0 AND EXISTS (SELECT 1 FROM DEPT WHERE DEPT.DEPTNO = EMP.DEPTNO AND LOC = ‘MELB')

(低效)SELECT * FROM EMP (基础表) WHERE EMPNO > 0 AND DEPTNO IN(SELECT DEPTNO FROM DEPT WHERE LOC = ‘MELB')
```

（16） 识别'低效执行'的SQL语句：

虽然目前各种关于SQL优化的图形化工具层出不穷,但是写出自己的SQL工具来解决问题始终是一个最好的方法：

```
SELECT EXECUTIONS , DISK_READS, BUFFER_GETS,

ROUND((BUFFER_GETS-DISK_READS)/BUFFER_GETS,2) Hit_radio,

ROUND(DISK_READS/EXECUTIONS,2) Reads_per_run,

SQL_TEXT

FROM V$SQLAREA

WHERE EXECUTIONS>0

AND BUFFER_GETS > 0

AND (BUFFER_GETS-DISK_READS)/BUFFER_GETS < 0.8

ORDER BY 4 DESC;
```

（17） 用索引提高效率：

索引是表的一个概念部分,用来提高检索数据的效率，ORACLE使用了一个复杂的自平衡B- tree结构. 通常,通过索引查询数据比全表扫描要快. 当ORACLE找出执行查询和Update语句的最佳路径时, ORACLE优化器将使用索引. 同样在联结多个表时使用索引也可以提高效率. 另一个使用索引的好处是,它提供了主键(primary key)的唯一性验证.。那些LONG或LONG RAW数据类型, 你可以索引几乎所有的列. 通常, 在大型表中使用索引特别有效. 当然,你也会发现, 在扫描小表时,使用索引同样能提高效率. 虽然使用索引能得到查询效率的提高,但是我们也必须注意到它的代价. 索引需要空间来存储,也需要定期维护, 每当有记录在表中增减或索引列被修改时, 索引本身也会被修改. 这意味着每条记录的INSERT , DELETE , UPDATE将为此多付出4 , 5 次的磁盘I/O . 因为索引需要额外的存储空间和处理,那些不必要的索引反而会使查询反应时间变慢.。定期的重构索引是有必要的.：在“系统维护清理”里有个“垃圾文件清 理”

ALTER INDEX REBUILD

（18） 用EXISTS替换DISTINCT：

当提交一个包含一对多表信息(比如部门表和雇员表)的查询时,避免在SELECT子句中使用DISTINCT. 一般可以考虑用EXIST替换, EXISTS 使查询更为迅速,因为RDBMS核心模块将在子查询的条件一旦满足后,立刻返回结果. 例子：

    (低效):
    SELECT DISTINCT DEPT_NO,DEPT_NAME FROM DEPT D , EMP E
    WHERE D.DEPT_NO = E.DEPT_NO
    
    (高效):
    
    SELECT DEPT_NO,DEPT_NAME FROM DEPT D WHERE EXISTS ( SELECT ‘X'
    FROM EMP E WHERE E.DEPT_NO = D.DEPT_NO);



（19） sql语句用大写的；因为oracle总是先解析sql语句，把小写的字母转换成大写的再执行

（20） 在java代码中尽量少用连接符“＋”连接字符串！

（21） 避免在索引列上使用NOT 通常，　

我们要避免在索引列上使用NOT, NOT会产生在和在索引列上使用函数相同的影响. 当ORACLE”遇到”NOT,他就会停止使用索引转而执行全表扫描.

（22） 避免在索引列上使用计算．

WHERE子句中，如果索引列是函数的一部分．优化器将不使用索引而使用全表扫描．

举例:

```sql
低效：
SELECT … FROM DEPT WHERE SAL * 12 > 25000;

高效:
SELECT … FROM DEPT WHERE SAL > 25000/12;
```

（23） 用>=替代>

```sql
高效:
SELECT * FROM EMP WHERE DEPTNO >=4

低效:
SELECT * FROM EMP WHERE DEPTNO >3
```

两者的区别在于, 前者DBMS将直接跳到第一个DEPT等于4的记录而后者将首先定位到DEPTNO=3的记录并且向前扫描到第一个DEPT大于3的记录.

（24） 用UNION替换OR (适用于索引列)

通常情况下, 用UNION替换WHERE子句中的OR将会起到较好的效果. 对索引列使用OR将造成全表扫描. 注意, 以上规则只针对多个索引列有效. 如果有column没有被索引, 查询效率可能会因为你没有选择OR而降低. 在下面的例子中, LOC_ID 和REGION上都建有索引.

```sql
高效:

SELECT LOC_ID , LOC_DESC , REGION

FROM LOCATION

WHERE LOC_ID = 10

UNION

SELECT LOC_ID , LOC_DESC , REGION

FROM LOCATION

WHERE REGION = “MELBOURNE”

低效:

SELECT LOC_ID , LOC_DESC , REGION

FROM LOCATION

WHERE LOC_ID = 10 OR REGION = “MELBOURNE”
```

如果你坚持要用OR, 那就需要返回记录最少的索引列写在最前面.

（25） 用IN来替换OR

这是一条简单易记的规则，但是实际的执行效果还须检验，在ORACLE8i下，两者的执行路径似乎是相同的．　

```sql
低效:

SELECT…. FROM LOCATION WHERE LOC_ID = 10 OR LOC_ID = 20 OR LOC_ID = 30

高效

SELECT… FROM LOCATION WHERE LOC_IN IN (10,20,30);
```

（26） 避免在索引列上使用IS NULL和IS NOT NULL

避免在索引中使用任何可以为空的列，ORACLE将无法使用该索引．对于单列索引，如果列包 含空值，索引中将不存在此记录. 对于复合索引，如果每个列都为空，索引中同样不存在此记录.　如果至少有一个列不为空，则记录存在于索引中．举例: 如果唯一性索引建立在表的A列和B列上, 并且表中存在一条记录的A,B值为(123,null) , ORACLE将不接受下一条具有相同A,B值（123,null）的记录(插入). 然而如果所有的索引列都为空，ORACLE将认为整个键值为空而空不等于空. 因此你可以插入1000 条具有相同键值的记录,当然它们都是空! 因为空值不存在于索引列中,所以WHERE子句中对索引列进行空值比较将使ORACLE停用该索引.

```sql
低效: (索引失效)

SELECT … FROM DEPARTMENT WHERE DEPT_CODE IS NOT NULL;

高效: (索引有效)

SELECT … FROM DEPARTMENT WHERE DEPT_CODE >=0;
```

（27） 总是使用索引的第一个列：

如果索引是建立在多个列上, 只有在它的第一个列(leading column)被where子句引用时,优化器才会选择使用该索引. 这也是一条简单而重要的规则，当仅引用索引的第二个列时,优化器使用了全表扫描而忽略了索引

（28） 用UNION-ALL 替换UNION ( 如果有可能的话)：

当SQL语句需要UNION两个查询结果集合时,这两个结果集合会以UNION-ALL的方 式被合并, 然后在输出最终结果前进行排序. 如果用UNION ALL替代UNION, 这样排序就不是必要了. 效率就会因此得到提高. 需要注意的是，UNION ALL 将重复输出两个结果集合中相同记录. 因此各位还是要从业务需求分析使用UNION ALL的可行性. UNION 将对结果集合排序,这个操作会使用到SORT_AREA_SIZE这块内存. 对于这块内存的优化也是相当重要的. 下面的SQL可以用来查询排序的消耗量

```sql
低效：

SELECT ACCT_NUM, BALANCE_AMT

FROM DEBIT_TRANSACTIONS

WHERE TRAN_DATE = '31-DEC-95'

UNION

SELECT ACCT_NUM, BALANCE_AMT

FROM DEBIT_TRANSACTIONS

WHERE TRAN_DATE = '31-DEC-95'

高效:

SELECT ACCT_NUM, BALANCE_AMT

FROM DEBIT_TRANSACTIONS

WHERE TRAN_DATE = '31-DEC-95'

UNION ALL

SELECT ACCT_NUM, BALANCE_AMT

FROM DEBIT_TRANSACTIONS

WHERE TRAN_DATE = '31-DEC-95'
```

（29） 用WHERE替代ORDER BY：

ORDER BY 子句只在两种严格的条件下使用索引.

ORDER BY中所有的列必须包含在相同的索引中并保持在索引中的排列顺序.

ORDER BY中所有的列必须定义为非空.

WHERE子句使用的索引和ORDER BY子句中所使用的索引不能并列.

例如:

表DEPT包含以下列:

>  DEPT_CODE PK NOT NULL
>
> DEPT_DESC NOT NULL
>
> DEPT_TYPE NULL

```sql
低效: (索引不被使用)

SELECT DEPT_CODE FROM DEPT ORDER BY DEPT_TYPE

高效: (使用索引)

SELECT DEPT_CODE FROM DEPT WHERE DEPT_TYPE > 0
```

（30） 避免改变索引列的类型:

当比较不同数据类型的数据时, ORACLE自动对列进行简单的类型转换.

假设 EMPNO是一个数值类型的索引列.

SELECT … FROM EMP WHERE EMPNO = ‘123'

实际上,经过ORACLE类型转换, 语句转化为:

SELECT … FROM EMP WHERE EMPNO = TO_NUMBER(‘123')

幸运的是,类型转换没有发生在索引列上,索引的用途没有被改变.

现在,假设EMP_TYPE是一个字符类型的索引列.

SELECT … FROM EMP WHERE EMP_TYPE = 123

这个语句被ORACLE转换为:

SELECT … FROM EMP WHERE TO_NUMBER(EMP_TYPE)=123

因为内部发生的类型转换, 这个索引将不会被用到! 为了避免ORACLE对你的SQL进行隐式的类型转换, 最好把类型转换用显式表现出来. 注意当字符和数值比较时, ORACLE会优先转换数值类型到字符类型

（31） 需要当心的WHERE子句:

某些SELECT 语句中的WHERE子句不使用索引. 这里有一些例子.

在下面的例子里, (1)‘!=' 将不使用索引. 记住, 索引只能告诉你什么存在于表中, 而不能告诉你什么不存在于表中. (2) ‘||'是字符连接函数. 就象其他函数那样, 停用了索引. (3) ‘+'是数学函数. 就象其他数学函数那样, 停用了索引. (4)相同的索引列不能互相比较,这将会启用全表扫描.

（32） a. 如果检索数据量超过30%的表中记录数.使用索引将没有显著的效率提高.

b. 在特定情况下, 使用索引也许会比全表扫描慢, 但这是同一个数量级上的区别. 而通常情况下,使用索引比全表扫描要块几倍乃至几千倍!

（33） 避免使用耗费资源的操作:

带有DISTINCT,UNION,MINUS,INTERSECT,ORDER BY的SQL语句会启动SQL引擎

执行耗费资源的排序(SORT)功能. DISTINCT需要一次排序操作, 而其他的至少需要执行两次排序. 通常, 带有UNION, MINUS , INTERSECT的SQL语句都可以用其他方式重写. 如果你的数据库的SORT_AREA_SIZE调配得好, 使用UNION , MINUS, INTERSECT也是可以考虑的, 毕竟它们的可读性很强

（34） 优化GROUP BY:

提高GROUP BY 语句的效率, 可以通过将不需要的记录在GROUP BY 之前过滤掉.下面两个查询返回相同结果但第二个明显就快了许多.

```sql
低效:

SELECT JOB , AVG(SAL)

FROM EMP

GROUP JOB

HAVING JOB = ‘PRESIDENT'

OR JOB = ‘MANAGER'

高效:

SELECT JOB , AVG(SAL)

FROM EMP

WHERE JOB = ‘PRESIDENT'

OR JOB = ‘MANAGER'

GROUP JOB
```

 

ORACLE查询或删除时指定使用索引的写法

查询时可以指定使用索引的写法。

SELECT   /*+ index(TB_ALIAS IX_G_COST3) */
TB_ALIAS.*
FROM g_Cost TB_ALIAS
WHERE Item_Two = 0
   AND Flight_Date >= To_Date('20061201', 'YYYYMMDD')
   AND Flight_Date <= To_Date('20061231', 'YYYYMMDD');

删除时也可以指定使用索引的写法。

DELETE   /*+ index(TB_ALIAS IX_G_COST1) */
FROM g_Cost TB_ALIAS
WHERE ITEM_NAME = '小时费';

相关资源：[**Oracle使用强制索引的方法与注意事项**](https://download.csdn.net/download/weixin_38697579/12826171?spm=1001.2101.3001.5697)





----

# [Oracle 建立索引及SQL优化](https://blog.csdn.net/suqi356/article/details/79281770)

一、建立数据库索引:

索引有单列索引和复合索引之说。

建设原则:

　1、索引应该经常建在Where 子句经常用到的列上。如果某个大表经常使用某个字段进行查询，并且检索行数小于总表行数的5%。则应该考虑。

　2、对于两表连接的字段，应该建立索引。如果经常在某表的一个字段进行Order By 则也经过进行索引。

　3、不应该在小表上建设索引。

优缺点:
　1、索引主要进行提高数据的查询速度。 当进行DML时，会更新索引。因此索引越多，则DML越慢，其需要维护索引。 因此在创建索引及DML需要权衡。

   2、当一个表的索引达到4个以上时，ORACLE的性能可能还是改善不了，因为OLTP系统每表超过5个索引即会降低性能，而且在一个sql 中， Oracle 从不能使用超过 5个索引

   3、索引可能产生碎片,因为记录从表中删除时,相应也从表的索引中删除.表释放的空间可以再用,而索引释放的空间却不能再用.频繁进行删除操作的被索引的表,应当阶段性地重建索引,以避免在索引中造成空间碎片,影响性能.在许可的条件下,也可以阶段性地truncate表,truncate命令删除表中所有记录,也删除索引碎片. （建立索引影响了删除和更新操作）

创建索引:
　单一索引:Create Index <Index-Name> On <Table_Name>(Column_Name);

　复合索引:Create Index <Index-Name> On emp(deptno,job); —>在emp表的deptno、job列建立索引。

　　select * from emp where deptno=66 and job='sals' ->走索引。

　　select * from emp where deptno=66 OR job='sals' ->将进行全表扫描。不走索引

　　select * from emp where deptno=66 ->走索引。

　　select * from emp where job='sals' ->进行全表扫描、不走索引。

　　如果在where 子句中有OR 操作符或单独引用Job 列(索引列的后面列) 则将不会走索引，将会进行全表扫描。

      同时在Oracle里用PL/SQL的F5可以对整个SQL查询来判断没加索引前和加完索引后的用时。

 


索引失效的情况:
　① Not Null/Null 如果某列建立索引,当进行Select * from emp where depto is not null/is null。 则会是索引失效。
　② 索引列上不要使用函数,SELECT Col FROM tbl WHERE substr(name ,1 ,3 ) = 'ABC'  或 SELECT Col FROM tbl WHERE name LIKE '%ABC%'  而 SELECT Col FROM tbl WHERE name LIKE 'ABC%' 会使用索引。

　③ 索引列上不能进行计算SELECT Col FROM tbl WHERE col / 10 > 10 则会使索引失效，应该改成SELECT Col FROM tbl WHERE col > 10 * 10

　④ 索引列上不要使用NOT （ != 、 <> ）如:SELECT Col FROM tbl WHERE col ! = 10 应该改成：SELECT Col FROM tbl WHERE col > 10 OR col < 10 。

 

二、关于SQL 性能优化

 

（一）ORACLE 性能优化主要方法
⑴硬件升级(CPU、内存、硬盘)：

     CPU：在任何机器中CPU的数据处理能力往往是衡量计算机性能的一个标志，并且ORACLE是一个提供并行能力的数据库系统，如果运行队列数目超过了CPU处理的数目，性能就会下降；
     内存：衡量机器性能的另外一个指标就是内存的多少了，在ORACLE中内存和我们在建数据库中的交换区进行数据的交换，读数据时，磁盘I/O必须等待物理I/O操作完成，在出现ORACLE的内存瓶颈时，我们第一个要考虑的是增加内存，由于I/O的响应时间是影响ORACLE性能的主要参数；
     网络条件：NET*SQL负责数据在网络上的来往，大量的SQL会令网络速度变慢。比如10M的网卡和100的网卡就对NET*SQL有非常明显的影响，还有交换机、集线器等等网络设备的性能对网络的影响很明显，建议在任何网络中不要试图用3个集线器来将网段互联。


⑵版本及参数设置




⑶应用程序设计（框架、调用方式---源代码）

     程序设计中的一个著名定律是20％的代码用去了80％的时间；
     两种方式优化：源代码的优化和SQL语句的优化。源代码的优化在时间成本和风险上代价很高；另一方面，源代码的优化对数据库系统性能的提升收效有限。
     DBMS处理查询计划的过程是这样的：在做完查询语句的词法、语法检查之后，将语句提交给DBMS的查询优化器，优化器做完代数优化和存取路径的优化之后，由预编译模块对语句进行处理并生成查询规划，然后在合适的时间提交给系统处理执行，最后将执行结果返回给用户。 


⑷SQL 语句优化:

 

当Oracle数据库拿到SQL语句时，其会根据查询优化器分析该语句，并根据分析结果生成查询执行计划。
也就是说，数据库是执行的查询计划，而不是Sql语句。
查询优化器有rule-based-optimizer(基于规则的查询优化器) 和Cost-Based-optimizer(基于成本的查询优化器)。
其中基于规则的查询优化器在10g版本中消失。
对于规则查询，其最后查询的是全表扫描。而CBO则会根据统计信息进行最后的选择。


①先执行From ->Where ->Group By->Order By，所以尽量避免全表扫。

②执行From 字句是从右往左进行执行。因此必须选择记录条数最少的表放在右边。　　

③对于Where字句其执行顺序是从后向前执行、因此可以过滤最大数量记录的条件必须写在Where子句的末尾，而对于多表之间的连接，则写在之前。因为这样进行连接时，可以去掉大多不重复的项。　　

④SELECT子句中避免使用(*)ORACLE在解析的过程中, 会将’*’ 依次转换成所有的列名, 这个工作是通过查询数据字典完成的, 这意味着将耗费更多的时间.但是在count(*)和count(1)的执行中不需要遵守上述内容，速度经过我测试是相同的。

⑤用UNION替换OR(适用于索引列)

　 union:是将两个查询的结果集进行追加在一起，它不会引起列的变化。 由于是追加操作，需要两个结果集的列数应该是相关的，并且相应列的数据类型也应该相当的。union 返回两个结果集，同时将两个结果集重复的项进行消除。 如果不进行消除，用UNOIN ALL.

   通常情况下, 用UNION替换WHERE子句中的OR将会起到较好的效果. 对索引列使用OR将造成全表扫描. 注意, 以上规则只针对多个索引列有效. 
   如果有column没有被索引, 查询效率可能会因为你没有选择OR而降低. 在下面的例子中, LOC_ID 和REGION上都建有索引.

　　高效:
　　SELECT ID , NAME
　　FROM LOCATION
　　WHERE ID = 1
　　UNION
　　SELECT ID , NAME
　　FROM LOCATION
　　WHERE NAME = “SUQI356”

　　低效:
　　SELECT ID , NAME 
　　FROM LOCATION
　　WHERE ID = 1 OR NAME = “SUQI356”
　　如果你坚持要用OR, 那就需要返回记录最少的索引列写在最前面.

⑥用EXISTS替代IN、用NOT EXISTS替代NOT IN和用（+）比用NOT IN更有效率
在许多基于基础表的查询中, 为了满足一个条件, 往往需要对另一个表进行联接. 在这种情况下, 使用EXISTS(或NOT EXISTS)通常将提高查询的效率. 
在子查询中, NOT IN子句将执行一个内部的排序和合并. 无论在哪种情况下, NOT IN都是最低效的(因为它对子查询中的表执行了一个全表遍历). 
为了避免使用NOT IN, 我们可以把它改写成外连接(Outer Joins)或NOT EXISTS.

例子：

高效: SELECT * FROM EMP (基础表) WHERE EMPNO > 0 AND EXISTS (SELECT ‘X’ FROM DEPT WHERE DEPT.DEPTNO = EMP.DEPTNO AND LOC = ‘MELB’)

低效: SELECT * FROM EMP (基础表) WHERE EMPNO > 0 AND DEPTNO IN(SELECT DEPTNO FROM DEPT WHERE LOC = ‘MELB’)

⑦ORACLE的解析器按照从右到左的顺序处理FROM子句中的表名,因此FROM子句中写在最后的表(基础表 driving table)将被最先处理，在FROM子句中包含多个表的情况下,你必须选择记录条数最少的表作为基础表。如果有3个以上的表连接查询, 那就需要选择交叉表(intersection table)作为基础表, 交叉表是指那个被其他表所引用的表 。

⑧避免使用HAVING子句, HAVING 只会在检索出所有记录之后才对结果集进行过滤，这个处理需要排序、总计等操作； 如果能通过WHERE子句限制记录的数目,那就能减少这方面的开销.

  ⑨尽可能使用varchar代替char，因为变长字段存储空间小，在一个相对较小的字段内搜索效率要高。

  ⑩使用临时表来存储



