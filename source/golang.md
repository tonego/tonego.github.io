## Golang
#### 汇编
* 
* go:linkname/noescape/nosplit/nowritebarrierrec/yeswritebarrierrec/noinline/norace/notinheap/

#### 坑
* map并发读写
* goroutine方法的指针参数会被外层修改 go func(ctx)
* mutex 不能复制
* 可变参数是空接口类型
* 数组是值传递, for i,v:=range arr[:]
* 切片append超过原数组将重新分配内存，不会修改原数组
* map遍历是顺序不固定
* 返回值被屏蔽
* recover必须在defer函数中运行
* 独占CPU导致其它Goroutine饿死，用runtime.Gosched()
* 闭包错误引用同一个变量， 传参
* 在循环内部执行defer语句， 实际在返回值时才defer调用
* 切片会导致整个底层数组被锁定
* 循环内值的指针使用。for i,v:=range arr{res=append(res,&v)}
* 

#### 静态检查
* errcheck、
* structtag
#### 参考资料
* [Golang高级编程](https://chai2010.cn/advanced-go-programming-book/appendix/appendix-a-trap.html)