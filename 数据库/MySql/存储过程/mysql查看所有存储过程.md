# 一、[mysql查看所有存储过程](https://blog.csdn.net/qq_32786873/article/details/62893151)

方法一：


    select `name` from MySQL.proc where db = 'your_db_name' and `type` = 'PROCEDURE'


方法二：


     show procedure status;





查看存储过程或函数的创建代码

show create procedure proc_name;
show create function func_name;