# [ibatis实战之一对多关联](https://blog.csdn.net/hffygc/article/details/87629433)

在实际开发中,我们常常遇到关联数据的情况,如User对象拥有若干Book对象

每个Book对象描述了归属于一个User信息,这种情况下,我们应该如何处理？

通过单独的Statement操作固然可以实现(通过Statement用于读取用户数据,再手工调用另外一个Statement

根据用户ID返回对应的book信息).不过这样未免失之繁琐.下面我们就看看在ibatis中,如何对关联数据进行操。

ibatis中,提供了Statement嵌套支持,通过Statement嵌套,我们即可实现关联数据的操作。
原文链接：https://blog.csdn.net/hffygc/article/details/87629433

```xml
 <!DOCTYPE sqlMap  PUBLIC "-//iBATIS.com//DTD SQL Map 2.0//EN"  "http://www.ibatis.com/dtd/sql-map-2.dtd">
<sqlMap namespace="User"> 
    <typeAlias alias="user" type="com.itmyhome.User" /> 
      <typeAlias alias="book" type="com.itmyhome.Book"/>    <!-- 一对多查询,一个User对应多个Book --> 
      <resultMap id="get_user_result" class="user"> 
          <result property="id" column="id"/>  
          <result property="name" column="name"/>  
          <result property="age" column="age"/>  
          <result property="books" column="id" select="User.getBookByUserId"/> </resultMap>  
      <!-- 查询主表 --> 
      <select id="getUser" parameterClass="java.lang.String" resultMap="get_user_result">  <![CDATA[   select * from user where id = #id#   ]]> </select>  
      <!-- 查询子表 --> 
      <select id="getBookByUserId" parameterClass="int" resultClass="book">  
          <![CDATA[  select *  from book   where uid = #uid#   ]]> </select> 
</sqlMap>
```

```xml
<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE sqlMapConfigPUBLIC "-//iBATIS.com//DTD SQL Map Config 2.0//EN""http://www.ibatis.com/dtd/sql-map-config-2.dtd"><sqlMapConfig> <settings   cacheModelsEnabled="true"   enhancementEnabled="true"  lazyLoadingEnabled="true"  errorTracingEnabled="true"  maxRequests="32"  maxSessions="10"  maxTransactions="5"  useStatementNamespaces="true" /> <transactionManager type="JDBC">  <dataSource type="SIMPLE">   <property name="JDBC.Driver" value="com.mysql.jdbc.Driver" />   <property name="JDBC.ConnectionURL" value="jdbc:mysql://localhost:3306/ibatis" />   <property name="JDBC.Username" value="root" />   <property name="JDBC.Password" value="root" />   <property name="Pool.MaximumActiveConnections" value="10" />   <property name="Pool.MaximumIdleConnections" value="5" />   <property name="Pool.MaximumCheckoutTime" value="120000" />   <property name="Pool.TimeToWait" value="500" />   <property name="Pool.PingQuery" value="select 1 from ACCOUNT" />   <property name="Pool.PingEnabled" value="false" />   <property name="Pool.PingConnectionsOlderThan" value="1" />   <property name="Pool.PingConnectionsNotUsedFor" value="1" />  </dataSource> </transactionManager> <sqlMap resource="com/itmyhome/User.xml" /></sqlMapConfig>
```





# [ibatis一对多查询结果集](https://www.doc88.com/p-3867933196975.html)

![1660904846123](C:\Users\sever\AppData\Roaming\Typora\typora-user-images\1660904846123.png)

![1660904880360](C:\Users\sever\AppData\Roaming\Typora\typora-user-images\1660904880360.png)

![1660904919314](C:\Users\sever\AppData\Roaming\Typora\typora-user-images\1660904919314.png)

![1660904963671](C:\Users\sever\AppData\Roaming\Typora\typora-user-images\1660904963671.png)



# [ibatis一对多映射查询的两种配置方式](https://blog.csdn.net/asty9000/article/details/83116516)

 方式一：

