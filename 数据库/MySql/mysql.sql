`sys_user`数据库密码：localhost:3306/ruoyi?useUnicode=TRUE&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=TRUE&serverTimezone=Asia/Shanghai
root/123456

#多表连接：真正的应用中常常需要从多个数据表中读取数据
#--内连接，外连接（左，右，全），交叉连接，自然连接

#1对1，1对多（1：n），多对多（m：n）表的对应关系

#查询书的名字，同时还要查询章节(当要查询的字段在多张表中都存在的时候就要加books.或b.)
#起别名的as可省略
#内连接：匹配不上不显示（取反则会显示所有不匹配的情况）
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid!=c.bookid

#多表连接
SELECT u.id,username,g.name FROM p_users u INNER JOIN p_user_group ug ON u.id=ug.uid INNER JOIN p_group g ON ug.gid=g.id

#左外连接：会把左表匹配不上的数据也显示出来（即左表所有数据都会显示，但右表只显示出了匹配上的数据）
SELECT b.bookid,bookname,charpterName FROM books b LEFT JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM charpters c  LEFT JOIN books b ON b.bookid=c.bookid

#右外连接
SELECT b.bookid,bookname,charpterName FROM books b RIGHT JOIN charpters c ON b.bookid=c.bookid

#全外连接：保留两表所有数据

#交叉连接：笛卡尔积（模拟实现彩排的所有组合全排列）
SELECT b.bookid,bookname,charpterName FROM charpters CROSS JOIN books b
SELECT c.n,b.n,a.n FROM ball a CROSS JOIN ball b CROSS JOIN ball c

#保存查询的数据结果：创建临时表用insert插入
INSERT INTO ball3d(a,b,c) SELECT c.n,b.n,a.n FROM ball a CROSS JOIN ball b CROSS JOIN ball c
SELECT SUM(n) FROM ball WHERE n%2=0


#练习1：求出ball2表的奇数行和偶数行求和结果，并存入另一张表
INSERT INTO ball2(n) SELECT n FROM ball
INSERT INTO getsum(oddsum,evensum) SELECT SUM(n),(SELECT SUM(n) FROM ball2 WHERE MOD(id,2)=0) FROM ball2 WHERE MOD(id,2)=1

#练习2：当银行将用户余额少于2元的账户删除后，重新在Account表中恢复Users表中未有的CardID账户
INSERT INTO `account`(CardID,Score) SELECT u.CardID,2 FROM users u LEFT JOIN `account` a ON u.CardID=a.CardID WHERE a.CardID IS  NULL
#用代码方式： 
#新建数据库
CREATE DATABASE javaoop

#删除数据库
DROP DATABASE javaoop

#删除表格
DROP TABLE aa

#新建表格
CREATE TABLE student3(
stid INT PRIMARY KEY AUTO_INCREMENT,
stname VARCHAR(10) NOT NULL,
phone CHAR(11) ,
birthday DATETIME DEFAULT '123',
money DECIMAL(12,2)
)

