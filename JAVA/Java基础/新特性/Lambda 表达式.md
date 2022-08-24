# [Java Lambda 表达式](https://www.runoob.com/java/java8-lambda-expressions.html)

Lambda 表达式，也可称为闭包，它是推动 Java 8 发布的最重要新特性。

Lambda 允许把函数作为一个方法的参数（函数作为参数传递进方法中）。

使用 Lambda 表达式可以使代码变的更加简洁紧凑。

### 语法

lambda 表达式的语法格式如下：

```
(parameters) -> expression 
或 (parameters) ->{ statements; }
```

以下是lambda表达式的重要特征:

- ==**可选类型声明：**不需要声明参数类型，编译器可以统一识别参数值。==
- ==**可选的参数圆括号：**一个参数无需定义圆括号，但多个参数需要定义圆括号。==
- ==**可选的大括号：**如果主体包含了一个语句，就不需要使用大括号。==
- ==**可选的返回关键字：**如果主体只有一个表达式返回值则编译器会自动返回值，大括号需要指定表达式返回了一个数值。==

------

## Lambda 表达式实例

Lambda 表达式的简单例子:

```
// 1. 不需要参数,返回值为 5  
() -> 5  
  
// 2. 接收一个参数(数字类型),返回其2倍的值  
x -> 2 * x  
  
// 3. 接受2个参数(数字),并返回他们的差值  
(x, y) -> x – y  
  
// 4. 接收2个int型整数,返回他们的和  
(int x, int y) -> x + y  
  
// 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)  
(String s) -> System.out.print(s)
```

在 Java8Tester.java 文件输入以下代码：

## Java8Tester.java 文件

```java
public class Java8Tester {
   public static void main(String args[]){
      Java8Tester tester = new Java8Tester();
        
      // 类型声明
      MathOperation addition = (int a, int b) -> a + b;
        
      // 不用类型声明
      MathOperation subtraction = (a, b) -> a - b;
        
      // 大括号中的返回语句
      MathOperation multiplication = (int a, int b) -> { return a * b; };
        
      // 没有大括号及返回语句
      MathOperation division = (int a, int b) -> a / b;
        
      System.out.println("10 + 5 = " + tester.operate(10, 5, addition));
      System.out.println("10 - 5 = " + tester.operate(10, 5, subtraction));
      System.out.println("10 x 5 = " + tester.operate(10, 5, multiplication));
      System.out.println("10 / 5 = " + tester.operate(10, 5, division));
        
      // 不用括号
      GreetingService greetService1 = message ->
      System.out.println("Hello " + message);
        
      // 用括号
      GreetingService greetService2 = (message) ->
      System.out.println("Hello " + message);
        
      greetService1.sayMessage("Runoob");
      greetService2.sayMessage("Google");
   }
    
   interface MathOperation {
      int operation(int a, int b);
   }
    
   interface GreetingService {
      void sayMessage(String message);
   }
    
   private int operate(int a, int b, MathOperation mathOperation){
      return mathOperation.operation(a, b);
   }
}
```

执行以上脚本，输出结果为：

```
$ javac Java8Tester.java 
$ java Java8Tester
10 + 5 = 15
10 - 5 = 5
10 x 5 = 50
10 / 5 = 2
Hello Runoob
Hello Google
```

使用 Lambda 表达式需要注意以下两点：

- Lambda 表达式主要用来定义行内执行的方法类型接口，例如，一个简单方法接口。在上面例子中，我们使用各种类型的Lambda表达式来定义MathOperation接口的方法。然后我们定义了sayMessage的执行。
- Lambda 表达式免去了使用匿名方法的麻烦，并且给予Java简单但是强大的函数化的编程能力。

------

## 变量作用域

**lambda 表达式只能引用标记了 final 的外层局部变量**，这就是说**==不能在 lambda 内部修改定义在域外的局部变量，否则会编译错误。==**

在 Java8Tester.java 文件输入以下代码：

