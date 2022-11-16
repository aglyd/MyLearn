# 快捷键

**Ctrl + B**

*Ctrl  + I*

<u>Ctrl  + U</u>

~~达瓦达瓦~~

`gdgfdgfd`

[超链接快捷键Ctrl + K](https://support.typora.io/Shortcut-Keys/#change-shortcut-keys)

<img src="C:\Users\sever\Pictures\新建文件夹\timg.jpg" alt="FDSFS" style="zoom: 33%;" /> 

| fdsf       | fdsf | ffsdfdfg | 发射点发射点 |
| ---------- | ---- | -------- | ------------ |
| fdskfj房价 | 分为 | 份未发   | 份未发       |
| 范德斯覅   |      |          |              |
| 范德萨     |      |          |              |
|            |      |          |              |



==**高亮**==

``dfds f``

```java
​``` 代码块
    大是大
```

---------------------------



==（1）标题==

# 一级标题

## 二级标题

### 三级标题

#### 四级标题

##### 五级标题

###### 六级标题

==（2）字体==

**加粗**

*斜体*

***斜体加粗***

~~删除线~~

==高亮==

我是^上标^

我是~下标~

==（3）列表==

+ 一二三四五

  + 上山打老虎

    + 老虎没打到

      + 打到小松鼠
        + 上一级多两个空格 +

1. 一二三四五

2. 上山打老虎

3. 老虎没打到

4. 打到小松鼠

==（4）表格==

|  Mon    | TUE    | WED    | THU    | FRI    |

| ------ | ------ | ------ | ------ | ------   |

| 上山   | 上山   | 上山   | 上山   | 上山   |

| 打老虎 | 打老虎 | 打老虎 | 打老虎 | 打老虎 |

==（5）引用==

>一二三四五

>>上山打老虎

>>>老虎没打到

>>>>打到小松鼠

==（6）分割线==

---------------------

==（7）代码==

`我是代码`

```

我是代码框

```

-------------正文结束-------------------

----



# [Typora修改空格样式（blockquote）][https://blog.csdn.net/Cisgodness/article/details/108917740]

Typora修改 >空格 样式（blockquote）
 最近一直在用typora做笔记，经常会用到>空格这个快捷键加一些小标题，如下：



但是这个小模块的样式初始是灰色的，在文字多了的时候会不显眼，也不是那么好看.接下来说一下改样式的方法。

 偏好设置->外观->打开主题文件夹->找到当前主题的文件夹。我使用的是github的主题，就直接修改github.css。


打开该文件后，找到blockquote

![在这里插入图片描述](Typora使用指南.assets/20201004115153134.png)

Border-left就是左边色块的颜色，下面的color是字体颜色，修改成你喜欢的颜色保存。重启typora即可。

 想要修改其他的样式的话，都在这个文件里找到对应的代码进行修改即可。如果不知道对应模块的name，可以通过观察命名和颜色来进行初步的判断。通过idea可以在查看的代码的时候知道该代码的颜色。



---

# Typora 常用快捷键

### for Windows

### 文本编辑快捷键s

- 无序列表：输入-之后输入空格 / ctrl + shift + ] (对选中行可用)
- 有序列表：输入数字+“.”之后输入空格 / ctrl + shift + [ (对选中行可用)
- 引用内容：> + 空格 / ctrl + shift + q (对选中内容可用)
- 任务列表：-[空格]空格 文字
- 标题：ctrl+数字
- 表格：ctrl+t
- 目录：[TOC]
- 任务列表：- [ ] 文字（注意 “-” 后与 “[]“ 中间都有空格）
- 选中一整行：ctrl+l (字母L)
- 选中单词：ctrl+d
- 选中相同格式的文字：ctrl+e
- 跳转到文章开头：ctrl+home
- 跳转到文章结尾：ctrl+end
- 搜索：ctrl+f
- 替换：ctrl+h
- 引用：输入>之后输入空格
- 代码块： ctrl + shift + k / ctrl + shift + ` (对选中行可用)
- 加粗：ctrl+b
- 倾斜：ctrl+i
- 下划线：ctrl+u
- 删除线：alt+shift+5
- 插入图片：直接拖动到指定位置即可或者ctrl+shift+i
- 插入链接：ctrl + k
- 插入公式：ctrl + shift + m

### 编辑模式快捷键

- 源码模式编辑切换：ctrl + /
- 打字机模式切换：F9
- 专注模式切换：F8
- 全屏模式切换：F11
- Typora内部窗口焦点切换：ctrl + tab
- 侧边栏显示/隐藏切换：ctrl + shift + L

### 快捷键自定义配置

> 偏好设置 -> 打开高级设置->conf.user.json文件
> keyBinding 即为快捷键配置：

```text
"keyBinding": {
    // for example: 
    "Always on Top": "Ctrl+Shift+P"
  },
```



一：菜单栏
文件：alt+F
编辑：alt+E
段落：alt+P
格式：alt+O
视图：alt+V
主题：alt+T
帮助：alt+H

二：文件
新建：Ctrl+N
新建窗口：Ctrl+Shift+N
打开：Ctrl+O
快速打开：Ctrl+P
保存：Ctrl+S
另存为：Ctrl+Shift+S
偏好：Ctrl+,
关闭：Ctrl+W

三：编辑
撤销：Ctrl+Z
重做：Ctrl+Y
剪切：Ctrl+X
复制：Ctrl+C
粘贴：Ctrl+V
复制为MarkDown：Ctrl+Shift+C
粘贴为纯文本：Ctrl+Shift+V
全选：Ctrl+A
选中当前行/句：Ctrl+L
选中当前格式文本：Ctrl+E
选中当前词：Ctrl+D
跳转到文首：Ctrl+Home
跳转到所选内容：Ctrl+J
跳转到文末：Ctrl+End
查找：Ctrl+F
查找下一个：F3
查找上一个：Shift+F3
替换：Ctrl+H

四：段落
标题：Ctrl+1/2/3/4/5
段落：Ctrl+0
增大标题级别：Ctrl+=
减少标题级别：Ctrl±
表格：Ctrl+T
代码块：Ctrl+Shift+K
公式块：Ctrl+Shift+M
引用：Ctrl+Shift+Q
有序列表：Ctrl+Shift+[
无序列表：Ctrl+Shift+] 增加缩进：Ctrl+] 减少缩进：Ctrl+[

五：格式
加粗：Ctrl+B
斜体：Ctrl+I
下划线：Ctrl+U
代码：Ctrl+Shift+`
删除线：Alt+Shift+5
超链接：Ctrl+K
图像：Ctrl+Shift+I
清除样式：Ctrl+

六：视图
显示隐藏侧边栏：Ctrl+Shift+L
大纲视图：Ctrl+Shift+1
文档列表视图：Ctrl+Shift+2
文件树视图：Ctrl+Shift+3
源代码模式：Ctrl+/
专注模式：F8
打字机模式：F9
切换全屏：F11
实际大小：Ctrl+Shift+0
放大：Ctrl+Shift+=
缩小：Ctrl+Shift±
应用内窗口切换：Ctrl+Tab
打开DevTools：Shift+F12
