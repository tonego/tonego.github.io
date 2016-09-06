title: mysql select状态查看
id: 275
categories:
  - mysql
date: 2015-01-23 16:40:42
tags:
---

mysql&gt; show status like 'Select_%';
+------------------------+-------+
| Variable_name | Value |
+------------------------+-------+
| Select_full_join | 0 |
| Select_full_range_join | 0 |
| Select_range | 0 |
| Select_range_check | 0 |
| Select_scan | 0 |
+------------------------+-------+
5 rows in set (0.03 sec)