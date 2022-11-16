# [Idea最新版创建一个SpringMVC项目的详细步骤](https://blog.csdn.net/qq_36223406/article/details/120850022)

IDEA创建一个SpringMVC项目（基于注解）
1. 首先在idea中如图建一个项目，别的不要勾


当然创建方法不唯一，也可以用maven，或者手工导jar包，自己建起目录结构。

接下来可以填写项目名

系统创建好的目录结构如下：


注意观察：applicationContext.xml,dispatcher-servlet.xml都在WEB-INF内被创建了
src是放java包的文件夹，java包中又有java类
而且这个项目里spring的jar包也已经下载好了：


2.下一步，按如图所示创建包结构：


3.下一步，设置好三个配置文件，web，spring与springmvc
web.xml
自动生成的其他部分不要动，在dispatcher中添加一个初始化标签，指向配置信息，附录中会粘贴可复制的文档，这里先看图


在dispatcherServlet.xml中写入如下内容：
不用管上面的命名空间，写完之后idea会自动补全，详细每条是什么意思请翻书，要注意前缀设置了WEB-INF/jsp，就意味着找视图时会从这个文件夹中找！


在applicationContext.xml中写入如下内容：


如果标红，就按Alt+Enter创建一个命名空间，


到此为止，spring就能扫描添加注解的类了。所以下面开始创建类

4.创建Bean，DAO，Service，Controller类
简单起见不写接口了，尽量简化，看清本质

package csdn.junKo.bean;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class Book {

    @Value("20")
    int id;
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    @Override
    public String toString() {
        return "Book{" +
                "id=" + id +
                '}';
    }
}


1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
package csdn.junKo.dao;


import csdn.junKo.bean.Book;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class BookDao {

    public void deleteBook(Book book){
        System.out.println("BookDao : deleteBook "+book +" in database ;");
    }
}


1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
package csdn.junKo.service;


import csdn.junKo.bean.Book;
import csdn.junKo.dao.BookDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class BookService {

    @Autowired
    BookDao bookDao;
    
    @Autowired
    Book book;
    
    public String deleteBook(){
        System.out.println("BookService: deleteBook");
        bookDao.deleteBook(book);
        return "deleteBook ok";
    }
}


1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
package csdn.junKo.controller;


import csdn.junKo.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class HelloBookController {

    @Autowired
    BookService bookService;
    
    @RequestMapping("/deleteBook")
    public ModelAndView  deleteBook(){
    
        String str = bookService.deleteBook();
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("deleteBook");
        modelAndView.addObject("msg",str);
        return modelAndView;
    }
}

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
5.在WEB-INF下的jsp文件夹中创建jsp页面
没有jsp文件夹，自己新建一个

用EL输出时有提示，说明结果正确。

当然，那些dao什么的都是瞎写的，就是检查一些spring能不能装配成功，如果点左边的绿叶子图标能导航到依赖它的类，就说明可以了


6.添加tomcat运行环境
照着图片点



前提是已经安装了tomcat环境

点fix

这里可这个黄圈里的东西可以改掉，它即为项目名，在访问url时会多一层它。

结果：

7.ProjectStructure设置
左键项目，按键盘F4，选择artifact双击右面两个或者按fix

此外，还要去把tomcat的库add进来，不然没法启动
加号->add Library


8.启动服务器，访问/deletebook.form
之所以有form后缀，因为web.xml里如此配置
结果：

## 附录：

配置文件内容
web.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_5_0.xsd"
         version="5.0">
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/applicationContext.xml</param-value>
    </context-param>
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <servlet>
        <servlet-name>dispatcher</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>

        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>WEB-INF/dispatcher-servlet.xml</param-value>
        </init-param>

        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatcher</servlet-name>
        <url-pattern>*.form</url-pattern>
    </servlet-mapping>
</web-app>
```

applicationContext.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"

       xsi:schemaLocation=
       "http://www.springframework.org/schema/beans 
       http://www.springframework.org/schema/beans/spring-beans.xsd 
       http://www.springframework.org/schema/context 
       https://www.springframework.org/schema/context/spring-context.xsd">
    <context:component-scan base-package="csdn.junKo"></context:component-scan>
    <context:annotation-config></context:annotation-config>
</beans>
```

dispatcher-[servlet](https://so.csdn.net/so/search?q=servlet&spm=1001.2101.3001.7020).xml

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd http://www.springframework.org/schema/mvc https://www.springframework.org/schema/mvc/spring-mvc.xsd">

    <context:component-scan base-package="csdn.junKo"/>
    <mvc:annotation-driven/>
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" id="InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/jsp/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
</beans>
```



# [IDEA 创建SpringMVC全过程](https://blog.csdn.net/gdvfs12/article/details/121739522)