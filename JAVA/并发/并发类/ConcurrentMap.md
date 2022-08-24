# [ConcurrentMap](https://www.jianshu.com/p/8f7b2cd34c47)

ConcurrentMap，它是一个接口，是一个能够支持[并发](https://so.csdn.net/so/search?q=并发&spm=1001.2101.3001.7020)访问的java.util.map集合；

[ConcurrentHashMap](https://so.csdn.net/so/search?q=ConcurrentHashMap&spm=1001.2101.3001.7020)是一个线程安全，并且是一个高效的HashMap。

spring 缓存注解 通过查看源代码发现将数据存在ConcurrentMap中

## 1 Map并发[集合](https://so.csdn.net/so/search?q=集合&spm=1001.2101.3001.7020)

### 1.1 ConcurrentMap

ConcurrentMap，它**是一个接口**，是一个能够支持并发访问的java.util.map集合；

在原有java.util.map接口基础上又新提供了4种方法，进一步扩展了原有Map的功能：

```java
public interface ConcurrentMap<K, V> extends Map<K, V> {
 
    //插入元素
    V putIfAbsent(K key, V value);
 
    //移除元素
    boolean remove(Object key, Object value);
 
    //替换元素
    boolean replace(K key, V oldValue, V newValue);
 
    //替换元素
    V replace(K key, V value);
}
```

**putIfAbsent：**与原有put方法不同的是，putIfAbsent方法中如果插入的key相同，则不替换原有的value值；

**remove：**与原有remove方法不同的是，新remove方法中增加了对value的判断，如果要删除的key--value不能与Map中原有的key--value对应上，则不会删除该元素;

**replace(K,V,V)：**增加了对value值的判断，如果key--oldValue能与Map中原有的key--value对应上，才进行替换操作；

**replace(K,V)：**与上面的replace不同的是，此replace不会对Map中原有的key--value进行比较，如果key存在则直接替换；

其实，对于ConcurrentMap来说，我们更关注Map本身的操作，在并发情况下是如何实现数据安全的。在java.util.concurrent包中，ConcurrentMap的实现类主要以ConcurrentHashMap为主。接下来，我们具体来看下。

### 1.2 ConcurrentHashMap

**ConcurrentHashMap是一个[线程安全](https://so.csdn.net/so/search?q=线程安全&spm=1001.2101.3001.7020)，并且是一个高效的HashMap。**

但是，如果从线程安全的角度来说，HashTable已经是一个线程安全的HashMap，那推出ConcurrentHashMap的意义又是什么呢？

说起ConcurrentHashMap，就不得不先提及下HashMap在线程不安全的表现，以及HashTable的效率！

- HashMap

关于HashMap的讲解，在此前的文章中已经说过了，本篇不在做过多的描述，有兴趣的朋友可以来这里看下--[HashMap](https://www.jianshu.com/p/a17b4717a721)。

在此节中，我们主要来说下，在多线程情况下HashMap的表现？

HashMap中添加元素的源码：（基于JDK1.7.0_45）

```java
public V put(K key, V value) {
    。。。忽略
    addEntry(hash, key, value, i);
    return null;
}
void addEntry(int hash, K key, V value, int bucketIndex) {
    。。。忽略
    createEntry(hash, key, value, bucketIndex);
}
//向链表头部插入元素：在数组的某一个角标下形成链表结构；
void createEntry(int hash, K key, V value, int bucketIndex) {
    Entry<K,V> e = table[bucketIndex];
    table[bucketIndex] = new Entry<>(hash, key, value, e);
    size++;
}
```

**在多线程情况下，同时A、B两个线程走到createEntry()方法中，并且这两个线程中插入的元素[hash](https://so.csdn.net/so/search?q=hash&spm=1001.2101.3001.7020)值相同，bucketIndex值也相同，那么无论A线程先执行，还是B线程先被执行，最终都会2个元素先后向链表的头部插入，导致互相覆盖，致使其中1个线程中的数据丢失。这样就造成了HashMap的线程不安全，数据的不一致；**

更要命的是，HashMap在多线程情况下还会出现死循环的可能，造成CPU占用率升高，导致系统卡死。

举个简单的例子：

```java
public class ConcurrentHashMapTest {
    public static void main(String[] agrs) throws InterruptedException {
 
        final HashMap<String,String> map = new HashMap<String,String>();
 
        Thread t = new Thread(new Runnable(){
            public  void run(){
                
                for(int x=0;x<10000;x++){
                    Thread tt = new Thread(new Runnable(){
                        public void run(){
                            map.put(UUID.randomUUID().toString(),"");
                        }
                    });
                    tt.start();
                    System.out.println(tt.getName());
                }
            }
        });
        t.start();
        t.join();
    }
}
```

在上面的例子中，我们利用for循环，启动了10000个线程，每个线程都向共享变量中添加一个元素。

测试结果：通过使用JDK自带的jconsole工具，可以看到HashMap内部形成了死循环，并且主要集中在两处代码上。

那么，是什么原因造成了死循环？

**HashMap--put()494行：**（基于JDK1.7.0_45）

```java
public V put(K key, V value) {
    if (table == EMPTY_TABLE) {
        inflateTable(threshold);
    }
    if (key == null)
        return putForNullKey(value);
    int hash = hash(key);
    int i = indexFor(hash, table.length);
    for (Entry<K,V> e = table[i]; e != null; e = e.next) {------**for循环494行**
        Object k;
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }
    modCount++;
    addEntry(hash, key, value, i);
    return null;
}
```

**HashMap--transfer()601行：**（基于JDK1.7.0_45）

```java
void transfer(Entry[] newTable, boolean rehash) {
    int newCapacity = newTable.length;
    for (Entry<K,V> e : table) {
        while(null != e) {
            Entry<K,V> next = e.next;
            if (rehash) {
                e.hash = null == e.key ? 0 : hash(e.key);
            }
            int i = indexFor(e.hash, newCapacity);
            e.next = newTable[i];
            newTable[i] = e;
            e = next;
        }-----**while循环601行**
    }
}
```

通过查看代码，可以看出，死循环的产生：主要因为在遍历数组角标下的链表时，没有了为null的元素，单向链表变成了循环链表，头尾相连了。

以上两点，就是HashMap在多线程情况下的表现。

- HashTable

说完了HashMap的线程不安全，接下来说下HashTable的效率！！

HashTable与HashMap的结构一致，都是哈希表实现。

与HashMap不同的是，在HashTable中，所有的方法都加上了synchronized锁，用锁来实现线程的安全性。由于synchronized锁加在了HashTable的每一个方法上，所以这个锁就是HashTable本身--this。那么，可想而知HashTable的效率是如何，安全是保证了，但是效率却损失了。

无论执行哪个方法，整个哈希表都会被锁住，只有其中一个线程执行完毕，释放所，下一个线程才会执行。无论你是调用get方法，还是put方法皆是如此；

HashTable部分源码：（基于JDK1.7.0_45）

```java
public class Hashtable<K,V> extends Dictionary<K,V> 
    implements Map<K,V>, Cloneable, java.io.Serializable {
    
    public synchronized int size() {...}
 
    public synchronized boolean isEmpty() {...}
 
    public synchronized V get(Object key) {...}
 
    public synchronized V put(K key, V value) {...}
}
```

通过上述代码，可以清晰看出，在HashTable中的主要操作方法上都加了synchronized锁以来保证线程安全。

说完了HashMap和HashTable，下面我们就重点介绍下ConcurrentHashMap，看看ConcurrentHashMap是如何来解决上述的两个问题的！

### 1.3 ConcurrentHashMap结构

在说到ConcurrentHashMap源码之前，我们首先来了解下ConcurrentHashMap的整体结构，这样有利于我们快速理解源码。

不知道，大家还是否记得HashMap的整体结构呢？如果忘记的话，我们就在此进行回顾下！



![img](https:////upload-images.jianshu.io/upload_images/5621908-1e81a73a1afaebb7.png?imageMogr2/auto-orient/strip|imageView2/2/w/724/format/webp)

HashMap底层使用数组和链表，实现哈希表结构。插入的元素通过散列的形式分布到数组的各个角标下；当有重复的散列值时，便将新增的元素插入在链表头部，使其形成链表结构，依次向后排列。

**下面是，ConcurrentHashMap的结构：**



![img](https:////upload-images.jianshu.io/upload_images/5621908-77efbdbf6c79fac9.png?imageMogr2/auto-orient/strip|imageView2/2/w/783/format/webp)

与HashMap不同的是，ConcurrentHashMap中多了一层数组结构，由Segment和HashEntry两个数组组成。其中Segment起到了加锁同步的作用，而HashEntry则起到了存储K.V键值对的作用。

在ConcurrentHashMap中，每一个ConcurrentHashMap都包含了一个Segment数组，在Segment数组中每一个Segment对象则又包含了一个HashEntry数组，而在HashEntry数组中，每一个HashEntry对象保存K-V数据的同时又形成了链表结构，此时与HashMap结构相同。

在多线程中，每一个Segment对象守护了一个HashEntry数组，当对ConcurrentHashMap中的元素修改时，在获取到对应的Segment数组角标后，都会对此Segment对象加锁，之后再去操作后面的HashEntry元素，这样每一个Segment对象下，都形成了一个小小的HashMap，在保证数据安全性的同时，又提高了同步的效率。只要不是操作同一个Segment对象的话，就不会出现线程等待的问题！





# [ConcurrentMap的详解](https://blog.csdn.net/weixin_33918357/article/details/91879714)

ConcurrentHashMap默认初始大小 16，临界值：12：基数：0.75

## 1.ConcurrentHashMap是一个线程安全的hashMap。

相对hashMap多出以下一些特殊属性：

```java
    //默认能够同时运行的线程数目
    static final int DEFAULT_CONCURRENCY_LEVEL = 16;
    //最大同时运行的线程数目
    static final int MAX_SEGMENTS = 1 << 16; // slightly conservative
```

## 2.ConcurrentHashMap的链表实例HashEntry：

```java
 static final class HashEntry<K,V> {
        final K key;
        final int hash;
        volatile V value;
        final HashEntry<K,V> next;
 
        HashEntry(K key, int hash, HashEntry<K,V> next, V value) {
            this.key = key;
            this.hash = hash;
            this.next = next;
            this.value = value;
        }
 
    @SuppressWarnings("unchecked")
    static final <K,V> HashEntry<K,V>[] newArray(int i) {
        return new HashEntry[i];
    }
    }
```

这里需要注意的是Value，value并不是final的，而是一个volatile.
volatile修饰符告诉编译程序不要对该变量所参与的操作进行某些优化。在两种特殊的情况下需要使用volatile修饰符：
第一种情况涉及到内存映射硬件(memory-mapped hardware，如图形适配器，这类设备对计算机来说就好象是内存的一部分一样)，
**第二种情况涉及到共享内存(shared memory，即被两个以上同时运行的程序所使用的内存)。**
    大多数计算机拥有一系列寄存器，其存取速度比计算机主存更快。好的编译程序能进行一种被称为“冗余装入和存储的删去”(redundant load and store removal)的优化，即编译程序会在程序中寻找并删去这样两类代码：一类是可以删去的从内存装入数据的指令，因为相应的数据已经被存放在寄存器中；另 一种是可以删去的将数据存入内存的指令，因为相应的数据在再次被改变之前可以一直保留在寄存器中。
    如果一个指针变量指向普通内存以外的位置，如指向一个外围设备的内存映射端口，那么冗余装入和存储的优化对它来说可能是有害的。
**ConcurrentHashMap不同于HashMap中的一点是，concurrentHashMap的put,get,remvoer等方法的实现都是由其内部类Segment实现的，该内部类：**

```java
static final class Segment<K,V> extends ReentrantLock implements Serializable {.....}
```

可以看出，该类实现了重入锁保证线程安全，使用final修饰保证方法不被篡改。

## 3、ConcurrentHashMap 中的 readValueUnderLock

```java
 V readValueUnderLock(HashEntry<K,V> e) {
            lock();
            try {
                return e.value;
            } finally {
                unlock();
            }
        }
```

该代码是在值为空的情况才调用；该方法在锁定的情况下获取值。由该方法的注释可以得知,这样做是为了防止在编译器重新定制一个指定的HashEntry实例初始化时，在内存模型中发生意外。

```
  /**
         * Reads value field of an entry under lock. Called if value
         * field ever appears to be null. This is possible only if a
         * compiler happens to reorder a HashEntry initialization with
         * its table assignment, which is legal under memory model
         * but is not known to ever occur.
         */
```

3.ConcurrentHashMap中的put方法：

```java
   public V put(K key, V value) {
        if (value == null)
            throw new NullPointerException();
        int hash = hash(key.hashCode());
        return segmentFor(hash).put(key, hash, value, false);
    }
```

**不允许null的键**
可以看出，ConcurrentHashMap和HashMap在对待null键的情况下截然不同，HashMap专门开辟了一块空间用于存储null键的情况，而ConcurrentHashMap则直接抛出空值针异常。

## 4、ConcurrentHashMap中segment的put方法：

```java
V put(K key, int hash, V value, boolean onlyIfAbsent) {
            lock();
            try {
                int c = count;
                if (c++ > threshold) // ensure capacity
                    rehash();
                HashEntry<K,V>[] tab = table;
                int index = hash & (tab.length - 1);
                HashEntry<K,V> first = tab[index];
                HashEntry<K,V> e = first;
                while (e != null && (e.hash != hash || !key.equals(e.key)))
                    e = e.next;
 
                V oldValue;
                if (e != null) {
                    oldValue = e.value;
                    if (!onlyIfAbsent)
                        e.value = value;
                }
                else {
                    oldValue = null;
                    ++modCount;
                    tab[index] = new HashEntry<K,V>(key, hash, first, value);
                    count = c; // write-volatile
                }
                return oldValue;
            } finally {
                unlock();
            }
```

  从该方法可以看出，根据key的hash值，计算到table下标位置之后，获取该下标位置的Entry链表，然后从链表第一个位置开始向后遍历，分别比 对entry的hash值和key的值，如果都相等且entry不为空，则获取 该entry，设置该entry的value为传入的value，否则往后遍历直到链表中最后一个位置,直到找到相匹配的key和hash；如果e为空， 则往该index下插入一个新的entry链表。
该方法使用了重入锁用以保证在同步时候线程的安全。

## 5、ConcurrentHashMa中segment的rehash方法

(当前数组容量不够，进行扩充的操作)：  

```java
 void rehash() {
            HashEntry<K,V>[] oldTable = table;
            int oldCapacity = oldTable.length;
            //如果数组的长度大于或等于临界值，数组不再进行扩容。
            if (oldCapacity >= MAXIMUM_CAPACITY)
                return;  
            //扩充数组容量为原来大小的两倍。
            HashEntry<K,V>[] newTable = HashEntry.newArray(oldCapacity<<1);
            //重新计算临界值
            threshold = (int)(newTable.length * loadFactor);
            
            int sizeMask = newTable.length - 1;
            for (int i = 0; i < oldCapacity ; i++) {
                // We need to guarantee that any existing reads of old Map can
                //  proceed. So we cannot yet null out each bin.
                HashEntry<K,V> e = oldTable[i];
 
                if (e != null) {
                    HashEntry<K,V> next = e.next;
                    //获取该链表在数组新的下标
                    int idx = e.hash & sizeMask;
 
                    //该链表不存在后续节点，直接把该链表存入新数组，无需其他操作
                    if (next == null)
                        newTable[idx] = e;
 
                    else {
                        // 存在后续节点，使用临时变量存储该链表，假设当前节点是最后节点。
                        HashEntry<K,V> lastRun = e;
                        //获取下标
                        int lastIdx = idx;
                        //遍历该链表的后续节点
                        for (HashEntry<K,V> last = next;
                             last != null;
                             last = last.next) {
                            //获取后一个节点的index
                            int k = last.hash & sizeMask;
                            //如果后一个节点的index值和前一个不相同,
                            //则使用后节点的index覆盖前一个节点并且设置该节点为最后节点，依次
                            //做相同的操作，直到链表的最后一个节点。
                            if (k != lastIdx) {
                                lastIdx = k;
                                lastRun = last;
                            }
                        }                       
                      //把链表最后节点的值传递给数组
                      //该数组下标为最后获取到的下标
                      newTable[lastIdx] = lastRun;
 
                        // 遍历老数组下得到的链表的节点值，复制到新的扩容后的数组中。
                        for (HashEntry<K,V> p = e; p != lastRun; p = p.next) {                   
                            //计算链表在新数组的下标
                            int k = p.hash & sizeMask;
                            //获取数组k下标的链表值。
                            HashEntry<K,V> n = newTable[k];
                            //把获取到的链表作为需要插入的新的entry的后续节点。
                            newTable[k] = new HashEntry<K,V>(p.key, p.hash,
                                                             n, p.value);
                        }
                    }
                }
            }
            //把扩容后的数组返回
            table = newTable;
        }
```

该方法的描述见代码注释

扩容时，每个线程先cas分若干桶（与核心数有关最小为16），对每个桶锁第一个元素，然后同样用高位链和低位链的方式完成重hash，并在最后在第一个桶出放一个ForwardingNode表示此桶已结束扩容迁移到新tab中。如果另外的线程在put的时候遇到ForwardingNode则会加入到扩容工作，每一个线程完成分给自己的段(bound)之后，会去拿另一段bound直至扩容全部完成。更改tab的引用到新的tab。如果另一个线程get的时候碰到ForwardingNode，则会调用ForwardingNode的find方法在新的tab中进行查找

## 6、ConcurrentHashMap中的remove方法：

```java
  public V remove(Object key) {
    int hash = hash(key.hashCode());
        return segmentFor(hash).remove(key, hash, null);
    }
```

## 7、ConcurrentHashMa中segment的remove方法:

```java
 V remove(Object key, int hash, Object value) {
            lock();
            try {
                int c = count - 1;
                HashEntry<K,V>[] tab = table;
                int index = hash & (tab.length - 1);
                HashEntry<K,V> first = tab[index];
                HashEntry<K,V> e = first;
                while (e != null && (e.hash != hash || !key.equals(e.key)))
                    e = e.next;
 
                V oldValue = null;
                if (e != null) {
                    V v = e.value;
                    if (value == null || value.equals(v)) {
                        oldValue = v;
                        // All entries following removed node can stay
                        // in list, but all preceding ones need to be
                        // cloned.
                        ++modCount;
                        HashEntry<K,V> newFirst = e.next;
                        for (HashEntry<K,V> p = first; p != e; p = p.next)
                            newFirst = new HashEntry<K,V>(p.key, p.hash,
                                                          newFirst, p.value);
                        tab[index] = newFirst;
                        count = c; // write-volatile
                    }
                }
                return oldValue;
            } finally {
                unlock();
            }
        }
```

类似于put方法，remove方法也使用了重入锁来保证线程安全；concurrentHashMap的remove方法不同于HashMap的 remove方法，在需要删除元素的index下的entry链表没有后续节点时候；后者的remove方法自己会负责回收删除元素的内存并且会移动删除 元素后面的元素来覆盖删除元素的位置，concurrentHashMap的remove方法只会回收内存却不会和HashMap一样移动元素。





# [ConcurrentMap入门](https://www.jianshu.com/p/1fe8fb16bcae)

基于java1.8：

ConcurrentMap重写了Map中的很多default方法，用来实现线程安全和内存一致性的原子操作。

很多的默认实现被重写，不允许使用null作为key/value

在多线程的的环境中，多个线程访问同一个map，ConcurrentHashMap是最合适的。

但是当Map只被一个线程访问时，那就用HashMap比较合适了，简单，性能稳定。

3.5 Pitfalls

读操作不会阻塞concurrenthashmap，而且还可以和更新操作重叠。为了更好的性能，他们只反映最近完成更新的操作，见官方[https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ConcurrentHashMap.html](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.oracle.com%2Fjavase%2F8%2Fdocs%2Fapi%2Fjava%2Futil%2Fconcurrent%2FConcurrentHashMap.html)

有许多要记住的：

1. 计算map集合状态的方法包含size，isEmpty，containsValue，只有在map没有其他线程更新时有用。

```java
@Test

public void givenConcurrentMap_whenUpdatingAndGetSize_thenError()

throws InterruptedException{

    final int MAX_SIZE = 1000;

    List<Integer> mapSizes = new ArrayList<>();

    ConcurrentMap<String, Integer> concurrentMap = new ConcurrentHashMap<>();

    Runnable collecitonMapSizes = () -> {

        for (int i = 0; i < MAX_SIZE; i++) {

            mapSizes.add(concurrentMap.size());

        }

    };

    Runnable updateMapData = () -> {

        for (int i = 0; i < MAX_SIZE; i++) {

            concurrentMap.put(String.valueOf(i), i);

        }

    };

    ExecutorService executorService =

            Executors.newFixedThreadPool(4);

    executorService.execute(updateMapData);

    executorService.execute(collecitonMapSizes);

    executorService.shutdown();

    executorService.awaitTermination(1, TimeUnit.SECONDS);

    Assert.assertNotEquals(MAX_SIZE, mapSizes.get(MAX_SIZE - 1).intValue());

    Assert.assertEquals(MAX_SIZE, concurrentMap.size());

}
```

如果并发更新是在严格的控制下，聚合状态的的结果还是可靠的。虽然，这些聚合的方法不能保证实时的精准，但是他们也许适合用来做监控或者估算。

注意使用size（）的时候应该使用mappingCount（）代替，它返回一个long count（），虽然在底层上他们是基于相同的估算的。

hashcode是很重要的，记住使用相同的hashcode是会严重影响性能的。

如果key实现了Comparable接口，ConcurrentHashMap可能使用比较排序后的keys来帮助斩断联系，改善。但是我们还是要避免使用相同的hashcode。

iterators只是为单线程设计的，他们提供了弱的一致性，也不直接报错，他们永远不会抛出CocurrentModificationException。

默认的初始capacity是16，在会随着concurrencyLevel调整。

要注意remapping函数，虽然我们可以remapping，使用compute或者merge函数。我们应该让他们保持快，短，简单，并且专注在当前mapping上，来避免不可预期的阻塞。

keys在concurrenthashmap里是无序的，在某些情况下，当排序是需要的，我们推荐使用ConcurrentSkipListMap。

4. ConcurrentNavigableMap

在某些需要排序的情况下，我么可以使用ConcurrentSkipListMap，一个concurrent类型的TreeMap。

作为ConcurrentMap的一个补充。ConcurrentNavigableMap支持完全排序keys，默认是按升序排的。并且可以并发排序。返回map的方法都兼容了并发。

subMap

headMap

tailMap

descendingMap

keySet()的iterators和spliterators是一种弱内存一致性。

navigableKeySet

keySet

descendingKeySet

5. ConcurrentSkipListMap

前面，我们讲了NavigableMap 接口，还有它的实现类TreeMap。ConcurrentSkipListMap可以看成是并发版的TreeMap。

在实际中，java中没有红黑树的实现。ConcurrentSkipListMap是使用的SkipLists的一个并发版的变种，提供了一个时间复杂度为log（n）的containsKey， get， put，remove以及他们的变种。

另外，TreeMap的特性，key 插入，删除，更新，以及访问都是线程安全的。下面就来比较一下TreeMap在并发条件下的表现。

```java
@Test

public void giventSkipListMap_whenNavConcurrently_thenCOuntCorrect()

        throws InterruptedException {

    NavigableMap<Integer, Integer> skipListMap =

            new ConcurrentSkipListMap<>();

    int count = countMapElementByPollingFirstEntry(skipListMap, 10000, 4);

    Assert.assertEquals(10000 * 4, count);

}

@Test

public void giventTreeMap_whenNavCOncurrently_thenCOuntError()

        throws InterruptedException {

    NavigableMap<Integer, Integer> treeMap = new TreeMap<>();

    int count = countMapElementByPollingFirstEntry(treeMap, 10000, 4);

    Assert.assertNotEquals(10000 * 4, count);

}

private int countMapElementByPollingFirstEntry(

        NavigableMap<Integer, Integer> navigableMap,

        int elementCount,

        int concurrencyLevel) throws InterruptedException {

    for (int i = 0; i < elementCount * concurrencyLevel; i++) {

        navigableMap.put(i, 1);

    }

    AtomicInteger counter = new AtomicInteger(0);

    ExecutorService executorService =

            Executors.newFixedThreadPool(concurrencyLevel);

    for (int j = 0; j < concurrencyLevel; j++) {

        executorService.execute(() -> {

            for (int i = 0; i < elementCount; i++) {

                if (navigableMap.pollFirstEntry() != null) {

                    counter.incrementAndGet();

                }

            }

        });

    }

    executorService.shutdown();

    executorService.awaitTermination(1, TimeUnit.SECONDS);

    return counter.get();

}
```

