# [java中的反射原理，为什么要使用反射以及反射使用场景（面试常问）](https://blog.csdn.net/j169ybz/article/details/118755447)

什么是反射

```
反射是框架的灵魂
```

**JAVA反射机制是在==运行==状态中，对于任意一个类，都能够知道这个类的所有属性和方法；对于任意一个对象，都能够调用它的任意一个方法和属性；这种动态获取的信息以及动态调用对象的方法的功能称为java语言的反射机制。**

要想解剖一个类,必须先要获取到该类的**字节码文件对象**。而解剖使用的就是Class类中的方法.所以先要获取到每一个字节码文件对应的**Class类型的对象.**

在java中获取字节文件的方式有三种

1. 任何数据类型（包括基本数据类型）都有一个“静态”的class属性
2. Object(对象) ——> getClass();
3. 通过Class类的静态方法：forName（String className）(常用)
   

```java
 		//方法一
        Class<CarEntity> carEntityClass0 = CarEntity.class;

        //方法二
        CarEntity carEntity =new CarEntity();
        Class carEntityClass1 =carEntity.getClass();

        //方法三
        Class carEntityClass2 = Class.forName("com.example.demo3.Entity.CarEntity");

        //判断获取到同一个类的Class对象是否是同一个
        System.out.println(carEntityClass0 == carEntityClass1);
        System.out.println(carEntityClass1 == carEntityClass2);
        System.out.println(carEntityClass0 == carEntityClass2);
```

上面的例子得到的结果，是三个true，由此我们得到了第一个定理：
**在运行期间，一个类，只有一个Class对象产生**


三种方式常用第三种，第一种需要导入类的包，依赖太强，不导包就抛编译错误。第二种对象都有了还要反射干什么。一般都第三种，一个字符串可以传入也可写在配置文件中等多种方法（**框架中都是用的第三种**）。


 

好，现在我们得到了Class对象了，又有什么用呢，Class对象是什么呢，能做什么呢？

在此之前我们先了解一下正常情况下我们new一个对象的时候，jvm底层做了什么事情。

首先要搞明白一件事情，jvm能读懂我们的java代码吗？不能！
那jvm是靠读取什么东西来运行程序的呢？.class文件！
请放大看下图。。。。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210717213307698.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0oxNjlZQlo=,size_16,color_FFFFFF,t_70#pic_center)

也就是说，我们现在可以不通过JVM的编译直接获取到jvm运行时需要的Class对象！
**也就是说！我们是不是可以通过对Class对象进行修改而改变CarEntity这个类原本在jvm里运行的逻辑！从而达到一系列不可告人的目的呢?**

没错，我们可以，这就像同桌张三把作业给我让我帮忙交给老师，然后我直接把他的作业全部撕了然后告诉老师（JVM）：张三这个崽种没做作业！（这是后面要讲的代理模式）。在当前的反射篇章我们可以理解为，我可以得到张三的作业的所有答案，然后我拿着自己用！

好，例子来了，顺便我们熟悉一下Class对象的常用API，面试的时候就可以装逼了

先看看我们的实体类是什么样子的

```java
//一个public 属性
public String name;

//一个private 属性
private String price;

//一个public 构造方法
public CarEntity(String name, String price) {
    this.name = name;
    this.price = price;
}

//一个private 构造方法
private CarEntity(String name){
    this.name = name;
}
```


```java
//以下全都是public 的GET，SET方法
public String getName() {
    return name;
}

public void setName(String name) {
    this.name = name;
}

public String getPrice() {
    return price;
}

public void setPrice(String price) {
    this.price = price;
}
```
好！开始测试！

```java
public static void main(String[] args) throws Exception {
    //获取CarEntity的Class对象
    Class carEntityClass = Class.forName("com.example.demo3.Entity.CarEntity");

    System.out.println("获取所有的Public的成员变量");
    Field[] field = carEntityClass.getFields();
    for (Field field1 : field) {
        System.out.println(field1.getName());
    }
    System.out.println("获取所有的的成员变量，不管你是Public,Private,Protected还是Default ");
    Field[] field01 = carEntityClass.getDeclaredFields();
    for (Field field1 : field01) {
        System.out.println(field1.getName());
    }
}
```
看看结果是什么

