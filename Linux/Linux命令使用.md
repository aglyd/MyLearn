# Linux命令使用

# Linux切换用户

**linux切换用户的命令是“su”。**

u 是最简单的用户切换命令，通过该命令可以实现任何身份的切换，包括从普通用户切换为 root 用户、从 root 用户切换为普通用户以及普通用户之间的切换。

> 普通用户之间切换以及普通用户切换至 root 用户，都需要知晓对方的密码，只有正确输入密码，才能实现切换；从 root 用户切换至其他用户，无需知晓对方密码，直接可切换成功。

su 命令的基本格式如下：

```
`# su [选项] 用户名`
```

选项：

- `-`：当前用户不仅切换为指定用户的身份，同时所用的工作环境也切换为此用户的环境（包括 PATH 变量、MAIL 变量等），使用 - 选项可省略用户名，默认会切换为 root 用户。
- `-l`：同 - 的使用类似，也就是在切换用户身份的同时，完整切换工作环境，但后面需要添加欲切换的使用者账号。
- `-p`：表示切换为指定用户的身份，但不改变当前的工作环境（不使用切换用户的配置文件）。
- `-m`：和 -p 一样；
- `-c` 命令：仅切换用户执行一次命令，执行后自动切换回来，该选项后通常会带有要执行的命令。

【例 1】

```
`[lamp@localhost ~]$ su -root``密码： <-- 输入 root 用户的密码``#``"-"``代表连带环境变量一起切换，不能省略`
```

【例 2】

```
`[lamp@localhost ~]$ whoami``lamp``#当前我是lamp``[lamp@localhost ~]$ su - -c ``"useradd user1"` `root``密码：``#不切换成root，但是执行useradd命令添加user1用户``[lamp@localhost ~]$ whoami``lamp``#我还是lamp``[lamp@localhost ~]$ grep "user1' /etc/passwd``userl:x:502:504::/home/user1:/bin/bash``#user用户已经添加了`
```

除了像例 2 这样，执行一条命令后用户身份会随即自动切换回来，其他切换用户的方式不会自动切换，只能使用 exit 命令进行手动切换，例如：

```
`[lamp@localhost ~]$ whoami``lamp``#当前我是lamp``[lamp@localhost ~]$ su - lamp1``Password:   <--输入lamp1用户的密码``#切换至 lamp1 用户的工作环境``[lamp@localhost ~]$ whoami``lamp1``#什么也不做，立即退出切换环境``[lamp1@localhost ~]$ ``exit``logout``[lamp@localhost ~]$ whoami``lamp`
```

**su 和 su - 的区别**

注意，使用 su 命令时，有 - 和没有 - 是完全不同的，- 选项表示在切换用户身份的同时，连当前使用的环境变量也切换成指定用户的。我们知道，环境变量是用来定义操作系统环境的，因此如果系统环境没有随用户身份切换，很多命令无法正确执行。



# 查看Linux系统版本信息的几种方法

一、查看Linux内核版本命令（两种方法）：

1、cat /proc/version

![img](https://img-blog.csdnimg.cn/img_convert/30a563e9624586d6cc2726f67f787fcb.png)

2、uname -a

![img](https://img-blog.csdnimg.cn/img_convert/32cea5be72915c2654042796886c1bd4.png)

二、查看Linux系统版本的命令（3种方法）：

1、lsb_release -a，即可列出所有版本信息：

![img](https://img-blog.csdnimg.cn/img_convert/1df1974df1ce4d8ab017bc563888c450.png)

这个命令适用于所有的Linux发行版，包括[RedHat](https://so.csdn.net/so/search?q=RedHat&spm=1001.2101.3001.7020)、SUSE、Debian…等发行版。

2、cat /etc/redhat-release，这种方法只适合Redhat系的Linux：

[root@S-CentOS home]# cat /etc/redhat-release

CentOS release 6.5 (Final)

3、cat /etc/issue，此命令也适用于所有的Linux发行版。

![img](https://img-blog.csdnimg.cn/img_convert/58827bda4d657ddf2b7f3e1f5ae05059.png)



# Linux cp 命令

Linux cp（英文全拼：copy file）命令主要用于复制文件或目录。

### 语法

```
cp [options] source dest
```

或

```
cp [options] source... directory
```

**参数说明**：

- -a：此选项通常在复制目录时使用，它保留链接、文件属性，并复制目录下的所有内容。其作用等于dpR参数组合。
- -d：复制时保留链接。这里所说的链接相当于 Windows 系统中的快捷方式。
- -f：覆盖已经存在的目标文件而不给出提示。
- -i：与 **-f** 选项相反，在覆盖目标文件之前给出提示，要求用户确认是否覆盖，回答 **y** 时目标文件将被覆盖。
- -p：除复制文件的内容外，还把修改时间和访问权限也复制到新文件中。
- -r：若给出的源文件是一个目录文件，此时将复制该目录下所有的子目录和文件。
- -l：不复制文件，只是生成链接文件。

### 实例

使用指令 **cp** 将当前目录 **test/** 下的所有文件复制到新目录 **newtest** 下，输入如下命令：

```
$ cp –r test/ newtest          
```

注意：用户使用该指令复制目录时，必须使用参数 **-r** 或者 **-R** 。



# Linux mv命令：移动文件或改名

mv 命令（move 的缩写），既可以在不同的目录之间移动文件或目录，也可以对文件和目录进行重命名。该命令的基本格式如下：

[root@localhost ~]# mv 【选项】 源文件 目标文件

选项：

- -f：强制覆盖，如果目标文件已经存在，则不询问，直接强制覆盖；
- -i：交互移动，如果目标文件已经存在，则询问用户是否覆盖（默认选项）；
- -n：如果目标文件已经存在，则不会覆盖移动，而且不询问用户；
- -v：显示文件或目录的移动过程；
- -u：若目标文件已经存在，但两者相比，源文件更新，则会对目标文件进行升级；

需要注意的是，同 rm 命令类似，mv 命令也是一个具有破坏性的命令，如果使用不当，很可能给系统带来灾难性的后果。

【例 1】移动文件或目录。

[root@localhost ~]# mv cangls /tmp
#移动之后，源文件会被删除，类似剪切
[root@localhost ~]# mkdir movie
[root@localhost ~]# mv movie/ /tmp
#也可以移动目录。和 rm、cp 不同的是，mv 移动目录不需要加入 "-r" 选项

如果移动的目标位置已经存在同名的文件，则同样会提示是否覆盖，因为 mv 命令默认执行的也是 "mv -i" 的别名，例如：

[root@localhost ~]# touch cangls
\#重新建立文件
[root@localhost ~]# mv cangls /tmp
mv:县否覆盖"tmp/cangls"？y
\#由于 /tmp 目录下已经存在 cangls 文件，所以会提示是否覆盖，需要手工输入 y 覆盖移动

【例 2】强制移动。

之前说过，如果目标目录下已经存在同名文件，则会提示是否覆盖，需要手工确认。这时如果移动的同名文件较多，则需要一个一个文件进行确认，很不方便。

如果我们确认需要覆盖已经存在的同名文件，则可以使用 "-f" 选项进行强制移动，这就不再需要用户手工确认了。例如：

[root@localhost ~]# touch cangls
\#重新建立文件
[root@localhost ~]# mv -f cangls /tmp
\#就算 /tmp/ 目录下已经存在同名的文件，由于"-f"选项的作用，所以会强制覆盖

【例 3】不覆盖移动。

既然可以强制覆盖移动，那也有可能需要不覆盖的移动。如果需要移动几百个同名文件，但是不想覆盖，这时就需要 "-n" 选项的帮助了。例如：

[root@localhost ~]# ls /tmp
/tmp/bols /tmp/cangls
\#在/tmp/目录下已经存在bols、cangls文件了
[root@localhost ~]# mv -vn bols cangls lmls /tmp/、
"lmls"->"/tmp/lmls"
\#再向 /tmp/ 目录中移动同名文件，如果使用了 "-n" 选项，则可以看到只移动了 lmls，而同名的 bols 和 cangls 并没有移动（"-v" 选项用于显示移动过程）

【例 4】改名。

如果源文件和目标文件在同一目录中，那就是改名。例如：

[root@localhost ~]# mv bols lmls
\#把 bols 改名为 lmls

目录也可以按照同样的方法改名。

【例 5】显示移动过程。

如果我们想要知道在移动过程中到底有哪些文件进行了移动，则可以使用 "-v" 选项来查看详细的移动信息。例如：

[root@localhost ~]# touch test1.txt test2.txt test3.txt
\#建立三个测试文件
[root@localhost ~]# mv -v *.txt /tmp
"test1.txt" -> "/tmp/test1.txt"
"test2.txt" -> "/tmp/test2.txt"
"test3.txt" -> "/tmp/test3.txt"
\#加入"-v"选项，可以看到有哪些文件进行了移动



# [Linux find命令：在目录中查找文件（超详解）](http://c.biancheng.net/view/779.html)

find 是 Linux 中强大的搜索命令，不仅可以按照文件名搜索文件，还可以按照权限、大小、时间、inode 号等来搜索文件。但是 find 命令是直接在硬盘中进行搜索的，如果指定的搜索范围过大，find命令就会消耗较大的系统资源，导致服务器压力过大。所以，在使用 find 命令搜索时，不要指定过大的搜索范围。

find 命令的基本信息如下：

- 命令名称：find。
- 英文原意：search for files in a directory hierarchy.
- 所在路径：/bin/find。
- 执行权限：所有用户。
- 功能描述：在目录中查找文件。

## 命令格式

[root@localhost ~]# find 搜索路径 [选项] 搜索内容

find 是比较特殊的命令，它有两个参数：

- 第一个参数用来指定搜索路径；
- 第二个参数用来指定搜索内容。

而且find命令的选项比较复杂，我们一个一个举例来看。

## 按照文件名搜索

[root@localhost ~]#find 搜索路径 [选项] 搜索内容

选项：

- -name: 按照文件名搜索；
- -iname: 按照文件名搜索，不区分文件名大小；
- -inum: 按照 inode 号搜索；

这是 find 最常用的用法，我们来试试：

[root@localhost ~]# find /-name yum.conf
/etc/yum.conf
\#在目录下査找文件名是yum.conf的文件

但是 find 命令有一个小特性，就是搜索的文件名必须和你的搜索内容一致才能找到。如果只包含搜索内容，则不会找到。我们做一个实验：

[root@localhost ~]# touch yum.conf.bak
\#在/root/目录下建立一个文件yum.conf.bak
[root@localhost ~]# find /-name yum.conf
/etc/yum.conf
\#搜索只能找到yum.conf文件，而不能找到 yum.conf.bak 文件

find 能够找到的是只有和搜索内容 yum.conf 一致的 /etc/yum.conf 文件，而 /root/yum.conf.bak 文件虽然含有搜索关键字，但是不会被找到。这种特性我们总结为：

find 命令是完全匹配的，必须和搜索关键字一模一样才会列出。

Linux 中的文件名是区分大小写的，也就是说，搜索小写文件，是找不到大写文件的。如果想要大小通吃，就要使用 -iname 来搜索文件。

[root@localhost ~]# touch CANGLS
[root@localhost ~]# touch cangls
#建立大写和小写文件
[root@localhost ~]#find.-iname cangls
./CANGLS
./cangls
#使用-iname，大小写文件通吃

每个文件都有 inode 号，如果我们知道 inode 号，则也可以按照 inode 号来搜索文件。

[root@localhost ~]#ls -i install.log
262147 install.log
\#如果知道文件名，则可以用"ls -i"来査找inode号
[root@localhost ~]# find.-inum 262147
./install.log
\#如果知道inode号，则可以用find命令来査找文件

按照 inode 号搜索文件，也是区分硬链接文件的重要手段，因为硬链接文件的 inode 号是一致的。

[root@localhost ~]# ln /root/install.log /tmp/
#给install.log文件创建一个硬链接文件
[root@localhost ~]#ll -i /root/install.log /tmp/install.log
262147 -rw-r--r--.2 root root 24772 1 月 14 2014/root/
install.log
262147 -rw-r--r--.2 root root 24772 1 月 14 2014/tmp/
install.log
#可以看到这两个硬链接文件的inode号是一致的
[root@localhost ~]# find /-inum 262147
/root/install.log
/tmp/install.log
#如果硬链接不是我们自己建立的，则可以通过find命令搜索inode号，来确定硬链接文件

## 按照文件大小搜索

[root@localhost ~]#find 搜索路径 [选项] 搜索内容

选项：

- -size[+-]大小：按照指定大小搜索文件

这里的"+"的意思是搜索比指定大小还要大的文件，"-" 的意思是搜索比指定大小还要小的文件。我们来试试：

[root@localhost ~]# ll -h install.log
-rw-r--r--.1 root root 25K 1月 14 2014 install.log #在当前目录下有一个大小是25KB的文件
[root@localhost ~]#
[root@localhost ~]# find.-size 25k
./install.log
#当前目录下，査找大小刚好是25KB的文件，可以找到
[root@localhost ~]# find .-size -25k
.
./.bashrc
./.viminfo
./.tcshrc
./.pearrc
./anaconda-ks.cfg
./test2
./.ssh
./.bash_history
./.lesshst
./.bash_profile
./yum.conf.bak
./.bashjogout
./install.log.syslog
./.cshrc
./cangls
#搜索小于25KB的文件，可以找到很多文件
[root@localhost ~]# find.-size +25k
#而当前目录下没有大于25KB的文件

其实 find 命令的 -size 选项是笔者个人觉得比较恶心的选项，为什么这样说？find 命令可以按照 KB 来搜索，应该也可以按照 MB 来搜索吧。

[root@localhost ~]# find.-size -25m
find:无效的-size类型"m"
\#为什么会报错呢？其实是因为如果按照MB来搜索，则必须是大写的M

这就是纠结点，千字节必须是小写的"k"，而兆字节必领是大写的"M"。有些人会说："你别那么执着啊，你就不能不写单位，直接按照字节搜索啊？"很傻，很天真，不写单位，你们就以为会按照字节搜索吗？我们来试试：

[root@localhost ~]# ll anaconda-ks.cfg
-rw-------.1 root root 1207 1 月 14 2014 anaconda-ks.cfg
\#anaconda-ks.cfg文件有1207字芳
[root@localhost ~]# find.-size 1207
\#但用find查找1207，是什么也找不到的

也就是说，find 命令的默认单位不是字节。如果不写单位，那么 find 命令是按照 512 Byte 来进行査找的。 我们看看 find 命令的帮助。

[root@localhost ~]# man find
-size n[cwbkMG]
File uses n units of space. The following suffixes can be used:
'b' for 512-byte blocks (this is the default if no suffix is used)
#这是默认单位，如果单位为b或不写单位，则按照 512Byte搜索
'c' for bytes
#搜索单位是c，按照字节搜索
'w' for two-byte words
#搜索单位是w，按照双字节（中文）搜索
'k'for Kilobytes (units of 1024 bytes)
#按照KB单位搜索，必须是小写的k
'M' for Megabytes (units of 1048576 bytes)
#按照MB单位搜索，必须是大写的M
'G' for Gigabytes (units of 1073741824 bytes)
#按照GB单位搜索，必须是大写的G

也就是说，如果想要按照字节搜索，则需要加搜索单位"c"。我们来试试：

[root@localhost ~]# find.-size 1207c
./anaconda-ks.cfg
\#使用搜索单位c，才会按照字节搜索

## 按照修改时间搜索

Linux 中的文件有访问时间(atime)、数据修改时间(mtime)、状态修改时间(ctime)这三个时间，我们也可以按照时间来搜索文件。

[root@localhost ~]# find搜索路径 [选项] 搜索内容

选项：

- -atime [+-]时间: 按照文件访问时间搜索
- -mtime [+-]时间: 按照文改时间搜索
- -ctime [+-]时间: 按照文件修改时间搜索

这三个时间的区别我们在 stat 命令中已经解释过了，这里用 mtime 数据修改时间来举例，重点说说 "[+-]"时间的含义。

- -5：代表@内修改的文件。
- 5：代表前5~6天那一天修改的文件。
- +5：代表6天前修改的文件。

我们画一个时间轴，来解释一下，如图 1 所示。


![img](http://c.biancheng.net/uploads/allimg/180930/2-1P930143J9411.jpg)
图 1 find时间轴

每次笔者讲到这里，"-5"代表 5 天内修改的文件，而"+5"总有人说代表 5 天修改的文件。要是笔者能知道 5 天系统中能建立什么文件，早就去买彩票了，那是未卜先知啊！所以"-5"指的是 5 天内修改的文件，"5"指的是前 5~6 天那一天修改的文件，"+5"指的是 6 天前修改的文件。我们来试试：

[root@localhost ~]#find.-mtime -5
\#查找5天内修改的文件

大家可以在系统中把几个选项都试试，就可以明白各选项之间的差别了。

find 不仅可以按照 atmie、mtime、ctime 来査找文件的时间，也可以按照 amin、mmin 和 cmin 来査找文件的时间，区别只是所有 time 选项的默认单位是天，而 min 选项的默认单位是分钟。

## 按照权限搜索

在 find 中，也可以按照文件的权限来进行搜索。权限也支持 [+/-] 选项。我们先看一下命令格式。

[root@localhost ~]# find 搜索路径 [选项] 搜索内容

选项：

- -perm 权限模式：査找文件权限刚好等于"权限模式"的文件
- -perm -权限模式：査找文件权限全部包含"权限模式"的文件
- -perm +权限模式：査找文件权限包含"权限模式"的任意一个权限的文件

为了便于理解，我们要举几个例子。先建立几个测试文件。

[root@localhost ~]# mkdir test
[root@localhost ~]# cd test/
[root@localhost test]# touch testl
[root@localhost test]# touch test2
[root@localhost test]# touch test3
[root@localhost test]# touch test4
#建立测试目录，以及测试文件
[root@localhost test]# chmod 755 testl
[root@localhost test]# chmod 444 test2
[root@localhost test]# chmod 600 test3
[root@localhost test]# chmod 200 test4
#设定实验权限。因为是实验权限，所以看起来比较别扭
[root@localhost test]# ll
总用量0
-rwxr-xr-x 1 root root 0 6月 17 11:05 testl -r--r--r-- 1 root root 0 6月 17 11:05 test2
-rw------- 1 root root 0 6月 17 11:05 test3
-w------- 1 root root 0 6月 17 11:05 test4
#查看权限

【例 1】

"-perm权限模式"。

这种搜索比较简单，代表査找的权限必须和指定的权限模式一模一样，才可以找到。

[root@localhost test]#find.-perm 444
./test2
[root@localhost test]#find.-perm 200
./test4
\#按照指定权限搜索文件，文件的权限必须和搜索指定的权限一致，才能找到

【例 2】

"-perm-权限模式"。

如果使用"-权限模式"，是代表的是文件的权限必须全部包含搜索命令指定的权限模式，才可以找到。

[root@localhost test]#find .-perm -200
./test4 <-此文件权限为200
./test3 <-此文件权限为600
./testl <-此文件权限为755
\#搜索文件的权限包含200的文件，不会找到test2文件，因为test2的权限为444，不包含200权限

因为 test4 的权限 200(-w-------)、test3 的权限 600(-rw-------)和 test1 的权限 755(-rwxr-xr-x) 都包含 200(--w-------) 权限，所以可以找到；而 test2 的权限是 444 (-r--r--r--)，不包含 200 (--w-------)权限，所以找不到，再试试：

[root@localhost test]# find .-perm -444
.
./test2 <-此文件权限为444
./test1 <-此文件权限为755
\#搜索文件的权限包含444的文件

上述搜索会找到 test1 和 test2，因为 test1 的权限 755 (-rwxr-xr-x)和 test2 的权限 444 (-r--r--r--)都完全包含 444 (-r--r--r--)权限，所以可以找到；而 test3 的权限 600 (-rw-------)和 test4 的权限 200 (-w-------)不完全包含 444 (-r--r--r--) 权限，所以找不到。也就是说，test3 和 test4 文件的所有者权限虽然包含 4 权限，但是所属组权限和其他人权限都是 0，不包含 4 权限，所以找不到，这也是完全包含的意义。

【例 3】

"-perm+权限模式"

刚刚的"-perm-权限模式"是必须完全包含，才能找到；而"-perm+权限模式"是只要包含任意一个指定权限，就可以找到。我们来试试：

[root@localhost test]# find .-perm +444
./test4 <-此文件权限为200
./test3 <-此文件权限为600
./testl <-此文件权限为755
\#搜索文件的权限包含200的文件，不会找到test2文件，因为test2的权限为444，不包含200权限。

因为 test4 的权限 200 (--w-------)、test3 的权限 600 (-rw-------)和 test1 的权限 755 (-rwxr-xr-x)都包含 200(--w-------)权限，所以可以找到；而 test2 的权限是 444 (-r--r--r--)，不包含 200 (--w-------)权限，所以找不到。

## 按照所有者和所属组搜索

[root@localhost ~]# find 搜索路径 [选项] 搜索内容

选项：

- -uid 用户 ID:按照用户 ID 査找所有者是指定 ID 的文件
- -gid 组 ID:按照用户组 ID 査找所属组是指定 ID 的文件
- -user 用户名：按照用户名査找所有者是指定用户的文件
- -group 组名：按照组名査找所属组是指定用户组的文件
- -nouser：査找没有所有者的文件

这组选项比较简单，就是按照文件的所有者和所属组来进行文件的査找。在 Linux 系统中，绝大多数文件都是使用 root 用户身份建立的，所以在默认情况下，绝大多数系统文件的所有者都是 root。例如：

[root@localhost ~]#find.-user root
\#在当前目录中査找所有者是 root 的文件

由于当前目录是 root 的家目录，所有文件的所有者都是 root 用户，所以这条搜索命令会找到当前目录下所有的文件。

按照所有者和所属组搜索时，"-nouser"选项比较常用，主要用于査找垃圾文件。在 Linux 中，所有的文件都有所有者，只有一种情况例外，那就是外来文件。比如光盘和 U 盘中的文件如果是由 Windows 复制的，在 Linux 中査看就是没有所有者的文件；再比如手工源码包安装的文件，也有可能没有所有者。

除这种外来文件外，如果系统中发现了没有所有者的文件，一般是没有作用的垃圾文件（比如用户删除之后遗留的文件），这时需要用户手工处理。搜索没有所有者的文件，可以执行以下命令：

[root@localhost ~]# find/-nouser

## 按照文件类型搜索

[root@localhost ~]# find 搜索路径 [选项] 搜索内容

选项:

- -type d：查找目录
- -type f：查找普通文件
- -type l：查找软链接文件

这个命令也很简单，主要按照文件类型进行搜索。在一些特殊情况下，比如需要把普通文件和目录文件区分开，比如需要把普通文件和目录文件区分开，使用这个选项就很方便。

[root@localhost ~]# find /etc -type d
\#查找/etc/目录下有哪些子目录

## 逻辑运算符

[root@localhost ~]#find 搜索路径 [选项] 搜索内容

选项：

- -a：and逻辑与
- -o：or逻辑或
- -not：not逻辑非

#### 1) -a:and逻辑与

find 命令也支持逻辑运算符选项，其中 -a 代表逻辑与运算，也就是 -a 的两个条件都成立，find 搜索的结果才成立。

举个例子：

[root@localhost ~]# find.-size +2k -a -type f
\#在当前目录下搜索大于2KB，并且文件类型是普通文件的文件

在这个例子中，文件既要大于 2KB，又必须是普通文件，find 命令才可以找到。再举个例子：

[root@localhost ~]# find.-mtime -3 -a -perm 644
\#在当前目录下搜索3天以内修改过，并且权限是644的文件

#### 2) -o:or逻辑或

-o 选项代表逻辑或运算，也就是 -o 的两个条件只要其中一个成立，find 命令就可以找到结果。例如：

[root@localhost ~]#find.-name cangls -o -name bols
./cangls
./bols
\#在当前目录下搜索文件名要么是cangls的文件，要么是bols的文件

-o 选项的两个条件只要成立一个，find 命令就可以找到结果，所以这个命令既可以找到 cangls 文件，也可以找到 bols 文件。

#### 3) -not:not逻辑非

-not是逻辑非，也就是取反的意思。举个例子:
[root@localhost ~]# find.-not -name cangls
\#在当前目录下搜索文件名不是cangls的文件

#### 其他选项

1) -exec选项

这里我们主要讲解两个选项"-exec"和"-ok"，这两个选项的基本作用非常相似。我们先来看看 "exec"选项的格式。

[root@localhost ~]# find 搜索路径 [选项] 搜索内容 -exec 命令2{}\;

首先，请大家注意这里的"{}"和"\;"是标准格式，只要执行"-exec"选项，这两个符号必须完整输入。

其次，这个选项的作用其实是把 find 命令的结果交给由"-exec"调用的命令 2 来处理。"{}"就代表 find 命令的査找结果。

我们举个例子，刚刚在讲权限的时候，使用权限模式搜索只能看到文件名，例如：

[root@localhost test]#find.-perm 444
./test2

如果要看文件的具体权限，还要用"ll"命令査看。用"-exec"选项则可以一条命令搞定：

[root@localhost test]# find.-perm 444 -exec ls -l {}\；
-r--r--r-- 1 root root 0 6月 17 11:05 ./test2
\#使用"-exec"选项，把find命令的结果直接交给"ls -l"命令处理

"-exec"选项的作用是把 find 命令的结果放入"{}"中，再由命令 2 直接处理。在这个例子中就是用"ls -l"命令直接处理，会使 find 命令更加方便。

2) -ok选项

"-ok"选项和"-exec"选项的作用基本一致，区别在于："-exec"的命令会直接处理，而不询问；"-ok"的命令 2 在处理前会先询问用户是否这样处理，在得到确认命令后，才会执行。例如：

[root@localhost test]# find .-perm 444 -ok rm -rf{}\;
<rm…./test2>?y  <-需要用户输入y,才会执行
\#我们这次使用rm命令来删除find找到的结果，删除的动作最好确认一下



# Linux which命令用于查找文件。

which指令会在环境变量$PATH设置的目录里查找符合条件的文件。

### 语法

```
which [文件...]
```

**参数**：

- -n<文件名长度> 　指定文件名长度，指定的长度必须大于或等于所有文件中最长的文件名。
- -p<文件名长度> 　与-n参数相同，但此处的<文件名长度>包括了文件的路径。
- -w 　指定输出时栏位的宽度。
- -V 　显示版本信息。

### 实例

使用指令"which"查看指令"bash"的绝对路径，输入如下命令：

```
$ which bash
```

上面的指令执行后，输出信息如下所示：

```shell
/bin/bash                   #bash可执行程序的绝对路径 
```

### 总结：

which 查看[可执行文件](https://so.csdn.net/so/search?q=可执行文件&spm=1001.2101.3001.7020)的位置。

whereis 查看文件位置。

locate 配合数据库查看文件位置。

find 实际搜索硬盘查询文件名称。

[grep](https://so.csdn.net/so/search?q=grep&spm=1001.2101.3001.7020) 查找文件内容

一般不常用find命令，因为find命令比较庞大，搜索范围太大了，耗时长。

对于which，它是根据PATH[环境变量](https://so.csdn.net/so/search?q=环境变量&spm=1001.2101.3001.7020)到该路径寻找可执行文件，所以它基本上就是“寻找可执行文件”命令。

whereis呢？这个比较灵活了，可以加上参数来锁定精确的搜索一下，比如-b参数，就是只找二进制文件；-u参数，找没有说明文档的文件……等等。

locate就更好了，它是这里最快的命令。可是有个缺点，它为什么快呢？因为locate是从本地的数据库文件中找(好像WINDOWS里的注册表)文件位置的，这就有缺点了，数据库文件没有更新的时候，某些没在数据库中的“文件位置”就会找不到了，呵呵。但是没关系，你可以在用locate之前先用“updatedb”命令更新一下数据库再找。

grep 的作用通常是在一个文件中查找某个关键字

命令的具体用法：

1、find

格式: find [dir] [expression]

例如：在/etc中搜索vsftpd.conf文件2.grep: 差找文件内容

[root@localhost ~]# find     /etc  -name vsftpd.conf

2、locate

使用该命令要先运行updatedb；

[root@localhost ~]# updatedb

例如： 要找vsftpd.conf文件都位于哪个位置；

[root@localhost ~]# locate vsftpd.conf

3、whereis

比如我们不知道fdisk工具放在哪里，我们就可以用whereis fdisk 来查找；

[root@localhost ~]# whereis fdisk

4、which

which 和where 相似，只是which是在我们所设置的环境变量中设置好的路径中寻找；比如；

[root@localhost ~]# which fdisk

5、grep

格式：grep [option] pattern file

例如：a. grep test *

在当前目录中查找 含有字符串 test 文件的行

b. #find dir -name "file-patten" | xargs grep "patten"

在某个文件夹内的特定类型的文件中查找特定字符串

\#find /usr/src/linux "*.[ch]" | xargs grep "include"

在/usr/src/linux文件夹内的所有.c和.h文件中查找字符串include



# [yum search java|grep jdk报错](https://blog.csdn.net/qq_32811865/article/details/92002278)

错误：Cannot find a valid baseurl for repo: base

原因：错误信息大概意思是缓存的镜像文件里的URL无效了，所以无法下载程序文件来安装，需要重新配置yum源

步骤：

1、一：进入到/etc/repos.d目录，

```bash
cd /etc/yum.repos.d
```

2、修改CentOS-Media.repo，只修改后面的这几行就行了。

```bash
vi CentOS-Media.repo
```

只修改后面的这几行就行了。

```bash
baseurl=file:///mnt/cdrom/
        file:///media/cdrecorder/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
