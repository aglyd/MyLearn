# [SpringBoot解决跨域问题][https://blog.csdn.net/xhaimail/article/details/107909759]




前后端分离是目前的趋势， 解决跨域问题也是老生常谈的话题了，我们了解一下什么是域和跨域。

域：协议 + 域名 + 端口；三者完全相同则为同域，反之有其一不同均为不同域。

跨域请求：当前【发起请求】的域和【请求指向】的域属于不同域时，该次请求称之为跨域请求。

 

## 跨域问题：
同一域名下允许通信
同一域名下不同文件夹允许通信
同一域名不同端口不允许通信
同一域名不同协议不允许通信
域名和域名对应IP不允许通信
主域名相同，子域名不同不允许通信
同一域名，不同二级域名不允许通信
不同域名不允许通信

## 跨域请求

### 1、全局配置

可以通过实现WebMvcConfigurer接口然后重写addCorsMappings方法解决跨域问题。

```
// 请求跨域
@Configuration
public class CorsConfig implements WebMvcConfigurer {
       

    static final String ORIGINS[] = new String[] { "GET", "POST", "PUT", "DELETE" };
     
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // 所有的当前站点的请求地址，都支持跨域访问。
                .allowedOrigins("*") // 所有的外部域都可跨域访问。 如果是localhost则很难配置，因为在跨域请求的时候，外部域的解析可能是localhost、127.0.0.1、主机名
                .allowCredentials(true) // 是否支持跨域用户凭证
                .allowedMethods(ORIGINS) // 当前站点支持的跨域请求类型是什么
                .maxAge(3600); // 超时时长设置为1小时。 时间单位是秒。
    }

}
```



### 2、使用 @CrossOrigin 注解

Controller层在需要跨域的类或者方法上加上该注解即可。

```
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
@CrossOrigin(origins = "*",maxAge = 3600)
public class UserController {
	final UserService userService;
	

	@GetMapping("/getOne/{id}")
	public User getOne(@PathVariable("id") Integer id) {
		return userService.getById(id);
	}

}
```



### 3、自定义跨域过滤器

#### 1）编写过滤器

    // 跨域过滤器
    @Component
    public class CORSFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
    	//*号表示对所有请求都允许跨域访问
        HttpServletResponse res = (HttpServletResponse) response;
        res.addHeader("Access-Control-Allow-Credentials", "true");
        res.addHeader("Access-Control-Allow-Origin", "*");
        res.addHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, PUT");
        res.addHeader("Access-Control-Allow-Headers", "Content-Type,X-CAF-Authorization-Token,sessionToken,X-TOKEN");
        if (((HttpServletRequest) request).getMethod().equals("OPTIONS")) {
            response.getWriter().println("Success");
            return;
        }
        chain.doFilter(request, response);
    }
     
    @Override
    public void destroy() {
     
    }
     
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
     
    }
    }

#### 2）注册过滤器

```
@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration corsConfiguration = new CorsConfiguration();
        corsConfiguration.addAllowedOrigin("*");
        corsConfiguration.addAllowedHeader("*");
        corsConfiguration.addAllowedMethod("*");
        corsConfiguration.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource urlBasedCorsConfigurationSource = new UrlBasedCorsConfigurationSource();
        urlBasedCorsConfigurationSource.registerCorsConfiguration("/**", corsConfiguration);
        return new CorsFilter(urlBasedCorsConfigurationSource);
    }

}
```


