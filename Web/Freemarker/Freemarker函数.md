# [Freemarker函数][https://blog.csdn.net/qixiang_chen/article/details/82958026]

Freemarker定义了很多内置函数，用户也可以自定义函数，函数的调用使用?

## 1、字符串函数

substring：截取子字符串的函数，类似Java的String.substring字符串函数
$(“abcdef”?substring(n) } 截取字符串n位置开始到结尾，n大于等于0，小于等于字符串的长度
$(“abcdef”?substring(m,n) } 截取字符串m位置开始到n位置，m,n大于等于0，小于等于字符串的长度

cap_first: 一行文本的首字母大写
${“hello world ,I am java programer”?cap_first }

uncap_first: 一行文本的首字母小写
${“Hello world ,I am java programer”?uncap_first }

capitalize:每个单词首字母小写改大写，大写改小写
${“hello world ,I am java programer”?capitalize}

ends_with:判断字符串使用以某字符串结尾
${“hello world ,I am java programer”?ends_with(“programer”)?c}

starts_with:判断字符串使用以某字符串开头
${“hello world ,I am java programer”?starts_with(“hello”)?c}

index_of:返回某字符串第一次出现的位置
${“hello world ,I am java programer”?index_of(“am”)}

last_index_of:返回某字符串最后一次出现的位置
${“hello world ,I am java programer”?last_index_of(“am”)}

length:返回字符串的长度
${“hello world ,I am java programer”?length}

left_pad:左侧补齐空格或指定的字符
${“hello world ,I am java programer”?left_pad(10)}
如果left_pad(n) n小于字符串的长度，返回全部字符串
如果left_pad(n) n大于字符串的长度，左侧补充空格或指定字符串

${“hello world ,I am java programer”?left_pad(60,"*")}

right_pad:右侧补齐空格或指定的字符
${“hello world ,I am java programer”?right_pad(100,"*")}
如果right_pad(n) n小于字符串的长度，返回全部字符串
如果right_pad(n) n大于字符串的长度，右侧补充空格或指定字符串

contains：判断字符串中是否存在某字符串
${“hello world ,I am java programer”?contains(“am”)?c}

replace:替换字符串
${“hello world ,I am java programer”?replace(“I”,“you”)}

split:分隔字符串为数组

![在这里插入图片描述](https://img-blog.csdn.net/20181007142335351?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

word_list:以任意多个空格分隔单词

![在这里插入图片描述](https://img-blog.csdn.net/20181007142408642?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 2、数字函数

c : 将数字或boolean 转化为字符串

${1234?c} ${true?c}

string ： 将数字转化为字符串

${123?string}

round: 四舍五入

${123.6?round}
${35.3?round}

floor:向下取整
${123.6?floor}
${35.3?floor}

ceiling:向上取整
${123.6?ceiling}
${35.3?ceiling}

## 3、日期函数

string(“yyyy-MM-dd”) :格式化日期
${.now?string(“yyyy-MM-dd HH:mm:ss”)}

date：获取当前日期
${.now?date}

time：获取当前时间
${.now?time}

datetime：获取当前日期时间
${.now?datetime}

## 4、布尔函数

转化boolean类型为字符串

${true?c}

${false?string(“no”,“yes”)}

## 5、序列函数

first：返回序列中第一个元素
last：返回序列中最后一个元素
seq_contains(n):判断序列中是否存在元素n
seq_index_of(n):返回n在序列中的位置
seq_last_index_of(n):返回n在序列中最后一个位置

![在这里插入图片描述](https://img-blog.csdn.net/20181007142519863?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

reverse:返回序列的反序集合
sort：序列中元素排序

![在这里插入图片描述](https://img-blog.csdn.net/20181007142559949?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

![在这里插入图片描述](https://img-blog.csdn.net/2018100714263330?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

sort_by:用于hash表的排序，可以指明根据那个字段排序

![在这里插入图片描述](https://img-blog.csdn.net/20181007142706633?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

chunk:把序列分成几个序列，可以指定填充元素

![在这里插入图片描述](https://img-blog.csdn.net/20181007142800996?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 6、Hash函数

keys：获取Map的中键集合

![在这里插入图片描述](https://img-blog.csdn.net/20181007142854824?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 7、自定义函数

![在这里插入图片描述](https://img-blog.csdn.net/20181007142943191?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FpeGlhbmdfY2hlbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)