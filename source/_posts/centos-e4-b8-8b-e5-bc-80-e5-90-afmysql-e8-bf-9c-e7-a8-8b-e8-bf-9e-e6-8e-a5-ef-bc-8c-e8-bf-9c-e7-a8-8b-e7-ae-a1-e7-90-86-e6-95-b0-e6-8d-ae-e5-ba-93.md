title: CentOS下开启mysql远程连接，远程管理数据库
id: 164
categories:
  - mysql
date: 2014-12-23 11:29:46
tags:
---

# CentOS下开启mysql远程连接，远程管理数据库

<div>

当服务器没有运行php、没装phpmyadmin的时候，远程管理[mysql](http://www.fantxi.com/blog/tag/mysql/ "mysql")就显得有必要了。因为在CentOS下设置的，所以标题加上了[CentOS](http://www.fantxi.com/blog/tag/CentOS/ "CentOS")，以下的命令在debian等系统下应该也OK。

1.  mysql -u root -p mysql # 第1个mysql是执行命令，第2个mysql是系统数据名称
在mysql控制台执行:

1.  grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;
2.  # root是用户名，%代表任意主机，'123456'指定的登录密码（这个和本地的root密码可以设置不同的，互不影响）
3.  flush privileges; # 重载系统权限
4.  exit;
允许3306端口

1.  iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
2.  # 查看规则是否生效
3.  iptables -L -n # 或者: service iptables status
4.5.  # 此时生产环境是不安全的，远程管理之后应该关闭端口，删除之前添加的规则
6.  iptables -D INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
PS，上面iptables添加/删除规则都是临时的，如果需要重启后也生效，需要保存修改:
service iptables save # 或者: /etc/init.d/iptables save
另外，
vi /etc/sysconfig/iptables # 加上下面这行规则也是可以的
-A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT

远程管理数据库的软件，win系统下可以使用SQLyog，用了几种远程软件，感觉这个用起来蛮不错的。

</div>