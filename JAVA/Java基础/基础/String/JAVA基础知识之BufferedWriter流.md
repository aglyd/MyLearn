# [JAVA基础知识之BufferedWriter流][https://blog.csdn.net/ai_bao_zi/article/details/81187688]

## 一、BufferedWriter流

​     API文档说明：

   1）将文本写入字符输出流，缓冲字符，以便有效地写入单个字符，数组和字符串？

    说明存在用单个字符、数组、字符串作为参数的方法写入数据
    
     2）可以指定缓冲区大小，或者可以接受默认大小。对于大多数用途，默认值足够大？
    
    说明该类存在一个常量值用作默认缓冲区大小同时也可以通过构造函数指定大小
    
     3）提供了一个newLine（）方法，它使用平台自己的行分隔符概念，由系统属性line.separator定义。并非所有平台都使用换行符（'\ n'）来终止行。因此，调用此方法终止每个输出行比直接编写换行符更为可取。
    
       用于进行输出的时候做换行操作且自动适用平台的换行分隔符，而非自定义的，比较灵活
    
     4） 通常，Writer会立即将其输出发送到基础字符或字节流。除非需要提示输出，否则建议将BufferedWriter包装在任何write（）操作可能代价高昂的Writer周围，例如FileWriters和OutputStreamWriters。
    
      意味着可以用BufferedWriter来包装write的子类提高输出效率

## 二、BufferedWriter流实例域

​      可以看出存在一个默认字符缓冲区，且默认大小是8192个字符

```
 //字符输出流
    private Writer out;
 
    //字符缓冲区
    private char cb[];
    
    //设置的字符缓冲区大小变量
    private int nChars;
    
    //字符缓冲区中的已存储元素的位置
    private int  nextChar;
 
    //默认字符缓冲区大小
    private static int defaultCharBufferSize = 8192;
 
    /**
     * 行分割字符串-
     * property at the moment that the stream was created.
     */
    private String lineSeparator;
```

## 三、BufferedWriter流构造函数

   **1、参数Writer out实际是Writer的子类如FileWriters和OutputStreamWriters等**

​	**2、 参数sz就是用于指定字符缓冲区大小的变量**

```java
 
    /**
     * 
     * 默认字符缓冲区大小的构造函数
     *
     * @param  out  A Writer
     */
    public BufferedWriter(Writer out) {
        this(out, defaultCharBufferSize);
    }
 
    /**
     * 指定字符缓冲区大小的构造函数
     */
    public BufferedWriter(Writer out, int sz) {
        super(out);
        if (sz <= 0)
            throw new IllegalArgumentException("Buffer size <= 0");
        this.out = out;
        cb = new char[sz];
        nChars = sz;
        nextChar = 0;
 
        lineSeparator = java.security.AccessController.doPrivileged(
           new sun.security.action.GetPropertyAction("line.separator"));
    }
```

## 四、BufferedWriter流的API

***1）写一个字符到字符缓冲区中：本质是写入字符到字符缓冲区中***

```
 /**
     * 写入一个字符，并存入到字符缓冲区中
     *
     * @exception  IOException  If an I/O error occurs
     */
    public void write(int c) throws IOException {
        synchronized (lock) {
            ensureOpen();
            if (nextChar >= nChars)
                flushBuffer();
            cb[nextChar++] = (char) c;  //将单个字符存入到
        }
    }
```

2）写一个字符数组的一部分：本质是调用OutputStreamWriter的write(cbuf, off, len)方法而OutputStreamWriter的write(cbuf, off, len)方法实际是调用StreamEncoder的write方法执行的

 **1、传入字符数组cbuf，字符数组的偏移点off，以及要写入的字符个数len--代表要从字符数组cbuf中下标off开始写入len个字符**

 **2、 前期条件判断避免出现RuntimeException异常所以必须抛出**

 **3、 当要写入的字符个数len大于字符缓冲区的长度时则意味着就算字符缓冲区cb是空的也无法载入写入字符，那么就没必有调用字符缓冲区了，直接调用write(cbuf, off, len)方法,out变量是OutputStreamWriter的对象，而OutputStreamWriter内的方法都是StreamEncoder类的方法执行。因此实际调用的是StreamEncoder的write方法。在StreamEncoder中直接把字符数组cbuf通过编码器编码到StreamEncoder的字节缓冲区中**

**4、当要写入的字符个数len小于字符缓冲区的长度时，通过 System.arraycopy的方法把字符数组cbuf内要写入的字符复制到字符缓冲区cb中，其中while循环的作用就是保证符数组cbuf内要写入的字符全部复制到字符缓冲区cb中**

