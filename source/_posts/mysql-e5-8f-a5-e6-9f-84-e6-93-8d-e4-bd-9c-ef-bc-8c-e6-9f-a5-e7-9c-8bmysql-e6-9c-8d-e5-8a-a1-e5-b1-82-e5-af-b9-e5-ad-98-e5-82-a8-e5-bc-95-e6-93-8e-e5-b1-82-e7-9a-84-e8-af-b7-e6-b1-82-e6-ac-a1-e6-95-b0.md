title: mysql 句柄操作，查看mysql服务层对存储引擎层的请求次数
id: 269
categories:
  - mysql
date: 2015-01-23 08:30:17
tags:
---

mysql 句柄操作，查看mysql服务层对存储引擎层的请求次数

mysql&gt; show status like 'Handler_%';
+----------------------------+-------+
| Variable_name | Value |
+----------------------------+-------+
| Handler_commit | 0 |
| Handler_delete | 0 |
| Handler_discover | 0 |
| Handler_prepare | 0 |
| Handler_read_first | 0 |
| Handler_read_key | 0 |
| Handler_read_last | 0 |
| Handler_read_next | 0 |
| Handler_read_prev | 0 |
| Handler_read_rnd | 0 |
| Handler_read_rnd_next | 0 |
| Handler_rollback | 0 |
| Handler_savepoint | 0 |
| Handler_savepoint_rollback | 0 |
| Handler_update | 0 |
| Handler_write | 0 |
+----------------------------+-------+
16 rows in set

&nbsp;

mysql&gt; explain select count(*) from b_book_info ;
+----+-------------+-------------+-------+---------------+------------+---------+------+--------+-------------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+-------------+-------------+-------+---------------+------------+---------+------+--------+-------------+
| 1 | SIMPLE | b_book_info | index | NULL | index_view | 4 | NULL | 385563 | Using index |
+----+-------------+-------------+-------+---------------+------------+---------+------+--------+-------------+
1 row in set

mysql&gt; show status like 'Handler_%';
+----------------------------+-------+
| Variable_name | Value |
+----------------------------+-------+
| Handler_commit | 1 |
| Handler_delete | 0 |
| Handler_discover | 0 |
| Handler_prepare | 0 |
| Handler_read_first | 0 |
| Handler_read_key | 0 |
| Handler_read_last | 0 |
| Handler_read_next | 0 |
| Handler_read_prev | 0 |
| Handler_read_rnd | 0 |
| Handler_read_rnd_next | 0 |
| Handler_rollback | 0 |
| Handler_savepoint | 0 |
| Handler_savepoint_rollback | 0 |
| Handler_update | 0 |
| Handler_write | 0 |
+----------------------------+-------+
16 rows in set