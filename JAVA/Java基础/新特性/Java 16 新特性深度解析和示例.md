# Java 16 新特性深度解析和示例

## 本文要点

- Java 16 和即将发布的 Java 17 引入了大量特性和语言增强，有助于提高开发人员的生产力和应用程序性能
- Java 16 Stream API 为常用的终端操作提供了很多新方法，有助于减少样板代码的混乱现象
- Record 是 Java 16 中的一项语言新特性，可简洁地定义纯数据类。编译器提供了构造器、访问器和一些常见 Object 方法的实现
- 模式匹配是 Java 16 中的另一个新特性，它简化了使用 instanceof 代码块完成的显式和冗长的转换，此外还有很多好处

 

Java 16 于 2021 年 3 月发布，版本类型是可用于生产的 GA 构建，我在这段[深度视频演示](http://www.infoq.com/presentations/new-java-16/)中介绍了该版本的新特性。下一个 LTS 版本 Java 17 计划于今年 9 月发布。Java 17 将包含许多改进和语言增强，其中大部分是自 Java 11 以来交付的所有新特性和更改的成果结晶。

 

就 Java 16 中的新特性而言，我将分享 Stream API 中一项讨喜的更新，然后主要关注语言更改部分。

## 从 Stream 到 List

```java
List<String> features =
  Stream.of("Records", "Pattern Matching", "Sealed Classes")
        .map(String::toLowerCase)
        .filter(s -> s.contains(" "))
        .collect(Collectors.toList());
```

复制代码

如果你习惯使用 Java Stream API，那么应该会很熟悉上面这个代码段。

 

这段代码里有一个包含一些字符串的流。我们在它上面映射一个函数，然后过滤这个流。

 

最后，我们将流物化为一个列表。

 

如你所见，我们通常会调用终端操作 collect 并给它传递一个收集器。

 

这里是很常见的实践——使用 collect 并将 Collectors.toList()传递给它，感觉就像是样板代码一样。

 

好消息是，在 Java 16 中 Stream API 中添加了一个新方法，使我们能够立即将 toList()作为一个流的一个终端操作来调用。

```java
List<String> features =
  Stream.of("Records", "Pattern Matching", "Sealed Classes")
        .map(String::toLowerCase)
        .filter(s -> s.contains(" "))
        .toList();
```

复制代码

在上面的代码中使用这个新方法会生成一个来自这个流，且包含一个空格的字符串的列表。请注意，我们返回的这个列表是一个不可修改的列表。这意味着你不能再从这个终端操作返回的列表中添加或删除任何元素。如果要将流收集到一个可变列表中，则必须继续使用一个带有 collect()函数的收集器。所以这个 Java 16 中新引入的 toList()方法真的很讨喜。这个更新应该能让流管道代码块读起来更容易一些。

 

Stream API 的另一个更新是 mapMulti()方法。它的用途有点像 flatMap()方法。如果你平常用的是 flatMap()，并且映射到 lambda 中的内部流并传递给它，那么 mapMulti()为你提供了一种替代方法，你可以将元素推送给一个消费者。我不会在本文中具体介绍这个方法，因为我想讨论的是 Java 16 中的语言新特性。如果你有兴趣进一步了解 mapMulti()，我强烈建议你查看[Java文档](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/stream/Stream.html#mapMulti(java.util.function.BiConsumer))中关于这种方法的介绍。

## Records

Java 16 中引入的第一个重大语言特性称为记录（records）。记录用来将数据表示为 Java 代码中的数据，而不是任意类。在 Java 16 之前，有时我们只是需要表示一些数据，最终却得到了一个任意类，如下面的代码段所示。

```java
public class Product {
  private String name;
  private String vendor;
  Private int price;
  private boolean inStock;
}
```

这里我们有一个 Product 类，它有四个成员。定义这个类所需的所有信息应该就是这些了。当然，我们需要更多的代码来完成这项工作。例如，我们需要有一个构造器。我们需要有相应的 getter 方法来获取成员的值。为了补充完整，我们还需要有与我们定义的成员一致的 equals()、hashCode()和 toString()实现。一些样板代码可以由 IDE 生成，但这样做会有一些缺陷。你也可以使用 Lombok 等框架，但它们也有一些缺陷。

 

我们真正需要的是由 Java 语言提供一种机制，可以更准确地描述拥有纯数据类这个概念。所以在 Java 16 中我们有了记录的概念。在以下代码段中，我们将 Product 类重新定义为一个记录。

```java
public record Product(
    String name,
    String vendor,
    int price,
    boolean inStock) {
}
```

请注意这里引入了新关键字 record。我们需要在关键字 record 之后指定记录类型的名称。在我们的示例中，这个名称是 Product。然后我们只需要提供组成这些记录的组件。在这里，我们给出了四个组件的类型和名称以提供它们。然后我们就完成了。Java 中的记录是类的一个特殊形式，其中只包含数据。

 

记录能给我们带来什么呢？一旦我们有了一个记录声明，我们就会得到一个类，它有一个隐式构造器，接受这个记录的组件的所有值。我们会根据所有记录组件自动获取 equals()、hashCode()和 toString()方法的实现。此外，我们还为记录中的每个组件获取访问器方法。在上面的例子中，我们得到了一个 name 方法、一个 vendor 方法、一个 price 方法和一个 inStock 方法，它们分别返回这个记录的组件的实际值。

 

记录永远是不可变的。这里没有 setter 方法。一旦使用某些值实例化一个记录，那么你就无法再更改它了。此外，记录类就是最终形式。你可以使用一个记录实现一个接口，但在定义记录时不能扩展其他任何类。总而言之，这里有一些限制。但是记录为我们提供了一种非常强大的方式来在我们的应用程序中简洁地定义纯数据类。

## 怎样看待记录

你应该如何看待和处理这些新的语言元素呢？记录是一种新的、受限形式的类，用于将数据建模为数据。我们不可能向记录添加任何附加状态；除了记录的组件之外，你不能定义（非静态）字段。记录实际上是建模不可变数据的。你也可以将记录视为元组，但它并不只是其他一些语言所有的那种一般意义上的元组，在那种元组里有一些可以由索引引用的任意组件。在 Java 中，元组元素有实际名称，并且元组类型本身——即记录，也有一个名称，因为名称在 Java 中很重要。

## 记录不适合哪些场景

有些场景中我们可能会觉得记录用起来并不是很合适。首先，它们并不是任何现有代码的一个样板缩减机制。虽然我们现在有一种非常简洁的方式来定义这些记录，但这并不意味着你的应用程序中的任何数据（如类）都可以轻松地被记录替换，这主要是因为记录存在的一些限制所致。这也不是它真正的设计目标。

 

记录的设计目标是提供一种将数据建模为数据的好方法。它也不是 JavaBeans 的直接替代品，因为正如我之前提到的，访问器这样的方法不符合 JavaBeans 的 get 标准。另外 JavaBeans 通常是可变的，而记录是不可变的。尽管它们的用途有点像，但记录并不会以某种方式取代 JavaBean。你也不应该将记录视为值类型。

 

值类型可能会在未来的 Java 版本中作为语言增强引入，其主要关注内存布局和类中数据的有效表示。当然，这两条世界线在未来某一时刻可能会合并在一起，但就目前而言，记录只是表达纯数据类的一种更简洁的方式。

## 进一步了解记录

考虑以下代码，我们创建了 Product 类型的记录 p1 和 p2，具有完全相同的值。

```java
Product p1 = new Product("peanut butter", "my-vendor", 20, true);
Product p2 = new Product("peanut butter", "my-vendor", 20, true);
```

我们可以通过引用相等来比较这些记录，也可以使用 equals()方法比较它们，该方法已由记录实现自动提供。

```java
System.out.println(p1 == p2); // Prints false
System.out.println(p1.equals(p2)); // Prints true
```

可以看到，这两条记录是两个不同的实例，因此引用对比将给出 false。但是当我们使用 equals()时，它只查看这两个记录的值，所以它会评估为 true。因为它只考虑记录内部的数据。重申一下，相等性和哈希码的实现完全基于我们为记录的构造器提供的值。

 

需要注意的一件事是，你仍然可以覆盖记录定义中的任何访问器方法，或者相等性和哈希码实现。但是，你有责任在记录的上下文中保留这些方法的语义。并且你可以向记录定义添加其他方法。你还可以访问这些新方法中的记录值。

 

另一个你可能想在记录中执行的重要特性是验证。例如，你只想在提供给记录构造器的输入有效时才创建记录。传统的验证方法是定义一个带有输入参数的构造器，这些参数在将参数分配给成员变量之前进行验证。但是对于记录而言，我们可以使用一种新格式，即所谓的紧凑构造器。在这种格式中，我们可以省略正式的构造器参数。构造器将隐式地访问组件值。在我们的 Product 示例中，我们可以说如果 price 小于零，则抛出一个新的 IllegalArgumentException。

```java
public record Product(
    String name,
    String vendor,
    int price,
    boolean inStock) {
  public Product {
    if (price < 0) {
      throw new IllegalArgumentException();
    }
  }
}
```

从上面的代码段中可以看出，如果价格高于零，我们就不必手动做任何赋值。在编译此记录时，编译器会自动添加从（隐式）构造器参数到记录字段的赋值。

 

如果我们愿意，甚至可以进行正则化。例如，我们可以将隐式可用的价格参数设置为一个默认值，而不是在价格小于零时抛出异常。

```java
public Product {
  if (price < 0) {
    price = 100;
  }
}
```

同样，对记录的实际成员的赋值——即作为这个记录定义一部分的最终字段，是由编译器在这个紧凑构造器的末尾自动插入的。总而言之，这是在 Java 中定义纯数据类的一种非常通用且非常棒的方法。

 

你还可以在方法中本地声明和定义记录。如果你想在方法中使用一些中间状态，这会非常方便。例如，假设我们要定义一个打折产品。我们可以定义一个记录，包含 Product 和一个指示产品是否打折的 boolean 值。

```java
public static void main(String... args) {
  Product p1 = new Product("peanut butter", "my-vendor", 100, true);
  record DiscountedProduct(Product product, boolean discounted) {}
  System.out.println(new DiscountedProduct(p1, true));
}
```

从上面的代码段中可以看出，我们不必为新记录定义提供正文。我们可以使用 p1 和 true 作为参数来实例化 DiscountedProduct。运行代码时，你会看到它的行为方式与源文件中的顶级记录完全相同。如果你希望在流管道的中间阶段分组某些数据，作为本地构造的记录会非常有用。

## 你会在哪里使用记录

记录有一些显而易见的使用场景。比如说当我们想要使用数据传输对象（Data Transfer Objects，DTO）时就可以使用记录。根据定义，DTO 是不需要任何身份或行为的对象。它们只是用来传输数据的。例如，从 2.12 版本开始，Jackson 库支持将记录序列化和反序列化为 JSON 和其他支持的格式。

 

如果你希望一个映射中的键由充当复合键的多个值组成，记录也会很好用，因为你会自动获得 equals 和 hashcode 实现的正确行为。由于记录也可以被认为是名义元组（其中每个组件都有一个名称），使用记录将多个值从方法返回给调用者也是很方便的。

 

另一方面，我认为记录在 Java Persistence API 中用的不会很多。如果你想使用记录来表示实体，那实际上是不可能的，因为实体在很大程度上是基于 JavaBeans 约定。并且实体通常倾向于是可变的。当然，当你在查询中实例化只读视图对象时，有些情况下你可以使用记录代替常规类。

 

总而言之，我认为 Java 中引入记录是一项激动人心的改进。我认为它们会得到广泛使用。

## instanceof 的模式匹配

Java 16 中的第二大语言更改是 instanceof 的模式匹配。这是将模式匹配引入 Java 的漫长旅程的第一步。就目前而言，我认为 Java 16 中提供的初期支持已经很不错了。看看下面的代码段。

```java
if (o instanceOf String) {
  String s = (String) o;
  return s.length();
}
```

你可能会认出这种模式，其中一些代码负责检查对象是否是一个类型的实例，在本例中是 String 类。如果检查通过，我们需要声明一个新的作用域变量，转换并赋值，然后我们才能开始使用这个类型化的变量。在这个示例中，我们需要声明变量 s，cast o 为一个 String，然后调用 length()方法。虽然这种办法也能用，但太啰嗦了，而且并没有反映出代码的真实意图。我们有更好的办法。

 

从 Java 16 开始，我们可以使用新的模式匹配特性了。使用模式匹配时，我们可以将 o 匹配一个类型模式，而不是说 o 是一个特定类型的实例。类型模式由一个类型和一个绑定变量组成。我们来看一个例子。

```java
if (o instanceOf String s) {
  return s.length();
}
```

在上面的代码段中，如果 o 确实是 String 的实例，那么 String s 将立即绑定到 o 的值。这意味着我们可以立即开始使用 s 作为一个字符串，而无需在 if 主体内进行显式转换。这里的另一个好处是 s 的作用域仅限于 if 的主体。这里需要注意的一点是，源代码中 o 的类型不应该是 String 的子类型，因为如果是这种情况，条件将始终为真。因此一般而言，如果编译器检测到正在测试的对象的类型是模式类型的子类型，则会抛出编译时错误。

 

另一个需要指出的有趣的事情是，编译器很聪明，可以根据条件的计算结果为 true 还是 false 来推断 s 的作用域，正如以下代码段中所示。

```java
if (!(o instanceOf String s)) {
  return 0;
} else {
  return s.length();
}
```

编译器看到，如果模式匹配不成功，那么在 else 分支中，我们的 s 将在 String 类型的作用域内。并且在 if 分支 s 不在作用域内时，我们在作用域内就只有 o。这种机制称为流作用域，其中类型模式变量仅在模式实际匹配时才在作用域内。这真的很方便，能够有效简化这段代码。你需要注意这个变化，可能需要一点时间来适应。

 

另一个例子里你也可以清楚地看到这个流的作用。当你重写 equals()方法的以下代码实现时，常规的实现是首先检查 o 是否是 MyClass 的一个实例。如果是，我们将 o 转换为 MyClass，然后将 o 的 name 字段与 MyClass 的当前实例进行匹配。

```java
@Override
public boolean equals(Object o) {
  return (o instanceOf MyClass) &&
      ((MyClass) o).name.equals(name);
}
```

我们可以使用新的模式匹配机制来简化这个实现，如下面的代码段所示。

```java
@Override
public boolean equals(Object o) {
  return (o instanceOf MyClass m) &&
      m.name.equals(name);
}
```

这里又一次对代码中显式、冗长的转换做了很好的简化。只要用在合适的用例里，模式匹配会抽象出许多样板代码。

## 模式匹配：未来发展

Java 团队已经勾勒出了模式匹配的一些未来发展方向。当然，团队并没有承诺这些设想何时或如何引入官方语言。在下面的代码段中可以看到，在新的 switch 表达式中，我们可以像之前讨论的那样使用 instanceOf 来做类型模式。

```java
static String format(Object o) {
  return switch(o) {
    case Integer i -> String.format("int %d", i);
    case Double d -> String.format("int %f", d);
    default -> o.toString();
  };
}
```

在 o 是整数的情况下，流作用域开始起作用，我们可以立即将变量 i 用作一个整数。其他情况和默认分支也是如此。

 

另一个令人兴奋的新方向是记录模式，我们可以模式匹配我们的记录并立即将组件值绑定到新变量。看看下面的代码段。

```java
if (o instanceOf Point(int x, int y)) {
  System.out.println(x + y);
}
```

我们有一个包含 x 和 y 的 Point 记录。如果对象 o 确实是一个点，我们将立即将 x 和 y 分量绑定到 x 和 y 变量并立即开始使用它们。

 

数组模式是可能在 Java 的未来版本中引入的另一种模式匹配。看看下面的代码段。

```java
if (o instanceOf String[] {String s1, String s2, ...}) {
  System.out.println(s1 + s2);
}
```

如果 o 是字符串数组，则可以立即将这个字符串数组的第一部分和第二部分提取到 s1 和 s2。当然，这只适用于字符串数组中有两个或更多元素的情况。我们可以使用三点表示法忽略数组元素的其余部分。

 

总而言之，使用 instanceOf 进行模式匹配是一个不错的小特性，但它是迈向新未来的一步。我们可能会引入其他类型的模式来帮助编写干净、简单和可读的代码。

## 特性预览：密封类

下面来谈谈密封类（sealed class）这个特性。请注意，这是 Java 16 中的预览特性，将在 Java 17 中成为最终版本。你需要将--enable-preview 标志传递给编译器调用和 JVM 调用才能在 Java 16 中使用这个特性。该特性允许你控制继承层次结构。

 

假设你想对一个超类型 Option 建模，其中你只想有 Some 和 Empty 两个子类型。并且你想预防 Option 类型获得任何扩展。例如，你不想在层次结构中允许 Maybe 类型。

![img](https://static001.geekbang.org/infoq/89/89f67aaf464f67ec066a488747d36570.jpeg)

 

因此，你已经详细描述了 Option 类型的所有子类型。如你所知，目前在 Java 中控制继承的唯一工具是通过 final 关键字。这意味着根本不能有任何子类，但这不是我们想要的。有一些解决方法可以在没有密封类的情况下建模这个特性，但有了密封类后就容易多了。

 

密封类特性带有新的关键字 sealed 和 permits。看看下面的代码段。

```java
public sealed class Option<T>
    permits Some, Empty {
  ...
}
public final class Some
    extends Option<String> {
  ...
}
public final class Empty
    extends Option<Void> {
  ...
}
```

我们可以定义要 sealed 的 Option 类。然后，在类声明之后，我们使用 permit 关键字来规定只允许 Some 和 Empty 类扩展 Option 类。然后，我们可以像往常一样将 Some 和 Empty 定义为类。我们希望将这些子类设为 final，以防止进一步继承。现在系统就不能编译其他类来扩展 Option 类了，这是由编译器通过密封类机制强制执行的。

 

关于此特性还有很多要说的内容，本文不能一一尽述。如果你有兴趣了解更多信息，我建议你浏览[密封类Java增强提案页面](https://openjdk.java.net/jeps/360)JEP360。

## 小结

Java 16 中还有很多我们无法在本文中介绍的内容，例如[Vector API](https://openjdk.java.net/jeps/338)、[Foreign Linker API](https://openjdk.java.net/jeps/389)和[Foreign-Memory Access API](https://openjdk.java.net/jeps/393)等孵化器 API 都非常有前途。并且新版在 JVM 层面也做了很多改进。例如[ZGC](https://docs.oracle.com/en/java/javase/16/gctuning/z-garbage-collector.html)有一些性能改进；在 JVM 中做了一些[Elastic Metaspace](https://openjdk.java.net/jeps/387)改进；还有一个新的 Java 应用程序[打包工具](https://docs.oracle.com/en/java/javase/16/jpackage/packaging-overview.html)，允许你为 Windows、Mac 和 Linux 创建原生安装程序。最后，当你从 classpath 运行应用程序时，JDK 中的封装类型将受到严格保护，我认为这也会有很大影响。

 

我强烈建议你研究所有这些新特性和语言增强，因为其中一些改进会对你的应用程序产生重大影响。