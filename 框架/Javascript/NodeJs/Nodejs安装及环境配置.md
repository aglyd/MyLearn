# Nodejs安装及环境配置



## 1、官网下载：http://nodejs.cn/

`.msi`和`.zip`格式区别：

- `.msi`是Windows installer开发出来的程序安装文件，它可以让你安装，修改，卸载你所安装的程序。说白了.msi就是Windows installer的数据包，把所有和安装文件相关的内容封装在一个包里。
- `.zip`是一个压缩包，解压之后即可，不需要安装



选择安装模式：

`npm package manager`表示npm包管理器

`online documentation shortcuts` 在线文档快捷方式

`Add to PATH`添加node安装路径到环境变量（选择了此项）

安装完成后，`.msi`格式的安装包已经将`node.exe`添加到系统环境变量`path`中,如果你下载的是`.zip`格式，因为没有安装过程，所以需要手动将`node.exe`所在目录添加到环境变量`path`中，查看系统变量验证



既然已经将`node`添加到全局系统变量，我们可以直接在`CMD`窗口中任意位置执行`node`，打开CMD窗口，执行命令`node -v`查看node版本

```css
v14.7.0
```

最新版的node在安装时同时也安装了`npm`,执行`npm -v`查看`npm`版本

```css
6.14.7
```



## 2、修改全局依赖包下载路径

默认情况下，我们在执行`npm install -g XXXX`下载全局包时，这个包的默认存放路径位`C:\Users\用户名\AppData\Roaming\npm\node_modules下`，可以通过`CMD`指令`npm root -g`查看

```undefined
C:\Users\liaijie\AppData\Roaming\npm\node_modules
```



默认存放安装模块配置位置：C:\Users\sever\AppData\Roaming\node_global，存放安装过程的缓存文件：C:\Users\sever\AppData\Roaming\node_cache

但是有时候我们不想让全局包放在这里，我们可以自定义存放目录,在`CMD`窗口执行以下两条命令修改默认路径：

先在所在位置下建立对应空文件夹

```swift
npm config set prefix "D:\Program Files\Nodejs\node_global"
```

```bash
npm config set cache "D:\Program Files\Nodejs\node_cache"
```

或者打开`c:\node\node_modules\npm\.npmrc`文件，修改如下：

```
prefix =D:\Program Files\Nodejs\node_global
 `cache = D:\Program Files\Nodejs\node_cache
```

以上操作表示，修改全局包下载目录为`D:\Program Files\Nodejs\node_global`,缓存目录为`D:\Program Files\Nodejs\node_cache`,并会自动创建`node_global`目录，而`node_cache`目录是缓存目录，会在你下载全局包时自动创建



## 3、配置环境变量

1、先将nodejs安装位置配置进path环境变量中：D:\Program Files\Nodejs\



2、将全局模板存放位置配置path：D:\Program Files\Nodejs\node_global

因为我们修改了全局包的下载路径，那么自然而然，我们下载的全局包就会存放在`D:\Program Files\Nodejs\node_global\node_modules`，而其对应的`cmd`指令会存放在`D:\Program Files\Nodejs\node_global`

我全局安装一个`vue-cli`脚手架

```css
npm install @vue/cli -g
```



安装好后我使用`CMD`命令`vue create myproject`指令创建一个项目，显示如下

```bash
'vue' 不是内部或外部命令，也不是可运行的程序
或批处理文件。
```

这是因为我们在执行指令时，它会默认在`node`安装根目录下查找指令文件，在这里就是`vue.cmd`,然后还会在`node`安装根目录下的`node_modules`下查找依赖包文件夹，在这里就是`@vue`文件夹，因为我们修改了全局包的存放路径，所以自然找不到了，所以我们需要把我们指定的全局包存放路径添加到系统环境变量，这样就可以找到了

再次测试：

```js
C:\Users\liaijie>vue create myproject
?  Your connection to the default npm registry seems to be slow.
   Use https://registry.npm.taobao.org for faster installation? (Y/n)
```

会在当前目录下创建一个vue项目（项目名myproject），进入该项目根目录下，cmd执行npm install，npm run dev



### 配置镜像站

最后可以配置一个国内镜像站提升下载速度，如：

```nginx
npm config set registry=http://registry.npm.taobao.org    #配置淘宝仓库
npm config get registry     #检查镜像站
```

切换其他镜像：

```nginx
npm config set registry  https://registry.npm.taobao.org 	#这个是淘宝的源

npm config set registry http://registry.cnpmjs.org/ 	#这个不知道是哪个源 是原来的源么

npm config set registry https://registry.npmjs.org/		#这个应该是原本的源

npm cache clean --force 	#换完源之后执行这个命令清除一下缓存
```


## 4、指令用法

### 升级npm

```
npm install -g npm
npm -g install npm@版本号    #升级到指定版本
```

### 安装cnpm

使用淘宝镜像仓库安装cnpm。

```
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

### 安装模块

将npm的全局模块目录和缓存目录配置到我们刚才创建的那两个目录

```nginx
npm install 模块名/包名 -g    #安装模块/包,-g全局安装,不带-g在当前项目安装
npm uninstall -g 模块名/包名    #删除模块
```

临时使用某个镜像站安装模块

```nginx
#使用淘宝镜像站下载cluster模块
npm --registry https://registry.npm.taobao.org install cluster -g

```

在镜像站中搜索安装包

```
npm search 包名
```

查看已安装的包

```
npm list -g  #-g全局,不带-g查看当前项目已安装的包
```



### 项目模块管理

```nginx
npm list         #列出当前项目已安装模块

npm config list  #列出当前配置信息
 
npm show express     #显示模块详情
 
npm update        #升级当前目录下的项目的所有模块
 
npm update express    #升级当前目录下的项目的指定模块
 
npm update -g express  #升级全局安装的express模块
 
npm uninstall express  #删除当前目录下的项目指定的模块
```



### 创建模块

```
npm init     #会输入各种配置包括git的url及用户名密码
npm publish
```