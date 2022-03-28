# 一、[MVCC 原理](https://zhuanlan.zhihu.com/p/147372839)

**事务的4个隔离级别**

- 读未提交
- 读已提交
- 可重复读
- 串行化



- 什么是脏读

简单说，读了一条未提交的数据

- 什么是不可重复读？

一个事务读取了另外一个事务**修改**后记录 强调的是 update 和delete ,只需要锁住满足条件的记录即可

- 什么是幻读

一个事务读取了另外一个事务**插入**的数据，强调的是 insert ，要锁住满足条件及相近的记录。

MYSQL 中默认的隔离级别是可重复读，可解决脏读和不可重复读的问题。但是不能解决幻读的问题。 Oracle 默认的是Read Commit 读已提交，可以避免脏读的问题。

## **MVCC 用来解决什么问题？**

一般解决不可重复读和幻读问题，是采用锁机制实现，有没有一种乐观锁的问题去处理，可以采用 MVCC 机制的设计，可以用来解决这个问题。取代行锁，降低系统开销。

### **MVCC 是啥？**

MVCC 的英文全称是 Multiversion Concurrency Control ，中文意思是多版本并发控制技术。原理是，通过数据行的多个版本管理来实现数据库的并发控制，简单来说就是保存数据的历史版本。可以通过比较版本号决定数据是否显示出来。读取数据的时候不需要加锁可以保证事务的隔离效果。

### **MVCC 可以解决什么问题？**

- 读写之间阻塞的问题，通过 MVCC 可以让读写互相不阻塞，读不相互阻塞，写不阻塞读，这样可以提升数据并发处理能力。
- 降低了死锁的概率，这个是因为 MVCC 采用了乐观锁的方式，读取数据时，不需要加锁，写操作，只需要锁定必要的行。
- 解决了一致性读的问题，当我们朝向某个数据库在时间点的快照是，只能看到这个时间点之前事务提交更新的结果，不能看到时间点之后事务提交的更新结果。

### **什么是快照读？**

快照读，读取的是**快照数据**，不加锁的简单 Select 都属于快照读.

```sql
SELECT * FROM player WHERE ...
```

## **什么是当前读？**

当前读就是读的是**最新数据**,而不是历史的数据，加锁的 SELECT，或者对数据进行增删改都会进行当前读。

```sql
SELECT * FROM player LOCK IN SHARE MODE;
SELECT FROM player FOR UPDATE;
INSERT INTO player values ...
DELETE FROM player WHERE ...
UPDATE player SET ...
```

## **InnoDB 的 MVCC 是如何实现的？**

InnoDB 是如何存储记录多个版本的？这些数据是 事务版本号，行记录中的隐藏列和Undo Log。

### **事务版本号**

每开启一个日志，都会从数据库中获得一个事务ID（也称为事务版本号），这个事务 ID 是自增的，通过 ID 大小，可以判断事务的时间顺序。

### **行记录的隐藏列**

1. row_id :隐藏的行 ID ,用来生成默认的聚集索引。如果创建数据表时没指定聚集索引，这时 InnoDB 就会用这个隐藏 ID 来创建聚集索引。采用聚集索引的方式可以提升数据的查找效率。
2. trx_id: 操作这个数据事务 ID ，也就是最后一个对数据插入或者更新的事务 ID 。
3. roll_ptr:回滚指针，指向这个记录的 Undo Log 信息。





### **Undo Log**

InnoDB 将行记录快照保存在 Undo Log 里。



数据行通过快照记录都通过链表的结构的串联了起来，每个快照都保存了 trx_id 事务ID，如果要找到历史快照，就可以通过遍历回滚指针的方式进行查找。

## **Read View 是啥？**

如果一个事务要查询行记录，需要读取哪个版本的行记录呢？ Read View 就是来解决这个问题的。Read View 可以帮助我们解决可见性问题。 Read View 保存了**当前事务开启时所有活跃的事务列表**。换个角度，可以理解为: **Read View 保存了不应该让这个事务看到的其他事务 ID 列表。**

1. trx_ids 系统当前正在活跃的事务ID集合。
2. low_limit_id ,ReadView生成时刻系统尚未分配的下一个事务ID（最大事务ID）
3. up_limit_id 活跃的事务中最小的事务 ID。
4. creator_trx_id，创建这个 ReadView 的事务ID。

### **ReadView**

如果当前事务的 creator_trx_id 想要读取某个行记录，这个行记录ID 的trx_id ，这样会有以下的情况：

- 如果 trx_id < 活跃的最小事务ID（up_limit_id）,也就是说这个行记录在**这些活跃的事务创建前就已经提交了，那么这个行记录对当前事务是可见的。**
- 如果trx_id > 活跃的最大事务ID（low_limit_id），这个说明行记录在这些活跃的事务之后才创建，说明**这个行记录对当前事务是不可见的。**
- 如果 up_limit_id < trx_id <low_limit_id,说明该记录需要在 trx_ids 集合中，可能还处于活跃状态，因此我们需要在 trx_ids 集合中遍历 ，如果trx_id 存在于 trx_ids 集合中，证明这个事务 trx_id 还处于活跃状态，不可见，否则 ，trx_id 不存在于 trx_ids 集合中，说明事务trx_id 已经提交了，这行记录是可见的。

## **如何查询一条记录**

1. 获取事务自己的版本号，即 事务ID
2. 获取 Read View
3. 查询得到的数据，然后 Read View 中的事务版本号进行比较。
4. 如果不符合 ReadView 规则， 那么就需要 UndoLog 中历史快照；
5. 最后返回符合规则的数据

InnoDB 实现多版本控制 （MVCC）是通过 ReadView+ UndoLog 实现的，UndoLog 保存了历史快照，ReadView 规则帮助判断当前版本的数据是否可见。

## **总结**

- 如果事务隔离级别是 ReadCommit ，一个事务的每一次 Select 都会去查一次ReadView ，每次查询的Read View 不同，就可能会造成不可重复读或者幻读的情况。
- 如果事务的隔离级别是可重读，为了避免不可重读读，一个事务只在第一次 Select 的时候会获取一次Read View ，然后后面索引的Select 会复用这个 ReadView.



----



# 二、[MVCC详解 ](https://www.cnblogs.com/xuwc/p/13873611.html)

参考：

https://blog.csdn.net/SnailMann/article/details/94724197

https://blog.csdn.net/DILIGENT203/article/details/100751755

https://blog.csdn.net/whoamiyang/article/details/51901888

https://techlog.cn/article/list/10183403

 

 

 

# 正确的理解MySQL的MVCC及实现原理

！首先声明，MySQL的测试环境是5.7

- 前提概要
  - 什么是MVCC
  - 什么是当前读和快照读？
  - 当前读，快照读和MVCC的关系
- MVCC实现原理
  - 隐式字段
  - undo日志
  - Read View(读视图)
  - 整体流程
- MVCC相关问题
  - RR是如何在RC级的基础上解决不可重复读的？
  - RC,RR级别下的InnoDB快照读有什么不同？



