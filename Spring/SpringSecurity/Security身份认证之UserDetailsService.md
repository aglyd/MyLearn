# [Security身份认证之UserDetailsService][https://blog.csdn.net/shehun1/article/details/45394405]

分类专栏： [javaEE](https://blog.csdn.net/qq_39329616/category_8710152.html) 文章标签： [springSecurity](https://www.csdn.net/tags/MtTaEg0sMDg2NDMtYmxvZwO0O0OO0O0O.html)

之前我们采用了配置文件的方式从数据库中读取用户进行登录。虽然该方式的灵活性相较于静态账号密码的方式灵活了许多，但是将数据库的结构暴露在明显的位置上，绝对不是一个明智的做法。本文通过Java代码实现UserDetailsService接口来实现身份认证。

##### 1.1 UserDetailsService在身份认证中的作用

Spring Security中进行身份验证的是AuthenticationManager接口，ProviderManager是它的一个默认实现，但它并不用来处理身份认证，而是委托给配置好的AuthenticationProvider，每个AuthenticationProvider会轮流检查身份认证。检查后或者返回Authentication对象或者抛出异常。

验证身份就是加载响应的UserDetails，看看是否和用户输入的账号、密码、权限等信息匹配。此步骤由实现AuthenticationProvider的DaoAuthenticationProvider（它利用UserDetailsService验证用户名、密码和授权）处理。包含 GrantedAuthority 的 UserDetails对象在构建 Authentication对象时填入数据。
![img](https://fuzui.oss-cn-shenzhen.aliyuncs.com/img/20180406152002371.png)

##### 1.2 配置UserDetailsService

###### 1.2.1 更改Spring-Security.xml中身份的方式，使用自定义的UserDetailsService。

==或者使用config类的方式在WebSecurityConfigurerAdapter的configure(AuthenticationManagerBuilder auth)中配置==

```xml
<security:authentication-manager> 
	<security:authentication-provider user-service ref="favUserDetailService">     
	</security:authentication-provider>
</security:authentication-manager>
<bean id="favUserDetailService" class="com.favccxx.favsecurity.security.FavUserDetailService" />
```

###### 1.2.2 新建FavUserDetailsService.java，实现UserDetailsService接口。为了降低学习的难度，这里并没有与数据库进行集成，而是采用模拟从数据库中获取用户的方式进行身份验证。示例代码如下：

```java
package com.favccxx.favsecurity.security;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
 
public class FavUserDetailService implements UserDetailsService {
	private static final Logger logger = LogManager.getLogger(FavUserDetailService.class);  
	/**  * 根据用户名获取用户 - 用户的角色、权限等信息   */
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {      
		UserDetails userDetails = null;     
		try {           
			com.favccxx.favsecurity.pojo.User favUser = new com.favccxx.favsecurity.pojo.User();            
			favUser.setUsername("favccxx");        
			favUser.setPassword("favccxx");         
			Collection<GrantedAuthority> authList = getAuthorities();         
			userDetails = new User(username, favUser.getPassword().toLowerCase(),true,true,true,true,authList);     
		}catch (Exception e) {         
			e.printStackTrace();        
		}       
		return userDetails; 
	}
	/**  * 获取用户的角色权限,为了降低实验的难度，这里去掉了根据用户名获取角色的步骤     * @param    * @return   */ 
	private Collection<GrantedAuthority> getAuthorities(){        
		List<GrantedAuthority> authList = new ArrayList<GrantedAuthority>();       
		authList.add(new SimpleGrantedAuthority("ROLE_USER"));      
		authList.add(new SimpleGrantedAuthority("ROLE_ADMIN"));     
		return authList;    
	}
}
```

###### 1.2.3 启动应用服务器，只要用户名和密码不全是favccxx，就会产生下面的错误。

![img](https://fuzui.oss-cn-shenzhen.aliyuncs.com/img/20180406152945823.png)

用户名和密码都输入favccxx，则登陆成功

![img](https://fuzui.oss-cn-shenzhen.aliyuncs.com/img/20180406153002554.png)

##### 1.3 跟踪UserDetailsService。

身份认证的调用流程图如下，用户可下载Spring Security源代码跟踪调试。
![img](https://fuzui.oss-cn-shenzhen.aliyuncs.com/img/20180406153020212.png)


本文转自:[Spring Security身份认证之UserDetailsService](https://blog.csdn.net/shehun1/article/details/45394405)

----



# [springsecurity中anonymous_Spring Security一个简单demo][https://blog.csdn.net/weixin_39930557/article/details/111391878]

 Spring Security 是一个功能强大且高度可定制的身份验证和访问控制框架。它是用于保护基于 Spring 的应用程序。

 Spring Security 是一个框架，侧重于为 Java 应用程序提供身份验证和授权。与所有 Spring 项目一样，Spring 安全性的真正强大之处，在于它很容易扩展以满足定制需求。

 一个简单的spring security例子

```yaml
spring:

# Spring Security 配置项，对应 SecurityProperties 配置类

  security:

# 配置默认的 InMemoryUserDetailsManager 的用户账号与密码。

    user:
      name: user # 账号
      password: user # 密码
      roles: ADMIN # 拥有角色
      
      
# 在 spring.security 配置项，设置 Spring Security 的配置，对应 SecurityProperties 配置类。
  #默认情况下，Spring Boot UserDetailsServiceAutoConfiguration 自动化配置类，
  #会创建一个内存级别的 InMemoryUserDetailsManager Bean 对象，提供认证的用户信息。
  #这里，我们添加了 spring.security.user 配置项，UserDetailsServiceAutoConfiguration 会基于配置的信息创建一个用户 User 在内存中。
  #如果，我们未添加 spring.security.user 配置项，UserDetailsServiceAutoConfiguration 会自动创建一个用户名为 "user" ，
  #密码为 UUID 随机的用户 User 在内存中
```


config类

 * ```java
 /**
    
     * @Author peppers
    
     * 继承 WebSecurityConfigurerAdapter 抽象类，实现 Spring Security 在 Web 场景下的自定义配置
       *
        *
    
     * 我们可以重写WebSecurityConfigurerAdapter的方法，实现自定义的spring security的配置
       **/
       @Configuration
       @EnableGlobalMethodSecurity(prePostEnabled = true)  //开启对 Spring Security 注解的方法，进行权限验证
       public class SecurityConfig extends WebSecurityConfigurerAdapter {
    
       /**重写 #configure(AuthenticationManagerBuilder auth) 方法，实现 AuthenticationManager 认证管理器。*/
       @Override
       protected void configure(AuthenticationManagerBuilder auth) throws Exception{
           auth
                   //使用内存中的InmemortUserDetailsManager
                   //Spring 内置了两种 UserDetailsManager 实现：
                   //1.InMemoryUserDetailsManager
                   //2.JdbcUserDetailsManager ，基于 JDBC的 JdbcUserDetailsManager 。
                   //实际项目中，我们更多采用//AuthenticationManagerBuilder.userDetailsService(userDetailsService) 方法，
                   // 使用自定义实现的 UserDetailsService 实现类，更加灵活且自由的实现认证的用户信息的读取。(若依项目//中SecurityConfig的此配置即为该方式)
           .inMemoryAuthentication()
                   //不使用PasswordEncoder密码编码器
           .passwordEncoder(NoOpPasswordEncoder.getInstance())
                   //配置admin用户
           .withUser("admin").password("admin").roles("NORMAL")
                   //篇日志normal用户
           .and().withUser("normal").password("normal").roles("NORMAL");
       }
    ```
    
    


```java
/**重写 #configure(HttpSecurity http) 方法，主要配置 URL 的权限控制*/
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
            //配置请求地址的全限,开始配置 URL 的权限控制
            /**#(String... antPatterns) 方法，配置匹配的 URL 地址，基于 Ant 风格路径表达式 ，可传入多个。
             【常用】#permitAll() 方法，所有用户可访问。
             【常用】#denyAll() 方法，所有用户不可访问。
             【常用】#authenticated() 方法，登录用户可访问。
             #anonymous() 方法，无需登录，即匿名用户可访问。
             #rememberMe() 方法，通过 remember me 登录的用户可访问。
             #fullyAuthenticated() 方法，非 remember me 登录的用户可访问。
             #hasIpAddress(String ipaddressExpression) 方法，来自指定 IP 表达式的用户可访问。
             【常用】#hasRole(String role) 方法， 拥有指定角色的用户可访问。
             【常用】#hasAnyRole(String... roles) 方法，拥有指定任一角色的用户可访问。
             【常用】#hasAuthority(String authority) 方法，拥有指定权限(authority)的用户可访问。
             【常用】#hasAuthority(String... authorities) 方法，拥有指定任一权限(authority)的用户可访问。
             【最牛】#access(String attribute) 方法，当 Spring EL 表达式的执行结果为 true 时，可以访问。*/
    .authorizeRequests()
            //所有用户可访问
            .antMatchers("/test/echo").permitAll()
            //需要admin角色
            .antMatchers("/test/admin").hasRole("ADMIN")
            //需要normal角色
            .antMatchers("test/normal").access("hasRole('ROLE_NORMAL')")
           /**配置了 .anyRequest().authenticated() ，任何请求，访问的用户都需要经过认证。*/
            // .anyRequest().authenticated()
            .and()
            //设置Form表单登录
            .formLogin()
            //登录URL地址
                    .loginPage("/login")
                .permitAll() //所有用户可访问
            .and()
            //配置退出相关
            .logout()
            //退出URL地址
            .logoutUrl("/logout")
    .permitAll(); //所有用户可访问
}
}
```

测试类

```java
@RestController
@RequestMapping("/demo")
public class DemoController {

    /**@PermitAll 注解，等价于 #permitAll() 方法，所有用户可访问。
    SecurityConfig」中，配置了 .anyRequest().authenticated() ，任何请求，访问的用户都需要经过认证。所以这里 @PermitAll 注解实际是不生效的。
    也就是说，Java Config 配置的权限，和注解配置的权限，两者是叠加的。*/
    @PermitAll
    @GetMapping("/echo")
    public String demo() {
        return "示例返回";
    }
     
    @GetMapping("/home")
    public String home() {
        return "我是首页";
    }
     
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    @GetMapping("/admin")
    public String admin() {
        return "我是管理员";
    }
     
    @PreAuthorize("hasRole('ROLE_NORMAL')")
    @GetMapping("/normal")
    public String normal() {
        return "我是普通用户";
    }
    }
```


------------------------------------------------




# [Spring Security（十四）：5.4 Authorize Requests][https://www.bbsmax.com/A/n2d9a8GgdD/]

我们的示例仅要求用户进行身份验证，并且已针对应用程序中的每个URL进行了身份验证。我们可以通过向http.authorizeRequests（）方法添加多个子项来指定URL的自定义要求。例如：

 

```java
protected void configure(HttpSecurity http) throws Exception {
	http
		.authorizeRequests()                                                                
			.antMatchers("/resources/**", "/signup", "/about").permitAll()                  
			.antMatchers("/admin/**").hasRole("ADMIN")                                      
			.antMatchers("/db/**").access("hasRole('ADMIN') and hasRole('DBA')")            
			.anyRequest().authenticated()                                                   
			.and()
		// ...
		.formLogin();
}
```

1、There are multiple children to the http.authorizeRequests() method each matcher is considered in the order they were declared.

http.authorizeRequests（）方法有多个子节点，每个匹配器按其声明的顺序进行考虑。

2、We specified multiple URL patterns that any user can access. Specifically, any user can access a request if the URL starts with "/resources/", equals "/signup", or equals "/about".

我们指定了任何用户都可以访问的多种URL模式。具体来说，如果URL以“/ resources /”开头，等于“/ signup”或等于“/ about”，则任何用户都可以访问请求。

3、Any URL that starts with "/admin/" will be restricted to users who have the role "ROLE_ADMIN". You will notice that since we are invoking the hasRole method we do not need to specify the "ROLE_" prefix.

任何以“/ admin /”开头的URL都将仅限于具有“ROLE_ADMIN”角色的用户。您会注意到，由于我们正在调用hasRole方法，因此我们不需要指定“ROLE_”前缀。

4、Any URL that starts with "/db/" requires the user to have both "ROLE_ADMIN" and "ROLE_DBA". You will notice that since we are using the hasRole expression we do not need to specify the "ROLE_" prefix.

任何以“/ db /”开头的URL都要求用户同时拥有“ROLE_ADMIN”和“ROLE_DBA”。您会注意到，由于我们使用的是hasRole表达式，因此我们不需要指定“ROLE_”前缀。

5、Any URL that has not already been matched on only requires that the user be authenticated

任何尚未匹配的URL只需要对用户进行身份验证



## 5.5 Handling Logouts 处理注销

When using the `WebSecurityConfigurerAdapter`, logout capabilities are automatically applied. The default is that accessing the URL `/logout` will log the user out by:

使用WebSecurityConfigurerAdapter时，会自动应用注销功能。默认情况下，访问URL / logout将通过以下方式记录用户：

- Invalidating the HTTP Session
- 使HTTP会话无效
- Cleaning up any RememberMe authentication that was configured
- 清理已配置的任何RememberMe身份验证
- Clearing the `SecurityContextHolder`
- 清除SecurityContextHolder
- Redirect to `/login?logout`
- 重定向到/ login？logout

Similar to configuring login capabilities, however, you also have various options to further customize your logout requirements:

但是，与配置登录功能类似，您还可以使用各种选项来进一步自定义注销要求：

```java
protected void configure(HttpSecurity http) throws Exception {
	http
		.logout()                                                                
			.logoutUrl("/my/logout")                                                 
			.logoutSuccessUrl("/my/index")                                           
			.logoutSuccessHandler(logoutSuccessHandler)                              
			.invalidateHttpSession(true)                                             
			.addLogoutHandler(logoutHandler)                                         
			.deleteCookies(cookieNamesToClear)                                       
			.and()
		...
}
```

1、Provides logout support. This is automatically applied when using WebSecurityConfigurerAdapter.

提供注销支持。使用WebSecurityConfigurerAdapter时会自动应用此选项。

2、The URL that triggers log out to occur (default is /logout). If CSRF protection is enabled (default), then the request must also be a POST. For more information, please consult the JavaDoc.

触发注销的URL（默认为/ logout）。如果启用了CSRF保护（默认），则该请求也必须是POST。有关更多信息，请参阅JavaDoc。

3、The URL to redirect to after logout has occurred. The default is /login?logout. For more information, please consult the JavaDoc.

注销后重定向到的URL。默认为/ login？logout。有关更多信息，请参阅JavaDoc。

4、Let’s you specify a custom LogoutSuccessHandler. If this is specified, logoutSuccessUrl() is ignored. For more information, please consult the JavaDoc.

我们指定一个自定义的LogoutSuccessHandler。如果指定了此参数，则忽略logoutSuccessUrl（）。有关更多信息，请参阅JavaDoc。

5、Specify whether to invalidate the HttpSession at the time of logout. This is true by default. Configures the SecurityContextLogoutHandler under the covers. For more information, please consult the JavaDoc.

指定在注销时是否使HttpSession无效。默认情况下这是真的。配置封面下的SecurityContextLogoutHandler。有关更多信息，请参阅JavaDoc。

6、Adds a LogoutHandler. SecurityContextLogoutHandler is added as the last LogoutHandler by default.

添加LogoutHandler。默认情况下，SecurityContextLogoutHandler被添加为最后一个LogoutHandler。

7、Allows specifying the names of cookies to be removed on logout success. This is a shortcut for adding a CookieClearingLogoutHandler explicitly.

允许指定在注销成功时删除的cookie的名称。这是显式添加CookieClearingLogoutHandler的快捷方式。

 

Logouts can of course also be configured using the XML Namespace notation. Please see the documentation for the [logout element](https://docs.spring.io/spring-security/site/docs/4.2.10.RELEASE/reference/htmlsingle/#nsa-logout) in the Spring Security XML Namespace section for further details.

当然也可以使用XML命名空间表示法配置注销。有关更多详细信息，请参阅Spring Security XML Namespace部分中logout元素的文档。

 

Generally, in order to customize logout functionality, you can add `LogoutHandler` and/or `LogoutSuccessHandler` implementations. For many common scenarios, these handlers are applied under the covers when using the fluent API.

通常，为了自定义注销功能，您可以添加LogoutHandler和/或LogoutSuccessHandler实现。对于许多常见场景，这些处理程序在使用流畅的API时应用于幕后。

### 5.5.1 LogoutHandler （登出处理）

Generally, `LogoutHandler` implementations indicate classes that are able to participate in logout handling. They are expected to be invoked to perform necessary clean-up. As such they should not throw exceptions. Various implementations are provided:

通常，LogoutHandler实现指示能够参与注销处理的类。预计将调用它们以进行必要的清理。因此，他们不应该抛出异常。提供了各种实现：

 

- [PersistentTokenBasedRememberMeServices](https://docs.spring.io/spring-security/site/docs/current/apidocs/org/springframework/security/web/authentication/rememberme/PersistentTokenBasedRememberMeServices.html)
- [TokenBasedRememberMeServices](https://docs.spring.io/spring-security/site/docs/current/apidocs/org/springframework/security/web/authentication/rememberme/TokenBasedRememberMeServices.html)
- [CookieClearingLogoutHandler](https://docs.spring.io/spring-security/site/docs/current/apidocs/org/springframework/security/web/authentication/logout/CookieClearingLogoutHandler.html)
- [CsrfLogoutHandler](https://docs.spring.io/spring-security/site/docs/current/apidocs/org/springframework/security/web/csrf/CsrfLogoutHandler.html)
- [SecurityContextLogoutHandler](https://docs.spring.io/spring-security/site/docs/current/apidocs/org/springframework/security/web/authentication/logout/SecurityContextLogoutHandler.html)

----



# loginProcessingUrl()方法的含义

loginProcessingUrl(）这个方法可以看作一个中转站，前台界面提交表单之后跳转到这个路径进行User DetailsService的验证，如果成功， defaultSuccessUrl（）如果失败,那么转向failureUrl("/error.html")，我们需要注意的就是

```xml
<form action="/user/login" method="post">		//这里的action现需要和loginProcessingUrl(）中的参数保持一致
   同户名 <input name="username" type="text">
    密码<input name="password" type="text">
    提交<input type="submit">
</form>
```


http.formLogin()//自定义页面
.loginPage("/login.html") //登陆界面
.loginProcessingUrl("/user/login")//登陆访问路径：提交表单之后跳转的地址,可以看作一个中转站，这个步骤就是验证user的一个过程
.defaultSuccessUrl("/test/index",true).permitAll() //登陆成功之后跳转的路径
.and().authorizeRequests()
.antMatchers("/","/test/hello","/user/login").permitAll() //匹配的路径不需要认证
.antMatchers("/test/index").hasAuthority(“admin”)
.anyRequest().authenticated()
.and().csrf().disable();