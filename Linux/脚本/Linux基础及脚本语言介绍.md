# [Linux基础及脚本语言](https://zhuanlan.zhihu.com/p/83578951)

## Linux基础

选择 Linux 还是 Windows？这个话题曾经在网上吵得很热，也许现在还有人在争论。一般而言，使用 Linux 的 优势要远远高于使用 Windows，原因简单列举如下：[[1\]](https://zhuanlan.zhihu.com/p/83578951#ref_1)

- 大多数科研专用的软件都是在 Linux 下开发的，然后再移植到 Windows 下，因而这类软件在 Windows 下 相对来说有更多的 Bug；
- 很多开源的代码是在 Linux 下写的，然后用 **gcc** 或 **gfotran** 编译的。理论上，只要程序写的时候考虑的可移植性，在 Windows 下编译是没有问题的，但实际上大多数代码都需要经过一番修改；
- Windows 自带了批处理工具（Batch）以及 Shell（PowerShell），可以用于完成数据的批处理； 但前者功能太单一，后者用的人又很少，所以两者都不是合适的选择；
- Linux 下自带了多种 Shell（Bash、csh、zsh），以及多个适合数据处理的工具，非常适合用于科研。

要学习 Linux，首先要选择合适的发行版：Ubuntu、Debian 和 Fedora 应该算是比较适合新手的发行版。刚 接触 Linux 的新手可以考虑在虚拟机中安装不同的发行版，每个都尝试一下，找到最适合自己的就好。选择好发 行版之后，还要对发行版的版本代号有一些了解。以 Ubuntu 为例，对于 12.04 和 14.04 是长期支持版，支持周期 为 5 年，而其他版本的支持周期只有一年多。我遇到不少目前还在用 Ubuntu 13.10 的人，（13.10 在 2014 年 7 月 便不再被支持）。这就是在给自己挖坑，系统用的时间越长，重装的代价就越高，想要重装的欲望就越低，重装时 数据丢失的风险也越大。

接下来要选择合适的入门书籍：国内推荐的比较多的是《鸟哥的 Linux 私房菜 – 基础学习篇》，个人觉得其语言过于啰嗦，知识点对于新手来说稍显繁杂；另一本推荐的比较多的是开源的《The Linux Command Line》， 该书有[中文译本](https://link.zhihu.com/?target=http%3A//billie66.github.io/TLCL/book/)。注意，要读的是介绍 Linux 的书，而不是任何介绍 Linux 发行版的书。

对于 Linux 入门需要了解的知识点包括：

- 了解 Linux 的历史，以及 Linux 与各个发行版之间的联系；
- 熟悉 Linux 的目录树，习惯使用命令行，掌握基本命令 **cd** 、 **pwd** 、**mkdir** 、 **rmdir**、 **ls** 、 **cp**、 **rm** 、 **mv** 的基本用法；
- 理解绝对路径和相对路径；
- 理解环境变量 **PATH** 的作用；
- 理解 Linux 文件权限 **rwx** ，掌握 **chmod** 命令；
- 其他几个有用的命令： **cat** 、 **touch** 、 **head** 、 **tail** 、 **which** 、 **locate ;**
- 符号链接 **ln** 与挂载 **mount** ；
- 了解最基本的 vi 编辑器的使用，因为很多时候 vi 是服务器上唯一能使用的编辑器；
- 掌握至少一种高级编辑器的使用，如 vim、emacs、sublime text、atom。怎样才叫掌握？这个问题 没有标准答案，选择其中一个一直用下去，遇到需要重复劳动或者不顺心的地方就去找各种插件配置一下。 像 gedit 这种编辑器不用也罢，用它来写程序效率太低；
- 理解 **~/.bashrc** 文件的作用；
- 理解并学会使用数据流重定向；
- 理解管道的作用及其用途；
- Linux 通配符；
- 掌握压缩相关命令 **tar** 、 **gzip** 、 **bzip2** ，其实最主要的是 **tar** 命令的两种常用方式： **-zxvf** 和 **-jxvf** ；
- 与数据处理相关的命令： **awk** 、 **cut** 、 **grep** 、 **wc** 、 **sort** 、**uniq** ；
- PS：严格地说， awk 已经不单单是一个命令，更像是一种微型语言了。

------

## Bash 及其相关 

Bash 其实本身只是一个空壳，具有最基本的条件判断和循环功能。除此之外，日常需要的数据处理、字符串处理， 都需要借助于 Linux 下的其他命令，比如 **cat** 、 **awk** 、 **grep** 、**cut** 、 **paste** 等等。 因而除了 bash 脚本自身的功能以外，还需要了解的工具包括:

- **awk** ：文本处理工具；
- **sed** ：流编辑器
- **printf** ：格式打印；
- **grep** ：正则表达式匹配；
- 正则表达式；

在科研过程中不推荐使用 Bash 脚本，因为 Bash Shell 与 awk 等命令本质上是独立的个体，二者在设计上有很多 不一致的地方，且 awk 等命令在设计的时候明显有向 Shell 妥协的意味。总之，Bash 脚本中坑比较多，仅仅适合 用几行就可以搞定的情况

## Perl 或 / 和 Python

Perl 和 Python 是另外两种常见的脚本语言。在学会了 Bash 脚本以及相关的各种工具之后为什么还要学习新的 脚本语言呢？因为 Bash 虽然作为 Linux 下最底层最常用的脚本语言，但是其功能过于依赖于外部工具，且难以 实现更加复杂的功能。Perl 和 Python 可以完全自给自足，其内部完全实现了 awk、grep 等工具的功能， 且速度很快，更重要的是 Perl 和 Python 具有模块功能，可以从网上下载各种别人已经写好的模块来实现几乎 所有自己想要的功能。因而 Perl/Python 实际上比 Bash 功能更强大，学起来也并不难。如果有心学习 Perl/Python 的话，可以简单了解 bash 相关知识，然后直接进入更高级的脚本语言。

就目前的情况来看，Perl 适合日常的简单的数据处理，而 Python 适合完成各种复杂的工作同时也适合进行 科学计算。对于新手，更推荐学习 Python。当然最好 Perl 也稍微懂一些。

对于Python的学习，可以参考[菜鸟教程](https://link.zhihu.com/?target=https%3A//www.runoob.com/python3/python3-tutorial.html)。

**以上，编辑于 2019.09.22 晚上**

------

## 最近使用了Linux，新的体会：

- 方便的数据处理：打乱**shuffle**，排序**sort**，取前几个数**head**，取后几个数**tail**，取某列数**awk**
- 可以自动打开一个窗口，变相并行计算：（待补充）
- **gcc**用于编译C语言，**g++**用于编译C++语言
- **Python**的使用很方便，可用于基本的计算和绘图，以及充当胶水语言。同时，它易读，是众多机器学习和深度学习框架的常用语言。它的安装，使用Anaconda即可；其他需要的包例如Pytorch另行安装。



# [Linux 脚本语言入门](http://t.zoukankan.com/hoaprox-p-10904792.html)

## 0、脚本编写初步介绍

（1）脚本第一行以 #!/bin/sh 开始，也可以用 #!/bin/bash 开始，但是第一行必须以这种方式开始.

（2）脚本名需要以.sh结尾

（3）#开头的句子表示注释

（4）若要执行脚本文件，需给脚本赋权限，chmod 755 filenme

（5）脚本执行./filename

# 1、基本语法

## （1）变量：

- **变量的类型：**

运行shell时，会同时存在三种变量：
1) 局部变量
局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。
2) 环境变量
所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。
3) shell变量
shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行

