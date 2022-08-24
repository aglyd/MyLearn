# [【Mybatis】useGeneratedKeys参数用法及遇到的问题](https://blog.csdn.net/Mrerlou/article/details/117569882)

## 什么是useGeneratedKeys？

官方的说法是该参数的作用是：“允许JDBC支持自动生成主键，需要驱动兼容”，如何理解这句话的意思？

其本意是说：对于支持自动生成记录主键的数据库，如：MySQL，SQL Server，此时设置useGeneratedKeys参数值为true，在执行添加记录之后可以获取到数据库自动生成的主键ID。

## 如何使用？

可以通过如下的方式来实现配置：

- 配置全局的配置文件

- 在xml映射器中配置useGeneratedKeys参数

- 在接口映射器中设置useGeneratedKeys参数

  

## 一、配置全局的配置文件

1、application.yml 配置文件

```yaml
# MyBatis配置
mybatis:
    # 搜索指定包别名
    typeAliasesPackage: com.ruoyi.**.domain
    # 配置mapper的扫描，找到所有的mapper.xml映射文件
    mapperLocations: classpath*:mapper/**/*Mapper.xml
    # 加载全局的配置文件
    configLocation: classpath:mybatis/mybatis-config.xml
```

2、配置mybatis config文件

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210604183008937.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01yZXJsb3U=,size_16,color_FFFFFF,t_70)

3、mybatis-config.xml

文件内容如下：


```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	
	<settings>
		<setting name="cacheEnabled"             value="true" />  <!-- 全局映射器启用缓存 -->
		<setting name="useGeneratedKeys"         value="true" />  <!-- 允许 JDBC 支持自动生成主键 -->
		<setting name="defaultExecutorType"      value="REUSE" /> <!-- 配置默认的执行器 -->
		<setting name="logImpl"                  value="SLF4J" /> <!-- 指定 MyBatis 所用日志的具体实现 -->
<!--		<setting name="mapUnderscoreToCamelCase" value="true"/> &lt;!&ndash; 驼峰式命名 &ndash;&gt;-->
	</settings>
	
</configuration>
```
另外，**==在配置文件settings元素中设置的全局useGeneratedKeys参数对于xml映射器sql无效==**。如果希望在xml映射器sql中执行添加记录之后返回主键ID，则必须在xml映射器中明确设置useGeneratedKeys参数值为true。

## 二、在xml映射器中配置useGeneratedKeys参数

### 1、Mapper.xml 文件

```xml
<insert id="addBigdataGroup" parameterType="BigdataGroup" useGeneratedKeys="true" keyProperty="groupId" keyColumn="group_id">
        insert into bigdata_group (
        group_id, group_name, comment, business_line, create_by, remark, create_time)
        values(#{groupId}, #{groupName}, #{comment}, #{businessLine}, #{createBy}, #{remark}, sysdate() );
</insert>
```

- parameterType 传入参数类型
- keyProperty JAVA属性
- keyColumn 数据库字段

> xml映射器中配置的useGeneratedKeys参数只会对xml映射器产生影响，且在settings元素中设置的全局useGeneratedKeys参数值对于xml映射器不产生任何作用。

## 三、在接口映射器中设置useGeneratedKeys参数

/设置useGeneratedKeys为true，返回数据库自动生成的记录主键id

```java
@Options(useGeneratedKeys = true, keyProperty = "id", keyColumn = "id")
@Insert("insert into test(name,descr,url,create_time,update_time) values(#{name},#{descr},#{url},now(),now())")
Integer insertOneTest(Test test);
```

> 注意： 在接口映射器中设置的useGeneratedKeys参数会覆盖在元素中设置的对应参数值。

## 遇到的问题

当我配置好获取主键ID后，但是返回的结果，并没有如预期的一样返回新插入数据库row的主键真实的数据。而是1。

代码如下：

1、Mybatis层

```java
import java.util.List;

public interface BigdataMapper {

    List<BigdataGroup> getBigdataGroup();

    int addBigdataGroup(BigdataGroup bigdataGroup);
}
```
2、service层

```java
public int addBigdataGroup(BigdataGroup bigdataGroup) {
        bigdataGroup.setCreateBy(SecurityUtils.getUsername());

        int update = bigdataMapper.addBigdataGroup(bigdataGroup);
        log.info("update: {}", update);
        return update;
    }
```
3、xml文件

```sql
<insert id="addBigdataGroup" parameterType="BigdataGroup" useGeneratedKeys="true" keyProperty="groupId" keyColumn="group_id">
        insert into bigdata_group (
        group_id, group_name, comment, business_line, create_by, remark, create_time)
        values(#{groupId}, #{groupName}, #{comment}, #{businessLine}, #{createBy}, #{remark}, sysdate() );
    </insert>
```

打印结果

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210604184623353.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01yZXJsb3U=,size_16,color_FFFFFF,t_70)

按理说返回结果应该为插入主键的真实数据，但是结果却是返回是1。

注意：**==原来真正的id已经被注入到传参对象的主键对应属性里==**了，只需要使用插入语句的入参对象的get方法即可获取到正确的自增id。

如这边获取新增数据的主键值，那么只需要获取对象主键对应的主键值就好了。

代码修改：

```java
public int addBigdataGroup(BigdataGroup bigdataGroup) {
        bigdataGroup.setCreateBy(SecurityUtils.getUsername());

        int update = bigdataMapper.addBigdataGroup(bigdataGroup);
        log.info("update: {}", update);
        // 新增如下代码
        int group_id = bigdataGroup.getGroupId();
        log.info("group_id: {}", group_id);
        // 到此为止
        return update;
    }
```

观察结果：

![在这里插入图片描述](https://img-blog.csdnimg.cn/2021060418495266.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01yZXJsb3U=,size_16,color_FFFFFF,t_70)





-----

使用useGeneratedKeys生成主键时

　　（1）如果在DAO层使用@Param注解传递参数，则 keyProperty 属性 需要通过 “param注解的名称.主键id” 的格式，否则无法返回主键。

如：

mapper.java

```java
public int insertUser(@Param("user")User user);
```

mapper.xml

```xml
<insert id="insertUser" parameterType="com.example.download1.entity.User" useGeneratedKeys="true" keyProperty="user.id" keyColumn="id">
        insert into user(name) values (#{user.name})
    </insert>
```



　　（2）如果在DAO层只有单个参数传递（不需要使用@Param注解穿传递参数），则 keyProperty 属性可以直接 = “主键id” 来返回主键。

mapper.java

```java
public int insertUser(User user);
```

mapper.xml

```xml
<insert id="insertUser" parameterType="com.example.download1.entity.User" useGeneratedKeys="true" keyProperty="id" keyColumn="id">
        insert into user(name) values (#{name})
    </insert>
```

