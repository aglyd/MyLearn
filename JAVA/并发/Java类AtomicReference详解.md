# [Java类AtomicReference详解](https://www.cnblogs.com/fhblikesky/p/13692643.html)

# 前言

Atomic家族主要是保证多线程环境下的原子性，相比synchronized而言更加轻量级。比较常用的是AtomicInteger，作用是对Integer类型操作的封装，而AtomicReference作用是对普通对象的封装。

对AtomicInteger原子性不了解的，可以看这篇：[volatile详解](https://blog.csdn.net/qq_28834355/article/details/108623535)

# 先看个例子

> 先简单定义个 User 类

```java
@Data
@AllArgsConstructor
public class User {
    private String name;
    private Integer age;
}
```

> 使用 AtomicReference 初始化，并赋值

```java
public static void main( String[] args ) {
    User user1 = new User("张三", 23);
    User user2 = new User("李四", 25);
    User user3 = new User("王五", 20);

	//初始化为 user1
    AtomicReference<User> atomicReference = new AtomicReference<>();
    atomicReference.set(user1);

	//把 user2 赋给 atomicReference
    atomicReference.compareAndSet(user1, user2);
    System.out.println(atomicReference.get());

	//把 user3 赋给 atomicReference
    atomicReference.compareAndSet(user1, user3);
    System.out.println(atomicReference.get());
}
```

输出结果如下：

```bash
User(name=李四, age=25)
User(name=李四, age=25)
```

# 解释

> compareAndSet(V expect, V update)

该方法作用是：如果atomicReference==expect，就把update赋给atomicReference，否则不做任何处理。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200917104859504.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzI4ODM0MzU1,size_16,color_FFFFFF,t_70#pic_center)

- atomicReference的初始值是user1，所以调用compareAndSet(user1, user2)，由于user1==user1，所以会把user2赋给atomicReference。此时值为“李四”
- 第二次调用atomicReference.compareAndSet(user1, user3)，由于user2 != user1，所以set失败。atomicReference仍然为“李四”



AtomicReference类提供了一个可以原子读写的对象引用变量。 原子意味着尝试更改相同AtomicReference的多个线程（例如，使用比较和交换操作）不会使AtomicReference最终达到不一致的状态。 AtomicReference甚至有一个先进的compareAndSet（）方法，它可以将引用与预期值（引用）进行比较，如果它们相等，则在AtomicReference对象内设置一个新的引用。