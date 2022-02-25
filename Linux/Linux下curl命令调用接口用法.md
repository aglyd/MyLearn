# 一、[curl常用的命令行工具的用法](https://zhuanlan.zhihu.com/p/346026915)

**curl** 是常用的命令行工具，用来请求 Web 服务器。它的名字就是客户端（client）的 URL 工具的意思。

它的功能非常强大，命令行参数多达几十种。如果熟练的话，完全可以取代 Postman 这一类的图形界面工具。

本文介绍它的主要命令行参数，作为日常的参考，方便查阅。内容主要翻译自《curl cookbook》。为了节约篇幅，下面的例子不包括运行时的输出，初学者可以先看我以前写的《curl 初学者教程》。

不带有任何参数时，curl 就是发出 GET 请求。

```less
$ curl https://www.example.com
```

上面命令向http://www.example.com发出 GET 请求，服务器返回的内容会在命令行输出。

-A

-A参数指定客户端的用户代理标头，即User-Agent。curl 的默认用户代理字符串是curl/[version]。

```less
$ curl -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36' https://google.com
```

上面命令将User-Agent改成 Chrome 浏览器。

```less
$ curl -A '' https://google.com
```

上面命令会移除User-Agent标头。

也可以通过-H参数直接指定标头，更改User-Agent。

```less
$ curl -H 'User-Agent: php/1.0' https://google.com
```

 多个参数在请求头中存储的get接口

```less
curl -H "参数:值" -H "参数:值" 地址
```

-b

-b参数用来向服务器发送 Cookie。

```less
$ curl -b 'foo=bar' https://google.com
```

上面命令会生成一个标头Cookie: foo=bar，向服务器发送一个名为foo、值为bar的 Cookie。

```less
$ curl -b 'foo1=bar;foo2=bar2' https://google.com
```

上面命令发送两个 Cookie。

```less
$ curl -b cookies.txt https://www.google.com
```

上面命令读取本地文件cookies.txt，里面是服务器设置的 Cookie（参见-c参数），将其发送到服务器。

-c

-c参数将服务器设置的 Cookie 写入一个文件。

```less
$ curl -c cookies.txt https://www.google.com
```

上面命令将服务器的 HTTP 回应所设置 Cookie 写入文本文件cookies.txt。

-d

-d参数用于发送 POST 请求的数据体。

```less
curl -H "Content-Type: application/json" -X POST -d '{"参数名":"值","参数名":"值"}' "地址"
```

```less
$ curl -d'login=emma＆password=123'-X POST https://google.com/login# 或者
$ curl -d 'login=emma' -d 'password=123' -X POST  https://google.com/login
```

使用-d参数以后，HTTP 请求会自动加上标头Content-Type : application/x-www-form-urlencoded。并且会自动将请求转为 POST 方法，因此可以省略-X POST。

-d参数可以读取本地文本文件的数据，向服务器发送。

```less
$ curl -d '@data.txt' https://google.com/login
```

上面命令读取data.txt文件的内容，作为数据体向服务器发送。

–data-urlencode

–data-urlencode参数等同于-d，发送 POST 请求的数据体，区别在于会自动将发送的数据进行 URL 编码。

```less
$ curl --data-urlencode 'comment=hello world' https://google.com/login
```

上面代码中，发送的数据hello world之间有一个空格，需要进行 URL 编码。

-e

-e参数用来设置 HTTP 的标头Referer，表示请求的来源。

```less
$ curl -e 'https://google.com?q=example' https://www.example.com
```

