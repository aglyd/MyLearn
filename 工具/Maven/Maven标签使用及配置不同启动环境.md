# [Maven之< profiles>](https://blog.csdn.net/w2009211777/article/details/124014773)

## 一、介绍

我们项目打包的时候需要选择具体引用哪个配置文件，product？test？dev？

而<profiles>就是指定具体的配置文件的。

## 二、配置案例

```xml
<!-- profile begin -->
  <profiles>
    <profile>
      <id>dev</id>
      <activation>
        <property>
          <name>APP_ENV</name>
          <value>dev</value>
        </property>
      </activation>
      <properties>
        <profile.env.name>env.dev.properties</profile.env.name>
      </properties>
    </profile>
    <profile>
      <id>test</id>
      <activation>
        <property>
          <name>APP_ENV</name>
          <value>test</value>
        </property>
      </activation>
      <properties>
        <profile.env.name>env.test.properties</profile.env.name>
      </properties>
    </profile>
    <profile>
      <id>product</id>
      <activation>
        <property>
          <name>APP_ENV</name>
          <value>product</value>
        </property>
      </activation>
      <properties>
        <profile.env.name>env.product.properties</profile.env.name>
      </properties>
    </profile>
    <profile>
      <id>product_cron</id>
      <activation>
        <property>
          <name>APP_ENV</name>
          <value>product_cron</value>
        </property>
      </activation>
      <properties>
        <profile.env.name>env.product_cron.properties</profile.env.name>
      </properties>
    </profile>
  </profiles>
  <!-- profile end -->
```

## 三、引用

### 方式一：通过-P + <profile.id>引用

打包时执行mvn clean package -P test将触发test环境的profile配置

相对应的：

> mvn clean package -P dev  触发env.dev.properties
>
> mvn clean package -P product  触发 env.product.properties

### 方式二：通过-D引用

**-D代表（Properties属性）**

如上对应的property的name为APP_ENV，因此可以使用如下命令

> mvn clean package -DAPP_ENV=test  将触发test环境的profile配置
>
> mvn clean package -DAPP_ENV=dev  触发env.dev.properties
>
> mvn clean package -DAPP_ENV=product  触发 env.product.properties




# [Maven中< resources>标签详解](https://blog.csdn.net/newbie_907486852/article/details/81205532)

```yaml
clean install -DskipTests -P test   传入test参数 
 DskipTests,不执行测试用例
-P test 会激活项目下的pom.xml配置的<profiles>标签下id为test的标签
```

```xml
 <!-- profiles.active默认激活dev -->
  <profiles>
    <profile>
        <!-- 声明这个profile的id身份 -->
        <id>dev</id>
        <!-- 默认激活：比如当知心mvn package命令是，没有传入参数，默认使用这个
                                    当使用mvn package -P dev 传入参数时，表示使用这个id的profile -->
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <!-- 该标签下配置对应的key  value -->
        <properties>
            <!-- 这里的标签名任意，在 项目的 properties、xml等配置文件中可以使用${profiles.active}取出dev这个值-->
            <profiles.active>dev</profiles.active>
        </properties>
    </profile>
    <profile>
        <id>test</id>
        <properties>
            <profiles.active>test</profiles.active>
        </properties>
    </profile>
    <profile>
        <id>pro</id>
        <properties>
            <profiles.active>pro</profiles.active>
        </properties>
    </profile>
  </profiles>


  <build>
    <finalName>com_dubbo_config</finalName>

    <resources>
        <!-- 导入除配置文件外的其他资源文件 -->
        <resource>
            <!-- 指定resources插件处理哪个目录下的资源文件,导入资源文件 -->
            <directory>src/main/resources</directory>
            <!-- 打包后放在什么位置 -->
            <targetPath>${project.build.directory}/classes</targetPath>
            <!-- 不包含directory指定目录下的以下文件 -->
            <excludes>
                <exclude>pro/*</exclude>
                <exclude>dev/*</exclude>
                <exclude>test/*</exclude>
            </excludes>
            <!-- 只（这个字很重要）包含directory指定目录下的以下文件 
                 <include>和<exclude>都存在的话，那就发生冲突了，这时会以<exclude>为准 -->
            <includes>
                <include></include>
            </includes>
            <!-- 待定： filtering为true的时候，这时只会把过滤的文件（<excludes>）打到classpath下，
                 filtering为false的时候，会把不需要过滤的文件（<includes>）打到classpath下 -->
            <filtering>true</filtering>
        </resource>

        <!-- 根据启动的环境，导入相应的资源目录，如启动dev环境，则导入src/main/resources/dev下的文件-->
        <resource>
            <directory>src/main/resources/${profiles.active}</directory>
            <targetPath>${project.build.directory}/classes</targetPath>
        </resource>
    </resources>
  </build>
```



# [maven中filtering的使用](https://www.cnblogs.com/wangxuejian/p/13551292.html)

