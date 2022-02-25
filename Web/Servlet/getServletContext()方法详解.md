# [getServletContext()方法详解][https://blog.csdn.net/py941215/article/details/77948617]

一个servlet上下文是servlet引擎提供用来服务于Web应用的接口。Servlet上下文具有名字（它属于Web应用的名字）唯一映射到文件系统的一个目录。
一个servlet可以通过ServletConfig对象的getServletContext()方法得到servlet上下文的引用，如果servlet直接或间接调用子类GenericServlet，则可以使用getServletContext()方法。
Web应用中servlet可以使用servlet上下文得到：
1.在调用期间保存和检索属性的功能，并与其他servlet共享这些属性。
2.读取Web应用中文件内容和其他静态资源的功能。
3.互相发送请求的方式。
4.记录错误和信息化消息的功能。

 
ServletContext接口中的方法    
Object getAttribute(String name)  返回servlet上下文中具有指定名字的对象，或使用已指定名捆绑一个对象。从Web应用的标准观点看，这样的对象是全局对象，因为它们可以被同一servlet在另一时刻访问。或上下文中任意其他servlet访问。    
void setAttribute(String name,Object obj)  设置servlet上下文中具有指定名字的对象。    
Enumeration getAttributeNames()  返回保存在servlet上下文中所有属性名字的枚举。    
ServletContext getContext(String uripath)  返回映射到另一URL的servlet上下文。在同一服务器中URL必须是以“/”开头的绝对路径。    
String getInitParameter(String name)  返回指定上下文范围的初始化参数值。此方法与ServletConfig方法名称不一样，后者只应用于已编码的指定servlet。此方法应用于上下文中所有的参数。    
Enumeration getInitParameterNames()  返回（可能为空）指定上下文范围的初始化参数值名字的枚举值。    
int getMajorVersion()  返回此上下文中支持servlet API级别的最大和最小版本号。    
int getMinorVersion()      
String getMimeType(String fileName)  返回指定文件名的MIME类型。典型情况是基于文件扩展名，而不是文件本身的内容（它可以不必存在）。如果MIME类型未知，可以返回null。    
RequestDispatcher getNameDispatcher(String name)  返回具有指定名字或路径的servlet或JSP的RequestDispatcher。如果不能创建RequestDispatch，返回null。如果指定路径，必须心“/”开头，并且是相对于servlet上下文的顶部。    
RequestDispatcher getNameDispatcher(String path)      
String getRealPath(String path)  给定一个URI，返回文件系统中URI对应的绝对路径。如果不能进行映射，返回null。    
URL getResource(String path)  返回相对于servlet上下文或读取URL的输入流的指定绝对路径相对应的URL，如果资源不存在则返回null。    
InputStream getResourceAsStream(String path)      
String getServerInfo()  返顺servlet引擎的名称和版本号。    
void log(String message)
void log(String message,Throwable t)  将一个消息写入servlet注册，如果给出Throwable参数，则包含栈轨迹。    
void removeAttribute(String name)  从servlet上下文中删除指定属性。 

 

[getServletContext()和getServletConfig()的意思](http://tag.csdn.net/Article/aacf9ff0-39af-4b2c-9f5c-97ea3b1ff8e4.html)

getServletConfig() 在servlet初始化时，容器传递进来一个ServletConfig对象并保存在servlet实例中，该对象允许访问两项内容：初始化参数和ServletContext对象，前者通常由容器在文件中指定，允许在运行时向sevrlet传递有关调度信息，比如说getServletConfig().getInitParameter("debug")后者为servlet提供有关容器的信息。

[getServletContext()和getServletConfig()的意思](http://tag.csdn.net/Article/c44889cb-2950-4155-841c-53a67863b36f.html)

getServletContext()和getServletConfig()的意思2007-07-09 11:10.getServletContext() 一个servlet可以使用getServletContext（）方法得到web应用的servletContext 即而使用getServletContext的一些方法来获得一些值 比如说getServletContext().getRealPath("/")来获得系统绝对路径 getServletContext().getResource("WEB-INF/config.xml")来获得xml文件的内容。

