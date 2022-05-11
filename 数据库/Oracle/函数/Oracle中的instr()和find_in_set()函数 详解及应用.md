# [Oracle中的instr()函数 详解及应用](https://www.cnblogs.com/dshore123/p/7813230.html)

### 1、instr()函数的格式 （俗称：字符查找函数）

格式一：instr( string1, string2 )   // instr(源字符串, 目标字符串)

格式二：instr( string1, string2 [, start_position [, nth_appearance ] ] )  // instr(源字符串, 目标字符串, 起始位置, 匹配序号)

解析：string2 的值要在string1中查找，是从start_position给出的数值（即：位置）开始在string1检索，检索第nth_appearance（几）次出现string2。

 注：在Oracle/PLSQL中，instr函数返回要截取的字符串在源字符串中的位置。**只检索一次**，也就是说从字符的开始到字符的结尾就结束。

### 2、实例

格式一

```
1 select instr('helloworld','l') from dual; --返回结果：3    默认第一次出现“l”的位置
2 select instr('helloworld','lo') from dual; --返回结果：4    即“lo”同时出现，第一个字母“l”出现的位置
3 select instr('helloworld','wo') from dual; --返回结果：6    即“wo”同时出现，第一个字母“w”出现的位置
```

格式二

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
1 select instr('helloworld','l',2,2) from dual;  --返回结果：4    也就是说：在"helloworld"的第2(e)号位置开始，查找第二次出现的“l”的位置
2 select instr('helloworld','l',3,2) from dual;  --返回结果：4    也就是说：在"helloworld"的第3(l)号位置开始，查找第二次出现的“l”的位置
3 select instr('helloworld','l',4,2) from dual;  --返回结果：9    也就是说：在"helloworld"的第4(l)号位置开始，查找第二次出现的“l”的位置
4 select instr('helloworld','l',-1,1) from dual;  --返回结果：9    也就是说：在"helloworld"的倒数第1(d)号位置开始，往回查找第一次出现的“l”的位置
5 select instr('helloworld','l',-2,2) from dual;  --返回结果：4    也就是说：在"helloworld"的倒数第2(l)号位置开始，往回查找第二次出现的“l”的位置
6 select instr('helloworld','l',2,3) from dual;  --返回结果：9    也就是说：在"helloworld"的第2(e)号位置开始，查找第三次出现的“l”的位置
7 select instr('helloworld','l',-2,3) from dual; --返回结果：3    也就是说：在"helloworld"的倒数第2(l)号位置开始，往回查找第三次出现的“l”的位置
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**注：MySQL中的模糊查询 like 和 Oracle中的 instr() 函数有同样的查询效果； 如下所示：**

```
MySQL： select * from tableName where name like '%helloworld%';
Oracle：select * from tableName where instr(name,'helloworld')>0;  --这两条语句的效果是一样的
```



----

# [mysql中find_in_set()函数的使用](https://www.cnblogs.com/xiaoxi/p/5889486.html)

首先举个例子来说：
有个文章表里面有个type字段，它存储的是文章类型，有 1头条、2推荐、3热点、4图文等等 。
现在有篇文章他既是头条，又是热点，还是图文，type中以 1,3,4 的格式存储。那我们如何用sql查找所有type中有4的图文类型的文章呢？？
这就要我们的 find_in_set 出马的时候到了。以下为引用的内容：

```
select * from article where FIND_IN_SET('4',type)
```

\----------------------------------------------------------
**MySQL手册中find_in_set函数的语法：**
FIND_IN_SET(str,strlist)

str 要查询的字符串
strlist 字段名 参数以”,”分隔 如 (1,2,6,8)
查询字段(strlist)中包含(str)的结果，返回结果为null或记录

假如字符串str在由N个子链组成的字符串列表strlist 中，则返回值的范围在 1 到 N 之间。 一个字符串列表就是一个由一些被 ‘,’ 符号分开的子链组成的字符串。如果第一个参数是一个常数字符串，而第二个是type SET列，则FIND_IN_SET() 函数被优化，使用比特计算。 如果str不在strlist 或strlist 为空字符串，则返回值为 0 。如任意一个参数为NULL，则返回值为 NULL。这个函数在第一个参数包含一个逗号(‘,’)时将无法正常运行。

\--------------------------------------------------------

 例子：