```

3、禁用默认的[yum](https://so.csdn.net/so/search?q=yum&spm=1001.2101.3001.7020) 网络源，将yum 网络源配置文件改名为CentOS-Base.repo.bak，否则会先在网络源中寻找适合的包，改名之后直接从本地源读取。

```bash
mv CentOS-Base.repo CentOS-Base.repo.bak
```

4、创建挂载点，并把光盘上的镜像挂在到目录上

创建挂载点

```bash
mkdir /mnt/cdrom
```

将镜像文件挂载到创建的挂载点上

```bash
mount /dev/cdrom /mnt/cdrom
```

5、更新yum源，更新执行命令，顺序执行

```bash
yum clean all
```

```
yum makecache
```

6、最后再去修改CentOS-Media.repo，你会发现后面多了点东西

```bash
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
```

可以把原来的删掉，或者设置为禁用。，把新生成的enabled=0修改成enabled=1

7、开始极乐之旅

```bash
yum install httpd
```



**[gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5 报获取 GPG 密钥失败](https://blog.csdn.net/grantxx/article/details/8509480)**

获取 GPG 密钥失败：[Errno 14]

2011-05-26 14:43

每个 fusion源发布的稳定 RPM 软件包都配有一个 GPG 签名。默认情况下，yum 和图形更新工具验证这些签名并拒绝安装任何没有签名或者签名损坏的软件包。您总是应该在安装软件包之前验证其签名。这些签名可确保您要安装的软件包出自fusion仓库，且没有被提供该软件包的网页或者镜像更换（无意的或者恶意的）。



而我们安装fusion源的时候，默认是没有添加gpg[密钥](https://so.csdn.net/so/search?q=密钥&spm=1001.2101.3001.7020)的，所以安装软件的时候会出现想

获取 GPG 密钥失败：[Errno 14] Could not open/read file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-fedora-15-x86_64

这种错误，那么怎么解决呢？

**处理方法一：导入密钥**

打开fusion源官网上的密钥页面：<http://rpmfusion.org/keys>



RPM Fusion free for Fedora 8, 9 and 10

Download; key in pgp.mit.edu; fingerprint: 

pub 1024D/49C8885A 2008-07-12 Key fingerprint = 870F EA14 0067 8204 7151 BA87 8550 99B2 49C8 885Auid RPM Fusion repository (Fedora - free) <rpmfusion-buildsys@lists.rpmfusion.org>sub 2048g/A2F04C4B 2008-07-12



第一行就是密钥对应的系统的版本,你用的是什么版本的系统就选择对于的密钥，然后点击download下载密钥,

因为小狼的是fedora15,所有下载后的文件是

RPM-GPG-KEY-rpmfusion-free-fedora-15

这样的，然后打开终端

su获取root权限，再输入以下命令:

rpm --import ' /home/XXX/RPM-GPG-KEY-rpmfusion-free-fedora-15'

后面的目录换成你下载的密钥文件的绝对路径，也可以把文件直接托进终端，系统会自动填写文件的地址的

回车执行，再试一下安装软件～是不是已经解决了呢？



**处理方法二**：

发现虚拟机系统版本为在CentOS6.8，更改CentOS-Media.repo后恢复正常

```
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
```



# [yum命令详解和报错 Cannot find a valid baseurl for repo: base](https://blog.csdn.net/u012060033/article/details/113790542)

# 1 [yum](https://so.csdn.net/so/search?q=yum&spm=1001.2101.3001.7020)命令

## 1.1 yum简介

`yum`，是`Yellow dog Updater Modified` 的简称，是杜克大学为了提高`RPM` 软件包安装性而开发的一种软件包管理器。起初是由`yellow dog `这一发行版的开发者Terra Soft 研发，用`python`写成，那时还叫做yup(yellow dog updater)，后经杜克大学的Linux@Duke 开发团队进行改进，遂有此名。
`yum` 的宗旨是自动化地升级，`安装/移除rpm 包`，收集rpm 包的相关信息，检查依赖性并自动提示用户解决。yum 的关键之处是要有可靠的repository，顾名思义，这是软件的仓库，它可以是http 或ftp 站点，也可以是本地软件池，但必须包含rpm 的header，header 包括了rpm 包的各种信息，包括描述，功能，提供的文件，依赖性等。正是收集了这些header 并加以分析，才能自动化地完成余下的任务。
`yum` 的理念是使用一个中心仓库(`repository`)管理一部分甚至一个`distribution `的应用程序相互关系，根据计算出来的软件依赖关系进行相关的升级、安装、删除等等操作，减少了`Linux`用户一直头痛的`dependencies`的问题。这一点上，yum 和apt 相同。apt 原为debian 的deb 类型软件管理所使用，但是现在也能用到RedHat 门下的rpm 了。
`yum`主要功能是更方便的添加/删除/更新`RPM`包，自动解决包的倚赖性问题，便于管理大量系统的更新问题。
`yum`可以同时配置多个资源库(Repository)，简洁的配置文件（`/etc/yum.conf`），自动解决增加或删除rpm 包时遇到的依赖性问题，保持与`RPM` 数据库的一致性

[常用命令参考](https://jingzh.blog.csdn.net/article/details/106435783)

## 1.2 yum安装

`CentOS` 默认已经安装了`yum`，不需要另外安装，这里为了实验目的，先将`yum` 卸载再重新安装。

1. 查看系统默认安装的yum

```shell
rpm -qa|grep yum
```

1. 卸载yum

```shell
rpm -e yum-fastestmirror-1.1.16-14.el5.centos.1 yum-metadata-parser-1.1.2-3.el5.centos yum-3.2.22-33.el5.centos
```

1. 重新安装yum

```shell
wget http://yum.baseurl.org/download/3.2/yum-3.2.28.tar.gz
tar xvf yum-3.2.28.tar.gz
```

## 1.3 yum配置

```
yum` 的配置文件分为两部分：`main` 和`repository
```

- `main`部分定义了全局配置选项，整个`yum` 配置文件应该只有一个`main`。常位于`/etc/yum.conf `中。
- `repository`部分定义了每个源/服务器的具体配置，可以有一到多个。常位于`/etc/yum.repo.d` 目录下的各文件中。

```shell
yum.conf `文件一般位于`/etc`目录下，一般其中只包含`main`部分的配置选项`cat /etc/yum.conf
[main]

