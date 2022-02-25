# [Jackson objectMapper.readValue 方法 详解](https://www.cnblogs.com/del88/p/13098678.html)

直接说结论方便一目了然：

1. 简单的直接Bean.class

2. 复杂的用 TypeReference 

这样就完事了。

```java
public class TestMain2 {
    public static void main(String[] args) throws JsonProcessingException {


        /*
          首先说明 readValue 针对String 一共有3个重载，如下：

          public <T> T readValue(String content, Class<T> valueType)；简单型，就是 直接  UserBase.class 就可。

          public <T> T readValue(String content, TypeReference<T> valueTypeRef)；复杂的可以 用这个

          public <T> T readValue(String content, JavaType valueType)；这个书写起来比较麻烦，就不说明了，不常用，前2个已经彻底满足了。

         */

        ObjectMapper objectMapper = new ObjectMapper();
        String json1 = "{\"userName\":\"小李飞刀\",\"age\":18,\"addTime\":1591851786568}";
        String json2 = "[{\"userName\":\"小李飞刀\",\"age\":18,\"addTime\":123}, {\"userName\":\"小李飞刀2\",\"age\":182,\"addTime\":1234}]";


        //1.最简单的常用方法，直接将一个json转换成实体类
        UserBase userBase1 = objectMapper.readValue(json1, UserBase.class); //简单类型的时候，这样最方便
        System.out.println("简单: " + userBase1.getUserName());
        //用 TypeReference 也可以，但是麻烦 不如第一种直接 TypeReference 主要针对繁杂类型
        //UserBase userBase2 = objectMapper.readValue(json1, new TypeReference<UserBase>() {});



        //2.把Json转换成map，必须使用 TypeReference , map的类型定义 可以根据实际情况来定，比如若值都是String那么就可以 Map<String, String>
        Map<String, Object> userBaseMap =  objectMapper.readValue(json1, new TypeReference<Map<String, Object>>() {});
        System.out.println("map: " + userBaseMap.get("userName"));


        //3.list<Bean>模式，必须用 TypeReference
        List<UserBase> userBaseList = objectMapper.readValue(json2, new TypeReference<List<UserBase>>() {});
        System.out.println("list: " + userBaseList.get(0).getUserName());


        //4.Bean[] 数组，必须用 TypeReference
        UserBase[] userBaseAry = objectMapper.readValue(json2, new TypeReference<UserBase[]>() {});
        System.out.println("ary: " + userBaseAry[0].getUserName());
    }
}
```

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612120910523-182974797.png)

==========================================================下面是详细的秒数==================================================

## 方法1，针对简单类型，有实体类的json，直接转换成单个实体类，上代码：

首先是一个实体类UserBase:

```
public class UserBase {

    /**
     * 用户名
     */
    private String userName;


    /**
     * 年龄
     */
    private Integer age;


    /**
     * 增加时间
     */
    private Date addTime;

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public Date getAddTime() {
        return addTime;
    }

    public void setAddTime(Date addTime) {
        this.addTime = addTime;
    }
}
```

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612101517730-1204218729.png)

```java
public class TestMain2 {
    public static void main(String[] args) throws JsonProcessingException {

        /*
         1.最简单的常用方法，直接将一个json转换成实体类
         */
        ObjectMapper objectMapper = new ObjectMapper();
        String json = "{\"userName\":\"小李飞刀\",\"age\":18,\"addTime\":1591851786568}";

        //这里需要这么写，
        UserBase userBase = objectMapper.readValue(json, UserBase.class); //简单类型的时候，这样最方便

        UserBase userBase1 = objectMapper.readValue(json, new TypeReference<UserBase>() {}); //这样也可以，TypeReference主要针对复杂类型

        System.out.println(userBase.getUserName());
        System.out.println(userBase1.getUserName());
    }
}
```

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612102003216-335128214.png)





## **2. 若是map呢， 应该怎么用会怎样？？以下开始举例：**

 

