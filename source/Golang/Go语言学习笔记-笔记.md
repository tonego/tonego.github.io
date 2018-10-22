《Go语言学习笔记》- 雨痕
## 1. 概述
多defer顺序为FILO
使用ok-idiom获取值，x,ok:=map["a]
接口采用duck type方式，无需在实现类型上显式声明
## 2. 类型
#### 2.1 变量
只能修改变量值不能修改类型
退化赋值前提：最少有一个新变量且同作用域
#### 2.2 命名
局部变量用简写，专有名词全大写escapeHTML
#### 2.3 常量
展开。常量会被在编译器预处理阶段直接展开，没有内存地址
#### 2.4 基本类型
uint8==byte int32==rune， 别名间赋值运算无需转换
function interface map slice channel默认值为nil
float32默认保存到小数点后六位, 0.123456==0.1234567
#### 2.5 引用类型
reference type: map slice channel ,必须使用make()创建
#### 2.6 类型转换
语法歧义。
```
(*int)(p)  (<-chan int)(c)  (func())(x)
```
#### 2.7 自定义类型
自定义类型不会继承基础类型的方法， type data int, 不能视作别名，不能隐式转换，不能比较
#### 2.8 未命名类型
未命名类型：point array slice map channel struct func interface
## 3. 表达式
++a a++只能作为独立语句不能作为表达式
unsafe.Pointer 将指针转换为uintptr
runtime/malloc.go有个zerobase全局变量，通过mallocgc分配的零长度对象都使用该地址
for range channelData{...}仅迭代不返回。 可用来清空channel
for i,v:=range array[:]{...} 避免复制，性能优化的技巧
break continue配合goto进行跳转层级
## 4. 函数
first-class object
从函数返回局部变量指针是安全的, escape analysis 来决定是否在堆上分配内存。
go build -gcflags "-l -m"
go tool objdump -s "main\.main" test
命名规则：动+名如scanWords, 避免不必要缩写，避免类型关键字，避免作用域提示前缀
指针参数避免了复制，但有堆内存分配和垃圾回收的成本
变参...int实际上是slice，test(a[:]...)转换为slice后展开。 变参会修改原数据
命名返回值会改善帮助文档&代码编辑器提示。 若返回值能明确表明含义，就不要对其命名
closure 是函数和引用环境的组合体
defer延迟调用性能差5倍。Lock / (defer) Unlock()测试
错误变量通常以err作为前缀，字符串全小写，无结束标点。 errors.New() fmt.Errorf()
自定义错误类型以Error作为后缀
defer 不能用在init()函数中， os.Exit(1)执行不到defer
## 5. 数据
#### 5.1 字符串
转换。字符串类型 []byte []rune与string转换, 可尝试用*(*string)(unsafe.Pointer(&bs))来做toString
(gdb) b runtime.mapaccess2_faststr //在map访问函数上打断点
性能。字符串连接方法， 优先使用 bytes.Buffer strings.Join, 少量使用 fmt.Sprintf text/template, 避免使用 +
Unicode。r:='我'自动rune/int32类型，s:="我"自动string类型。 utf8.RuneCountInString返回字符数
rune 专门存储Unicode码点，相当于UCS-4/UTF-32格式


#### 5.2 数组
第一维度允许使用 d:=[...]user{{"a"},{"b"}}
指针。 指针数组 数组指针. 数组指针可以直接操作元素
复制。 可用指针或切片传参避免数据复制
#### 5.3 切片
切片是只读对象，类似数组指针的一种包装
少元素，不适合用切片代替数组，切片底层数组可能在堆上分配内存， 小数组在栈上拷贝的消耗小于make代价
reslice 新建切片依旧指向原底层数组， 修改对所有关联切片可见
append 超出sli的cap则会新分配空间，不会改变原数组|Sli
copy 根据原切片长度进行覆盖操作
#### 5.4 字典
m2:=map[string]int{}已初始化，等同make操作
安全。 data race sync.RWMutex
性能。 不会收缩内存
#### 5.5 结构
空结构。 指向runtime.zerobase
匿名字段
字段标签
内存布局
## 6. 方法
## 7. 接口
通常以er作为后缀
## 8 并发
#### 8.1 并发含义
Wait， make(chan struct{}) close() sync.WaitGroup()
runtime.GOMAXPROCS
Local Storage
runtime.Gosched()
runtime.Goexit() 会执行defer不会panic， os.Exit()不会执行defer
#### 8.2 通道
CSP Actor
收发。x,ok:=<-c可判断是否close， for x:=range c{}，close()意思是关闭写入，可读不可写。
单向。
选择。
模式。 通常使用工厂方法将goroutine和channel绑定。 <-(chan struct{})(nil)用nil channel堵塞进程。
性能。将发往channel数据打包
资源泄露。channel一直被堵塞会引发goroutine leak
#### 8.3 同步
channel解决逻辑层并发处理架构，sync.RWMutex保护局部范围内的数据安全
