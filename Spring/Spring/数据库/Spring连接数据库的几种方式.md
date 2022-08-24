# [Spring连接数据库的几种常用的方式](https://blog.csdn.net/weixin_30266885/article/details/96682481)

测试主类为:

```java
package myspring2;
 
import java.sql.*;
 
import javax.sql.DataSource;
 
import org.springframework.context.ApplicationContext;
 
import org.springframework.context.support.ClassPathXmlApplicationContext;
 
public class MySpringTest {
 
  public static void main(String args[]) throws Exception{  
 
    ApplicationContext ctx=new ClassPathXmlApplicationContext("applicationContext.xml");   
 
   DataSource dataSource=ctx.getBean("dataSource",DataSource.class);
 
     String sql="select * from user_inf";    
 
  Connection connection=dataSource.getConnection();  
 
    Statement stm=connection.createStatement();    
 
  ResultSet rs=stm.executeQuery(sql);  
 
    while(rs.next())     
 
{       System.out.println("用户名为:");  
 
     System.out.println(rs.getString(2));  
 
    }                   
 
}
 
 
 
}
```

## 第一种：使用spring自带的DriverManagerDataSource   配置文件如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>  
 
<beans xmlns="http://www.springframework.org/schema/beans"
 
  xmlns:aop="http://www.springframework.org/schema/aop"
 
xmlns:tx="http://www.springframework.org/schema/tx"
 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 
xmlns:context="http://www.springframework.org/schema/context"  
 
xmlns:p="http://www.springframework.org/schema/p"
 
  xsi:schemaLocation=" 
          http://www.springframework.org/schema/beans     
       http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
           http://www.springframework.org/schema/tx       
     http://www.springframework.org/schema/tx/spring-tx-3.0.xsd
           http://www.springframework.org/schema/context
           http://www.springframework.org/schema/context/spring-context-3.0.xsd
           http://www.springframework.org/schema/aop
           http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
 
 <!-- 使用XML Schema的p名称空间配置 -->
 
  <bean name="dataSource"  class="org.springframework.jdbc.datasource.DriverManagerDataSource"  
 
  p:driverClassName="com.mysql.jdbc.Driver"  
 
  p:url="jdbc:mysql://localhost:3306/test"
 
  p:username="root"
 
  p:password="123456"  / >  
 
  <!-- 或者采用property的普通配置 相比之下有点麻烦,但是效果是一样的哦,-->
 
<!--     
 
  <bean name="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">  
 
    <property name="driverClassName"  value="com.mysql.jdbc.Driver" />
 
     <property name="url" value="jdbc:mysql://localhost:3306/test" />
 
     <property name="username" value="root" />
 
     <property name="password" value="123456" />
 
    </bean>
 
    -->       
 
</beans>
```

## 第二种：C3P0数据源。

需要使c3p0的核心jar包，我使用的是c3p0-0.9.1.jar,比较稳定，推荐使用。一般在下载hibernate的时候都会自带一个： 我在hibernate-release-4.3.0.Final\lib\optional\c3p0路径下找到的。

配置文件中如下：

```xml
<?xml version="1.0" encoding="UTF-8"?> 
 
<beans xmlns="http://www.springframework.org/schema/beans"
 
  xmlns:aop="http://www.springframework.org/schema/aop"
 
xmlns:tx="http://www.springframework.org/schema/tx"
 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 
xmlns:context="http://www.springframework.org/schema/context" 
 
xmlns:p="http://www.springframework.org/schema/p"
 
  xsi:schemaLocation="
          http://www.springframework.org/schema/beans    
       http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
            http://www.springframework.org/schema/tx      
     http://www.springframework.org/schema/tx/spring-tx-3.0.xsd
           http://www.springframework.org/schema/context
            http://www.springframework.org/schema/context/spring-context-3.0.xsd
           http://www.springframework.org/schema/aop
            http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
 
  <!-- 使用XML Schema的p名称空间配置   -->
 
<bean name="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource"  
 
   p:driverClass="com.mysql.jdbc.Driver"  
 
   p:jdbcUrl="jdbc:mysql://localhost:3306/test"
 
   p:user="root"
 
   p:password="123456" >       
 
</bean>    
 
