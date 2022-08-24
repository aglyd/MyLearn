# [Maven War 插件详解](https://www.jianshu.com/p/0895de58c524)

WAR 插件负责收集 Web 应用程序的所有依赖项、类和资源，并将它们打包到 WAR 包中，仅包含 `scope` 为 `compile+runtime` 的依赖项，默认绑定到 `package` 阶段。详情请参考：[https://maven.apache.org/plugins/maven-war-plugin/](https://links.jianshu.com/go?to=https%3A%2F%2Fmaven.apache.org%2Fplugins%2Fmaven-war-plugin%2F)。

使用 War 插件有 4 种方法：

- 在 `package` 阶段使用 war 打包类型；
- 调用 `war:war` 目标；
- 调用 `war:exploded` 目标；
- 调用 `war:inplace` 目标；

当使用 `war:` 目标时，WAR 插件假定 `compile` 阶段已经完成。WAR 插件不负责编译 Java 源代码或复制资源文件。

为了处理归档，这个版本的 Maven WAR 插件使用 [Maven Archiver](https://links.jianshu.com/go?to=http%3A%2F%2Fmaven.apache.org%2Fshared%2Fmaven-archiver%2Findex.html) 3.5.0 来进行归档，使用 [Maven Filtering](https://links.jianshu.com/go?to=http%3A%2F%2Fmaven.apache.org%2Fshared%2Fmaven-filtering%2Findex.html) 3.1.1 来处理资源文件中的属性引用替换。

### 调用 `war:war` 目标

这是使用 WAR 插件的一般方式。需要解析 `scope` 为 `compile+runtime` 的依赖项，默认绑定到 `package` 阶段。

下面是一个示例项目的 pom.xml：

```xml
<project>
  ...
  <groupId>com.example.projects</groupId>
  <artifactId>documentedproject</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>Documented Project</name>
  <url>http://example.com</url>
  ...
</project>
```

项目的结构如下所示：

```shell
 |-- pom.xml
 `-- src
     `-- main
         |-- java
         |   `-- com
         |       `-- example
         |           `-- projects
         |               `-- SampleAction.java
         |-- resources
         |   `-- images
         |       `-- sampleimage.jpg
         `-- webapp
             |-- WEB-INF
             |   `-- web.xml
             |-- index.jsp
             `-- jsp
                 `-- websource.jsp
```

调用：`mvn package` 或 `mvn compile war:war`，将生成 war 文件 `target/documentedproject-1.0-SNAPSHOT.WAR`。以下是该 WAR 文件的内容：

```shell
documentedproject-1.0-SNAPSHOT.war
  |-- META-INF
  |   |-- MANIFEST.MF
  |   `-- maven
  |       `-- com.example.projects
  |           `-- documentedproject
  |               |-- pom.properties
  |               `-- pom.xml
  |-- WEB-INF
  |   |-- classes
  |   |   |-- com
  |   |   |   `-- example
  |   |   |       `-- projects
  |   |   |           `-- SampleAction.class
  |   |   `-- images
  |   |       `-- sampleimage.jpg
  |   `-- web.xml
  |-- index.jsp
  `-- jsp
      `-- websource.jsp
```

###  `war:war` 目标的全部参数介绍

#### 必需的参数

-  `<outputDirectory>`：生成的 WAR 文件的目录。默认为 `${project.build.directory}`。`${project.build.directory}   `即/target，`${project.basedir}`是自带变量,指的是当前项目的[根目录](https://so.csdn.net/so/search?q=根目录&spm=1001.2101.3001.7020)。
-  `<warSourceDirectory>`：用于在 WAR 中包含额外文件的单个目录。这是您放置 JSP 文件的地方。默认为 `${basedir}/src/main/webapp`。
-  `<webappDirectory>`：指定解压形式的 WAR 的默认输出目录，默认为 `${project.build.directory}/${project.build.finalName}` 可以是外部 Web 容器的部署目录以便直接运行，比如 Tomcat 的 `webapps` 目录。
-  `<workDirectory>`：将所依赖的 WAR 包解压缩的输出目录（如果需要的话）。默认为 `${project.build.directory}/war/work`。

#### 可选的参数

- `<archive>`：要使用的存档配置。参见 [Maven Archiver 参考资料](https://links.jianshu.com/go?to=http%3A%2F%2Fmaven.apache.org%2Fshared%2Fmaven-archiver%2Findex.html)。

- `<archiveClasses>`：是否将 `webapp` 中的 `.class` 文件打包成 JAR 文件。使用此可选配置参数将使编译后的类归档到 `/WEB-INF/lib/` 中的 JAR 文件中，然后将 `classes` 目录从 `webapp/WEB-INF/classes/` 中排除。默认值为：`false`。

- `<containerConfigXML>`：servlet 容器的配置文件的路径。请注意，对于不同的 servlet 容器，文件名可能不同。Apache Tomcat 使用名为 context.xml 的配置文件。该文件将被复制到 META-INF 目录。

- `<delimiters>`：在资源中用于属性引用替换的表达式的一组分隔符。这些分隔符以 `beginToken*endToken` 的形式指定。如果未给出 `*`，则假定起始和结束的分隔符相同。因此，可以将默认分隔符指定为：

  ```xml
  <delimiters>
    <delimiter>${*}</delimiter>
    <delimiter>@</delimiter>
  </delimiters>
  ```

  由于两端的 `@` 分隔符相同，因此不需要指定 `@*@`（尽管也可以这样指定）。

- `<dependentWarExcludes>`：进行 WAR 覆盖时要进行排除的逗号分隔的标记列表。默认值为 `Overlay.DEFAULT_EXCLUDES`。

- `<dependentWarIncludes>`：进行 WAR 覆盖时要进行包含的逗号分隔的标记列表。默认值为 `Overlay.DEFAULT_INCLUDES`。

- `<escapeString>`：前面带有此字符串的表达式将不会被插值替换，比如 `\${foo}` 将替换为 `${foo}`。

- `<escapedBackslashesInFilePath>`：是否转义 Windows 路径，默认为 `false`。比如，`c:\foo\bar` 将替换为 `c:\\foo\\bar`。

- `<failOnMissingWebXml>`：如果 web.xml 文件丢失，是否使构建失败。如果希望在不使用 web.xml 文件的情况下生成 WAR 包，请将其设置为 `false`。如果要构建没有 web.xml 文件的 WAR 包，这可能很有用。从 3.1.0 开始，如果项目依赖于 Servlet 3.0 API 或更新版本，则此属性默认为 `false`。

- `<filteringDeploymentDescriptors>`：是否过滤部署描述符（如 web.xml）中的插值。默认情况下 `false`。

- `<filters>`：在 pom.xml 的插值过程中要包含的过滤器（property 文件），可以通过若干个 `<filter>` 子元素指定一个 property 文件列表。

- `<includeEmptyDirectories>`：是否包含空目录。默认为 `false`。

- `<nonFilteredFileExtensions>`：不应筛选的文件扩展名列表。将在筛选 `webResources` 和 `overlays` 时使用。

- `<outdatedCheckPath>`：将根据过期内容检查的资源的路径前缀。从 3.3.2 开始，如果指定了 `/` 值，则将检查整个 `webappDirectory`，即 `/` 表示根目录。默认为 `WEB-INF/lib/`。

- `<outputFileNameMapping>`：复制库和 TLD 时要使用的文件名映射。如果未设置文件映射（默认），则将使用文件的标准名称复制文件。。

- `<outputTimestamp>`：可重复输出存档项的时间戳，格式为 ISO 8601 `yyyy-MM-dd'T'HH:mm:ssXXX` 或表示自纪元起的整秒数（如[SOURCE_DATE_EPOCH](https://links.jianshu.com/go?to=https%3A%2F%2Freproducible-builds.org%2Fdocs%2Fsource-date-epoch%2F)）。默认为 `${project.build.outputTimestamp}`。

- `<overlays>`：要应用的覆盖层。每个 `<overlay>` 子元素可能包含：

  -  `id`：默认为 `currentBuild`。
  -  `groupId`：如果该元素和 `artifactId` 为 null，则当前项目将被视为自己的覆盖。
  -  `artifactId`：见上文。
  - `classifier`
  - `type`
  -  `includes`：字符串模式列表。
  -  `excludes`：字符串模式列表。
  -  `filtered`：默认为 `false`。
  -  `skip`：默认为 `false`。
  -  `targetPath`：默认为 `webapp` 结构的根目录。

- `<recompressZippedFiles>`：指示是否应再次压缩添加到 WAR 中的 zip 存档（jar、zip 等）。再次压缩可能会导致较小的存档大小，但会显著延长执行时间。默认为 `true`。

- `<resourceEncoding>`：复制那些筛选的 Web 资源时要使用的编码。默认为 `${project.build.sourceEncoding}`。

- `<supportMultiLineFiltering>`：停止搜索行末尾的 `endToken`。默认为 `false`。

- `<useDefaultDelimiters>`：除了自定义分隔符（如果有）之外，还使用默认分隔符。默认为 `true`。

- `<useJvmChmod>`：使用 `jvmChmod` 而不是 `cli chmod` 和 forking 过程。默认为 `true`。

- `<warSourceExcludes>`：复制 `warSourceDirectory` 内容时要排除的标记的逗号分隔列表。

- `<warSourceIncludes>`：复制 `warSourceDirectory` 内容时要包含的标记的逗号分隔列表。

- `<webResources>`：要传输的 Web 资源列表，通过若干个 `<resource>` 子元素来指定这样一个资源列表，每个资源使用相对于 pom.xml 文件的路径。

- `<webXml>`：要使用的 web.xml 文件的路径。

### 调用 `war:exploded` 目标

为了在开发阶段加快测试速度，`war:exploded` 可以用来生成解压形式的 WAR。需要解析 `scope` 为 `runtime` 的依赖项，默认绑定到 `package` 阶段。

使用上述项目并调用：`mvn compile war:exploded`。这将在`target/documentedproject-1.0-SNAPSHOT` 中生成 WAR 的解压版本。该目录的内容如下所示：

```shell
 documentedproject-1.0-SNAPSHOT
 |-- META-INF
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           `-- SampleAction.class
 |   |   `-- images
 |   |       `-- sampleimage.jpg
 |   `-- web.xml
 |-- index.jsp
 `-- jsp
     `-- websource.jsp
```

解压形式的 WAR 的默认输出目录是 `${project.build.directory}/${project.build.finalName}`，即 `target/<finalName>`，最终名称通常采用 `<artifactId>-<version>` 的形式。可以通过指定 `webappDirectory` 参数来覆盖此默认目录。

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <webappDirectory>/sample/servlet/container/deploy/directory</webappDirectory>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

###  `war:exploded` 目标的全部参数

#### 必需的参数

`war:exploded` 目标的必需参数比  `war:war` 目标的必选参数少了一个 `<outputDirectory>`。

-  `<warSourceDirectory>`：用于在 WAR 中包含额外文件的单个目录。这是您放置 JSP 文件的地方。默认为 `${basedir}/src/main/webapp`。
-  `<webappDirectory>`：指定解压形式的 WAR 的默认输出目录，默认为 `${project.build.directory}/${project.build.finalName}` 可以是外部 Web 容器的部署目录以便直接运行，比如 Tomcat 的 `webapps` 目录。
-  `<workDirectory>`：将所依赖的 WAR 包解压缩的输出目录（如果需要的话）。默认为 `${project.build.directory}/war/work`。

#### 可选的参数

`war:exploded` 目标的可选参数与 `war:exploded` 目标的可选参数相同。

### 调用 `war:inplace` 目标

`war:exploded` 的另一个变体是 `war:inplace`。使用`war:inplace` 创建的解压形式的 WAR 的输出目录默认为 `src/main/webapp`。使用上述项目并调用：`mvn compile war:inplace`，结果如下：

```shell
|-- pom.xml
 |-- src
 |   `-- main
 |       |-- java
 |       |   `-- com
 |       |       `-- example
 |       |           `-- projects
 |       |               `-- SampleAction.java
 |       |-- resources
 |       |   `-- images
 |       |       `-- sampleimage.jpg
 |       `-- webapp
 |           |-- META-INF
 |           |-- WEB-INF
 |           |   |-- classes
 |           |   |   |-- com
 |           |   |   |   `-- example
 |           |   |   |       `-- projects
 |           |   |   |           `-- SampleAction.class
 |           |   |   `-- images
 |           |   |       `-- sampleimage.jpg
 |           |   `-- web.xml
 |           |-- index.jsp
 |           `-- jsp
 |               `-- websource.jsp
 `-- target
     `-- classes
         |-- com
         |   `-- example
         |       `-- projects
         |           `-- SampleAction.class
         `-- images
             `-- sampleimage.jpg
```

###  `war:inplace` 目标的全部参数

需要解析 `scope` 为 `runtime` 的依赖项，默认绑定到 `package` 阶段。

#### 必需的参数

`war:inplace` 目标的必需参数比 `war:war` 目标的必选参数少了一个 `<outputDirectory>`。

-  `<warSourceDirectory>`：用于在 WAR 中包含额外文件的单个目录。这是您放置 JSP 文件的地方。默认为 `${basedir}/src/main/webapp`。
-  `<webappDirectory>`：指定解压形式的 WAR 的默认输出目录，默认为 `${project.build.directory}/${project.build.finalName}` 可以是外部 Web 容器的部署目录以便直接运行，比如 Tomcat 的 `webapps` 目录。
-  `<workDirectory>`：将所依赖的 WAR 包解压缩的输出目录（如果需要的话）。默认为 `${project.build.directory}/war/work`。

#### 可选的参数

`war:inplace` 目标的可选参数与 `war:war` 目标的可选参数相同。

### Overlay

#### 简介

Overlay（覆盖）用于跨多个 Web 应用程序共享公共资源。WAR 项目的依赖项收集在 `WEB-INF/lib` 中，WAR 项目本身上覆盖的 WAR 工件除外。

以下面的项目结构来作为说明：

```shell
 |-- pom.xml
 `-- src
     `-- main
         |-- java
         |   `-- com
         |       `-- example
         |           `-- projects
         |               `-- SampleAction.java
         |-- resources
         |   |-- images
         |   |   `-- sampleimage.jpg
         |   `-- sampleresource
         `-- webapp
             |-- WEB-INF
             |   `-- web.xml
             |-- index.jsp
             `-- jsp
                 `-- websource.jsp
```

该项目依赖于另一个 WAR 工件 `documentedprojectdependency-1.0-SNAPSHOT.war` ，该工件在项目的 pom.xml 中声明为依赖项：

```xml
<project>
  ...
  <dependencies>
    <dependency>
      <groupId>com.example.projects</groupId>
      <artifactId>documentedprojectdependency</artifactId>
      <version>1.0-SNAPSHOT</version>
      <type>war</type>
      <scope>runtime</scope>
    </dependency>
    ...
  </dependencies>
  ...
</project>
```

`documentedprojectdependency` 的 WAR 文件结构如下：

```shell
documentedprojectdependency-1.0-SNAPSHOT.war
 |-- META-INF
 |   |-- MANIFEST.MF
 |   `-- maven
 |       `-- com.example.projects
 |           `-- documentedprojectdependency
 |               |-- pom.properties
 |               `-- pom.xml
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           `-- SampleActionDependency.class
 |   |   `-- images
 |   |       `-- sampleimage-dependency.jpg
 |   `-- web.xml
 `-- index-dependency.jsp
```

最终合并的 WAR 文件如下：

```shell
 |-- META-INF
 |   |-- MANIFEST.MF
 |   `-- maven
 |       `-- com.example.projects
 |           `-- documentedproject
 |               |-- pom.properties
 |               `-- pom.xml
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           |-- SampleAction.class
 |   |   |           `-- SampleActionDependency.class
 |   |   `-- images
 |   |       |-- sampleimage-dependency.jpg
 |   |       `-- sampleimage.jpg
 |   `-- web.xml
 |-- index-dependency.jsp
 |-- index.jsp
 `-- jsp
     `-- websource.jsp
```

上面的 `web.xml` 文件来自 `documentedproject` 项目。

#### Overlay 类型

WAR 插件将 war 和 zip 工件作为覆盖处理。但是，出于向后兼容性的原因，只有在插件的配置中明确定义 zip 覆盖时，才会处理它们。

#### Overlay 配置

在以前版本的 WAR 插件中，不需要配置。如果您对默认设置感到满意，这种情况仍然存在。`<overlay>` 元素可以有以下子元素：

-  `id`：Overlay 的 id。如果没有提供，WAR 插件将生成一个。
-  `groupId`：要配置的 Overlay 工件的 `groupId`。
-  `artifactId`：要配置的 Overlay 工件的 `artifactId`。
-  `classifier`：如果多个工件与 `groupId/artifactId` 匹配，则要配置的 Overlay 工件的 `classifier`。
-  `type`：要配置的 Overlay 工件的类型。默认值为 war。
-  `includes`：要包括的文件。默认情况下，包含所有文件。
-  `excludes`：要排除的文件。默认情况下，`META-INF/MANIFEST.MF` 文件被排除在外。
-  `filtered`：是否对此 Overlay 应用过滤。默认为 `false`。
-  `skip`：设置为 true 可跳过此 Overlay。默认为 `false`。
-  `targetPath`：`webapp` 结构中的目标相对路径，仅适用于 war 类型的 Overlay。默认情况下，Overlay 的内容添加到 `webapp` 的根结构中。

例如，排除上面 `documentedprojectdependency` `war` 覆盖的 `sampleimage-dependency.jpg`。

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <overlays>
            <overlay>
              <groupId>com.example.projects</groupId>
              <artifactId>documentedprojectdependency</artifactId>
              <excludes>
                <exclude>WEB-INF/classes/images/sampleimage-dependency.jpg</exclude>
              </excludes>
            </overlay>
          </overlays>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

#### Overlay 打包

Overlay 采用先赢策略（因此，如果一个文件已经被一个 Overlay 复制了，则另一个 Overlay 就不会复制该文件）。Overlay 按其在 `<overlays>` 配置中定义的顺序应用。如果未提供任何配置，则使用 POM 中定义依赖项的顺序（警告：这是不确定的，尤其是当 Overlay 是可传递依赖项时）。在混合情况下（例如，已配置的 Overlay 和没有配置的 Overlay），在已配置的 Overlay 之后应用没有配置的 Overlay。

默认情况下，首先添加项目源（当前构建的项目）（例如，在应用任何 Overlay 之前）。当前构建被定义为一个特殊的 Overlay，没有 `groupId`、`artifactId`。如果需要首先应用 Overlay，只需在这些 Overlay 之后配置当前构建。

例如，如果 `com.example.projects:my-webapp` 是项目的依赖项，需要在该项目的源之前应用，请执行以下操作：

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <overlays>
            <overlay>
              <groupId>com.example.projects</groupId>
              <artifactId>my-webapp</artifactId>
            </overlay>
            <overlay>
              <!-- empty groupId/artifactId represents the current build -->
            </overlay>
          </overlays>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

在上面的场景中，任何其他 WAR 依赖项都将在当前构建之后应用，因为它们尚未在 `<overlays>` 元素中配置。为了执行更细粒度的 Overlay 策略，可以使用不同的包含/排除多次打包 Overlay。例如，如果必须在 `webapp` 中设置 Overlay `my-webapp` 中的 `index.jsp` 文件，但其他文件可以通过常规方式控制，为 `my-webapp` 定义两种 Overlay 配置：

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <overlays>
            <overlay>
              <id>my-webapp-index.jsp</id>
              <groupId>com.example.projects</groupId>
              <artifactId>my-webapp</artifactId>
              <includes>
                <include>index.jsp</include>
              </includes>
            </overlay>
            <overlay>
              <!-- empty groupId/artifactId represents the current build -->
            </overlay>
 
            <!-- Other overlays here if necessary -->
 
            <overlay>
              <id>my-webapp</id>
              <groupId>com.example.projects</groupId>
              <artifactId>my-webapp</artifactId>
            </overlay>
          </overlays>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

#### Overlay 全局设置

可以全局指定以下设置，并修改应用所有 Overlay 的方式。

- `dependentWarIncludes` 设置应用于所有 Overlay 的默认 includes 。默认情况下，没有特定 `includes` 元素的任何 Overlay 都将继承此设置。

  ```xml
  <project>
      ...
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-war-plugin</artifactId>
          <version>3.3.2</version>
          <configuration>
            <dependentWarIncludes>**/IncludeME,**/images</dependentWarIncludes>
          </configuration>
         </plugin>
      </plugins>
      ...
  </project>
  ```

- `dependentWarExcludes` 设置要应用于所有 Overlay 的默认 excludes。默认情况下，没有特定 `excludes` 元素的任何 Overlay 都将继承此设置。

  ```xml
  <project>
      ...
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-war-plugin</artifactId>
          <version>3.3.2</version>
          <configuration>
            <dependentWarExcludes>WEB-INF/web.xml,index.*</dependentWarExcludes>
          </configuration>
         </plugin>
      </plugins>
      ...
  </project>
  ```

- `workDirectory` 设置将临时提取 Overlay 的目录。

  ```xml
  <project>
      ...
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-war-plugin</artifactId>
          <version>3.3.2</version>
          <configuration>
            <!-- default value is target/war/work -->
            <workDirectory>/tmp/extract_here</workDirectory>
          </configuration>
         </plugin>
      </plugins>
      ...
  </project>
  ```

#### 使用 Overlay 的 zip 依赖

要将 zip 依赖项用作 Overlay ，必须在插件的配置中显式配置它。例如，要在 `webapp` 的 `scripts` 目录中插入 zip Overlay 的内容，请执行以下操作：

```xml
<project>
    ...
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <overlays>
            <overlay>
              <groupId>zipGroupId</groupId>
              <artifactId>zipArtifactId</artifactId>
              <type>zip</type>
              <targetPath>scripts</targetPath>
            </overlay>
          </overlays>
        </configuration>
      </plugin>
    </plugins>
    ...
</project>
```

### 示例

#### 引入外部资源

假设我们的项目结构如下：

```shell
 .
 |-- pom.xml
 |-- resource2
 |   |-- external-resource.jpg
 |   `-- image2
 |       `-- external-resource2.jpg
 `-- src
     `-- main
         |-- java
         |   `-- com
         |       `-- example
         |           `-- projects
         |               `-- SampleAction.java
         |-- resources
         |   `-- images
         |       `-- sampleimage.jpg
         `-- webapp
             |-- WEB-INF
             |   `-- web.xml
             |-- index.jsp
             `-- jsp
                 `-- websource.jsp
```

上面的项目结构中包含了外部资源目录：resource2。如果也想将这些外部资源打包到 WAR 包中，则可以借用 `<webResources>` 元素。

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <webResources>
            <resource>
              <!-- 下面是一个相对于pom.xml文件的目录 -->
              <directory>resource2</directory>
            </resource>
          </webResources>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

使用上面的 `<webResources>` 配置生成的结果如下：

```shell
documentedproject-1.0-SNAPSHOT.war
 |-- META-INF
 |   |-- MANIFEST.MF
 |   `-- maven
 |       `-- com.example.projects
 |           `-- documentedproject
 |               |-- pom.properties
 |               `-- pom.xml
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           `-- SampleAction.class
 |   |   `-- images
 |   |       `-- sampleimage.jpg
 |   `-- web.xml
 |-- external-resource.jpg
 |-- image2
 |   `-- external-resource2.jpg
 |-- index.jsp
 `-- jsp
     `-- websource.jsp
```

`external-resource2.jpg` 和 `image2` 将复制到 WAR 的根目录，保留目录结构。

#### 过滤资源文件

假设我们的项目结构如下（添加了一个 configurations 目录）：

```shell
 .
 |-- configurations
 |   |-- config.cfg
 |   `-- properties
 |       `-- config.prop
 |-- pom.xml
 |-- resource2
 |   |-- external-resource.jpg
 |   `-- image2
 |       `-- external-resource2.jpg
 `-- src
     `-- main
         |-- java
         |   `-- com
         |       `-- example
         |           `-- projects
         |               `-- SampleAction.java
         |-- resources
         |   `-- images
         |       `-- sampleimage.jpg
         `-- webapp
             |-- WEB-INF
             |   `-- web.xml
             |-- index.jsp
             `-- jsp
                 `-- websource.jsp
```

为了防止在启用筛选时损坏二进制文件，可以配置一个不被筛选的文件扩展名列表。

```xml
        ...
        <configuration>
          <!-- the default value is the filter list under build -->
          <!-- specifying a filter will override the filter list under build -->
          <filters>
            <filter>properties/config.prop</filter>
          </filters>
          <!-- 指定不需要过滤的资源文件的扩展名 -->  
          <nonFilteredFileExtensions>
            <!-- 默认值包含jpg,jpeg,gif,bmp,png -->
            <nonFilteredFileExtension>pdf</nonFilteredFileExtension>
          </nonFilteredFileExtensions>
          <webResources>
            <resource>
              <directory>resource2</directory>
              <!-- 一般不会过滤二进制文件，否则可能会损坏二进制文件。所以，这里禁用过滤功能 -->
              <filtering>false</filtering>
            </resource>
            <resource>
              <directory>configurations</directory>
              <!-- 对文本类型的资源文件开启过滤功能 -->
              <filtering>true</filtering>
              <excludes>
                <exclude>**/properties</exclude>
              </excludes>
            </resource>
          </webResources>
        </configuration>
        ...
```

假如 `config.prop` 的内容如下：

```undefined
interpolated_property=some_config_value
```

假如 `config.cfg` 的内容如下：

```xml
<another_ioc_container>
    <configuration>${interpolated_property}</configuration>
</another_ioc_container>
```

生成的 WAR 包中的结构如下：

```shell
documentedproject-1.0-SNAPSHOT.war
 |-- META-INF
 |   |-- MANIFEST.MF
 |   `-- maven
 |       `-- com.example.projects
 |           `-- documentedproject
 |               |-- pom.properties
 |               `-- pom.xml
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           `-- SampleAction.class
 |   |   `-- images
 |   |       `-- sampleimage.jpg
 |   `-- web.xml
 |-- config.cfg
 |-- external-resource.jpg
 |-- image2
 |   `-- external-resource2.jpg
 |-- index.jsp
 `-- jsp
     `-- websource.jsp
```

其中，WAR 包中 `config.cfg` 文件的内容如下：

```xml
<another_ioc_container>
   <configuration>some_config_value</configuration>
</another_ioc_container>
```

在 2.2 和更早版本的插件中，在过滤资源时使用的当前平台的编码。根据编码方式的不同，过滤后的字符可能会乱码。从 2.3 版本开始，该插件在过滤资源时使用`project.build.sourceEncoding` property 的值。一个值得注意的例外是 `.xml` 文件是使用的 xml 文件中指定的编码进行过滤的。

#### 覆盖默认输出目录

默认情况下，Web 资源被复制到 WAR 的根目录，如前一个示例所示。要覆盖默认输出目录，请指定 `targetPath`。

```xml
        ...
        <configuration>
          <webResources>
            <resource>
              ...
            </resource>
            <resource>
              <directory>configurations</directory>
              <!-- override the destination directory for this resource -->
              <targetPath>WEB-INF</targetPath>
              <!-- enable filtering -->
              <filtering>true</filtering>
              <excludes>
                <exclude>**/properties</exclude>
              </excludes>
            </resource>
          </webResources>
        </configuration>
        ...
```

如果使用上面的示例项目和插件配置，则产生的 WAR 如下所示：

```shell
documentedproject-1.0-SNAPSHOT.war
 |-- META-INF
 |   |-- MANIFEST.MF
 |   `-- maven
 |       `-- com.example.projects
 |           `-- documentedproject
 |               |-- pom.properties
 |               `-- pom.xml
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           `-- SampleAction.class
 |   |   `-- images
 |   |       `-- sampleimage.jpg
 |   |-- config.cfg
 |   `-- web.xml
 |-- external-resource.jpg
 |-- image2
 |   `-- external-resource2.jpg
 |-- index.jsp
 `-- jsp
     `-- websource.jsp
```

#### 自定义 WAR 的清单文件

可以通过配置 WAR 插件的 archiver 来定制 WAR 包中的清单文件。有关可用的完整信息，请查看 [Maven Archiver 的文档](https://links.jianshu.com/go?to=http%3A%2F%2Fmaven.apache.org%2Fshared%2Fmaven-archiver%2Findex.html)。

为 WAR 生成 `Class-Path` 清单项类似于为 JAR 生成 `Class-Path` 清单项，但有几个细微的区别，因为通常情况下不希望同一个 JAR 同时出现在 `Class-Path` 清单项和 `WEB-INF/lib` 目录中。下面是一个自定义 WAR 插件的归档配置：

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <archive>
            <manifest>
              <addClasspath>true</addClasspath>
            </manifest>
          </archive>
        </configuration>
      </plugin>
      ...
    </plugins>
  </build>
  ...
</project>
```

现在，您可以通过以下示例控制 `WEB-INF/lib` 和 `Class-Path` 清单项中包含哪些依赖项。Maven 将遵循可传递依赖关系树，直到它到达范围为 `provided` 的工件。注意：没有办法声明一个依赖项仅包含在 `WEB-INF/lib` 中而不包含在 `Class-Path` 清单项中。

```xml
<project>
  ...
  <dependencies>
    <dependency>
      <groupId>org.foo</groupId>
      <artifactId>bar-jar1</artifactId>
      <version>${pom.version}</version>
      <optional>true</optional>
      <!-- goes in manifest classpath, but not included in WEB-INF/lib -->
    </dependency>
    <dependency>
      <groupId>org.foo</groupId>
      <artifactId>bar-jar2</artifactId>
      <version>${pom.version}</version>
      <!-- goes in manifest classpath, AND included in WEB-INF/lib -->
    </dependency>
    <dependency>
      <groupId>org.foo</groupId>
      <artifactId>bar-jar3</artifactId>
      <version>${pom.version}</version>
      <scope>provided</scope>
      <!-- excluded from manifest classpath, and excluded from WEB-INF/lib -->
    </dependency>
    ...
  </dependencies>
  ...
</project>
```

#### 包括和排除 WAR 中的文件

通过使用 `<packageIncludes>` 和 `<packageExcludes>` 元素可以从 WAR 文件中包括或排除某些文件，这两个元素都采用逗号分隔的 Ant 文件集模式列表。您可以使用 `**` 等通配符来表示连续的多个目录，使用 `*` 来表示单个文件名或单个目录名中的部分字符。下面是一个从 `WEB-INF/lib` 中排除所有 JAR 文件的示例：

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <packagingExcludes>WEB-INF/lib/*.jar</packagingExcludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

有时，即使是这样的通配符也是不够的。在这些情况下，可以使用具有 `%regex[]` 语法的正则表达式。这里是一个实际的用例，我们希望排除任何 `commons-logging` 和 `log4j` 的 JAR 文件，但不希望排除 `log4j-over-slf4j` 的 JAR 文件。因此，我们希望排除 `log4j-<version>.jar`，但保留 `log4j-over-slf4j-<version>.jar`。

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.3.2</version>
        <configuration>
          <!--
            Exclude JCL and LOG4J since all logging should go through SLF4J.
            Note that we're excluding log4j-<version>.jar but keeping
            log4j-over-slf4j-<version>.jar
          -->
          <packagingExcludes>
            WEB-INF/lib/commons-logging-*.jar,
            %regex[WEB-INF/lib/log4j-(?!over-slf4j).*.jar]
          </packagingExcludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

#### 使用文件名映射

可能需要自定义库和 TLD 的文件名。默认情况下，使用以下模式存储这些资源：

```shell
@{artifactId}@-@{version}@.@{extension}@
```

如果工件具有 `classifier`，那么默认模式为：

```shell
@{artifactId}@-@{version}@-@{classifier}@.@{extension}@
```

`outputFileNameMapping` 参数允许您提供自定义模式，模式中定义的每个标记将被当前工件中的一个值替换。您可以使用 `Artifact` 和 `ArtifactHandler` 的任何属性作为要代替的标记。还有一个名为 `dashClassifier?`。从 2.1 开始就可以使用。当且仅当工件具有 `classifier` 时，它才会添加字符串 `-yourclassifier`。

例如，要存储没有版本号或 `classifier` 的库和 TLD，请使用以下模式：

```shell
@{artifactId}@.@{extension}@
```

要存储没有版本号但带有 `classifier`（如果存在）的库和 TLD，请使用以下模式：

```shell
@{artifactId}@@{dashClassifier?}@.@{extension}@
```

#### 创建瘦身的 WAR 包

在典型的 J2EE 环境中，WAR 打包在 EAR 中进行部署。WAR 可以在 `WEB-INF/lib` 中包含其所有依赖的 JAR，但是如果存在多个 WAR，由于存在重复的 JAR，EAR 可能会迅速变大。相反，J2EE 规范允许 WAR 通过 `MANIFEST.MF` 中的 `Class-Path` 设置引用 EAR 中打包的外部 JAR。

Maven EAR 插件直接支持创建瘦身的 WAR 包，这意味着也需要[配置 Maven EAR 插件](https://links.jianshu.com/go?to=http%3A%2F%2Fmaven.apache.org%2Fplugins%2Fmaven-ear-plugin%2Fexamples%2Fskinny-wars.html)。

您需要更改 EAR 项目的 pom.xml 以在 EAR 中打包这些所需要依赖的 JAR。注意，我们将所有内容打包到 EAR 中的 `lib/` 目录中。这只是个人用来区分 J2EE 模块（将打包在 EAR 的根目录中）和 Java 库（打包在 `lib/` 中）的一种方式。

```xml
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <artifactId>maven-ear-plugin</artifactId>
        <version>2.9.1</version>
        <configuration>
          <defaultLibBundleDir>lib/</defaultLibBundleDir>
          <skinnyWars>true</skinnyWars>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>
```

现在是痛苦的部分。您的 EAR 项目的 pom.xml 需要列出 WAR 的每个依赖项。这是因为 Maven 假设打包的是完整的 WAR 包，并且不包括 EAR 中其他 WAR 的可传递依赖项。

```xml
<project>
  ....
  <dependencies>
    <dependency>
      <groupId>com.acme</groupId>
      <artifactId>shared-jar</artifactId>
      <version>1.0.0</version>
    </dependency>
    <dependency>
      <groupId>com.acme</groupId>
      <artifactId>war1</artifactId>
      <version>1.0.0</version>
      <type>war</type>
    </dependency>
    <dependency>
      <groupId>com.acme</groupId>
      <artifactId>war2</artifactId>
      <version>1.0.0</version>
      <type>war</type>
    </dependency>
  </dependencies>
  ...
</project>
```

您的 EAR 将包含以下内容：

```xml
 .
 |-- META-INF
 |   `-- application.xml
 |-- lib
 |   `-- shared-jar-1.0.0.jar
 |-- war1-1.0.0.war
 `-- war2-1.0.0.war
```

下面是一个更完整的示例。

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-war-plugin</artifactId>
    <version>3.3.2</version>
    <configuration>
        <!-- 生成的WAR文件的目录。默认为${project.build.directory} -->
        <outputDirectory>${project.build.directory}</outputDirectory>
        <!-- 用于在WAR中包含额外文件的单个目录。这是您放置JSP文件的地方。。默认为${basedir}/src/main/webapp -->
        <warSourceDirectory>${basedir}/src/main/webapp</warSourceDirectory>
        <!-- 指定解压形式的 WAR 的默认输出目录。默认为${project.build.directory}/${project.build.finalName}
            可以是外部servlet容器的部署目录以便直接运行，比如Tomcat的webapps目录 -->
        <webappDirectory>/your/apache-tomcat-x.x.xx/webapps/</webappDirectory>
        <!-- 将所依赖的 WAR 包解压缩的输出目录（如果需要的话）。默认为${project.build.directory}/war/work -->
        <workDirectory>${project.build.directory}/war/work</workDirectory>
        
        <!-- Maven项目的默认资源目录为src/main/resources，将会输出到target/classes和WAR包中的WEB-INF/classes，并保留源资源目录结构。
             <webResources>元素可以用来包含不在默认资源目录中的资源文件 -->
        <webResources>
            <!-- 这里的<resource>元素与一般<resource>元素的用法相同 -->
            <resource>
                <!-- 下面是一个相对于pom.xml文件的目录 -->
                <directory>resource2</directory>
                <!-- <includes>默认值为**，即包含所有文件。下面仅包含.jpg文件 -->
                <includes>
                    <include>**/*.jpg</include>
                </includes>
                <!-- <excludes>没有默认值。下面排除路径中包含image2的资源 -->
                <excludes>
                    <exclude>**/image2</exclude>
                </excludes>
            </resource>
            <!-- 另一个<resource>示例 -->
            <resource>
                <directory>resource2</directory>
                <includes>
                    <include>**/pattern1</include>
                    <include>*pattern2</include>
                </includes>
                <excludes>
                    <exclude>*pattern3/pattern3</exclude>
                    <exclude>pattern4/pattern4</exclude>
                </excludes>
            </resource>
        </webResources>
        <archive>
            <!-- 默认打成WAR时不包含pom.xml -->
            <addMavenDescriptor>false</addMavenDescriptor>
        </archive>
        <!-- 指定打成WAR时不包含的文件 -->
        <packagingExcludes>WEB-INF/jetty-*.xml</packagingExcludes>
    </configuration>
</plugin>
```



ps：

> maven常用打包命令
> 1、mvn compile 编译,将Java源程序编译成class字节码文件。
> 2、mvn test 测试,并生成测试报告
> 3、mvn clean将以前编译得到的旧的class字节码文件删除
> 4、mvn pakage 打包,动态 web工程打war包, Java工程打jar包。
> 5、mvn install将项目生成jar包放在仓库中,以便别的模块调用
> 6、mvn clean install -Dmaven. test. skip=true 抛弃测试用例打包

打war包命令：mvn clean package  (-P +profile.id)



#  [maven打war包（外部）第三方依赖](https://blog.csdn.net/ZT1090258642/article/details/125906657)

需求：项目中引用了第三方jar包，位置在lib下，打包时需要一块打入进war中

解决：有两种方式，一种是将第三方依赖包复制到war包的lib中，另一种方式是将第三方jar包放入本地的[maven](https://so.csdn.net/so/search?q=maven&spm=1001.2101.3001.7020)仓库中

**方式一：将第三方依赖包复制到war包的lib中**

1.在（/src/main/resources）中新建一个lib包来存放第三方依赖

2.pom中的依赖

```xml
<!--xxx依赖-->
<dependency>
    <groupId>com.xxx.api</groupId>
    <artifactId>xxx</artifactId>
    <version>5.2.1</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/src/main/resources/lib/xxx-5.2.1.jar</systemPath>
</dependency> 
```

`${project.basedir}`是自带变量,指的是当前项目的[根目录](https://so.csdn.net/so/search?q=根目录&spm=1001.2101.3001.7020)。

3.打war包需要配置pom中的plugin，否则第三方依赖打不进去

```xml
<!--设置maven-war-plugins插件，否则外部依赖无法打进war包 -->
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-war-plugin</artifactId>
				<configuration>
					<webResources>
						<resource>
							<!-- directory的路径是需要打包的第三方jar包位置-->
							<directory>/src/main/resources/lib</directory>
							<targetPath>WEB-INF/lib/</targetPath>
							<includes>
								<include>**/*.jar</include>
							</includes>
						</resource>
					</webResources>
				</configuration>
			</plugin>
```

4.上面的三个步骤是打包的时候：配置maven将lib中的第三方jar包复制到war中，所以可以手动直接将lib中的第三方依赖直接拖到war包中的WEB-INF/lib/下，一样可以正常运行项目。

**方式二：将第三方jar包放入本地的maven仓库中（参考文章：**[将外部jar包导入本地maven仓库](https://www.cnblogs.com/java-spring/p/13055925.html)**）**

1.选择一个位置存放第三方jar包，我这里是 F:\maven\dcm4che

2.运行mvn命令,注意加粗的部分都需要修改成自己的

mvn install:install-file -DgroupId=**org.dcm4che** -DartifactId=**dcm4che-core** -Dversion=**5.22.5** -Dpackaging=jar -Dfile=**F:\maven\dcm4che\dcm4che-core-5.22.5.jar**

```XML
mvn install:install-file 
-DgroupId=org.dcm4che 
-DartifactId=dcm4che-core -Dversion=5.22.5 
-Dpackaging=jar 
-Dfile=F:\maven\dcm4che\dcm4che-core-5.22.5.jar
```

3.然后在maven仓库中按着上面的依赖路径查找jar包

4.项目中的依赖可以修改为正常的

```xml
<dependency>
    <groupId>org.dcm4che</groupId>
    <artifactId>dcm4che-core</artifactId>
    <version>5.22.5</version>
</dependency>
```

