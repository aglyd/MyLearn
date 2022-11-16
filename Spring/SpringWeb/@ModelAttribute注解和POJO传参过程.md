# [@ModelAttribute注解和POJO传参过程](https://www.cnblogs.com/Hxinguan/p/6128774.html)

### **1、@ModelAttribute注解**

@ModelAttribute主要有三个用途，对方法进行注解，对参数进行注解，还有@ModelAttribute和@RequestMapping一起对方法进行注解。

(1) 对方法进行注解

@ModelAttribute对方法进行注解，有两个作用，一是在调用@RequestMapping注解的方法之前，先调用@ModelAttribute注解的方法，二是在@ModelAttribute注解的方法中，所有Map的对象都放入ImpliciteModel中，key就是Map的key。在后面讲解POJO传参的过程中，会讲解ImpliciteModel的作用。测试代码如下：

两个POJO代码如下：、

User.java

```java
public class User {
      private String username;
      private String password;
     private int id;
}
```

Cat.java

```java
public class Cat {
    private int speed;  
}
```

Controller代码：

```java
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.SessionAttributes;

@Controller
public class HandlerController {

    @RequestMapping("/hello")
    public String hello(@ModelAttribute("users")User user, Map<String, Object> map, Cat cat, String password)
    {
        cat.setSpeed(100);
        System.out.println(password);
        return "hello";
    }

    @ModelAttribute
    public String preUser(Cat cat, User user, Map<String, Object> map, String username)
    {
        System.out.println(username);
        cat.setSpeed(110);
        user.setId(1);
        User user1 = new User(2, "username1", "password1");
        map.put("users", user1);
        return "abc";
    }
}
```

提交表单jsp：

 <form action="hello.do" method="post">
     <input name="username" type="text"/>
     <input name="password" type="text"/>
     <input type="submit" value="submit" > 
</form>



页面显示代码：

```jsp
<body>
user:
${user.username }
${user.password }
${user.id }
<br><br>
users:
${users.username }
${users.password }
${users.id }
<br><br>
string:
${string}
<br><br>
cat:
${cat.speed }
<br><br>
username:
${username }
<br><br>
password:
${password }
</body>
```

在表单中输入username, password，页面显示的结果如下：

![img](https://images2015.cnblogs.com/blog/790604/201612/790604-20161203135609865-78165863.png)

控制台中输出：username  password

从结果可以看出：@ModelAttribute注解的方法在@RequestMapping注解的方法之前执行，并且preUser方法中，一共有四个对象放入map中，相当于：

map.put("cat", cat)、map.put("user", user)、map.put("users", user1)和map.put("string", "abc");

POJO在传参的过程中，springmvc会默认的把POJO放入到map中，其中键值就是类名的第一个字母小写。在@ModelAttribute注解的方法里，POJO放入到Map的同时，也放入ImpliciteModel中， 比如上面代码中的user和cat。@ModelAttribute注解的方法里，返回类型不是void，则返回的值也会被放到Map中，其中键值为返回类型的第一个字母小写。比如上述代码中，返回的"abc",就会被放入到Map中，相当于map.put("string", "abc")。

　　在执行@ModelAttribute注解的方法里，表单的数据会被当作参数传到@ModelAttribute注解的方法，和@RequestMapping注解的方法传参是一样的。

(2) @ModelAttribute对参数进行注解

比如上面的代码，@ModelAttribute("users")User user。在传参的过程中，首先检查ImpliciteModel有没有键值为users，有的话，直接从ImpliciteModel中取出该对象，然后在把表单传过来的数据赋值到该对象中，最后把该对象当作参数传入到@RequestMapping注解方法里，也就是hello方法。当检查到键值的话，并不会创建新的对象，而是直接从ImpliciteModel直接取出来。

(3) @ModelAttribute和@RequestMapping一起对方法进行注解

@ModelAttribute和@RequestMapping对方法进行注解时，其中返回类型被到Map中，并不会被当作视图的路径进行解析。把controller代码改变成如下：

```
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.SessionAttributes;

@Controller
public class HandlerController {

    @ModelAttribute
    @RequestMapping("/hello")
    public String hello(@ModelAttribute("users")User user, Map<String, Object> map, Cat cat, String password)
    {
        cat.setSpeed(100);
        System.out.println(password);
        return "bbbbb";
    }

    @ModelAttribute
    public String preUser(Cat cat, User user, Map<String, Object> map, String username)
    {
        System.out.println(username);
        cat.setSpeed(110);
        user.setId(1);
        User user1 = new User(2, "username1", "password1");
        map.put("users", user1);
        return "abc";
    }
}
```

其中返回的视图路径就是@RequestMapping("/hello")中的hello，显示结果如下：

![img](https://images2015.cnblogs.com/blog/790604/201612/790604-20161203143513896-1908491729.png)

从结果中，bac变为了bbbbb，主要是因为返回值会被放入到map，键值为返回类型第一个字母的小写，原来的map.put("string", "abc")被覆盖掉，变成map.put("string", "bbbbb")。

 

### **2、POJO传参的过程**

POJO传参的过程中，先检查ImpliciteModel中是否有相对应的键值，有的话就把该键值的对象取出来，把表单传过来的数据传到该对象，然后把该对象作为参数传到目标方法中，也就是@RequestMapping注解的方法中。在ImpliciteModel没有相对应的键值，假如controller用SessionAttribute进行注解，则就会在Session attribute查找相对应的key，假如找到了key，却没有对象，则会报异常。在ImpliciteModel和SessionAttribute都没有查找到key，才会创建新的对象，把表单传过来的数据赋值给新的对象，最后把新的对象作为参数传到目标方法中。

以下是报异常的代码

```
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.SessionAttributes;

@SessionAttributes("user")
@Controller
public class HandlerController {

    @ModelAttribute
    @RequestMapping("/hello")
    public String hello(@ModelAttribute User user, Map<String, Object> map, Cat cat, String password)
    {
        cat.setSpeed(100);
        System.out.println(password);
        return "bbbbb";
    }
}
```

会报如下异常：

![img](https://images2015.cnblogs.com/blog/790604/201612/790604-20161203145315240-1425818609.png)

 只要把@SessionAttributes("user")改成@SessionAttributes("users")就可以消去异常，或者把public String hello(@ModelAttribute User user, Map<String, Object> map, Cat cat, String password)中的@ModelAttribute 去掉，只有用@ModelAttribute注解参数，才会从session attribute中查找相对应的key。