# [Spring Security中 SecurityContextHolder.getContext().getAuthentication().getPrincipal()](https://www.cnblogs.com/yangzhixue/p/12435316.html)

**获取当前用户**

Spring Security使用一个Authentication对象来描述当前用户的相关信息。SecurityContextHolder中持有的是当前用户的SecurityContext，而SecurityContext持有的是代表当前用户相关信息的Authentication的引用。这个Authentication对象不需要我们自己去创建，在与系统交互的过程中，Spring Security会自动为我们创建相应的Authentication对象，然后赋值给当前的SecurityContext。但是往往我们需要在程序中获取当前用户的相关信息，比如最常见的是获取当前登录用户的用户名。在程序的任何地方，通过如下方式我们可以获取到当前用户的用户。

```
  public User getCurrentUser(){
        User user=(User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return user;
    }
```

 

通过Authentication.getPrincipal()可以获取到代表当前用户的信息，这个对象通常是UserDetails的实例。获取当前用户的用户名是一种比较常见的需求。

此外，调用SecurityContextHolder.getContext()获取SecurityContext时，如果对应的SecurityContext不存在，则Spring Security将为我们建立一个空的SecurityContext并进行返回。



----



# [spring security无法获取SecurityContextHolder.getContext().getAuthentication()][https://bbs.csdn.net/topics/392321589]

我这边配置了security，验证成功后，不知道为什么没有把userdetails保存到SecurityContext中。
但是
request.getSession().getAttribute("SPRING_SECURITY_CONTEXT");能获取到userDetails.
这个是为什么？
网络上有说，我是因为配置了 security="none"所以不会放到SecurityContext中，但是实际上我只对登录的放行，其他的都需要过滤。具体我还是贴一下关键代码。
XML配置



```html


<sec:http pattern="/login/login.do" security="none" />

	<sec:http pattern="error.jsp" security="none" />
	<sec:http pattern="index.jsp" security="none" />
	<sec:http pattern="/syscode/type.do" security="none" />
	<sec:http pattern="/login/loginpage.do" security="none" />

	

	<sec:http use-expressions="true" auto-config="true" access-denied-page="/views/accessDenied.jsp">

		<sec:form-login login-page="/login/loginpage.do"

			authentication-failure-url="/index.jsp"

			default-target-url="/login/main.do"/>

		<sec:logout invalidate-session="true" logout-success-url="/index.jsp" />

		<!--<检测失效的sessionId,超时时定位到另外一个URL 

		<sec:session-management invalid-session-url="/views/sessionTimeout.jsp" />-->
		<sec:custom-filter ref="worktimesLoginProcessingFilter" before="FORM_LOGIN_FILTER" />
		<sec:custom-filter ref="worktimesSessionFilter" before="CONCURRENT_SESSION_FILTER" />

	</sec:http>

	<bean class="org.springframework.security.authentication.event.LoggerListener" />

	<bean id="worktimesLoginProcessingFilter" class="com.worktimes.core.security.WorktimesLoginProcessingFilter">

		<property name="authenticationManager" ref="authenticationManager" />

		<property name="authenticationFailureHandler" ref="simpleUrlAuthenticationFailureHandler" />

		<property name="sessionAuthenticationStrategy" ref="sas" />

		<property name="authenticationSuccessHandler" ref="authenticationSuccessHandler" />

	</bean>

```


XML的配置很简单，
关键是配置了一个worktimesLoginProcessingFilter的过滤器，实现AbstractUserDetailsAuthenticationProvider接口。
在WorktimesAuthenticationProvider中，装配WorktimesUsernamePasswordAuthenticationToken后，保存到AuthenticationManager中，具体代码如下：

```java


@Override

	public Authentication attemptAuthentication(HttpServletRequest request,

			HttpServletResponse response) throws AuthenticationException,

			IOException, ServletException {

		String loginType = request.getParameter("loginType");
		String username = request.getParameter("account");
	    String password = request.getParameter("password");

		if(loginType == null){
			throw new CaptchaException("loginType is null!");
		}

		if("0".equals(loginType)){
			loginType = Constants.NormalUser;
		}else{
			loginType = Constants.SystemUser;
		}

		WorktimesUsernamePasswordAuthenticationToken authRequest = null;
		this.logger.info("Captcha enabled!");

		//验证码

		String captchaValue = (String)request.getSession().getAttribute("Rand");

		String captchaReq = request.getParameter("captcha");

		if (!captchaReq.equals(captchaValue)) {
			throw new CaptchaException("Bad captcha!");
		}

		request.getSession().removeAttribute("Rand");
	    request.getSession().setAttribute("username", username);

            //装配UsernamePasswordAuthenticationToken

	    authRequest = new WorktimesUsernamePasswordAuthenticationToken(username, password, loginType);
	    authRequest.setLoginType(loginType);
	    authRequest.setUserIP(CommonFunction.getIpAddr(request));

            //保存到AuthenticationManager中

	    return getAuthenticationManager().authenticate(authRequest);

	}

```


