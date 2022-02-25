# [ORACLE 中ROWNUM用法总结!][https://blog.csdn.net/qq_39196949/article/details/84379874]

假设某个表 t1(c1) 有 20 条记录

如果用 select rownum,c1 from t1 where rownum < 10, 只要是用小于号，查出来的结果很容易地与一般理解在概念上能达成一致，应该不会有任何疑问的。

可如果用 select rownum,c1 from t1 where rownum > 10 (如果写下这样的查询语句，这时候在您的头脑中应该是想得到表中后面10条记录)，你就会发现，显示出来的结果要让您失望了，也许您还会怀疑是不谁删了一 些记录，然后查看记录数，仍然是 20 条啊？那问题是出在哪呢？

先好好理解 rownum 的意义吧。因为ROWNUM是对结果集加的一个伪列，即先查到结果集之后再加上去的一个列 (强调：先要有结果集)。简单的说 rownum 是对符合条件结果的序列号。它总是从1开始排起的。所以你选出的结果不可能没有1，而有其他大于1的值。所以您没办法期望得到下面的结果集：

11 aaaaaaaa
12 bbbbbbb
13 ccccccc
.................

rownum >10 没有记录，因为第一条不满足去掉的话，第二条的ROWNUM又成了1，所以永远没有满足条件的记录。或者可以这样理解：

ROWNUM是一个序列，是oracle数据库从数据文件或缓冲区中读取数据的顺序。它取得第一条记录则rownum值为1，第二条为2，依次类 推。如果你用>,>=,=,between...and这些条件，因为从缓冲区或数据文件中得到的第一条记录的rownum为1，则被删除， 接着取下条，可是它的rownum还是1，又被删除，依次类推，便没有了数据。

有了以上从不同方面建立起来的对 rownum 的概念，那我们可以来认识使用 rownum 的几种现像

1. select rownum,c1 from t1 where rownum != 10 为何是返回前9条数据呢？它与 select rownum,c1 from tablename where rownum < 10 返回的结果集是一样的呢？
因为是在查询到结果集后，显示完第 9 条记录后，之后的记录也都是 != 10,或者 >=10,所以只显示前面9条记录。也可以这样理解，rownum 为9后的记录的 rownum为10，因条件为 !=10，所以去掉，其后记录补上，rownum又是10，也去掉，如果下去也就只会显示前面9条记录了

2. 为什么 rownum >1 时查不到一条记录，而 rownum >0 或 rownum >=1 却总显示所以的记录
因为 rownum 是在查询到的结果集后加上去的，它总是从1开始

3. 为什么 between 1 and 10 或者 between 0 and 10 能查到结果，而用 between 2 and 10 却得不到结果
原因同上一样，因为 rownum 总是从 1 开始

从上可以看出，任何时候想把 rownum = 1 这条记录抛弃是不对的，它在结果集中是不可或缺的，少了rownum=1 就像空中楼阁一般不能存在，所以你的 rownum 条件要包含到 1

但如果就是想要用 rownum > 10 这种条件的话话就要用嵌套语句,把 rownum 先生成，然后对他进行查询。
select * 
from (selet rownum as rn，t1.* from a where ...)
where rn >10

一般代码中对结果集进行分页就是这么干的。

另外：rowid 与 rownum 虽都被称为伪列，但它们的存在方式是不一样的，rowid 可以说是物理存在的，表示记录在表空间中的唯一位置ID，在DB中唯一。只要记录没被搬动过，rowid是不变的。rowid 相对于表来说又像表中的一般列，所以以 rowid 为条件就不会有 rownum那些情况发生。
另外还要注意：rownum不能以任何基表的名称作为前缀。
------------------------------------------------


# [rownum 用法][https://blog.csdn.net/qq_35893120/article/details/70810704]

***\**\*对于rownum来说它是oracle系统顺序分配为从\*\*查询\*\*返回的行的编号，返回的第一行分配的是1，第二行是2，依此类推，这个伪字段可以用于限制查询返回的总行数，且rownum不能以任何表的名称作为前缀。\*\**\***

**(1) rownum 对于等于某值的查询条件
\*\*如果希望找到学生表中第一条学生的信息，可以使用rownum=1作为条件。但是想找到学生表中第二条学生的信息，使用rownum=2结果查不到数据。因为rownum都是从1开始，但是1以上的自然数在rownum做等于判断是时认为都是false条件，所以无法查到rownum = n（n>1的自然数）。
SQL> select rownum,id,name from student where rownum=1;（可以用在限制返回记录条数的地方，保证不出错，如：隐式游标）
SQL> select rownum,id,name from student where rownum =2;
  ROWNUM ID   NAME
---------- ------ ---------------------------------------------------\*\**\***

***\**\*（2）rownum对于大于某值的查询条件
  如果想找到从第二行记录以后的记录，当使用rownum>2是查不出记录的，原因是由于rownum是一个总是从1开始的伪列，Oracle 认为rownum> n(n>1的自然数)这种条件依旧不成立，所以查不到记录。

