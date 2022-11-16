# [response.setHeader()下载的用法](https://www.cnblogs.com/chengzixin/p/6792000.html)

\1. HTTP消息头

（1）通用信息头

即能用于请求消息中,也能用于响应信息中,但与被传输的实体内容没有关系的信息头,如Data,Pragma

主要: Cache-Control , Connection , Data , Pragma , Trailer , Transfer-Encoding , Upgrade

（2）请求头

用于在请求消息中向服务器传递附加信息,主要包括客户机可以接受的数据类型,压缩方法,语言,以及客户计算机上保留的信息和发出该请求的超链接源地址等.

主要: Accept , Accept-Encoding , Accept-Language , Host ,

（3）响应头

用于在响应消息中向客户端传递附加信息,包括服务程序的名称,要求客户端进行认证的方式,请求的资源已移动到新地址等.

主要: Location , Server , WWW-Authenticate(认证头)

（4）实体头

用做实体内容的元信息,描述了实体内容的属性,包括实体信息的类型,长度,压缩方法,最后一次修改的时间和数据的有效期等.

主要: Content-Encoding , Content-Language , Content-Length , Content-Location , Content-Type

（4）扩展头

主要：Refresh, Content-Disposition

\2. 几个主要头的作用

（1）Content-Type的作用

该实体头的作用是让服务器告诉浏览器它发送的数据属于什么文件类型。

例如：当Content-Type 的值设置为text/html和text/plain时,前者会让浏览器把接收到的实体内容以HTML格式解析,后者会让浏览器以普通文本解析.

（2）Content-Disposition 的作用

当Content-Type 的类型为要下载的类型时 , 这个信息头会告诉浏览器这个文件的名字和类型。

在讲解这个内容时,张老师同时讲出了解决中文文件名乱码的解决方法,平常想的是使用getBytes() , 实际上应使用email的附件名编码方法对文件名进行编码,但IE不支持这种作法(其它浏览器支持) , 使用javax.mail.internet.*包的MimeUtility.encodeWord("中文.txt")的方法进行编码。

Content-Disposition扩展头的例子：

<%@ page pageEncoding="GBK" contentType="text/html;charset=utf-8" import="java.util.*,java.text.*" %>

<%=DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT, Locale.CHINA).format(new Date())

%>

<%

​        response.setHeader("Content-Type","video/x-msvideo");

​        response.setHeader("Content-Disposition", "attachment;filename=aaa.doc");

%>

Content-Disposition中指定的类型是文件的扩展名，并且弹出的下载对话框中的文件类型图片是按照文件的扩展名显示的，点保存后，文件以filename的值命名，保存类型以Content中设置的为准。

注意：在设置Content-Disposition头字段之前，一定要设置Content-Type头字段。

（3）Authorization头的作用

Authorization的作用是当客户端访问受口令保护时，服务器端会发送401状态码和WWW-Authenticate响应头，要求客户机使用Authorization来应答。

例如：

<%@ page pageEncoding="GBK" contentType="text/html;charset=utf-8" import="java.util.*,java.text.*" %>

<%=DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT, Locale.CHINA).format(new Date())

%>

<%

response.setStatus(401);

response.setHeader("WWW-Authenticate", "Basic realm=\"Tomcat Manager Application\"");

%>

3．如何实现文件下载

要实现文件下载，我们只需要设置两个特殊的相应头，它们是什么头？如果文件名带中文，该如何解决？

两个特殊的相应头：

----Content-Type:    application/octet-stream

----Content-Disposition: attachment;filename=aaa.zip

例如：

response.setContentType("image/jpeg");response.setHeader("Content- Disposition","attachment;filename=Bluehills.jpg");

如果文件中filename参数中有中文，则就会出现乱码。

解决办法：

（1）MimeUtility.encodeWord("中文.txt");//现在版本的IE还不行

（2）new String("中文".getBytes("GB2312"),"ISO8859- 1");//实际上这个是错误的

\4. 测试并分析文件名乱码问题

response.setHeader()下载中文文件名乱码问题

response.setHeader("Content-Disposition", "attachment; filename=" + java.net.URLEncoder.encode(fileName, "UTF-8"));

下载的程序里有了上面一句，一般在IE6的下载提示框上将正确显示文件的名字，无论是简体中文，还是日文。不过当时确实没有仔细测试文件名为很长的中文文件名的情况。现如今经过仔细测试，发现文字只要超过17个字，就不能下载了。分析如下：

一. 通过原来的方式，也就是先用URLEncoder编码，当中文文字超过17个时，IE6 无法下载文件。这是IE的bug，参见微软的知识库文章 KB816868 。原因可能是IE在处理 Response Header 的时候，对header的长度限制在150字节左右。而一个汉字编码成UTF-8是9个字节，那么17个字便是153个字节，所以会报错。而且不跟后缀也不对.

二. 解决方案：将文件名编码成ISO8859-1是有效的解决方案，代码如下：

response.setHeader( "Content-Disposition", "attachment;filename=" + new String( fileName.getBytes("gb2312"), "ISO8859-1" ) );

在确保附件文件名都是简体中文字的情况下，那么这个办法确实是最有效的，不用让客户逐个的升级IE。如果台湾同胞用，把gb2312改成big5就行。但现在的系统通常都加入了 国际化的支持，普遍使用UTF-8。如果文件名中又有简体中文字，又有繁体中文，还有日文。那么乱码便产生了。另外，在上Firefox (v1.0-en)下载也是乱码。