Java8Tester.java 文件

```java
public class Java8Tester {
 
   final static String salutation = "Hello! ";
   
   public static void main(String args[]){
      GreetingService greetService1 = message -> 
      System.out.println(salutation + message);
      greetService1.sayMessage("Runoob");
   }
    
   interface GreetingService {
      void sayMessage(String message);
   }
}
```

执行以上脚本，输出结果为：

```
$ javac Java8Tester.java 
$ java Java8Tester
Hello! Runoob
```

我们也可以直接在 lambda 表达式中访问外层的局部变量：

Java8Tester.java 文件

```java
public class Java8Tester {
    public static void main(String args[]) {
        final int num = 1;
        Converter<Integer, String> s = (param) -> System.out.println(String.valueOf(param + num));
        s.convert(2);  // 输出结果为 3
    }
 
    public interface Converter<T1, T2> {
        void convert(int i);
    }
}
```

**==lambda 表达式使用的局部变量可以不用声明为 final，但是必须不可被后面的代码修改（即隐性的具有 final 的语义）==**

```java
int num = 1;  
Converter<Integer, String> s = (param) -> System.out.println(String.valueOf(param + num));
s.convert(2);
num = 5;  
//报错信息：Local variable num defined in an enclosing scope must be final or effectively 
 final
```

**==在 Lambda 表达式当中不允许声明一个与局部变量同名的参数或者局部变量。==**

```java
String first = "";  
Comparator<String> comparator = (first, second) -> Integer.compare(first.length(), second.length());  //编译会出错 
```



-----

# [Java8 Interface Lambda](https://blog.csdn.net/u012410733/article/details/53795960)

Java是一门面向对象编程语言。面向对象编程语言和函数式编程语言中的基本元素（Basic Values）都可以动态封装程序行为：面向对象编程语言使用带有方法的对象封装行为，函数式编程语言使用函数封装行为。但这个相同点并不明显，因为Java的对象往往比较“重量级”：实例化一个类型往往会涉及不同的类，并需要初始化类里的字段和方法。

在Java8中接口也很多变化：

## 1、接口变量的访问

1) 局部变量：

从Java8开始，如果在内部类里面访问局部变量，会自动给局部变量加上final修饰
Java8之前，内部类只能访问final的局部变量
2) 类变量：
内部类可以直接访问外部类变量，相当于是当前类访问一样。
3) 实例变量：

如果在静态的方法里面写上匿名内部类，访问实例变量，必须通过外部类的实例来进行访问
如果外部类的实例是一个局部变量，该实例对应的变量不能多次赋值。但实例变量本身不会有影响

## 2、函数式接口 – Lambda的使用

函数式接口：当接口只有一个抽象方法的时候(可以有其它默认方法),就是函数式接口，可以使用注解(@FunctionalInterface)强制限定接口只能有一个抽象方法。

lambda语法:

```
([形参列表,不带数据类型]) -> {
    // 执行语句
    [return ...;]
}
```

其中:

```
() : 表示参数列表,不需要指定参数类型,会自动推断
-> : 连接符
{} : 表示方法体
```

注意点:

1.如果形参列表是空的，只需要保留()即可。
2.如果没有返回值，只需要在{}写执行语句即可。
3.如果接口的抽象方法只有一个形参，()可以省略，只需要参数的名称即可
4.如果执行语句只有一行，可以省略{}，但是如果有返回值的时候，不能省略
5.形参列表的数据类型自动推断，只要参数名称
6.如果函数式接口的方法有返回值，必须要给定返回值，如果执行语句只有一行代码，可以省略大特号，但必须同时省略return关键字
lambda表达式就是函数式接口，也可以认为是一种特殊的匿名内部类。下面就看看匿名内部类的lamdba表达式的写法:

### 1）方法无参数，无返回值