```xml
<sqlMap namespace="author">
	<typeAlias alias="author" type="Author" />
    <typeAlias alias="book" type="Book" />
 
    <resultMap class="author" id="authorResult">
		<result property="id" column="id"/>
		<result property="authorName" column="authorName"/>
		<result property="description" column="description"/>
		<result property="books" column="id" select="getBooksByAuthorId"/>
    </resultMap>
    
	<resultMap class="book" id="bookResult">
		<result property="id" column="id" />
		<result property="bookName" column="bookName"/>
		<result property="price" column="price" />
		<result property="shelve" column="shelve" />
		<result property="authorId" column="authorId" />
	</resultMap>
 
    <select id="getBooksByAuthorId" parameterClass="int" resultMap="bookResult">
    	SELECT id,bookName,price,shelve,authorId FROM book WHERE authorId=#id#
    </select>
   
    <select id="getAuthor" parameterClass="java.util.Map" resultMap="authorResult">
		SELECT id, authorName, description FROM author WHERE isDelete = 0
		<dynamic prepend="">
			<isNotNull property="authorName">
				AND authorName LIKE '%$authorName$%'
			</isNotNull>
		</dynamic>
		ORDER BY id LIMIT #start#, #end#
    </select>
</sqlMap>
```

方式二：

```xml
<sqlMap namespace="author">
	<typeAlias alias="author" type="Author" />
    <typeAlias alias="book" type="Book" />
 
    <resultMap class="author" id="authorResult">
		<result property="id" column="id"/>
		<result property="authorName" column="authorName"/>
		<result property="description" column="description"/>
		<result property="books" column="id" resultMap="bookResult"/>
    </resultMap>
    
	<resultMap class="book" id="bookResult">
		<result property="id" column="bookId" />
		<result property="bookName" column="bookName"/>
		<result property="price" column="price" />
		<result property="shelve" column="shelve" />
	</resultMap>
 
    <select id="getBooksByAuthorId" parameterClass="int" resultMap="bookResult">
    	SELECT id,bookName,price,shelve,authorId FROM book WHERE authorId=#id#
    </select>
   
    <select id="getAuthor" parameterClass="java.util.Map" resultMap="authorResult">
		SELECT a.id, a.authorName, a.description,b.id as bookId,b.bookName,b.price,b.shelve FROM author a join book b on a.id=b.authorId WHERE a.isDelete = 0
		<dynamic prepend="">
			<isNotNull property="authorName">
				AND a.authorName LIKE '%$authorName$%'
			</isNotNull>
		</dynamic>
		ORDER BY a.id LIMIT #start#, #end#
    </select>
</sqlMap>
```

方式一：结构清晰，但查询会有N+1的问题（主表查询一次，子表查询N次）。

方式二：是方式一的改进，一次查询出所有结果，性能更好，但结构复杂时不易维护。在子表信息查询次数较少时，通过使用ibatis的延迟加载机制方式一会比较高效。





# [DB2逗号分隔输出（按组）](https://www.imooc.com/wenda/detail/595884)

