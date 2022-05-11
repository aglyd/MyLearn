# [Java集合详解（全） ](https://www.cnblogs.com/linliquan/p/11323172.html)

List , Set继承至Collection接口，Map为独立接口

 

List下有ArrayList，LinkedList，Vector

Set下有HashSet，LinkedHashSet，TreeSet
Map下有HashMap，LinkedHashMap， TreeMap，Hashtable


![img](Java集合详解.assets/1443349-20190808191920652-953306830.png)

![img](Java集合详解.assets/1443349-20190808192003006-1847943518.png)

 ![img](Java集合详解.assets/1443349-20190809161916620-1110076229.png)

![img](Java集合详解.assets/1443349-20190809162020071-1121742231.png)

![img](Java集合详解.assets/1443349-20190809162120314-216869644.png)

 

 

**总结:**
**Connection接口:**



## 1.List 有序,可重复

**ArrayList:**
优点: 底层数据结构是数组，查询快，增删慢。
缺点: 线程不安全，效率高

**LinkedList:**
优点: 底层数据结构是链表，查询慢，增删快。
缺点: 线程不安全，效率高
**Vector:**
优点: 底层数据结构是数组，查询快，增删慢。
缺点: 线程安全，效率低

 

## 2.Set 无序,唯一

### （1）HashSet：

底层数据结构是哈希表。 (数组+链表/红黑树)的方式进行存储数据  (无序,唯一)
如何来保证元素唯一性?
1.依赖两个方法：hashCode()和equals()

 **HashSet**底层数据结构**采用哈希表实现，元素无序且唯一，线程不安全，效率高，可以存储null元素**，元素的唯一性是靠所存储元素类型是否重写**==hashCode()和equals()==**方法来保证的，**==如果没有重写这两个方法，则无法保证元素的唯一性。==** 

 

**具体实现唯一性的比较过程:**

```tex
1.存储元素时首先会使用hash()算法函数生成一个int类型hashCode散列值，然后已经的所存储的元素的hashCode值比较，如果hashCode不相等，肯定是不同的对象。
2.hashCode值相同，再比较equals方法。
3.equals相同，对象相同。（则无需储存）
```

### （2）LinkedHashSet：

底层数据结构是链表和哈希表。(**==FIFO插入有序==**,唯一)
1.由链表保证元素有序
2.由哈希表保证元素唯一

**LinkedHashSet底层数据结构采用链表和哈希表共同实现，==链表保证了元素的顺序与存储顺序一致（注意只能保证插入顺序）==，哈希表保证了元素的唯一性。线程不安全，效率高。** 

### （3）TreeSet：

底层数据结构是**==红黑树==**。**==(唯一，有序，非线程安全)==**

1. 如何保证元素排序的呢?
   自然排序
   比较器排序
2. 如何保证元素唯一性的呢?
   根据比较的返回值是否是0来决定

 

**TreeSet**底层数据结构采用红黑树来实现，元素唯一且已经排好序；**==唯一性同样需要重写hashCode和equals()方法(如String.equals方法会比较值内容是否相等)==**，**==二叉树结构保证了元素的有序性。==**根据构造方法不同，分为自然排序（无参构造）和比较器排序（有参构造），自然排序要求元素必须实现Compareable接口，并重写里面的compareTo()方法，元素通过比较返回的int值来判断排序序列，返回0说明两个对象相同，不需要存储；**==比较器排需要在TreeSet初始化是时候传入一个实现Comparator接口的比较器对象，或者采用匿名内部类的方式new一个Comparator对象，重写里面的compare()方法；==**



==**适用场景分析:HashSet是基于Hash算法实现的，其性能通常都优于TreeSet。为快速查找而设计的Set，我们通常都应该使用HashSet，在我们需要排序的功能时，我们才使用TreeSet。**== 

#### 红黑树：

在学习红黑树之前，咱们需要先来理解下二叉查找树（BST）。

#### 二叉查找树

要想了解二叉查找树，我们首先看下二叉查找树有哪些特性呢？

1， 左子树上所有的节点的值均小于或等于他的根节点的值

2， 右子数上所有的节点的值均大于或等于他的根节点的值

3， 左右子树也一定分别为二叉排序树

我们来看下图的这棵树，他就是典型的二叉查找树

**![img](Java集合详解.assets/1443349-20190809152254032-121121486.png)**

#### 红黑树

红黑树就是一种平衡的二叉查找树，说他平衡的意思是他不会变成“瘸子”，左腿特别长或者右腿特别长。除了符合二叉查找树的特性之外，还具体下列的特性：

**1. 节点是红色或者黑色**

**2. 根节点是黑色**

**3. 每个叶子的节点都是黑色的空节点（NULL）**

**4. 每个红色节点的两个子节点都是黑色的。**

**5. 从任意节点到其每个叶子的所有路径都包含相同的黑色节点。**

看下图就是一个典型的红黑树：

![img](Java集合详解.assets/1443349-20190809152414102-1642174191.png)

红黑树详情：http://www.360doc.com/content/18/0904/19/25944647_783893127.shtml

 

#### TreeSet的两种排序方式比较

1.基本数据类型默认按升序排序

2.自定义排序

（1）自然排序：重写Comparable接口中的Compareto方法

（2）比较器排序：重写Comparator接口中的Compare方法

```java
compare(T o1,T o2)      比较用来排序的两个参数。
o1：代表当前添加的数据
o2：代表集合中已经存在的数据
0： 表示 o1 == o2
-1(逆序输出)： o1 < o2 
1(正序输出): o1 > o2 
```

