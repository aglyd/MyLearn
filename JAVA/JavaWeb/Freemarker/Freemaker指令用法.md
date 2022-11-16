# Freemaker指令用法

## [1、freemarker 的replace功能](https://www.cnblogs.com/volare/p/4288602.html)

```
替换字符串 replace  
${s?replace(‘ba’, ‘XY’ )}  
${s?replace(‘ba’, ‘XY’ , ‘规则参数’)}将s里的所有的ba替换成xy 规则参数包含: i r m s c f 具体含义如下: 
 i: 大小写不区分. 
 f: 只替换第一个出现被替换字符串的字符串
 r:  XY是正则表达式
```

![img](https://images0.cnblogs.com/blog/623878/201502/121731439018840.png)

将文本中的html标签替换掉，清除格式

Don’t hurry say have no choice， perhaps， next intersection will meet hope．



----

## [2、数字显示问题（超过1000会加逗号分隔）][https://blog.csdn.net/weixin_43376054/article/details/105722338]

freemarker在数字回显时，如果数字超过999，会自动用 , 分割开，例如 2020 变成了 2,020，然而，此时传递到后台的时候，并不会按照int/long处理，而是当作String字符串处理，所有会报类型不匹配的异常。

```
<input type="hidden" name="userId" value="${(user.userId)!number}" class="layui-input">
```

### 1、解决方案1全局变量

解决这个问题，只需要在application.properties文件中加入

```
spring.freemarker.settings.number_format=0.##

```

至于application.yaml版本为什么是number_format而不是number-format，别问我，我也是试出来的，这个通过IDEA的智能提示是无法直接提示的，因为是个Map对象。

```
spring:
    freemarker:
        settings:
            number_format: 0.##
```


yml的转换方法可以在toyaml 进行管理。

### 2、解决方案2临时

```ftl
${num?c}
如果是2020，会正常输出2020而不是2,020	如果不加?c 默认情况下freemarker会将数字用逗号分隔

${num?string('0.00')}
如果小数点后不足两位，用 0 代替

${num?string('#.##')}
如果小数点后多余两位，就只保留两位，否则输出实际值
输出为：1239765.46

${num?string(',###.00')}
输出为：1,239,765.46
整数部分每三位用 , 分割，并且保证小数点后保留两位，不足用 0 代替

${num?string(',###.##')}
输出为：1,239,765.46
整数部分每三位用 , 分割，并且小数点后多余两位就只保留两位，不足两位就取实际位数，可以不不包含小数点

${num?string('000.00')}
输出为：012.70
整数部分如果不足三位（000），前面用0补齐，否则取实际的整数位

${num?string('###.00')}
等价于
${num?string('#.00')}
输出为：12.70
整数取实际的位数
```

### 3、setting指令设置全局数字格式

setting指令,用于动态设置freeMarker的运行环境:

该指令用于设置FreeMarker的运行环境,该指令的语法格式如下:<#setting name=value>,在这个格式中,name的取值范围包含如下几个:
locale:该选项指定该模板所用的国家/语言选项
number_format:指定格式化输出数字的格式

```
<#setting number_format="percent"/>  

1、在模板中直接加.toString()转化数字为字符串，如：${languageList.id.toString()}； 
2、在freemarker配置文件freemarker.properties加number_format=#或者number_format=0； 
3、在模板中直接加<#setting number_format=",##0.00">，如：<#if AdminLanguagePaginationMsg?exists> 
<#setting number_format="#">
```

boolean_format:指定两个布尔值的语法格式,默认值是true,false
date_format,time_format,datetime_format:指定格式化输出日期的格式
time_zone:设置格式化输出日期时所使用的时区



## 时间格式化

```html
freemarker的日期格式化，可以使用预定义的变量
${dateVar?string.short}
${dateVar?string.medium}
${dateVar?string.long}
${dateVar?string.full}
      在local问US_EN，时区是US.PACIFIC时结果是
4/20/07 12:45 PM
Apr 20, 2007 12:45:09 PM
April 20, 2007 12:45:09 PM CEST
Friday, April 20, 2007 12:45:09 PM CEST
      日期和时间还可以分别指定
${lastUpdated?string.short_long} <#-- short date, long time -->
${lastUpdated?string.medium_short} <#-- medium date, short time -->
 
4/8/03 9:24:44 PM PDT
Apr 8, 2003 9:24 PM 
 
      自己指定格式是这样
${dateVar?string("yyyy-MM-dd HH:mm:ss zzzz")}
 
      下面这三个字符可以用来截取
date:只使用年、月、日
time:只使用时、分、秒和毫秒部分
datetime:日期和时间两部分都被使用
 
${dateVar?time}得到的是08:00:54 PM
```



-----

## [3、Freemarker中if判断为空](https://www.cnblogs.com/yisanx/p/12421508.html)[https://www.cnblogs.com/xinxin1994/p/6138063.html]

Freemarker中显示某对象使用 ${name}

#### 1.判断对象不为空

如果name为null，freemarker就会报错。

如果需要判断对象不为空：

```
<#if name??>

    ……

</#if>
```

当对象有属性时，对象及对象属性都有可能为空，可写成：

```
<#if (user.name)??>//判断对象属性不为空

    ……

</#if>
```

 

#### 2、判断List是不为空

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
<#if userList?? && (userList?size > 0) > 
    <h1>List不为空</h1>
    <#list userList as uInfo>
    ……
<#else> 
    <h1>显示</h1>
</#if>
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

#### 3、判断Map是否为空

用freemarker取出map值后，判断该值是否等于某一字符串，可以使用内建函数 ?string 来进行判断。

实际代码：

Data 是一个Record对象【JFinal的，其实可以理解为一个Map】。

Data.get(key)根据map的key取出value对应的值。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
<#list datas as Data>
    <Condition>
        <#list Data.getColumnNames() as key> 
            <${key}>
            <#if Data.get(key)?exists>
                <#if Data.get(key)?string !="null">${Data.get(key)}</#if>
            </#if>
            </${key}> 
        </#list>
   </Condition>
</#list>
```



----

## [4、FreeMarker四种变量的用法][https://blog.csdn.net/dianerbing/article/details/79032699]

**freemarker的变量**可以分为四种，分别是数据模型的变量【root中的变量】，模板中的变量使用【<#assign>定义的变量】，局部变量【在指令中的变量】，循环变量【在循环中的变量】 **数据模型的变量【root中的变量】** 直接从模型中给模板传值的变量就是数据模型的变量，它把变量的值放在一个map中，在模板中直接可以用。 

```
@Test**public** **void** test10() {  root.put("username","张三");  fu.print("10.ftl",root);}
```

${username}张三 **模板中的变量使用【<#assign>定义的变量】** 模板中的变量，是使用<#assign定义的变量，如果模板中定义的变量和模型中的变量名称一致，不是覆盖，而是隐藏

| <#assign username="李四"><#--此时模板中的变量的名称和模型中的变量名称一致，不是覆盖，而是隐藏-->${username} |
| ------------------------------------------------------------ |
| 李四                                                         |

${username}李四模型中的变量被隐藏后，可以使用.globals可以访问模型中的变量<#--使用.globals可以访问模型中的变量-->

| <#--使用.globals可以访问模型中的变量-->${.globals.username} |
| ----------------------------------------------------------- |
| 张三                                                        |

 **局部变量【在指令中的变量】** 使用local可以声明局部变量<#macro test>  



| <#macro test>  <#--  此时当调用该指令之后，会将模板中的变量username覆盖为王五  所以这种方式存在风险，所以一般不使用这种方式在指令中定义变量  -->  <#--<#assign  username="王五"/>-->  <#--使用local可以声明局部变量，所以在marco中非特殊使用局部变量-->  <#local  username="王五"/>  ${username}</#macro><@test/>${username} |
| ------------------------------------------------------------ |
| 王五  李四                                                   |

 **循环变量【在循环中的变量】** 在list循环中定义的变量，循环中的变量只在循环中有效，也是一种临时的变量定义方式

| <#list 1..3 as username>  <#--循环中的变量出了循环就消失-->  ${username}</#list>$​{username}   <=3 |
| ------------------------------------------------------------ |
| 1  2  3李四                                                  |



### **assign** 

  assign指令在前面已经使用了多次,它用于为该模板页面创建或替换一个顶层变量,

  assign指令的用法有多种,包含创建或替换一个顶层变量,或者创建或替换多个变量等,

  它的最简单的语法如下:

   <#assign name=value [in namespacehash]>,

   这个用法用于指定一个名为name的变量,该变量的值为value,

   此外,FreeMarker允许在使用assign指令里增加in子句,

   in子句用于将创建的name变量放入namespacehash命名空间中.



 

  assign指令还有如下用法:

   <#assign name1=value1 name2=value2 ... nameN=valueN [in namespacehash]>,

   这个语法可以同时创建或替换多个顶层变量,此外,还有一种复杂的用法,

   如果需要创建或替换的变量值是一个复杂的表达式,

   则可以使用如下语法格式:

​    <#assign name [in namespacehash]>capture this</#assign>,

   在这个语法中,是指将assign指令的内容赋值给name变量.如下例子:

   <#assign x>
   <#list ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期天"]as n>
   ${n}
   </#list>
   </#assign>
   ${x}
   上面的代码将产生如下输出:

​        星期一 星期二 星期三 星期四 星期五 星期六 星期天

   虽然assign指定了这种复杂变量值的用法,但是我们也不要滥用这种用法,

​    如下例子:

​         <#assign x>Hello ${user}!</#assign>,

​    以上代码改为如下写法更合适:

​         <#assign x="Hello ${user}!">



参考文档（想详细学习的看这里）：http://freemarker.foofun.cn

它和 assign 指令 类似，但是它创建或替换局部变量。 这仅仅在宏和方法的内部定义才会有作用。要获得更多关于变量的信息，可以阅读：模板开发指南/其它/在模板中定义变量

### 实现变量求和

```
<#assign tprice = 0 >
<#list orderlist as order >
<#if order.price??>
<#assign tprice = tprice + order.price >
</#if>
</#list>

${tprice } <!#-- 输出结果 -->
```



-----

## [5、local和assign标签区别][https://blog.csdn.net/weixin_41056807/article/details/98609201]

local
概要

```
<#local name=value>
或
<#local name1=value1 name2=value2 ... nameN=valueN>
或
<#local name>
  capture this
</#local>
```

name： 在root中局部对象的名称。它不是一个表达式。但它可以被写作是字符串形式， 如果变量名包含保留字符，这是很有用的，比如 <#local “foo-bar” = 1>。 请注意，这个字符串没有扩展插值(如"${foo}")
=：赋值操作符，也可以简写的赋值操作符之一 (++，+= 等…)，和 the assign 指令 相似。
value： 存储的值，是表达式。
它和 assign 指令 类似，但是它创建或替换局部变量。 这仅仅在宏和方法的内部定义才会有作用。要获得更多关于变量的信息，可以阅读：模板开发指南/其它/在模板中定义变量

assign
概要

<#assign name1=value1 name2=value2 ... nameN=valueN>
或
<#assign same as above... in namespacehash>
或
<#assign name>
  capture this
</#assign>
或
<#assign name in namespacehash>
  capture this
</#assign>

name：变量的名字。 它不是表达式。而它可以写作是字符串，如果变量名包含保留字符这是很有用的， 比如 <#assign “foo-bar” = 1>。 请注意这个字符串没有展开插值(如"${foo}")； 如果需要赋值一个动态创建的名字，那么不得不使用 这个技巧。
=：赋值操作符。 它也可以是一个简写的赋值操作符(从 FreeMarker 2.3.23 版本开始)： ++，–， +=，-=， *=，/= 或 %=。比如 <#assign x++> 和 <#assign x = x + 1> 是一样的，并且 <#assign x += 2> 和 <#assign x = x + 2> 是相同的。 请注意， ++ 通常意味着算术加法 (对于非数字将会失败)，不像 + 或 += 可以进行字符连接等重载操作
value： 存储的值。是表达式
namespacehash：(通过 import) 为命名空间创建的哈希表。是表达式
描述
使用该指令你可以创建一个新的变量， 或者替换一个已经存在的变量。注意仅仅顶级变量可以被创建/替换 (也就是说你不能创建/替换 some_hash.subvar， 除了 some_hash)

assign应用：
1.变量 seq 存储一个序列

<#assign seq = ["foo", "bar", "baz"]>
1
2.变量 x 中存储增长的数字

<#assign x++>
1
3.作为一个方便的特性，你可以使用一个 assign 标记来进行多次定义。
比如这个会做上面两个例子中相同的事情

<#assign
  seq = ["foo", "bar", "baz"]
  x++
>
>4.assign 指令在命名空间中创建变量。
>通常它在当前的命名空间 (也就是和标签所在模板关联的命名空间)中创建变量。
>但如果你是用了 in namespacehash，
>那么你可以用另外一个 命名空间 来创建/替换变量。
>比如，这里你在命名空间中 /mylib.ftl 创建/替换了变量 bgColor

<#import "/mylib.ftl" as my>
<#assign bgColor="red" in my>

5.assign 的极端使用是当它捕捉它的开始标记和结束标记中间生成的输出时。
也就是说，在标记之间打印的东西将不会在页面上显示， 但是会存储在变量中

<#macro myMacro>foo</#macro>
<#assign x>
  <#list 1..3 as n>
    ${n} <@myMacro />
  </#list>
</#assign>
Number of words: ${x?word_list?size}
${x}

请注意，你不应该使用它来往字符串中插入变量：

<#assign x>Hello ${user}!</#assign> <#-- BAD PRACTICE! -->

你可以这么来写：

<#assign x="Hello ${user}!">



## List

```html
<#list list as a>  
     ${a_index}  //打印list遍历中的下标序号
</#list>   
```



## 获取到当前list循环的counter

```html
<#list lists as x>
<#assign j=x?counter>
${j}						//依次输出1，2，3....根据循环次数而定
</#list>
```

