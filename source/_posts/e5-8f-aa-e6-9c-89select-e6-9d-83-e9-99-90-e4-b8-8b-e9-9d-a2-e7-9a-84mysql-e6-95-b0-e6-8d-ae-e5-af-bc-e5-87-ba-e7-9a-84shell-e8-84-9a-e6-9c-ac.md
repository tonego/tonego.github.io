title: 只有select权限下面的mysql数据导出的SHELL脚本
id: 135
categories:
  - Linux
  - mysql
date: 2014-12-10 16:53:22
tags:
---

用SHELL脚本实现只有select权限下面的mysql数据导出、数据同步。

&nbsp;

#!/bin/bash
#Program:
# 线上数据表同步到开发机
#History
# 2014/10/20 wangtong First release
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/go/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/wangtong/bin
export PATH

read -p '请输入你要从68导入87数据库的表名：' table

#以下为方案一，不用mysqldump导出，而导入效率也极低，10w条数据导入需要1h以上
#mysql -h114.112.**.** -P13**4 -uwangtong -pc************e6****fe -D duba_*** -e "set names utf8; select * from $table" &gt; /home/wangtong/tmp.sql
#sed -i 's/"/\\"/g' /home/wangtong/tmp.sql
#colnum=$(head -1 tmp.sql | wc -w)
#for((i=1;i&lt;$colnum;i=i+1))
#do
# values=$values'\""$'$i'"\",'
#done
# values=$values'\""$'$colnum'"\"'
#cat -T /home/wangtong/tmp.sql | awk -F '\\^I' '{ print "insert into '$table' values('$values');";} ' &gt; /home/wangtong/$table.sql
#sed -i '1a truncate table '$table';' /home/wangtong/$table.sql
#sed -i '1d' /home/wangtong/$table.sql
#mysql -hlocalhost -uroot -pij*******7777 -D ******ba_nav &lt; /home/wangtong/$table.sql
#以下为方案二，用msyqldump导出，用source导入
mysqldump -h114.112.6**.** -P1*** -uwangtong -pc0**********fe --lock-tables=false -B duba_nav --table $table &gt; /home/wangtong/tmp/$table.sql
mysql -hlocalhost -uroot -piji******77 -D s******duba_nav -e "source /home/wangtong/tmp/"$table".sql"