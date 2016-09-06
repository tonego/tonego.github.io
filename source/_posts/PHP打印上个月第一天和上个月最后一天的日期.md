title: PHP打印上个月第一天和上个月最后一天的日期
id: 13
categories:
  - PHP笔试题
date: 2014-11-03 20:51:03
tags:
---

PHP打印上个月第一天和上个月最后一天的日期：

&nbsp;

echo date('Y-m-d', strtotime('last month first day'));
echo date('Y-m-d', strtotime('last month last day'));

&nbsp;

echo date('Y-m-01', strtotime('-1 month'));
echo date('Y-m-t', strtotime('-1 month'));