### 前提概要

------

#### 什么是MVCC?

> MVCC
> `MVCC`，全称`Multi-Version Concurrency Control`，即多版本并发控制。MVCC是一种并发控制的方法，一般在数据库管理系统中，实现对数据库的并发访问，在编程语言中实现事务内存。
> [mvcc - @百度百科](https://baike.baidu.com/item/MVCC/6298019?fr=aladdin)
>
>  
>
> 多版本控制: 指的是一种提高并发的技术。最早的数据库系统，只有读读之间可以并发，读写，写读，写写都要阻塞。引入多版本之后，**只有写写之间相互阻塞，其他三种操作都可以并行**，这样大幅度提高了InnoDB的并发度。在内部实现中，与Postgres在数据行上实现多版本不同，InnoDB是在undolog中实现的，通过undolog可以找回数据的历史版本。找回的数据历史版本可以提供给用户读(按照隔离级别的定义，有些读请求只能看到比较老的数据版本)，也可以在回滚的时候覆盖数据页上的数据。在InnoDB内部中，会记录一个全局的活跃读写事务数组，其主要用来判断事务的可见性。
> MVCC是一种多版本并发控制机制。

MVCC在MySQL InnoDB中的实现主要是为了提高数据库并发性能，用更好的方式去处理读-写冲突，做到即使有读写冲突时，也能做到不加锁，非阻塞并发读

------

#### 什么是当前读和快照读？

在学习MVCC多版本并发控制之前，我们必须先了解一下，什么是MySQL InnoDB下的`当前读`和`快照读`?

- 当前读
  像select lock in share mode(`共享锁`), select for update ; update, insert ,delete(`排他锁`)这些操作都是一种**当前读，为什么叫当前读？就是它读取的是记录的最新版本，读取时还要保证其他并发事务不能修改当前记录，会对读取的记录进行加锁**
- 快照读
  像`不加锁`的select操作就是快照读，即不加锁的非阻塞读；快照读的前提是隔离级别不是串行级别，串行级别下的快照读会退化成当前读；之所以出现快照读的情况，是基于提高并发性能的考虑，快照读的实现是基于多版本并发控制，即MVCC,可以认为MVCC是行锁的一个变种，但它在很多情况下，避免了加锁操作，降低了开销；既然是基于多版本，即快照读可能读到的并不一定是数据的最新版本，而有可能是之前的历史版本

说白了MVCC就是**为了实现读-写冲突不加锁，而这个读指的就是`快照读`, 而非当前读，当前读实际上是一种加锁的操作，是悲观锁的实现**

------

#### 当前读，快照读和MVCC的关系

- 准确的说，MVCC多版本并发控制指的是 “维持一个数据的多个版本，使得读写操作没有冲突” 这么一个概念。**仅仅是一个理想概念**
- 而在MySQL中，实现这么一个MVCC理想概念，我们就需要MySQL提供具体的功能去实现它，而快照读就是MySQL为我们实现MVCC理想模型的其中一个具体非阻塞读功能。而相对而言，**当前读就是悲观锁的具体功能实现**
- 要说的再细致一些，快照读本身也是一个抽象概念，再深入研究。MVCC模型在MySQL中的具体实现则是由 `3个隐式字段`，`undo日志` ，`Read View` 等去完成的，具体可以看下面的MVCC实现原理

------

#### MVCC能解决什么问题，好处是？

数据库并发场景有三种，分别为：

- `读-读`：不存在任何问题，也不需要并发控制
- `读-写`：有线程安全问题，可能会造成事务隔离性问题，可能遇到脏读，幻读，不可重复读
- `写-写`：有线程安全问题，可能会存在更新丢失问题，比如第一类更新丢失，第二类更新丢失

备注：第1类丢失更新：事务A撤销时，把已经提交的事务B的更新数据覆盖了；第2类丢失更新：事务A覆盖事务B已经提交的数据，造成事务B所做的操作丢失

 

MVCC带来的好处是？
多版本并发控制（MVCC）是一种用来解决`读-写冲突`的无锁并发控制，也就是为事务分配单向增长的时间戳，为每个修改保存一个版本，版本与事务时间戳关联，读操作只读该事务开始前的数据库的快照。 所以MVCC可以为数据库解决以下问题

- 在并发读写数据库时，可以做到在读操作时不用阻塞写操作，写操作也不用阻塞读操作，提高了数据库并发读写的性能
- 同时还可以解决脏读，幻读，不可重复读等事务隔离问题，但不能解决更新丢失问题

小结一下咯
总之，MVCC就是因为大牛们，不满意只让数据库采用悲观锁这样性能不佳的形式去解决读-写冲突问题，而提出的解决方案，所以在数据库中，因为有了MVCC，所以我们可以形成两个组合：

- `MVCC + 悲观锁`
  MVCC解决读写冲突，悲观锁解决写写冲突
- `MVCC + 乐观锁`
  MVCC解决读写冲突，乐观锁解决写写冲突

这种组合的方式就可以最大程度的提高数据库并发性能，并解决读写冲突，和写写冲突导致的问题



### MVCC的实现原理

------

MVCC的目的就是多版本并发控制，在数据库中的实现，就是为了解决`读写冲突`，它的实现原理主要是依赖记录中的 `3个隐式字段`，`undo日志` ，`Read View` 来实现的。所以我们先来看看这个三个point的概念

#### 隐式字段

每行记录除了我们自定义的字段外，还有数据库隐式定义的`DB_TRX_ID`,`DB_ROLL_PTR`,`DB_ROW_ID`等字段

- `DB_TRX_ID`
  6byte，最近修改(`修改/插入`)事务ID：记录创建这条记录/最后一次修改该记录的事务ID
- `DB_ROLL_PTR`
  7byte，回滚指针，指向这条记录的上一个版本（存储于rollback segment里）
- `DB_ROW_ID`
  6byte，隐含的自增ID（隐藏主键），如果数据表没有主键，InnoDB会自动以`DB_ROW_ID`产生一个聚簇索引
- 实际还有一个删除flag隐藏字段, 既记录被更新或删除并不代表真的删除，而是删除flag变了

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190313213705258.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1NuYWlsTWFubg==,size_16,color_FFFFFF,t_70)
如上图，`DB_ROW_ID`是数据库默认为该行记录生成的唯一隐式主键，`DB_TRX_ID`是当前操作该记录的事务ID,而`DB_ROLL_PTR`**是一个回滚指针，用于配合undo日志，指向上一个旧版本**

------

#### undo日志

undo log主要分为两种：

- insert undo log
  代表事务在`insert`新记录时产生的`undo log`, **只在事务回滚时需要，并且在事务提交后可以被立即丢弃**
- update undo log
  事务在进行`update`或`delete`时产生的`undo log`; **不仅在事务回滚时需要，在快照读时也需要；所以不能随便删除，只有在快速读或事务回滚不涉及该日志时，对应的日志才会被`purge`线程统一清除**