**1：o1 - o2（升序排列）**
**-1：o2 - o1 (降序排列)**

 

例子1：

```java
import java.util.Comparator;
import java.util.Set;
import java.util.TreeSet;

public class Test {
    public static void main(String[] args) {

        /**
         * 自定义规则的TreeSet
         * 客户端排序：自己写一个比较器，转给TreeSet
         *
         * 比较规则
         * 当TreeSet集合添加数据的时候就会触发比较器的compare()方法
         */
        Comparator<Integer> comp = new Comparator<Integer>() {
            /**
             * o1 当前添加的数据
             * o2 集合中已经存在的数据
             * 0： 表示 o1 == o2
             * -1 ： o1 < o2
             * 1 : o1 > o2
             */
            @Override
            public int compare(Integer o1, Integer o2) {
                System.out.println(o1+"--"+o2);
                return o2 -o1; //输出53 33 10，降序排序
              //  return  0;  //只输出一个元素：33
              //   return -1; //输出53 10 33，倒序输出
              //  return 1;  //输出33 10 55
            }
        };

        Set<Integer> s2 = new TreeSet<>(comp);
        s2.add(33);
        s2.add(10);
        s2.add(55);

        System.out.println(s2); //输入53 33 10，降序排序

    }
}
```

例2：

```java
import java.util.Comparator;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;

/**
 * 使用TreeSet和Comparator（使用匿名类），写Test.java
 * 要求：对TreeSet中的元素
 *     1，2，3，4，5，6，7，8，9，10进行排列，
 * 排序逻辑为奇数在前偶数在后，
 * 奇数按照升序排列，偶数按照降序排列
 * 输出结果：1 3 5 7 9 10 8 6 4 2
 */
public class Test {
    public static void main(String[] args) {
        Set<Integer> s = new TreeSet<>(new Comparator<Integer>() {
            //重写compare方法
            @Override
            public int compare(Integer o1, Integer o2) {
                System.out.println("o1="+o1+" o2="+o2);
                if(o2%2==0){
                    if (o1%2==0){
                            return o2 -o1;
                    }else{
                        return -1;
                    }
                }else {
                    if (o1%2==0){
                        return 1;
                    }else{
                        return o1 -o2;
                    }
                }


            }
        });

        s.add(2);
        s.add(6);
        s.add(4);
        s.add(1);
        s.add(3);
        s.add(5);
        s.add(8);
        s.add(10);
        s.add(9);
        s.add(7);

        Iterator iterator = s.iterator();

        while(iterator.hasNext()){
            System.out.print(iterator.next()+" ");	//输出结果：1 3 5 7 9 10 8 6 4 2
        }

    }
}
```

## 3.Map接口:

Map用于保存具有映射关系的数据，Map里保存着两组数据：key和value，它们都可以使任何引用类型的数据，但key不能重复。所以通过指定的key就可以取出对应的value。

Map接口有四个比较重要的实现类，分别是HashMap、LinkedHashMap、TreeMap和HashTable。

TreeMap是有序的，HashMap和HashTable是无序的。

**==Hashtable的方法是同步的，HashMap的方法不是同步的。这是两者最主要的区别。==**

### HashMap

- Map 主要用于存储键(key)值(value)对，根据键得到值，因此键不允许重复,但允许值重复。

- HashMap 是一个最常用的Map,它根据键的HashCode 值存储数据,根据键可以直接获取它的值，具有很快的访问速度。

- HashMap最多只允许一条记录的键为Null;允许多条记录的值为 Null;

- **==HashMap不支持线程的同步==**，即任一时刻可以有多个线程同时写HashMap;可能会导致数据的不一致。如果需要同步，可以用

  **==Collections的synchronizedMap方法使HashMap具有同步的能力，或者使用ConcurrentHashMap。==**

- HashMap基于哈希表结构实现的 ，**==当一个对象被当作键时，必须重写hasCode和equals方法。==**

### LinkedHashMap

LinkedHashMap继承自HashMap，它主要是用链表实现来扩展HashMap类，HashMap中条目是没有顺序的，但是在**LinkedHashMap中元素既可以按照它们插入图的顺序排序，也可以按它们最后一次被访问的顺序排序。**

### TreeMap

TreeMap基于**红黑树**数据结构的实现，**键值可以使用Comparable或Comparator接口来排序（可以重写排序方法）。**TreeMap继承自AbstractMap，同时实现了接口NavigableMap，而接口NavigableMap则继承自SortedMap。SortedMap是Map的子接口，使用它可以确保图中的条目是排好序的。

**==在实际使用中，如果更新图时不需要保持图中元素的顺序，就使用HashMap，如果需要保持图中元素的插入顺序或者访问顺序，就使用LinkedHashMap，如果需要使图按照键值排序（可以自定义），就使用TreeMap。==**

### Hashtable

Hashtable和前面介绍的HashMap很类似，它也是一个**==散列表==**，存储的内容是键值对映射，不同之处在于，Hashtable是继承自Dictionary的，**==Hashtable中的函数都是同步的，这意味着它也是线程安全的==**，另外，**Hashtable中key和value都不可以为null。**



 

**怎么选择：**

![img](Java集合详解.assets/1443349-20190809112124846-1780683313.png)

 

### 遍历map实例

