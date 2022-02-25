# RequestContextHolder获取request

分类专栏： [框架笔记](https://blog.csdn.net/weixin_44251024/category_8558534.html) 文章标签： [request](https://www.csdn.net/tags/MtTaEg0sMTEzMjUtYmxvZwO0O0OO0O0O.html)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190118184143583.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDI1MTAyNA==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/2019011818423733.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDI1MTAyNA==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190118184323751.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDI1MTAyNA==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190118184433832.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDI1MTAyNA==,size_16,color_FFFFFF,t_70)

在Web开发中，service层或者某个工具类中需要获取到HttpServletRequest对象还是比较常见的。一种方式是将HttpServletRequest作为方法的参数从controller层一直放下传递，不过这种有点费劲，且做起来不是优雅；还有另一种则是RequestContextHolder，直接在需要用的地方使用如下方式取HttpServletRequest即可，使用代码如下：

```
HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder
        .getRequestAttributes()).getRequest();
12
```

要理解上面的为何可以这么使用，需要理解两个问题：

RequestContextHolder为什么能获取到当前的HttpServletRequest
HttpServletRequest是在什么时候设置到RequestContextHolder

对于第1个问题，熟悉ThreadLocal的人应该很容易看出来这个是ThreadLocal的应用，这个类的原理在上一篇博文(ThreadLocal原理)有讲到，其实很类似上篇博文文末提到的UserContextHolder。
第2个问题应该属于spring-mvc的问题，这个是在spring-mvc执行时设置进去的

源码分析
首先我们先来看下RequestContextHolder的源码，源码如下：

```
public abstract class RequestContextHolder  {

    private static final ThreadLocal<RequestAttributes> requestAttributesHolder =
            new NamedThreadLocal<RequestAttributes>("Request attributes");

    private static final ThreadLocal<RequestAttributes> inheritableRequestAttributesHolder =
            new NamedInheritableThreadLocal<RequestAttributes>("Request context");


    public static void resetRequestAttributes() {
        requestAttributesHolder.remove();
        inheritableRequestAttributesHolder.remove();
    }


    public static void setRequestAttributes(RequestAttributes attributes) {
        setRequestAttributes(attributes, false);
    }

    //将RequestAttributes对象放入到ThreadLocal中，而HttpServletRequest和HttpServletResponse等则封装在RequestAttributes对象中，在此处就不对RequestAttributes这个类展开。反正我们需要知道的就是要获取RequestAttributes对象，然后再从RequestAttributes对象中获取到我们所需要的HttpServletRequest即可
    public static void setRequestAttributes(RequestAttributes attributes, boolean inheritable) {
        if (attributes == null) {
            resetRequestAttributes();
        }
        else {
            if (inheritable) {
                inheritableRequestAttributesHolder.set(attributes);
                requestAttributesHolder.remove();
            }
            else {
                requestAttributesHolder.set(attributes);
                inheritableRequestAttributesHolder.remove();
            }
        }
    }

    public static RequestAttributes getRequestAttributes() {
        RequestAttributes attributes = requestAttributesHolder.get();
        if (attributes == null) {
            attributes = inheritableRequestAttributesHolder.get();
        }
        return attributes;
    }

}

12345678910111213141516171819202122232425262728293031323334353637383940414243444546
```

那么在spring-mvc中是怎么实现的呢，我们来简单分析的，想了解具体机制的可以去看看spring-mvc的源码。
我们看下FrameworkServlet这个类，也就是DispatcherServlet的父类，里面有个processRequest方法，根据方法名称我们也可以大概了解到这个是方法用于处理请求的。

```
protected final void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        long startTime = System.currentTimeMillis();
        Throwable failureCause = null;

        LocaleContext previousLocaleContext = LocaleContextHolder.getLocaleContext();
        LocaleContext localeContext = buildLocaleContext(request);

        RequestAttributes previousAttributes = RequestContextHolder.getRequestAttributes();
        ServletRequestAttributes requestAttributes = buildRequestAttributes(request, response, previousAttributes);

        WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);
        asyncManager.registerCallableInterceptor(FrameworkServlet.class.getName(), new RequestBindingInterceptor());

        //将RequestAttributes设置到RequestContextHolder
        initContextHolders(request, localeContext, requestAttributes);

        try {
            //具体的业务逻辑
            doService(request, response);
        }
        catch (ServletException ex) {
            failureCause = ex;
            throw ex;
        }
        catch (IOException ex) {
            failureCause = ex;
            throw ex;
        }
        catch (Throwable ex) {
            failureCause = ex;
            throw new NestedServletException("Request processing failed", ex);
        }

        finally {
            //重置RequestContextHolder之前设置RequestAttributes
            resetContextHolders(request, previousLocaleContext, previousAttributes);
            if (requestAttributes != null) {
                requestAttributes.requestCompleted();
            }

            if (logger.isDebugEnabled()) {
                if (failureCause != null) {
                    this.logger.debug("Could not complete request", failureCause);
                }
                else {
                    if (asyncManager.isConcurrentHandlingStarted()) {
                        logger.debug("Leaving response open for concurrent processing");
                    }
                    else {
                        this.logger.debug("Successfully completed request");
                    }
                }
            }

            publishRequestHandledEvent(request, response, startTime, failureCause);
        }
    }
    
    
    private void initContextHolders(
            HttpServletRequest request, LocaleContext localeContext, RequestAttributes requestAttributes) {

        if (localeContext != null) {
            LocaleContextHolder.setLocaleContext(localeContext, this.threadContextInheritable);
        }
        if (requestAttributes != null) {
            RequestContextHolder.setRequestAttributes(requestAttributes, this.threadContextInheritable);
        }
        if (logger.isTraceEnabled()) {
            logger.trace("Bound request context to thread: " + request);
        }
    }


12345678910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364656667686970717273747576
```

简单看下源码，我们可以知道HttpServletRequest是在执行doService方法之前，也就是具体的业务逻辑前进行设置的，然后在执行完业务逻辑或者抛出异常时重置RequestContextHolder移除当前的HttpServletRequest。

【多线程】ThreadLocal原理
使用
在每个线程的内部有个数据结构为Map的threadLocals变量，以<ThreadLocal,Value>的形式保存着线程变量和其对应的值。
当使用set()方法时：

1.获取到当前线程的threadLocals，类型为Map
2.将这值放到这个Map结构的变量中，key为ThreadLocal对象，value为所有存放的值

当使用get()方法时：

1.获取到当前线程的threadLocals，类型为Map。
2.以ThreadLocal对象为Map的key获取到它的value值。

因为ThreadLocal对象作为Map的key，所以一个ThreadLocal对象只能存放一个值，当存放多个时，会将新值覆盖旧值。

数据结构：

```
public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);//当前线程为入参，获取当前线程的threadLocals变量
        if (map != null)
         //入参为this，也就是说key为ThreadLocal对象
            map.set(this, value);
        else
            createMap(t, value);
    }

    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);//当前线程为入参，获取当前线程的threadLocals
        if (map != null) {
            //入参为this，也就是说key为ThreadLocal
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
    
    ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;//threadLocals为线程的变量
    }
    
    private Entry getEntry(ThreadLocal<?> key) {
        int i = key.threadLocalHashCode & (table.length - 1);
        Entry e = table[i];
        if (e != null && e.get() == key)
            return e;
        else
            return getEntryAfterMiss(key, i, e);//避免内存泄漏，下文有提。
    }

1234567891011121314151617181920212223242526272829303132333435363738
```

【多线程】ThreadLocal原理https://www.jianshu.com/p/6bf1adb775e0



----

# 非Controller层通过RequestContextHolder.getRequestAttributes()获取HttpServletRequest，HttpServletRespon空指针问题

东谌 2019-01-20 15:37:57  20106  收藏 9
分类专栏： Spring Mvc
版权
       有时我们需要在非Controller层如service层而不通过Controller层传参方式而获得HttpServletRequest，HttpServletResponse，通过查找到RequestContextHolder是Spring提供的可以获取HttpServletRequest的一个工具，于是我在工作中就自己封装了一个工具类如下：

```
public class ServletUtils {
    /**

   * 获取String参数
     /
         public static String getParameter(String name) {
     return getRequest().getParameter(name);
         }

/**

 * 获取request
   */
   public static HttpServletRequest getRequest() {
   return getRequestAttributes().getRequest();
   }

/**

 * 获取response
   */
   public static HttpServletResponse getResponse() {
   return getRequestAttributes().getResponse();
   }

/**

 * 获取session
   */
   public static HttpSession getSession() {
   return getRequest().getSession();
   }

public static ServletRequestAttributes getRequestAttributes() {
    RequestAttributes attributes = RequestContextHolder.getRequestAttributes();
    return (ServletRequestAttributes) attributes;
}
}


```



```
编码时没问题，但是实际调用时RequestContextHolder.getRequestAttributes()空指针异常。
对RequestContextHolder源码分析，可参考博客 https://blog.csdn.net/u012706811/article/details/53432032
```

解决办法：

在web.xml配置RequestContextListener监听器:

```
<listener>
      <listener-class>
          org.springframework.web.context.request.RequestContextListener
      </listener-class>
</listener>
```

或者WebConfig.class中添加

 * ```
 /**
 
  * RequestContextListener监听器
    * @return
    */
    @Bean
    public RequestContextListener requestContextListenerBean() {
    return new RequestContextListener();
    }
 ```
 
 原理分析

RequestContextListener实现了ServletRequestListener ,在其覆盖的requestInitialized(ServletRequestEvent requestEvent)方法中,将request最终设置到了RequestContextHolder中.

```
public class RequestContextListener implements ServletRequestListener {
    private static final String REQUEST_ATTRIBUTES_ATTRIBUTE = RequestContextListener.class.getName() + ".REQUEST_ATTRIBUTES";
    

public RequestContextListener() {
}

public void requestInitialized(ServletRequestEvent requestEvent) {
    if (!(requestEvent.getServletRequest() instanceof HttpServletRequest)) {
        throw new IllegalArgumentException("Request is not an HttpServletRequest: " + requestEvent.getServletRequest());
    } else {
        HttpServletRequest request = (HttpServletRequest)requestEvent.getServletRequest();
        ServletRequestAttributes attributes = new ServletRequestAttributes(request);
        request.setAttribute(REQUEST_ATTRIBUTES_ATTRIBUTE, attributes);
        LocaleContextHolder.setLocale(request.getLocale());
        RequestContextHolder.setRequestAttributes(attributes);
    }
}
```

配置RequestContextListener时大家可能会想到ContextLoaderListener

RequestContextListener与ContextLoaderListener区别：

ContextLoaderListener
ContextLoaderListener extends ContextLoader implements ServletContextListener。

ServletContextListener extends EventListener。 
ServletContextListener只负责监听Web容器的启动和关闭的事件。

ContextLoaderListener(或ContextLoaderServlet)将Web容器与spring容器进行整合。

这是使用Spring 必须配置 的：

```
  <listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
  </listener> 
```

Spring配置文件的声明：

```
<context-param>
  <param-name>contextConfigLocation</param-name>
  <param-value>classpath:applicationContext.xml</param-value>
</context-param>
```

如果没有显式声明，则 系统默认 在WEB-INF/applicationContext.xml。

在一个团队使用Spring的实际项目中，应该需要多个Spring的配置文件，如何使用和交叉引用的问题： 
如果想装入多个配置文件，可以用逗号作分隔符，如：

```
<context-param>
  <param-name>contextConfigLocation</param-name>
  <param-value>applicationContext-database.xml，applicationContext.xml</param-value>
</context-param>
```

多个配置文件里的交叉引用可以用ref的external或bean解决，例如:

applicationContext.xml

```
<bean id="userService" class="domain.user.service.impl.UserServiceImpl"> 
    <property name="dbbean">
         <ref bean="dbBean"/>
    </property> 
</bean>
```

dbBean在applicationContext-database.xml中。

RequestContextListener
RequestContextListener implements ServletRequestListener

ServletRequestListener extends EventListener 
ServletRequestListener监听HTTP请求事件，Web服务器接收的每次请求都会通知该监听器。

RequestContextListener将Spring容器与Web容器结合的更加密切。这是可选配置，并且后者与scope=”request”搭配使用：

```
<listener>
  <listener-class>org.springframework.web.context.request.RequestContextListener</listener-class>
</listener>
```

两者区别
ContextLoaderListener(或ContextLoaderServlet)将Web容器与spring容器整合。RequestContextListener将Spring容器与Web容器结合的更加密切。 
前者为必选配置，后者为可选配置，并且后者与scope=”request”搭配使用。