# [对象转JSONObject时，值为null的属性会消失](https://www.cnblogs.com/yunque123/p/14435022.html)

```java
import package com.alibaba.fastjson;

String updateDate = JSONObject.toJSONString(object, SerializerFeatrue.WriteMapNullValue, SerializerFeatrue.WriteNullStringAsEmpty);
```

