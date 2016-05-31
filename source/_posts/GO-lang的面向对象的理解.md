title: GO-lang的面向对象的理解
date: 2016-02-18 10:04:51
tags:
---

###　对象的写法
* 除指针外的所有类型都可以作为对象
* 对象的方法有×则可修改对象，无×不能修改对象,实际工作中，几乎全用×
[^code]
go```

```

### 有4个类型为引用类型，即a=&b
+ slice
+ map 
+ channel
+ interface 
go```
//slice
type slice struct{
    first *T
    len int
    cap int
}

//map
type Map_K_V struct{
    //...
}
type Map[K]V struct{
    imp1 *Map_K_V
}

//interface
type interface struct{
    data *void
    itab *Itab
}
```

