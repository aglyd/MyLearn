# @Retention注解作用

分类专栏： [spring](https://blog.csdn.net/m0_37840000/category_7775570.html) 文章标签： [注解](https://www.csdn.net/tags/MtTaEg0sMTYzOTUtYmxvZwO0O0OO0O0O.html)

@Retention作用是定义**被它所注解的注解保留多久**，一共有三种策略，定义在RetentionPolicy枚举中.

从注释上看：

source：注解只保留在源文件，当Java文件编译成class文件的时候，注解被遗弃；被编译器忽略

class：注解被保留到class文件，但jvm加载class文件时候被遗弃，这是默认的生命周期

runtime：注解不仅被保存到class文件中，jvm加载class文件之后，仍然存在

这3个生命周期分别对应于：Java源文件(.java文件) ---> .class文件 ---> 内存中的字节码。

![img](https://img-blog.csdn.net/20180705092609373?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L20wXzM3ODQwMDAw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)



那怎么来选择合适的注解生命周期呢？

首先要明确生命周期长度 **SOURCE < CLASS < RUNTIME** ，所以前者能作用的地方后者一定也能作用。一般如果需要**在运行时去动态获取注解信息，那只能用 RUNTIME 注解**；如果要**在编译时进行一些预处理操作**，比如生成一些辅助代码（如 [ButterKnife](https://github.com/JakeWharton/butterknife)）**，就用 CLASS注解**；如果**只是做一些检查性的操作**，比如 **@Override** 和 **@SuppressWarnings**，则**可选用 SOURCE 注解**。

下面来介绍下运行时注解的简单运用。

**获取注解**

你需要通过反射来获取运行时注解，可以从 Package、Class、Field、Method...上面获取，基本方法都一样，几个常见的方法如下：



```java

```

1. */***
2. ** 获取指定类型的注解*
3. **/*
4. public <A extends Annotation> A getAnnotation(Class<A> annotationType);
5. 
6. */***
7. ** 获取所有注解，如果有的话*
8. **/*
9. public Annotation[] getAnnotations();
10. 
11. */***
12. ** 获取所有注解，忽略继承的注解*
13. **/*
14. public Annotation[] getDeclaredAnnotations();
15. 
16. */***
17. ** 指定注解是否存在该元素上，如果有则返回true，否则false*
18. **/*
19. public boolean isAnnotationPresent(Class<? extends Annotation> annotationType);
20. 
21. */***
22. ** 获取Method中参数的所有注解*
23. **/*
24. public Annotation[][] getParameterAnnotations();



要使用这些函数必须先通过反射获取到对应的元素：Class、Field、Method 等。

**自定义注解**

来看下自定义注解的简单使用方式，这里先定义3个运行时注解：



```java

```

1. *// 适用类、接口（包括注解类型）或枚举*
2. @Retention(RetentionPolicy.RUNTIME)
3. @Target(ElementType.TYPE)
4. public @interface ClassInfo {
5. String value();
6. }
7. *// 适用field属性，也包括enum常量*
8. @Retention(RetentionPolicy.RUNTIME)
9. @Target(ElementType.FIELD)
10. public @interface FieldInfo {
11. int[] value();
12. }
13. *// 适用方法*
14. @Retention(RetentionPolicy.RUNTIME)
15. @Target(ElementType.METHOD)
16. public @interface MethodInfo {
17. String name() default "long";
18. String data();
19. int age() default 27;
20. }

这3个注解分别适用于不同的元素，并都带有不同的属性，在使用注解是需要设置这些属性值。



再定义一个测试类来使用这些注解：



```java

```

1. */***
2. ** 测试运行时注解*
3. **/*
4. @ClassInfo( "Test Class")
5. public class TestRuntimeAnnotation {
6. 
7. @FieldInfo(value = { 1, 2})
8. public String fieldInfo = "FiledInfo";
9. 
10. @FieldInfo(value = { 10086})
11. public int i = 100;
12. 
13. @MethodInfo(name = "BlueBird", data = "Big")
14. public static String getMethodInfo() {
15. return TestRuntimeAnnotation.class.getSimpleName();
16. }
17. }



使用还是很简单的，最后来看怎么在代码中获取注解信息：



```java

```

1. */***
2. ** 测试运行时注解*
3. **/*
4. private void _testRuntimeAnnotation() {
5. StringBuffer sb = new StringBuffer();
6. Class<?> cls = TestRuntimeAnnotation.class;
7. Constructor<?>[] constructors = cls.getConstructors();
8. *// 获取指定类型的注解*
9. sb.append( "Class注解：").append( "\n");
10. ClassInfo classInfo = cls.getAnnotation(ClassInfo.class);
11. if (classInfo != null) {
12. sb.append(Modifier.toString(cls.getModifiers())).append( " ")
13. .append(cls.getSimpleName()).append( "\n");
14. sb.append( "注解值: ").append(classInfo.value()).append( "\n\n");
15. }
16. 
17. sb.append( "Field注解：").append( "\n");
18. Field[] fields = cls.getDeclaredFields();
19. for (Field field : fields) {
20. FieldInfo fieldInfo = field.getAnnotation(FieldInfo.class);
21. if (fieldInfo != null) {
22. sb.append(Modifier.toString(field.getModifiers())).append( " ")
23. .append(field.getType().getSimpleName()).append( " ")
24. .append(field.getName()).append( "\n");
25. sb.append( "注解值: ").append(Arrays.toString(fieldInfo.value())).append( "\n\n");
26. }
27. }
28. 
29. sb.append( "Method注解：").append( "\n");
30. Method[] methods = cls.getDeclaredMethods();
31. for (Method method : methods) {
32. MethodInfo methodInfo = method.getAnnotation(MethodInfo.class);
33. if (methodInfo != null) {
34. sb.append(Modifier.toString(method.getModifiers())).append( " ")
35. .append(method.getReturnType().getSimpleName()).append( " ")
36. .append(method.getName()).append( "\n");
37. sb.append( "注解值: ").append( "\n");
38. sb.append( "name: ").append(methodInfo.name()).append( "\n");
39. sb.append( "data: ").append(methodInfo.data()).append( "\n");
40. sb.append( "age: ").append(methodInfo.age()).append( "\n");
41. }
42. }
43. 
44. System.out.print(sb.toString());
45. }



所做的操作都是通过反射获取对应元素，再获取元素上面的注解，最后得到注解的属性值。

看一下输出情况，这里我直接显示在手机上：

![img](https://img-blog.csdn.net/20160804145145432?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)



这个自定义运行时注解是很简单的例子，有很多优秀的开源项目都有使用运行时注解来处理问题，有兴趣可以找一些来研究。因为涉及到反射，所以运行时注解的效率多少会受到影响，现在很多的开源项目使用的是编译时注解，关于编译时注解后面再来详细介绍。