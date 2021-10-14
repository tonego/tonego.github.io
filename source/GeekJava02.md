## Java
#### 杨晓峰-java核心技术36讲

###### 00以面试题为切入点，有效提升你的Java内功
###### 01谈谈你对Java平台的理解？
最显著的特性有两个方面，一是所谓的“书写一次，到处运行”（Write once, run anywhere）；另外就是垃圾收集（GC, Garbage Collection）
JRE，也就是 Java 运行环境，包含了 JVM 和 Java 类库，以及一些模块等。而 JDK 可以看作是 JRE 的一个超集，提供了更多工具，比如编译器、各种诊断工具等。
Javac 编译成为字节码（bytecode）
Java 虚拟机（JVM）内嵌的 JIT（Just-In-Time）编译器 在运行时将热点代码字节码转换成为机器码.部分热点代码就属于编译执行，而不是解释执行了.
Java 语言特性，包括泛型、Lambda 等语言特性；基础类库，包括集合、IO/NIO、网络、并发、安全等基础类库。
 JVM 的一些基础概念和机制，比如 Java 的类加载机制，常用版本 JDK（如 JDK 8）内嵌的 Class-Loader，例如 Bootstrap、 Application 和 Extension Class-loader；类加载大致过程：加载、验证、链接、初始化（这里参考了周志明的《深入理解 Java 虚拟机》，非常棒的 JVM 上手书籍）；自定义 Class-Loader 等。还有垃圾收集的基本原理，最常见的垃圾收集器，如 SerialGC、Parallel GC、 CMS、 G1 等，对于适用于什么样的工作负载.
Java 分为编译期和运行时。Javac 的编译，编译 Java 源码生成“.class”文件里面实际是字节码，而不是可以直接执行的机器码。
JVM 会通过类加载器（ Class-Loader ）加载字节码，解释或者编译执行。 JDK 8 实际是解释和编译混合的一种模式，即所谓的混合模式（-Xmixed）。
通常运行在 server 模式的 JVM，会进行上万次调用以收集足够的信息进行高效的编译，client 模式这个门限是 1500 次。
Oracle Hotspot JVM 内置了两个不同的 JIT compiler，C1 对应前面说的 client 模式，适用于对于启动速度敏感的应用，比如普通 Java 桌面应用；C2 对应 server 模式，它的优化是为长时间运行的服务器端应用设计的。默认是采用所谓的分层编译（TieredCompilation）。
指定“-Xint”，就是告诉 JVM 只进行解释执行，不对代码进行编译，这种模式抛弃了 JIT 可能带来的性能优势。
“-Xcomp”参数，这是告诉 JVM 关闭解释器，不要进行解释执行，或者叫作最大优化级别。
分支预测，如果不进行 profiling，往往并不能进行有效优化。
 AOT（Ahead-of-Time Compilation），直接将字节码编译成机器代码，这样就避免了 JIT 预热等
jaotc --output libHelloWorld.so HelloWorld.class
jaotc --output libjava.base.so --module java.base
java -XX:AOTLibrary=./libHelloWorld.so,./libjava.base.so HelloWorld

###### 02Exception和Error有什么区别？
Exception 和 Error 都是继承了 Throwable 类，在 Java 中只有 Throwable 类型的实例才可以被抛出（throw）或者捕获（catch），它是异常处理机制的基本组成类型。
Exception 是程序正常运行中，可以预料 应该被捕获。
绝大部分的 Error 都会导致程序（比如 JVM 自身）处于非正常的、不可恢复状态。OutOfMemoryError 之类，都是 Error 的子类
Exception 又分为可检查（checked）异常和不检查（unchecked）异常。
不检查异常就是所谓的运行时异常，类似 NullPointerException、ArrayIndexOutOfBoundsException 之类，通常是可以编码避免的逻辑错误，具体根据需要来判断是否需要捕获，并不会在编译期强制要求。
Throwable、Exception、Error 的设计和分类
try-catch-finally 块，throw、throws 关键字。 便利的特性，比如try-with-resources 和 multiple catch
```
try (BufferedReader br = new BufferedReader(…);
     BufferedWriter writer = new BufferedWriter(…)) {// Try-with-resources
// do something
catch ( IOException | XEception e) {// Multiple catch
   // Handle it
}
```
尽量不要捕获类似 Exception 这样的通用异常，而是应该捕获特定异常
不要生吞（swallow）异常。
Throw early, catch late 原则。

###### 03谈谈final、finally、 finalize有什么不同？
final 的方法也是不可以重写的（override）
finally 则是 Java 保证重点代码一定要被执行的一种机制。
finalize 是基础类 java.lang.Object 的一个方法，它的设计目的是保证对象在被垃圾收集前完成特定资源的回收。finalize 机制现在已经不推荐使用，并且在 JDK 9 开始被标记为 deprecated。