- **特殊变量：**

![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522142158036-1867855019.png)

```
定义变量:
m=100
使用变量:
echo $m
echo ${m}
```

**注:**

1,变量名和等号之间不能有空格;

2,首个字符必须为字母（a-z，A-Z）。

3, 中间不能有空格，可以使用下划线（_）。

4, 不能使用标点符号。

5, 不能使用bash里的关键字（可用help命令查看保留关键字）。

6,对于变量的{} 是可以选择的, 它的目的为帮助解释器识别变量的边界.

7，$* 和 $@ 的区别为: $* 和 $@ 都表示传递给函数或脚本的所有参数，不被双引号(" ")包含时，都以"$1" "$2" … "$n" 的形式输出所有参数。但是当它们被双引号(" ")包含时，"$*" 会将所有的参数作为一个整体，以"$1 $2 … $n"的形式输出所有参数；"$@" 会将各个参数分开，以"$1" "$2" … "$n" 的形式输出所有参数。

8，$? 可以获取上一个命令的退出状态。所谓退出状态，就是上一个命令执行后的返回结果。退出状态是一个数字，一般情况下，大部分命令执行成功会返回 0，失败返回 1。

## （2）shell中的字符串：

- **单引号：**

1. 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
2. 单引号字串中不能出现单引号（对单引号使用转义符后也不行）。

- **双引号：**

1. 双引号里可以有变量
2. 双引号里可以出现转义字符

## （3）shell中的替换：

- **转义符：**

在echo中可以用于的转义符有：

![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522142734577-506759200.png)

- **变量替换**:

可以根据变量的状态（是否为空、是否定义等）来改变它的值.

 ![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522142913666-1817896273.png)

