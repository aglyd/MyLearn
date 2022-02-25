# [MyBatis动态传入表名](https://www.cnblogs.com/cnsdhzzl/p/8888770.html)

mybatis里#{}与${}的用法：

　　在动态sql解析过程，#{}与${}的效果是不一样的：

```
  #{ } 解析为一个 JDBC 预编译语句（prepared statement）的参数标记符。
```

　　如以下sql语句

```
  select * from user where name = #{name};
```

　　会被解析为：

```
  select * from user where name = ?;
```

　　可以看到#{}被解析为一个参数占位符？。

 

```
  ${ } 仅仅为一个纯碎的 string 替换，在动态 SQL 解析阶段将会进行变量替换
```

　　如以下sql语句：

```
  select * from user where name = ${name};
```

　　当我们传递参数“sprite”时，sql会解析为：

```
  select * from user where name = "sprite";
```

　　可以看到预编译之前的sql语句已经不包含变量name了。

　　综上所得， ${ } 的变量的替换阶段是在动态 SQL 解析阶段，而 #{ }的变量的替换是在 DBMS 中。

\#{}与${}的区别可以简单总结如下：

- \#{}将传入的参数当成一个字符串，会给传入的参数加一个双引号
- ${}将传入的参数直接显示生成在sql中，不会添加引号
- \#{}能够很大程度上防止sql注入，${}无法防止sql注入

　　${}在预编译之前已经被变量替换了，这会存在sql注入的风险。如下sql

```
  select * from ${tableName} where name = ${name}
```

　　如果传入的参数tableName为user; delete user; --，那么sql动态解析之后，预编译之前的sql将变为：

```
  select * from user; delete user; -- where name = ?;
```

　　--之后的语句将作为注释不起作用，顿时我和我的小伙伴惊呆了！！！看到没，本来的查询语句，竟然偷偷的包含了一个删除表数据的sql，是删除，删除，删除！！！重要的事情说三遍，可想而知，这个风险是有多大。

- ${}一般用于传输数据库的表名、字段名等
- 能用#{}的地方尽量别用${}

　　进入正题，通过上面的分析，相信大家可能已经对如何动态调用表名和字段名有些思路了。示例如下：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
  <select id="getUser" resultType="java.util.Map" parameterType="java.lang.String" statementType="STATEMENT">
    select 
         ${columns}
    from ${tableName}
        where 　　　　　　　　COMPANY_REMARK = ${company}
  </select>
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

　　要实现动态调用表名和字段名，就不能使用预编译了，需添加statementType="STATEMENT"" 。

```
  statementType：STATEMENT（非预编译），PREPARED（预编译）或CALLABLE中的任意一个，这就告诉 MyBatis 分别使用Statement，PreparedStatement或者CallableStatement。默认：PREPARED。这里显然不能使用预编译，要改成非预编译。
```

　　其次，sql里的变量取值是${xxx},不是#{xxx}。

　　因为${}是将传入的参数直接显示生成sql，如${xxx}传入的参数为字符串数据，需在参数传入前加上引号，如：

```
   String name = "sprite";
   name = "'" + name + "'";
```