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



# [java8新特性 lambda Stream map(函数式编程)](https://blog.csdn.net/u014646662/article/details/52261511/)

牛刀小试：使用Java8新特性获取股票数据
https://blog.csdn.net/u014646662/article/details/82936131

Java8实战.pdf 下载：
https://download.csdn.net/download/u014646662/10805079

对人工智能感兴趣的同学，可以点击以下链接：

现在人工智能非常火爆，很多朋友都想学，但是一般的教程都是为博硕生准备的，太难看懂了。最近发现了一个非常适合小白入门的教程，不仅通俗易懂而且还很风趣幽默。所以忍不住分享一下给大家。点这里可以跳转到教程。

https://www.cbedai.net/u014646662

1.接口的默认方法
Java 8允许我们给接口添加一个非抽象的方法实现，只需要使用 default关键字即可，这个特征又叫做扩展方法

```java
//Formula表示一个设计 计算公式 的接口 
public interface Formula {
	//计算
	double calculate(int a);
	
	//开方
	default double sqrt(int a){
		return Math.sqrt(a);
	}
}
 
main:
Formula f = new Formula() {
	@Override
	public double calculate(int a) {
		return a+1;
	}
};
System.out.println(f.calculate(4));
System.out.println(f.sqrt(8));
 
注意:现在接口还可以存在静态方法，
可以使用 接口名.静态方法名 的形式直接调用
```

## 2.Lambda 表达式

### 2.1 认识Lambda表达式

```java
 
	public class LambdaTest1 {
	
		public static void main(String[] args) {
			
			//假如一个list机会中的元素要排序
			List<String> list = Arrays.asList
			("hello","tom","apple","bbc");
			//之前的排序我们可以这样写
			Collections.sort(list, new Comparator<String>(){
				@Override
				public int compare(String o1, String o2) {
					return -o1.compareTo(o2);
				}
			});
			
			//使用Lambda表达式
			Collections.sort(list,(String s1,String s2)->{
				return s1.compareTo(s2);
			});
			
			//可以简写为
			//1.大括号里面就一句代码
			//2.编译器可以自动推导出参数类型
			Collections.sort(list,(s1,s2)->s1.compareTo(s2));
			
			System.out.println(list);
			
		}
		
	}
```

### 2.2 Functional接口

```
“函数式接口”是指仅仅只包含一个抽象方法的接口，每一个该类型的lambda表达式都会被匹配到这个抽象方法。因为 默认方法 不算抽象方法，所以你也可以给你的函数式接口添加默认方法。
我们可以将lambda表达式当作任意只包含一个抽象方法的接口类型，确保你的接口一定达到这个要求，你只需要给你的接口添加 @FunctionalInterface 注解，编译器如果发现你标注了这个注解的接口有多于一个抽象方法的时候会报错的。
```

```java
public class LambdaTest2 {
	
		public static void main(String[] args) {
			
			LambdaTest2 t = new LambdaTest2();
	//		也可以先创建对象
	//		Action1 a1 = ()->System.out.println("hello");
			
			t.test1(()->System.out.println("hello"));
			
			//Action2<String,Integer> a2 = (f)->"这个数字是:"+f;	//默认写法：参数 -> 返回;或者参数->{程序处理... return xxx;}
			//如果参数就一个,那么还可以这样简写 去掉小括号
			Action2<String,Integer> a2 = f->"这个数字是:"+f;
			t.test2(a2);
		}
		public void test1(Action1 a){
			a.run();
		}
		public void test2(Action2<String,Integer> a){
			System.out.println(a.run(3));
		}
		
	}
	//这个注解不加也可以,加上只是为了让编译器检查
	@FunctionalInterface
	interface Action1{
		public void run();
	}
	
	//这个注解不加也可以,加上只是为了让编译器检查
	@FunctionalInterface
	interface Action2<T,F>{
		public T run(F f);
	}
	
 
	注意:lambda表达式无法访问接口的默认方法
```

### 2.3 方法与构造函数引用

Java 8 允许你使用 :: 关键字来传递方法(静态方法和非静态方法)

```java
 
	public class LambdaTest3 {
		public static void main(String[] args) {
			
			LambdaTest3 t = new LambdaTest3();
			//使用Lambda引用类的静态方法
			//能引用Integer类中的静态方法toBinaryString的原因是:
			//Action3接口中只有一个方法且方法的参数类型和返回值类型
			//与Integer类中的静态方法toBinaryString的参数类型、返回类型是一致的
			Action3 a3 = Integer::toBinaryString;
			System.out.println(a3.run(4));
			
			//使用Lambda引用对象的非静态方法
			//能引用对象t中的非静态方法test的原因是和上面的描述是一致的
			Action3 aa3 = t::test;
			System.out.println(aa3.run(4));
		}
		
		public String test(int i){
			return "i="+i;
		}
	}
 
	@FunctionalInterface
	interface Action3{
		public String run(int Integer);
	}
 
 
//下面是一个接口中带泛型的时候特殊例子: 可以使用  类名::非静态方法  的形式引用方法(只能引用无参的非静态方法，因为类名	不可以作为实体对象参数)。
//要引用有参的非静态方法，可以使用  对象::非静态方法
	public class LambdaTest6 {
	
		public static void main(String[] args) {
			
			Model m = new Model();
			
			//方法有一个参数，然后没返回类型,这里参数类型会自动识别
			Action<Model> a1 = (s)->System.out.println("hello");
			a1.run(m);
			
			//注意:如果这里泛型类型不是Model 那么就不能引用Model中的非静态方法（可以引用静态方法，但静态方法参数返回类			型(需要可以转换，会将实现方法返回转换为接口定义返回类型)要匹配接口）
        //可以引用Model类中任意方法 只要满足一点:该方法没有参数
        //将来run方法中就会调用Model类型对象m的此处引用的方法
			Action<Model> a2 = Model::test3;	//返回类型int会转换为void
			a2.run(m);
            Action<Model> test2 = Model::test1;
        	test2.run(m);
//          Action<String> stringAction = Model::test31;  会报错：要引用非泛型类名的方法只能引用静态方法
			
			//引用对象m中的test2方法
			//因为test2方法的参数和返回类型和Action接口的方法完全一致
			Action<Model> a3 = m::test2;
			a3.run(m);
//       	Action<Model> a32 = Model::test2;    会报错：必须要用实体类，因为类名不可以作为实体对象参数
            
             //引用静态方法
//      	Action<Model> a7 = Model::test7;   会报错：类名引用静态方法必须有参
       	 	Action<Model> a71 = Model::test71;
        	Action2<String> test4Int = Model::test4;
        	Integer test4IntOut = test4Int.run("a222");
        	Action2<String> test5Inte = Model::test5;
       		Integer test5InteOut = test5Inte.run("a2223");
        	System.out.println(test4IntOut +"//"+test5InteOut);
        	Action2<Double> d1 = Model::test8;
            
             /*总结
        * 函数接口带泛型，可以引用： 都要求实现方法返回类型可转换
        * 泛型类名::（只可无参，返回类型相同）非静态方法
        * 泛型实体对象:（入参相同，返回类型相同）非静态方法
        * 要引用非泛型类名的方法只能引用静态方法
        *
        * 泛型类名::（必须有参，返回类型相同）静态方法
        * 非泛型类名::（必须有参，且参数类型与泛型类型相同）静态方法
        *
        * 相同指可转换：如（double -> Double,int -> Integer）
        * */
		}
		
	}
 
	interface Action<T>{
		public void run(T t);
	}
	interface Action2<T>{
    	public Integer run(T t);
	}
 
	class Model{
		
		public void test1(){
			System.out.println("test1");
		}
		public void test2(Model a){
			System.out.println("test2");
		}
		public int test3(){
			System.out.println("test3");
			return 1;
		}
        public int test31(String s){
        System.out.println("test3");
        return 1;
    }
    public static int test4(String s){
        System.out.println("test4："+s);
        return 4;
    }

    public static Integer test5(String s) {
        System.out.println("test5："+s);
        return 5;
    }
    public static Integer test7() {
        System.out.println("test7：");
        return 7;
    }
    public static Integer test71(Model m) {
        System.out.println("test71："+m);
        return 71;
    }
    public static Integer test8(double d) {
        System.out.println("test8："+d);
        return 8;
    }
	}
	
 
	Java 8 允许你使用 :: 关键字来引用构造函数
	public class LambdaTest4 {
		
		public static void main(String[] args) {
			
			//Lambda表达式引用构造函数
			//根据构造器的参数来自动匹配使用哪一个构造器
			Action4Creater creater = Action4::new;
			Action4 a4 = creater.create("zhangsan");
			a4.say();
			
			
		}
		
	}
 
	class Action4{
		private String name;
		public Action4() {
			
		}
		public Action4(String name) {
			this.name = name;
		}
		public void say(){
			System.out.println("name = "+name);
		}
	}
 
	interface Action4Creater{
		public Action4 create(String name);		//因为接口方法返回Action对象，故可传入Action构造方法返回Action对象，但接口参数类型需在Action构造方法中有同类型的入参构造（即第二个String name构造方法，因为会根据接口参数类型去匹配构造方法）
	}
 
```

