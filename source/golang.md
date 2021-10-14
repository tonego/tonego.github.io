## Golang
#### gc
写屏障
插入屏障（Dijkstra）- 灰色赋值器：尚未被回收器扫描过或尽管已经扫描过，但仍需要重新扫描。

黑色赋值器：已经由回收器扫描过，不会再次对其进行扫描。
https://liangyaopei.github.io/2021/01/02/golang-gc-intro/


#### goroutine/channel
https://mp.weixin.qq.com/s/40uxAPdubIk0lU321LmfRg
https://reading.developerlearning.cn/reading/12-2018-08-02-goroutine-gpm/
    M的状态是通过notesleep()方法变为unspin状态， 通过notewakeup()方法变为spin状态
    Gdead状态通过newproc()变更为runnable状态

#### panic
https://xiaomi-info.github.io/2020/01/20/go-trample-panic-recover/
数组 ( slice ) 下标越界 panic: runtime error: index out of range
访问未初始化的指针或 nil 指针 panic: runtime error: invalid memory address or nil pointer dereference
试图往已经 close 的 chan 里发送数据 panic: send on closed channel
并发读写相同 map fatal error: concurrent map read and map write. （throw的panic错误，无法用recover捕获，最为致命）
类型断言 interface conversion: interface {} is string, not []string 


#### interface
eface(_type,data)
iface(itab,data)
    itab.hash = _type.hash用于断言。
interface入参不会为nil    

#### 汇编
* 
* go:linkname/noescape/nosplit/nowritebarrierrec/yeswritebarrierrec/noinline/norace/notinheap/

#### 坑
* race问题 - map并发读写
* mutex 不能复制
* 可变参数是空接口类型
* goroutine方法的指针参数会被外层修改 go func(ctx)
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
* errcheck
* structtag
#### 参考资料
* [Golang高级编程](https://chai2010.cn/advanced-go-programming-book/appendix/appendix-a-trap.html)