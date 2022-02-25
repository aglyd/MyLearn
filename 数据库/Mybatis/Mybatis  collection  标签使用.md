# [Mybatis < collection > 标签使用](https://blog.csdn.net/mamba10/article/details/20927225)




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