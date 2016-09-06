title: 'mysql 的线程和连接统计的状态 '
id: 257
categories:
  - mysql
date: 2015-01-22 20:24:25
tags:
---

mysql 的线程和连接统计的状态 可以看到 尝试的连接、退出的连接、网络流量、线程统计，对我司的68nav 统计如下：

&nbsp;

mysql&gt; show status like '%Connect%';
+----------------------+------------+
| Variable_name | Value |
+----------------------+------------+
| Aborted_connects | 273249 |
| Connections | 2146159970 |
| Max_used_connections | 3001 |
| Threads_connected | 10 |
+----------------------+------------+

&nbsp;

mysql&gt; show status like '%Aborted%';
+------------------+--------+
| Variable_name | Value |
+------------------+--------+
| Aborted_clients | 5564 |
| Aborted_connects | 273249 |
+------------------+--------+
2 rows in set

&nbsp;

mysql&gt; show status like '%Bytes%';'
+----------------+-------+
| Variable_name | Value |
+----------------+-------+
| Bytes_received | 339 |
| Bytes_sent | 1662 |
+----------------+-------+
2 rows in set

&nbsp;

mysql&gt; show status like '%threads%';
+------------------------+--------+
| Variable_name | Value |
+------------------------+--------+
| Delayed_insert_threads | 0 |
| Slow_launch_threads | 0 |
| Threads_cached | 6 |
| Threads_connected | 10 |
| Threads_created | 727972 |
| Threads_running | 8 |
+------------------------+--------+
6 rows in set

&nbsp;

&nbsp;