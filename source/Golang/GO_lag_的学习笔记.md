title: GO lang 的学习笔记
date: 2016-02-16 15:24:05
tags:
---

## GO 的特性

### 并发

goroutine ,比线程更小， runtime.GOMAXPROCS(n) 告知调度器同时使用多个线程

### channel

hannel接收和发送数据都是阻塞的

### range 和close [^code]
```go
func Test() {
    c: =make(chan int, 10)
    go fibonacci(cap(c), c)
    for i: =range c { //使用range操作缓存类型的channel
        fmt.Println(i)
    }
}
func fibonacci(n int, c chan int) {
    x,
    y: =1,
    1
    for i: =0;
    i < n;
    i++{
        c < -x
        x,
        y = y,
        x + y
    }
    close(c) //在生产者的地方关闭channel，而不是在消费的地方去关闭它，这样容易起panic。
}
select
func Test() {
    c: =make(chan int)
    quit: =make(chan int)
    go func() {
        for i: =0;
        i < 10;
        i++{
            fmt.Println( < -c)
        }
        quit < -0
    } ()
    fibonacci(c, quit)
}
func fibonacci(c, quit chan int) {
    x,
    y: =1,
    1
    for {
        select { //*select 默认是阻塞的，只要当监听的channel中发送或者接收可以进行时，才会运行。
        case c < -x: //*当多个channel都准备好的时候，select是随机选择一个执行的。
            x,
            y = y,
            x + y
        case < -quit:
            fmt.Println("quit")
            return
        default:
            fmt.Println("do some thing ");
        }
    }
}
```

> [原文](http://studygolang.com/articles/1538)