上面命令将Referer标头设为[https://google.com](https://link.zhihu.com/?target=https%3A//google.com)?q=example。

-H参数可以通过直接添加标头Referer，达到同样效果。

```text
curl -H 'Referer: https://google.com?q=example' https://www.example.com
```

-F

-F参数用来向服务器上传二进制文件。

```text
$ curl -F 'file=@photo.png' https://google.com/profile
```

上面命令会给 HTTP 请求加上标头Content-Type: multipart/form-data，然后将文件photo.png作为file字段上传。

-F参数可以指定 MIME 类型。

```text
$ curl -F 'file=@photo.png;type=image/png' https://google.com/profile
```

上面命令指定 MIME 类型为image/png，否则 curl 会把 MIME 类型设为application/octet-stream。

-F参数也可以指定文件名。

```text
$ curl -F 'file=@photo.png;filename=me.png' https://google.com/profile
```

上面命令中，原始文件名为photo.png，但是服务器接收到的文件名为me.png。

-G

-G参数用来构造 URL 的查询字符串。

```text
$ curl -G -d 'q=kitties' -d 'count=20' https://google.com/search
```

上面命令会发出一个 GET 请求，实际请求的 URL 为[https://google.com/search?q=kitties&count=20](https://link.zhihu.com/?target=https%3A//google.com/search%3Fq%3Dkitties%26count%3D20)。如果省略–G，会发出一个 POST 请求。

如果数据需要 URL 编码，可以结合–data–urlencode参数。

```text
$ curl -G --data-urlencode 'comment=hello world' https://www.example.com
```

-H

-H参数添加 HTTP 请求的标头。

```text
$ curl -H 'Accept-Language: en-US' https://google.com
```

上面命令添加 HTTP 标头Accept-Language: en-US。

```text
$ curl -H 'Accept-Language: en-US' -H 'Secret-Message: xyzzy' https://google.com
```

上面命令添加两个 HTTP 标头。

```text
$ curl -d '{"login": "emma", "pass": "123"}' -H 'Content-Type: application/json' https://google.com/login
```

上面命令添加 HTTP 请求的标头是Content-Type: application/json，然后用-d参数发送 JSON 数据。

-i

-i参数打印出服务器回应的 HTTP 标头。

```text
$ curl -i https://www.example.com
```

上面命令收到服务器回应后，先输出服务器回应的标头，然后空一行，再输出网页的源码。

-I

-I参数向服务器发出 HEAD 请求，然会将服务器返回的 HTTP 标头打印出来。

```text
$ curl -I https://www.example.com
```

上面命令输出服务器对 HEAD 请求的回应。

–head参数等同于-I。

```text
$ curl --head https://www.example.com
```

-k

-k参数指定跳过 SSL 检测。

```text
$ curl -k https://www.example.com
```

上面命令不会检查服务器的 SSL 证书是否正确。

-L

-L参数会让 HTTP 请求跟随服务器的重定向。curl 默认不跟随重定向。

```text
$ curl -L -d 'tweet=hi' https://api.twitter.com/tweet
```

–limit-rate

–limit-rate用来限制 HTTP 请求和回应的带宽，模拟慢网速的环境。

```text
$ curl --limit-rate 200k https://google.com
```

上面命令将带宽限制在每秒 200K 字节。

-o

-o参数将服务器的回应保存成文件，等同于wget命令。

```text
$ curl -o example.html https://www.example.com
```

上面命令将http://www.example.com保存成example.html。

-O

-O参数将服务器回应保存成文件，并将 URL 的最后部分当作文件名。

```text
$ curl -O https://www.example.com/foo/bar.html
```

上面命令将服务器回应保存成文件，文件名为bar.html。

-s

-s参数将不输出错误和进度信息。

```text
$ curl -s https://www.example.com
```

上面命令一旦发生错误，不会显示错误信息。不发生错误的话，会正常显示运行结果。

如果想让 curl 不产生任何输出，可以使用下面的命令。

```text
$ curl -s -o /dev/null https://google.com
```

-S

-S参数指定只输出错误信息，通常与-s一起使用。

```text
$ curl -S -s -o /dev/null https://google.com
```

上面命令没有任何输出，除非发生错误。

-u

-u参数用来设置服务器认证的用户名和密码。

```text
$ curl -u 'bob:12345' https://google.com/login
```

上面命令设置用户名为bob，密码为12345，然后将其转为 HTTP 标头Authorization: Basic Ym9iOjEyMzQ1。

curl 能够识别 URL 里面的用户名和密码。

```text
$ curl https://bob:12345@google.com/login
```

上面命令能够识别 URL 里面的用户名和密码，将其转为上个例子里面的 HTTP 标头。

```text
$ curl -u 'bob' https://google.com/login
```

上面命令只设置了用户名，执行后，curl 会提示用户输入密码。

-v

-v参数输出通信的整个过程，用于调试。

```text
$ curl -v https://www.example.com
```

–trace参数也可以用于调试，还会输出原始的二进制数据。

```text
$ curl --trace - https://www.example.com
```

-x

-x参数指定 HTTP 请求的代理。

```text
$ curl -x socks5://james:cats@myproxy.com:8080 https://www.example.com
```

上面命令指定 HTTP 请求通过[http://myproxy.com:8080](https://link.zhihu.com/?target=http%3A//myproxy.com%3A8080)的 socks5 代理发出。

如果没有指定代理协议，默认为 HTTP。

```text
$ curl -x james:cats@myproxy.com:8080 https://www.example.com
```

上面命令中，请求的代理使用 HTTP 协议。

-X

-X参数指定 HTTP 请求的方法。

```text
$ curl -X POST https://www.example.com
```



----

# 二、[【curl】Linux下命令行curl详解](https://www.cnblogs.com/chenxiaomeng/p/10470481.html)

在Linux中curl是一个利用URL规则在命令行下工作的文件传输工具，可以说是一款很强大的http命令行工具。它支持文件的上传和下载，是综合传输工具，但按传统，习惯称url为下载工具。

```
语法：# curl [option] [url]
```

```less
-A/--user-agent <string>              设置用户代理发送给服务器
-b/--cookie <name=string/file>    cookie字符串或文件读取位置
-c/--cookie-jar <file>                    操作结束后把cookie写入到这个文件中
-C/--continue-at <offset>            断点续转
-D/--dump-header <file>              把header信息写入到该文件中
-e/--referer                                  来源网址
-f/--fail                                          连接失败时不显示http错误
-o/--output                                  把输出写到该文件中
-O/--remote-name                      把输出写到该文件中，保留远程文件的文件名
-r/--range <range>                      检索来自HTTP/1.1或FTP服务器字节范围
-s/--silent                                    静音模式。不输出任何东西
-T/--upload-file <file>                  上传文件
-u/--user <user[:password]>      设置服务器的用户和密码
-w/--write-out [format]                什么输出完成后
-x/--proxy <host[:port]>              在给定的端口上使用HTTP代理
-#/--progress-bar                        进度条显示当前的传送状态





-a/--append 上传文件时，附加到目标文件
--anyauth 可以使用“任何”身份验证方法
--basic 使用HTTP基本验证
-B/--use-ascii 使用ASCII文本传输
-d/--data <data> HTTP POST方式传送数据
--data-ascii <data> 以ascii的方式post数据
--data-binary <data> 以二进制的方式post数据
--negotiate 使用HTTP身份验证
--digest 使用数字身份验证
--disable-eprt 禁止使用EPRT或LPRT
--disable-epsv 禁止使用EPSV
--egd-file <file> 为随机数据(SSL)设置EGD socket路径
--tcp-nodelay 使用TCP_NODELAY选项
-E/--cert <cert[:passwd]> 客户端证书文件和密码 (SSL)
--cert-type <type> 证书文件类型 (DER/PEM/ENG) (SSL)
--key <key> 私钥文件名 (SSL)
--key-type <type> 私钥文件类型 (DER/PEM/ENG) (SSL)
--pass <pass> 私钥密码 (SSL)
--engine <eng> 加密引擎使用 (SSL). "--engine list" for list
--cacert <file> CA证书 (SSL)
--capath <directory> CA目 (made using c_rehash) to verify peer against (SSL)
--ciphers <list> SSL密码
--compressed 要求返回是压缩的形势 (using deflate or gzip)
--connect-timeout <seconds> 设置最大请求时间
--create-dirs 建立本地目录的目录层次结构
--crlf 上传是把LF转变成CRLF
--ftp-create-dirs 如果远程目录不存在，创建远程目录
--ftp-method [multicwd/nocwd/singlecwd] 控制CWD的使用
--ftp-pasv 使用 PASV/EPSV 代替端口
--ftp-skip-pasv-ip 使用PASV的时候,忽略该IP地址
--ftp-ssl 尝试用 SSL/TLS 来进行ftp数据传输
--ftp-ssl-reqd 要求用 SSL/TLS 来进行ftp数据传输
-F/--form <name=content> 模拟http表单提交数据
-form-string <name=string> 模拟http表单提交数据
-g/--globoff 禁用网址序列和范围使用{}和[]
-G/--get 以get的方式来发送数据
-h/--help 帮助
-H/--header <line> 自定义头信息传递给服务器
--ignore-content-length 忽略的HTTP头信息的长度
-i/--include 输出时包括protocol头信息
-I/--head 只显示文档信息
-j/--junk-session-cookies 读取文件时忽略session cookie
--interface <interface> 使用指定网络接口/地址
--krb4 <level> 使用指定安全级别的krb4
-k/--insecure 允许不使用证书到SSL站点
-K/--config 指定的配置文件读取
-l/--list-only 列出ftp目录下的文件名称
--limit-rate <rate> 设置传输速度
--local-port<NUM> 强制使用本地端口号
-m/--max-time <seconds> 设置最大传输时间
--max-redirs <num> 设置最大读取的目录数
--max-filesize <bytes> 设置最大下载的文件总量
-M/--manual 显示全手动
-n/--netrc 从netrc文件中读取用户名和密码
--netrc-optional 使用 .netrc 或者 URL来覆盖-n
--ntlm 使用 HTTP NTLM 身份验证
-N/--no-buffer 禁用缓冲输出
-p/--proxytunnel 使用HTTP代理
--proxy-anyauth 选择任一代理身份验证方法
--proxy-basic 在代理上使用基本身份验证
--proxy-digest 在代理上使用数字身份验证
--proxy-ntlm 在代理上使用ntlm身份验证
-P/--ftp-port <address> 使用端口地址，而不是使用PASV
-Q/--quote <cmd> 文件传输前，发送命令到服务器
--range-file 读取（SSL）的随机文件
-R/--remote-time 在本地生成文件时，保留远程文件时间
--retry <num> 传输出现问题时，重试的次数
--retry-delay <seconds> 传输出现问题时，设置重试间隔时间
--retry-max-time <seconds> 传输出现问题时，设置最大重试时间
-S/--show-error 显示错误
--socks4 <host[:port]> 用socks4代理给定主机和端口
--socks5 <host[:port]> 用socks5代理给定主机和端口
-t/--telnet-option <OPT=val> Telnet选项设置
--trace <file> 对指定文件进行debug
--trace-ascii <file> Like --跟踪但没有hex输出
--trace-time 跟踪/详细输出时，添加时间戳
--url <URL> Spet URL to work with
-U/--proxy-user <user[:password]> 设置代理用户名和密码
-V/--version 显示版本信息
-X/--request <command> 指定什么命令
-y/--speed-time 放弃限速所要的时间。默认为30
-Y/--speed-limit 停止传输速度的限制，速度时间'秒
-z/--time-cond 传送时间设置
-0/--http1.0 使用HTTP 1.0
-1/--tlsv1 使用TLSv1（SSL）
-2/--sslv2 使用SSLv2的（SSL）
-3/--sslv3 使用的SSLv3（SSL）
--3p-quote like -Q for the source URL for 3rd party transfer
--3p-url 使用url，进行第三方传送
--3p-user 使用用户名和密码，进行第三方传送
-4/--ipv4 使用IP4
-6/--ipv6 使用IP6

 

 

 

 -M/--manual	 显示全手动
 -n/--netrc	 从netrc文件中读取用户名和密码
 --netrc-optional	 使用 .netrc 或者 URL来覆盖-n
 --ntlm	 使用 HTTP NTLM 身份验证
 -N/--no-buffer	 禁用缓冲输出
 -o/--output	 把输出写到该文件中
 -O/--remote-name	 把输出写到该文件中，保留远程文件的文件名
 -p/--proxytunnel	 使用HTTP代理
 --proxy-anyauth	 选择任一代理身份验证方法
 --proxy-basic	 在代理上使用基本身份验证
 --proxy-digest	 在代理上使用数字身份验证
 --proxy-ntlm	 在代理上使用ntlm身份验证
 -P/--ftp-port <address>	 使用端口地址，而不是使用PASV
 -Q/--quote <cmd>	 文件传输前，发送命令到服务器
 -r/--range <range>	 检索来自HTTP/1.1或FTP服务器字节范围
 --range-file  	 读取（SSL）的随机文件
 -R/--remote-time	 在本地生成文件时，保留远程文件时间
 --retry <num>	 传输出现问题时，重试的次数
 --retry-delay <seconds>	 传输出现问题时，设置重试间隔时间
 --retry-max-time <seconds>	 传输出现问题时，设置最大重试时间
 -s/--silent	 静音模式。不输出任何东西
 -S/--show-error	 显示错误
 --socks4 <host[:port]>	 用socks4代理给定主机和端口
 --socks5 <host[:port]>	 用socks5代理给定主机和端口
 -t/--telnet-option <OPT=val>	 Telnet选项设置
 --trace <file>	 对指定文件进行debug
 --trace-ascii <file> Like	 跟踪但没有hex输出
 --trace-time	 跟踪/详细输出时，添加时间戳
 -T/--upload-file <file>	 上传文件
 --url <URL>	 Spet URL to work with
 -u/--user <user[:password]>	 设置服务器的用户和密码
 -U/--proxy-user <user[:password]>	 设置代理用户名和密码
 -V/--version	 显示版本信息
 -w/--write-out [format]	 什么输出完成后
 -x/--proxy <host[:port]>	 在给定的端口上使用HTTP代理
 -X/--request <command>	 指定什么命令
 -y/--speed-time	 放弃限速所要的时间。默认为30
 -Y/--speed-limit	 停止传输速度的限制，速度时间'秒
 -z/--time-cond	 传送时间设置
 -0/--http1.0	 使用HTTP 1.0
 -1/--tlsv1	 使用TLSv1（SSL）
 -2/--sslv2	 使用SSLv2的（SSL）
 -3/--sslv3	 使用的SSLv3（SSL）
 --3p-quote	  like -Q for the source URL for 3rd party transfer
 --3p-url	 使用url，进行第三方传送
 --3p-user	 使用用户名和密码，进行第三方传送
 -4/--ipv4	 使用IP4
 -6/--ipv6	 使用IP6
 -#/--progress-bar	 用进度条显示当前的传送状态
```

基本用法

例子：

## **1.测试是否可以达到一个网站，可用于client建立tcp连接或其他连接时候的测试排查网址是否可达**

```
curl http://www.baidu.com
```

执行后，www.linux.com 的html就会显示在屏幕上了
Ps：由于安装linux的时候很多时候是没有安装桌面的，也意味着没有浏览器，因此这个方法也经常用于测试一台服务器是否可以到达一个网站

![img](https://img2018.cnblogs.com/blog/971787/201903/971787-20190304112425785-1272875761.png)

 不可达则则返回结果为空

![img](https://img2018.cnblogs.com/blog/971787/201903/971787-20190304113945858-519427837.png)

 

## **2.保存访问的网页**

2.1:使用linux的重定向功能保存

```
curl http://www.linux.com >> linux.html
```

执行完成后会显示如下界面，显示100%则表示保存成功，0则表示为没有保存内容

![img](https://img2018.cnblogs.com/blog/971787/201903/971787-20190304114408355-581445493.png)

![img](https://img2018.cnblogs.com/blog/971787/201903/971787-20190304114659648-748945867.png)

2.2:可以使用curl的内置option:-o(小写)保存网页，此时页面内容就会存储到home.html的文件中

```
 curl -o home.html  http://www.sina.com.cn 
```

结果和上面一样

2.3，用-O（大写的），后面的url要具体到某个文件，不然抓不下来。我们还可以用正则来抓取东西 

```
curl -O http://www.linux.com/hello.sh
```

## **3.测试网页返回值**

```
# curl -o /dev/null -s -w %{http_code} www.linux.com
```

Ps:在脚本中，这是很常见的测试网站是否正常的用法

## **4.指定proxy服务器以及其端口**

很多时候上网需要用到代理服务器(比如是使用代理服务器上网或者因为使用curl别人网站而被别人屏蔽IP地址的时候)，幸运的是curl通过使用内置option：-x来支持设置代理

```
curl -x 192.168.100.100:1080 http://www.linux.com
curl -i -X POST '{https://1662d8sji1.execute-api.eu-central-1.amazonaws.com/v1/3,"si":"c2826469a40b"}'
```

## **5.cookie**

有些网站是使用cookie来记录session信息。对于chrome这样的浏览器，可以轻易处理cookie信息，但在curl中只要增加相关参数也是可以很容易的处理cookie
5.1:保存http的response里面的cookie信息。内置option:-c（小写）

```
curl -c cookiec.txt http:``//www.linux.com
```

执行后cookie信息就被存到了cookiec.txt里面了

模拟表单信息，模拟登录，保存cookie信息 

```
curl -c ./cookie_c.txt -F log=aaaa -F pwd=****** http:``//blog.51yip.com/wp-login.php　　
```

 

5.2:保存http的response里面的header信息。内置option: -D

```
curl -D cookied.txt http:``//www.linux.com
```

 

```
curl -D ./cookie_D.txt -F log=aaaa -F pwd=****** http:``//blog.51yip.com/wp-login.php
```

执行后cookie信息就被存到了cookied.txt里面了

注意：-c(小写)产生的cookie和-D里面的cookie是不一样的。

 

5.3:使用cookie
很多网站都是通过监视你的cookie信息来判断你是否按规矩访问他们的网站的，因此我们需要使用保存的cookie信息。内置option: -b

```
curl -b cookiec.txt http:``//www.linux.com
```

## **6.模仿浏览器**

```
curl -A ``"Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.0)"` `http:``//www.linux.com
```

这样服务器端就会认为是使用IE8.0去访问的

## **7.伪造referer（盗链）**

很多服务器会检查http访问的referer从而来控制访问。比如：你是先访问首页，然后再访问首页中的邮箱页面，这里访问邮箱的referer地址就是访问首页成功后的页面地址，如果服务器发现对邮箱页面访问的referer地址不是首页的地址，就断定那是个盗连了
curl中内置option：-e可以让我们设定referer

```
curl -e ``"www.linux.com"` `http:``//mail.linux.com
```

这样就会让服务器其以为你是从www.linux.com点击某个链接过来的

这边做一个小科普：referer盗链知识：

referer 是 HTTP 请求 header 的一部分，当浏览器（或者模拟浏览器行为）向`web服务器`发送请求的时候，头信息里有包含referer 。比如我在`www.baidu.com` 链接去访问google，那么点击这个`www.baidu.com` ，它的`header` 信息里就有：

  Referer=http://www.baidu.com

![img](https://img2018.cnblogs.com/blog/971787/201903/971787-20190304134622438-1986545643.png)

同理访问sina也是，这边都不属于盗链情况，因为返回回来的还是baidu的页面

![img](https://img2018.cnblogs.com/blog/971787/201903/971787-20190304134729469-1687503279.png)

 

盗链：就是一个网站中如果没有起页面中所说的信息，例如图片信息，那么它完全可以将这个图片的连接到别的网站。这样没有任何资源的网站利用了别的网站的资源来展示给浏览者，提高了自己的访问量，而大部分浏览者又不会很容易地发现，这样显然，对于那个被利用了资源的网站是不公平的。一些不良网站为了不增加成本而扩充自己站点内容，经常盗用其他网站的链接。一方面损害了被链接网站的合法利益，另一方面又加重了被链接网站的服务器的负担。

所以只要判断当前的refer的上一页是之前的主页就可以断定不是盗链。

如果想对自己的网站进行防盗链保护，则需要针对不同的情况进行区别对待。如果网站服务器用的是**apache**，那么使用apache自带的Url Rewrite功能可以很轻松地防止各种盗链，其原理是检查refer，如果refer的信息来自其他网站则重定向到指定图片或网页上。

如果服务器使用的是**IIS**的话，则需要通过第三方插件来实现防盗链功能了，现在比较常用的一款产品叫做ISAPI_Rewrite，可以实现类似于apache的防盗链功能。另外对于论坛来说还可以使用“登录验证”的方法进行防盗链。

## 8.下载文件

8.1：利用curl下载文件。
\#使用内置option：-o(小写)

```
curl -o dodo1.jpg http:www.linux.com/dodo1.JPG
```

\#使用内置option：-O（大写)

```
curl -O http://www.linux.com/dodo1.JPG
```

这样就会以服务器上的名称保存文件到本地

8.2：循环下载
有时候下载图片可以能是前面的部分名称是一样的，就最后的尾缀名不一样

```
curl -O http://www.linux.com/dodo[1-5].JPG
```

这样就会把dodo1，dodo2，dodo3，dodo4，dodo5全部保存下来

8.3：下载重命名

```
curl -O http:``//www.linux.com/{hello,bb}/dodo[1-5].JPG
```

由于下载的hello与bb中的文件名都是dodo1，dodo2，dodo3，dodo4，dodo5。因此第二次下载的会把第一次下载的覆盖，这样就需要对文件进行重命名。

```
curl -o #1_#2.JPG http:``//www.linux.com/{hello,bb}/dodo[1-5].JPG
```

这样在hello/dodo1.JPG的文件下载下来就会变成hello_dodo1.JPG,其他文件依此类推，从而有效的避免了文件被覆盖

8.4：分块下载
有时候下载的东西会比较大，这个时候我们可以分段下载。使用内置option：-r

```
curl -r 0-100 -o dodo1_part1.JPG http:``//www.linux.com/dodo1.JPG``curl -r 100-200 -o dodo1_part2.JPG http:``//www.linux.com/dodo1.JPG``curl -r 200- -o dodo1_part3.JPG http:``//www.linux.com/dodo1.JPG``cat dodo1_part* > dodo1.JPG
```

这样就可以查看dodo1.JPG的内容了

8.5：通过ftp下载文件
curl可以通过ftp下载文件，curl提供两种从ftp中下载的语法

```
curl -O -u 用户名:密码 ftp:``//www.linux.com/dodo1.JPG``curl -O ftp:``//用户名:密码@www.linux.com/dodo1.JPG
```

8.6：显示下载进度条

```
curl -# -O http:``//www.linux.com/dodo1.JPG
```

8.7：不会显示下载进度信息

```
curl -s -O http:``//www.linux.com/dodo1.JPG
```

## **9.断点续传**

在windows中，我们可以使用迅雷这样的软件进行断点续传。curl可以通过内置option:-C同样可以达到相同的效果
如果在下载dodo1.JPG的过程中突然掉线了，可以使用以下的方式续传

```
curl -C -O http:``//www.linux.com/dodo1.JPG
```

## **10.上传文件**

curl不仅仅可以下载文件，还可以上传文件。通过内置option:-T来实现

```
curl -T dodo1.JPG -u 用户名:密码 ftp:``//www.linux.com/img/
```

这样就向ftp服务器上传了文件dodo1.JPG

## **11.显示抓取错误**

```
curl -f http:``//www.linux.com/error
```

　　

\1. 获取页面内容 
\2. 显示 HTTP 头 
\3. 将链接保存到文件 
\4. 同时下载多个文件 
\5. 使用 -L 跟随链接重定向 
\6. 使用 -A 自定义 User-Agent 
\7. 使用 -H 自定义 header 
\8. 使用 -c 保存 Cookie 
\9. 使用 -b 读取 Cookie 
\10. 使用 -d 发送 POST 请求

## 1. 获取页面内容

当我们不加任何选项使用 curl 时，默认会发送 GET 请求来获取链接内容到标准输出。 
curl [http://www.codebelief.com](http://www.codebelief.com/)

## 2. 显示 HTTP 头

如果我们只想要显示 HTTP 头，而不显示文件内容，可以使用 -I 选项： 
curl -I [http://www.codebelief.com](http://www.codebelief.com/) 
输出为：

```
HTTP/1.1 200 OK
Server: nginx/1.10.3
Date: Thu, 11 May 2017 08:24:45 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 24206
Connection: keep-alive
X-Powered-By: Express
Cache-Control: public, max-age=0
ETag: W/"5e8e-Yw5ZdnVVly9/aEnMX7fVXQ"
Vary: Accept-Encoding
```

也可以同时显示 HTTP 头和文件内容，使用 -i 选项： 
curl -i [http://www.codebelief.com](http://www.codebelief.com/) 
输出为：

```
HTTP/1.1 200 OK
Server: nginx/1.10.3
Date: Thu, 11 May 2017 08:25:46 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 24206
Connection: keep-alive
X-Powered-By: Express
Cache-Control: public, max-age=0
ETag: W/"5e8e-Yw5ZdnVVly9/aEnMX7fVXQ"
Vary: Accept-Encoding

<!DOCTYPE html>
<html lang="en">
......
</html>
```

## 3. 将链接保存到文件

我们可以使用 > 符号将输出重定向到本地文件中。 
curl [http://www.codebelief.com](http://www.codebelief.com/) > index.html 
也可以通过 curl 自带的 -o/-O 选项将内容保存到文件中。

-o（小写的 o）：结果会被保存到命令行中提供的文件名 
-O（大写的 O）：URL 中的文件名会被用作保存输出的文件名 
curl -o index.html [http://www.codebelief.com](http://www.codebelief.com/) 
curl -O http://www.codebelief.com/page/2/ 
注意：使用 -O 选项时，必须确保链接末尾包含文件名，否则 curl 无法正确保存文件。如果遇到链接中无文件名的情况，应该使用 -o 选项手动指定文件名，或使用重定向符号。

## 4. 同时下载多个文件

我们可以使用 -o 或 -O 选项来同时指定多个链接，按照以下格式编写命令： 
curl -O http://www.codebelief.com/page/2/ -O http://www.codebelief.com/page/3/

或者： 
curl -o page1.html http://www.codebelief.com/page/1/ -o page2.html http://www.codebelief.com/page/2/

## 5. 使用 -L 跟随链接重定向

如果直接使用 curl 打开某些被重定向后的链接，这种情况下就无法获取我们想要的网页内容。例如： 
curl [http://codebelief.com](http://codebelief.com/) 
会得到如下提示：

```
<html>
<head><title>301 Moved Permanently</title></head>
<body bgcolor="white">
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.10.3</center>
</body>
</html>
```

 

而当我们通过浏览器打开该链接时，会自动跳转到 [http://www.codebelief.com](http://www.codebelief.com/)。此时我们想要 curl 做的，就是像浏览器一样跟随链接的跳转，获取最终的网页内容。我们可以在命令中添加 -L 选项来跟随链接重定向：

curl -L [http://codebelief.com](http://codebelief.com/) 
这样我们就能获取到经过重定向后的网页内容了。

## 6. 使用 -A 自定义 User-Agent

我们可以使用 -A 来自定义用户代理，例如下面的命令将伪装成安卓火狐浏览器对网页进行请求： 
curl -A “Mozilla/5.0 (Android; Mobile; rv:35.0) Gecko/35.0 Firefox/35.0” [http://www.baidu.com](http://www.baidu.com/) 
下面我们会使用 -H 来实现同样的目的。

## 7. 使用 -H 自定义 header

当我们需要传递特定的 header 的时候，可以仿照以下命令来写： 
curl -H “Referer: www.example.com” -H “User-Agent: Custom-User-Agent” [http://www.baidu.com](http://www.baidu.com/) 
可以看到，当我们使用 -H 来自定义 User-Agent 时，需要使用 “User-Agent: xxx” 的格式。

我们能够直接在 header 中传递 Cookie，格式与上面的例子一样： 
curl -H “Cookie: JSESSIONID=D0112A5063D938586B659EF8F939BE24” [http://www.example.com](http://www.example.com/) 
另一种方式会在下面介绍。

## 8. 使用 -c 保存 Cookie

当我们使用 cURL 访问页面的时候，默认是不会保存 Cookie 的。有些情况下我们希望保存 Cookie 以便下次访问时使用。例如登陆了某个网站，我们希望再次访问该网站时保持登陆的状态，这时就可以现将登陆时的 Cookie 保存起来，下次访问时再读取。

-c 后面跟上要保存的文件名。 
curl -c “cookie-example” [http://www.example.com](http://www.example.com/)

## 9. 使用 -b 读取 Cookie

前面讲到了使用 -H 来发送 Cookie 的方法，这种方式是直接将 Cookie 字符串写在命令中。如果使用 -b 来自定义 Cookie，命令如下： 
curl -b “JSESSIONID=D0112A5063D938586B659EF8F939BE24” [http://www.example.com](http://www.example.com/) 
如果要从文件中读取 Cookie，-H 就[无能为力](https://www.baidu.com/s?wd=无能为力&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)了，此时可以使用 -b 来达到这一目的： 
curl -b “cookie-example” [http://www.example.com](http://www.example.com/) 
即 -b 后面既可以是 Cookie 字符串，也可以是保存了 Cookie 的文件名。

## 10. 使用 -d 发送 POST 请求

我们以登陆网页为例来进行说明使用 cURL 发送 POST 请求的方法。假设有一个登录页面 www.example.com/login，只需要提交用户名和密码便可登录。我们可以使用 cURL 来完成这一 POST 请求，-d 用于指定发送的数据，-X 用于指定发送数据的方式： 
curl -d “userName=tom&passwd=123456” -X POST http://www.example.com/login

在使用 -d 的情况下，如果省略 -X，则默认为 POST 方式： 
curl -d “userName=tom&passwd=123456” http://www.example.com/login

强制使用 GET 方式 
发送数据时，不仅可以使用 POST 方式，也可以使用 GET 方式，例如： 
curl -d “somedata” -X GET http://www.example.com/api

或者使用 -G 选项： 
curl -d “somedata” -G http://www.example.com/api

从文件中读取 data 
curl -d “@data.txt” http://www.example.com/login

带 Cookie 登录 
当然，如果我们再次访问该网站，仍然会变成未登录的状态。我们可以用之前提到的方法保存 Cookie，在每次访问网站时都带上该 Cookie 以保持登录状态。 
curl -c “cookie-login” -d “userName=tom&passwd=123456” http://www.example.com/login 
再次访问该网站时，使用以下命令： 
curl -b “cookie-login” http://www.example.com/login 
这样，就能保持访问的是登录后的页面了。

 

参考链接：

https://blog.csdn.net/cuishi0/article/details/7038999

https://blog.csdn.net/chenliaoyuanjv/article/details/79689028

 