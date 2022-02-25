# [mysql insert一条记录后 返回创建记录主键id的方法](https://www.cnblogs.com/pxzbky/p/10261277.html)

==一种是数据库(如MySQL,SQLServer)支持auto-generated key field，另一种是数据库（如Oracle）不支持auto-generated key field的。==

mysql插入数据后返回自增ID的方法

mysql和oracle插入的时候有一个很大的区别是，oracle支持序列做id，mysql本身有一个列可以做自增长字段，mysql在插入一条数据后，如何能获得到这个自增id的值呢？

方法一：是使用last_insert_id

```
mysql> SELECT LAST_INSERT_ID();
```

  产生的ID 每次连接后保存在服务器中。这意味着函数向一个给定客户端返回的值是该客户端产生对影响AUTO_INCREMENT列的最新语句第一个 AUTO_INCREMENT值的。这个值不能被其它客户端影响，即使它们产生它们自己的 AUTO_INCREMENT值。这个行为保证了你能够找回自己的 ID 而不用担心其它客户端的活动，而且不需要加锁或处理。 

  每次mysql_query操作在mysql服务器上可以理解为一次“原子”操作, 写操作常常需要锁表的， 是mysql应用服务器锁表不是我们的应用程序锁表。

  值得注意的是，如果你一次插入了多条记录，这个函数返回的是第一个记录的ID值。

>  因为LAST_INSERT_ID是基于Connection的，只要每个线程都使用独立的Connection对象，LAST_INSERT_ID函数 将返回该Connection对AUTO_INCREMENT列最新的insert or update*作生成的第一个record的ID。这个值不能被其它客户端（Connection）影响，保证了你能够找回自己的 ID 而不用担心其它客户端的活动，而且不需要加锁。使用单INSERT语句插入多条记录, LAST_INSERT_ID返回一个列表。
>   LAST_INSERT_ID 是与table无关的，如果向表a插入数据后，再向表b插入数据，LAST_INSERT_ID会改变。

方法二：是使用max(id)

使用last_insert_id是基础连接的，如果换一个窗口的时候调用则会一直返回10
如果不是频繁的插入我们也可以使用这种方法来获取返回的id值

```
select max(id) from user;
```

这个方法的缺点是不适合高并发。如果同时插入的时候返回的值可能不准确。

方法三：是创建一个存储过程，在存储过程中调用先插入再获取最大值的操作

```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS `test` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test`(in name varchar(100),out oid int)
BEGIN
  insert into user(loginname) values(name);
  select max(id) from user into oid;
  select oid;