**总结：**
 **        **函数接口带泛型，可以引用： 都要求实现方法返回类型可转换**
         **泛型类名::（只可无参，返回类型相同）非静态方法**
         **泛型实体对象:（入参相同，返回类型相同）非静态方法**
         **要引用非泛型类名的方法只能引用静态方法**
        

```
     **泛型类名::（必须有参，返回类型相同）静态方法**
     **非泛型类名::（必须有参，且参数类型与泛型类型相同）静态方法**
```

**这里相同指可转换：如（double -> Double,int -> Integer）**

​        

### 2.4 lambda表达式中的变量访问

```java
 
	public class LambdaTest5 {
		private static int j;
		private int k;
		public static void main(String[] args) {
			LambdaTest5 t = new LambdaTest5();
			t.test();
		}
		
		public void test(){
			int num = 10;
			j = 20;
			k = 30;
			
			//lambda表达式中可以访问成员变量也可以方法局部变量
			Action5 a5 = (i)->System.out.println("操作后:i="+(i+num+j+k));
			a5.run(1);
			
			//但是这个被访问的变量默认变为final修饰的 不可再改变 否则编译不通过
			//num = 60;
			j = 50;
			k = 70;
		}
		
	}
 
	interface Action5{
		public void run(int i);
	}
```

### 2.5 Predicate接口和lambda表达式

java.util.function.Predicate接口是用来支持java函数式编程新增的一个接口,使用这个接口和lamb表达式就可以以更少的代码为API方法添加更多的动态行为。 

```java
public class LambdaTest6 {
		public static void main(String[] args) {
			List<String> languages = Arrays.asList("Java", "html5","JavaScript", "C++", "hibernate", "PHP");
			
			//开头是J的语言
			filter(languages,(name)->name.startsWith("J"));
			//5结尾的
			filter(languages,(name)->name.endsWith("5"));
			//所有的语言
			filter(languages,(name)->true);
			//一个都不显示
			filter(languages,(name)->false);
			//显示名字长度大于4
			filter(languages,(name)->name.length()>4);
			System.out.println("-----------------------");
			//名字以J开头并且长度大于4的
			Predicate<String> c1 = (name)->name.startsWith("J");
			Predicate<String> c2 = (name)->name.length()>4;
			filter(languages,c1.and(c2));
			
			//名字不是以J开头
			Predicate<String> c3 = (name)->name.startsWith("J");
			filter(languages,c3.negate());
			
			//名字以J开头或者长度小于4的
			Predicate<String> c4 = (name)->name.startsWith("J");
			Predicate<String> c5 = (name)->name.length()<4;
			filter(languages,c4.or(c5));
			
			//名字为Java的
			filter(languages,Predicate.isEqual("Java"));
			
			//判断俩个字符串是否相等
			boolean test = Predicate.isEqual("hello").test("world");
			System.out.println(test);
		}
		public static void filter(List<String> languages, Predicate<String> condition) {  
			for(String name: languages) {  
				if(condition.test(name)) {  
					System.out.println(name + " ");  
				}  
			}  
		}  
		
	}	
```

### 2.6 Function 接口

 Function有一个参数并且返回一个结果，并附带了一些可以和其他函数组合的默认方法
 compose方法表示在某个方法之前执行
andThen方法表示在某个方法之后执行
注意：compose和andThen方法调用之后都会把对象自己本身返回，这可以方便链式编程
default <V> Function<T,V> andThen(Function<? super R,? extends V> after) 返回一个先执行当前函数对象apply方法再执行after函数对象apply方法的函数对象。

 default <V> Function<T,V> compose(Function<? super V,? extends T> before)返回一个先执行before函数对象apply方法再执行当前函数对象apply方法的函数对象。

 static <T> Function<T,T> identity() 返回一个执行了apply()方法之后只会返回输入参数的函数对象。

```java
 
	
	
	public interface Function<T, R> {
 
		R apply(T t);
 
		default <V> Function<V, R> compose(Function<? super V, ? extends T> before) {
			Objects.requireNonNull(before);
			return (V v) -> apply(before.apply(v));
		}
 
		default <V> Function<T, V> andThen(Function<? super R, ? extends V> after) {
			Objects.requireNonNull(after);
			return (T t) -> after.apply(apply(t));
		}
		
		//注意: t->t是(t)->t的简写
		//t->t是作为方法identity的返回值的,也就是Function类型对象
		//类似于这样的写法:Function<Object, Object> f = t->t;
		//那么f.apply("test") 返回字符串"test"
		//传入什么则返回什么
		static <T> Function<T, T> identity() {
			return t -> t;
		}
	}
 
	例如:
	public class LambdaTest7 {
		//静态内部类
		private static class Student{
			private String name;
			public Student(String name){
				this.name = name;
			}
			public String getName() {
				return name;
			}
			
		}
		public static void main(String[] args) {
			/*用户注册输入一个名字tom*/
			String name = "tom";
			
			/*使用用户的输入的名字创建一个对象*/
			Function<String, Student> f1 =(s)->new Student(s);
			//注意上面的代码也可以写出这样，引用类中的构造器
			//Function<String, Student> f1 =Student::new;
			Student stu1 = f1.apply(name);
			System.out.println(stu1.getName());
			
			/*需求改变,使用name创建Student对象之前需要给name加一个前缀*/
			Function<String,String> before = (s)->"briup_"+s;
			//表示f1调用之前先执行before对象的方法,把before对象的方法返回结果作为f1对象方法的参数
			Student stu2 = f1.compose(before).apply(name);
			System.out.println(stu2.getName());
			
			/*获得创建好的对象中的名字的长度*/
			Function<Student,Integer> after = (stu)->stu.getName().length();
			//before先调用方法,结果作为参数传给f1来调用方法,结果再作为参数传给after,结果就是我们接收的数据
			int len = f1.compose(before).andThen(after).apply(name);
			System.out.println(len);
			
		}
		
	}   
```

### 2.7 Supplier接口

Supplier接口返回一个任意范型的值，和Function接口不同的是该接口没有任何参数

```java
 
	public interface Supplier<T> {
		T get();
	}
	例如:
	public class LambdaTest8 {
		public static void main(String[] args) {
			//生成一个八位的随机字符串
			Supplier<String> f = ()->{
				String base = "abcdefghijklmnopqrstuvwxyz0123456789";     
				Random random = new Random();     
				StringBuffer sb = new StringBuffer();     
				for (int i = 0; i < 8; i++) {  
					//生成[0,base.length)之间的随机数
					int number = random.nextInt(base.length());     
					sb.append(base.charAt(number));     
				}     
				return sb.toString();   
			};
			System.out.println(f.get());
		}
		
	}
```

### 2.8 Consumer接口

Consumer接口接收一个任意范型的值，和Function接口不同的是该接口没有任何值

```java
 
	public interface Consumer<T> {
 
		void accept(T t);
 
		default Consumer<T> andThen(Consumer<? super T> after) {
			Objects.requireNonNull(after);
			return (T t) -> { accept(t); after.accept(t); };
		}
	}
	例如:
	public class LambdaTest9 {
		//静态内部类
		private static class Student{
			private String name;
 
			public String getName() {
				return name;
			}
 
			public void setName(String name) {
				this.name = name;
			}
		}
		
		public static void main(String[] args) {
			Student s = new Student();
			s.setName("tom");
			
			Consumer<Student> c = 
			stu->System.out.println("hello!"+stu.getName());
			c.accept(s);
			
		}
		
	}
 
```

#### 总结

​        Function<T, R>  接口   R apply(T t);       有参数有返回值
​        Supplier<T>       接口   T get();          没参数有返回值
​        Consumer<T>    接口   void accept(T t); 有参数没返回值

```
    另外需要注意的接口: 其用法和上面介绍的接口使用方式类同
    BinaryOperator<T>接口    T apply(T t, T t)  将两个T作为输入，返回一个T作为输出
    BiFunction<T, U, R>接口  R apply(T t, U u)  将一个T和一个U输入，返回一个R作为输出
    BinaryOperator接口继承了BiFunction接口
    public interface BinaryOperator<T> extends BiFunction<T,T,T>

    BiConsumer<T, U>接口  void accept(T t, U u) 将俩个参数传入，没有返回值
```

