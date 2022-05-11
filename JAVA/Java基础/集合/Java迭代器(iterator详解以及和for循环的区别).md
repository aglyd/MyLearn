# [Java迭代器(iterator详解以及和for循环的区别)][https://www.cnblogs.com/cloud-ken/p/11303084.html]

## 前言

- 迭代器是一种模式、详细可见其设计模式，可以使得序列类型的数据结构的遍历行为与被遍历的对象分离，即我们无需关心该序列的底层结构是什么样子的。只要拿到这个对象,使用迭代器就可以遍历这个对象的内部
- **Iterable** 实现这个接口的集合对象支持迭代，是可以迭代的。实现了这个可以配合foreach使用~
- **Iterator** 迭代器，提供迭代机制的对象，具体如何迭代是这个Iterator接口规范的。

```java
//Iterable JDK源码
//可以通过成员内部类，方法内部类，甚至匿名内部类去实现Iterator

public interface Iterable<T>
{

    Iterator<T> iterator();
```

- Iterable还有一个默认的方法forEach()
- 而Iterator接口：包含三个方法：hasNext，next，remove、remove一般很少用到.

```java
public interface Iterator<E> {


    boolean hasNext();    //每次next之前，先调用此方法探测是否迭代到终点

    E next();            //返回当前迭代元素 ，同时，迭代游标后移


     /*删除最近一次已近迭代出出去的那个元素。
     只有当next执行完后，才能调用remove函数。
     比如你要删除第一个元素，不能直接调用 remove()   而要先next一下( );
     在没有先调用next 就调用remove方法是会抛出异常的。
     这个和MySQL中的ResultSet很类似
    */
    void remove()
    {
        throw new UnsupportedOperationException("remove");
    }
```

### Note

- 迭代出来的元素都是原来集合元素的拷贝。
- Java集合中保存的元素实质是对象的引用，而非对象本身。
- 迭代出的对象也是引用的拷贝，结果还是引用。那么如果集合中保存的元素是可变类型的，那么可以通过迭代出的元素修改原集合中的对象。

```java
import java.util.ArrayList;
import java.util.Iterator;

public class test {
    public static void main(String[] args) {
        ArrayList<Person> array = new ArrayList<Person>();

        Person p1 = new Person("Tom1");
        Person p2 = new Person("Tom2");
        Person p3 = new Person("Tom3");
        Person p4 = new Person("Tom4");

        array.add(p1);
        array.add(p2);
        array.add(p3);
        array.add(p4);

        Iterator<Person> iterator = array.iterator();

        for (Person pp : array){
            System.out.println(pp.getName());
        }

        System.out.println("\r\n" + "-----利用Lambda表达式的foreach-----" + "\r\n");
        array.forEach(obj -> System.out.println(obj.getName()));


        System.out.println("\r\n" + "-----利用for循环-----" + "\r\n");
        for(Person p : array){
            p.setName("wang");
        }

        while(iterator.hasNext()){
            System.out.println(iterator.next().getName()); //输出的是wang，而不是tom
        }



    }
}
```

![img](https://img-blog.csdn.net/20180531184535979?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0phZV9XYW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## Map遍历也是一样的~

```java
public static void main(String[] args) {
        Map map = new HashMap();
        for(int i = 0; i < 10; i ++){
            map.put(i, String.valueOf("map" + i));
        }
        Iterator iterMap = map.entrySet().iterator();
        while(iterMap.hasNext()){
            Map.Entry strMap = (Map.Entry)iterMap.next();
            System.out.println("key为:" + strMap.getKey() +
                    ", value为:" + strMap.getValue());
        }
    }
```

那么当Iterator迭代访问Collection集合中元素时，Collection的元素不能改变（多个线程的修改），只有通过Iterator的remove（）方法删除上一次next（）方法返回集合才可以。这样会引发ModificationException异常，即fail-fast机制

```java
//创建集合，添加元素和上述一样      
        Iterator<Person> iterator = array.iterator();

      while(iterator.hasNext()){
         String name = iterator.next().getName();
         System.out.println(name);
         if(name.equals("Tom3")){
             //array.remove(name);  不推荐这种方式
             iterator.remove();
         }
      }
```

### Iterator与泛型搭配:

- Iterator对集合类中的任何一个实现类，都可以返回这样一个Iterator对象。可以适用于任何一个类。
- 因为集合类(List和Set等)可以装入的对象的类型是不确定的,从集合中取出时都是Object类型,用时都需要进行强制转化,这样会很麻烦,用上泛型,就是提前告诉集合确定要装入集合的类型,这样就可以直接使用而不用显示类型转换.非常方便.

### foreach和Iterator的关系：

- for each以用来处理集合中的每个元素而不用考虑集合定下标。就是为了让用Iterator简单。但是删除的时候，区别就是在remove，循环中调用集合remove会导致原集合变化导致错误，而应该用迭代器的remove方法。

### 使用for循环还是迭代器Iterator对比

- **采用ArrayList对随机访问比较快，而for循环中的get()方法，采用的即是随机访问的方法，因此在ArrayList里，for循环较快**
- **采用LinkedList则是顺序访问比较快，iterator中的next()方法，采用的即是顺序访问的方法，因此在LinkedList里，使用iterator较快**
- 从数据结构角度分析,for循环适合访问顺序结构,可以根据下标快速获取指定元素.而Iterator 适合访问链式结构,因为迭代器是通过next()和Pre()来定位的.可以访问没有顺序的集合.
- 而使用 Iterator 的好处在于可以使用相同方式去遍历集合中元素，而不用考虑集合类的内部实现（只要它实现了 java.lang.Iterable 接口），如果使用 Iterator 来遍历集合中元素，一旦不再使用 List 转而使用 Set 来组织数据，那遍历元素的代码不用做任何修改，如果使用 for 来遍历，那所有遍历此集合的算法都得做相应调整,因为List有序,Set无序,结构不同,他们的访问算法也不一样.（还是说明了一点遍历和集合本身分离了）