title: mysql中utf8mb4类型的特点
id: 66
categories:
  - mysql
  - PHP笔试题
date: 2014-11-18 17:50:09
tags:
---

&nbsp;

UTF8存储每个字符最大使用3个字节，而utf8mb4存储每个字符 最大可以使用4个字节。有些UTF8无法存储的utf8mb4就可以。支持 emoji 表情符号