title: mysql 的二进制日志状态查看
id: 259
categories:
  - mysql
date: 2015-01-22 20:28:18
tags:
---

&nbsp;

mysql&gt; show status like '%binlog%';;
+----------------------------+-----------+
| Variable_name | Value |
+----------------------------+-----------+
| Binlog_cache_disk_use | 1138890 |
| Binlog_cache_use | 188573519 |
| Binlog_stmt_cache_disk_use | 276 |
| Binlog_stmt_cache_use | 13417134 |
| Com_binlog | 0 |
| Com_show_binlog_events | 0 |
| Com_show_binlogs | 0 |
+----------------------------+-----------+
7 rows in set