# [linux后台执行命令：&与nohup的用法](https://zhuanlan.zhihu.com/p/59297350)

大家可能有这样的体验：某个程序运行的时候，会产生大量的log，但实际上我们只想让它跑一下而已，log暂时不需要或者后面才有需要。所以在这样的情况下，我们希望程序能够在后台进行，也就是说，在终端上我们看不到它所打出的log。为了实现这个需求，我们介绍以下几种方法。

我们以下面一个test程序来模拟产生大量log的程序，这个程序每隔1秒就会打印一句“Hello world!”：

```c
#include 
#include 
#include 

int main()
{
    fflush(stdout);
    setvbuf(stdout, NULL, _IONBF, 0);

    while (1) {
        printf("Hello world!\n");
        sleep(1);
    }
}
```

现在，我们想要一个清静的世界，终端上不要有大量的log出现，我们要求test程序在后台运行。

## **&**

这种方法很简单，就是在命令之后加个“&”符号就可以了，如下：

```text
./test &
```

这样一来，test程序就在后台运行了。但是，这样处理还不够，因为这样做虽然程序是在后台运行了，但log依然不停的输出到当前终端。因此，要让终端彻底的清静，还应将log重定向到指定的文件：

```text
./test >> out.txt 2>&1 &
```

2>&1是指将标准错误重定向到标准输出，于是标准错误和标准输出都重定向到指定的out.txt文件中，从此终端彻底清静了。

但是这样做要注意，如果Test程序需要从标准输入接收数据，它就会在那死等，不会再往下运行。所以需要从标准输入接收数据，那这种方法最好不要使用。

那现在程序在后台运行了，我们怎么找到它呢？很简单，有两种方法：

**1. jobs命令**

jobs命令可以查看当前有多少在后台运行。

```text
jobs -l
```

此命令可显示所有任务的PID，jobs的状态可以是running, stopped, Terminated。但是如果任务被终止了（kill），shell 从当前的shell环境已知的列表中删除任务的进程标识。

**2. ps命令**

```text
ps aux | grep test
```

## **nohup命令**

**在命令的末尾加个&符号后，程序可以在后台运行，但是一旦当前终端关闭（即退出当前帐户），该程序就会停止运行**。那假如说我们想要退出当前终端，但又想让程序在后台运行，该如何处理呢？

实际上，这种需求在现实中很常见，比如想远程到服务器编译程序，但网络不稳定，一旦掉线就编译就中止，就需要重新开始编译，很浪费时间。

在这种情况下，我们就可以使用nohup命令。nohup就是不挂起的意思( no hang up)。该命令的一般形式为：

```text
nohup ./test &
```

如果仅仅如此使用nohup命令的话，程序的输出会默认重定向到一个nohup.out文件下。如果我们想要输出到指定文件，可另外指定输出文件：

```text
nohup ./test > myout.txt 2>&1 &
```

这样一来，多管齐下，既使用了nohup命令，也使用了&符号，同时把标准输出/错误重定向到指定目录下。

使用了nohup之后，很多人就这样不管了，其实这样有可能在当前账户非正常退出或者结束的时候，命令还是自己结束了。所以在使用nohup命令后台运行命令之后，需要使用exit正常退出当前账户，这样才能保证命令一直在后台运行。

### 百度百科描述

nohup 命令运行由 [Command](https://baike.baidu.com/item/Command?fromModule=lemma_inlink)参数和任何相关的 Arg参数指定的命令，忽略所有挂断（SIGHUP）[信号](https://baike.baidu.com/item/信号/32683?fromModule=lemma_inlink)。在注销后使用 nohup 命令运行后台中的程序。要运行后台中的 nohup 命令，添加 & （ 表示“and”的符号）到命令的尾部。

**用途：**[LINUX](https://baike.baidu.com/item/LINUX?fromModule=lemma_inlink)命令用法，不挂断地[运行命令](https://baike.baidu.com/item/运行命令/1268360?fromModule=lemma_inlink)。

如果不将 nohup 命令的输出重定向，输出将附加到当前目录的 nohup.out 文件中。如果当前目录的 nohup.out 文件不可写，输出重定向到 $HOME/nohup.out 文件中。如果没有文件能创建或打开以用于追加，那么 Command 参数指定的命令不可调用。如果标准错误是一个终端，那么把指定的命令写给标准错误的所有输出作为标准输出重定向到相同的[文件描述符](https://baike.baidu.com/item/文件描述符?fromModule=lemma_inlink)。

### 退出状态

该命令返回下列出口值：

126 可以查找但不能调用 Command 参数指定的命令。

127 nohup 命令发生错误或不能查找由 Command 参数指定的命令。

否则，nohup 命令的退出状态是 Command 参数指定命令的退出状态。

nohup命令及其输出文件

nohup命令：如果你正在运行一个进程，而且你觉得在退出帐户时该进程还不会结束，那么可以使用nohup命令。该命令可以在你退出帐户/关闭终端之后继续运行相应的进程。nohup就是不挂断的意思( no hang up)。

该命令的一般形式为：nohup command &

使用nohup命令提交作业

如果使用nohup命令提交作业，那么在缺省情况下该作业的所有输出都被重定向到一个名为nohup.out的文件中，除非另外指定了输出文件：

nohup command > myout.file 2>&1 &

在上面的例子中，0 – stdin (standard input)，1 – stdout (standard output)，2 – stderr (standard error) ；

2>&1是将标准错误（2）重定向到标准输出（&1），标准输出（&1）再被重定向输入到myout.file文件中。

使用 jobs 查看任务。

使用 fg %n　关闭。

有两个常用的**ftp**工具ncftpget和ncftpput，可以实现ftp上传和下载，我们可以利用nohup命令在后台实现文件的上传和下载。



# [计算机语言echo off什么意思,批处理文件的@echo off是什么意思?](https://blog.csdn.net/weixin_35720618/article/details/118872241)

@echo off

关闭回显

@echo on

打开回显

@echo off并不是DOS程序中的，

而是DOS批处理中的。

当年的DOS，所有操作都用键盘命令来完成，

当你每次都要输入相同的命令时，

可以把这么多命令存为一个批处理，

从此以后，只要运行这个批处理，

就相当于打了几行、几十行命令。

DOS在运行bat批处理时，

会依次执行批处理中的每条命令，

并且会在显示器上显示，

如果你不想让它们显示，

可以加一个“echo off”

当然，“echo off”也是命令，

它本身也会显示，

如果连这条也不显示，

就在前面加个“@”。

pause

使显示器停下，并显示“请按任意键继续_ _ _”

例如：

@echo off

@echo hello!

pause

显示：

```
hello1

请按任意键继续...
```



@echo on

@echo hello!

pause

显示：