### 2.9 Optional类

​    Optional 不是接口而是一个类，这是个用来防止NullPointerException异常的辅助类型
​    Optional 被定义为一个简单的容器，其值可能是null或者不是null。
​    在Java8之前一般某个函数应该返回非空对象但是偶尔却可能返回了null，而在Java 8中，不推荐你返回null而是返回Optional。
​    这是一个可以为null的容器对象。
​    如果值存在则isPresent()方法会返回true，调用get()方法会返回该对象。

```java
 
public class Optotion {
 
public static void main(String[] args) {
	
	/*of方法 为非null的值创建一个Optional*/
	//of方法通过工厂方法创建Optional类。
	//需要注意的是，创建对象时传入的参数不能为null。
	//如果传入参数为null，则抛出NullPointerException 。
	Optional<String> op1 = Optional.of("hello");
	
	/*ofNullable方法 为指定的值创建一个Optional，如果指定的值为null，则返回一个空的Optional。*/
	//ofNullable与of方法相似，唯一的区别是可以接受参数为null的情况
	Optional<String> op2 = Optional.ofNullable(null);
	
	/*isPresent方法 如果值存在返回true，否则返回false。*/
	/*get方法 如果Optional有值则将其返回，否则抛出NoSuchElementException。*/
	if(op1.isPresent()){
		System.out.println(op1.get());
	}
	if(op2.isPresent()){
		System.out.println(op2.get());
	}
	
	/*ifPresent方法 如果Optional实例有值则为其调用consumer，否则不做处理*/
	//consumer接口中的方法只有参数没有返回值
	op1.ifPresent(str->System.out.println(str));
	op2.ifPresent(str->System.out.println(str));//这个不执行 因为op2里面的值是null
	
	
	/*orElse方法 如果有值则将其返回，否则返回指定的其它值。*/
	System.out.println(op1.orElse("如果op1中的值为null则返回这句话,否则返回这个值"));
	System.out.println(op2.orElse("如果op2中的值为null则返回这句话,否则返回这个值"));
	
	
	/*orElseGet方法 orElseGet与orElse方法类似，区别在于得到的默认值。orElse方法将传入的字符串作为默认值，orElseGet方法可以接受Supplier接口的实现用来生成默认值。*/
	//Supplier接口中的方法没有参数但是有返回值
	System.out.println(op1.orElseGet(()->"自己定义的返回值"));
	System.out.println(op2.orElseGet(()->"自己定义的返回值"));
	
	
	/*orElseThrow方法 如果有值则将其返回，否则抛出supplier接口创建的异常。*/
	//在orElseThrow中我们可以传入一个lambda表达式或方法，如果值不存在来抛出异常。
	//orElseThrow方法的声明如下 所有只能返回一个Throwable类型对象
	//public <X extends Throwable> T orElseThrow(Supplier<? extends X> exceptionSupplier) throws X
	try {
		System.out.println(op1.orElseThrow(Exception::new));;
		//System.out.println(op2.orElseThrow(Exception::new));;这个会抛出异常
	} catch (Exception e) {
		e.printStackTrace();
	}
	
	
	/*map方法 如果有值，则对其执行调用mapper函数得到返回值。*/
	//返回值并且依然Optional包裹起来,其泛型和你返回值的类型一致
	//public<U> Optional<U> map(Function<? super T, ? extends U> mapper)
	Optional<Integer> map1 = op1.map(str->1);
	System.out.println(map1.get());
	Optional<Double> map2 = op2.map(str->1.2);
	System.out.println(map2.orElse(0.0));
	
	
	/*flatMap方法 如果有值，为其执行mapper函数返回Optional类型返回值，否则返回空Optional。*/
	//flatMap与map方法类似，区别在于flatMap中的mapper返回值必须是Optional。调用结束时，flatMap不会对结果用Optional封装。
	//需要我们自己把返回值封装为Optional
	//public<U> Optional<U> flatMap(Function<? super T, Optional<U>> mapper) 
	System.out.println(op1.flatMap(str->Optional.of(str+"_briup")).get());
	//op1.flatMap(str->"");编译出错
	
	
	/*filter方法 如果有值并且满足断言条件返回包含该值的Optional，否则返回空Optional。*/
	//public Optional<T> filter(Predicate<? super T> predicate) 
	op1 = op1.filter(str->str.length()<10);
	System.out.println(op1.orElse("值为null"));
	op1 = op1.filter(str->str.length()>10);
	System.out.println(op1.orElse("值为null"));
}
```

### 2.10 Stream 接口

java.util.Stream 表示能应用在一组元素上一次执行的操作序列。
    Stream 操作分为中间操作或者最终操作两种，最终操作返回一特定类型的计算结果，
    而中间操作返回Stream本身，这样你就可以将多个操作依次串起来(链式编程)。
    Stream 的创建需要指定一个数据源，比如 java.util.Collection的子类，List或者Set， Map不支持。
    Stream的操作可以串行执行或者并行执行。
    Stream 作为 Java 8 的一大亮点，它与 java.io 包里的 InputStream 和 OutputStream 是完全不同的概念。
    Java 8 中的 Stream 是对集合（Collection）对象功能的增强，它专注于对集合对象进行各种非常便利、
    高效的聚合操作（aggregate operation），或者大批量数据操作 (bulk data operation)。
    Stream API 借助于同样新出现的Lambda表达式，极大的提高编程效率和程序可读性。
    同时它提供串行和并行两种模式进行汇聚操作

#### 2.10.1 Stream对象的构建:

```java
 // 1.使用值构建
Stream<String> stream = Stream.of("a", "b", "c");
// 2. 使用数组构建
String[] strArray = new String[] {"a", "b", "c"};
Stream<String> stream = Stream.of(strArray);
Stream<String> stream = Arrays.stream(strArray);
// 3. 利用集合构建(不支持Map集合)
List<String> list = Arrays.asList(strArray);
stream = list.stream();
```

对于基本数值型，目前有三种对应的包装类型 Stream：IntStream、LongStream、DoubleStream。
当然我们也可以用 Stream<Integer>、Stream<Long> 、Stream<Double>，但是 自动拆箱装箱会很耗时，所以特别为这三种基本数值型提供了对应的 Stream。
Java 8 中还没有提供其它基本类型数值的Stream

#### 2.10.2 数值Stream的构建:

```
IntStream stream1 = IntStream.of(new int[]{1, 2, 3});
//[1,3)
IntStream stream2 = IntStream.range(1, 3);
//[1,3]
IntStream stream3 = IntStream.rangeClosed(1, 3);
```

#### 2.10.3 Stream转换为其它类型:

```java
 Stream<String> stream = Stream.of("hello","world","tom");
// 1. 转换为Array
String[] strArray  = stream.toArray(String[]::new);
// 2. 转换为Collection
List<String> list1 = stream.collect(Collectors.toList());
List<String> list2 = stream.collect(Collectors.toCollection(ArrayList::new));
Set<String> set3 = stream.collect(Collectors.toSet());
Set<String> set4 = stream.collect(Collectors.toCollection(HashSet::new));
// 3. 转换为String
String str = stream.collect(Collectors.joining()).toString();
```

特别注意 : 一个 Stream 只可以使用一次，上面的代码为了简洁而重复使用了多次。
这个代码直接运行会抛出异常的:
java.lang.IllegalStateException: stream has already been operated upon or closed

#### 2.10.4 Stream操作

当把一个数据结构包装成Stream后，就要开始对里面的元素进行各类操作了。常见的操作可以归类如下。

Intermediate：中间操作
map (mapToInt, flatMap 等)、 filter、 distinct、 sorted、 peek、 limit、 skip、 parallel、 sequential、 unordered

Terminal： 最终操作
forEach、 forEachOrdered、 toArray、 reduce、 collect、 min、 max、 count、 anyMatch、 allMatch、 noneMatch、findFirst、 findAny、 iterator

Short-circuiting： 短路操作
anyMatch、 allMatch、 noneMatch、 findFirst、 findAny、 limit

map/flatMap映射 把 Stream中 的每一个元素，映射成另外一个元素。

```java
//转换大写
Stream<String> wordList = Stream.of("hello","world","tom");
List<String> output = wordList. map(String::toUpperCase). collect(Collectors.toList());
  //也可以直接使用forEach循环输出
wordList.map(String::toUpperCase).collect(Collectors.toList()).forEach(System.out::println);
 
 
//计算平方数
List<Integer> nums = Arrays.asList(1, 2, 3, 4);
List<Integer> squareNums =  nums.stream(). map(n -> n * n). collect(Collectors.toList());

```