```java
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class Test {

    public static void main(String[] args) {
        Map<String, String> map = new HashMap<String, String>();
        map.put("first", "linlin");
        map.put("second", "好好学java");
        map.put("third", "sihai");
        map.put("first", "sihai2");


        // 第一种：通过Map.keySet遍历key和value
        System.out.println("===================通过Map.keySet遍历key和value:===================");
        for (String key : map.keySet()) {
            System.out.println("key= " + key + "  and  value= " + map.get(key));
        }

        // 第二种：通过Map.entrySet使用iterator遍历key和value
        System.out.println("===================通过Map.entrySet使用iterator遍历key和value:===================");
        Iterator<Map.Entry<String, String>> it = map.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, String> entry = it.next();
            System.out.println("key= " + entry.getKey() + "  and  value= "
                    + entry.getValue());
        }

        // 第三种：通过Map.entrySet遍历key和value
        System.out.println("===================通过Map.entrySet遍历key和value:===================");
        for (Map.Entry<String, String> entry : map.entrySet()) {
            System.out.println("key= " + entry.getKey() + "  and  value= "
                    + entry.getValue());
        }

        // 第四种：通过Map.values()遍历所有的value，但是不能遍历键key
        System.out.println("===================通过Map.values()遍历所有的value:===================");
        for (String v : map.values()) {
            System.out.println("value= " + v);
        }
    }

}
```

 

## 重点问题重点分析:

## （一）说说List,Set,Map三者的区别？

- List(对付顺序的好帮手)： List接口存储一组不唯一（可以有多个元素引用相同的对象），有序的对象
- Set(注重独一无二的性质): 不允许重复的集合。不会有多个元素引用相同的对象。
- Map(用Key来搜索的专家): 使用键值对存储。Map会维护与Key有关联的值。两个Key可以引用相同的对象，但Key不能重复，典型的Key是String类型，但也可以是任何对象。

## （二）Arraylist 与 LinkedList 区别?

-  是否保证线程安全： `ArrayList` 和 `LinkedList` 都是**不同步的，也就是不保证线程安全；**
-  底层数据结构： `Arraylist` 底层使用的是 **==`Object` 数组==**；`LinkedList` 底层使用的是**双向链表数据结构（JDK1.6之前为循环链表，JDK1.7取消了循环。注意双向链表和双向循环链表的区别，下面有介绍到！）**
- 插入和删除是否受元素位置的影响： ① `ArrayList` 采用数组存储，所以插入和删除元素的时间复杂度受元素位置的影响。 比如：执行`add(E e) `方法的时候， `ArrayList` 会默认在将指定的元素追加到此列表的末尾，这种情况时间复杂度就是O(1)。但是如果**要在指定位置 i 插入和删除元素的话（`add(int index, E element) `）时间复杂度就为 O(n-i)**。因为在进行上述操作的时候集合中第 i 和第 i 个元素之后的(n-i)个元素都要执行向后位/向前移一位的操作。 ② `LinkedList` **采用链表存储，所以插入，删除元素时间复杂度不受元素位置的影响，都是近似 O（1）而数组为近似 O（n）。**
- 是否支持快速随机访问： **`LinkedList` 不支持高效的随机元素访问，而 `ArrayList` 支持**。快速随机访问就是通过元素的序号快速获取元素对象(对应于`get(int index) `方法)。
- 内存空间占用： **ArrayList的空间浪费主要体现在在list列表的==结尾会预留一定的容量空间==，而LinkedList的空间花费则体现在它的每一个元素都需要消耗比ArrayList更多的空间（因为要存放==直接后继和直接前驱以及数据==）**。

　　1.ArrayList是实现了基于**动态数组**的数据结构，LinkedList**基于链表**的数据结构。
　　2.**对于随机访问get和set，ArrayList觉得优于LinkedList，因为LinkedList要移动指针。**
　　3.**对于新增和删除操作add和remove，LinedList比较占优势，因为ArrayList要移动数据。**
    **尽量避免同时遍历和删除集合。因为这会改变集合的大小；（不可以在一个遍历中同时又改变集合本身）**

 

## （三）ArrayList 与 Vector 区别呢?为什么要用Arraylist取代Vector呢？

**`Vector`类的所有方法都是==同步的==。可以由两个线程安全地访问一个Vector对象、但是一个线程访问Vector的话代码要在同步操作上耗费大量的时间。**

`Arraylist`不是同步的，所以在不需要保证线程安全时建议使用Arraylist。

 

## （四）说一说 ArrayList 的扩容机制吧

https://github.com/Snailclimb/JavaGuide/blob/master/docs/java/collection/ArrayList-Grow.md

 

## （五）HashSet与TreeSet与LinkedHashSet对比

 HashSet不能保证元素的排列顺序，顺序有可能发生变化，不是同步的，集合元素可以是null,但只能放入一个null
TreeSet是SortedSet接口的唯一实现类，TreeSet可以确保集合元素处于排序状态。TreeSet支持两种排序方式，自然排序 和定制排序，其中自然排序为默认的排序方式。**向 TreeSet中加入的应该是同一个类的对象。**
TreeSet判断两个对象不相等的方式是两个对象通过equals方法返回false，或者通过CompareTo方法比较没有返回0
**自然排序**
自然排序使用要排序元素的CompareTo（Object obj）方法来比较元素之间大小关系，然后将元素按照升序排列。
**定制排序**
自然排序是根据集合元素的大小，以升序排列，如果要定制排序，应该使用Comparator接口，实现 int compare(To1,To2)方法
LinkedHashSet集合同样是根据元素的hashCode值来决定元素的存储位置，但是它同时使用链表维护元素的次序。这样使得元素看起来像是以**==插入顺序==**保存的，也就是说，当遍历该集合时候，LinkedHashSet将会**以元素的添加顺序访问集合的元素**。
**LinkedHashSet在迭代访问Set中的全部元素时，性能比HashSet好，但是插入时性能稍微逊色于HashSet。**

 

