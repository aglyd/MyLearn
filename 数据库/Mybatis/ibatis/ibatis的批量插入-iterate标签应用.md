# [ibatis的批量插入-iterate标签应用](https://blog.csdn.net/u011233568/article/details/80407933)

https://wenku.baidu.com/view/5ba8739066ce0508763231126edb6f1aff0071a9.html

项目开发中在很多地方可能会遇到同时插入多条记录到数据库的业务场景，如果业务级别循环单条插入数据会不断建立连接且有多个事务，这个时候如果业务的事务执行频率相当较高的话（高并发），对数据库的性能影响是比较大的;为了提高效率，批量操作会是不错的选择，一次批量操作只需要建立一次连接且一个事务，能很大程度上提高数据库的效率。

​      批量插入操作的SQL语句原型如下：

```sql
insert into     
    wsjiang_test（COL1，COL2，COL3）   
value    
    （col1_v，col2_v，col3_v），   
    （col1_v，col2_v，col3_v），  
```

​      这里我们以ibatis的的为例，进行应用说明！

 

## 一、ibatis iterate标签配置说明

```xml
<  iterate   
    property  =  ""   / *可选，   
        从传入的参数集合中使用属性名去获取值，   
        这个必须是一个列表类型，   
        否则会出现OutofRangeException，   
        通常是参数使用java.util.Map时才使用，   
        如果传入的参数本身是一个java.util.List的，不能只用这个属性。  
        不知道为啥官网HTTP：//ibatis.apache.org/docs/dotnet/datamapper/ch03s09.html#id386679 
        说这个属性是必须的，但是测试的时候是可以不设置这个属性的，还望那位大虾知道，讲解一下。  
        * /  
    conjunction =  ""   / *可选，   
        iterate可以看作是一个循环，   
        这个属性指定每一次循环结束后添加的符号，   
         比如使每次循环是OR的，则设置这个属性为OR * /  
    open  =  ""   / *可选，循环的开始符号* /  
    close  =  ""   / *可选，循环的结束符号* /  
    prepend  =  ""   / *可选，加在开放指定的符号之前的符号* /  
>  </  iterate  >
```



##  二、ibatis迭代标签使用示例

### 1、批量查询

```xml
<  select   id  =  “iterate_query”   parameterClass  =  “java.util.List”  >   
    <！[CDATA [  
       select * from wsjiang_test where id = 1 
    ]]>   
    <  iterate   prepend  =  “prepend”   conjunction  =  “conn”   open  =  “open”   colse  =  “close”  >   
        / *使用的java.util.List作为参数不能设置属性属性* /  
        <！[CDATA [  
            #V[]＃  
        ]]>  / *这里的“[]”是必须的，要不然ibatis会把v直接解析为一个String * /  
    </  iterate  >   
</  select  >
```

​             如果传入一个列表为[123234345]，上面的配置将得到一个SQL语句：

​                   **select \* from wsjiang_test**  where id = 1 prepend open 123 conn 234 conn 345 close

 

### 2、批量插入

**A、不使用开/关属性**

```xml
<  insert   id  =  “  iterate_insert1  ”   parameterClass  =  “java.util.List”  >   
    <！[CDATA [  
        insert into wsjinag_test（ col1 ， col2 ， col3 ）value  
    ]]>    
    <  iterate   连接 =  “，”  >   
        <！[CDATA [  
            （＃test[].col1＃，＃test[].col2＃，＃test[].col3＃）  
        ]]>   
    </  iterate  >   
</  insert  > 
```

​              上面的配置将得到一个SQL语句：

​                   insert into  wsjiang_test（ COL1，COL2，COL3 ）   value （？，？，？），（？，？，？），（？，？，？） 

 

**B、使用开/关属性**

```xml
<  insert   id  =  “betchAddNewActiveCode”   parameterClass  =  “java.util.List”  >    
   <！[CDATA [  
        insert into wsjinag_test（ col1 ， col2 ， col3 ） value
    ]]> 
    <  iterate   linkage  =  “，”   open  =  “（”   close  =  “）”  >   
        <！[CDATA [  
            / *这里不加“（”和“）”* /  
            ＃test[].col1＃，＃test[].col2＃，＃test[].col3＃
        ]]>   
    </  iterate  >   
</  insert  > 
```

​             上面的配置将得到一个SQL语句：

​                  **插入**  **到** wsjiang_test（ COL1，COL2，COL3 ）   **值**  （？，？，？，？，？，？，？，？，？）

 

​         这两种使用方式区别是相当大的。连接，打开和关闭这几个属性需小心使用，将其区分。

 

## 三、单条插入返回新增记录主键

​          通常情况，ibatis的的的插入方法需要返回新增记录的主键，但并非任何表的插入操作都会返回主键（这是一个陷阱）;要返回这个新增记录的主键，前提是表的主键是自增型的，或者是顺序的;且必须启用了ibatis的的 **selectKey元素元素**标签; 否则获取新增记录主键的值为0或者空。

​         ibatis的的的配置：

```xml
<  insert   id  =  “  iterate_insert1  ”   parameterClass  =  “Object”  >   
    <！[CDATA [  
        insert into wsjinag_test（ col1 ， col2 ，  col3 ）
        value   （＃ col1 ＃，＃ col2 ＃，＃ col3 ＃）  
    ]]>    
    <  selectKey    keyProperty  =  “id”  resultClass =  “Long”  >   
        <！[CDATA [  
            SELECT LAST_INSERT_ID（）AS值  
        ]]>   
    </  selectKey  >   
</  insert  >
```

 

## 四、插入报道查看 新增记录数