<!-- 或采用property的普通配置 相比之下有点麻烦,但是效果是一样的哦 建议使用上面的-->
 
<!--       <bean name="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">  
 
            <property name="driverClass"  value="com.mysql.jdbc.Driver" />    
 
            <property name="jdbcUrl" value="jdbc:mysql://localhost:3306/test" />
 
            <property name="user" value="root" />
 
            <property name="password" value="123456" />
 
            </bean>
 
  -->    
 
  </beans>
```

## 第三种:使用apache的dbcp插件连接数据库 

需要下载的jar包：commons-dbcp.jar，commons-pool.jar,commons-collection.jar

 spring的配置文件中如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>  
 
<beans xmlns="http://www.springframework.org/schema/beans"  
 
xmlns:aop="http://www.springframework.org/schema/aop"
 
xmlns:tx="http://www.springframework.org/schema/tx"
 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 
xmlns:context="http://www.springframework.org/schema/context"
 
  xmlns:p="http://www.springframework.org/schema/p"  
 
xsi:schemaLocation="        
   http://www.springframework.org/schema/beans  
     http://www.springframework.org/schema/beans/spring-beans-3.0.xsd    
        http://www.springframework.org/schema/tx     
       http://www.springframework.org/schema/tx/spring-tx-3.0.xsd    
        http://www.springframework.org/schema/context  
          http://www.springframework.org/schema/context/spring-context-3.0.xsd
           http://www.springframework.org/schema/aop  
          http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
 
 <!-- 使用XML Schema的p名称空间配置 -->
 
   <bean name="dataSource" class="org.apache.commons.dbcp.BasicDataSource"
 
  p:driverClassName="com.mysql.jdbc.Driver"  
 
p:url="jdbc:mysql://localhost:3306/test"
 
  p:username="root"
 
  p:password="123456" >  
 
</bean>
 
 
 
    <!-- 或采用property的普通配置 相比之下有点麻烦,但是效果是一样的哦 建议使用上面的-->
 
<!--       <bean name="dataSource" class="org.apache.commons.dbcp.BasicDataSource">  
 
    <property name="driverClassName"  value="com.mysql.jdbc.Driver" />    
 
  <property name="url" value="jdbc:mysql://localhost:3306/test" />
 
     <property name="username" value="root" />  
 
    <property name="password" value="123456" />  
 
    </bean>
 
   -->    
 
  </beans>
```

## 第四种：使用hibernate数据源

  需要hiberante核心jar包，我使用的hibernate1的版本是hibernate-release-4.3.0.Final  

目前三大框架较流行，spring一般与hiberante做搭档，数据库连接方式写在hiberante的配置文件中，在spring管理hibernate中的配置文件中，直接读取hibernate核心配置文件即可。在使用hibernate连接数据库的时候需要读取hibernate.cfg.xml的配置文件和相应的实体类，

读者可参照下面的自己配置一下

```xml
<bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean"> 
 
 <property name="configLocations"> 
 
   <list> 
 
      <value>classpath:com/config/hibernate.cfg.xml</value> 
 
   </list> 
 
 </property> 
 
    <property name="mappingLocations">  
 
<!-- 所有的实体类映射文件 --> 
 
        <list> 
 
            <value>classpath:com/hibernate/*.hbm.xml</value> 
 
        </list> 
 
</property>
```





# [Spring 中使用 MyBatis](https://www.cnblogs.com/jwen1994/p/11300560.html)

使用 MyBatis 提供的 ORM 机制，对业务逻辑实现人员而言，面对的是纯粹的 Java 对象，这一点与使用 Hibernate 框架基本一致。对于具体的数据操作，Hibernate 会自动生成 SQL 语句，而 MyBatis 则要求开发者编写具体的 SQL 语句。相对于 Hibernate 等“全自动”的 ORM 机制而言，MyBatis 在 SQL 开发的工作量和数据库移植性上做出了让步，为数据持久化操作提供了更大的自由空间。相对于“全自动”的 ORM 实现方案来说，MyBatis 的出现显得别有创意。

2010年5月，iBATIS 更名为 MyBatis 并迁移到 Google Code，可以把 MyBatis 看作 iBatis 3.0。从公告上可以看出，开发团队想脱离 Apache 基金会寻求独立发展。开发团队保证不会修改授权协议（Apache License）、代码完全兼容、包名不会更改、不会删除 Apache 站上的任何资源。

