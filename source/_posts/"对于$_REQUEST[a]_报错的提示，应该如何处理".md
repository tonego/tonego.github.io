title: "对于$_REQUEST['a'] 报错的提示，应该如何处理"
id: 37
categories:
  - PHP
  - PHP笔试题
date: 2014-11-18 16:23:29
tags:
---

对于$_REQUEST['a'] 报错的提示，应该如何处理呢？

报错说明代码不规范，应该根本解决问题，规范自己写代码的习惯，类似这样：  $a = !empty($_GET['a'])? $_GET['a'] : '';

&nbsp;

如果是要屏蔽报错显示：

① 设置PHP.INI ， error_reporting = E_ALL &amp; ~E_NOTICE ; 除提示外，显示所有的错误。。。

② 在页面上游代码中添加，error_reporting(E_ALL &amp; ~E_NOTICE);

③ 在本句前面加  @ 。

&nbsp;

参考资料： http://www.w3school.com.cn/php/func_error_reporting.asp

http://php.net/manual/zh/function.error-reporting.php

&nbsp;

&nbsp;

&nbsp;

&nbsp;