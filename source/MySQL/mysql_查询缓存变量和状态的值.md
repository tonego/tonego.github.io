title: mysql 查询缓存变量和状态的值
id: 249
categories:
  - mysql
date: 2015-01-20 19:35:02
tags:
---

&nbsp;

我这里现有的mysql查询缓存相关变量和状态如下：

mysql&gt; show status like 'Qcache%';
+-------------------------+-----------+
| Variable_name | Value |
+-------------------------+-----------+
| Qcache_free_blocks | 3977 |
| Qcache_free_memory | 18250096 |
| Qcache_hits | 283961322 |
| Qcache_inserts | 18428082 |
| Qcache_lowmem_prunes | 4356073 |
| Qcache_not_cached | 5546877 |
| Qcache_queries_in_cache | 7952 |
| Qcache_total_blocks | 21891 |
+-------------------------+-----------+
8 rows in set (0.00 sec)

mysql&gt; show status like 'Qcache%';
+-------------------------+-----------+
| Variable_name | Value |
+-------------------------+-----------+
| Qcache_free_blocks | 4084 |
| Qcache_free_memory | 18467768 |
| Qcache_hits | 283964884 |
| Qcache_inserts | 18428200 |
| Qcache_lowmem_prunes | 4356073 |
| Qcache_not_cached | 5546880 |
| Qcache_queries_in_cache | 7840 |
| Qcache_total_blocks | 21775 |
+-------------------------+-----------+
8 rows in set (0.00 sec)

mysql&gt; show variables like 'query_cache%';
+------------------------------+----------+
| Variable_name | Value |
+------------------------------+----------+
| query_cache_limit | 1048576 |
| query_cache_min_res_unit | 4096 |
| query_cache_size | 67108864 |
| query_cache_type | ON |
| query_cache_wlock_invalidate | OFF |
+------------------------------+----------+
5 rows in set (0.06 sec)