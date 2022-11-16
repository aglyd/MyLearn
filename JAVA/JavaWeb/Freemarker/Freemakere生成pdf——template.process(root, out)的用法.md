# 一、[Freemakere生成pdf——template.process(root, out)的用法](https://blog.csdn.net/weixin_33901926/article/details/85970319)

```java
Writer out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "utf-8"));
2             Template template = getTemplate(ftlName, ftlPath);
3             template.process(root, out);
 1     public static Template getTemplate(String ftlName, String ftlPath) throws Exception{
 2         try {
 3             Configuration cfg = new Configuration();                                                  //通过Freemaker的Configuration读取相应的ftl
 4             cfg.setEncoding(Locale.CHINA, "utf-8");
 5             cfg.setDirectoryForTemplateLoading(new File(PathUtil.getClassResources()+"/ftl/"+ftlPath));        //设定去哪里读取相应的ftl模板文件
 6             Template temp = cfg.getTemplate(ftlName);                                                //在模板文件目录中找到名称为name的文件
 7             return temp;
 8         } catch (IOException e) {
 9             e.printStackTrace();
10         }
11         return null;
12     }
```

template 就是获取的模板

```java
package com.fh.controller.${packageName}.${objectNameLower};
  2 
  3 import java.io.PrintWriter;
  4 import java.text.DateFormat;
  5 import java.text.SimpleDateFormat;
  6 import java.util.ArrayList;
  7 import java.util.Date;
  8 import java.util.HashMap;
  9 import java.util.List;
 10 import java.util.Map;
 11 import javax.annotation.Resource;
 12 import org.springframework.beans.propertyeditors.CustomDateEditor;
 13 import org.springframework.stereotype.Controller;
 14 import org.springframework.web.bind.WebDataBinder;
 15 import org.springframework.web.bind.annotation.InitBinder;
 16 import org.springframework.web.bind.annotation.RequestMapping;
 17 import org.springframework.web.bind.annotation.ResponseBody;
 18 import org.springframework.web.servlet.ModelAndView;
 19 import com.fh.controller.base.BaseController;
 20 import com.fh.entity.Page;
 21 import com.fh.util.AppUtil;
 22 import com.fh.util.ObjectExcelView;
 23 import com.fh.util.PageData;
 24 import com.fh.util.Jurisdiction;
 25 import com.fh.util.Tools;
 26 import com.fh.service.${packageName}.${objectNameLower}.${objectName}Manager;
 27 
 28 /** 
 29  * 说明：${TITLE}
 30  * 创建人：FH Q313596790
 31  * 创建时间：${nowDate?string("yyyy-MM-dd")}
 32  */
 33 @Controller
 34 @RequestMapping(value="/${objectNameLower}")
 35 public class ${objectName}Controller extends BaseController {
 36     
 37     String menuUrl = "${objectNameLower}/list.do"; //菜单地址(权限用)
 38     @Resource(name="${objectNameLower}Service")
 39     private ${objectName}Manager ${objectNameLower}Service;
 40     
 41     /**保存
 42      * @param
 43      * @throws Exception
 44      */
 45     @RequestMapping(value="/save")
 46     public ModelAndView save() throws Exception{
 47         logBefore(logger, Jurisdiction.getUsername()+"新增${objectName}");
 48         if(!Jurisdiction.buttonJurisdiction(menuUrl, "add")){return null;} //校验权限
 49         ModelAndView mv = this.getModelAndView();
 50         PageData pd = new PageData();
 51         pd = this.getPageData();
 52         pd.put("${objectNameUpper}_ID", this.get32UUID());    //主键
 53 <#list fieldList as var><#if var[3] == "否"><#if var[1] == "Date">        pd.put("${var[0]}", Tools.date2Str(new Date()));    //${var[2]}
 54 <#elseif var[1] == "Integer">        pd.put("${var[0]}", "${var[4]?replace("无",0)}");    //${var[2]}
 55 <#elseif var[1] == "Double">        pd.put("${var[0]}", "${var[4]?replace("无",0)}");    //${var[2]}
 56 <#else>        pd.put("${var[0]}", "${var[4]?replace("无","")}");    //${var[2]}
 57 </#if></#if></#list>        ${objectNameLower}Service.save(pd);
 58         mv.addObject("msg","success");
 59         mv.setViewName("save_result");
 60         return mv;
 61     }
 62     
 63     /**删除
 64      * @param out
 65      * @throws Exception
 66      */
 67     @RequestMapping(value="/delete")
 68     public void delete(PrintWriter out) throws Exception{
 69         logBefore(logger, Jurisdiction.getUsername()+"删除${objectName}");
 70         if(!Jurisdiction.buttonJurisdiction(menuUrl, "del")){return;} //校验权限
 71         PageData pd = new PageData();
 72         pd = this.getPageData();
 73         ${objectNameLower}Service.delete(pd);
 74         out.write("success");
 75         out.close();
 76     }
 77     
 78     /**修改
 79      * @param
 80      * @throws Exception
 81      */
 82     @RequestMapping(value="/edit")
 83     public ModelAndView edit() throws Exception{
 84         logBefore(logger, Jurisdiction.getUsername()+"修改${objectName}");
 85         if(!Jurisdiction.buttonJurisdiction(menuUrl, "edit")){return null;} //校验权限
 86         ModelAndView mv = this.getModelAndView();
 87         PageData pd = new PageData();
 88         pd = this.getPageData();
 89         ${objectNameLower}Service.edit(pd);
 90         mv.addObject("msg","success");
 91         mv.setViewName("save_result");
 92         return mv;
 93     }
 94     
 95     /**列表
 96      * @param page
 97      * @throws Exception
 98      */
 99     @RequestMapping(value="/list")
100     public ModelAndView list(Page page) throws Exception{
101         logBefore(logger, Jurisdiction.getUsername()+"列表${objectName}");
102         //if(!Jurisdiction.buttonJurisdiction(menuUrl, "cha")){return null;} //校验权限(无权查看时页面会有提示,如果不注释掉这句代码就无法进入列表页面,所以根据情况是否加入本句代码)
103         ModelAndView mv = this.getModelAndView();
104         PageData pd = new PageData();
105         pd = this.getPageData();
106         String keywords = pd.getString("keywords");                //关键词检索条件
107         if(null != keywords && !"".equals(keywords)){
108             pd.put("keywords", keywords.trim());
109         }
110         page.setPd(pd);
111         List<PageData>    varList = ${objectNameLower}Service.list(page);    //列出${objectName}列表
112         mv.setViewName("${packageName}/${objectNameLower}/${objectNameLower}_list");
113         mv.addObject("varList", varList);
114         mv.addObject("pd", pd);
115         mv.addObject("QX",Jurisdiction.getHC());    //按钮权限
116         return mv;
117     }
118     
119     /**去新增页面
120      * @param
121      * @throws Exception
122      */
123     @RequestMapping(value="/goAdd")
124     public ModelAndView goAdd()throws Exception{
125         ModelAndView mv = this.getModelAndView();
126         PageData pd = new PageData();
127         pd = this.getPageData();
128         mv.setViewName("${packageName}/${objectNameLower}/${objectNameLower}_edit");
129         mv.addObject("msg", "save");
130         mv.addObject("pd", pd);
131         return mv;
132     }    
133     
134      /**去修改页面
135      * @param
136      * @throws Exception
137      */
138     @RequestMapping(value="/goEdit")
139     public ModelAndView goEdit()throws Exception{
140         ModelAndView mv = this.getModelAndView();
141         PageData pd = new PageData();
142         pd = this.getPageData();
143         pd = ${objectNameLower}Service.findById(pd);    //根据ID读取
144         mv.setViewName("${packageName}/${objectNameLower}/${objectNameLower}_edit");
145         mv.addObject("msg", "edit");
146         mv.addObject("pd", pd);
147         return mv;
148     }    
149     
150      /**批量删除
151      * @param
152      * @throws Exception
153      */
154     @RequestMapping(value="/deleteAll")
155     @ResponseBody
156     public Object deleteAll() throws Exception{
157         logBefore(logger, Jurisdiction.getUsername()+"批量删除${objectName}");
158         if(!Jurisdiction.buttonJurisdiction(menuUrl, "del")){return null;} //校验权限
159         PageData pd = new PageData();        
160         Map<String,Object> map = new HashMap<String,Object>();
161         pd = this.getPageData();
162         List<PageData> pdList = new ArrayList<PageData>();
163         String DATA_IDS = pd.getString("DATA_IDS");
164         if(null != DATA_IDS && !"".equals(DATA_IDS)){
165             String ArrayDATA_IDS[] = DATA_IDS.split(",");
166             ${objectNameLower}Service.deleteAll(ArrayDATA_IDS);
167             pd.put("msg", "ok");
168         }else{
169             pd.put("msg", "no");
170         }
171         pdList.add(pd);
172         map.put("list", pdList);
173         return AppUtil.returnObject(pd, map);
174     }
175     
176      /**导出到excel
177      * @param
178      * @throws Exception
179      */
180     @RequestMapping(value="/excel")
181     public ModelAndView exportExcel() throws Exception{
182         logBefore(logger, Jurisdiction.getUsername()+"导出${objectName}到excel");
183         if(!Jurisdiction.buttonJurisdiction(menuUrl, "cha")){return null;}
184         ModelAndView mv = new ModelAndView();
185         PageData pd = new PageData();
186         pd = this.getPageData();
187         Map<String,Object> dataMap = new HashMap<String,Object>();
188         List<String> titles = new ArrayList<String>();
189 <#list fieldList as var>        titles.add("${var[2]}");    //${var_index + 1}
190 </#list>        dataMap.put("titles", titles);
191         List<PageData> varOList = ${objectNameLower}Service.listAll(pd);
192         List<PageData> varList = new ArrayList<PageData>();
193         for(int i=0;i<varOList.size();i++){
194             PageData vpd = new PageData();
195 <#list fieldList as var><#if var[1] == "Integer">            vpd.put("var${var_index + 1}", varOList.get(i).get("${var[0]}").toString());    //${var_index + 1}
196 <#elseif var[1] == "Double">            vpd.put("var${var_index + 1}", varOList.get(i).get("${var[0]}").toString());    //${var_index + 1}
197 <#else>            vpd.put("var${var_index + 1}", varOList.get(i).getString("${var[0]}"));        //${var_index + 1}
198 </#if></#list>            varList.add(vpd);
199         }
200         dataMap.put("varList", varList);
201         ObjectExcelView erv = new ObjectExcelView();
202         mv = new ModelAndView(erv,dataMap);
203         return mv;
204     }
205     
206     @InitBinder
207     public void initBinder(WebDataBinder binder){
208         DateFormat format = new SimpleDateFormat("yyyy-MM-dd");
209         binder.registerCustomEditor(Date.class, new CustomDateEditor(format,true));
210     }
211 }
212 
213 null
214 null
215 {}
216 null
```

