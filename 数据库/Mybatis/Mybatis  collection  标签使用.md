# Mybatis < collection > 标签使用](https://blog.csdn.net/mamba10/article/details/20927225)




```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<!-- 获得这个用户所有的菜单权限 -->
<select id="searchSingleUserMenuAuthorities" parameterType="java.lang.String" resultMap="OneMenuAuthority">
	select 
	name name,
	ht_authority_id htAuthorityId,
	(select ${uid} from dual ) currentUserId
	from ht_authority 
	where pid = 0
</select>
<resultMap type="com.sailod.shiro.dto.HtAuthorityMenuDTO" id="OneMenuAuthority">
	<id property="htAuthorityId" column="htAuthorityId" javaType="java.lang.Long" />
	<result property="name" column="name" javaType="java.lang.String" />
	<result property="currentUserId" column="currentUserId" javaType="java.lang.Long" />
	<collection property="htAuthorityDTO"  ofType="com.sailod.shiro.dto.HtAuthorityDTO"
	 select="selectAuthority" column="{htAuthorityId2 = htAuthorityId ,currentUserId2 = currentUserId}"   >
	 </collection>
</resultMap>
<select id="selectAuthority" parameterType="java.util.HashMap" resultType="com.sailod.shiro.dto.HtAuthorityDTO" resultMap="OneAuthority"  >
	select ha.name name,
	ha.url url ,
	ha.ht_authority_id htauthorityid,
	ha.pid pid,
	ha.type type,
	ha.permission permission,
	hua.ht_user_id currUserId
	from ht_authority ha
	left join ht_user_authority hua on hua.ht_authority_id = ha.ht_authority_id 
	where ha.pid = ${htAuthorityId2}
	and ha.type = 'menu' 
	and hua.ht_user_id = ${currentUserId2} 
</select>
<resultMap type="com.sailod.shiro.dto.HtAuthorityDTO" id="OneAuthority" >
	<id property="pid" column="pid" javaType="java.lang.Long" />
	<result property="name" column="name"  javaType="java.lang.String"/>
	<result property="url" column="url" javaType="java.lang.String"/>
	<result property="type" column="type" javaType="java.lang.String"/>
	<result property="permission" column="permission" javaType="java.lang.String"/>
	<result property="htAuthorityId" column="htauthorityid" javaType="java.lang.Long"/>
	<result property="currUserId" column="currUserId" javaType="java.lang.Long" />
</resultMap>
</mapper>
```
<resultMap>其实就是返回类型为其引用的id的  标签所定义的。

<collection>往这个标签定义的 ‘类’ 的 list 属性中设置值， 如何设置值？ 还要根据其 select="selectAuthority" ， 把值查询出来。

