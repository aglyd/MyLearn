# [@ModelAtribute用法][https://blog.csdn.net/qq_35182361/article/details/77768852]

[@ModelAttribute运用详解](http://www.cnblogs.com/yg_zhang/p/4308271.html)

被@ModelAttribute注释的方法会在此controller每个方法执行前被执行，因此对于一个controller映射多个URL的用法来说，要谨慎使用。

我们编写控制器代码时，会将保存方法独立成一个控制器也是如此。

 

[1.@ModelAttribute](mailto:1.@ModelAttribute)注释void返回值的方法

```java
@Controller
public class HelloModelController {
    
    @ModelAttribute 
    public void populateModel(@RequestParam String abc, Model model) {  
       model.addAttribute("attributeName", abc);  
    }  

    @RequestMapping(value = "/helloWorld")  
    public String helloWorld() {  
       return "helloWorld.jsp";  
    }  

}
```

在这个代码中，访问控制器方法helloWorld时，会首先调用populateModel方法，将页面参数abc(/helloWorld.ht?abc=text)放到model的attributeName属性中，在视图中可以直接访问。

jsp页面页面如下。



```jsp
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
</head>
<body>
<c:out value="${attributeName}"></c:out>
</body>
</html>
```



 

[2.@ModelAttribute](mailto:2.@ModelAttribute)注释返回具体类的方法

```java
@Controller
public class Hello2ModelController {
    
    @ModelAttribute 
    public User populateModel() {  
       User user=new User();
       user.setAccount("ray");
       return user;
    }  
    @RequestMapping(value = "/helloWorld2")  
    public String helloWorld() {  
       return "helloWorld.jsp";  
    }  
}
```



当用户请求 http://localhost:8080/test/helloWorld2.ht时，首先访问populateModel方法，返回User对象，model属性的名称没有指定，

它由返回类型隐含表示，如这个方法返回User类型，那么这个model属性的名称是user。 
这个例子中model属性名称有返回对象类型隐含表示，model属性对象就是方法的返回值。它无须要特定的参数。

jsp 中如下访问：

```jsp
<c:out value="${user.account}"></c:out>
```

也可以指定属性名称



```java
@Controller
public class Hello2ModelController {
    
    @ModelAttribute(value="myUser")
    public User populateModel() {  
       User user=new User();
       user.setAccount("ray");
       return user;
    }  
    @RequestMapping(value = "/helloWorld2")  
    public String helloWorld(Model map) {  
       return "helloWorld.jsp";  
    }  
}
```



jsp中如下访问：

```jsp
<c:out value="${myUser.account}"></c:out>
```

 

对象合并:

```java
@Controller
public class Hello2ModelController {
    
    @ModelAttribute
    public User populateModel() {  
       User user=new User();
       user.setAccount("ray");
       return user;
    }  
    
    @RequestMapping(value = "/helloWorld2")  
    public String helloWorld(User user) {
        user.setName("老王");
       return "helloWorld.jsp";  
    }  
}
```



这个在编写代码的时候很有用处,比如在更新的时候，我们可以现在populateModel方法中根据ID获取对象，然后使用spring mvc的自动组装功能，组装

User对象，这样在客户端提交了值的属性才会被组装到对象中。

比如：User对象，首先从数据库中获取此对象，客户端表单只有account属性，提交时就只会改变account属性。

 

对象合并指定对象名称：



```java
@Controller
public class Hello2ModelController {
    
    @ModelAttribute("myUser")
    public User populateModel() {  
       User user=new User();
       user.setAccount("ray");
       return user;
    }  
    
    @RequestMapping(value = "/helloWorld2")  
    public String helloWorld(@ModelAttribute("myUser") User user) {
        user.setName("老王");
       return "helloWorld.jsp";  
    }  
}
```



这样在jsp中可以使用如下方式访问

```jsp
<c:out value="${myUser.name}"></c:out>
<c:out value="${myUser.account}"></c:out>
```

 

3.通过此特性控制权限.

我们可以在基类方法中控制写此注解，需要控制权限的控制器，继承控制器就可以了。



```java
public class BaseController {
    
    @ModelAttribute
    public void populateModel() throws Exception {  
       SysUser user=ContextUtil.getCurrentUser();
       if(user.getAccount().equals("admin")){
           throw new Exception("没有权限");
       }
    }  
}
```



需要控制权限的类继承BaseController

```java
@Controller
public class Hello2ModelController extends BaseController {
    
    @RequestMapping(value = "/helloWorld2")  
    public String helloWorld(@ModelAttribute("myUser") User user) {
        user.setName("老王");
       return "helloWorld.jsp";  
    }  
}
```



------



# [SpringMvc中的@ModelAttribute][https://blog.csdn.net/qq_21050291/article/details/72724607]

@ModelAttribute注解用于将请求的参数绑定到Model对象中，方便在前台的数据回显

### @ModelAtttribute注解一个方法的具体的形参

```java
  @RequestMapping(value="/updateItem",method=RequestMethod.POST)
    public String updateItem(@ModelAttribute("id") Integer id,@ModelAttribute("item")Items itemcustomer) throws Exception{
        itemsService.updateItems(id,itemcustomer);
        /*model.addAttribute("id",id);*/
        return "editItem";
        //      return "redirect:queryItems.action";
    }
```

springmvc会自动的将pojo类型添加到Model中，**key为该pojo的类名首字母小写**
在这里如果去掉形参itmecustomer上的注解，就会由springmvc自动将itemcustomer写到model中，类似于model.addAttribute(“itmes”,itemcustomer)，
如果想要改变Key的值，就必须使用@ModelAttribute(value=key)这个注解
对于普通类型springmvc并不会这么做，必须手动编写model.addAttribute(“”)，例如这里的id是Integer类型的，所以并不会自动将id写到Model中，除非加上@ModelAttribute(“id”)或者在方法内model.addAttribute(“id”,id)

### @ModelAtttribute注解一个方法

```java
    @RequestMapping("/queryItems")
    public ModelAndView queryItems() throws Exception{
        List<ItemsCustomer> itemsCustomers = itemsService.queryItems(null);
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("itemsList");
        modelAndView.addObject("items",itemsCustomers);
        return modelAndView;
    }
```




```java
@ModelAttribute
public Items getItem(Integer id){
    Items items = new Items();
    items.setName("自己添加的");
    return items;
}
```
1. 如果方法返回pojo对象，那么可以不用在@ModelAttribute中加上value属性，其值就是返回类型的首字母小写
2. 如果方法没有返回值，那么就可以**在方法的形参中加上一个Model形参，然后在代码里就行addAttribute**(例本页第一个方法代码)
3. 如果方法返回的是普通类型，那么可以在注解里面加上value属性，指定model中的key值
4. 在一个Controller类中，如果有方法使用了@ModelAttribute注解，那么每一个请求都会先请求这个方法，然后再请求url指定的那个方法，像上面的这个方法，如果此时请求queryItems.action,那么会调用getItem方法，这个方法会将items以(“items”,items)的形式添加到Model中，然后再执行queryItems方法，不过此时，在这个里面也有这个方法modelAndView.addObject(“items”,itemsCustomers);意味着key重复了，本质上Model是一个Map，所以理所当然的会将之前的items冲掉了
5. 使用@ModelAttribute将公用的获取数据的方法返回值传到页面，**不用在每一个controller方法通过Model将数据传到页面。**

### @ModelAtttribute和@RequestMapping方法作用于同一个方法

```java
    @RequestMapping("/login")
    @ModelAttribute("loginname")
    public String login(){
        return "admin";
    }
```

当使用@RequestMapping和@ModelAtribute一起注解一个方法的时候，**方法的返回值是会将加入到Model中的**
视图名应该是@RequestMapping的value的值，这里就是login
请求的时候也是按照@RequestMapping的value进行请求

------------------------------------------------




# [Spring中Model,ModelMap以及ModelAndView之间的区别][https://www.cnblogs.com/nongzihong/p/10071223.html]

**1.场景分析**
  在许多实际项目需求中，后台要从控制层直接返回前端所需的数据，这时Model大家族就派上用场了。

 

**2.三者区别**

Model

Model是一个接口，它的实现类为ExtendedModelMap，继承ModelMap类 

```java
public class ExtendedModelMap extends ModelMap implements Model
```


**ModelMap**

ModelMap继承LinkedHashMap，spring框架自动创建实例并作为controller的入参，用户无需自己创建

```java
public class ModelMap extends LinkedHashMap<String,Object>
```


**ModelAndView**

顾名思义，ModelAndView指模型和视图的集合，既包含模型 又包含视图；ModelAndView的实例是开发者自己手动创建的，这也是和ModelMap主要不同点之一；



 

### Model的用法

spring自动为Model创建实例，并作为controller的入参

```java
@RequestMapping("hello")
public String testVelocity(Model model,String name){
    model.addAttribute("name",name);
    return "hello";
}
```

 测试效果：

![img](https://img2018.cnblogs.com/blog/1470521/201812/1470521-20181205152718487-1475368657.png)

 

### ModelMap与model用法差不多

```java
@RequestMapping("hello")
public String testVelocity(ModelMap model,String name){
    model.addAttribute("name",name);
    return "hello";
}
```

这里效果跟Model运行效果一样

 

### ModelAndView的用法:

```java
@RequestMapping("model")
public ModelAndView testModel(String name) {
    //构建ModelAndView实例，并设置跳转地址
    ModelAndView view = new ModelAndView("test");
    //将数据放置到ModelAndView对象view中,第二个参数可以是任何java类型
    view.addObject("name",name);
    //返回ModelAndView对象view
    return view;
}
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

设置view跳转地址

```java
ModelAndView view = new ModelAndView("test");
```

当然还可以这样设置跳转地址

```java
ModelAndView view = new ModelAndView();
view.setViewName("test");
```

中的test表示templates中的test.html，springboot默认的模版文件一般都在resources/templates下

![img](https://img-blog.csdn.net/20170715213336355?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvemhhbmd4aW5nNTIwNzc=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)