三. 参看邮件中的中文附件名的形式，用outlook新建一个带有中文附件的邮件，然后看这个邮件的源代码，找到：

Content-Disposition: attachment;

filename="=?gb2312?B?0MK9qCDOxLG+zsS1tS50eHQ=?="

用这个filename原理上就可以显示中文名附件，但是现在IE并不支持，Firefox是支持的。尝试使用 javamail 的MimeUtility.encode()方法来编码文件名，也就是编码成 =?gb2312?B?xxxxxxxx?= 这样的形式，并从 RFC1522 中找到对应的标准支持。

折中考虑，结合了一、二的方式，代码片断如下：

String fileName = URLEncoder.encode(atta.getFileName(), "UTF-8");

/*

\* see http://support.microsoft.com/default.aspx?kbid=816868

*/

if (fileName.length() > 150) {

String guessCharset = xxxx

//根据request的locale 得出可能的编码，中文操作系统通常是gb2312

fileName = new String(atta.getFileName().getBytes(guessCharset), "ISO8859-1");

}

response.setHeader("Content-Disposition", "attachment; filename=" + fileName);

编码转换的原理：

首先在源程序中将编码设置成GB2312字符编码,然后将源程序按Unicode编码转换成字节码加载到内存中（java加载到内存中的字节码都是Unicode编码），然后按GB2312编码获得中文字符串的字节数组，然后生成按ISO8859-1编码形式的Unicode字符串（这时的4个字节就变成了8个字节，高位字节补零）,

当在网络中传输时，因为setHeader方法中的字符只能按ISO8859-1传输，所以这时候就又把Unicode字符转换成了ISO8859-1的编码传到浏览器（就是把刚才高位补的零全去掉），这时浏览器接收到的ISO8859-1码的字符因为符合GB2312编码，所以就可以显示中文了。

\5. jsp翻译成class时的编码问题

记事本中代码块1：

<%=

​    "a中文".length()

%>

代码块2：

<%@ page pageEncoding="gbk"%>

<%=

​    "a中文".length()

%>

为什么上面的输出值为5，改成下面的则输出3？

因为上面的代码没有添加该文件的编码说明 , WEB应用程序在将jsp翻译成class文件时 , 把该字符串的内容按默认的保存方式指定的编码ASCII码来算的，在UTF-8中，原ASCII字符占一个字节，汉字占两个字节，对应两个字符，长度就变成了5 , 而下面的是GBK编码, 一个汉字和一个英文都对应一个字符,得到结果就为3.


]


response.setHeader(...)文件名中有空格的时候

String fileName = StringUtils.trim(file.getName());

String formatFileName = encodingFileName(name);//在后面定义方法encodingFileName(String fileName);
response.setHeader("Content-Disposition", "attachment; filename=" + formatFileName );

//处理文件名中出现的空格 

//其中%20是空格在UTF-8下的编码

public static String encodingFileName(String fileName) {
    String returnFileName = "";
    try {
      returnFileName = URLEncoder.encode(fileName, "UTF-8");
      returnFileName = StringUtils.replace(returnFileName, "+", "%20");
      if (returnFileName.length() > 150) {
        returnFileName = new String(fileName.getBytes("GB2312"), "ISO8859-1");
        returnFileName = StringUtils.replace(returnFileName, " ", "%20");
      }
    } catch (UnsupportedEncodingException e) {
      e.printStackTrace();
      if (log.isWarnEnabled()) {
        log.info("Don't support this encoding ...");
      }
    }
    return returnFileName;
  }



-----



# [URLEncode 中对 空格的编码有 “+”和“%20”两种](https://www.cnblogs.com/zhengxl5566/p/10783422.html)

详细RFC文档请参考此文

