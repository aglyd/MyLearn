# [使用iText生成PDF文件](https://blog.csdn.net/u010154380/article/details/78087663)

### [【Java】使用iText生成PDF文件](http://www.cnblogs.com/h--d/p/6150320.html)

　　iText是著名的开放[源码](https://so.csdn.net/so/search?q=源码&spm=1001.2101.3001.7020)的站点sourceforge一个项目，是用于生成PDF文档的一个java类库。通过iText不仅可以生成PDF或rtf的文档，而且可以将XML、Html文件转化为PDF文件。

　　项目要使用iText，必须引入jar包。才能使用，[maven](https://so.csdn.net/so/search?q=maven&spm=1001.2101.3001.7020)依赖如下：

```
1 <dependency>
2     <groupId>com.itextpdf</groupId>
3     <artifactId>itextpdf</artifactId>
4     <version>5.5.10</version>
5 </dependency>
```

　　输出中文，还要引入下面itext-asian.jar包：

```
1 <dependency>
2     <groupId>com.itextpdf</groupId>
3     <artifactId>itext-asian</artifactId>
4     <version>5.2.0</version>
5 </dependency>
```

   设置pdf文件密码，还要引入下面bcprov-jdk15on.jar包：

```
1 <dependency>
2     <groupId>org.bouncycastle</groupId>
3     <artifactId>bcprov-jdk15on</artifactId>
4     <version>1.54</version>
5 </dependency>
```

 

### iText常用类

- com.itextpdf.text.Document：这是iText库中最常用的类，它代表了一个pdf实例。如果你需要从零开始生成一个PDF文件，你需要使用这个Document类。首先创建（new）该实例，然后打开（open）它，并添加（add）内容，最后关闭（close）该实例，即可生成一个pdf文件。
- com.itextpdf.text.Paragraph：表示一个缩进的文本段落，在段落中，你可以设置对齐方式，缩进，段落前后间隔等。
- com.itextpdf.text.Chapter：表示PDF的一个章节，他通过一个Paragraph类型的标题和整形章数创建。
- com.itextpdf.text.Font：这个类包含了所有规范好的字体，包括family of font，大小，样式和颜色，所有这些字体都被声明为静态常量。
- com.itextpdf.text.List：表示一个列表；
- cocom.itextpdf.text.List：表示一个列表；
- com.itextpdf.text.Anchor：表示一个锚，类似于HTML页面的链接。
- com.itextpdf.text.pdf.PdfWriter：当这个PdfWriter被添加到PdfDocument后，所有添加到Document的内容将会写入到与文件或网络关联的输出流中。
- com.itextpdf.text.pdf.PdfReader：用于读取PDF文件；

### iText使用

1. 创建一个简单的pdf文件，如下：

   ```
   package com.hd.pdf;
   
   import java.io.FileNotFoundException;
   import java.io.FileOutputStream;
   
   import com.itextpdf.text.Document;
   import com.itextpdf.text.DocumentException;
   import com.itextpdf.text.Paragraph;
   import com.itextpdf.text.pdf.PdfWriter;
   
   public class TestPDFDemo1 {
   
       public static void main(String[] args) throws FileNotFoundException, DocumentException {
   
           // 1.新建document对象
           Document document = new Document();
   
           // 2.建立一个书写器(Writer)与document对象关联，通过书写器(Writer)可以将文档写入到磁盘中。
           // 创建 PdfWriter 对象 第一个参数是对文档对象的引用，第二个参数是文件的实际名称，在该名称中还会给出其输出路径。
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test.pdf"));
   
           // 3.打开文档
           document.open();
   
           // 4.添加一个内容段落
           document.add(new Paragraph("Hello World!"));
   
           // 5.关闭文档
           document.close();
   
       }
   
   }
   ```

   

   打开文件

   ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209165247147-746087588.png)

2. 给PDF文件设置文件属性，例如：

   ```
   public static void main(String[] args) throws FileNotFoundException, DocumentException {
   
           //创建文件
           Document document = new Document();
           //建立一个书写器
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test2.pdf"));
           //打开文件
           document.open();
           //添加内容
           document.add(new Paragraph("Some content here"));
   
           //设置属性
           //标题
           document.addTitle("this is a title");
           //作者
           document.addAuthor("H__D");
           //主题
           document.addSubject("this is subject");
           //关键字
           document.addKeywords("Keywords");
           //创建时间
           document.addCreationDate();
           //应用程序
           document.addCreator("hd.com");
   
           //关闭文档
           document.close();
           //关闭书写器
           writer.close();
       }
   ```

   ![复制代码](http://common.cnblogs.com/images/copycode.gif)

   打开文件
   ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209170702194-1352132557.png)

3. PDF中添加图片

   ```
   public static void main(String[] args) throws DocumentException, IOException {
   
           //创建文件
           Document document = new Document();
           //建立一个书写器
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test3.pdf"));
           //打开文件
           document.open();
           //添加内容
           document.add(new Paragraph("HD content here"));
   
           //图片1
           Image image1 = Image.getInstance("C:/Users/H__D/Desktop/IMG_0109.JPG");
           //设置图片位置的x轴和y周
           image1.setAbsolutePosition(100f, 550f);
           //设置图片的宽度和高度
           image1.scaleAbsolute(200, 200);
           //将图片1添加到pdf文件中
           document.add(image1);
   
           //图片2
           Image image2 = Image.getInstance(new URL("http://static.cnblogs.com/images/adminlogo.gif"));
           //将图片2添加到pdf文件中
           document.add(image2);
   
           //关闭文档
           document.close();
           //关闭书写器
           writer.close();
       }
   ```

   打开文件
    ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209172020116-407724178.png)

