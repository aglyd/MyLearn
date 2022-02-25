# [Oracle的varchar2类型实现主键自增][https://blog.csdn.net/qq_40303219/article/details/103957545]



```sql
1、建用户数据表
     drop table dectuser;
     create table dectuser(
          userid integer primary key,  /*主键，自动增加*/
          name varchar2(20),
          sex varchar2(2)
          );
2、创建自动增长序列
 
     drop sequence dectuser_tb_seq;
     create sequence dectuser_tb_seq minvalue 1 maxvalue 99999999
              increment by 1
              start with 1;   /*步长为1*/
3、创建触发器
      create or replace trigger dectuser_tb_tri
         before insert on dectuser     /*触发条件：当向表dectuser执行插入操作时触发此触发器*/
         for each row                       /*对每一行都检测是否触发*/
         begin                                   /*触发器开始*/
                select dectuser_tb_seq.nextval into :new.userid from dual;   /*触发器主题内容，即触发后执行的动作，在此是取得序列dectuser_tb_seq的下一个值插入到表dectuser中的userid字段中*/
          end;
    
         /                                         /*退出sqlplus行编辑*/
4、提交
     commit;
 
     现在就完成了自增主键的设定，搞定！
```

 

1.建表

```sql
create table project_manage(
productionid VARCHAR2(20) not null,
name VARCHAR2(20) not null,
remarks VARCHAR2(50));
```

2.序列

```sql
sqlcreate sequence auto_add
start with 10000
increment by 10
nomaxvalue
nocache
```

3.触发器

```sql
create or replace trigger myProject
before insert on project_manage
for each row
begin
if (to_char(:new.productionid) is null) then
select auto_add.nextval into :new.productionid from dual;
end if;
end;
```

 

