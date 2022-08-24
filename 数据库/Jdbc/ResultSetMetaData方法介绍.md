# [ResultSetMetaData的用法介绍](https://blog.csdn.net/ftd1314/article/details/80614436)

## ResultSetMetaData 方法介绍

**用来获取：结果集的元数据信息**

利用ResultSet的getMetaData的方法可以获得ResultSetMeta对象，而ResultSetMetaData**==存储了 ResultSet的MetaData。==**所谓的MetaData在英文中的解释为“Data about Data”，直译成中文则为“有关数据的数据”或者“描述数据的数据”，实际上就是描述及解释含义的数据。以Result的MetaData为例，ResultSet是以表格的形式存在，所以**==getMetaData就包括了数据的字段名称、类型以及数目等表格所必须具备的信息。（但只是部分字段信息，如果要获取全面的字段信息可用DatabaseMetaData）==**


在 ResultSetMetaData类中主要有一下几个方法。

ResultSetMetaData rsmd=rs.getMetaData();

```java
String sql = "select * from " + schemaName + "." + tableName + "";
stmt = (Statement) conn.createStatement();
stmt.execute(sql);
ResultSet rs = (ResultSet) stmt.getResultSet();
ResultSetMetaData rsmd = rs.getMetaData();// 获取tableName的字段信息
int columnCount = rsmd.getColumnCount();// 获取行的数量
 for (int i = 0; i <= columnCount; i++) {
 String columnName = rsmd.getColumnName(i + 1);//获取字段名
 rsmd.getColumnTypeName(i + 1);	//获取字段类型名
 }
```

1．getColumCount()方法

方法的原型：public int getColumCount() throws SQLException。

方法说明：返回所有字段的数目

返回值：所有字段的数目（整数）。

异常产生：数据库发生任何的错误，则会产生一个SQLException对象。

2．getColumName()方法

方法的原型：public String getColumName (int colum) throws SQLException。

方法说明：根据字段的索引值取得字段的名称。

参数：colum，字段的索引值，从1开始。

返回值：字段的名称（字符串）。

异常产生：数据库发生任何的错误，则会产生一个SQLException对象。

3．getColumType()方法

方法的原型：public String getColumType (int colum) throws SQLException。

方法说明：根据字段的索引值取得字段的类型，返回值的定义在java.sql.Type类。

参数：colum，字段的索引值，从1开始。

返回值：字符串，SQL的数据类型定义在java.sql.Type类。

异常产生：数据库发生任何的错误，则会产生一个SQLException对象。

方法摘要 

