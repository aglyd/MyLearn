# [List集合排序总结](https://blog.csdn.net/weixin_42585386/article/details/123735556)

## 1、Collections.sort(java对象)

​        这种方式需要满足以下条件：
​    1.1、list集合中元素的数据类型是一个java对象；

​    1.2、该java对象必须实现Comparable类；

​    1.3、重写compareTo方法；

​    其中 compareTo 方法用于指示当前元素与其他元素的比较规则，一般都是以 a - b 的形式返回int类型，表示排序规则为从 a 到 b 排序，其逻辑理解就是：**如果compareTo方法返回值小于0，则当前元素往前放，大于0，则往后放（升序），反之则降序。**

Student实体类：

```java
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Student implements Comparable<Student> {
private String name;
 
private int age;
 
@Override
public int compareTo(Student stu) {
	return getAge() - stu.getAge();
}
}
```

测试：

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1=new Student("小米",1);
		Student stu2=new Student("小王",2);
		Student stu3=new Student("小明",3);
 
		List<Student> list=new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
 
		System.out.println("排序后：");
		Collections.sort(list);
		System.out.println(list);
	}
}
```

打印结果：升序排列

```java
排序后从左到右：	Student stu1=new Student("小米",1);
		Student stu2=new Student("小王",2);
		Student stu3=new Student("小明",3);
```



##  2、Collections.sort(java对象集合, new Comparator<>() {});

​        这种方式与需要满足以下条件：
​    1.1、list集合中元素的数据类型是一个java对象；

​    1.2、重写compare方法；

**Comparator 和 Comparable 的区别和理解：**

**Comparator 可以看成是外部比较器，因为它是先有list集合，然后再对list集合用比较器去排序；**

**Comparable 可以看成是内部比较器，因为它是直接在java对象实现类添加了比较器，因此是先有比较器，然后再对list集合用比较器去排序；**

从上面两点，也可以推测出 **Comparable 的排序算法的效率应该是比 Comparator 要高效的**。

Comparator ：使用了匿名内部类来构建了一个Comparator比较器对象，从而实现排序，**优点是：不需要在创建java对象时，实现 Comparable 接口，缺点是效率比 Comparable  要低一些。**

Student实体类：

```java
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Student{
private String name;
 
private int age;
}
```

测试：

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1 = new Student("小米", 1);
		Student stu2 = new Student("小王", 2);
		Student stu3 = new Student("小明", 3);
 
		List<Student> list = new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
 
		System.out.println("排序后：");
		Collections.sort(list, new Comparator<Student>() {
			@Override
			public int compare(Student stu1, Student stu2) {
				return stu1.getAge() - stu2.getAge();
			}
		});
		System.out.println(list);
        
	}
}
```

打印结果：

排序结果同上

拓展：
        **根据 JAVA8 的 lambda 表达式上面Comparator比较器的代码可以简写成以下代码：**

```java
//传入Comparator重写compare方法实现倒序
Collections.sort(list, (stu11, stu21) -> stu11.getAge() - stu21.getAge());

// 再进一步简化成如下代码：注意：但是此简化方式不可以使用.reversed()倒序，而上面的方式可以反转两个参数顺序即可实现倒序
Collections.sort(list, Comparator.comparingInt(Student::getAge));
//或
Collections.sort(list, Comparator.comparing(Student::getAge));
//java8 stram流中传入Comparator重写compare方法实现倒序
list = list.stream.sort(list, (stu11, stu21) -> stu21.getAge() - stu11.getAge()).collect(Collectors.toList());
```

通过查询 comparing开头的方法，可以看见：

