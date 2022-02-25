# [java8 .stream().map().collect()用法](https://www.cnblogs.com/javagg/p/12660957.html)

API: https://www.runoob.com/java/java8-streams.html

```
mylist.stream()
    .map(myfunction->{
        return item;
    }).collect(Collectors.toList());
```

　　

**说明：**
**steam():把一个源数据，可以是集合，数组，I/O channel， 产生器generator 等，转化成流。**

**forEach():迭代流中的每个数据。以下代码片段使用 forEach 输出了10个随机数.**

 

```
Random random = ``new` `Random();``random.ints().limit(``10``).forEach(System.out::println);
```

 

**map():用于映射每个元素到对应的结果。以下代码片段使用 map 输出了元素对应的平方数：**

```
List<Integer> numbers = Arrays.asList(3, 2, 2, 3, 7, 3, 5);
// 获取对应的平方数
List<Integer> squaresList = numbers.stream().map( i -> i*i).distinct().collect(Collectors.toList());
```

**filter():filter 方法用于通过设置的条件过滤出元素。以下代码片段使用 filter 方法过滤出空字符串：**

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
List<String>strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
// 获取空字符串的数量
int count = strings.stream().filter(string -> !string.isEmpty()).count();//留下非空的字符串对象，去除不符合的
limit
limit 方法用于获取指定数量的流。 以下代码片段使用 limit 方法打印出 10 条数据：

Random random = new Random();
random.ints().limit(10).forEach(System.out::println);
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**sorted(): 用于对流进行排序。以下代码片段使用 sorted 方法对输出的 10 个随机数进行排序：**

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
Random random = new Random();
random.ints().limit(10).sorted().forEach(System.out::println);
并行（parallel）程序
parallelStream 是流并行处理程序的代替方法。以下实例我们使用 parallelStream 来输出空字符串的数量：

List<String> strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
// 获取空字符串的数量
int count = strings.parallelStream().filter(string -> string.isEmpty()).count();
我们可以很容易的在顺序运行和并行直接切换。
```



**Collectors(): 类实现了很多归约操作，例如将流转换成集合和聚合元素。Collectors 可用于返回列表或字符串：**



```java
List<String>strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
List<String> filtered = strings.stream().filter(string -> !string.isEmpty()).collect(Collectors.toList());
 
System.out.println("筛选列表: " + filtered);
String mergedString = strings.stream().filter(string -> !string.isEmpty()).collect(Collectors.joining(", "));
System.out.println("合并字符串: " + mergedString);
```





# [java8新特性stream().map().collect()用法][https://blog.csdn.net/S_yellow/article/details/117438569]

### stream()优点：

无存储。stream不是一种数据结构，它只是某种数据源的一个视图，数据源可以是一个数组，Java容器或I/O channel等。
为函数式编程而生。对stream的任何修改都不会修改背后的数据源，比如对stream执行过滤操作并不会删除被过滤的元素，而是会产生一个不包含被过滤元素的新stream。
惰式执行。stream上的操作并不会立即执行，只有等到用户真正需要结果的时候才会执行。
可消费性。stream只能被“消费”一次，一旦遍历过就会失效，就像容器的迭代器那样，想要再次遍历必须重新生成。

```
有一个集合：
List users = getList(); //从数据库查询的用户集合
现在想获取User的身份证号码；在后续的逻辑处理中要用；
常用的方法我们大家都知道，用for循环
```

```
//定义一个集合来装身份证号码
List idcards=new ArrayList();
for(int i=0;i<users.size();i++){
idcards.add(users.get(i).getIdcard());
}

//这种方法要写好几行代码，java8 API一行就能搞定：
List idcards= users.stream().map(User::getIdcard).collect(Collectors.toList())
```

解释下一这行代码： users：一个实体类的集合，类型为List User：实体类
getIdcard：实体类中的get方法，为获取User的idcard

Collectors类的静态工厂方法

![在这里插入图片描述](java8 .stream().map().collect()用法.assets/20210601112556711.png)



---



# [Stream系列（七）distinct方法使用][https://blog.csdn.net/wenhaipan/article/details/103323852]

![img](java8 .stream().map().collect()用法.assets/20191130135635858.png)

EmployeeTestCase.java

```java
package com.example.demo;

import lombok.Data;
import lombok.ToString;
import lombok.extern.log4j.Log4j2;
import one.util.streamex.StreamEx;
import org.junit.Test;

import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.LongStream;
import java.util.stream.Stream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

@Log4j2
public class EmployeeTestCase extends BaseTest{
    @Test
    public void distinct() {
        //常规实现方式
        List<Employee> employeesDis = list.stream().distinct().collect(Collectors.toList());
        assertEquals(employeesDis.size(),5);
        //StreamEx 实现方式
        List<Employee> employeesDisBySalary2 = StreamEx.of(list).distinct(Employee::getSalary)
                .peek(System.out::println).collect(Collectors.toList());
        //Stream filter 实现方式
        List<Employee> employeesDisBySalary = list.stream().filter(distinctByKey(Employee::getSalary))
                .collect(Collectors.toList());
        assertEquals(employeesDisBySalary,employeesDisBySalary2);
    }
    private static <T> Predicate<T> distinctByKey(Function<? super T, ?> keyExtractor) {
        Map<Object,Boolean> seen = new ConcurrentHashMap<>();
        return t -> seen.putIfAbsent(keyExtractor.apply(t), Boolean.TRUE) == null;
    }
}

```

