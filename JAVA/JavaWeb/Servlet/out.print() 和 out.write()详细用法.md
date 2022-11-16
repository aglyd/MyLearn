# [out.print() 和 out.write()详细用法][https://blog.csdn.net/weixin_42098099/article/details/86300381]



out.print()和out.write()都可以用在jsp中做输出, 我们先看看区别. 然后再研究什么时候用print(), 什么时候用write().

## out.print()

会将所有类型的数据转换为字符串, 包括null值, 并输出

```
int a = 10;
String b = null
out.print("abc<hr>");	//abc<hr>(html解析后为分割线)
out.print('c');	   //c
out.print(a);	//10
out.print(b);	//null
```



## out.write()

会将所有类型数据转换为字符,字符数组, 字符串并输出.

查看源码

```
public void write(int c){
    ...
    writeBuffer[0] = (char) c; 
    ...
}
```

注: 1. 当整型数据转换为字符时, 其中1-32是一些特殊符号, 不会显示出来. 2. 如果传入null值, 会报错

```
int ab = 10;
String c = null;
out.write(2);	//特殊符号(不显示)
out.write(ab);	//d(10转换为字符d)
out.write("abc<hr>");	//abc<hr>(html解析后为分割线)
out.write(c);	//报错
```

![ASCIIç è¡¨](https://img-blog.csdn.net/20160910022505042)

那么什么时候用print(), 什么时候用write().
<% %>:
用来标示java代码, 里面的全部代码会被原样编译成java代码;
<%= %>:
用来输出数据, 不能放语句, 编译java代码后是使用out.print()输出;
未用jsp样式标示:
未标识的都是html代码, tomcat默认使用out.print(), 并加上双引号输出全部html数据;

----



# [关于PrintWriter out = response.getWriter()的使用及注意事项][https://blog.csdn.net/workinghardboy/article/details/80556735]



首先说明两种方法的区别

write()：仅支持输出字符类型数据，字符、字符数组、字符串等

print()：可以将各种类型（包括Object）的数据通过默认编码转换成bytes字节形式，这些字节都通过write(int c)方法被输出

因此传输数据时，write,print都可以使用

**1.PrintWriter可以直接调用write()或print()方法，把字符串作为参数写入，这样就可以写入json格式的数据了。如：**

```
PrintWriter out = response.getWriter();
String info = gson.toJson(arraylistUsers);
out.write(info);
```

通过这种方式，客户端就可以接受到数据了。客户端读取数据有多种方式，可以通过ajax读，也可以通过GetPostUtil来读取返回的数据。



**2.print方法和write方法是有区别的，最大的区别就是上述提到的，print可以写入对象，而write不行。**

**3.print和write都可以写入html代码，来进行页面的跳转，并在一段时间后跳回到原来的页面，以此来达到提醒的作用。如：**



**4.PrintWriter不能PrintWriter  out = new PrintWriter()，因为这样，out不能找到输出的对象，导致输出失败。**

**5.out.flush()表示强制将缓冲区中的数据发送出去，不必等到缓冲区满。所以一般先flush()再close()，否则容易导致数据丢失**

------------------------------------------------
版权声明：本文为CSDN博主「努力中的稳健少年」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/workinghardboy/article/details/80556735

----



# [Servlet用out.print()输出中文乱码][https://blog.csdn.net/weixin_42063239/article/details/84317442]

用out.print()往页面输出时产生了中文乱码

![img](https://img-blog.csdnimg.cn/20181121133444612.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MjA2MzIzOQ==,size_16,color_FFFFFF,t_70)

明明设置了request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
response.setCharacterEncoding("utf-8");

但并没有什么用，一番差错加百度下找到了原因，虽然是设置了编码类型，但是是在输出流获取后才指定，此时再指定编码对输出流就已经无效了，把编码设置放到输出流获取之前就ok了

![img](https://img-blog.csdnimg.cn/20181121133801184.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MjA2MzIzOQ==,size_16,color_FFFFFF,t_70)

------------------------------------------------
