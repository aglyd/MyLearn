# [Response 输出方式，输出字符和文件流][]

在项目中之前一直是返回普通文本，这时候使用 print()和write() 方法都是可以实现的，那这两个方法有什么区别呢？

```java
response.getWriter()返回的是PrintWriter，这是一个打印输出流。writer.print(""),writer.flush,writer.close
 
response.getWriter().print(),不仅可以打印输出文本格式的（包括html标签），
还可以将一个对象以默认的编码方式转换为二进制字节输出
 
response.getWriter().writer(),只能打印输出文本格式的（包括html标签），不可以打印对象。
```

现在我们项目中，有一个需求是；A项目在内网不可访问外网，B项目即可访问外网又可访问外网，C项目部署在外网，这时候 A项目要调用 C项目的一个接口，需要经过B项目中转一下。

 

 普通的文本返回，C项目返回B项目接收再response.getWriter().writer()回去 A项目就能收到正常响应；这个方法只能写字符串。如果要写字节，比如，传个图片，怎么办呢？就要靠response.getOutputStream()

```java
private void downloadFile(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String wechatUrl = request.getParameter("wechatUrl");
        String access_token = request.getParameter("access_token");
        String mediaId = request.getParameter("media_id");
        System.out.println("===>mediaId:" + mediaId);
        StringBuffer sb = new StringBuffer();
        sb.append(wechatUrl).append("?access_token=").append(access_token).append("&media_id=").append(mediaId);
        URL _url = new URL(sb.toString());
        HttpURLConnection conn = (HttpURLConnection) _url.openConnection();
        // 连接超时
        conn.setConnectTimeout(25000);
        // 读取超时 --服务器响应比较慢，增大时间
        conn.setReadTimeout(25000);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "Keep-Alive");
        conn.setRequestProperty("User-Agent", HttpRequest.DEFAULT_USER_AGENT);
        conn.setDoOutput(true);
        conn.setDoInput(true);
        conn.connect();
        String ds = conn.getHeaderField("Content-disposition");
        response.setHeader("Content-disposition", ds);
 
        OutputStream outputStream = null;
        try {
            outputStream = response.getOutputStream();
            InputStream istram = conn.getInputStream();
            int read;
            while ((read = istram.read()) != -1) {
                outputStream.write(read);
            }
            outputStream.flush();
        } catch (Exception e) {
 
        } finally {
            if (outputStream != null) {
                try {
                    outputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (conn != null) {
                conn.disconnect();
            }
        }
    }
```

当然，response.getOutputStream()也可以打印字符串

```java
 response.setContentType("text/html;charset=utf-8");
 byte[] error = new String("<font style='font-family: 宋体;font-size: 18px;color:red;font-weight: normal;' >下载失败,"+e.getMessage()+"</font>").getBytes();
response.getOutputStream().write(error);
```

打印图片则为：

```java
 response.setContentType("image/jpeg");

            FileInputStream fos = new FileInputStream(file);

            byte[] bytes = new byte[1024*1024];

            int length = 0;

            while((length=fos.read(bytes))!=-1){
                response.getOutputStream().write(bytes,0,length);///打印流
}
```

