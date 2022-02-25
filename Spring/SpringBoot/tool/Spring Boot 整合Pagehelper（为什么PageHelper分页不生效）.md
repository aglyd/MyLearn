# [Spring Boot 整合Pagehelper（为什么PageHelper分页不生效）][https://blog.51cto.com/357712148/2381845?source=dra]



引入包
https://mvnrepository.com/artifact/com.github.pagehelper/pagehelper-spring-boot-starter/1.2.10

```html
<!--分页-->
        <!-- https://mvnrepository.com/artifact/com.github.pagehelper/pagehelper-spring-boot-starter -->
        <dependency>
            <groupId>com.github.pagehelper</groupId>
            <artifactId>pagehelper-spring-boot-starter</artifactId>
            <version>1.2.10</version>
        </dependency>

<!--需要注入容器中-->
		<dependency>
            <groupId>com.github.pagehelper</groupId>
            <artifactId>pagehelper</artifactId>
            <version>1.2.10</version>
        </dependency>
```

# 配置文件

==现 PageHelper若要在Springboot中使用 是需要进行注入的：==

==**使用Springboot PageHelper启动器包** 无需注入 开箱即用==

```html
import com.github.pagehelper.PageHelper;
import org.apache.ibatis.session.Configuration;
import org.mybatis.spring.boot.autoconfigure.ConfigurationCustomizer;
import org.springframework.context.annotation.Bean;
import java.util.Properties;


/**
 *配置文件
 * @author liwen406
 * @date 2019-04-20 12:14 2019-04-20 13:20
 */
@org.springframework.context.annotation.Configuration
public class MyBatisConfig {

    /**
     * 目的防止驼峰命名规则
     * @return
     */
    @Bean
    public ConfigurationCustomizer configurationCustomizer(){
        return new ConfigurationCustomizer(){

            @Override
            public void customize(Configuration configuration) {
                configuration.setMapUnderscoreToCamelCase(true);
            }
        };
    }

    /**
     * 分页插件
     * @return
     */
    @Bean
    public PageHelper pageHelper() {
        System.out.println("MyBatisConfiguration.pageHelper()");
        PageHelper pageHelper = new PageHelper();
        Properties p = new Properties();
        p.setProperty("offsetAsPageNum", "true");
        p.setProperty("rowBoundsWithCount", "true");
        p.setProperty("reasonable", "true");
        pageHelper.setProperties(p);
        return pageHelper;
    }
}
```

# dao mapper

```html
    @Select("SELECT * from tbl_emp")
    List<Employee> selectByExample(Employee example);
```

# Service

```html
   @Override
    public List<Employee> selectByExample() {

        return projectInfodao.selectByExample(null);
    }
```

# Controller

```html
    @GetMapping("/page/{start}/{end}")
    @ResponseBody
    public List<Employee> likeName(@PathVariable int start, @PathVariable int end) throws Exception {
        /*
         * 第一个参数：第几页;
         * 第二个参数：每页获取的条数.
         */
        PageHelper.startPage(start, end);
        return projectInfService.selectByExample();
    }
```



----------

[springboot整合PageHelper 过程中PageHelper.startPage(1,1)不生效问题][https://blog.csdn.net/weixin_43733952/article/details/90268127]

[SpringBoot项目中分页插件PageHelper无效的问题及解决方法][https://www.jb51.net/article/188328.htm]

[PageHelper获取数据总条数][https://blog.csdn.net/wangshuoxyy/article/details/102720141]