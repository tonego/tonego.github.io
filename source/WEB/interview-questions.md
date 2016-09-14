
## Baidu 

#### 如何处理评论的回复的性能问题
    * 在有大量并发评论产生的时候，直接insert到mysql 可能扛不住。
    * 可以先放到nosql中，利用队列插入数据库。
    * 但是，会出现一个问题：如果我对一个评论进行回复，而被回复的评论还在队列里面，未产生mysql的递增ID，那我这个回复给谁的如何记录呢？

#### 


## xiaomi

#### 商品每分钟的库存变化报表的实现

    原题如下：

    5000个商品goods_id，库存stock，在redis里面 。  

    要做两个事情：

    ①每分钟快照一次；

    ②做报表，每个商品每分钟的库存变化折线图。

    注意的地方：

    存的时候注意数据量，要能存的下来；

    取的时候要足够快速，直接查db可能会存在问题；

    db的表结构或者其他存储的设计

#### 一个数组存放一个大整数，大整数的运算实现类

    原题如下：

    一个整数非常的大，以至于int类型或者double类型都存不下，所以将一个整数放到一个数组里面，每个元素只有一位数字，比如 928329 = array(9,2,8,3,2,9)   93848784278 = array（9,3,8,4,8,7,8,4,2,7,8）
    
    写一个类用到单例模式实现大整数的加法运算，另外写个排序算法来实现数组内元素的排序。


#### 用PHP实现LRU算法


#### PHP打印上个月第一天和上个月最后一天的日期

        echo date('Y-m-d', strtotime('last month first day'));
        echo date('Y-m-d', strtotime('last month last day'));

        echo date('Y-m-01', strtotime('-1 month'));
        echo date('Y-m-t', strtotime('-1 month'));

#### 变量如何赋值进数组

    print_r(array('1','2','3'));

    Array ( [0] =&gt; 1 [1] =&gt; 2 [2] =&gt; 3 ) 

    $data = "'1','2','3'";

    print_r(array($data));

    Array ( [0] =&gt; '1','2','3' )

    像上面一样，从一个变量赋值进去要怎么做？


#### 整型的一维数组，对其里面的值进行大小排序，追求效率
    
#### 排序算法

    选择排序
    冒泡排序
    归并排序
    希尔排序
    快速排序
    堆排序
    插入排序
    视觉直观感受 7 种常用的排序算法：http://blog.jobbole.com/11745/

#### 判断一个变量为空有哪些方式，判断一个数组为空有哪些方式

#### 对于$_REQUEST['a'] 报错的提示，应该如何处理

    报错说明代码不规范，应该根本解决问题，规范自己写代码的习惯，类似这样：  $a = !empty($_GET['id'])? (int)$_GET['id'] : 0; 

    如果是要屏蔽报错显示：
    ① 设置PHP.INI ， error_reporting = E_ALL &amp; ~E_NOTICE ; 除提示外，显示所有的错误。。。
    ② 在页面上游代码中添加，error_reporting(E_ALL &amp; ~E_NOTICE);
    ③ 在本句前面加  @ 。

    参考资料： http://www.w3school.com.cn/php/func_error_reporting.asp

    http://php.net/manual/zh/function.error-reporting.php


#### PHP用文件来做计数器，提醒确保多个进程同时写入一个文件成功


#### 跨域的解决方案、实现机制
    
    jsonp session

#### PHP中传值与传引用的区别，什么时候传值，什么时候传引用

#### 关于continue写在函数中的题目
    ```php
    $a = 4;
    for($i = 0;$i&lt;$a; $i++){
        echo $i."&lt;br&gt;";
        for($ii=0;$ii&lt;$a;$ii++){
            echo $ii.'22'."&lt;br&gt;";
            fun();
        }
    }

    function fun(){
        continue;
    }
    ```

    这个会输出：**Fatal error**: Cannot break/continue 1 level in **/home/wxxxxm/index.php** on line **16**


#### 用PHP来实现hash算法与一致性hash算法
        ```php
        Class ClassA{
            private $buckets;
            private $size=10;
            public function __construct(){
                $this-&gt;buckets = new SplFixedArray($this-&gt;size);
            }
            public static function instance(){
                return new ClassA();
            }
            private function funcHash($key){
                $str_len = strlen($key);
                for($i=0;$i&lt;$str_len;$i++){
                    $hashval += ord($key{$i});
                }
                return $hashval % $this-&gt;size;
            }
            public function insert($key,$val){
                $index = $this-&gt;funcHash($key);
                $this-&gt;buckets[$index] = $val;
            }
            public function find($key){
                $index = $this-&gt;funcHash($key);
                return $this-&gt;buckets[$index];
            }
        }
        ```


#### 关于 floor((0.1+0.7)*10)=7 的问题

    $f = 0.58;
    var_dump(intval($f * 100));
    答案： int(57)

    相关资料请查阅 http://php.net/manual/zh/language.types.float.php


#### 多个程序调用redis的incr会产生线程安全问题

#### echo print print_r 区别

#### include、require、require_once 的联系和区别？

    require()所包含的文件中不能包含控制结构，而且不能使用return这样的语句。在require()所包含的文件中使用return语句会产生处理错误。
    不象include()语句，require()语句会无条件地读取它所包含的文件的内容，而不管这些语句是否执行。
    所以如果你想按照不同的条件包含不同的文件，就必须使用include()语句。当然，如果require()所在位置的语句不被执行，require()所包含的文件中的语句也不会被执行。 include语句只有在被执行时才会读入要包含的文件。在错误处理方便，使用include语句，如果发生包含错误，程序将跳过include语句，虽然会显示错误信息但是程序还是会继续执行！                                              php处理器会在每次遇到include()语句时，对它进行重新处理，所以可以根据不同情况的，在条件控制语句和循环语句中使用include()来包含不同的文件。                                                                                             require_once()和include_once()语句分别对应于require()和include()语句。require_once()和include_once()语句主要用于需要包含多个文件时，可以有效地避免把同一段代码包含进去而出现函数或变量重复定义的错误。



#### PHP 内存管理

    PHP的内存管理可以被看作是分层（hierarchical）的。 它分为三层：存储层（storage）、堆层（heap）和接口层（emalloc/efree）。
    存储层通常申请的内存块都比较大
    PHP内存管理的核心实现，heap层控制整个PHP内存管理的过程
    PHP中的内存管理主要工作就是维护三个列表：小块内存列表（free_buckets）、 大块内存列表（large_free_buckets）和剩余内存列表（rest_buckets）。
    来源：http://www.php-internals.com/book/?p=chapt06/06-02-php-memory-manager


#### 10G的access_log文件，找出访问最少的N个url

    web 服务器的访问日志文件 ，有10G大小，找出访问最少的N个url。
    结合分治、快速排序的思路来解决问题。

#### 不同linux服务器之前传输文件的命令：

    ftp
    rcp
    scp
    wget
    curl
    rsync
    linux 与window 传输用 ： sz与rz
    Linux 上的常用文件传输方式介绍与比较:   http://www.ibm.com/developerworks/cn/linux/l-cn-filetransfer/