## （六）LinkedHashMap和HashMap，TreeMap对比

Hashtable与 HashMap类似,它继承自Dictionary类，不同的是:它不允许记录的键或者值为空;**==它支持线程的同步，即任一时刻只有一个线程能写Hashtable,因此也导致了 Hashtable在写入时会比较慢。==**
Hashmap 是一个最常用的Map,它根据键的HashCode 值存储数据,根据键可以直接获取它的值，**==具有很快的访问速度==**，遍历时，**取得数据的顺序是==完全随机==的。**
LinkedHashMap保存了记录的**==插入顺序==**，**在用Iterator遍历LinkedHashMap时，先得到的记录肯定是先插入的.也可以在构造时用带参数，按照应用次数排序。在遍历的时候会比HashMap慢，不过有种情况例外，当HashMap容量很大，实际数据较少时，遍历起来可能会比LinkedHashMap慢，==因为LinkedHashMap的遍历速度只和实际数据有关，和容量无关，而HashMap的遍历速度和他的容量有关。==**
**TreeMap实现SortMap接口，能够把它保存的记录根据键排序,默认是按键值的升序排序，也可以指定排序的比较器，当用Iterator 遍历TreeMap时，得到的记录是排过序的。**
我们用的最多的是HashMap,HashMap里面存入的键值对**==在取出的时候是随机的,访问数度快==**，在Map 中插入、删除和定位元素，HashMap 是最好的选择。
TreeMap取出来的是排序后的键值对。但如果您要按**==自然顺序或自定义顺序遍历键==**，那么TreeMap会更好。
LinkedHashMap 是HashMap的一个子类，如果需要**==输出的顺序和输入的相同==**,那么用LinkedHashMap可以实现,它还可以**按读取顺序来排列**，像连接池中可以应用。

 

## （七）HashMap 和 Hashtable 的区别

1. **线程是否安全**： HashMap 是非线程安全的，HashTable 是线程安全的；HashTable 内部的方法基本都经过`synchronized` 修饰。（如果你要保证线程安全的话就使用 ConcurrentHashMap 吧！）；
2. **效率**： 因为线程安全的问题，HashMap 要比 HashTable 效率高一点。另外，HashTable 基本被淘汰，不要在代码中使用它；取而代之使用ConcurrentHashMap 
3. **对Null key 和Null value的支持**： HashMap 中，null 可以作为键，这样的键只有一个，可以有一个或多个键所对应的值为 null。。但是在 HashTable 中 put 进的键值只要有一个 null，直接抛出 NullPointerException。
4. **初始容量大小和每次扩充容量大小的不同** ： ①创建时如果不指定容量初始值，Hashtable 默认的初始大小为11，之后每次扩充，容量变为原来的2n+1。HashMap 默认的初始化大小为16。之后每次扩充，容量变为原来的2倍。②创建时如果给定了容量初始值，那么 Hashtable 会直接使用你给定的大小，而 HashMap 会将其扩充为2的幂次方大小（HashMap 中的`tableSizeFor()`方法保证，下面给出了源代码）。也就是说 HashMap 总是使用2的幂作为哈希表的大小,后面会介绍到为什么是2的幂次方。
5. **底层数据结构**： JDK1.8 以后的 HashMap 在解决哈希冲突时有了较大的变化，当链表长度大于阈值（默认为8）时，将链表转化为红黑树，以减少搜索时间。Hashtable 没有这样的机制。

## （八）HashMap 和 HashSet区别

如果你看过 `HashSet` 源码的话就应该知道：HashSet 底层就是基于 HashMap 实现的。（HashSet 的源码非常非常少，因为除了 `clone() `、`writeObject()`、`readObject()`是 HashSet 自己不得不实现之外，其他方法都是直接调用 HashMap 中的方法。

![img](Java集合详解.assets/1443349-20190809144733007-1488097470.png)

 

## （九）HashSet如何检查重复

当你把对象加入`HashSet`时，HashSet会先计算对象的`hashcode`值来判断对象加入的位置，同时也会与其他加入的对象的hashcode值作比较，如果没有相符的hashcode，HashSet会假设对象没有重复出现。但是如果发现有相同hashcode值的对象，这时会调用`equals（）`方法来检查hashcode相等的对象是否真的相同。如果两者相同，HashSet就不会让加入操作成功。（摘自我的Java启蒙书《Head fist java》第二版）

hashCode（）与equals（）的相关规定：

1. 如果两个对象相等，则hashcode一定也是相同的
2. 两个对象相等,对两个equals方法返回true
3. 两个对象有相同的hashcode值，它们也不一定是相等的
4. 综上，equals方法被覆盖过，则hashCode方法也必须被覆盖（不然如果equals判断相等，hashCode却不相等则equals相等不会生效，也就是equals相等则hashCode必然相等，hashCode只是equals的预判断）
5. hashCode()的默认行为是对堆上的对象产生独特值。如果没有重写hashCode()，则该class的两个对象无论如何都不会相等（即使这两个对象指向相同的数据）。

## （十）HashMap的底层实现

### JDK1.8之前

