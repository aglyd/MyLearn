# [java中Xml、json之间的相互转换](https://www.cnblogs.com/tv151579/p/3516674.html)

工具类：

```
package exercise.xml;

import net.sf.json.JSON;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;

import org.jdom.Document;

public class XmlExercise {

    /**
     * 将xml字符串<STRONG>转换</STRONG>为JSON字符串
     * 
     * @param xmlString
     *            xml字符串
     * @return JSON<STRONG>对象</STRONG>
     */
    public static String xml2json(String xmlString) {
        XMLSerializer xmlSerializer = new XMLSerializer();
        JSON json = xmlSerializer.read(xmlString);
        return json.toString(1);
    }

    /**
     * 将xmlDocument<STRONG>转换</STRONG>为JSON<STRONG>对象</STRONG>
     * 
     * @param xmlDocument
     *            XML Document
     * @return JSON<STRONG>对象</STRONG>
     */
    public static String xml2json(Document xmlDocument) {
        return xml2json(xmlDocument.toString());
    }

    /**
     * JSON(数组)字符串<STRONG>转换</STRONG>成XML字符串
     * 
     * @param jsonString
     * @return
     */
    public static String json2xml(String jsonString) {
        XMLSerializer xmlSerializer = new XMLSerializer();
        return xmlSerializer.write(JSONSerializer.toJSON(jsonString));
        // return xmlSerializer.write(JSONArray.fromObject(jsonString));//这种方式只支持JSON数组
    }

}
```

测试类：

```
package exercise.xml;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class XmlTest extends XmlExercise {

    public static void main(String[] args) {

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("username", "horizon");
        JSONArray jsonArray = new JSONArray();
        JSONObject dataJson = new JSONObject();
        jsonArray.add(jsonObject);
        //jsonArray.add(jsonObject);
        dataJson.put("data", jsonArray);
        System.out.println(dataJson.toString());

        String xml = json2xml(dataJson.toString());
        System.out.println("xml:" + xml);
        String str = xml2json(xml);
        System.out.println("to_json" + str);

    }
}
```



-----



# [java json转换xml格式_xml和JSON格式相互转换的Java实现][https://blog.csdn.net/weixin_31001069/article/details/114463949]

依赖的包:

json-lib-2.4-jdk15.jar

ezmorph-1.0.6.jar

xom-1.2.1.jar

commons-lang-2.1.jar

commons-io-1.3.2.jar

jaxen-1.1.jar

```
package com.cash.util;

import java.io.IOException;

import java.io.InputStream;

import org.apache.commons.io.IOUtils;

import net.sf.json.JSON;

import net.sf.json.xml.XMLSerializer;

public class Test {

/**
*输入xml文件,输出JSON对象
*/
public static void ConvertXMLtoJSON() {
InputStream is = ConvertXMLtoJSON.class.getResourceAsStream("sample.xml");

String xml;

try {
xml = IOUtils.toString(is);

System.out.println(xml);

XMLSerializer xmlSerializer = new XMLSerializer();

JSON json = xmlSerializer.read(xml);

System.out.println(json.toString(1));

} catch (IOException e) {
e.printStackTrace();

}

}
}

/**

* 将xml字符串转换为JSON对象

* @param xmlFile xml字符串

* @return JSON对象

*/

public JSON getJSONFromXml(String xmlString) {
XMLSerializer xmlSerializer = new XMLSerializer();

JSON json = xmlSerializer.read(xmlString);

return json;

}

/**

* 将xmlDocument转换为JSON对象

* @param xmlDocument XML Document

* @return JSON对象

*/

public JSON getJSONFromXml(Document xmlDocument) {
String xmlString = xmlDocument.toString();

return getJSONFromXml(xmlString);

}

/**

* 将xml字符串转换为JSON字符串

* @param xmlString

* @return JSON字符串

*/

public String getJSONStringFromXml(String xmlString ) {
return getJSONFromXml(xmlString).toString();

}

/**

*将xmlDocument转换为JSON字符串

* @param xmlDocument XML Document

* @return JSON字符串

*/

public String getXMLtoJSONString(Document xmlDocument) {
return getJSONStringFromXml(xmlDocument.toString());

}

/**

* 读取XML文件准换为JSON字符串

* @param xmlFile XML文件

* @return JSON字符串

*/

public String getXMLFiletoJSONString(String xmlFile) {
InputStream is = JsonUtil.class.getResourceAsStream(xmlFile);

String xml;

JSON json = null;

try {
xml = IOUtils.toString(is);

XMLSerializer xmlSerializer = new XMLSerializer();

json = xmlSerializer.read(xml);

} catch (IOException e) {
e.printStackTrace();

}

return json.toString();

}

/**

* 将Java对象转换为JSON格式的字符串

*

* @param javaObj

* POJO,例如日志的model

* @return JSON格式的String字符串

*/

public static String getJsonStringFromJavaPOJO(Object javaObj) {
return JSONObject.fromObject(javaObj).toString(1);

}

/**

* 将Map准换为JSON字符串

* @param map

* @return JSON字符串

*/

public static String getJsonStringFromMap(Map, ?> map) {
JSONObject object = JSONObject.fromObject(map);

return object.toString();

}
```





-----

```
		<dependency>
          <groupId>xerces</groupId>
          <artifactId>xercesImpl</artifactId>
          <version>2.9.1</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/xom/xom -->
        <dependency>
            <groupId>xom</groupId>
            <artifactId>xom</artifactId>
            <version>1.0</version>
        </dependency>
```

```
package com.han;
import org.apache.commons.io.FileUtils;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import net.sf.json.JSONObject;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;

public class XmlFormatter {

        //格式化
    public String format(String unformattedXml) {
        try {
            final Document document = parseXmlFile(unformattedXml);
            OutputFormat format = new OutputFormat(document);
            format.setLineWidth(65);
            format.setIndenting(true);
            format.setIndent(2);
            Writer out = new StringWriter();
            XMLSerializer serializer = new XMLSerializer(out, format);
            serializer.serialize(document);
            return out.toString();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

	//无效？待查DocumentBuilder.parse()
    private Document parseXmlFile(String in) {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            InputSource is = new InputSource(new StringReader(in));
            return db.parse(is);
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        } catch (SAXException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

        //转化为String
    public static String jsonToXML(String json) {
        net.sf.json.xml.XMLSerializer xmlSerializer = new net.sf.json.xml.XMLSerializer();
        // 根节点名称
        xmlSerializer.setRootName("resource");
        // 不对类型进行设置
        xmlSerializer.setTypeHintsEnabled(false);
        String xmlStr = "";
        JSONObject jobj = JSONObject.fromObject(json);
        xmlStr = xmlSerializer.write(jobj);
        return xmlStr;
    }

    public static void main(String[] args) throws Exception{
        String aa = "{\"index\":\"0\",\"title\":null,\"order\":\"0\",\"componentKey\":\"ColumnPanel\",\"layoutDetail\":[{\"aa\":\"12\"}]}";
        // String original_filename= "/Users/xidehan/Downloads/aa.txt";
       //String file = FileUtils.readFileToString(new File(original_filename));
        String s = jsonToXML(file);

        System.out.println(new XmlFormatter().format(s));
        PrintWriter writer = new PrintWriter("/Users/xidehan/Downloads/resource.xml", "UTF-8");
        writer.println(new XmlFormatter().format(s));
        writer.close();
    }
```

