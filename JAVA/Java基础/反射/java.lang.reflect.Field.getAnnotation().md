# [java.lang.reflect.Field.getAnnotation()][https://www.yiibai.com/javareflect/javareflect_field_getannotation.html]

java.lang.reflect.Field.getAnnotation(Class <T> annotationClass)方法返回指定类型的元素的注释，否则返回为null。

**参数**

- *annotationClass* - 如果给定的注释类为`null`。

**返回值**

- 该元素的注释指定的注释类型，如果存在于此元素，否则返回`null`。

 **异常**

- *NullPointerException* - 如果指定的对象为`null`，该字段为实例字段。

## 例子

以下示例显示`java.lang.reflect.Field.getAnnotation(Class<T> annotationClass)`方法的用法。

```java
import java.lang.annotation.Annotation;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.reflect.Field;

public class GetAnnotation {

   public static void main(String[] args) throws NoSuchFieldException, SecurityException, IllegalArgumentException, IllegalAccessException {
      Field field = SampleClass.class.getField("sampleField");
      Annotation annotation = field.getAnnotation(CustomAnnotation.class);
      if(annotation instanceof CustomAnnotation){
         CustomAnnotation customAnnotation = (CustomAnnotation) annotation;
         System.out.println("name: " + customAnnotation.name());
         System.out.println("value: " + customAnnotation.value());
      }
   }
}

@CustomAnnotation(name="SampleClass",  value = "Sample Class Annotation")
class SampleClass {

   @CustomAnnotation(name="sampleClassField",  value = "Sample Field Annotation")
   public String sampleField;

   public String getSampleField() {
      return sampleField;
   }

   public void setSampleField(String sampleField) {
      this.sampleField = sampleField;
   }
}

@Retention(RetentionPolicy.RUNTIME)
@interface CustomAnnotation {
   public String name();
   public String value();
}
Java
```

让我们编译并运行上面的程序，这将产生以下结果 -

```shell
name: sampleClassField
value: Sample Field Annotation
```



-----



# [Java Field getAnnotation()方法][http://www.yiidian.com/java-reflect/java-field-getannotation.html]