SpringEL表达式取值一般是${var}方式取值, 见于application.properties和@Value("${var}")中

maven的pom.xml文件中也有类似的取值表达式, 也是通过${var}的方式取值

然而:  它们并不是一个东西!

EL表达式适用于配置文件及代码中的注解

maven的占位符取值表达式默认仅仅适用于pom.xml文件中

我们的需求大多是想打通二者的交流,如何做?

此时filtering就派上用场了

maven的占位符解析表达式的使用场合默认只在pom文件范围内活动

如果想扩大它的活动范围,就必须指定需要扩大到哪些文件,然后指定filtering=true.然后maven的占位符解析表达式就可以用于它里面的表达式解析了.

```xml
<build>
    <resources>
        <resource>
            <directory>${project.basedir}/src/main/resources</directory>
            <filtering>true</filtering>
        </resource>
    </resources>
</build>
```

题外话:

==**如果你的项目继承了spring-boot-starter-parent,**==

==**如果想在application.properties中使用maven的占位符以获取maven的参数,此时就不能用${},**==

==**因为可能会与EL表达式冲突,**==

==**怎么办?**==

==**此时parent依赖将maven占位符表达式默认改为@var@的形式.  所以只能用@var@替代${var}**==

 

总结:

1. Spring EL表达式和MAVEN的占位符表达式长得一样,但两者默认进水不犯河水,不能再Spring的范围内取maven的参数

2. **==filtering的作用就是打通两者的连接, 让井水犯河水, 具体来说是让Spring的范围内能取到maven的参数==**

3. ==**filtering的使用要配合resource一起使用: 前者开启打通连接,后者指定打通的范围.**==



# [案例：maven profile ＜filtering＞true＜/filtering＞的作用](https://blog.csdn.net/u010002184/article/details/103404553)

1  在pom.xml中 <!--<filtering>true</filtering>--> 被注释掉

打包时能替换文件名，但是不能替换文件里面的标识符,启动项目时报错。

2 在pom.xml中 <filtering>true</filtering>

打包时能替换文件名，也能**替换文件里面的标识符**：启动时正常

------------------------------------------------------------------------------

1  在pom.xml中 <!--<filtering>true</filtering>--> 被注释掉

```xml
        <profile>
            <id>dev</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <profilesActive>dev</profilesActive>
                <activated_yml>dev</activated_yml>
            </properties>
            <build>
                <resources>
                    <resource>
                        <!--<filtering>true</filtering>-->
                        <directory>src/main/resources</directory>
                        <includes>
                            <include>application.yml</include>
                            <include>application-${activated_yml}.yml</include>
                            <include>logback-dev.xml</include>
                            <include>spring-mvc.xml</include>
                            <include>spring-task.xml</include>
                            <include>mybatis/mapper/*.xml</include>
                            <include>mybatis/mybatis-config.xml</include>
                        </includes>
                    </resource>
                </resources>
            </build>
 
        </profile>
```

**打包时能替换文件名，但是不能替换文件里面的标识符：**