**==map生成的是个1:1映射，每个输入元素，都按照规则转换成为另外一个元素。还有一些场景，是一对多映射关系的，这时需要 flatMap。==**
map和flatMap的方法声明是不一样的
<R> Stream<R>      map(Function<? super T, ? extends R> mapper);
<R> Stream<R> flatMap(Function<? super T, ? extends Stream<? extends R>> mapper);

```java
//stream1中的每个元素都是一个List集合对象
Stream<List<Integer>> stream1 = Stream.of(
				 Arrays.asList(1),
				 Arrays.asList(2, 3),
				 Arrays.asList(4, 5, 6)
			 );
			Stream<Integer> stream2 = stream1.
			flatMap((e) -> e.stream());
			
stream2.forEach(e->System.out.println(e));//输出1 2 3 4 5 6
flatMap 把 stream1 中的层级结构扁平化，就是将最底层元素抽出来放到一起，最终新的 stream2 里面已经没有 List 了，都是直接的数字。
 
例子:
Stream<String> stream1 = Stream.of("tom.Li","lucy.Liu");
//flatMap方法把stream1中的每一个字符串都用[.]分割成了俩个字符串
//最后返回了一个包含4个字符串的stream2
Stream<String> stream2 = stream1.flatMap(s->Stream.of(s.split("[.]")));
stream2.forEach(System.out::println);
输出结果:
	tom
	Li
	lucy
	Liu

```

forEach 遍历 接收一个 Lambda 表达式，然后在 Stream 的每一个元素上执行该表达式。
forEach 是 terminal 操作，执行完stream就不能再用了

```
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
list.stream().forEach(System.out::println);

```

filter 过滤 对原始 Stream 进行某项测试，通过测试的元素被留下来生成一个新 Stream。
通过一个predicate接口来过滤并只保留符合条件的元素，该操作属于中间操作，所以我们可以在过滤后的结果来应用其他Stream操作（比如forEach）。forEach需要一个函数来对过滤后的元素依次执行。forEach是一个最终操作，所以我们不能在forEach之后来执行其他Stream操作

```java
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
list.stream().filter(s->s.length()>4).forEach(System.out::println);
//注意:System.out::println 这个是lambda表达式中对静态方法的引用

```

peek 对每个元素执行操作并返回一个新的 Stream
注意:调用peek之后,一定要有一个最终操作
peek是一个intermediate 操作

```java
List<String> list = Arrays.asList("one", "two", "three", "four");
List<String> list2 = list.stream()
			 .filter(e -> e.length() > 3)
			 .peek(e -> System.out.println("第一次符合条件的值为: " + e))
			 .filter(e->e.length()>4)
			 .peek(e -> System.out.println("第二次符合条件的值为: " + e))
			 .collect(Collectors.toList());
System.out.println(list2.size());//打印结果为 1
最后list2中就存放的筛选出来的元素

```

findFirst 总是返回 Stream 的第一个元素，或者空，返回值类型：Optional。
如果集中什么都没有,那么list.stream().findFirst()返回一个Optional<String>对象,但是里面封装的是一个null。

```java
List<String> list = Arrays.asList("test","hello","world");
Optional<String> first = list.stream().findFirst();
System.out.println(first.orElse("值为null"));

```

sort 排序
排序是一个中间操作，返回的是排序好后的Stream。如果你不指定一个自定义的Comparator则会使用默认排序。
对 Stream 的排序通过 sorted 进行，它比数组的排序更强之处在于你可以首先对 Stream 进行各类 map、filter、limit、skip 甚至 distinct 来减少元素数量后，再排序，这能帮助程序明显缩短执行时间。

```java
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
list.stream().sorted().filter(s->s.startsWith("j")).forEach(System.out::println);
//按照字符串的长短排序
list.stream().sorted((s1,s2)->s1.length()-s2.length()).forEach(System.out::println);

```

需要注意的是，排序只创建了一个排列好后的Stream，而不会影响原有的数据源，排序之后原数据list是不会被修改的

map 映射
中间操作map会将元素根据指定的Function接口来依次将元素转成另外的对象，下面的示例展示了将字符串转换为大写字符串。 你也可以通过map来讲对象转换成其他类型，map返回的Stream类型是根据你map传递进去的函数的返回值决定的。

```java
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
list.stream().map(s->s.toUpperCase()).forEach(System.out::println);

```

Match 匹配
Stream提供了多种匹配操作，允许检测指定的Predicate是否匹配整个Stream。所有的匹配操作都是最终操作，并返回一个boolean类型的值。

```java
 //所有元素匹配成功才返回true 否则返回false
例子:
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
boolean allMatch = list.stream().allMatch((s)->s.startsWith("j"));
System.out.println(allMatch);
 
//任意一个匹配成功就返回true 否则返回false
例子:
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
boolean anyMatch = list.stream().anyMatch((s)->s.startsWith("j"));
System.out.println(anyMatch);
 
//没有一个匹配的就返回true 否则返回false
例子:
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
boolean noneMatch = list.stream().noneMatch((s)->s.startsWith("j"));
System.out.println(noneMatch);
```

Count 计数
计数是一个最终操作，返回Stream中元素的个数，返回值类型是long。

```java
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
long count = list.stream().filter(s->s.startsWith("j")).count();
System.out.println(count);
```

Reduce 规约/合并
这是一个最终操作，允许通过指定的函数来将stream中的多个元素规约合并为一个元素.它提供一个起始值（种子），然后依照运算规则（BinaryOperator），和前面 Stream 的第一个、第二个、第 n 个元素组合。Stream.reduce，常用的方法有average, sum, min, max, and count，返回单个的结果值， 并且reduce操作每处理一个元素总是创建一个新值.
从这个意义上说，字符串拼接、数值的 sum、min、max等都是特殊的 reduce。

```java
IntStream integers = IntStream.range(1, 10);
Integer sum = integers.reduce(0, (a, b) -> a+b); 或
Integer sum = integers.reduce(0, Integer::sum);
//也有没有起始值的情况，这时会把 Stream 的前面两个元素组合起来，返回的是 Optional。
OptionalInt min = integers.reduce((a, b) -> a<b?a:b);
// 字符串连接，concat = "ABCD"
String concat 		 = Stream.of("A", "B", "C", "D").reduce("", String::concat); 
Optional<String> opStr = Stream.of("A", "B", "C", "D").reduce(String::concat); 
 
List<String> list =Arrays.asList("test","javap","hello","world","java","tom","C","javascript");
Optional<String> reduce = list.stream()
    .sorted((s1,s2)->s2.length()-s1.length())
    .filter(s->s.startsWith("j"))
    .map(s->s+"_briup")
    .reduce((s1,s2)->s1+"|"+s2);
System.out.println(reduce.orElse("值为空"));//打印结果为: javascript_briup|javap_briup|java_briup
整个代码有点长，可以换行看下:
Optional<String> reduce    =  list.stream()
				  .sorted((s1,s2)->s2.length()-s1.length())
				  .filter(s->s.startsWith("j"))
				  .map(s->s+"_briup")
				  .reduce((s1,s2)->s1+"|"+s2);	
```

 1.先调用stream方法
    2.再排序，按照字符串的长度进行排序，长的在前短的再后
    3.再过滤，字符串必须是以字符'j'开头的
    4.再进行映射，把每个字符串后面拼接上"_briup"
    5.再调用reduce进行合并数据,使用"|"连接字符串
    6.最后返回Optional<String>类型数据，处理好的字符串数据就封装在这个对象中  

limit/skip 
limit 返回 Stream 的前面 n 个元素；skip 则是跳过前 n 个元素只要后面的元素

```java
List<String> list = Arrays.asList("test","javap","hello","world","java","tom","C","javascript");
list.stream().limit(5).forEach(System.out::println);
list.stream().skip(5).forEach(System.out::println);
```

min/max/distinct

```java
//找出字符文件中字符字符最长的一行
BufferedReader br = new BufferedReader(new FileReader("src/com/briup/test/a.txt"));
int maxLen = br.lines().
	   	mapToInt(String::length).
	   	max().
	   	getAsInt();
 
System.out.println(maxLen);	
```

注意:lines方法把文件中所有行都返回并且转换为一个Stream<String>类型对象,因为每行读出的String类型数据,同时String::length是使用方法引用的特殊方式(因为泛型的缘故),上面的笔记中已经介绍过了,max()方法执行后返回的时候OptionalInt类型对象,所以接着调用了getAsInt方法来获得这次运行结果的int值