**JDK1.8 之前 `HashMap` 底层是 数组和链表结合在一起使用也就是链表散列。HashMap 通过 key 的 hashCode 经过扰动函数处理过后得到 hash 值，然后通过 (n - 1) & hash 判断当前元素存放的位置（这里的 n 指的是数组的长度），如果当前位置存在元素的话，就判断该元素与要存入的元素的 hash 值以及 key 是否相同，如果相同的话，直接覆盖，不相同就通过拉链法解决冲突。**

**所谓扰动函数指的就是 HashMap 的 hash 方法。使用 hash 方法也就是扰动函数是为了防止一些实现比较差的 hashCode() 方法，换句话说使用扰动函数之后可以减少碰撞。**

 

**HashMap实现原理（比较好的描述）：HashMap以键值对（key-value）的形式来储存元素，但调用put方法时，HashMap会通过hash函数来计算key的hash值，然后通过hash值&(HashMap.length-1)判断当前元素的存储位置，如果当前位置存在元素的话，就要判断当前元素与要存入的key是否相同，如果相同则覆盖，如果不同则通过拉链表来解决。JDk1.8时，当链表长度大于8时，将链表转为红黑树。**

 

**JDK 1.8 HashMap 的 hash 方法源码:**

**JDK 1.8 的 hash方法 相比于 JDK 1.7 hash 方法更加简化，但是原理不变。**

```java
static final int hash(Object key) {
      int h;
      // key.hashCode()：返回散列值也就是hashcode
      // ^ ：按位异或
      // >>>:无符号右移，忽略符号位，空位都以0补齐
      return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
  } 
```

对比一下 JDK1.7的 HashMap 的 hash 方法源码.

```java
static int hash(int h) {
    // This function ensures that hashCodes that differ only by
    // constant multiples at each bit position have a bounded
    // number of collisions (approximately 8 at default load factor).

    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
}
```

 

相比于 JDK1.8 的 hash 方法 ，JDK 1.7 的 hash 方法的性能会稍差一点点，因为毕竟扰动了 4 次。

所谓 “**拉链法**” 就是：将链表和数组相结合。也就是说创建一个链表数组，数组中每一格就是一个链表。**==若遇到哈希冲突，则将冲突的值加到链表中即可。==**取值的时候先计算hashCode散列码，如果相同就是存储在数组的同一个位置上，取出该数组位置中的链表，再遍历该链表对比key取出目标数据

![img](Java集合详解.assets/1443349-20190809145045752-466127573.png)

 

### JDK1.8之后

相比于之前的版本， JDK1.8之后在解决哈希冲突时有了较大的变化，当链表长度大于阈值（默认为8）时，**==将链表转化为红黑树，以减少搜索时间。（因为遍历红黑树比遍历链表要快，用的是二分查找）==**

![img](Java集合详解.assets/1443349-20190809145127349-1599258530.png)

 

**TreeMap、TreeSet以及JDK1.8之后的HashMap底层都用到了红黑树。红黑树就是为了解决二叉查找树的缺陷，因为二叉查找树在某些情况下会退化成一个线性结构。**

 

## （十一）HashMap 的长度为什么是2的幂次方

为了能让 HashMap 存取高效，尽量较少碰撞，也就是要尽量把数据分配均匀。我们上面也讲到了过了，Hash 值的范围值-2147483648到2147483647，前后加起来大概40亿的映射空间，只要哈希函数映射得比较均匀松散，一般应用是很难出现碰撞的。但问题是一个40亿长度的数组，内存是放不下的。所以这个散列值是不能直接拿来用的。用之前还要先做对数组的长度取模运算，得到的余数才能用来要存放的位置也就是对应的数组下标。这个数组下标的计算方法是“ `(n - 1) & hash`”。（n代表数组长度）。这也就解释了 HashMap 的长度为什么是2的幂次方。

这个算法应该如何设计呢？

我们首先可能会想到采用%取余的操作来实现。但是，重点来了：**“取余(%)操作中如果除数是2的幂次则等价于与其除数减一的与(&)操作（也就是说 hash%length==hash&(length-1)的前提是 length 是2的 n 次方；）**。” 并且 采用二进制位操作 &，相对于%能够提高运算效率，这就解释了 HashMap 的长度为什么是2的幂次方。

 

## （十二）HashMap 多线程操作导致死循环问题

主要原因在于 并发下的Rehash 会造成元素之间会形成一个循环链表。不过，jdk 1.8 后解决了这个问题，但是还是不建议在多线程下使用 HashMap,因为多线程下使用 HashMap 还是会存在其他问题比如数据丢失。**并发环境下推荐使用 ConcurrentHashMap 。**

 Rehash：一般来说，Hash表这个容器当有数据要插入时，都会检查容量有没有超过设定的thredhold，如果超过，需要增大Hash表的尺寸，但是这样一来，**整个Hash表里的无素都需要被重算一遍。这叫rehash，这个成本相当的大。**

## （十三）ConcurrentHashMap 和 Hashtable 的区别

ConcurrentHashMap 和 Hashtable 的区别主要体现在实现线程安全的方式上不同。

