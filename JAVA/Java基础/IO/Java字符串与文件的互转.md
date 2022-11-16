# [Java字符串与文件的互转][https://blog.csdn.net/weixin_34112030/article/details/90072778]

一、字符串转换为文件

 

```java
    /** 
​     \* 将字符串写入指定文件(当指定的父路径中文件夹不存在时，会最大限度去创建，以保证保存成功！) 
​     \* 
​     \* @param res      原字符串 
​     \* @param filePath 文件路径 
​     \* @return 成功标记 
​     */ 
​     public static boolean string2File(String res, String filePath) { 
​         boolean flag = true; 
​        BufferedReader bufferedReader = null; 
​        BufferedWriter bufferedWriter = null; 
​         try { 
​            File distFile = new File(filePath); 
​             if (!distFile.getParentFile().exists()) distFile.getParentFile().mkdirs(); 
​            bufferedReader = new BufferedReader( new StringReader(res)); 
​            bufferedWriter = new BufferedWriter( new FileWriter(distFile)); 
​             char buf[] = new char[1024];     //字符缓冲区 
​             int len; 
​             while ((len = bufferedReader.read(buf)) != -1) { 
​                bufferedWriter.write(buf, 0, len); 
​            } 
​            bufferedWriter.flush(); 
​            bufferedReader.close(); 
​            bufferedWriter.close(); 
​        } catch (IOException e) { 
​            e.printStackTrace(); 
​            flag = false; 
​             return flag; 
​        } finally { 
​             if (bufferedReader != null) { 
​                 try { 
​                    bufferedReader.close(); 
​                } catch (IOException e) { 
​                    e.printStackTrace(); 
​                } 
​            } 
​        } 
​         return flag; 
​    }


```

二、文件转换为字符串

```java
    /** 
     \* 文本文件转换为指定编码的字符串 
     \* 
     \* @param file     文本文件 
     \* @param encoding 编码类型 
     \* @return 转换后的字符串 
     \* @throws IOException 
     */ 
     public static String file2String(File file, String encoding) { 
        InputStreamReader reader = null; 
        StringWriter writer = new StringWriter(); 
         try { 
             if (!(encoding == null || "".equals(encoding.trim()))) { 
                reader = new InputStreamReader( new FileInputStream(file), encoding); 
            } else { 
                reader = new InputStreamReader( new FileInputStream(file)); 
            } 
             //将输入流写入输出流 
             char[] buffer = new char[DEFAULT_BUFFER_SIZE]; 
             int n = 0; 
             while (-1 != (n = reader.read(buffer))) { 
                writer.write(buffer, 0, n); 
            } 
        } catch (Exception e) { 
            e.printStackTrace(); 
             return null; 
        } finally { 
             if (reader != null) 
                 try { 
                    reader.close(); 
                } catch (IOException e) { 
                    e.printStackTrace(); 
                } 
        } 
         //返回转换结果 
         if (writer != null) 
             return writer.toString(); 
         else return null; 
    }
```

 

不想抛出太多的检查异常，如果你需要捕捉，就抛出吧。

 

注意：对于文件转换为字符串，存在一个编码问题。上面的file2String方法中，如果你不知道编码，调用时候方法设为null即可，此时使用系统默认的编码类型。