​      在第三节中已经讲清楚通过ibatis的的的插入方法只能得到新增记录的ID;  如果对于无需知道新增记录ID，只需要知道有没有插入成功的业务场景时，特别是对于批量插入，配置的 **selectKey元素元素**可能会有问题时，一次插入多条，拿不到新增的ID，我们这时就只能报道查看插入成功的记录数来区分是否新增成功但是插入方法的英文不会报道查看记录数;！于是我们可以使用了ibatis的的更新方法来调用没有配置  **selectKey元素元素** 标签的插入语句，这样就能返回影响（插入）的记录数了！

 对于最后一点今天工作中遇到了，查了好久的错误，返回null，而且自增字段在增加，但是没插入数据

result = sqlMapClientTemplate.**update**（“”，list）;





例子：

```java
        //JAVA代码
 
        List<QiaodaCvAnalysis> qList=new ArrayList<QiaodaCvAnalysis>();
		for(int i=0;i<10;i++){
			QiaodaCvAnalysis  dAnalysis=new QiaodaCvAnalysis();
			String i_vivian=String.valueOf(i);
			dAnalysis.setResumeId(i_vivian);
			dAnalysis.setPositionRank(i);
			qList.add(dAnalysis);
		}
		try {
			decomposevservice.addTest(qList);
		} catch (Exception e) {
			String msg = e.getMessage();
			System.out.println(msg);
			// TODO: handle exception
		}
```

```xml
<typeAlias alias="QiaodaCvAnalysis"
		type="com.transing.arithmetic.bo.decomposeCV.QiaodaCvAnalysis" />
<insert id="addQiaodaCvAnalysisTest" parameterClass="java.util.ArrayList" >
			<![CDATA[
				insert into test(resumeId,toBachelor,updateTime)
				values
			]]>
			<iterate  conjunction="," >
			     (#QiaodaCvAnalysis[].resumeId#,#QiaodaCvAnalysis[].toBachelor#,now())
			</iterate> 
			
			 ON DUPLICATE KEY UPDATE toBachelor=values(toBachelor);
	</insert>
```





## 更新< update>标签的使用：

```xml
<update>
update xxx.xxx 
<dynamic prepend="set">		//会自动去除第一个","
   <isNotEmpty prepend="," property="insertTime">
      INSERT_TIME=#insertTime#
   </isNotEmpty>
    <isNotEmpty prepend="," property="year">
			YEAR=#year#
		</isNotEmpty>
    <dynamic prepend="WHERE">  
        id = #id:INTEGER#
   		and name =#name:VARCHAR# 
    </dynamic>  
</update>
```



# [Ibatis中的isNotNull、isEqual、isEmpty的区别](https://blog.csdn.net/wangxy799/article/details/50905795/)

> isNull判断property字段是否是null
> isEmpty判断property字段 是否是null 和 空[字符串](https://so.csdn.net/so/search?q=字符串&spm=1001.2101.3001.7020)
> isEqual相当于[equals](https://so.csdn.net/so/search?q=equals&spm=1001.2101.3001.7020)，数字用得多些，一般都是判断状态值

------

转载自：<http://jun1986.iteye.com/blog/1402191>

例子1:(isEqual)

```xml
<isEqual property="state" compareValue="0">< /isEqual>
或
<isEqual property="state" compareProperty="nextState"></isEqual>
```

例子2：
传入的map或者类的属性name等于”1”吗，是就附加and和vvvv

```xml
<isEqual property="name" compareValue="1" prepend="and">
    vvvv = '哈哈'
< /isEqual>
```

传入的map或者类的属性name是null吗，是就附加and和vvvv = null

```xml
< isNull property="name" prepend="and">
    vvvv = null
< /isNull>
```

sqlmap

```xml
<select id="querySingleModelByOut"  parameterClass="com.hanpeng.base.phone.model.TBussinessNotice"   
    resultClass="com.hanpeng.base.phone.model.TBussinessNotice">  
    select * from (select row_.*, rownum rownum_ from (  
        SELECT  
            i.NOTICE_NUM  as noticeNum ,              
            i.BUSSINESS_ID  as bussinessId ,              
            i.STATE  as state ,           
            i.READ_DATE  as readDate ,  
            n.NOTICE_TITLE as noticeTitle ,           
            n.NOTICE_INFO as noticeInfo ,             
            n.CREATE_DATE as createDate ,             
            n.EMPLOYEE_ID as employeeId ,             
            n.NOTICE_TYPE as noticeType ,             
            n.NOTICE_SHOW_TYPE as noticeShowType ,            
            n.FINISH_DATE as finishDate ,             
            n.PUBLISH_DATE as publishDate   
        FROM  T_BUSSINESS_NOTICE i left join T_NOTICE n on n.NOTICE_NUM = i.NOTICE_NUM   
        WHERE  
        n.PUBLISH_DATE &lt;= sysdate AND n.FINISH_DATE &gt;= sysdate  
        <isNotEmpty prepend=" AND " property="bussinessId">   
            i.BUSSINESS_ID = #bussinessId# </isNotEmpty>  
        <isNotEmpty prepend=" AND " property="state">   
            i.STATE = #state# </isNotEmpty>  
        <isNotEmpty prepend=" AND " property="noticeShowType">   
            n.NOTICE_SHOW_TYPE = #noticeShowType# </isNotEmpty>  
        <isEqual property="saleBack" compareValue="10" prepend=" AND ">  
            n.NOTICE_TYPE!='25'</isEqual>  
        <isEqual property="remittanceBank" compareValue="10" prepend=" AND ">  
            n.NOTICE_TYPE!='63'</isEqual>  
        <isEqual property="remittanceOnline" compareValue="10" prepend=" AND ">  
            n.NOTICE_TYPE!='64'</isEqual>  
    )row_ where rownum &lt;=1 ) where rownum_&gt;=0  
</select>  
```