由于 Spring 越来越成为 Java 事实标准的技术框架，因此 MyBatis 团队开发出整合类，可以让开发者直接在 Spring 中使用 MyBatis。因此，Spring 4.0 移除了对 iBatis 的直接支持，Spring 更乐于让第三方框架自身提供整合支持。

事务管理可以由 Spring 标准机制进行处理。对于 MyBatis 来说，没有特别的事务策略，除了 JDBCConnection 外，也没有特别的事务资源。它和 Spring JDBC 事务管理的方式完全一致，采用和 Spring JDBC 相同的 DataSourceTransactionManager 事务管理器。

 

## 1.配置 SqlMapClient

每个 MyBatis 的应用程序都以一个 SqlSessionFactory 对象的实例为核心。SqlSessionFactory 对象的实例可以通过 SqlSessionFactoryBuilder 对象来获得。SqlSessionFactoryBuilder 对象可以从 XML 配置文件或 Configuration 类的实例中构建 SqlSessionFactory 对象。

和 Hibernate 相似，MyBatis 拥有多个 SQL 映射文件，并通过一个配置文件对这些 SQL 映射文件进行装配，同时在该文件中定义一些控制属性的信息。下面是一个简单的 MyBatis 配置文件，如下面代码所示。

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
    PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>①
        <setting name="lazyLoadingEnabled" value="false" />
    </settings>
    <typeAliases>②
        <typeAlias alias="Forum" type="com.smart.domain.Forum" />
        <typeAlias alias="Topic" type="com.smart.domain.Topic" />
        <typeAlias alias="Post" type="com.smart.domain.Post" />
    </typeAliases>
    <mappers>③
        <mapper resource="com/smart/orm/domain/mybatis/Forum.xml"/>
        <mapper resource="com/smart/orm/domain/mybatis/Topic.xml"/>
        <mapper resource="com/smart/orm/domain/mybatis/Post.xml"/>
    </mappers>
</configuration>
```

在①处提供可控制 MyBatis 框架运行行为的属性信息。在②处定义全限定类名的别名，在映射文件中可以通过别名代替具体的类名，简化配置。在③处将 MyBatis 的所有映射文件组装起来。

在③处通过 <mappers> 标签引用了3个 SQL 映射文件，下面来了解一下其中的 Forum.xml 文件，如下面代码所示。

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.smart.dao.mybatis.ForumMybatisDao">①
  <select id="getForum" resultType="Forum" parameterType="int" >②
        SELECT 
         forum_id  forumId,
         forum_name  forumName,
         forum_desc  forumDesc
        FROM t_forum 
        WHERE forum_id = #{forumId}
  </select>
   ...
  <insert id="addForum" parameterType="Forum">③
        INSERT INTO t_forum(forum_id,forum_name,forum_desc)
        VALUES(#{forumId},#{forumName}, #{forumDesc})
  </insert>
  <update id="updateForum" parameterType="Forum">④
        UPDATE t_forum f
        SET forum_name=#{forumName},forum_desc=#{forumDesc}
        WHERE f.forum_id = #{forumId}
  </update>
</mapper>
```

该文件定义了对 Forum 实体类进行数据操作时所需的 SQL 语句，同时还定义了查询结果和对象属性的映射关系。在①处指定了映射所在的命名空间，每个具体的映射项都有一个 id，可以通过命名空间和映射项的 id 定位到具体的映射项。如通过如下语句可以调用 getForum 的映射语句：

```
SqlSession session = sqlSessionFactory.openSession();
try {
    Forum forum = (Employee) session.selectOne(
            "com.smart.dao.mybatis.ForumMybatisDao", 1);
} finally {
    session.close();
}
```

在②、③和④处分别定义了一条 SELECT、INSERT 及 UPDATE 语句映射项，映射项的 parameterType 指定传入的参数对象，可以是全限定名的类，也可以是类的别名，类的别名在 MyBatis 的主配置文件中定义。如果映射项的入参是基础类型或 String 类型，则可以使用如 int、long、String 的基础类型名。SELECT 映射项拥有返回类型对象，通过 resultType 指定。在映射项中通过 #{xxx} 绑定 parameterType 指定参数类的属性，支持级联属性，如 #{topic.forumld}。

 

