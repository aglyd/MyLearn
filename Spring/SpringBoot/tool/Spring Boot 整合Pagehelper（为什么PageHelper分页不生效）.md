# [Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）][https://blog.51cto.com/357712148/2381845?source=dra]



引入包
https://mvnrepository.com/artifact/com.github.pagehelper/pagehelper-spring-boot-starter/1.2.10

```html
<!--分页-->
        <!-- https://mvnrepository.com/artifact/com.github.pagehelper/pagehelper-spring-boot-starter -->
        <dependency>
            <groupId>com.github.pagehelper</groupId>
            <artifactId>pagehelper-spring-boot-starter</artifactId>
            <version>1.2.10</version>
        </dependency>

<!--需要注入容器中-->
		<dependency>
            <groupId>com.github.pagehelper</groupId>
            <artifactId>pagehelper</artifactId>
            <version>1.2.10</version>
        </dependency>
```

# 配置文件

==现 PageHelper若要在Springboot中使用 是需要进行注入的：==

==**使用Springboot PageHelper启动器包** 无需注入 开箱即用==

```java
import com.github.pagehelper.PageHelper;
import org.apache.ibatis.session.Configuration;
import org.mybatis.spring.boot.autoconfigure.ConfigurationCustomizer;
import org.springframework.context.annotation.Bean;
import java.util.Properties;


/**
 *配置文件
 * @author liwen406
 * @date 2019-04-20 12:14 2019-04-20 13:20
 */
@org.springframework.context.annotation.Configuration
public class MyBatisConfig {

    /**
     * 目的防止驼峰命名规则
     * @return
     */
    @Bean
    public ConfigurationCustomizer configurationCustomizer(){
        return new ConfigurationCustomizer(){

            @Override
            public void customize(Configuration configuration) {
                configuration.setMapUnderscoreToCamelCase(true);
            }
        };
    }

    /**
     * 分页插件
     * @return
     */
    @Bean
    public PageHelper pageHelper() {
        System.out.println("MyBatisConfiguration.pageHelper()");
        PageHelper pageHelper = new PageHelper();
        Properties p = new Properties();
        p.setProperty("offsetAsPageNum", "true");
        p.setProperty("rowBoundsWithCount", "true");
        p.setProperty("reasonable", "true");
        pageHelper.setProperties(p);
        return pageHelper;
    }
}
```

# dao mapper

```java
    @Select("SELECT * from tbl_emp")
    List<Employee> selectByExample(Employee example);
```

# Service

```java
   @Override
    public List<Employee> selectByExample() {

        return projectInfodao.selectByExample(null);
    }
```

# Controller

```java
    @GetMapping("/page/{start}/{end}")
    @ResponseBody
    public List<Employee> likeName(@PathVariable int start, @PathVariable int end) throws Exception {
        /*
         * 第一个参数：第几页;
         * 第二个参数：每页获取的条数.
         */
        PageHelper.startPage(start, end);
        return projectInfService.selectByExample();
    }
```



----------

