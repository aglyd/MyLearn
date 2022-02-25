# 使用ZipEntry压缩与解压缩

```
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.zip.CRC32;
import java.util.zip.CheckedOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

import org.apache.log4j.Logger;

public class ZipUtil {
    private static Logger logger = Logger.getLogger(ZipUtil.class);
    /**
     * 递归压缩文件夹
     * 
     * @param srcRootDir
     *            压缩文件夹根目录的子路径
     * @param file
     *            当前递归压缩的文件或目录对象
     * @param zos
     *            压缩文件存储对象
     * @throws Exception
     */
    private static void zip(String srcRootDir, File file, ZipOutputStream zos)
            throws Exception {
        if (file == null) {
            return;
        }
```




        // 如果是文件，则直接压缩该文件
        if (file.isFile()) {
            int count, bufferLen = 1024;
            byte data[] = new byte[bufferLen];
    
            // 获取文件相对于压缩文件夹根目录的子路径
            String subPath = file.getAbsolutePath();
            int index = subPath.indexOf(srcRootDir);
            if (index != -1) {
                subPath = subPath.substring(srcRootDir.length()
                        + File.separator.length());
            }
            ZipEntry entry = new ZipEntry(subPath);
            zos.putNextEntry(entry);
            BufferedInputStream bis = new BufferedInputStream(
                    new FileInputStream(file));
            while ((count = bis.read(data, 0, bufferLen)) != -1) {
                zos.write(data, 0, count);
            }
            bis.close();
            zos.closeEntry();
        }
        // 如果是目录，则压缩整个目录
        else {
            // 压缩目录中的文件或子目录
            File[] childFileList = file.listFiles();
            for (int n = 0; n < childFileList.length; n++) {
                childFileList[n].getAbsolutePath().indexOf(
                        file.getAbsolutePath());
                zip(srcRootDir, childFileList[n], zos);
            }
        }
    }
    
    /**
     * 对文件或文件目录进行压缩
     * 
     * @param srcPath
     *            要压缩的源文件路径。如果压缩一个文件，则为该文件的全路径；如果压缩一个目录，则为该目录的顶层目录路径
     * @param zipPath
     *            压缩文件保存的路径。注意：zipPath不能是srcPath路径下的子文件夹
     * @param zipFileName
     *            压缩文件名
     * @throws Exception
     */
    public static void zip(String srcPath, String zipPath, String zipFileName)
            throws Exception {
        if (isEmpty(srcPath) || isEmpty(zipPath) || isEmpty(zipFileName)) {
            throw new Exception("PARAMETER_IS_NULL");
        }
        CheckedOutputStream cos = null;
        ZipOutputStream zos = null;
        try {
            File srcFile = new File(srcPath);
    
            // 判断压缩文件保存的路径是否为源文件路径的子文件夹，如果是，则抛出异常（防止无限递归压缩的发生）
            if (srcFile.isDirectory() && zipPath.indexOf(srcPath) != -1) {
                throw new Exception(
                        "zipPath must not be the child directory of srcPath.");
            }
    
            // 判断压缩文件保存的路径是否存在，如果不存在，则创建目录
            File zipDir = new File(zipPath);
            if (!zipDir.exists() || !zipDir.isDirectory()) {
                zipDir.mkdirs();
            }
    
            // 创建压缩文件保存的文件对象
            String zipFilePath = zipPath + File.separator + zipFileName;
            File zipFile = new File(zipFilePath);
            if (zipFile.exists()) {
                // 检测文件是否允许删除，如果不允许删除，将会抛出SecurityException
                SecurityManager securityManager = new SecurityManager();
                securityManager.checkDelete(zipFilePath);
                // 删除已存在的目标文件
                zipFile.delete();
            }
    
            cos = new CheckedOutputStream(new FileOutputStream(zipFile),
                    new CRC32());
            zos = new ZipOutputStream(cos);
    
            // 如果只是压缩一个文件，则需要截取该文件的父目录
            String srcRootDir = srcPath;
            if (srcFile.isFile()) {
                int index = srcPath.lastIndexOf(File.separator);
                if (index != -1) {
                    srcRootDir = srcPath.substring(0, index);
                }
            }
            // 调用递归压缩方法进行目录或文件压缩
            zip(srcRootDir, srcFile, zos);
            zos.flush();
        } catch (Exception e) {
            throw e;
        } finally {
            try {
                if (zos != null) {
                    zos.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * 解压缩zip包
     * 
     * @param zipFilePath
     *            zip文件的全路径
     * @param unzipFilePath
     *            解压后的文件保存的路径
     * @param includeZipFileName
     *            解压后的文件保存的路径是否包含压缩文件的文件名。true-包含；false-不包含
     */
    @SuppressWarnings("unchecked")
    public static void unzip(String zipFilePath, String unzipFilePath,
            boolean includeZipFileName) throws Exception {
        if (isEmpty(zipFilePath) || isEmpty(unzipFilePath)) {
            throw new Exception("PARAMETER_IS_NULL");
        }
        File zipFile = new File(zipFilePath);
        // 如果解压后的文件保存路径包含压缩文件的文件名，则追加该文件名到解压路径
        if (includeZipFileName) {
            String fileName = zipFile.getName();
            if (isNotEmpty(fileName)) {
                fileName = fileName.substring(0, fileName.lastIndexOf("."));
            }
            unzipFilePath = unzipFilePath + File.separator + fileName;
        }
        // 创建解压缩文件保存的路径
        File unzipFileDir = new File(unzipFilePath);
        if (!unzipFileDir.exists() || !unzipFileDir.isDirectory()) {
            unzipFileDir.mkdirs();
        }
    
        // 开始解压
        ZipEntry entry = null;
        String entryFilePath = null, entryDirPath = null;
        File entryFile = null, entryDir = null;
        int index = 0, count = 0, bufferSize = 1024;
        byte[] buffer = new byte[bufferSize];
        BufferedInputStream bis = null;
        BufferedOutputStream bos = null;
        //E:\projectTest\downloadPath\payseat_1.0
        ZipFile zip = new ZipFile(zipFile);
        Enumeration<ZipEntry> entries = (Enumeration<ZipEntry>) zip.entries();
        // 循环对压缩包里的每一个文件进行解压
        while (entries.hasMoreElements()) {
            entry = entries.nextElement();
            if (entry.isDirectory()) {
                continue;
            }
            // 构建压缩包中一个文件解压后保存的文件全路径
            entryFilePath = unzipFilePath + File.separator + entry.getName();
            // 构建解压后保存的文件夹路径
            index = entryFilePath.lastIndexOf(File.separator)>entryFilePath.lastIndexOf("/")?entryFilePath.lastIndexOf(File.separator):entryFilePath.lastIndexOf("/");
            if (index != -1) {
                entryDirPath = entryFilePath.substring(0, index);
            } else {
                entryDirPath = "";
            }
            entryDir = new File(entryDirPath);
            // 如果文件夹路径不存在，则创建文件夹
            if (!entryDir.exists() || !entryDir.isDirectory()) {
                entryDir.mkdirs();
            }
    
            // 创建解压文件
            entryFile = new File(entryFilePath);
            if (entryFile.exists()) {
                /*// 检测文件是否允许删除，如果不允许删除，将会抛出SecurityException
                SecurityManager securityManager = new SecurityManager();
                securityManager.checkDelete(entryFilePath);*/
                // 删除已存在的目标文件
                entryFile.delete();
            }
            try {
                // 写入文件
                bos = new BufferedOutputStream(new FileOutputStream(entryFile));
                bis = new BufferedInputStream(zip.getInputStream(entry));
                while ((count = bis.read(buffer, 0, bufferSize)) != -1) {
                    bos.write(buffer, 0, count);
                }
                bos.flush();
                bos.close();
                bis.close();
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                logger.warn("unzip file "+entry.getName()+" exception :"+e);
            }
    
        }
    
    }
    @SuppressWarnings("unchecked")
    public static void unPartZip(String zipFilePath, String unzipFilePath) throws Exception {
        if (isEmpty(zipFilePath) || isEmpty(unzipFilePath)) {
            throw new Exception("PARAMETER_IS_NULL");
        }
        File zipFile = new File(zipFilePath);
    
        // 创建解压缩文件保存的路径
        File unzipFileDir = new File(unzipFilePath);
        if (!unzipFileDir.exists() || !unzipFileDir.isDirectory()) {
            unzipFileDir.mkdirs();
        }
    
        // 开始解压
        ZipEntry entry = null;
        String entryFilePath = null, entryDirPath = null;
        File entryFile = null, entryDir = null;
        int index = 0, count = 0, bufferSize = 1024;
        byte[] buffer = new byte[bufferSize];
        BufferedInputStream bis = null;
        BufferedOutputStream bos = null;
        //E:\projectTest\downloadPath\payseat_1.0
        ZipFile zip = new ZipFile(zipFile);
        Enumeration<ZipEntry> entries = (Enumeration<ZipEntry>) zip.entries();
        // 循环对压缩包里的每一个文件进行解压
        while (entries.hasMoreElements()) {
            entry = entries.nextElement();
            if (entry.isDirectory()) {
                continue;
            }
            // 构建压缩包中一个文件解压后保存的文件全路径
            entryFilePath = unzipFilePath + File.separator + entry.getName();
            // 构建解压后保存的文件夹路径
            index = entryFilePath.lastIndexOf(File.separator)>entryFilePath.lastIndexOf("/")?entryFilePath.lastIndexOf(File.separator):entryFilePath.lastIndexOf("/");
            if (index != -1) {
                entryDirPath = entryFilePath.substring(0, index);
            } else {
                entryDirPath = "";
            }
            entryDir = new File(entryDirPath);
            // 如果文件夹路径不存在，则创建文件夹
            if (!entryDir.exists() || !entryDir.isDirectory()) {
                entryDir.mkdirs();
            }
    
            // 创建解压文件
            entryFile = new File(entryFilePath);
            if (entryFile.exists()) {
                /*// 检测文件是否允许删除，如果不允许删除，将会抛出SecurityException
                SecurityManager securityManager = new SecurityManager();
                securityManager.checkDelete(entryFilePath);*/
                // 删除已存在的目标文件
                entryFile.delete();
            }
            try {
                // 写入文件
                bos = new BufferedOutputStream(new FileOutputStream(entryFile));
                bis = new BufferedInputStream(zip.getInputStream(entry));
                while ((count = bis.read(buffer, 0, bufferSize)) != -1) {
                    bos.write(buffer, 0, count);
                }
                bos.flush();
                bos.close();
                bis.close();
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                logger.warn("unzip file "+entry.getName()+" exception :"+e);
            }
    
        }
    
    }
    
    /**
     * @description:生成最新的版本文件全量包
     * @return
     */
    public static File createDownloadZip(){
        //备份保存目录
        String backupPath = SysPropUtil.getValue("backupPath");
        //当前版本信息
        String currentVersion = SysPropUtil.getValue("currentVersion");
        String currentKey = SysPropUtil.getValue("currentVersionKey");
        String currentVersionStartTime = SysPropUtil.getValue("currentVersionStartTime");
        //更新版本信息
        String updateVersion = SysPropUtil.getValue("updateVersion");
        String updateVersionKey = SysPropUtil.getValue("updateVersionKey");
        String updateVersionStartTime = SysPropUtil.getValue("updateVersionStartTime");
        //
        String currentZipName = currentVersion+"_"+currentKey+"_"+currentVersionStartTime;
        String updateZipName = updateVersion+"_"+updateVersionKey+"_"+updateVersionStartTime;
        String updateFile = backupPath+"\\"+updateZipName+".zip";       
        //当前版本的全量包
        String fullCurrentFile = backupPath+"\\"+currentZipName+"_F.zip";
        //生成的供下载的版本的全量包
        String fullUpdateFile = backupPath+"\\"+updateZipName+"_F.zip";
    
        ZipFile currentZip = null;
        ZipFile updateZip = null;
        ZipOutputStream zos = null;
        //当前版本全量压缩包
        File currentFile = null;
        //结果全量压缩包
        File resultFile = null;
        try{
            currentFile = new File(fullCurrentFile);
            resultFile = new File(fullUpdateFile);
    
            //当前版本全量压缩包已存在则跳过
            if (!currentFile.exists()) {
                //生成当前版本的全量压缩包
                zip("C:\\cuss\\apps",backupPath,currentZipName+"_F.zip");
            }
    
            //结果全量压缩包已存在直接返回
            if (resultFile.exists() && resultFile.length() > 0) {
                return resultFile;
            }
    
            zos = new ZipOutputStream(new FileOutputStream(fullUpdateFile));            
    
            currentZip = new ZipFile(currentFile);
            updateZip = new ZipFile(new File(updateFile));
            Enumeration<? extends ZipEntry> currentEntrys = currentZip.entries();
            Enumeration<? extends ZipEntry> updateEntrys = updateZip.entries();


            String currentInnerName = "";
            String updateInnerName = "";
    
            //最新版本压缩包的所有内容都应放入生成的最新全量压缩包
            while(updateEntrys.hasMoreElements()){
                ZipEntry update = updateEntrys.nextElement();
                //获取压缩包内文件名
                updateInnerName = getInnerName(update,updateVersion);                   
                if(!updateInnerName.equals("")){
                    ZipEntry entry = new ZipEntry(updateInnerName);
                    zos.putNextEntry(entry);
                    putNextEntry(updateZip,update,zos);
                }
            }


            while(currentEntrys.hasMoreElements()){
                ZipEntry current = currentEntrys.nextElement();
                //获取压缩包内文件名
                currentInnerName = getInnerName(current,currentVersion);
                //是否有同名文件
                boolean hasSameOne = false;
                Enumeration<? extends ZipEntry> updateEntrys2 = updateZip.entries();
                while(updateEntrys2.hasMoreElements()){
                    ZipEntry update = updateEntrys2.nextElement();
                    //获取压缩包内文件名
                    updateInnerName = getInnerName(update,updateVersion);
                    //如果有同名文件
                    if(currentInnerName.equals(updateInnerName)){
                        hasSameOne = true;
                        break;
                    }                   
                }
                //没有同名文件
                if(hasSameOne == false && !currentInnerName.equals("")){
                    ZipEntry entry = new ZipEntry(currentInnerName);
                    zos.putNextEntry(entry);
                    putNextEntry(currentZip,current,zos);
                }
    
            }
    
            zos.flush();
            currentZip.close();
            updateZip.close();
    
            return resultFile;
        }catch(Exception e){
            e.printStackTrace();
            return null;
        }finally{
            try {
                if(zos !=null){
                    zos.close();
                }
                //删除当前版本临时全量压缩包
                //new File(fullCurrentFile).delete();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    
    }
    /**
     * 
     * @Description:专为生效动作打造的解压缩方法
     * @param zipFilePath   压缩文件
     * @param unZipPath 解压目录
     * @param versionName   包含的版本
     */
    public static boolean unZip(String zipFilePath,String unZipPath,String versionName) {
        boolean result = true;
        ZipFile zip = null;
        try{
            zip = new ZipFile(zipFilePath);
            //String zipFileName = zip.getName();
            //String zipName = zipFileName.substring(zipFileName.lastIndexOf("\\")+1,
            //      zipFileName.length()-4);
    
            Enumeration<? extends ZipEntry> entrys = zip.entries();
    
            ZipEntry entry;
            String name;
            String path;
            File file;
            FileOutputStream fos;
            BufferedOutputStream bos;
            InputStream input;
            BufferedInputStream bis;
            while(entrys.hasMoreElements()){
                entry = entrys.nextElement();
                name = getInnerName(entry,versionName);
                path = unZipPath+"\\"+name;
                file = new File(path);
                //根目录
                if("".equals(name)){
                    continue;
                }
                //文件夹
                if(name.endsWith("/")) {
                    file.mkdir();
                    continue;
                }
                else {
                    file.createNewFile();
                }
    
                //压缩文件输入输出
                fos = new FileOutputStream(file);
                bos = new BufferedOutputStream(fos);
    
                byte[] buf = new byte[1024];
                int read;
                input = zip.getInputStream(entry);
                bis = new BufferedInputStream(input);
                while((read = bis.read(buf,0,buf.length)) != -1){
                    bos.write(buf,0,read);
                }
                bos.flush();
                input.close();
                fos.close();
            }
    
            return result;
        } catch(Exception e) {      
            e.printStackTrace();
    
            return false;
        }
    }
    
    private static void putNextEntry(ZipFile zip,ZipEntry entry,ZipOutputStream zos){
        try {
            InputStream input = zip.getInputStream(entry);
            byte[] buf = new byte[1024];
            int read;
            while((read = input.read(buf,0,buf.length)) != -1){
                zos.write(buf,0,read);
            }
    
            zos.closeEntry();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private static String getInnerName(ZipEntry entry,String versionName){
        String name = entry.getName();
        if(name.indexOf(versionName) != -1){
        String  result = name.substring((versionName+File.separator).length());         
            return result;
        }else{
            return name;
        }       
    }



    public static boolean isEmpty(String s) {
        if (s == null || s.equals(""))
            return true;
        else
            return false;
    }
    
    public static boolean isNotEmpty(String s) {
        return !isEmpty(s);
    }
    
    /*public static void main(String[] args) {
        String zipPath = "C:\\cuss\\apps";
        String dir = "C:\\Users\\dgy\\Desktop\\backup";
        String zipFileName = "CussStore_V3.4.1.zip";
        try {
            zip(zipPath, dir, zipFileName);
        } catch (Exception e) {
            e.printStackTrace();
        }
        File file = ZipUtil.createDownloadZip();
        System.out.println(file.length());
    }*/