## （4）shell中的运算符：

-  **算术运算符：**

原生bash不支持简单的数学运算，但是可以通过其他命令来实现，例如 awk 和 expr. 下面使用expr进行；  expr是一款表达式计算工具，使用它可以完成表达式的求值操作；

 ![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522142953792-1146233267.png)

- **关系运算符：**

只支持数字，不支持字符串，除非字符串的值是数字。常见的有：

 ![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522143034182-1639275863.png)

- **布尔运算符：**

![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522143056730-788062410.png)

- **字符串运算符：**

 ![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522143114114-396482083.png)

- **文件测试运算符：**

 检测 Unix 文件的各种属性。

![img](https://img2018.cnblogs.com/blog/604038/201905/604038-20190522143145159-1381261423.png)

## （5）shell中的数组：

bash支持一维数组, 不支持多维数组, 它的下标从0开始编号. 用下标[n] 获取数组元素；

- **定义数组：**

在shell中用括号表示数组，元素用空格分开。 如：

```
array_name=(value0 value1 value2 value3)
```

也可以单独定义数组的各个分量，可以不使用连续的下标，而且下标的范围没有限制。如：

```
array_name[0]=value0
array_name[1]=value1
array_name[2]=value2
```

- **读取数组：**

读取某个下标的元素一般格式为:

```
${array_name[index]}
```

读取数组的全部元素，用@或*

```
${array_name[*]}
${array_name[@]}
```

- **获取数组的信息：**

取得数组元素的个数：

```
length=${#array_name[@]}
#或
length=${#array_name[*]}
```

获取数组的下标：

```
length=${!array_name[@]}
#或
length=${!array_name[*]}
```

取得数组单个元素的长度:

```
lengthn=${#array_name[n]}
```

# 2、简单控制语句：

## （1）if 语句：

```
1， if

if  [ 表达式 ] 
then  
  语句  
fi

2.  if else

if  [ 表达式 ] 
then 
  语句 
else 
  语句 
fi

3.  if else if

if  [ 表达式] 
then 
  语句  
elif  [ 表达式 ] 
then 
  语句 
elif  [ 表达式 ] 
then 
  语句
fi
```

例：

```
1， if

a=5
if [ $a -lt 10 ]
then
 echo $a
fi


2.  if else

m=5
if [$m -lt 3 ]
then
  echo $m+1
else
  echo $m
fi

3.  if else if

if [ $1 -lt 3 ]
then
  val=`expr $1 + 1`
  echo $val
elif [ $1 -gt 6 ]
then
  val=`expr $1 - 1`
  echo $val
else
  echo $1
fi
```

注：expr前后为反引号··，运算符+、-前后需要空格

## （2）for循环：

格式：

```
for 变量 in 列表
do
    command1
    command2
    ...
    commandN
done
```

注：列表是一组值（数字、字符串等）组成的序列，每个值通过空格分隔。每循环一次，就将列表中的下一个值赋给变量。

例：

```
for loop in 1 2 3 4 5
do
    echo "The value is: $loop"
done
```

## （3）while循环：

格式：

```
while command
do
   Statement(s) to be executed if command is true
done
```

例：

```
int=1
m=8
while(( $int<=5 ))
do
 m=9
 echo $int
 echo $m
 let "int++"
done
```

- **相关阅读:**
  [常用SQL](http://t.zoukankan.com/shiqi17-p-10538836.html)
  [常用vim命令](http://t.zoukankan.com/shiqi17-p-9944118.html)
  [原生Ajax XMLHttpRequest对象](http://t.zoukankan.com/shiqi17-p-9906145.html)
  [跨域两种解决方案CORS以及JSONP](http://t.zoukankan.com/shiqi17-p-9880520.html)

- 原文地址：https://www.cnblogs.com/hoaprox/p/10904792.html



# [Linux awk 命令](https://www.runoob.com/linux/linux-comm-awk.html)





# [awk命令详解](https://blog.csdn.net/u010502101/article/details/81839519)

awk是linux中处理文本的强大工具，或者说是一种专门处理字符串的语言，它有自己的编码格式。awk的强大之处还在于能生成强大的格式化报告。
awk的命令格式如下：

其中常用选项有 -F、-f等选项，后面会介绍。
例如

```
awk -F: '{print $1}' file
```

表示把file文件中每行数据以“:”分割后，打印出第一个字段。下面详细介绍使用方式。
以下示例如不做说明，均用file文件为例，file文件中数据为：

The dog:There is a big dog and a little dog in the park
The cat:There is a big cat and a little cat in the park
The tiger:There is a big tiger and a litle tiger in the park

# [Shell基础](http://c.biancheng.net/view/706.html)