查找\*\*\*\*到第二行以后的记录可使用以下的子查询方法来解决。注意子查询中的rownum必须要有别名，否则还是不会查出记录来，这是因为rownum不是某个表的列，如果不起别名的话，无法知道rownum是子查询的列还是主查询的列。
SQL>select \* from(select rownum no ,id,name from student) where no>2;
    NO ID   NAME
---------- ------ ---------------------------------------------------
     3 200003 李三
     4 200004 赵四\*\**\***

***\**\*（3）rownum对于小于某值的查询条件
rownum对于rownum<n（(n>1的自然数）的条件认为是成立的，所以可以找到记录。
SQL> select rownum,id,name from student where rownum <3;
  ROWNUM ID   NAME
---------- ------ ---------------------------------------------------
    1 200001 张一
    2 200002 王二\*\**\***

***\*查询\*\*rownum在某区间的数据，必须使用子查询。\*\*\*\*例如要查询rownum在第二行到第三行之间的数据，包括第二行和第三行数据，那么我们只能写以下语句，先让它返回小于等于三的记录行，然后在主查询中判断新的rownum的别名列大于等于二的记录行。但是\*\*\*\*这样的操作会在大数据集中影响速度。
SQL> select \* from (select rownum no,id,name from student where rownum<=3 ) where no >=2;
    NO ID   NAME
---------- ------ ---------------------------------------------------
     2 200002 王二
     3 200003 李三\*\**\***

***\**\*（4）rownum和排序 
Oracle中的rownum的是在取数据的时候产生的序号，所以\*\*\*\*想对指定排序的数据去指定的rowmun行数据就必须注意了。
SQL> select rownum ,id,name from student order by name;
  ROWNUM ID   NAME
---------- ------ ---------------------------------------------------
     3 200003 李三
     2 200002 王二
     1 200001 张一
     4 200004 赵四
可以看出，rownum并不是按照name列来生成的序号。系统是按照记录插入时的顺序给记录排的号，rowid也是顺序分配的。为了解决这个问题，\*\*\*\*必须使用子查询；
SQL> select rownum ,id,name from (select \* from student order by name);
  ROWNUM ID   NAME
---------- ------ ---------------------------------------------------
     1 200003 李三
     2 200002 王二
     3 200001 张一
     4 200004 赵四
这样就成了按name排序，并且用rownum标出正确序号（有小到大）
笔者在工作中有一上百万\*\*\*\*条记录的表，在jsp页面中需对该表进行分页显示，便考虑用rownum来作，下面是具体方法(每页显示20条)：
“select \* from tabname where rownum<20 order by name" 但却发现oracle却不能按自己的意愿来执行，而是先随便取20条记录，然后再order by，后经咨询oracle,说rownum确实就这样，想用的话，只能用子查询来实现先排序，后rownum，方法如下：
"select \* from (select \* from tabname order by name) where rownum<20",但这样一来，效率会低很多。
后经笔者试验，只需在order by 的字段上加主键或索引即可让oracle先按该字段排序，然后再rownum；方法不变：  “select \* from tabname where rownum<20 order by name"\*\**\***

***\**\*取得某列中\*\*第N\*\*大的行\*\**\***

***\**\*select column_name from
(select table_name.\*,dense_rank() over (order by column desc) rank from table_name)
where rank = &N；
　假如要返回前5条记录：\*\**\***

　　***\**\*select \* from tablename where rownum<6;(或是rownum <= 5 或是rownum != 6)
假如要返回第5-9条记录：\*\**\***

***\**\*select \* from tablename
where …
and rownum<10
minus
select \* from tablename
where …
and rownum<5
order by name
选出结果后用name排序显示结果。(先选再排序)\*\**\***

***\**\*注意：只能用以上符号(<、<=、!=)。\*\**\***

***\**\*select \* from tablename where rownum != 10;返回的是前９条记录。
不能用：>,>=,=,Between...and。由于rownum是一个总是从1开始的伪列，Oracle 认为这种条件不成立。\*\**\***

***\**\*另外，这个方法更快：\*\**\***

***\**\*select \* from (
select rownum r,a from yourtable
where rownum <= 20
order by name )
where r > 10
这样取出第11-20条记录!(先选再排序再选)\*\**\***

***\**\*要先排序再选则须用select嵌套：内层排序外层选。
rownum是随着结果集生成的，一旦生成，就不会变化了；同时,生成的结果是依次递加的，没有1就永远不会有2!
rownum 是在查询集合产生的过程中产生的伪列，并且如果where条件中存在 rownum 条件的话，则:\*\**\***

***\**\*1： 假如判定条件是常量，则：
只能 rownum = 1, <= 大于1 的自然数， = 大于1 的数是没有结果的；大于一个数也是没有结果的
即 当出现一个 rownum 不满足条件的时候则 查询结束 this is stop key（一个不满足，系统将该记录过滤掉，则下一条记录的rownum还是这个，所以后面的就不再有满足记录，this is stop key）；\*\**\***

***\**\*2： 假如判定值不是常量，则：\*\**\***

***\**\*若条件是 = var , 则只有当 var 为1 的时候才满足条件，这个时候不存在 stop key ,必须进行full scan ,对每个满足其他where条件的数据进行判定，选出一行后才能去选rownum=2的行……\*\**\***

 