只不过这时候获取的模板是动态的，这时候通过

 template.process(root, out);

 

这个方法中root 是动态的这时候root就会动态的把tempate获取的动态数据给替换掉



----

# 二、[Java Template.process方法代碼示例](https://vimsky.com/zh-tw/examples/detail/java-method-freemarker.template.Template.process.html)

本文整理匯總了Java中**freemarker.template.Template.process\**方法\****的典型用法代碼示例。如果您正苦於以下問題：Java Template.process方法的具體用法？Java Template.process怎麽用？Java Template.process使用的例子？那麽恭喜您, 這裏精選的方法代碼示例或許可以為您提供幫助。您也可以進一步了解該方法所在**類**[`freemarker.template.Template`](https://vimsky.com/zh-tw/examples/detail/java-class-freemarker.template.Template.html)的用法示例。

在下文中一共展示了**Template.process方法**的16個代碼示例，這些例子默認根據受歡迎程度排序。您可以為喜歡或者感覺有用的代碼點讚，您的評價將有助於我們的係統推薦出更棒的Java代碼示例。

## 示例1: service

 點讚 5 

```java
import freemarker.template.Template; //導入方法依賴的package包/類
@Override
public void service(ServletRequest servletRequest, ServletResponse response) throws ServletException, IOException {
  ClientSettings settings = new ClientSettings(
      options.getOption(SupportService.SUPPORT_EMAIL_ADDR),
      options.getOption(SupportService.SUPPORT_EMAIL_SUBJECT),
      options.getOption(SupportService.OUTSIDE_COMMUNICATION_DISABLED),
      options.getOption(AccelerationOptions.ENABLE_SUBHOUR_POLICIES),
      options.getOption(UIOptions.ALLOW_LOWER_PROVISIONING_SETTINGS),
      options.getOption(UIOptions.TABLEAU_TDS_MIMETYPE));

  String environment = config.allowTestApis ? "DEVELOPMENT" : "PRODUCTION";
  final ServerData indexConfig = new ServerData(environment, serverHealthMonitor, config.getConfig(), settings, getVersionInfo(), supportService.getClusterId().getIdentity());

  Template tmp = templateCfg.getTemplate("/index.html");

  response.setContentType("text/html; charset=utf-8");
  OutputStreamWriter outputWriter = new OutputStreamWriter(response.getOutputStream());
  try {
    tmp.process(ImmutableMap.of("dremio", indexConfig), outputWriter);
    outputWriter.flush();
    outputWriter.close();
  } catch (TemplateException e) {
    throw new IOException("Error rendering index.html template", e);
  }
}
 
```