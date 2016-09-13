title: mysql 的临时文件和表的 状态查看
id: 267
categories:
  - mysql
date: 2015-01-23 08:27:34
tags:
---

mysql 的临时文件和表的 状态查看

&nbsp;

mysql&gt; show status like '%created_tmp%';
+-------------------------+--------+
| Variable_name | Value |
+-------------------------+--------+
| Created_tmp_disk_tables | 0 |
| Created_tmp_files | 128719 |
| Created_tmp_tables | 0 |
+-------------------------+--------+
3 rows in set