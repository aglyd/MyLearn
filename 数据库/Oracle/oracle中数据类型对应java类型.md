# [oracle中数据类型对应java类型](https://www.cnblogs.com/softidea/p/7101091.html)

地址：

http://otndnld.[Oracle](http://lib.csdn.net/base/oracle).co.jp/document/products/oracle10g/102/doc_cd/[Java](http://lib.csdn.net/base/java).102/B19275-03/datacc.htm#BHCJBJCC

 

| SQL数据类型                      | JDBC类型代码                           | 标准的Java类型         | Oracle扩展的Java类型          |
| -------------------------------- | -------------------------------------- | ---------------------- | ----------------------------- |
|                                  | 1.0标准的JDBC类型:                     |                        |                               |
| `CHAR`                           | `java.sql.Types.CHAR`                  | `java.lang.String`     | `oracle.sql.CHAR`             |
| `VARCHAR2`                       | `java.sql.Types.VARCHAR`               | `java.lang.String`     | `oracle.sql.CHAR`             |
| `LONG`                           | `java.sql.Types.LONGVARCHAR`           | `java.lang.String`     | `oracle.sql.CHAR`             |
| `NUMBER`                         | `java.sql.Types.NUMERIC`               | `java.math.BigDecimal` | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.DECIMAL`               | `java.math.BigDecimal` | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.BIT`                   | `boolean`              | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.TINYINT`               | `byte`                 | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.SMALLINT`              | `short`                | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.INTEGER`               | `int`                  | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.BIGINT`                | `long`                 | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.REAL`                  | `float`                | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.FLOAT`                 | `double`               | `oracle.sql.NUMBER`           |
| `NUMBER`                         | `java.sql.Types.DOUBLE`                | `double`               | `oracle.sql.NUMBER`           |
| `RAW`                            | `java.sql.Types.BINARY`                | `byte[]`               | `oracle.sql.RAW`              |
| `RAW`                            | `java.sql.Types.VARBINARY`             | `byte[]`               | `oracle.sql.RAW`              |
| `LONGRAW`                        | `java.sql.Types.LONGVARBINARY`         | `byte[]`               | `oracle.sql.RAW`              |
| `DATE`                           | `java.sql.Types.DATE`                  | `java.sql.Date`        | `oracle.sql.DATE`             |
| `DATE`                           | `java.sql.Types.TIME`                  | `java.sql.Time`        | `oracle.sql.DATE`             |
| `TIMESTAMP`                      | `java.sql.Types.TIMESTAMP`             | `javal.sql.Timestamp`  | `oracle.sql.TIMESTAMP`        |
|                                  | 2.0标准的JDBC类型:                     |                        |                               |
| `BLOB`                           | `java.sql.Types.BLOB`                  | `java.sql.Blob`        | `oracle.sql.BLOB`             |
| `CLOB`                           | `java.sql.Types.CLOB`                  | `java.sql.Clob`        | `oracle.sql.CLOB`             |
| 用户定义的对象                   | `java.sql.Types.STRUCT`                | `java.sql.Struct`      | `oracle.sql.STRUCT`           |
| 用户定义的参考                   | `java.sql.Types.REF`                   | `java.sql.Ref`         | `oracle.sql.REF`              |
| 用户定义的集合                   | `java.sql.Types.ARRAY`                 | `java.sql.Array`       | `oracle.sql.ARRAY`            |
|                                  | Oracle扩展:                            |                        |                               |
| `BFILE`                          | `oracle.jdbc.OracleTypes.BFILE`        | N/A                    | `oracle.sql.BFILE`            |
| `ROWID`                          | `oracle.jdbc.OracleTypes.ROWID`        | N/A                    | `oracle.sql.ROWID`            |
| `REF CURSOR`                     | `oracle.jdbc.OracleTypes.CURSOR`       | `java.sql.ResultSet`   | `oracle.jdbc.OracleResultSet` |
| `TIMESTAMP`                      | `oracle.jdbc.OracleTypes.TIMESTAMP`    | `java.sql.Timestamp`   | `oracle.sql.TIMESTAMP`        |
| `TIMESTAMP WITH TIME ZONE`       | `oracle.jdbc.OracleTypes.TIMESTAMPTZ`  | `java.sql.Timestamp`   | `oracle.sql.TIMESTAMPTZ`      |
| `TIMESTAMP WITH LOCAL TIME ZONE` | `oracle.jdbc.OracleTypes.TIMESTAMPLTZ` | `java.sql.Timestamp`   | `oracle.sql.TIMESTAMPLTZ`     |

 

 

http://blog.csdn.net/perny/article/details/7971003

 

[数据库](http://lib.csdn.net/base/mysql)中为number类型的字段，在[Java](http://lib.csdn.net/base/java)类型中对应的有Integer和BigDecimal都会出现； 
经[测试](http://lib.csdn.net/base/softwaretest)发现当数据库为sql server和DB2时，用getObject()取出来时Integer类型，但是[Oracle](http://lib.csdn.net/base/oracle) 中取出来就会是Integer或者BigDecimal类型。原因是[oracle](http://lib.csdn.net/base/oracle)与java类型对应于number长度有关。 
![这里写图片描述](http://img.blog.csdn.net/20170509135251042?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbHVkb25nc2h1bjIwMTY=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

遇到该类型问题，若要判断每个数据库和数据库字段长度不同对应的java数据类型不同太过烦琐，可采用getString()来取值，统一先转为string来判断

另外附上 
java.sql.Types，数据库字段类型，java数据类型的对应关系 
http://www.cnblogs.com/shishm/archive/2012/01/30/2332142.html