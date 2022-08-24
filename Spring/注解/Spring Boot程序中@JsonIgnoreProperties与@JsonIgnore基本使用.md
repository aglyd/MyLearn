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



**实际代码**

代码简要说明， User类的fullName 和comment字段会被@JsonIgnoreProperties注解忽略。address字段会被@JsonIgnore注解忽略。regDate会按照@JsonFormat(timezone = “GMT+8”, pattern = “yyyy-MM-dd HH:mm:ss”)进行格式转。

```java
@Data
@JsonIgnoreProperties(value = {"fullName", "comment"})
public class User {
    private String id;
    private String name;
    private String fullName;
    private String comment;
    private String mail;

    @JsonIgnore
    private String address;

    @JsonFormat(timezone = "GMT+8", pattern = "yyyy-MM-dd HH:mm:ss")
    private Date regDate;

    private Date reg2Date;
}
```

controller示例代码

```java
    @ApiOperation(value = "按用户id删除", notes="private")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "userId", defaultValue = "2", value = "userID", required = true, dataType = "string", paramType = "path"),
    })
    @DeleteMapping(value = "/users/{userId}", produces = "application/json;charset=UTF-8")
    public User delUser(@PathVariable String userId) {
        User user = (User)userSvc.deleteById(userId);
        log.info("rest del user={} by id={}", user, userId);
        return user;
    }
```



# [@JsonInclude](https://blog.csdn.net/Mr_Dracy/article/details/117950385)

前后端分离的项目，框架中封装了返回给前端的结果。
但是在数据库中查询到的数据为null 的时候，响应的内容没有了，但是前端想要得到这个类型的结构（比如说是个实体，那么就返回他的各个属性；是个数据或集合就返回 [ ] ）。最终发现是@JsonInclude这个注解过滤掉了当返回值为null 的时候的属性。
@JsonInclude(JsonInclude.Include.ALWAYS) 默认
@JsonInclude(JsonInclude.Include.NON_DEFAULT ) 属性为默认值不序列化
@JsonInclude(JsonInclude.Include.NON_EMPTY ) 属性为空（""） 或者为 NULL 都不序列化
@JsonInclude(JsonInclude.Include.NON_NULL ) 属性为NULL 不序列化

将该标记放在属性上，如果该属性满足它的条件则不参与序列化 ；如果放在类上，那么该标记对这个类的全部属性起作用。

☺下图是注解为：NON_EMPTY
![1661235370055](C:\Users\sever\AppData\Roaming\Typora\typora-user-images\1661235370055.png)
☺当我把注解改为：NON_DEFAULT 之后，返回值是个空的集合：[] ，就展示出来了。

```
{
	"results":{
	"api_version":"1.0",
	"return_code":200,
	"result_datas":[]
	}
}
```



## @JsonInclude用法：

JsonInclude.Include.ALWAYS 这个是默认策略，任何情况下都序列化该字段，和不写这个注解是一样的效果。
JsonInclude.Include.NON_NULL 这个最常用，即如果加该注解的字段为null，那么就不序列化这个字段了。
JsonInclude.Include.NON_ABSENT 这个包含NON_NULL，即为null的时候不序列化，详情看源码。

JsonInclude.Include.NON_EMPTY 这个属性包含NON_NULL，NON_ABSENT之后还包含如果字段为空也不序列化。

JsonInclude.Include.NON_DEFAULT 这个属性是如果该字段为默认值的话就不序列化。

JsonInclude.Include.USE_DEFAULTS 使用默认值的情况下就不序列化。

JsonInclude.Include.CUSTOM 这个是自定义包含规则，官方的解释如下：

如果使用@JsonInclude#value=JsonInclude.Include.CUSTOM并通过@JsonInclude#value filter指定一个筛选器类，则仅当该属性值未被筛选器类筛选时，才会对其进行序列化。filter类的equals（）方法用于筛选值；如果返回“true”，则不序列化值。

类似地，如果使用@JsonInclude#content=JsonInclude.Include.CUSTOM并通过@JsonInclude#content filter指定筛选器类，则如果筛选器类的equals方法返回true，则不会序列化目标属性的内容值。

注：fasterxml.jackson的相关版本2.8不支持，小编使用的是2.10version

**Example**

```java
package com.logicbig.example; 
import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.Date;
import java.util.Map;
 
 
@Data
public class Employee {
 
    private String name;
 
    @JsonInclude(value = JsonInclude.Include.CUSTOM, valueFilter = DateOfBirthFilter.class)
    private Date dateOfBirth;
 
    @JsonInclude(content = JsonInclude.Include.CUSTOM, contentFilter = PhoneFilter.class)
    private Map<String, String> phones;
 
}
```

```java
package com.logicbig.example;
 
 
 
import java.util.Date;
 
 
 
public class DateOfBirthFilter {
 
 
 
    @Override
 
    public boolean equals(Object obj) {
 
        if (obj == null || !(obj instanceof Date)) {
 
            return false;
 
        }
 
        //date should be in the past
 
        Date date = (Date) obj;
 
        return !date.before(new Date());
 
    }
 
}
```

```java
package com.logicbig.example;
 
 
 
import java.util.regex.Pattern;
 
 
 
public class PhoneFilter {
 
    private static Pattern phonePattern = Pattern.compile("\\d{3}-\\d{3}-\\d{4}");
 
 
 
    @Override
 
    public boolean equals(Object obj) {
 
        if (obj == null || !(obj instanceof String)) {
 
            return false;
 
        }
 
        //phone must match the regex pattern
 
        return !phonePattern.matcher(obj.toString()).matches();
 
    }
 
}
```