- **底层数据结构**： JDK1.7的 ConcurrentHashMap 底层采用 **分段的数组+链表** 实现，JDK1.8 采用的数据结构跟HashMap1.8的结构一样，**数组+链表/红黑二叉树**。Hashtable 和 JDK1.8 之前的 HashMap 的底层数据结构类似都是采用 **数组+链表** 的形式，数组是 HashMap 的主体，链表则是主要为了解决哈希冲突而存在的；
- **实现线程安全的方式（重要**）： ① **在JDK1.7的时候**，**ConcurrentHashMap（分段锁）** 对整个桶数组进行了分割分段(Segment)，每一把锁只锁容器其中一部分数据，多线程访问容器里不同数据段的数据，就不会存在锁竞争，提高并发访问率。 **到了 JDK1.8 的时候已经摒弃了Segment的概念，而是直接用 Node 数组+链表+红黑树的数据结构来实现，并发控制使用 synchronized 和 CAS 来操作。**（JDK1.6以后 对 synchronized锁做了很多优化） 整个看起来就像是优化过且线程安全的 HashMap，虽然在JDK1.8中还能看到 Segment 的数据结构，但是已经简化了属性，只是为了兼容旧版本；② **Hashtable**(同一把锁) :**使用 synchronized 来保证线程安全，get/put所有相关操作都是synchronized的，这相当于给整个哈希表加了一把大锁,效率非常低下**。当一个线程访问同步方法时，其他线程也访问同步方法，可能会进入阻塞或轮询状态，如使用 put 添加元素，另一个线程不能使用 put 添加元素，也不能使用 get，竞争会越来越激烈效率越低。

 

**两者的对比图：**

**HashTable:**

![img](Java集合详解.assets/1443349-20190809145459367-256682176.png)

 

## JDK1.7的ConcurrentHashMap：

![img](Java集合详解.assets/1443349-20190809145551507-2036789540.png)

![img](Java集合详解.assets/1443349-20190809145611182-803126838.png)

## （十四）ConcurrentHashMap线程安全的具体实现方式/底层具体实现

### JDK1.7（上面有示意图）

首先将数据分为一段一段的存储，然后给每一段数据配一把锁，当一个线程占用锁访问其中一个段数据时，其他段的数据也能被其他线程访问。

ConcurrentHashMap 是由 Segment 数组结构和 HashEntry 数组结构组成。

Segment 实现了 ReentrantLock,所以 Segment 是一种可重入锁，扮演锁的角色。HashEntry 用于存储键值对数据。

```java
static class Segment<K,V> extends ReentrantLock implements Serializable {
}
```

一个 ConcurrentHashMap 里包含一个 Segment 数组。Segment 的结构和HashMap类似，是一种数组和链表结构，一个 Segment 包含一个 HashEntry 数组，每个 HashEntry 是一个链表结构的元素，每个 Segment 守护着一个HashEntry数组里的元素，当对 HashEntry 数组的数据进行修改时，必须首先获得对应的 Segment的锁。

###  

### JDK1.8 （上面有示意图）

ConcurrentHashMap取消了Segment分段锁，**采用CAS和synchronized来保证并发安全**。数据结构跟HashMap1.8的结构类似，数组+链表/红黑二叉树。Java 8在链表长度超过一定阈值（8）时将链表（寻址时间复杂度为O(N)）转换为红黑树（寻址时间复杂度为O(log(N))）

**synchronized只锁定当前链表或红黑二叉树的首节点，这样只要hash不冲突，就不会产生并发，效率又提升N倍。**

 

## （十五）comparable 和 Comparator的区别

- comparable接口实际上是出自java.lang包 它有一个 `compareTo(Object obj)`方法用来排序
- comparator接口实际上是出自 java.util 包它有一个`compare(Object obj1, Object obj2)`方法用来排序

一般我们需要对一个集合使用自定义排序时，我们就要重写`compareTo()`方法或`compare()`方法，当我们需要对某一个集合实现两种排序方式，比如一个song对象中的歌名和歌手名分别采用一种排序方法的话，我们可以重写`compareTo()`方法和使用自制的Comparator方法或者以两个Comparator来实现歌名排序和歌星名排序，第二种代表我们只能使用两个参数版的 `Collections.sort()`.





-----



# [数组和集合哪个效率高_Java集合](https://blog.csdn.net/weixin_39929566/article/details/111279776)

## 1、Java集合的诞生

通常，我们的Java程序需要根据程序运行时才知道创建了多少个对象。但若非程序运行，程序开发阶段，我们根本不知道到底需要多少个数量的对象，甚至不知道它的准确类型。为了满足这些常规的编程需要，我们要求能在任何时候，任何地点创建任意数量的对象，而这些对象用什么来容纳呢？我们首先想到了数组，但是！数组只能存放同一类型的数据，而且其长度是固定的，那怎么办呢？集合便应运而生了。

## 2、什么是Java集合

Java集合类存放在java.util包中，是一个用来存放对象的容器。

Java集合只能存放对象，比如当我们存入int型数放入集合中，它会自动转化为Integer类型。

集合存放的都是对象的引用，而非对象本身。所以我们称集合中的对象就是集合中对象的引用。对象本身还是存放在堆内存中。

集合可以存放不同类型、不限数量的数据类型。

## 3、集合和数组的区别：

**长度区别：**

- 数组固定
- 集合可变

**内容区别：**

- 数组可以是基本数据类型，也可以是引用类型


- 集合只能是引用类型


**元素内容**

- 数组只能存储同一种类型


- 集合可以存储不同类型


## 4、常用集合分类

**Collection 接口：对象的集合**

- List 接口：有序、可重复
  - **LinkList** 接口实现类，链表、没有同步，线程不安全，增删速度快
  - **ArrayList** 接口实现类，数组、没有同步，线程不安全，随机访问
  - **Vector** 接口实现类，数组，同步，线程安全

- **Set 接口：不可重复，内部排序**
  - **HashSet** 使用hash表(数组)存储元素
  - **TreeSet** 底层实现为二叉树

- **Map 接口：键值对的集合**

- **Hashtable** 接口实现类，同步，线程安全

