# [HttpClient模拟浏览器登录后发起请求](https://www.lmlphp.com/user/16918/article/item/565233/)

**浏览器实现这个效果需要如下几个步骤：**

  1请求一个需要登录的页面或资源

  2服务器判断当前的会话是否包含已登录信息。如果没有登录重定向到登录页面

  3手工在登录页面录入正确的账户信息并提交

  4服务器判断登录信息是否正确，如果正确则将登录成功信息保存到session中

  5登录成功后服务器端给浏览器返回会话的SessionID信息保存到客户端的Cookie中

  6浏览器自动跳转到之前的请求地址并携带之前的Cookie（包含登录成功的SessionID）

  7服务器端判断session中是否有成功登录信息，如果有则将请求的资源反馈给浏览器

```java
package com.artsoft.demo;

import java.io.FileOutputStream;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.CookieStore;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.PoolingClientConnectionManager;
import org.apache.http.util.EntityUtils;

/**
 * TODO(用一句话描述该文件的作用)
 *
 * @title: HttpClientDemo.java
 * @author zhangjinshan-ghq
 * @date 2014-6-11 14:59:04
 */

public class HttpClientDemo
{

  /**
   * The main method.
   *
   * @param args the arguments
   * @throws Exception the exception
   */
  public static void main(String[] args) throws Exception
  {
    getResoucesByLoginCookies();
  }

  /**
   * 根据登录Cookie获取资源
   * 一切异常均未处理，需要酌情检查异常
   *
   * @throws Exception
   */
  private static void getResoucesByLoginCookies() throws Exception
  {
    HttpClientDemo demo = new HttpClientDemo();
    String username = "......";// 登录用户
    String password = "......";// 登录密码

    // 需要提交登录的信息
    String urlLogin = "http://hx.buscoming.cn/Api/Security/Logon?UserCode=" + username + "&Password=" + password;

    // 登录成功后想要访问的页面 可以是下载资源 需要替换成自己的iteye Blog地址
    String urlAfter = "http://hx.buscoming.cn/Api/Security/GetLoginAccount";

    DefaultHttpClient client = new DefaultHttpClient(new PoolingClientConnectionManager());

    /**
     * 第一次请求登录页面 获得cookie
     * 相当于在登录页面点击登录，此处在URL中 构造参数，
     * 如果参数列表相当多的话可以使用HttpClient的方式构造参数
     * 此处不赘述
     */
    HttpPost post = new HttpPost(urlLogin);
    HttpResponse response = client.execute(post);
    HttpEntity entity = response.getEntity();
    CookieStore cookieStore = client.getCookieStore();
    client.setCookieStore(cookieStore);

    /**
     * 带着登录过的cookie请求下一个页面，可以是需要登录才能下载的url
     * 此处使用的是iteye的博客首页，如果登录成功，那么首页会显示【欢迎XXXX】
     *
     */
    HttpGet get = new HttpGet(urlAfter);
    response = client.execute(get);
    entity = response.getEntity();

    /**
     * 将请求结果放到文件系统中保存为 myindex.html,便于使用浏览器在本地打开 查看结果
     */

    String pathName = "d:\\index.html";
    writeHTMLtoFile(entity, pathName);
  }

  /**
   * Write htmL to file.
   * 将请求结果以二进制形式放到文件系统中保存为.html文件,便于使用浏览器在本地打开 查看结果
   *
   * @param entity the entity
   * @param pathName the path name
   * @throws Exception the exception
   */
  public static void writeHTMLtoFile(HttpEntity entity, String pathName) throws Exception
  {

    byte[] bytes = new byte[(int) entity.getContentLength()];

    FileOutputStream fos = new FileOutputStream(pathName);

    bytes = EntityUtils.toByteArray(entity);

    fos.write(bytes);

    fos.flush();

    fos.close();
  }

}

```





----

# [java 模拟form_java如何模拟发送form-data的请求](https://blog.csdn.net/weixin_29391747/article/details/114227001)

