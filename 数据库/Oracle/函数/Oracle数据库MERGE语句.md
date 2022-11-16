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

```sql
merge into 目标表 a
 
using 源表 b
 
on(a.条件字段1=b.条件字段1 and a.条件字段2=b.条件字段2 ……)  
 
when matched then update set a.字段=b.字段 --目标表别称a和源表别称b都不要省略
 
when  not matched then insert (a.字段1,a.字段2……)values(b.字段1,b.字段2……) --目标表别称a可省略,源表别称b不可省略
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



## 用例

```xml
   <!-- 保存或修改账户清理信息集合 -->  
    <update id="saveOrUpdateAccountCleanList" parameterClass="java.util.ArrayList">
        MERGE INTO AIMS_ACCOUNT_CLEAN AAC 
        USING
        <iterate open="(" close=") A" conjunction="UNION">  
            SELECT
            <!-- 主键为空时候返回字符串，与原类型不匹配，非字符串类型都需要做转换 -->
            DECODE(#list[].cleanId#,NULL,NULL,#list[].cleanId#) AS CLEAN_ID,
            DECODE(#list[].accountId#,NULL,NULL,#list[].accountId#) AS ACCOUNT_ID,
            #list[].accountCode# AS ACCOUNT_CODE,
            #list[].accountName# AS ACCOUNT_NAME,
            #list[].noticeDate# AS NOTICE_DATE,
            DECODE(#list[].needClean#,NULL,NULL,#list[].needClean#) AS NEED_CLEAN,
            #list[].feedbackResult# AS FEEDBACK_RESULT,
            #list[].undoReason# AS UNDO_REASON,
            #list[].feedbackDate# AS FEEDBACK_DATE,
            #list[].aacCreateTime# AS AAC_CREATE_TIME,
            #list[].aacUpdateTime# AS AAC_UPDATE_TIME,
            #list[].aacCreatePerson# AS AAC_CREATE_PERSON,
            #list[].aacUpdatePerson# AS AAC_UPDATE_PERSON,
            #list[].cleanStep# AS CLEAN_STEP
            FROM DUAL
        </iterate>
        ON (A.CLEAN_ID = AAC.CLEAN_ID)
        WHEN MATCHED THEN
            UPDATE SET
            AAC.AAC_UPDATE_TIME = A.AAC_UPDATE_TIME
        <isNotEqual compareValue="" property="list[].accountId" prepend=",">
            AAC.ACCOUNT_ID = A.ACCOUNT_ID
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].accountName" prepend=",">
            AAC.ACCOUNT_CODE = A.ACCOUNT_CODE
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].accountName" prepend=",">
            AAC.ACCOUNT_NAME = A.ACCOUNT_NAME
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].noticeDate" prepend=",">
            AAC.NOTICE_DATE = A.NOTICE_DATE
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].needClean" prepend=",">
            AAC.NEED_CLEAN = A.NEED_CLEAN
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].feedbackResult" prepend=",">
            AAC.FEEDBACK_RESULT = A.FEEDBACK_RESULT
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].undoReason" prepend=",">
            AAC.UNDO_REASON = A.UNDO_REASON
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].feedbackDate" prepend=",">
            AAC.FEEDBACK_DATE = A.FEEDBACK_DATE
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].aacCreateTime" prepend=",">
            AAC.AAC_CREATE_TIME = A.AAC_CREATE_TIME
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].aacCreatePerson" prepend=",">
            AAC.AAC_CREATE_PERSON = A.AAC_CREATE_PERSON
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].aacUpdatePerson" prepend=",">
            AAC.AAC_UPDATE_PERSON = A.AAC_UPDATE_PERSON
        </isNotEqual>
        <isNotEqual compareValue="" property="list[].cleanStep" prepend=",">
            AAC.CLEAN_STEP = A.CLEAN_STEP
        </isNotEqual>
 
        <isNotEmpty prepend="," property="list[].accountCode">
                AAC.ACCOUNT_CODE = A.ACCOUNT_CODE
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].accountName">
                AAC.ACCOUNT_NAME = A.ACCOUNT_NAME
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].noticeDate">
                AAC.NOTICE_DATE = A.NOTICE_DATE
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].needClean">
                AAC.NEED_CLEAN = A.NEED_CLEAN
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].feedbackResult">
                AAC.FEEDBACK_RESULT = A.FEEDBACK_RESULT
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].undoReason">
                AAC.UNDO_REASON = A.UNDO_REASON
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].feedbackDate">
                AAC.FEEDBACK_DATE = A.FEEDBACK_DATE
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].aacCreateTime">
                AAC.AAC_CREATE_TIME = A.AAC_CREATE_TIME
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].aacCreatePerson">
                AAC.AAC_CREATE_PERSON = A.AAC_CREATE_PERSON
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].aacUpdatePerson">
                AAC.AAC_UPDATE_PERSON = A.AAC_UPDATE_PERSON
            </isNotEmpty>
            <isNotEmpty prepend="," property="list[].cleanStep">
                AAC.CLEAN_STEP = A.CLEAN_STEP
            </isNotEmpty>
        WHEN NOT MATCHED THEN 
            INSERT (
            CLEAN_ID,
            ACCOUNT_ID,
            ACCOUNT_CODE,
            ACCOUNT_NAME,
            NOTICE_DATE,
            NEED_CLEAN,
            FEEDBACK_RESULT,
            UNDO_REASON,
            FEEDBACK_DATE,
            AAC_CREATE_TIME,
            AAC_UPDATE_TIME,
            AAC_CREATE_PERSON,
            AAC_UPDATE_PERSON,
            CLEAN_STEP
            ) VALUES (
            AIMS_ACCOUNT_CLEAN_SEQ.NEXTVAL,
            A.ACCOUNT_ID,
            A.ACCOUNT_CODE,
            A.ACCOUNT_NAME,
            A.NOTICE_DATE,
            A.NEED_CLEAN,
            A.FEEDBACK_RESULT,
            A.UNDO_REASON,
            A.FEEDBACK_DATE,
            A.AAC_CREATE_TIME,
            A.AAC_UPDATE_TIME,
            A.AAC_CREATE_PERSON,
            A.AAC_UPDATE_PERSON,
            A.CLEAN_STEP
            )    
    </update>
```

