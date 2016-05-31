title: 用 shell curl 遍历 mysql中的 url数据，排除无效链接
id: 15
categories:
  - Linux
  - mysql
date: 2014-11-06 18:28:01
tags:
---

背景：小说导航网站 ，需要对各个小说站点书的url和章节的url进行检查，去除无效URL；chapters 有255个分表，每个表大约40w数据；site表大约有80w个数据；总计URL过亿； 解决方案： 用 shell 遍历 mysql中的 url数据，排除无效链接；

&nbsp;

#!/bin/bash

mysql -h114.112.xx.xx -Pxxxx -uwaxxxng -pxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -D xxxx_book -e "select site_url from b_book_d_site" &gt; ~/table.tmp
for i in `cat ~/table.tmp`
do
HTTP_CODE=`curl -o /dev/null -s -w %{http_code} $i`
if [ "$HTTP_CODE" -ne "200" ]; then
echo -e "$i:\t$HTTP_CODE" &gt;&gt; ~/res.txt
fi
done

结果发现速度极慢，夜里8点挂上，明早8点起来查了一下，才跑了1.6w的数据，所以此种方案排除。考虑到用curl_multi 系列函数来实现。