#cachedir：yum缓存的目录，yum在此存储下载的rpm包和数据库，一般是/var/cache/yum/$basearch/$releasever。
cachedir=/var/cache/yum/$basearch/$releasever 

#keepcache：是否保留缓存内容，0：表示安装后删除软件包，1表示安装后保留软件包
keepcache=1

#debuglevel：除错级别，0──10,默认是2 貌似只记录安装和删除记录
debuglevel=2

#logfile：存放系统更新软件的日志的目录。用户可以到/var/log/yum.log文件去查询自己在过去的日子里都做了哪些更新。
logfile=/var/log/yum.log

#pkgpolicy： 包的策略。一共有两个选项，newest和last，这个作用是如果你设置了多个repository，而同一软件在不同的repository中同时存 在，yum应该安装哪一个，如果是newest，则yum会安装最新的那个版本。如果是last，则yum会将服务器id以字母表排序，并选择最后的那个 服务器上的软件安装。一般都是选newest。
pkgpolicy=newest

#指定一个软件包，yum会根据这个包判断你的发行版本，默认是RedHat-release，也可以是安装的任何针对自己发行版的rpm包。
distroverpkg=CentOS-release

#tolerent，也有1和0两个选项，表示yum是否容忍命令行发生与软件包有关的错误，比如你要安装1,2,3三个包，而其中3此前已经安装了，如果你设为1,则yum不会出现错误信息。默认是0。
tolerant=1

