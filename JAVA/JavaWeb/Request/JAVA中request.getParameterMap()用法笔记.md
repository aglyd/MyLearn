# [JAVA中request.getParameterMap()用法笔记][https://blog.csdn.net/qq_39949109/article/details/80415560]

 今天学习了一个获取提交表单数据的新方法request.getParameterMap。

 在此之前，获取表单数据时总是用request.getParameter(“name”)，根据表单中的name值获取value值，需要获取几项就得重复写几次getParameter，而request.getParameterMap方法则不同，不需要参数，返回结果为Map<String,String[]> 。其实，request.getParameterMap()方法也是通过前台表单中的name值进行获取的，获取到后又进行了一次封装。 之所以返回的map中的value为字符串类型的数组，是为了解决表单中有多个name值一样的项。

 

一、

   根据Java规范：request.getParameterMap()返回的是一个Map类型的值，该返回值记录着前端（如jsp页面）所提交请求中的请求参数和请求参数值的映射关系。这个返回值有个特别之处——只能读。不像普通的Map类型数据一样可以修改。这是因为服务器为了实现一定的安全规范，所作的限制。比如WebLogic，Tomcat，Resin，JBoss等服务器均实现了此规范。

  如果实在有必要在取得此值以后做修改的话，要新建一个map对象，将返回值复制到此新map对象中进行修改，用新的map对象代替使用之前的返回值。

```
<span style="font-size:14px;">01.Map readOnlyMap = request.getParameterMap();  
02.Map writeAbleMap = new HashMap();  
03.writeAbleMap.putAll(readOnlyMap);  
04.writeAbleMap.remove()或者put()...  
05.在后续的程序代码中使用writeAbleMap即可  
</span>
```

二、

  对request.getParameterMap()的返回值使用泛型时应该是Map<String,String[]>形式，因为有时像checkbox这样的组件会有一个name对应对个value的时候，所以该Map中键值对是<String-->String[]>的实现。

  举例，在服务器端得到jsp页面提交的参数很容易,但通过request.getParameterMap()可以将request中的参数和值变成一个Map。

  以下是将得到的参数和值打印出来，形成的map结构：Map(key,value[])，即：key是String型，value是String型数组。

例如：request中的参数t1=1&t1=2&t2=3形成的map结构：

key=t1;value[0]=1,value[1]=2



key=t2;value[0]=3

如果直接用map.get("t1"),得到的将是:Ljava.lang.String;  value之所以是数组形式，就是防止参数名有相同的情况。

遍历request.getParameterMap()里面的值：

```
    //获取request对象
     HttpServletRequest request = ServletActionContext.getRequest();
        
     Map<String,String[]> map=request.getParameterMap();
     //遍历
      for(Iterator iter=map.entrySet().iterator();iter.hasNext();){
        	Map.Entry element=(Map.Entry)iter.next();
        	//key值
        	Object strKey = element.getKey();
        	//value,数组形式
          String[] value=(String[])element.getValue();
 
         System.out.print(strKey.toString() +"=");
         for(int i=0;i<value.length;i++){
             System.out.print(value[i]+",");
         }           
```

三、当传递的参数个数不固定且参数名没有重复的，取值的方法：

//得到枚举类型的参数名称，参数名称若有重复的只能得到第一个

```
Map map = new HashMap();

Enumeration enum =this.getRequest().getParameterNames();  
 while (enum.hasMoreElements()) {  
  String paramName = (String) enum.nextElement();  
   
  String paramValue = this.getRequest().getParameter(paramName);  
   //形成键值对应的map  
  map.put(paramName, paramValue);  
  }  
```



------



# [request.getParameterMap()][https://blog.csdn.net/a897180673/article/details/79050235]



查看了一个项目的源码,里面用到了request.getParameterMap(),很是新奇,以往我们用的都是request.getParameter(arg0),用来获取前端传给后端的数据.

猜测getParameterMap() 应该是获取所有的请求的参数,他的返回的参数格式是Map

```
package com.test;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/TestPara")
public class Testpara  extends HttpServlet{

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            String a=request.getParameter("a");
            String b=request.getParameter("b");
            String c=request.getParameter("c");

            Map<String, String[]> map=  request.getParameterMap();
    }
}
```

把这个servlet跑起来,然后get请求一下参数

```
http://127.0.0.1:8080/工程名/TestPara?a=a&b=b&c=c1
```

在后台打个断点 看下结果

![这里写图片描述](JAVA中request.getParameterMap()用法笔记.assets/20180113112457203.jpg)

可以看到 request.getParameterMap() 就是把所有的请求参数全部封装成了map,
同时我们也注意到,他的value部分是String[]的一个数组,我们这样上传的话长度都是1,怎么样才能超过1个呢?

那就是url中多次赋值


http://127.0.0.1:8080/工程名/TestPara?a=a&a=aa&a=aaa&b=b&c=c



给a赋值3次就可以看到数组了,同时还要注意到,request.getParameter(“a”);它的值以第一个a 为准



-----



# [request.getParameter()方法][https://blog.csdn.net/wodegeekworld/article/details/41870123]

request.getParameter()方法:1.获取通过http协议提交过来的数据.       通过容器的实现来取得通过get或者post方式提交过来的数据

2.request.getParameter()方法传递的数据，会从web客户端传到web服务器端，代表HTTP请求数据，该方法返回String类型的数据

request.setAttribute()和getAttribute()只是在web容器内部流转，仅仅是请求处理阶段



request.getAttribute()方法返回request范围内存在的对象


request.setAttribute() 和 getAttribute() 方法传递的数据只会存在于Web容器内部

HttpServletRequest 类有 setAttribute() 方法，而没有setParameter() 方法
一般通过表单和链接传递的参数使用getParameter