```
获取所有的Public的成员变量
name
获取所有的的成员变量，不管你是Public,Private,Protected还是Default 
name
price
```

好，再来一个

```java
    System.out.println("获取所有的Public的构造方法");
    Constructor[] constructors = carEntityClass.getConstructors();
    for (Constructor constructor1 : constructors) {
        System.out.println(constructor1);
    }
    System.out.println("获取所有的的构造方法，不管你是Public,Private,Protected还是Default ");
    Constructor[] constructors01 = carEntityClass.getDeclaredConstructors();
    for (Constructor constructor1 : constructors01) {
        System.out.println(constructor1);
    }
```
结果：

```java
获取所有的Public的构造方法
public com.example.demo3.Entity.CarEntity(java.lang.String,java.lang.String)
获取所有的的构造方法，不管你是Public,Private,Protected还是Default 
public com.example.demo3.Entity.CarEntity(java.lang.String,java.lang.String)
private com.example.demo3.Entity.CarEntity(java.lang.String)

```

发现了没？我们现在只需要一个类的全路径，我们就可以掌握这个类的所有情况！

上面的例子我们也发现了Class对象的APi的规律，只要加了Declared的Get方法，我们就能够“非法”地获取到这个类的编写者本来不愿意公布出来的属性！

当然我们还可以获取到这个类的所有普通方法：

```java
    System.out.println("获取所有的方法");
    Method[] methods = carEntityClass.getMethods();
    for (Method method : methods) {
        System.out.println(method.getName());
    }
```
```
获取所有的方法
getName
setName
getPrice
setPrice
wait
wait
wait
equals
toString
hashCode
getClass
notify
notifyAll

```

我们再继续深入一点点，大家耐心看。

我们先给我们的Car类补上刚刚忘掉的无参构造方法


```java
public CarEntity() {

}
```
然后开始我们的测试**（是干嘛呢？通过反射调用目标类的方法！）**

```java
 //获取CarEntity的Class对象
        Class<?> carEntityClass = Class.forName("com.example.demo3.Entity.CarEntity");
        //通过Class对象获取到具体的CarEntity实例（需要无参构造方法！！！！）
        CarEntity carEntity = (CarEntity)carEntityClass.newInstance();

        System.out.println("获取SetName方法");
        //第一个参数：方法名称，第二个参数：方法形参的类型
        Method method = carEntityClass.getDeclaredMethod("setName",String.class);
        //第一个参数，对象类型carEntity，第二个参数是我这里调用方法时传的参数
        method.invoke(carEntity,"张三");


        System.out.println("获取getName方法");
        Method method2 = carEntityClass.getDeclaredMethod("getName",null);
        String name = (String) method2.invoke(carEntity,null);
        System.out.println(name);

```

```
获取SetName方法
获取getName方法
张三
```

我们现在居然只通过一个类的路径，获取到了这个类的所有信息，并且还能调用他的所有方法。

现在是不是大概明白了，为什么一开始说反射是框架的灵魂。举个最简单的例子，Spring的注解式事务是怎么实现的？？ 现在我们大概可以猜猜了（只是猜想）：

1.通过注解，我们在项目启动的时候可以获取所有打了注解的类或方法
2.通过反射，我们可以获取类的所有信息或方法的所有信息
3.通过反射，我们可以在方法的前后加上事务回滚相关的代码，然后通过上面例子中的invoke方法调用目标方法
4.这个过程我不需要知道你这些类或方法是干嘛的，你的一切与我无关

框架就是这样诞生的，更多的细节请看我的其他博客，关于静态代理和动态代理。
------------------------------------------------


# [Java基础篇：反射机制详解](https://blog.csdn.net/a745233700/article/details/82893076)

## 一、什么是反射：

（1）Java反射机制的核心是在程序运行时动态加载类并获取类的详细信息，从而操作类或对象的属性和方法。本质是JVM得到class对象之后，再通过class对象进行反编译，从而获取对象的各种信息。

