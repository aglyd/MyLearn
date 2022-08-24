# [Oracle 之 Linux基础](https://blog.csdn.net/u012596785/article/details/79936299)

## 三、用户和组

### (一)、用户

UID ~ user id
GID ~ group id

/etc/passwd : id 与账号的对应

登录linux  ~ 账号 ~ uid、gid ～ and 账号的家目录及shell设定

～ /etc/shadow 核对密码

～进入 shell 管控阶段



2.1  /etc/passwd

一行一账号， ～ 系统账号 ，bin, daemon...

例： 

root 系统管理员

root : x : 0 : 0 : root : /root: /bin/bash

root 账号名称 ～ 对应 uid

x  ~  密码  ～ 密码数据移至 /etc/shadow

0  ~  uid ~ 0 系统管理员 ～ 1-499 保留至系统 ～ 500-65535 一般使用者

0  ~  gid ~ /etc/group

root ~ 使用者信息 ， 解释账号意义
/root ~ 使用者的家目录 

/bin/bash ~ SHELL ~ /bin/bash 指令下达



2.2 /etc/shadow

uid,gid 判断权限问题 ~ 

/etc/passwd必须要设定为只读权限

~密码移至 /etc/shadow

shadow, 九个字段

root ~ 账号名称

$1$i... ~ 密码
12959 ～ 最近更动密码的日期

0～ 密码不可被更动的天数

99999～ 密码需要重新变更的天数
。。。。





### (二)、组

1. /etc/group 和 /etc/gshadow

root : x : 0 : root

root ~ 群组名称
x ~ 群组密码
0 ～ gid

root: 支持的账号名称



2. 有效群组 、 初始群组

/etc/passwd 第四栏 gid ～ 初始群组 ～ 该使用者一登入系统，就拥有这个群组的相关权限



/etc/passwd, 使用者群组gid501，也就数/etc/group dmtsai的群组。～ 非initail group 不同

dmtsai 加入user群组， 由于开始是并非初始群组， 要加上

so ~ 两群组拥有的功能，dmtsai这个使用者都有。

新建档案 ～ 要看当时的有效群组

查看所支持的群组 ～ groups



### (三)、 有关用户和组的指令

1、添加用户 useradd

-u ~ uid
-g ~ initail group

-G ~ 还可以支持的群组

-M ~ 强制， 不建立使用者家目录
-m ~ 强制， 要建立使用者家目录
-c ~ /etc/passwd 第五栏的说明内容
-d ~ 指定目录为家目录
-r ~ 建立系统账号，账号uid会有限制

-s ~ 后面接一个shell， 预设/bin/bash

2、修改用户 usermod

-c ~ 账号说明
-d ~ 家目录



3、修改密码 passwd


passwd ～ root ~ 帮使用者修改密码，不需要旧密码

密码验证要求 ～ root ~ successfully

~ 非root ～ /etc/login.defs 最小密码字符数， /etc/pam.d/passwd PAM模块的检验
密码不能与账号相同；

密码尽量不要选择字典出现过的字符串

密码需要超过8 字符



4.删除用户 Userdel

移除账号 ～ /etc/passwd /etc/shadow  ~userdel

5.显示用户所属的组 groups

6. 创建组 groupadd

7.groupmod

8.groupdel

9.显示用户信息id