```java
public class LambdaDemo {

    public static void main(String[] args) {
        // 1. 匿名内部类的方式实现,在Java8之前,没有Lambda表达式
        UserService userService = new UserService() {
            @Override
            public void test() {
                System.out.println("不使用lambda表达式");
            }
        };
        userService.test();

        // lambda 右边的类型，会自动根据左边的变量的类型进行推断
        UserService userService1 = () -> {
            System.out.println("使用lambda表达式");
        };
        userService1.test();
        // lambda 如果方法体只有一句话，可以省略大括号以及省略一个分号
        // 如果有返回值，连return也可以省略
        UserService userService2 = () -> System.out.println("使用最简lambda表达式");
        userService2.test();
     }
}

@FunctionalInterface
// 没有参数，没有返回值
interface UserService{
    void test();
}
```
**Result:**

不适用lambda表达式

用lambda表达式

使用最简lambda表达式

### 2) 有一个参数，无返回值

```java
public class LambdaDemo {

    public static void main(String[] args) {
        // 2 方法有一个参数,园括号里面只需要知道参数的名称，不需要参数的类型。
        // 数据类型自动根据函数式接口的定义自动推断
        UserService1 test1 = (x) -> {
            System.out.println("一个参数，一行代码输出参数的值 : " + x);
        };
        test1.test(100);

        // 如果参数列表里面，只有一个参数，可以省略园括号
        UserService1 test2 = x -> System.out.println("一个参数，一行代码输出参数的值 : " + x);
        test2.test(100);
    }
}

@FunctionalInterface
// 有一个参数，没有返回值
interface UserService1{
    void test(int i);
}
```

### 3) 有二个参数，没有返回值

```java
public class LambdaDemo {

    public static void main(String[] args) {
        UserService2 test3 = (x, y) -> {
        System.out.println("两个参数 : " + x);
        System.out.println("两个参数 : " + y);
        };
        test3.test(100, 200);
    }

}

@FunctionalInterface
// 有二个参数，没有返回值
interface UserService2{
    void test(int i, int j);
}
```

### 4) 有一个参数，有返回值

```java
public class LambdaDemo {

    public static void main(String[] args) {
            // 4 有返回值
        UserService3 test4 = b -> {
            b = b + 10;
            return b;
        };
        int o = test4.test(15);
        System.out.println(o);

        // 如果省略大括号，return一定要省略掉。代码里面的表达式返回值会自动作为方法的返回值
        UserService3 test5 = b -> b + 10;
        System.out.println(test5.test(15));
    }

}

@FunctionalInterface
// 有一个参数，有返回值
interface UserService3{
    int test(int i);
}
```

## 3、方法的引用 – Lambda的使用

### 1) 引用实例方法

```java
public class TestMethodRef {

    public static void main(String[] args) {
        MethodRef r = s -> System.out.println(s);
        r.test("字符串的");

        // 使用方法的引用 : 实例方法的引用
        // System.out是一个实例
        MethodRef r1 = System.out :: println;
        r1.test("方法引用");
    }

}

@FunctionalInterface
interface MethodRef{
    void test(String s);
}
```

### 2) 引用类方法

```java
public class TestMethodRef {

    public static void main(String[] args) {
            // 能够根据函数式接口的方法参数，推断引用的方法的参数的数据类型
        // 不引用方法进行排序
        MethodRef1 r3 = (o) -> Arrays.sort(o);
        // 引用类方法
        MethodRef1 r2 = Arrays :: sort;
        int[] a = new int[]{4, 12, 32, 44, 5, 9};
        // 引用方法排序
        r2.test(a);
        // 引用方法输出
        r3.test(a);
    }

}

@FunctionalInterface
interface MethodRef1{
    void test(int[] arr);
}
```

### 3) 引用类实例方法

```java
public class TestMethodRef {

    public static void main(String[] args) {
        // *** 引用类的实例方法
        MethodRef2 r4 = PrintStream :: println;
        // 第二个之后的参数,作为引用方法的参数
        r4.test(System.out, "第二个参数");
    }

}

@FunctionalInterface
interface MethodRef2{
    void test(PrintStream out, String str);
}
```