## 2.在 Spring 中配置 MyBatis

可以使用 MyBatis 提供的 mybatis-spring 整合类包实现 Spring 和 MyBatis 的整合，从功能上来说，mybatis-spring 完全符合 Spring 的风格。要在 Spring 中整合 MyBatis，必须将 mybatis-spring 构件添加到 pom.xml 中，如下面代码所示。

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<beans ...>

    <context:component-scan base-package="com.smart.dao.mybatis"/>
    <context:component-scan base-package="com.smart.service.mybatis"/>
    <context:property-placeholder location="classpath:jdbc.properties"/>
    
    <bean id="dataSource"
          class="org.apache.commons.dbcp.BasicDataSource"
          destroy-method="close"
          p:driverClassName="com.mysql.jdbc.Driver"
          p:url="jdbc:mysql://localhost:3306/sampledb"
          p:username="root"
          p:password="123456"/>

    <bean id="sqlSessionFactory"
          class="org.mybatis.spring.SqlSessionFactoryBean"  ①
          p:dataSource-ref="dataSource"
          p:configLocation="classpath:myBatisConfig.xml"/>  ②

</beans>
```

mybatis-spring 类包提供了一个 SqlSessionFactoryBean，以便通过 Spring 风格创建 MyBatis 的  SqlSessionFactory，如①处所示。只需注入数据源并指定 MyBatis 的总装配置文件就可以了，如②处所示。

**如果在 MyBatis 的==总装配置文件 mybatisConfig.xml 中指定了 SQL 映射文件，则必须逐个列出所有的 SQL 映射文件，比较烦琐。==是否可以像 Spring 加载 Hibernate 映射文件一样按资源路径匹配规则扫描式加载呢？答案是肯定的。SqlSessionFactoryBean 提供了 ==mapperLocations 属性，支持扫描式加载 SQL 映射文件。==**

首先将映射文件匹配从 mybatisConfig.xml 中移除，然后通过如下便捷方式加载 SQL 映射文件：

```xml
<bean id="sqlSessionFactory"
　　　　class="org.mybatis.spring.SqlSessionFactoryBean"
　　　　p:dataSource-ref="dataSource"
　　　　p:configLocation="classpath:myBatisConfig.xml"      
　　　　p:mapperLocations="classpath:com/smart/domain/mybatis/*.xml"/>
```

这样，SqlSessionFactoryBean 将扫描 com/smart/orm/domain/mybatis 类路径并加载所有以 .xml 为后缀的映射文件。

 

## 3.编写 MyBatis 的 DAO

### 1）使用 SqlSessionTemplate

mybatis-spring 效仿 Spring 的风格提供了一个模板类 SqlSessionTemplate，可以通过模板类轻松地访问数据库。

首先在 applicationContext-mybatis.xml 中配置好 SqlSessionTemplateBean。

```xml
<bean class="org.mybatis.spring.SqlSessionTemplate">
　　<constructor-arg ref="sqlSessionFactory"/>
</bean>
```

然后就可以使用 SqlSessionTemplate 调用 SQL 映射项完成数据访问操作，如下面代码所示。

```java
@Repository
public class ForumMybatisTemplateDao {
    @Autowired
    private SqlSessionTemplate sessionTemplate;

    public Forum getForum(int forumId) {//①
        return (Forum) sessionTemplate.selectOne(
                "com.smart.dao.mybatis.ForumMybatisDao.getForum",
                forumId);
    }
}
```

在①处，SqlSessionTemplate 通过 selectOne() 方法调用在 Forum.xml 映射文件中定义的命名空间为com.smart.orm.dao.mybatis.ForumMybatisDao、映射项 id 为 getForum 的 SQL 映射项，并传入参数，返回映射成 Forum 对象的查询结果。

在 SqlSessionTemplate 模板类中提供了多个方便调用的方法，常用方法介绍如下。

（1）List<?> selectList(String statement，Object parameter)：调用 select 映射项，返回一个结果对象集合。其中，statement 为映射项全限定名，即包括命名空间和映射项 id（下同）；而 parameter 为传递给映射项的入参。

（2）int insert(String statement，Object parameter)：调用 insert 映射项，返回插入的记录数。

（3）int update(String statement，Object parameter)：调用 update 映射项，返回更改的记录数。

### 2）使用映射接口

使用字符串指定映射项，这种方式很容易引起错误。因为字符串本身没有语义性，如果存在编写错误，则在编译期无法识别，只能等到运行期才能发现。MyBatis 为解决这个问题，特别提供了一种可将 SQL 映射文件中的映射项通过名称匹配接口进行调用的方法：接口名称和映射命名空间相同，接口方法和映射元素的 id 相同。

下面为 Forum.xml 文件的映射项定义一个调用接口，如下面代码所示。

```java
package com.smart.dao.mybatis;

