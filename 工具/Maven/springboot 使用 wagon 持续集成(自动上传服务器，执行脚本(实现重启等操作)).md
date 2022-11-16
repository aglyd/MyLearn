# [springboot 使用 wagon 持续集成(自动上传服务器，执行脚本(实现重启等操作))，不限于springboot](https://blog.51cto.com/u_15082395/4400797)

1 应用背景
 对于大型的项目，现在有很多CI/CD 持续集成/部署方式。如下图:



但是对于小型项目来说，其实有时候用不到这么多东西。项目的体量、以及更新迭代、维护等方面，都不至于做如此自动化的流程。杀鸡焉用宰牛刀嘛。

 不知道大家有没有遇到过这样的场景: 总是要用maven打包好项目，再用SSH 连接Linux服务器 ，再上传jar包，然后使用shell命令启动java应用。

为了避免这一重复操作，为大家介绍一款maven插件。可以一键上传、部署运行java项目。



2、wagon-maven-plugin 插件自动打包部署jar包

2.1 配置Linux服务器用户名和密码
 在maven 的 settings.xml中添加:

```xml
<!--这一步可以省略：用户名密码可以手动输入;也可以在下面配置服务器url的时候加上用户名和密码   -->
<servers>
<server>
<id>linux-server-dev</id>
<username>root</username>
<password>123456</password>
</server>
</servers>
```

2.2 添加依赖

```
 <dependency>
<groupId>org.codehaus.mojo</groupId>
<artifactId>wagon-maven-plugin</artifactId>
<version>2.0.0</version>
</dependency>
```

2.3 首先实现打包后，自动上传jar包 编辑pom.xml中的 标签

```
<build>
<extensions>
<extension>
<groupId>org.apache.maven.wagon</groupId>
<artifactId>wagon-ssh</artifactId>
<version>2.8</version>
</extension>
</extensions>
<plugins>
<plugin>
<groupId>org.codehaus.mojo</groupId>
<artifactId>wagon-maven-plugin</artifactId>
<version>1.0</version>
<configuration>
<!-- serverId即在settings.xml中配置的service的id -->
<serverId>linux-server-dev</serverId>
<!-- 要上传到服务器的文件，一般来说是jar或者war包 -->
<fromFile>target/project_name.jar</fromFile>
<!-- 配置服务器的地址以及文件上传的目录。 -->
<!-- 如果2.1 serverId配置省略了没写，可以这么写：
scp://user:password@192.168.1.1/home/project_name/  -->
<!-- 注意上传的路径中不能带有横杠'-'，例如/home/project-name ，否则会导致无法执行远程shell命令 -->
<url>scp://192.168.1.1/home/project_name/</url>
</configuration>
</plugin>
</plugins>
</build>
```

配置完成后，在cmd终端 cd到 项目pom.xml文件同一级， 运行命令：mvn clean package wagon:upload-single 打包并上传。

2.4 实现自动启动/重启java应用
编辑pom.xml中的 标签：

```
<build>
<extensions>
<extension>
<groupId>org.apache.maven.wagon</groupId>
<artifactId>wagon-ssh</artifactId>
<version>2.8</version>
</extension>
</extensions>
<plugins>
<plugin>
<groupId>org.codehaus.mojo</groupId>
<artifactId>wagon-maven-plugin</artifactId>
<version>1.0</version>
<configuration>
<serverId>linux-server-dev</serverId>
<fromFile>target/project_name.jar</fromFile>
<url>scp://192.168.20.128/home/project_name/</url>
<commands>
<!-- 启动/重启jar包的shell脚本，需要自己编写，放在/home/project_name 目录下即可-->
<command>sh ./restart.sh</command>
<!-- 也可以直接执行命令-->
<command><![CDATA[nohup java -jar /home/project_name/xx.jar &]]><command>
</commands>
<!-- 显示运行命令的输出结果 -->
<displayCommandOutputs>true</displayCommandOutputs>
</configuration>
</plugin>
</plugins>
</build>
```

运行命令：mvn clean package wagon:upload-single wagon:sshexec

打包、上传、执行shell脚本或者命令

2.5 maven install 一键打包、部署
如果觉得每次输入 mvn clean package wagon:upload-single wagon:sshexec 还是很麻烦的话。可以配置execution

```xml
<build>
<extensions>
<extension>
<groupId>org.apache.maven.wagon</groupId>
<artifactId>wagon-ssh</artifactId>
<version>2.8</version>
</extension>
</extensions>
<plugins>
<plugin>
<groupId>org.codehaus.mojo</groupId>
<artifactId>wagon-maven-plugin</artifactId>
<version>1.0</version>
<executions>
<execution>
<id>upload-deploy</id>
<!-- 运行package打包的同时运行upload-single和sshexec -->
<phase>package</phase>
<goals>
<goal>upload-single</goal>
<goal>sshexec</goal>
</goals>
<configuration>
<serverId>linux-server-dev</serverId>
<fromFile>target/project_name.jar</fromFile>
<url>scp://192.168.20.128/home/project_name/</url>
<commands>
<!-- 启动/重启jar包的shell脚本，需要自己编写，放在/home/project_name 目录下即可-->
<command>sh ./restart.sh</command>
<!-- 也可以直接执行命令-->
<command><![CDATA[nohup java -jar /home/project_name/xx.jar &]]><command>
</commands>
<!-- 显示运行命令的输出结果 -->
<displayCommandOutputs>true</displayCommandOutputs>
</configuration>
</execution>
</executions>
</plugin>
</plugins>
</build>
```

配置完后mvn clean package 即可 一键打包部署。

我用的是spring tools suite (其实就是eclipse )开发，右键项目-> Run as -> maven install 就直接一键 打包部署了。因为maven install 里包含了 package 这个命令。关于shell

3.后记
3.1使用的时候遇到了一个小问题
就是总是让我输入服务器密码。提示：

Keyboard interactive required, supplied password is ignored

交互式面板，提供的密码被忽略。google了一下。

在 StackOverflow找到了一篇问答。



vi /etc/ssh/sshd_config



service sshd restart 修改之后重启服务

3.2 shell命令参考
 这里提供 杀掉 老的服务启动进程命令。jar包的启动命令自己添加。

 如果有启动进程才执行kill ,这样判断的好处是，如果没有服务运行，执行kill脚本，不会再提示参数不够了。

```shell
#killold.sh
if [[ -n $(ps -ef | grep 项目的部分名称* | grep -v grep ) ]]; then
echo  'kill old process'
ps -ef | grep 项目的部分名称* | grep -v grep | awk '{print $2}' | xargs kill -9
fi
```

以下我的具体配置。 为什么java -jar 启动命令 没有和 killold.sh 写在同一个脚本呢？ 一开始是写在一起的叫 restart.sh 不过新的服务总是启动不了。就拆开写了。读者可以自己试一试。

![springboot 使用 wagon 持续集成(自动上传服务器，执行脚本(实现重启等操作))，不限于springboot_wagon_04](https://s2.51cto.com/images/blog/202108/02/1983d04be958f9e087624eb7f4993332.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_30,g_se,x_10,y_10,shadow_20,type_ZmFuZ3poZW5naGVpdGk=/format,webp/resize,m_fixed,w_750)