- **HashMap** 接口实现类，没有同步，线程不安全
  - **LinkedHashMap** 双向链表和哈希表实现

- **TreeMap** 红黑树对所有的key进行排序

## 5、List详解

### **ArrayList** 解析

==**(底层数据结构是数组，查询快，增删慢，线程不安全，效率高，可以存储重复元素 )**==

![026b7a5857939971651a96ba938cbfb7.png](Java集合详解.assets/026b7a5857939971651a96ba938cbfb7.png)

根据上面我们可以清晰的发现：**==ArrayList底层其实就是一个数组==**，ArrayList中有**==扩容==**这么一个概念，正因为它扩容，所以它**能够实现“动态”增长。**

构造方法

![0987c2b7ca7fcab912d4594e291ea7ab.png](Java集合详解.assets/0987c2b7ca7fcab912d4594e291ea7ab.png)

add方法

![cb764bd26c87077f65fedf8e90318936.png](Java集合详解.assets/cb764bd26c87077f65fedf8e90318936.png)

步骤：

1️⃣调用 ensureCapacityInternal(size + 1); 检查是否需要扩容

2️⃣确认list容量，尝试容量加1是否满足，

![02f996b13213842a8bb08387315bf458.png](Java集合详解.assets/02f996b13213842a8bb08387315bf458.png)

3️⃣ 调用ensureExplicitCapacity(minCapacity);方法，来确定容量；如果要的最小容量比数组的长度要大，就调用grow()来扩容，相当于扩容1.5倍(当添加第11个元素时，minCapacity为11，数组长度为10，那么就需要扩容了)，

![c51c2edbcf2d29d6eebfa6435544a962.png](Java集合详解.assets/c51c2edbcf2d29d6eebfa6435544a962.png)

get()方法

```java
public E get(int index) {        
    rangeCheck(index);   //检查角标        
                         return elementData(index);  //返回具体元素    
}
```

set()方法

```java
public E set(int index, E element) {        rangeCheck(index);        
                                    E oldValue = elementData(index);//检查角标        
                                    elementData[index] = element;   //替换元素       
                                    return oldValue;                    //返回旧值      
                                   }
```

remove()方法(检查角标、删除元素、计算出需要移动的个数，并移动，gc回收)

![af176ab88a9b7fb0bbf576e53a4be0cb.png](Java集合详解.assets/af176ab88a9b7fb0bbf576e53a4be0cb.png)

**ArrayList总结：**

- ArrayList是**基于动态数组实现的，在增删时候，需要数组的拷贝复制。**


- **ArrayList的默认初始化容量是10，每次扩容时候增加原先容量的一半，也就是变为原来的1.5倍**

- 删除元素时不会减少容量，**若希望减少容量则调用trimToSize()**


- 它**不是线程安全**的。它能存放null值。

  

### Vector解析

**==(底层数据结构是数组，查询快，增删慢，线程安全，效率低，可以存储重复元素 )==**

Vector是jdk1.2的类了，比较老的一个集合类，Vector底层也是数组，与ArrayList最大的区别的就是：同步(线程安全)

线程安全，方法都由synchronized修饰。

扩容为原来的2倍

### LinkedList解析

==**(底层数据结构是链表，查询慢，增删快，线程不安全，效率高，可以存储重复元素)**==

LinkedList的方法比ArrayList的方法多太多了，这里我就不一一说明了。具体可参考：https://blog.csdn.net/panweiwei1994/article/details/77110354。

## 6、set详解

### HashSet

**==(无序，允许为null，底层是HashMap(散列表+红黑树)，非线程同步安全)==**

我们知道Map是一个映射，有key有value，既然HashSet底层用的是HashMap，那么value在哪里呢？？？

从下面的源代码我们可以直接总结出：**HashSet实际上就是封装了HashMap，操作HashSet元素实际上就是操作HashMap。**

![5210bbc01ee9675fedbae184e193b5e9.png](Java集合详解.assets/5210bbc01ee9675fedbae184e193b5e9.png)

### TreeSet

**==(有序，不允许为null，底层是TreeMap(红黑树),非线程同步（安全）)==**

底层实际上是一个TreeMap实例

![5a925e37e82450ee8a85fdba5bb50798.png](Java集合详解.assets/5a925e37e82450ee8a85fdba5bb50798.png)

### LinkedHashSet

**==(迭代有序，允许为null，底层是HashMap+双向链表，非线程同步)==**

- 迭代是有序的
- 允许为null
- **底层实际上是一个HashMap+双向链表实例(其实就是LinkedHashMap)**
- 非线程同步，不是线程安全的
- **性能比HashSet差一丢丢，因为要维护一个双向链表**
- 初始容量与迭代无关，LinkedHashSet迭代的是双向链表



## 7、Map详解

前面我们学习的Collection叫做集合，它可以快速查找现有的元素。而Map在《Core Java》中称之为-->映射，就是key----------value的形式。那为什么我们需要这种数据存储结构呢？举个例子；作为学生来说，我们是根据学号来区分不同的学生。只要我们知道学号(key)，就可以获取对应的学生信息(value)。这就是Map映射的作用！

**Map与Collection的区别**

- Map集合储存元素是成对出现的，Map的键是唯一的，值是可以重复的。
- Collection集合存储元素是单独出现的，Collection的儿子Set是唯一的，List是可以重复的
- Map集合的数据结构针对键有效，跟值无关
- Collection集合的数据结构针对元素有效

**Map的常用方法及功能**

![7ce04a6b959f7abc37b424c28466dd37.png](Java集合详解.assets/7ce04a6b959f7abc37b424c28466dd37.png)