4. PDF中创建表格
    

   ```
   public static void main(String[] args) throws DocumentException, FileNotFoundException {
           //创建文件
           Document document = new Document();
           //建立一个书写器
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test4.pdf"));
           //打开文件
           document.open();
           //添加内容
           document.add(new Paragraph("HD content here"));
   
           // 3列的表.
           PdfPTable table = new PdfPTable(3);
           table.setWidthPercentage(100); // 宽度100%填充
           table.setSpacingBefore(10f); // 前间距
           table.setSpacingAfter(10f); // 后间距
   
           List<PdfPRow> listRow = table.getRows();
           //设置列宽
           float[] columnWidths = { 1f, 2f, 3f };
           table.setWidths(columnWidths);
   
           //行1
           PdfPCell cells1[]= new PdfPCell[3];
           PdfPRow row1 = new PdfPRow(cells1);
   
           //单元格
           cells1[0] = new PdfPCell(new Paragraph("111"));//单元格内容
           cells1[0].setBorderColor(BaseColor.BLUE);//边框验证
           cells1[0].setPaddingLeft(20);//左填充20
           cells1[0].setHorizontalAlignment(Element.ALIGN_CENTER);//水平居中
           cells1[0].setVerticalAlignment(Element.ALIGN_MIDDLE);//垂直居中
   
           cells1[1] = new PdfPCell(new Paragraph("222"));
           cells1[2] = new PdfPCell(new Paragraph("333"));
   
           //行2
           PdfPCell cells2[]= new PdfPCell[3];
           PdfPRow row2 = new PdfPRow(cells2);
           cells2[0] = new PdfPCell(new Paragraph("444"));
   
           //把第一行添加到集合
           listRow.add(row1);
           listRow.add(row2);
           //把表格添加到文件中
           document.add(table);
   
           //关闭文档
           document.close();
           //关闭书写器
           writer.close();
       }
   ```

   打开文件
   ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209175622882-861451380.png)

    

5.  PDF中创建列表

   ```
   public static void main(String[] args) throws DocumentException, FileNotFoundException {
           //创建文件
           Document document = new Document();
           //建立一个书写器
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test5.pdf"));
           //打开文件
           document.open();
           //添加内容
           document.add(new Paragraph("HD content here"));
   
           //添加有序列表
           List orderedList = new List(List.ORDERED);
           orderedList.add(new ListItem("Item one"));
           orderedList.add(new ListItem("Item two"));
           orderedList.add(new ListItem("Item three"));
           document.add(orderedList);
   
           //关闭文档
           document.close();
           //关闭书写器
           writer.close();
       }
   ```

   打开文件

    ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209180029726-1168732515.png)

