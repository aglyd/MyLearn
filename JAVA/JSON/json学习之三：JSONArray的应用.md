# [json学习之三：JSONArray的应用](https://www.cnblogs.com/henryxu/archive/2013/03/10/2952738.html)

从json数组中得到相应java数组，如果要获取java数组中的元素，只需要遍历该数组。

```java
/**
      * 从json数组中得到相应java数组
      * JSONArray下的toArray()方法的使用
      * @param str
      * @return
      */
      public static Object[] getJsonToArray(String str) {
          JSONArray jsonArray = JSONArray.fromObject(str);
          return jsonArray.toArray();
      }

   public static void main(String[] args) {
        JSONArray jsonStrs = new JSONArray();
        jsonStrs.add(0, "cat");
        jsonStrs.add(1, "dog");
        jsonStrs.add(2, "bird");
        jsonStrs.add(3, "duck");

        Object[] obj=getJsonToArray(jsonStrs.toString());
        for(int i=0;i<obj.length;i++){
              System.out.println(obj[i]);
        }
    }
```

从json数组中得到java数组，可以对该数组进行转化，如将JSONArray转化为String型、Long型、Double型、Integer型、Date型等等。 
分别采用jsonArray下的getString(index)、getLong(index)、getDouble(index)、getInt(index)等方法。 
同样，如果要获取java数组中的元素，只需要遍历该数组。

```java
/**
      * 将json数组转化为Long型
      * @param str
      * @return
      */
     public static Long[] getJsonToLongArray(String str) {
          JSONArray jsonArray = JSONArray.fromObject(str);
          Long[] arr=new Long[jsonArray.size()];
          for(int i=0;i<jsonArray.size();i++){
              arr[i]=jsonArray.getLong(i);
              System.out.println(arr[i]);
          }
          return arr;
    }
     /**
      * 将json数组转化为String型
      * @param str
      * @return
      */
     public static String[] getJsonToStringArray(String str) {
          JSONArray jsonArray = JSONArray.fromObject(str);
          String[] arr=new String[jsonArray.size()];
          for(int i=0;i<jsonArray.size();i++){
              arr[i]=jsonArray.getString(i);
              System.out.println(arr[i]);
          }
          return arr;
    }
     /**
      * 将json数组转化为Double型
      * @param str
      * @return
      */
     public static Double[] getJsonToDoubleArray(String str) {
          JSONArray jsonArray = JSONArray.fromObject(str);
          Double[] arr=new Double[jsonArray.size()];
          for(int i=0;i<jsonArray.size();i++){
              arr[i]=jsonArray.getDouble(i);
          }
          return arr;
    }
     /**
      * 将json数组转化为Date型
      * @param str
      * @return
      */
     public static Date[] getJsonToDateArray(String jsonString) {

          JSONArray jsonArray = JSONArray.fromObject(jsonString);
          Date[] dateArray = new Date[jsonArray.size()];
          String dateString;
          Date date;
          SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
          for (int i = 0; i < jsonArray.size(); i++) {
              dateString = jsonArray.getString(i);
              try {
                  date=sdf.parse(dateString);
                  dateArray[i] = date;
              } catch (Exception e) {
                  e.printStackTrace();
              }
          }
          return dateArray;
    }


 public static void main(String[] args) {

        JSONArray jsonLongs = new JSONArray();
        jsonLongs.add(0, "111");
        jsonLongs.add(1, "222.25");
        jsonLongs.add(2, new Long(333));
        jsonLongs.add(3, 444);

        Long[] log=getJsonToLongArray(jsonLongs.toString());
        for(int i=0;i<log.length;i++){
            System.out.println(log[i]);
        }

        JSONArray jsonStrs = new JSONArray();
        jsonStrs.add(0, "2011-01-01");
        jsonStrs.add(1, "2011-01-03");
        jsonStrs.add(2, "2011-01-04 11:11:11");

        Date[] d=getJsonToDateArray(jsonStrs.toString());
        for(int i=0;i<d.length;i++){
            System.out.println(d[i]);
        }
    }
  /*结果如下：
     * 111
     * 222
     * 333
     * 444
     *
     * Sat Jan 01 00:00:00 CST 2011
     * Mon Jan 03 00:00:00 CST 2011
     * Tue Jan 04 00:00:00 CST 2011
     */
```