```java
package com.silot.test;

import org.apache.http.HttpResponse;

import org.apache.http.client.methods.HttpPost;

import org.apache.http.entity.mime.HttpMultipartMode;

import org.apache.http.entity.mime.MultipartEntity;

import org.apache.http.entity.mime.content.StringBody;

import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;

import java.io.InputStream;

import java.io.InputStreamReader;

import java.nio.charset.Charset;

public class TestCli

{

public static void main(String args[]) throws Exception

{

MultipartEntity multipartEntity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE, "------------------------------0ea3fcae38ff", Charset.defaultCharset());

multipartEntity.addPart("skey", new StringBody("哈哈哈哈哈", Charset.forName("UTF-8")));

multipartEntity.addPart("operator", new StringBody("啦啦啦啦", Charset.forName("UTF-8")));

multipartEntity.addPart("VrfKey", new StringBody("渣渣渣", Charset.forName("UTF-8")));

multipartEntity.addPart("StatCode", new StringBody("00", Charset.forName("UTF-8")));

multipartEntity.addPart("mass_id", new StringBody("1234", Charset.forName("UTF-8")));

multipartEntity.addPart("reference_id", new StringBody("21231544", Charset.forName("UTF-8")));

HttpPost request = new HttpPost("http://xiefei.s1.natapp.cc/v1/withdrawCallback");

request.setEntity(multipartEntity);

request.addHeader("Content-Type", "Content-Disposition: form-data; boundary=------------------------------0ea3fcae38ff");

DefaultHttpClient httpClient = new DefaultHttpClient();

HttpResponse response = httpClient.execute(request);

InputStream is = response.getEntity().getContent();

BufferedReader in = new BufferedReader(new InputStreamReader(is));

StringBuffer buffer = new StringBuffer();

String line = "";

while ((line = in.readLine()) != null)

{

buffer.append(line);

}

System.out.println("发送消息收到的返回：" + buffer.toString());

}

}

补充知识：java模拟复杂表单post请求

java模拟复杂表单post请求

能支持文件上传

/**

* 支持复杂表单，比如文件上传

* @param formParam

* @return

* @throws Exception

*/

public static String postWithForm(FormParam formParam) throws Exception {

String url = formParam.getUrl();

String charset = "UTF-8";

String boundary = Long.toHexString(System.currentTimeMillis()); // Just generate some unique random value.

String CRLF = "\r\n"; // Line separator required by multipart/form-data.

URLConnection connection = new URL(url).openConnection();

connection.setDoOutput(true);

connection.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

try (

OutputStream output = connection.getOutputStream();

PrintWriter writer = new PrintWriter(new OutputStreamWriter(output, charset), true);

) {

// make body param

Map bodyParam = formParam.getBodyParam();

if (null != bodyParam) {

for (String p : bodyParam.keySet()) {

writer.append("--" + boundary).append(CRLF);

writer.append("Content-Disposition: form-data; name=\"" + p + "\"").append(CRLF);

writer.append("Content-Type: text/plain; charset=" + charset).append(CRLF);

writer.append(CRLF).append(bodyParam.get(p)).append(CRLF).flush();

}

}

// Send file.

Map fileParam = formParam.getFileParam();

if (null != fileParam) {

for (String fileName : fileParam.keySet()) {

writer.append("--" + boundary).append(CRLF);

writer.append("Content-Disposition: form-data; name=\"" + fileName + "\"; filename=\""

+ fileParam.get(fileName).getName() + "\"").append(CRLF);

writer.append("Content-Type: " + URLConnection.guessContentTypeFromName(fileName)).append(CRLF);

writer.append("Content-Transfer-Encoding: binary").append(CRLF);

writer.append(CRLF).flush();

Files.copy(fileParam.get(fileName).toPath(), output);

output.flush(); // Important before continuing with writer!

writer.append(CRLF).flush(); // CRLF is important! It indicates end of boundary.

}

}

// End of multipart/form-data.

writer.append("--" + boundary + "--").append(CRLF).flush();

}

HttpURLConnection conn = (HttpURLConnection) connection;

ByteArrayOutputStream bout = new ByteArrayOutputStream();

int len;

byte[] buffer = new byte[1024];

while ((len = conn.getInputStream().read(buffer)) != -1) {

bout.write(buffer, 0, len);

}

String result = new String(bout.toByteArray(), "utf-8");

return result;

}

FormParam封装类:

package net.riking.core.utils;

import java.io.File;

import java.util.Map;

public class FormParam {

private String url;

//private String auth;

///**

// * http请求头里的参数

// */

//private Map headerParam;

/**

* 常规参数

*/

private Map bodyParam;

/**

* 待上传的文件参数 filename和file

*/

private Map fileParam;

public String getUrl() {

return url;

}

public void setUrl(String url) {

this.url = url;

}

//public String getAuth() {

//return auth;

//}

//

//public void setAuth(String auth) {

//this.auth = auth;

//}

//

//public Map getHeaderParam() {

//return headerParam;

//}

//

//public void setHeaderParam(Map headerParam) {

//this.headerParam = headerParam;

//}

public Map getBodyParam() {

return bodyParam;

}

public void setBodyParam(Map bodyParam) {

this.bodyParam = bodyParam;

}

public Map getFileParam() {

return fileParam;

}

public void setFileParam(Map fileParam) {

this.fileParam = fileParam;

}

}
```



