# [JavaWeb项目中如何扩展一个Request对象——包装器HttpServletRequestWrapper](https://blog.csdn.net/u011047968/article/details/106559867)

一、使用场景
在一个JavaWeb中我们会遇到统一处理出入参或者处理特殊参数的场景，这些场景就需要我们扩展我们的Request对象。所谓的包装器就是在原来的基础上包装一下就是在原来功能上添加一些其他功能。具体使用场景如下：

处理过滤器中参数统一加解密问题
需要为特殊请求扩展参数问题。
二、具体实现
1、首先继承HttpServletRequestWrapper

```java
public class MyRequestWrapper extends HttpServletRequestWrapper {

    private Map params = new HashMap<>();

    public MyRequestWrapper(HttpServletRequest request, Map newParams) {
        super(request);
        if(request.getParameterMap() != null){
            this.params.putAll(request.getParameterMap());
        }
        if(newParams != null){
            this.params.putAll(newParams);
        }
    }

    //主要覆盖这个方法来获取新的参数对象
    @Override
    public Map getParameterMap() {
        return params;
    }

    public Enumeration getParameterNames() {
        Vector l = new Vector(params.keySet());
        return l.elements();
    }


    @Override
    public String[] getParameterValues(String name) {
        Object v = params.get(name);
        if (v == null) {
            return null;
        } else if (v instanceof String[]) {
            return (String[]) v;
        } else if (v instanceof String) {
            return new String[]{(String) v};
        } else {
            return new String[]{v.toString()};
        }
    }

    /**
     * 根据参数的key获取参数
     * @param name
     * @return
     */
    @Override
    public String getParameter(String name) {
        Object v = params.get(name);
        if (v == null) {
            return null;
        } else if (v instanceof String[]) {
            String[] strArr = (String[]) v;
            if (strArr.length > 0) {
                return strArr[0];
            } else {
                return null;
            }
        } else if (v instanceof String) {
            return (String) v;
        } else {
            return v.toString();
        }
    }
}
```

##### 2、编写过滤器代码

```java
public class MyFilter implements Filter {
    //日志
    private static final Logger LOGGER = LogManager.getLogger();
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("MyFilter过滤器初始化");
    }
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        //获取HttpServletRequest对象
        HttpServletRequest httpServletRequest = (HttpServletRequest) request;
        String ipAddr = HttpUtil.getIpAddress(httpServletRequest);
        LOGGER.info("ip地址为：" + ipAddr);
        Map paramMap = new HashMap<>();
        paramMap.put("ipAddr", ipAddr);
        MyRequestWrapper myRequestWrapper = new MyRequestWrapper(httpServletRequest, paramMap);
        chain.doFilter(myRequestWrapper, response);
    }
    @Override
    public void destroy() {
        LOGGER.info("MyFilter过滤器被销毁");
    }
}
```

编写完过滤器需要在`web.xml`添加过滤器配置

```xml
    <filter>
        <filter-name>MyFilter</filter-name>
        <filter-class>com.leo.filter.MyFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>MyFilter</filter-name>
        <url-pattern>/*</url-pattern>		//拦截所有路径
    </filter-mapping>
```

##### 3、编写测试代码

```java
    @RequestMapping(value = "/getIpAddr", method = RequestMethod.GET)
    @ResponseBody
    public String getIpAddr(HttpServletRequest request){
        String ipAddr = request.getParameter("ipAddr");
        LOGGER.info("获取参数：" + ipAddr);
        return ipAddr;
    }
```

启动项目，访问：http://localhost:8080/springmvc/getIpAddr

后台日志：

```shell
2020-06-04 23:53:26.365 INFO  com.leo.util.HttpUtil:25 [http-apr-8080-exec-3] - getIpAddress(HttpServletRequest) - X-Forwarded-For - String ip=null
2020-06-04 23:53:26.368 INFO  com.leo.util.HttpUtil:33 [http-apr-8080-exec-3] - getIpAddress(HttpServletRequest) - Proxy-Client-IP - String ip=null
2020-06-04 23:53:26.369 INFO  com.leo.util.HttpUtil:39 [http-apr-8080-exec-3] - getIpAddress(HttpServletRequest) - WL-Proxy-Client-IP - String ip=null
2020-06-04 23:53:26.370 INFO  com.leo.util.HttpUtil:45 [http-apr-8080-exec-3] - getIpAddress(HttpServletRequest) - HTTP_CLIENT_IP - String ip=null
2020-06-04 23:53:26.371 INFO  com.leo.util.HttpUtil:51 [http-apr-8080-exec-3] - getIpAddress(HttpServletRequest) - HTTP_X_FORWARDED_FOR - String ip=null
2020-06-04 23:53:26.372 INFO  com.leo.util.HttpUtil:57 [http-apr-8080-exec-3] - getIpAddress(HttpServletRequest) - getRemoteAddr - String ip=127.0.0.1
2020-06-04 23:53:26.373 INFO  com.leo.filter.MyFilter:38 [http-apr-8080-exec-3] - ip地址为：127.0.0.1
2020-06-04 23:53:26.375 INFO  com.leo.interceptor.HandlerInterceptor1:26 [http-apr-8080-exec-3] - HandlerInterceptor1 preHandle
2020-06-04 23:53:26.376 INFO  com.leo.controller.HelloController:129 [http-apr-8080-exec-3] - 获取参数：127.0.0.1
2020-06-04 23:53:26.380 INFO  com.leo.interceptor.HandlerInterceptor1:34 [http-apr-8080-exec-3] - HandlerInterceptor1 postHandle
2020-06-04 23:53:26.381 INFO  com.leo.interceptor.HandlerInterceptor1:39 [http-apr-8080-exec-3] - HandlerInterceptor1 afterCompletion
2020-06-04 23:53:26.382 INFO  com.leo.interceptor.HandlerInterceptor1:42 [http-apr-8080-exec-3] - HandlerInterceptor1 过滤的接口耗时：6ms
```


完整代码请参考：
chapter-6-springmvc-mybatis1（常规整合）
https://gitee.com/leo825/spring-framework-learning-example.git

