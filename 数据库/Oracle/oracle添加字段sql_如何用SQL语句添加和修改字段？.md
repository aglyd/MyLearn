# [oracle添加字段sql_如何用SQL语句添加和修改字段？][https://blog.csdn.net/weixin_42544838/article/details/113535715]

增加字段：

alter table 表名 add 字段名 type not null default 0

在指定位置插入新字段:

alter table 表名 add [column] 字段名 字段类型 是否可为空 comment '注释' after 指定某字段 ;

删除字段：

alter table 表名 drop column 字段名;

修改字段名：

alter table 表名 rename column A to B

修改字段类型：

alter table 表名 alter column 字段名 type not null

修改字段默认值:

alter table 表名 add default (0) for 字段名 with values

注意：如果字段有默认值，则需要先删除字段的约束，在添加新的默认值，

select c.name from sysconstraints a

inner join syscolumns b on a.colid=b.colid

inner join sysobjects c on a.constid=c.id

where a.id=object_id('表名')

and b.name='字段名'

根据约束名称删除约束

alter table 表名 drop constraint 约束名

根据表名向字段中增加新的默认值

alter table 表名 add default (0) for 字段名 with values
------------------------------------------------
1.添加字段：

alter table  表名  add (字段  字段类型)  [ default  '输入默认值'] [null/not null]  ;

2.添加备注：

comment on column  库名.表名.字段名 is  '输入的备注';  如： 我要在ers_data库中  test表 document_type字段添加备注  comment on column ers_data.test.document_type is '文件类型';

3.修改字段类型：

alter table 表名  modiy (字段  字段类型  [default '输入默认值' ] [null/not null]  ,字段  字段类型  [default '输入默认值' ] [null/not null] ); 修改多个字段用逗号隔开

4.删除字段：

alter table  表名  drop (字段);