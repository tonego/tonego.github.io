title: PHP 内存管理
tags:
  - 滴滴打车面试题
id: 277
categories:
  - PHP
  - PHP笔试题
date: 2015-01-23 19:24:28
---

&nbsp;

PHP的内存管理可以被看作是分层（hierarchical）的。 它分为三层：存储层（storage）、堆层（heap）和接口层（emalloc/efree）。

&nbsp;

存储层通常申请的内存块都比较大

PHP内存管理的核心实现，heap层控制整个PHP内存管理的过程

&nbsp;

PHP中的内存管理主要工作就是维护三个列表：小块内存列表（free_buckets）、 大块内存列表（large_free_buckets）和剩余内存列表（rest_buckets）。

&nbsp;

来源：http://www.php-internals.com/book/?p=chapt06/06-02-php-memory-manager

&nbsp;

&nbsp;