#exactarch，有两个选项1和0,代表是否只升级和你安装软件包cpu体系一致的包，如果设为1，则如你安装了一个i386的rpm，则yum不会用1686的包来升级。
exactarch=1

#retries，网络连接发生错误后的重试次数，如果设为0，则会无限重试。
retries=20

#此选项在进行发行版跨版本升级的时候会用到。
obsoletes=1

#gpgchkeck= 有1和0两个选择，分别代表是否是否进行gpg校验，如果没有这一项，默认是检查的。以确定rpm包的来源是有效和安全的。这个选项如果设置在[main]部分，则对每个repository都有效
gpgcheck=1

#默认都会被include 进来 也就是说 /etc/yum.repos.d/xx.repo 无论配置文件有多少个 每个里面有多少个[name] 最后其实都被整合到 一个里面看就是了 重复的[name]后面的覆盖前面的
reposdir=/etc/yy.rm #默认是 /etc/yum.repos.d/ 低下的 xx.repo后缀文件

#exclude 排除某些软件在升级名单之外，可以用通配符，列表中各个项目要用空格隔开，这个对于安装了诸如美化包，中文补丁的朋友特别有用。
exclude=xxx

#该选项用户指定 .repo 文件的绝对路径。.repo 文件包含软件仓库的信息 (作用与 /etc/yum.conf 文件中的 [repository] 片段相同)。
reposdir=[包含 .repo 文件的目录的绝对路径]
```

## 1.4 配置本地yum源

1. 挂载系统安装光盘

```shell
mount /dev/cdrom /mnt/cdrom/
```

1. 配置本地yum源

```shell
cd /etc/yum.repos.d/
ls
```

`CentOS-Base.repo` 是yum 网络源的配置文件
CentOS-Media.repo 是yum 本地源的配置文件
修改CentOS-Media.repo

```shell
cat CentOS-Media.repo
1
# CentOS-Media.repo
#
# This repo is used to mount the default locations for a CDROM / DVD on
#  CentOS-5.  You can use this repo and yum to install items directly off the
#  DVD ISO that we release.
#
# To use this repo, put in your DVD and use it with the other repos too:
#  yum --enablerepo=c5-media [command]
#  
# or for ONLY the media repo, do this:
#
#  yum --disablerepo=\* --enablerepo=c5-media [command]
 