方法三：

```java
String[] repGroup = ((JSONArray)param.get("repGroup")).toArray(new String[]{});     
1
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200423175937965.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3h5NDA1NTgwMzY0,size_16,color_FFFFFF,t_70)



------



# [Java中Json转List方法][http://www.51gjie.com/java/755.html]

Java利用Json-lib包进行json字符串转换成List集合

### JSONArray转换List用法实例

```java
public void JSON2List() {
    try {
        fail("==============JSON Arry String >>> Java List ==================");
        String json = "{\"address\":\"chian\",\"birthday\":{\"birthday\":\"2010-11-22\"}," + "\"email\":\"email@123.com\",\"id\":22,\"name\":\"tom\"}";
        json = "[" + json + "]";
        jsonArray = JSONArray.fromObject(json);
        List < Student > list = JSONArray.toList(jsonArray, Student.class);
        System.out.println(list.size());
        System.out.println(list.get(0));

        list = JSONArray.toList(jsonArray);
        System.out.println(list.size());
        System.out.println(list.get(0)); //MorphDynaBean
    } catch(Exception e) {
        e.printStackTrace();
    }
}
```

执行结果：

```
==============JSON Arry String >>> Java List ==================
1
tom#22#chian#2010-11-22#email@123.com
1
net.sf.ezmorph.bean.MorphDynaBean@141b571[{id=22, birthday=net.sf.ezmorph.bean.MorphDynaBean@b23210[{birthday=2010-11-22}], address=chian, email=email@123.com, name=tom}]
```

### JSONSerializer转换List方法实例

```
String json = "[\"first\",\"second\"]";
JSONArray jsonArray = (JSONArray) JSONSerializer.toJSON(json);
List output = (List) JSONSerializer.toJava(jsonArray);
```



----



```java
//json转list
List<Map> mapList = JSON.parseObject(data, (Type) List.class) //转换为什么type类型对象
或
List<String> ids = JSONArray.parseArray(idsJson, String.class);	//转为List，list中的元素对象类型为String
```



-----



# [Java 语言 ArrayList 和 JSONArray 相互转换](https://www.cnblogs.com/miracle-luna/p/11143702.html)

## 1、ArrayList 转成 JSONArray

简单总结了 **6 种** 方法（**推荐 第5、6种**），代码如下：

[![复制代码](json学习之三：JSONArray的应用.assets/copycode.gif)](javascript:void(0);)

```java
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import java.util.ArrayList;

/**
 * @author Miracle Luna
 * @version 1.0
 * @date 2019/7/5 17:43
 */
public class ArrayListToJSONArray {
    public static void main(String[] args) {
        ArrayList<Student> studentList = new ArrayList<Student>();
        JSONArray studentJsonArray = new JSONArray();

        Student John = new Student("John", 16,"boy");
        Student Lily = new Student("Lily", 17, "girl");
        Student Jack = new Student("Jack", 18, "boy");

        studentList.add(John);
        studentList.add(Lily);
        studentList.add(Jack);

        System.out.println("=============== studentList info ================");
        System.out.println(studentList.toString());

        // 方式 1
        studentJsonArray = JSON.parseArray(JSONObject.toJSONString(studentList));
        System.out.println("\n方式 1: " + studentJsonArray.toJSONString());

        // 方式 2
        studentJsonArray = JSON.parseArray(JSON.toJSONString(studentList));
        System.out.println("\n方式 2: " + studentJsonArray.toJSONString());

        // 方式 3
        studentJsonArray = JSONObject.parseArray(JSONObject.toJSONString(studentList));
        System.out.println("\n方式 3: " + studentJsonArray.toJSONString());

        // 方式 4
        studentJsonArray = JSONObject.parseArray(JSON.toJSONString(studentList));
        System.out.println("\n方式 4: " + studentJsonArray.toJSONString());

        // 方式 5（推荐）
        studentJsonArray = JSONArray.parseArray(JSONObject.toJSONString(studentList));
        System.out.println("\n方式 5: " + studentJsonArray.toJSONString());

        // 方式 6（推荐）
        studentJsonArray = JSONArray.parseArray(JSON.toJSONString(studentList));
        System.out.println("\n方式 6: " + studentJsonArray.toJSONString());

        System.out.println("\n============== Lambda 表达式 遍历 JSONArray ============");
        studentJsonArray.forEach(student -> System.out.println("student info: " + student));
    }
}
```

执行结果如下：

```java
=============== studentList info ================
[Student{name='John', age=16, gender='boy'}, Student{name='Lily', age=17, gender='girl'}, Student{name='Jack', age=18, gender='boy'}]