import java.util.List;
import com.smart.domain.Forum;

public interface ForumMybatisDao{
    void addForum(Forum forum);    
    void updateForum(Forum forum) ;
    Forum getForum(int forumId) ;
    long getForumNum() ;
    List<Forum> findForumByName(String forumName);
}
```

类名为 com.smart.dao.mybatis.ForumMybatisDao，Forum.xml 文件中的每个映射项对应一个接口方法，接口方法的签名和映射项的声明匹配。

在定义好 ForumMybatisDao 接口后，该如何通过该接口进行数据访问呢？毕竟 ForumMybatisDao 接口没有任何实现类。一种简单的方式是通过 SqlSessionTemplate 获取接口的实例。

```java
@Repository
public class ForumMybatisTemplateDao {
    @Autowired
    private SqlSessionTemplate sessionTemplate;

    public Forum getForum2(int forumId) {
        ForumMybatisDao forumMybatisDao =
                sessionTemplate.getMapper(ForumMybatisDao.class);
        return forumMybatisDao.getForum(forumId);
    }
}
```

SqlSessionTemplate 提供了一个可以根据接口类返回接口实例的方法 getMapper(Class<T> type)，直接访问接口实例的方法，即可调用 SQL 映射文件定义的映射项。

这种方法虽然比直接通过字符串指定映射项的方法安全便捷，但还不是最优的方法。**对于 Spring 应用来说，更希望在 Service 类中通过 @Autowired 注解直接注入接口实例，而非每次都通过 getMapper(Class<T> type）方法获取实例。**

mybatis-spring 提供了一个“神奇”的转换器 **==MapperScannerConfigurer==**，**它可以将映射接口直接转换为 Spring 容器中的 Bean，这样就可以在 Service 中注入映射接口的 Bean 了。**假设已经为3个SQL映射文件分别定义了对应的接口类，这些接口类位于 com.smart.dao.mybatis 包中，接口名分别为 ForumMybatisDao、TopicMybatisDao 及 PostMybatisDao。使用如下配置即可将接口转换为Bean：

```xml
<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer"
　　p:sqlSessionFactory-ref="sqlSessionFactory"
　　p:basePackage="com.smart.dao.mybatis"/>	<!-- 指定扫描接口目录，springboot可直接使用注解@Mapper在类上-->
```

**==MapperScannerConfigurer 将扫描 basePackage 所指定的包下的所有接口类（包括子包），如果它们在 SQL 映射文件中定义过，则将它们动态定义为一个 Spring Bean，这样就可以在 Service 中直接注入映射接口的 Bean==** 了，如下面代码所示。

```java
package com.smart.service.mybatis;

import com.smart.dao.mybatis.ForumMybatisDao;
import com.smart.dao.mybatis.PostMybatisDao;
import com.smart.dao.mybatis.TopicMybatisDao;
import com.smart.domain.Forum;
import com.smart.domain.Post;
import com.smart.domain.Topic;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Transactional
@Service
public class BbtForumSerive{
    @Autowired
    private ForumMybatisDao forumDao;

    @Autowired
    private TopicMybatisDao topicDao;

    @Autowired
    private PostMybatisDao postDao;

    public void addForum(Forum forum) {
        forumDao.addForum(forum);
    }
    ...
}
```

如粗体代码所示，BbtForumSerive 可以直接使用 @Autowired 注入这些映射接口的 Bean，然后即可顺利地通过接口方法调用 MyBatis 的映射项访问数据。