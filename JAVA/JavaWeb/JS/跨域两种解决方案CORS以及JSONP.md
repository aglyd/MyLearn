# [跨域两种解决方案CORS以及JSONP](http://t.zoukankan.com/shiqi17-p-9880520.html)

一、CORS设置请求头

- 设置请求头实现跨域：

```js
//跨域的浏览器会让请求带Origin头，表明来自哪里的跨域请求
Origin: http://xxx.example

//表明允许跨域访问
Access-Control-Allow-Origin:上面origin的地址

//其他跨域相关的请求头
Access-Control-Allow-Methods:POST,GET
Access-Control-Allow-Credentials:true
Access-Control-Allow-Headers:Origin,Content-Type,Accept,token,X-Requested-With
```

二、JSONP通过script标签回调函数实现跨域

- 原理
  浏览器中对于img、script、iframe等标签不会跨域阻拦
  生成script标签，利用script的src对目标地址进行访问，然后拿到数据，删除script标签，并调用回调函数

```js
var tag = document.createElement("script"); 
tag.src = "http://www.xxx.com/api/v1/data/?callback=handleback&id=1717";
document.head.appendChild(tag);
document.head.removeChildren(tag);

function handleback(response, state){
    console.log("取回的数据为："+response)
}
```

1. 创建一个script标签
2. 该标签添加src属性，指向将要访问的地址
3. 定义回调函数，标签加载完成后自动调用
4. 将该标签添加到页面中
5. 该标签被浏览器自动加载，调用回调函数取得数据处理
6. 删除该标签

ajax实现跨域请求

- ajax实现

```js
<script type="text/javascript" src="https://code.jquery.com/jquery-3.1.0.min.js"></script>
<script type="text/javascript">
    $(function(){
        $("#btn").click(function(){ 
            $.ajax({
                url : "https://api.douban.com/v2/book/search",
                type : "GET",
                dataType : "jsonp", // 返回的数据类型，设置为JSONP方式
                jsonp : 'callback', //指定一个查询参数名称来覆盖默认的 jsonp 回调参数名 callback
                jsonpCallback: 'handleResponse', //设置回调函数名
                data : {
                    q : "javascript", 
                    count : 1
                }, 
                success: function(response, status, xhr){
                    console.log('状态为：' + status + ',状态是：' + xhr.statusText);
                    console.log(response);
                }
            });
        });
    });
</script>
```