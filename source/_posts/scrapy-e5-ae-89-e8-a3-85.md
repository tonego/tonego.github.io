title: scrapy 安装
id: 153
categories:
  - python
date: 2014-12-23 11:22:05
tags:
---

根据scrapy的文档上安装:sudo easy_install -U Scrapy

安装过程中提示

NOTE: Trying to build without Cython, pre-generated 'src/lxml/lxml.etree.c' needs to be available.
ERROR: /bin/sh: xslt-config: not found

** make sure the development packages of libxml2 and libxslt are installed **

Using build configuration of libxslt
src/lxml/lxml.etree.c:4: fatal error: Python.h: 没有那个文件或目录
compilation terminated.
error: Setup script exited with error: command 'gcc' failed with exit status 1

经过google查询得知没有安装libxml2-dev和libxlst1-dev

为保险起见，请依次安装如下：

sudo apt-get install gcc

sudo apt-get install python-dev

sudo apt-get install libxml2 libxml2-dev

sudo apt-get install libxslt1.1 libxslt1-dev

后面的是数字1，不是字母l,不要写错了。

然后再次运行sudo easy_install -U Scrapy

成功。