title: mysql 查看键缓冲的次数的状态
id: 273
categories:
  - mysql
date: 2015-01-23 08:35:08
tags:
---

mysql  Key_* 变量包含度量值和关于MyISAM键缓冲的次数。

&nbsp;

mysql&gt; show status like 'key_%';
+------------------------+-----------+
| Variable_name | Value |
+------------------------+-----------+
| Key_blocks_not_flushed | 0 |
| Key_blocks_unused | 272963 |
| Key_blocks_used | 54328 |
| Key_read_requests | 306869577 |
| Key_reads | 74343 |
| Key_write_requests | 44085316 |
| Key_writes | 19361517 |
+------------------------+-----------+
7 rows in set