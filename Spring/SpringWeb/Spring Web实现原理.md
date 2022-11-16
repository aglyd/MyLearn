# [关于Spring 请求、响应注解，及PrintWriter的区别](https://blog.csdn.net/superzhang6666/article/details/124382105)

请求
以前我们请求时会通过写大量的servlet来接收请求，现在srping mvc 框架的嵌入，只需通过restFul请求的方式。

## 1、Get请求

==**get请求没有请求体**==
==**get请求的请求头中没有Content-Type**==
get请求发生的数据拼接在url路径后面 , 数据发送到服务器的模式是**==Query-String==**

使用get请求时通过spring 接受参数
（1）使用@RequestParam(“username”)注解
底层实现 —> request.getParameter(“username”)
当参数名与接收的数据名一致时, 可以简写为@RequestParam 或者 省略不写

（2）也可以使用HttpServletRequest.getParameter(“”) 的方式

## 2、Post请求

==**请求头content-type=application/x-www-form-urlencoded**==
==**数据存放在请求体中**==
username=xxx&password=yyy
数据发送到服务器的模式是**Query-String**

使用spring 接受参数时同Get请求

## 3、Post请求

==**请求头content-type=application/json**==
==**数据存放在请求体中**==
{username : xxx , password : yyy}
数据发送到服务器的模式是**==Json-String==**

使用springMvc接收参数时
使用@RequestBody注解, 需要使用对象来接受数据
**底层实现：获得json串 —> BufferedReader br = request.getReader()**
将json串转为java对象

## Http请求 的编码方式有3种

当前台界面使用GET或POST方式提交数据时，request的body部分的数据编码格式由header部分的Content-Type指定，有以下几种方式

- application/x-www-form-urlencoded(默认)
- multipart/form-data （**==form表单里面有文件上传时，必须要指定enctype属性值为multipart/form-data，意思是以二进制流的形式传输文件==**）
- application/json、application/xml等格式的数据

## Spring MVC 用来处理请求参数的注解

`@PathVariable @RequestParam @ModelAttribute @RequestBody`

Spring MVC 提供了多个注解来获取get，post等请求中的参数。不同注解可以处理的参数是根据请求的编码方式来决定的。即根据request header content-type 值来判断。（换句话理解：Spring MVC项目中 controller中方法接收参数有多种方式，具体采用哪种方式是根据 请求的编码方式来决定的）：

- **@PathVariable 用来获取请求url中的参数** @RequestParam注解 如果get或post请求中 参数是
  application/x-www-form-urlencoded或者multipart/form-data编码方式，

- @RequestParam：
  RequestParam可以接受简单类型的属性，也可以接受对象类型 。
  RequestParam实质是将Request.getParameter() 中的Key-Value参数Map
  利用Spring的转化机制ConversionService配置，转化成参数接收对象或字段。get方式中query
  String的值，和post方式中body
  data的值都会被Servlet接受到并转化到Request.getParameter()参数集中，所以@RequestParam可以获取的到
- **@RequestBody 用来处理以application/json、application/xml等格式提交的数据**
- **@ModelAttribute 注解类型将参数绑定到Model对象**



## 响应

Spring MVC 控制器方法的返回值

==**1、Spring MVC 在使用 @RequestMapping 后，返回值通常解析为跳转路径。**==
==**2、加上 @ResponseBody 后返回结果不会被解析为跳转路径，会直接返回 json 数据，写入 HTTP response body 中。 比如异步获取 json 数据。**==
==**3、在springmvc中当返回值是String时，如果不加@ResponseBody的话，返回的字符串就会找这个String对应的页面，如果找不到会报404错误。**==
==**4、有时候不加@ResponseBody注解，那么就需要我们在controller的方法中传入response参数，然后在方法里面获取response.getWriter()赋给PrintWriter。然后通过PrintWriter把这个字符串以流的形式传递给原发送请求的页面。**==

参考文章：https://blog.csdn.net/dreamstar613/article/details/89492982