> purge
>
> - 从前面的分析可以看出，为了实现InnoDB的MVCC机制，更新或者删除操作都只是设置一下老记录的deleted_bit，并不真正将过时的记录删除。
> - 为了节省磁盘空间，InnoDB有专门的purge线程来清理deleted_bit为true的记录。为了不影响MVCC的正常工作，purge线程自己也维护了一个read view（这个read view相当于系统中最老活跃事务的read view）;如果某个记录的deleted_bit为true，并且DB_TRX_ID相对于purge线程的read view可见，那么这条记录一定是可以被安全清除的。

对MVCC有帮助的实质是`update undo log` ，`undo log`实际上就是存在`rollback segment`中旧记录链，它的执行流程如下：

一、 比如一个有个事务插入persion表插入了一条新记录，记录如下，`name`为Jerry, `age`为24岁，`隐式主键`是1，`事务ID`和`回滚指针`，我们假设为NULL

![img](https://img-blog.csdnimg.cn/20190313213836406.png)

二、 现在来了一个`事务1`对该记录的`name`做出了修改，改为Tom

- 在`事务1`修改该行(记录)数据时，数据库会先对该行加`排他锁`
- 然后把该行数据拷贝到`undo log`中，作为旧记录，既在`undo log`中有当前行的拷贝副本
- 拷贝完毕后，修改该行`name`为Tom，并且修改隐藏字段的事务ID为当前`事务1`的ID, 我们默认从`1`开始，之后递增，回滚指针指向拷贝到`undo log`的副本记录，既表示我的上一个版本就是它
- 事务提交后，释放锁

![img](https://img-blog.csdnimg.cn/20190313220441831.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1NuYWlsTWFubg==,size_16,color_FFFFFF,t_70)

三、 又来了个`事务2`修改`person表`的同一个记录，将`age`修改为30岁

- 在`事务2`修改该行数据时，数据库也先为该行加锁
- 然后把该行数据拷贝到`undo log`中，作为旧记录，发现该行记录已经有`undo log`了，那么最新的旧数据作为链表的表头，插在该行记录的`undo log`最前面
- 修改该行`age`为30岁，并且修改隐藏字段的事务ID为当前`事务2`的ID, 那就是`2`，回滚指针指向刚刚拷贝到`undo log`的副本记录
- 事务提交，释放锁

![img](https://img-blog.csdnimg.cn/20190313220528630.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1NuYWlsTWFubg==,size_16,color_FFFFFF,t_70)

从上面，我们就可以看出，不同事务或者相同事务的对同一记录的修改，会导致该记录的`undo log`成为一条记录版本线性表，既链表，`undo log`的链首就是最新的旧记录，链尾就是最早的旧记录（当然就像之前说的该undo log的节点可能是会purge线程清除掉，向图中的第一条insert undo log，其实在事务提交之后可能就被删除丢失了，不过这里为了演示，所以还放在这里）

------

#### Read View(读视图)

什么是Read View?

什么是Read View，说白了Read View就是**事务进行`快照读`操作的时候生产的`读视图`(Read View)，在该事务执行的快照读的那一刻，会生成数据库系统当前的一个快照，记录并维护系统当前活跃事务的ID**(当每个事务开启时，都会被分配一个ID, 这个ID是递增的，所以最新的事务，ID值越大)

所以我们知道 `Read View`主要是用来做可见性判断的, 即当我们某个事务执行快照读的时候，对该记录创建一个`Read View`读视图，把它比作条件用来判断当前事务能够看到哪个版本的数据，既可能是当前最新的数据，也有可能是该行记录的`undo log`里面的某个版本的数据。

Read View`遵循一个可见性算法，主要是将`==**要被修改的数据的最新记录中的`DB_TRX_ID`（即当前事务ID）取出来（判断是否某条记录是否可见的记录事务id）**==，与系统当前其他活跃事务的ID去对比（由Read View维护），如果`DB_TRX_ID`跟Read View的属性做了某些比较，不符合可见性，==那就通过`DB_ROLL_PTR`回滚指针去取出`Undo Log`中的`DB_TRX_ID`再比较，即遍历链表的`DB_TRX_ID`（从链首到链尾，即从最近的一次修改查起），直到找到满足特定条件的`DB_TRX_ID`, 那么这个DB_TRX_ID所在的旧记录就是当前事务能看见的最新老版本（本次查询所能看见该数据的版本）==

那么这个判断条件是什么呢？
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190314144440494.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1NuYWlsTWFubg==,size_16,color_FFFFFF,t_70)
我们这里盗窃[@呵呵一笑百媚生](https://www.zhihu.com/question/66320138/answer/241418502)一张源码图，如上，它是一段MySQL判断可见性的一段源码，即`changes_visible`方法（不完全哈，但能看出大致逻辑），该方法展示了我们拿DB_TRX_ID去跟Read View某些属性进行怎么样的比较

在展示之前，我先简化一下Read View，我们可以把Read View简单的理解成有三个全局属性

> - `trx_list`（名字我随便取的）
>   一个数值列表，用来维护Read View生成时刻系统正活跃的事务ID
> - `up_limit_id`
>   记录trx_list列表中事务ID最小的ID
> - `low_limit_id`
>   ReadView生成时刻系统尚未分配的下一个事务ID，也就是==目前已出现过的事务ID的最大值+1==

- 首先比较`DB_TRX_ID < up_limit_id`, 如果小于，则当前事务能看到`DB_TRX_ID` 所在的记录，如果大于等于进入下一个判断
- 接下来判断 `DB_TRX_ID 大于等于 low_limit_id` , 如果大于等于则代表`DB_TRX_ID` 所在的记录在`Read View`生成后才出现的，那对当前事务肯定不可见，如果小于则进入下一个判断
- 判断`DB_TRX_ID` 是否在活跃事务之中，`trx_list.contains(DB_TRX_ID)`，如果在，则代表我`Read View`生成时刻，你这个事务还在活跃，还没有Commit，你修改的数据，我当前事务也是看不见的；如果不在，则说明，你这个事务在`Read View`生成之前就已经Commit了，你修改的结果，我当前事务是能看见的

------

#### ==整体流程==

我们在了解了`隐式字段`，`undo log`， 以及`Read View`的概念之后，就可以来看看MVCC实现的整体流程是怎么样了

整体的流程是怎么样的呢？我们可以模拟一下

- 当`事务2`对某行数据执行了`快照读`，数据库为该行数据生成一个`Read View`读视图，假设当前事务ID为`2`，此时还有`事务1`和`事务3`在活跃中，`事务4`在`事务2`快照读前一刻提交更新了，所以Read View记录了系统当前活跃事务1，3的ID，维护在一个列表上，假设我们称为`trx_list`

| 事务1    | 事务2    | 事务3    | 事务4        |
| -------- | -------- | -------- | ------------ |
| 事务开始 | 事务开始 | 事务开始 | 事务开始     |
| …        | …        | …        | 修改且已提交 |
| 进行中   | 快照读   | 进行中   |              |
| …        | …        | …        |              |

- Read View不仅仅会通过一个列表`trx_list`来维护`事务2`执行`快照读`那刻系统正活跃的事务ID，还会有两个属性`up_limit_id`（记录trx_list列表中事务ID最小的ID），==`low_limit_id`(记录trx_list列表中事务ID最大的ID，也有人说快照读那刻系统尚未分配的下一个事务ID也就是`目前已出现过的事务ID的最大值+1`==，我更倾向于后者 [>>>资料传送门 | 呵呵一笑百媚生的回答](https://www.zhihu.com/question/66320138/answer/241418502)) ；所以在这里例子中`up_limit_id`就是1，`low_limit_id`就是4 + 1 = 5，trx_list集合的值是1,3，`Read View`如下图

![img](https://img-blog.csdnimg.cn/20190313224045780.png)

- 我们的例子中，只有`事务4`修改过该行记录，并在`事务2`执行`快照读`前，就提交了事务，所以当前该行当前数据的`undo log`如下图所示；我们的事务2在快照读该行记录的时候，就会拿该行记录的`DB_TRX_ID`去跟`up_limit_id`,`low_limit_id`和`活跃事务ID列表(trx_list)`进行比较，判断当前`事务2`能看到该记录的版本是哪个。

![img](https://img-blog.csdnimg.cn/2019031322511052.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1NuYWlsTWFubg==,size_16,color_FFFFFF,t_70)

- 所以先拿该记录`DB_TRX_ID`字段记录的事务ID `4`去跟`Read View`的的`up_limit_id`比较，看`4`是否小于`up_limit_id`(1)，所以不符合条件，继续判断 `4` 是否大于等于 `low_limit_id`(5)，也不符合条件，最后判断`4`是否处于`trx_list`中的活跃事务, 最后发现事务ID为`4`的事务不在当前活跃事务列表中, 符合可见性条件，所以`事务4`修改后提交的最新结果对`事务2`快照读时是可见的，所以`事务2`能读到的最新数据记录是`事务4`所提交的版本，而事务4提交的版本也是全局角度上最新的版本

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190314141320189.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1NuYWlsTWFubg==,size_16,color_FFFFFF,t_70)

- 也正是Read View生成时机的不同，从而造成RC,RR级别下快照读的结果的不同



### MVCC相关问题

------

#### RR是如何在RC级的基础上解决不可重复读的？

##### 当前读和快照读在RR级别下的区别：

```
表1:
```

| 事务A                       | 事务B                                      |
| --------------------------- | ------------------------------------------ |
| 开启事务                    | 开启事务                                   |
| 快照读(无影响)查询金额为500 | 快照读查询金额为500                        |
| 更新金额为400               |                                            |
| 提交事务                    |                                            |
|                             | select `快照读`金额为500                   |
|                             | select lock in share mode`当前读`金额为400 |

在上表的顺序下，事务B的在事务A提交修改后的快照读是旧版本数据，而当前读是实时新数据400

```
表2:
```

| 事务A                         | 事务B                                      |
| ----------------------------- | ------------------------------------------ |
| 开启事务                      | 开启事务                                   |
| 快照读（无影响）查询金额为500 |                                            |
| 更新金额为400                 |                                            |
| 提交事务                      |                                            |
|                               | select `快照读`金额为400                   |
|                               | select lock in share mode`当前读`金额为400 |

而在`表2`这里的顺序中，事务B在事务A提交后的快照读和当前读都是实时的新数据400，这是为什么呢？

- 这里与上表的唯一区别仅仅是`表1`的事务B在事务A修改金额前`快照读`过一次金额数据，而`表2`的事务B在事务A修改金额前没有进行过快照读。

所以我们知道事务中快照读的结果是非常依赖该事务首次出现快照读的地方，即某个事务中首次出现快照读的地方非常关键，它有决定该事务后续快照读结果的能力

我们这里测试的是`更新`，同时`删除`和`更新`也是一样的，如果事务B的快照读是在事务A操作之后进行的，事务B的快照读也是能读取到最新的数据的

------

#### RC,RR级别下的InnoDB快照读有什么不同？

正是`Read View`生成时机的不同，从而造成RC,RR级别下快照读的结果的不同

- 在RR级别下的某个事务的对某条记录的第一次快照读会创建一个快照及Read View, 将当前系统活跃的其他事务记录起来，此后在调用快照读的时候，还是使用的是同一个Read View，所以只要当前事务在其他事务提交更新之前使用过快照读，那么之后的快照读使用的都是同一个Read View，所以对之后的修改不可见；
- ==即RR级别下，快照读生成Read View时，Read View会记录此时所有其他活动事务的快照，这些事务的修改对于当前事务都是不可见的。而早于Read View创建的事务所做的修改均是可见==
- ==而在RC级别下的，事务中，每次快照读都会新生成一个快照和Read View, 这就是我们在RC级别下的事务中可以看到别的事务提交的更新的原因==

==总之在RC隔离级别下，是每个快照读都会生成并获取最新的Read View；而在RR隔离级别下，则是同一个事务中的第一个快照读才会创建Read View, 之后的快照读获取的都是同一个Read View。==



### MySQL系列

------

- [【MySQL笔记】正确的理解MySQL的乐观锁与悲观锁,MVCC](https://blog.csdn.net/SnailMann/article/details/88388829)

- [【MySQL笔记】正确的理解MySQL的MVCC及实现原理](https://blog.csdn.net/SnailMann/article/details/94724197)

- [【MySQL笔记】正确的理解MySQL的事务和隔离级别](https://blog.csdn.net/SnailMann/article/details/88299127)

  

### 参考资料

------

- [InnoDB多版本(MVCC)实现简要分析 - @作者：何登成](http://hedengcheng.com/?p=148)
- [MySQL InnoDB MVCC深度分析 - @作者：stevenczp](https://www.cnblogs.com/stevenczp/p/8018986.html)
- [InnoDB存储引擎MVCC的工作原理 - @作者：秋风醉了](https://my.oschina.net/xinxingegeya/blog/505675)
- [MySQL 在 RC 隔离级别下是如何实现读不阻塞的？ - @作者：知乎](https://www.zhihu.com/question/66320138/answer/241418502)
- [MVCC read view的问题 - @作者：PHP中文网](http://m.php.cn/article/134174.html)
- [MySQL数据库事务各隔离级别加锁情况–read committed && MVCC - @作者：mark_fork](http://m.imooc.com/article/details?article_id=17290)
- [乐观锁与CAS，MVCC - @作者：shuff1e](https://www.jianshu.com/p/56fa361e0d94)
- [悲观锁，乐观锁以及MVCC - @作者：wezheng](https://www.cnblogs.com/wezheng/p/8352985.html)
- [【数据库】悲观锁与乐观锁与MySQL的MVCC实现简述 - @作者：Nick Huang](https://www.cnblogs.com/nick-huang/p/6653996.html)

 

 

 

#  一文讲透 MVCC 实现原理

# 1. 引言

上一篇文章中，我们介绍了 mysql 的 crash safe 机制，也是 ACID 中原子性的实现 – redolog 的原理和配置方法。
[mysql 异常情况下的事务安全 – 详解 mysql redolog](http://techlog.cn/article/list/10183403)

本文，我们来介绍 mysql 在可重复读隔离级别下事务的实现方式 – MVCC，以及他的实现原理 – undolog

# 2. undo log

undo log 是 MVCC 实现的一个重要依赖，所以在详细介绍 MVCC 前，我们先来介绍 undo log 是什么。
undo log 与 redo log 一起构成了 MySQL 事务日志，并且我们上篇文章中提到的日志先行原则 WAL 除了包含 redo log 外，也包括 undo log，事务中的每一次修改，innodb 都会先记录对应的 undo log 记录。
那么 undo log 是什么呢？顾名思义，与 redo log 用于数据的灾后重新提交不同，undo log 主要用于数据修改的回滚。

与 redo log 记录的是物理页的修改不同，undo log 记录的是逻辑日志。
当 delete 一条记录时，undo log 中会记录一条对应的 insert 记录，反之亦然，当 update 一条记录时，它记录一条对应相反的 update 记录，如果 update 的是主键，则是对先删除后插入的两个事件的反向逻辑操作的记录。

![# 此处有图片 2](https://img-blog.csdnimg.cn/20190911224150251.png)

这样，在事务回滚时，我们就可以从 undo log 中反向读取相应的内容，并进行回滚，同时，我们也可以根据 undo log 中记录的日志读取到一条被修改后数据的原值。
正是依赖 undo log，innodb 实现了 ACID 中的 C – Consistency 即一致性。

# 3. undo log 的存储与相关配置

innodb 通过段的方式来管理 undo log，每一条记录占用一个 undo log segment，每 1024 个 undo log segment 被组织为一个回滚段（rollback segment）
mysql 5.6 版本以后可以通过 innodb_undo_logs 配置项设置系统支持的最大回滚段个数，默认为 128。
通过 innodb_undo_directory 配置可以设置 undo log 存储的目录。
通过 innodb_undo_tablespaces 可以设置将 undo log 平均分配到多少个文件中，默认为 0，即全部写入同一个文件中。

这里顺便说一下，在 mysql 5.6 的早期版本及之前的版本中，并没有限制回滚段的大小，这就造成了一个非常严重的漏洞，攻击者可以通过反复更新一个字段造成 undo log 占用大量的磁盘空间，可以参看：
https://blog.jcole.us/2014/04/16/a-little-fun-with-innodb-multi-versioning/
https://bugs.mysql.com/bug.php?id=72362。

# 4. MVCC

此前的文章中，我们介绍了 mysql 事务隔离级别，其中非常粗略的介绍了 MVCC：
[mysql 锁机制与四种隔离级别](http://techlog.cn/article/list/10182853)

MVCC 全称是 multiversion concurrency control，即多版本并发控制，是 innodb 实现事务并发与回滚的重要功能。
具体的实现是，在数据库的每一行中，添加额外的三个字段：

1. DB_TRX_ID – 记录插入或更新该行的最后一个事务的事务 ID
2. DB_ROLL_PTR – 指向改行对应的 undolog 的指针
3. DB_ROW_ID – 单调递增的行 ID，他就是 AUTO_INCREMENT 的主键 ID

![# 此处有图片 3](https://img-blog.csdnimg.cn/20190911224201739.jpg)

# 5. 快照读与当前读

innodb 拥有一个自增的全局事务 ID，每当一个事务开启，在事务中都会记录当前事务的唯一 id，而全局事务 ID 会随着新事务的创建而增长。
同时，新事务创建时，事务系统会将当前未提交的所有事务 ID 组成的数组传递给这个新事务，本文的下面段落我们成这个数组为 TRX_ID 集合。

## 5.1. 快照读

正如我们前面介绍的，每当一个事务更新一条数据时，都会在写入对应 undo log 后将这行记录的隐藏字段 DB_TRX_ID 更新为当前事务的事务 ID，用来表明最新更新该数据的事务是该事务。
当另一个事务去 select 数据时，读到该行数据的 DB_TRX_ID 不为空并且 DB_TRX_ID 与当前事务的事务 ID 是不同的，这就说明这一行数据是另一个事务修改并提交的。
那么，这行数据究竟是在当前事务开启前提交的还是在当前事务开启后提交的呢？

![# 此处有图片 4](https://img-blog.csdnimg.cn/20190911224215559.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0RJTElHRU5UMjAz,size_16,color_FFFFFF,t_70)

如上图所示，有了上文提到的 TRX_ID 集合，就很容易判断这个问题了，如果这一行数据的 DB_TRX_ID 在 TRX_ID 集合中或大于当前事务的事务 ID，那么就说明这行数据是在当前事务开启后提交的，否则说明这行数据是在当前事务开启前提交的。
对于当前事务开启后提交的数据，当前事务需要通过隐藏的 DB_ROLL_PTR 字段找到 undo log，然后进行逻辑上的回溯才能拿到事务开启时的原数据。
这个通过 undo log + 数据行获取到事务开启时的原始数据的过程就是“快照读”。

## 5.2. 当前读

很多时候，我们在读取数据库时，需要读取的是行的当前数据，而不需要通过 undo log 回溯到事务开启前的数据状态，主要包含以下操作：

1. insert
2. update
3. select … lock in share mode
4. select … for update

# 6. MVCC 与不可重复读、幻读的问题

## 6.1. 不可重复读与幻读

“不可重复读”与“幻读”是两个数据库常见的极易混淆的问题。
不可重复读指的是，在一个事务开启过程中，当前事务读取到了另一事务提交的修改。
幻读则指的是，在一个事务开启过程中，读取到另一个事务提交导致的数据条目的新增或删除。

## 6.2. 可重复读解决不可重复读与幻读问题的原理

那么，可重复读的隔离级别是否解决了不可重复读与幻读问题呢？
上面我们提到，对于正常的 select 查询 innodb 实际上进行的是快照读，即通过判断读取到的行的 DB_TRX_ID 与 DB_ROLL_PTR 字段指向的 undo log 回溯到事务开启前或当前事务最后一次更新的数据版本，从而在这样的场景下避免了可重复读与幻读的问题。
针对已存在的数据，insert 和 update 操作虽然是进行当前读，但 insert 与 update 操作后，该行的最新修改事务 ID 为当前事务 ID，因此读到的值仍然是当前事务所修改的数据，不会产生不可重复读的问题。
但如果当前事务更新到了其他事务新插入并提交了的数据，这就会造成该行数据的 DB_TRX_ID 被更新为当前事务 ID，此后即便进行快照读，依然会查出该行数据，产生幻读（其他事务插入或删除但未提交该行数据的情况下会锁定该行，造成当前事务对该行的更新操作被阻塞，所以这种情况不会产生幻读问题，有关事务间的锁，不在本篇文章的讨论范围内，接下来的文章我们会进一步讨论）

## 6.3. 实证

我们实际来看一个例子。
首先，我们创建一个表：

```sql
CREATE TABLE `test` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `value` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
```

然后我们插入三条初始数据：

```sql
INSERT INTO `test` (`value`) VALUES (1), (2), (3)
```

 

接下来我们在两个窗口中分别开启一个事务并查询出现有数据：

![# 此处有图片 5](https://img-blog.csdnimg.cn/20190911224227267.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0RJTElHRU5UMjAz,size_16,color_FFFFFF,t_70)

我们在其中一个事务中先更新 id 为 1 的数据，再插入一条 id 为 4 的数据，再删除 id 为 2 的数据，然后，在另一个事务中查询，可以看到此时查询出来的仍然是事务开启时的初始数据，说明当前隔离级别和场景下并没有脏读的问题存在：

![# 此处有图片 6](https://img-blog.csdnimg.cn/20190911224236136.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0RJTElHRU5UMjAz,size_16,color_FFFFFF,t_70)

此时，我们提交所有的修改，接着在另一个事务中查询，可以看到此时查询到的结果仍然是事务开启前的原始数据，说明当前隔离级别和场景下并没有不可重复读和幻读的问题存在：

![# 此处有图片 7](https://img-blog.csdnimg.cn/2019091122425048.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0RJTElHRU5UMjAz,size_16,color_FFFFFF,t_70)

那么接下来，我们在未提交的这个事务中执行一条修改，可以看到，本应在事务中只影响一行的 update 操作返回了 changed: 2，接着，我们查询结果出现了 id 为 4 的行，说明了幻读问题的存在【update当前读会读最新数据】：

![# 此处有图片 8](https://img-blog.csdnimg.cn/20190911224305759.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0RJTElHRU5UMjAz,size_16,color_FFFFFF,t_70)

# 7. undo log 的清理

在回滚段中，每个 undo log 段都有一个类型字段，共有两种类型：insert undo logs 和 update undo logs。
对于执行 insert 语句插入的数据，其回滚段类型为 insert undo logs，用来在事务中回滚当前的插入操作。
对于执行 delete 语句删除和 update 语句更新的数据，其回滚段类型为 update undo logs。
如果事务 rollback，innodb 通过执行 undo log 中的所有反向操作，实现事务中所有操作的回滚，随后就会删除该事务关联的所有 undo log 段。
如果事务 commit，对于 insert undo logs，innodb 会直接清除，但对于 update undo logs，只有当前没有任何事务存在时，innodb 的 purge 线程才会清理这些 undo log 段。
这里提到了 purge 线程，他是一个周期运行的垃圾收集线程，主要用来收集 undo log 段，以及已经被废弃的索引。
在事务提交时，innodb 会将所有需要清理的任务添加到 purge 队列中，可以通过 innodb_max_purge_lag 配置项设定 purge 队列的大小。
purge 线程会在周期执行时，对 purge 队列中的任务进行清理，innodb_max_purge_lag_delay 配置项说明了 purge 线程的执行周期间隔。
所以，尽量缩短使用中每个事务的持续时间，可以让 purge 线程有更大概率回收已经没有存在必要的 undo log 段，从而尽量释放磁盘空间的占用。

# 8. 《高性能 MySQL》中的谬误

主页君在多年以前曾经就 MVCC 的实现阅读过相对非常权威的著作《高性能 MySQL》，其中有着下面的一段话：

![# 此处有图片 9](https://img-blog.csdnimg.cn/20190911224317770.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0RJTElHRU5UMjAz,size_16,color_FFFFFF,t_70)

主页君看到网上目前许许多多的博客都是按照上述文字中介绍的原理来讲述的。
但当如今主页君仔细去深究其中的原理，参阅官方文档之后，发现各版本 innodb MVCC 的原理并不是书上所描述的这样，毕竟官方文档是除源码外的第一手资料，同时，参阅一些文章贴出的源码来看，确实是按照官方文档中介绍的原理实现的，因此，本文主要参阅官方的相关源码进行详细的总结和讲述。
那么，《高性能 MySQL》中的描述是来源于哪里呢？事实上，它讲述的是 PostgreSQL 的实现方式。
与 InnoDB 类似，PostgreSQL 为每一行数据添加了 4 个额外的字段：

1. xmin – 插入与更新数据时写入的事务 ID
2. xmax – 删除数据时写入的事务 ID
3. cmin – 插入与更新数据时写入的命令 ID
4. cmax – 删除数据时写入的命令 ID

在每一个事务中，都维护了一个从 0 开始单调递增的命令 ID（COMMAND_ID），每当一个命令执行后，COMMAND_ID 都会自增。
当一个事务更新一条数据，PostgreSQL 会创建一条新的记录，并将新的记录的 xmin 更新为当前事务的事务 ID。
当一个事务删除一条数据，PostgreSQL 不会创建一条新纪录，而是将该行记录的 xmax 更新为当前事务的 ID。
因为 cmin 和 cmax 的记录，PostgreSQL 可以以此排列出同一事务中所有更新、删除操作的先后。
这样，在一个事物读取数据时，只需要读取 xmin 小于当前事务 ID 且 xmin 不在 TRX_ID 集合中的数据即可实现快照读的功能。

## 8.1. 优缺点

PostgreSQL 的 MVCC 实现与 innodb 的 MVCC 实现相比，最大的优点在于其查询无需解析 undo log 进行回溯。
对于数据回滚，只需要删除所有 xmin 为当前事务 ID 的记录，清除所有 xmax 为当前事务 ID 的 xmax 字段即可。
但其缺点也很明显，那就是随着更新操作，数据库中会产生大量的额外数据，这些数据同时也对数据库其他的操作例如索引的建立等都带来了额外的性能消耗。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190911224438815.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0RJTElHRU5UMjAz,size_16,color_FFFFFF,t_70)

 

 

 

 

 

 

 

 

 

# 轻松理解MYSQL MVCC 实现机制

### 1. MVCC简介

#### 1.1 什么是MVCC

MVCC是一种多版本并发控制机制。

#### 1.2 MVCC是为了解决什么问题?

- 大多数的MYSQL事务型存储引擎,如,InnoDB，Falcon以及PBXT都不使用一种简单的行锁机制.事实上,他们都和MVCC–多版本并发控制来一起使用.
- 大家都应该知道,锁机制可以控制并发操作,但是其系统开销较大,而MVCC可以在大多数情况下代替行级锁,使用MVCC,能降低其系统开销.

#### 1.3 MVCC实现

MVCC是通过保存数据在某个时间点的快照来实现的. 不同存储引擎的MVCC. 不同存储引擎的MVCC实现是不同的,典型的有乐观并发控制和悲观并发控制.

### 2.MVCC 具体实现分析

下面,我们通过InnoDB的MVCC实现来分析MVCC使怎样进行并发控制的.
InnoDB的MVCC,是通过在每行记录后面保存两个隐藏的列来实现的,这两个列，分别保存了这个行的创建时间，一个保存的是行的删除时间。这里存储的并不是实际的时间值,而是系统版本号(可以理解为事务的ID)，没开始一个新的事务，系统版本号就会自动递增，事务开始时刻的系统版本号会作为事务的ID.下面看一下在REPEATABLE READ隔离级别下,MVCC具体是如何操作的.

### 2.1简单的小例子

create table yang(
id int primary key auto_increment,
name varchar(20));

> > 假设系统的版本号从1开始.

#### INSERT

InnoDB为新插入的每一行保存当前系统版本号作为版本号.
第一个事务ID为1；

```sql
start transaction;
insert into yang values(NULL,'yang') ;
insert into yang values(NULL,'long');
insert into yang values(NULL,'fei');
commit;
```

 

对应在数据中的表如下(后面两列是隐藏列,我们通过查询语句并看不到)

| id   | name | 创建时间(事务ID) | 删除时间(事务ID) |
| ---- | ---- | ---------------- | ---------------- |
| 1    | yang | 1                | undefined        |
| 2    | long | 1                | undefined        |
| 3    | fei  | 1                | undefined        |

#### SELECT

InnoDB会根据以下两个条件检查每行记录:
a.InnoDB只会查找版本早于当前事务版本的数据行(也就是,行的系统版本号小于或等于事务的系统版本号)，这样可以确保事务读取的行，要么是在事务开始前已经存在的，要么是事务自身插入或者修改过的.
b.行的删除版本要么未定义,要么大于当前事务版本号,这可以确保事务读取到的行，在事务开始之前未被删除.
只有a,b同时满足的记录，才能返回作为查询结果.

#### DELETE

InnoDB会为删除的每一行保存当前系统的版本号(事务的ID)作为删除标识.
看下面的具体例子分析:
第二个事务,ID为2;

```sql
start transaction;
select * from yang;  //(1)
select * from yang;  //(2)
commit; 
```

 

 

#### 假设1

假设在执行这个事务ID为2的过程中,刚执行到(1),这时,有另一个事务ID为3往这个表里插入了一条数据;
第三个事务ID为3;

```sql
start transaction;
insert into yang values(NULL,'tian');
commit;
```

 

这时表中的数据如下:

| id   | name | 创建时间(事务ID) | 删除时间(事务ID) |
| ---- | ---- | ---------------- | ---------------- |
| 1    | yang | 1                | undefined        |
| 2    | long | 1                | undefined        |
| 3    | fei  | 1                | undefined        |
| 4    | tian | 3                | undefined        |

然后接着执行事务2中的(2),由于id=4的数据的创建时间(事务ID为3),执行当前事务的ID为2,而InnoDB只会查找事务ID小于等于当前事务ID的数据行,所以id=4的数据行并不会在执行事务2中的(2)被检索出来,在事务2中的两条select 语句检索出来的数据都只会下表:

| id   | name | 创建时间(事务ID) | 删除时间(事务ID) |
| ---- | ---- | ---------------- | ---------------- |
| 1    | yang | 1                | undefined        |
| 2    | long | 1                | undefined        |
| 3    | fei  | 1                | undefined        |

#### 假设2

假设在执行这个事务ID为2的过程中,刚执行到(1),假设事务执行完事务3后，接着又执行了事务4;
第四个事务:

```sql
start   transaction;  
delete from yang where id=1;
commit;  
```

 

此时数据库中的表如下:

| id   | name | 创建时间(事务ID) | 删除时间(事务ID) |
| ---- | ---- | ---------------- | ---------------- |
| 1    | yang | 1                | 4                |
| 2    | long | 1                | undefined        |
| 3    | fei  | 1                | undefined        |
| 4    | tian | 3                | undefined        |

接着执行事务ID为2的事务(2),根据SELECT 检索条件可以知道,它会检索创建时间(创建事务的ID)小于当前事务ID的行和删除时间(删除事务的ID)大于当前事务的行,而id=4的行上面已经说过,而id=1的行由于删除时间(删除事务的ID)大于当前事务的ID,所以事务2的(2)select * from yang也会把id=1的数据检索出来.所以,事务2中的两条select 语句检索出来的数据都如下:

| id   | name | 创建时间(事务ID) | 删除时间(事务ID) |
| ---- | ---- | ---------------- | ---------------- |
| 1    | yang | 1                | 4                |
| 2    | long | 1                | undefined        |
| 3    | fei  | 1                | undefined        |

#### UPDATE

InnoDB执行UPDATE，实际上是新插入了一行记录，并保存其创建时间为当前事务的ID，同时保存当前事务ID到要UPDATE的行的删除时间.

#### 假设3

假设在执行完事务2的(1)后又执行,其它用户执行了事务3,4,这时，又有一个用户对这张表执行了UPDATE操作:
第5个事务:

```sql
start  transaction;
update yang set name='Long' where id=2;
commit;
```

 

 

根据update的更新原则:会生成新的一行,并在原来要修改的列的删除时间列上添加本事务ID,得到表如下:

| id   | name | 创建时间(事务ID) | 删除时间(事务ID) |
| ---- | ---- | ---------------- | ---------------- |
| 1    | yang | 1                | 4                |
| 2    | long | 1                | 5                |
| 3    | fei  | 1                | undefined        |
| 4    | tian | 3                | undefined        |
| 2    | Long | 5                | undefined        |

继续执行事务2的(2),根据select 语句的检索条件,得到下表:

| id   | name | 创建时间(事务ID) | 删除时间(事务ID) |
| ---- | ---- | ---------------- | ---------------- |
| 1    | yang | 1                | 4                |
| 2    | long | 1                | 5                |
| 3    | fei  | 1                | undefined        |

还是和事务2中(1)select 得到相同的结果.

 

 

 

 

 

 

 

# redolog

# 引言

上一篇文章中，我们介绍了 mysql 的二进制日志 binlog，他为数据的同步、恢复和回滚提供了非常便利的支持

[怎么避免从删库到跑路 -- 详解 mysql binlog 的配置与使用](https://techlog.cn/article/list/10183401)

 

无论我们使用的是什么存储引擎，只要通过配置开启，mysql 都会记录 binlog

在工程存储项目中，有一个重要的概念，那就是 crash safe，即当服务器突然断电或宕机，需要保证已提交的数据或修改不会丢失，未提交的数据能够自动回滚，这就是 mysql ACID 特性中的一个十分重要的特性 -- Atomicity 原子性

根据我们上一篇文章中的讲解，依靠 binlog 是无法保证 crash safe 的，因为 binlog 是事务提交时写入的，如果在 binlog 缓存中的数据持久化到硬盘之前宕机或断电

在服务器恢复工作后，由于 binlog 缺失一部分已提交的操作数据，而主数据库中实际上这部分操作已经存在，从数据库因此无法同步这部分操作，从而造成主从数据库数据不一致，这是很严重的

但实际上，innodb 存储引擎是拥有 crash safe 能力的，那么他是用什么机制来实现呢？本文我们就来详细说明

 

# mysql 的执行过程

无论使用任何存储引擎，只要开启相应配置，mysql 都会记录 binlog

但 MyISAM 引擎并没有提供 crash safe 能力，而 InnoDB 则提供了灾后恢复能力，这是为什么呢？

这和 mysql 整体的分层有关，我们需要首先了解一下一条 sql 语句是如何执行的

[![img](https://techlog.cn/article/list/images/15ff4aeb110986b62a169308b58d333b.png?id=3378376&v=1)](https://techlog.cn/article/list/images/15ff4aeb110986b62a169308b58d333b.png)

 

 

mysql 主要分为两层，与客户端直接交互的是 server 层，包括连接的简历和管理、词法分析、语法分析、执行计划与具体 sql 的选择都是在 server 层中进行的，binlog 就是在 server 层中由 mysql server 实现的

而 innodb 作为具体的一个存储引擎，他通过 redolog 实现了 crash safe 的支持

 

# redolog 的写入

mysql 有一个基本的技术理念，那就是 WAL，即 Write-Ahead Logging，先写日志，再写磁盘，从而保证每一次操作都有据可查，这里所说的“先写日志”中的日志就包括 innodb 的 redolog

redolog 与持续向后添加的 binlog 不同，他只占用预先分配的一块固定大小的磁盘空间，在这片空间中，redolog 采用循环写入的方式写入新的数据

[![img](https://techlog.cn/article/list/images/054fd37784f79e521dca96693e976049.png?id=3378377&v=1)](https://techlog.cn/article/list/images/054fd37784f79e521dca96693e976049.png)

 

 

同时，binlog 是以每条操作语句为单位进行记录的，而 redolog 则是以数据页来进行记录的，他记录了每个页上的修改，所以一个事务中可能分多次多条写入 redolog

 

# crash safe 与两阶段提交

每条 redolog 都有两个状态 -- prepare 与 commit 状态

例如对于一张 mysql 表（CREATE TABLE `A` (`ID` int(10) unsigned NOT NULL AUTO_INCREMENT, `C` int(10) NOT NULL DEFAULT 0, PRIMARY KEY (`ID`)) ENGINE=InnoDB），我们执行一条 SQL 语句：

> UPDATE A set C=C+1 WHERE ID=2

 

实际上，mysql 数据库会进行以下操作（下图中深色的是 mysql server 层所做的操作，浅色部分则是 innodb 存储引擎进行的操作）：：

[![img](https://techlog.cn/article/list/images/a70511f707b15cc4768cb82ceab4d4b5.png?id=3378378&v=1)](https://techlog.cn/article/list/images/a70511f707b15cc4768cb82ceab4d4b5.png)

 

 

可以看到，在写入 binlog 及事务提交前，innodb 先记录了 redolog，并标记为 prepare 状态，在事务提交后，innodb 会将 redolog 更新为 commit 状态，这样在异常发生时，就可以按照下面两条策略来处理：

1. 1. 当异常情况发生时，如果第一次写入 redolog 成功，写入 binlog 失败，MySQL 会当做事务失败直接回滚，保证了后续 redolog 和 binlog 的准确性

1. 1. 如果第一次写入 redolog 成功，binlog 也写入成功，当第二次写入 redolog 时候失败了，那数据恢复的过程中，MySQL 判断 redolog 状态为 prepare，且存在对应的 binlog 记录，则会重放事务提交，数据库中会进行相应的修改操作

 

整个过程是一个典型的两阶段提交过程，由 binlog 充当了协调者的角色，针对每一次日志写入，innodb 都会随之记录一个 8 字节序列号 -- LSN（日志逻辑序列号 log sequence number），他会随着日志写入不断单调递增

binlog、DB 中的数据、redolog 三者就是通过 LSN 关联到一起的，因为数据页上记录了 LSN、日志开始与结束均记录了 LSN、刷盘节点 checkpoint 也记录了 LSN，因此 LSN 成为了整套系统中的全局版本信息

当异常发生并重新启动后，innodb 会根据出在 prepare 状态的 redo log 记录去查找相同 LSN 的 binlog、数据记录，从而实现异常后的恢复

 

# redo log 的组织

redo log 是以“块”为单位进行存储的，称之为“redo log block”，每个块的大小是 512 字节

以块为单位存储的原因是他和磁盘扇区的大小是相同的，从而保证在异常情况发生时不会出现部分写入成功产生的脏数据

 

# 相关配置

### innodb_log_file_size

redo log 磁盘空间大小，默认为 5M

 

 

### innodb_log_buffer_size

redo log 缓存大小，默认为 8M

 

 

### innodb_flush_log_at_trx_commit

此前我们曾经介绍过，操作系统为了减少了磁盘的读写次数，提升系统的 IO 性能，会在内存空间中分配一个缓冲区，这就是页面高速缓冲，虽然高速缓冲让 IO 性能得以大幅提升，但在宕机等异常发生时，这部分在高速缓冲区中的数据就会丢失，因此 unix 提供了系统调用 fsync来让我们手动执行高速缓冲到磁盘的刷新工作

对于 redolog 来说，由于他的存在就是为了避免异常情况造成的已提交事务的丢失，所以高速缓冲引起的未刷盘数据丢失是不能容忍的，innodb_flush_log_at_trx_commit 配置项就是指定具体的刷盘策略的

他有以下值可以选择：

1. 1. 0 -- 以固定间隔将缓存中的数据写入系统高速缓存并调用一次 fsync 强制刷新高速缓冲，系统崩溃可能丢失最大1秒的数据

1. 1. 1 -- 默认值，每次事务提交时调用 fsync，这种方式即使系统崩溃也不会丢失任何数据，但是因为每次提交都写入磁盘，IO的性能较差

1. 1. 2 -- 每次事务提交都将数据写入系统高速缓存，但仅在固定间隔调用一次 fsync 强制刷新高速缓冲，安全性高于配置为 0

 

通常，为了绝对的安全性，我们会配置为 1，但在追求最高的写入性能时，我们通常配置为 2，因为设置为 2 与设置为 0 在性能上差异不大，但配置为 2 却在安全性上高于配置为 0

同时为了保证 binlog 的安全性，我们同时要配置 sync_binlog 为 1，保证每次 binlog 都直接写入磁盘，而不进行缓存

 

[![img](https://techlog.cn/article/list/images/c0ff098290796c91e80d42861353f40f.png?id=3378379&v=1)](https://techlog.cn/article/list/images/c0ff098290796c91e80d42861353f40f.png)

### innodb_flush_log_at_timeout

上面提到了刷新告诉缓存的固定间隔，这个“固定间隔”就是通过 innodb_flush_log_at_timeout 配置项指定的，默认是 1 秒

但实际上，如果 redo log 的缓存占用超过一半，也会立即触发缓冲的刷新

 

 