（2）Java属于先编译再运行的语言，程序中对象的类型在编译期就确定下来了，而当程序在运行时可能需要动态加载某些类，这些类因为之前用不到，所以没有被加载到JVM。通过反射，可以在运行时动态地创建对象并调用其属性，不需要提前在编译期知道运行的对象是谁。

## 二、反射的原理：

下图是类的正常加载过程、反射原理与class对象：

Class对象的由来是将.class文件读入内存，并为之创建一个Class对象。



对于类加载机制与双亲委派模型感兴趣的小伙伴可以阅读这篇文章：https://blog.csdn.net/a745233700/article/details/90232862

## 三、反射的优缺点：

1、优点：在运行时获得类的各种内容，进行反编译，对于Java这种先编译再运行的语言，能够让我们很方便的创建灵活的代码，这些代码可以在运行时装配，无需在组件之间进行源代码的链接，更加容易实现面向对象。

2、缺点：（1）反射会消耗一定的系统资源，因此，如果不需要动态地创建一个对象，那么就不需要用反射；

（2）反射调用方法时可以忽略权限检查，因此可能会破坏封装性而导致安全问题。

## 四、反射的用途：

1、反编译：.class-->.java

2、通过反射机制访问java对象的属性，方法，构造方法等

3、当我们在使用IDE,比如Ecplise时，当我们输入一个对象或者类，并想调用他的属性和方法是，一按点号，编译器就会自动列出他的属性或者方法，这里就是用到反射。

4、反射最重要的用途就是开发各种通用框架。比如很多框架（Spring）都是配置化的（比如通过XML文件配置Bean），为了保证框架的通用性，他们可能需要根据配置文件加载不同的类或者对象，调用不同的方法，这个时候就必须使用到反射了，运行时动态加载需要的加载的对象。

5、例如，在使用Strut2框架的开发过程中，我们一般会在struts.xml里去配置Action，比如

```xml
<action name="login" class="org.ScZyhSoft.test.action.SimpleLoginAction" method="execute">   
    <result>/shop/shop-index.jsp</result>           
    <result name="error">login.jsp</result>       
</action>
```

比如我们请求login.action时，那么StrutsPrepareAndExecuteFilter就会去解析struts.xml文件，从action中查找出name为login的Action，并根据class属性创建SimpleLoginAction实例，并用Invoke方法来调用execute方法，这个过程离不开反射。配置文件与Action建立了一种映射关系，当View层发出请求时，请求会被StrutsPrepareAndExecuteFilter拦截，然后StrutsPrepareAndExecuteFilter会去动态地创建Action实例。

比如，加载数据库驱动的，用到的也是反射。

Class.forName("com.mysql.jdbc.Driver"); // 动态加载mysql驱动

## 五、反射机制常用的类：

Java.lang.Class;

Java.lang.reflect.Constructor;

Java.lang.reflect.Field;

Java.lang.reflect.Method;

Java.lang.reflect.Modifier;

## 六、反射的基本使用：

### 1、获得Class：主要有三种方法：

（1）Object-->getClass

（2）任何数据类型（包括基本的数据类型）都有一个“静态”的class属性

（3）通过class类的静态方法：forName(String className)（最常用）

```java
package fanshe;
 
public class Fanshe {
	public static void main(String[] args) {
		//第一种方式获取Class对象  
		Student stu1 = new Student();//这一new 产生一个Student对象，一个Class对象。
		Class stuClass = stu1.getClass();//获取Class对象
		System.out.println(stuClass.getName());
		
		//第二种方式获取Class对象
		Class stuClass2 = Student.class;
		System.out.println(stuClass == stuClass2);//判断第一种方式获取的Class对象和第二种方式获取的是否是同一个
		
		//第三种方式获取Class对象
		try {
			Class stuClass3 = Class.forName("fanshe.Student");//注意此字符串必须是真实路径，就是带包名的类路径，包名.类名
			System.out.println(stuClass3 == stuClass2);//判断三种方式是否获取的是同一个Class对象
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		
	}
}
```

注意，在运行期间，一个类，只有一个Class对象产生，所以打印结果都是true；

三种方式中，常用第三种，第一种对象都有了还要反射干什么，第二种需要导入类包，依赖太强，不导包就抛编译错误。一般都使用第三种，一个字符串可以传入也可以写在配置文件中等多种方法。