```
  * 写一个字符数组的一部分
    *
     */
    public void write(char cbuf[], int off, int len) throws IOException {
        synchronized (lock) {
            ensureOpen();
            if ((off < 0) || (off > cbuf.length) || (len < 0) ||
                ((off + len) > cbuf.length) || ((off + len) < 0)) {
                throw new IndexOutOfBoundsException();
            } else if (len == 0) {
                return;
            }
 
            if (len >= nChars) {
                //如果请求长度超过输出缓冲区的大小则直接进行输出，而不用字符缓冲区做缓冲
                flushBuffer();
                out.write(cbuf, off, len);  //实际是调用的OutputStreamWriter的write方法本质是调用StreamEncoder的write方法执行的
                return;
            }
 
            int b = off, t = off + len;
             
             //此循环的目的就是保证len个字符务必被复制到字符缓冲区中区
                while (b < t) {      
                int d = min(nChars - nextChar, t - b);  //判断字符缓冲区中的剩余位置和要写入的字符长度最小值，若字符缓冲区空间充足，则复制len个字符，若不充足，则复制剩余位置个字符
                System.arraycopy(cbuf, b, cb, nextChar, d); //从目标数组cbuf的下标b中复制d个字符到字符缓冲区
                b += d;
                nextChar += d;
                if (nextChar >= nChars) //判断字符缓冲区是否已满？若满了，则调用flushBuffer方法把缓冲区中的内容全部输出，然后按道理此时字符缓冲区应该就是空了的？
                    flushBuffer();
            }
        }
    }
```

***3）写字符串的一部分：本质跟第二个写字符数组的一部分一致***

```
/**
     * 写一个字符串的一部分
     *  若len为负值，则没有任何字符被写入，
     */
    public void write(String s, int off, int len) throws IOException {
        synchronized (lock) {
            ensureOpen();
            int b = off, t = off + len;
            while (b < t) {
                int d = min(nChars - nextChar, t - b);
                s.getChars(b, b + d, cb, nextChar); //本质跟System.arraycopy(cbuf, b, cb, nextChar, d);一样，将内容复制 到缓冲区中
                b += d;
                nextChar += d;
                if (nextChar >= nChars)
                    flushBuffer();
            }
        }
    }
```

**4）close方法--关闭流资源，关闭之前会先调用flushBuffer()方法然后调用StreamEncoder的write方法把字符缓冲区的内容写入到StreamEncoder的字节缓冲区中，最后调用close方法在把StreamEncoder的字节缓冲区内容输出到计算机中**

 /**
     * 关闭流，关闭之前先刷新缓冲区，然后再关闭流
          */

    public void close() throws IOException {
        synchronized (lock) {
            if (out == null) {
                return;
            }
            try {
                flushBuffer();
            } finally {
                out.close();  //实际调用的是OutputStreamWriter的close方法
                out = null;
                cb = null;
            }
        }
    }
    
    /**
     * 将字符缓冲区中的内容写入到字节缓冲区中
     */
    void flushBuffer() throws IOException {
        synchronized (lock) {
            ensureOpen();
            if (nextChar == 0)
                return;
            out.write(cb, 0, nextChar);   //注意这里的方法调用到了实现类outputSteam类的write方法
            nextChar = 0;
        }
    }
**5）flush方法：刷新缓冲区数据，其本质是先调用flushBuffer方法把BufferedWriter类中的字符缓冲区内容写入到StreamEncoder的字节缓冲区，而后调用OutputStreamWriter的flush方法把StreamEncoder的字节缓冲区内容给写出去，因此和close方法作用一致，但是没有关闭资源链接达到释放资源作用，所以项目中一般是先进行flush工作保证字节输出，而后调用close做二次保证以及关闭资源**

    /**
     * 刷新缓冲区将缓冲区字符编码到字节缓冲区中
     *
     * @exception  IOException  If an I/O error occurs
     */
    public void flush() throws IOException {
        synchronized (lock) {
            flushBuffer();
            out.flush();
        }
    }
## 五、BufferedWriter流与OutputStreamWriter的关系

​     1）前面OutputStreamWriter的API说明中提到过：为了获得最高效率，请考虑在BufferedWriter中包装OutputStreamWriter，以避免频繁的转换器调用这句话，理解如下：

         当我们直接使用OutputStreamWriter进行输出时，不管是一个字符，还是一个数组，都会调用字符编码器进行转换，因为其是直接调用的StreamEncoder的implWrite方法，若存在for循环100次，每次调用write(int c)方法写入一个字符，那么最终就会调用100次的implWrite方法，就会调用100次的字符编码器进行转换
    
       但是当我们使用BufferedWriter包装OutputStreamWriter时，每次调用write(int c)方法时，都只是将字符写入到BufferedWriter类的字符缓冲区中。到最后调用flush方法或者close方法时，才会调用一次StreamEncoder的implWrite方法，也就是调用一次字符编码器
    
      因此BufferedWriter可以提高字符输出的效率，提高的关键点在于：存在字符缓冲区用于存储字符

 



2）因此根据对FileWriter、OutputStreamWriter、StreamEncoder、BufferedWriter的源码分析，我们可以得出以下几点

     2.1    以上4个类的起到字符编码成字节并调用底层字节输出流的是StreamEncoder类
    
    2.2     FileWriter类和OutputStreamWriter类只是傀儡性质，实际并未发挥作用
    
    2.3     项目中遇到文件字符输出流时，请使用BufferedWriter包装OutputStreamWriter类，以便提高效率
    
    2.4    StreamEncoder类在jdk1.7的版本中是没有源码可以导入的，因此不建议直接使用
    
    2.5    若要理解透彻，可以对以上4个类源码进行重写，然后做实际数据验证，就可以理解每一个方法的作用了
------------------------------------------------