我看文档，到这里就会把WorktimesUsernamePasswordAuthenticationToken放进SecurityContext中。不知道对不对...
在这步执行完后，spring security会进行用户名密码验证，实现AbstractUserDetailsAuthenticationProvider接口

```java


@Override

	protected void additionalAuthenticationChecks(UserDetails userDetails,

			UsernamePasswordAuthenticationToken authentication) throws AuthenticationException {

		WorktimesUsernamePasswordAuthenticationToken worktimesAuthentication = (WorktimesUsernamePasswordAuthenticationToken) authentication;

		String presentedPassword = worktimesAuthentication.getCredentials().toString();

		if(!presentedPassword.equals(userDetails.getPassword())){
			this.logger.debug("Authentication failed: password does not match stored value");
	        throw new BadCredentialsException("Bad credentials");
		}
	}

	@Override

	protected UserDetails retrieveUser(String username,

			UsernamePasswordAuthenticationToken authentication)

			throws AuthenticationException {

		WorktimesUsernamePasswordAuthenticationToken worktimesAuthentication = (WorktimesUsernamePasswordAuthenticationToken) authentication;

		userDetailsService.loginType=worktimesAuthentication.getLoginType();

		WorktimesUserInfo userInfo = (WorktimesUserInfo)userDetailsService.loadUserByUsername(worktimesAuthentication.getName());

		if(userInfo.getStatus().equals("1")){
			throw new AccountExpiredException("用户已注销！");
		}

		return userInfo;
	}
```


先执行retrieveUser获取User对象，通过userDetailsService到数据库查询我这边的帐户，这步代码就不贴了，无非是查数据库数据，填充WorktimesUserInfo。对了，WorktimesUserInfo是要继承User。然后账号没问题，springsecurity会执行additionalAuthenticationChecks检查用户密码是否正确。我到这边密码也是正常的。
关键代码就是这些，最后执行成功后，页面跳转根据XML文件中配置的authenticationSuccessHandler跳转到/login/main.do，这个也是正常。接下来获取用户就有问题了，

```java
public static WorktimesUserInfo getLoginUser(){

		Object userInfo = null;
		SecurityContext securityContext = SecurityContextHolder.getContext();

		System.out.println("认证成功后获取securityContext:"+securityContext);
		System.out.println("认证成功后获取getAuthentication:"+securityContext.getAuthentication());

		if(securityContext != null && securityContext.getAuthentication() !=null ){

			userInfo = securityContext.getAuthentication().getPrincipal();

			if(userInfo instanceof WorktimesUserInfo){
				return (WorktimesUserInfo) userInfo;
			}
		} 
		return null;
	}
```

定义一个方法获取用户信息，但是securityContext正常，能打印出来值，但是
securityContext.getAuthentication()是null。这个就郁闷了，不知道什么情况，查了很多资料都没办法解决........



----

# [SecurityContextHolder.getContext().getAuthentication()为null的情况][https://blog.csdn.net/weixin_30876945/article/details/97086889]

原理：

UserDetails userDetails = (UserDetails) SecurityContextHolder.getContext().getAuthentication() .getPrincipal();

如果想用上面的代码获得当前用户，必须在spring security过滤器执行中执行，否则在过滤链执行完时org.springframework.security.web.context.SecurityContextPersistenceFilter类会

调用SecurityContextHolder.clearContext();而把SecurityContextHolder清空，所以会得到null。   经过spring security认证后，

 security会把一个SecurityContextImpl对象存储到session中，此对象中有当前用户的各种资料。

网上的情况：

1.关键就是要把filters="none" 变化为相应的权限如access="permitAll"（必须设置<http auto-config="true" use-expressions="true">，否则会提示permitAll找不到），或者access = "IS_AUTHENTICATED_ANONYMOUSLY, IS_AUTHENTICATED_FULLY, IS_AUTHENTICATED_REMEMBERED"，当然security 3.1是要修改<http pattern="/login" security="none"/>这类的

原文：https://blog.csdn.net/softwarehe/article/details/7710707/


2.SecurityContextImpl securityContextImpl = (SecurityContextImpl) request.getSession().getAttribute("SPRING_SECURITY_CONTEXT");

 

3.删除 <intercept-url pattern="/aaa/bbb*" filters="none"/> 类似配置

我的情况：

我给静态资源js配置了<security:http pattern="/js/**" security="none"/>

又给action加了@Namespace("/js/xjgzjs") 注解

所以在访问这个action时，没有经过spring security过滤器，SecurityContextHolder清空，所以会得到null。

把@Namespace("/js/xjgzjs")改为@Namespace("/ry/xjgzjs")即可。

 