# 从JVM内存机制理解 java 的继承 重写 多态 构造 以及this关键字和super关键字


Java的对象是在堆空间中分配一块内存空间,对于继承来说，子类拥有父类所有权限范围内的属性和方法，但是实质上子类在分配空间时，其内存中已经分配了父类所有方法和属性的内存，包括了private在内。在内存上 子类的内存分配如下图

可以看作

 子类的内存空间=父类的内存空间 +子类自己独特的内存空间

 

![img](https://img-blog.csdn.net/20180804000746772?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1NTg5MDgw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

然后来看一下this关键字和super关键字

this 关键字依靠对象而存在，它代表了对象，指向堆空间中对象的地址。

所以我们能用this来调用对象的成员方法和成员属性。也可以使用this来实现构造方法的互相调用。

之前一直以为super关键字是父类的对象。在子类中我们使用super来构造父类，我们使用super来调用父类的成员属性和成员方法。

但是我们使用getClass方法来获取super和this的类你就会发现

this.getClass()==super.getClass();

原来super和this都是子类的对象。那之前所认为的super调用父类的构造和super调用父类的属性和方法都是一种假象。

 

那super到底是什么呢，super是子类的对象，不过他管理的地方没有this的大，ta只负责子类对象内存中从父类继承而来的那一部分。

可以理解为 super是被强制类型转换为父类型的this

 

古时候，一个诸侯被分封在一个小国家当王，后来他大儿子继承了王位之后，吞并了周边几个国家，大儿子于是把父亲原来的封地分封给弟弟，让弟弟去管理父亲原来的封地。

this和super的关系就类似于此。

 

所以，在子类构造的时候会默认调用super来初始化父类，其实是初始化的是子类对象中来自父类的那部分属性和方法。说到底，子类始终自能构造自己的东西，父类的东西还是要super去构造。

楼下一家月饼店做的月饼很好买，后来他们又加了一个月饼包装流程，成了一家盒装月饼店，可说到底，月饼还得在厨房做出来不是吗。

 

我们在来看看子类重写父类的方法。子类重写父类的方法实质是什么？他是在父类方法的基础上添加自己的东西吗?其实不是，他是在内存中开辟了一块新的空间，重写的方法实质上相当于子类自己的新的东西。

如果是子类重写了父类的cry()方法，其实在子类对象的内存中，有父类cry方法的空间，

也有子类cry方法的空间，只是对于子类来说，父类cry（）方法被隐藏了。子类现在只能使用自己的cry（）方法了。

 

你老师之前交你学习写web前端，后来你想学java，然后就把web前端的技能送给了你同学，从此就不会写web前端了，然后有一天你想写一个网站，没办法，你只能找你同学来帮你写前端。

所以我们有了新的方法父类的方法就会隐藏起来

重写的过程是JVM在编译时执行，会覆盖掉父类的方法

 

![img](https://img-blog.csdn.net/20180804000749530?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1NTg5MDgw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

 

![img](https://img-blog.csdn.net/20180804000752592?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1NTg5MDgw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

 

![img](https://img-blog.csdn.net/20180804000750801?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1NTg5MDgw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)![img](https://img-blog.csdn.net/20180804000748287?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1NTg5MDgw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

 

 然后我们来看向上造型

![img](https://img-blog.csdn.net/20180804000752891?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1NTg5MDgw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

上面程序输出的结果都是Sun类

 

故而在向上造型时，我们只能使用对象中继承于父类的部分

 

最后来说说我对java多态的理解，java中多态基于继承，重写，向上造型。

我们用多个子类型的共同父类的引用来指向子类型们的对象地址。**基于向上造型来说，这些引用可以访问子类中来自父类的属性和方法。基于重写，这些引用去访问被重写的方法时，它们只能访问到子类重写的方法和属性。因为它们指向子类对象的内存，在子类对象内存里，来自父类的的方法已经被隐藏了，只能通过super关键字去访问。**

---



# Java中继承机制以及父类引用指向子类对象的一些问题(多态)

码农麒麟 2019-06-11 20:01:00  406  收藏 3
分类专栏： Java 文章标签： 继承 Java 多态 构造方法 构造器
版权
本篇文章是面向初学者的,本人在项目中遇到了这一part的部分,于是去查书看博,总结了一下,放到该篇博客中.

本篇面向对Java有一定了解的群众,扫盲的就可以把我跳过了QaQ.

目录

一、概念介绍

二、继承类对象的存储

三、继承中的构造方法

四、父类对象强转子类导致异常

一、概念介绍
首先介绍一下继承的概念,继承在写Java实体类的时候可以避免重复的定义域(即类的属性),比如Person和Student,每一个学生都是一个人,所以他们之间存在继承关系,继承最简单的判断方式就是"is a",Student is a Person,所以Student继承自Person,但Person不一定是Student,所以Person是父类,Student是子类.

Person.java

public class Person{

    private String name;    //姓名
    private int age;        //年龄
    private int sex;        //性别
     
    public Person(){
        
    }
    public String getName() {    return name;    }
    public void setName(String name) {    this.name = name;    }
    
    public int getAge() {    return age;    }
    public void setAge(int age) {    this.age = age;    }
    
    public int getSex() {    return sex;    }
    public void setSex(int sex) {    this.sex = sex;    }
    
    public void run(){    System.out.println("Peoson run");    }
}
在Person类中定义了三个实例域,name、age和sex,并且定义了他们的set和get方法,为了区分Person类和Student类以及实现重写,我在Person类中定义了run()方法,后续再Student中会重写该方法.

 

Student.java

public class Stuent extends{
    private String stuNum;    //学号
    private String school;    //学校

    public Student(){
     
    }
    public String getStudentNum() {    return studentNum;    }
    public void setStudentNum(String studentNum) {    this.studentNum = studentNum;    }
    
    public String getSchool() {    return school;    }
    public void setSchool(String school) {    this.school = school;    }
    
    @Override
    public void run(){    System.out.println("Student run");    }
}
在Student类中有学号和学校两个实体域以及他们的get和set方法,在Student中重写了父类的run方法.接下来我们进行测试.

Test.java

public class Test{
    public static void main(String[] args){
        People p = new People();
        Student s = new Student();
        p.run();
        s.run();
        p = s;
        p.run();
    }
}
一个最简单的继承就完成了,在Test中我创建了一个People对象和一个Student对象,并且分别调用了他们的run方法,但是后来我把Studednt对象的引用赋值给了Person的引用,那么调用p.run()会输出的是哪个类的run()方法呢?

很显然,结果显示p对象调用了Student的run方法,其实这就是一种多态.多态的定义就是:一个对象变量可以指示多种时机类型的现象.

二、继承类对象的存储
在上面的例子中,调用p.run()却执行了在Student中定义的run方法,那么内存中对该对象的存储又是怎样的呢?



在JVM中,对有继承的类,会先加载它的父类,再加载它本身,这可以看作一个Student类中在存有Person的所有实体域的基础上,自己新增加了stuNum和school.当一个Person对象指向它时,只能够访问其中的Person本有的方法与实体域.这一点在逻辑上也是较易理解的,Person既然不是学生又怎么能让他访问Student中私有的东西呢?

但是对于子类和父类中都有的方法,run()来说,就不太一样了,具体分析如下:

在JVM中,对象实例存在堆中,但是该对象的引用存在栈中.

Student s的实例方法存在一个专门的区叫方法区,B中所有的方法在创建B实例的时候Student类的class方法二进制字节码就已经加载到了方法区，所有此类的方法调用的类对象均可以共享此代码空间，常量池会存放在堆里，当调用Student中的方法的时候，先从方法区通过方法表快速拿到调用方法的字节码指令入栈并创建栈帧。对于s.run()，实际上在创建Student对象的堆空间的时候，声明在栈里的s引用指向了B对象的内存空间首地址，所以在调用run方法的时候会去这个对象空间找对应的方法字节码，所以最终执行的是Student中的run方法。

对于重写可以参照以下图示:





super代表父类(Person)对象,this代表当前对象(Student).

参考链接:https://blog.csdn.net/qq_35589080/article/details/81396331.

三、继承中的构造方法
废话不多说,先把Student和Person的构造方法代码贴上去.

Person类的构造方法:

public Person(){

}
public Person(String name, int age, int sex){
    this.name = name;
    this.age = age;
    this.sex = sex;
}
          Student类的构造方法:

public Student(String studentNum, String school,String name,int age,int sex) {
    super(name,age,sex);
    this.studentNum = studentNum;
    this.school = school;
}
public Student(){

}
因为在Person类中,我将所有的实体域设置成了private,所以在子类中不能够直接访问,但是可以通过set和get方法获取,为了在构造方法中初始化Student类的name等属性,通过super(name,age,sex)调用父类的构造方法实现对Person私有域的初始化.

需要注意的是,利用super调用父类的构造方法必须放在构造方法中的第一句,这一点与通过this()调用自身的构造方法是一致的.

可能大家已经注意到了,我在代码中对于空参的构造方法,什么东西也没有写,我是不是有病 - -.其实不然,如果你用Eclipse或IDEA编写的话,假如你忘了在子类对象中显式的调用父类的构造方法就会有错误(把Person中的无参构造器删除).



???为什么会报错呢?其实这是因为Java自身的机制,如果说子类的构造器没有显式的调用父类的构造器,则将自动调用超类(没有参数)默认的构造器.所以我在子类中定义的Student()构造器既然没有用super调用父类的构造器,那么Java就会自动替我调用父类的空参构造器,但是因为我在父类中定义了有参数的构造器,所以Java不会自动的替我生成Person类的空参构造器.

四、父类对象强转子类导致异常
上面我们举例的是一个子类对象被父类引用,那么如果一个父类对象强转子类对象又会怎么样呢?



强转的操作行不通啊,在运行时直接触发了ClassCastException,这是为什么呢?

对于一个Person类对象来说,它在内存上只有三个实例域,不具有Student中的两条实例域;从设计者的角度来考虑的话,如果允许这样的转换,让一个Student引用一个Person对象,相当于本来不是学生的人摇身一变成了学生,这显然是不能被允许的,即使是伟大的古娜拉黑暗之神,也做不到吧.