### 4) 引用构造器

```java
public class TestMethodRef {

    public static void main(String[] args) {
        // 引用构造器,根据函数式接口的方法名来推断引用哪个构造器
        MethodRef4 r5 = String :: new;
        String ok = r5.test(new char[]{'阿' , '器'});
        System.out.println(ok);

        MethodRef4 r6 = (c) -> {return new String(c);};
        String o1 = r6.test(new char[]{'阿' , '器'});
        System.out.println(o1);
    }

}

// 测试构造器引用
@FunctionalInterface
interface MethodRef4{
    String test(char[] str);
}
```

## 4、接口中的静态方法java

从java8开始接口里面可以有静态方法(之前接口中是不能定义静态方法的)，和普通类里面的静态方法类似，使用static修饰，但是接口里面的只能是public的。格式为:

```java
[public] static <返回值> <方法名> ([形参列表])
{
    // 方法体
}
```

**例子如下:**

```java
public interface TestStaticMethod {

    // 这是一个函数式接口,因为这个接口里面只有一个抽象方法
    public void test();

    // 静态方法不是抽象方法
    static void test1(){
        System.out.println("这个是接口里面的静态方法，直接可以使用接口调用此方法");
    }

    public static void main(String[] args) {
        System.out.println("自从接口可以有静态方法，从此接口可以写main方法,可以作为程序的入口");
        TestStaticMethod.test1();
    }

}

class TestStaticMethodClass{
    public static void main(String[] args) {
        // 调用接口的静态方法
        TestStaticMethod.test1();
    }
}
```

## 5、接口中的默认方法

在Java8中除了可以在接口里面写静态方法，还可以写非静态方法，但是必须用default进行修饰。

```java
public interface TestDefaultMethod {

    // 使用 default 修改的方法,表示实例方法, 必须通过实例来方法
    public default void test(){
        System.out.println("这个是接口里面的默认方法" + this);
    }

    public static void main(String[] args) {
        // 使用匿名内部类初始化实例
        TestDefaultMethod tdm = new TestDefaultMethod() {};
        // 使用对象来访问默认方法
        tdm.test();
    }

}
```

result:

```
这个是接口里面的默认方法com.weimob.o2o....
```

接口中可以使用this关键字，但是我们可以看到结果中有$，这是不是和我们的匿名内部类有点像了？

注意：

默认方法可以被继承。如果继承多个父接口有重复的默认方法被继承到子接口，必须使用super引用明确指定调用哪个接口的默认方法在子接口必须重写重复方法，并使用下面的语法重写父接口方法重复的问题

```
<父接口类名>.super.<重复的方法名>([参数]);
```

- 同样，如果实现了多个接口，遇到有重复的默认方法，也需要使用重写重复的方法，使用super引用解决问题，和接口一样。
- 父接口的抽象方法，在子接口里面可以使用默认方法实现，这样是实现类里面就不需要再实现了。如果实现类再去实现默认方法，那么相当于是”方法覆盖”。
- 如果父接口有一个抽象方法，在子接口里面可以重写为抽象方法(去掉父接口的形为)

### 1) 默认方法多继承

```java
interface A{
    default void test(){
        System.out.println("接口A里面的默认方法");
    }
}

interface B{
    default void test(){
        System.out.println("接口B里面的默认方法");
    }
}

public interface C extends A, B {
    // 明确指定引用父接口,使用super引用调用父接口的默认方法
    // <父接口类名>.super.<重复的方法名>([参数])
    default void test(){
        B.super.test();
        System.out.println("接口C重写的默认test方法");
    }

}
```

**如果注释掉C接口中的test方法就会报以下的错误:**

Class ‘C’ never used

```java
class Test{
    public static void main(String[] args) {
        C c = new C(){};
        c.test();
    }
}
```

result:

接口B里面的默认方法

接口C重写的默认test方法

### 2) 默认方法的重写

