# [mybatis之foreach用法](https://www.cnblogs.com/fnlingnzb-learner/p/10566452.html)

在做mybatis的mapper.xml文件的时候，我们时常用到这样的情况：动态生成sql语句的查询条件，这个时候我们就可以用mybatis的foreach了

foreach元素的属性主要有item，index，collection，open，separator，close。

- **item：**集合中元素迭代时的别名，该参数为必选。
- **index**：在list和数组中,index是元素的序号，在map中，index是元素的key，该参数可选
- **open**：foreach代码的开始符号，一般是(和close=")"合用。常用在in(),values()时。该参数可选
- **separator**：元素之间的分隔符，例如在in()的时候，separator=","会自动在元素中间用“,“隔开，避免手动输入逗号导致sql错误，如in(1,2,)这样。该参数可选。
- **close:** foreach代码的关闭符号，一般是)和open="("合用。常用在in(),values()时。该参数可选。
- **collection:** 要做foreach的对象，作为入参时，List对象默认用"list"代替作为键，数组对象有"array"代替作为键，Map对象没有默认的键。当然在作为入参时可以使用@Param("keyName")来设置键，设置keyName后，list,array将会失效。 除了入参这种情况外，还有一种作为参数对象的某个字段的时候。举个例子：如果User有属性List ids。入参是User对象，那么这个collection = "ids".***如果User有属性Ids ids;其中Ids是个对象，Ids有个属性List id;入参是User对象，那么collection = "ids.id"***

在使用foreach的时候最关键的也是最容易出错的就是collection属性，该属性是必须指定的，但是在不同情况下，该属性的值是不一样的，主要有一下3种情况： 

- 如果传入的是单参数且参数类型是一个List的时候，collection属性值为list .
- 如果传入的是单参数且参数类型是一个array数组的时候，collection的属性值为array .
- ==如果传入的参数是多个的时候，我们就需要把它们封装成一个Map了，当然单参数也可以封装成map，实际上如果你在传入参数的时候，在MyBatis里面也是会把它封装成一个Map的，map的key就是参数名，所以这个时候collection属性值就是传入的List或array对象在自己封装的map里面的key.==

针对最后一条，我们来看一下官方说法：

> 注意 你可以将一个 List 实例或者数组作为参数对象传给 MyBatis，当你这么做的时候，MyBatis 会自动将它包装在一个 Map 中并以名称为键。List 实例将会以“list”作为键，而数组实例的键将是“array”。

所以，不管是多参数还是单参数的list,array类型，都可以封装为map进行传递。如果传递的是一个List，则mybatis会封装为一个list为key，list值为object的map，如果是array，则封装成一个array为key，array的值为object的map，如果自己封装呢，则colloection里放的是自己封装的map里的key值。

## 源码分析

由于官方文档对这块的使用，描述的比较简短，细节上也被忽略掉了(可能是开源项目文档一贯的问题吧)，也使用不少同学在使用中遇到了问题。特别是foreach这个函数中，collection属性做什么用，有什么注意事项。由于文档不全，这块只能通过源代码剖析的方式来分析一下各个属性的相关要求。

collection属性的用途是接收输入的数组或是List接口实现。但对于其名称的要求，Mybatis在实现中还是有点不好理解的，所以需要特别注意这一点。

下面开始分析源代码(笔记使用的是Mybatis 3.0.5版本)

先找到Mybatis执行SQL配置解析的入口

MapperMethod.java类中 public Object execute(Object[] args) 该方法是执行的入口.

针对in集合查询，对应用就是 selectForList或SelctForMap方法。

