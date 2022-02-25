# [常用的校验注解之实体字段校验 @NotNull、@NotEmpty、@NotBlank][https://blog.csdn.net/weixin_49770443/article/details/109772162]

```
1.@NotNull

不能为 null，但可以为 empty，一般用在 Integer 类型的基本数据类型的非空校验上，而且被其标注的字段可以使用 @size、@Max、@Min 对字段数值进行大小的控制

2.@NotEmpty

不能为 null，且长度必须大于 0，一般用在集合类上或者数组上

3.@NotBlank

只能作用在接收的 String 类型上，注意是只能，不能为 null，而且调用 trim() 后，长度必须大于 0即：必须有实际字符
```

注意在使用 @NotBlank 等注解时，一定要和 @valid 一起使用，否则 @NotBlank 不起作用。
一个 BigDecimal 的字段使用字段校验标签应该为 @NotNull。
在使用 @Length 一般用在 String 类型上可对字段数值进行最大长度限制的控制。
在使用 @Range 一般用在 Integer 类型上可对字段数值进行大小范围的控制。


如下图示：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201118143135279.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80OTc3MDQ0Mw==,size_16,color_FFFFFF,t_70#pic_center)




如下示例：

```
1.String name = null;

@NotNull: false
@NotEmpty:false 
@NotBlank:false 



2.String name = "";

@NotNull:true
@NotEmpty: false
@NotBlank: false



3.String name = " ";

@NotNull: true
@NotEmpty: true
@NotBlank: false



4.String name = "Hello World！";

@NotNull: true
@NotEmpty:true
@NotBlank:true
```




常用的校验注解

javax.validation.constraints.xxx

|注解	|说明|
| ---- | ---- | ---- |
|@Null	|被注释的元素必须为null|
|@NotNull	|被注释的元素不能为null|
|@AssertTrue	|被注释的元素必须为true|
|@AssertFalse	|被注释的元素必须为false|
|@Min(value)	|被注释的元素必须是一个数字，其值必须大于等于指定的最小值||
|@Max(value)	|被注释的元素必须是一个数字，其值必须小于等于指定的最大值|
|@DecimalMin(value)	|被注释的元素必须是一个数字，其值必须大于等于指定的最小值|
|@DecimalMax(value)	|被注释的元素必须是一个数字，其值必须小于等于指定的最大值|
|@Size(max,min)	|被注释的元素的大小必须在指定的范围内。|
|@Digits(integer,fraction)	|被注释的元素必须是一个数字，其值必须在可接受的范围内|
|@Past	|被注释的元素必须是一个过去的日期|
|@Future	|被注释的元素必须是一个将来的日期|
|@Pattern(value)	|被注释的元素必须符合指定的正则表达式。|
|@Email	|被注释的元素必须是电子邮件地址|
|@Length	|被注释的字符串的大小必须在指定的范围内|
|@NotEmpty	|被注释的字符串必须非空|
|@Range	|被注释的元素必须在合适的范围内|



附 @JsonFormat

```
有时使用 @JsonFormat 注解时，查到的时间可能会比数据库中的时间少八个小时，这是由于时区差引起的，JsonFormat 默认的时区是 Greenwich Time， 默认的是格林威治时间，而我们是在东八区上，所以时间会比实际我们想得到的时间少八个小时。需要在后面加上一个时区,如下示例：
```

```
@JsonFormat(pattern="yyyy-MM-dd",timezone="GMT+8")
private Date date;
```



---



# [@Validated注解详解，分组校验，嵌套校验，@Valid和@Validated 区别，Spring Boot @Validated][https://blog.csdn.net/qq_32352777/article/details/108424932]

![img]()