# [Spring Boot程序中@JsonIgnoreProperties与@JsonIgnore基本使用][https://blog.csdn.net/russle/article/details/84147236]


问题由来：
springboot项目中定义了很多类，我们在rest返回中直接返回或者在返回对象中使用这些类，spring已经使用jackson自动帮我们完成这些的to json。但是有时候自动转的json内容太多，或者格式不符合我们的期望，因此需要调整类的to json过程，或者说希望自定义类的json过程。

解决办法：
使用@JsonIgnoreProperties、@JsonIgnore、@JsonFormat。

@JsonIgnore注解用来忽略某些字段，可以用在变量或者Getter方法上，用在Setter方法时，和变量效果一样。这个注解一般用在我们要忽略的字段上。

@JsonIgnoreProperties(ignoreUnknown = true)，将这个注解写在类上之后，就会忽略类中不存在的字段。这个注解还可以指定要忽略的字段，例如@JsonIgnoreProperties({ “password”, “secretKey” })

@JsonFormat可以帮我们完成格式转换。例如对于Date类型字段，如果不适用JsonFormat默认在rest返回的是long，如果我们使用@JsonFormat(timezone = “GMT+8”, pattern = “yyyy-MM-dd HH:mm:ss”)，就返回"2018-11-16 22:58:15"

具体可以参考官方文档
https://fasterxml.github.io/jackson-annotations/javadoc/2.6/com/fasterxml/jackson/annotation/JsonIgnoreProperties.html

@JsonProperty 此注解用于属性上，作用是把该属性的名称序列化为另外一个名称，如把myName属性序列化为name，@JsonProperty(value="name")。

在变成json序列化时候就用这个名字来命名，如在controller里

(@RequestBody Person person)

前端传入person对象的参数就为{“name”:”xxxx”}而不是用myName