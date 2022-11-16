# 一、[Excel 导入导出](https://mp.weixin.qq.com/s/rqtan5sQipW8Gkkldgb1sQ)

喝水不忘挖井人，感谢阿里巴巴项目组提供了easyexcel工具类，github地址：

> https://github.com/alibaba/easyexcel

## 文章目录

- [环境搭建](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- [读取excel文件](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- 

- - [默认读取](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [指定读取](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [默认读取](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [指定读取](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [小于1000行数据](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [大于1000行数据](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- [导出excle](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- 

- - [无模型映射导出](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [模型映射导出](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [单个Sheet导出](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
  - [多个Sheet导出](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- [工具类](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

- [测试类](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

## 环境搭建

- [easyexcel 依赖（必须）](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
- [springboot (不是必须)](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)
- [lombok （不是必须）](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```xml
 <dependency>
   <groupId>com.alibaba</groupId>
   <artifactId>easyexcel</artifactId>
   <version>1.1.2-beat1</version>
 </dependency>

 <dependency>
   <groupId>org.projectlombok</groupId>
   <artifactId>lombok</artifactId>
   <version>1.18.2</version>
 </dependency>
```

Spring Boot 基础就不介绍了，推荐下这个实战教程：

> https://github.com/javastacks/spring-boot-best-practice

## 读取excel文件

### 小于1000行数据

##### 默认读取

[读取Sheet1的全部数据](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
 String filePath = "/home/chenmingjian/Downloads/学生表.xlsx";
 List<Object> objects = ExcelUtil.readLessThan1000Row(filePath);
```

##### 指定读取

[下面是学生表.xlsx中Sheet1，Sheet2的数据](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

![图片](https://mmbiz.qpic.cn/mmbiz_png/mR4CwoLXicg09icMj8b8HXGWr6W7Xm2NrJ4F0MLiawlOTPfAkIzkKK4QW4AZYSo9mo5n3LPtnLM5bjKaPYEeIhSpA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

![图片](https://mmbiz.qpic.cn/mmbiz_png/mR4CwoLXicg09icMj8b8HXGWr6W7Xm2NrJuic9etibFftFwxWXU5Npsj2sXwpc12YYBeA4vcia3ibSK6CQmiaOsV98wrA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

[获取Sheet1表头以下的信息](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
String filePath = "/home/chenmingjian/Downloads/学生表.xlsx";
//第一个1代表sheet1, 第二个1代表从第几行开始读取数据，行号最小值为0
Sheet sheet = new Sheet(1, 1);
List<Object> objects = ExcelUtil.readLessThan1000Row(filePath,sheet);
```

[获取Sheet2的所有信息](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
 String filePath = "/home/chenmingjian/Downloads/学生表.xlsx";
 Sheet sheet = new Sheet(2, 0);
 List<Object> objects = ExcelUtil.readLessThan1000Row(filePath,sheet);
```

### 大于1000行数据

##### 默认读取

```java
String filePath = "/home/chenmingjian/Downloads/学生表.xlsx";
List<Object> objects = ExcelUtil.readMoreThan1000Row(filePath);
```

##### 指定读取

```java
String filePath = "/home/chenmingjian/Downloads/学生表.xlsx";
Sheet sheet = new Sheet(1, 2);
List<Object> objects = ExcelUtil.readMoreThan1000Row(filePath，sheet);
```

## 导出excle

### 单个Sheet导出

##### 无模型映射导出

```java
String filePath = "/home/chenmingjian/Downloads/测试.xlsx";
List<List<Object>> data = new ArrayList<>();
data.add(Arrays.asList("111","222","333"));
data.add(Arrays.asList("111","222","333"));
data.add(Arrays.asList("111","222","333"));
List<String> head = Arrays.asList("表头1", "表头2", "表头3");
ExcelUtil.writeBySimple(filePath,data,head);
```

[结果](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

![图片](https://mmbiz.qpic.cn/mmbiz_png/mR4CwoLXicg09icMj8b8HXGWr6W7Xm2NrJlxjiaw0KUeScD7QhOeMWhe89h1c6qVe1GH3KnO0qMQmzlFj564jp7IQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

##### 模型映射导出

1、定义好模型对象

```java
package com.springboot.utils.excel.test;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.metadata.BaseRowModel;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * @description:
 * @author: chenmingjian
 * @date: 19-4-3 14:44
 */
@EqualsAndHashCode(callSuper = true)
@Data
public class TableHeaderExcelProperty extends BaseRowModel {

    /**
     * value: 表头名称
     * index: 列的号, 0表示第一列
     */
    @ExcelProperty(value = "姓名", index = 0)
    private String name;

    @ExcelProperty(value = "年龄",index = 1)
    private int age;

    @ExcelProperty(value = "学校",index = 2)
    private String school;
}
```

2、调用方法

```java
String filePath = "/home/chenmingjian/Downloads/测试.xlsx";
ArrayList<TableHeaderExcelProperty> data = new ArrayList<>();
  for(int i = 0; i < 4; i++){
      TableHeaderExcelProperty tableHeaderExcelProperty = new TableHeaderExcelProperty();
      tableHeaderExcelProperty.setName("cmj" + i);
      tableHeaderExcelProperty.setAge(22 + i);
      tableHeaderExcelProperty.setSchool("清华大学" + i);
      data.add(tableHeaderExcelProperty);
  }

  ExcelUtil.writeWithTemplate(filePath,data);
```

### 多个Sheet导出

1、定义好模型对象

```java
package com.springboot.utils.excel.test;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.metadata.BaseRowModel;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * @description:
 * @author: chenmingjian
 * @date: 19-4-3 14:44
 */
@EqualsAndHashCode(callSuper = true)
@Data
public class TableHeaderExcelProperty extends BaseRowModel {

    /**
     * value: 表头名称
     * index: 列的号, 0表示第一列
     */
    @ExcelProperty(value = "姓名", index = 0)
    private String name;

    @ExcelProperty(value = "年龄",index = 1)
    private int age;

    @ExcelProperty(value = "学校",index = 2)
    private String school;
}
```

[2、调用方法](http://mp.weixin.qq.com/s?__biz=MzUyNDc0NjM0Nw==&mid=2247492574&idx=2&sn=f27a39ad8bf4540785d08d7d4be889df&chksm=fa2a08dacd5d81cc3b043fcf01b6b0d9f12e0ed43f02a97c0941c5d325d989c6af5fb0276dc7&scene=21#wechat_redirect)

```java
 ArrayList<ExcelUtil.MultipleSheelPropety> list1 = new ArrayList<>();
 for(int j = 1; j < 4; j++){
      ArrayList<TableHeaderExcelProperty> list = new ArrayList<>();
      for(int i = 0; i < 4; i++){
          TableHeaderExcelProperty tableHeaderExcelProperty = new TableHeaderExcelProperty();
          tableHeaderExcelProperty.setName("cmj" + i);
          tableHeaderExcelProperty.setAge(22 + i);
          tableHeaderExcelProperty.setSchool("清华大学" + i);
          list.add(tableHeaderExcelProperty);
      }

      Sheet sheet = new Sheet(j, 0);
      sheet.setSheetName("sheet" + j);

      ExcelUtil.MultipleSheelPropety multipleSheelPropety = new ExcelUtil.MultipleSheelPropety();
      multipleSheelPropety.setData(list);
      multipleSheelPropety.setSheet(sheet);

      list1.add(multipleSheelPropety);

  }

  ExcelUtil.writeWithMultipleSheel("/home/chenmingjian/Downloads/aaa.xlsx",list1);
```

最新面试题整理好了，点击[Java面试库](https://mp.weixin.qq.com/s/rqtan5sQipW8Gkkldgb1sQ)小程序在线刷题。

## 工具类

```java
package com.springboot.utils.excel;

import com.alibaba.excel.EasyExcelFactory;
import com.alibaba.excel.ExcelWriter;
import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.event.AnalysisEventListener;
import com.alibaba.excel.metadata.BaseRowModel;
import com.alibaba.excel.metadata.Sheet;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * @description:
 * @author: chenmingjian
 * @date: 19-3-18 16:16
 */
@Slf4j
public class ExcelUtil {

   private static Sheet initSheet;

   static {
      initSheet = new Sheet(1, 0);
      initSheet.setSheetName("sheet");
      //设置自适应宽度
      initSheet.setAutoWidth(Boolean.TRUE);
   }

   /**
    * 读取少于1000行数据
    * @param filePath 文件绝对路径
    * @return
    */
   public static List<Object> readLessThan1000Row(String filePath){
      return readLessThan1000RowBySheet(filePath,null);
   }

   /**
    * 读小于1000行数据, 带样式
    * filePath 文件绝对路径
    * initSheet ：
    *      sheetNo: sheet页码，默认为1
    *      headLineMun: 从第几行开始读取数据，默认为0, 表示从第一行开始读取
    *      clazz: 返回数据List<Object> 中Object的类名
    */
   public static List<Object> readLessThan1000RowBySheet(String filePath, Sheet sheet){
      if(!StringUtils.hasText(filePath)){
         return null;
      }

      sheet = sheet != null ? sheet : initSheet;

      InputStream fileStream = null;
      try {
         fileStream = new FileInputStream(filePath);
         return EasyExcelFactory.read(fileStream, sheet);
      } catch (FileNotFoundException e) {
         log.info("找不到文件或文件路径错误, 文件：{}", filePath);
      }finally {
         try {
            if(fileStream != null){
               fileStream.close();
            }
         } catch (IOException e) {
            log.info("excel文件读取失败, 失败原因：{}", e);
         }
      }
      return null;
   }

   /**
    * 读大于1000行数据
    * @param filePath 文件觉得路径
    * @return
    */
   public static List<Object> readMoreThan1000Row(String filePath){
      return readMoreThan1000RowBySheet(filePath,null);
   }

   /**
    * 读大于1000行数据, 带样式
    * @param filePath 文件觉得路径
    * @return
    */
   public static List<Object> readMoreThan1000RowBySheet(String filePath, Sheet sheet){
      if(!StringUtils.hasText(filePath)){
         return null;
      }

      sheet = sheet != null ? sheet : initSheet;

      InputStream fileStream = null;
      try {
         fileStream = new FileInputStream(filePath);
         ExcelListener excelListener = new ExcelListener();
         EasyExcelFactory.readBySax(fileStream, sheet, excelListener);
         return excelListener.getDatas();
      } catch (FileNotFoundException e) {
         log.error("找不到文件或文件路径错误, 文件：{}", filePath);
      }finally {
         try {
            if(fileStream != null){
               fileStream.close();
            }
         } catch (IOException e) {
            log.error("excel文件读取失败, 失败原因：{}", e);
         }
      }
      return null;
   }

   /**
    * 生成excle
    * @param filePath  绝对路径, 如：/home/chenmingjian/Downloads/aaa.xlsx
    * @param data 数据源
    * @param head 表头
    */
   public static void writeBySimple(String filePath, List<List<Object>> data, List<String> head){
      writeSimpleBySheet(filePath,data,head,null);
   }

   /**
    * 生成excle
    * @param filePath 绝对路径, 如：/home/chenmingjian/Downloads/aaa.xlsx
    * @param data 数据源
    * @param sheet excle页面样式
    * @param head 表头
    */
   public static void writeSimpleBySheet(String filePath, List<List<Object>> data, List<String> head, Sheet sheet){
      sheet = (sheet != null) ? sheet : initSheet;

      if(head != null){
         List<List<String>> list = new ArrayList<>();
         head.forEach(h -> list.add(Collections.singletonList(h)));
         sheet.setHead(list);
      }

      OutputStream outputStream = null;
      ExcelWriter writer = null;
      try {
         outputStream = new FileOutputStream(filePath);
         writer = EasyExcelFactory.getWriter(outputStream);
         writer.write1(data,sheet);
      } catch (FileNotFoundException e) {
         log.error("找不到文件或文件路径错误, 文件：{}", filePath);
      }finally {
         try {
            if(writer != null){
               writer.finish();
            }

            if(outputStream != null){
               outputStream.close();
            }

         } catch (IOException e) {
            log.error("excel文件导出失败, 失败原因：{}", e);
         }
      }

   }

   /**
    * 生成excle
    * @param filePath 绝对路径, 如：/home/chenmingjian/Downloads/aaa.xlsx
    * @param data 数据源
    */
   public static void writeWithTemplate(String filePath, List<? extends BaseRowModel> data){
      writeWithTemplateAndSheet(filePath,data,null);
   }

   /**
    * 生成excle
    * @param filePath 绝对路径, 如：/home/chenmingjian/Downloads/aaa.xlsx
    * @param data 数据源
    * @param sheet excle页面样式
    */
   public static void writeWithTemplateAndSheet(String filePath, List<? extends BaseRowModel> data, Sheet sheet){
      if(CollectionUtils.isEmpty(data)){
         return;
      }

      sheet = (sheet != null) ? sheet : initSheet;
      sheet.setClazz(data.get(0).getClass());

      OutputStream outputStream = null;
      ExcelWriter writer = null;
      try {
         outputStream = new FileOutputStream(filePath);
         writer = EasyExcelFactory.getWriter(outputStream);
         writer.write(data,sheet);
      } catch (FileNotFoundException e) {
         log.error("找不到文件或文件路径错误, 文件：{}", filePath);
      }finally {
         try {
            if(writer != null){
               writer.finish();
            }

            if(outputStream != null){
               outputStream.close();
            }
         } catch (IOException e) {
            log.error("excel文件导出失败, 失败原因：{}", e);
         }
      }

   }

   /**
    * 生成多Sheet的excle
    * @param filePath 绝对路径, 如：/home/chenmingjian/Downloads/aaa.xlsx
    * @param multipleSheelPropetys
    */
   public static void writeWithMultipleSheel(String filePath,List<MultipleSheelPropety> multipleSheelPropetys){
      if(CollectionUtils.isEmpty(multipleSheelPropetys)){
         return;
      }

      OutputStream outputStream = null;
      ExcelWriter writer = null;
      try {
         outputStream = new FileOutputStream(filePath);
         writer = EasyExcelFactory.getWriter(outputStream);
         for (MultipleSheelPropety multipleSheelPropety : multipleSheelPropetys) {
            Sheet sheet = multipleSheelPropety.getSheet() != null ? multipleSheelPropety.getSheet() : initSheet;
            if(!CollectionUtils.isEmpty(multipleSheelPropety.getData())){
               sheet.setClazz(multipleSheelPropety.getData().get(0).getClass());
            }
            writer.write(multipleSheelPropety.getData(), sheet);
         }

      } catch (FileNotFoundException e) {
         log.error("找不到文件或文件路径错误, 文件：{}", filePath);
      }finally {
         try {
            if(writer != null){
               writer.finish();
            }

            if(outputStream != null){
               outputStream.close();
            }
         } catch (IOException e) {
            log.error("excel文件导出失败, 失败原因：{}", e);
         }
      }

   }

   /*********************匿名内部类开始，可以提取出去******************************/

   @Data
   public static class MultipleSheelPropety{

      private List<? extends BaseRowModel> data;

      private Sheet sheet;
   }

   /**
    * 解析监听器，
    * 每解析一行会回调invoke()方法。
    * 整个excel解析结束会执行doAfterAllAnalysed()方法
    *
    * @author: chenmingjian
    * @date: 19-4-3 14:11
    */
   @Getter
   @Setter
   public static class ExcelListener extends AnalysisEventListener {

      private List<Object> datas = new ArrayList<>();

      /**
       * 逐行解析
       * object : 当前行的数据
       */
      @Override
      public void invoke(Object object, AnalysisContext context) {
         //当前行
         // context.getCurrentRowNum()
         if (object != null) {
            datas.add(object);
         }
      }

      /**
       * 解析完所有数据后会调用该方法
       */
      @Override
      public void doAfterAllAnalysed(AnalysisContext context) {
         //解析结束销毁不用的资源
      }

   }

   /************************匿名内部类结束，可以提取出去***************************/

}
```

## 测试类

Spring Boot 基础就不介绍了，推荐下这个实战教程：

> https://github.com/javastacks/spring-boot-best-practice

```java
package com.springboot.utils.excel;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.metadata.BaseRowModel;
import com.alibaba.excel.metadata.Sheet;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @description: 测试类
 * @author: chenmingjian
 * @date: 19-4-4 15:24
 */
@SpringBootTest
@RunWith(SpringRunner.class)
public class Test {

    /**
     * 读取少于1000行的excle
     */
    @org.junit.Test
    public void readLessThan1000Row(){
        String filePath = "/home/chenmingjian/Downloads/测试.xlsx";
        List<Object> objects = ExcelUtil.readLessThan1000Row(filePath);
        objects.forEach(System.out::println);
    }

    /**
     * 读取少于1000行的excle，可以指定sheet和从几行读起
     */
    @org.junit.Test
    public void readLessThan1000RowBySheet(){
        String filePath = "/home/chenmingjian/Downloads/测试.xlsx";
        Sheet sheet = new Sheet(1, 1);
        List<Object> objects = ExcelUtil.readLessThan1000RowBySheet(filePath,sheet);
        objects.forEach(System.out::println);
    }

    /**
     * 读取大于1000行的excle
     * 带sheet参数的方法可参照测试方法readLessThan1000RowBySheet()
     */
    @org.junit.Test
    public void readMoreThan1000Row(){
        String filePath = "/home/chenmingjian/Downloads/测试.xlsx";
        List<Object> objects = ExcelUtil.readMoreThan1000Row(filePath);
        objects.forEach(System.out::println);
    }

    /**
     * 生成excle
     * 带sheet参数的方法可参照测试方法readLessThan1000RowBySheet()
     */
    @org.junit.Test
    public void writeBySimple(){
        String filePath = "/home/chenmingjian/Downloads/测试.xlsx";
        List<List<Object>> data = new ArrayList<>();
        data.add(Arrays.asList("111","222","333"));
        data.add(Arrays.asList("111","222","333"));
        data.add(Arrays.asList("111","222","333"));
        List<String> head = Arrays.asList("表头1", "表头2", "表头3");
        ExcelUtil.writeBySimple(filePath,data,head);
    }

    /**
     * 生成excle, 带用模型
     * 带sheet参数的方法可参照测试方法readLessThan1000RowBySheet()
     */
    @org.junit.Test
    public void writeWithTemplate(){
        String filePath = "/home/chenmingjian/Downloads/测试.xlsx";
        ArrayList<TableHeaderExcelProperty> data = new ArrayList<>();
        for(int i = 0; i < 4; i++){
            TableHeaderExcelProperty tableHeaderExcelProperty = new TableHeaderExcelProperty();
            tableHeaderExcelProperty.setName("cmj" + i);
            tableHeaderExcelProperty.setAge(22 + i);
            tableHeaderExcelProperty.setSchool("清华大学" + i);
            data.add(tableHeaderExcelProperty);
        }
        ExcelUtil.writeWithTemplate(filePath,data);
    }

    /**
     * 生成excle, 带用模型,带多个sheet
     */
    @org.junit.Test
    public void writeWithMultipleSheel(){
        ArrayList<ExcelUtil.MultipleSheelPropety> list1 = new ArrayList<>();
        for(int j = 1; j < 4; j++){
            ArrayList<TableHeaderExcelProperty> list = new ArrayList<>();
            for(int i = 0; i < 4; i++){
                TableHeaderExcelProperty tableHeaderExcelProperty = new TableHeaderExcelProperty();
                tableHeaderExcelProperty.setName("cmj" + i);
                tableHeaderExcelProperty.setAge(22 + i);
                tableHeaderExcelProperty.setSchool("清华大学" + i);
                list.add(tableHeaderExcelProperty);
            }

            Sheet sheet = new Sheet(j, 0);
            sheet.setSheetName("sheet" + j);

            ExcelUtil.MultipleSheelPropety multipleSheelPropety = new ExcelUtil.MultipleSheelPropety();
            multipleSheelPropety.setData(list);
            multipleSheelPropety.setSheet(sheet);

            list1.add(multipleSheelPropety);

        }

        ExcelUtil.writeWithMultipleSheel("/home/chenmingjian/Downloads/aaa.xlsx",list1);

    }

    /*******************匿名内部类，实际开发中该对象要提取出去**********************/

    /**
     * @description:
     * @author: chenmingjian
     * @date: 19-4-3 14:44
     */
    @EqualsAndHashCode(callSuper = true)
    @Data
    public static class TableHeaderExcelProperty extends BaseRowModel {

        /**
         * value: 表头名称
         * index: 列的号, 0表示第一列
         */
        @ExcelProperty(value = "姓名", index = 0)
        private String name;

        @ExcelProperty(value = "年龄",index = 1)
        private int age;

        @ExcelProperty(value = "学校",index = 2)
        private String school;
    }

    /*******************匿名内部类，实际开发中该对象要提取出去**********************/

}
```





## [excel操作之poi-ooxml](https://www.cnblogs.com/muxi0407/p/11975145.html)

目前市场上流行的对于excel处理的框架大致有两种：poi和jxl。对于这两种框架，我们可以做一个简单的对比：
   1 开发团队：poi是Apache旗下的一个开源项目，由Apache官方维护，jxl好像是一个个人维护的开源项目。
   2 各自优点：poi对公式支持较好，jxl不算好 。jxl提供对图片的支持（仅仅PNG格式），poi支持。（就这一条来看财务软件就该选poi，而媒体类的软件就该选jxl了）
   3 内存消耗：由于jxl在对资源回收利用方面做了相当的功课，在内存消耗上jxl是略胜于poi的。所以对于大数据量的软件导入来说，选择jxl是比较合算的，当然数据量小的基本没有差别。
   4 运行速度： 估计是内存消耗多的缘故，poi对于读写速度这一功能做的好像比jxl好了不少，并且支持压缩excel。
    对比了这么多，对于自己项目该使用哪个框架，应该也十分明显了（当然这些也都是从网上搜集来的，不保证有错误的地方）。
    这里我记录一下poi的使用吧，都挺简单的，基本原理都是将excel表格数据提取出来组成一个list。然后对应这个list自己去做循环对应自己数据表的数据就行了。需要说明的一点是如果是数字类型的话，读出来的数据一般都是以double类型返回给你的，比如你在excel里面写的是100，读取出来的数据就是100.0.这点比较烦人，当然自己做一下处理就好了。
    还有一点就是poi也有两个不同的jar包，分别是处理excel2003和excel2007+的，对应的是poi和poi-ooxml。毕竟poi-ooxml是poi的升级版本，处理的单页数据量也是百万级别的，所以我们选择的也是poi-ooxml。好了，下面就贴上代码吧，注释较多，就不多做啰嗦了。,前提是引入包：

```
<!--poi对excel2007以上版本的支持-->
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-ooxml</artifactId>
            <version>3.12</version>
        </dependency>
```

   以下代码完全可以作为一个excel工具类迁移到自己的项目中：

```java
/**
 * 处理excel读入的工具类
 * Created by Liujishuai on 2015/8/5.
 */
public class ExcelUtils {
    /**
     * 要求excel版本在2007以上
     *
     * @param file 文件信息
     * @return
     * @throws Exception
     */
    public static List<List<Object>> readExcel(File file) throws Exception {
        if(!file.exists()){
            throw new Exception("找不到文件");
        }
        List<List<Object>> list = new LinkedList<List<Object>>();
        XSSFWorkbook xwb = new XSSFWorkbook(new FileInputStream(file));
        // 读取第一张表格内容
        XSSFSheet sheet = xwb.getSheetAt(0);
        XSSFRow row = null;
        XSSFCell cell = null;
        for (int i = (sheet.getFirstRowNum() + 1); i <= (sheet.getPhysicalNumberOfRows() - 1); i++) {
            row = sheet.getRow(i);
            if (row == null) {
                continue;
            }
            List<Object> linked = new LinkedList<Object>();
            for (int j = row.getFirstCellNum(); j <= row.getLastCellNum(); j++) {
                Object value = null;
                cell = row.getCell(j);
                if (cell == null) {
                    continue;
                }
                switch (cell.getCellType()) {
                    case XSSFCell.CELL_TYPE_STRING:
                        //String类型返回String数据
                        value = cell.getStringCellValue();
                        break;
                    case XSSFCell.CELL_TYPE_NUMERIC:
                        //日期数据返回LONG类型的时间戳
                        if ("yyyy\"年\"m\"月\"d\"日\";@".equals(cell.getCellStyle().getDataFormatString())) {
                            //System.out.println(cell.getNumericCellValue()+":日期格式："+cell.getCellStyle().getDataFormatString());
                            value = DateUtils.getMillis(HSSFDateUtil.getJavaDate(cell.getNumericCellValue())) / 1000;
                        } else {
                            //数值类型返回double类型的数字
                            //System.out.println(cell.getNumericCellValue()+":格式："+cell.getCellStyle().getDataFormatString());
                            value = cell.getNumericCellValue();
                        }
                        break;
                    case XSSFCell.CELL_TYPE_BOOLEAN:
                        //布尔类型
                        value = cell.getBooleanCellValue();
                        break;
                    case XSSFCell.CELL_TYPE_BLANK:
                        //空单元格
                        break;
                    default:
                        value = cell.toString();
                }
                if (value != null && !value.equals("")) {
                    //单元格不为空，则加入列表
                    linked.add(value);
                }
            }
            if (linked.size()!= 0) {
                list.add(linked);
            }
        }
        return list;
    }
    /**
     * 要求excel版本在2007以上
     *
     * @param fileInputStream 文件信息
     * @return
     * @throws Exception
     */
    public static List<List<Object>> readExcel(FileInputStream fileInputStream) throws Exception {
        List<List<Object>> list = new LinkedList<List<Object>>();
        XSSFWorkbook xwb = new XSSFWorkbook(fileInputStream);
        // 读取第一张表格内容
        XSSFSheet sheet = xwb.getSheetAt(1);
        XSSFRow row = null;
        XSSFCell cell = null;
        for (int i = (sheet.getFirstRowNum() + 1); i <= (sheet.getPhysicalNumberOfRows() - 1); i++) {
            row = sheet.getRow(i);
            if (row == null) {
                continue;
            }
            List<Object> linked = new LinkedList<Object>();
            for (int j = row.getFirstCellNum(); j <= row.getLastCellNum(); j++) {
                Object value = null;
                cell = row.getCell(j);
                if (cell == null) {
                    continue;
                }
                switch (cell.getCellType()) {
                    case XSSFCell.CELL_TYPE_STRING:
                        value = cell.getStringCellValue();
                        break;
                    case XSSFCell.CELL_TYPE_NUMERIC:
                        if ("yyyy\"年\"m\"月\"d\"日\";@".equals(cell.getCellStyle().getDataFormatString())) {
                            //System.out.println(cell.getNumericCellValue()+":日期格式："+cell.getCellStyle().getDataFormatString());
                            value = DateUtils.getMillis(HSSFDateUtil.getJavaDate(cell.getNumericCellValue())) / 1000;
                        } else {
                            //System.out.println(cell.getNumericCellValue()+":格式："+cell.getCellStyle().getDataFormatString());
                            value = cell.getNumericCellValue();
                        }
                        break;
                    case XSSFCell.CELL_TYPE_BOOLEAN:
                        value = cell.getBooleanCellValue();
                        break;
                    case XSSFCell.CELL_TYPE_BLANK:
                        break;
                    default:
                        value = cell.toString();
                }
                if (value != null && !value.equals("")) {
                    //单元格不为空，则加入列表
                    linked.add(value);
                }
            }
            if (linked.size()!= 0) {
                list.add(linked);
            }
        }
        return list;
    }
 
    /**
     * 导出excel
     * @param excel_name 导出的excel路径（需要带.xlsx)
     * @param headList  excel的标题备注名称
     * @param fieldList excel的标题字段（与数据中map中键值对应）
     * @param dataList  excel数据
     * @throws Exception
     */
    public static void createExcel(String excel_name, String[] headList,
                                   String[] fieldList, List<Map<String, Object>> dataList)
            throws Exception {
        // 创建新的Excel 工作簿
        XSSFWorkbook workbook = new XSSFWorkbook();
        // 在Excel工作簿中建一工作表，其名为缺省值
        XSSFSheet sheet = workbook.createSheet();
        // 在索引0的位置创建行（最顶端的行）
        XSSFRow row = sheet.createRow(0);
        // 设置excel头（第一行）的头名称
        for (int i = 0; i < headList.length; i++) {
 
            // 在索引0的位置创建单元格（左上端）
            XSSFCell cell = row.createCell(i);
            // 定义单元格为字符串类型
            cell.setCellType(XSSFCell.CELL_TYPE_STRING);
            // 在单元格中输入一些内容
            cell.setCellValue(headList[i]);
        }
        // ===============================================================
        //添加数据
        for (int n = 0; n < dataList.size(); n++) {
            // 在索引1的位置创建行（最顶端的行）
            XSSFRow row_value = sheet.createRow(n + 1);
            Map<String, Object> dataMap = dataList.get(n);
            // ===============================================================
            for (int i = 0; i < fieldList.length; i++) {
 
                // 在索引0的位置创建单元格（左上端）
                XSSFCell cell = row_value.createCell(i);
                // 定义单元格为字符串类型
                cell.setCellType(XSSFCell.CELL_TYPE_STRING);
                // 在单元格中输入一些内容
                cell.setCellValue((dataMap.get(fieldList[i])).toString());
            }
            // ===============================================================
        }
        // 新建一输出文件流
        FileOutputStream fos = new FileOutputStream(excel_name);
        // 把相应的Excel 工作簿存盘
        workbook.write(fos);
        fos.flush();
        // 操作结束，关闭文件
        fos.close();
    }
}
```