[c5-media]
name=CentOS-$releasever - Media
baseurl=file:///media/CentOS/
        file:///mnt/cdrom/
        file:///media/cdrecorder/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
```

在`baseurl `中修改第2个路径为`/mnt/cdrom`（即为光盘挂载点）
将`enabled=0`改为`1`

1. 禁用默认的`yum`网络源
   将`yum` 网络源配置文件改名为`CentOS-Base.repo.bak`，否则会先在网络源中寻找适合的包，改名之后直接从本地源读取。
2. 执行yum 命令

```shell
yum install postgresql
```

### 1.4.1 关于repo 文件的格式

所有`repository`服务器设置都应该遵循如下格式：

```shell
[serverid]
name=Some name for this server
baseurl=url://path/to/repository/
```

- `serverid` : 是用于区别各个不同的`repository`，必须有一个独一无二的名称；
- `name` : 是对`repository` 的描述，支持像`$releasever $basearch`这样的变量
  `$releasever`：代表发行版的版本，从`[main]`部分的`distroverpkg`获取，如果没有，则根据`redhat-release`包进行判断
  `$basearch`：cpu的基本体系组，如i686和athlon同属i386，alpha和alphaev6同属alpha
- `baseurl` : 是服务器设置中最重要的部分，只有设置正确，才能从上面获取软件。它的格式是：

> baseurl=url://server1/path/to/repository/
> 　　　　 url://server2/path/to/repository/
> 　　　　 url://server3/path/to/repository/

其中`url `支持的协议有` http:// ftp:// file://` 三种。`baseurl` 后可以跟多个`url`，你可以自己改为速度比较快的镜像站，但`baseurl` 只能有一个，也就是说不能像如下格式：

> baseurl=url://server1/path/to/repository/
> baseurl=url://server2/path/to/repository/
> baseurl=url://server3/path/to/repository/

其中`url` 指向的目录必须是这个`repository header` 目录的上一级，它也支持`$releasever $basearch` 这样的变量。
`url` 之后可以加上多个选项，如`gpgcheck、exclude、failovermethod` 等，比如：

```shell
[updates-released]
name=Fedora Core $releasever - $basearch - Released Updates
baseurl=http://download.atrpms.net/mirrors/fedoracore/updates/$releasever/$basearch
　　　　 http://redhat.linux.ee/pub/fedora/linux/core/updates/$releasever/$basearch
　　　　 http://fr2.rpmfind.net/linux/fedora/core/updates/$releasever/$basearch
gpgcheck=1
exclude=gaim
failovermethod=priority
```

其中`gpgcheck，exclude` 的含义和`[main]` 部分相同，但只对此服务器起作用，`failovermethode` 有两个选项priority和roundrobin ，意思分别是有多个url可供选择时，yum 选择的次序，`roundrobin` 是随机选择，如果连接失败则使用下一个，依次循环，`priority` 则根据`url `的次序从第一个开始。如果不指明，默认是`roundrobin`

## 1.5 配置国内yum源

系统默认的`yum`源速度往往不尽人意，为了达到快速安装的目的，在这里修改`yum`源为国内源

**1.5.1 上海交通大学yum源**

修改`/etc/yum.repos.d/CentOS-Base.repo`为：

```shell
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
baseurl=http://ftp.sjtu.edu.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5

#released updates 
[updates]
name=CentOS-$releasever - Updates
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
baseurl=http://ftp.sjtu.edu.cn/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
baseurl=http://ftp.sjtu.edu.cn/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
baseurl=http://ftp.sjtu.edu.cn/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib
baseurl=http://ftp.sjtu.edu.cn/centos/$releasever/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
```

关于变量

- `$releasever`：代表发行版的版本，从`[main]`部分的`distroverpkg`获取，如果没有，则根据`redhat-release`包进行判断。
- `$arch`：cpu体系，如i686,athlon等
- `$basearch`：cpu的基本体系组，如i686和athlon同属i386，alpha和alphaev6同属alpha。

导入`GPG KEY`
`yum`可以使用`gpg`对包进行校验，确保下载包的完整性，所以我们先要到各个`repository`站点找到`gpg key`，一般都会放在首页的醒目位置，一些名字诸如RPM-GPG-KEY-CentOS-5 之类的纯文本文件，把它们下载下来，然后用rpm --import RPM-GPG-KEY-CentOS-5 命令将key 导入。

**1.5.2 其他国内yum源列表如下**

1. 企业贡献：
   搜狐开源镜像站：http://mirrors.sohu.com/
   网易开源镜像站：http://mirrors.163.com/
   腾讯云软件：https://mirrors.cloud.tencent.com/centos/
   阿里镜像站：http://mirrors.aliyun.com/
2. 大学教学：
   北京理工大学：
   http://mirror.bit.edu.cn (IPv4 only)
   http://mirror.bit6.edu.cn (IPv6 only)
   北京交通大学：
   http://mirror.bjtu.edu.cn (IPv4 only)
   http://mirror6.bjtu.edu.cn (IPv6 only)
   http://debian.bjtu.edu.cn (IPv4+IPv6)
   兰州大学：http://mirror.lzu.edu.cn/
   厦门大学：http://mirrors.xmu.edu.cn/
   清华大学：
   http://mirrors.tuna.tsinghua.edu.cn/ (IPv4+IPv6)
   http://mirrors.6.tuna.tsinghua.edu.cn/ (IPv6 only)
   http://mirrors.4.tuna.tsinghua.edu.cn/ (IPv4 only)
   天津大学：http://mirror.tju.edu.cn/
   中国科学技术大学：
   http://mirrors.ustc.edu.cn/ (IPv4+IPv6)
   http://mirrors4.ustc.edu.cn/
   http://mirrors6.ustc.edu.cn/
   东北大学：
   http://mirror.neu.edu.cn/ (IPv4 only)
   http://mirror.neu6.edu.cn/ (IPv6 only)
   电子科技大学：http://ubuntu.uestc.edu.cn/
   南京大学：http://mirrors.nju.edu.cn/

## 1.6 使用第三方软件库

`Centos/RHEL`默认的`yum`软件仓库非常有限，仅仅限于发行版本那几张盘里面的常规包和一些软件包的更新，利用`RpmForge`，可以增加非常多的第三方`rpm`软件包。`RpmForge`库现在已经拥有超过`10000种`的`CentOS`的软件包，被`CentOS`社区认为是最安全也是最稳定的一个第三方软件库。

1. 安装`yum-priorities`插件
   这个插件是用来设置`yum`在调用软件源时的顺序的。因为官方提供的软件源，都是比较稳定和被推荐使用的。因此，官方源的顺序要高于第三方源的顺序。如何保证这个顺序，就需要安装`yum-priorities`这插件了
   `yum -y install yum-priorities`
2. 安装完`yum-priorities`插件后需要设置`/etc/yum.repos.d/`目录下的`.repo`相关文件（如CentOS-Base.repo），在这些文件中插入顺序指令：`priority=N` （N为1到99的正整数，数值越小越优先）
   一般配置`[base], [addons], [updates], [extras]` 的`priority=1`，`[CentOSplus], [contrib]` 的`priority=2`，其他第三的软件源为：`priority=N` （推荐N>10）
   以`CentOS-Base.repo` 为例：

```shell
[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
baseurl=http://ftp.sjtu.edu.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=1
```

1. 下载与安装相应rpmforge的rpm文件包

```shell
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
```

1. 安装DAG的PGP Key
   `rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt`
2. 验证rpmforge的rpm文件包
   `rpm -K rpmforge-release-0.5.2-2.el5.rf.*.rpm`
3. 安装rpmforge的rpm文件包
   `rpm -i rpmforge-release-0.5.2-2.el5.rf.i386.rpm`
4. 设置`/etc/yum.repos.d/rpmforge.repo`文件中源的级别
   `cat rpmforge.repo`

```shell
### Name: RPMforge RPM Repository for RHEL 5 - dag
### URL: http://rpmforge.net/
[rpmforge]
name = RHEL $releasever - RPMforge.net - dag
baseurl = http://apt.sw.be/redhat/el5/en/$basearch/rpmforge
mirrorlist = http://apt.sw.be/redhat/el5/en/mirrors-rpmforge
#mirrorlist = file:///etc/yum.repos.d/mirrors-rpmforge
enabled = 1
protect = 0
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
gpgcheck = 1
priority=12
```

# 2 yum安装报错

## 2.1 错误示例

`yum`命令是用来直接安装软件常用命令，
但是在使用此命令时会有如下错误信息：

```powershell
Loaded plugins: fastestmirror, security
Determining fastest mirrors
YumRepo Error: All mirror URLs are not using ftp, http[s] or file.
Eg. Invalid release/
removing mirrorlist with no valid mirrors: /var/cache/yum/base/mirrorlist.txt
Error: Cannot find a valid baseurl for repo: base
```

网上给的解决方法是修改`DNS`之类的 都尝试过了 ，还是没有解决问题 ， 没办法只好卸载`yum`重新安装，发现问题依旧，于是分析可能是 `yum` 源失效的问题 ， 是不是服务器的 `yum` 源失效了 ， 抱着试试的心态更换了 `yum` 源 ，终于解决了问题

## 2.2 解决方法

**2.2.1 操作步骤**

更换`yum` 源
进入 `yum` 配置文件目录 `cd /etc/yum.repos.d/`
备份配置文件`mv CentOS-Base.repo CentOS-Base.repo.bak`
下载 `163` 的配置文件 `wget http://mirrors.163.com/.help/CentOS6-Base-163.repo`
更名 `mv CentOS6-Base-163.repo CentOS-Base.repo`
`注意：`由于 `163`源迁移的问题 所以这个下载下来的源是同样无法使用的只能自己手动修改

