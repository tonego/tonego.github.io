title: mysql 执行 show processlist 出现 unauthenticated user 的用户
id: 64
categories:
  - mysql
  - PHP笔试题
date: 2014-11-18 17:47:22
tags:
---

&nbsp;

发现这算属MySQL的一个bug，不管连接是通过hosts还是ip的方式，MySQL都会对DNS做反查，IP到DNS，由于反查的接续速度过慢（不管是不是isp提供的dns服务器的问题或者其他原因），大量的查询就难以应付，线程不够用就使劲增加线程，但是却得不到释放，所以MySQL会“假死”。

解决的方案很简单，结束这个反查的过程，禁止任何解析。

打开mysql的配置文件（my.cnf），在[mysqld]下面增加一行：

skip-name-resolve

重新载入配置文件或者重启MySQL服务即可。