```java
public class TestMain3 {
    public static void main(String[] args) throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();

        //注意这里键名和键值都是String类型的
        Map<String, String> map = new HashMap<>();
        map.put("name", "小李飞刀");
        map.put("sex", "男");

        //先生成一个json方便理解
        String json = objectMapper.writeValueAsString(map);
        System.out.println(json);//{"sex":"男","name":"小李飞刀"}

        /*
         开始反序列化
         */
        Map<String,String> map1 = new HashMap<>();
        //我之前是这么写的直接 Map.class 总觉得不妥，感觉他用了默认的推断，然后程序也能正常运行
        map1 = objectMapper.readValue(json, Map.class);
        System.out.println(map1.get("name"));


    }
}
```

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612110152184-1656700447.png)

 

***\**\*![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612110517683-1016725648.png)\*\**\***

 



 

***\**\*我们调试一下代码看下，\*\**\***

 

***\**\*![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612110913724-888018094.png)\*\**\***

 



 



 

 

***\**\*![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612110729165-106303846.png)\*\**\***

 



 

 

 

 ![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612111159521-1311895184.png)

 

 

 

**显然这种方式，不好，1. 编译时 会有 泛型警告。2. 不完美 虽然能用，但是不要这样。那么 Map时 应该如何 反序列化呢，看如下代码：**

 

 

```
map1 = objectMapper.readValue(json, new TypeReference<Map<String, String>>() {}); //用这个
```

 

 

**我们来调试看下，这次是否清晰说明了 map1的类型。**

 

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612111602367-952117262.png)

 

 

 

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612111752999-1443125463.png)

 

 

 ![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612111924783-1623058030.png)

 

 

 

 

**好了，干完了 map，接下来还有一个常用的List<Bean> ，我们调试看下：**

```
public class TestMain4 {
    public static void main(String[] args) throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();

        String json = "[{\"userName\":\"小李飞刀\",\"age\":18,\"addTime\":123}, {\"userName\":\"小李飞刀2\",\"age\":182,\"addTime\":1234}]";

        List<UserBase> userBaseList = objectMapper.readValue(json, List.class);

        System.out.println(userBaseList.get(0).getUserName());
    }
}
```

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612112818424-856007296.png)

先不调试了，需要这么写：

```
List<UserBase> userBaseList = objectMapper.readValue(json, new TypeReference<List<UserBase>>() {});
```

 

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612113347123-275468904.png)

 

 

 

**上面是直接把Json, 转换成 List<bean>，关于直接转换成 Bean数组的问题即，直接把 json转换成 bean[]，也是用 TypeReference 就可：看如下代码：**

 

```
public class TestMain4 {
    public static void main(String[] args) throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();

        String json = "[{\"userName\":\"小李飞刀\",\"age\":18,\"addTime\":123}, {\"userName\":\"小李飞刀2\",\"age\":182,\"addTime\":1234}]";

        UserBase[] userBaseAry = objectMapper.readValue(json, new TypeReference<UserBase[]>() {});

        System.out.println(userBaseAry[0].getUserName());
    }
}
```

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612114255694-329421686.png)

===================================================================================================

由于 objectMapper 一共有3个重载，我们已经讲了 2个，还有一个 我们看下他的用法，这个不常用，以后尽量少用 会不用，写代码 没有上面2种 来的直接和方便。

 