**2.2.2 原来163源**

未改动过的 163 源是这样子的

```shell
[base]
name=CentOS-$releasever - Base - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#released updates 
[updates]
name=CentOS-$releasever - Updates - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/contrib/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6
```

**2.2.3 更改163源**

改动后的163源的示例

```shell
[base]
name=CentOS-$releasever - Base - 163.com
baseurl=http://vault.centos.org/6.7/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
gpgcheck=1
gpgkey=http://vault.centos.org/RPM-GPG-KEY-CentOS-6

#released updates 
[updates]
name=CentOS-$releasever - Updates - 163.com
baseurl=http://vault.centos.org/6.7/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
gpgcheck=1
gpgkey=http://vault.centos.org/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - 163.com
baseurl=http://vault.centos.org/6.7/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
gpgcheck=1
gpgkey=http://vault.centos.org/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - 163.com
baseurl=http://vault.centos.org/6.7/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=1
enabled=0
gpgkey=http://vault.centos.org/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib - 163.com
baseurl=http://vault.centos.org/6.7/contrib/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib
gpgcheck=1
enabled=0
gpgkey=http://vault.centos.org/RPM-GPG-KEY-CentOS-6
```

**2.2.4 注意问题**

首先是网址要改为了 `http://vault.centos.org` 然后删除了`centos` 把 `$releasever` 这个变量自己手动改为了 `6.7`（对应的版本号） 这一步自己琢磨 我是改完之后他还报错 发现是版本号的问题 给我显示的 `6` 而我是 `6.7`的版本，改完之后最好自己先去访问一下有没有对应的文件 以防出错
查看自己服务器版本命令：` cat /etc/redhat-release`
在最后全部执行后开始如下命令：

```shell
yum clean all
yum makecache
```

**2.2.5 更改阿里源**

先备份原来的地址源

```shell
mv /etc/yum.repos.d/CentOS-Base.repo \
/etc/yum.repos.d/CentOS-Base.repo.backup
```

下载`aliyun`的`yum`源配置文件到`/etc/yum.repos.d/`
`CentOS 7`环境:

```shell
wget -O /etc/yum.repos.d/CentOS-Base.repo \
http://mirrors.aliyun.com/repo/Centos-7.repo
```

`CentOS 6`环境:

```shell
wget -O /etc/yum.repos.d/CentOS-Base.repo \
http://mirrors.aliyun.com/repo/Centos-6.repo
```

`CentOS 5`环境:

```shell
wget -O /etc/yum.repos.d/CentOS-Base.repo \
http://mirrors.aliyun.com/repo/Centos-5.repo
```

运行`yum makecache`生成缓存

```shell
yum makecache
```



# [yum源的三种安装配置方式，总有一款适合你](https://blog.csdn.net/weixin_45551608/article/details/117360402)

## 一、yum本地源安装

第一步：将官方yum源相关的配置文件备份到repo.bak目录中，创建本地yum源的配置文件

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528135004656.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第二步：在本地yum源的配置文件添加相关配置如下：

