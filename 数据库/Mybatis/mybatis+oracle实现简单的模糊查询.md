# [mybatis+oracle实现简单的模糊查询](https://www.cnblogs.com/maogege/p/10462329.html)

第一种 concat

```
select * from cat_table where cat_name like concat(#{catName},'%')      --单个百分号
select * from cat_table where cat_name like concat(concat('%',#{catName}),'%')    --前后百分号
```

第二种 ||

```
select * from cat_table where cat_name like '%' || #{catName} || '%' 
```

 第三种 instr

```
select * from cat_table where instr(#{catName},'helloworld')>0
```



-----



# [mybatis sql使用及Oracle模糊查询][https://blog.csdn.net/qq_40846086/article/details/84101240]

1.第一个问题

sql在数据库能查到但是,执行时就是什么都没有,网上查了下,解决办法,可能可数据库数据类型有关,如果是char(10)长度为10的话,可能不足10个都用空格补位了,所以这个时候要加trim()函数去空格,因为

但我加上并没有什么用,而且我数据库类型varchar可变长度

 

这个是用postman的请求

这个是查询结果,但当时这个参数是'37',查询结果totel = 0

xml地方去掉参数直接查询就正常了,由此判断是还是传参问题,但注解传参也没发现有什么问题



xml页面用#进行接收



最后看了下sql编译结果发现 select * from table where provCode = ''37''

是这个条件去查的,不是双引号,而是嵌套了两个单引号,那么匹配条件自然没有里面于''单引号的.

解决办法,其实是个失误,



postman拼接参数不加''单引号即可,笑哭

在就是可以使用${value} 来进行接收 ,${value} 不会自动加''号

再就是记录一些小规范 ,#和{之间不能有空格



不能写分号结束,会报无效的字符



再就是一个模糊查询的问题,首先说下两种接收参数区别

#{} 会在 变量外侧 加上 单引号

${} 并不会

但我们应尽量避免使用 ${} ，因为这个最终会将参数拼接到 sql语句上，存在sql注入的问题。

 两种办法

**1.使用'%${name}%'  这种方式，但是这种方式并不好，上面说了，有sql注入的风险。**

**2.我们可以采用 name like concat('%',#{name},'%') 这种方式来进行字符串拼接.**

**但是以上拼接在oracle中是错误的,因为oracle中concat函数拼接3个要嵌套拼接**

**concat(concat('aa','bb'),'cc')**

**或者使用**



**注意第二种方法后面两个只限oracle。**

**mysql concat('%',#{name},'%')就可以 了,第一种方法则都可以**

****

```
<!--方法三: 使用 bind 标签,对字符串进行绑定,然后对绑定后的字符串使用 like 关键字进行模糊查询 -->
<if test="email != null">
<bind name="pattern" value="'%'+email+'%'"/>
and email like #{pattern}
</if>
```


