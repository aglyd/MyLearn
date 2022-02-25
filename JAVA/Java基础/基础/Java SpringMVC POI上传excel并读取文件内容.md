# Java SpringMVC POI上传excel并读取文件内容



用的SSM框架，所需要的jar包如图所示：![img](https://img-blog.csdn.net/20160829111417078?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)，链接地址：[jar包下载](http://pan.baidu.com/s/1dF7drfN) ，下面直接上代码。



**1、判断文件后缀名判断excel版本，生成对应workbook**

**2、生成Sheet页**

**3、生成row行**

**4、生成列**



| CellType          | 类型     |  值  |
| ----------------- | -------- | :--: |
| CELL_TYPE_NUMERIC | 数值型   |  0   |
| CELL_TYPE_STRING  | 字符串型 |  1   |
| CELL_TYPE_FORMULA | 公式型   |  2   |
| CELL_TYPE_BLANK   | 空值     |  3   |
| CELL_TYPE_BOOLEAN | 布尔型   |  4   |
| CELL_TYPE_ERROR   | 错误     |  5   |



1、ExcelUtil工具类



1. <span style="color:#993399;"><span style="font-size:18px;color:#993399;">**import** java.text.DecimalFormat; 
2. **import** java.text.SimpleDateFormat; 
3. **import** java.util.Calendar; 
4. **import** java.util.Date; 
5. **import** java.util.regex.Matcher; 
6. **import** java.util.regex.Pattern; 
7.  
8. **import** org.apache.poi.hssf.usermodel.HSSFCell; 
9. **import** org.apache.poi.hssf.usermodel.HSSFDateUtil; 
10. **import** org.apache.poi.ss.usermodel.Cell; 
11. **import** org.apache.poi.ss.usermodel.DateUtil; 
12. **import** org.apache.poi.xssf.usermodel.XSSFCell; 
13.  
14. /** 
15.  \* Excel工具类 
16.  \* @author lp 
17.  \* 
18.  */ 
19. **public** **class** ExcelUtil { 
20.   **public** **static** **final** String OFFICE_EXCEL_2003_POSTFIX = "xls"; 
21.   **public** **static** **final** String OFFICE_EXCEL_2010_POSTFIX = "xlsx"; 
22.   **public** **static** **final** String EMPTY = ""; 
23.   **public** **static** **final** String POINT = "."; 
24.   **public** **static** SimpleDateFormat sdf =  **new** SimpleDateFormat("yyyy/MM/dd"); 
25.   /** 
26.    \* 获得path的后缀名 
27.    \* @param path 
28.    \* @return 
29.    */ 
30.   **public** **static** String getPostfix(String path){ 
31. ​    **if**(path==**null** || EMPTY.equals(path.trim())){ 
32. ​      **return** EMPTY; 
33. ​    } 
34. ​    **if**(path.contains(POINT)){ 
35. ​      **return** path.substring(path.lastIndexOf(POINT)+1,path.length()); 
36. ​    } 
37. ​    **return** EMPTY; 
38.   } 
39.   /** 
40.    \* 单元格格式 
41.    \* @param hssfCell 
42.    \* @return 
43.    */ 
44.   @SuppressWarnings({ "static-access", "deprecation" }) 
45.   **public** **static** String getHValue(HSSFCell hssfCell){ 
46. ​     **if** (hssfCell.getCellType() == hssfCell.CELL_TYPE_BOOLEAN) { 
47. ​       **return** String.valueOf(hssfCell.getBooleanCellValue()); 
48. ​     } **else** **if** (hssfCell.getCellType() == hssfCell.CELL_TYPE_NUMERIC) { 
49. ​       String cellValue = ""; 
50. ​       **if**(HSSFDateUtil.isCellDateFormatted(hssfCell)){         
51. ​         Date date = HSSFDateUtil.getJavaDate(hssfCell.getNumericCellValue()); 
52. ​         cellValue = sdf.format(date); 
53. ​       }**else**{ 
54. ​         DecimalFormat df = **new** DecimalFormat("#.##"); 
55. ​         cellValue = df.format(hssfCell.getNumericCellValue()); 
56. ​         String strArr = cellValue.substring(cellValue.lastIndexOf(POINT)+1,cellValue.length()); 
57. ​         **if**(strArr.equals("00")){ 
58. ​           cellValue = cellValue.substring(0, cellValue.lastIndexOf(POINT)); 
59. ​         }  
60. ​       } 
61. ​       **return** cellValue; 
62. ​     } **else** { 
63. ​      **return** String.valueOf(hssfCell.getStringCellValue()); 
64. ​     } 
65.   } 
66.   /** 
67.    \* 单元格格式 
68.    \* @param xssfCell 
69.    \* @return 
70.    */ 
71.   **public** **static** String getXValue(XSSFCell xssfCell){ 
72. ​     **if** (xssfCell.getCellType() == Cell.CELL_TYPE_BOOLEAN) { 
73. ​       **return** String.valueOf(xssfCell.getBooleanCellValue()); 
74. ​     } **else** **if** (xssfCell.getCellType() == Cell.CELL_TYPE_NUMERIC) { 
75. ​       String cellValue = ""; 
76. ​       **if**(XSSFDateUtil.isCellDateFormatted(xssfCell)){ 
77. ​         Date date = XSSFDateUtil.getJavaDate(xssfCell.getNumericCellValue()); 
78. ​         cellValue = sdf.format(date); 
79. ​       }**else**{ 
80. ​         DecimalFormat df = **new** DecimalFormat("#.##"); 
81. ​         cellValue = df.format(xssfCell.getNumericCellValue()); 
82. ​         String strArr = cellValue.substring(cellValue.lastIndexOf(POINT)+1,cellValue.length()); 
83. ​         **if**(strArr.equals("00")){ 
84. ​           cellValue = cellValue.substring(0, cellValue.lastIndexOf(POINT)); 
85. ​         }  
86. ​       } 
87. ​       **return** cellValue; 
88. ​     } **else** { 
89. ​      **return** String.valueOf(xssfCell.getStringCellValue()); 
90. ​     } 
91.   }   
92. /** 
93.  \* 自定义xssf日期工具类 
94.  \* @author lp 
95.  \* 
96.  */ 
97. **class** XSSFDateUtil **extends** DateUtil{ 
98.   **protected** **static** **int** absoluteDay(Calendar cal, **boolean** use1904windowing) {  
99. ​    **return** DateUtil.absoluteDay(cal, use1904windowing);  
100.   }  
101. }</span></span> 

2、ExcelRead：读取Excel类

 

[java] [view plain](http://blog.csdn.net/lp1791803611/article/details/52351333#) [copy](http://blog.csdn.net/lp1791803611/article/details/52351333#)



1. **package** com.ssm.util; 
2.  
3. **import** java.io.IOException; 
4. **import** java.io.InputStream; 
5. **import** java.util.ArrayList; 
6. **import** java.util.List; 
7.  
8. **import** org.apache.poi.hssf.usermodel.HSSFCell; 
9. **import** org.apache.poi.hssf.usermodel.HSSFRow; 
10. **import** org.apache.poi.hssf.usermodel.HSSFSheet; 
11. **import** org.apache.poi.hssf.usermodel.HSSFWorkbook; 
12. **import** org.apache.poi.xssf.usermodel.XSSFCell; 
13. **import** org.apache.poi.xssf.usermodel.XSSFRow; 
14. **import** org.apache.poi.xssf.usermodel.XSSFSheet; 
15. **import** org.apache.poi.xssf.usermodel.XSSFWorkbook; 
16. **import** org.springframework.web.multipart.MultipartFile; 
17. /** 
18.  \* 读取Excel 
19.  \* @author lp 
20.  \* 
21.  */ 
22. **public** **class** ExcelRead {   
23.   **public** **int** totalRows; //sheet中总行数 
24.   **public** **static** **int** totalCells; //每一行总单元格数 
25.   /** 
26.    \* read the Excel .xlsx,.xls 
27.    \* @param file jsp中的上传文件 
28.    \* @return 
29.    \* @throws IOException 
30.    */ 
31.   **public** List<ArrayList<String>> readExcel(MultipartFile file) **throws** IOException { 
32. ​    **if**(file==**null**||ExcelUtil.EMPTY.equals(file.getOriginalFilename().trim())){ 
33. ​      **return** **null**; 
34. ​    }**else**{ 
35. ​      String postfix = ExcelUtil.getPostfix(file.getOriginalFilename()); 
36. ​      **if**(!ExcelUtil.EMPTY.equals(postfix)){ 
37. ​        **if**(ExcelUtil.OFFICE_EXCEL_2003_POSTFIX.equals(postfix)){ 
38. ​          **return** readXls(file); 
39. ​        }**else** **if**(ExcelUtil.OFFICE_EXCEL_2010_POSTFIX.equals(postfix)){ 
40. ​          **return** readXlsx(file); 
41. ​        }**else**{          
42. ​          **return** **null**; 
43. ​        } 
44. ​      } 
45. ​    } 
46. ​    **return** **null**; 
47.   } 
48.   /** 
49.    \* read the Excel 2010 .xlsx 
50.    \* @param file 
51.    \* @param beanclazz 
52.    \* @param titleExist 
53.    \* @return 
54.    \* @throws IOException 
55.    */ 
56.   @SuppressWarnings("deprecation") 
57.   **public** List<ArrayList<String>> readXlsx(MultipartFile file){ 
58. ​    List<ArrayList<String>> list = **new** ArrayList<ArrayList<String>>(); 
59. ​    // IO流读取文件 
60. ​    InputStream input = **null**; 
61. ​    XSSFWorkbook wb = **null**; 
62. ​    ArrayList<String> rowList = **null**; 
63. ​    **try** { 
64. ​      input = file.getInputStream(); 
65. ​      // 创建文档 
66. ​      wb = **new** XSSFWorkbook(input);             
67. ​      //读取sheet(页) 
68. ​      **for**(**int** numSheet=0;numSheet<wb.getNumberOfSheets();numSheet++){ 
69. ​        XSSFSheet xssfSheet = wb.getSheetAt(numSheet); 
70. ​        **if**(xssfSheet == **null**){ 
71. ​          **continue**; 
72. ​        } 
73. ​        totalRows = xssfSheet.getLastRowNum();        
74. ​        //读取Row,从第二行开始 
75. ​        **for**(**int** rowNum = 1;rowNum <= totalRows;rowNum++){ 
76. ​          XSSFRow xssfRow = xssfSheet.getRow(rowNum); 
77. ​          **if**(xssfRow!=**null**){ 
78. ​            rowList = **new** ArrayList<String>(); 
79. ​            totalCells = xssfRow.getLastCellNum(); 
80. ​            //读取列，从第一列开始 
81. ​            **for**(**int** c=0;c<=totalCells+1;c++){ 
82. ​              XSSFCell cell = xssfRow.getCell(c); 
83. ​              **if**(cell==**null**){ 
84. ​                rowList.add(ExcelUtil.EMPTY); 
85. ​                **continue**; 
86. ​              }               
87. ​              rowList.add(ExcelUtil.getXValue(cell).trim()); 
88. ​            }   
89. ​          list.add(rowList);                      
90. ​          } 
91. ​        } 
92. ​      } 
93. ​      **return** list; 
94. ​    } **catch** (IOException e) {       
95. ​      e.printStackTrace(); 
96. ​    } **finally**{ 
97. ​      **try** { 
98. ​        input.close(); 
99. ​      } **catch** (IOException e) { 
100. ​        e.printStackTrace(); 
101. ​      } 
102. ​    } 
103. ​    **return** **null**; 
104. ​     
105.   } 
106.   /** 
107.    \* read the Excel 2003-2007 .xls 
108.    \* @param file 
109.    \* @param beanclazz 
110.    \* @param titleExist 
111.    \* @return 
112.    \* @throws IOException 
113.    */ 
114.   **public** List<ArrayList<String>> readXls(MultipartFile file){  
115. ​    List<ArrayList<String>> list = **new** ArrayList<ArrayList<String>>(); 
116. ​    // IO流读取文件 
117. ​    InputStream input = **null**; 
118. ​    HSSFWorkbook wb = **null**; 
119. ​    ArrayList<String> rowList = **null**; 
120. ​    **try** { 
121. ​      input = file.getInputStream(); 
122. ​      // 创建文档 
123. ​      wb = **new** HSSFWorkbook(input);             
124. ​      //读取sheet(页) 
125. ​      **for**(**int** numSheet=0;numSheet<wb.getNumberOfSheets();numSheet++){ 
126. ​        HSSFSheet hssfSheet = wb.getSheetAt(numSheet); 
127. ​        **if**(hssfSheet == **null**){ 
128. ​          **continue**; 
129. ​        } 
130. ​        totalRows = hssfSheet.getLastRowNum();        
131. ​        //读取Row,从第二行开始 
132. ​        **for**(**int** rowNum = 1;rowNum <= totalRows;rowNum++){ 
133. ​          HSSFRow hssfRow = hssfSheet.getRow(rowNum); 
134. ​          **if**(hssfRow!=**null**){ 
135. ​            rowList = **new** ArrayList<String>(); 
136. ​            totalCells = hssfRow.getLastCellNum(); 
137. ​            //读取列，从第一列开始 
138. ​            **for**(**short** c=0;c<=totalCells+1;c++){ 
139. ​              HSSFCell cell = hssfRow.getCell(c); 
140. ​              **if**(cell==**null**){ 
141. ​                rowList.add(ExcelUtil.EMPTY); 
142. ​                **continue**; 
143. ​              }               
144. ​              rowList.add(ExcelUtil.getHValue(cell).trim()); 
145. ​            }     
146. ​            list.add(rowList); 
147. ​          }           
148. ​        } 
149. ​      } 
150. ​      **return** list; 
151. ​    } **catch** (IOException e) {       
152. ​      e.printStackTrace(); 
153. ​    } **finally**{ 
154. ​      **try** { 
155. ​        input.close(); 
156. ​      } **catch** (IOException e) { 
157. ​        e.printStackTrace(); 
158. ​      } 
159. ​    } 
160. ​    **return** **null**; 
161.   } 
162. } 