mysql> SELECT FIND_IN_SET('b', 'a,b,c,d');
-> 2 因为b 在strlist集合中放在2的位置 从1开始

select FIND_IN_SET('1', '1'); 返回 就是1 这时候的strlist集合有点特殊 只有一个字符串 其实就是要求前一个字符串 一定要在后一个字符串集合中才返回大于0的数
select FIND_IN_SET('2', '1，2'); 返回2
select FIND_IN_SET('6', '1'); 返回0

\--------------------------------------------------------

注意：
select * from treenodes where FIND_IN_SET(id, '1,2,3,4,5');
使用find_in_set函数一次返回多条记录
id 是一个表的字段，然后每条记录分别是id等于1，2，3，4，5的时候
有点类似in （集合）
select * from treenodes where id in (1,2,3,4,5);

\--------------------------------------------------------

**find_in_set()和in的区别：**

弄个测试表来说明两者的区别

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
CREATE TABLE `tb_test` (
  `id` int(8) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `list` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
);
INSERT INTO `tb_test` VALUES (1, 'name', 'daodao,xiaohu,xiaoqin');
INSERT INTO `tb_test` VALUES (2, 'name2', 'xiaohu,daodao,xiaoqin');
INSERT INTO `tb_test` VALUES (3, 'name3', 'xiaoqin,daodao,xiaohu');
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

原来以为mysql可以进行这样的查询：

```
SELECT id,name,list from tb_test WHERE 'daodao' IN(list); -- (一) 
```

![img](https://images2015.cnblogs.com/blog/249993/201609/249993-20160920213558715-1931077652.png)

实际上这样是不行的，这样只有当list字段的值等于'daodao'时（和IN前面的字符串完全匹配），查询才有效，否则都得不到结果，即使'daodao'真的在list中。

再来看看这个：

```
SELECT id,name,list from tb_test WHERE 'daodao' IN ('libk', 'zyfon', 'daodao'); -- (二)
```

![img](https://images2015.cnblogs.com/blog/249993/201609/249993-20160921001750731-486093364.png)

这样是可以的。

这两条到底有什么区别呢？为什么第一条不能取得正确的结果，而第二条却能取得结果。原因其实是（一）中 (list) list是变量， 而（二）中 ('libk', 'zyfon', 'daodao')是常量。
所以如果要让（一）能正确工作，需要用find_in_set():

```
SELECT id,name,list from tb_test WHERE FIND_IN_SET('daodao',list); -- (一)的改进版
```

![img](https://images2015.cnblogs.com/blog/249993/201609/249993-20160921001815684-828184073.png)

**总结：**
所以如果list是常量，则可以直接用IN， 否则要用find_in_set()函数。

\--------------------------------------------------------

**find_in_set()和like的区别：**

在mysql中，有时我们在做数据库查询时，需要得到某字段中包含某个值的记录，但是它也不是用like能解决的，使用like可能查到我们不想要的记录，它比like更精准，这时候mysql的FIND_IN_SET函数就派上用场了，下面来看一个例子。

创建表并插入语句：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
CREATE TABLE users(
    id int(6) NOT NULL AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    limits VARCHAR(50) NOT NULL, -- 权限
    PRIMARY KEY (id)
);

INSERT INTO users(name, limits) VALUES('小张','1,2,12'); 
INSERT INTO users(name, limits) VALUES('小王','11,22,32');
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 其中limits表示用户所拥有的权限（以逗号分隔），现在想查询拥有权限编号为2的用户，如果用like关键字的话，则查询结果如下：

```
SELECT * FROM users WHERE limits LIKE '%2%';
```

![img](https://images2015.cnblogs.com/blog/249993/201609/249993-20160921004321215-1374990584.png)

这样第二条数据不具有权限'2'的用户也查出来了，不符合预期。下面利用mysql 函数find_in_set()来解决。

```
SELECT * FROM users WHERE FIND_IN_SET(2,limits);
```

![img](https://images2015.cnblogs.com/blog/249993/201609/249993-20160921004636043-1677344596.png)

这样就能达到我们预期的效果，问题就解决了！

**注意**：mysql字符串函数 find_in_set(str1,str2)函数是返回str2中str1所在的位置索引，str2必须以","分割开。

**总结：**like是广泛的模糊匹配，字符串中没有分隔符，Find_IN_SET 是精确匹配，字段值以英文”,”分隔，Find_IN_SET查询的结果要小于like查询的结果。

