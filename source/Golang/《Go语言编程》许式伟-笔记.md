### Charpter 2
uint8（即byte类型） 0 ~ 255

int32(),int(),float32()进行强制类型转换, math.IsEqual()进行浮点数比较
```
var value2 int32
value1 := 64 // value1将会被自动推导为int类型
value2 = value1 // 编译错误
value2 = int32(value1) // 编译通过
```
Go编译器支持UTF-8的源代码文件格式。这意味着源代码中的字符串可以包含非ANSI的字符，比如“Hello world. 你好，世界！”可以出现在Go代码中。

x + y 字符串连接 "Hello" + "123" // 结果为Hello123

Go语言支持两种方式遍历字符串。一种是以字节数组(byte, uint8)的方式遍历,另一种是以Unicode字符(rune)遍历

数组是一个值类型（value type）。所有的值类型变量在赋值和作为参数传递时都将产生一次复制动作

数组切片的数据结构可以抽象为以下3个变量：

 一个指向原生数组的指针；
 数组切片中的元素个数；
 数组切片已分配的存储空间。

mySlice = append(mySlice, mySlice2...)   //加上省略号相当于把mySlice2包含的所有元素打散后传入。
###### map
myMap["1234"] = PersonInfo{"1", "Jack", "Room 101,..."} //元素赋值
delete(myMap, "1234") //元素删除
```
//元素查找
value, ok := myMap["1234"]
if ok { // 找到了
// 处理找到的value
}
```
只有在case中明确添加fallthrough关键字，才会继续执行紧跟的下一个case；

Go语言中函数名字的大小写不仅仅是风格，更直接体现了该函数的可见性，这一点尤其需要注意。

func myfunc(args ...int) {} //不定参数类型