![img](https://img-blog.csdnimg.cn/a8a06d9381e64efca55fcbd837db7fd5.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_20,color_FFFFFF,t_70,g_se,x_16)

经过我的测试发现comparing兼容了下面三种基于整型数据的方法：

![img](https://img-blog.csdnimg.cn/8d04925852d046ed8e80865d7010618d.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_11,color_FFFFFF,t_70,g_se,x_16)

显然用comparing很省事，但是**一般兼容性越高，效率也就越低，可以推测出comparing方法内部肯定是有一重判断了参数的数据类型的逻辑，这会降低代码执行效率**；因此，如果是整型数据的话，建议使用上面三种与数据类型对应的方法，而如果是字符串的话，就使用comparing。

简化后：

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1 = new Student("小米", 1);
		Student stu2 = new Student("小王", 2);
		Student stu3 = new Student("小明", 3);
 
		List<Student> list = new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
 
		System.out.println("排序后：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge));
		System.out.println(list);
	}
}
```

打印结果：

同上

可以看出这是升序排序的，那么如何降序呢？

由于降序=升序的倒序，所以可以使用倒序的方法**【.reversed()】**实现降序：

但是注意：Comparator.comparing()方法有两种用法：

1. **==Comparator.comparing(类名::方法名).reversed()==**，此方式可实现升序倒序

2. ==**Collections.sort(list, Comparator.comparing(student -> student.getAge()));**==，

   **==第二种方式不可以使用.reversed实现升序排序，即Collections.sort(list, Comparator.comparing(student -> student.getAge()).reversed());会报错找不到.getAge()方法（但是传入Studeng::getAge可以正常使用），且该方式只可以填入一个入参，不可以传入自定义排序方法即==**

   ```java
   //都会报错，第二个参数的方法会找不到
   //Collections.sort(rows2,Comparator.comparing((s1,s2) -> s1.getName().compareTo(s2.getName)));	
   //Collections.sort(rows2,Comparator.comparing((s1,s2) -> s1.getAge() - s2.getAge));
   
   //会报错，s.getCompanyCode()方法找不到
   //Collections.sort(rows2,Comparator.comparing(s -> s.getAge()).reversed());   
   Collections.sort(rows2,Comparator.comparing(Student::getAge).reversed());    //可以正常降序
   ```

==**因此如果用Comparator给普通java对象集合根据某属性降序排列，可以用`Comparator.comparing(类名::方法名).reversed()`的方式实现，但如果要给List<Map>根据某字段排序则不可以使用，因为Map没有特定方法，不能使用第一种方式，而第二种方式可以使用`Collections.sort(listMap, Comparator.comparing(map-> map.get("column")));`实现降序排序，但是无法做到升序排序，如果要给LIst<Map>集合做升序，可以使用list.stream().sorted()或Collections.sort()传入Comparator重写compare比较方法的方式（下面会讲）**==



```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1 = new Student("小米", 1);
		Student stu2 = new Student("小王", 2);
		Student stu3 = new Student("小明", 3);
 
		List<Student> list = new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
 
		System.out.println("排序后：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge));
		System.out.println(list);
        System.out.println("倒序后：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).reversed());
		System.out.println(list);
	}
}
```

打印结果：

![img](https://img-blog.csdnimg.cn/d609ecec0dcc419890d16bfc4c2d0685.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_20,color_FFFFFF,t_70,g_se,x_16)

### 多条件排序：

Student实体类：

	@Data
	@AllArgsConstructor
	public class Student{
	 
		private String name;
	 
		private int age;
	 
		private double grade;
	 
		private int tall;
	 
	}
	}


测试：

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1 = new Student("小米", 20, 95.0, 175);
		Student stu2 = new Student("小王", 20, 90.5, 175);
		Student stu3 = new Student("小明", 20, 90.0, 180);
 
		List<Student> list = new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
		System.out.println("排序后：");
		Collections.sort(list, Comparator.comparingInt(Student::getTall));
		System.out.println(list);
		System.out.println("倒序后：");
		Collections.sort(list, Comparator.comparingInt(Student::getTall).reversed());
		System.out.println(list);
 
		System.out.println("1.按年龄升序、分数升序、身高升序排序：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).thenComparingInt(Student::getTall));
		System.out.println(list);
		System.out.println("2.按年龄升序、分数升序、身高降序序排序：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).thenComparingInt(Student::getTall).reversed());
		System.out.println(list);
		System.out.println("3.按年龄升序、分数降序、身高升序排序：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).reversed().thenComparingInt(Student::getTall));
		System.out.println(list);
		System.out.println("4.按年龄升序、分数降序、身高降序序排序：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).reversed().thenComparingInt(Student::getTall).reversed());
		System.out.println(list);
		System.out.println("5.按年龄升序、身高升序、分数升序排序：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).thenComparingInt(Student::getTall).thenComparingDouble(Student::getGrade));
		System.out.println(list);
		System.out.println("6.按年龄升序、身高升序、分数降序序排序：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).thenComparingInt(Student::getTall).thenComparingDouble(Student::getGrade).reversed());
		System.out.println(list);
		System.out.println("7.按年龄升序、身高降序、分数升序排序：");
		Collections.sort(list, Comparator.comparingInt(Student::getAge).thenComparingInt(Student::getTall).reversed().thenComparingDouble(Student::getGrade));
		System.out.println(list);
		System.out.println("8.按年龄升序、身高降序、分数降序序排序：");
		Collections.sort(list, Comparator.comparing(Student::getAge).thenComparing(Student::getGrade).reversed().thenComparing(Student::getTall).reversed());
		System.out.println(list);
	}
}
```

打印结果：

![img](https://img-blog.csdnimg.cn/2e87938af1044ecd943e17a92a810b87.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_20,color_FFFFFF,t_70,g_se,x_16)

## 3、list.stream().sorted()

**JAVA8 之后，引入了stream流操作，可以极大提高集合的链式操作效率**，关于stream流操作不太清楚的小伙伴，可以自行查阅资料，比较简单，这里就不再拓展了；

这里要提的是stream流操作中的 sorted()方法可以用于排序，其逻辑原理和上面第二种 Comparator 的排序方式是一样的。

这种方式与需要满足以下条件：
    1.1、list集合中元素的数据类型是一个java对象；

​    1.2、引入stream流操作规范；

优点：排序算法效率高。

 Student实体类：

```java
import lombok.AllArgsConstructor;
import lombok.Data;
 
@Data
@AllArgsConstructor
public class Student{
 
	private String name;
 
	private int age;
 
}
```

测试：

```java
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1 = new Student("小米", 1);
		Student stu2 = new Student("小王", 2);
		Student stu3 = new Student("小明", 3);
 
		List<Student> list = new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
 
		System.out.println("排序后：");
		list = list.stream().sorted(Comparator.comparing(Student::getAge)).collect(Collectors.toList());
		System.out.println(list);
	}
}
```

打印结果：

排序后：1——>2——>3

同样的以使用倒序的方法**【.reversed()】实现降序**：

```java
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1 = new Student("小米", 1);
		Student stu2 = new Student("小王", 2);
		Student stu3 = new Student("小明", 3);
 
		List<Student> list = new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
 
		System.out.println("排序后：");
		list = list.stream().sorted(Comparator.comparing(Student::getAge)).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("倒序后：");
		list = list.stream().sorted(Comparator.comparing(Student::getAge).reversed()).collect(Collectors.toList());
		System.out.println(list);
	}
}
```

打印结果：

倒序后：3-->2-->1

   拓展：

​     很多使用不仅需要对单一字段进行排序，还需要多个字段排序，因此多条件排序很重要！

### 多条件排序：

 Student实体类：

```java
import lombok.AllArgsConstructor;
import lombok.Data;
 
@Data
@AllArgsConstructor
public class Student{
 
	private String name;
 
	private int age;
 
	private double grade;
 
	private int tall;
 
}
```

测试：

```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
 
public class TestUtil {
	public static void main(String[] args) {
		Student stu1 = new Student("小米", 20, 95.0, 175);
		Student stu2 = new Student("小王", 20, 90.5, 175);
		Student stu3 = new Student("小明", 20, 90.0, 180);
 
		List<Student> list = new ArrayList<>();
		list.add(stu2);
		list.add(stu1);
		list.add(stu3);
 
		System.out.println("排序前：");
		System.out.println(list);
 
		System.out.println("1.按年龄升序、分数升序、身高升序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).thenComparingInt(Student::getTall)).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("2.按年龄升序、分数升序、身高降序序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).thenComparingInt(Student::getTall).reversed()).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("3.按年龄升序、分数降序、身高升序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).reversed().thenComparingInt(Student::getTall)).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("4.按年龄升序、分数降序、身高降序序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingDouble(Student::getGrade).reversed().thenComparingInt(Student::getTall).reversed()).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("5.按年龄升序、身高升序、分数升序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingInt(Student::getTall).thenComparingDouble(Student::getGrade)).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("6.按年龄升序、身高升序、分数降序序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingInt(Student::getTall).thenComparingDouble(Student::getGrade).reversed()).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("7.按年龄升序、身高降序、分数升序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingInt(Student::getTall).reversed().thenComparingDouble(Student::getGrade)).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("8.按年龄升序、身高降序、分数降序序排序：");
		list = list.stream().sorted(Comparator.comparingInt(Student::getAge).thenComparingInt(Student::getTall).reversed().thenComparingDouble(Student::getGrade).reversed()).collect(Collectors.toList());
		System.out.println(list);
	}
}
```

![img](https://img-blog.csdnimg.cn/58676d2e776549ffbd2c10a181e456de.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_20,color_FFFFFF,t_70,g_se,x_16)打印结果：



### 对List< Map >集合降序

**==1、使用Comparator.comparing()方法先升序排列，再使用Collections.reverse(list);倒序实现降序==**

**==2、使用java8 lambda表达式方式写传入Comparator重写compare方法自定义排序==**

```java
public static void test1(){
List<Map<String,String>> rows = new ArrayList<>();
List<Student> rowsS = new ArrayList<>();
       
        Map map1 = new HashMap();
        Map map2 = new HashMap();
        Map map3 = new HashMap();
        Map map4 = new HashMap();
        map1.put("REAL_INTEREST_RATE", "0.3274");
        map2.put("REAL_INTEREST_RATE", "0.4555");
        map3.put("REAL_INTEREST_RATE", "0.2142");
        map4.put("REAL_INTEREST_RATE", "0.6432");
        rows.add(map1);
        rows.add(map2);
        rows.add(map3);
        rows.add(map4);
        
String finalSortKey = "REAL_INTEREST_RATE";
    
    //降序排列
    //方法一：先升序，再倒序
    rows = rows.stream().sorted(Comparator.comparing(m -> map.get(finalSortKey))).collect(Collectors.toList());
    //或
    //Collections.sort(rows,Comparator.comparing(m -> map.get(finalSortKey)));
    Collections.reverse(rows);
    
    
    //方法二
rows = rows.stream().sorted((m1,m2) -> new BigDecimal(m2.get(finalSortKey)).compareTo(new BigDecimal(m1.get(finalSortKey)))).collect(Collectors.toList());

rows = rows.stream().sorted((m1,m2) -> MapUtils.getDouble(m2,finalSortKey).compareTo(MapUtils.getDouble(m1,finalSortKey))).collect(Collectors.toList());
        
Collections.sort(rows,(m1,m2) -> new BigDecimal(m2.get(finalSortKey)).compareTo(new BigDecimal(m1.get(finalSortKey))));

Collections.sort(rows,(m1,m2) -> Integer.parseInt(m2.get(finalSortKey)) - (Integer.parseInt(m1.get(finalSortKey))));

    //升序：反过来m1-m2即可
rows = rows.stream().sorted((m1,m2) -> MapUtils.getDouble(m1,finalSortKey).compareTo(MapUtils.getDouble(m2,finalSortKey))).collect(Collectors.toList());
//或者使用Comparator.comparing()
rows = rows.stream().sorted(Comparator.comparing(m -> m.get(finalSortKey))).collect(Collectors.toList());

//注意这样会报错：m2.get方法会找不到
rows = rows.stream().sorted(Comparator.comparing((m1,m2) -> m1.get(finalSortKey) - m2.get(finalSortKey)))).collect(Collectors.toList());

//如果是普通自定义对象升序可以简化写法    
rowsS = rowsS.stream().sorted(Comparator.comparingInt(Student::getAge).collect(Collectors.toList());
    
}
```



## 总结：

​        **推荐使用第三种排序方法，因为stream流操作排序效率最高。**



## 4、List< JSONObject >排序

==**与List<Map>相同**==

这个其实才是这篇文章的重点，很多时候为了方便，我们会用到JSONObject或者Map对象去接收数据库返回的结果集；

​    1、例如当数据库表过多的时候，我们并不想为每个表都创建一个java实体类去接收数据；

​    2、尤其是当我们想动态的查询出自己想要的数据，而结果中的字段名很可能并不是固定的；

​    3、当然还有很多其他的复杂情况。。。

当我们使用的这一类不是由java实体类组成的List集合的时候，上面的那三种方法显然是未必适用的，于是为了应对这种情况下的排序需求，经过我的测试，总结出了下面3种情况和方法：

### 4.1、List<JSONObject>的单条件升序（默认）排序

大多数情况下，我们需要排序的时候，都是单条件排序，所以这是最基本的排序方法，基本上和第三种排序方式（list.stream().sorted()）中的单条件排序的写法很类似，所以比较简单。

测试：

```java
public class TestDemoUtil {
	public static void main(String[] args) {
		List<JSONObject> list = new ArrayList<>();
		JSONObject jsonObject1 = new JSONObject();
		JSONObject jsonObject2 = new JSONObject();
		JSONObject jsonObject3 = new JSONObject();
 
		jsonObject1.put("name", "小米");
		jsonObject1.put("age", 20);
		jsonObject1.put("grade", 95.0);
		jsonObject1.put("tail", 175);
 
		jsonObject2.put("name", "小王");
		jsonObject2.put("age", 20);
		jsonObject2.put("grade", 90.5);
		jsonObject2.put("tail", 175);
 
		jsonObject3.put("name", "小明");
		jsonObject3.put("age", 20);
		jsonObject3.put("grade", 90.0);
		jsonObject3.put("tail", 180);
		list.add(jsonObject1);
		list.add(jsonObject2);
		list.add(jsonObject3);
 
		System.out.println("排序前：");
		System.out.println(list);
		System.out.println("按成绩升序排序后：");
		list = list.stream().sorted(Comparator.comparingDouble(o -> o.getDoubleValue("grade"))).collect(Collectors.toList());
		System.out.println(list);
	}
}
```

打印结果：

![img](https://img-blog.csdnimg.cn/19c5a474936a430abe971a452027720e.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_20,color_FFFFFF,t_70,g_se,x_16)

### 4.2、List<JSONObject>的单条件降序排序

​        **==需要注意的是，和上面提到的第三种排序方式（list.stream().sorted()）不同，在对集合进行降序排序的时候，无法直接在链式链式调用后面加上【.reversed()】来实现降序了；经过测试发现list.stream().sorted()对于JSONObject这一类非自定义的java对象无法完美是使用链式调用了，原因是因为调用.reversed()不能传入Comparator.comparing(s -> 调用方法)，而必须传入Comparator.comparing(类名::方法名).reversed()，JSONObject这一类对象没有确定的属性方法，所以下面这种写法会在编译的时候报错：==**

```java
	list = list.stream().sorted(Comparator.comparingDouble(o -> o.getDoubleValue("grade")).reversed()).collect(Collectors.toList());
```
==**猜测原因应该是因为在链式调用中 getDoubleValue 会被识别为 JSONObject对象中 doubleValue属性对应的 getter方法，而该对象根本没有这个属性，所以就报错了，所以还是那句话链式调用的规则，并不适用于没有确定属性的这一类对象**==。

所以可以使用下面这种写法来解决降序的问题：

测试：

```java
public class TestDemoUtil {
	public static void main(String[] args) {
		List<JSONObject> list = new ArrayList<>();
		JSONObject jsonObject1 = new JSONObject();
		JSONObject jsonObject2 = new JSONObject();
		JSONObject jsonObject3 = new JSONObject();
 
		jsonObject1.put("name", "小米");
		jsonObject1.put("age", 20);
		jsonObject1.put("grade", 95.0);
		jsonObject1.put("tail", 175);
 
		jsonObject2.put("name", "小王");
		jsonObject2.put("age", 20);
		jsonObject2.put("grade", 90.5);
		jsonObject2.put("tail", 175);
 
		jsonObject3.put("name", "小明");
		jsonObject3.put("age", 20);
		jsonObject3.put("grade", 90.0);
		jsonObject3.put("tail", 180);
		list.add(jsonObject1);
		list.add(jsonObject2);
		list.add(jsonObject3);
 
		System.out.println("排序前：");
		System.out.println(list);
		System.out.println("按成绩升序排序后：");
		list = list.stream().sorted(Comparator.comparingDouble(o -> o.getDoubleValue("grade"))).collect(Collectors.toList());
		System.out.println(list);
		System.out.println("按成绩降序排序后：");
		list = list.stream().sorted((o1, o2) -> o2.getDoubleValue("grade") - o1.getDoubleValue("grade") > 0 ? 1 : -1).collect(Collectors.toList());
		System.out.println(list);
	}
}
```

打印结果：

![img](https://img-blog.csdnimg.cn/948c80f6f3034012834bd17633e2e359.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_20,color_FFFFFF,t_70,g_se,x_16)

###  4.3、List<JSONObject>的多条件排序

多条件排序是重点，虽然很多时候我们只需要单条件排序；但多条件排序的写法才是重点，因为这种写法是最基础的，也是兼容最强的。

测试：

```java
public class TestDemoUtil {
	public static void main(String[] args) {
		List<JSONObject> list = new ArrayList<>();
		JSONObject jsonObject1 = new JSONObject();
		JSONObject jsonObject2 = new JSONObject();
		JSONObject jsonObject3 = new JSONObject();
 
		jsonObject1.put("name", "小米");
		jsonObject1.put("age", 20);
		jsonObject1.put("grade", 95.0);
		jsonObject1.put("tail", 175);
 
		jsonObject2.put("name", "小王");
		jsonObject2.put("age", 20);
		jsonObject2.put("grade", 90.5);
		jsonObject2.put("tail", 175);
 
		jsonObject3.put("name", "小明");
		jsonObject3.put("age", 20);
		jsonObject3.put("grade", 90.0);
		jsonObject3.put("tail", 180);
		list.add(jsonObject1);
		list.add(jsonObject2);
		list.add(jsonObject3);
 
		System.out.println("排序前：");
		System.out.println(list);
		System.out.println("按成绩排序后：");
		list = list.stream().sorted(Comparator.comparingDouble(o -> o.getDoubleValue("grade"))).collect(Collectors.toList());
		System.out.println(list);
 
		System.out.println("1.按年龄升序、分数升序、身高升序排序：");
		list = list.stream().sorted((o1, o2) -> {
			int value = o1.getIntValue("age") - o2.getIntValue("age");
			if ( value == 0 ) {
				double v = o1.getDoubleValue("grade") - o2.getDoubleValue("grade");
				if ( v == 0.0 ) {
					return o1.getIntValue("tail") - o2.getIntValue("tail");
				}
				return v > 0.0 ? 1 : -1;
			}
			return value;
		}).collect(Collectors.toList());
		System.out.println(list);
 
		System.out.println("2.按年龄升序、分数降序、身高升序排序：");
		list = list.stream().sorted((o1, o2) -> {
			int value = o1.getIntValue("age") - o2.getIntValue("age");
			if ( value == 0 ) {
				double v = o2.getDoubleValue("grade") - o1.getDoubleValue("grade");
				if ( v == 0.0 ) {
					return o1.getIntValue("tail") - o2.getIntValue("tail");
				}
				return v > 0.0 ? 1 : -1;
			}
			return value;
		}).collect(Collectors.toList());
		System.out.println(list);
 
		System.out.println("3.按年龄升序、身高升序、分数降序排序：");
		list = list.stream().sorted((o1, o2) -> {
			int value = o1.getIntValue("age") - o2.getIntValue("age");
			if ( value == 0 ) {
				value = o1.getIntValue("tail") - o2.getIntValue("tail");
				if ( value == 0 ) {
					return o2.getDoubleValue("grade") - o1.getDoubleValue("grade") > 0.0 ? 1 : -1;
				}
				return value;
			}
			return value;
		}).collect(Collectors.toList());
		System.out.println(list);
	}
}
```

上面的代码可以通过提取公共方法，来提高代码复用率，由于和文章主题无关，这里就不进一步优化了。

打印结果：

 ![img](https://img-blog.csdnimg.cn/65875712ac51417380c5d313aba1fa76.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAU3RlcGhlbsK3WW917oSO,size_20,color_FFFFFF,t_70,g_se,x_16)





# [Java8 集合Map/list排序](https://blog.csdn.net/WLPJLP/article/details/115395383)

在java8之前排序一般是使用[内部类](https://so.csdn.net/so/search?q=内部类&spm=1001.2101.3001.7020)自定义排序的方式实现的，在java8中使用lambda实现，示例如下：

```java
@SuppressWarnings("ALL")
public class MyCollectionUtils {
 
    private MyCollectionUtils() {
    }
 
    /**
     * map根据key正序
     *
     * @param map 数据集合
     * @param <K> key 类型
     * @param <V> value 类型
     * @return 排序后的结果
     */
    public static <K extends Comparable<? super K>, V> Map<K, V> sortByKey(Map<K, V> map) {
        return map.entrySet().stream().sorted(Map.Entry.comparingByKey())
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (m1, m2) -> m1, LinkedHashMap::new));
    }
 
    /**
     * map根据key倒序
     *
     * @param map 数据集合
     * @param <K> key 类型
     * @param <V> value 类型
     * @return 排序后的结果
     */
    public static <K extends Comparable<? super K>, V> Map<K, V> sortByKeyReversed(Map<K, V> map) {
        return map.entrySet().stream().sorted(Map.Entry.<K, V>comparingByKey().reversed())
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (m1, m2) -> m1, LinkedHashMap::new));
    }
 
    /**
     * map根据value正序
     *
     * @param map 数据集合
     * @param <K> key 类型
     * @param <V> value 类型
     * @return 排序后的结果
     */
    public static <K, V extends Comparable<? super V>> Map<K, V> sortByValue(Map<K, V> map) {
        return map.entrySet().stream().sorted(Map.Entry.comparingByValue())
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (m1, m2) -> m1, LinkedHashMap::new));
    }
 
    /**
     * map根据value倒序
     *
     * @param map 数据集合
     * @param <K> key 类型
     * @param <V> value 类型
     * @return 排序后的结果
     */
    public static <K, V extends Comparable<? super V>> Map<K, V> sortByValueReversed(Map<K, V> map) {
        return map.entrySet().stream().sorted(Map.Entry.<K, V>comparingByValue().reversed())
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (m1, m2) -> m1, LinkedHashMap::new));
    }
 
    /**
     * list数据排序(正序)
     *
     * @param elements
     * @param <T>
     * @return
     */
    public static <T, U extends Comparable<? super U>> Iterable<? extends T> sortIterable(Collection<? extends T> collection,
                                                                                          Function<? super T, ? extends U> keyExtractor) {
        return collection.stream().sorted(Comparator.comparing(keyExtractor)).collect(Collectors.toList());
    }
 
    /**
     * list数据排序(倒序序)
     *
     * @param elements
     * @param <T>
     * @return
     */
    public static <T, U extends Comparable<? super U>> Iterable<? extends T> sortIterableReversed(Collection<? extends T> collection,
                                                                                                  Function<? super T, ? extends U> keyExtractor) {
        return collection.stream().sorted(Comparator.comparing(keyExtractor).reversed()).collect(Collectors.toList());
    }
}
```





# [Java8 ListMap sorted() 排序](https://blog.csdn.net/qq_35461948/article/details/120444008)

Java8 ListMap sorted() 排序

学习了List<Bean>排序，如果类型是List<Map>类型，处理上有什么区别吗：

**最大的区别在于倒序，List<Bean>可以直接使用reversed()方法了，List<Map>要写下 Comparator.comparing具体的内容**

代码；
数据模拟

```java
public static List<Map<String, Object>> setCpuRateValue() {
    Map<String, Object> paas = new HashMap<>(8);
    List<Map<String, Object>> neIdList = new ArrayList<>();
 
    paas.put("metric", "400000279");
    paas.put("neId", "1000000058448");
    paas.put("value", 0.92);
    neIdList.add(paas);
    Map<String, Object> iaas = new HashMap<>(8);
    iaas.put("metric", "400000273");
    iaas.put("neId", "1000000058449");
    iaas.put("value", 0.45);
    neIdList.add(iaas);
    Map<String, Object> scenes = new HashMap<>(8);
    scenes.put("metric", "400000276");
    scenes.put("neId", "1000000058450");
    scenes.put("value", 0.98);
    neIdList.add(scenes);
 
    Map<String, Object> crm = new HashMap<>(8);
    crm.put("metric", "400000279");
    crm.put("neId", "1000000058451");
    crm.put("value", 0.36);
    neIdList.add(crm);
    return neIdList;
}
 
public static List<Map<String, Object>> setCpuRateNullValue() {
    Map<String, Object> paas = new HashMap<>(8);
    List<Map<String, Object>> neIdList = new ArrayList<>();
 
    paas.put("metric", "400000279");
    paas.put("neId", "1000000058448");
    paas.put("value", 0.92);
    neIdList.add(paas);
    Map<String, Object> iaas = new HashMap<>(8);
    iaas.put("metric", "400000273");
    iaas.put("neId", "1000000058449");
    iaas.put("value", 0.45);
    neIdList.add(iaas);
    Map<String, Object> scenes = new HashMap<>(8);
    scenes.put("metric", "400000276");
    scenes.put("neId", "1000000058450");
    scenes.put("value", null);
    neIdList.add(scenes);
 
    Map<String, Object> crm = new HashMap<>(8);
    crm.put("metric", "400000279");
    crm.put("neId", "1000000058451");
    crm.put("value", null);
    neIdList.add(crm);
    return neIdList;
}
```

## 常见排序

```java
public static void main(String args[]) throws IOException, ClassNotFoundException {
    testSorted(); 
}
 
public static void testSorted() {
    List<Map<String, Object>> cpuRateList = setCpuRateValue();
 
 
    List<Map<String, Object>> valueList = cpuRateList.stream()
            .sorted(Comparator.comparing(e -> MapUtils.getDouble(e, "value"))).collect(Collectors.toList());
    System.out.println("============排序 ===========");
    valueList.forEach(System.out::println);
    // 倒序
     Collections.reverse(valueList);
    //或
    List<Map<String, Object>> reverseValueList = cpuRateList.stream()
            .sorted((c1, c2) -> MapUtils.getDouble(c2, "value").compareTo(MapUtils.getDouble(c1, "value"))).collect(Collectors.toList());
    System.out.println("============倒序===========");
    reverseValueList.forEach(System.out::println);
 
}
```

## 处理null的情况

如果排序中，值为null了，要怎么处理呢？

```java
public static void main(String args[]) throws IOException, ClassNotFoundException {     testMapWithNullSorted();
}
 
public static void testMapWithNullSorted() {
    List<Map<String, Object>> cpuRateList = setCpuRateNullValue();
 
    List<Map<String, Object>> filterValueList = cpuRateList.stream().filter(e -> MapUtils.getDouble(e, "value") != null)
            .sorted(Comparator.comparing(e -> MapUtils.getDouble(e, "value"))).collect(Collectors.toList());
    System.out.println("==========过滤null===========");
    filterValueList.forEach(System.out::println);
 
    List<Map<String, Object>> valueNullFirstList = cpuRateList.stream().sorted(Comparator.comparing(e -> MapUtils.getDouble(e, "value"), Comparator.nullsFirst(Double::compareTo))).collect(Collectors.toList());
    System.out.println("==========null排前面===========");
    valueNullFirstList.forEach(System.out::println);
    
    //奇怪的是，此方法这样用，有null还是会报空指针
//       List<Map<String, Object>> valueNullFirstList = cpuRateList.stream().sorted(Comparator.nullsFirst(Comparator.comparing(e -> MapUtils.getDouble(e, "value"))).collect(Collectors.toList());	
 
    List<Map<String, Object>> valueNullLastList = cpuRateList.stream().sorted(Comparator.comparing(e -> MapUtils.getDouble(e, "value"), Comparator.nullsLast(Double::compareTo))).collect(Collectors.toList());
    System.out.println("==========null排后面===========");
    valueNullLastList.forEach(System.out::println);
}
```



## JSONArray排序

JSONArray的排序同理。

```java
public static void main(String args[]){
    testSorted();
    testJsonWithNullSorted();
}
 
public static void testSorted() {
    JSONArray fieldList = initFiledValue();
 
    List<JSONObject> sortIdList = ListUtils.emptyIfNull(fieldList).stream().map(e -> (JSONObject) e)
            .sorted(Comparator.comparing(e -> MapUtils.getInteger(e, "sortId"))).collect(Collectors.toList());
    System.out.println("============排序 ===========");
    sortIdList.forEach(System.out::println);
    // 倒序
    List<JSONObject> reverseSortIdList = ListUtils.emptyIfNull(fieldList).stream().map(e -> (JSONObject) e)
            .sorted((c1, c2) -> MapUtils.getInteger(c2, "sortId").compareTo(MapUtils.getInteger(c1, "sortId"))).collect(Collectors.toList());
    System.out.println("============倒序===========");
    reverseSortIdList.forEach(System.out::println);
}
 
public static void testJsonWithNullSorted() {
    JSONArray fieldList = initFiledNullValue();
 
    List<JSONObject> filterValueList = ListUtils.emptyIfNull(fieldList).stream().map(e -> (JSONObject) e).filter(e -> MapUtils.getInteger(e, "sortId") != null)
            .sorted(Comparator.comparing(e -> MapUtils.getInteger(e, "sortId"))).collect(Collectors.toList());
    System.out.println("==========过滤null===========");
    filterValueList.forEach(System.out::println);
 
    List<JSONObject> valueNullFirstList = ListUtils.emptyIfNull(fieldList).stream().map(e -> (JSONObject) e).sorted(Comparator.comparing(e -> MapUtils.getInteger(e, "sortId"), Comparator.nullsFirst(Integer::compareTo))).collect(Collectors.toList());
    System.out.println("==========null排前面===========");
    valueNullFirstList.forEach(System.out::println);
 
    List<JSONObject> valueNullLastList = ListUtils.emptyIfNull(fieldList).stream().map(e -> (JSONObject) e).sorted(Comparator.comparing(e -> MapUtils.getInteger(e, "sortId"), Comparator.nullsLast(Integer::compareTo))).collect(Collectors.toList());
    System.out.println("==========null排后面===========");
    valueNullLastList.forEach(System.out::println);
}
//
public static JSONArray initFiledValue() {
    String data = "[{\n" +
            "\t\"fieldName\": \"model_name\",\n" +
            "\t\"sortId\": 2,\n" +
            "\t\"elementLabel\": \"模型名\"\n" +
            "}, {\n" +
            "\t\"elementName\": \"model_mod\",\n" +
            "\t\"sortId\": 1,\n" +
            "\t\"elementLabel\": \"模型ID\"\n" +
            "}, {\n" +
            "\t\"fieldName\": \"remark\", \n" +
            "\t\"sortId\": 3,\n" +
            "\t\"elementLabel\": \"备注\"\n" +
            "}, {\n" +
            "\t\"fieldName\": \"model_type\", \n" +
            "\t\"sortId\": 4,\n" +
            "\t\"elementLabel\": \"类型\" \n" +
            "}]";
    return JSONArray.parseArray(data);
}
 
public static JSONArray initFiledNullValue() {
    String data = "[{\n" +
            "\t\"fieldName\": \"model_name\",\n" +
            "\t\"sortId\": 2,\n" +
            "\t\"elementLabel\": \"模型名\"\n" +
            "}, {\n" +
            "\t\"elementName\": \"model_mod\",\n" +
            "\t\"sortId\": null,\n" +
            "\t\"elementLabel\": \"模型ID\"\n" +
            "}, {\n" +
            "\t\"fieldName\": \"remark\", \n" +
            "\t\"sortId\": 3,\n" +
            "\t\"elementLabel\": \"备注\"\n" +
            "}, {\n" +
            "\t\"fieldName\": \"model_type\", \n" +
            "\t\"sortId\": 4,\n" +
            "\t\"elementLabel\": \"类型\" \n" +
            "}]";
    return JSONArray.parseArray(data);
}
```

总结：
     List<Map>在处理倒序的时候，要重写下Comparator的compare方法或使用Collections.reverse(list);，其它的使用跟List<Bean>差不多。排好序，就可以进行下一步操作。



# [Java Comparator.nullsFirst | 将空元素被认为小于非空元素](https://blog.csdn.net/qq_31635851/article/details/120323320nullsFirst是比较器功能接口的静态方法。

Java 8中引入的Comparator.nullsFirst方法返回一个对null友好的比较器，认为null小于非null。

从Java源代码中找到它的声明。

static <T> Comparator<T> nullsFirst(Comparator<? super T> comparator) 
1
找到由nullsFirst方法返回的比较器的工作原理。
1. 空元素被认为小于非空元素。
2. 当两个元素都是空的时候，那么它们被认为是相等的。
3. 当两个元素都是非空的时候，指定的比较器决定了顺序。
4. 如果指定的比较器是空的，那么返回的比较器认为所有非空的元素是相等的。

使用 Comparator.nullsFirst
找到使用Comparator.nullsFirst方法的例子。

NullsFirstDemo.java

```java
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
public class NullsFirstDemo {
  public static void main(String[] args) {
	Student s1 = new Student("Ram", 18);
	Student s2 = new Student("Shyam", 22);
	Student s3 = new Student("Mohan", 17);

	System.out.println("-------Case1: One null----------");

	List<Student> list = Arrays.asList(s1, s2, null, s3);
	Collections.sort(list, Comparator.nullsFirst(Comparator.comparing(Student::getName)));	//但是这种用法对于Double，Integer等数字类型还是会报空指针
	list.forEach(s -> System.out.println(s));

	System.out.println("--------Case2: More than one null---------");

	list = Arrays.asList(s1, null, s2, null, s3);
	Collections.sort(list, Comparator.nullsFirst(Comparator.comparing(Student::getName)));
	list.forEach(s -> System.out.println(s));

	System.out.println("--------Case3: Reverse specified Comparator to nullsFirst---------");

	list = Arrays.asList(s1, null, s2, null, s3);
	Collections.sort(list, Comparator.nullsFirst(Comparator.comparing(Student::getName).reversed()));
	list.forEach(s -> System.out.println(s));

	System.out.println("--------Case4: Reverse Comparator returned by nullsFirst---------");

	list = Arrays.asList(s1, null, s2, null, s3);
	Collections.sort(list, Comparator.nullsFirst(Comparator.comparing(Student::getName)).reversed());
	list.forEach(s -> System.out.println(s));

	System.out.println("--------Case5: Specify natural order Comparator to nullsFirst---------");

	list = Arrays.asList(s1, null, s2, null, s3);
	Collections.sort(list, Comparator.nullsFirst(Comparator.naturalOrder()));
	list.forEach(s -> System.out.println(s));

	System.out.println("--------Case6: Specify null to nullsFirst---------");

	list = Arrays.asList(s1, null, s2, null, s3);
	Collections.sort(list, Comparator.nullsFirst(null));
	list.forEach(s -> System.out.println(s));
  }
} 
```

**Student.java**

```java
public class Student implements Comparable<Student> {
  private String name;
  private int age;

  public Student(String name, int age) {
	this.name = name;
	this.age = age;
  }
  public String getName() {
        return name;
  }
  public int getAge() {
        return age;
  }
  @Override
  public int compareTo(Student o) {
        return name.compareTo(o.getName());
  }
  @Override  
  public String toString(){
	return name + "-" + age; 
  }  
} 
```

输出

```
-------Case1: One null----------
null
Mohan-17
Ram-18
Shyam-22
--------Case2: More than one null---------
null
null
Mohan-17
Ram-18
Shyam-22
--------Case3: Reverse specified Comparator to nullsFirst---------
null
null
Shyam-22
Ram-18
Mohan-17
--------Case4: Reverse Comparator returned by nullsFirst---------
Shyam-22
Ram-18
Mohan-17
null
null
--------Case5: Specify natural order Comparator to nullsFirst---------
null
null
Mohan-17
Ram-18
Shyam-22
--------Case6: Specify null to nullsFirst---------
null
null
Ram-18
Shyam-22
Mohan-17 
```

示例说明

Case-1: 我们的集合中有一个空元素。由于nullsFirst方法返回的比较器，在排序中，null元素将排在第一位。非空元素的顺序将由传递给nullsFirst方法的比较器决定。

Case-2: 我们有一个以上的空元素。我们知道，当两个元素都是空的时候，那么它们被认为是相等的。所以，所有的空元素将被排在第一位。非空元素的顺序将由传递给nullsFirst方法的比较器决定。

Case-3: 在这种情况下，我们将指定的比较器反转到nullsFirst方法。这将只影响非空元素的顺序。所有的空元素将被排在第一位。

Case-4: 在这种情况下，我们将nullsFirst方法返回的比较器反转。现在，所有的空元素将被排在最后。

Case-5: 在这种情况下，我们通过比较器来使用元素的自然顺序。对于自然顺序，元素类需要实现Comparable和覆盖compareTo方法。所有的空元素将按顺序排在第一位，非空元素将按其自然顺序排列。

Case-6: 在这种情况下，我们将null传递给nullsFirst方法。我们知道，如果指定给nullsFirst的比较器是null，那么返回的比较器会认为所有非null元素都是相等的。所有的空元素将被排在第一位，对非空元素的顺序没有影响。


# [关于Comparator.nullsFirst()和nullsLast()报NullPointerException的坑](https://blog.csdn.net/Cheirmin/article/details/110945580)

昨天开发的时候，遇到了一个排序的问题，于是乎采用java.util包下面的Comparator.comparing来比较。测试的时候发现了空指针异常，于是乎，找到了它的nullsFirst()和nullsLast()两个方法，两个方法的意思就是，为空的时候，就给放到最前面或者最后面。但是，这两个方法并不可行，还是报错。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201210085514260.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0NoZWlybWlu,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/2020121008562720.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0NoZWlybWlu,size_16,color_FFFFFF,t_70)


开启Debug。

## nullsFirst()和nullsLast()方法介绍及出错原因

> nullsFirst()：
>
> 此方法返回比较器，其是空型比较，并认为空值小于非空。null首先通过以下逻辑进行操作：
> 1.null元素被认为小于non-null（即值是null的小于非空的）。
> 2.当两个元素都为空时，则认为它们相等。
> 3.当两个元素都不为空时，指定的Comparator确定顺序。
> 4.如果指定的比较器为null，则返回的比较器将所有非null元素视为相等。
> 5.如果指定的比较器可序列化，则返回的比较器可序列化。
>
> nullsLast()：
> 方法返回比较器，其是空型比较，并认为比非空更大空值。null首先通过以下逻辑进行操作：
> 1.null元素被认为大于非null。
> 2.当两个元素都为空时，则认为它们相等。
> 3.当两个元素都不为空时，指定的Comparator确定顺序。
> 4.如果指定的比较器为null，则返回的比较器将所有非null元素视为相等。
> 5.如果指定的比较器可序列化，则返回的比较器可序列化。

网上说可以 用这两个东西来避免空指针异常。但是事实并不是**（实际上如果nullsFirst()放Comparator.comparing()方法里面确实可以）。**

**==看源码我们可以发现，compare是有判空两个比较对象都为空的情况，直接返回0，理论上是没有问题的，但是而debug的时候，发现这两个对象，传过来的就是对象本身，并不是我想比较的两个对象里面的某个字段。==**

![在这里插入图片描述](https://img-blog.csdnimg.cn/2020121009110584.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0NoZWlybWlu,size_16,color_FFFFFF,t_70)

**所以这里判空，肯定不是null，从而继续比较，**
**继续往下我们可以发现，它进入了String 的compareTo()方法**，但是可以发现这个方法，本身参数就有一个@NotNull注解，于是乎，当比较的字段为null的时候，就有了空指针异常。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20201210091719168.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0NoZWlybWlu,size_16,color_FFFFFF,t_70)

## 解决办法

知道了原因，再来找解决办法，就有思路了

### .filter()过滤

刚开始的时候，我们尝试了在流式操作的时候，用.filter()来过滤掉，字段为空的数据，实际效果也可行，确实解决了空指针异常的问题。
但是运行出来的数据，并不是我们想要的效果

### 自定义比较器

这个方法也是w哥提供给我的一个思路，但是，写到一半，感觉不太可行，毕竟String 的compareTo()还是有@NotNull标签，这也就意味着要写一大堆if else 自己判空，写出来的代码，很不优雅，over

### 最终解决方案–自己写个Function

既然它本身是因为为空的时候，有空指针异常，那么我们自己写一个方法不就好了？太伟了

```java
 //定义排序规则
Comparator<DeviationByTypeVO> byOne = Comparator
	.comparing(mapOrDefault(DeviationByTypeVO::getOneClass));
Comparator<DeviationByTypeVO> byTwo = Comparator
	.comparing(mapOrDefault(DeviationByTypeVO::getTwoClass));
Comparator<DeviationByTypeVO> byThree = Comparator
	.comparing(mapOrDefault(DeviationByTypeVO::getThreeClass));
Comparator<DeviationByTypeVO> byFour = Comparator
	.comparing(mapOrDefault(DeviationByTypeVO::getFourClass));

//联合排序
Comparator<DeviationByTypeVO> finalComparator = 
	byOne.thenComparing(byTwo).thenComparing(byThree).thenComparing(byFour);

return result.stream().sorted(finalComparator).collect(Collectors.toList());
```


自定义的mapOrDefault()方法

自定义的mapOrDefault()方法

```java
private Function<DeviationByTypeVO,String> mapOrDefault(Function<DeviationByTypeVO, String> func){
	//用Optional来设置默认值，如果为空就设置为你想要的规则，比如我这里，想放最后
	//这里比较的因为都是英语单词，Z就是最大的，ASCII码是90，比Z大1的就是91
	return vo -> Optional.ofNullable(func.apply(vo)).orElse("91");
}
```


经实践证明，此方法科学可行，靠谱。



实践：

```java
public class ServiceFMZL01 {
    public static void main(String[] args) throws ParseException {
        BigDecimal num = new BigDecimal("1");
        BigDecimal numL = new BigDecimal("100");
//        String s = num.divide(numL, 3, BigDecimal.ROUND_HALF_UP).subtract(new BigDecimal("1")).multiply(new BigDecimal(100)).setScale(1, BigDecimal.ROUND_HALF_UP).toPlainString();
        BigDecimal result = num.subtract(numL).divide(num, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal(100));
//        System.out.println(result+"%");
        Map<String,String> map = new HashMap<>();
        map.put("FINANCING_MONEY","90.22");
        map.put("RR","R1");
        Map<String,String> map1 = new HashMap<>();
        map1.put("FINANCING_MONEY","");
        map1.put("RR","");
        Map<String,String> map2 = new HashMap<>();
        map2.put("FINANCING_MONEY","100.33");
        map2.put("RR","R2");
        Map<String,String> map3 = new HashMap<>();
        map3.put("FINANCING_MONEY","45.11");
        map3.put("RR","R3");
        List<Map<String,String>> rows = new ArrayList<>();
        rows.add(map);
        rows.add(map1);
        rows.add(map2);
        rows.add(map3);

        //Comparator.nullsFirst放Comparator.comparing()里面，null不会报错
//        Collections.sort(rows, Comparator.comparingDouble(m -> Double.valueOf(m.get("FINANCING_MONEY"))));
        Collections.sort(rows, Comparator.comparing(e -> MapUtils.getDouble(e, "FINANCING_MONEY"), Comparator.nullsFirst(Double::compareTo)));
//        Collections.sort(rows, Comparator.comparing(e -> MapUtils.getInteger(e, "FINANCING_MONEY"), Comparator.nullsFirst(Integer::compareTo)));
//        Collections.sort(rows,Comparator.comparing(m -> m.get("RR"),Comparator.nullsFirst(String::compareTo)));
        
        //Comparator.nullsFirst放前面，数字类型空指针还是会报错
//        Collections.sort(rows,Comparator.nullsFirst(Comparator.comparing(m -> m.get("FINANCING_MONEY"))));      //null不会报空指针，但是会当成String无法正确比较
//        Collections.sort(rows,Comparator.nullsFirst(Comparator.comparing(m -> Double.parseDouble(m.get("FINANCING_MONEY")))));  //null会报空指针
//        Collections.sort(rows,Comparator.nullsFirst(Comparator.comparing(m -> Integer.valueOf(m.get("FINANCING_MONEY")))));  //null会报空指针
//        Collections.sort(rows,Comparator.nullsFirst(Comparator.comparing(e -> MapUtils.getDouble(e, "FINANCING_MONEY"))));      //null会报空指针
//        Collections.sort(rows,Comparator.nullsFirst(Comparator.comparing(mapOrDefault100(e -> MapUtils.getDouble(e, "FINANCING_MONEY")))));      //null会捕获当作设定值100比较，不会报空指针，相当于自己实现了一个Comparator.nulls100,因为没有null了Comparator.nullsFirst也永远不会生效
//        Collections.sort(rows,Comparator.comparing(mapOrDefaultZero(e -> MapUtils.getDouble(e, "FINANCING_MONEY"))));      //null会捕获当作0比较，不会报空指针，相当于自己实现了一个Comparator.nullsFirst
//        Collections.sort(rows,Comparator.nullsFirst(Comparator.comparing(m -> m.get("RR"))));     //比较String，为null不会报错

//        Collections.sort(rows, (m1,m2) -> MapUtils.getDouble(m2,"FINANCING_MONEY").compareTo(MapUtils.getDouble(m1,"FINANCING_MONEY")));
//        List<Map<String, String>> valueNullLastList = rows.stream().sorted(Comparator.comparing(e -> MapUtils.getDouble(e, "FINANCING_MONEY"), Comparator.nullsLast(Double::compareTo))).collect(Collectors.toList());


        System.out.println(rows);
        Collections.reverse(rows);
        System.out.println(rows);


    }

    //用Optional来设置默认值，如果为空就设置为你想要的规则，比如我这里，想放最后
    //这里比较的因为都是Double，如果为空则返回0，相当于实现了Comparator.nullsFirst，如果外层再套一层Comparator.nullsFirst会不再生效，因为比较值null已经变为了设定值0
    private static Function<Map,Double> mapOrDefaultZero(Function<Map, Double> func){
        return vo -> Optional.ofNullable(func.apply(vo)).orElse(0D);
    }
    private static Function<Map,Double> mapOrDefault100(Function<Map, Double> func){
        return vo -> Optional.ofNullable(func.apply(vo)).orElse(100D);
    }
}
```

经实践证明，此方法科学可行，靠谱。
