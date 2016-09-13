title: linux统计某个文件内容的 每个值出现的次数
tags:
  - 小米面试题
id: 233
categories:
  - Linux
  - PHP笔试题
date: 2015-01-07 16:48:33
---

linux统计某个文件内容的 每个值出现的次数

last | cut -d ' ' -f 1 | sort | uniq -c | sort -t ' ' -k 1 -n -r

&nbsp;