### 2、判断是否为某个类的示例：

一般的，我们使用instanceof 关键字来判断是否为某个类的实例。同时我们也可以借助反射中Class对象的isInstance()方法来判断时候为某个类的实例，他是一个native方法。

```java
public native boolean isInstance(Object obj);
```

### 3、创建实例：通过反射来生成对象主要有两种方法：

（1）使用Class对象的newInstance()方法来创建Class对象对应类的实例。

```java
Class<?> c = String.class;
Object str = c.newInstance();
```

（2）先通过Class对象获取指定的Constructor对象，再调用Constructor对象的newInstance()方法来创建对象，这种方法可以用指定的构造器构造类的实例。

```java
//获取String的Class对象
Class<?> str = String.class;
//通过Class对象获取指定的Constructor构造器对象
Constructor constructor=c.getConstructor(String.class);
//根据构造器创建实例：
Object obj = constructor.newInstance(“hello reflection”);
```

### 4、通过反射获取构造方法并使用：

（1）批量获取的方法：
public Constructor[] getConstructors()：所有"公有的"构造方法
public Constructor[] getDeclaredConstructors()：获取所有的构造方法(包括私有、受保护、默认、公有)

（2）单个获取的方法，并调用：
public Constructor getConstructor(Class... parameterTypes):获取单个的"公有的"构造方法：
public Constructor getDeclaredConstructor(Class... parameterTypes):获取"某个构造方法"可以是私有的，或受保护、默认、公有；

（3） 调用构造方法：

Constructor-->newInstance(Object... initargs)

newInstance是 Constructor类的方法（管理构造函数的类）

api的解释为：newInstance(Object... initargs) ，使用此 Constructor 对象表示的构造方法来创建该构造方法的声明类的新实例，并用指定的初始化参数初始化该实例。

它的返回值是T类型，所以newInstance是创建了一个构造方法的声明类的新实例对象，并为之调用。

例子：

Student类：共六个构造方法。

```java
package fanshe;
public class Student {
	//---------------构造方法-------------------
	//（默认的构造方法）
	Student(String str){
		System.out.println("(默认)的构造方法 s = " + str);
	}
	//无参构造方法
	public Student(){
		System.out.println("调用了公有、无参构造方法执行了。。。");
	}
	//有一个参数的构造方法
	public Student(char name){
		System.out.println("姓名：" + name);
	}
	//有多个参数的构造方法
	public Student(String name ,int age){
		System.out.println("姓名："+name+"年龄："+ age);//这的执行效率有问题，以后解决。
	}
	//受保护的构造方法
	protected Student(boolean n){
		System.out.println("受保护的构造方法 n = " + n);
	}
	//私有构造方法
	private Student(int age){
		System.out.println("私有的构造方法   年龄："+ age);
	}
}
```

测试类：

```java
package fanshe;
import java.lang.reflect.Constructor;
 
/*
 * 通过Class对象可以获取某个类中的：构造方法、成员变量、成员方法；并访问成员；
 * 
 * 1.获取构造方法：
 * 		1).批量的方法：
 * 			public Constructor[] getConstructors()：所有"公有的"构造方法
            public Constructor[] getDeclaredConstructors()：获取所有的构造方法(包括私有、受保护、默认、公有)
 * 		2).获取单个的方法，并调用：
 * 			public Constructor getConstructor(Class... parameterTypes):获取单个的"公有的"构造方法：
 * 			public Constructor getDeclaredConstructor(Class... parameterTypes):获取"某个构造方法"可以是私有的，或受保护、默认、公有； 		
 * 		3).调用构造方法：
 * 			Constructor-->newInstance(Object... initargs)
 */
public class Constructors {
 
	public static void main(String[] args) throws Exception {
		//1.加载Class对象
		Class clazz = Class.forName("fanshe.Student");
		
		//2.获取所有公有构造方法
		System.out.println("**********************所有公有构造方法*********************************");
		Constructor[] conArray = clazz.getConstructors();
		for(Constructor c : conArray){
			System.out.println(c);
		}
		
		System.out.println("************所有的构造方法(包括：私有、受保护、默认、公有)***************");
		conArray = clazz.getDeclaredConstructors();
		for(Constructor c : conArray){
			System.out.println(c);
		}
		
		System.out.println("*****************获取公有、无参的构造方法*******************************");
		Constructor con = clazz.getConstructor(null);
		//1>、因为是无参的构造方法所以类型是一个null,不写也可以：这里需要的是一个参数的类型，切记是类型
		//2>、返回的是描述这个无参构造函数的类对象。
		System.out.println("con = " + con);
 
		//调用构造方法
		Object obj = con.newInstance();
	//	System.out.println("obj = " + obj);
	//	Student stu = (Student)obj;
		
		System.out.println("******************获取私有构造方法，并调用*******************************");
		con = clazz.getDeclaredConstructor(char.class);
		System.out.println(con);
		//调用构造方法
		con.setAccessible(true);//暴力访问(忽略掉访问修饰符)
		obj = con.newInstance('男');
	}
}
```

