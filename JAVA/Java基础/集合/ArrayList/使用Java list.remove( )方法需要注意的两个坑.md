# [使用Java list.remove( )方法需要注意的两个坑](https://www.cnblogs.com/jiangjunlucode/articles/9908834.html)

### list.remove

第一种使用：

最近研究数据结构，需要用到list.remove()方法进行链表的节点删除的时候，发现两个有趣的坑，经过分析后找到原因，记录一下跟大家分享一下。

```java
public class Main {

    public static void main(String[] args) {
        List<String> stringList = new ArrayList<>();//数据集合
        List<Integer> integerList = new ArrayList<>();//存储remove的位置

        stringList.add("a");
        stringList.add("b");
        stringList.add("c");
        stringList.add("d");
        stringList.add("e");

        integerList.add(2);
        integerList.add(4);//此处相当于要移除最后一个数据

        for (Integer i :integerList){
            stringList.remove(i);
        }

        for (String s :stringList){
            System.out.println(s);
        }
    }
}
```

如上代码我们有一个5个元素的list数据集合，我们要删除第2个和第4个位置的数据。运行代码执行的结果是a b c d e。

为什么执行两次remove()，stringList的数据没有变化呢？ 

没有报错，说明代码没有问题，那问题出在哪呢？
仔细分析我们发现，remove()这个方法是一个重载方法，即remove(int position)和remove(object object)，唯一的区别是参数类型。

仔细观察上面代码你会发现，其实i是Integer对象，而由于Java系统中如果找不到准确的对象，会自动向上升级，而(int < Integer < Object)，所以在调用stringList.remove(i)时，其实使用的remove(object object)，而很明显stringList不存在Integer对象，自然会移除失败（0.0），Java也不会因此报错。
如果我们想使用remove(int position)方法，只能降低对象等级，即修改代码；

```java
for (Integer i :integerList){
             int a =i;
             stringList.remove(a);
         }
```

运行代码执行的结果是抛出异常：java.lang.IndexOutOfBoundsException:Index :4 ,Size:4

我们发现提示在坐标为4的地方越界了，这是为什么呢？
其实很简单，因为执行stringList.remove(2)后，list.size()就-1为4了，我们原来要移除的最后一个位置的数据移动到了第3个位置上，自然就造成了越界。

我们修改代码先执行stringList.remove(4)，再执行执行stringList.remove(2)。结果OK通过正常删除。
这个错误提醒我们：使用remove()的方法时，要先从大到小的位置移除。当然如果你知道具体的对象，直接移除remove(对象)更稳妥。

在使用remove()的时候需要注意：

1 使用remove()的方法时，要先从大到小的位置移除。当然如果你知道具体的对象，直接移除remove(对象)更稳妥。

2 要密切注意自己调用的remove()方法中的，传入的是int类型还是一个对象。

第二种使用方式：

使用Iterator进行迭代,先看一段代码

```java
Collection<String> coll = new ArrayList<String>();
        coll.add("123");
        coll.add("234");
        coll.add("456");
        for (Iterator<String> it = coll.iterator(); it.hasNext();) {
            String object = it.next();
            System.out.println(object);
            if ("123".equals(object)) {
                coll.remove(object);
            }
        }
```

初步看一下是否能找出代码存在的问题？

以上代码执行就会报异常：java.util.ConcurrentModificationException

通过异常进行分析：

in thread "main" java.util.ConcurrentModificationException
at java.util.AbstractList$Itr.checkForComodification(AbstractList.java:372)
at java.util.AbstractList$Itr.next(AbstractList.java:343)

原因：

当集合使用Iterator进行迭代的时候，实际是new Itr()创建一个内部对象，初始化包含对象个数，可以理解为在独立线程中操作的。Iterator创建之后引用指向原来的集合对象。当原来的对象数量发生变化时，这个内部对象索引表内容其实是不会同步的。所以，当索引指针往后移动的时候就找不到要迭代的对象了。内部对象操作时为了避免这种情况都会通过checkForComodification方法检测是否一致，不一致提前抛出异常ConcurrentModifiedException。


解决办法：
Iterator 支持从源集合中安全地删除对象，只需在 Iterator 上调用 remove() 即可。这样做的好处是可以避免 ConcurrentModifiedException ，这个异常顾名思意：当打开 Iterator 迭代集合时，同时又在对集合进行修改。有些集合不允许在迭代时删除或添加元素，但是调用 Iterator 的 remove() 方法是个安全的做法。

```java
Collection<String> coll = new ArrayList<String>();
        coll.add("123");
        coll.add("234");
        coll.add("456");
        for (Iterator<String> it = coll.iterator(); it.hasNext();) {
            String object = it.next();
            System.out.println(object);
            if ("123".equals(object)) {
                it.remove(object);
            }
        }
```

