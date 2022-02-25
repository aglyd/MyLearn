# 一、[Oracle数据库MERGE语句](https://blog.csdn.net/zorro_jin/article/details/81053693)

## 一、使用背景

    当需要对一个表根据不同条件分别进行INSERT、UPDATE以及DELETE操作时，可以使用MERGE(融合，合并)语句。MERGE语句可以根据不同条件获取要插入、更新或删除到表中的数据行，然后从1个或多个数据源头对表进行更新或者向表中插入行。

## 二、MERGE语句的语法

```sql
MERGE INTO 表名
USING 表名/视图/子查询 ON 连接条件
-- 当匹配得上连接条件时
WHEN MATCHED THEN 
更新、删除操作
-- 当匹配不上连接条件时
WHEN NOT MATCHED THEN 
更新、删除、插入操作
```

## 三、示例

#### 1、创建要操作的表，并插入几条数据

```mysql
-- 60号部门员工奖金表
CREATE TABLE dept60_bonuses
(
   employee_id NUMBER,
   bonus_amt NUMBER
);

INSERT INTO dept60_bonuses
VALUES
(103, 0);
INSERT INTO dept60_bonuses
VALUES
(104, 100);
INSERT INTO dept60_bonuses
VALUES
(105, 0);

-- 提交事务
COMMIT;

SELECT employee_id, last_name, salary
FROM hr.employees
WHERE department_id = 60;
```

![img](https://img-blog.csdn.net/20180715165616248?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3pvcnJvX2ppbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

```mysql
SELECT *
FROM dept60_bonuses;
```

![img](https://img-blog.csdn.net/20180715170448156?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3pvcnJvX2ppbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

#### 2、根据不同条件对dept60_bonuses记录进行新增、修改以及删除操作

```sql
MERGE INTO dept60_bonuses b
USING (
           SELECT employee_id, salary, department_id
           FROM hr.employees
           WHERE department_id = 60
      ) e
ON (b.employee_id = e.employee_id)
-- 当符合关联条件时
WHEN MATCHED THEN
     -- 将奖金为0的员工的奖金调整为其工资的20%
     UPDATE 
     SET b.bonus_amt = e.salary * 0.2
     WHERE b.bonus_amt = 0
     -- 删除工资大于7500的员工奖金记录
     DELETE 
     WHERE (e.salary > 7500)
-- 当不符合连接条件时
WHEN NOT MATCHED THEN
     -- 将不在部门为60号的，且不在dept60_bonuses表的用工信息插入，并将其奖金设置为其工资的10%
     INSERT 
     (b.employee_id, b.bonus_amt)
     VALUES 
     (e.employee_id, e.salary * 0.1)
     WHERE (e.salary < 7500)
```

#### 3、操作示意图

![img](https://img-blog.csdn.net/20180715173523915?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3pvcnJvX2ppbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

#### 4、操作结果

![img](https://img-blog.csdn.net/20180715173616825?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3pvcnJvX2ppbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

#### 5、MERGE语句完成了以下任务：

· 更新了一行（员工id=105）

· 删除了一行（员工id=103）

· 插入了两行（员工id=106 & 107）

## 四、补充说明

USING：简化的连接查询

使用条件：

1、查询条件必须是等值连接

2、等值连接列必须有相同的名称和数据类型

------------------------------------------------