[下载的附件名总乱码？你该去读一下 RFC 文档了！](https://www.cnblogs.com/zhengxl5566/p/13492602.html)

 

URL中的空格有时候被编码成%20，有时候被编码成加号+，曾经迷糊过一段时间，后来查了下资料才搞明白。

一个URL的基本组成部分包括协议(scheme),域名，端口号，路径和查询字符串（路径参数和锚点标记就暂不考虑了）。路径和查询字符串之间用问号?分离。例如http://www.example.com/index?param=1，路径为index，查询字符串(Query String)为param=1。URL中关于空格的编码正是与空格所在位置相关：空格被编码成加号+的情况只会在查询字符串部分出现，而被编码成%20则可以出现在路径和查询字符串中。

造成这种混乱局面的原因在于：[W3C标准规定](http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.1)，当Content-Type为application/x-www-form-urlencoded时，URL中查询参数名和参数值中空格要用加号+替代，所以几乎所有使用该规范的浏览器在表单提交后，URL查询参数中空格都会被编成加号+。而在另一份规范([RFC 2396](http://www.ietf.org/rfc/rfc2396.txt)，定义URI)里, URI里的保留字符都需转义成%HH格式(Section 3.4 Query Component)，因此空格会被编码成%20，加号+本身也作为保留字而被编成%2B，对于某些遵循RFC 2396标准的应用来说，它可能不接受查询字符串中出现加号+，认为它是非法字符。所以一个安全的举措是URL中统一使用%20来编码空格字符。

Java中的URLEncoder本意是用来把字符串编码成application/x-www-form-urlencoded MIME格式字符串，也就是说仅仅适用于URL中的查询字符串部分，但是URLEncoder经常被用来对URL的其他部分编码，它的encode方法会把空格编成加号+，与之对应的是，URLDecoder的decode方法会把加号+和%20都解码为空格，这种违反直觉的做法造成了当初我对空格URL编码问题的困扰。因此后来我的做法都是，在调用URLEncoder.encode对URL进行编码后(所有加号+已被编码成%2B)，再调用replaceAll(“\\+”, “%20″)，将所有加号+替换为%20。



----



# [下载的附件名总乱码？你该去读一下 RFC 文档了！](https://www.cnblogs.com/zhengxl5566/p/13492602.html)

Web 开发过程中，相信大家都遇到过附件下载的场景，其中，各浏览器下载后的文件名中文乱码问题或许一度让你苦恼不已。

网上搜索一下，大部分都是通过`Request Headers`中的`UserAgent`字段来判断浏览器类型，根据不同的浏览器做不同的处理，类似下面的代码：

```java
// MicroSoft Browser
if (agent.contains("msie") || agent.contains("trident") || agent.contains("edge")) {
  // filename 特殊处理
}
// firefox
else if (agent.contains("firefox")) {
  // filename 特殊处理
}
// safari
else if (agent.contains("safari")) {
  // filename 特殊处理
}
// Chrome
else if (agent.contains("chrome")) {
  // filename 特殊处理
}
// 其他
else{
 // filename 特殊处理
}
//最后把特殊处理后的文件名放到head里
response.setHeader("Content-Disposition",
                    "attachment;fileName=" + filename);
```

不过，这样的代码看起来很魔幻，为什么每个浏览器的处理方式都不一样？难道每次新出一个浏览器都要做兼容吗？就没有一个统一标准来约束一下这帮浏览器吗？

带着这个疑惑，我翻阅了 RFC 文档，最终得出了一个优雅的解决方案：

```java
// percentEncodedFileName 为百分号编码后的文件名
response.setHeader("Content-disposition",
        "attachment;filename=" + percentEncodedFileName +
        ";filename*=utf-8''" + percentEncodedFileName);
```

经过测试，这段响应头可以兼容市面上所有主流浏览器，由于是 HTTP 协议范畴，所以语言无关。只要按这个规则设置响应头，就能一劳永逸地解决恼人的附件名中文乱码问题。

接下来课代表带大家抽丝剥茧，通过阅读 RFC 文档，还原一下这个响应头的产出过程。

## 1. Content-Disposition

一切要从 [RFC 6266](https://tools.ietf.org/html/rfc6266) 开始，在这份文档中，介绍了`Content-Disposition`响应头，其实它并不属于`HTTP`标准，但是因为使用广泛，所以在该文档中进行了约束。它的语法格式如下：

```java
content-disposition = "Content-Disposition" ":"
                            disposition-type *( ";" disposition-parm )

     disposition-type    = "inline" | "attachment" | disp-ext-type
                         ; case-insensitive
     disp-ext-type       = token

     disposition-parm    = filename-parm | disp-ext-parm

     filename-parm       = "filename" "=" value
                         | "filename*" "=" ext-value
```

其中的`disposition-type`有两种：

- inline 代表默认处理，一般会在页面展示
- attachment 代表应该被保存到本地，需要配合设置`filename`或`filename*`

注意到`disposition-parm`中的`filename`和`filename*`，文档规定：这里的信息可以用于保存的文件名。

它俩的区别在于，filename 的 value 不进行编码，而`filename*`遵从 [RFC 5987](https://tools.ietf.org/html/rfc5987)中定义的编码规则：

```java
Producers MUST use either the "UTF-8" ([RFC3629]) or the "ISO-8859-1" ([ISO-8859-1]) character set.
```

由于`filename*`是后来才定义的，许多老的浏览器并不支持，所以文档规定，当二者同时出现在头字段中时，需要采用`filename*`，忽略`filename`。

至此，响应头的骨架已经呼之欲出了，摘录 [RFC 6266] 中的示例如下：

```java
 Content-Disposition: attachment;
                      filename="EURO rates";
                      filename*=utf-8''%e2%82%ac%20rates
```

这里对`filename*=utf-8''%e2%82%ac%20rates`做一下说明，这个写法乍一看可能会觉得很奇怪，它其实是用单引号作为分隔符，将等号右边分成了三部分：第一部分是字符集(`utf-8`)，中间部分是语言(未填写)，最后的`%e2%82%ac%20rates`代表了实际值。对于这部分的组成，在[RFC 2231](https://tools.ietf.org/html/rfc2231).section 4 中有详细说明：

```java
 A single quote is used to
   separate the character set, language, and actual value information in
   the parameter value string, and an percent sign is used to flag
   octets encoded in hexadecimal.
```

## 2.PercentEncode

PercentEncode 又叫 Percent-encoding 或 URL encoding.

正如前文所述，`filename*`遵守的是[RFC 5987] 中定义的编码规则，在[RFC 5987] 3.2中定义了必须支持的字符集：

```java
recipients implementing this specification
MUST support the character sets "ISO-8859-1" and "UTF-8".
```

并且在[RFC 5987] 3.2.1规定，百分号编码遵从 [RFC 3986](https://tools.ietf.org/html/rfc3986).section 2.1中的定义，摘录如下：

```java
A percent-encoding mechanism is used to represent a data octet in a
component when that octet's corresponding character is outside the
allowed set or is being used as a delimiter of, or within, the
component.  A percent-encoded octet is encoded as a character
triplet, consisting of the percent character "%" followed by the two
hexadecimal digits representing that octet's numeric value.  For
example, "%20" is the percent-encoding for the binary octet
"00100000" (ABNF: %x20), which in US-ASCII corresponds to the space
character (SP).  Section 2.4 describes when percent-encoding and
decoding is applied.
```

注意了，**[RFC 3986]** 明确规定了**空格 会被百分号编码为`%20`**

而在另一份文档 [RFC 1866](https://tools.ietf.org/html/rfc1866).Section 8.2.1 *The form-urlencoded Media Type* 中却规定：

```java
The default encoding for all forms is `application/x-www-form-
   urlencoded'. A form data set is represented in this media type as
   follows:

        1. The form field names and values are escaped: space
        characters are replaced by `+', and then reserved characters
        are escaped as per [URL]
```

这里要求`application/x-www-form-urlencoded`类型的消息中，空格要被替换为`+`,其他字符按照[URL]中的定义来转义，其中的[URL]指向的是[RFC 1738](https://tools.ietf.org/html/rfc1738) 而它的修订版中和 URL 有关的最新文档恰恰就是 **[RFC 3986]**

这也就是为什么很多文档中描述空格(white space)的百分号编码结果都是 `+`或`%20`，如：

w3schools:

```
URL encoding normally replaces a space with a plus (+) sign or with %20.
```

MDN:

```
Depending on the context, the character ' ' is translated to a '+' (like in the percent-encoding version used in an application/x-www-form-urlencoded message), or in '%20' like on URLs.
```

那么问题来了，开发过程中，对于空格符的百分号编码我们应该怎么处理？

课代表建议大家遵循最新文档，因为 [RFC 1866] 中定义的情况仅适用于`application/x-www-form-urlencoded`类型， 就百分号编码的定义来说，我们应该以 **[RFC 3986]** 为准，所以，任何需要百分号编码的地方，都应该将空格符 百分号编码为`%20`，stackoverflow 上也有支持此观点的答案：[When to encode space to plus (+) or %20?](https://stackoverflow.com/questions/2678551/when-to-encode-space-to-plus-or-20)

## 3. 代码实践

有了理论基础，代码写起来就水到渠成了，直接上代码：

```java
@GetMapping("/downloadFile")
public String download(String serverFileName, HttpServletRequest request, HttpServletResponse response) throws IOException {

    request.setCharacterEncoding("utf-8");
    response.setContentType("application/octet-stream");

    String clientFileName = fileService.getClientFileName(serverFileName);
    // 对真实文件名进行百分号编码
    String percentEncodedFileName = URLEncoder.encode(clientFileName, "utf-8")
            .replaceAll("\\+", "%20");

    // 组装contentDisposition的值
    StringBuilder contentDispositionValue = new StringBuilder();
    contentDispositionValue.append("attachment; filename=")
            .append(percentEncodedFileName)
            .append(";")
            .append("filename*=")
            .append("utf-8''")
            .append(percentEncodedFileName);
    response.setHeader("Content-disposition",
            contentDispositionValue.toString());
    
    // 将文件流写到response中
    try (InputStream inputStream = fileService.getInputStream(serverFileName);
         OutputStream outputStream = response.getOutputStream()
    ) {
        IOUtils.copy(inputStream, outputStream);
    }

    return "OK!";
}
```

代码很简单，其中有两点需要说明一下：

1. `URLEncoder.encode(clientFileName, "utf-8")`方法之后，为什么还要`.replaceAll("\\+", "%20")`。

   正如前文所述，我们已经明确，任何需要百分号编码的地方，都应该把 空格符编码为 `%20`，而`URLEncoder`这个类的说明上明确标注其会将空格符转换为`+`:

   > The space character "  " is converted into a plus sign "{@code +}".

   其实这并不怪 JDK，因为它的备注里说明了其遵循的是`application/x-www-form-urlencoded`( PHP 中也有这么一个函数，也是这么个套路)

   > Translates a string into {@code application/x-www-form-urlencoded} format using a specific encoding scheme. This method uses the

   所以这里我们用`.replaceAll("\\+", "%20")` 把`+`号处理一下，使其完全符合 **[RFC 3986]** 的百分号编码规范。这里为了方便说明问题，把所有操作都展现出来了。当然，你完全可以自己实现一个`PercentEncoder`类，丰俭由人。

2. [RFC 6266] 标准中`filename=`的`value`是不需要编码的，这里的`filename=`后面的 value 为什么要百分号编码？

   回顾 [RFC 6266] 文档， `filename`和`filename*`同时出现时取后者，浏览器太老不支持新标准时取前者。

   目前主流的浏览器都采用自升级策略，所以大部分都支持新标准------除了老版本IE。老版本的IE对 value 的处理策略是 进行百分号解码 并使用。所以这里专门把`filename=`的`value`进行百分号编码，用来兼容老版本 IE。

   PS：课代表实测 IE11 及 Edge 已经支持新标准了。

   由于 filename* 是后来才定义的，许多老的浏览器并不支持，所以文档规定，当二者同时出现在头字段中时，需要采用 filename* ，忽略filename。
   通过使用filename兼容老IE， filename* 兼容新浏览器，从而实现对主流浏览器的兼容

   例：

   ```
    Content-Disposition: attachment;
                         filename="EURO rates";
                         filename*=utf-8''%e2%82%ac%20rates
   ```

## 4. 浏览器测试

根据下图 statcounter 统计的 2019 年中国市场浏览器占有率，课代表设计了一个包含中文，英文，空格的文件名 `下载-down test .txt`用来测试

![img](https://img2020.cnblogs.com/blog/1181064/202008/1181064-20200812194057839-955114611.png)

测试结果：

| Browser         | Version        | pass |
| --------------- | -------------- | ---- |
| Chrome          | 84.0.4147.125  | true |
| UC              | V6.2.4098.3    | true |
| Safari          | 13.1.2         | true |
| QQ Browser      | 10.6.1(4208)   | true |
| IE              | 7-11           | true |
| Firefox         | 79.0           | true |
| Edge            | 44.18362.449.0 | true |
| 360安全浏览器12 | 12.2.1.362.0   | true |
| Edge(chromium)  | 84.0.522.59    | true |

根据测试结果可知：基本已经能够兼容市面上所有主流浏览器了。

## 5.总结

回顾本文内容，其实就是浏览器兼容性问题引发的附件名乱码，为了解决这个问题，查阅了两类标准文档：

1. HTTP 响应头相关标准

   [RFC 6266]、[RFC 1866]

2. 编码标准

   [RFC 5987]、[RFC 2231]、[3986]、[1738]

我们以 [RFC 6266] 为切入点，全文总共引用了 6 个 [RFC] 相关文档，引用都标明了出处，感兴趣的同学可以跟着文章思路阅读一下原文档，相信你会对这个问题有更深入的理解。文中代码已上传 [github](https://github.com/zhengxl5566/springboot-demo)

最后不禁要感叹一下：规范真是个好东西，它就像 Java 语言中的 `interface`，只制定标准，具体实现留给大家各自发挥。

如果觉得本文对你有帮助，欢迎收藏、分享、在看三连

## 6.参考资料

[1]RFC 6266: *https://tools.ietf.org/html/rfc6266*

[2]RFC 5987: *https://tools.ietf.org/html/rfc5987*

[3]RFC 2231: *https://tools.ietf.org/html/rfc2231*

[4]RFC 3986: *https://tools.ietf.org/html/rfc3986*

[5]RFC 1866: *https://tools.ietf.org/html/rfc1866*

[6]RFC 1738: *https://tools.ietf.org/html/rfc1738*

[7]When to encode space to plus (+) or %20?: *https://stackoverflow.com/questions/2678551/when-to-encode-space-to-plus-or-20*



----



# [在浏览器中通过response.setHeader实现图片显示和文件下载][https://blog.csdn.net/weixin_45583017/article/details/100862682]

## 1、图片显示

```java
response.setHeader("Content-type" , "jpeg");

 File file = new File("E:/Javacode/exercise/12.jpg");

 // 1) 读取本地文件
 FileInputStream in = new FileInputStream(file);

 //定义个输出流
 ServletOutputStream out = response.getOutputStream();

 //定义容器，指定大小
 byte[] buf = new byte[1024];
 int len = 0;
 // 边读边写
 while( (len=in.read(buf)) != -1) {
     out.write(buf, 0, len);
 }
 in.close();
 out.close();
```



## 2、文件下载

```java
request.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8");

File file = new File("E:/Javacode/exercise/12.jpg");

//如果是中文的图片名的话，必须这样进行包装     先通过GBK进行getBytes，然后通过设置新的ISO8859_1
response.setHeader("content-disposition", "attachment;filename=123.jpg"*//*+new String(file.getName().getBytes("GBK"),"ISO8859_1")*//*);

// 1) 读取本地文件
FileInputStream in = new FileInputStream(file);

// 2) 写出给浏览器（字节内容）
OutputStream out = response.getOutputStream();
byte[] buf = new byte[1024];

int len = 0;
// 边读边写
while( (len=in.read(buf)) != -1) {
    out.write(buf, 0, len);
}

// 关闭
in.close();
out.close();
```



## 3、使用IOUtils工具类来实现文件下载

![在这里插入图片描述](response.setHeader()下载的用法.assets/20190916213934682.png)
注：使用idea需要导入commons-io jar包

```java
//获取要下载的文件名称
String fileName = request.getParameter("file");

//获取要下载的文件类型 （可省略）
String mimeType = getServletContext().getMimeType(fileName);

//告诉浏览器要下载文件的类型（可省略）
response.setHeader("Content-Type", mimeType);

//告诉浏览器是下载文件，不是解析文件
    //先使用utf-8对文件名称进行编码
fileName = URLEncoder.encode(fileName, "utf-8");
    //告诉浏览器是下载文件，不是解析文件
response.setHeader("Content-Disposition", "attachment;filename=" + fileName);
    //先使用utf-8对文件名称进行解码
fileName = URLDecoder.decode(fileName, "utf-8");

//获取到要下载文件的真实路径
String realPath = getServletContext().getRealPath("/download/" + fileName);

//使用输入输出流，完成文件的下载---关闭
FileInputStream is  = new FileInputStream(realPath);
OutputStream os = response.getOutputStream();
IOUtils.copy(is, os);
is.close();
```

**jsp文件**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
</head>
<body>
<a href='/Upload/Respond?file=abc.PNG'>abc.PNG</a><br>
<a href='/Upload/Respond?file=哈哈.zip'>哈哈.zip</a>

</body>
</html>
```



# [Spring mvc的文件上传](http://t.zoukankan.com/javawebsoa-p-3037466.html)

使用spring MVC框架进行文件上传，步骤如下：

首先向dispatcher-servlet.xml添加下面代码：

```xml
<bean  id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver">  
                    <property name="maxUploadSize" value="1024000000"/>  
                    <property name="resolveLazily" value="true"/>  
                    <property name="maxInMemorySize" value="4096"/>  
</bean>  
```

控制类controller的代码如下：

```java
@RequestMapping(value = "upload", method = RequestMethod.POST)
    public String upload(HttpServletRequest request, HttpServletResponse response) {
        FileOutputStream fileOutputStream = null;
        try {
            MultipartHttpServletRequest multipartHttpservletRequest = (MultipartHttpServletRequest) request;
            MultipartFile multipartFile = multipartHttpservletRequest.getFile("uploadFile");
            String originalFileName = multipartFile.getOriginalFilename();
            File file = new File("../webapps/upload");
            if (!file.exists()) {
                file.mkdir();
            }
            System.out.println(file.getAbsolutePath() + "\t" + originalFileName);
            fileOutputStream = new FileOutputStream(file + "/" + originalFileName);
            fileOutputStream.write(multipartFile.getBytes());
            fileOutputStream.flush();
        } catch (IOException ex) {
            Logger.getLogger(ExcelController.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                fileOutputStream.close();
            } catch (IOException ex) {
                Logger.getLogger(ExcelController.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return "success";
    }
```

或者入参里直接用文件类型参数MultipartFile接收

```
public Map upload(MultipartFile file,HttpServletRequest request) throws IOException {
  String oname = file.getOriginalFilename();
  String originalFilename = file.getOriginalFilename().replaceAll(".xls","");
      
}
```

上传页面index.jsp如下：

```jsp
    <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">  
    <html>  
    <head>  
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">  
    <title>上传</title>  
    </head>  
    <body>  
        <div>  
            <form  enctype="multipart/form-data"  method="post" action="upload">  
                <input type="file" name="uploadFile" />  
                <button onclick="this.form.submit();">上传</button>  
            </form>  
        </div>  
    </body>  
    </html>  
```





# [文件下载响应头的设置](https://www.jianshu.com/p/d4a85d025768)

content-type 指示响应内容的格式

content-disposition 指示如何处理响应内容，一般有两种方式：

- inline：直接在页面中打开文件显示
- attchment：以附件形式下载文件

Server 端实现文件下载
打开文件，将文件内容写入到 reponse 中
设置 Response header（content-type,content-disposition）

```java
Content-Type: application/octet-stream
Content-Disposition: attachment;filename=2018-03-03_15-47-45--2019-03-03_15-48-13--73c75b84-ba2a-470f-a713-07216fcd214b.xlsx
```



## 1. Content-Disposition的作用

**Content-disposition是MIME协议的扩展，MIME协议指示MIME用户代理如何显示附加的文件。当Internet Explorer接收到头时，他会激活文件下载对话框，它的文件名框自动填充headers指定的文件名。**

服务器向浏览器发送文件时，如果是浏览器支持的文件类型，一般会默认使用浏览器打开，比如`txt`、`jpg`等。如果需要提示用户保存，就要利用**Content-Disposition**进行处理，（敲黑板，划重点）关键在于一定要加上**attachment** `[附件] [əˈtætʃmənt]`。

**例如**
 Response.AppendHeader("ContentDisposition","attachment;filename=FileName.txt");

> 这样的话，浏览器在打开的时候回提示保存还是打开，即使选择打开，也会使用相关联的程序，比如记事本打开，而不是IE直接打开。

Content-Disposition就是当用户想把请求所得的内容存为一个文件的时候提供一个默认的文件名。
 **具体的定义如下：**

```java
//content-disposition的定义
content-disposition ="Content-Disposition" ":"
                     disposition-type
                     *(";" disposition-param)
//disposition-type的定义
disposition-type="attachment"|disp-extension-token
//disposition-param的定义
disposition-param=filename-param|disp-extension-parm
//filename-param的定义
filename-param= "filename"  "=" quoted-string
//disp-extension-token的定义
disp-extension-token = token
//disp-extension-parm
token "=" ( token | quoted-string )
```

例如：
 Content-Disposition:attachment;filename="filename.xlsx;"

注意点：
 当然filename参数可以包含路径信息，但User-Agnet会忽略这些信息，只会把路径信息的最后一部分作为文件名。当响应类型为`application/octet-stream`情况下使用上面的头信息的话，那么就不能直接显示内容，而是弹出一个"文件下载"的对话框，接下来就是用户决定“打开”还是“保存”了。

## 2. 下载文件中文乱码

> Content-Disposition如何适配各个浏览器以及解决中文乱码问题。

[IE浏览器下载乱码问题](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Fdreaming317%2Farticle%2Fdetails%2F82591600)
 总体下来就是这么几点：

> 1. 两个IE11在使用第一个方法下载文件时中文文件名都会乱码，而使用第二个方法下载时其中一个IE11中文不会乱码，另一个IE11则会乱码；
> 2. 文件名中存在空格时两个IE11浏览器下载下来文件文件名空格会变成+号，其他浏览器没有这个问题；
> 3. 火狐浏览器下载时遇到文件名中有空格时下载下来的文件的文件名第一个空格后面的文字都会丢失。

1. **老版IE的USER-AGENT参数中含有MISE关键字，但是IE11之后浏览器的USER-AGENT中去掉了MISE关键字。`【IE11：Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko；】` **
2. IE下载文件名存在+号，是因为URLEncoder函数在对字符串进行转码后将空格替换成了+号，IE直接把+号显示出来。解决办法就是对文件名进行转码之后，使用replace方法将+号替换成%20即可，浏览器会将%20转换成空格输出。
3. 对于第三个问题则是因为代码在set响应头时Content-Disposition参数的attachment;filename=等号后面文件名字符串没有使用**双引号**括起来，火狐浏览器对于遇到文件名有空格时认为空格前的字符是一个完整的字符串。故下载下来文件时文件名就只剩空格前的那几个字了。解决办法就是：在filename两边加上双引号并加反斜杠转义。

**编码类**

```dart
 public static String toUtf8String(String fileName, HttpServletRequest request) throws Exception {
        final String userAgent = request.getHeader("USER-AGENT");
        String finalFileName = null;
        if (StringUtils.contains(userAgent, "MSIE")||StringUtils.contains(userAgent, "Trident")) {// IE浏览器（旧版/新版）
            finalFileName = URLEncoder.encode(fileName, "UTF8");
        } else if (StringUtils.contains(userAgent, "Mozilla")) {// google,火狐浏览器
            finalFileName = new String(fileName.getBytes(), "ISO8859-1");
        } else {
            finalFileName = URLEncoder.encode(fileName, "UTF8");// 其他浏览器
            //或者HttpUtility.UrlEncode(filename, System.Text.Encoding.UTF8);
        }
        return finalFileName;
    }

@RequestMapping("/downExcel")
    public void downExcel(HttpServletRequest request, HttpServletResponse response) {
            out = response.getOutputStream();// 取得输出流
            response.reset();// 清空输出流
            response.setHeader("Content-disposition",
                    "attachment; filename=" + ExcelUtil.toUtf8String(fileName, request) + ".xlsx");// 设定输出文件头
            response.setContentType("application/msexcel");// 定义输出类型
        //将数据写入输出流
        //TODO
      }
```



# 常见的MIME类型(通用型)：

　　超文本标记语言文本 .html text/html

　　xml文档 .xml text/xml

　　XHTML文档 .xhtml application/xhtml+xml

　　普通文本 .txt text/plain

　　RTF文本 .rtf application/rtf

　　PDF文档 .pdf application/pdf

　　Microsoft Word文件 .word application/msword

　　PNG图像 .png image/png

　　GIF图形 .gif image/gif

　　JPEG图形 .jpeg,.jpg image/jpeg

　　au声音文件 .au audio/basic

　　MIDI音乐文件 mid,.midi audio/midi,audio/x-midi

　　RealAudio音乐文件 .ra, .ram audio/x-pn-realaudio

　　MPEG文件 .mpg,.mpeg video/mpeg

　　AVI文件 .avi video/x-msvideo

　　GZIP文件 .gz application/x-gzip

　　TAR文件 .tar application/x-tar

　　任意的二进制流数据 application/octet-stream

 

2，MIME类型参考手册：

| 扩展名   | 类型/子类型                             |
| :------- | :-------------------------------------- |
| 二进制流 | application/octet-stream                |
| 323      | text/h323                               |
| acx      | application/internet-property-stream    |
| ai       | application/postscript                  |
| aif      | audio/x-aiff                            |
| aifc     | audio/x-aiff                            |
| aiff     | audio/x-aiff                            |
| asf      | video/x-ms-asf                          |
| asr      | video/x-ms-asf                          |
| asx      | video/x-ms-asf                          |
| au       | audio/basic                             |
| avi      | video/x-msvideo                         |
| axs      | application/olescript                   |
| bas      | text/plain                              |
| bcpio    | application/x-bcpio                     |
| bin      | application/octet-stream                |
| bmp      | image/bmp                               |
| c        | text/plain                              |
| cat      | application/vnd.ms-pkiseccat            |
| cdf      | application/x-cdf                       |
| cer      | application/x-x509-ca-cert              |
| class    | application/octet-stream                |
| clp      | application/x-msclip                    |
| cmx      | image/x-cmx                             |
| cod      | image/cis-cod                           |
| cpio     | application/x-cpio                      |
| crd      | application/x-mscardfile                |
| crl      | application/pkix-crl                    |
| crt      | application/x-x509-ca-cert              |
| csh      | application/x-csh                       |
| css      | text/css                                |
| dcr      | application/x-director                  |
| der      | application/x-x509-ca-cert              |
| dir      | application/x-director                  |
| dll      | application/x-msdownload                |
| dms      | application/octet-stream                |
| doc      | application/msword                      |
| dot      | application/msword                      |
| dvi      | application/x-dvi                       |
| dxr      | application/x-director                  |
| eps      | application/postscript                  |
| etx      | text/x-setext                           |
| evy      | application/envoy                       |
| exe      | application/octet-stream                |
| fif      | application/fractals                    |
| flr      | x-world/x-vrml                          |
| gif      | image/gif                               |
| gtar     | application/x-gtar                      |
| gz       | application/x-gzip                      |
| h        | text/plain                              |
| hdf      | application/x-hdf                       |
| hlp      | application/winhlp                      |
| hqx      | application/mac-binhex40                |
| hta      | application/hta                         |
| htc      | text/x-component                        |
| htm      | text/html                               |
| html     | text/html                               |
| htt      | text/webviewhtml                        |
| ico      | image/x-icon                            |
| ief      | image/ief                               |
| iii      | application/x-iphone                    |
| ins      | application/x-internet-signup           |
| isp      | application/x-internet-signup           |
| jfif     | image/pipeg                             |
| jpe      | image/jpeg                              |
| jpeg     | image/jpeg                              |
| jpg      | image/jpeg                              |
| js       | application/x-javascript                |
| latex    | application/x-latex                     |
| lha      | application/octet-stream                |
| lsf      | video/x-la-asf                          |
| lsx      | video/x-la-asf                          |
| lzh      | application/octet-stream                |
| m13      | application/x-msmediaview               |
| m14      | application/x-msmediaview               |
| m3u      | audio/x-mpegurl                         |
| man      | application/x-troff-man                 |
| mdb      | application/x-msaccess                  |
| me       | application/x-troff-me                  |
| mht      | message/rfc822                          |
| mhtml    | message/rfc822                          |
| mid      | audio/mid                               |
| mny      | application/x-msmoney                   |
| mov      | video/quicktime                         |
| movie    | video/x-sgi-movie                       |
| mp2      | video/mpeg                              |
| mp3      | audio/mpeg                              |
| mpa      | video/mpeg                              |
| mpe      | video/mpeg                              |
| mpeg     | video/mpeg                              |
| mpg      | video/mpeg                              |
| mpp      | application/vnd.ms-project              |
| mpv2     | video/mpeg                              |
| ms       | application/x-troff-ms                  |
| mvb      | application/x-msmediaview               |
| nws      | message/rfc822                          |
| oda      | application/oda                         |
| p10      | application/pkcs10                      |
| p12      | application/x-pkcs12                    |
| p7b      | application/x-pkcs7-certificates        |
| p7c      | application/x-pkcs7-mime                |
| p7m      | application/x-pkcs7-mime                |
| p7r      | application/x-pkcs7-certreqresp         |
| p7s      | application/x-pkcs7-signature           |
| pbm      | image/x-portable-bitmap                 |
| pdf      | application/pdf                         |
| pfx      | application/x-pkcs12                    |
| pgm      | image/x-portable-graymap                |
| pko      | application/ynd.ms-pkipko               |
| pma      | application/x-perfmon                   |
| pmc      | application/x-perfmon                   |
| pml      | application/x-perfmon                   |
| pmr      | application/x-perfmon                   |
| pmw      | application/x-perfmon                   |
| pnm      | image/x-portable-anymap                 |
| pot,     | application/vnd.ms-powerpoint           |
| ppm      | image/x-portable-pixmap                 |
| pps      | application/vnd.ms-powerpoint           |
| ppt      | application/vnd.ms-powerpoint           |
| prf      | application/pics-rules                  |
| ps       | application/postscript                  |
| pub      | application/x-mspublisher               |
| qt       | video/quicktime                         |
| ra       | audio/x-pn-realaudio                    |
| ram      | audio/x-pn-realaudio                    |
| ras      | image/x-cmu-raster                      |
| rgb      | image/x-rgb                             |
| rmi      | audio/mid                               |
| roff     | application/x-troff                     |
| rtf      | application/rtf                         |
| rtx      | text/richtext                           |
| scd      | application/x-msschedule                |
| sct      | text/scriptlet                          |
| setpay   | application/set-payment-initiation      |
| setreg   | application/set-registration-initiation |
| sh       | application/x-sh                        |
| shar     | application/x-shar                      |
| sit      | application/x-stuffit                   |
| snd      | audio/basic                             |
| spc      | application/x-pkcs7-certificates        |
| spl      | application/futuresplash                |
| src      | application/x-wais-source               |
| sst      | application/vnd.ms-pkicertstore         |
| stl      | application/vnd.ms-pkistl               |
| stm      | text/html                               |
| svg      | image/svg+xml                           |
| sv4cpio  | application/x-sv4cpio                   |
| sv4crc   | application/x-sv4crc                    |
| swf      | application/x-shockwave-flash           |
| t        | application/x-troff                     |
| tar      | application/x-tar                       |
| tcl      | application/x-tcl                       |
| tex      | application/x-tex                       |
| texi     | application/x-texinfo                   |
| texinfo  | application/x-texinfo                   |
| tgz      | application/x-compressed                |
| tif      | image/tiff                              |
| tiff     | image/tiff                              |
| tr       | application/x-troff                     |
| trm      | application/x-msterminal                |
| tsv      | text/tab-separated-values               |
| txt      | text/plain                              |
| uls      | text/iuls                               |
| ustar    | application/x-ustar                     |
| vcf      | text/x-vcard                            |
| vrml     | x-world/x-vrml                          |
| wav      | audio/x-wav                             |
| wcm      | application/vnd.ms-works                |
| wdb      | application/vnd.ms-works                |
| wks      | application/vnd.ms-works                |
| wmf      | application/x-msmetafile                |
| wps      | application/vnd.ms-works                |
| wri      | application/x-mswrite                   |
| wrl      | x-world/x-vrml                          |
| wrz      | x-world/x-vrml                          |
| xaf      | x-world/x-vrml                          |
| xbm      | image/x-xbitmap                         |
| xla      | application/vnd.ms-excel                |
| xlc      | application/vnd.ms-excel                |
| xlm      | application/vnd.ms-excel                |
| xls      | application/vnd.ms-excel                |
| xlt      | application/vnd.ms-excel                |
| xlw      | application/vnd.ms-excel                |
| xof      | x-world/x-vrml                          |
| xpm      | image/x-xpixmap                         |
| xwd      | image/x-xwindowdump                     |
| z        | application/x-compress                  |
| zip      | application/zip                         |