| String getCatalogName(int column)           获取指定列的表目录名称。 |
| ------------------------------------------------------------ |
| String getColumnClassName(int column)           如果调用方法 ResultSet.getObject 从列中检索值，则返回构造其实例的 Java 类的完全限定名称。 |
| int getColumnCount()           返回此 ResultSet 对象中的列数。 |
| int getColumnDisplaySize(int column)           指示指定列的最大标准宽度，以字符为单位。 |
| String getColumnLabel(int column)           获取用于打印输出和显示的指定列的建议标题。 |
| String getColumnName(int column)           获取指定列的名称。 |
| int getColumnType(int column)           检索指定列的 SQL 类型。 |
| String getColumnTypeName(int column)           检索指定列的数据库特定的类型名称。 |
| int getPrecision(int column)           获取指定列的小数位数。 |
| int getScale(int column)           获取指定列的小数点右边的位数。 |
| String getSchemaName(int column)           获取指定列的表模式。 |
| String getTableName(int column)           获取指定列的名称。 |
| boolean isAutoIncrement(int column)           指示是否自动为指定列进行编号，这样这些列仍然是只读的。 |
| boolean isCaseSensitive(int column)           指示列的大小写是否有关系。 |
| boolean isCurrency(int column)           指示指定的列是否是一个哈希[代码](http://www.xuebuyuan.com/)值。 |
| boolean isDefinitelyWritable(int column)           指示在指定的列上进行写操作是否明确可以获得成功。 |
| int isNullable(int column)           指示指定列中的值是否可以为 null。 |
| boolean isReadOnly(int column)           指示指定的列是否明确不可写入。 |
| boolean isSearchable(int column)           指示是否可以在 where 子句中使用指定的列。 |
| boolean isSigned(int column)           指示指定列中的值是否带正负号。 |
| boolean isWritable(int column)           指示在指定的列上进行写操作是否可以获得成功。 |

## DatabaseMetaData中的方法介绍

使用DatabaseMetaData则是用来获得**==数据库的元数据信息==**，下面介绍这个类的使用方法。

DatabaseMetaData对象提供的是关于数据库的各种信息，这些信息包括： 
**==1、    数据库与用户，数据库标识符以及函数与存储过程。==**
==**2、    数据库限制。**== 
==**3、    数据库支持不支持的功能。**== 
==**4、    架构、编目、表、列和视图等。（可以获取某张表的所有字段信息，包括注释等，而ResultSetMetaData只能获取部分字段信息没有注释信息）**==

通过调用DatabaseMetaData的各种方法，[程序](http://www.xuebuyuan.com/)可以动态的了解一个数据库。由于这个类中的方法非常的多那么就介绍几个常用的方法来给大家参考。 

DatabaseMetaData实例的获取方法是，通过连接来获得的 

```java
  Properties propsDB =new Properties();
  propsDB.put("remarksReporting","true");	//开启支持查询备注注释信息，但好像默认就是开启的
  propsDB.put("user",user);
  propsDB.put("password",pwd);
  //  conn = (Connection) DriverManager.getConnection(url, propsDB);
  conn = (Connection) DriverManager.getConnection(url, user, pwd);
  DatabaseMetaData databaseMetaData = conn.getMetaData();
  //获取BWQX.tableName表列头部信息（注释，列类型等），从左自右依次是catalog,schema,table,column
  ResultSet tbrs = databaseMetaData.getColumns(null, "BWQX",tableName,null);	
// or： tbrs = databaseMetaData.getColumns("", "BWQX",tableName,"%");
//ResultSet  rs   =   dbmd.getColumns(con.getCatalog(),"%",tableName,null); 
  ResultSetMetaData tableMetaData = tbrs.getMetaData();
```

创建了这个实例，就可以使用他的方法来获取数据库得信息。首先是数据库中用户标识符的信息的获得，主要使用如下的方法： 
**getDatabaseProductName()**用以获得当前数据库是什么数据库。比如oracle，access等。返回的是字符串。 
**getDatabaseProductVersion()**获得数据库的版本。返回的字符串。 
**getDriverVersion()**获得驱动程序的版本。返回字符串。 
**supportsResultSetType(ResultSet.resultype)**是判定是否支持这种结果集的类型。比如参数如果是Result.TYPE_FORWARD_ONLY,那就是判定是否支持，只能先前移动结果集的指针。返回值为boolean，true表示支持。

上面介绍的只是几个常用的方法，这个类中还有很多方法，可以到jdk的帮助文档中去查看类java.sql.DatabaseMetaData。

这个类中还有一个比较常用的方法就是获得表的信息。使用的方法是： 
**getTables（String catalog,String schema,String tableName,String[] types），** 
这个方法带有四个参数，他们表示的含义如下： 
**String catalog——要获得表所在的编目。串“”””意味着没有任何编目，Null表示所有编目。
String schema——要获得表所在的模式。串“”””意味着没有任何模式，Null表示所有模式。该参数可以包含单字符的通配符（“_ ”）,也可以包含多字符的通配符（“%”）。 
String tableName——指出要返回表名与该参数匹配的那些表，该参数可以包含单字符的通配符（“_”）,也可以包含多字符的通配符（“%”）。 
String types——一个指出返回何种表的数组。可能的数组项是：”TABLE”，”VIEW”，”SYSTEM TABLE”，”GLOBAL TEMPORARY”，”LOCAL TEMPORARY”，”ALIAS”，“SYSNONYM”。**

通过getTables（）方法返回一个表的信息的结果集。 
这个结果集包括字段有：TABLE_CAT表所在的编目。TABLE_SCHEM表所在的模式，TABLE_NAME表的名称。TABLE_TYPE标的类型。REMARKS一段解释性的备注。通过这些字段可以完成表的信息的获取。

还有两个方法一个是获得列： 
getColumns(String catalog,String schama,String tablename,String columnPattern)一个是获得关键字的方法 
getPrimaryKeys(String catalog, String schema, String table)这两个方法中的参数的含义和上面的介绍的是相同的。 
凡是pattern的都是可以用通配符匹配的。getColums()返回的是结果集，这个结果集包括了列的所有信息，类型，名称，可否为空等。getPrimaryKey（）则是返回了某个表的关键字的结果集。 
通过getTables（），getColumns（），getPrimaryKeys（）就可以完成表的反向设计了。主要步骤如下： 
1、 通过getTables()获得数据库中表的信息。 
2、 对于每个表使用，getColumns(),getPrimaryKeys()获得相应的列名，类型，限制条件，关键字等。 
3、 通过1，2获得信息可以生成相应的建表的SQL语句。





# [Java DatabaseMetaData getColumns()方法与示例](https://www.nhooo.com/note/qa0rlt.html)

此方法检索表的列的描述。它接受4个参数-

- **catalog-目录**-一个字符串参数，表示表（包含通常需要检索其描述的列的表）的目录（通常是数据库）的名称（或名称模式）。传递“”以获取没有目录的表中列的描述，如果不想使用目录，则传递null，从而缩小搜索范围。
- **schemaPattern-**一个String参数，表示表的架构的名称（或名称模式），如果表中的列没有架构，则传递“”，如果您不想使用架构，则传递null。
- **tableNamePattern-**一个String参数，代表表的名称（或名称模式）。
- **columnNamePattern-**一个String参数，表示列的名称（或名称模式）。

此方法返回描述指定列的ResultSet对象。该对象保存以下详细信息的值（作为列名）-

| 栏名               | 数据类型 | 描述                                                         |
| :----------------- | :------- | :----------------------------------------------------------- |
| TABLE_CAT          | 串       | 表的目录。                                                   |
| TABLE_SCHEM        | 串       | 模式的目录。                                                 |
| TABLE_NAME         | 串       | 表名。                                                       |
| COLUMN_NAME        | 串       | 列名。                                                       |
| DATA_TYPE          | 整数     | 列的数据类型为整数。                                         |
| TYPE_NAME          | 串       | 列的数据类型名称。                                           |
| COLUMN_SIZE        | 整型     | 列的大小。                                                   |
| remark             | 串       | 在该列上的注释。                                             |
| COLUMN_DEF         | 串       | 列的默认值。                                                 |
| ORDINAL_POSITION   | 整型     | 表中列的索引。                                               |
| IS_AUTOINCREMENT   | 串       | 如果列是自动递增的，则返回yes；如果列不是自动递增的，则返回false；如果无法确定，则返回一个空的String（“”）。 |
| IS_GENERATEDCOLUMN | 串       | 如果该列是生成的列，则返回yes；如果该列不是生成的列，则返回false；如果无法确定，则返回一个空的String（“”）。 |



获取数据库中所需列的描述-

- 确保您的数据库已启动并正在运行。
- 使用`registerDriver()`DriverManager类的方法注册驱动程序。传递与基础数据库相对应的驱动程序类的对象。
- 使用`getConnection()`DriverManager类的方法获取连接对象。将URL和数据库中的用户密码作为字符串变量传递给数据库。
- 使用`getMetaData()`Connection接口的方法获取有关当前连接的DatabaseMetaData对象。
- 最后，通过调用`getColumns()`DatabaseMetaData接口的方法，获取包含所需列的描述的ResultSet对象。

## 示例

让我们创建一个名称为example_database的数据库，并使用CREATE语句在其中创建一个名称为sample_table的表，如下所示-

```java
Statement stmt = con.createStatement();
stmt.execute("CREATE DATABASE example_database");
stmt.execute("CREATE TABLE example_database.sample_table(Name VARCHAR(255), age INT, Location VARCHAR(255));");
```

现在，在此表中，我们将插入两个记录-

```java
stmt.execute("INSERT INTO example_database.sample_table values('Kasyap', 29, 'Vishakhapatnam')");
stmt.execute("INSERT INTO example_database.sample_table values('Krishna', 30, 'Hyderabad')");
```

下面的JDBC程序建立与MySQL数据库的连接，检索指定列的描述。

```java
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
public class DatabaseMetaData_getColumns {
   public static void main(String args[]) throws SQLException {
      //注册驱动程序
      DriverManager.registerDriver(new com.mysql.jdbc.Driver());
      //获得连接
      String url = "jdbc:mysql://localhost/example_database";
      Connection con = DriverManager.getConnection(url, "root", "password");
      System.out.println("Connection established......");
      //检索元数据对象
      DatabaseMetaData metaData = con.getMetaData();
      //检索数据库中的列
      ResultSet columns = metaData.getColumns(null, null, "sample_table", null);
      //打印列名称和大小
      while (columns.next()){
         System.out.print("Column name and size: "+columns.getString("COLUMN_NAME"));
         System.out.print("("+columns.getInt("COLUMN_SIZE")+")");
         System.out.println(" ");
         System.out.println("Ordinal position: "+columns.getInt("ORDINAL_POSITION"));
         System.out.println("Catalog: "+columns.getString("TABLE_CAT"));
         System.out.println("Data type (integer value): "+columns.getInt("DATA_TYPE"));
         System.out.println("Data type name: "+columns.getString("TYPE_NAME"));
         System.out.println(" ");
      }
   }
}
```

输出结果

```
Connection established......
Column name and size: Name(255)
Ordinal position: 1
Catalog: example_database
Data type (integer value): 12
Data type name: VARCHAR
Column name and size: age(10)
Ordinal position: 2
Catalog: example_database
Data type (integer value): 4
Data type name: INT
Column name and size: Location(255)
Ordinal position: 3
Catalog: example_database
Data type (integer value): 12
Data type name: VARCHAR
```





# [getColumns](http://www.cjsdn.net/doc/jdk50/java/sql/DatabaseMetaData.html)

有些 `DatabaseMetaData` 方法以 `ResultSet` 对象的形式返回信息列表。常规 `ResultSet` 方法，比如 `getString` 和 `getInt`，可用于从这些 `ResultSet` 对象中检索数据。如果给定形式的元数据不可用，则 `ResultSet` 获取方法抛出 `SQLException`。

有些 `DatabaseMetaData` 方法使用 String 模式的参数。这些参数都有 fooPattern 这样的名称。在模式 String 中，"%" 表示匹配 0 个或多个字符的任何子字符串，"_" 表示匹配任何一个字符。仅返回匹配搜索模式的元数据项。如果将搜索模式参数设置为 `null`，则从搜索中删除参数标准。

```sql
getColumns
ResultSet getColumns(String catalog,
                     String schemaPattern,
                     String tableNamePattern,
                     String columnNamePattern)
                     throws SQLException
检索可在指定类别中使用的表列的描述。
仅返回与类别、模式、表和列名称标准匹配的列描述。它们根据 TABLE_SCHEM、TABLE_NAME 和 ORDINAL_POSITION 进行排序。

每个列描述都有以下列：

TABLE_CAT String => 表类别（可为 null）
TABLE_SCHEM String => 表模式（可为 null）
TABLE_NAME String => 表名称
COLUMN_NAME String => 列名称
DATA_TYPE int => 来自 java.sql.Types 的 SQL 类型
TYPE_NAME String => 数据源依赖的类型名称，对于 UDT，该类型名称是完全限定的
COLUMN_SIZE int => 列的大小。对于 char 或 date 类型，列的大小是最大字符数，对于 numeric 和 decimal 类型，列的大小就是精度。
BUFFER_LENGTH 未被使用。
DECIMAL_DIGITS int => 小数部分的位数
NUM_PREC_RADIX int => 基数（通常为 10 或 2）
NULLABLE int => 是否允许使用 NULL。
columnNoNulls - 可能不允许使用 NULL 值
columnNullable - 明确允许使用 NULL 值
columnNullableUnknown - 不知道是否可使用 null
REMARKS String => 描述列的注释（可为 null）
COLUMN_DEF String => 默认值（可为 null）
SQL_DATA_TYPE int => 未使用
SQL_DATETIME_SUB int => 未使用
CHAR_OCTET_LENGTH int => 对于 char 类型，该长度是列中的最大字节数
ORDINAL_POSITION int => 表中的列的索引（从 1 开始）
IS_NULLABLE String => "NO" 表示明确不允许列使用 NULL 值，"YES" 表示可能允许列使用 NULL 值。空字符串表示没人知道是否允许使用 null 值。
SCOPE_CATLOG String => 表的类别，它是引用属性的作用域（如果 DATA_TYPE 不是 REF，则为 null）
SCOPE_SCHEMA String => 表的模式，它是引用属性的作用域（如果 DATA_TYPE 不是 REF，则为 null）
SCOPE_TABLE String => 表名称，它是引用属性的作用域（如果 DATA_TYPE 不是 REF，则为 null）
SOURCE_DATA_TYPE short => 不同类型或用户生成 Ref 类型、来自 java.sql.Types 的 SQL 类型的源类型（如果 DATA_TYPE 不是 DISTINCT 或用户生成的 REF，则为 null）
参数：
catalog - 类别名称，因为存储在数据库中，所以它必须匹配类别名称。该参数为 "" 则检索没有类别的描述，为 null 则表示该类别名称不应用于缩小搜索范围
schemaPattern - 模式名称的模式，因为存储在数据库中，所以它必须匹配模式名称。该参数为 "" 则检索那些没有模式的描述，为 null 则表示该模式名称不应用于缩小搜索范围
tableNamePattern - 表名称模式，因为存储在数据库中，所以它必须匹配表名称
columnNamePattern - 列名称模式，因为存储在数据库中，所以它必须匹配列名称
返回：
ResultSet - 每一行都是一个列描述
抛出：
SQLException - 如果发生数据库访问错误
另请参见：
getSearchStringEscape()
```





# [SQLServerDatabaseMetaData](https://docs.microsoft.com/zh-cn/sql/connect/jdbc/reference/getcolumns-method-sqlserverdatabasemetadata?view=sql-server-ver16)

```java
import java.sql.*;  
public class c1 {  
   public static void main(String[] args) {  
      String connectionUrl = "jdbc:sqlserver://localhost:1433;databaseName=AdventureWorks;integratedsecurity=true";  
  
      Connection con = null;  
      Statement stmt = null;  
      ResultSet rs = null;  
  
      try {  
         Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");  
         con = DriverManager.getConnection(connectionUrl);  
         DatabaseMetaData dbmd = con.getMetaData();  
         rs = dbmd.getColumns("AdventureWorks", "Person", "Contact", "FirstName");  
  
         ResultSet r = dbmd.getColumns(null, null, "Contact", null);  
         ResultSetMetaData rm = r.getMetaData();   
         int noofcols = rm.getColumnCount();  
  
         if (r.next())  
            for (int i = 0 ; i < noofcols ; i++ )  
            System.out.println(rm.getColumnName( i + 1 ) + ": \t\t" + r.getString( i + 1 ));  
      }  
  
      catch (Exception e) {}  
      finally {}  
   }  
}
```