![img](https://img2020.cnblogs.com/blog/307031/202006/307031-20200612114727762-1220983823.png)

 

 

不浪费时间了，直接粘贴网上的文章：

来源：https://www.cnblogs.com/gaomanito/p/9591730.html

```java
复制代码
ObjectMapper mapper = new ObjectMapper();
　　// 排除json字符串中实体类没有的字段
　　objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES,false);



String json = "[{\"name\":\"a\",\"password\":\"345\"},{\"name\":\"b\",\"password\":\"123\"}]";
        
//第一种方法
List<User> list = mapper.readValue(json, new TypeReference<List<User>>(){/**/});
        
//第二种方法
JavaType javaType = mapper.getTypeFactory().constructCollectionType(List.class, User.class);
List<User> list2 = mapper.readValue(json, javaType);
复制代码
 

Jackson，我感觉是在Java与Json之间相互转换的最快速的框架，当然Google的Gson也很不错，但是参照网上有人的性能测试，看起来还是Jackson比较快一点

    Jackson处理一般的JavaBean和Json之间的转换只要使用ObjectMapper 对象的readValue和writeValueAsString两个方法就能实现。但是如果要转换复杂类型Collection如 List<YourBean>，那么就需要先反序列化复杂类型 为泛型的Collection Type。

如果是ArrayList<YourBean>那么使用ObjectMapper 的getTypeFactory().constructParametricType(collectionClass, elementClasses);

如果是HashMap<String,YourBean>那么 ObjectMapper 的getTypeFactory().constructParametricType(HashMap.class,String.class, YourBean.class);

复制代码
public final ObjectMapper mapper = new ObjectMapper(); 
     
    public static void main(String[] args) throws Exception{  
        JavaType javaType = getCollectionType(ArrayList.class, YourBean.class); 
        List<YourBean> lst =  (List<YourBean>)mapper.readValue(jsonString, javaType); 
    }   
       /**   
        * 获取泛型的Collection Type  
        * @param collectionClass 泛型的Collection   
        * @param elementClasses 元素类   
        * @return JavaType Java类型   
        * @since 1.0   
        */   
    public static JavaType getCollectionType(Class<?> collectionClass, Class<?>... elementClasses) {   
        return mapper.getTypeFactory().constructParametricType(collectionClass, elementClasses);   
    }
复制代码
 复杂类型转换

复制代码
ObjectMapper objectMapper = new ObjectMapper();
// 排除json字符串中实体类没有的字段
objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
PledgeCertificate pledgeCertificate;
Pledge pledge = new Pledge();
try {
      pledgeCertificate = objectMapper.readValue(requestBody, PledgeCertificate.class);
      pledge = objectMapper.readValue(requestBody, Pledge.class);
　　   Map<String, Object> map = objectMapper.readValue(requestBody, Map.class);
      String writeValueAsString = objectMapper.writeValueAsString(map.get("obligee"));
      JavaType javaType = objectMapper.getTypeFactory().constructParametricType(List.class, Obligee.class);
      List<Obligee> obligee = objectMapper.readValue(writeValueAsString,javaType);
}catch (IOException e) {
      return “转换错误”;
}

数据格式：（实体类没有obligee字段，先排除）
{
“certificate”:"豫(2016)郑州市不动产权第0026369号",
“debtEnd”: "yyyy-mm-dd",
“debtStart”: "yyyy-mm-dd",
“pledgeType”: "2",
“maxDebtAmount”:88,
“registType”:"0201",
“obligee” :[{
"obligeeType":"1","name":张三","certType":"1","certNo":"4114211..."},{
"obligeeType":"1","name":"李四","certType":"1","certNo":"4114211..."}]
}
复制代码
 

{

“certificate”:"豫(2016)郑州市不动产权第0026369号",

“debtEnd”: "yyyy-mm-dd",

“debtStart”: "yyyy-mm-dd",

“pledgeType”: "2",

“maxDebtAmount”:88,

“registType”:"0201",

“obligee” :[{

"obligeeType":"1","name":张三","certType":"1","certNo":"4114211..."},{

"obligeeType":"1","name":"李四","certType":"1","certNo":"4114211..."}]

}

```

来源：https://www.cnblogs.com/surge/p/9046223.html

```
Jackson 处理复杂类型(List,map)两种方法
 

方法一:

String jsonString="[{'id':'1'},{'id':'2'}]";  
ObjectMapper mapper = new ObjectMapper();  
JavaType javaType = mapper.getTypeFactory().constructParametricType(List.class, Bean.class);  
//如果是Map类型  mapper.getTypeFactory().constructParametricType(HashMap.class,String.class, Bean.class);  
List<Bean> lst =  (List<Bean>)mapper.readValue(jsonString, javaType);   
 

方法二:

String jsonString="[{'id':'1'},{'id':'2'}]";  
ObjectMapper mapper = new ObjectMapper();  
List<Bean> beanList = mapper.readValue(jsonString, new TypeReference<List<Bean>>() {});
```

