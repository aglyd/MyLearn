# [getOutputStream() has already been called for this response][https://blog.csdn.net/qq_40279809/article/details/86737104]

原因分析：

产生这样的异常原因:是web容器生成的servlet代码中有out.write(""),
这个和JSP中调用的response.getOutputStream()产生冲突.即Servlet规范说明，
不能既调用response.getOutputStream()，又调用response.getWriter(),
无论先调用哪一个，在调用第二个时候应会抛出IllegalStateException，因为在jsp中，
out变量实际上是通过response.getWriter得到的，你的程序中既用了response.getOutputStream，又用了out变量，故出现以上错误。

解决办法：

在调用 response.getOutputStream()之前，清空缓存的内容，并返回一个新的BodyContext，更新PageContext的out属性的内容

```
response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-disposition", "inline;filename="+fileName);
    out.clear();      //清空缓存的内容
    out=pageContext.pushBody();  //更新PageContext的out属性的内容
    writeExcel(response.getOutputStream(),startDate,endDate);
```

我的是 加载aop日志后 页面出不来 其他人导出报错 把aop里面所有JSON.toJSONString(obj)注释

![img](https://img-blog.csdnimg.cn/20190201151242707.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQwMjc5ODA5,size_16,color_FFFFFF,t_70)

1.跟Output之类其他的输出流相互排斥了。 
2.也可能是多次调用那个Struts里面定义的方法。 
3.最后查出原因：Struts方法之间调用引起的

------------------------------------------------
