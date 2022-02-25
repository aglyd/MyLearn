# [mybatis用法(三)mybatis保存CLOB类型到oracle数据库实例][https://blog.csdn.net/zengdeqing2012/article/details/78864922]

## 1.背景

近期项目中遇到了用mybatis保存数据库CLOB类型到oracle库的操作,记录一下,方便以后查阅。

## 2.实例代码

### 2.1 表结构

```html
--判断表是否存在，如果存在则删除  
-- drop table WMS_IN_POOL;   
   
-- Create table 
create table WMS_IN_POOL  
(   
  POOL_PK_NO  NUMBER NOT NULL,
  BIG_DATA    CLOB default NULL,
  CREATE_TIME DATE default SYSDATE,
  UPDATE_TIME DATE
);
 
-- Add comments to the table     
comment on table VENDOR_CHECK_WAY is 'CLOB测试表';   
   
-- Add comments to the columns      
COMMENT ON COLUMN WMS_IN_POOL.POOL_PK_NO IS '主键ID(自增)';
COMMENT ON COLUMN WMS_IN_POOL.BIG_DATA  IS '存储json字符串,大数据值';
COMMENT ON COLUMN VENDOR_CHECK_WAY.CREATE_TIME  IS '创建时间';
COMMENT ON COLUMN VENDOR_CHECK_WAY.UPDATE_TIME  IS '修改时间';
 
-- Create/Recreate primary, unique and foreign key constraints     
alter table WMS_IN_POOL    
  add constraint WMS_IN_POOL primary key (POOL_PK_NO);
 
-- Create sequence     
create sequence SEQ_POOL_PK_NO    
minvalue 1    -- 最小值=1    
maxvalue 999999999999999999999999999  -- 指定最大值     
   
start with 1   -- 从1开始    
increment by 1  -- 每次递增1    
cache 20;
    
-- Create Index  --> clob can not create index
-- create index index_big_data on WMS_IN_POOL(BIG_DATA);
 
-- commit
commit;
```


效果图:

![img](https://img-blog.csdn.net/20171221163021254)

### 2.2 实体类 WmsInPool.java

```
import java.math.BigDecimal;
import java.util.Date;
 
public class WmsInPool implements java.io.Serializable {
 
	private static final long serialVersionUID = 1L;
 
	/** 主键id*/
    private BigDecimal poolPkNo;
    
    /** clob类型数据字段*/
    private String bigData;
 
    /** 创建时间*/
    private Date createTime;
    
    /** 更新时间*/
    private Date updateTime;
 
	public BigDecimal getPoolPkNo() {
		return poolPkNo;
	}
 
	public void setPoolPkNo(BigDecimal poolPkNo) {
		this.poolPkNo = poolPkNo;
	}
 
	public String getBigData() {
		return bigData;
	}
 
	public void setBigData(String bigData) {
		this.bigData = bigData;
	}
 
	public Date getCreateTime() {
		return createTime;
	}
 
	public void setCreateTime(Date createTime) {
		this.createTime = createTime;
	}
 
	public Date getUpdateTime() {
		return updateTime;
	}
 
	public void setUpdateTime(Date updateTime) {
		this.updateTime = updateTime;
	}
    
}
```

### 2.3 mybatis映射文件 WmsInPoolMapper.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="cn.wlw.mgt.dao.WmsInPoolMapper">
  <resultMap id="BaseResultMap" type="cn.wlw.mgt.entity.WmsInPool">
    <id column="POOL_PK_NO" jdbcType="DECIMAL" property="poolPkNo" />
    <result column="BIG_DATA" property="bigData" jdbcType="CLOB" javaType = "java.lang.String"/>
    <result column="CREATE_TIME" jdbcType="TIMESTAMP" property="createTime" />
    <result column="UPDATE_TIME" jdbcType="TIMESTAMP" property="updateTime" />
  </resultMap>
  
  <sql id="Base_Column_List">
    POOL_PK_NO,BIG_DATA,CREATE_TIME,UPDATE_TIME
  </sql>
  
  <select id="selectByPrimaryKey" parameterType="java.math.BigDecimal" resultMap="BaseResultMap">
    select 
    <include refid="Base_Column_List" />
    from WMS_IN_POOL
    where POOL_PK_NO = #{poolPkNo,jdbcType=DECIMAL}
  </select>
  
  <delete id="deleteByPrimaryKey" parameterType="java.math.BigDecimal">
    delete from WMS_IN_POOL
    where POOL_PK_NO = #{poolPkNo,jdbcType=DECIMAL}
  </delete>
  
  <insert id="insert" parameterType="cn.wlw.mgt.entity.WmsInPool">
  	<selectKey resultType="Decimal" keyProperty="poolPkNo" order="BEFORE">
        SELECT nvl(max(POOL_PK_NO),0)+1 from WMS_IN_POOL
    </selectKey>
    insert into WMS_IN_POOL (POOL_PK_NO,BIG_DATA,CREATE_TIME,UPDATE_TIME)
    values (
      #{poolPkNo,jdbcType=DECIMAL},#{bigData,jdbcType=CLOB},  
      #{createTime,jdbcType=TIMESTAMP},#{updateTime,jdbcType=TIMESTAMP}
    )
  </insert>
  
  <insert id="insertSelective" parameterType="cn.wlw.mgt.entity.WmsInPool">
    insert into WMS_IN_POOL
    <trim prefix="(" suffix=")" suffixOverrides=",">
      <if test="poolPkNo != null">
        POOL_PK_NO,
      </if>
      <if test="bigData != null">
        BIG_DATA,
      </if>
      <if test="createTime != null">
        CREATE_TIME,
      </if>
      <if test="updateTime != null">
        UPDATE_TIME,
      </if>
    </trim>
    <trim prefix="values (" suffix=")" suffixOverrides=",">
      <if test="poolPkNo != null">
        #{poolPkNo,jdbcType=DECIMAL},
      </if>
      <if test="bigData != null">
        #{bigData,jdbcType=CLOB},
      </if>
      <if test="createTime != null">
        #{createTime,jdbcType=TIMESTAMP},
      </if>
      <if test="updateTime != null">
        #{updateTime,jdbcType=TIMESTAMP},
      </if>
    </trim>
  </insert>
  
  <update id="updateByPrimaryKeySelective" parameterType="cn.wlw.mgt.entity.WmsInPool">
    update WMS_IN_POOL
    <set>
      <if test="bigData != null">
        BIG_DATA = #{bigData,jdbcType=CLOB},
      </if>
      <if test="createDate != null">
        UPDATE_TIME = #{updateTime,jdbcType=TIMESTAMP},
      </if>
    </set>
    where POOL_PK_NO = #{poolPkNo,jdbcType=DECIMAL}
  </update>
  
  <update id="updateByPrimaryKey" parameterType="cn.wlw.mgt.entity.WmsInPool">
    update WMS_IN_POOL
    set BIG_DATA = #{bigDdata,jdbcType=CLOB},
      UPDATE_TIME = #{updateTime,jdbcType=TIMESTAMP}
    where POOL_PK_NO = #{poolPkNo,jdbcType=DECIMAL}
  </update>
	
  <insert id="batchInsertWmsInPool" parameterType="cn.wlw.mgt.entity.WmsInPool">
		insert into WMS_IN_POOL(
		POOL_PK_NO,BIG_DATA,CREATE_TIME,UPDATE_TIME) 
		select SEQ_POOL_PK_NO.NEXTVAL, A.* from(
		<foreach collection="wmsInPools" item="item" index="index" separator="UNION ALL">
			SELECT
			#{item.bigData,jdbcType=CLOB},
			#{item.createTime,jdbcType=TIMESTAMP},
			#{item.updateTime,jdbcType=TIMESTAMP} 
			from dual
		</foreach>
		) A
  </insert>
  
</mapper>
```

### 2.4 dao层接口(没有实现类的哦)

```
import cn.wlw.mgt.entity.WmsInPool;
import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Param;
 
public interface WmsInPoolMapper {
	/**
	 * 
	 * @param poolPkNo
	 * @return
	 */
    public int deleteByPrimaryKey(BigDecimal poolPkNo);
 
    /**
     * 
     * @param record
     * @return
     */
    public int insert(WmsInPool record);
 
    /**
     * 
     * @param record
     * @return
     */
    public int insertSelective(WmsInPool record);
 
    /**
     * 
     * @param poolPkNo
     * @return
     */
    public WmsInPool selectByPrimaryKey(BigDecimal poolPkNo);
 
    /**
     * 
     * @param record
     * @return
     */
    public int updateByPrimaryKeySelective(WmsInPool record);
 
    /**
     * 
     * @param record
     * @return
     */
    public int updateByPrimaryKey(WmsInPool record);
 
    /**
     * @param wmsInPools
     * @return
     */
    public int batchInsertWmsInPool(@Param("wmsInPools") List<WmsInPool> wmsInPools);
}
```



-----



# [Java 存储和读取 oracle CLOB 类型字段](https://www.cnblogs.com/dyh-air/articles/9258346.html)

```java
import java.io.BufferedReader;   
import java.io.File;   
import java.io.FileReader;   
import java.io.IOException;   
import java.io.Reader;   
import java.io.StringReader;   
import java.sql.Connection;   
import java.sql.DriverManager;   
import java.sql.PreparedStatement;   
import java.sql.ResultSet;   
import java.sql.SQLException;   
import oracle.jdbc.driver.OracleDriver;   
import oracle.sql.CLOB;   
  
public class ClobTest {   
String url = "jdbc:oracle:thin:@192.168.2.157:1521:orcl";   
String user = "xj";   
String pwd = "xj";   
String text = "这是要插入到CLOB里面的数据";   
  
  
private void clobImport() throws ClassNotFoundException, SQLException {   
// TODO Auto-generated method stub   
DriverManager.registerDriver(new OracleDriver());   
Connection conn = DriverManager.getConnection(url, user, pwd);// 得到连接对象   
String sql = "insert into clob_test(id,str) values ('1',?)";// 要执行的SQL语句   
  
PreparedStatement stmt = conn.prepareStatement(sql);// 加载SQL语句   
// PreparedStatement支持SQL带有问号？，可以动态替换？的内容。   
Reader clobReader = new StringReader(text); // 将 text转成流形式   
stmt.setCharacterStream(1, clobReader, text.length());// 替换sql语句中的？   
int num = stmt.executeUpdate();// 执行SQL   
if (num > 0) {   
System.out.println("ok");   
} else {   
System.out.println("NO");   
}   
stmt.close();   
conn.close();   
}   
  
private void clobExport() throws ClassNotFoundException, SQLException,   
IOException {   
// TODO Auto-generated method stub   
CLOB clob = null;   
String sql = "select * from clob_test where id=1";   
DriverManager.registerDriver(new OracleDriver());   
Connection conn = DriverManager.getConnection(url, user, pwd);// 得到连接对象   
PreparedStatement stmt = conn.prepareStatement(sql);   
ResultSet rs = stmt.executeQuery();   
String id = "";   
String content = "";   
if (rs.next()) {   
id = rs.getString("id");// 获得ID   
clob = (oracle.sql.CLOB) rs.getClob("str"); // 获得CLOB字段str   
// 注释： 用 rs.getString("str")无法得到 数据 ，返回的 是 NULL;   
content = ClobToString(clob);   
}   
stmt.close();   
conn.close();   
// 输出结果   
System.out.println(id);   
System.out.println(content);   
}   
  
// 将字CLOB转成STRING类型   
public String ClobToString(CLOB clob) throws SQLException, IOException {   
  
String reString = "";   
Reader is = clob.getCharacterStream();// 得到流   
BufferedReader br = new BufferedReader(is);   
String s = br.readLine();   
StringBuffer sb = new StringBuffer();   
while (s != null) {// 执行循环将字符串全部取出付值给StringBuffer由StringBuffer转成STRING   
sb.append(s);   
s = br.readLine();   
}   
reString = sb.toString();   
return reString;   
}   
  
  
// TODO Auto-generated method stub   
public static void main(String[] args) throws IOException,   
ClassNotFoundException, SQLException {   
// TODO Auto-generated method stub   
ClobTest clobtest = new ClobTest();   
// read file   
FileReader _frd = new FileReader(new File("D://DOS.txt"));   
BufferedReader _brd = new BufferedReader(_frd);   
String _rs = _brd.readLine();   
StringBuffer _input = new StringBuffer();   
while (_rs != null) {   
_input.append(_rs);   
_rs = _brd.readLine();   
}   
// System.out.println(_input.toString());   
// 输入测试   
clobtest.text = _input.toString();   
clobtest.clobImport();   
// 输出测试   
// clobtest.clobExport();   
}   
  
}  
```



----



# 百度百科----clob的Java操作

JAVA里面对CLOB的操作

在绝大多数情况下，使用2种方法使用CLOB

1 相对比较小的，可以用String进行直接操作，把CLOB看成字符串类型即可

2 如果比较大，可以用 getAsciiStream 或者 getUnicodeStream 以及对应的 setAsciiStream 和 setUnicodeStream 即可

**读取数据**

ResultSet rs = stmt.executeQuery("SELECT TOP 1 * FROM Test1");

rs.next();

Reader reader = rs.getCharacterStream(2);

**插入数据**

PreparedStatement pstmt = con.prepareStatement("INSERT INTO test1 (c1_id, c2_vcmax) VALUES (?, ?)");

pstmt.setInt(1, 1);

pstmt.setString(2, htmlStr);

pstmt.executeUpdate();

**更新数据**

Statement stmt = con.createStatement();

ResultSet rs = stmt.executeQuery("SELECT * FROM test1");

rs.next();

Clob clob = rs.getClob(2);

long pos = clob.position("dog", 1);

clob.setString(1, "cat", len, 3);

rs.updateClob(2, clob);

rs.updateRow();



------



# [java中clob类型的值处理](https://www.cnblogs.com/jassy/p/6840295.html)

1、String类转换Clob类型

private Clob clobStr;

private String Str="测试值";

clobStr = Hibernate.createClob(obj.toJSONString());

2、Clob类型转换String类型

private Clob clobStr;

private String Str;

Str = clobStr.getSubString(1, (int) clobStr.length());



------



# 注解@Column使用：

# [clob 对应java 类型_Clob字段和Java类中字段对应][https://blog.csdn.net/weixin_35671798/article/details/114068415]

最近在使用webservice的时候接受客户端的字符串,是使用xml或者json格式的字符串.

在对应的句javaBean中直接使用String类型保存,数据库后台使用的是Clob字段对应.

```
@SuppressWarnings("serial")

@Entity

@Table(name = "T_BCL_BIZINSTRUCTIONDOCUMENTS")

public class TBclBizinstructiondocument implements java.io.Serializable {
private Long bizinstructiondocid;       //业务系统传递过来的数据Id

private Date receivedate;                  //业务系统传递过来的数据时间

private String instructioncomment;    //业务系统传递过来的数据内容  注意:此处使用Sring,后台是clob字段

@Id

@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "bizinstructiondocid_sequence")

@SequenceGenerator(name = "bizinstructiondocid_sequence", allocationSize = 1,sequenceName = "bizinstructiondocid_sequence")

@Column(name = "BIZINSTRUCTIONDOCID", unique = true, nullable = false, precision = 16, scale = 0)

public Long getBizinstructiondocid() {
return bizinstructiondocid;

}

public void setBizinstructiondocid(Long bizinstructiondocid) {
this.bizinstructiondocid = bizinstructiondocid;

}

@Temporal(TemporalType.TIMESTAMP)

@Column(name = "RECEIVEDATE", length = 14)

public Date getReceivedate() {
return receivedate;

}

public void setReceivedate(Date receivedate) {
this.receivedate = receivedate;

}

@Lob

@Basic(fetch = FetchType.EAGER)

@Column(name="INSTRUCTIONCOMMENT", columnDefinition="CLOB", nullable=true)

public String getInstructioncomment() {
return instructioncomment;

}

public void setInstructioncomment(String instructioncomment) {
this.instructioncomment = instructioncomment;

}

}

记录如下:对应的Java字段使用String类型,后台数据库oracle中对应Clob字段.

注解使用:

@Lob

@Basic(fetch = FetchType.EAGER)

@Column(name="INSTRUCTIONCOMMENT", columnDefinition="CLOB", nullable=true)
```

