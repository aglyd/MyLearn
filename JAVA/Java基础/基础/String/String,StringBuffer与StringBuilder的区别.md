# [String,StringBuffer与StringBuilder的区别][https://blog.csdn.net/u011702479/article/details/82262823]

**一、Java String 类——String字符串常量**

字符串广泛应用 在Java 编程中，在 Java 中字符串属于**对****象**，Java 提供了 **String 类来****创建****和****操作****字符串**。

需要注意的是，String的值是不可变的，这就导致每次对String的操作都会生成**新的String对象**，这样不仅效率低下，而且大量浪费有限的内存空间。我们来看一下这张对String操作时内存变化的图：

![img](https://img-blog.csdn.net/20180411091757991?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MTEwMTE3Mw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

我们可以看到，初始String值为“hello”，然后在这个字符串后面加上新的字符串“world”，这个过程是需要重新在栈堆内存中开辟内存空间的，最终得到了“hello world”字符串也相应的需要开辟内存空间，这样短短的两个字符串，却需要开辟三次内存空间，不得不说这是对内存空间的**极大浪费**。为了应对经常性的字符串相关的操作，谷歌引入了两个新的类——StringBuffer类和StringBuild类来对此种变化字符串进行处理。

**二、Java StringBuffer 和 StringBuilder 类——StringBuffer字符串变量、StringBuilder字符串变量**

**![img](https://img-blog.csdn.net/20180411092222821?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MTEwMTE3Mw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)**

当**对字符串进行修改**的时候，需要使用 StringBuffer 和 StringBuilder 类。

和 String 类不同的是，StringBuffer 和 StringBuilder 类的对象能够被多次的修改，并且**不产生新的未使用对象**。

StringBuilder 类在 Java 5 中被提出，它和 StringBuffer 之间的最大不同在于 StringBuilder 的方法不是线程安全的（不能同步访问）。

由于 StringBuilder 相较于 StringBuffer 有速度优势，**所以多数情况下建议使用 StringBuilder 类**。**然而在应用程序要求线程安全的情况下，则必须使用 StringBuffer 类。**

**三者的继承结构**

**![img](https://img-blog.csdn.net/20180411092328691?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MTEwMTE3Mw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)**

**三者的区别**：

![img](https://img-blog.csdn.net/20180411092400746?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MTEwMTE3Mw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

（1）字符修改上的区别（主要，见上面分析）

（2）初始化上的区别，String可以空赋值，后者不行，报错

①String

String s = null;  

String s = “abc”;  

②StringBuffer

StringBuffer s = null; //结果警告：Null pointer access: The variable result can only be null at this location

StringBuffer s = new StringBuffer();//StringBuffer对象是一个空的对象

StringBuffer s = new StringBuffer(“abc”);//创建带有内容的StringBuffer对象,对象的内容就是字符串”

**小结**：（1）如果要操作少量的数据用 String；

（2）多线程操作字符串缓冲区下操作大量数据 StringBuffer；

（3）**单线程操作字符串缓冲区下操作大量数据 StringBuilder**。



-----



# [StringBuffer和StringBuilder的区别][https://blog.csdn.net/mad1989/article/details/26389541]

String、StringBuffer、StringBuilder区别
StringBuffer、StringBuilder和String一样，也用来代表字符串。String类是不可变类，任何对String的改变都 会引发新的String对象的生成；StringBuffer则是可变类，任何对它所指代的字符串的改变都不会产生新的对象。既然可变和不可变都有了，为何还有一个StringBuilder呢？相信初期的你，在进行append时，一般都会选择StringBuffer吧！

先说一下集合的故事，HashTable是线程安全的，很多方法都是synchronized方法，而HashMap不是线程安全的，但其在单线程程序中的性能比HashTable要高。StringBuffer和StringBuilder类的区别也是如此，他们的原理和操作基本相同，区别在于StringBufferd支持并发操作，线性安全的，适 合多线程中使用。StringBuilder不支持并发操作，线性不安全的，不适合多线程中使用。新引入的StringBuilder类不是线程安全的，但其在单线程中的性能比StringBuffer高。

接下来，我直接贴上测试过程和结果的代码，一目了然：

```java
public class StringTest {
 
	public static String BASEINFO = "Mr.Y";
	public static final int COUNT = 2000000;
 
	/**
	 * 执行一项String赋值测试
	 */
	public static void doStringTest() {
 
		String str = new String(BASEINFO);
		long starttime = System.currentTimeMillis();
		for (int i = 0; i < COUNT / 100; i++) {
			str = str + "miss";
		}
		long endtime = System.currentTimeMillis();
		System.out.println((endtime - starttime)
				+ " millis has costed when used String.");
	}
 
	/**
	 * 执行一项StringBuffer赋值测试
	 */
	public static void doStringBufferTest() {
 
		StringBuffer sb = new StringBuffer(BASEINFO);
		long starttime = System.currentTimeMillis();
		for (int i = 0; i < COUNT; i++) {
			sb = sb.append("miss");
		}
		long endtime = System.currentTimeMillis();
		System.out.println((endtime - starttime)
				+ " millis has costed when used StringBuffer.");
	}
 
	/**
	 * 执行一项StringBuilder赋值测试
	 */
	public static void doStringBuilderTest() {
 
		StringBuilder sb = new StringBuilder(BASEINFO);
		long starttime = System.currentTimeMillis();
		for (int i = 0; i < COUNT; i++) {
			sb = sb.append("miss");
		}
		long endtime = System.currentTimeMillis();
		System.out.println((endtime - starttime)
				+ " millis has costed when used StringBuilder.");
	}
 
	/**
	 * 测试StringBuffer遍历赋值结果
	 * 
	 * @param mlist
	 */
	public static void doStringBufferListTest(List<String> mlist) {
		StringBuffer sb = new StringBuffer();
		long starttime = System.currentTimeMillis();
		for (String string : mlist) {
			sb.append(string);
		}
		long endtime = System.currentTimeMillis();
		System.out.println(sb.toString() + "buffer cost:"
				+ (endtime - starttime) + " millis");
	}
 
	/**
	 * 测试StringBuilder迭代赋值结果
	 * 
	 * @param mlist
	 */
	public static void doStringBuilderListTest(List<String> mlist) {
		StringBuilder sb = new StringBuilder();
		long starttime = System.currentTimeMillis();
		for (Iterator<String> iterator = mlist.iterator(); iterator.hasNext();) {
			sb.append(iterator.next());
		}
 
		long endtime = System.currentTimeMillis();
		System.out.println(sb.toString() + "builder cost:"
				+ (endtime - starttime) + " millis");
	}
 
	public static void main(String[] args) {
		doStringTest();
		doStringBufferTest();
		doStringBuilderTest();
 
		List<String> list = new ArrayList<String>();
		list.add(" I ");
		list.add(" like ");
		list.add(" BeiJing ");
		list.add(" tian ");
		list.add(" an ");
		list.add(" men ");
		list.add(" . ");
 
		doStringBufferListTest(list);
		doStringBuilderListTest(list);
	}
 
}
```

看一下执行结果：
2711 millis has costed when used String.
211 millis has costed when used StringBuffer.
141 millis has costed when used StringBuilder.
 I  like  BeiJing  tian  an  men  . buffer cost:1 millis
 I  like  BeiJing  tian  an  men  . builder cost:0 millis

从上面的结果可以看出，不考虑多线程，采用String对象时（我把Count/100），执行时间比其他两个都要高，而采用StringBuffer对象和采用StringBuilder对象的差别也比较明显。由此可见，如果我们的程序是在单线程下运行，或者是不必考虑到线程同步问题，我们应该优先使用StringBuilder类；如果要保证线程安全，自然是StringBuffer。

从后面List的测试结果可以看出，除了对多线程的支持不一样外，这两个类的使用方式和结果几乎没有任何差别，

StringBuffer常用方法
（由于StringBuffer和StringBuilder在使用上几乎一样，所以只写一个，以下部分内容网络各处收集，不再标注出处）

StringBuffer s = new StringBuffer();
这样初始化出的StringBuffer对象是一个空的对象，
 StringBuffer sb1=new StringBuffer(512);
分配了长度512字节的字符缓冲区。 
StringBuffer sb2=new StringBuffer(“how are you?”)

创建带有内容的StringBuffer对象，在字符缓冲区中存放字符串“how are you?”

```java
a、append方法
public StringBuffer append(boolean b)
该方法的作用是追加内容到当前StringBuffer对象的末尾，类似于字符串的连接，调用该方法以后，StringBuffer对象的内容也发生改 变，例如：
StringBuffer sb = new StringBuffer(“abc”);
sb.append(true);
则对象sb的值将变成”abctrue”

使用该方法进行字符串的连接，将比String更加节约内容，经常应用于数据库SQL语句的连接。


 b、deleteCharAt方法
public StringBuffer deleteCharAt(int index)
该方法的作用是删除指定位置的字符，然后将剩余的内容形成新的字符串。例如：
StringBuffer sb = new StringBuffer(“KMing”);
sb. deleteCharAt(1);
该代码的作用删除字符串对象sb中索引值为1的字符，也就是删除第二个字符，剩余的内容组成一个新的字符串。所以对象sb的值变 为”King”。
还存在一个功能类似的delete方法：
public StringBuffer delete(int start,int end)
该方法的作用是删除指定区间以内的所有字符，包含start，不包含end索引值的区间。例如：
StringBuffer sb = new StringBuffer(“TestString”);
sb. delete (1,4);
该代码的作用是删除索引值1(包括)到索引值4(不包括)之间的所有字符，剩余的字符形成新的字符串。则对象sb的值是”TString”。 


 c、insert方法
public StringBuffer insert(int offset, boolean b),
该方法的作用是在StringBuffer对象中插入内容，然后形成新的字符串。例如：
StringBuffer sb = new StringBuffer(“TestString”);
sb.insert(4,false);
该示例代码的作用是在对象sb的索引值4的位置插入false值，形成新的字符串，则执行以后对象sb的值是”TestfalseString”。 


 d、reverse方法
public StringBuffer reverse()
该方法的作用是将StringBuffer对象中的内容反转，然后形成新的字符串。例如：
StringBuffer sb = new StringBuffer(“abc”);
sb.reverse();
经过反转以后，对象sb中的内容将变为”cba”。 

 e、setCharAt方法
public void setCharAt(int index, char ch)该方法的作用是修改对象中索引值为index位置的字符为新的字符ch。例如：
StringBuffer sb = new StringBuffer(“abc”);
sb.setCharAt(1,’D’);
则对象sb的值将变成”aDc”。 

 f、trimToSize方法
public void trimToSize()
该方法的作用是将StringBuffer对象的中存储空间缩小到和字符串长度一样的长度，减少空间的浪费，和String的trim()是一样的作用，不在举例。

 g、length方法
该方法的作用是获取字符串长度 ，不用再说了吧。

 h、setlength方法
该方法的作用是设置字符串缓冲区大小。
StringBuffer sb=new StringBuffer();
sb.setlength(100);
如果用小于当前字符串长度的值调用setlength()方法，则新长度后面的字符将丢失。 

 i、sb.capacity方法
该方法的作用是获取字符串的容量。
StringBuffer sb=new StringBuffer(“string”);
int i=sb.capacity(); 

 j、ensureCapacity方法
该方法的作用是重新设置字符串容量的大小。
StringBuffer sb=new StringBuffer();
sb.ensureCapacity(32); //预先设置sb的容量为32 


 k、getChars方法
该方法的作用是将字符串的子字符串复制给数组。
getChars(int start,int end,char chars[],int charStart); 

StringBuffer sb = new StringBuffer("I love You");
int begin = 0;
int end = 5;
//注意ch字符数组的长度一定要大于等于begin到end之间字符的长度
//小于的话会报ArrayIndexOutOfBoundsException
//如果大于的话，大于的字符会以空格补齐
char[] ch  = new char[end-begin];
sb.getChars(begin, end, ch, 0);
System.out.println(ch);
结果：I lov
```