```
[local]
name=local
baseurl=file:///mnt
enabled=1
gpgcheck=0
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528164444956.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

yum源的配置内容解释如下：

[ local ]：代表源的名字，中括号要存在，里面的名字可以随便取，但是不能有两个相同的yum源名称；
name：只是说明一下这个yum源的意义而已，重要性不高；
baseurl=：这个最重要，后面接的是yum源的实际地址，这里代表文件目录为mnt；
enable=1：就是让这个yum源被启动，如果不想启用可以使用enable=0；
gpgcheck=0：0代表不查看RPM文件内的数字签名，如果设置为“1”则代表需要查看RPM的数字签名。
gpgkey=：后面跟着RPM的数字签名的公钥文件所在位置，使用默认值即可。

第三步：挂载镜像文件，清除yum缓存并更新

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528222646503.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

挂载失败检查【虚拟机设置】的光盘镜像是否选择，【设备状态】是否为已连接和启动时连接


第四步：查看yum源信息，并使用yum本地源进行安装测试

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528225746470.png)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528171547241.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第五步：设置自动挂载

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528224331866.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

## 二、安装阿里云在线yum源

第一步：进行网络测试，保证能正常连接外网：ping www.baidu.com通

第二步：将我们配置的本地源也移动到repo.bak目录中。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528172334480.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第三步： 将阿里云镜像下载到/etc/yum.repos.d/目录下

```
先备份原来的:
mv CentOS-Base.repo CentOS-Base.back.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
```

第四步：清理缓存并且生成新的缓存（如果是从本地源修改过来的记得先使用umount /dev/cdrom进行解挂载）

```
yum clean all && yum makecache
```

第五步：查看yum源信息，安装程序进行测试yum源是否配置成功

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528225545794.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528223630631.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

## 三、远程访问yum源

第一步：服务端安装httpd服务，并开启

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210528233704274.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第二步：服务端解除挂载，然后新建/var/www/html/shareyum目录后创建挂载

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529093508377.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第三步：客户端添加服务器的yum源地址

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529095753427.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第五步：客户端上将其他yum源移至备份目录repo.vak中（如阿里源、本地源和官方在线源等）

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529095916650.png)


第五步：客户端查看yum源信息，并安装程序进行测试

![ ](https://img-blog.csdnimg.cn/2021052910091570.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529100951681.png)

## 四、设置yum阿里源和本地源同时存在

第一步：可以看到我这边阿里源和本地源同时存在，我们在装软件包的时候当然希望先用本地的yum源去安装，
本地找不到可用的包时再使用aliyun源去安装软件,这里就涉及到了优先级的问题

![在这里插入图片描述](https://img-blog.csdnimg.cn/202105291030376.png)

第二步：使用yum提供的插件yum-plugin-priorities.noarch解决这个问题,安装yum install -y yum-plugin-priorities.noarch

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529104911566.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第三步：查看插件是否启用.cat /etc/yum/pluginconf.d/priorities.conf

![在这里插入图片描述](https://img-blog.csdnimg.cn/2021052910503112.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第四步：修改本地yum源优先使用，vim local.repo

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529104729497.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第五步：可显示所有仓库包

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529110035832.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

第六步：安装本地源内没有的程序进行测试是否能自动选择阿里源

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529110250788.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210529110309987.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTU1MTYwOA==,size_16,color_FFFFFF,t_70)



# [Linux alternatives 命令](https://www.cjavapy.com/article/2310/)

> Linux命令是对Linux系统进行管理的命令。对于Linux系统来说，无论是中央处理器、内存、磁盘驱动器、键盘、鼠标，还是用户等都是文件，Linux系统管理的命令是它正常运行的核心，与之前的DOS命令类似。linux命令在系统中有两种类型：内置Shell命令和Linux命令。本文主要介绍Linux alternatives 命令。

## 1、命令简介

alternatives是Linux下的一个功能强大的命令。只能在root权限下执行。如系统中有几个命令功能十分类似，却又不能随意删除，则可以用 alternatives 来指定一个全局的设置。

alternatives是专门维护系统命令链接符的工具，其可以对某个工具的多个软件版本进行管理，通过它可以很方便的设置系统默认使用哪个命令的哪个软件版本
**==alternatives和update-alternatives其实一个命令，均指向alternatives==**

## 2、命令用法

```
alternatives [options] --install link name path priority [--slave link name path]... [--initscript service]
alternatives [options] --remove name path
alternatives [options] --set name path
alternatives [options] --auto name
alternatives [options] --display name
alternatives [options] --config name
```

| install  | 表示安装         |
| -------- | ---------------- |
| link     | 是符号链接       |
| name     | 则是标识符       |
| path     | 是执行文件的路径 |
| priority | 则表示优先级     |

查看链接：ls -l  [+ link]

```powershell
[root@elephant default] ls -l  /usr/bin/java
lrwxrwxrwx. 1 root root 22 Nov  8 08:23 /usr/bin/java -> /etc/alternatives/java
[root@elephant default] ls -l /etc/alternatives/java
lrwxrwxrwx. 1 root root 26 Nov  8 08:23 /etc/alternatives/java -> /usr/java/default/bin/java
```

系统路径/usr/bin/<name>这个软链接，指向了/etc/alternatives/<name>这个软链接，该软链接指向了该<name>命令的实际可执行文件；

上面例子通过两次软链接，我们可以定位到实际的java文件；

## 3、命令描述

alternatives创建、删除、维护和显示关于组成备选项系统的符号链接的信息。替代系统是Debian替代系统的重新实现。重写它主要是为了消除对perl的依赖;它的目的是取代Debian的更新依赖脚本。此手册页是Debian项目手册页的一个轻微修改版本。

在一个系统上，可以同时安装多个实现相同或类似功能的程序。例如，许多系统同时安装多个文本编辑器。这为系统的用户提供了选择，允许每个用户在需要时使用不同的编辑器，但如果用户没有指定特定的首选项，则程序很难选择要调用的编辑器。

alternatives旨在解决这个问题。文件系统中的通用名称由提供可互换功能的所有文件共享。alternatives和系统管理员共同决定这个通用名称引用的实际文件。例如，如果系统上同时安装了文本编辑器**ed(1)**和**nvi(1)**，那么替代的系统将使通用名`/usr/bin/editor`默认指向`/usr/bin/nvi`。系统管理员可以覆盖此设置，并使其指向`/usr/bin/ed`，而alternatives将不会更改此设置，直到明确要求这样做。

通用名不是指向所选备选项的直接符号链接。相反，它是指向alternative目录中某个名称的符号链接，而该名称又是指向所引用的实际文件的符号链接。

当安装、更改或删除提供具有特定功能的文件的每个包时，将调用替代来更新alternatives中关于该文件的信息。alternative通常从RPM包中的`%post`或`%pre`脚本调用。

将多个alternatives同步是很有用的，这样它们就可以作为一个组进行更改;例如，当安装了多个版本的vi(1)编辑器时，`/usr/share/man/man1/vi.1`应该对应于`/usr/bin/vi`引用的可执行文件。alternatives通过主和从链接来处理这个问题;当主服务器被更改时，任何关联的从服务器也会被更改。一个主链路和它关联的从链路组成一个链路组。

<iframe id="aswift_3" name="aswift_3" sandbox="allow-forms allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts allow-top-navigation-by-user-activation" width="941" height="280" frameborder="0" marginwidth="0" marginheight="0" vspace="0" hspace="0" allowtransparency="true" scrolling="no" src="https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-6349629766850590&amp;output=html&amp;h=280&amp;adk=1412611381&amp;adf=1441705490&amp;pi=t.aa~a.128779072~i.19~rp.4&amp;w=941&amp;fwrn=4&amp;fwrnh=100&amp;lmt=1662604802&amp;num_ads=1&amp;rafmt=1&amp;armr=3&amp;sem=mc&amp;pwprc=5072308212&amp;psa=1&amp;ad_type=text_image&amp;format=941x280&amp;url=https%3A%2F%2Fwww.cjavapy.com%2Farticle%2F2310%2F&amp;fwr=0&amp;pra=3&amp;rh=200&amp;rw=940&amp;rpe=1&amp;resp_fmts=3&amp;wgl=1&amp;fa=27&amp;uach=WyJXaW5kb3dzIiwiMTQuMC4wIiwieDg2IiwiIiwiOTguMC40NzU4LjEwMiIsW10sZmFsc2UsbnVsbCwiNjQiLFtbIiBOb3QgQTtCcmFuZCIsIjk5LjAuMC4wIl0sWyJDaHJvbWl1bSIsIjk4LjAuNDc1OC4xMDIiXSxbIkdvb2dsZSBDaHJvbWUiLCI5OC4wLjQ3NTguMTAyIl1dLGZhbHNlXQ..&amp;dt=1662604801983&amp;bpp=1&amp;bdt=3863&amp;idt=1&amp;shv=r20220901&amp;mjsv=m202209010201&amp;ptt=9&amp;saldr=aa&amp;abxe=1&amp;cookie=ID%3D7fbe0d228cfa8739-22ef0a6446d600d2%3AT%3D1662604799%3ART%3D1662604799%3AS%3DALNI_MYpQr79OK9Oapgw8PDRA31ZpHIx7A&amp;gpic=UID%3D0000099461085ada%3AT%3D1662604799%3ART%3D1662604799%3AS%3DALNI_MaDOP21gks-cLENUlxmMmclFrcdxQ&amp;prev_fmts=0x0%2C193x600%2C941x280&amp;nras=3&amp;correlator=5329712895662&amp;frm=20&amp;pv=1&amp;ga_vid=1204039606.1662604800&amp;ga_sid=1662604801&amp;ga_hid=1111049300&amp;ga_fc=1&amp;u_tz=480&amp;u_his=2&amp;u_h=864&amp;u_w=1536&amp;u_ah=816&amp;u_aw=1536&amp;u_cd=24&amp;u_sd=1.25&amp;dmc=8&amp;adx=289&amp;ady=1776&amp;biw=1519&amp;bih=714&amp;scr_x=0&amp;scr_y=300&amp;eid=44759875%2C44759926%2C44759837%2C31062931&amp;oid=2&amp;pvsid=4165747248630188&amp;tmod=741170837&amp;uas=0&amp;nvt=1&amp;ref=https%3A%2F%2Flink.csdn.net%2F%3Ftarget%3Dhttps%253A%252F%252Fwww.cjavapy.com%252Farticle%252F2310%252F&amp;eae=0&amp;fc=1408&amp;brdim=0%2C0%2C0%2C0%2C1536%2C0%2C1536%2C816%2C1536%2C714&amp;vis=1&amp;rsz=%7C%7Cs%7C&amp;abl=NS&amp;fu=128&amp;bc=31&amp;ifi=4&amp;uci=a!4&amp;btvi=3&amp;fsb=1&amp;xpc=4CuSetazvV&amp;p=https%3A//www.cjavapy.com&amp;dtd=33" data-google-container-id="a!4" data-google-query-id="CKKDh8SVhPoCFcpFKgodhegL2Q" data-load-complete="true" style="box-sizing: inherit; left: 0px; position: absolute; top: 0px; border: 0px; width: 941px; height: 280px;"></iframe>

在任何给定的时间，每个链接组处于两种模式之一:自动或手动。当一个组处于自动模式时，当包被安装和删除时，alternatives将自动决定是否以及如何更新链接。在手动模式下，alternatives不会改变链接;它将把所有决策留给系统管理员。

当链路组第一次被引入系统时，它们处于自动模式。如果系统管理员更改了系统的自动设置，下一次在已更改链接的组上运行alternatives时将会注意到这一点，并且该组将自动切换到手动模式。

每个选项都有一个与之相关联的优先级。当链接组处于自动模式时，该组成员所指向的选项将是优先级最高的选项。

当使用`--config`选项时，其他选项将列出名称为主链接的链接组的所有选项。然后将提示为链接组使用哪个选项。一旦你做了改变，链接组将不再处于自动模式。需要使用`--auto`选项以返回自动状态。

## 4、命令选项 

| 选项                                                         | 说明                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| --install link name path pri [--slave slink sname spath] [--initscript service]... |                                                              |
|                                                              | 向系统添加一组alternatives。name是主链接的通用名称，link是它的符号链接的名称，path是为主链接引入的替代方法。Sname、slink和spath是通用名、符号链接名和从链接的替代名，service是替代名的任何相关初始化脚本的名称。注意：--initscript是Red Hat Linux特有的选项。可以指定零个或多个--slave选项，每个选项后面跟着三个参数。 |
|                                                              | 如果指定的主符号链接已经存在于alternatives的记录中，则提供的信息将作为组的一组新的alternatives添加。否则，将使用此信息添加一个设置为自动模式的新组。如果该组处于自动模式，并且新添加的alternatives的优先级高于该组中任何已安装的alternatives，则符号链接将被更新以指向新添加的alternatives。如果使用--initscript，alternatives将通过chkconfig管理与alternatives相关联的初始化脚本，根据哪个alternatives是活动的注册和注销初始化脚本。注意:--initscript是Red Hat Linux特有的选项。 |
| --remove name path                                           |                                                              |
|                                                              | 删除一个alternatives及其所有关联的从链接。name是alternative目录中的名称，path是名称可以链接到的绝对文件名。如果name确实链接到path，则name将被更新为指向另一个合适的alternatives，如果没有这样的alternatives，则删除。相应的，相关的从链接将被更新或删除。如果链接当前没有指向路径，则不会更改链接;只有关于alternatives的信息被删除。 |
| --set name path                                              |                                                              |
|                                                              | link group name的符号link和slave设置为path的符号，link和slave, link group设置为manual模式。这个选项在最初的Debian实现中没有。 |
| --config name                                                |                                                              |
|                                                              | 为用户提供一个配置菜单，用于选择链接组名的主链接和从链接。一旦选择，链接组被设置为手动模式。 |
| --auto name                                                  |                                                              |
|                                                              | 将主符号链接名称切换到自动模式。在这个过程中，这个符号链接和它的slaves被更新到指向最高优先级的已安装的alternatives。 |
| --display name                                               |                                                              |
|                                                              | 显示名称为主链路的链路组信息。显示的信息包括组的模式(自动或手动)、符号链接当前指向的alternatives、可用的其他alternatives(及其相应的从alternatives)以及当前安装的最高优先级alternatives。 |

## 5、使用示例

```powershell
 alternatives --install /usr/bin/java java /tools/jdk/bin/java 3
 alternatives --config java

There are 3 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
*+ 1           /usr/lib/jvm/jre-1.7.0-icedtea/bin/java
   2           /usr/lib/jvm/jre-1.5.0-gcj/bin/java
   3           /tools/jdk/bin/java

Enter to keep the current selection[+], or type selection number: 3
```

## 6、相关文档 

| 选项                   | 说明                                             |
| ---------------------- | ------------------------------------------------ |
| /etc/alternatives/     |                                                  |
|                        | 默认的alternatives目录。可以被--altdir选项覆盖。 |
| /var/lib/alternatives/ |                                                  |
|                        | 默认的管理目录。可以由--admindir选项覆盖。       |

## [其他用法](https://blog.csdn.net/bhniunan/article/details/104077930?ops_request_misc=&request_id=&biz_id=102&utm_term=%E8%BD%AF%E8%BF%9E%E6%8E%A5&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-1-104077930.nonecase&spm=1018.2226.3001.4187)

   软连接是linux中一个常用命令，它的功能是为某一个文件在另外一个位置建立一个同步的链接。软连接类似与c语言中的指针，传递的是文件的地址；更形象一些，软连接类似于WINDOWS系统中的快捷方式。

   例如，在a文件夹下存在一个文件hello，如果在b文件夹下也需要访问hello文件，那么一个做法就是把hello复制到b文件夹下，另一个做法就是在b文件夹下建立hello的软连接。通过软连接，就不需要复制文件了，相当于文件只有一份，但在两个文件夹下都可以访问。

  创建软连接的方法需要使用下面的命令

```
ln  -s  [源文件或目录]  [目标文件或目录]
```

如下实例

```
ln –s  ./a/test  ./b/hello
```

它的作用是将当前路径下的a文件夹中的test文件，在当前路径的b文件夹中建立软连接，并且用一个新的名字为hello



## 软链接与硬链接

1、定义不同

软链接又叫符号链接，这个文件包含了另一个文件的路径名。可以是任意文件或目录，可以链接不同文件系统的文件。

硬链接就是一个文件的一个或多个文件名。把文件名和计算机文件系统使用的节点号链接起来。因此我们可以用多个文件名与同一个文件进行链接，这些文件名可以在同一目录或不同目录。

2、限制不同

硬链接只能对已存在的文件进行创建，不能交叉文件系统进行硬链接的创建；

软链接可对不存在的文件或目录创建软链接；可交叉文件系统；

3、创建方式不同

硬链接不能对目录进行创建，只可对文件创建；

软链接可对文件或目录创建；

4、影响不同

删除一个硬链接文件并不影响其他有相同 inode 号的文件。

删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为死链接（即 dangling link，若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。



# [Linux-创建用户组和用户](https://blog.csdn.net/JustDI0209/article/details/123739690)

**1.前提**
创建用户组和用户均需要管理员权限，要么是 root 用户，要么是现用户有 sudo 权限。

下面的命令大部分是基于 sudo 权限

**2.用户组**
创建用户组

```
sudo groupadd 组名
```


查看用户组

```
cat /etc/group
```


删除用户组

```
sudo groupdel 组名
```

**3.用户**

创建用户

```
sudo useradd -m -g 组名 新建用户名
```

-m 自动为新建的用户创建家目录，-g 所属用户组

查看用户

```
cat /etc/passwd
```


设置用户密码

```
sudo passwd 用户名
```


 删除用户

```
sudo userdel -r 用户名
```

-r 把用户的家目录一起删除




 切换用户

```
sudo su 用户名
```

设置密码后，切换用户需要输入密码，然后 cd 就会去到自动创建的当前用户的家目录


也可以使用

```
sudo su - 用户名
```

直接到了用户的家目录
退出当前用户

```
exit
```

**其他命令**

```
#查看用户 UID 和 GID 信息
id