控制台输出：

```java
**********************所有公有构造方法*********************************
public fanshe.Student(java.lang.String,int)
public fanshe.Student(char)
public fanshe.Student()
************所有的构造方法(包括：私有、受保护、默认、公有)***************
private fanshe.Student(int)
protected fanshe.Student(boolean)
public fanshe.Student(java.lang.String,int)
public fanshe.Student(char)
public fanshe.Student()
fanshe.Student(java.lang.String)
*****************获取公有、无参的构造方法*******************************
con = public fanshe.Student()
调用了公有、无参构造方法执行了。。。
******************获取私有构造方法，并调用*******************************
public fanshe.Student(char)
姓名：男
```

### 5、获取成员变量并调用：

Student类：

```java
package fanshe.field;
 
public class Student {
	public Student(){
		
	}
	//**********字段*************//
	public String name;
	protected int age;
	char sex;
	private String phoneNum;
	
	@Override
	public String toString() {
		return "Student [name=" + name + ", age=" + age + ", sex=" + sex
				+ ", phoneNum=" + phoneNum + "]";
	}
}
```

测试类：

```java
package fanshe.field;
import java.lang.reflect.Field;
/*
 * 获取成员变量并调用：
 * 
 * 1.批量的
 * 		1).Field[] getFields():获取所有的"公有字段"
 * 		2).Field[] getDeclaredFields():获取所有字段，包括：私有、受保护、默认、公有；
 * 2.获取单个的：
 * 		1).public Field getField(String fieldName):获取某个"公有的"字段；
 * 		2).public Field getDeclaredField(String fieldName):获取某个字段(可以是私有的)
 * 
 * 	 设置字段的值：
 * 		Field --> public void set(Object obj,Object value):
 * 					参数说明：
 * 					1.obj:要设置的字段所在的对象；
 * 					2.value:要为字段设置的值；
 */
public class Fields {
 
		public static void main(String[] args) throws Exception {
			//1.获取Class对象
			Class stuClass = Class.forName("fanshe.field.Student");
			//2.获取字段
			System.out.println("************获取所有公有的字段********************");
			Field[] fieldArray = stuClass.getFields();
			for(Field f : fieldArray){
				System.out.println(f);
			}
			System.out.println("************获取所有的字段(包括私有、受保护、默认的)********************");
			fieldArray = stuClass.getDeclaredFields();
			for(Field f : fieldArray){
				System.out.println(f);
			}
			System.out.println("*************获取公有字段**并调用***********************************");
			Field f = stuClass.getField("name");
			System.out.println(f);
			//获取一个对象
			Object obj = stuClass.getConstructor().newInstance();//产生Student对象--》Student stu = new Student();
			//为字段设置值
			f.set(obj, "刘德华");//为Student对象中的name属性赋值--》stu.name = "刘德华"
			//验证
			Student stu = (Student)obj;
			System.out.println("验证姓名：" + stu.name);
			
			
			System.out.println("**************获取私有字段****并调用********************************");
			f = stuClass.getDeclaredField("phoneNum");
			System.out.println(f);
			f.setAccessible(true);//暴力反射，解除私有限定
			f.set(obj, "18888889999");
			System.out.println("验证电话：" + stu);
			
		}
	}
```

