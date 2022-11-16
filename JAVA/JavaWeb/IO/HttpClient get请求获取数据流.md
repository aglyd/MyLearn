# [HttpClient get请求获取数据流](https://www.cnblogs.com/gongxr/p/10935824.html)

HttpClient get请求获取数据流，将数据保存为文件

```java
public String getStreamFile(String url) throws Exception {
        HttpClient client = HttpClientUtils.createSSLInsecureClient();
        HttpGet get = new HttpGet(url);
        HttpResponse response = client.execute(get);
//        获取消息头
//        Header[] headers = response.getAllHeaders();
//        for (Header header : headers) {
//            System.out.println(MessageFormat.format("header:{0}={1}", header.getName(), header.getValue()));
//        }
        String fileName = response.getHeaders("Content-Disposition")[0].getValue().split("filename=")[1];
        logger.info("文件名为" + fileName);

        if (response.getStatusLine().getStatusCode() == 200) {
            //得到实体
            HttpEntity entity = response.getEntity();
            byte[] data = EntityUtils.toByteArray(entity);
            //存入磁盘
            FileOutputStream fos = new FileOutputStream(fileName);
            fos.write(data);
            fos.close();
            logger.info("文件下载成功！");
        } else {
            throw new Exception("文件下载失败！Http状态码为" + response.getStatusLine().getStatusCode());
        }
        return fileName;
    }
```



## 实例：

背景：前台调用后台生成Excel导出，中间经过网关项目转发。

后台生成Excel的workBook，workBook.write(out)写入response.getOutputStream()的out，返回给网关项目，网关用HTTP client调用，取出响应数据（文件数据字节数组），再写入返回给前端的response.getOutputStream()响应流，相当于写了两次响应流（第一次返回给网关，第二次返回给前端）

```java
//方式一：
OutputStream out = response.getOutputStream();
//生成Excel...返回给网关的out
workBook.write(out);



//网关执行转调后台接口获取响应结果
CloseableHttpResponse responseResult = httpclient.execute(httpGet);
//获取响应中的数据（如果是常规实体类对象可用EntityUtils.toString()拿到数据的jsonstring（可用String类接收），再转为jsonobject即可）
byte[] resultByte = EntityUtils.toByteArray(responseResult.getEntity());
//写入返回给前端的响应流
outputStream = response.getOutputStream();
outputStream.write(resultByte);


//方式二：或者也可以写Excel生成到服务器本地，再返回文件地址给前端，前端再调用下载接口下载文件
OutputStream out = new FileOutputStream(new File("filePath"));// 创建文件输出流，准备输出电子表格
//生成Excel...
workBook.write(out);


```



-----



# [java – 如何在HttpClient.execute()完成获取大型请求中的所有内容时如何判断？][https://blog.lzys.cc/p/965848.html]

使用org.apache.http.client.HttpClient,我可以向大小为1kb的URL发出请求,整个响应包含在HttpResponse中：



```java
HttpClient client = new DefaultHttpClient();
HttpGet request = new HttpGet("http://10.16.83.67/1kb.log");
HttpResponse response = null;
BufferedReader rd = null;

response = client.execute(request);
```

然后我可以从响应中获取HttpEntity：

```java
HttpEntity entity = response.getEntity();
rd = new BufferedReader(new InputStreamReader(entity.getContent()));
```

然后,使用BufferedReader 

```java
while ((line = rd.readLine()) != null) {
 // ... parse or whatever
}
```

我正在看WireShark,我看到上面代码的每个方向都有一个传输：日志文件的请求,然后整个日志在响应中传递.

但是,如果我要求更大的东西,例如我的1MB日志文件,我会看到一些非常不同的东西.数据被分块为帧,然后在rd.readLine()循环内通过线路流式传输.

似乎第一个kb左右包含在初始响应中.但是当readLine()运行时,它会向服务器发出其他请求,并将数据流式传输到套接字.如果网络连接中断,我会收到IO错误.对于大型请求,entity.isStreaming()为true.

这是一个异步调用(在Android上是必需的,因为无法在UI线程上进行网络调用)但我不想继续,直到我确定我已经完成了从此请求接收到的所有数据.不幸的是,仅仅等待一段时间,然后继续并希望最好的是不是一种选择.

我的问题是：我的HttpClient,HttpGet,HttpResponse或HttpEntity对象是否知道它们何时完成从此请求接收数据？或者我必须依靠BufferedReader知道流何时关闭？

最佳答案

你在使用AsyncTask吗？否则你可以去做

```java
private class DownloadFilesTask extends AsyncTask<URL, Integer, Long> {
 protected Long doInBackground(URL... urls) {}
```

//在上面的方法中执行所有http请求

```java
 protected void onProgressUpdate(Integer... progress) {
     setProgressPercent(progress[0]);
 }

 protected void onPostExecute(Long result) {
     showDialog("I pop up when all the code in the DoInbackground is finished");
 }
```