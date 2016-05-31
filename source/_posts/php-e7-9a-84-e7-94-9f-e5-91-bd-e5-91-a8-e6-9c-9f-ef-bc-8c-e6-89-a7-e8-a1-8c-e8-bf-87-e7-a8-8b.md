title: PHP的生命周期，执行过程
id: 144
categories:
  - PHP
date: 2014-12-15 18:47:56
tags:
---

&nbsp;

PHP的生命周期，执行过程

&nbsp;

大体上是MINIT、 RINIT、RSHUTDOWN、MSHUTDOWN

更细一些：

**MINIT**

初始化全局变量(zuf)、

初始化常量(PHP_VERSION)、

初始化Zend引擎和核心组件(始化若干HashTable（比如函数表，常量表等等）, 注册内置函数（如strlen、define等），注册标准常量（如E_ALL、TRUE、NULL等）、注册GLOBALS全局变量)；

解析PHP.INI ；

$_GET、$_POST、$_FILES等的全局操作函数的初始化；

初始化标准扩展模块和加载函数（依次遍历每个模块，调用每个模块的模块初始化函数， 也就是在本小节前面所说的用宏PHP_MINIT_FUNCTION包含的内容。）；

禁用函数和类（调用zend_disable_function函数将指定的函数名从CG(function_table)函数表中删除）；

**RINIT(ACTIVATION)**

激活zend引擎（gc_reset函数用来重置垃圾收集机制;init_compiler函数用来初始化编译器，比如将编译过程中在放opcode的数组清空，准备编译时用来的数据结构;init_executor函数用来初始化中间代码执行过程。）

激活SAPI ，（比如当请求方法为HEAD时，设置SG(request_info).headers_only=1）；

环境初始化,(以$_COOKIE为例，php_default_treat_data函数会对依据分隔符，将所有的cookie拆分并赋值给对应的变量。)

模块请求初始化（遍历注册在module_registry变量中的所有模块，调用其RINIT方法实现模块的请求初始化操作）；

**运行**

RSHUTDOWN

MSHUTDOWN

&nbsp;

PHP关闭请求的过程是一个若干个关闭操作的集合，这个集合存在于php_request_shutdown函数中。 这个集合包括如下内容：

1.  调用所有通过register_shutdown_function()注册的函数。这些在关闭时调用的函数是在用户空间添加进来的。 一个简单的例子，我们可以在脚本出错时调用一个统一的函数，给用户一个友好一些的页面，这个有点类似于网页中的404页面。
2.  执行所有可用的__destruct函数。 这里的析构函数包括在对象池（EG(objects_store）中的所有对象的析构函数以及EG(symbol_table)中各个元素的析构方法。
3.  将所有的输出刷出去。
4.  发送HTTP应答头。这也是一个输出字符串的过程，只是这个字符串可能符合某些规范。
5.  遍历每个模块的关闭请求方法，执行模块的请求关闭操作，这就是我们在图中看到的Call each extension's RSHUTDOWN。
6.  销毁全局变量表（PG(http_globals)）的变量。
7.  通过zend_deactivate函数，关闭词法分析器、语法分析器和中间代码执行器。
8.  调用每个扩展的post-RSHUTDOWN函数。只是基本每个扩展的post_deactivate_func函数指针都是NULL。
9.  关闭SAPI，通过sapi_deactivate销毁SG(sapi_headers)、SG(request_info)等的内容。
10.  关闭流的包装器、关闭流的过滤器。
11.  关闭内存管理。
12.  重新设置最大执行时间
&nbsp;

&nbsp;

摘自： http://www.php-internals.com/book/?p=chapt02/02-01-php-life-cycle-and-zend-engine

&nbsp;

&nbsp;