![img](https://img-blog.csdnimg.cn/20191205144114978.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTAwMDIxODQ=,size_16,color_FFFFFF,t_70)

![img](https://img-blog.csdnimg.cn/20191205144256431.png)

启动项目时报错：

14:37:32.598 [main] ERROR org.springframework.boot.SpringApplication - Application run failed
java.lang.IllegalStateException: Failed to load property source from location 'classpath:/application.yml'

2 在pom.xml中 <filtering>true</filtering>

```xml
        <profile>
            <id>dev</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <profilesActive>dev</profilesActive>
                <activated_yml>dev</activated_yml>
            </properties>
            <build>
                <resources>
                    <resource>
                        <filtering>true</filtering>
                        <directory>src/main/resources</directory>
                        <includes>
                            <include>application.yml</include>
                            <include>application-${activated_yml}.yml</include>
                            <include>logback-dev.xml</include>
                            <include>spring-mvc.xml</include>
                            <include>spring-task.xml</include>
                            <include>mybatis/mapper/*.xml</include>
                            <include>mybatis/mybatis-config.xml</include>
                        </includes>
                    </resource>
                </resources>
            </build>
 
        </profile>
```

![img](https://img-blog.csdnimg.cn/20191205144614491.png)



# [maven的filtering,includes,excludes标签用法](http://t.zoukankan.com/wangxuejian-p-13556306.html)

filtering标签和includes,excludes标签都是resource标签下的标签,它们经常出入成双

然而,这两者根本就是俩东西

filtering用于扩大范围,什么范围呢?maven默认只会替换pom文件中的占位符属性,不会触碰resources下相关文件的.但**==filtering=true了,就可以触碰了.触碰的效果就是能替换resources下指定文件的占位符属性.==**

可是谁来指定文件是哪些呢?这就是includes和excludes的事儿了.

此处可以望文生义, includes和excludes的实际意思就是: 包括和排除

**==默认情况下,maven打包时会包含resources下所有的文件==**

如果我们只想让指定的几个文件被打包,那就将这几个文件放在includes标签下处理

同理: 如果我们不想让这几个文件被打包,那就将这几个文件放在excludes标签下处理.

========================filtering的单独使用====================================

### 1、没有使用filtering时:

pom文件中定义在不同激活区的属性xxx

```xml
<profiles>
    <profile>
        <id>dev</id>
        <properties>
            <xxx>dev</xxx>
        </properties>
    </profile>
    <profile>
        <id>sit</id>
        <properties>
            <xxx>sit</xxx>
        </properties>
    </profile>
    <profile>
        <id>uat</id>
        <properties>
            <xxx>uat</xxx>
        </properties>
    </profile>
</profiles>
```

bootstrap.properties文件中定义的占位符属性${xxx}

```
spring.cloud.config.profile=${xxx}
```

使用-Psit打包后target下对应文件原封不动,没被替换:

```
spring.cloud.config.profile=${xxx}
```

### 2、使用filtering后:

```xml
<build>
    <resources>
        <resource>
            <directory>${project.basedir}/src/main/resources</directory>
            <filtering>true</filtering>
        </resource>
    </resources>
</build>
```

使用-Psit打包后target下对应文件中${}占位符被替换了:

```
spring.cloud.config.profile=sit
```

### 3、注意点:

**项目不能继承spring-boot-starter-parent,因为这个parent为了防止与pom的占位符冲突,通过maven-resources-plugin将spring使用的资源占位符专门设置为:@**  ,如下:

```xml
<properties>
   <java.version>1.6</java.version>
   <resource.delimiter>@</resource.delimiter> <!-- delimiter that doesn't clash with Spring ${} placeholders -->
   <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
   <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
   <maven.compiler.source>${java.version}</maven.compiler.source>
   <maven.compiler.target>${java.version}</maven.compiler.target>
</properties>
<plugin>
   <groupId>org.apache.maven.plugins</groupId>
   <artifactId>maven-resources-plugin</artifactId>
   <version>2.6</version>
   <configuration>
      <delimiters>
         <delimiter>${resource.delimiter}</delimiter>
      </delimiters>
      <useDefaultDelimiters>false</useDefaultDelimiters>
   </configuration>
</plugin>

可通过自己配置plugin覆盖此处配置:
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-resources-plugin</artifactId>
            <version>3.1.0</version>
            <configuration>
                <encoding>utf-8</encoding>
                <!-- 使Spring Boot支持${}占位符 -->
                <useDefaultDelimiters>true</useDefaultDelimiters>
            </configuration>
        </plugin>
    </plugins>
</build>

```

=============================includes与excludes的使用==================================

resources下文件有多个:

![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230158811-1700785425.png)

如果使用了include,

```xml
<build>
    <resources>
        <resource>
            <directory>${project.basedir}/src/main/resources</directory>
            <includes>
                <include>dev/</include>
            </includes>
        </resource>
    </resources>
</build>
```

则打包时进入target的是这样的:

![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230158811-1700785425.png)>>>>![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230300952-1128142539.png)

如果使用了exclude,

```xml
<build>
    <resources>
        <resource>
            <directory>${project.basedir}/src/main/resources</directory>
            <excludes>
                <exclude>dev/</exclude>
            </excludes>
        </resource>
    </resources>
</build>
```

则打包时进入target的是这样的:

![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230158811-1700785425.png)>>>>![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230352819-1194813190.png)

如果同时使用了include和exclude,

```xml
<build>
    <resources>
        <resource>
            <directory>${project.basedir}/src/main/resources</directory>
            <includes>
                <include>dev/</include>
            </includes>
            <excludes>
                <exclude>dev/application-dev.*</exclude>
            </excludes>
        </resource>
    </resources>
</build>
```

则打包时是这样的:

![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230158811-1700785425.png)>>>>![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230439607-280995611.png)

一个排除,一个包含,可以各自单独使用,也可以混合使用,混合使用时,如果范围有交集,会被排除掉,通常用于过滤掉文件夹中的几个特殊文件

========================filtering与include,exclude混合使用=================================

既进行资源过滤,又扩大maven属性占位符替换的范围,有三种方式:

**1.排除资源-------使用excludes排除**

**2.包括资源, 替换属性-------使用include包含, 且使用filtering=true过滤**

**3.包括资源, 不替换属性-------使用include包含,且不使用filtering过滤**

如果这样用:

```xml
<build>
    <resources>
        <resource>
            <directory>${project.basedir}/src/main/resources</directory>
　　　　　　　　// 红色表示资源过滤: 只保留dev文件夹下名字不是application-dev的文件
            <includes>
                <include>dev/</include>
            </includes>
            <excludes>
                <exclude>dev/application-dev.*</exclude>
            </excludes>
　　　　　　　　// 蓝色表示扩大属性替换范围: 替换资源过滤最终留下来的文件中的${}占位符属性
            <filtering>true</filtering>
        </resource>
    </resources>
</build>
```

那么打包结果:

![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824230158811-1700785425.png)>>>>![img](https://img2020.cnblogs.com/blog/1606054/202008/1606054-20200824231734531-1066958002.png)

target文件夹下的application-dev2.properties文件的属性值变化:

```
spring.cloud.config.profile=${xxx}    ----->      spring.cloud.config.profile=sit
```

###  总结:

1. ==**filtering用于打包时扩大maven替换占位符属性的范围, true表示会替换所在resource标签确定的文件范围内的占位符属性**==

2. ==**include和exclude用于打包时资源过滤, 主要目的是把resources下不想要的文件排除掉,不打进包中.**==

3. ==**exclude和filtering都是resource标签下的子标签, 一个用于过滤资源,一个用于是否替换占位符属性, 一般都是搭配使用, 但两者功能迥异.**==



# [maven中filter的使用方法](https://juejin.cn/post/6844904185557680142)

## 1、Filtering 的使用

### 1.1 使用项目中属性

在资源文件中可以使用`${...}`来表示变量（前提：项目不是springboot启动，否则要用@name@）。变量的定义可以为系统属性，项目中属性，筛选的资源以及命令。

例如： 在 `src/main/resources/hello.txt` 中包含以下内容：

```bash
Hello ${name}
```

并且pom.xml文件中代码如下：

```xml
<project>
  ...
  <name>My Resources Plugin Practice Project</name>
  ...
  <build>
    ...
    <resources>
      <resource>
        <directory>src/main/resources</directory>
      </resource>
      ...
    </resources>
    ...
  </build>
  ...
</project>
```

执行 `mvn resources:resources` 产生的 `target` 文件夹中 生成的 `target/classes/hello.txt` 文件和`src/main/resources/hello.txt` 文件有着一样的内容：

```bash
Hello ${name}
```

然而，在pom 文件`<resource>`标签下加入`<filtering>`标签 并且 设置为 `true`：

```xml
...
      <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
      </resource>
...
```

执行 `mvn resources:resources`  命令后，`target/classes/hello.txt` 文件内容发生了变化：

```
hello My Resources Plugin Practice Project
```

这是因为定义在 pom 中的 `<name>` 标签中的值替换了 `hello.txt`文件中 `name` 变量。

### 1.2 使用命令行

此外，也可以使用`“-D”`后面加上声明的命令行的方式来指定内容，例如： `mvn resources:resources -Dname="world"` 命令执行后，`target/classes/hello.txt` 文件内容为：

```
hello world
```

### 1.3 使用自定义属性

更近一步，不仅可以使用预先定义的项目变量，也可以使用在`<properties>`标签下自定义变量。例如：

在 `src/main/resources/hello.txt` 文件中将文件内容更改为：

```bash
Hello ${your.name}
```

在pom中`<properties>`标签下定义自定义变量 `your.name`：

```xml
<project>
  ...
  <properties>
    <your.name>world</your.name>
  </properties>
  ...
</project>
```

### 1.4 spring boot框架 与 Filtering 的使用

如果在 pom 文件中继承了 `spring-boot-starter-parent` pom文件，那么maven-resources-plugins的 Filtering 默认的过滤符号就从 `${*}` 改为 `@...@` (i.e. @maven.token@ instead of ${maven.token})来防止与 spring 中的占位符冲突。点击 [这里](https://link.juejin.cn?target=https%3A%2F%2Fdocs.spring.io%2Fspring-boot%2Fdocs%2F1.3.0.RELEASE%2Freference%2Fhtml%2Fhowto-properties-and-configuration.html%23howto-use-short-command-line-arguments) 查看文档

## 2、filter 的使用

为了管理项目，可以将所有变量和 其对应的值 写入一个独立的文件，这样就不需要重写pom文件或者每次构建都设置值。为此可以增加一个 `filter`：读取filter里的属性值，并过滤其他值

```xml
<project>
  ...
  <name>My Resources Plugin Practice Project</name>
  ...
  <build>
    ...
    <filters>
      <filter>[a filter property]</filter>
    </filters>
    ...
  </build>
  ...
</project>
```

例如： 新建文件 `my-filter-values.properties` 内容为：

```ini
your.name = world
```

在pom中增加filter：

```xml
...
    <filters>
      <filter>my-filter-values.properties</filter>
    </filters>
    ...
```

**注：不要过滤二进制内容的文件（如：图像）！会导致输出损坏。**

有文本和二进制资源文件情况下，推荐使用两个独立的文件夹。文件夹 `src/main/resources (默认)`中存放不需要过滤的资源文件，`src/main/resources-filtered`文件夹存放需要过滤的资源文件。

```xml
<project>
  ...
  <build>
    ...
    <resources>
      <resource>
        <directory>src/main/resources-filtered</directory>
        <filtering>true</filtering>
      </resource>
      ...
    </resources>
    ...
  </build>
  ...
</project>
复制代码
```

注：正如前面所提到的，过滤图像、pdf等二进制文件可能导致损坏的输出。为了防止这样的问题，可以配置文件扩展名不会被过滤。

## 3、Binary filtering

该插件将阻止二进制文件过滤，而无需为以下文件扩展名添加一些排除配置：

```
jpg, jpeg, gif, bmp 以及 png
```

如果想要添加补充文件扩展名，可以使用以下配置简单地实现

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-resources-plugin</artifactId>
        <version>3.1.0</version>
        <configuration>
          ...
          <nonFilteredFileExtensions>
            <nonFilteredFileExtension>pdf</nonFilteredFileExtension>
            <nonFilteredFileExtension>swf</nonFilteredFileExtension>
          </nonFilteredFileExtensions>
          ...
        </configuration>
      </plugin>
    </plugins>
    ...
  </build>
  ...
</project>
```

## 4、练习

在单独文件中定义变量以及值，并且将值对 resiurce文件夹下hello.txt文件中的变量定义符号进行替换。 文件结构：

```css
├─ src
│    └─ main
│           ├─ resources
│           │    └─ hello.txt
│           └─ resources-filtered
│                  └─ my-filter-values.properties
└─ pom.xml
```

hello.txt

```bash
hello ${your.name}
```

my-filter-values.properties

```ini
your.name = nomiracle
```

pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project ...>
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.example</groupId>
    <artifactId>test</artifactId>
    <version>1.0</version>

    <name>My Resources Plugin Practice Project</name>

    <build>
        <filters>
            <filter>src/main/resources-filtered/my-filter-values.properties</filter>
        </filters>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <filtering>true</filtering>
            </resource>
        </resources>
    </build>

</project>
```

执行 `mvn clean resources:resources` 命令，生成的 target 文件夹目录结构为：

```markdown
target
└─ classes
       └─ hello.txt
```

其中 hello.txt 文件中变量已经被替换：

```
hello nomiracle
```



# [maven的资源过滤filters](https://blog.csdn.net/pursuer211/article/details/82346354)

## [maven](https://so.csdn.net/so/search?q=maven&spm=1001.2101.3001.7020)的资源过滤

maven的过滤资源需要结合maven的2个定义才能实现，分别是：

- profile
- resources

下面分开来做介绍。

### profile

profile可以让我们定义一系列的配置信息，然后指定其激活条件。这样我们就可以定义多个profile，然后每个profile对应不同的激活条件和配置信息，从而达到不同环境使用不同配置信息的效果。需要掌握profile的定义以及激活条件。后面结合resources会介绍。

### resources

resources是指定maven编译资源文件指定到何处的，例如maven的标准资源目录结构是src/main/resources(这个在超级pom中定义到了)，maven进行编译时候就会将resources中的资源文件放到web的WEB-INF/classes下.具体如何和资源目录有关系，后面结合的时候后讲到。
超级pom中定义的resources：

```xml
<resources>
     <resource>
            <directory>${project.basedir}/src/main/resources</directory>
    </resource>
</resources>
<testResources>
      <testResource>
           <directory>${project.basedir}/src/test/resources</directory>
      </testResource>
</testResources>
```

## maven标准目录filter

很多互联网项目中，测试环境和线上环境都是分离的，那么为了方便开发测试，maven项目可以在编译时选取不同的配置文件，如何设置呢，看看以下例子？。

例子如下：
我在java/src/resources目录中定义了jdbc.properties文件内容如下：

```ruby
#dataSource configure
#jdbc.connection.url=jdbc:mysql://localhost:3306/test
#jdbc.connection.username=root
#jdbc.connection.password=123456
 
 
jdbc.connection.url=${jdbc.url}
jdbc.connection.username=${jdbc.username}
jdbc.connection.password=${jdbc.password}
```

通过maven编译后再WEB-INF/classes中得到的jdbc.properties文件内容如下：

```r
#dataSource configure
#jdbc.connection.url=jdbc:mysql://localhost:3306/test
#jdbc.connection.username=root
#jdbc.connection.password=123456
 
 
jdbc.connection.url=abcd
jdbc.connection.username=cccc
jdbc.connection.password=dddd
```

具体是怎么做到的呢？属性在使用${}的方式获取，属性值肯定得在pom中定义，这个在项目pom.xml中的定义方式如下：

```xml
<profiles>
        <!-- 开发/测试环境，默认激活 -->
        <profile>
            <id>test</id>
            <properties>
                <jdbc.url>abcd</jdbc.url>
                <jdbc.username>cccc</jdbc.username>
                <jdbc.password>dddd</jdbc.password>
            </properties>
            <activation>
                <!--默认启用的是dev环境配置 -->
                <activeByDefault>true</activeByDefault>
            </activation>
        </profile>
 
        <!-- 生产环境 -->
        <profile>
            <id>product</id>
            <properties>
                <env>product</env>
            </properties>
        </profile>
    </profiles>
```

为了能让profiles中的内容能让resources中的文件使用到，还需要上面说到的resources插件，定义信息如下：

```xml
<build>
        <finalName>idea-maven-introduce</finalName>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <filtering>true</filtering>
            </resource>
        </resources>
    </build>
```

**filtering设置为true很关键，不然引用不到profiles中的内容。但是这样做，就算设置好了吗，如何切换不同的属性的呢，还是没能体现到啊**

### profiles的激活方式：

**1、默认激活方式**
根据上面的例子，定义了一个

```xml
<activation>
        <!--默认启用的是dev环境配置 -->
         <activeByDefault>true</activeByDefault>
</activation>
```

这个是默认的激活方式，意思就是你什么都不做，直接使用标准的package打包时候会将该test定义属性能让resources下面的文件获取到。

**2、手动方式激活**
使用命令,mvn package –P profileId,例如：

```css
mvn package –P profileTest1 
```

它就会找profileTest1定义的属性了。

**3、根据jdk环境来激活**

```xml
<profiles>  
       <profile>  
              <id>profileTest1</id>  
              <jdk>1.5</jdk>  
       </profile>  
<profiles>  
```

 

**使用标准的maven目录file进行管理profiles**

src/main/java/filters中的文件如下：
aaa.properties

jdbc.url=aaajdbc:mysql://192.168.120.220:3306/testdb?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull jdbc.username=aaatestuser jdbc.password=aaa123456

```ruby
jdbc.url=aaajdbc:mysql://192.168.120.220:3306/testdb?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull
jdbc.username=aaatestuser
jdbc.password=aaa123456
```

bbb.properties

```ruby
jdbc.url=bbbjdbc:mysql://192.168.120.220:3306/testdb?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull
jdbc.username=bbbtestuser
jdbc.password=bbb123456
```

**file管理配置文件例子1：**

pom.xml文件的内容：

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.lgy</groupId>
    <artifactId>idea-maven-introduce</artifactId>
    <packaging>war</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>idea-maven-introduce Maven Webapp</name>
    <url>http://maven.apache.org</url>
 
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.10</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
 
 
 
    <build>
        <finalName>idea-maven-introduce</finalName>
 
        <filters> <!-- 指定使用的 filter -->
            <filter>src/main/filters/aaa.properties</filter>
        </filters>
 
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <filtering>true</filtering>
            </resource>
        </resources>
    </build>
</project>
```

此时去掉了profiles，直接用filters指定要使用的filter，此时，resources中要用到的值都会从aaa.properties.

```ruby
#dataSource configure
#jdbc.connection.url=jdbc:mysql://localhost:3306/test
#jdbc.connection.username=root
#jdbc.connection.password=123456
 
 
jdbc.connection.url=aaajdbc:mysql://192.168.120.220:3306/testdb?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull
jdbc.connection.username=aaatestuser
jdbc.connection.password=aaa123456
```

**file管理配置文件例子2：**

结合profiles的激活机制能更好的使用filers目录中的内容,pom.xml中的内容如下：

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.lgy</groupId>
    <artifactId>idea-maven-introduce</artifactId>
    <packaging>war</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>idea-maven-introduce Maven Webapp</name>
    <url>http://maven.apache.org</url>
 
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.10</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
 
 
    <profiles>
        <!-- 开发/测试环境，默认激活 -->
        <profile>
            <id>test</id>
            <properties>
                <dev.name>aaa</dev.name>
            </properties>
 
            <activation>
                <!--默认启用的是dev环境配置 -->
                <activeByDefault>true</activeByDefault>
            </activation>
        </profile>
 
        <!-- 生产环境 -->
        <profile>
            <id>product</id>
            <properties>
                <dev.name>bbb</dev.name>
            </properties>
        </profile>
    </profiles>
 
    <build>
        <finalName>idea-maven-introduce</finalName>
 
        <filters> <!-- 动态指定使用的 filter -->
            <filter>src/main/filters/${dev.name}.properties</filter>
        </filters>
 
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <filtering>true</filtering>
            </resource>
        </resources>
    </build>
</project>
```

==**此时默认的激活方式就是profiles中id为test，filters就会去寻找aaa.peroperties中的对应的属性值给resources中的资源文件进行使用！**==

## 总结

有关知识点的内容讲解有如下：
\- maven profiles标签的使用
\- resources 资源标签的使用
\- filters 标签的使用

==**配置不同环境配置环境有两种方式：**==

==**1、通过指定激活<profile>环境，动态引入特定配置文件资源<resource>**==

==**2、通过指定激活<profile>环境，动态引入特定配置文件（application-dev.properties或application-test.properties）里的属性<filter>，该xxx.propertise里配置了需要动态切换的属性如jdbc配置等**==





# [maven标签和概念简介](https://blog.csdn.net/qq_25220289/article/details/117700704)

子项目使用父项目依赖时，正常情况子项目应该继承父项目依赖，无需使用版本号

## maven基础标签

<sourceDirectory/>
该元素设置了项目源码目录，当构建项目的时候，构建系统会编译目录里的源码。该路径是相对于pom.xml的相对路径。

<outputDirectory/>
被编译过的应用程序class文件存放的目录。

<resources>
这个元素描述了项目相关的所有资源路径列表，例如和项目相关的属性文件，这些资源被包含在最终的打包文件里。

<targetPath/>

描述了资源的目标路径。该路径相对target/classes目录（例如${project.build.outputDirectory}）。举个例 子，如果你想资源在特定的包里(org.apache.maven.messages)，你就必须该元素设置为org/apache/maven /messages。然而，如果你只是想把资源放到源码目录结构里，就不需要该配置。

<filtering/>

是否使用参数值代替参数名。参数值取自properties元素或者文件里配置的属性，文件在filters元素里列出。

<directory />

描述存放资源的目录，该路径相对POM路径

<includes />

包含的模式列表，例如**/*.xml

<excludes/>

排除的模式列表，例如**/*.xml

<finalname>abc</finalname>

设定指定的名字作为打包的包名，如abc.jar或abc.war，如果没有设置，打包后的包名-----artifactId与version拼接的结果，artifactId-version.jar

<resources/>
<directory/>
构建产生的所有文件存放的目录

<filters/>
当filtering开关打开时，使用到的过滤器属性文件列表

<plugin>
使用的插件列表

<inherited/>

任何配置是否被传播到子项目

</plugin>
<profile>
在列的项目构建profile，如果被激活，会修改构建处理,根据环境参数或命令行参数激活某个构建处理

<id />

构建配置的唯一标识符。即用于命令行激活，也用于在继承时合并具有相同标识符的profile。

<activation/>

自动触发profile的条件逻辑。Activation是profile的开启钥匙。profile的力量来自于它 能够在某些特定的环境中自动使用某些特定的值；这些环境通过activation元素指定。activation元素并不是激活profile的唯一方式

<property/>

如果Maven检测到某一个属性（其值可以在POM中通过${名称}引用），其拥有对应的名称和值，Profile就会被激活。如果值 字段是空的，那么存在属性名称字段就会激活profile，否则按区分大小写方式匹配属性值字段

<profile/>
<modules/>
模块（有时称作子项目） 被构建成项目的一部分。列出的每个模块元素是指向该模块的目录的相对路径

<repository/>
包含需要连接到远程仓库的信息

<pluginRepositories/>
发现插件的远程仓库列表，这些插件用于构建和报表

<dependency>
该元素描述了项目相关的依赖

<type/>

依赖类型，默认类型是jar。它通常表示依赖的文件的扩展名，但也有例外。一个类型可以被映射成另外一个扩展名或分类器。类型经常和使用的打包方式对应。尽管这也有例外。一些类型的例子：jar，war，ejb-client和test-jar。如果设置extensions为 true，就可以在 plugin里定义新的类型。

<classifier/>

依赖的分类器。分类器可以区分属于同一个POM，但不同构建方式的构件。分类器名被附加到文件名的版本号后面。例如，如果你想要构建两个单独的构件成 JAR，一个使用Java 1.4编译器，另一个使用Java 6编译器，你就可以使用分类器来生成两个单独的JAR构件。

<scope/>

依赖范围。在项目发布过程中，帮助决定哪些构件被包括进来。
- compile ：默认范围，用于编译

- provided：类似于编译，但支持你期待jdk或者容器提供，类似于classpath

- runtime: 在执行时需要使用

- test: 用于test任务时使用

- system: 需要外在提供相应的元素。通过systemPath来取得

- systemPath: 仅用于范围为system。提供相应的路径

- optional: 当项目自身被依赖时，标注依赖是否传递。用于连续依赖时使用

<dependency/>
<dependencyManagement/>
继承自该项目的所有子项目的默认依赖信息。这部分的依赖信息不会被立即解析,而是当子项目声明一个依赖（必须描述group ID和 artifactID信息），如果group ID和artifact ID以外的一些信息没有描述，则通过group ID和artifact ID 匹配到这里的依赖，并使用这里的依赖信息。

<distributionManagement/>
项目分发信息，在执行mvn deploy后表示要发布的位置。有了这些信息就可以把网站部署到远程服务器或者把构件部署到远程仓库。

web项目tomcat 插件的配置

```xml
<!-- tomcat7 -->
 <plugin>
     <groupId>org.apache.tomcat.maven</groupId>
     <artifactId>tomcat7-maven-plugin</artifactId>
     <version>2.2</version>
     <configuration>
         <uriEncoding>UTF-8</uriEncoding>
     </configuration>
 </plugin>
```

```
tomcat7:run -Dmaven.tomcat.port=9011 -P qas
```

> 如果在配置上面tomcat7插件时指定了端口好，那么命令中`-Dmaven.tomcat.port=9011` 则无效，配置中优先级高于命令参数优先级。

## maven生命周期

当一个阶段通过 Maven 命令调用时，例如 mvn compile，只有该阶段之前以及包括该阶段在内的所有阶段会被执行。

Maven 有以下三个标准的生命周期：

1. clean：项目清理的处理
2. default(或 build)：项目部署的处理
3. site：项目站点文档创建的处理



clean

项目清理

validate

校验项目是否正确并且所有必要的信息可以完成项目的构建过程。

compile

编译项目的源代码。

test
使用合适的单元测试框架运行测试（Juint是其中之一）。

**package**

**将编译后的代码打包成可分发格式的文件，比如JAR、WAR或者EAR文件。但是命令本身不区分是打jar还是war，需在pom里指定<packaging>war</packaging>打war**

verify

运行任意的检查来验证项目包有效且达到质量标准。

install

安装项目包到本地仓库，这样项目包可以用作其他本地项目的依赖。

deploy

将最终的项目包复制到远程仓库中与其他开发者和项目共享。

> maven常用打包命令
> 1、mvn compile 编译,将Java源程序编译成class字节码文件。
> 2、mvn test 测试,并生成测试报告
> 3、mvn clean将以前编译得到的旧的class字节码文件删除
> 4、mvn pakage 打包,动态 web工程打war包, Java工程打jar包。
> 5、mvn install将项目生成jar包放在仓库中,以便别的模块调用
> 6、mvn clean install -Dmaven. test. skip=true 抛弃测试用例打包



## maven构建配置文件

构建配置文件是一系列的配置项的值，可以用来设置或者覆盖 Maven 构建默认值。**==配置文件在 pom.xml 文件中使用 <activeProfiles> 或者 <profiles> 元素指定，并且可以通过各种方式触发。==**配置文件在构建时修改 POM，并且用来给参数设定不同的目标环境（比如说，开发（Development）、测试（Testing）和生产环境（Production）中数据库服务器的地址）。

### 配置文件激活

使用命令控制台输入显式激活。
通过 maven 设置。
基于环境变量（用户或者系统变量）。
操作系统设置（比如说，Windows系列）。
文件的存在或者缺失。

### Maven 插件

我们在输入 mvn 命令的时候 比如 mvn clean，clean 对应的就是 Clean 生命周期中的 clean 阶段。但是 clean 的具体操作是由 maven-clean-plugin 来实现的。

所以说 Maven 生命周期的每一个阶段的具体实现都是由 Maven 插件实现的。

Maven 实际上是一个依赖插件执行的框架，每个任务实际上是由插件完成。Maven 插件通常被用来：

创建 jar 文件（mvn clean install打jar包）
创建 war 文件（mvn clean package打war包，因为war包不可以安装）
编译代码文件
代码单元测试
创建工程文档
创建工程报告

### Maven 快照

快照是一种特殊的版本，指定了某个当前的开发进度的副本。不同于常规的版本，Maven 每次构建都会在远程仓库中检查新的快照。 现在 data-service 团队会每次发布更新代码的快照到仓库中，比如说 data-service:1.0-SNAPSHOT 来替代旧的快照 jar 包。



# [Maven打包避免测试](https://blog.csdn.net/dymkkj/article/details/117334579)

避免mvn打包时，编译测试用例类和执行测试用例
-DskipTest，编译测试用例类，但不执行测试用例，生成相应的class文件至target/test-classes下

> mvn clean package -DskipTest

-Dmaven.test.skip=true,既不编译测试用例，又执行不测试用例类

> mvn clean package -Dmaven.test.skip=true 

或者

```xml
<plugin>  
    <groupId>org.apache.maven.plugin</groupId>  
    <artifactId>maven-compiler-plugin</artifactId>  
    <version>2.1</version>  
    <configuration>  
        <skip>true</skip>  
    </configuration>  
</plugin>  
<plugin>  
    <groupId>org.apache.maven.plugins</groupId>  
    <artifactId>maven-surefire-plugin</artifactId>  
    <version>2.5</version>  
    <configuration>  
        <skip>true</skip>  
    </configuration>  
</plugin>
```

只跳过执行测试用例；如果没时间修改单元测试的bug，或者单元测试编译错误，不要用这个，用跳过所有测试相关编译

> mvn package -DskipTests

或者

```xml
<plugin>  
    <groupId>org.apache.maven.plugins</groupId>  
    <artifactId>maven-surefire-plugin</artifactId>  
    <version>2.5</version>  
    <configuration>  
        <skipTests>true</skipTests>  
    </configuration>  
</plugin>
```