END $$
DELIMITER ;
call test('gg',@id);
```



方法四:使用@@identity

```
select @@IDENTITY
```

  @@identity是表示的是最近一次向具有identity属性(即自增列)的表插入数据时对应的自增列的值，是系统定 义的全局变量。一般系统定义的全局变量都是以@@开头，用户自定义变量以@开头。比如有个表A，它的自增列是id，当向A表插入一行数据后，如果插入数据 后自增列的值自动增加至101，则通过select @@identity得到的值就是101。使用@@identity的前提是在进行insert操作后，执行select @@identity的时候连接没有关闭，否则得到的将是NULL值。

方法五:是使用getGeneratedKeys()

```sql
Connection conn = ;
Serializable ret = null;
PreparedStatement state = .;
ResultSet rs=null;
try {
    state.executeUpdate();
    rs = state.getGeneratedKeys();
    if (rs.next()) {
        ret = (Serializable) rs.getObject(1);
    }     
} catch (SQLException e) {
}
return ret;
```



总结一下，在mysql中做完插入之后获取id在高并发的时候是很容易出错的。另外last_insert_id虽然是基于session的但是不知道为什么没有测试成功。


方法6：selectkey:

其实在ibtias框架里使用selectkey这个节点，并设置insert返回值的类型为integer，就可以返回这个id值。

SelectKey在Mybatis中是为了解决Insert数据时不支持主键自动生成的问题，他可以很随意的设置生成主键的方式。

不管SelectKey有多好，尽量不要遇到这种情况吧，毕竟很麻烦。

 

| 属性            | 描述                                                         |
| --------------- | ------------------------------------------------------------ |
| `keyProperty`   | selectKey 语句结果应该被设置的目标属性。                     |
| `resultType`    | 结果的类型。MyBatis 通常可以算出来,但是写上也没有问题。MyBatis 允许任何简单类型用作主键的类型,包括字符串。 |
| `order`         | 这可以被设置为 BEFORE 或 AFTER。如果设置为 BEFORE,那么它会首先选择主键,设置 keyProperty 然后执行插入语句。如果设置为 AFTER,那么先执行插入语句,然后是 selectKey 元素-这和如 Oracle 数据库相似,可以在插入语句中嵌入序列调用。 |
| `statementType` | 和前面的相 同,MyBatis 支持 STATEMENT ,PREPARED 和CALLABLE 语句的映射类型,分别代表 PreparedStatement 和CallableStatement 类型。 |

 

SelectKey需要注意order属性，像Mysql一类支持自动增长类型的数据库中，order需要设置为after才会取到正确的值。

像Oracle这样取序列的情况，需要设置为before，否则会报错。

 

另外在用Spring管理事务时，SelectKey和插入在同一事务当中，因而Mysql这样的情况由于数据未插入到数据库中，所以是得不到自动增长的Key。取消事务管理就不会有问题。

 

下面是一个xml和注解的例子，SelectKey很简单，两个例子就够了：

```xml
<insert id="insert" parameterType="map">  
    insert into table1 (name) values (#{name})  
    <selectKey resultType="java.lang.Integer" keyProperty="id">  
      CALL IDENTITY()  
    </selectKey>  
</insert>
```



==上面xml的传入参数是map，selectKey会将结果放到入参数map中。用POJO的情况一样，但是有一点需要注意的是，keyProperty对应的字段在POJO中必须有相应的setter方法，setter的参数类型还要一致，否则会报错。==

==注意：selectKey操作会将操作查询结果赋值到insert元素的parameterType的入参实例下对应的属性中。并提供给insert语句使用==

```xml
@Insert("insert into table2 (name) values(#{name})")  
@SelectKey(statement="call identity()", keyProperty="nameId", before=false, resultType=int.class)  
int insertTable2(Name name); 
```

上面是注解的形式。

方法:7：使用<insert中的useGeneratedKeys 和keyProperty 两个属性

1.在Mybatis Mapper文件中添加属性“useGeneratedKeys”和“keyProperty”，其中**keyProperty是Java对象的属性名，而不是表格的字段名**。

例如：<insert id="insertSelective" keyColumn="measurement_record_id" keyProperty="measurementRecordId" parameterType="com.tbt.purchase.model.BodyMeasurementsNew" useGeneratedKeys="true">

2.Mybatis执行完插入语句后，自动将自增长值赋值给对象systemBean的属性id。因此，可通过systemBean对应的getter方法获取！

 

【注意事项】

1.Mybatis Mapper 文件中，“useGeneratedKeys”和“keyProperty”必须添加，而且keyProperty一定得和java对象的属性名称一致，而不是表格的字段名

2.java Dao中的Insert方法，传递的参数必须为java对象，也就是Bean，而不能是某个参数。



----



## SQL INSERT INTO SELECT 语句

INSERT INTO SELECT 语句从一个表复制数据，然后把数据插入到一个已存在的表中。目标表中任何已存在的行都不会受影响。

**INSERT** **INTO** table2
**SELECT** * **FROM** table1;



**INSERT** **INTO** Websites (name, country)
**SELECT** app_name, country **FROM** apps
**WHERE** id=1;

----

# [MyBatis+MySQL 返回插入的主键ID](https://blog.csdn.net/ido1ok/article/details/80073999)

方法：在mapper中指定keyProperty属性，示例如下：

Xml代码 

```xml
<insert id="insertAndGetId" useGeneratedKeys="true" keyProperty="uId" parameterType="com.chenzhou.mybatis.User">  
    insert into user(userName,password,comment)  
    values(#{userName},#{password},#{comment})  
</insert>  
```

 如上所示，我们在[insert](https://so.csdn.net/so/search?q=insert&spm=1001.2101.3001.7020)中指定了keyProperty="uId"，其中uId代表插入的User对象的主键属性。



如果mybaities报错无法识别这个uId,我们需要查看这个uid是否在返回对象实体类里，名称是否相同。最好和数据库主键名相同，如果还是不行，把uId改成（传入对象）.uId 比如user.uId



我们使用这种方式需要知其然也有知其所以然。



**1.insert 属性详解：**



 parameterType ，入参的全限定类名或类型别名

  keyColumn ，设置数据表自动生成的主键名。对特定数据库（如PostgreSQL），若自动生成的主键不是第一个字段则必须设置

  keyProperty ，默认值unset，用于设置getGeneratedKeys方法或selectKey子元素返回值将赋值到领域模型的哪个属性中

  useGeneratedKeys ，取值范围true|false(默认值)，设置是否使用JDBC的getGenereatedKeys方法获取主键并赋值到keyProperty设置的领域模型属性中。MySQL和SQLServer执行auto-generated key field，因此当数据库设置好自增长主键后，可通过JDBC的getGeneratedKeys方法获取。但像Oralce等不支持auto-generated key field的数据库就不能用这种方法获取主键了

  statementType ，取值范围STATEMENT,PREPARED（默认值）,CALLABLE

  flushCache ，取值范围true(默认值)|false，设置执行该操作后是否会清空二级缓存和本地缓存

  timeout ，默认为unset（依赖jdbc驱动器的设置），设置执行该操作的最大时限，超时将抛异常

  databaseId ，取值范围oracle|mysql等，表示数据库厂家，元素内部可通过`<if test="_databaseId = 'oracle'">`来为特定数据库指定不同的sql语句





## 2.数据库需要支持自增主键(mysql、sqlserver)

==使用insert、update标签中的useGeneratedKeys、keyProperty来获取主键返回值，useGeneratedKeys设置为true，keyProperty设置为主键对应实体类的属性值，如果是联合主键那么属性名用逗号隔开；insert时，返回的是新增记录的主键值、update时返回的时更新记录的主键值==
==useGeneratedKeys="true" keyProperty="id"==

```
 <insert id="insertSelective" parameterType="testmaven.entity.User" useGeneratedKeys="true" keyProperty="id">
  insert into user(name,age) values (#{name,jdbcType=VARCHAR},#{age,jdbcType=INTEGER}) 
 </insert>
```

同理，如果插入多条记录，只要设置了`useGeneratedKeys、keyProperty`，同样可以获取主键；

```csharp
<insert id="insertBatch"  useGeneratedKeys="true" keyProperty="id">
      insert into user(name,age) values
      <foreach collection="list" separator=","  item="item">
         (#{item.name,jdbcType=VARCHAR},#{item.age,jdbcType=INTEGER}) 
      </foreach>
  </insert>
```

## 3.非mysql数据库，数据库不支持自增主键（oracle）

在数据库不支持自增主键情况下，需要**使用selectKey来返回插入的主键值**。

------

### selectKey属性

```vbnet
<selectKey resultType="java.lang.Integer" order="AFTER" keyProperty="id">
            select last_insert_id() as id
 </selectKey>
```

| 属性名      | 作用                                            |
| :---------- | :---------------------------------------------- |
| resultType  | selectKey指定sql返回值类型                      |
| order       | 执行顺序，after，表示后执行；before，表示限制性 |
| keyProperty | 主键对应实体类中的属性名字                      |

==注意：selectKey操作会将操作查询结果赋值到insert元素的parameterType的入参实例下对应的属性中。并提供给insert语句使用==

------

### 插入记录后，获取主键（如mysql）

selectKey中的order=after，代表先执行insert into，后执行selectKey。此处利用mysql的last_insert_id函数来获取最后一条记录的id

```xml
<insert id="insert" parameterType="com.mycat.test.model.Test">
        INSERT INTO test(name) VALUES(#{name,jdbcType=VARCHAR})
        <selectKey resultType="java.lang.Integer" order="AFTER" keyProperty="id">
            select last_insert_id() as id
        </selectKey>
    </insert>
```

- 

### 插入记录前，获取主键（如oracle）

注意，selectKey中的order=before，代表先执行selectKey，后执行insert into。此处利用sequence先获取id值，设置到sql中，然后返回主键。

```xml
<insert id="insert" parameterType="com.mycat.test.model.Test">
        INSERT INTO test(id,name) VALUES(#{id,jdbcType=INTEGER},
        #{name,jdbcType=VARCHAR})
        <selectKey resultType="java.lang.Integer" 
          order="before" keyProperty="id">
            select xx_sequence.nextval from dual
        </selectKey>
    </insert>
```

----



# [MyBatis insert 返回主键的方法(oracle和mysql)](https://www.cnblogs.com/tv151579/archive/2013/03/11/2954841.html)

参考：

1.http://liuqing9382.iteye.com/blog/1574864

2.http://blog.csdn.net/ultrani/article/details/9351573

3.mybatis中文文档

 

**作者前言：**

使用Mybatis时，对于不同数据库比如Oracle、SQL Server、Mysql，它们的主键生成策略是不同的：

\1. Oracle自增主键必须得配一个sequence；

\2. SQL Server和Mysql的自增使用自动自增设置的；

\3. 对于非自增的主键，项目也可以使用数据库函数来产生唯一主键，比如uuid()。
**插入操作：** 
\1. 对于类似mysql、SQL Server这样自增主键的表，插入可以不配置插入的主键列（在sql中显式的写出该id）；

\2. 类似Oracle这类使用sequence或者uuid()这种数据库函数产生唯一主键，如果不做触发器之类的设置的话，一般需要在sql中写出主键列的。

**获取主键**：

mybatis针对以上的不同生成策略以及不同的sql主键配置类型，将插入数据返回主键的解决方案分为一下几个情况：

\1. 如果使用的数据库支持自动生成主键（如：MySQL 和 SQL Server），那么您就可以简单地将 useGeneratedKeys 设置为”true”，然后使用 keyProperty 设置你希望自动生成主键的字段就可以了。

例如，如果 Author 表使用一个字段自动生成主键，那么配置语句就可以修改为：

```
<insert id="insertAuthor" parameterType="domain.blog.Author" useGeneratedKeys=”true” keyProperty=”id”>
　　insert into Author (username,password,email,bio) values (#{username},#{password},#{email},#{bio})
</insert>
```

对于useGeneratedKeys和keyProperty属性的说明如下图：

![img](mysql insert一条记录后 返回创建记录主键id的方法.assets/062219295847869.jpg)

\2. MyBatis 还有另外一种方式为不支持自动生成主键的数据库及 JDBC 驱动来生成键值，下面展示一个能够随机生成 ID 的例子（也许你不会这么做，这仅仅是演示 MyBatis 的功能，文档的词语，意思像是说至于你做不做，反正我做了）：

[![复制代码](mysql insert一条记录后 返回创建记录主键id的方法.assets/copycode.gif)](javascript:void(0);)

```xml
<insert id="insertAuthor" parameterType="domain.blog.Author">
　　<selectKey keyProperty="id" resultType="java.lang.integer" order="BEFORE">
　　　　select CAST(RANDOM()*1000000 as INTEGER) a from SYSIBM.SYSDUMMY1
　　</selectKey>
　　insert into Author (id, username, password, email,bio, favourite_section)
　　　　values (#{id}, #{username}, #{password}, #{email}, #{bio}, #{favouriteSection,jdbcType=VARCHAR})
</insert>
```

==注意：mapper接口返回值依然是成功插入的记录数，但不同的是主键值已经赋值到领域模型实体的id中了。==

[![复制代码](mysql insert一条记录后 返回创建记录主键id的方法.assets/copycode.gif)](javascript:void(0);)

注意：上面的语句中标红的文字，添加了**selectKey标签**，首先解释如下图：

![img](mysql insert一条记录后 返回创建记录主键id的方法.assets/062252165842533.jpg)

正如上面的解释我们只要把握住order的设置，在sql语句执行前（BEFORE）或者执行后（AFTER），执行selectKey 语句来获得主键就可以了，如上面例子selectKey首先执行，生成随机的主键，这时候Author对象中的id首先被赋值了，然后才会调用insert 语句。这相当于在您的数据库中自动生成键值，不需要编写复杂的 java 代码。

**当然，是否需要配置<selectKey>根据情况，只要能保证记录有主键即可，一旦配置了<selectKey>，就可以在执行插入操作时获取到新增记录的主键。** 
**注意:如果没有配置<selectKey>那么保存后的对象的主键依旧为null。**

 

**小结：**

通过上面的方案：

\1. 我们针对uuid()函数的主键返回应该如下：

[![复制代码](mysql insert一条记录后 返回创建记录主键id的方法.assets/copycode.gif)](javascript:void(0);)

```xml
    <insert id="insertTestRole" parameterType="hashmap" >
        <selectKey resultType="java.lang.String" order="BEFORE" keyProperty="id"> 
        SELECT uuid()
        </selectKey>
        insert into
        testRole(id,name)
        values(#{id},#{name})
    </insert>
```

[![复制代码](mysql insert一条记录后 返回创建记录主键id的方法.assets/copycode.gif)](javascript:void(0);)

\2. oracle针对Sequence主键而言，隐式主键插入前必须指定一个主键值给要插入的记录： 

```xml
<insert id="AltName.insert" parameterType="AltName">  
   　　<selectKey resultType="long" keyProperty="id">  
   　　　　SELECT SEQ_TEST.NEXTVAL FROM DUAL   
   　　</selectKey>  
   　　insert into altname(primaryName,alternateName,type)values(#{primaryName},#{alternateName},#{type})   
 </insert> 
```

或者显式主键：

[![复制代码](mysql insert一条记录后 返回创建记录主键id的方法.assets/copycode.gif)](javascript:void(0);)

```xml
    <insert id="insertEnterprise" parameterType="hashmap">
        <selectKey resultType="integer" order="AFTER" keyProperty="ENTERPRISE_ID">
            select sq_enterprise.currval from dual
        </selectKey>
            insert into
                m_enterprise
                (ENTERPRISE_ID,ENTERPRISE_NAME,ENTERPRISE_ADDRESS,ENTERPRISE_INTRODUCTION,ENTERPRISE_ZIP,ENTERPRISE_PHONE,ENTERPRISE_NUMBER)
            values
                (sq_enterprise.nextval,#{enterprise_name},#{address},#{introduction},#{zip},#{phone},#{enterprise_number})
    </insert>
```

[![复制代码](mysql insert一条记录后 返回创建记录主键id的方法.assets/copycode.gif)](javascript:void(0);)

\3. MySql、sql server自增主键而言，这类表在插入时不需要主键，而是在插入过程自动获取一个自增的主键： 

```xml
     <insert id="AltName.insert" parameterType="AltName">
      　　<selectKey resultType="long" keyProperty="id">
      　　　　SELECT LAST_INSERT_ID()
      　　</selectKey>
      　　insert into altname(primaryName,alternateName,type)values(#{primaryName},#{alternateName},#{type})
    </insert>
```

根据获得自增主键的方法，我们还可以：

```xml
     <insert id="AltName.insert" parameterType="AltName">
      　　<selectKey resultType="long" keyProperty="id">
      　　　　SELECT @@IDENTITY
      　　</selectKey>
      　　insert into altname(primaryName,alternateName,type)values(#{primaryName},#{alternateName},#{type})
    </insert>
```

但是参考**http://blog.csdn.net/ultrani/article/details/9351573** 中四种获得自增主键的方法利弊分析，作者推荐使用useGeneratedKeys属性设置来利用JDBC的getGeneratedKeys方法获得自增主键。



==注意：对于非自增主键数据库如Oracle，insert使用useGeneratedKeys =true一样会返回主键值，哪怕没有设置主键也会返回一个隐藏的rowid，因为Oracle没有设置主键会自动生成一个随机主键rowid，此时返回的就是这个主键，Oracle设置了主键但是没有自增返回的也是这个rowid==



----

# [MYSQL获取自增主键【4种方法】](https://blog.csdn.net/ultrani/article/details/9351573)