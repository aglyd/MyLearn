## [distinct 单个字段](https://www.cnblogs.com/q149072205/p/4318133.html)

**如果数据库设置select后字段必须是group by的字段，则需用一下方法group by接聚合函数min()取出一条的id，再根据该id去取其余的字段**



select 要使用字段1,要使用字段2 from 表名 where id in (select min(id) from 表名 group by 不重复字段名)

例：

 select byid,id from bbs where id in (select min(id) from bbs group by byid)

select * from table where id in (select min(id) from table group by a,b,c)



```
SELECT 字段A,字段B FROM 表 
WHERE 字段A IN(SELECT MAX(字段A) FROM 表 GROUP BY 字段B) 
order by 字段A desc
```



如果数据库没有设置select字段必须在group by（sql_mode中没有’only_full_group_by’），则可直接select * from table group by 不重复字段



