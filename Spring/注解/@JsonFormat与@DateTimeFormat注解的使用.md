# [@JsonFormat与@DateTimeFormat注解的使用](https://www.cnblogs.com/mracale/p/9828346.html)

背景：

前端时间控件，一般情况下直接会传一个yyyy-MM-dd的日期字符串到后台。这个时候如果我们直接用java.util.Date类型就无法正确接收到。或者我们从数据库里查到DateTime类型并且用java的Date类型接收并返回给前台的时候，前台也无法用yyyy-MM-dd的形式进行呈现。
这个时候，前面两种情况分别对应了@DateTimeFormat和@JsonFormat注解的使用。

从数据库获取时间传到前端进行展示的时候，我们有时候可能无法得到一个满意的时间格式的时间日期，在数据库中显示的是正确的时间格式，获取出来却变成了很丑的时间戳，@JsonFormat注解很好的解决了这个问题，我们通过使用@JsonFormat可以很好的解决：后台到前台时间格式保持一致的问题，其次，另一个问题是，我们在使用WEB服务的时，可能会需要用到，传入时间给后台，比如注册新用户需要填入出生日期等，这个时候前台传递给后台的时间格式同样是不一致的，而我们的与之对应的便有了另一个注解，@DataTimeFormat便很好的解决了这个问题，接下来记录一下具体的@JsonFormat与DateTimeFormat的使用过程。

声明：关于@JsonFormat的使用，一定要导入正确完整的包。

## 1.注解@JsonFormat

  1.使用maven引入@JsonFormat所需要的jar包，我贴一下我这里的pom文件的依赖

```xml
<!--JsonFormat-->
  
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-annotations</artifactId>
            <version>2.8.8</version>
        </dependency>
  
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.8.8</version>
        </dependency>
  
        <dependency>
            <groupId>org.codehaus.jackson</groupId>
            <artifactId>jackson-mapper-asl</artifactId>
            <version>1.9.13</version>
        </dependency>
```

2.在你需要查询出来的时间的数据库字段对应的实体类的属性上添加@JsonFormat

```java
import java.util.Date;
  
import com.fasterxml.jackson.annotation.JsonFormat;
  
public class TestClass {
  
    //设置时区为上海时区，时间格式自己据需求定。
    @JsonFormat(pattern="yyyy-MM-dd",timezone = "GMT+8")
    private Date testTime;
  
     
    public Date gettestTime() {
        return testTime;
    }
  
    public void settestTime(Date testTimee) {
        this.testTime= testTime;
    }
}
```

这里解释一下：@JsonFormat(pattern="yyyy-MM-dd",timezone = "GMT+8")

  pattern:是你需要转换的时间日期的格式

  timezone：是时间设置为东八区，避免时间在转换中有误差

 提示：@JsonFormat注解可以在属性的上方，同样可以在属性对应的get方法上，两种方式没有区别

3.完成上面两步之后，我们用对应的实体类来接收数据库查询出来的结果时就完成了时间格式的转换，**再返回给前端时就是一个符合我们设置的时间格式了**

## 2.注解@DateTimeFormat

1.@DateTimeFormat的使用和@jsonFormat差不多，首先需要引入是spring还有jodatime,spring我就不贴了

```xml
<!-- joda-time -->
        <dependency>
            <groupId>joda-time</groupId>
            <artifactId>joda-time</artifactId>
            <version>2.3</version>
        </dependency>
```

2.在controller层我们使用spring mvc 表单自动封装映射对象时，我们在对应的接收前台数据的对象的属性上加@@DateTimeFormat

```java
@DateTimeFormat(pattern = "yyyy-MM-dd")		//前端传入此格式的字符串即可
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss",timezone="GMT+8")
private Date symstarttime;
 
@DateTimeFormat(pattern = "yyyy-MM-dd")
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss",timezone="GMT+8")
private Date symendtime;
```

　　随后在前端对应symendtime传入的yyyy-MM-dd日期类型就能够按照该种格式进行转义赋值给Person类中的symendtime的Date类型。
若想按照yyyy/MM/dd的日期格式，则直接修改@DateTimeFormat的pattern属性为对应的日期格式即可，即@DateTimeFormat(pattern = “yyyy/MM/dd”)。或者还想要接收到对应的HH-mm-ss时分秒，同样在pattern中加上即可，如@DateTimeFormat(pattern = “yyyy-MM-dd HH-mm-ss”)

 我这里就只贴这两个属性了，这里我两个注解都同时使用了，因为我既需要取数据到前台，也需要前台数据传到后台，都需要进行时间格式的转换，可以同时使用

3.通过上面两个步骤之后，我们就可以获取一个符合自定义格式的时间格式存储到数据库了

总结： 

 注解@JsonFormat主要是**后台到前台的时间格式的转换**

 注解@DataFormAT主要是**前后到后台的时间格式的转换**