[springboot整合PageHelper 过程中PageHelper.startPage(1,1)不生效问题][https://blog.csdn.net/weixin_43733952/article/details/90268127]

[SpringBoot项目中分页插件PageHelper无效的问题及解决方法][https://www.jb51.net/article/188328.htm]

[PageHelper获取数据总条数][https://blog.csdn.net/wangshuoxyy/article/details/102720141]



----

# [Mybatis分页插件PageHelper简单使用](https://www.cnblogs.com/qlqwjy/p/8442148.html)

### 1. 引入分页插件

引入分页插件有下面2种方式，推荐使用 Maven 方式。

#### 1). 引入 Jar 包

你可以从下面的地址中下载最新版本的 jar 包

- https://oss.sonatype.org/content/repositories/releases/com/github/pagehelper/pagehelper/
- http://repo1.maven.org/maven2/com/github/pagehelper/pagehelper/

由于使用了sql 解析工具，你还需要下载 jsqlparser.jar：

- http://repo1.maven.org/maven2/com/github/jsqlparser/jsqlparser/0.9.5/

#### 2). 使用 Maven

在 pom.xml 中添加如下依赖：

```xml
<dependency>
    <groupId>com.github.pagehelper</groupId>
    <artifactId>pagehelper</artifactId>
    <version>最新版本</version>
</dependency>
```

最新版本号可以从首页查看。

 

 

### 2. 配置拦截器插件

　　特别注意，新版拦截器是 `com.github.pagehelper.PageInterceptor`。 `com.github.pagehelper.PageHelper` 现在是一个特殊的 `dialect` 实现类，是分页插件的默认实现类，提供了和以前相同的用法。

```
<!--
    plugins在配置文件中的位置必须符合要求，否则会报错，顺序如下:
    properties?, settings?,
    typeAliases?, typeHandlers?,
    objectFactory?,objectWrapperFactory?,
    plugins?,
    environments?, databaseIdProvider?, mappers?
-->
<plugins>
    <!-- com.github.pagehelper为PageHelper类所在包名 -->
    <plugin interceptor="com.github.pagehelper.PageInterceptor">
        <!-- 使用下面的方式配置参数，后面会有所有的参数介绍 -->
        <property name="param1" value="value1"/>
    </plugin>
</plugins>
```



#### 2. 在 Spring 配置文件中配置拦截器插件

使用 spring 的属性配置方式，可以使用 `plugins` 属性像下面这样配置：

```
<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
  <!-- 注意其他配置 -->
  <property name="plugins">
    <array>
      <bean class="com.github.pagehelper.PageInterceptor">
        <property name="properties">
          <!--使用下面的方式配置参数，一行配置一个 -->
          <value>
            params=value1
          </value>
        </property>
      </bean>
    </array>
  </property>
</bean>
```

#### 3. 分页插件参数介绍

分页插件提供了多个可选参数，这些参数使用时，按照上面两种配置方式中的示例配置即可。

分页插件可选参数如下：

- `dialect`：默认情况下会使用 PageHelper 方式进行分页，如果想要实现自己的分页逻辑，可以实现 `Dialect`(`com.github.pagehelper.Dialect`) 接口，然后配置该属性为实现类的全限定名称。

**下面几个参数都是针对默认 dialect 情况下的参数。使用自定义 dialect 实现时，下面的参数没有任何作用。**

1. `helperDialect`：分页插件会自动检测当前的数据库链接，自动选择合适的分页方式。 你可以配置`helperDialect`属性来指定分页插件使用哪种方言。配置时，可以使用下面的缩写值：
   `oracle`,`mysql`,`mariadb`,`sqlite`,`hsqldb`,`postgresql`,`db2`,`sqlserver`,`informix`,`h2`,`sqlserver2012`,`derby`
   **特别注意：**使用 SqlServer2012 数据库时，需要手动指定为 `sqlserver2012`，否则会使用 SqlServer2005 的方式进行分页。
   你也可以实现 `AbstractHelperDialect`，然后配置该属性为实现类的全限定名称即可使用自定义的实现方法。
2. `offsetAsPageNum`：默认值为 `false`，该参数对使用 `RowBounds` 作为分页参数时有效。 当该参数设置为 `true` 时，会将 `RowBounds` 中的 `offset` 参数当成 `pageNum` 使用，可以用页码和页面大小两个参数进行分页。
3. `rowBoundsWithCount`：默认值为`false`，该参数对使用 `RowBounds` 作为分页参数时有效。 当该参数设置为`true`时，使用 `RowBounds` 分页会进行 count 查询。
4. `pageSizeZero`：默认值为 `false`，当该参数设置为 `true` 时，如果 `pageSize=0` 或者 `RowBounds.limit = 0` 就会查询出全部的结果（相当于没有执行分页查询，但是返回结果仍然是 `Page` 类型）。
5. `reasonable`：分页合理化参数，默认值为`false`。当该参数设置为 `true` 时，`pageNum<=0` 时会查询第一页， `pageNum>pages`（超过总数时），会查询最后一页。默认`false` 时，直接根据参数进行查询。
6. `params`：为了支持`startPage(Object params)`方法，增加了该参数来配置参数映射，用于从对象中根据属性名取值， 可以配置 `pageNum,pageSize,count,pageSizeZero,reasonable`，不配置映射的用默认值， 默认值为`pageNum=pageNum;pageSize=pageSize;count=countSql;reasonable=reasonable;pageSizeZero=pageSizeZero`。
7. `supportMethodsArguments`：支持通过 Mapper 接口参数来传递分页参数，默认值`false`，分页插件会从查询方法的参数值中，自动根据上面 `params` 配置的字段中取值，查找到合适的值时就会自动分页。 使用方法可以参考测试代码中的 `com.github.pagehelper.test.basic` 包下的 `ArgumentsMapTest` 和 `ArgumentsObjTest`。
8. `autoRuntimeDialect`：默认值为 `false`。设置为 `true` 时，允许在运行时根据多数据源自动识别对应方言的分页 （不支持自动选择`sqlserver2012`，只能使用`sqlserver`），用法和注意事项参考下面的**场景五**。
9. `closeConn`：默认值为 `true`。当使用运行时动态数据源或没有设置 `helperDialect` 属性自动获取数据库类型时，会自动获取一个数据库连接， 通过该属性来设置是否关闭获取的这个连接，默认`true`关闭，设置为 `false` 后，不会关闭获取的连接，这个参数的设置要根据自己选择的数据源来决定。

**重要提示：**

当 `offsetAsPageNum=false` 的时候，由于 `PageNum` 问题，`RowBounds`查询的时候 `reasonable` 会强制为 `false`。使用 `PageHelper.startPage` 方法不受影响。

 

 

**---------------------Maven项目mysql数据库没有集成Spring的测试---------------**

**0.目录结构:**

**![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180211151023060-388417171.png)**

 

**1.Exam在mysql表结构**

![img](https://images2017.cnblogs.com/blog/1196212/201802/1196212-20180211151059295-444005352.png)

 

**2.Exam.java与ExamExample.java是mybatis逆向工程导出来的:**

**3.ExamMapper.java是在导出来的基础上加了一个自己写的方法,对应mapper的xml也加了一个自己的实现:**

***\*ExamMapper.java自己手动加的一个方法:\****

```
    /**
     * 自己手写的一个根据名字模糊查询考试
     * @param name
     * @return
     */
    List<Exam> selectAllExamsByName(@Param("name")String name);
```

 

 ***\*ExamMapper.xml自己手动加的一个方法的实现:\****

```
  <!-- 自己手写的一个根据名字模糊查询考试   exam是扫描出来的别名 -->
  <select id="selectAllExamsByName" parameterType="string" resultType="exam">
      select * from exam where examName like '%${name}%'
  </select>
```

 

 

**4.SqlMapConfig.xml配置:(注意plugins的配置)**

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

    <!-- 加载属性文件 -->
    <properties resource="db.properties">
        <!--properties中还可以配置一些属性名和属性值 -->
        <!-- <property name="jdbc.driver" value=""/> -->
    </properties>
    <!-- 全局配置参数，需要时再设置 -->
    <!-- <settings> </settings> -->

    <!-- 别名定义 -->
    <typeAliases>

        <!-- 针对单个别名定义 type：类型的路径 alias：别名 -->
        <!-- <typeAlias type="cn.itcast.mybatis.po.User" alias="user"/> -->
        <!-- 批量别名定义 指定包名，mybatis自动扫描包中的po类，自动定义别名，别名就是类名（首字母大写或小写都可以） -->
        <package name="cn.xm.exam.bean.exam" />

    </typeAliases>

    <plugins>
        <!-- com.github.pagehelper为PageHelper类所在包名 -->
        <plugin interceptor="com.github.pagehelper.PageInterceptor">
            <!-- 使用下面的方式配置参数，后面会有所有的参数介绍 -->
            <property name="dialect" value="mysql"/>
        </plugin>
    </plugins>


    <!-- 和spring整合后 environments配置将废除 -->
    <environments default="development">
        <environment id="development">
            <!-- 使用jdbc事务管理，事务控制由mybatis -->
            <transactionManager type="JDBC" />
            <!-- 数据库连接池，由mybatis管理 -->
            <dataSource type="POOLED">
                <property name="driver" value="${jdbc.driver}" />
                <property name="url" value="${jdbc.url}" />
                <property name="username" value="${jdbc.username}" />
                <property name="password" value="${jdbc.password}" />
            </dataSource>
        </environment>
    </environments>
    <!-- 加载 映射文件 -->
    <mappers>
        <!-- 批量加载mapper 指定mapper接口的包名，mybatis自动扫描包下边所有mapper接口进行加载 遵循一些规范：需要将mapper接口类名和mapper.xml映射文件名称保持一致，且在一个目录 
            中 上边规范的前提是：使用的是mapper代理方法 -->
        <package name="cn.xm.exam.mapper" />

    </mappers>

</configuration>
```

 

**4.pom.xml配置以及项目中的jar包:**

**pom.xml**

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>cn.qlq</groupId>
    <artifactId>MybatisPagerHelper</artifactId>
    <version>0.0.1-SNAPSHOT</version>

    <build>
        <!-- 配置了很多插件 -->
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.5.1</version>
                <configuration>
                    <source>1.7</source>
                    <target>1.7</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
        </plugins>
    </build>


    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.9</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>servlet-api</artifactId>
            <version>2.5</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>jsp-api</artifactId>
            <version>2.0</version>
            <scope>provided</scope>
        </dependency>

        <!-- pageHelper -->
        <dependency>
            <groupId>com.github.pagehelper</groupId>
            <artifactId>pagehelper</artifactId>
            <version>5.1.0</version>
        </dependency>

        <!-- Mybatis -->
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.2.7</version>
        </dependency>
        
        <!-- mysql连接驱动包 -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.37</version>
        </dependency>
    </dependencies>

</project>
```



最终的jar包:

![img](https://images2017.cnblogs.com/blog/1196212/201802/1196212-20180211152319591-940810732.png)

 

**6.测试代码:**

```
package cn.xm.exam.daoTest;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import javax.print.Doc;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.junit.Before;
import org.junit.Test;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import cn.xm.exam.bean.exam.Exam;
import cn.xm.exam.bean.exam.ExamExample;
import cn.xm.exam.mapper.exam.ExamMapper;

public class PageHelperTest {

    private SqlSessionFactory sqlSessionFactory;

    @Before
    public void setUp() throws IOException {
        String resource = "SqlMapConfig.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
    }


    @Test
    public void test1() {
         SqlSession sqlSession = sqlSessionFactory.openSession();
         //创建ExamMapper对象
         ExamMapper examMapper = sqlSession.getMapper(ExamMapper.class);
         
         ExamExample examExample = new ExamExample();
         ExamExample.Criteria criteria = examExample.createCriteria();
         //只对紧邻的下一条select语句进行分页查询，对之后的select不起作用
         PageHelper.startPage(1,8);
         //上面pagehelper的设置对此查询有效，查到数据总共8条
        List<Exam> exams = examMapper.selectByExample(examExample);
        PageInfo<Exam> pageInfo = new PageInfo<>(exams);
        System.out.println("第一次查询的exams的大小:"+exams.size());
        for(Exam e:pageInfo.getList()){
            System.out.println(e);
        }
        System.out.println("分页工具类中数据量"+pageInfo.getList().size());
        System.out.println();
        System.out.println("---------------华丽的分割线------------");
        System.out.println();
        //第二次进行查询:上面pagehelper的设置对此查询无效（查询所有的数据86条）
        List<Exam> exams2 = examMapper.selectByExample(examExample);
        //总共86条
        System.out.println("第二次查询的exams2的大小"+exams2.size());
        
    }
    /**
     * 测试自己写的根据名称模糊查询考试
     */
    @Test
    public void test2() {
        SqlSession sqlSession = sqlSessionFactory.openSession();
        //创建examMapper对象
        ExamMapper examMapper = sqlSession.getMapper(ExamMapper.class);

        //只对紧邻的下一条select语句进行分页查询，对之后的select不起作用
        PageHelper.startPage(1,6);
        //上面pagehelper的设置对此查询有效，查到数据，总共6条
        List<Exam> exams = examMapper.selectAllExamsByName("厂级");
        PageInfo<Exam> pageInfo = new PageInfo<>(exams);
        System.out.println("第一次查询的exams的大小(受pageHelper影响):"+exams.size());
        for(Exam e:pageInfo.getList()){
            System.out.println(e);
        }
        System.out.println("分页工具类中数据量"+pageInfo.getList().size());
        System.out.println();
        System.out.println("---------------华丽的分割线------------");
        System.out.println();
         //第二次进行查询:上面pagehelper的设置对此查询无效（查询所有的数据34条）
        List<Exam> exams2 = examMapper.selectAllExamsByName("厂级");
        System.out.println("第二次查询的exams2的大小(不受pageHelper影响)"+exams2.size());
        
    }
}
```



运行结果:

test1:

![img](https://images2017.cnblogs.com/blog/1196212/201802/1196212-20180211152504545-2017586297.png)

 

 

test2：

![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180211152529638-1086326366.png)

 

 

 

**debugger打断点查看PageInfo的信息:(也就是将来在开发过程中直接返回PageInfo对象就可以将分页所需要的全部参数携带到前台)**

**![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180211152806701-374063052.png)**

 

 

 **总结:**

　　**使用也简单，大致就是导包，两个包(pagehelper和jsqlparser)，然后在配置文件中引入插件,最后在代码中使用，使用方法可以简化成如下:**

```
        //只对紧邻的下一条select语句进行分页查询，对之后的select不起作用
        PageHelper.startPage(1,6);
        //上面pagehelper的设置对此查询有效，查到数据，总共6条
        List<Exam> exams = examMapper.selectAllExamsByName("厂级");
        PageInfo<Exam> pageInfo = new PageInfo<>(exams);
```

　　　exams就是分页查出的数据，最后将数据存入pageInfo的list中，pageInfo中就是分页的全部信息，可以直接返回到页面进行显示。

 

 

 

**---------------------Maven项目mysql数据库集成Spring的测试---------------**

**0.添加spring 的包**

**pom.xml**

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>cn.qlq</groupId>
    <artifactId>MybatisPagerHelper</artifactId>
    <version>0.0.1-SNAPSHOT</version>

    <build>
        <!-- 配置了很多插件 -->
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.5.1</version>
                <configuration>
                    <source>1.7</source>
                    <target>1.7</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
        </plugins>
    </build>


    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.9</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>servlet-api</artifactId>
            <version>2.5</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>jsp-api</artifactId>
            <version>2.0</version>
            <scope>provided</scope>
        </dependency>

        <!-- pageHelper -->
        <dependency>
            <groupId>com.github.pagehelper</groupId>
            <artifactId>pagehelper</artifactId>
            <version>5.1.2</version>
        </dependency>

        <!-- Mybatis -->
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.2.7</version>
        </dependency>
        <dependency>
            <groupId>cglib</groupId>
            <artifactId>cglib</artifactId>
            <version>2.2.2</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-spring</artifactId>
            <version>1.2.1</version>
        </dependency>
        <!-- mysql连接驱动包 -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.37</version>
        </dependency>
        <!-- Spring -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-beans</artifactId>
            <version>4.2.4.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>4.2.4.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <version>4.2.4.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-tx</artifactId>
            <version>4.2.4.RELEASE</version>
        </dependency>
        <!-- DBCP连接池 -->
        <dependency>
            <groupId>commons-dbcp</groupId>
            <artifactId>commons-dbcp</artifactId>
            <version>1.3</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
            <version>4.2.4.RELEASE</version>
        </dependency>
    </dependencies>

    <!-- spring -->



</project>
```



**1.修改mybatis主配置文件:**

**SqlMapConfig2.xml**

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <!-- 设置别名 -->
    <typeAliases>
        <!-- 2. 指定扫描包，会把包内所有的类都设置别名，别名的名称就是类名，大小写不敏感 -->
        <package name="cn.xm.exam.bean.exam" />
    </typeAliases>

</configuration>
```



**2.增加spring配置文件**

**applicationContext.xml**

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:context="http://www.springframework.org/schema/context" xmlns:p="http://www.springframework.org/schema/p"
    xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.0.xsd
    http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.0.xsd
    http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-4.0.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.2.xsd
    http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util-4.0.xsd">


    <context:property-placeholder location="classpath:db.properties" />

    <!-- 数据库连接池 -->
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource"
        destroy-method="close">
        <property name="driverClassName" value="${jdbc.driver}" />
        <property name="url" value="${jdbc.url}" />
        <property name="username" value="${jdbc.username}" />
        <property name="password" value="${jdbc.password}" />
        <property name="maxActive" value="10" />
        <property name="maxIdle" value="5" />
    </bean>

    <!-- Mybatis的工厂 -->
    <bean id="sqlSessionFactoryBean" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource" />
        <!-- 核心配置文件的位置 -->
        <property name="configLocation" value="classpath:SqlMapConfig2.xml" />
        <!-- 注意其他配置 -->
        <property name="plugins">
            <array>
                <bean class="com.github.pagehelper.PageInterceptor">
                    <property name="properties">
                        <!--使用下面的方式配置参数，一行配置一个 -->
                        <value>
                            helperDialect=mysql
                             reasonable=true
                        </value>
                    </property>
                </bean>
            </array>
        </property>
    </bean>

    <!-- Mapper动态代理开发 扫描 -->
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <!-- 基本包 -->
        <property name="basePackage" value="cn.xm.exam.mapper" />
    </bean>
</beans>
```



　　注意上面黄色背景的配置:(用helperDialect=mysql,用dialect=mysql会报错)

**3.最终配置文件结构:**

![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180211161613966-1277717760.png)

 

 **4.spring-junit测试;**

```
package cn.xm.exam.daoTest;

import java.util.List;

import javax.annotation.Resource;

import org.apache.ibatis.session.SqlSession;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import cn.xm.exam.bean.exam.Exam;
import cn.xm.exam.bean.exam.ExamExample;
import cn.xm.exam.mapper.exam.ExamMapper;

/**
 * 与spring集成的mybatis的分页插件pagehelper的测试
 * @author liqiang
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class PageHelperTestWithSpring {
    
    @Resource
    private ExamMapper examMapper;

    @Test
    public void test1() {
         //创建ExamMapper对象
         ExamExample examExample = new ExamExample();
         ExamExample.Criteria criteria = examExample.createCriteria();
         //只对紧邻的下一条select语句进行分页查询，对之后的select不起作用
         PageHelper.startPage(1,8);
         //上面pagehelper的设置对此查询有效，查到数据总共8条
        List<Exam> exams = examMapper.selectByExample(examExample);
        PageInfo<Exam> pageInfo = new PageInfo<>(exams);
        System.out.println("第一次查询的exams的大小:"+exams.size());
        for(Exam e:pageInfo.getList()){
            System.out.println(e);
        }
        System.out.println("分页工具类中数据量"+pageInfo.getList().size());
        System.out.println();
        System.out.println("---------------华丽的分割线------------");
        System.out.println();
        //第二次进行查询:上面pagehelper的设置对此查询无效（查询所有的数据86条）
        List<Exam> exams2 = examMapper.selectByExample(examExample);
        //总共86条
        System.out.println("第二次查询的exams2的大小"+exams2.size());
        
    }
    @Test
    public void test2() {
        //创建ExamMapper对象
        ExamExample examExample = new ExamExample();
        ExamExample.Criteria criteria = examExample.createCriteria();
        //只对紧邻的下一条select语句进行分页查询，对之后的select不起作用
        PageHelper.startPage(1,8);
        //上面pagehelper的设置对此查询有效，查到数据总共8条
        List<Exam> exams = examMapper.selectAllExamsByName("厂级");
        PageInfo<Exam> pageInfo = new PageInfo<>(exams);
        System.out.println("第一次查询的exams的大小:"+exams.size());
        for(Exam e:pageInfo.getList()){
            System.out.println(e);
        }
        System.out.println("分页工具类中数据量"+pageInfo.getList().size());
        System.out.println();
        System.out.println("---------------华丽的分割线------------");
        System.out.println();
        //第二次进行查询:上面pagehelper的设置对此查询无效（查询所有的数据86条）
        List<Exam> exams2 = examMapper.selectAllExamsByName("厂级");
        //总共86条
        System.out.println("第二次查询的exams2的大小"+exams2.size());
        
    }
}
```

 

结果:

test1：

![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180211161800013-1448216051.png)

 

 

 

 test2:

![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180211161840060-1841900893.png)

 

 

 

**总结:**

　　**在spring中配置pagehelper插件的时候要用helperDialect=mysql,用dialect=mysql会报错**

 

 

**git源码地址:https://github.com/qiao-zhi/MybatisPageHelper**

 

 

 

**自己项目中的一个例子:(Spring+Struts2+Mybatis)**

**Mapper接口**

 

```
public interface TraincontentCustomMapper {
    List<Map<String,Object>> selectTraincontentWithFYCondition(Map map);

}
```

 

 

 

**Mapper实现(只用写查询，不用写分页)**

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="cn.xm.exam.mapper.trainContent.custom.TraincontentCustomMapper">
    <!-- lixianyuan 9/19 start -->
    <!-- 分页查询:根据组合条件进行分页查询 -->
    <select id="selectTraincontentWithFYCondition" parameterType="map"
        resultType="map">
        select documentid,departmentid,documentname,traintype,departmentname,knowledgetype,originalname,currentname,
            uptime,size,employeename,level,description,browsetimes,typeid,typename
         from traincontent,traincontenttype
        <where>
            <if test="1 == 1">
                and traincontent.knowledgeType = traincontenttype.typeid
            </if>
            <if test="documentName!=null &amp;&amp; documentName!=''">
                and documentName like
                concat(concat('%',#{documentName}),'%')
            </if>
            <if test="departmentName!=null  &amp;&amp; departmentName!='' ">
                and departmentName like concat(concat('%',#{departmentName}),'%')
            </if>
            <if test="typeId != null">
                and knowledgeType = #{typeId}
            </if>
        </where>
        order by upTime desc
    </select>
</mapper> 
```

 

**Service接口:**

 

```
List<Map<String,Object>> selectTraincontentWithFYCondition(Map map) throws Exception;
```

 

 

 

**ServiceImpl实现上面方法:**

```
    @Override
    public List<Map<String,Object>> selectTraincontentWithFYCondition(Map map) throws Exception {
        List<Map<String,Object>> trainContentList = traincontentCustomMapper.selectTraincontentWithFYCondition(map);
        if (trainContentList!=null) {
            return trainContentList;
        } else {
            return null;
        }
    }
```

 

 

**Action实现分页查询:**

```
    private String documentName;//文档名称
    private String departmentName;//部门名称
    private String typeId;//类别编号
    
    /**
     * 根据资料名称、所属部门、资料级别、知识点、当前页页号、每页显示记录数进行分页查询
     * 
     * @return
     * @throws Exception
     */
    public String findTrainByFYCondiction() throws Exception {
        map = new LinkedHashMap<String, Object>();
        // 封装查询条件
        Map<String,Object> condition = new HashMap<String,Object>();//封装条件的map
        if(ValidateCheck.isNotNull(documentName)){
            condition.put("documentName", documentName);
        }
        if(ValidateCheck.isNotNull(departmentName)){
            condition.put("departmentName", departmentName);
        }
        if(ValidateCheck.isNotNull(typeId)){
            condition.put("typeId", typeId);
        }
        int current_page = Integer.parseInt(currentPage);//当前页
        int current_total = Integer.parseInt(currentTotal);//页大小
        /******S    PageHelper分页*********/
        PageHelper.startPage(current_page,current_total);//开始分页
        List<Map<String,Object>> traincontentList = traincontentService.selectTraincontentWithFYCondition(condition);
        PageInfo<Map<String,Object>> pageInfo = new PageInfo<>(traincontentList);
        /******E    PageHelper分页*********/
        
        map.put("pageInfo", pageInfo);
        
        return "ok";
    }
```

 

 

**传到前台的JSON数据:**

**![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180308135422669-1721977295.png)**

 

 

 

 

 

 

**补充:pageHelper也可以设置排序类别:**

例如:

**数据库数据:**

**![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180313112728048-1123259888.png)**

 

 

**Mapper配置:**

```
    @Select("select * from user")
    public List<User> findUsersByPage() throws SQLException;
```

 

-  (1)根据id升序取3条

**Action设置根据id升序排序，取3条**

```
    public String findPage() throws Exception {
        response = new HashMap();
        // 第三个参数代表排序方式
        PageHelper.startPage(1, 3, "id");
        List<User> users = userService.findUsersByPage();
        response.put("users", users);
        return "success";
    }
```

 

 

查看startPage(1, 3, "id")源码:

```
    /**
     * 开始分页
     *
     * @param pageNum  页码
     * @param pageSize 每页显示数量
     * @param orderBy  排序
     */
    public static <E> Page<E> startPage(int pageNum, int pageSize, String orderBy) {
        Page<E> page = startPage(pageNum, pageSize);
        page.setOrderBy(orderBy);
        return page;
    }
```

 

 

**测试:**

![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180313112955669-2133950858.png)

 

 **查看日志:**

```
11:25:02,938 DEBUG findUsersByPage:132 - ==>  Preparing: SELECT * FROM user order by id LIMIT ? 
11:25:02,939 DEBUG findUsersByPage:132 - ==> Parameters: 3(Integer)
11:25:02,941 TRACE findUsersByPage:138 - <==    Columns: id, name
11:25:02,941 TRACE findUsersByPage:138 - <==        Row: 1, QLQ
11:25:02,943 TRACE findUsersByPage:138 - <==        Row: 2, QLQ2
11:25:02,943 TRACE findUsersByPage:138 - <==        Row: 3, QLQ3
```

 

 

- (2)根据id降序取第二页，每页2条

**Action配置:**

```
    public String findPage() throws Exception {
        response = new HashMap();
        // 第三个参数代表排序方式
        PageHelper.startPage(2, 2, "id desc");
        List<User> users = userService.findUsersByPage();
        response.put("users", users);
        return "success";
    }
```



 

 **测试:**

![img](Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）.assets/1196212-20180313113549826-1074893338.png)

 

**查看sql日志:**

```
11:35:36,307 DEBUG findUsersByPage:132 - ==>  Preparing: SELECT * FROM user order by id desc LIMIT ?, ? 
11:35:36,308 DEBUG findUsersByPage:132 - ==> Parameters: 2(Integer), 2(Integer)
11:35:36,309 TRACE findUsersByPage:138 - <==    Columns: id, name
11:35:36,310 TRACE findUsersByPage:138 - <==        Row: 3, QLQ3
11:35:36,311 TRACE findUsersByPage:138 - <==        Row: 2, QLQ2
```