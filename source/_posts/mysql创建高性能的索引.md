title: mysql创建高性能的索引
id: 309
categories:
  - mysql
date: 2015-03-11 19:32:49
tags:
---

mysql创建高性能的索引，一些注意事项：

多列索引，要将离散度高的列放在前面；

多个单列索引，where条件是and，or，或者他们的组合，mysql优化器会自动采用 索引合并策略 index_merge

如果某个列，集中在某个值上的数据太多，即基数太大，则会对索引的优化产生误判，会产生慢查询，对此类要修改应用程序。

前缀索引字节数： select count(distinct left(author,7))/count(*) , count(distinct left(author,6))/count(*) , count(distinct left(author,5))/count(*)  from b_book_info where 1 limit 1;

前缀索引不能用于orderby groupby 和索引覆盖查询。

&nbsp;