![img](https://img-blog.csdn.net/20150416141141654?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbWFtYmExMA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

```java
package com.sailod.shiro.dto;
 
import java.util.List;
 
/**
 * 查询菜单用到dto
 * 
 *
 */
@Data
public class HtAuthorityMenuDTO {
	
 
	private String name;
	
	private Long htAuthorityId;
	
	private Long currentUserId;
	
	private List<HtAuthorityDTO> htAuthorityDTO;
 
}
```

```java
package com.sailod.shiro.dto;
 
/**
 * 查询菜单用到dto
 * 
 *
 */
@Data
public class HtAuthorityDTO {
	
	//这个权限的主键
	private Long htAuthorityId;
	//父菜单的主键
	private Long pid;
	
	private String name;
	
	private String url;
	//类型
	private String type;
	
	private String permission;
	
	private Long currUserId;
	
}
```

## **低效率 collection:**

![img](https://img-blog.csdn.net/20150426102659632?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbWFtYmExMA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)



## 高效率collection：

1 查询用联合查询

2<collection>里面不写column 

![img](https://img-blog.csdn.net/20150426102731300?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbWFtYmExMA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)





# [MyBatis中的collection两种常用使用方法](https://blog.csdn.net/weixin_46645338/article/details/123987406)

MyBatis中的collection两种常用使用方法
码云MybatisDemo: 用来学习springboot整合mybatis (gitee.com)

collection主要是应对表关系是一对多的情况

查询的时候，用到联表去查询

接下来的小案例包括：市，学校，医院（随便写的），写一个最简单的demo

主要的功能就是查询出所有的市以及对应的市下面所有的学校和医院

实体类：医院

```
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Hospital {
    private int id;                 //医院编号
    private int urbanId;            //市的编号
    private String hospitalName;    //医院名称
    private Long people;            //医院人数
}
```

实体类：学校

```
@Data
@AllArgsConstructor
@NoArgsConstructor
public class School {
    private int id;               //学校编号
    private int urbanId;          //市的编号
    private String schoolName;    //学校名字
    private Long people;          //学校人数
}
```


实体类：市

```
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Urban {
    private int id;                   //市的编号
    private String cityId;            //省的编号（此博文没用到）
    private String urbanName;         //城市名字
    private List<School> schools;     //对应的所有的学校
    private List<Hospital> hospitals; //对应的所有的医院
}
```


第一种方式，采用select
首先我们要在学校和医院接口对应的xml中写出按照市的编号来查询出所有数据的xml

xml：医院

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.yh.mybatis.dao.mapper.HospitalMapper">
    <select id="findAllByUId" resultType="com.yh.mybatis.dao.pojo.Hospital">
        select * from hospital where urban_id = #{urbanId}
    </select>
<!--实际工作不建议用 *，id就是mapper接口中对应的方法名，resultType就是查询出结果后返回的list的泛型 
 urban_id = #{urbanId} 按照urban_id去查找-->
</mapper>
```

xml：学校

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.yh.mybatis.dao.mapper.SchoolMapper">
    <select id="urbanSchool" resultType="com.yh.mybatis.dao.pojo.School">
        select * from school where urban_id = #{urbanId}
    </select>
</mapper>
```


接下来就是在`市`的xml中对学校和医院的xml进行一个调用（用collection中select）
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.yh.mybatis.dao.mapper.UrbanMapper">
	  <resultMap id="findAllUrbanSandH" type="com.yh.mybatis.dao.pojo.Urban">
        <collection property="schools" javaType="java.util.List" ofType="com.yh.mybatis.dao.pojo.School"
                    select="com.yh.mybatis.dao.mapper.SchoolMapper.urbanSchool"
                    column="{urbanId=id}">
        </collection>
        <collection property="hospitals" javaType="java.util.List" ofType="com.yh.mybatis.dao.pojo.Hospital"
                    select="com.yh.mybatis.dao.mapper.HospitalMapper.findAllByUId"
                    column="{urbanId=id}">
        </collection>
    </resultMap>
<!--
		resultMap中的 <id><result>都可以不写，直接写List<School>和List<Hospital>
									type还是sql的返回类型
		collection中  property 是Urban中对应的字段
									javaType 是这个字段的类型
									ofType 是这个字段的泛型  这一项和上一项其实都可以不写，写上了看着更清晰
									select 是子表的按照市的编号查询所有数据的方法 这里要写下全路径
									column 作为select语句的参数传入, 也就是把市的编号id 传给医院和学校xml的urbanId
-->
		<select id="findAllUrbanSandH" resultMap="findAllUrbanSandH">
        select * from urban
    </select>
</mapper>
```

## 第二种方式，执行一次sql

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.yh.mybatis.dao.mapper.UrbanMapper">
		<resultMap id="findAllUrbanSandH2" type="com.yh.mybatis.dao.pojo.Urban">
        <id property="id" column="id"/>
        <result property="cityId" column="city_id"/>
        <result property="urbanName" column="urban_name"/>
<!--这上面这几个字段就是urban表中，自带的那几个字段-->
        <collection property="schools" javaType="java.util.List" ofType="com.yh.mybatis.dao.pojo.School">
            <id property="id" column="sid"/>
            <result property="urbanId" column="surban_id"/>
            <result property="schoolName" column="school_name"/>
            <result property="people" column="speople"/>
        </collection>
<!--这上面就是school表中的字段
		javaType是urban类中定义的school的类型  可以不写
		ofType就是泛型，这个还是很有必要的，接下来的id result 就是这个类中定义的各种字段，要写全
		如果涉及到的任何表中，在数据库中有重复的字段名，那就必须要起别名。（例如各个表中的id）
		起别名直接在下面的sql中就可以。
-->
        <collection property="hospitals" javaType="java.util.List" ofType="com.yh.mybatis.dao.pojo.Hospital">
            <id property="id" column="hid"/>
            <result property="urbanId" column="hurban_id"/>
            <result property="hospitalName" column="hospital_name"/>
            <result property="people" column="hpeople"/>
        </collection>
    </resultMap>
		<select id="findAllUrbanSandH2" resultMap="findAllUrbanSandH2">
        select  urban.city_id
                ,urban.id
                ,urban.urban_name
                ,school.id sid
                ,school.urban_id surban_id
                ,school.school_name
                ,school.people speople
                ,hospital.id hid
                ,hospital.urban_id hurban_id
                ,hospital.hospital_name
                ,hospital.people hpeople
        from urban
            inner join school on urban.id = school.urban_id
            inner join hospital on urban.id = hospital.urban_id
    </select>
</mapper>
```

接下来就可以写两个接口来测试这两个xml配置是否正确，具体的代码在最上面的码云地址里，大家可以配合swagger进行测试。提供一个springboot整合swagger3的一个小教程[springboot整合swagger3](https://blog.csdn.net/weixin_46645338/article/details/123895447)



 