```javascript
public interface E {

    default void test(){
        System.out.println("默认方法");
    }

}

interface F extends E{
    // 在子接口重写父接口的默认方法，把默认方法改为抽象方法
    void test();
}

class RemoveDefaultMethod {

    public static void main(String[] args) {
        E e = new E(){};
        e.test();		//默认方法
        F f = () -> System.out.println("匿名内部类重写父接口方法");
        f.test();		//匿名内部类重写父接口方法
    }

}
```





-----

# [方法引用真的等价lambda表达式吗？方法引用不永远等价于lambda表达式！](https://blog.csdn.net/lamfang/article/details/108739813)

在网络上包括许多书在介绍java8的时候都会提及lamda表达式与方法引用。

拿我们多线程经常用的Runnable接口来说：

```
public interface Runnable {
    public abstract void run();
}
```

以前我们使用这类接口时，在一些场合为了方便会使用匿名内部类，比如下面这样：

        Runnable object = new Runnable(){
            @Override
            public void run() {
                System.out.printf("1");
            }
        };
这个时候很多人就说了，java你语法太重了，代码太繁琐了，那些类名和方法没必要写。于是，java8出了一个lambda语法。之后，我们可以使用lambda表达式来代替匿名内部类的方式。

```
        Runnable object = () -> {
            System.out.printf("1");
        };
```

代码一下子就简洁了很多。

那方法引用是怎么回事呢？

> 方法引用通过方法的名字来指向一个方法。
>
> 方法引用使用一对冒号 ::

例如我们熟悉的 System.out.println(); 它的方法引用就是 System.out::println

在一般的介绍中，方法引用会等价于lambda。比如

```
Runnable object = System.out::println;
```

等价于

```
        Runnable object = ()->{
            System.out.println();
        };
```

如果我们的实现只使用到了某一个类的静态方法，那么用方法引用比lamda要更加简洁。但是在某些情况下，使用方法引用会造成capturing lambda（lamda函数的捕获现象）.**==在大多数时候没影响，在循环的情况下会造成不必要的垃圾回收。==**

进入正文：

lambda函数的捕获现象
如下所示，同样效果的两个函数，前者会造成lamda函数的捕获现象。

```
   Runnable createLambdaWithCapture() {
      return System.out::println;
   }    
   Runnable createLambdaWithApparentCapture() {
        return () -> System.out.println();
   }
```

实际上，第一个函数等价于：

```
Runnable createLambdaWithCapture() {
    PrintWriter foo = System.out;
    return () -> foo.println(); // foo is captured and effectively final
}
```

与后者相比，多了一个foo引用。

为什么方法引用翻译会多一个引用呢？

**这涉及到了编译原理。类似于a = b + c +d时，生成的中间代码是 $1 = $2 + $3 , $4 = $1 + $5;最终$4是我们要计算的a变量的值，$1是中间变量（编译原理已经学太久啦，只能说个大概是这样）。上面引用foo就是编译过程中生成的中间变量**

另外我们看StackOverflow上的一个回答，是这样说的：

> The method reference System.out::println will evaluate System.out first, then create the equivalent of a lambda expression which captures the evaluated value. Usually, you would use
> o -> System.out.println(o) to achieve the same as the method reference, but this lambda expression will evaluate System.out each time the method will be called.

**方法引用 System.out::println将会首先分析System.out，然后再创建一个等价的lambda表达式，那个表达式会有一个捕获值（也就是我们上文代码中多出来的引用foo)。当你使用的是o -> System.out.println(o)这种lambda表达式时（与System.out::println方法引用相同），System.out会在每次方法真正被调用的时候都分析System.out。**

回到我们之前的代码

```
   Runnable createLambdaWithCapture() {
      return System.out::println;
   }    
   Runnable createLambdaWithApparentCapture() {
        return () -> System.out.println();
   }
```

将方法引用替换成等价lambda之后：

