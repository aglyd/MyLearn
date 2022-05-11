# [java 通过泛型创建对象](https://blog.csdn.net/viaco2love/article/details/122555928)

## [java 根据泛型创建对象，实例化泛型对象](https://blog.csdn.net/qq_21460229/article/details/104351684)

实例化泛型对象
在你发布的代码中，不可能创建一个泛型T，因为你不知道它是什么类型：

```java
public class Abc<T>
{
       public T getInstanceOfT()
       {
           // There is no way to create an instance of T here
           // since we don't know its type
       }
} 
```

当然，如果你有一个引用Class<T>并且T有一个默认的构造函数，就可以调用newInstance()这个Class对象。

如果你继承子类，Abc<T>你甚至可以解决类型擦除问题，并且不必传递任何Class<T>引用：

```java
import java.lang.reflect.ParameterizedType;

public class Abc<T>
{
	private T getInstanceOfT()
	    {
	        ParameterizedType superClass = (ParameterizedType) getClass().getGenericSuperclass();
	        Class<T> type = (Class<T>) superClass.getActualTypeArguments()[0];
	        try
	        {
	            return type.newInstance();
	        }
	        catch (Exception e)
	        {
	            // Oops, no default constructor
	            throw new RuntimeException(e);
	        }
	    }
	
	    private Class<T> getClassOfT()
	    {
	        ParameterizedType superClass = (ParameterizedType) getClass().getGenericSuperclass();
	        Class<T> type = (Class<T>) superClass.getActualTypeArguments()[0];
	        return type;
	    }

class SubClass
    extends Abc<String>
{
}

```



换个思路，传入demo实例对象

```java
    public static <T> void toIPageVo(IPage foIPage, IPageVo<T> iPageVo,T voDemo) throws InvocationTargetException, IllegalAccessException {
        List foList = foIPage.getRecords();
        List toList = new ArrayList<T>();
        for (Object foRecord : foList) {
            T vo=null;
            try {
               vo  = (T) voDemo.getClass().newInstance();
            } catch (InstantiationException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
            BeanUtilImpl.copyToVo(vo,foRecord);
            toList.add(vo);
        }
 
        iPageVo.setRecords(toList);
        iPageVo.setCurrent(foIPage.getCurrent());
        iPageVo.setSize(foIPage.getSize());
        iPageVo.setTotal(foIPage.getTotal());
        iPageVo.setPages(foIPage.getPages());
    }	
```

或者传入class

```java
    public static <T> void toIPageVo(IPage foIPage, IPageVo<T> iPageVo,Class clazz) throws InvocationTargetException, IllegalAccessException {
        List foList = foIPage.getRecords();
        List toList = new ArrayList<T>();
        for (Object foRecord : foList) {
            T vo=null;
            try {
                vo  = (T) clazz.newInstance();
            } catch (InstantiationException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
            BeanUtilImpl.copyToVo(vo,foRecord);
            toList.add(vo);
        }
 
        iPageVo.setRecords(toList);
        iPageVo.setCurrent(foIPage.getCurrent());
        iPageVo.setSize(foIPage.getSize());
        iPageVo.setTotal(foIPage.getTotal());
        iPageVo.setPages(foIPage.getPages());
    }
```