控制台输出：

```java
************获取所有公有的字段********************
public java.lang.String fanshe.field.Student.name
************获取所有的字段(包括私有、受保护、默认的)********************
public java.lang.String fanshe.field.Student.name
protected int fanshe.field.Student.age
char fanshe.field.Student.sex
private java.lang.String fanshe.field.Student.phoneNum
*************获取公有字段**并调用***********************************
public java.lang.String fanshe.field.Student.name
验证姓名：刘德华
**************获取私有字段****并调用********************************
private java.lang.String fanshe.field.Student.phoneNum
验证电话：Student [name=刘德华, age=0, sex=
```

### 6、获取成员方法并调用：

Student类：

```java
package fanshe.method;
 
public class Student {
	//**************成员方法***************//
	public void show1(String s){
		System.out.println("调用了：公有的，String参数的show1(): s = " + s);
	}
	protected void show2(){
		System.out.println("调用了：受保护的，无参的show2()");
	}
	void show3(){
		System.out.println("调用了：默认的，无参的show3()");
	}
	private String show4(int age){
		System.out.println("调用了，私有的，并且有返回值的，int参数的show4(): age = " + age);
		return "abcd";
	}
}
```

测试类：

```java
package fanshe.method;
import java.lang.reflect.Method;
 
/*
 * 获取成员方法并调用：
 * 
 * 1.批量的：
 * 		public Method[] getMethods():获取所有"公有方法"；（包含了父类的方法也包含Object类）
 * 		public Method[] getDeclaredMethods():获取所有的成员方法，包括私有的(不包括继承的)
 * 2.获取单个的：
 * 		public Method getMethod(String name,Class<?>... parameterTypes):
 * 					参数：
 * 						name : 方法名；
 * 						Class ... : 形参的Class类型对象
 * 		public Method getDeclaredMethod(String name,Class<?>... parameterTypes)
 * 
 * 	 调用方法：
 * 		Method --> public Object invoke(Object obj,Object... args):
 * 					参数说明：
 * 					obj : 要调用方法的对象；
 * 					args:调用方式时所传递的实参；
):
 */
public class MethodClass {
 
	public static void main(String[] args) throws Exception {
		//1.获取Class对象
		Class stuClass = Class.forName("fanshe.method.Student");
		//2.获取所有公有方法
		System.out.println("***************获取所有的”公有“方法*******************");
		stuClass.getMethods();
		Method[] methodArray = stuClass.getMethods();
		for(Method m : methodArray){
			System.out.println(m);
		}
		System.out.println("***************获取所有的方法，包括私有的*******************");
		methodArray = stuClass.getDeclaredMethods();
		for(Method m : methodArray){
			System.out.println(m);
		}
		System.out.println("***************获取公有的show1()方法*******************");
		Method m = stuClass.getMethod("show1", String.class);
		System.out.println(m);
		//实例化一个Student对象
		Object obj = stuClass.getConstructor().newInstance();
		m.invoke(obj, "刘德华");
		
		System.out.println("***************获取私有的show4()方法******************");
		m = stuClass.getDeclaredMethod("show4", int.class);
		System.out.println(m);
		m.setAccessible(true);//解除私有限定
		Object result = m.invoke(obj, 20);//需要两个参数，一个是要调用的对象（获取有反射），一个是实参
		System.out.println("返回值：" + result);	
	}
}
```

控制台输出：

```java
***************获取所有的”公有“方法*******************
public void fanshe.method.Student.show1(java.lang.String)
public final void java.lang.Object.wait(long,int) throws java.lang.InterruptedException
public final native void java.lang.Object.wait(long) throws java.lang.InterruptedException
public final void java.lang.Object.wait() throws java.lang.InterruptedException
public boolean java.lang.Object.equals(java.lang.Object)
public java.lang.String java.lang.Object.toString()
public native int java.lang.Object.hashCode()
public final native java.lang.Class java.lang.Object.getClass()
public final native void java.lang.Object.notify()
public final native void java.lang.Object.notifyAll()
***************获取所有的方法，包括私有的*******************
public void fanshe.method.Student.show1(java.lang.String)
private java.lang.String fanshe.method.Student.show4(int)
protected void fanshe.method.Student.show2()
void fanshe.method.Student.show3()
***************获取公有的show1()方法*******************
public void fanshe.method.Student.show1(java.lang.String)
调用了：公有的，String参数的show1(): s = 刘德华
***************获取私有的show4()方法******************
private java.lang.String fanshe.method.Student.show4(int)
调用了，私有的，并且有返回值的，int参数的show4(): age = 20
返回值：abcd
```

