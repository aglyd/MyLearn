# [Spring Security Web 5.1.2 -- HttpSessionRequestCache源码分析][https://blog.csdn.net/andy_zhang2007/article/details/84846764]

## 概述

**Spring Security Web认证机制(通常指表单登录)中登录成功后页面需要跳转到原来客户请求的URL。该过程中首先需要将原来的客户请求缓存下来，然后登录成功后将缓存的请求从缓存中提取出来。**

**针对该需求，Spring Security Web 提供了在http session中缓存请求的能力，也就是HttpSessionRequestCache。HttpSessionRequestCache所保存的请求必须封装成一个SavedRequest接口对象，实际上，HttpSessionRequestCache总是使用自己的SavedRequest缺省实现DefaultSavedRequest。**

==要获取HttpSessionRequestCache对象可直接new HttpSessionRequestCache();使用.getRequest(request,response)会获取到当前request的session从中获取保存的缓存SavedRequest，因此是动态获取到当前用户的session中的SavedRequest==

源代码解析

```
**

 *  * ```
      /**
      
       * RequestCache which stores the SavedRequest in the HttpSession.
      
       * 将SavedRequest保存到HttpSession中的RequestCache。
         *
      
       * The DefaultSavedRequest class is used as the implementation.
      
       * 这里使用的SavedRequest是其缺省实现DefaultSavedRequest。
         *
      
       * @author Luke Taylor
      
       * @author Eddú Meléndez
      
       * @since 3.0
         */
         public class HttpSessionRequestCache implements RequestCache {
         // 将请求缓存到session时缺省使用的session属性名称
         static final String SAVED_REQUEST = "SPRING_SECURITY_SAVED_REQUEST";
         protected final Log logger = LogFactory.getLog(this.getClass());
      
         // 用于解析请求中的 server:port 信息
         private PortResolver portResolver = new PortResolverImpl();
         //  如果session不存在是否允许创建，缺省为true可以创建
         private boolean createSessionAllowed = true;
         // 用于判断哪些请求可以被缓存的请求匹配器，缺省为任何请求都可以被缓存，
         // 实际上会被外部指定覆盖成:
         // 1. 必须是 GET /**
         // 2. 并且不能是 /**/favicon.*
         // 3. 并且不能是 application.json
         // 4. 并且不能是 XMLHttpRequest (也就是一般意义上的 ajax 请求)
         private RequestMatcher requestMatcher = AnyRequestMatcher.INSTANCE;
         // 将请求缓存到session时使用的session属性名称，初始化为使用SAVED_REQUEST
         private String sessionAttrName = SAVED_REQUEST;
      
         /**
      
          * Stores the current request, provided the configuration properties allow it.
          * 在配置属性requestMatcher匹配的情况下缓存当前请求
            */
            public void saveRequest(HttpServletRequest request, HttpServletResponse response) {
            if (requestMatcher.matches(request)) {
            	// 在配置属性requestMatcher匹配的情况下缓存当前请求，
            	//  首先将当前请求包装成一个DefaultSavedRequest,也就是从当前请求中获取
            	// 各种必要的信息组装成一个DefaultSavedRequest
            	DefaultSavedRequest savedRequest = new DefaultSavedRequest(request,
            			portResolver);
```

​      

      	// 获取session并执行缓存动作，也就是将上面创建的DefaultSavedRequest对象
      	// 添加为session的一个名称为this.sessionAttrName的属性
      	if (createSessionAllowed || request.getSession(false) != null) {
      		// Store the HTTP request itself. Used by
      		// AbstractAuthenticationProcessingFilter
      		// for redirection after successful authentication (SEC-29)
      		request.getSession().setAttribute(this.sessionAttrName, savedRequest);
      		logger.debug("DefaultSavedRequest added to Session: " + savedRequest);
      	}
    
      }
      else {
      	logger.debug("Request not saved as configured RequestMatcher did not match");
      }
      }

   // 从session中提取所缓存的请求对象，也就是获取session中名称为this.sessionAttrName的属性，
   // 如果 session 不存在直接返回 null
   public SavedRequest getRequest(HttpServletRequest currentRequest,
   		HttpServletResponse response) {
   	HttpSession session = currentRequest.getSession(false);

   	if (session != null) {
   		return (SavedRequest) session.getAttribute(this.sessionAttrName);
   	}
   	
   	return null;

   }

   // 从 session 中删除所缓存的请求对象,也就是移除session中名称为this.sessionAttrName的属性
   public void removeRequest(HttpServletRequest currentRequest,
   		HttpServletResponse response) {
   	HttpSession session = currentRequest.getSession(false);

   	if (session != null) {
   		logger.debug("Removing DefaultSavedRequest from session if present");
   		session.removeAttribute(this.sessionAttrName);
   	}

   }

   // 从 session 获取缓存的请求对象，检验它和当前请求是否一致，如果一致的话将其封装成
   // 一个SavedRequestAwareWrapper返回，同时删除所缓存的请求。其他情况则不做任何修改
   // 动作，直接返回null。
   public HttpServletRequest getMatchingRequest(HttpServletRequest request,
   		HttpServletResponse response) {
   	// 从 session 获取缓存的请求对象	
   	SavedRequest saved = getRequest(request, response);

   	if (!matchesSavedRequest(request, saved)) {
   	// 如果缓存的请求和当前请求不匹配则返回null
   		logger.debug("saved request doesn't match");
   		return null;
   	}
   	// 如果缓存的请求和当前请求匹配则删除缓存中缓存的请求对象
   	removeRequest(request, response);
   	
   	// 封装和返回从缓存中提取到的请求对象
   	return new SavedRequestAwareWrapper(saved, request);

   }

   // 检测当前请求和参数savedRequest是否匹配
   private boolean matchesSavedRequest(HttpServletRequest request, SavedRequest savedRequest) {
   	if (savedRequest == null) {
   		return false;
   	}
   	

   ```
   
   	if (savedRequest instanceof DefaultSavedRequest) {
   	// 如果savedRequest是一个DefaultSavedRequest，则使用DefaultSavedRequest的
   	// 方法doesRequestMatch检验是否匹配
   		DefaultSavedRequest defaultSavedRequest = (DefaultSavedRequest) savedRequest;
   		return defaultSavedRequest.doesRequestMatch(request, this.portResolver);
   	}
   	
   	// 如果savedRequest不是一个DefaultSavedRequest，则通过比较二者的url是否相等
   	// 来检验二者是否匹配
   	String currentUrl = UrlUtils.buildFullRequestUrl(request);
   	return savedRequest.getRedirectUrl().equals(currentUrl);
   
   }
   
   /**
   
    * Allows selective use of saved requests for a subset of requests. By default any
    * request will be cached by the  saveRequest method.
    * 
    * If set, only matching requests will be cached.
    * 
    * 指定哪些请求会被缓存，如果不指定，缺省情况是所有请求都会被缓存
    * @param requestMatcher a request matching strategy which defines which requests
    * should be cached.
      */
      public void setRequestMatcher(RequestMatcher requestMatcher) {
      this.requestMatcher = requestMatcher;
      }
   
   /**
   
    * If true, indicates that it is permitted to store the target URL and
    * exception information in a new HttpSession (the default). In
    * situations where you do not wish to unnecessarily create HttpSessions
    * - because the user agent will know the failed URL, such as with BASIC or Digest
    * authentication - you may wish to set this property to false.
      */
      public void setCreateSessionAllowed(boolean createSessionAllowed) {
      this.createSessionAllowed = createSessionAllowed;
      }
   
   public void setPortResolver(PortResolver portResolver) {
   	this.portResolver = portResolver;
   }
   
   /**
   
    * If the sessionAttrName property is set, the request is stored in
    * the session using this attribute name. Default is
    * "SPRING_SECURITY_SAVED_REQUEST".
      *
    * @param sessionAttrName a new session attribute name.
    * @since 4.2.1
      */
      public void setSessionAttrName(String sessionAttrName) {
      this.sessionAttrName = sessionAttrName;
      }
      }
   

   
   ```





# [【Spring实战】----security4.1.3认证的过程以及原请求信息的缓存及恢复（RequestCache）][https://blog.csdn.net/honghailiang888/article/details/53671108]

一、先看下认证过程
认证过程分为7步:
1.用户访问网站，打开了一个链接(origin url)。

2.请求发送给服务器，服务器判断用户请求了受保护的资源。

3.由于用户没有登录，服务器重定向到登录页面

4.填写表单，点击登录

5.浏览器将用户名密码以表单形式发送给服务器

6.服务器验证用户名密码。成功，进入到下一步。否则要求用户重新认证（第三步）

7.服务器对用户拥有的权限（角色）判定: 有权限，重定向到origin url; 权限不足，返回状态码403("forbidden").

从第3步，我们可以知道，用户的请求被中断了。

用户登录成功后（第7步），会被重定向到origin url，spring security通过使用缓存的request，使得被中断的请求能够继续执行。



二、使用缓存

用户登录成功后，页面重定向到origin url。浏览器发出的请求优先被拦截器RequestCacheAwareFilter拦截，RequestCacheAwareFilter通过其持有的RequestCache对象实现request的恢复。

```
public void doFilter(ServletRequest request, ServletResponse response,
 FilterChain chain) throws IOException, ServletException {

 // request匹配，则取出，该操作同时会将缓存的request从session中删除
HttpServletRequest wrappedSavedRequest = requestCache.getMatchingRequest(
 (HttpServletRequest) request, (HttpServletResponse) response);

 // 优先使用缓存的request
 chain.doFilter(wrappedSavedRequest == null ? request : wrappedSavedRequest,
 response);
 }
```


三、何时缓存

首先，我们需要了解下RequestCache以及ExceptionTranslationFilter。

1）RequestCache

RequestCache接口声明了缓存与恢复操作。默认实现类是HttpSessionRequestCache。接口的声明如下:

```
public interface RequestCache {

 // 将request缓存到session中
void saveRequest(HttpServletRequest request, HttpServletResponse response);

 // 从session中取request
 SavedRequest getRequest(HttpServletRequest request, HttpServletResponse response);

 // 获得与当前request匹配的缓存，并将匹配的request从session中删除
HttpServletRequest getMatchingRequest(HttpServletRequest request,
 HttpServletResponse response);

 // 删除缓存的request
 void removeRequest(HttpServletRequest request, HttpServletResponse response);
}
```

实现类为HttpSessionRequestCache

```
public class HttpSessionRequestCache implements RequestCache {
	static final String SAVED_REQUEST = "SPRING_SECURITY_SAVED_REQUEST";
	protected final Log logger = LogFactory.getLog(this.getClass());

	private PortResolver portResolver = new PortResolverImpl();
	private boolean createSessionAllowed = true;
	private RequestMatcher requestMatcher = AnyRequestMatcher.INSTANCE;
	 
	/**
	 * Stores the current request, provided the configuration properties allow it.
	 */
	public void saveRequest(HttpServletRequest request, HttpServletResponse response) {
		if (requestMatcher.matches(request)) {
			DefaultSavedRequest savedRequest = new DefaultSavedRequest(request,
					portResolver);
	 
			if (createSessionAllowed || request.getSession(false) != null) {
				// Store the HTTP request itself. Used by
				// AbstractAuthenticationProcessingFilter
				// for redirection after successful authentication (SEC-29)
				request.getSession().setAttribute(SAVED_REQUEST, savedRequest);
				logger.debug("DefaultSavedRequest added to Session: " + savedRequest);
			}
		}
		else {
			logger.debug("Request not saved as configured RequestMatcher did not match");
		}
	}
	 
	public SavedRequest getRequest(HttpServletRequest currentRequest,
			HttpServletResponse response) {
		HttpSession session = currentRequest.getSession(false);
	 
		if (session != null) {
			return (SavedRequest) session.getAttribute(SAVED_REQUEST);
		}
	 
		return null;
	}
	 
	public void removeRequest(HttpServletRequest currentRequest,
			HttpServletResponse response) {
		HttpSession session = currentRequest.getSession(false);
	 
		if (session != null) {
			logger.debug("Removing DefaultSavedRequest from session if present");
			session.removeAttribute(SAVED_REQUEST);
		}
	}
	 
	public HttpServletRequest getMatchingRequest(HttpServletRequest request,
			HttpServletResponse response) {
		DefaultSavedRequest saved = (DefaultSavedRequest) getRequest(request, response);
	 
		if (saved == null) {
			return null;
		}
	 
		if (!saved.doesRequestMatch(request, portResolver)) {
			logger.debug("saved request doesn't match");
			return null;
		}
	 
		removeRequest(request, response);
	 
		return new SavedRequestAwareWrapper(saved, request);
	}
	 
	/**
	 * Allows selective use of saved requests for a subset of requests. By default any
	 * request will be cached by the {@code saveRequest} method.
	 * <p>
	 * If set, only matching requests will be cached.
	 *
	 * @param requestMatcher a request matching strategy which defines which requests
	 * should be cached.
	 */
	public void setRequestMatcher(RequestMatcher requestMatcher) {
		this.requestMatcher = requestMatcher;
	}
	 
	/**
	 * If <code>true</code>, indicates that it is permitted to store the target URL and
	 * exception information in a new <code>HttpSession</code> (the default). In
	 * situations where you do not wish to unnecessarily create <code>HttpSession</code>s
	 * - because the user agent will know the failed URL, such as with BASIC or Digest
	 * authentication - you may wish to set this property to <code>false</code>.
	 */
	public void setCreateSessionAllowed(boolean createSessionAllowed) {
		this.createSessionAllowed = createSessionAllowed;
	}
	 
	public void setPortResolver(PortResolver portResolver) {
		this.portResolver = portResolver;
	}

}
```

可以看出原请求信息时实质上是被缓存到session中了，缓存的是HttpSessionRequestCache实例，任意HttpSessionRequestCache实例均可获得缓存的原请求信息，只要请求的session没有变化。

2）ExceptionTranslationFilter

ExceptionTranslationFilter 是Spring Security的核心filter之一，用来处理AuthenticationException和AccessDeniedException两种异常（由FilterSecurityInterceptor认证请求返回的异常）。

在我们的例子中，AuthenticationException指的是未登录状态下访问受保护资源，AccessDeniedException指的是登陆了但是由于权限不足(比如普通用户访问管理员界面）。

ExceptionTranslationFilter 持有两个处理类，分别是AuthenticationEntryPoint和AccessDeniedHandler。

ExceptionTranslationFilter 对异常的处理是通过这两个处理类实现的，处理规则很简单：

```
规则1. 如果异常是 AuthenticationException，使用 AuthenticationEntryPoint 处理
规则2. 如果异常是 AccessDeniedException 且用户是匿名用户，使用 AuthenticationEntryPoint 处理
规则3. 如果异常是 AccessDeniedException 且用户不是匿名用户，如果否则交给 AccessDeniedHandler 处理。
```

对应以下代码

```
private void handleSpringSecurityException(HttpServletRequest request,
 HttpServletResponse response, FilterChain chain, RuntimeException exception)
 throws IOException, ServletException {
 if (exception instanceof AuthenticationException) {
 logger.debug(
"Authentication exception occurred; redirecting to authentication entry point",
 exception);

 sendStartAuthentication(request, response, chain,
 (AuthenticationException) exception);
 }
 else if (exception instanceof AccessDeniedException) {
 if (authenticationTrustResolver.isAnonymous(SecurityContextHolder
 .getContext().getAuthentication())) {
 logger.debug(
 "Access is denied (user is anonymous); redirecting to authentication entry point",
 exception);

 sendStartAuthentication(
 request,
 response,
 chain,
 new InsufficientAuthenticationException(
 "Full authentication is required to access this resource"));
 }
 else {
 logger.debug(
 "Access is denied (user is not anonymous); delegating to AccessDeniedHandler",
 exception);

 accessDeniedHandler.handle(request, response,
 (AccessDeniedException) exception);
 }
 }
 }


//AccessDeniedHandler 默认实现是 AccessDeniedHandlerImpl。该类对异常的处理是返回403错误码。

public void handle(HttpServletRequest request, HttpServletResponse response,
 AccessDeniedException accessDeniedException) throws IOException,
 ServletException {
 if (!response.isCommitted()) {
 if (errorPage != null) { // 定义了errorPage
 // errorPage中可以操作该异常
request.setAttribute(WebAttributes.ACCESS_DENIED_403,
 accessDeniedException);

 // 设置403状态码
response.setStatus(HttpServletResponse.SC_FORBIDDEN);

 // 转发到errorPage
 RequestDispatcher dispatcher = request.getRequestDispatcher(errorPage);
 dispatcher.forward(request, response);
}
 else { // 没有定义errorPage，则返回403状态码(Forbidden)，以及错误信息
response.sendError(HttpServletResponse.SC_FORBIDDEN,
 accessDeniedException.getMessage());
 }
 }
}
```

AuthenticationEntryPoint 如果不配置<http>标签的entry-point-ref属性，则默认实现是 LoginUrlAuthenticationEntryPoint, 如果配置了entry-point-ref则用配置的。

```
protected void sendStartAuthentication(HttpServletRequest request,
			HttpServletResponse response, FilterChain chain,
			AuthenticationException reason) throws ServletException, IOException {
		// SEC-112: Clear the SecurityContextHolder's Authentication, as the
		// existing Authentication is no longer considered valid
		SecurityContextHolder.getContext().setAuthentication(null);
		requestCache.saveRequest(request, response);                   //缓存原请求
		logger.debug("Calling Authentication entry point.");
		authenticationEntryPoint.commence(request, response, reason);
	}
```

LoginUflAuthenticationEntryPoint该类的处理是转发或重定向到登录页面

```
public void commence(HttpServletRequest request, HttpServletResponse response,
 AuthenticationException authException) throws IOException, ServletException {

 String redirectUrl = null;

 if (useForward) {

 if (forceHttps && "http".equals(request.getScheme())) {
 // First redirect the current request to HTTPS.
 // When that request is received, the forward to the login page will be
 // used.
 redirectUrl = buildHttpsRedirectUrlForRequest(request);
 }

 if (redirectUrl == null) {
 String loginForm = determineUrlToUseForThisRequest(request, response,
 authException);

 if (logger.isDebugEnabled()) {
logger.debug("Server side forward to: " + loginForm);
 }

 RequestDispatcher dispatcher = request.getRequestDispatcher(loginForm);

 // 转发
dispatcher.forward(request, response);

 return;
 }
 }
 else {
 // redirect to login page. Use https if forceHttps true

 redirectUrl = buildRedirectUrlToLoginPage(request, response, authException);

 }

 // 重定向
redirectStrategy.sendRedirect(request, response, redirectUrl);
}
```

 

了解完这些，回到我们的例子。

第3步时，用户未登录的情况下访问受保护资源，ExceptionTranslationFilter会捕获到AuthenticationException异常(规则1)。页面需要跳转，ExceptionTranslationFilter在跳转前使用requestCache缓存request。

```
protected void sendStartAuthentication(HttpServletRequest request,
HttpServletResponse response, FilterChain chain,
 AuthenticationException reason) throws ServletException, IOException {
 // SEC-112: Clear the SecurityContextHolder's Authentication, as the
 // existing Authentication is no longer considered valid
 SecurityContextHolder.getContext().setAuthentication(null);
 // 缓存 request
requestCache.saveRequest(request, response);
 logger.debug("Calling Authentication entry point.");
 authenticationEntryPoint.commence(request, response, reason);
}
```


requestCache使用的是HttpSessionRequestCache

```
/**
	 * Stores the current request, provided the configuration properties allow it.
	 */
	public void saveRequest(HttpServletRequest request, HttpServletResponse response) {
		if (requestMatcher.matches(request)) {
			DefaultSavedRequest savedRequest = new DefaultSavedRequest(request,
					portResolver);

			if (createSessionAllowed || request.getSession(false) != null) {
				// Store the HTTP request itself. Used by
				// AbstractAuthenticationProcessingFilter
				// for redirection after successful authentication (SEC-29)
				request.getSession().setAttribute(SAVED_REQUEST, savedRequest);
				logger.debug("DefaultSavedRequest added to Session: " + savedRequest);
			}
		}
		else {
			logger.debug("Request not saved as configured RequestMatcher did not match");
		}
	}

```

总结，在跳转前进行缓存，是缓存到session中。
四、了解了以上原理以及forward和redirect的区别forward和redirect的区别，配置实现如下，基于springsecurity4.1.3版本

配置文件：完整的

```xml
<?xml version="1.0" encoding="UTF-8"?>

<beans:beans xmlns="http://www.springframework.org/schema/security"
xmlns:beans="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.springframework.org/schema/beans
http://www.springframework.org/schema/beans/spring-beans.xsd
http://www.springframework.org/schema/security
http://www.springframework.org/schema/security/spring-security.xsd">

<http auto-config="true" use-expressions="true" entry-point-ref="myLoginUrlAuthenticationEntryPoint">
<form-login 
login-page="/login"
authentication-failure-url="/login?error" 
login-processing-url="/login"
authentication-success-handler-ref="myAuthenticationSuccessHandler" /> 
<!-- 认证成功用自定义类myAuthenticationSuccessHandler处理 -->

<logout logout-url="/logout" 
logout-success-url="/" 
invalidate-session="true"
delete-cookies="JSESSIONID"/>

<csrf disabled="true" />
<intercept-url pattern="/order/*" access="hasRole('ROLE_USER')"/>
</http>

<!-- 使用自定义类myUserDetailsService从数据库获取用户信息 -->
<authentication-manager> 
<authentication-provider user-service-ref="myUserDetailsService"> 
<!-- 加密 -->
<password-encoder hash="md5">
</password-encoder>
</authentication-provider>
</authentication-manager>

<!-- 被认证请求向登录界面跳转采用forward方式 -->
<beans:bean id="myLoginUrlAuthenticationEntryPoint" 
class="org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint">
<beans:constructor-arg name="loginFormUrl" value="/login"></beans:constructor-arg>
<beans:property name="useForward" value="true"/>
</beans:bean>

</beans:beans
```





1）向登录界面跳转：主要配置

```xml
<http auto-config="true" use-expressions="true" entry-point-ref="myLoginUrlAuthenticationEntryPoint">

<!-- 被认证请求向登录界面跳转采用forward方式 -->
<beans:bean id="myLoginUrlAuthenticationEntryPoint" 
class="org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint">
<beans:constructor-arg name="loginFormUrl" value="/login"></beans:constructor-arg>
<beans:property name="useForward" value="true"/>
</beans:bean
```

从上面的分析可知，默认情况下采用的是redirect方式，这里通过配置从而实现了forward方式，这里还是直接利用的security自带的类LoginUrlAuthenticationEntryPoint（当然也可以用户自定义了类，下一篇说明如何根据自定义了类实现向不同登录页面的跳转），只不过进行了以上配置：

```
/**

* Performs the redirect (or forward) to the login form URL.
  */
  public void commence(HttpServletRequest request, HttpServletResponse response,
  AuthenticationException authException) throws IOException, ServletException {

String redirectUrl = null;

if (useForward) {

if (forceHttps && "http".equals(request.getScheme())) {
// First redirect the current request to HTTPS.
// When that request is received, the forward to the login page will be
// used.
redirectUrl = buildHttpsRedirectUrlForRequest(request);
}

if (redirectUrl == null) {
String loginForm = determineUrlToUseForThisRequest(request, response,
authException);

if (logger.isDebugEnabled()) {
logger.debug("Server side forward to: " + loginForm);
}

RequestDispatcher dispatcher = request.getRequestDispatcher(loginForm);

dispatcher.forward(request, response);

return;
}
}
else {
// redirect to login page. Use https if forceHttps true

redirectUrl = buildRedirectUrlToLoginPage(request, response, authException);

}

redirectStrategy.sendRedirect(request, response, redirectUrl);
}
```


2）登录信息提交后认证流程

跳转到登录界面，提交登录信息后，经过过滤器UsernamePasswordAuthenticationFilter，该过滤器继承了AbstractAuthenticationProcessingFilter，

public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest request = (HttpServletRequest) req;
		HttpServletResponse response = (HttpServletResponse) res;
	 
		if (!requiresAuthentication(request, response)) {
			chain.doFilter(request, response);
	 
			return;
		}
	 
		if (logger.isDebugEnabled()) {
			logger.debug("Request is to process authentication");
		}
	 
		Authentication authResult;
	 
		try {
			authResult = attemptAuthentication(request, response);  //获取认证结果，其中包括从数据源中获取用户数据与登录时填写的信息比较，包括是否有该用户，密码是否正确，否则抛异常
			if (authResult == null) {
				// return immediately as subclass has indicated that it hasn't completed
				// authentication
				return;
			}
			sessionStrategy.onAuthentication(authResult, request, response);
		}
		catch (InternalAuthenticationServiceException failed) {
			logger.error(
					"An internal error occurred while trying to authenticate the user.",
					failed);
			unsuccessfulAuthentication(request, response, failed);
	 
			return;
		}
		catch (AuthenticationException failed) {
			// Authentication failed
			unsuccessfulAuthentication(request, response, failed);
	 
			return;
		}
	 
		// Authentication success
		if (continueChainBeforeSuccessfulAuthentication) {
			chain.doFilter(request, response);
		}
	 
		successfulAuthentication(request, response, chain, authResult);   //认证成功后调用
	}
在以上程序中包含了从数据源中获取用户信息并和用户填写的信息进行对比的过程，功能实现attemptAuthentication，这里不对其进行详细分析。
判断是否认证成功，认证成功后执行如下代码：

```
protected void successfulAuthentication(HttpServletRequest request,
			HttpServletResponse response, FilterChain chain, Authentication authResult)
			throws IOException, ServletException {

		if (logger.isDebugEnabled()) {
			logger.debug("Authentication success. Updating SecurityContextHolder to contain: "
					+ authResult);
		}
	 
		SecurityContextHolder.getContext().setAuthentication(authResult);
	 
		rememberMeServices.loginSuccess(request, response, authResult);
	 
		// Fire event
		if (this.eventPublisher != null) {
			eventPublisher.publishEvent(new InteractiveAuthenticationSuccessEvent(
					authResult, this.getClass()));
		}
	 
		successHandler.onAuthenticationSuccess(request, response, authResult);
	}

```

其中successHandler就是配置的MyAuthenticationSuccessHandler。
登录成功后的类配置，存入登录user信息后交给认证成功后的处理类MyAuthenticationSuccessHandler，该类继承了SavedRequestAwareAuthenticationSuccessHandler，他会从缓存中提取请求，从而可以恢复之前请求的数据。初次之外还可以通过配置自定义类实现认证成功后根据权限跳转到不同的页面，例如用户中心和后台管理中心，下一篇会详细说明。

```java
/**

* 登录后操作
* 
* @author HHL
* @date
* */
  @Component
  public class MyAuthenticationSuccessHandler extends
  SavedRequestAwareAuthenticationSuccessHandler {

@Autowired
private IUserService userService;

@Override
public void onAuthenticationSuccess(HttpServletRequest request,
HttpServletResponse response, Authentication authentication)
throws IOException, ServletException {

// 认证成功后，获取用户信息并添加到session中
UserDetails userDetails = (UserDetails) authentication.getPrincipal();
MangoUser user = userService.getUserByName(userDetails.getUsername());
request.getSession().setAttribute("user", user);

super.onAuthenticationSuccess(request, response, authentication);

}


}


//SavedRequestAwareAuthenticationSuccessHandler中的onAuthenticationSuccess方法;

@Override
public void onAuthenticationSuccess(HttpServletRequest request,
HttpServletResponse response, Authentication authentication)
throws ServletException, IOException {
SavedRequest savedRequest = requestCache.getRequest(request, response);

if (savedRequest == null) {
super.onAuthenticationSuccess(request, response, authentication);

return;
}
String targetUrlParameter = getTargetUrlParameter();
if (isAlwaysUseDefaultTargetUrl()
|| (targetUrlParameter != null && StringUtils.hasText(request
.getParameter(targetUrlParameter)))) {
requestCache.removeRequest(request, response);
super.onAuthenticationSuccess(request, response, authentication);

return;
}

clearAuthenticationAttributes(request);

// Use the DefaultSavedRequest URL
String targetUrl = savedRequest.getRedirectUrl();
logger.debug("Redirecting to DefaultSavedRequest Url: " + targetUrl);
getRedirectStrategy().sendRedirect(request, response, targetUrl);
}
```


4.1.3中如果配置了 authentication-success-handler-ref，则首先使用该配置的，如果配置了authentication-success-forward-url，则使用该配置的，如果都没有配置则采用的SavedRequestAwareAuthenticationSuccessHandler进行处理，详情可参见： Spring实战篇系列----源码解析Spring Security中的过滤器Filter初始化


上述实现了跳转到登录界面采用forward方式，就是浏览器地址栏没有变化，当然也可采用redirect方式，地址栏变为登录界面地址栏，当登录完成后恢复到原先的请求页面，请求信息会从requestCache中还原回来。可参考 Spring实战篇系列----spring security4.1.3配置以及踩过的坑



**总结：**
1）被认证请求被FilterSecurityInterceptor拦截看有没有对应权限，如果没有抛异常给ExceptionTranslationFilter
2）ExceptionTranslationFilter缓存原请求，利用LoginUrlAuthenticationEntryPoint入口跳转到登录界面
3）用户在登录界面填写登录信息后，提交，经过UsernamePasswordAuthenticationFilter对填写的信息和从数据源中获取的信息进行对比，成功则授权权限，并通过登录成功后入口SavedRequestAwareAuthenticationSuccessHandler跳转回原请求页面（跳转时有从缓存中对请求信息的恢复）
4）登录完成后返回原请求，由FilterSecurityInterceptor进行权限的验证（大部分工作有AbstractSecurityInterceptor来做），根据登录成功后生成的Authentication（Authentication authentication = SecurityContextHolder.getContext().getAuthentication();由SecurityContextHolder持有，而其中的SecurityContext由 SecurityContextPersistentFilter保存到session中从而实现request共享 ）中的权限和请求所需的权限对比，如果一致则成功执行，如果权限不正确则返回403错误码﻿﻿
5）以上均是默认情况下，没有经过配置的执行过程，当然可以自定义LoginUrlAuthenticationEntryPoint和SavedRequestAwareAuthenticationSuccessHandler实现根据不同的请求所需权限跳转到不同登录页面及授权成功后根据权限跳转到不同页面，以及返回403错误码时跳转到对应的页面（AccessDeniedHandlerImpl）在下一篇中会对其进行实现﻿﻿