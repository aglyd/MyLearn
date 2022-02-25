# [java实现创建临时文件然后在程序退出时自动删除文件](https://www.cnblogs.com/haw2106/p/10280967.html)

这篇文章主要介绍了java实现创建临时文件然后在程序退出时自动删除文件，从个人项目中提取出来的，小伙伴们可以直接拿走使用。

　　通过java的File类创建临时文件，然后在程序退出时自动删除临时文件。下面将通过创建一个JFrame界面，点击创建按钮在当前目录下面创建temp文件夹且创建一个以mytempfile******.tmp格式的文本文件。代码如下：

```
import java.io.*;
import java.util.*;
import javax.swing.*;
import java.awt.event.*;

/**
 * 功能: 创建临时文件(在指定的路径下)
 */
public class TempFile implements ActionListener {

    private File tempPath;

    public static void main(String args[]){
        TempFile ttf = new TempFile();
        ttf.init();
        ttf.createUI();
     }

    //创建UI
    public void createUI() {
        JFrame frame = new JFrame();
        JButton jb = new JButton("创建临时文件");
        jb.addActionListener(this);
        frame.add(jb,"North");
        frame.setSize(200,100);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);
    }

    //初始化
    public void init(){
        tempPath = new File("./temp");
        if(!tempPath.exists() || !tempPath.isDirectory()) {
            tempPath.mkdir(); //如果不存在，则创建该文件夹
        }
    }

    //处理事件
    public void actionPerformed(ActionEvent e) {
        try {
            //在tempPath路径下创建临时文件"mytempfileXXXX.tmp"
            //XXXX 是系统自动产生的随机数, tempPath对应的路径应事先存在
            File tempFile = File.createTempFile("mytempfile", ".txt", tempPath);
            System.out.println(tempFile.getAbsolutePath());
            FileWriter fout = new FileWriter(tempFile);
            PrintWriter out = new PrintWriter(fout);
            out.println("some info!" );
            out.close(); //注意：如无此关闭语句，文件将不能删除
            //tempFile.delete();
            tempFile.deleteOnExit();	//程序退出时删除
        } catch(IOException e1) {
            System.out.println(e1);
        }
    }

}
```