### 7、反射main方法：

Student类：

```java
package fanshe.main;
 
public class Student {
	public static void main(String[] args) {
		System.out.println("main方法执行了。。。");
	}
}
```

测试类：

```java
package fanshe.main;
import java.lang.reflect.Method;
 
/**
 * 获取Student类的main方法、不要与当前的main方法搞混了
 */
public class Main {
	
	public static void main(String[] args) {
		try {
			//1、获取Student对象的字节码
			Class clazz = Class.forName("fanshe.main.Student");
			
			//2、获取main方法
			 Method methodMain = clazz.getMethod("main", String[].class);//第一个参数：方法名称，第二个参数：方法形参的类型，
			//3、调用main方法
			// methodMain.invoke(null, new String[]{"a","b","c"});
			 //第一个参数，对象类型，因为方法是static静态的，所以为null可以，第二个参数是String数组，这里要注意在jdk1.4时是数组，jdk1.5之后是可变参数
			 //这里拆的时候将  new String[]{"a","b","c"} 拆成3个对象。。。所以需要将它强转。
			 methodMain.invoke(null, (Object)new String[]{"a","b","c"});//方式一
			// methodMain.invoke(null, new Object[]{new String[]{"a","b","c"}});//方式二			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
```

控制台输出：

```
main方法执行了。。。
```

### 8、利用反射创建数值：

数组在Java里是比较特殊的一种类型，它可以赋值给一个Object Reference。

```java
public static void testArray() throws ClassNotFoundException {
        Class<?> cls = Class.forName("java.lang.String");
        Object array = Array.newInstance(cls,25);
        //往数组里添加内容
        Array.set(array,0,"golang");
        Array.set(array,1,"Java");
        Array.set(array,2,"pytho");
        Array.set(array,3,"Scala");
        Array.set(array,4,"Clojure");
        //获取某一项的内容
        System.out.println(Array.get(array,3));
    }
```

### 9、反射方法的其他使用--通过反射运行配置文件内容：

Student类：

```java
public class Student {
	public void show(){
		System.out.println("is show()");
	}
}
```

配置文件以txt文件为例子：

```java
className = cn.fanshe.Student
methodName = show
```

测试类：

```java
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.Properties;
 
/*
 * 我们利用反射和配置文件，可以使：应用程序更新时，对源码无需进行任何修改
 * 我们只需要将新类发送给客户端，并修改配置文件即可
 */
public class Demo {
	public static void main(String[] args) throws Exception {
		//通过反射获取Class对象
		Class stuClass = Class.forName(getValue("className"));//"cn.fanshe.Student"
		//2获取show()方法
		Method m = stuClass.getMethod(getValue("methodName"));//show
		//3.调用show()方法
		m.invoke(stuClass.getConstructor().newInstance());
		
	}
	
	//此方法接收一个key，在配置文件中获取相应的value
	public static String getValue(String key) throws IOException{
		Properties pro = new Properties();//获取配置文件的对象
		FileReader in = new FileReader("pro.txt");//获取输入流
		pro.load(in);//将流加载到配置文件对象中
		in.close();
		return pro.getProperty(key);//返回根据key获取的value值
	}
}
```

控制台输出：

```csharp
is show()
```

需求：

当我们升级这个系统时，不要Student类，而需要新写一个Student2的类时，这时只需要更改pro.txt的文件内容就可以了。代码就一点不用改动。

```java
public class Student2 {
	public void show2(){
		System.out.println("is show2()");
	}
}
```

配置文件更改为：

```yaml
className = cn.fanshe.Student2
methodName = show2
```



