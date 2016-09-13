title: 听《Web安全分享》
date: 2016-06-02 17:50:34
tags:
---


最常用的两个工具: sqlmap / burp suite

xss 反射型漏洞案例：http://www.111.com.cn/search/search.action?keyWord=%2522%257D;alert(document.cookie);var%2520a=%257Ba:%2522dd

方法：输入woca，源码中搜索woca，根据woca出现的位置来闭合标签实现xss，优先选择js通常更容易实现。


关于sql inject，做到两点即可过滤%92的攻击，
    ①int型参数一定要int 转换，不然易构造1 union select 1,user(),3,version()的不含引号等特殊字符的注入。
    ②string型参数，转义单双引号即可防止构造闭合语句。

关于xss，要做的地方比较多。
    主要注意数据解析到js和html中的特殊符号, 也要注意其他编码格式：\u0027，&#39，%2527