方式 1: [{"gender":"boy","name":"John","age":16},{"gender":"girl","name":"Lily","age":17},{"gender":"boy","name":"Jack","age":18}]

方式 2: [{"gender":"boy","name":"John","age":16},{"gender":"girl","name":"Lily","age":17},{"gender":"boy","name":"Jack","age":18}]

方式 3: [{"gender":"boy","name":"John","age":16},{"gender":"girl","name":"Lily","age":17},{"gender":"boy","name":"Jack","age":18}]

方式 4: [{"gender":"boy","name":"John","age":16},{"gender":"girl","name":"Lily","age":17},{"gender":"boy","name":"Jack","age":18}]

方式 5: [{"gender":"boy","name":"John","age":16},{"gender":"girl","name":"Lily","age":17},{"gender":"boy","name":"Jack","age":18}]

方式 6: [{"gender":"boy","name":"John","age":16},{"gender":"girl","name":"Lily","age":17},{"gender":"boy","name":"Jack","age":18}]

============== Lambda 表达式 遍历 JSONArray ============
student info: {"gender":"boy","name":"John","age":16}
student info: {"gender":"girl","name":"Lily","age":17}
student info: {"gender":"boy","name":"Jack","age":18}
```

## 2、JSONArray 转成 ArrayList

简单总结了 **7 种** 方法（**推荐前 4种**），代码如下：



```java
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import java.util.*;

/**
 * @author Miracle Luna
 * @version 1.0
 * @date 2019/7/5 18:36
 */