#加上not null则必须非空，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone SET DEFAULT 'ab';
#追加新增字段
ALTER TABLE student ADD address  ;
#追加新增外键约束
ALTER TABLE student ADD CONSTRAINT fk_class FOREIGN KEY(class) REFERENCES classes(class_id);
INSERT INTO adminlogin VALUE (2,'nanshen','123456'),(3,'ainin','123#用代码方式： 
#新建数据库
create database javaoop

#删除数据库
drop database javaoop

#删除表格
drop table aa

#新建表格
create table student3(
stid int primary key auto_increment,
stname varchar(10) not null,
phone char(11) ,
birthday datetime default '123',
money decimal(12,2)
)
#多表连接：真正的应用中常常需要从多个数据表中读取数据
#--内连接，外连接（左，右，全），交叉连接，自然连接

#1对1，1对多（1：n），多对多（m：n）表的对应关系

#查询书的名字，同时还要查询章节(当要查询的字段在多张表中都存在的时候就要加books.或b.)
#起别名的as可省略
#内连接：匹配不上不显示（取反则会显示所有不匹配的情况）
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid!=c.bookid

#多表连接
select u.id,username,g.name from p_users u inner join p_user_group ug on u.id=ug.uid inner join p_group g on ug.gid=g.id

#左外连接：会把左表匹配不上的数据也显示出来（即左表所有数据都会显示，但右表只显示出了匹配上的数据）
SELECT b.bookid,bookname,charpterName FROM books b left JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM charpters c  LEFT JOIN books b ON b.bookid=c.bookid

#右外连接
SELECT b.bookid,bookname,charpterName FROM books b right JOIN charpters c ON b.bookid=c.bookid

#全外连接：保留两表所有数据

#交叉连接：笛卡尔积（模拟实现彩排的所有组合全排列）
SELECT b.bookid,bookname,charpterName FROM charpters cross JOIN books b
select c.n,b.n,a.n from ball a cross join ball b cross join ball c

#保存查询的数据结果：创建临时表用insert插入
insert into ball3d(a,b,c) SELECT c.n,b.n,a.n FROM ball a CROSS JOIN ball b CROSS JOIN ball c
SELECT SUM(n) FROM ball WHERE n%2=0


#练习1：求出ball2表的奇数行和偶数行求和结果，并存入另一张表
insert into ball2(n) select n from ball
insert into getsum(oddsum,evensum) select sum(n),(SELECT SUM(n) FROM ball2 WHERE MOD(id,2)=0) from ball2 where mod(id,2)=1

#练习2：当银行将用户余额少于2元的账户删除后，重新在Account表中恢复Users表中未有的CardID账户
insert into `account`(CardID,Score) select u.CardID,2 from users u left join `account` a on u.CardID=a.CardID where a.CardID is  null
#用代码方式： 
#新建数据库
create database javaoop

#删除数据库
drop database javaoop

#删除表格
drop table aa

#新建表格
create table student3(
stid int primary key auto_increment,
stname varchar(10) not null,
phone char(11) ,
birthday datetime default '123',
money decimal(12,2)
)

#加上not null则必须非空，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone set DEFAULT 'ab';
#追加新增字段
alter table student add address  ;
#追加新增外键约束
alter table student add constraint fk_class foreign key(class) references classes(class_id);
#用代码方式： 
#新建数据库
create database javaoop

#删除数据库
drop database javaoop

#删除表格
drop table aa

#新建表格
create table student3(
stid int primary key auto_increment,
stname varchar(10) not null,
phone char(11) ,
birthday datetime default '123',
money decimal(12,2)
)

#加上not null则必须非空，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone set DEFAULT 'ab';
#追加新增字段
alter table student add address  ;
#追加新增外键约束
alter table student add constraint fk_class foreign key(class) references classes(class_id);
#用代码方式： 
#新建数据库
create database javaoop

#删除数据库
drop database javaoop

#删除表格
drop table aa

#新建表格
create table student3(
stid int primary key auto_increment,
stname varchar(10) not null,
phone char(11) ,
birthday datetime default '123',
money decimal(12,2)
)

#加上not null则必须非空，auto_increment自增，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone set DEFAULT 'ab';
#追加新增字段
alter table student add address  ;
#追加新增外键约束
alter table student add constraint fk_class foreign key(class) references classes(class_id);
#新增一条记录，除了数值型数据不打引号其他都要打，想要在什么字段添加数据就写上什么字段，（注意：不要违反自己设的约束条件）
insert into student(stname)value('女神a'),('男神')

#修改数据,若不加where条件，则所有记录的字段都会被修改
update student set phone='566785',class=3 where stid=4
update student set free=231.123,class=2 where (stid>=3&&stid<=5)||stid=6
update student set money=money+200

#删除数据,不写where则会删除所有数据,delete不会清空自动增长列
delete from student where stname='女神a'||stname='aa'
DELETE FROM student WHERE stname='女神a' or stname='aa'
#注意：当其他表引用了此行数据的时候无法删除数据，如学生表有学生引用了外键classid=3，则无法删除classid=3此行数据，除非先删除清空其学生
delete from classes where class_id=4
delete from address2
-- 物理删除  自动增长列清零
TRUNCATE TABLE student

-- 删除表
DROP TABLE student

#查询------------------------------------------
select * from student 
select stname,phone from student where stid=2||stid=3||stid=6
select * from student where money>700
select * from student where stid between 2 and 5
#in范围查询
select * from student where stid in(2,4,6,7,8)
#查询可以起别名
SELECT stname AS 姓名,phone AS 电话 FROM student
#查询的同时并计算
SELECT stname,money,free,money*free AS 总金额 FROM student
#查询并过滤重复数据（多个字段则要所有字段都重复了才会过滤）
SELECT DISTINCT phone FROM student
#模糊查询   %：匹配0~n个任意字符  _:匹配一个任意字符
select * from student where stname like '%乐%'
SELECT * FROM student WHERE stname LIKE '%'
SELECT * FROM student WHERE stname LIKE '__'
#查找空值
select * from student where class is null
SELECT * FROM student WHERE class IS not NULL
#排序(默认升序，DESC降序)
SELECT * FROM student WHERE class IS not NULL order by money
SELECT * FROM student WHERE class IS NOT NULL ORDER BY money desc

#分页查询  （查询lol数据库的bbc表）第一个数字：跳过多少行 利用公式（page-1）*第二个数字N;  第二个数字N：显示多少行
SELECT * FROM bbc limit 20,10

#聚合函数（聚合函数里不可再查询普通字段如：name，因为聚合函数只能显示一行，而name有很多行记录但只能显示一个）
#--SUM(字段) 求和
#--count(字段) 求某一字段不为空数据的记录条数，当为 * 时则只要所有字段有一个字段不为空即可进入统计
select name,sum(gdp) from bbc where region='Africa'
select gdp from bbc where region='Africa'
SELECT COUNT(*) FROM bbc WHERE region='Africa'
select count(name) from bbc where region='Africa'
#--max(字段),min(字段) 求某字段最大值（最小值）的记录。
select min(gdp) from bbc

#子查询：MySQL支持子查询可在查询语句内部嵌入另一条子查询语句（如查询最小gdp数据的国家名字）
select name from bbc where gdp=(SELECT MIN(gdp) FROM bbc)

#平均查询（利用子查询查询欧洲地区gdp大于平均值的国家）
SELECT AVG(gdp) FROM bbc WHERE region='Europe'
select name,gdp from bbc where gdp>(select avg(gdp) from bbc where region='Europe')

#分组查询（注意：普通字段如name等不能再分组查询里查询，而聚合函数可以，因为分组查询查到几个组就只会显示几行，
#而name每组有很多条记录但只能显示每组其中一条，而聚合函数每组只有一条便可以正常查询）
select region ,COUNT(*) from bbc group by region
#分组查询过滤--having
SELECT region ,COUNT(*) FROM bbc GROUP BY region having count(*)>=20

#MySQL的常用函数---------------------------
#ASCII(s):返回字符串 s 的第一个字符的 ASCII 码。
SELECT ASCII('NAME') AS NumCodeOfFirstChar
#返回表bbc中 name 字段第一个字母的 ASCII 码：
SELECT ASCII(name) AS NumCodeOfFirstCharFROM from bbc;

#CHAR_LENGTH(s)：返回字符串 s 的字符数
SELECT CHAR_LENGTH("RUNOOB") AS LengthOfString;
#返回bbc中name字段的字符长度
SELECT CHAR_LENGTH(name) AS LengthOfString from bbc;

#FIELD(s,s1,s2...):返回第一个字符串 s 在字符串列表(s1,s2...)中的位置
#单引号，双引号都一样：大多数数据库都支持单引号和双引号的互换，即varchar类型的变量既可以用答单引号来囊括，也可以用双引号。
SELECT FIELD('c', 'a', "b", "c", "d", "e");
SELECT FIND_IN_SET("cd", 'a,b,c,cd,e');

#INSERT(s1,x,len,s2):字符串 s2 替换 s1 的 x 位置开始长度为 len 的字符串
SELECT INSERT("google.com", 1, 6, "baidu");

#LOWER(s):将字符串 s 的所有字母变成小写字母
SELECT LOWER('RUNOOB')

#LPAD(s1,len,s2):在字符串 s1 的开始处填充字符串 s2，使字符串长度达到 len
select lpad('.com',8,'baidu')
SELECT LPAD('.com',10,'baidu')
SELECT LPAD('.com',2,'baidu')#多表连接：真正的应用中常常需要从多个数据表中读取数据
#--内连接，外连接（左，右，全），交叉连接，自然连接

#1对1，1对多（1：n），多对多（m：n）表的对应关系

#查询书的名字，同时还要查询章节(当要查询的字段在多张表中都存在的时候就要加books.或b.)
#起别名的as可省略
#内连接：匹配不上不显示（取反则会显示所有不匹配的情况）
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid!=c.bookid

#多表连接
select u.id,username,g.name from p_users u inner join p_user_group ug on u.id=ug.uid inner join p_group g on ug.gid=g.id

#左外连接：会把左表匹配不上的数据也显示出来（即左表所有数据都会显示，但右表只显示出了匹配上的数据）
SELECT b.bookid,bookname,charpterName FROM books b left JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM charpters c  LEFT JOIN books b ON b.bookid=c.bookid

#右外连接
SELECT b.bookid,bookname,charpterName FROM books b right JOIN charpters c ON b.bookid=c.bookid

#全外连接：保留两表所有数据

#交叉连接：笛卡尔积（模拟实现彩排的所有组合全排列）
SELECT b.bookid,bookname,charpterName FROM charpters cross JOIN books b
select c.n,b.n,a.n from ball a cross join ball b cross join ball c

#保存查询的数据结果：创建临时表用insert插入
insert into ball3d(a,b,c) SELECT c.n,b.n,a.n FROM ball a CROSS JOIN ball b CROSS JOIN ball c
SELECT SUM(n) FROM ball WHERE n%2=0


#练习1：求出ball2表的奇数行和偶数行求和结果，并存入另一张表
insert into ball2(n) select n from ball
insert into getsum(oddsum,evensum) select sum(n),(SELECT SUM(n) FROM ball2 WHERE MOD(id,2)=0) from ball2 where mod(id,2)=1

#练习2：当银行将用户余额少于2元的账户删除后，重新在Account表中恢复Users表中未有的CardID账户
insert into `account`(CardID,Score) select u.CardID,2 from users u left join `account` a on u.CardID=a.CardID where a.CardID is  null
#用代码方式： 
#新建数据库
create database javaoop

#删除数据库
drop database javaoop

#删除表格
drop table aa

#新建表格
create table student3(
stid int primary key auto_increment,
stname varchar(10) not null,
phone char(11) ,
birthday datetime default '123',
money decimal(12,2)
)

#加上not null则必须非空，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone set DEFAULT 'ab';
#追加新增字段
alter table student add address  ;
#追加新增外键约束
alter table student add constraint fk_class foreign key(class) references classes(class_id);
#多表连接：真正的应用中常常需要从多个数据表中读取数据
#--内连接，外连接（左，右，全），交叉连接，自然连接

#1对1，1对多（1：n），多对多（m：n）表的对应关系

#查询书的名字，同时还要查询章节(当要查询的字段在多张表中都存在的时候就要加books.或b.)
#起别名的as可省略
#内连接：匹配不上不显示（取反则会显示所有不匹配的情况）
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM books b INNER JOIN charpters c ON b.bookid!=c.bookid

#多表连接
select u.id,username,g.name from p_users u inner join p_user_group ug on u.id=ug.uid inner join p_group g on ug.gid=g.id

#左外连接：会把左表匹配不上的数据也显示出来（即左表所有数据都会显示，但右表只显示出了匹配上的数据）
SELECT b.bookid,bookname,charpterName FROM books b left JOIN charpters c ON b.bookid=c.bookid
SELECT b.bookid,bookname,charpterName FROM charpters c  LEFT JOIN books b ON b.bookid=c.bookid

#右外连接
SELECT b.bookid,bookname,charpterName FROM books b right JOIN charpters c ON b.bookid=c.bookid

#全外连接：保留两表所有数据

#交叉连接：笛卡尔积（模拟实现彩排的所有组合全排列）
SELECT b.bookid,bookname,charpterName FROM charpters cross JOIN books b
select c.n,b.n,a.n from ball a cross join ball b cross join ball c

#保存查询的数据结果：创建临时表用insert插入
insert into ball3d(a,b,c) SELECT c.n,b.n,a.n FROM ball a CROSS JOIN ball b CROSS JOIN ball c
SELECT SUM(n) FROM ball WHERE n%2=0


#练习1：求出ball2表的奇数行和偶数行求和结果，并存入另一张表
insert into ball2(n) select n from ball
insert into getsum(oddsum,evensum) select sum(n),(SELECT SUM(n) FROM ball2 WHERE MOD(id,2)=0) from ball2 where mod(id,2)=1

#练习2：当银行将用户余额少于2元的账户删除后，重新在Account表中恢复Users表中未有的CardID账户
insert into `account`(CardID,Score) select u.CardID,2 from users u left join `account` a on u.CardID=a.CardID where a.CardID is  null

#加上not null则必须非空，auto_increment自增，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone set DEFAULT 'ab';
#追加新增字段
alter table student add address  ;
#追加新增外键约束
alter table student add constraint fk_class foreign key(class) references classes(class_id);
#新增一条记录，除了数值型数据不打引号其他都要打，想要在什么字段添加数据就写上什么字段，（注意：不要违反自己设的约束条件）
insert into student(stname)value('女神a'),('男神')

#修改数据,若不加where条件，则所有记录的字段都会被修改
update student set phone='566785',class=3 where stid=4
update student set free=231.123,class=2 where (stid>=3&&stid<=5)||stid=6
update student set money=money+200

#删除数据,不写where则会删除所有数据,delete不会清空自动增长列
delete from student where stname='女神a'||stname='aa'
DELETE FROM student WHERE stname='女神a' or stname='aa'
#注意：当其他表引用了此行数据的时候无法删除数据，如学生表有学生引用了外键classid=3，则无法删除classid=3此行数据，除非先删除清空其学生
delete from classes where class_id=4
delete from address2
-- 物理删除  自动增长列清零
TRUNCATE TABLE student

-- 删除表
DROP TABLE student

#查询------------------------------------------
select * from student 
select stname,phone from student where stid=2||stid=3||stid=6
select * from student where money>700
select * from student where stid between 2 and 5
#in范围查询
select * from student where stid in(2,4,6,7,8)
#查询可以起别名
SELECT stname AS 姓名,phone AS 电话 FROM student
#查询的同时并计算
SELECT stname,money,free,money*free AS 总金额 FROM student
#查询并过滤重复数据（多个字段则要所有字段都重复了才会过滤）
SELECT DISTINCT phone FROM student
#模糊查询   %：匹配0~n个任意字符  _:匹配一个任意字符
select * from student where stname like '%乐%'
SELECT * FROM student WHERE stname LIKE '%'
SELECT * FROM student WHERE stname LIKE '__'
#查找空值
select * from student where class is null
SELECT * FROM student WHERE class IS not NULL
#排序(默认升序，DESC降序)
SELECT * FROM student WHERE class IS not NULL order by money
SELECT * FROM student WHERE class IS NOT NULL ORDER BY money desc

#分页查询  （查询lol数据库的bbc表）第一个数字：跳过多少行 利用公式（page-1）*第二个数字N;  第二个数字N：显示多少行
SELECT * FROM bbc limit 20,10

#聚合函数（聚合函数里不可再查询普通字段如：name，因为聚合函数只能显示一行，而name有很多行记录但只能显示一个）
#--SUM(字段) 求和
#--count(字段) 求某一字段不为空数据的记录条数，当为 * 时则只要所有字段有一个字段不为空即可进入统计
select name,sum(gdp) from bbc where region='Africa'
select gdp from bbc where region='Africa'
SELECT COUNT(*) FROM bbc WHERE region='Africa'
select count(name) from bbc where region='Africa'
#--max(字段),min(字段) 求某字段最大值（最小值）的记录。
select min(gdp) from bbc

#子查询：MySQL支持子查询可在查询语句内部嵌入另一条子查询语句（如查询最小gdp数据的国家名字）
select name from bbc where gdp=(SELECT MIN(gdp) FROM bbc)

#平均查询（利用子查询查询欧洲地区gdp大于平均值的国家）
SELECT AVG(gdp) FROM bbc WHERE region='Europe'
select name,gdp from bbc where gdp>(select avg(gdp) from bbc where region='Europe')

#分组查询（注意：普通字段如name等不能再分组查询里查询，而聚合函数可以，因为分组查询查到几个组就只会显示几行，
#而name每组有很多条记录但只能显示每组其中一条，而聚合函数每组只有一条便可以正常查询）
select region ,COUNT(*) from bbc group by region
#分组查询过滤--having
SELECT region ,COUNT(*) FROM bbc GROUP BY region having count(*)>=20

#MySQL的常用函数---------------------------
#ASCII(s):返回字符串 s 的第一个字符的 ASCII 码。
SELECT ASCII('NAME') AS NumCodeOfFirstChar
#返回表bbc中 name 字段第一个字母的 ASCII 码：
SELECT ASCII(name) AS NumCodeOfFirstCharFROM from bbc;

#CHAR_LENGTH(s)：返回字符串 s 的字符数
SELECT CHAR_LENGTH("RUNOOB") AS LengthOfString;
#返回bbc中name字段的字符长度
SELECT CHAR_LENGTH(name) AS LengthOfString from bbc;

#FIELD(s,s1,s2...):返回第一个字符串 s 在字符串列表(s1,s2...)中的位置
#单引号，双引号都一样：大多数数据库都支持单引号和双引号的互换，即varchar类型的变量既可以用答单引号来囊括，也可以用双引号。
SELECT FIELD('c', 'a', "b", "c", "d", "e");
SELECT FIND_IN_SET("cd", 'a,b,c,cd,e');

#INSERT(s1,x,len,s2):字符串 s2 替换 s1 的 x 位置开始长度为 len 的字符串
SELECT INSERT("google.com", 1, 6, "baidu");

#LOWER(s):将字符串 s 的所有字母变成小写字母
SELECT LOWER('RUNOOB')

#LPAD(s1,len,s2):在字符串 s1 的开始处填充字符串 s2，使字符串长度达到 len
select lpad('.com',8,'baidu')
SELECT LPAD('.com',10,'baidu')
SELECT LPAD('.com',2,'baidu')')#用代码方式： 
#新建数据库
CREATE DATABASE javaoop

#删除数据库
DROP DATABASE javaoop

#删除表格
DROP TABLE aa

#新建表格
CREATE TABLE student3(
stid INT PRIMARY KEY AUTO_INCREMENT,
stname VARCHAR(10) NOT NULL,
phone CHAR(11) ,
birthday DATETIME DEFAULT '123',
money DECIMAL(12,2)
)

#加上not null则必须非空，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone SET DEFAULT 'ab';
#追加新增字段
ALTER TABLE student ADD address  ;
#追加新增外键约束
ALTER TABLE student ADD CONSTRAINT fk_class FOREIGN KEY(class) REFERENCES classes(class_id);
#用代码方式： 
#新建数据库
CREATE DATABASE javaoop

#删除数据库
DROP DATABASE javaoop

#删除表格
DROP TABLE aa

#新建表格
CREATE TABLE student3(
stid INT PRIMARY KEY AUTO_INCREMENT,
stname VARCHAR(10) NOT NULL,
phone CHAR(11) ,
birthday DATETIME DEFAULT '123',
money DECIMAL(12,2)
)

#加上not null则必须非空，auto_increment自增，不加则默认可以为空,decimal(12,2)表示总长度12，小数2

#唯一性约束：唯一性，但一个表可以有多个字段有唯一约束（主键约束只能有一个字段有），可以某条记录为空，但其他记录就不可再为空了（唯一性）

#创建表格之后，再追加修改默认值
ALTER TABLE student2 ALTER COLUMN phone SET DEFAULT 'ab';
#追加新增字段
ALTER TABLE student ADD address  ;
#追加新增外键约束
ALTER TABLE student ADD CONSTRAINT fk_class FOREIGN KEY(class) REFERENCES classes(class_id);
#新增一条记录，除了数值型数据不打引号其他都要打，想要在什么字段添加数据就写上什么字段，（注意：不要违反自己设的约束条件）
INSERT INTO student(stname)VALUE('女神a'),('男神')

#修改数据,若不加where条件，则所有记录的字段都会被修改
UPDATE student SET phone='566785',class=3 WHERE stid=4
UPDATE student SET free=231.123,class=2 WHERE (stid>=3&&stid<=5)||stid=6
UPDATE student SET money=money+200

#删除数据,不写where则会删除所有数据,delete不会清空自动增长列
DELETE FROM student WHERE stname='女神a'||stname='aa'
DELETE FROM student WHERE stname='女神a' OR stname='aa'
#注意：当其他表引用了此行数据的时候无法删除数据，如学生表有学生引用了外键classid=3，则无法删除classid=3此行数据，除非先删除清空其学生
DELETE FROM classes WHERE class_id=4
DELETE FROM address2
-- 物理删除  自动增长列清零
TRUNCATE TABLE student

-- 删除表
DROP TABLE student

#查询------------------------------------------
SELECT * FROM student 
SELECT stname,phone FROM student WHERE stid=2||stid=3||stid=6
SELECT * FROM student WHERE money>700
SELECT * FROM student WHERE stid BETWEEN 2 AND 5
#in范围查询
SELECT * FROM student WHERE stid IN(2,4,6,7,8)
#查询可以起别名
SELECT stname AS 姓名,phone AS 电话 FROM student
#查询的同时并计算
SELECT stname,money,free,money*free AS 总金额 FROM student
#查询并过滤重复数据（多个字段则要所有字段都重复了才会过滤）
SELECT DISTINCT phone FROM student
#模糊查询   %：匹配0~n个任意字符  _:匹配一个任意字符
SELECT * FROM student WHERE stname LIKE '%乐%'
SELECT * FROM student WHERE stname LIKE '%'
SELECT * FROM student WHERE stname LIKE '__'
#查找空值
SELECT * FROM student WHERE class IS NULL
SELECT * FROM student WHERE class IS NOT NULL
#排序(默认升序，DESC降序)
SELECT * FROM student WHERE class IS NOT NULL ORDER BY money
SELECT * FROM student WHERE class IS NOT NULL ORDER BY money DESC

#分页查询  （查询lol数据库的bbc表）第一个数字：跳过多少行 利用公式（page-1）*第二个数字N;  第二个数字N：显示多少行
SELECT * FROM bbc LIMIT 20,10

#聚合函数（聚合函数里不可再查询普通字段如：name，因为聚合函数只能显示一行，而name有很多行记录但只能显示一个）
#--SUM(字段) 求和
#--count(字段) 求某一字段不为空数据的记录条数，当为 * 时则只要所有字段有一个字段不为空即可进入统计
SELECT NAME,SUM(gdp) FROM bbc WHERE region='Africa'
SELECT gdp FROM bbc WHERE region='Africa'
SELECT COUNT(*) FROM bbc WHERE region='Africa'
SELECT COUNT(NAME) FROM bbc WHERE region='Africa'
#--max(字段),min(字段) 求某字段最大值（最小值）的记录。
SELECT MIN(gdp) FROM bbc

#子查询：MySQL支持子查询可在查询语句内部嵌入另一条子查询语句（如查询最小gdp数据的国家名字）
SELECT NAME FROM bbc WHERE gdp=(SELECT MIN(gdp) FROM bbc)

#平均查询（利用子查询查询欧洲地区gdp大于平均值的国家）
SELECT AVG(gdp) FROM bbc WHERE region='Europe'
SELECT NAME,gdp FROM bbc WHERE gdp>(SELECT AVG(gdp) FROM bbc WHERE region='Europe')

#分组查询（注意：普通字段如name等不能再分组查询里查询，而聚合函数可以，因为分组查询查到几个组就只会显示几行，
#而name每组有很多条记录但只能显示每组其中一条，而聚合函数每组只有一条便可以正常查询）
SELECT region ,COUNT(*) FROM bbc GROUP BY region
#分组查询过滤--having
SELECT region ,COUNT(*) FROM bbc GROUP BY region HAVING COUNT(*)>=20

#MySQL的常用函数---------------------------
#ASCII(s):返回字符串 s 的第一个字符的 ASCII 码。
SELECT ASCII('name') AS NumCodeOfFirstChar
#返回表bbc中 name 字段第一个字母的 ASCII 码：
SELECT ASCII(NAME) AS NumCodeOfFirstCharFROM FROM bbc;

#CHAR_LENGTH(s)：返回字符串 s 的字符数
SELECT CHAR_LENGTH("RUNOOB") AS LengthOfString;
#返回bbc中name字段的字符长度
SELECT CHAR_LENGTH(NAME) AS LengthOfString FROM bbc;

#FIELD(s,s1,s2...):返回第一个字符串 s 在字符串列表(s1,s2...)中的位置
#单引号，双引号都一样：大多数数据库都支持单引号和双引号的互换，即varchar类型的变量既可以用答单引号来囊括，也可以用双引号。
SELECT FIELD('c', 'a', "b", "c", "d", "e");
SELECT FIND_IN_SET("cd", 'a,b,c,cd,e');

#INSERT(s1,x,len,s2):字符串 s2 替换 s1 的 x 位置开始长度为 len 的字符串
SELECT INSERT("google.com", 1, 6, "baidu");

#LOWER(s):将字符串 s 的所有字母变成小写字母
SELECT LOWER('RUNOOB')

#LPAD(s1,len,s2):在字符串 s1 的开始处填充字符串 s2，使字符串长度达到 len
SELECT LPAD('.com',8,'baidu')
SELECT LPAD('.com',10,'baidu')
SELECT LPAD('.com',2,'baidu')