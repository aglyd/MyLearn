# [java泛型中< ? >和< T >有什么区别？](https://www.cnblogs.com/jpfss/p/9929045.html)

**T 代表一种类型**

加在类上:class SuperClass<A>{}

加在方法上:

**public** <T>**void** fromArrayToCollection(T[] a, Collection<T> c){}

方法上的<T>代表括号里面要用到泛型参数，若类中传了泛型，此处可以不传，调用类型上面的泛型参数，前提是方法中使用的泛型与类中传来的泛型一致。

**class People<T>{**

**public** **void** show(T a) {

  }

}

T extends T2 指传的参数为T2或者T2的子类型。

 

**?是通配符,泛指所有类型**

一般用于定义一个引用变量,这么做的好处是,如下所示,定义一个sup的引用变量，就可以指向多个对象。

SuperClass<?> sup = new SuperClass<String>("lisi");

sup = new SuperClass<People>(new People());

sup = new SuperClass<Animal>(new Animal());

若不用?,用固定的类型的话，则：

SuperClass<String> sup1 = new SuperClass<String>("lisi");

SuperClass<People> sup2 = new SuperClass<People>("lisi");

SuperClass<Animal> sup3 = new SuperClass<Animal>("lisi");

这就是?通配符的好处。

 

? extends T 指T类型或T的子类型

? super T  指T类型或T的父类型

这个两个一般也是和?一样用在定义引用变量中，但是传值范围不一样

**T和？运用的地方有点不同,?是定义在引用变量上,T是类上或方法上**

**
**

**
**

**如果有泛型方法和非泛型方法,都满足条件,会执行非泛型方法**

**public** **void** show(String s){

   System.***out\***.println("1");

  }

  @Override

  **public** **void** show(T a) {

   System.***out\***.println("2");

  }



***java泛型的两种用法：List<T>是泛型方法，List<?>是限制通配符***



List<T>一般有两种用途：
1、定义一个通用的泛型方法。

```js
public interface Dao{

  List<T> getList(){};

}


List<String> getStringList(){

  return dao.getList();//dao是一个实现类实例

}


List<Integer> getIntList(){

  return dao.getList();

}
```

上面接口的getList方法如果定义成List<?> ，后面就会报错。



2、限制方法的参数之间或参数和返回结果之间的关系。

```text
List<T> getList<T param1,T param2>
```

这样可以限制返回结果的类型以及两个参数的类型一致。

List<?>一般就是在泛型起一个限制作用。

```text
public Class Fruit(){}
public Class Apple extends Fruit(){}
public void test(? extends Fruit){};
test(new Fruit());
test(new Apple());
test(new String()); //这个就会报错,参数必须是Fruit或其子类。


```



“<T>"和"<?>"，首先要区分开两种不同的场景：



1. 第一，声明一个泛型类或泛型方法。

2. 第二，使用泛型类或泛型方法。

3. 类型参数“<T>”主要用于第一种，声明泛型类或泛型方法。

4. 无界通配符“<?>”主要用于第二种，使用泛型类或泛型方法

   

---

参考：https://www.zhihu.com/question/31429113

![微信截图_20210521180535](C:\Users\sever\Desktop\微信截图_20210521180535.png)