public class JSONArrayToArrayList {
    public static void main(String[] args) {
        JSONArray studentJSONArray = new JSONArray();
        List<Student> studentList = new ArrayList<Student>();

        Map<String, Object> JohnMap = new HashMap<String, Object>();
        JohnMap.put("name", "John");
        JohnMap.put("age", 16);
        JohnMap.put("gender", "boy");
        JSONObject John = new JSONObject(JohnMap);

        Map<String, Object> LilyMap = new HashMap<String, Object>();
        LilyMap.put("name", "Lily");
        LilyMap.put("age", 17);
        LilyMap.put("gender", "girl");
        JSONObject Lily = new JSONObject(LilyMap);

        Map<String, Object> JackMap = new HashMap<String, Object>();
        JackMap.put("name", "Jack");
        JackMap.put("age", 18);
        JackMap.put("gender", "boy");
        JSONObject Jack = new JSONObject(JackMap);

        studentJSONArray.add(John);
        studentJSONArray.add(Lily);
        studentJSONArray.add(Jack);

        System.out.println("\n=============== studentJSONArray info ================");
        System.out.println(studentJSONArray);

        System.out.println("\n=============== JSONArray to ArrayList(方式 1) ================");
        studentList = studentJSONArray.toJavaList(Student.class);
        studentList.forEach(student -> System.out.println("student info: " + student));

        System.out.println("\n=============== JSONArray to ArrayList(方式 2) ================");
        studentList = JSON.parseArray(studentJSONArray.toJSONString(), Student.class);
        studentList.forEach(student -> System.out.println("student info: " + student));

        System.out.println("\n=============== JSONArray to ArrayList(方式 3) ================");
        studentList = JSONObject.parseArray(studentJSONArray.toJSONString(), Student.class);
        studentList.forEach(student -> System.out.println("student info: " + student));

        System.out.println("\n=============== JSONArray to ArrayList(方式 4) ================");
        studentList = JSONArray.parseArray(studentJSONArray.toJSONString(), Student.class);
        studentList.forEach(student -> System.out.println("student info: " + student));

        System.out.println("\n=============== JSONArray to ArrayList(方式 5) ================");
        final ArrayList<Student> tmpList = new ArrayList<Student>();
        studentJSONArray.forEach(studentJson -> {
            JSONObject jsonObject = (JSONObject)studentJson;
            Student student = new Student(jsonObject.getString("name"), jsonObject.getInteger("age"), jsonObject.getString("gender"));
            tmpList.add(student);
        });

        studentList = tmpList;
        studentList.forEach(student -> System.out.println("student info: " + student));

        System.out.println("\n=============== JSONArray to ArrayList(方式 6) ================");
        studentList.clear();
        for (Object object : studentJSONArray) {
            JSONObject jsonObject = (JSONObject)object;
            Student student = new Student(jsonObject.getString("name"), jsonObject.getInteger("age"), jsonObject.getString("gender"));
            studentList.add(student);
        }
        studentList.forEach(student -> System.out.println("student info: " + student));

        System.out.println("\n=============== JSONArray to ArrayList(方式 7) ================");
        studentList.clear();
        for (int i = 0; i < studentJSONArray.size(); i++) {
            JSONObject jsonObject = (JSONObject)studentJSONArray.get(i);
            Student student = new Student(jsonObject.getString("name"), jsonObject.getInteger("age"), jsonObject.getString("gender"));
            studentList.add(student);
        }
        studentList.forEach(student -> System.out.println("student info: " + student));
    }
}
```



执行结果如下：

```java
=============== studentJSONArray info ================
[{"gender":"boy","name":"John","age":16},{"gender":"girl","name":"Lily","age":17},{"gender":"boy","name":"Jack","age":18}]

=============== JSONArray to ArrayList(方式 1) ================
student info: Student{name='John', age=16, gender='boy'}
student info: Student{name='Lily', age=17, gender='girl'}
student info: Student{name='Jack', age=18, gender='boy'}

=============== JSONArray to ArrayList(方式 2) ================
student info: Student{name='John', age=16, gender='boy'}
student info: Student{name='Lily', age=17, gender='girl'}
student info: Student{name='Jack', age=18, gender='boy'}

=============== JSONArray to ArrayList(方式 3) ================
student info: Student{name='John', age=16, gender='boy'}
student info: Student{name='Lily', age=17, gender='girl'}
student info: Student{name='Jack', age=18, gender='boy'}

=============== JSONArray to ArrayList(方式 4) ================
student info: Student{name='John', age=16, gender='boy'}
student info: Student{name='Lily', age=17, gender='girl'}
student info: Student{name='Jack', age=18, gender='boy'}

=============== JSONArray to ArrayList(方式 5) ================
student info: Student{name='John', age=16, gender='boy'}
student info: Student{name='Lily', age=17, gender='girl'}
student info: Student{name='Jack', age=18, gender='boy'}

=============== JSONArray to ArrayList(方式 6) ================
student info: Student{name='John', age=16, gender='boy'}
student info: Student{name='Lily', age=17, gender='girl'}
student info: Student{name='Jack', age=18, gender='boy'}

=============== JSONArray to ArrayList(方式 7) ================
student info: Student{name='John', age=16, gender='boy'}
student info: Student{name='Lily', age=17, gender='girl'}
student info: Student{name='Jack', age=18, gender='boy'}
```