----

```java
public class HttpUtils {
/**
 * 请求超时时间
 */
private static final int TIME_OUT = 120000;

/**
 * Https请求
 */
private static final String HTTPS = "https";

/**
 * Content-Type
 */
private static final String CONTENT_TYPE = "Content-Type";

/**
 * 表单提交方式Content-Type
 */
private static final String FORM_TYPE = "application/x-www-form-urlencoded;charset=UTF-8";

/**
 * JSON提交方式Content-Type
 */
private static final String JSON_TYPE = "application/json;charset=UTF-8";

/**
 * 发送Get请求
 *
 * @param url 请求URL
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response get(String url) throws IOException {
    return get(url, null);
}

/**
 * 发送Get请求
 *
 * @param url 请求URL
 * @param headers 请求头参数
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response get(String url, Map<String, String> headers) throws IOException {
    if (null == url || url.isEmpty()) {
        throw new RuntimeException("The request URL is blank.");
    }

    // 如果是Https请求
    if (url.startsWith(HTTPS)) {
        getTrust();
    }
    Connection connection = Jsoup.connect(url);
    connection.method(Method.GET);
    connection.timeout(TIME_OUT);
    connection.ignoreHttpErrors(true);
    connection.ignoreContentType(true);
    connection.maxBodySize(0);

    if (null != headers) {
        connection.headers(headers);
    }

    Response response = connection.execute();
    return response;
}

/**
 * 发送JSON格式参数POST请求
 *
 * @param url 请求路径
 * @param params JSON格式请求参数
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response post(String url, String params) throws IOException {
    return doPostRequest(url, null, params);
}

/**
 * 发送JSON格式参数POST请求
 *
 * @param url 请求路径
 * @param headers 请求头中设置的参数
 * @param params JSON格式请求参数
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response post(String url, Map<String, String> headers, String params) throws IOException {
    return doPostRequest(url, headers, params);
}

/**
 * 字符串参数post请求
 *
 * @param url 请求URL地址
 * @param paramMap 请求字符串参数集合
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response post(String url, Map<String, String> paramMap) throws IOException {
    return doPostRequest(url, null, paramMap, null);
}

/**
 * 带请求头的普通表单提交方式post请求
 *
 * @param headers 请求头参数
 * @param url 请求URL地址
 * @param paramMap 请求字符串参数集合
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response post(Map<String, String> headers, String url, Map<String, String> paramMap) throws IOException {
    return doPostRequest(url, headers, paramMap, null);
}

/**
 * 带上传文件的post请求
 *
 * @param url 请求URL地址
 * @param paramMap 请求字符串参数集合
 * @param fileMap 请求文件参数集合
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response post(String url, Map<String, String> paramMap, Map<String, File> fileMap) throws IOException {
    return doPostRequest(url, null, paramMap, fileMap);
}

/**
 * 带请求头的上传文件post请求
 *
 * @param url 请求URL地址
 * @param headers 请求头参数
 * @param paramMap 请求字符串参数集合
 * @param fileMap 请求文件参数集合
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
public static Response post(String url, Map<String, String> headers, Map<String, String> paramMap, Map<String, File> fileMap) throws IOException {
    return doPostRequest(url, headers, paramMap, fileMap);
}

/**
 * 执行post请求
 *
 * @param url 请求URL地址
 * @param headers 请求头
 * @param jsonParams 请求JSON格式字符串参数
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
private static Response doPostRequest(String url, Map<String, String> headers, String jsonParams) throws IOException {
    if (null == url || url.isEmpty()) {
        throw new RuntimeException("The request URL is blank.");
    }

    // 如果是Https请求
    if (url.startsWith(HTTPS)) {
        getTrust();
    }

    Connection connection = Jsoup.connect(url);
    connection.method(Method.POST);
    connection.timeout(TIME_OUT);
    connection.ignoreHttpErrors(true);
    connection.ignoreContentType(true);
    connection.maxBodySize(0);

    if (null != headers) {
        connection.headers(headers);
    }

    connection.header(CONTENT_TYPE, JSON_TYPE);
    connection.requestBody(jsonParams);

    Response response = connection.execute();
    return response;
}

/**
 * 普通表单方式发送POST请求
 *
 * @param url 请求URL地址
 * @param headers 请求头
 * @param paramMap 请求字符串参数集合
 * @param fileMap 请求文件参数集合
 * @return HTTP响应对象
 * @throws IOException 程序异常时抛出，由调用者处理
 */
private static Response doPostRequest(String url, Map<String, String> headers, Map<String, String> paramMap, Map<String, File> fileMap) throws IOException {
    if (null == url || url.isEmpty()) {
        throw new RuntimeException("The request URL is blank.");
    }

    // 如果是Https请求
    if (url.startsWith(HTTPS)) {
        getTrust();
    }

    Connection connection = Jsoup.connect(url);
    connection.method(Method.POST);
    connection.timeout(TIME_OUT);
    connection.ignoreHttpErrors(true);
    connection.ignoreContentType(true);
    connection.maxBodySize(0);

    if (null != headers) {
        connection.headers(headers);
    }

    // 收集上传文件输入流，最终全部关闭
    List<InputStream> inputStreamList = null;
    try {

        // 添加文件参数
        if (null != fileMap && !fileMap.isEmpty()) {
            inputStreamList = new ArrayList<InputStream>();
            InputStream in = null;
            File file = null;
            for (Entry<String, File> e : fileMap.entrySet()) {
                file = e.getValue();
                in = new FileInputStream(file);
                inputStreamList.add(in);
                connection.data(e.getKey(), file.getName(), in);
            }
        }

        // 普通表单提交方式
        else {
            connection.header(CONTENT_TYPE, FORM_TYPE);
        }

        // 添加字符串类参数
        if (null != paramMap && !paramMap.isEmpty()) {
            connection.data(paramMap);
        }

        Response response = connection.execute();
        return response;
    }

    // 关闭上传文件的输入流
    finally {
        closeStream(inputStreamList);
    }
}

/**
 * 关流
 *
 * @param streamList 流集合
 */
private static void closeStream(List<? extends Closeable> streamList) {
    if (null != streamList) {
        for (Closeable stream : streamList) {
            try {
                stream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

/**
 * 获取服务器信任
 */
private static void getTrust() {
    try {
        HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier() {

            public boolean verify(String hostname, SSLSession session) {
                return true;
            }
        });
        SSLContext context = SSLContext.getInstance("TLS");
        context.init(null, new X509TrustManager[] { new X509TrustManager() {

            public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {}

            public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {}

            public X509Certificate[] getAcceptedIssuers() {
                return new X509Certificate[0];
            }
        } }, new SecureRandom());
        HttpsURLConnection.setDefaultSSLSocketFactory(context.getSocketFactory());
    } catch (Exception e) {
        e.printStackTrace();
    }
}
}
```