```
Runnable createLambdaWithCapture() {
    PrintWriter foo = System.out;
    return () -> foo.println(); // foo is captured and effectively final
}
```

前后两者的区别在于前者在方法真正被调用之前就已经计算出System.out部分，之后就直接调用foo.println();而后者则在每次方法调用时都会计算System.out。



-----

# [Java Lambda详解](https://blog.csdn.net/weixin_68320784/article/details/123883239)

Lambda表达式是JDK 8开始后的一种新语法形式。

作用：简化匿名内部类的代码写法

简化格式

(匿名内部类被重写方法的形参列表) -> {
	重写方法
}
Lambda表达式只能简化函数式接口的匿名内部类的写法形式

什么是函数式接口？

- 首先必须是接口、其次接口中有且仅有一个抽象方法的形式
- 通常会在接口上加上一个@FunctionalInterface注解，标记该接口必须是满足函数式接口

## 如何使用Lambda？

我们将根据下面三个问题来帮助大家理解和使用Lambda

背景：我们自定义了一个man的类，创建了一个man的List。

```java
class man {
    public int age;
    public char sex;
    public double socre;

    public man(int age, char sex, double score) {
        this.age = age;
        this.sex = sex;
        this.score = score;
    }
}
```
问题一:

现需要对这个list根据人的年龄进行排序

要实现排序的功能，可以直接调用List对象自带的sort方法完成，但是需要man先实现Comparator的接口并重写compare方法，编译器才能比较两个不同man的大小。但是要更改原始类的代码，会比较麻烦，如果以后要对人的分数进行排序，那就又要更改的类的源码，这样操作很不方便。

sort(Comparator<? super E> c) 方法可以直接传入一个Comparator对象，我们可以直接改写compare方法就可以实现比较。

第一种写法

```java
    public class lambdaTry {
    public static void main(String[] args) {
        List<man> humans = new ArrayList<>();
        humans.add(new man(19, 'g', 98.0));
        humans.add(new man(18, 'b', 95.0));
        humans.add(new man(20, 'b', 96.0));
        humans.add(new man(17, 'g', 97.0));
    
    humans.sort(new Comparator<man>() {
        @Override
        public int compare(man o1, man o2) {
            return o1.age - o2.age;
        }
    });
}
}
```

第二种写法

Lambda

我们知道Lambda是用来简化函数式接口的匿名内部类，且Comparator满足函数式接口的两个条件：

- 首先必须是接口、其次接口中有且仅有一个抽象方法的形式
- @FunctionalInterface注解

```java
@FunctionalInterface
public interface Comparator<T> {
	int compare(T o1, T o2);
    ...
}
```

因此我们可以对上述的源码进行改写成Lambda格式

```java
public class lambdaTry {
    public static void main(String[] args) {
        List<man> humans = new ArrayList<>();
        humans.add(new man(19, 'g', 98.0));
        humans.add(new man(18, 'b', 95.0));
        humans.add(new man(20, 'b', 96.0));
        humans.add(new man(17, 'g', 97.0));

        humans.sort((man o1, man o2) -> {
                return o1.age - o2.age;
        });
    }
}
```
改写过后代码简洁了很多。但是还可以继续简写。

Lambda表达式的省略写法

1. ==**参数类型可以不写**==
2. ==**如果只有一个参数，参数类型可以省略，同时()也可以省略**==
3. ==**如果Lambda表达式的方法块中代码只有一行，可以省略大括号，同时省略分号。**==
4. ==**在条件三的基础上，如果这行代码是return语句，必须省略return。**==

第三种写法

Lambda简写

可以看到，此表达式满足省略写法的条件，可以继续简写成如下格式。只需要一行语句就能完成

```java
public class lambdaTry {
    public static void main(String[] args) {
        List<man> humans = new ArrayList<>();
        humans.add(new man(19, 'g', 98.0));
        humans.add(new man(18, 'b', 95.0));
        humans.add(new man(20, 'b', 96.0));
        humans.add(new man(17, 'g', 97.0));

        humans.sort((o1, o2) -> o1.age - o2.age);
    }
}
```