### HashMap

- 计算node节点的位置的算法是**(n-1)&hash**，n代表map的容量，扩容后的容量n只是在二进制高位多了个1，实际上去判断与之对应的hash值的二进制为0或1就可以明确map扩容后节点的位置是否需要发生变化，若hash对应的二进制为1，则证明索引需要变化，变化的大小只需要加上旧map的容量即可。(因为map扩容后容量的高位多了个1，就需要比较前后两次(n-1)&hash的值是否相同)
- HashMap基于Map接口实现，元素以键值对的方式存储，并且允许空键和空值，**但是由于key不可重复，所以只允许有一个键为空。==HashMap 是无序的，HashMap是线程不安全的。HashMap是一个散列表的数据结构，即数组和链表的结合体，他的底层是一个数组结构，数组中的每一项又是一个链表结构。==**
- 当我们往HashMap中put元素的时候，先根据key的hashCode重新计算hash值，根**据hash值得到这个元素在数组中的位置(即下标)，如果数组该位置上已经存放有其他元素了，那么在这个位置上的元素将以链表的形式存放，新加入的放在链头，最先加入的放在链尾。如果数组该位置上没有元素，就直接将该元素放到此数组中的该位置上。**
- jdk7是将节点重新hash，分配到新的数组中。
- jdk8是将节点的hash值和旧hashmap的容量进行与运算，若与的结果为0，则扩容后的位置跟原位置一样。如果结果为不为0，扩容后的位置=原索引位置加上旧hashmap的容量
- HashMap 是一个最常用的Map,**它根据键的HashCode 值存储数据**,根据键可以直接获取它的值，具有很快的访问速度。
- HashMap最多只允许一条记录的键为Null;允许多条记录的值为 Null;
- **HashMap不支持线程的同步，即任一时刻可以有多个线程同时写HashMap;可能会导致数据的不一致。如果需要同步，可以用 Collections的synchronizedMap方法使HashMap具有同步的能力，或者使用ConcurrentHashMap。**
- HashMap基于哈希表结构实现的 ，当一个对象被当作键时，必须重写hasCode和equals方法。

### LinkedHashMap

LinkedHashMap内部是**双向链表结构**，保存了元素插入的顺序，Iterator遍历元素时按照插入的顺序排列，**支持线程同步**。

### TreeMap

- TreeMap基于**==红黑树==**数据结构的实现，键值可以使用**Comparable或Comparator接口**来排序。TreeMap继承自AbstractMap，同时实现了接口NavigableMap，而接口NavigableMap则继承自SortedMap。SortedMap是Map的子接口，使用它可以确保图中的条目是排好序的。
- 在实际使用中，如果更新图时不需要保持图中元素的顺序，就使用HashMap，如果需要保持图中元素的插入顺序或者访问顺序，就使用LinkedHashMap，如果需要使图按照键值排序，就使用TreeMap。

### Hashtable

Hashtable和前面介绍的HashMap很类似，它也是一个散列表，存储的内容是键值对映射，不同之处在于，Hashtable是继承自Dictionary的，**==Hashtable中的函数都是同步的，这意味着它也是线程安全的==**，另外，**Hashtable中key和value都不可以为null。**

### 散列表介绍

无论是Set还是Map，我们会发现都会有对应的-->HashSet,HashMap

首先我们也先得回顾一下数组和链表：

而还有另外的一些存储结构：**不在意元素的顺序，能够快速的查找元素的数据**

- 其中就有一种非常常见的：**散列表**
- 链表和数组都可以按照人们的意愿来排列元素的次序，他们可以说是有序的(存储的顺序和取出的顺序是一致的)
- 但同时，这会带来缺点：想要获取某个元素，就要访问所有的元素，直到找到为止。
- 这会让我们消耗很多的时间在里边，比如遍历访问元素

#### 散列表的工作原理

散列表**为每个对象计算出一个整数，称为散列码。**根据这些计算出来的**整数(散列码)保存在对应的位置上**！在Java中，**==散列表用的是链表数组实现的==，每个列表称之为桶。**    

![94adb17fe3795233bc231077fcd5188b.png](Java集合详解.assets/94adb17fe3795233bc231077fcd5188b.png)

**一个桶上可能会遇到被占用的情况(hashCode散列码相同，就存储在同一个位置上)，这种情况是无法避免的，**

如果散列表太满，是需要**对散列表再散列，创建一个桶数更多的散列表，并将原有的元素插入到新表中，丢弃原来的表~这种现象称之为：散列冲突**

- 装填因子(load factor)决定了何时对散列表再散列~
- 装填因子默认为0.75，如果表中超过了75%的位置已经填入了元素，那么这个表就会用**双倍的桶数**自动进行再散列
- 此时需要用该对象与桶上的对象进行比较，看看该对象是否存在桶子上了~如果存在，就不添加了，如果不存在则添加到桶子上

- 当然了，如果hashcode函数设计得足够好，桶的数目也足够，这种比较是很少的~
- 在JDK1.8中，桶满时会从链表变成**平衡二叉树**

### 红黑树

附上两篇文章：

https://riteme.github.io/blog/2016-3-12/2-3-tree-and-red-black-tree.html#fn:red-is-left

https://blog.csdn.net/chen_zhang_yu/article/details/52415077

最后附上一篇集合详解的文章：https://www.cnblogs.com/linliquan/p/11323172.html

相关资源：浅谈java中集合的由来,以及集合和数组的区别详解_java集合的由来...