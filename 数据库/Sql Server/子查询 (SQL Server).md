# [子查询 (SQL Server)](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15)

**适用于：** ![是](https://docs.microsoft.com/zh-cn/sql/includes/media/yes-icon.png?view=sql-server-ver15)SQL Server（所有支持的版本） ![是](https://docs.microsoft.com/zh-cn/sql/includes/media/yes-icon.png?view=sql-server-ver15)Azure SQL 数据库 ![是](https://docs.microsoft.com/zh-cn/sql/includes/media/yes-icon.png?view=sql-server-ver15)Azure SQL 托管实例 ![是](https://docs.microsoft.com/zh-cn/sql/includes/media/yes-icon.png?view=sql-server-ver15)Azure Synapse Analytics 是![img](https://docs.microsoft.com/zh-cn/sql/includes/media/yes-icon.png?view=sql-server-ver15)并行数据仓库

子查询是一个嵌套在 `SELECT`、`INSERT`、`UPDATE` 或 `DELETE` 语句或其他子查询中的查询。

 备注

本文中的示例使用可在 [AdventureWorks 示例数据库](https://docs.microsoft.com/zh-cn/sql/samples/adventureworks-install-configure?view=sql-server-ver15)中下载的 AdventureWorks2016 数据库。

任何允许使用表达式的地方都可以使用子查询。 在此示例中，子查询用作 `SELECT` 语句中名为 MaxUnitPrice 的列表达式。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT Ord.SalesOrderID, Ord.OrderDate,
    (SELECT MAX(OrdDet.UnitPrice)
     FROM Sales.SalesOrderDetail AS OrdDet
     WHERE Ord.SalesOrderID = OrdDet.SalesOrderID) AS MaxUnitPrice
FROM Sales.SalesOrderHeader AS Ord;
GO
```

## 子查询基础知识

子查询也称为内部查询或内部选择，而包含子查询的语句也称为外部查询或外部选择。

许多包含子查询的 Transact-SQL 语句都可以改用联接表示。 其他问题只能通过子查询提出。 在 Transact-SQL 中，包含子查询的语句和语义上等效的不包含子查询的语句在性能上通常没有差别。 有关 SQL Server 如何处理查询的体系结构信息，请参阅 [SQL 语句处理](https://docs.microsoft.com/zh-cn/sql/relational-databases/query-processing-architecture-guide?view=sql-server-ver15#sql-statement-processing)。但是，在必须检查存在性的某些情况下，联接会产生更好的效果。 否则，为确保消除重复值，必须为外部查询的每个结果都处理嵌套查询。 所以在这些情况下，联接方式会产生更好的效果。

以下示例显示了返回相同结果集和执行计划的 `SELECT` 子查询和 `SELECT` 联接：

SQL复制

```sql
USE AdventureWorks2016;
GO

/* SELECT statement built using a subquery. */
SELECT [Name]
FROM Production.Product
WHERE ListPrice =
    (SELECT ListPrice
     FROM Production.Product
     WHERE [Name] = 'Chainring Bolts' );
GO

/* SELECT statement built using a join that returns
   the same result set. */
SELECT Prd1.[Name]
FROM Production.Product AS Prd1
     JOIN Production.Product AS Prd2
       ON (Prd1.ListPrice = Prd2.ListPrice)
WHERE Prd2.[Name] = 'Chainring Bolts';
GO
```

嵌套在外部 SELECT 语句中的子查询包括以下组件：

- 包含常规选择列表组件的常规 `SELECT` 查询。
- 包含一个或多个表或视图名称的常规 `FROM` 子句。
- 可选的 `WHERE` 子句。
- 可选的 `GROUP BY` 子句。
- 可选的 `HAVING` 子句。

子查询的 SELECT 查询总是使用圆括号括起来。 它不能包含 `COMPUTE` 或 `FOR BROWSE` 子句，如果同时指定了 TOP 子句，则只能包含 `ORDER BY` 子句。

子查询可以嵌套在外部 `SELECT``INSERT``UPDATE` 或 `DELETE` 语句的 `WHERE` 或 `HAVING` 子句内，也可以嵌套在其他子查询内。 尽管根据可用内存和查询中其他表达式的复杂程度的不同，嵌套限制也有所不同，但嵌套到 32 层是可能的。 个别查询可能不支持 32 层嵌套。 任何可以使用表达式的地方都可以使用子查询，只要它返回的是单个值。

如果某个表只出现在子查询中，而没有出现在外部查询中，那么该表中的列就无法包含在输出（外部查询的选择列表）中。

包含子查询的语句通常采用以下格式中的一种：

- `WHERE expression \[NOT] IN (subquery)`
- `WHERE expression comparison_operator \[ANY | ALL] (subquery)`
- `WHERE \[NOT] EXISTS (subquery)`

在某些 Transact-SQL 语句中，子查询可以作为独立查询来计算。 从概念上说，子查询结果会代入外部查询（尽管这不一定是 SQL Server 实际处理带有子查询的 Transact-SQL 语句的方式）。

有三种基本的子查询。 它们是：

- 在通过 `IN` 或由 `ANY` 或 `ALL` 修改的比较运算符引入的列表上操作。
- 通过未修改的比较运算符引入且必须返回单个值。
- 通过 `EXISTS` 引入的存在测试。

## 子查询规则

子查询受下列限制的制约：

- 通过比较运算符引入的子查询选择列表只能包括一个表达式或列名称（对 `EXISTS` 执行的 `IN` 或对列表执行的 `SELECT *` 子查询除外）。
- 如果外部查询的 `WHERE` 子句包括列名称，它必须与子查询选择列表中的列是联接兼容的。
- **ntext**、**text** 和 **image** 数据类型不能用在子查询的选择列表中。
- 由于必须返回单个值，所以由未修改的比较运算符（即后面未跟关键字 `ANY` 或 `ALL` 的运算符）引入的子查询不能包含 `GROUP BY` 和 `HAVING` 子句。
- 包含 GROUP BY 的子查询不能使用 `DISTINCT` 关键字。
- `COMPUTE` 和 `INTO` 子句不能指定。
- 只有指定了 `TOP` 时才能指定 `ORDER BY`。
- 不能更新使用子查询创建的视图。
- 按照惯例，由 `EXISTS` 引入的子查询的选择列表有一个星号 (*)，而不是单个列名。 因为由 `EXISTS` 引入的子查询创建了存在测试并返回 TRUE 或 FALSE 而非数据，所以由 `EXISTS` 引入的子查询的规则与标准选择列表的规则相同。

## 在子查询中限定列名

在下列示例中，外部查询的 `WHERE` 子句中的 BusinessEntityID 列是由外部查询的 `FROM` 子句中的表名 (Sales.Store) 隐性限定的。 对子查询的选择列表中 CustomerID 的引用则是由子查询的 `FROM` 子句（即通过 Sales.Customer 表）来限定的。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Sales.Store
WHERE BusinessEntityID NOT IN
    (SELECT CustomerID
     FROM Sales.Customer
     WHERE TerritoryID = 5);
GO
```

一般的规则是，语句中的列名通过同级 `FROM` 子句中引用的表来隐性限定。 如果子查询的 `FROM` 子句中引用的表中不存在列，则它是由外部查询的 `FROM` 子句中引用的表隐性限定的。

下例是使用这些隐性假设限定后查询的样式：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Sales.Store
WHERE Sales.Store.BusinessEntityID NOT IN
    (SELECT Sales.Customer.CustomerID
     FROM Sales.Customer
     WHERE TerritoryID = 5);
GO
```

显式表述一个表名绝对不会出错，而且用显式限定替代有关表名的隐性假定总是可能的。

 重要

如果某个子查询中引用的列不存在于该子查询的 `FROM` 子句引用的表中，而存在于外部查询的 `FROM` 子句引用的表中，则该查询可以正确执行。 SQL Server 会用外部查询中的表名隐式限定该子查询中的列。

## 多层嵌套

子查询自身可以包括一个或多个子查询。 一个语句中可以嵌套任意数量的子查询。

以下查询将查找作为销售人员的雇员的姓名。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT LastName, FirstName
FROM Person.Person
WHERE BusinessEntityID IN
    (SELECT BusinessEntityID
     FROM HumanResources.Employee
     WHERE BusinessEntityID IN
        (SELECT BusinessEntityID
         FROM Sales.SalesPerson)
    );
GO
```

下面是结果集：

复制

```
LastName                                           FirstName
-------------------------------------------------- -----------------------
Jiang                                              Stephen
Abbas                                              Syed
Alberts                                            Amy
Ansman-Wolfe                                       Pamela
Campbell                                           David
Carson                                             Jillian
Ito                                                Shu
Mitchell                                           Linda
Reiter                                             Tsvi
Saraiva                                            Jos
Vargas                                             Garrett
Varkey Chudukatil                                  Ranjit
Valdez                                             Rachel
Tsoflias                                           Lynn
Pak                                                Jae
Blythe                                             Michael
Mensa-Annan                                        Tete

(17 row(s) affected)
```

最里层查询将返回销售人员的 ID。 再上一层查询将用这些销售人员 ID 进行取值，并返回雇员的联系 ID 号。 最后，外部查询将使用这些联系 ID 查找雇员的姓名。

也可以将该查询表示为一个联接：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT LastName, FirstName
FROM Person.Person c
INNER JOIN HumanResources.Employee e
ON c.BusinessEntityID = e.BusinessEntityID
JOIN Sales.SalesPerson s 
ON e.BusinessEntityID = s.BusinessEntityID;
GO
```

## 相关子查询

许多查询都可以通过执行一次子查询并将得到的值代入外部查询的 `WHERE` 子句中进行计算。 在包括相关子查询（也称为重复子查询）的查询中，子查询依靠外部查询获得值。 这意味着子查询是重复执行的，为外部查询可能选择的每一行均执行一次。 此查询在 SalesPerson 表中检索奖金为 5000 且雇员标识号与 Employee 和 SalesPerson 表中的标识号相匹配的雇员的名和姓的一个实例。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT DISTINCT c.LastName, c.FirstName, e.BusinessEntityID 
FROM Person.Person AS c JOIN HumanResources.Employee AS e
ON e.BusinessEntityID = c.BusinessEntityID 
WHERE 5000.00 IN
    (SELECT Bonus
    FROM Sales.SalesPerson sp
    WHERE e.BusinessEntityID = sp.BusinessEntityID) ;
GO
```

下面是结果集：

复制

```
LastName FirstName BusinessEntityID
-------------------------- ---------- ------------
Ansman-Wolfe Pamela 280
Saraiva José 282

(2 row(s) affected)
```

该语句中前面的子查询无法独立于外部查询进行计算。 它需要 Employee.BusinessEntityID 值，但是此值随 SQL Server 检查 Employee 中的不同行而改变。
下面准确说明了如何计算此查询：SQL Server 通过将每一行的值代入内部查询，考虑 Employee 表中的每一行是否都包括在结果中。 例如，如果 SQL Server 首先检查 `Syed Abbas` 行，那么变量 Employee.BusinessEntityID 将取值 285，SQL Server 将该值代入内部查询。 这两个查询示例使用相关子查询表示上一个示例的分解。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT Bonus
FROM Sales.SalesPerson
WHERE BusinessEntityID = 285;
GO
```

结果为 0.00（`Syed Abbas` 没有收到奖金，因为他不是销售人员），因此外部查询计算为：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT LastName, FirstName
FROM Person.Person AS c JOIN HumanResources.Employee AS e
ON e.BusinessEntityID = c.BusinessEntityID 
WHERE 5000 IN (0.00);
GO
```

因为这是 false，`Syed Abbas` 的行不包含在具有相关子查询的先前示例查询的结果中。 对 `Pamela Ansman-Wolfe` 行运行相同的过程。 你将看到此行包含在结果中，因为 `WHERE 5000 IN (5000)` 包含结果。

通过在外部查询中引用表中的列作为表值函数的参数，相关子查询也可以在 `FROM` 子句中包含表值函数。 在这种情况下，对于外部查询的每一行，将根据子查询计算表值函数。

## 子查询类型

可以在许多位置指定子查询：

- 使用别名。 有关详细信息，请参阅[使用别名的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#aliases)。
- 使用 `IN` 或 `NOT IN`。 有关详细信息，请参阅[使用 IN 的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#in)和[使用 NOT IN 的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#notin)。
- 在 `UPDATE``DELETE` 和 `INSERT` 语句中。 有关详细信息，请参阅 [UPDATE、DELETE 和 INSERT 语句中的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#upsert)。
- 使用比较运算符。 有关详细信息，请参阅[使用比较运算符的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#comparison)。
- 使用 `ANY`、`SOME` 或 `ALL`。 有关详细信息，请参阅[用 ANY、SOME 或 ALL 修改的比较运算符](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#comparison_modified)。
- 使用 `EXISTS` 或 `NOT EXISTS`。 有关详细信息，请参阅[使用 EXISTS 的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#exists)和[使用 NOT EXISTS 的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#notexists)。
- 代替表达式。 有关详细信息，请参阅[用于替代表达式的子查询](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/subqueries?view=sql-server-ver15#expression)。

### 带有表别名的子查询

许多其中的子查询和外部查询引用同一表的语句可称为自联接（将某个表与自身联接）。 例如，您可以使用子查询查找特定州的员工的地址。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT StateProvinceID, AddressID
FROM Person.Address
WHERE AddressID IN
    (SELECT AddressID
     FROM Person.Address
     WHERE StateProvinceID = 39);
GO
```

下面是结果集：

复制

```
StateProvinceID AddressID
----------- -----------
39 942
39 955
39 972
39 22660

(4 row(s) affected)
```

也可以使用自联接：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT e1.StateProvinceID, e1.AddressID
FROM Person.Address AS e1
INNER JOIN Person.Address AS e2
ON e1.AddressID = e2.AddressID
AND e2.StateProvinceID = 39;
GO
```

由于自联接的表会以两种不同的角色出现，因此必须有表别名 e1 和 e2。 别名也可用于在内部查询和外部查询中引用同一表的嵌套查询。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT e1.StateProvinceID, e1.AddressID
FROM Person.Address AS e1
WHERE e1.AddressID IN
    (SELECT e2.AddressID
     FROM Person.Address AS e2
     WHERE e2.StateProvinceID = 39);
GO
```

显式表别名清楚地表明，在子查询中对 Person.Address 的引用并不等同于在外部查询中的该引用。

### 使用 `IN` 的子查询

通过 `IN`（或 `NOT IN`）引入的子查询结果是包含零个值或多个值的列表。 子查询返回结果之后，外部查询将利用这些结果。
下面的查询查找 Adventure Works Cycles 生成的所有车轮产品的名称。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE [Name] = 'Wheels');
GO
```

下面是结果集：

复制

```
Name
----------------------------
LL Mountain Front Wheel
ML Mountain Front Wheel
HL Mountain Front Wheel
LL Road Front Wheel
ML Road Front Wheel
HL Road Front Wheel
Touring Front Wheel
LL Mountain Rear Wheel
ML Mountain Rear Wheel
HL Mountain Rear Wheel
LL Road Rear Wheel
ML Road Rear Wheel
HL Road Rear Wheel
Touring Rear Wheel

(14 row(s) affected)
```

该语句分两步进行评估。 首先，内部查询返回与名称 'Wheel' (17) 匹配的子类别标识号。 然后，这些值将替换到外部查询中，此外部查询将在 Production.Product 中查找与子类别标识号匹配的产品名称。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ProductSubcategoryID IN ('17');
GO
```

使用联接而不使用子查询处理该问题及类似问题的一个不同之处在于，联接使您可以在结果中显示多个表中的列。 例如，如果要在结果中包括产品子类别的名称，则必须使用联接版本。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT p.[Name], s.[Name]
FROM Production.Product p
INNER JOIN Production.ProductSubcategory s
ON p.ProductSubcategoryID = s.ProductSubcategoryID
AND s.[Name] = 'Wheels';
GO
```

下面是结果集：

复制

```
Name
LL Mountain Front Wheel Wheels
ML Mountain Front Wheel Wheels
HL Mountain Front Wheel Wheels
LL Road Front Wheel Wheels
ML Road Front Wheel Wheels
HL Road Front Wheel Wheels
Touring Front Wheel Wheels
LL Mountain Rear Wheel Wheels
ML Mountain Rear Wheel Wheels
HL Mountain Rear Wheel Wheels
LL Road Rear Wheel Wheels
ML Road Rear Wheel Wheels
HL Road Rear Wheel Wheels
Touring Rear Wheel Wheels

(14 row(s) affected)
```

以下示例查找所有信誉度良好，与 Adventure Works Cycles 有过至少 20 项订购记录，并且其平均交付时间小于 16 天的所有供应商的名称。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Purchasing.Vendor
WHERE CreditRating = 1
AND BusinessEntityID IN
    (SELECT BusinessEntityID
     FROM Purchasing.ProductVendor
     WHERE MinOrderQty >= 20
     AND AverageLeadTime < 16);
GO
```

下面是结果集：

复制

```
Name
--------------------------------------------------
Compete Enterprises, Inc
International Trek Center
First National Sport Co.
Comfort Road Bicycles
Circuit Cycles
First Rate Bicycles
Jeff's Sporting Goods
Competition Bike Training Systems
Electronic Bike Repair & Supplies
Crowley Sport
Expert Bike Co
Team Athletic Co.
Compete, Inc.   

(13 row(s) affected)
```

评估内部查询后，产生符合子查询限定条件的供应商的 ID 号。 然后评估外部查询。 注意，在内部和外部查询的 `WHERE` 子句中，都可以包括多个条件。

使用联接，同一查询可以用如下方式表示：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT DISTINCT [Name]
FROM Purchasing.Vendor v
INNER JOIN Purchasing.ProductVendor p
ON v.BusinessEntityID = p.BusinessEntityID
WHERE CreditRating = 1
  AND MinOrderQty >= 20
  AND AverageLeadTime < 16;
GO
```

联接总是可以表示为子查询。 子查询经常（但不总是）可以表示为联接。 这是因为联接是对称的：无论以何种顺序联接表 A 和 B，都将得到相同的结果。 而对子查询来说，情况则并非如此。

### 使用 `NOT IN` 的子查询

通过 `NOT IN` 关键字引入的子查询也返回一列零值或更多值。
以下查询将查找不是成品自行车的产品名称。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ProductSubcategoryID NOT IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE [Name] = 'Mountain Bikes' 
        OR [Name] = 'Road Bikes'
        OR [Name] = 'Touring Bikes');
GO
```

此语句无法转换为一个联接。 这种类似但不相等连接有不同的含义：它在某个非成品自行车的子类别中查找产品名称。

### `UPDATE`、`DELETE` 和 `INSERT` 语句中的子查询

可以在 `UPDATE`、`DELETE`、`INSERT` 和 `SELECT` 数据操作 (DML) 语句中嵌套子查询。

以下示例使 Production.Product 表的 ListPrice 列中的值加倍。 `WHERE` 子句中的子查询将引用 Purchasing.ProductVendor 表以便将 Product 表中更新的行仅限制为 BusinessEntity 1540 对应的那些行。

SQL复制

```sql
USE AdventureWorks2016;
GO 
UPDATE Production.Product
SET ListPrice = ListPrice * 2
WHERE ProductID IN
    (SELECT ProductID 
     FROM Purchasing.ProductVendor
     WHERE BusinessEntityID = 1540);
GO
```

下面是一条使用联接的等效 `UPDATE` 语句：

SQL复制

```sql
USE AdventureWorks2016;
GO 
UPDATE Production.Product
SET ListPrice = ListPrice * 2
FROM Production.Product AS p
INNER JOIN Purchasing.ProductVendor AS pv
    ON p.ProductID = pv.ProductID AND BusinessEntityID = 1540;
GO   
```

为清楚起见，如果同一个表本身在其他子查询中引用，请使用目标表的别名：

SQL复制

```sql
USE AdventureWorks2016;
GO 
UPDATE p
SET ListPrice = ListPrice * 2
FROM Production.Product AS p
INNER JOIN Purchasing.ProductVendor AS pv
    ON p.ProductID = pv.ProductID AND BusinessEntityID = 1540;
GO   
```

### 使用比较运算符的子查询

子查询可以由一个比较运算符（`=`、`< >`、`>`、`> =`、`<`、`! >`、`! <` 或 `< =`）引入。

与使用 `IN` 引入的子查询一样，由未修饰的比较运算符（即后面不接 `ANY` 或 `ALL` 的比较运算符）引入的子查询必须返回单个值而不是值列表。 如果这样的子查询返回多个值，SQL Server 将显示一条错误信息。

要使用由未修改的比较运算符引入的子查询，必须对数据和问题的本质非常熟悉，以了解该子查询实际是否只返回一个值。

例如，如果假定每个销售员只负责一块销售区域，而你要找出 Linda Mitchell 所负责区域的客户，那么可以编写一条语句，带上由简单的 `=` 比较运算符引入的子查询。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT CustomerID
FROM Sales.Customer
WHERE TerritoryID =
    (SELECT TerritoryID
     FROM Sales.SalesPerson
     WHERE BusinessEntityID = 276);
GO
```

但是，如果 `Linda Mitchell` 负责的销售区域不止一个，则会产生一条错误信息。 这时可以用 `IN` 表达式（`=ANY` 也可以）来代替 `=` 比较运算符。

由未修改的比较运算符引入的子查询经常包括聚合函数，因为这些子查询要返回单个值。 例如，下面的语句将找出定价高于平均定价的所有产品的名称。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ListPrice >
    (SELECT AVG (ListPrice)
     FROM Production.Product);
GO
```

因为由未修改的比较运算符引入的子查询必须返回单个值，所以除非知道 `GROUP BY` 或 `HAVING` 子句本身会返回单个值，否则不能包括 `GROUP BY` 或 `HAVING` 子句。 例如，下面的查询将找出 ProductSubcategoryID 14 中定价高于最低定价的产品。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ListPrice >
    (SELECT MIN (ListPrice)
     FROM Production.Product
     GROUP BY ProductSubcategoryID
     HAVING ProductSubcategoryID = 14);
GO
```

### 由 `ANY`、`SOME` 或 `ALL` 修改的比较运算符

可以用 `ALL` 或 `ANY` 关键字修改引入子查询的比较运算符。 `SOME` 是与 `ANY` 等效的 ISO 标准。 有关这些比较运算符的详细信息，请参阅 [SOME | ANY](https://docs.microsoft.com/zh-cn/sql/t-sql/language-elements/some-any-transact-sql?view=sql-server-ver15)。

通过修改的比较运算符引入的子查询返回零个值或多个值的列表，并且可以包括 `GROUP BY` 或 `HAVING` 子句。 这些子查询可以用 `EXISTS` 重新表述。

以 > 比较运算符为例，`>ALL` 表示大于每一个值。 换句话说，它表示大于最大值。 例如，`>ALL (1, 2, 3)` 表示大于 3。 `>ANY` 表示至少大于一个值，即大于最小值。 因此 `>ANY (1, 2, 3)` 表示大于 1。 若要使带有 `>ALL` 的子查询中的行满足外部查询中指定的条件，引入子查询的列中的值必须大于子查询返回的值列表中的每个值。

同样，`>ANY` 表示要使某一行满足外部查询中指定的条件，引入子查询的列中的值必须至少大于子查询返回的值列表中的一个值。

下面的查询提供一个由 `ANY` 修改的比较运算符引入的子查询的示例。 它查找定价高于或等于任何产品子类别的最高定价的产品。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ListPrice >= ANY
    (SELECT MAX (ListPrice)
     FROM Production.Product
     GROUP BY ProductSubcategoryID);
GO
```

对于每个产品子类别，内部查询查找最高定价。 外部查询查看所有这些值，并确定定价高于或等于任何产品子类别的最高定价的单个产品。 如果 `ANY` 更改为 `ALL`，查询将只返回定价高于或等于内部查询返回的所有定价的那些产品。

如果子查询不返回任何值，那么整个查询将不会返回任何值。

`=ANY` 运算符等效于 `IN`。 例如，若要查找 Adventure Works Cycles 生产的所有轮子产品的名称，可以使用 `IN` 或 `=ANY`。

SQL复制

```sql
--Using =ANY
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ProductSubcategoryID =ANY
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels');
GO

--Using IN
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE Name = 'Wheels');
GO
```

下面是任一查询的结果集：

复制

```
Name
--------------------------------------------------
LL Mountain Front Wheel
ML Mountain Front Wheel
HL Mountain Front Wheel
LL Road Front Wheel
ML Road Front Wheel
HL Road Front Wheel
Touring Front Wheel
LL Mountain Rear Wheel
ML Mountain Rear Wheel
HL Mountain Rear Wheel
LL Road Rear Wheel
ML Road Rear Wheel
HL Road Rear Wheel
Touring Rear Wheel

(14 row(s) affected)
```

但是，`<>ANY` 运算符不同于 `NOT IN`：

- `<>ANY` 表示不等于 a，或者不等于 b，或者不等于 c
- `NOT IN` 表示不等于 a，并且不等于 b，并且不等于 c
- `<>ALL` 表示与 `NOT IN` 相同

例如，以下查询查找位于任何销售人员都不负责的地区的客户。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT CustomerID
FROM Sales.Customer
WHERE TerritoryID <> ANY
    (SELECT TerritoryID
     FROM Sales.SalesPerson);
GO
```

结果包含除销售地区为 NULL 的客户以外的所有客户，因为分配给客户的每个地区都由一个销售人员负责。 内部查询查找销售人员负责的所有销售地区，然后对于每个地区，外部查询查找不在任一地区的客户。

由于同一原因，当在此查询中使用 `NOT IN` 时，结果将不包含任何客户。

还可以使用 `<>ALL` 运算符获得相同的结果，该运算符与 `NOT IN` 等效。

### 使用 `EXISTS` 的子查询

使用 `EXISTS` 关键字引入子查询后，子查询的作用就相当于进行存在测试。 外部查询的 `WHERE` 子句测试子查询返回的行是否存在。 子查询实际上不产生任何数据，它只返回 `TRUE` 或 `FALSE` 值。

使用 EXISTS 引入的子查询的语法如下：

```
WHERE [NOT] EXISTS (subquery)
```

以下查询将查找 Wheels 子类别中所有产品的名称：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE EXISTS
    (SELECT * 
     FROM Production.ProductSubcategory
     WHERE ProductSubcategoryID = 
            Production.Product.ProductSubcategoryID
        AND [Name] = 'Wheels');
GO
```

下面是结果集：

复制

```
Name
--------------------------------------------------
LL Mountain Front Wheel
ML Mountain Front Wheel
HL Mountain Front Wheel
LL Road Front Wheel
ML Road Front Wheel
HL Road Front Wheel
Touring Front Wheel
LL Mountain Rear Wheel
ML Mountain Rear Wheel
HL Mountain Rear Wheel
LL Road Rear Wheel
ML Road Rear Wheel
HL Road Rear Wheel
Touring Rear Wheel

(14 row(s) affected)
```

若要了解此查询的结果，请依次考虑每件产品的名称。 此值是否使子查询至少返回一行？ 换句话说，查询是否使存在测试的计算结果为 `TRUE`？

注意，使用 EXISTS 引入的子查询在下列方面与其他子查询略有不同：

- `EXISTS` 关键字前面没有列名、常量或其他表达式。
- 由 `EXISTS` 引入的子查询的选择列表通常几乎都是由星号 (*) 组成。 由于只是测试是否存在符合子查询中指定条件的行，因此不必列出列名。

由于通常没有备选的、无子查询的表示法，因此 `EXISTS` 关键字很重要。 尽管一些使用 EXISTS 创建的查询不能以任何其他方法表示，但许多查询都可以使用 `IN` 或者由 `ANY` 或 `ALL` 修改的比较运算符来获取类似结果。

例如，可以使用 `IN` 表示上述查询：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE ProductSubcategoryID IN
    (SELECT ProductSubcategoryID
     FROM Production.ProductSubcategory
     WHERE [Name] = 'Wheels');
GO
```

### 使用 `NOT EXISTS` 的子查询

`NOT EXISTS` 与 `EXISTS` 的工作方式类似，只是如果子查询不返回行，那么使用 NOT EXISTS 的 `WHERE` 子句会得到令人满意的结果。

例如，查找不在轮子类别中的产品的名称：

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name]
FROM Production.Product
WHERE NOT EXISTS
    (SELECT * 
     FROM Production.ProductSubcategory
     WHERE ProductSubcategoryID = 
            Production.Product.ProductSubcategoryID
        AND [Name] = 'Wheels');
GO
```

### 用于替代表达式的子查询

在 Transact-SQL 中，除了在 `ORDER BY` 列表中以外，在 `SELECT`、`UPDATE`、`INSERT` 和 `DELETE` 语句中任何能够使用表达式的地方都可以用子查询替代。

以下示例说明如何使用此增强功能。 此查询找出所有山地车产品的价格、平均价格以及两者之间的差价。

SQL复制

```sql
USE AdventureWorks2016;
GO
SELECT [Name], ListPrice, 
(SELECT AVG(ListPrice) FROM Production.Product) AS Average, 
    ListPrice - (SELECT AVG(ListPrice) FROM Production.Product)
    AS Difference
FROM Production.Product
WHERE ProductSubcategoryID = 1;
GO
```

## 另请参阅

### 语法：

- [IN (Transact-SQL)](https://docs.microsoft.com/zh-cn/sql/t-sql/language-elements/in-transact-sql?view=sql-server-ver15)
- [EXISTS (Transact-SQL)](https://docs.microsoft.com/zh-cn/sql/t-sql/language-elements/exists-transact-sql?view=sql-server-ver15)
- [ALL (Transact-SQL)](https://docs.microsoft.com/zh-cn/sql/t-sql/language-elements/all-transact-sql?view=sql-server-ver15)
- [SOME | ANY (Transact-SQL)](https://docs.microsoft.com/zh-cn/sql/t-sql/language-elements/some-any-transact-sql?view=sql-server-ver15)
- [联接](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/joins?view=sql-server-ver15)
- [比较运算符 (Transact-SQL)](https://docs.microsoft.com/zh-cn/sql/t-sql/language-elements/comparison-operators-transact-sql?view=sql-server-ver15)

### 查询性能概念：

- [查询处理体系结构指南](https://docs.microsoft.com/zh-cn/sql/relational-databases/query-processing-architecture-guide?view=sql-server-ver15)
- [查询存储最佳做法](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/best-practice-with-the-query-store?view=sql-server-ver15)
- [SQL 数据库中的智能查询处理](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/intelligent-query-processing?view=sql-server-ver15)
- [基数估计 (SQL Server)](https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/cardinality-estimation-sql-server?view=sql-server-ver15)