```java
//找出全文的单词，转小写，去掉空字符,去除重复单词并排序
BufferedReader br = new BufferedReader(new FileReader("src/com/briup/test4/day17.txt"));
br.lines().
   flatMap(s->Stream.of(s.split(" "))).
   filter(s->s.length()>0).
   map(s->s.toLowerCase()).
   distinct().
   sorted().
   forEach(System.out::println);
```

```java
Stream.generate
通过Supplier接口，可以自己来控制Stream的生成。这种情形通常用于随机数、常量的 Stream，或者需要前后元素间维持着某种状态信息的 Stream。
把 Supplier 实例传递给 Stream.generate() 生成的 Stream，由于它是无限的，在管道中，必须利用limit之类的操作限制Stream大小。可以使用此方式制造出海量的测试数据
public static<T> Stream<T> generate(Supplier<T> s);
例子:
生成100个随机数并由此创建出Stream实例
Stream.generate(()->(int)(Math.random()*100)).limit(100).forEach(System.out::println);
	
Stream.iterate
iterate 跟 reduce 操作很像，接受一个种子值，和一个 UnaryOperator（假设是 f）。
然后种子值成为 Stream 的第一个元素，f(seed) 为第二个，f(f(seed)) 第三个，
	f(f(f(seed))) 第四个,以此类推。
该方法的声明为:
public static<T> Stream<T> iterate(final T seed, final UnaryOperator<T> f)
 
UnaryOperator接口继承了Function接口:
public interface UnaryOperator<T> extends Function<T, T>
例子:
生成一个等差数列
Stream.iterate(0, n -> n + 3).
			limit(10). 
			forEach(x -> System.out.print(x + " "));
打印结果:
0 3 6 9 12 15 18 21 24 27 
```

Collectors 
java.util.stream.Collectors 类的主要作用就是辅助进行各类有用的操作。
例如把Stream转变输出为 Collection，或者把 Stream 元素进行分组。

```java
//把Stream中的元素进行过滤然后再转为List集合
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
List<String> result = list.stream().filter(s->s.length()>4).collect(Collectors.toList());
 
//分组:按照字符串的长度分组
List<String> list = Arrays.asList("test","hello","world","java","tom","C","javascript");
//相同长度的字符串放到一个List集合中作为Map的value,字符串的长度作为Map的Key
Map<Integer, List<String>> collect = list.stream().collect(Collectors.groupingBy(String::length));
//注意下面写法可能写到s->s.length()的时候Eclipse里面有可能不会代码提示，这个要看你先的是=号的哪一边
//最终原因还是泛型的事情
Map<Integer, List<String>> collect = list.stream().collect(Collectors.groupingBy(s->s.length()));
	
//分割:按照字符串是否包含java进行划分  partitioning分割划分的意思
Map<Boolean, List<String>> collect = 
		list.stream().collect(Collectors.partitioningBy(s->s.indexOf("java")!=-1));
for(Boolean b:collect.keySet()){
	System.out.println(b+" : "+collect.get(b).size());
}
```

### 2.11 并行Streams

Stream有串行和并行两种，串行Stream上的操作是在一个线程中依次完成，而并行Stream则是在多个线程上同时执行。

```java
 
	public class LambdaTest12 {
	
		public static void main(String[] args) {
			
			//生成100万个不同的字符串放到集合中
			int max = 1000000;
			List<String> values = new ArrayList<String>(max);
			for (int i = 0; i < max; i++) {
			    UUID uuid = UUID.randomUUID();
			    values.add(uuid.toString());
			}
 
 
			//1纳秒*10^9=1秒 
			long t0 = System.nanoTime();
			//串行stream 
			long count = values.stream().sorted().count();
			//并行stream
			//long count = values.parallelStream().sorted().count();
			long t1 = System.nanoTime();
 
			long time = t1 - t0;
			System.out.println(count);
			System.out.println(time);
		}
		
	}
 
	//结论:对100万个字符串进行排序和计数操作，串行和并行运算的用时差别还是很明显的
```

### 2.12 Map集合

   Map类型不支持stream，不过Map提供了一些新的有用的方法来处理一些日常任务。
   Java8为Map新增的方法：

```java
Object compute(Object key, BiFunction remappingFunction):
该方法使用remappingFunction根据原key-value对计算一个新的value。
只要新的value不为null，就使用新的value覆盖原value；如果新的value为null，则删除原key-value对；
 
Object computeIfAbsent(Object key, Function mappingFunction):
如果传入的key参数在Map中对应的value为null，
该方法将使用mappingFunction根据原key、value计算一个新的结果，则用该计算结果覆盖原value；
如果传入的key参数在Map中对应的value为null，则该方法不做任何事情；如果原Map原来不包括该key，
该方法可能会添加一组key-value对。
 
Object computeIfPresent(Object key, BiFunction remappingFunction):
如果传给该方法的key参数在Map中对应的value不为null，
该方法将使用remappingFunction根据原key、value计算一个新结果，并且该计算结果不为null，
则使用该结果覆盖原来的value；
如果计算结果为null，则删除原key-value对。
 
void forEach(BiConsumer action):
该方法是Java8为Map新增的一个遍历key-value对的方法。
 
Object getOrDefault(Object key, V defaultValue):
获取指定的key对应的value。如果该key不存在，则返回defaultValue。
 
Object merge(Object key, Object value, BiFunction remappingFunction):
该方法会先根据key参数获取该Map中对应的value。如果获取的value为null，
则直接使用传入的value覆盖原value（在这种情况下，可能会添加一组key-value）；
如果获取的value不为null，则使用remappingFunction函数根据原value、新value计算一个新的结果，并用新的结果去覆盖原有的value。
 
Object putIfAbsent(Object key, Object value):
该方法会自动检测指定的key对应的value是否为null，如果该key对应的value为null，则使用传入的新value代替原来的null。
如果该key对应的value不是null，那么该方法不做任何事情。
 
Object replace(Object key, Object value):
将Map中指定key对应的value替换成新value并把被替换掉的旧值返回。
如果key在Map中不存在，该方法不会添加key-value对，而是返回null。
 
Boolean replace(K key, V oldValue, V newValue):
将Map中指定的key-value对的原value替换成新value。
如果在Map中找到指定的key-value对，则执行替换并返回true，否则返回false。
 
replaceAll(BiFunction function):
该方法使用function对原key-value对执行计算，并将计算结果作为key-value对的value值
```





------



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

```
List<String>strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
// 获取空字符串的数量
int count = strings.stream().filter(string -> !string.isEmpty()).count();//留下非空的字符串对象，去除不符合的
limit
limit 方法用于获取指定数量的流。 以下代码片段使用 limit 方法打印出 10 条数据：

Random random = new Random();
random.ints().limit(10).forEach(System.out::println);
```

**sorted(): 用于对流进行排序。以下代码片段使用 sorted 方法对输出的 10 个随机数进行排序：**

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

![在这里插入图片描述](E:/%E5%AD%A6%E4%B9%A0/JAVA/Java%E5%9F%BA%E7%A1%80/%E6%96%B0%E7%89%B9%E6%80%A7/Lambda 表达式.assets/20210601112556711.png)



------



# [Stream系列（七）distinct方法使用][https://blog.csdn.net/wenhaipan/article/details/103323852]

![img](E:\学习\JAVA\Java基础\新特性\Lambda 表达式.assets/20191130135635858.png)

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





# [lambda的peek，filter，map，collect函数使用](https://blog.csdn.net/XiaoHanZuoFengZhou/article/details/79915724)

```java
@RequestMapping(value = "/list.json", method = GET)
public void list(ModelMap modelMap, String taskId, Integer currentPage, Integer pageSize) {
    Pagination pagination = Pagination.builder().current(currentPage).pageSize(pageSize).build();
    if (StringUtils.isNotBlank(taskId)) {
        return;
    }
    Map<Long, TaskBO> taskMap = Maps.newHashMap();
    Pager<RecordBO> boPager = recordManager.findRecordList(taskId, pagination);
    modelMap.addAttribute(KEY_DATA, new Pager<>(pagination,
            boPager.getList()
                    .stream()
                    .peek(recordBO -> {
                        if (!taskMap.containsKey(recordBO.getTaskId())) {
                            Optional<TaskBO> optionalTaskBO = taskManager.get(recordBO.getTaskId());
                            optionalTaskBO.ifPresent(taskBO -> taskMap.put(recordBO.getTaskId(), taskBO));
                        }
 
                    })
                    .filter(recordBO -> taskMap.containsKey(recordBO.getTaskId()))
                    .map(recordBO -> {
                        TaskBO taskBO = taskMap.get(recordBO.getTaskId());
                        return RecordVO.read4BO(recordBO, taskBO.getId() + ": " + taskBO.getName());
                    })
                    .collect(Collectors.toList())));
}
```

