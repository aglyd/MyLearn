一、[HttpClient+fastJson 总结与案例 ](https://www.cnblogs.com/fatCat1/p/11904954.html)

# HttpCLient是什么

Apache Jakarta Common 下的子项目
支持 HTTP 协议的客户端编程工具包
支持 HTTP 协议最新的版本

 

# 怎么利用HttpClient写自动化

简化重点：

1、接口请求与接口响应（先要理解http协议），常见的以下两种请求方式

  Get

　Post

2、数据解析，学会以下用法

　JsonObject

　JsonArray

3、结果断言

![img](https://img2018.cnblogs.com/i-beta/1718450/201911/1718450-20191121204334469-1902582332.png)

 

![img](https://img2018.cnblogs.com/i-beta/1718450/201911/1718450-20191121125648251-1441719465.png)

 

# 演示代码片段

这里以https://my.oschina.net/u/3559695/blog/1600534/网页的接口为例 1 @Test

```java
   public void test1() throws IOException {
//      构造数据
        String cookie = "111111";//会定时更新，自己去获取吧～
        //json的写法  => Content-Type:application/json  (传输的数据格式)
//        User user=new User();//需要新建一个User类，命名属性的set方法
//        user.setUserId(3559695);
//        user.setSkillsNum(5);
//        String jsonString=JSON.toJSONString(user); 等同于  String jsonString=" {\"userId\":3559695,\"skillsNum\":5}";
//        System.out.println("打印"+jsonString);
//        StringEntity stringEntity=new StringEntity(jsonString);

        //form的写法 => Content-Type:application/x-www-form-urlencoded
        //携带普通的参数params的方式
        List<NameValuePair> params=new ArrayList<>();
        params.add(new BasicNameValuePair("userId","3559695"));//BasicNameValuePair是存储键值对的类
        params.add(new BasicNameValuePair("skillsNum","5"));
        String jsonString=EntityUtils.toString(new UrlEncodedFormEntity(params, Consts.UTF_8));//这里就是：userId=3559695&skillsNum=5
        System.out.println(jsonString);

        //1、打开浏览器
        CloseableHttpClient httpClient = HttpClients.createDefault();
        //2、创建httpGet对象
        HttpPost httpPost = new HttpPost("https://my.oschina.net/u/3559695/radar/getUserPortraitRadarMap");
        httpPost.addHeader("Cookie", cookie);
//        httpPost.addHeader("Accept-Encoding","gzip, deflate, br");
        httpPost.addHeader("Content-Type", "application/x-www-form-urlencoded");
        httpPost.addHeader("User-Agent",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36");
//        httpPost.setEntity(stringEntity); 这个是json格式的方式
        httpPost.setEntity(new UrlEncodedFormEntity(params,"UTF-8"));
        //3、发送请求，获取响应模型
        CloseableHttpResponse httpResponse = httpClient.execute(httpPost);
        //4、从响应模型获取响应实体
        HttpEntity httpEntity = httpResponse.getEntity();
        //5、将响应实体转为String
        if (httpEntity != null){
            String str = EntityUtils.toString(httpEntity);
            System.out.println(str);
            //6、String解析为JsonObject、JsonArray
            JSONObject jsonObject=JSONObject.parseObject(str);
            System.out.println(jsonObject);
            System.out.println("输出状态码code："+jsonObject.getString("code"));
            System.out.println(jsonObject.get(1));
            JSONObject jsonObject1=jsonObject.getJSONObject("result");
            System.out.println(jsonObject1);
            JSONArray jsonArray=JSONArray.parseArray(jsonObject1.getString("skills"));
            System.out.println(jsonArray);
            System.out.println(jsonArray.get(1));

            //测试
            Assert.assertEquals(jsonObject.getString("code"),"1");
            Assert.assertTrue(jsonArray.get(1).equals("社区影响力"));
            Assert.assertNotNull(jsonObject.getString("result"));
            Assert.assertNotSame(jsonObject1.getString("skills"),jsonArray);

        }else EntityUtils.consume(httpEntity);
        //释放资源
        httpResponse.close();
        httpClient.close();
    }
```

 url响应结果：

```json
{"code":1,"message":"success","result":{"skills":["社区活跃度","社区影响力","技术贡献度","活动活跃性","开源贡献度","学习积极性"],"maxSkillScore":100,"skillsScore":[11.932739749333637,10.202996646175928,10.279304325337817,5.0,5.0,12.192893401015228]},"time":"2019-11-21 12:45:10"}

```



----

# 二、[HttpClient用法--这一篇全了解（内含例子）](https://blog.csdn.net/w372426096/article/details/82713315)

HttpClient相比传统JDK自带的URLConnection，增加了易用性和灵活性，它不仅使客户端发送Http请求变得容易，而且也方便开发人员测试接口（基于Http协议的），提高了开发的效率，也方便提高代码的健壮性。因此熟练掌握HttpClient是很重要的必修内容，掌握HttpClient后，相信对于Http协议的了解会更加深入。

**org.apache.commons.httpclient.HttpClient**与**org.apache.http.client.HttpClient**的区别

Commons的HttpClient项目现在是生命的尽头，不再被开发,  已被Apache HttpComponents项目HttpClient和HttpCore  模组取代，提供更好的性能和更大的灵活性。  

## 一、简介

HttpClient是Apache Jakarta Common下的子项目，用来提供高效的、最新的、功能丰富的支持HTTP协议的客户端编程工具包，并且它支持HTTP协议最新的版本和建议。HttpClient已经应用在很多的项目中，比如Apache Jakarta上很著名的另外两个开源项目Cactus和HTMLUnit都使用了HttpClient。

下载地址: http://hc.apache.org/downloads.cgi

## 二、特性

1. 基于标准、纯净的java语言。实现了Http1.0和Http1.1

2. 以可扩展的面向对象的结构实现了Http全部的方法（GET, POST, PUT, DELETE, HEAD, OPTIONS, and TRACE）。

3. 支持HTTPS协议。

4. 通过Http代理建立透明的连接。

5. 利用CONNECT方法通过Http代理建立隧道的https连接。

6. Basic, Digest, NTLMv1, NTLMv2, NTLM2 Session, SNPNEGO/Kerberos认证方案。

7. 插件式的自定义认证方案。

8. 便携可靠的套接字工厂使它更容易的使用第三方解决方案。

9. 连接管理器支持多线程应用。支持设置最大连接数，同时支持设置每个主机的最大连接数，发现并关闭过期的连接。

10. 自动处理Set-Cookie中的Cookie。

11. 插件式的自定义Cookie策略。

12. Request的输出流可以避免流中内容直接缓冲到socket服务器。

13. Response的输入流可以有效的从socket服务器直接读取相应内容。

14. 在http1.0和http1.1中利用KeepAlive保持持久连接。

15. 直接获取服务器发送的response code和 headers。

16. 设置连接超时的能力。

17. 实验性的支持http1.1 response caching。

18. 源代码基于Apache License 可免费获取。

## 三、使用方法

使用HttpClient发送请求、接收响应很简单，一般需要如下几步即可。

1. 创建HttpClient对象。

2. 创建请求方法的实例，并指定请求URL。如果需要发送GET请求，创建HttpGet对象；如果需要发送POST请求，创建HttpPost对象。

3. 如果需要发送请求参数，可调用HttpGet、HttpPost共同的setParams(HttpParams params)方法来添加请求参数；对于HttpPost对象而言，也可调用setEntity(HttpEntity entity)方法来设置请求参数。

4. 调用HttpClient对象的execute(HttpUriRequest request)发送请求，该方法返回一个HttpResponse。

5. 调用HttpResponse的getAllHeaders()、getHeaders(String name)等方法可获取服务器的响应头；调用HttpResponse的getEntity()方法可获取HttpEntity对象，该对象包装了服务器的响应内容。程序可通过该对象获取服务器的响应内容。

6. 释放连接。无论执行方法是否成功，都必须释放连接

相关jar包

```
commons-cli-1.2.jar  
commons-codec-1.9.jar  
commons-logging-1.2.jar  
fluent-hc-4.5.1.jar  
httpclient-4.5.1.jar  
httpclient-cache-4.5.1.jar  
httpclient-win-4.5.1.jar  
httpcore-4.4.3.jar  
httpcore-ab-4.4.3.jar  
httpcore-nio-4.4.3.jar  
httpmime-4.5.1.jar  
jna-4.1.0.jar  
jna-platform-4.1.0.jar  

```

最简单post请求, 源自 http://my.oschina.net/xinxingegeya/blog/282683

```java
package a;  
   
import java.io.FileInputStream;  
import java.io.IOException;  
import java.util.ArrayList;  
import java.util.List;  
import java.util.Properties;  
   
import org.apache.http.HttpEntity;  
import org.apache.http.HttpResponse;  
import org.apache.http.NameValuePair;  
import org.apache.http.client.HttpClient;  
import org.apache.http.client.config.RequestConfig;  
import org.apache.http.client.entity.UrlEncodedFormEntity;  
import org.apache.http.client.methods.HttpPost;  
import org.apache.http.impl.client.DefaultHttpClient;  
import org.apache.http.message.BasicNameValuePair;  
import org.apache.http.util.EntityUtils;  
   
public class First {  
    public static void main(String[] args) throws Exception{  
        List<NameValuePair> formparams = new ArrayList<NameValuePair>();  
        formparams.add(new BasicNameValuePair("account", ""));  
        formparams.add(new BasicNameValuePair("password", ""));  
        HttpEntity reqEntity = new UrlEncodedFormEntity(formparams, "utf-8");  
    
        RequestConfig requestConfig = RequestConfig.custom()  
        .setConnectTimeout(5000)//一、连接超时：connectionTimeout-->指的是连接一个url的连接等待时间  
                .setSocketTimeout(5000)// 二、读取数据超时：SocketTimeout-->指的是连接上一个url，获取response的返回等待时间  
                .setConnectionRequestTimeout(5000)  
                .build();  
    
        HttpClient client = new DefaultHttpClient();  
        HttpPost post = new HttpPost("http://cnivi.com.cn/login");  
        post.setEntity(reqEntity);  
        post.setConfig(requestConfig);  
        HttpResponse response = client.execute(post);  
    
        if (response.getStatusLine().getStatusCode() == 200) {  
            HttpEntity resEntity = response.getEntity();  
            String message = EntityUtils.toString(resEntity, "utf-8");  
            System.out.println(message);  
        } else {  
            System.out.println("请求失败");  
        }  
    }  
   
}  	
```

## 四、实例

### 4.1  主文件

```java
package com.test;  
      
import java.io.File;  
import java.io.FileInputStream;  
import java.io.IOException;  
import java.io.UnsupportedEncodingException;  
import java.security.KeyManagementException;  
import java.security.KeyStore;  
import java.security.KeyStoreException;  
import java.security.NoSuchAlgorithmException;  
import java.security.cert.CertificateException;  
import java.util.ArrayList;  
import java.util.List;  
import javax.net.ssl.SSLContext;  
import org.apache.http.HttpEntity;  
import org.apache.http.NameValuePair;  
import org.apache.http.ParseException;  
import org.apache.http.client.ClientProtocolException;  
import org.apache.http.client.entity.UrlEncodedFormEntity;  
import org.apache.http.client.methods.CloseableHttpResponse;  
import org.apache.http.client.methods.HttpGet;  
import org.apache.http.client.methods.HttpPost;  
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;  
import org.apache.http.conn.ssl.SSLContexts;  
import org.apache.http.conn.ssl.TrustSelfSignedStrategy;  
import org.apache.http.entity.ContentType;  
import org.apache.http.entity.mime.MultipartEntityBuilder;  
import org.apache.http.entity.mime.content.FileBody;  
import org.apache.http.entity.mime.content.StringBody;  
import org.apache.http.impl.client.CloseableHttpClient;  
import org.apache.http.impl.client.HttpClients;  
import org.apache.http.message.BasicNameValuePair;  
import org.apache.http.util.EntityUtils;  
import org.apache.http.client.config.RequestConfig;  
import org.junit.Test;  
public class HttpClientTest {  
　　//方法见下........  
}  
```



### 4.2  HttpClientUtils工具类

```java
package com.bobo.code.web.controller.technology.httpcomponents;  
   
   
import org.apache.http.HttpEntity;  
import org.apache.http.HttpHost;  
import org.apache.http.HttpResponse;  
import org.apache.http.NameValuePair;  
import org.apache.http.client.HttpClient;  
import org.apache.http.client.config.RequestConfig;  
import org.apache.http.client.methods.HttpUriRequest;  
import org.apache.http.client.methods.RequestBuilder;  
import org.apache.http.conn.routing.HttpRoute;  
import org.apache.http.impl.client.CloseableHttpClient;  
import org.apache.http.impl.client.HttpClientBuilder;  
import org.apache.http.impl.client.HttpClients;  
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;  
import org.apache.http.message.BasicNameValuePair;  
import org.apache.http.util.EntityUtils;  
    
import java.io.IOException;  
import java.util.*;  
    
public class HttpClientUtils {  
    
    private static PoolingHttpClientConnectionManager connectionManager = null;  
    private static HttpClientBuilder httpBuilder = null;  
    private static RequestConfig requestConfig = null;  
    
    private static int MAXCONNECTION = 10;  
    
    private static int DEFAULTMAXCONNECTION = 5;  
    
    private static String IP = "cnivi.com.cn";  
    private static int PORT = 80;  
    
    static {  
        //设置http的状态参数  
        requestConfig = RequestConfig.custom()  
                .setSocketTimeout(5000)  
                .setConnectTimeout(5000)  
                .setConnectionRequestTimeout(5000)  
                .build();  
    
        HttpHost target = new HttpHost(IP, PORT);  
        connectionManager = new PoolingHttpClientConnectionManager();  
        connectionManager.setMaxTotal(MAXCONNECTION);//客户端总并行链接最大数  
        connectionManager.setDefaultMaxPerRoute(DEFAULTMAXCONNECTION);//每个主机的最大并行链接数  
        connectionManager.setMaxPerRoute(new HttpRoute(target), 20);  
        httpBuilder = HttpClients.custom();  
        httpBuilder.setConnectionManager(connectionManager);  
    }  
    
    public static CloseableHttpClient getConnection() {  
        CloseableHttpClient httpClient = httpBuilder.build();  
        return httpClient;  
    }  
    
    
    public static HttpUriRequest getRequestMethod(Map<String, String> map, String url, String method) {  
        List<NameValuePair> params = new ArrayList<NameValuePair>();  
        Set<Map.Entry<String, String>> entrySet = map.entrySet();  
        for (Map.Entry<String, String> e : entrySet) {  
            String name = e.getKey();  
            String value = e.getValue();  
            NameValuePair pair = new BasicNameValuePair(name, value);  
            params.add(pair);  
        }  
        HttpUriRequest reqMethod = null;  
        if ("post".equals(method)) {  
            reqMethod = RequestBuilder.post().setUri(url)  
                    .addParameters(params.toArray(new BasicNameValuePair[params.size()]))  
                    .setConfig(requestConfig).build();  
        } else if ("get".equals(method)) {  
            reqMethod = RequestBuilder.get().setUri(url)  
                    .addParameters(params.toArray(new BasicNameValuePair[params.size()]))  
                    .setConfig(requestConfig).build();  
        }  
        return reqMethod;  
    }  
    
    public static void main(String args[]) throws IOException {  
        Map<String, String> map = new HashMap<String, String>();  
        map.put("account", "");  
        map.put("password", "");  
    
        HttpClient client = getConnection();  
        HttpUriRequest post = getRequestMethod(map, "http://cnivi.com.cn/login", "post");  
        HttpResponse response = client.execute(post);  
    
        if (response.getStatusLine().getStatusCode() == 200) {  
            HttpEntity entity = response.getEntity();  
            String message = EntityUtils.toString(entity, "utf-8");  
            System.out.println(message);  
        } else {  
            System.out.println("请求失败");  
        }  
    }  
}  
```


### 4.3  get方式

```java
/** 
     * 发送 get请求 
     */   
    public void get() {   
        CloseableHttpClient httpclient = HttpClients.createDefault();   
        try {   
            // 创建httpget.     
            HttpGet httpget = new HttpGet("http://www.baidu.com/");   
            System.out.println("executing request " + httpget.getURI());   
            // 执行get请求.     
            CloseableHttpResponse response = httpclient.execute(httpget);   
            try {   
                // 获取响应实体     
                HttpEntity entity = response.getEntity();   
                System.out.println("--------------------------------------");   
                // 打印响应状态     
                System.out.println(response.getStatusLine());   
                if (entity != null) {   
                    // 打印响应内容长度     
                    System.out.println("Response content length: " + entity.getContentLength());   
                    // 打印响应内容     
                    System.out.println("Response content: " + EntityUtils.toString(entity));   
                }   
                System.out.println("------------------------------------");   
            } finally {   
                response.close();   
            }   
        } catch (ClientProtocolException e) {   
            e.printStackTrace();   
        } catch (ParseException e) {   
            e.printStackTrace();   
        } catch (IOException e) {   
            e.printStackTrace();   
        } finally {   
            // 关闭连接,释放资源     
            try {   
                httpclient.close();   
            } catch (IOException e) {   
                e.printStackTrace();   
            }   
        }   
    }  
```



### 4.4  post方式 

```java
/** 
     * 发送 post请求访问本地应用并根据传递参数不同返回不同结果 
     */   
    public void post() {   
        // 创建默认的httpClient实例.     
        CloseableHttpClient httpclient = HttpClients.createDefault();   
        // 创建httppost     
        HttpPost httppost = new HttpPost("http://localhost:8080/myDemo/Ajax/serivceJ.action");   
        // 创建参数队列     
        List<NameValuePair> formparams = new ArrayList<NameValuePair>();   
        formparams.add(new BasicNameValuePair("type", "house"));   
        UrlEncodedFormEntity uefEntity;   
        try {   
            uefEntity = new UrlEncodedFormEntity(formparams, "UTF-8");   
            httppost.setEntity(uefEntity);   
            System.out.println("executing request " + httppost.getURI());   
            CloseableHttpResponse response = httpclient.execute(httppost);   
            try {   
                HttpEntity entity = response.getEntity();   
                if (entity != null) {   
                    System.out.println("--------------------------------------");   
                    System.out.println("Response content: " + EntityUtils.toString(entity, "UTF-8"));   
                    System.out.println("--------------------------------------");   
                }   
            } finally {   
                response.close();   
            }   
        } catch (ClientProtocolException e) {   
            e.printStackTrace();   
        } catch (UnsupportedEncodingException e1) {   
            e1.printStackTrace();   
        } catch (IOException e) {   
            e.printStackTrace();   
        } finally {   
            // 关闭连接,释放资源     
            try {   
                httpclient.close();   
            } catch (IOException e) {   
                e.printStackTrace();   
            }   
        }   
    }  
```

post方式乱码补充　

如果有乱码,可以偿试使用 StringEntity 来替换HttpEntity:

```java
StringEntity content =new StringEntity(soapRequestData.toString(), Charset.forName("UTF-8"));// 第二个参数，设置后才会对，内容进行编码  
        content.setContentType("application/soap+xml; charset=UTF-8");  
        content.setContentEncoding("UTF-8");  
        httppost.setEntity(content);  

```

具体SOAP协议代码如下:

```java
    package com.isoftstone.core.service.impl;  
      
    import java.io.BufferedReader;  
    import java.io.File;  
    import java.io.FileInputStream;  
    import java.io.FileReader;  
    import java.io.IOException;  
    import java.io.InputStreamReader;  
    import java.nio.charset.Charset;  
    import java.util.Scanner;  
      
    import org.apache.http.HttpEntity;  
    import org.apache.http.HttpResponse;  
    import org.apache.http.client.ClientProtocolException;  
    import org.apache.http.client.HttpClient;  
    import org.apache.http.client.entity.EntityBuilder;  
    import org.apache.http.client.methods.HttpPost;  
    import org.apache.http.entity.ContentType;  
    import org.apache.http.entity.StringEntity;  
    import org.apache.http.impl.client.HttpClients;  
    import org.apache.http.util.EntityUtils;  
    import org.apache.log4j.Logger;  
    import org.jdom.Document;  
    import org.jdom.Element;  
      
    import com.isoftstone.core.common.constant.RequestConstants;  
    import com.isoftstone.core.common.tools.XmlTool;  
    import com.isoftstone.core.service.intf.ServiceOfStringPara;  
    /** 
     * 
     * 
     */  
    public class DeloittePricingSingleCarImpl implements ServiceOfStringPara {  
        private  String serviceUrl = "http://10.30.0.35:7001/ZSInsUW/Auto/PricingService";  
      
        private static Logger log = Logger.getLogger(DeloittePricingSingleCarImpl.class.getName());  
      
        public String invoke(String sRequest) {  
              
            StringBuffer soapRequestData = new StringBuffer();  
            soapRequestData.append("<soapenv:Envelope");  
            soapRequestData.append("  xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" ");  
            soapRequestData.append("  xmlns:prov=\"http://provider.webservice.zsins.dtt.com/\">");  
            soapRequestData.append(" <soapenv:Header/> ");  
            soapRequestData.append("<soapenv:Body>");  
            soapRequestData.append("<prov:executePrvPricing>");  
            soapRequestData.append("<arg0>");  
            soapRequestData.append("<![CDATA[" + sRequest + "]]>");  
            soapRequestData.append("</arg0>");  
            soapRequestData.append("</prov:executePrvPricing>");  
            soapRequestData.append(" </soapenv:Body>");  
            soapRequestData.append("</soapenv:Envelope>");  
      
            HttpClient httpclient = HttpClients.createDefault();  
            HttpPost httppost = new HttpPost(serviceUrl);  
      
            StringEntity content =new StringEntity(soapRequestData.toString(), Charset.forName("UTF-8"));// 第二个参数，设置后才会对，内容进行编码  
            content.setContentType("application/soap+xml; charset=UTF-8");  
            content.setContentEncoding("UTF-8");  
            httppost.setEntity(content);  
              
            //用下面的服务器端以UTF-8接收到的报文会乱码,原因未知  
    //        HttpEntity reqEntity = EntityBuilder.create().setContentType(  
    //                ContentType.TEXT_PLAIN) // .TEXT_PLAIN  
    //                .setText(soapRequestData.toString()).build();  
    //        httppost.setEntity(reqEntity);  
    //        httppost.addHeader("Content-Type",  
    //                "application/soap+xml; charset=utf-8");  
            HttpResponse response = null;  
            Document doc = null;  
            String returnXml = null;  
            String sentity = null;  
            try {  
                response = httpclient.execute(httppost);  
                HttpEntity resEntity = response.getEntity();  
                if (resEntity != null) {  
                    sentity = EntityUtils.toString(resEntity, "UTF-8");  
                    doc = XmlTool.getDocument(sentity, RequestConstants.ENCODE);  
                    System.out.println(doc.toString());  
                    Element eRoot = doc.getRootElement();  
                    Element body = eRoot.getChild("Body", eRoot.getNamespace());  
                    Element resp = (Element) body.getChildren().get(0);  
                    Element returnele = resp.getChild("return");  
                    returnXml = returnele.getText().toString();  
                }  
            } catch (ClientProtocolException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            } catch (Exception e) {  
                e.printStackTrace();  
            } finally {  
                log.info("发送给系统的请求报文：\n" + soapRequestData.toString());  
                log.info("系统返回的响应报文：\n" + sentity);  
                log.info("返回给核心的的报文:\n" + returnXml);  
            }  
            return returnXml;  
        }  
          
          
        public String getServiceUrl() {  
            return serviceUrl;  
        }  
      
      
        public void setServiceUrl(String serviceUrl) {  
            this.serviceUrl = serviceUrl;  
        }  
      
      
        public static void main(String[] args) throws Exception{  
            File file = new File("D:/test.txt");  
            System.out.println(file.exists());  
              
            String temp2 = null;  
            StringBuilder sb2 = new StringBuilder();  
            InputStreamReader isr = new InputStreamReader(new FileInputStream(file),"GBK");  
            BufferedReader br = new BufferedReader(isr);  
            temp2 = br.readLine();  
              
            while( temp2 != null ){  
                sb2.append(temp2);  
                temp2 = br.readLine();  
            }  
            String sss = sb2.toString();  
    //        System.out.println(sss.toString());  
            new DeloittePricingSingleCarImpl().invoke(sss);  
        }  
    }  
 
```



### 4.5  post提交表单

```java
/** 
     * post方式提交表单（模拟用户登录请求） 
     */   
    public void postForm() {   
        // 创建默认的httpClient实例.     
        CloseableHttpClient httpclient = HttpClients.createDefault();   
        // 创建httppost     
        HttpPost httppost = new HttpPost("http://localhost:8080/myDemo/Ajax/serivceJ.action");   
        // 创建参数队列     
        List<NameValuePair> formparams = new ArrayList<NameValuePair>();   
        formparams.add(new BasicNameValuePair("username", "admin"));   
        formparams.add(new BasicNameValuePair("password", "123456"));   
        UrlEncodedFormEntity uefEntity;   
        try {   
            uefEntity = new UrlEncodedFormEntity(formparams, "UTF-8");   
            httppost.setEntity(uefEntity);   
            System.out.println("executing request " + httppost.getURI());   
            CloseableHttpResponse response = httpclient.execute(httppost);   
            try {   
                HttpEntity entity = response.getEntity();   
                if (entity != null) {   
                    System.out.println("--------------------------------------");   
                    System.out.println("Response content: " + EntityUtils.toString(entity, "UTF-8"));   
                    System.out.println("--------------------------------------");   
                }   
            } finally {   
                response.close();   
            }   
        } catch (ClientProtocolException e) {   
            e.printStackTrace();   
        } catch (UnsupportedEncodingException e1) {   
            e1.printStackTrace();   
        } catch (IOException e) {   
            e.printStackTrace();   
        } finally {   
            // 关闭连接,释放资源     
            try {   
                httpclient.close();   
            } catch (IOException e) {   
                e.printStackTrace();   
            }   
        }   
    }  
```



### 4.6  文件上传

**（在后台里直接上传给后台的Java方式，不是页面上传到后台）**

```java
/** 
     * 上传文件 
     */   
    public void upload() {   
        CloseableHttpClient httpclient = HttpClients.createDefault();   
        try {   
            HttpPost httppost = new HttpPost("http://localhost:8080/myDemo/Ajax/serivceFile.action");   
     
            FileBody bin = new FileBody(new File("F:\\image\\sendpix0.jpg"));   
            StringBody comment = new StringBody("A binary file of some kind", ContentType.TEXT_PLAIN);   
     
            HttpEntity reqEntity = MultipartEntityBuilder.create().addPart("bin", bin).addPart("comment", comment).build();   
     
            httppost.setEntity(reqEntity);   
     
            System.out.println("executing request " + httppost.getRequestLine());   
            CloseableHttpResponse response = httpclient.execute(httppost);   
            try {   
                System.out.println("----------------------------------------");   
                System.out.println(response.getStatusLine());   
                HttpEntity resEntity = response.getEntity();   
                if (resEntity != null) {   
                    System.out.println("Response content length: " + resEntity.getContentLength());   
                }   
                EntityUtils.consume(resEntity);   
            } finally {   
                response.close();   
            }   
        } catch (ClientProtocolException e) {   
            e.printStackTrace();   
        } catch (IOException e) {   
            e.printStackTrace();   
        } finally {   
            try {   
                httpclient.close();   
            } catch (IOException e) {   
                e.printStackTrace();   
            }   
        }   
    } 
```



### 4.7  ssl连接

```java
/** 
     * HttpClient连接SSL 
     */   
    public void ssl() {   
        CloseableHttpClient httpclient = null;   
        try {   
            KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());   
            FileInputStream instream = new FileInputStream(new File("d:\\tomcat.keystore"));   
            try {   
                // 加载keyStore d:\\tomcat.keystore     
                trustStore.load(instream, "123456".toCharArray());   
            } catch (CertificateException e) {   
                e.printStackTrace();   
            } finally {   
                try {   
                    instream.close();   
                } catch (Exception ignore) {   
                }   
            }   
            // 相信自己的CA和所有自签名的证书   
            SSLContext sslcontext = SSLContexts.custom().loadTrustMaterial(trustStore, new TrustSelfSignedStrategy()).build();   
            // 只允许使用TLSv1协议   
            SSLConnectionSocketFactory sslsf = new SSLConnectionSocketFactory(sslcontext, new String[] { "TLSv1" }, null,   
                    SSLConnectionSocketFactory.BROWSER_COMPATIBLE_HOSTNAME_VERIFIER);   
            httpclient = HttpClients.custom().setSSLSocketFactory(sslsf).build();   
            // 创建http请求(get方式)   
            HttpGet httpget = new HttpGet("https://localhost:8443/myDemo/Ajax/serivceJ.action");   
            System.out.println("executing request" + httpget.getRequestLine());   
            CloseableHttpResponse response = httpclient.execute(httpget);   
            try {   
                HttpEntity entity = response.getEntity();   
                System.out.println("----------------------------------------");   
                System.out.println(response.getStatusLine());   
                if (entity != null) {   
                    System.out.println("Response content length: " + entity.getContentLength());   
                    System.out.println(EntityUtils.toString(entity));   
                    EntityUtils.consume(entity);   
                }   
            } finally {   
                response.close();   
            }   
        } catch (ParseException e) {   
            e.printStackTrace();   
        } catch (IOException e) {   
            e.printStackTrace();   
        } catch (KeyManagementException e) {   
            e.printStackTrace();   
        } catch (NoSuchAlgorithmException e) {   
            e.printStackTrace();   
        } catch (KeyStoreException e) {   
            e.printStackTrace();   
        } finally {   
            if (httpclient != null) {   
                try {   
                    httpclient.close();   
                } catch (IOException e) {   
                    e.printStackTrace();   
                }   
            }   
        }   
    }   
```



### 4.8  关于RequestConfig的配置: 

源自:  

http://segmentfault.com/a/1190000000587944

http://blog.csdn.net/walkerjong/article/details/51710945

```java
public void requestConfig(){  
//      新建一个RequestConfig：  
        RequestConfig defaultRequestConfig = RequestConfig.custom()  
            //一、连接目标服务器超时时间：ConnectionTimeout-->指的是连接一个url的连接等待时间  
            .setConnectTimeout(5000)  
            //二、读取目标服务器数据超时时间：SocketTimeout-->指的是连接上一个url，获取response的返回等待时间  
            .setSocketTimeout(5000)  
            //三、从连接池获取连接的超时时间:ConnectionRequestTimeout  
            .setConnectionRequestTimeout(5000)  
            .build();  
           
//      这个超时可以设置为客户端级别,作为所有请求的默认值：  
        CloseableHttpClient httpclient = HttpClients.custom()  
            .setDefaultRequestConfig(defaultRequestConfig)  
            .build();  
//       httpclient.execute(httppost);的时候可以让httppost直接享受到httpclient中的默认配置.  
           
//      Request不会继承客户端级别的请求配置，所以在自定义Request的时候，需要将客户端的默认配置拷贝过去：  
        HttpGet httpget = new HttpGet("http://www.apache.org/");  
        RequestConfig requestConfig = RequestConfig.copy(defaultRequestConfig)  
            .setProxy(new HttpHost("myotherproxy", 8080))  
            .build();  
        httpget.setConfig(requestConfig);  
//      httpget可以单独地使用新copy的requestConfig请求配置,不会对别的request请求产生影响  
    }  
```

httpGet或httpPost 的abort()和releaseConnection()差异

```java
//httpPost.abort();//中断请求,接下来可以开始另一段请求,所以个人理应,用这个应该可以在session中虚拟登录  
 //httpPost.releaseConnection();//释放请求.如果释放了相当于要清空session  
```

可知模拟登录可以如下:  源自 http://bbs.csdn.net/topics/390195343

```java
package com.bms.core;  
     
import java.io.IOException;  
import java.util.ArrayList;  
import java.util.List;  
     
import org.apache.http.Consts;  
import org.apache.http.HttpEntity;  
import org.apache.http.HttpResponse;  
import org.apache.http.NameValuePair;  
import org.apache.http.client.ClientProtocolException;  
import org.apache.http.client.entity.UrlEncodedFormEntity;  
import org.apache.http.client.methods.HttpGet;  
import org.apache.http.client.methods.HttpPost;  
import org.apache.http.impl.client.DefaultHttpClient;  
import org.apache.http.message.BasicNameValuePair;  
import org.apache.http.util.EntityUtils;  
     
import com.bms.util.CommonUtil;  
     
public class Test2 {  
     
    /** 
     * @param args 
     * @throws IOException 
     * @throws ClientProtocolException 
     */  
    public static void main(String[] args) throws ClientProtocolException, IOException {  
        DefaultHttpClient httpclient = new DefaultHttpClient();  
     
         HttpGet httpGet = new HttpGet("http://www.baidu.com");  
         String body = "";  
         HttpResponse response;  
         HttpEntity entity;  
         response = httpclient.execute(httpGet);  
         entity = response.getEntity();  
         body = EntityUtils.toString(entity);//这个就是页面源码了  
         httpGet.abort();//中断请求,接下来可以开始另一段请求  
         System.out.println(body);  
         //httpGet.releaseConnection();//释放请求.如果释放了相当于要清空session  
         //以下是post方法  
         HttpPost httpPost = new HttpPost("http://www.baidu.com");//一定要改成可以提交的地址,这里用百度代替  
         List <NameValuePair> nvps = new ArrayList <NameValuePair>();  
         nvps.add(new BasicNameValuePair("name", "1"));//名值对  
         nvps.add(new BasicNameValuePair("account", "xxxx"));  
         httpPost.setEntity(new UrlEncodedFormEntity(nvps, Consts.UTF_8));  
         response = httpclient.execute(httpPost);  
         entity = response.getEntity();  
         body = EntityUtils.toString(entity);  
         System.out.println("Login form get: " + response.getStatusLine());//这个可以打印状态  
         httpPost.abort();  
         System.out.println(body);  
         httpPost.releaseConnection();  
    }  
     
}  
```

源自  http://blog.csdn.net/wangpeng047/article/details/19624529#reply

其它相关资料: 非CloseableHttpClient  HTTPClient模块的HttpGet和HttpPost

HttpClient 4.3教程

httpclient异常情况分析



-----

# 三、[HttpClient详细使用示例](https://blog.csdn.net/justry_deng/article/details/81042379)

 HTTP 协议可能是现在 Internet 上使用得最多、最重要的协议了，越来越多的 Java 应用程序需要直接通过 HTTP 协议来访问网络资源。虽然在 JDK 的 java net包中已经提供了访问 HTTP 协议的基本功能，但是对于大部分应用程序来说，JDK 库本身提供的功能还不够丰富和灵活。HttpClient 是 Apache Jakarta Common 下的子项目，用来提供高效的、最新的、功能丰富的支持 HTTP 协议的客户端编程工具包，并且它支持 HTTP 协议最新的版本和建议。

        HTTP和浏览器有点像，但却不是浏览器。很多人觉得既然HttpClient是一个HTTP客户端编程工具，很多人把他当做浏览器来理解，但是其实HttpClient不是浏览器，它是一个HTTP通信库，因此它只提供一个通用浏览器应用程序所期望的功能子集，最根本的区别是HttpClient中没有用户界面，浏览器需要一个渲染引擎来显示页面，并解释用户输入，例如鼠标点击显示页面上的某处，有一个布局引擎，计算如何显示HTML页面，包括级联样式表和图像。javascript解释器运行嵌入HTML页面或从HTML页面引用的javascript代码。来自用户界面的事件被传递到javascript解释器进行处理。除此之外，还有用于插件的接口，可以处理Applet，嵌入式媒体对象（如pdf文件，Quicktime电影和Flash动画）或ActiveX控件（可以执行任何操作）。HttpClient只能以编程的方式通过其API用于传输和接受HTTP消息。

HttpClient的主要功能：

实现了所有 HTTP 的方法（GET、POST、PUT、HEAD、DELETE、HEAD、OPTIONS 等）
支持 HTTPS 协议
支持代理服务器（Nginx等）等
支持自动（跳转）转向
……
进入正题

环境说明：JDK1.8、SpringBoot

准备环节
第一步：在pom.xml中引入HttpClient的依赖

```xml
 <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpclient</artifactId>
            <version>4.5.13</version>
        </dependency>
```

第二步：引入fastjson依赖：com.alibaba.fastjson


注：本人引入此依赖的目的是，在后续示例中，会用到“将对象转化为json字符串的功能”，也可以引其他有此功能的依赖。 

注：SpringBoot的基本依赖配置，这里就不再多说了。

详细使用示例
声明：此示例中，以JAVA发送HttpClient(在test里面单元测试发送的)；也是以JAVA接收的（在controller里面接收的）。

声明：下面的代码，本人亲测有效。

## 1、GET无参：

HttpClient发送示例：

```java
    /**
	 * GET---无参测试
	 *
	 * @date 2018年7月13日 下午4:18:50
	 */
	@Test
	public void doGetTestOne() {
		// 获得Http客户端(可以理解为:你得先有一个浏览器;注意:实际上HttpClient与浏览器是不一样的)
		CloseableHttpClient httpClient = HttpClientBuilder.create().build();
		// 创建Get请求
		HttpGet httpGet = new HttpGet("http://localhost:12345/doGetControllerOne");
 
		// 响应模型
		CloseableHttpResponse response = null;
		try {
			// 由客户端执行(发送)Get请求
			response = httpClient.execute(httpGet);
			// 从响应模型中获取响应实体
			HttpEntity responseEntity = response.getEntity();
			System.out.println("响应状态为:" + response.getStatusLine());
			if (responseEntity != null) {
				System.out.println("响应内容长度为:" + responseEntity.getContentLength());
				System.out.println("响应内容为:" + EntityUtils.toString(responseEntity));
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				// 释放资源
				if (httpClient != null) {
					httpClient.close();
				}
				if (response != null) {
					response.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
```

![img](https://img-blog.csdn.net/20180714120325210?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)



## 2、GET有参(方式一：直接拼接URL)：

HttpClient发送示例：

```java
/**
 * GET---有参测试 (方式一:手动在url后面加上参数)
 *
 * @date 2018年7月13日 下午4:19:23
 */
@Test
public void doGetTestWayOne() {
	// 获得Http客户端(可以理解为:你得先有一个浏览器;注意:实际上HttpClient与浏览器是不一样的)
	CloseableHttpClient httpClient = HttpClientBuilder.create().build();
 
	// 参数
	StringBuffer params = new StringBuffer();
	try {
		// 字符数据最好encoding以下;这样一来，某些特殊字符才能传过去(如:某人的名字就是“&”,不encoding的话,传不过去)
		params.append("name=" + URLEncoder.encode("&", "utf-8"));
		params.append("&");
		params.append("age=24");
	} catch (UnsupportedEncodingException e1) {
		e1.printStackTrace();
	}
 
	// 创建Get请求
	HttpGet httpGet = new HttpGet("http://localhost:12345/doGetControllerTwo" + "?" + params);
	// 响应模型
	CloseableHttpResponse response = null;
	try {
		// 配置信息
		RequestConfig requestConfig = RequestConfig.custom()
				// 设置连接超时时间(单位毫秒)
				.setConnectTimeout(5000)
				// 设置请求超时时间(单位毫秒)
				.setConnectionRequestTimeout(5000)
				// socket读写超时时间(单位毫秒)
				.setSocketTimeout(5000)
				// 设置是否允许重定向(默认为true)
				.setRedirectsEnabled(true).build();
 
		// 将上面的配置信息 运用到这个Get请求里
		httpGet.setConfig(requestConfig);
 
		// 由客户端执行(发送)Get请求
		response = httpClient.execute(httpGet);
 
		// 从响应模型中获取响应实体
		HttpEntity responseEntity = response.getEntity();
		System.out.println("响应状态为:" + response.getStatusLine());
		if (responseEntity != null) {
			System.out.println("响应内容长度为:" + responseEntity.getContentLength());
			System.out.println("响应内容为:" + EntityUtils.toString(responseEntity));
		}
	} catch (ClientProtocolException e) {
		e.printStackTrace();
	} catch (ParseException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	} finally {
		try {
			// 释放资源
			if (httpClient != null) {
				httpClient.close();
			}
			if (response != null) {
				response.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
```
对应接收示例：

![img](https://img-blog.csdn.net/20180714120342745?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)



## 3、GET有参(方式二：使用URI获得HttpGet)：

HttpClient发送示例：

```java
    /**
	 * GET---有参测试 (方式二:将参数放入键值对类中,再放入URI中,从而通过URI得到HttpGet实例)
	 *
	 * @date 2018年7月13日 下午4:19:23
	 */
	@Test
	public void doGetTestWayTwo() {
		// 获得Http客户端(可以理解为:你得先有一个浏览器;注意:实际上HttpClient与浏览器是不一样的)
		CloseableHttpClient httpClient = HttpClientBuilder.create().build();
 
		// 参数
		URI uri = null;
		try {
			// 将参数放入键值对类NameValuePair中,再放入集合中
			List<NameValuePair> params = new ArrayList<>();
			params.add(new BasicNameValuePair("name", "&"));
			params.add(new BasicNameValuePair("age", "18"));
			// 设置uri信息,并将参数集合放入uri;
			// 注:这里也支持一个键值对一个键值对地往里面放setParameter(String key, String value)
			uri = new URIBuilder().setScheme("http").setHost("localhost")
					              .setPort(12345).setPath("/doGetControllerTwo")
					              .setParameters(params).build();
		} catch (URISyntaxException e1) {
			e1.printStackTrace();
		}
		// 创建Get请求
		HttpGet httpGet = new HttpGet(uri);
 
		// 响应模型
		CloseableHttpResponse response = null;
		try {
			// 配置信息
			RequestConfig requestConfig = RequestConfig.custom()
					// 设置连接超时时间(单位毫秒)
					.setConnectTimeout(5000)
					// 设置请求超时时间(单位毫秒)
					.setConnectionRequestTimeout(5000)
					// socket读写超时时间(单位毫秒)
					.setSocketTimeout(5000)
					// 设置是否允许重定向(默认为true)
					.setRedirectsEnabled(true).build();
 
			// 将上面的配置信息 运用到这个Get请求里
			httpGet.setConfig(requestConfig);
 
			// 由客户端执行(发送)Get请求
			response = httpClient.execute(httpGet);
 
			// 从响应模型中获取响应实体
			HttpEntity responseEntity = response.getEntity();
			System.out.println("响应状态为:" + response.getStatusLine());
			if (responseEntity != null) {
				System.out.println("响应内容长度为:" + responseEntity.getContentLength());
				System.out.println("响应内容为:" + EntityUtils.toString(responseEntity));
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				// 释放资源
				if (httpClient != null) {
					httpClient.close();
				}
				if (response != null) {
					response.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
```

对应接收示例：

![img](https://img-blog.csdn.net/20180714120401361?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)



## 4、POST无参：

HttpClient发送示例：

```java
/**
 * POST---无参测试
 *
 * @date 2018年7月13日 下午4:18:50
 */
@Test
public void doPostTestOne() {
 
	// 获得Http客户端(可以理解为:你得先有一个浏览器;注意:实际上HttpClient与浏览器是不一样的)
	CloseableHttpClient httpClient = HttpClientBuilder.create().build();
 
	// 创建Post请求
	HttpPost httpPost = new HttpPost("http://localhost:12345/doPostControllerOne");
	// 响应模型
	CloseableHttpResponse response = null;
	try {
		// 由客户端执行(发送)Post请求
		response = httpClient.execute(httpPost);
		// 从响应模型中获取响应实体
		HttpEntity responseEntity = response.getEntity();
 
		System.out.println("响应状态为:" + response.getStatusLine());
		if (responseEntity != null) {
			System.out.println("响应内容长度为:" + responseEntity.getContentLength());
			System.out.println("响应内容为:" + EntityUtils.toString(responseEntity));
		}
	} catch (ClientProtocolException e) {
		e.printStackTrace();
	} catch (ParseException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	} finally {
		try {
			// 释放资源
			if (httpClient != null) {
				httpClient.close();
			}
			if (response != null) {
				response.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
```
对应接收示例：

![img](https://img-blog.csdn.net/20180714120544899?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)



## 5、POST有参(普通参数)：

注：POST传递普通参数时，方式与GET一样即可，这里以直接在url后缀上参数的方式示例。

**HttpClient发送示例：**

```java
/**
 * POST---有参测试(普通参数)
 *
 * @date 2018年7月13日 下午4:18:50
 */
@Test
public void doPostTestFour() {
 
	// 获得Http客户端(可以理解为:你得先有一个浏览器;注意:实际上HttpClient与浏览器是不一样的)
	CloseableHttpClient httpClient = HttpClientBuilder.create().build();
 
	// 参数
	StringBuffer params = new StringBuffer();
	try {
		// 字符数据最好encoding以下;这样一来，某些特殊字符才能传过去(如:某人的名字就是“&”,不encoding的话,传不过去)
		params.append("name=" + URLEncoder.encode("&", "utf-8"));
		params.append("&");
		params.append("age=24");
	} catch (UnsupportedEncodingException e1) {
		e1.printStackTrace();
	}
 
	// 创建Post请求
	HttpPost httpPost = new HttpPost("http://localhost:12345/doPostControllerFour" + "?" + params);
 
	// 设置ContentType(注:如果只是传普通参数的话,ContentType不一定非要用application/json)
	httpPost.setHeader("Content-Type", "application/json;charset=utf8");
 
	// 响应模型
	CloseableHttpResponse response = null;
	try {
		// 由客户端执行(发送)Post请求
		response = httpClient.execute(httpPost);
		// 从响应模型中获取响应实体
		HttpEntity responseEntity = response.getEntity();
 
		System.out.println("响应状态为:" + response.getStatusLine());
		if (responseEntity != null) {
			System.out.println("响应内容长度为:" + responseEntity.getContentLength());
			System.out.println("响应内容为:" + EntityUtils.toString(responseEntity));
		}
	} catch (ClientProtocolException e) {
		e.printStackTrace();
	} catch (ParseException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	} finally {
		try {
			// 释放资源
			if (httpClient != null) {
				httpClient.close();
			}
			if (response != null) {
				response.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
```
**对应接收示例：**

![img](https://img-blog.csdn.net/20180714120601771?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)



## 6、POST有参(对象参数)：

先给出User类

```java
public class User{
String name;
Integer age;
String gender;
String motto;
}
```

**HttpClient发送示例：**

```java
/**
 * POST---有参测试(对象参数)
 *
 * @date 2018年7月13日 下午4:18:50
 */
@Test
public void doPostTestTwo() {
 
	// 获得Http客户端(可以理解为:你得先有一个浏览器;注意:实际上HttpClient与浏览器是不一样的)
	CloseableHttpClient httpClient = HttpClientBuilder.create().build();
 
	// 创建Post请求
	HttpPost httpPost = new HttpPost("http://localhost:12345/doPostControllerTwo");
	User user = new User();
	user.setName("潘晓婷");
	user.setAge(18);
	user.setGender("女");
	user.setMotto("姿势要优雅~");
	// 我这里利用阿里的fastjson，将Object转换为json字符串;
	// (需要导入com.alibaba.fastjson.JSON包)
	String jsonString = JSON.toJSONString(user);
 
	StringEntity entity = new StringEntity(jsonString, "UTF-8");
 
	// post请求是将参数放在请求体里面传过去的;这里将entity放入post请求体中
	httpPost.setEntity(entity);
 
	httpPost.setHeader("Content-Type", "application/json;charset=utf8");
 
	// 响应模型
	CloseableHttpResponse response = null;
	try {
		// 由客户端执行(发送)Post请求
		response = httpClient.execute(httpPost);
		// 从响应模型中获取响应实体
		HttpEntity responseEntity = response.getEntity();
 
		System.out.println("响应状态为:" + response.getStatusLine());
		if (responseEntity != null) {
			System.out.println("响应内容长度为:" + responseEntity.getContentLength());
			System.out.println("响应内容为:" + EntityUtils.toString(responseEntity));
		}
	} catch (ClientProtocolException e) {
		e.printStackTrace();
	} catch (ParseException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	} finally {
		try {
			// 释放资源
			if (httpClient != null) {
				httpClient.close();
			}
			if (response != null) {
				response.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
```
**对应接收示例：**

![img](https://img-blog.csdn.net/2018071412062926?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)



## 7、POST有参(普通参数 + 对象参数)：

注：POST传递普通参数时，方式与GET一样即可，这里以通过URI获得HttpPost的方式为例。

先给出User类：

**HttpClient发送示例：**

```java
/**
 * POST---有参测试(普通参数 + 对象参数)
 *
 * @date 2018年7月13日 下午4:18:50
 */
@Test
public void doPostTestThree() {
 
	// 获得Http客户端(可以理解为:你得先有一个浏览器;注意:实际上HttpClient与浏览器是不一样的)
	CloseableHttpClient httpClient = HttpClientBuilder.create().build();
 
	// 创建Post请求
	// 参数
	URI uri = null;
	try {
		// 将参数放入键值对类NameValuePair中,再放入集合中
		List<NameValuePair> params = new ArrayList<>();
		params.add(new BasicNameValuePair("flag", "4"));
		params.add(new BasicNameValuePair("meaning", "这是什么鬼？"));
		// 设置uri信息,并将参数集合放入uri;
		// 注:这里也支持一个键值对一个键值对地往里面放setParameter(String key, String value)
		uri = new URIBuilder().setScheme("http").setHost("localhost").setPort(12345)
				.setPath("/doPostControllerThree").setParameters(params).build();
	} catch (URISyntaxException e1) {
		e1.printStackTrace();
	}
 
	HttpPost httpPost = new HttpPost(uri);
	// HttpPost httpPost = new
	// HttpPost("http://localhost:12345/doPostControllerThree1");
 
	// 创建user参数
	User user = new User();
	user.setName("潘晓婷");
	user.setAge(18);
	user.setGender("女");
	user.setMotto("姿势要优雅~");
 
	// 将user对象转换为json字符串，并放入entity中
	StringEntity entity = new StringEntity(JSON.toJSONString(user), "UTF-8");
 
	// post请求是将参数放在请求体里面传过去的;这里将entity放入post请求体中
	httpPost.setEntity(entity);
 
	httpPost.setHeader("Content-Type", "application/json;charset=utf8");
 
	// 响应模型
	CloseableHttpResponse response = null;
	try {
		// 由客户端执行(发送)Post请求
		response = httpClient.execute(httpPost);
		// 从响应模型中获取响应实体
		HttpEntity responseEntity = response.getEntity();
 
		System.out.println("响应状态为:" + response.getStatusLine());
		if (responseEntity != null) {
			System.out.println("响应内容长度为:" + responseEntity.getContentLength());
			System.out.println("响应内容为:" + EntityUtils.toString(responseEntity));
		}
	} catch (ClientProtocolException e) {
		e.printStackTrace();
	} catch (ParseException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	} finally {
		try {
			// 释放资源
			if (httpClient != null) {
				httpClient.close();
			}
			if (response != null) {
				response.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
```
**对应接收示例：**

![img](https://img-blog.csdn.net/20180714120705348?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

**对评论区关注度较高的问题进行相关补充：**
提示：如果想要知道完整的具体的代码及测试细节，可去下面给的项目代码托管链接，将项目clone下来
           进行观察。如果需要运行测试，可以先启动该SpringBoot项目，然后再运行相关test方法，进行
           测试。



## 8、解决响应乱码问题(示例)：

![img](https://img-blog.csdnimg.cn/20190918182600512.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n,size_16,color_FFFFFF,t_70)



## 9、进行HTTPS请求并进行(或不进行)证书校验(示例)：

使用示例：

![img](https://img-blog.csdnimg.cn/20190918182730959.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n,size_16,color_FFFFFF,t_70)



**相关方法详情(非完美封装)：**

```java
/**
 * 根据是否是https请求，获取HttpClient客户端
 *
 * TODO 本人这里没有进行完美封装。对于 校不校验校验证书的选择，本人这里是写死
 *      在代码里面的，你们在使用时，可以灵活二次封装。
 *
 * 提示: 此工具类的封装、相关客户端、服务端证书的生成，可参考我的这篇博客:
 *      <linked>https://blog.csdn.net/justry_deng/article/details/91569132</linked>
 *
 *
 * @param isHttps 是否是HTTPS请求
 *
 * @return  HttpClient实例
 * @date 2019/9/18 17:57
 */
private CloseableHttpClient getHttpClient(boolean isHttps) {
   CloseableHttpClient httpClient;
   if (isHttps) {
      SSLConnectionSocketFactory sslSocketFactory;
      try {
         /// 如果不作证书校验的话
         sslSocketFactory = getSocketFactory(false, null, null);
 
         /// 如果需要证书检验的话
         // 证书
         //InputStream ca = this.getClass().getClassLoader().getResourceAsStream("client/ds.crt");
         // 证书的别名，即:key。 注:cAalias只需要保证唯一即可，不过推荐使用生成keystore时使用的别名。
         // String cAalias = System.currentTimeMillis() + "" + new SecureRandom().nextInt(1000);
         //sslSocketFactory = getSocketFactory(true, ca, cAalias);
      } catch (Exception e) {
         throw new RuntimeException(e);
      }
      httpClient = HttpClientBuilder.create().setSSLSocketFactory(sslSocketFactory).build();
      return httpClient;
   }
   httpClient = HttpClientBuilder.create().build();
   return httpClient;
}
 
/**
 * HTTPS辅助方法, 为HTTPS请求 创建SSLSocketFactory实例、TrustManager实例
 *
 * @param needVerifyCa
 *         是否需要检验CA证书(即:是否需要检验服务器的身份)
 * @param caInputStream
 *         CA证书。(若不需要检验证书，那么此处传null即可)
 * @param cAalias
 *         别名。(若不需要检验证书，那么此处传null即可)
 *         注意:别名应该是唯一的， 别名不要和其他的别名一样，否者会覆盖之前的相同别名的证书信息。别名即key-value中的key。
 *
 * @return SSLConnectionSocketFactory实例
 * @throws NoSuchAlgorithmException
 *         异常信息
 * @throws CertificateException
 *         异常信息
 * @throws KeyStoreException
 *         异常信息
 * @throws IOException
 *         异常信息
 * @throws KeyManagementException
 *         异常信息
 * @date 2019/6/11 19:52
 */
private static SSLConnectionSocketFactory getSocketFactory(boolean needVerifyCa, InputStream caInputStream, String cAalias)
      throws CertificateException, NoSuchAlgorithmException, KeyStoreException,
      IOException, KeyManagementException {
   X509TrustManager x509TrustManager;
   // https请求，需要校验证书
   if (needVerifyCa) {
      KeyStore keyStore = getKeyStore(caInputStream, cAalias);
      TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
      trustManagerFactory.init(keyStore);
      TrustManager[] trustManagers = trustManagerFactory.getTrustManagers();
      if (trustManagers.length != 1 || !(trustManagers[0] instanceof X509TrustManager)) {
         throw new IllegalStateException("Unexpected default trust managers:" + Arrays.toString(trustManagers));
      }
      x509TrustManager = (X509TrustManager) trustManagers[0];
      // 这里传TLS或SSL其实都可以的
      SSLContext sslContext = SSLContext.getInstance("TLS");
      sslContext.init(null, new TrustManager[]{x509TrustManager}, new SecureRandom());
      return new SSLConnectionSocketFactory(sslContext);
   }
   // https请求，不作证书校验
   x509TrustManager = new X509TrustManager() {
      @Override
      public void checkClientTrusted(X509Certificate[] arg0, String arg1) {
      }
 
      @Override
      public void checkServerTrusted(X509Certificate[] arg0, String arg1) {
         // 不验证
      }
 
      @Override
      public X509Certificate[] getAcceptedIssuers() {
         return new X509Certificate[0];
      }
   };
   SSLContext sslContext = SSLContext.getInstance("TLS");
   sslContext.init(null, new TrustManager[]{x509TrustManager}, new SecureRandom());
   return new SSLConnectionSocketFactory(sslContext);
}
 
/**
 * 获取(密钥及证书)仓库
 * 注:该仓库用于存放 密钥以及证书
 *
 * @param caInputStream
 *         CA证书(此证书应由要访问的服务端提供)
 * @param cAalias
 *         别名
 *         注意:别名应该是唯一的， 别名不要和其他的别名一样，否者会覆盖之前的相同别名的证书信息。别名即key-value中的key。
 * @return 密钥、证书 仓库
 * @throws KeyStoreException 异常信息
 * @throws CertificateException 异常信息
 * @throws IOException 异常信息
 * @throws NoSuchAlgorithmException 异常信息
 * @date 2019/6/11 18:48
 */
private static KeyStore getKeyStore(InputStream caInputStream, String cAalias)
      throws KeyStoreException, CertificateException, IOException, NoSuchAlgorithmException {
   // 证书工厂
   CertificateFactory certificateFactory = CertificateFactory.getInstance("X.509");
   // 秘钥仓库
   KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
   keyStore.load(null);
   keyStore.setCertificateEntry(cAalias, certificateFactory.generateCertificate(caInputStream));
   return keyStore;
}
```



## 10、application/x-www-form-urlencoded表单请求(示例)：

![img](https://img-blog.csdnimg.cn/20190919181453842.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n,size_16,color_FFFFFF,t_70)



## 11、发送文件(示例)：

准备工作：

       如果想要灵活方便的传输文件的话，除了引入org.apache.httpcomponents基本的httpclient依赖外再额外引入org.apache.httpcomponents的httpmime依赖。
P.S.：即便不引入httpmime依赖，也是能传输文件的，不过功能不够强大。

在pom.xml中额外引入：

```xml
<!--
     如果需要灵活的传输文件，引入此依赖后会更加方便
-->
<dependency>
	<groupId>org.apache.httpcomponents</groupId>
	<artifactId>httpmime</artifactId>
	<version>4.5.5</version>
</dependency>
```

**发送端是这样的：**

```java
/**
 *

 * 发送文件
   *

 * multipart/form-data传递文件(及相关信息)
   *

 * 注:如果想要灵活方便的传输文件的话，

 * 除了引入org.apache.httpcomponents基本的httpclient依赖外

 * 再额外引入org.apache.httpcomponents的httpmime依赖。

 * 追注:即便不引入httpmime依赖，也是能传输文件的，不过功能不够强大。
    *
    */
   @Test
   public void test4() {
   CloseableHttpClient httpClient = HttpClientBuilder.create().build();
   HttpPost httpPost = new HttpPost("http://localhost:12345/file");
   CloseableHttpResponse response = null;
   try {
      MultipartEntityBuilder multipartEntityBuilder = MultipartEntityBuilder.create();
      // 第一个文件
      String filesKey = "files";
      File file1 = new File("C:\\Users\\JustryDeng\\Desktop\\back.jpg");
      multipartEntityBuilder.addBinaryBody(filesKey, file1);
      // 第二个文件(多个文件的话，使用同一个key就行，后端用数组或集合进行接收即可)
      File file2 = new File("C:\\Users\\JustryDeng\\Desktop\\头像.jpg");
      // 防止服务端收到的文件名乱码。 我们这里可以先将文件名URLEncode，然后服务端拿到文件名时在URLDecode。就能避免乱码问题。
      // 文件名其实是放在请求头的Content-Disposition里面进行传输的，如其值为form-data; name="files"; filename="头像.jpg"
      multipartEntityBuilder.addBinaryBody(filesKey, file2, ContentType.DEFAULT_BINARY, URLEncoder.encode(file2.getName(), "utf-8"));
      // 其它参数(注:自定义contentType，设置UTF-8是为了防止服务端拿到的参数出现乱码)
      ContentType contentType = ContentType.create("text/plain", Charset.forName("UTF-8"));
      multipartEntityBuilder.addTextBody("name", "邓沙利文", contentType);
      multipartEntityBuilder.addTextBody("age", "25", contentType);

      HttpEntity httpEntity = multipartEntityBuilder.build();
      httpPost.setEntity(httpEntity);

      response = httpClient.execute(httpPost);
      HttpEntity responseEntity = response.getEntity();
      System.out.println("HTTPS响应状态为:" + response.getStatusLine());
      if (responseEntity != null) {
         System.out.println("HTTPS响应内容长度为:" + responseEntity.getContentLength());
         // 主动设置编码，来防止响应乱码
         String responseStr = EntityUtils.toString(responseEntity, StandardCharsets.UTF_8);
         System.out.println("HTTPS响应内容为:" + responseStr);
      }
   } catch (ParseException | IOException e) {
      e.printStackTrace();
   } finally {
      try {
         // 释放资源
         if (httpClient != null) {
            httpClient.close();
         }
         if (response != null) {
            response.close();
         }
      } catch (IOException e) {
         e.printStackTrace();
      }
   }
   }
```

**接收端是这样的：**

![img](https://img-blog.csdnimg.cn/2019091918183139.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n,size_16,color_FFFFFF,t_70)



## 12、发送流(示例)：

**发送端是这样的：**

```java
/**
 *
 * 发送流
 *
 */
@Test
public void test5() {
   CloseableHttpClient httpClient = HttpClientBuilder.create().build();
   HttpPost httpPost = new HttpPost("http://localhost:12345/is?name=邓沙利文");
   CloseableHttpResponse response = null;
   try {
      InputStream is = new ByteArrayInputStream("流啊流~".getBytes());
      InputStreamEntity ise = new InputStreamEntity(is);
      httpPost.setEntity(ise);
 
      response = httpClient.execute(httpPost);
      HttpEntity responseEntity = response.getEntity();
      System.out.println("HTTPS响应状态为:" + response.getStatusLine());
      if (responseEntity != null) {
         System.out.println("HTTPS响应内容长度为:" + responseEntity.getContentLength());
         // 主动设置编码，来防止响应乱码
         String responseStr = EntityUtils.toString(responseEntity, StandardCharsets.UTF_8);
         System.out.println("HTTPS响应内容为:" + responseStr);
      }
   } catch (ParseException | IOException e) {
      e.printStackTrace();
   } finally {
      try {
         // 释放资源
         if (httpClient != null) {
            httpClient.close();
         }
         if (response != null) {
            response.close();
         }
      } catch (IOException e) {
         e.printStackTrace();
      }
   }
}
```

**接收端是这样的：**

![img](https://img-blog.csdnimg.cn/20190919192502513.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2p1c3RyeV9kZW5n,size_16,color_FFFFFF,t_70)

再次提示：如果想要自己进行测试，可去下面给的项目代码托管链接，将项目clone下来，然后先启动该
                  SpringBoot项目，然后再运行相关test方法，进行测试。

工具类提示：使用HttpClient时，可以视情况将其写为工具类。如：Github上Star非常多的一个HttpClient
                      的工具类是httpclientutil。本人在这里也推荐使用该工具类，因为该工具类的编写者封装了
                      很多功能在里面，如果不是有什么特殊的需求的话，完全可以不用造轮子，可以直接使用
                      该工具类。使用方式很简单，可详见https://github.com/Arronlong/httpclientutil。

代码托管链接[https://github.com/JustryDeng/P.../Abc_HttpClientDemo](https://github.com/JustryDeng/PublicRepository/tree/master/Abc_HttpClientDemo)

------------------------------------------------