### **10、**反射方法的其他使用--通过反射越过泛型检查：

泛型用在编译期，编译过后泛型擦除（消失掉），所以是可以通过反射越过泛型检查的

测试类：

```java
import java.lang.reflect.Method;
import java.util.ArrayList;
 
/*
 * 通过反射越过泛型检查
 * 例如：有一个String泛型的集合，怎样能向这个集合中添加一个Integer类型的值？
 */
public class Demo {
	public static void main(String[] args) throws Exception{
		ArrayList<String> strList = new ArrayList<>();
		strList.add("aaa");
		strList.add("bbb");
		
	//	strList.add(100);
		//获取ArrayList的Class对象，反向的调用add()方法，添加数据
		Class listClass = strList.getClass(); //得到 strList 对象的字节码 对象
		//获取add()方法
		Method m = listClass.getMethod("add", Object.class);
		//调用add()方法
		m.invoke(strList, 100);
		
		//遍历集合
		for(Object obj : strList){
			System.out.println(obj);
		}
	}
}
```

控制台输出：

```
aaa
bbb
100
```

推荐阅读：

Java 反射：https://juejin.cn/post/6917050648563777544
Java 注解：https://juejin.cn/post/6909692344291819533
参考博客：https://www.sczyh30.com/posts/Java/java-reflection-1/



----



# 反射

##  java反射之Method的invoke方法实现

[method.invoke](https://blog.csdn.net/wenyuan65/article/details/81145900)

在框架中经常会会用到method.invoke()方法，用来执行某个的对象的目标方法。以前写代码用到反射时，总是获取先获取Method，然后传入对应的Class实例对象执行方法。然而前段时间研究invoke方法时，发现invoke方法居然包含多态的特性，这是以前没有考虑过的一个问题。那么Method.invoke()方法的执行过程是怎么实现的？它的多态又是如何实现的呢？

本文将从java和JVM的源码实现深入探讨invoke方法的实现过程。

首先给出invoke方法多态特性的演示代码：



```javascript
public class MethodInvoke {
public static void main(String[] args) throws Exception {
	Method animalMethod = Animal.class.getDeclaredMethod("print");
	Method catMethod = Cat.class.getDeclaredMethod("print");
	
	Animal animal = new Animal();
	Cat cat = new Cat();
	
	animalMethod.invoke(cat);	//相当于Animal a = New Cat(); a.print();父类指针指向子类实例，执行的是子类的方法
	animalMethod.invoke(animal);           
	
	catMethod.invoke(cat);
	catMethod.invoke(animal);	//相当于Cat obj =New Animal();会报指针无法指向实例对象。
}
}
```

```java
class Animal {
public void print() {
	System.out.println("Animal.print()");
}
}
```

```java
class Cat extends Animal {
@Override
public void print() {
	System.out.println("Cat.print()");
}
}
```

代码中，Cat类覆盖了父类Animal的print()方法， 然后通过反射分别获取print()的Method对象。最后分别用Cat和Animal的实例对象去执行print()方法。其中animalMethod.invoke(animal)和catMethod.invoke(cat)，示例对象的真实类型和Method的声明Classs是相同的，按照预期打印结果；**animalMethod.invoke(cat)中，由于Cat是Animal的子类，按照多态的特性，子类调用父类的的方法，方法执行时会动态链接到子类的实现方法上。**因此，这里会调用Cat.print()方法；**而catMethod.invoke(animal)中，传入的参数类型Animal是父类，却期望调用子类Cat的方法，因此这一次会抛出异常。**代码打印结果为：

```
Cat.print()`
`Animal.print()`
`Cat.print()`
`Exception in thread "main" java.lang.IllegalArgumentException: object is not an instance of declaring class`
	`at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)`
	`at sun.reflect.NativeMethodAccessorImpl.invoke(Unknown Source)`
	`at sun.reflect.DelegatingMethodAccessorImpl.invoke(Unknown Source)`
	`at java.lang.reflect.Method.invoke(Unknown Source)`
	at com.wy.invoke.MethodInvoke.main(MethodInvoke.java:17)
```


接下来，我们来看看invoke()方法的实现过程。

------------------------------------------------