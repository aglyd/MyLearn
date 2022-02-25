# [js 中数组传递到后台controller 批量删除](https://www.cnblogs.com/duanqiao123/p/9119822.html)

```
/*批量删除*/
function datadel(url) {
    var ids=[];
    $("input[type='checkbox']:checked").each(function () {
        var id=$(this).parent().next().text();
        if(id!="ID"){
            ids.push(id);
        }
    });
    console.log("-=-----------1"+JSON.stringify(ids));

    layer.confirm('确认要删除多条记录吗？',function(index){
        $.ajax({
            type: 'POST',
            url:url,
           // dataType: 'json',
            contentType : "application/json" ,
            data:JSON.stringify(ids),
            success: function(data){
                if(data>0){
                    layer.msg('已删除!',{icon:1,time:1000});
                }

            },
            error:function(data) {
                console.log(data.msg);
            },
        });
    });

}

[Controller]
@RequestMapping(value = "/deleteAll", method = {RequestMethod.POST})
@ResponseBody
public Object testPost(@RequestBody String[] ids) throws IOException {
    for (String string : ids) {
        System.out.println(string);
    }
    return 1;
}
```