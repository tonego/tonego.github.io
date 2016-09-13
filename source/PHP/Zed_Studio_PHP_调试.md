title: Zend Studio PHP 调试
id: 79
categories:
  - PHP
  - 调试
date: 2014-11-20 12:17:43
tags:
---

关于PHP调试，花费额的时间算是挺多的。

由于开发环境的多样性，不得不花时间去研究各种调试配置。

在这里开发环境是这样的：url访问资源，nginx配置、php脚本、mysql数据库、memcache服务 均在linux服务器，好在有samba提供了远程文件管理可以使用zend studio 鼓捣一下。

这种情况下，涉及数据量大，web server不能在本地windows部署，所以，不能用之前 普通的ZendDebugger来部署调试了。

半年前我曾远程配置成功了，但是那台笔记本磁盘坏掉后，现在de我竟然忘记当时是怎么配出来的。

现在，重新研究吧。。。