问题二

将List转换为数组

我们知道List接口有一个方法toArray方法可以实现将其转换为数组。

JDK11之后，提供了这样的一个方法，提供了一个函数式接口来让我们转换

```java
default <T> T[] toArray(IntFunction<T[]> generator) {
    return toArray(generator.apply(0));
}
```

IntFunction函数式接口是从JDK8之后实现的，内部只有一个apply抽象方法，是一个标准的函数式接口

```java
@FunctionalInterface
public interface IntFunction<R> {
    R apply(int value);
}
```

我们可以直接用lambda，完成数组的转换

```java
public class lambdaTry {
    public static void main(String[] args) {
        List<man> humans = new ArrayList<>();
        humans.add(new man(19, 'g', 98.0));
        humans.add(new man(18, 'b', 95.0));
        humans.add(new man(20, 'b', 96.0));
        humans.add(new man(17, 'g', 97.0));

		// 原本写法
        // man[] mans = humans.toArray(new IntFunction<man[]>() {
        //     @Override
        //     public man[] apply(int value) {
        //         return new man[value];
        //     }
        // });

        // lambda写法
        man[] mans = humans.toArray(value -> new man[value]);
        
        // 实际上用不上这样的写法，只是为了举例说明
        // man[] mans = humans.toArray(new man[0]);
        // man[] mans = humans.toArray(man[]::new);
        // 上面两种写法都可以，传值进去的size为0不影响实际的转换，具体可以看ArrayList的toArray重写方法
        
    }
}
```

问题三

输出年龄大于18的男同学的成绩

可以用forEach方法快捷实现，forEach方法来自于Iterable接口

```java
default void forEach(Consumer<? super T> action) {
    Objects.requireNonNull(action);
    for (T t : this) {
        action.accept(t);
    }
}
```

再看Consumer接口，也是一个函数式接口

```java
@FunctionalInterface
public interface Consumer<T> {
    void accept(T t);
    ...
}
```

具体实现

```java
public class lambdaTry {
    public static void main(String[] args) {
        List<man> humans = new ArrayList<>();
        humans.add(new man(19, 'g', 98.0));
        humans.add(new man(18, 'b', 95.0));
        humans.add(new man(20, 'b', 96.0));
        humans.add(new man(17, 'g', 97.0));

        // humans.forEach(new Consumer<>() {
        //     @Override
        //     public void accept(man man) {
        //         if (man.age >= 18 && man.sex == 'g') {
        //             System.out.println(man.score);
        //         }
        //     }
        // });

        humans.forEach(man -> {
            if (man.age >= 18 && man.sex == 'g') {
                System.out.println(man.score);
            }
        });
    }
}
```

有时Lambda还可以继续简写成方法引用（method reference）

## 方法引用

方法引用通过方法的名字来指向一个方法。

方法引用可以使语言的构造更紧凑简洁，减少冗余代码。

方法引用使用一对冒号 ::

主要分为四种：

- **==构造器引用 Class::new==**

​	man[] mans = humans.toArray(man[]::new);

- ==**静态方法引用 Class::static_method**==

​	打印每个man（需要在man内重写toString）

​	humans.forEach(System.out::println)

- ==**特定类的任意对象的方法引用 Class::method**==

- ==**特定对象的方法引用 instance::method**==



----

# [Java 8 方法引用](https://www.runoob.com/java/java8-method-references.html)

方法引用通过方法的名字来指向一个方法。

方法引用可以使语言的构造更紧凑简洁，减少冗余代码。

方法引用使用一对冒号 **::** 。

下面，我们在 Car 类中定义了 4 个方法作为例子来区分 Java 中 4 种不同方法的引用。