1、distinct: 对于Stream中包含的元素进行去重操作（去重逻辑依赖元素的equals方法），新生成的Stream中没有重复的元素；

distinct方法示意图(**以下所有的示意图都要感谢[RxJava](https://github.com/Netflix/RxJava)项目的doc中的图片给予的灵感,**)：

![img](https://img-blog.csdnimg.cn/20181221161438313)

2、filter: 对于Stream中包含的元素使用给定的过滤函数进行过滤操作，新生成的Stream只包含符合条件的元素；

filter方法示意图：

![img](https://img-blog.csdnimg.cn/20181221161438349)

3、map: 对于Stream中包含的元素使用给定的转换函数进行转换操作，新生成的Stream只包含转换生成的元素。这个方法有三个对于原始类型的变种方法，分别是：mapToInt，mapToLong和mapToDouble。这三个方法也比较好理解，比如mapToInt就是把原始Stream转换成一个新的Stream，这个新生成的Stream中的元素都是int类型。之所以会有这样三个变种方法，可以免除自动装箱/拆箱的额外消耗；

map方法示意图：

4、flatMap：和map类似，不同的是其每个元素转换得到的是Stream对象，会把子Stream中的元素压缩到父集合中；

flatMap方法示意图：

![img](https://img-blog.csdnimg.cn/20181221161438368)

5、peek: 生成一个包含原Stream的所有元素的新Stream，同时会提供一个消费函数（Consumer实例），新Stream每个元素被消费的时候都会执行给定的消费函数；

- `peek` **返回值是和之前流泛型相同的流, 多用于打印中间操作时元素数据，后面可继续操作流**
- `forEach` **没有返回值, 无法继续使用点语法操作，后面无法再继续操作流**

peek方法示意图：

![img](https://img-blog.csdnimg.cn/20181221161438385)

6、limit: 对一个Stream进行截断操作，获取其前N个元素，如果原Stream中包含的元素个数小于N，那就获取其所有的元素；

limit方法示意图：

![img](https://img-blog.csdnimg.cn/20181221161438401)

7、skip: 返回一个丢弃原Stream的前N个元素后剩下元素组成的新Stream，如果原Stream中包含的元素个数小于N，那么返回空Stream；

skip方法示意图：

![img](https://img-blog.csdnimg.cn/20181221161438420)

8、实践

```java
	List<Integer> nums = Lists.newArrayList(1,1,null,2,3,4,null,5,6,7,8,9,10);
	System.out.println(“sum is:”+nums.stream().filter(num -> num != null)
	            .distinct().mapToInt(num -> num * 2)
	            .peek(System.out::println).skip(2).limit(4).sum());
```


这段代码演示了上面介绍的所有转换方法（除了flatMap），简单解释一下这段代码的含义：给定一个Integer类型的List，获取其对应的Stream对象，然后进行过滤掉null，再去重，再每个元素乘以2，再每个元素被消费的时候打印自身，在跳过前两个元素，最后去前四个元素进行加和运算(解释一大堆，很像废话，因为基本看了方法名就知道要做什么了。这个就是声明式编程的一大好处！)。大家可以参考上面对于每个方法的解释，看看最终的输出是什么。

9、性能问题
有些细心的同学可能会有这样的疑问：在对于一个Stream进行多次转换操作，每次都对Stream的每个元素进行转换，而且是执行多次，这样时间复杂度就是一个for循环里把所有操作都做掉的N（转换的次数）倍啊。其实不是这样的，转换操作都是lazy的，多个转换操作只会在汇聚操作（见下节）的时候融合起来，一次循环完成。我们可以这样简单的理解，Stream里有个操作函数的集合，每次转换操作就是把转换函数放入这个集合中，在汇聚操作的时候循环Stream对应的集合，然后对每个元素执行所有的函数。

## 关于lambda:map和peek区别

1.Stream<T> peek(Consumer<? super T> action);

peek办法接管一个Consumer的入参。理解λ表达式的应该明确 **Consumer的实现类 应该只有一个办法，该办法返回类型为void，peek方法本身有返回，返回的是每个元素经过Consumer方法处理之后的每个元素**

```
Consumer<Integer> c =  i -> System.out.println("hello" + i);
```

2.<R> Stream<R> map(Function<? super T, ? extends R> mapper);

Function 的 λ表达式 能够这样写

```
Function<Integer,String> f = x -> {return  "hello" + i;};
```

**咱们发现Function 比 Consumer 多了一个 return。**
这也就是peek 与 map的区别了。

总结：peek接管一个没有返回值的λ表达式，能够做一些输入，内部解决等。map接管一个有返回值的λ表达式，之后Stream的泛型类型将转换为map参数λ表达式返回的类型



# [java8的lambda中的map相关操作](https://blog.csdn.net/wabiaozia/article/details/84262195)

## 1 以下是正文

英文地址：<https://www.baeldung.com/java-merge-maps>

原文链接：<https://blog.csdn.net/w605283073/article/details/82987157>

**1. 介绍**

本入门教程将介绍Java8中如何合并两个map。如果想学习入门教程点击开篇0入门篇：[lambda表达式:list转map](https://blog.csdn.net/wabiaozia/article/details/103321752)

更具体说来，我们将研究不同的合并方案，包括Map含有重复元素的情况。

## **2. 初始化**

我们定义两个map实例

```typescript
private static Map<String, Employee> map1 = new HashMap<>();
 
private static Map<String, Employee> map2 = new HashMap<>();
```

*Employee类*

```kotlin
public class Employee {
 
 
private Long id;
 
private String name;
 
 
// 此处省略构造方法, getters, setters方法
 
}
```

然后往map中存入一些数据

```java
Employee employee1 = new Employee(1L, "Henry");
 
map1.put(employee1.getName(), employee1);
 
Employee employee2 = new Employee(22L, "Annie");
 
map1.put(employee2.getName(), employee2);
 
Employee employee3 = new Employee(8L, "John");
 
map1.put(employee3.getName(), employee3);
 
 
Employee employee4 = new Employee(2L, "George");
 
map2.put(employee4.getName(), employee4);
 
Employee employee5 = new Employee(3L, "Henry");
 
map2.put(employee5.getName(), employee5);
```

特别需要注意的是*employee1* 和 *employee5在map中有完全相同的key（name）。*

## **3. Map.merge()**

Java8为 **java.util.Map接口新增了merge()函数。**

 *merge()*  函数的作用是: 如果给定的key之前没设置value 或者value为null, 则将给定的value关联到这个key上.

否则，通过给定的remaping函数计算的结果来替换其value。如果remapping函数的计算结果为null，将解除此结果。

First, let’s construct a new *HashMap* by copying all the entries from the *map1*:

首先，我们通过拷贝map1中的元素来构造一个新的*HashMap*

```typescript
Map<String, Employee> map3 = new HashMap<>(map1);
```

然后引入merge函数和合并规则

```java
map3.merge(key, value, (oldMap, newMap) -> new Employee(oldMap.getId(),newMap.getName())
```

最后对map2进行迭代将其元素合并到map3中

```java
map2.forEach(
(key, value) -> map3.merge(key, value, (oldMap, newMap) -> new Employee(oldMap.getId(),newMap.getName())));
```

运行程序并打印结果如下：

```java
John=Employee{id=8, name='John'}
 
Annie=Employee{id=22, name='Annie'}
 
George=Employee{id=2, name='George'}
 
Henry=Employee{id=1, name='Henry'}
```

最终，通过结果可以看出，实现了两个map的合并，对重复的key也合并为同一个元素。

**注意最后一个*Employee*的id来自map1而name来自map2.**

原因是我们的merge函数的定义

```scss
(v1, v2) -> new Employee(v1.getId(), v2.getName())
```

## **4. Stream.concat()**

*Java8的Stream* API 也为解决该问题提供了较好的解决方案。

首先需要将两个map合为一个**Stream。**

```java
Stream combined = Stream.concat(map1.entrySet().stream(), map2.entrySet().stream());
```

我们需要将entry sets作为参数，然后利用*Collectors.toMap()*:将结果放到新的map中。

```typescript
Map<String, Employee> result = combined.collect(
 
Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
```

该方法可以实现map的合并，但是有重复key会报*IllegalStateException异常。*

为了解决这个问题，我们需要加入[lambda](https://so.csdn.net/so/search?q=lambda&spm=1001.2101.3001.7020)表达式**merger作为第三个参数**

```scss
(value1, value2) -> new Employee(value2.getId(), value1.getName())
```

当检测到有重复Key时就会用到该lambda表达式。

现在把上面代码组合在一起：

```java
Map<String, Employee> result = Stream.concat(map1.entrySet().stream(), map2.entrySet().stream())
.collect(Collectors.toMap(
Map.Entry::getKey,
Map.Entry::getValue,
(value1, value2) -> new Employee(value2.getId(), value1.getName())));
```

最终的结果

```bash
George=Employee{id=2, name='George'}
 
John=Employee{id=8, name='John'}
 
Annie=Employee{id=22, name='Annie'}
 
Henry=Employee{id=3, name='Henry'}
```

从结果可以看出重复的key *“**Henry**”将合并为一个新的键值对，**id取自map2，name取自map1。***



## *5. Stream.of()*

通过Stream.of()方法不需要借助其他stream就可以实现map的合并。

```coffeescript
Map<String, Employee> map3 = Stream.of(map1, map2)
 
.flatMap(map -> map.entrySet().stream())
 
.collect(Collectors.toMap(
 
Map.Entry::getKey,
 
Map.Entry::getValue,
 
(v1, v2) -> new Employee(v1.getId(), v2.getName())));
```

首先将map1和map2的元素合并为同一个流，然后再转成map。通过使用v1的id和v2的name来解决重复key的问题。

map3的运行打印结果如下：

## *6. Simple Streaming*

我们还可以借助stream的管道操作来实现map合并。

```coffeescript
Map<String, Employee> map3 = map2.entrySet()
 
.stream()
 
.collect(Collectors.toMap(
 
Map.Entry::getKey,
 
Map.Entry::getValue,
 
(v1, v2) -> new Employee(v1.getId(), v2.getName()),
 
() -> new HashMap<>(map1)));
```

结果如下：

```bash
{John=Employee{id=8, name='John'},
 
Annie=Employee{id=22, name='Annie'},
 
George=Employee{id=2, name='George'},
 
Henry=Employee{id=1, name='Henry'}}
```

## *7. StreamEx*

我们还可以使**Stream API** 的增强库

```coffeescript
Map<String, Employee> map3 = EntryStream.of(map1)
 
.append(EntryStream.of(map2))
 
.toMap((e1, e2) -> e1);
```

注意 *(e1, e2) -> e1* 表达式来处理重复key的问题，如果没有该表达式依然会报*IllegalStateException异常。*

结果：

```bash
{George=Employee{id=2, name='George'},
 
John=Employee{id=8, name='John'},
 
Annie=Employee{id=22, name='Annie'},
 
Henry=Employee{id=1, name='Henry'}}
```

8 总结

**本文使用了Map.merge(), Stream API, StreamEx 库实现map的合并。**

本文源码：<https://github.com/eugenp/tutorials/tree/master/core-java-collections>

## 二：Java8使List转为Map

<https://blog.csdn.net/hanerer1314/article/details/78826068>

```java
import com.yang.test.User;
 
import javax.jws.soap.SOAPBinding;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;
 
public class Main {
 
    public static void main(String[] args) {
 
        List<User> userlist = new ArrayList<>();
        for (int i = 0; i <10; i++) {
 
            userlist.add(new User("张三"+i,i));
        }
        System.out.println(getAllages(userlist).size());
 
        System.out.println(getUser2Map(userlist));
 
        System.out.println(getUser2MapUser(userlist));
 
        System.out.println(getUser2MapUser2(userlist));
 
          System.out.println(getUser2MapUser3(userlist));
 
    }
 
    public static List<Integer> getAllages(List<User>userlist){
        return  userlist.stream().map(user -> user.getAge()).collect(Collectors.toList());
    }
 
    public static Map<Integer,String> getUser2Map(List<User>userlist){
 
        return userlist.stream().collect(Collectors.toMap(User::getAge,User::getName));
    }
 
    public static Map<Integer,User> getUser2MapUser(List<User>userlist){
 
        return userlist.stream().collect(Collectors.toMap(User::getAge,User-> User));
    }
 
    /**
     * 比较优雅的写法是这样的
     * @param userlist
     * @return
     */
    public static Map<Integer,User> getUser2MapUser2(List<User>userlist){
 
        return userlist.stream().collect(Collectors.toMap(User::getAge, Function.identity()));
    }
 
    /**
     * 重复key的情况下 简单的使用后者覆盖前者的
     */
    public static Map<Integer,User> getUser2MapUser3(List<User>userlist){
 
        return userlist.stream().collect(Collectors.toMap(User::getAge, Function.identity(),(key1,key2)->key2));
    }
 
    /**
     *指定map的具体实现
     * @param userlist
     * @return
     */
    public static Map<Integer,User> getUser2MapUser4(List<User>userlist){
 
        return userlist.stream().collect(Collectors.toMap(User::getAge, Function.identity(),(key1,key2)->key2, LinkedHashMap::new));
    }
}
```

## java将Map转换为List

```java
//map的所有value转换为List
List<BlogComment> blogCommentListResult = new ArrayList<>(blogCommentMap.values());
//map的所有key转为List
List<BlogComment> blogCommentListResult = new ArrayList<>(blogCommentMap.KeySet());
```

Map数据转换为自定义对象的List，例如把map的key,value分别对应Person对象两个属性：（不同排序）

```java
List<Person> list = map.entrySet().stream().sorted(Comparator.comparing(e -> e.getKey()))
		.map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());

List<Person> list = map.entrySet().stream().sorted(Comparator.comparing(Map.Entry::getValue))
		.map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());

List<Person> list = map.entrySet().stream().sorted(Map.Entry.comparingByKey())
	.map(e -> new Person(e.getKey(), e.getValue())).collect(Collectors.toList());
```



# [使用flatMap](https://blog.csdn.net/qq_24184997/article/details/88116471)

1、什么情况下用到flatMap
当使用map（）操作时，不是返回一个值，而是返回一个集合或者一个数组的时候，这时候就可以使用flatMap解决这个问题。举个例子，你有一个列表 [21,23,42]，然后你调用getPrimeFactors()方法map操作 使数组转化成stream。
上述结果[[3,7],[23],[2,3,7]]，这个类型Stream<String[]> 使用 stream 操作（filter，sum，distinct …）和 collectors 都不支持这种类型。如果你想把Stream of Stream转换为值列表，使用 flatMap() 方法 重新生成一个Stream对象，最后可以得到 [3,7,2,3,2,3,7]

2、flatMap如何工作的
通过下面的图，我们就很容易理解flatmap在java8 中是如何工作的

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190304131022877.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzI0MTg0OTk3,size_16,color_FFFFFF,t_70)

使用红色标记的列表和绿色标记的列表，经过flatmap方法后在第二个管道中把把上述两个列表的数据合并成一个列表数据

3、flatmap 使用例子

```java
		List<List<Integer>> lists = new ArrayList<>();
        List<Integer> list = new ArrayList<>();
        list.add(4444);
        list.add(33333);
        list.add(444444);
        lists.add(list);
        lists.stream().flatMap(Collection::stream).forEach(System.out::println);
```

由于上述 lists.stream() 后返回的是stream<list> 所以需要使用flatMap 进行合并

4、总结
本文主要通过为啥使用 flatmap，如何使用flatmap 这两点讲述了flatmap方法，下一章节我们来讲一个map & flatmap。

参考文档
[How to use flatMap() in Java 8](http://www.java67.com/2016/03/how-to-use-flatmap-in-java-8-stream.html)
[Java 8 flatMap示例](https://www.mkyong.com/java8/java-8-flatmap-example/)

实例：

```java
public class Test { 
public static void main(String args[]) {

List<String> teamIndia = Arrays.asList("Virat", "Dhoni", "Jadeja"); 
List<String> teamAustralia = Arrays.asList("Warner", "Watson", "Smith");
List<String> teamEngland = Arrays.asList("Alex", "Bell", "Broad"); 
List<String> teamNewZeland = Arrays.asList("Kane", "Nathan", "Vettori"); 
List<String> teamSouthAfrica = Arrays.asList("AB", "Amla", "Faf"); 
List<String> teamWestIndies = Arrays.asList("Sammy", "Gayle", "Narine"); 
List<String> teamSriLanka = Arrays.asList("Mahela", "Sanga", "Dilshan"); 
List<String> teamPakistan = Arrays.asList("Misbah", "Afridi", "Shehzad");

List<List<String>> playersInWorldCup2016 = new ArrayList<>(); playersInWorldCup2016.add(teamIndia); 
playersInWorldCup2016.add(teamAustralia);
playersInWorldCup2016.add(teamEngland); 
playersInWorldCup2016.add(teamNewZeland); 
playersInWorldCup2016.add(teamSouthAfrica); 
playersInWorldCup2016.add(teamWestIndies); 
playersInWorldCup2016.add(teamSriLanka); 
playersInWorldCup2016.add(teamPakistan);

// Let's print all players before Java 8 List<String> 
listOfAllPlayers = new ArrayList<>();

for(List<String> team : playersInWorldCup2016){ 
for(String name : team){ 
listOfAllPlayers.add(name); 
} }

System.out.println("Players playing in world cup 2016");
        System.out.println(listOfAllPlayers);
        
        // Now let's do this in Java 8 using FlatMap 
    List<String> flatMapList = playersInWorldCup2016 .stream() .flatMap(pList -> pList.stream()) .collect(Collectors.toList()); 
    System.out.println("List of all Players using Java 8"); 		    System.out.println(flatMapList); } }


```



   map的作用很容易理解就是对rdd之中的元素进行逐一进行函数操作映射为另外一个rdd。

   flatMap的操作是将函数应用于rdd之中的每一个元素，将返回的迭代器的所有内容构成新的rdd。通常用来切分单词。

Spark 中 map函数会对每一条输入进行指定的操作，然后为每一条输入返回一个对象。 而flatMap函数则是两个操作的集合——正是“先映射后扁平化”：

操作1：同map函数一样：对每一条输入进行指定的操作，然后为每一条输入返回一个对象

操作2：最后将所有对象合并为一个对象

```java
object fla_map {
 def main(args: Array[String]): Unit = {
    val rdd1= List(List("A","B"),List("C","D"))

    rdd1.map( i => println(i))
    println(rdd1)
    println("----------------------")
    val strings = rdd1.flatMap(f => f)
    println(strings)
    strings.foreach( i => println(i))
  }
}
```

打印：

```
List(A,B)
List(C,D)
List(List(A,B),List(C,D))
---------------------------
List(A,B,C,D)
A
B
C
D
```

map：List里有小的List
flatmap：是先flat再map，只能压一次，形成一个新的List[集合](https://so.csdn.net/so/search?q=集合&spm=1001.2101.3001.7020)，把原元素放进新的集合里面



# 详解Map.merge()

在JDK的[API](https://so.csdn.net/so/search?q=API&spm=1001.2101.3001.7020)中，这样的一个方法它是很特别的，它很新颖，它是值得我们花时间去了解的，同时也推荐你可以运用到实际的项目代码中，对你们应该帮助很大。[Map.merge（）](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.oracle.com%2Fen%2Fjava%2Fjavase%2F11%2Fdocs%2Fapi%2Fjava.base%2Fjava%2Futil%2FMap.html%23merge(K%2CV%2Cjava.util.function.BiFunction))。这可能是Map中最通用的操作。但它也相当模糊，几乎很少人会去使用它。

## 背景介绍

`merge()`可以解释如下：它将新的值赋值给到key中（如果不存在）或更新具有给定值的现有key（UPSERT）。让我们从最基本的例子开始：计算唯一的单词出现次数。在java8之前的时候，代码非常混乱，实际的实现其实已经失去了本质层面的设计意义。

```go
var map = new HashMap<String, Integer>();
words.forEach(word -> {
    var prev = map.get(word);
    if (prev == null) {
        map.put(word, 1);
    } else {
        map.put(word, prev + 1);
    }
});
 
```

按照上述代码的逻辑，假设给定一个输入集合，输出的结果如下；

```typescript
var words = List.of("Foo", "Bar", "Foo", "Buzz", "Foo", "Buzz", "Fizz", "Fizz");
//...
{Bar=1, Fizz=2, Foo=3, Buzz=2}
```

## 改进V1

现在让我们来重构它，主要去掉它的一些判断逻辑；

```go
words.forEach(word -> {
    map.putIfAbsent(word, 0);
    map.put(word, map.get(word) + 1);
});
```

这样的改进，是可以满足我们的重构要求。putIfAbsent()的具体用法就不过多描述。`putIfAbsent`那一行代码是一定需要的，否则，后面的逻辑也就会报错。而在下面代码中，又出现了`put`、`get`这一点会很奇怪，让我们再继续的进行改进设计。

### 改进V2

```java
words.forEach(word -> {
    map.putIfAbsent(word, 0);
    map.computeIfPresent(word, (w, prev) -> prev + 1);
});
```

`computeIfPresent`是仅当 `word`中的的key存在的时候才调用给定的转换。否则它什么都不处理。我们通过将key初始化为零来确保key存在，因此增量始终有效。这样的实现是不是已经足够完美？未必，还有其他的思路可以减少额外的初始化。

```coffeescript
words.forEach(word ->
        map.compute(word, (w, prev) -> prev != null ? prev + 1 : 1)
);
```

`compute ()`就像是`computeIfPresent()`，但无论给定key的存在与否如何都会调用它。如果key的值不存在，则prev参数为null。将简单移动if 到隐藏在lambda中的三元表达式也远远没有达到最佳的表现。在我向你展示最终版本之前，让我们看一下稍微简化的默认实现`Map.merge()`源码分析。

## 改进V3

> merge()源码

```java
default V merge(K key, V value, BiFunction<V, V, V> remappingFunction) {
    V oldValue = get(key);
    V newValue = (oldValue == null) ? value :
               remappingFunction.apply(oldValue, value);
    if (newValue == null) {
        remove(key);
    } else {
        put(key, newValue);
    }
    return newValue;
}
```

代码片段胜过千言万语。 阅读源码总是能够发现新大陆，`merge()` 适用于两种情况**==。如果给定的key不存在，它就变成了put(key, value)。但是，如果key已经存在一些值，则执行remappingFunction（前一个是旧值，后一个是新值，执行某个函数），我们 remappingFunction 可以选择合并的方式。==**这个功能是完美契机上面的场景：

- 只需返回新值即可覆盖旧值： `(old, new) -> new`
- 只需返回旧值即可保留旧值：`(old, new) -> old`
- 以某种方式合并两者，例如：`(old, new) -> old + new`
- 甚至删除旧值：`(old, new) -> null`

如你所见，它 merge() 是非常通用的。那么，我们的问题该如何使用`merge()`呢？代码如下：

```java
 words.forEach(word ->
        map.merge(word, 1, (prev, one) -> prev + one)
);
```

你可以按照如下思路理解：如果没有key，那么初始化的value等于1；否则，将1添加到现有值。代码中的 `one` 是一个常量，因为我们的场景中，默认一直是加1，具体变化可以随意切换。

## 场景

> 想象一下，`merge()`真的那么好用吗？它的场景可以有什么？

举一个例子。你有一个帐户操作类

```kotlin
class Operation {
    private final String accNo;
    private final BigDecimal amount;
}
```

以及针对不同帐户的一系列操作：

```php
 operations = List.of(
    new Operation("123", new BigDecimal("10")),
    new Operation("456", new BigDecimal("1200")),
    new Operation("123", new BigDecimal("-4")),
    new Operation("123", new BigDecimal("8")),
    new Operation("456", new BigDecimal("800")),
    new Operation("456", new BigDecimal("-1500")),
    new Operation("123", new BigDecimal("2")),
    new Operation("123", new BigDecimal("-6.5")),
    new Operation("456", new BigDecimal("-600"))
);
```

我们希望为每个帐户计算余额（总运营金额）。假如不用`merge()`，就变得非常麻烦了：

```java
 Map balances = new HashMap<String, BigDecimal>();
operations.forEach(op -> {
    var key = op.getAccNo();
    balances.putIfAbsent(key, BigDecimal.ZERO);
    balances.computeIfPresent(key, (accNo, prev) -> prev.add(op.getAmount()));
});
```

使用`merge`之后的代码

```java
operations.forEach(op ->
        balances.merge(op.getAccNo(), op.getAmount(), 
                (soFar, amount) -> soFar.add(amount))
);
```

再进行优化的逻辑。

```less
operations.forEach(op ->
        balances.merge(op.getAccNo(), op.getAmount(), BigDecimal::add)
);
```

当然结果是正确的，这样简洁的代码心动吗？对于每个操作，`add`在给定的`amount`给定`accNo`。

```undefined
{ 123 = 9.5，456 = - 100 }
```

### ConcurrentHashMap

当我们再延伸到`ConcurrentHashMap`来，当 `Map.merge`的出现，和`ConcurrentHashMap`的结合那是非常的完美的。这样的搭配场景是对于那些自动执行插入或者更新操作的单线程安全的逻辑。