6.  

   PDF中设置样式/格式化输出，输出中文内容，必须引入itext-asian.jar

   ```
   public static void main(String[] args) throws DocumentException, IOException {
           //创建文件
           Document document = new Document();
           //建立一个书写器
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test6.pdf"));
           //打开文件
           document.open();
   
           //中文字体,解决中文不能显示问题
           BaseFont bfChinese = BaseFont.createFont("STSong-Light","UniGB-UCS2-H",BaseFont.NOT_EMBEDDED);
   
           //蓝色字体
           Font blueFont = new Font(bfChinese);
           blueFont.setColor(BaseColor.BLUE);
           //段落文本
           Paragraph paragraphBlue = new Paragraph("paragraphOne blue front", blueFont);
           document.add(paragraphBlue);
   
           //绿色字体
           Font greenFont = new Font(bfChinese);
           greenFont.setColor(BaseColor.GREEN);
           //创建章节
           Paragraph chapterTitle = new Paragraph("段落标题xxxx", greenFont);
           Chapter chapter1 = new Chapter(chapterTitle, 1);
           chapter1.setNumberDepth(0);
   
           Paragraph sectionTitle = new Paragraph("部分标题", greenFont);
           Section section1 = chapter1.addSection(sectionTitle);
   
           Paragraph sectionContent = new Paragraph("部分内容", blueFont);
           section1.add(sectionContent);
   
           //将章节添加到文章中
           document.add(chapter1);
   
           //关闭文档
           document.close();
           //关闭书写器
           writer.close();
       }
   ```

   打开文件
   ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209190354772-265500590.png)
   ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209190415616-518691886.png)

    

7.  给PDF文件设置密码，需要引入bcprov-jdk15on.jar包：

   ```
   public static void main(String[] args) throws DocumentException, IOException {
           // 创建文件
           Document document = new Document();
           // 建立一个书写器
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test8.pdf"));
   
           //用户密码
           String userPassword = "123456";
           //拥有者密码
           String ownerPassword = "hd";
           writer.setEncryption(userPassword.getBytes(), ownerPassword.getBytes(), PdfWriter.ALLOW_PRINTING,
                   PdfWriter.ENCRYPTION_AES_128);
   
           // 打开文件
           document.open();
   
           //添加内容
           document.add(new Paragraph("password !!!!"));
   
           // 关闭文档
           document.close();
           // 关闭书写器
           writer.close();
       }
   ```

   打开文件
   ![img](http://images2015.cnblogs.com/blog/851491/201612/851491-20161209193435710-2086845787.png)

8. 给PDF文件设置权限

   ```
   public static void main(String[] args) throws DocumentException, IOException {
           // 创建文件
           Document document = new Document();
           // 建立一个书写器
           PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream("C:/Users/H__D/Desktop/test9.pdf"));
   
           // 只读权限
           writer.setEncryption("".getBytes(), "".getBytes(), PdfWriter.ALLOW_PRINTING, PdfWriter.ENCRYPTION_AES_128);
   
           // 打开文件
           document.open();
   
           // 添加内容
           document.add(new Paragraph("password !!!!"));
   
           // 关闭文档
           document.close();
           // 关闭书写器
           writer.close();
       }
   ```

    

9. 读取/修改已有的PDF文件

   ```
   public static void main(String[] args) throws DocumentException, IOException {
   
           //读取pdf文件
           PdfReader pdfReader = new PdfReader("C:/Users/H__D/Desktop/test1.pdf");
   
           //修改器
           PdfStamper pdfStamper = new PdfStamper(pdfReader, new FileOutputStream("C:/Users/H__D/Desktop/test10.pdf"));
   
           Image image = Image.getInstance("C:/Users/H__D/Desktop/IMG_0109.JPG");
           image.scaleAbsolute(50, 50);
           image.setAbsolutePosition(0, 700);
   
           for(int i=1; i<= pdfReader.getNumberOfPages(); i++)
           {
               PdfContentByte content = pdfStamper.getUnderContent(i);
               content.addImage(image);
           }
   
           pdfStamper.close();
       }
   ```