#查看当前登录的用户列表
who

#查看当前用户的账户名
whoami
```

**4.其他**
改变文件或文件夹归属组和用户

```
sudo chown -R 用户名:组名 文件名或文件夹名
```

- -R：递归更改文件属组，就是在更改某个目录文件的属组时，如果加上-R的参数，那么该目录下的所有文件的属组都会更改。

# [更改文件权限属性命令](https://www.runoob.com/linux/linux-file-attr-permission.html)

### 1、chgrp：更改文件属组

语法：

```
chgrp [-R] 属组名 文件名
```

参数选项

- -R：递归更改文件属组，就是在更改某个目录文件的属组时，如果加上-R的参数，那么该目录下的所有文件的属组都会更改。

### 2、chown：更改文件属主，也可以同时更改文件属组

语法：

```
chown [–R] 属主名 文件名
chown [-R] 属主名：属组名 文件名
```

进入 /root 目录（~）将install.log的拥有者改为bin这个账号：

```
[root@www ~] cd ~
[root@www ~]# chown bin install.log
[root@www ~]# ls -l
-rw-r--r--  1 bin  users 68495 Jun 25 08:53 install.log
```

将install.log的拥有者与群组改回为root：

```
[root@www ~]# chown root:root install.log
[root@www ~]# ls -l
-rw-r--r--  1 root root 68495 Jun 25 08:53 install.log
```

### 3、chmod：更改文件9个属性

Linux文件属性有两种设置方法，一种是数字，一种是符号。

Linux 文件的基本权限就有九个，分别是 **owner/group/others(拥有者/组/其他)** 三种身份各有自己的 **read/write/execute** 权限。

先复习一下刚刚上面提到的数据：文件的权限字符为： **-rwxrwxrwx** ， 这九个权限是三个三个一组的！其中，我们可以使用数字来代表各个权限，各权限的分数对照表如下：

- r:4
- w:2
- x:1

每种身份(owner/group/others)各自的三个权限(r/w/x)分数是需要累加的，例如当权限为： **-rwxrwx---** 分数则是：

- owner = rwx = 4+2+1 = 7
- group = rwx = 4+2+1 = 7
- others= --- = 0+0+0 = 0

所以等一下我们设定权限的变更时，该文件的权限数字就是 **770**。变更权限的指令 chmod 的语法是这样的：

```
 chmod [-R] xyz 文件或目录
```

选项与参数：

- **xyz** : 就是刚刚提到的数字类型的权限属性，为 **rwx** 属性数值的相加。
- **-R** : 进行递归(recursive)的持续变更，以及连同次目录下的所有文件都会变更

举例来说，如果要将 **.bashrc** 这个文件所有的权限都设定启用，那么命令如下：

```
[root@www ~]# ls -al .bashrc
-rw-r--r--  1 root root 395 Jul  4 11:45 .bashrc
[root@www ~]# chmod 777 .bashrc
[root@www ~]# ls -al .bashrc
-rwxrwxrwx  1 root root 395 Jul  4 11:45 .bashrc
```

那如果要将权限变成 *-rwxr-xr--* 呢？那么权限的分数就成为 [4+2+1][4+0+1][4+0+0]=754。

### 符号类型改变文件权限

还有一个改变权限的方法，从之前的介绍中我们可以发现，基本上就九个权限分别是：

- user：用户
- group：组
- others：其他

那么我们就可以使用 **u, g, o** 来代表三种身份的权限。

此外， **a** 则代表 **all**，即全部的身份。读写的权限可以写成 **r, w, x**，也就是可以使用下表的方式来看：



| chmod | u g o a | +(加入) -(除去) =(设定) | r w x | 文件或目录 |
| ----- | ------- | ----------------------- | ----- | ---------- |
|       |         |                         |       |            |

如果我们需要将文件权限设置为 **-rwxr-xr--** ，可以使用 **chmod u=rwx,g=rx,o=r 文件名** 来设定:

```
#  touch test1    // 创建 test1 文件
# ls -al test1    // 查看 test1 默认权限
-rw-r--r-- 1 root root 0 Nov 15 10:32 test1
# chmod u=rwx,g=rx,o=r  test1    // 修改 test1 权限
# ls -al test1
-rwxr-xr-- 1 root root 0 Nov 15 10:32 test1
```

而如果是要将权限去掉而不改变其他已存在的权限呢？例如要拿掉全部人的可执行权限，则：

```
#  chmod  a-x test1
# ls -al test1
-rw-r--r-- 1 root root 0 Nov 15 10:32 test1
```



# [linux查看所有用户](https://blog.csdn.net/web15286201346/article/details/126595972)

**1、Linux里查看所有用户**
(1)在终端里.其实只需要查看cd /etc/passwd文件就行了.
(2)看第三个参数:500以上的,就是后面建的用户了.其它则为系统的用户.
或者用

cat /etc/passwd |cut -f 1 -d :

**2、用户管理命令**
useradd 注：添加用户
adduser 注：添加用户
passwd 注：为用户设置密码
usermod 注：修改用户命令，可以通过usermod 来修改登录名、用户的家目录等等;
pwcov 注：同步用户从/etc/passwd 到/etc/shadow
pwck 注：pwck是校验用户配置文件/etc/passwd 和/etc/shadow 文件内容是否合法或完整;
pwunconv 注：是pwcov 的立逆向操作，是从/etc/shadow和 /etc/passwd 创建/etc/passwd ，然后会删除 /etc/shadow 文件;
finger 注：查看用户信息工具
id 注：查看用户的UID、GID及所归属的用户组
chfn 注：更改用户信息工具
su 注：用户切换工具
sudo 注：sudo 是通过另一个用户来执行命令(execute a command as another user)，su 是用来切换用户，然后通过切换到的用户来完成相应的任务，但sudo 能后面直接执行命令，比如sudo 不需要root 密码就可以执行root 赋与的执行只有root才能执行相应的命令;但得通过visudo 来编辑/etc/sudoers来实现;
visudo 注：visodo 是编辑 /etc/sudoers 的命令;也可以不用这个命令，直接用vi 来编辑 /etc/sudoers 的效果是一样的;
sudoedit 注：和sudo 功能差不多;

**3、管理用户组(group)的工具或命令;**

groupadd 注：添加用户组;
groupdel 注：删除用户组;
groupmod 注：修改用户组信息
groups 注：显示用户所属的用户组
grpck
grpconv 注：通过/etc/group和/etc/gshadow 的文件内容来同步或创建/etc/gshadow ，如果/etc/gshadow 不存在则创建;
grpunconv 注：通过/etc/group 和/etc/gshadow 文件内容来同步或创建/etc/group ，然后删除gshadow文件

**非root用户使用sudo报错：mysql is not in the sudoers file. This incident will be reported.**
1.切换到root用户下
2.添加sudo文件的写权限,命令是:

```
chmod u+w /etc/sudoers
```

给/etc/sudoers所属用户u +（增加）w（write写）权限

3.编辑sudoers文件

```
vi /etc/sudoers
```

找到这行 root ALL=(ALL) ALL,在他下面添加：

用户名 ALL=(ALL) ALL

找到这行 root ALL=(ALL) ALL,在他下面添加用户名 ALL=(ALL) ALL

```
root    ALL=(ALL)       ALL
maven   ALL=(ALL)       ALL
nginx   ALL=(ALL)       ALL
mysql   ALL=(ALL)       ALL
```

添加下面四行中任意一条

> youuser ALL=(ALL) ALL
> %yougroup ALL=(ALL) ALL
> youuser ALL=(ALL) NOPASSWD: ALL
> %yougroup ALL=(ALL) NOPASSWD: ALL
>
> 第一行:允许用户youuser执行sudo命令(需要输入密码).
> 第二行:允许用户组yougroup 里面的用户执行sudo命令(需要输入密码).
> 第三行:允许用户youuser执行sudo命令,并且在执行的时候不输入密码.
> 第四行:允许用户组yougroup 里面的用户执行sudo命令,并且在执行的时候不输入密码.

添加下面四行中任意一条
youuser ALL=(ALL) ALL
%youuser ALL=(ALL) ALL
youuser ALL=(ALL) NOPASSWD: ALL
%youuser ALL=(ALL) NOPASSWD: ALL

4.撤销sudoers文件写权限,命令:

```
chmod u-w /etc/sudoers
```

这样普通用户就可以使用sudo了


这样普通用户就可以使用sudo了
