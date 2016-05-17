title: include、require、require_once 的联系和区别？
tags:
  - 凤凰网面试题
  - 猎豹移动面试题
id: 8
categories:
  - PHP
  - PHP笔试题
date: 2014-11-03 20:46:47
---

require()所包含的文件中不能包含控制结构，而且不能使用return这样的语句。在require()所包含的文件中使用return语句会产生处理错误。 不象include()语句，require()语句会无条件地读取它所包含的文件的内容，而不管这些语句是否执行。所以如果你想按照不同的条件包含不同的文件，就必须使用include()语句。当然，如果require()所在位置的语句不被执行，require()所包含的文件中的语句也不会被执行。 include语句只有在被执行时才会读入要包含的文件。在错误处理方便，使用include语句，如果发生包含错误，程序将跳过include语句，虽然会显示错误信息但是程序还是会继续执行！ php处理器会在每次遇到include()语句时，对它进行重新处理，所以可以根据不同情况的，在条件控制语句和循环语句中使用include()来包含不同的文件。 require_once()和include_once()语句分别对应于require()和include()语句。require_once()和include_once()语句主要用于需要包含多个文件时，可以有效地避免把同一段代码包含进去而出现函数或变量重复定义的错误。