Db2中最接近mysql的``collect_set()`函数的是`LISTAGG()`

示例：如果存在带有的列，ID并且它具有3行相同的列，ID但具有三个不同的角色，则数据应以逗号连接。

ID   | Role

\------------

4555 | 2

4555 | 3

4555 | 4

每行输出应类似于以下内容：

4555 2,3,4






> LISTAGG函数是DB2 LUW 9.7中的新函数
>
> 参见示例：
>
> create table myTable (id int, category int);
>
> insert into myTable values (1, 1);
>
> insert into myTable values (2, 2);
>
> insert into myTable values (5, 1);
>
> insert into myTable values (3, 1);
>
> insert into myTable values (4, 2);
>
> 
>
> 示例：在分组列中不按任何顺序进行选择
>
> select category, LISTAGG(id, ', ') as ids from myTable group by category;
>
> 结果：
>
> CATEGORY  IDS
>
> --------- -----
>
> 1         1, 5, 3
>
> 2         2, 4
>
> 
>
> 示例：在分组列中使用order by子句进行选择
>
> select
>
>   category,
>
>   LISTAGG(id, ', ') WITHIN GROUP(ORDER BY id ASC) as ids
>
> from myTable
>
> group by category;
>
> 结果：
>
> CATEGORY  IDS
>
> --------- -----
>
> 1         1, 3, 5
>
> 2         2, 4



> 注意：在Db2中，`LISTAGG()`有两种形式
>
> LISTAGG(DISTINCT mycolumn) --duplicates removed，移除重复值
> LISTAGG(ALL mycolumn)      --duplicates kept，显示所有值



> 这等效于DB2中MySQL的GROUP_CONCAT。
>
> 
>
> SELECT 
>
> NUM, 
>
> SUBSTR(xmlserialize(xmlagg(xmltext(CONCAT( ', ',ROLES))) as VARCHAR(1024)), 3) as ROLES
>
> FROM mytable 
>
> GROUP BY NUM;
>
> 这将输出类似：
>
> NUM   ROLES
>
> ----  -------------
>
> 1     111, 333, 555
>
> 2     222, 444
>
> 
>
> 假设您的原始结果是这样的：
>
> NUM   ROLES
>
> ----  ---------
>
> 1     111
>
> 2     222
>
> 1     333
>
> 2     444
>
> 1     555

> 根据您拥有的DB2版本，可以使用XML函数来实现此目的。
>
> 
>
> 带有一些数据的示例表
>
> 
>
> create table myTable (id int, category int);
>
> insert into myTable values (1, 1);
>
> insert into myTable values (2, 2);
>
> insert into myTable values (3, 1);
>
> insert into myTable values (4, 2);
>
> insert into myTable values (5, 1);
>
> 使用xml函数汇总结果
>
> 
>
> select category, 
>
> ​    xmlserialize(XMLAGG(XMLELEMENT(NAME "x", id) ) as varchar(1000)) as ids 
>
> ​    from myTable
>
> ​    group by category;
>
> 结果：
>
> 
>
> CATEGORY IDS
>
>  -------- ------------------------
>
> ​        1 <x>1</x><x>3</x><x>5</x>
>
> ​        2 <x>2</x><x>4</x>
>
> 使用替换使结果看起来更好
>
> 
>
> select category, 
>
> ​        replace(
>
> ​        replace(
>
> ​        replace(
>
> ​            xmlserialize(XMLAGG(XMLELEMENT(NAME "x", id) ) as varchar(1000))
>
> ​            , '</x><x>', ',')
>
> ​            , '<x>', '')
>
> ​            , '</x>', '') as ids 
>
> ​    from myTable
>
> ​    group by category;
>
> 清理结果
>
> 
>
> CATEGORY IDS
>
>  -------- -----
>
> ​        1 1,3,5
>
> ​        2 2,4
>
> 刚看到使用XMLELEMENT的XMLTEXT而不是一个更好的解决方案在这里。



# [IBM官方文档](https://www.ibm.com/docs/zh/db2/9.7?topic=functions-listagg)

WITHIN GROUP

Indicates that the aggregation will follow the specified ordering within the grouping set.

If WITHIN GROUP is not specified and no other LISTAGG, ARRAY_AGG, or XMLAGG is included in the same SELECT clause with ordering specified, the ordering of strings within the result is not deterministic. If WITHIN GROUP is not specified, and the same SELECT clause has multiple occurrences of XMLAGG, ARRAY_AGG, or LISTAGG that specify ordering, the same ordering is used for the result of the LISTAGG function invocation.

- ORDER BY

  Specifies the order of the rows from the same grouping set that are processed in the aggregation. If the ORDER BY clause cannot distinguish the order of the column data, the rows in the same grouping set are arbitrarily ordered.

  - *sort-key*

  The sort key can be a column name or a *sort-key-expression*. If the sort key is a constant, it does not refer to the position of the output column (as in the ORDER BY clause of a query), but it is simply a constant, which implies no sort key.

  - ASC

  Processes the *sort-key* in ascending order. This is the default option.

  - DESC

  Processes the *sort-key* in descending order.

  

within group (order by sort-key asc)

## Example

Produce an alphabetical list of comma-separated names, grouped by department.

生成以逗号分隔的姓名的字母列表，按部门分组。

```sql
   SELECT workdept, 
         LISTAGG(lastname, ', ') WITHIN GROUP(ORDER BY lastname)
         AS employees 
      FROM emp 
      GROUP BY workdept
```