```java
package com.runoob.main;
 
@FunctionalInterface
public interface Supplier<T> {
    T get();
}
 
class Car {
    //Supplier是jdk1.8的接口，这里和lamda一起使用了
    public static Car create(final Supplier<Car> supplier) {
        return supplier.get();
    }
 
    public static void collide(final Car car) {
        System.out.println("Collided " + car.toString());
    }
 
    public void follow(final Car another) {
        System.out.println("Following the " + another.toString());
    }
 
    public void repair() {
        System.out.println("Repaired " + this.toString());
    }
}
```

- **构造器引用：**它的语法是Class::new，或者更一般的Class< T >::new实例如下：

  ```java
  final Car car = Car.create( Car::new ); 
  final List< Car > cars = Arrays.asList( car );
  ```

- **静态方法引用：**它的语法是Class::static_method，实例如下：

  ```java
  cars.forEach( Car::collide );
  ```

- **特定类的任意对象的方法引用：**

  它的语法是Class::method实例如下：

  ```java
  cars.forEach( Car::repair );
  ```

- ==**特定对象的方法引用：**==

  它的语法是instance::method实例如下：

  ```java
  final Car police = Car.create( Car::new ); cars.forEach( police::follow );
  ```

  ## 方法引用实例

  在 Java8Tester.java 文件输入以下代码：

```java
import java.util.List;
import java.util.ArrayList;
 
public class Java8Tester {
   public static void main(String args[]){
      List<String> names = new ArrayList();
        
      names.add("Google");
      names.add("Runoob");
      names.add("Taobao");
      names.add("Baidu");
      names.add("Sina");
        
      names.forEach(System.out::println);
   }
}
```

实例中我们将 System.out::println 方法作为静态方法来引用。

执行以上脚本，输出结果为：

```
$ javac Java8Tester.java 
$ java Java8Tester
Google
Runoob
Taobao
Baidu
Sina
```



-----

# [Java的方法引用](https://blog.csdn.net/qq_43141726/article/details/122716680)

## 1.方法引用

方法引用是用来直接访问类或者实例的已经存在的方法或者构造方法。方法引用提供了一种引用而不执行方法的方式，它需要由兼容的函数式接口构成的目标类型上下文。计算时，方法引用会创建函数式接口的一个实例。

方法引用通过方法的名字来指向一个方法。

方法引用可以使语言的构造更紧凑简洁，减少冗余代码。

方法引用使用一对冒号 ::

## 2.方法引用与lambda

![在这里插入图片描述](Lambda 表达式.assets/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAT29aenp5,size_20,color_FFFFFF,t_70,g_se,x_16.png)

## 3.方法引用的使用

```java
@Data
@ApiModel
class DataInfo{
    private String name;

    private String info;

    private String welcome;

    public static DataInfo create( Supplier<DataInfo> supplier) {
        return supplier.get();
    }

    public static void getDataInfo( DataInfo dataInfo) {
        System.out.println("DataInfo ： " + dataInfo.toString());
    }

    public void getWebNameinfo( DataInfo dataInfo) {
        System.out.println(" WebName " + dataInfo.getName());
    }

    public void getWelcomeInfo() {
        System.out.println("welcome " + this.toString());
    }
}
```

### 静态方法引用

静态方法引用：它的语法是Class::static_method

```java
dataInfoList.forEach(DataInfo::getDataInfo);
```

```java
//lambda表达式优化
useConverter(s->Integer.parseInt(s));

//引用类方法改进优化
useConverter(Integer::parseInt);
//lambda表达式被类方法替代的时候,它的形式参数全部传递给静态方法作为参数
```

### 实例方法引用

特定对象的方法引用：它的语法是instance::method实例

```java
dataInfoList.forEach( DataInfo.create( DataInfo::new )::getWebNameinfo );
```

### 对象方法引用

特定类的任意对象的方法引用：它的语法是Class::method

```java
 dataInfoList.forEach(DataInfo::getWelcomeInfo);
```

### 构建方法引用

构造器引用：它的语法是Class::new。

```java
DataInfo dataInfo = DataInfo.create(DataInfo::new);
```

