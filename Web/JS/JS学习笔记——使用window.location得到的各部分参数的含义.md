# [JS学习笔记——使用window.location得到的各部分参数的含义](https://blog.csdn.net/MRlaochen/article/details/120110579)

在平常的项目开发过程中，我们会经常从URL中解析各种数据信息，所以我们对window.location获取到的URL中的各种字段含义进行解析。

### 1、url拆解

通常我们所说的URL，即`统一资源定位符`(Uniform Resource Locator, URL) ,
对于一个完整的URL，由这几个部分构成：

```
scheme://host:port/path?query#fragment
```

- `scheme(通信协议)`：常用的`http`，`ftp`，`maito`等
- `host(主机+端口)`：服务器(计算机)`域名系统 (DNS) 主机名`或 `IP 地址` + `端口号`。
- `port(端口号)`：`整数`，可选，省略时使用方案的默认端口，如`http`的默认端口为`80`。
- `path(路径)`：由`零`或`多个"/"`符号隔开的字符串，一般用来表示`主机上的一个目录或文件地址`。
- `query(查询)`：`可选`，用于给动态网页（如使用CGI、ISAPI、PHP/JSP/ASP/ASP.NET等技术制作的网页）传递参数，可有`多个参数`，用`"&"`符号`隔开`，每个`参数的名`和`值`用`"="`符号`隔开`。
- `fragment(信息片断)`：`字符串`，用于指定网络资源中的片断。例如一个网页中有多个名词解释，可使用fragment直接定位到某一名词解释。(也称为锚点.)

我们以下面的URL为例，进行拆解：

```
http://www.x2y2.com:8866/file/test/window.location.html?verson=1.0&id=6&appnm=xxx#imhere
```

### 2、window.location.href（当前url）

`window.location.href`返回的是`整个URL字符串(在浏览器中就是完整的地址栏)`
本例中的返回值就是:

```
http://www.x2y2.com:80/file/test/window.location.html?ver=1.0&id=6#imhere
```

### 3、window.location.protocol（协议）

`window.location.protocol`返回的是`URL 的协议部分`,本例返回值:

```
http:
```

### 4、window.location.host（主机名/域名+端口号）

`window.location.host`返回的是`URL的主机+端口号`，本例返回值:

```
www.x2y2.com:8866
```

### 5、window.location.hostname（域名）

`window.location.hostname`返回的是`URL的主机/域名`，本例返回值:

```
www.x2y2.com
```

### 6、window.location.port（端口）

`window.location.port`返回的是`URL 的端口部分`， 如果采用`默认的80端口`(update:即使添加了:80)，那么`返回值并不是默认的80而是空字符`
本例返回值:

```
8866
```

### 7、window.location.pathname（路径部分）

`window.location.pathname`返回的是`URL 的路径部分(就是文件地址)`，本例返回值:

```
file/test/window.location.html
```

### 8、window.location.search（请求的参数）

`window.location.search`返回的是`查询(参数)部分`，除了给动态语言赋值以外，我们同样可以给静态页面,并使用javascript来获得相信应的参数值。
本例返回值:

```
?verson=1.0&id=6&appnm=xxx
```

### 9、window.location.hash（锚点）

`window.location.hash`返回的是`锚点`，本例返回值:

```
#imhere 
<src="http://feeds.feedburner.com/~s/fisker?i=http://www.x2y2.com/fisker/post/0703/window.location.html" type="text/javascript" charset="utf-8">
```

### 10、window.location.origin（’?'前边的URL）

`window.location.origin`返回的是`?前面的部分`，本例返回值:

```
http://www.x2y2.com:8866/file/test/window.location.html
```