title: 小说系统SQL的一次优化
id: 106
categories:
  - mysql
date: 2014-12-03 17:41:29
tags:
---

业务背景： 将抓取站点书籍的所有来源站点全是404的书籍隐藏。

内网测试流程如下：

两个表：

| b_book_info | CREATE TABLE `b_book_info` (
`id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
`name` varchar(64) NOT NULL COMMENT '小说名称',
`is_free` tinyint(1) NOT NULL COMMENT '小说免费与否，请用数字表示，0：不免费，1：免费，2：部分章节免费；此处“免费”定义表示该小说无收费章节。',
`is_show` tinyint(1) DEFAULT '1' COMMENT '是否显示',
`node_id` int(11) NOT NULL DEFAULT '0',
`d_type` tinyint(4) DEFAULT '0' COMMENT '0为包含抓取数据，1为全抓取数据',
`has_d` tinyint(4) DEFAULT '0',
`d_id` int(11) DEFAULT '0',
PRIMARY KEY (`id`),
UNIQUE KEY `unique_name_author` (`name`,`author`),
KEY `index_view` (`view`),
KEY `index_words` (`num_of_words`),
KEY `index_auth` (`author`),
KEY `index_for_cate` (`category`,`is_finished`,`is_free`,`is_show`,`order_id`,`last_modify_time`),
KEY `ik_b_book_info_1` (`d_id`),
KEY `ik_b_book_info_0` (`has_d`,`d_update_time`),
KEY `index_category_is_show` (`category`,`is_show`,`order_id`,`last_modify_time`)
) ENGINE=InnoDB AUTO_INCREMENT=9653254 DEFAULT CHARSET=utf8

&nbsp;

| b_book_d_site | CREATE TABLE `b_book_d_site` (
`src` char(4) NOT NULL,
`book_id` int(11) NOT NULL,
`site_key` char(32) NOT NULL,
`site_name` varchar(32) NOT NULL,
`site_url` varchar(256) NOT NULL,
`http_code` char(3) NOT NULL DEFAULT '' COMMENT 'site_url的返回HTTP状态码',
PRIMARY KEY (`book_id`,`site_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 |

关联关系： b_book_info.d_id = b_book_d_site.book_id

下面的执行时间&gt;1min：

mysql&gt; explain select count(*) from b_book_info where d_id in( select book_id from (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d_site where s=0);
+----+--------------------+---------------+-------+---------------+------------------+---------+------+--------+--------------------------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+--------------------+---------------+-------+---------------+------------------+---------+------+--------+--------------------------+
| 1 | PRIMARY | b_book_info | index | NULL | ik_b_book_info_1 | 5 | NULL | 978201 | Using where; Using index |
| 2 | DEPENDENT SUBQUERY | &lt;derived3&gt; | ALL | NULL | NULL | NULL | NULL | 408345 | Using where |
| 3 | DERIVED | b_book_d_site | index | NULL | PRIMARY | 100 | NULL | 803251 | |
+----+--------------------+---------------+-------+---------------+------------------+---------+------+--------+--------------------------+
3 rows in set

&nbsp;

下面的可以执行时间在10s内：

mysql&gt; explain select id from b_book_info as z join (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id where s=0;
+----+-------------+---------------+-------+------------------+------------------+---------+-----------+--------+--------------------------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+-------------+---------------+-------+------------------+------------------+---------+-----------+--------+--------------------------+
| 1 | PRIMARY | &lt;derived2&gt; | ALL | NULL | NULL | NULL | NULL | 408345 | Using where |
| 1 | PRIMARY | z | ref | ik_b_book_info_1 | ik_b_book_info_1 | 5 | d.book_id | 1 | Using where; Using index |
| 2 | DERIVED | b_book_d_site | index | NULL | PRIMARY | 100 | NULL | 803251 | |
+----+-------------+---------------+-------+------------------+------------------+---------+-----------+--------+--------------------------+
3 rows in set

&nbsp;

mysql&gt; select count(*) from b_book_info as z join (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id where s=0 and z.d_type=1;
+----------+
| count(*) |
+----------+
| 108791 |
+----------+
1 row in set

&nbsp;

mysql&gt; update b_book_info set is_show=0 where id in(select z.id from b_book_info as z join (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id where d.s=0 and z.d_type=1);
1093 - You can't specify target table 'b_book_info' for update in FROM clause

&nbsp;

mysql&gt; update b_book_info as a inner join (select z.id from b_book_info as z join (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id where d.s=0 and z.d_type=1) as b on a.id=b.id set a.is_show=0;
Query OK, 6545 rows affected
Rows matched: 6545 Changed: 6545 Warnings: 0

&nbsp;

mysql&gt; explain
update b_book_info as a inner join (select z.id from b_book_info as z join (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id where d.s=0 and z.d_type=1) as b on a.id=b.id set a.is_show=0;
+----+-------------+---------------+--------+------------------+------------------+---------+-----------+--------+-------------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+-------------+---------------+--------+------------------+------------------+---------+-----------+--------+-------------+
| 1 | PRIMARY | &lt;derived2&gt; | ALL | NULL | NULL | NULL | NULL | 240960 | NULL |
| 1 | PRIMARY | a | eq_ref | PRIMARY | PRIMARY | 4 | b.id | 1 | NULL |
| 2 | DERIVED | &lt;derived3&gt; | ALL | NULL | NULL | NULL | NULL | 53546 | Using where |
| 2 | DERIVED | z | ref | ik_b_book_info_1 | ik_b_book_info_1 | 5 | d.book_id | 6 | Using where |
| 3 | DERIVED | b_book_d_site | index | PRIMARY | PRIMARY | 100 | NULL | 53546 | NULL |
+----+-------------+---------------+--------+------------------+------------------+---------+-----------+--------+-------------+
5 rows in set

&nbsp;

&nbsp;

mysql&gt; update b_book_info as z inner join (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id set z.is_show=1 where d.s=0 and z.d_type=1 ;
Query OK, 6545 rows affected
Rows matched: 6545 Changed: 6545 Warnings: 0

&nbsp;

mysql&gt; explain update b_book_info as z inner join (select book_id ,sum(http_code=200) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id set z.is_show=1 where d.s=0 and z.d_type=1 ;
+----+-------------+---------------+-------+------------------+------------------+---------+-----------+-------+-------------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+-------------+---------------+-------+------------------+------------------+---------+-----------+-------+-------------+
| 1 | PRIMARY | &lt;derived2&gt; | ALL | NULL | NULL | NULL | NULL | 53546 | Using where |
| 1 | PRIMARY | z | ref | ik_b_book_info_1 | ik_b_book_info_1 | 5 | d.book_id | 6 | Using where |
| 2 | DERIVED | b_book_d_site | index | PRIMARY | PRIMARY | 100 | NULL | 53546 | NULL |
+----+-------------+---------------+-------+------------------+------------------+---------+-----------+-------+-------------+
3 rows in set

&nbsp;