![img](https://img2018.cnblogs.com/blog/1000464/201903/1000464-20190320173657220-1615038745.png)
但不管调用哪个方法，都会对原来JDK传入的参数 Object[]类型，通过 getParam方法转换成一个Object,那这个方法是做什么的呢？分析源码如下：

 ![img](https://img2018.cnblogs.com/blog/1000464/201903/1000464-20190320173731188-273615511.png)

上图中标红的两处，很惊讶的发现，一个参数与多个参数的处理方式是不同的(后续很多同学遇到的问题，就有一大部分出自这个地方)。==如果参数个数大于一个，则会被封装成Map, key值如果使用了Mybatis的 Param注解，则会使用该key值，否则默认统一使用数据序号,从1开始。==这个问题先记下，继续分析代码，接下来如果是selectForList操作(其它操作就对应用相应方法),会调用DefaultSqlSession的public List selectList(String statement, Object parameter, RowBounds rowBounds) 方法

又一个发现，见源代码如下：

 ![img](https://img2018.cnblogs.com/blog/1000464/201903/1000464-20190320173752320-237995715.png)

上图标红部分，对参数又做了一次封装，我们看一下代码

![img](https://img2018.cnblogs.com/blog/1000464/201903/1000464-20190320173803697-949044115.png)

现在有点清楚了，==如果参数类型是List,则必须在collecion中指定为list, 如果是数据组，则必须在collection属性中指定为 array.==

现在就问题就比较清楚了，如果是一个参数的话，collection的值取决于你的参数类型。

==如果是多个值的话，除非使用注解Param指定，否则都是数字开头，==所以在collection中指定什么值都是无用的。下图是debug显示结果。

![img](https://img2018.cnblogs.com/blog/1000464/201903/1000464-20190320173836786-932705696.png)



### 使用方法

### 1.单参数List 类型

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```xml
1 <select id="countByUserList" resultType="_int" parameterType="list">
2 select count(*) from users
3   <where>
4     id in
5     <foreach item="item" collection="list" separator="," open="(" close=")" index="">
6       #{item.id, jdbcType=NUMERIC}
7     </foreach>
8   </where>
9 </select>
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

测试代码：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```java
 1 @Test
 2   public void shouldHandleComplexNullItem() {
 3     SqlSession sqlSession = sqlSessionFactory.openSession();
 4     try {
 5       Mapper mapper = sqlSession.getMapper(Mapper.class);
 6       User user1 = new User();
 7       user1.setId(2);
 8       user1.setName("User2");
 9       List<User> users = new ArrayList<User>();
10       users.add(user1);
11       users.add(null);
12       int count = mapper.countByUserList(users);
13       Assert.assertEquals(1, count);
14     } finally {
15       sqlSession.close();
16     }
17   }
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

### 2.单参数array数组的类型：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```xml
1 <select id="dynamicForeach2Test" resultType="Blog">
2      select * from t_blog where id in
3      <foreach collection="array" index="index" item="item" open="(" separator="," close=")">
4           #{item}
5      </foreach>
6 </select> 
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

上述collection为array，对应的Mapper代码：
public List dynamicForeach2Test(int[] ids);
对应的测试代码：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```java
 1 @Test
 2  public void dynamicForeach2Test() {
 3          SqlSession session = Util.getSqlSessionFactory().openSession();
 4          BlogMapper blogMapper = session.getMapper(BlogMapper.class);
 5          int[] ids = new int[] {1,3,6,9};
 6          List blogs = blogMapper.dynamicForeach2Test(ids);
 7          for (Blog blog : blogs)
 8          System.out.println(blog);    
 9          session.close();
10  }
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

### 3.自己把参数封装成Map的类型

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```xml
1 <select id="dynamicForeach3Test" resultType="Blog">
2          select * from t_blog where title like "%"#{title}"%" and id in
3           <foreach collection="ids" index="index" item="item" open="(" separator="," close=")">
4                #{item}
5           </foreach>
6  </select>
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

上述collection的值为ids，是传入的参数Map的key，对应的Mapper代码：
public List dynamicForeach3Test(Map params);
对应测试代码：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```java
 1 @Test
 2     public void dynamicForeach3Test() {
 3         SqlSession session = Util.getSqlSessionFactory().openSession();
 4          BlogMapper blogMapper = session.getMapper(BlogMapper.class);
 5           final List ids = new ArrayList();
 6           ids.add(1);
 7           ids.add(2);
 8           ids.add(3);
 9           ids.add(6);
10          ids.add(7);
11          ids.add(9);
12         Map params = new HashMap();
13          params.put("ids", ids);
14          params.put("title", "中国");
15         List blogs = blogMapper.dynamicForeach3Test(params);
16          for (Blog blog : blogs)
17              System.out.println(blog);
18          session.close();
19      }
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**注意注意sql语句SELECT \* FROM ny_jobs WHERE id IN () 这个会报错，所以最后判断一下Ids是有元素的**



---

# [mybatis传入多个参数](https://www.cnblogs.com/aoshicangqiong/p/8910318.html)

**需要查阅本文的基本都是需要传入多个参数的，这里记住一句话：无论你传的参数是什么样的，最后mybtis都会将你传入的转换为map的**

**一、单个参数：**

```xml
public List<XXBean> getXXBeanList(@param("id")String id);  

<select id="getXXXBeanList" parameterType="java.lang.String" resultType="XXBean">

　　select t.* from tableName t where t.id= #{id}  

</select>  

其中方法名和ID一致，#{}中的参数名与方法中的参数名一致， 这里采用的是@Param这个参数，实际上@Param这个最后会被Mabatis封装为map类型的。

select 后的字段列表要和bean中的属性名一致， 如果不一致的可以用 as 来补充。
```

**二、多参数：**

**方案1**

```
public List<XXXBean> getXXXBeanList(String xxId, String xxCode);  

<select id="getXXXBeanList" resultType="XXBean">

　　select t.* from tableName where id = #{0} and name = #{1}  

</select>  

由于是多参数那么就不能使用parameterType， 改用#｛index｝是第几个就用第几个的索引，索引从0开始
```

**方案2（推荐）基于注解**

```xml
public List<XXXBean> getXXXBeanList(@Param("id")String id, @Param("code")String code);  

<select id="getXXXBeanList" resultType="XXBean">

　　select t.* from tableName where id = #{id} and name = #{code}  

</select>  

由于是多参数那么就不能使用parameterType， 这里用@Param来指定哪一个
```

**三、Map封装多参数：** 

```xml
public List<XXXBean> getXXXBeanList(HashMap map);  

<select id="getXXXBeanList" parameterType="hashmap" resultType="XXBean">

　　select 字段... from XXX where id=#{xxId} code = #{xxCode}  

</select>  

其中hashmap是mybatis自己配置好的直接使用就行。map中key的名字是那个就在#{}使用那个，map如何封装就不用了我说了吧。 
```

 **四、List封装in：**

```
public List<XXXBean> getXXXBeanList(List<String> list);  

<select id="getXXXBeanList" resultType="XXBean">
　　select 字段... from XXX where id in
　　<foreach item="item" index="index" collection="list" open="(" separator="," close=")">  
　　　　#{item}  
　　</foreach>  
</select>  

foreach 最后的效果是select 字段... from XXX where id in ('1','2','3','4') 
```

**五、selectList()只能传递一个参数，但实际所需参数既要包含String类型，又要包含List类型时的处理方法：**

将参数放入Map，再取出Map中的List遍历。如下：

```java
List<String> list_3 = new ArrayList<String>();
Map<String, Object> map2 = new HashMap<String, Object>();

list.add("1");
list.add("2");
map.put("list", list); //网址id

map.put("siteTag", "0");//网址类型
public List<SysWeb> getSysInfo(Map<String, Object> map2) {
　　return getSqlSession().selectList("sysweb.getSysInfo", map2);
}
<select id="getSysInfo" parameterType="java.util.Map" resultType="SysWeb">
　　select t.sysSiteId, t.siteName, t1.mzNum as siteTagNum, t1.mzName as siteTag, t.url, t.iconPath
  from TD_WEB_SYSSITE t
  left join TD_MZ_MZDY t1 on t1.mzNum = t.siteTag and t1.mzType = 10
  WHERE t.siteTag = #{siteTag } 
  and t.sysSiteId not in 
  <foreach collection="list" item="item" index="index" open="(" close=")" separator=",">
     #{item}
  </foreach>
 </select>
```