###### 04强引用、软引用、弱引用、幻象引用有什么区别？
强引用（“Strong” Reference），就是我们最常见的普通对象引用，只要还有强引用指向一个对象，就能表明对象还“活着”，垃圾收集器不会碰这种对象。
软引用（SoftReference），是一种相对强引用弱化一些的引用，可以让对象豁免一些垃圾收集，只有当 JVM 认为内存不足时，才会去试图回收软引用指向的对象。
弱引用（WeakReference），是很多缓存实现的选择。
幻象引用，有时候也翻译成虚引用，你不能通过它访问对象。提供了一种确保对象被 finalize 以后做些事情的机制。如做所谓的 Post-Mortem 清理机制、Java 平台自身 Cleaner 机制、幻象引用监控对象的创建和销毁。
###### 05String、StringBuffer、StringBuilder有什么区别？
StringBuffer 是为解决上面提到拼接产生太多中间对象的问题而提供的一个类。StringBuffer 本质是一个线程安全的可修改字符序列。
StringBuilder 是 Java 1.5 中新增的，在能力上和 StringBuffer 没有本质区别，但是它去掉了线程安全的部分。
###### 06动态代理是基于什么原理？
动态代理是一种方便运行时动态构建代理、动态处理代理方法调用的机制，很多场景都是利用类似机制做到的，比如用来包装 RPC 调用、面向切面的编程（AOP）。


###### 07int和Integer有什么区别？
Integer 是 int 对应的包装类。
###### 08对比Vector、ArrayList、LinkedList有何区别？
Vector 是 Java 早期提供的线程安全的动态数组
ArrayList 是应用更加广泛的动态数组实现，它本身不是线程安全的。
LinkedList 顾名思义是 Java 提供的双向链表，所以它不需要像上面两种那样调整容量，它也不是线程安全的。
###### 09对比Hashtable、HashMap、TreeMap有什么不同？
Hashtable 是早期 Java 类库提供的一个哈希表实现，本身是同步的，不支持 null 键和值，由于同步导致的性能开销，所以已经很少被推荐使用。
HashMap 不是同步的，支持 null 键和值等. HashMap 进行 put 或者 get 操作，可以达到常数时间的性能，所以它是绝大部分利用键值对存取场景的首选
TreeMap 则是基于红黑树的一种提供顺序访问的 Map，和 HashMap 不同，它的 get、put、remove 之类操作都是 O（log(n)）的时间复杂度


###### 10如何保证集合是线程安全的ConcurrentHashMap如何实现高效地线程安全
在传统集合框架内部，除了 Hashtable 等同步容器，还提供了所谓的同步包装器（Synchronized Wrapper），我们可以调用 Collections 工具类提供的包装方法，来获取一个同步的包装容器（如 Collections.synchronizedMap），但是它们都是利用非常粗粒度的同步方式，在高并发情况下，性能比较低下。

ConcurrentHashMap、CopyOnWriteArrayList
ArrayBlockingQueue、SynchronousQueue

###### 11Java提供了哪些IO方式？ NIO如何实现多路复用？
传统的 java.io 包，它基于流模型实现，提供了我们最熟知的一些 IO 功能，比如 File 抽象、输入输出流等。

###### 12Java有几种文件拷贝方式？哪一种最高效？
###### 13谈谈接口和抽象类有什么区别？
###### 14谈谈你知道的设计模式？
###### 15synchronized和ReentrantLock有什么区别呢？
###### 16 synchronized底层如何实现？什么是锁的升级、降级？
###### 17一个线程两次调用start()方法会出现什么情况？
###### 18什么情况下Java程序会产生死锁？如何定位、修复？
###### 19Java并发包提供了哪些并发工具类？
###### 20并发包中的ConcurrentLinkedQueue和LinkedBlockingQueue有什么区别？
###### 21Java并发类库提供的线程池有哪几种？ 分别有什么特点？
###### 22AtomicInteger底层实现原理是什么？如何在自己的产品代码中应用CAS操作？
###### 23请介绍类加载过程，什么是双亲委派模型？
###### 24有哪些方法可以在运行时动态生成一个Java类？
###### 25谈谈JVM内存区域的划分，哪些区域可能发生OutOfMemoryError
###### 26如何监控和诊断JVM堆内和堆外内存使用？
###### 27Java常见的垃圾收集器有哪些？
###### 28谈谈你的GC调优思路
###### 29Java内存模型中的happen-before是什么
###### 30Java程序运行在Docker等容器环境有哪些新问题
###### 31你了解Java应用开发中的注入攻击吗？
###### 32如何写出安全的Java代码？
###### 33后台服务出现明显“变慢”，谈谈你的诊断思路？
###### 34有人说“Lambda能让Java程序慢30倍”，你怎么看？
###### 35JVM优化Java代码时都做了什么？
###### 36谈谈MySQL支持的事务隔离级别，以及悲观锁和乐观锁的原理和应用场景？
###### 37谈谈Spring Bean的生命周期和作用域？
###### 38对比Java标准NIO类库，你知道Netty是如何实现更高性能的吗？
###### 39谈谈常用的分布式ID的设计方案？Snowflake是否受冬令时切换影响？
###### 40 技术没有终点

