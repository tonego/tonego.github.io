title: 小说系统索引优化案例
id: 312
categories:
  - mysql
date: 2015-03-12 08:55:03
tags:
---

小说系统索引优化案例

&nbsp;

表以及索引结构如下：

b_book_info | CREATE TABLE `b_book_info` (
`id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
`name` varchar(64) NOT NULL COMMENT '小说名称',
`provider_id` int(11) NOT NULL COMMENT '内容提供商id，对应 b_book_provider 的 id',
`big_image` char(32) NOT NULL DEFAULT '',
`big_image_url` varchar(256) NOT NULL COMMENT '小说的大图，尺寸200×250，以http开头',
`small_image` char(32) NOT NULL DEFAULT '',
`small_image_url` varchar(256) NOT NULL COMMENT '小说的小图，尺寸112×155，以http开头',
`list_url` varchar(256) NOT NULL COMMENT '小说全部目录链接，以http开头',
`read_url` varchar(256) NOT NULL COMMENT '小说阅读链接地址',
`category` varchar(64) NOT NULL COMMENT '小说分类，要求必须在以下分类中选择，如果不在将不会被收录。玄幻奇幻/武侠仙侠/都市言情/历史军事/游戏竞技/穿越时空/古代言情/总裁豪门/青春校园/耽美同人',
`category_url` varchar(256) NOT NULL COMMENT '小说分类链接，匹配站点对应分类，例如小说属于玄幻，匹配金山的分类为玄幻奇幻，对应的分类链接依然为站点玄幻分类链接。',
`num_of_words` int(8) NOT NULL COMMENT '小说字数',
`is_finished` tinyint(1) NOT NULL COMMENT '小说状态，请给定数字表示，1：连载中，2：已完结',
`summary` varchar(1024) NOT NULL COMMENT '小说简介 最多1024中英文字符',
`author` varchar(64) NOT NULL COMMENT '小说作者',
`author_url` varchar(256) NOT NULL COMMENT '小说作者列表页',
`last_update_time` varchar(32) NOT NULL COMMENT '小说最近更新时间，格式为YYYY-MM-DD hh:mm',
`view` int(11) NOT NULL COMMENT '小说阅读次数',
`is_free` tinyint(1) NOT NULL COMMENT '小说免费与否，请用数字表示，0：不免费，1：免费，2：部分章节免费；此处“免费”定义表示该小说无收费章节。',
`is_show` tinyint(1) DEFAULT '1' COMMENT '是否显示',
`order_id` int(8) DEFAULT '1000',
`last_modify_time` int(11) DEFAULT NULL,
`hot` int(11) DEFAULT '0' COMMENT '本站统计的点击量，非供应商提供',
`node_id` int(11) NOT NULL DEFAULT '0',
`d_type` tinyint(4) DEFAULT '0',
`has_d` tinyint(4) DEFAULT '0',
`d_id` int(11) DEFAULT '0',
`d_src` char(4) DEFAULT '',
`d_node_id` int(11) NOT NULL DEFAULT '0',
`d_update_time` int(11) DEFAULT '0',
`d_modify_time` int(11) NOT NULL DEFAULT '0',
PRIMARY KEY (`id`),
UNIQUE KEY `unique_name_author` (`name`,`author`),
KEY `index_view` (`view`),
KEY `index_words` (`num_of_words`),
KEY `index_auth` (`author`),
KEY `index_for_cate` (`category`,`is_finished`,`is_free`,`is_show`,`order_id`,`last_modify_time`),
KEY `ik_b_book_info_1` (`d_id`),
KEY `ik_b_book_info_0` (`has_d`,`d_update_time`),
KEY `index_category_is_show` (`category`,`is_show`,`order_id`,`last_modify_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1003325 DEFAULT CHARSET=utf8 |

&nbsp;

案例一： 在复合索引中，查询条件对第一列没有要求，可以用in代替用来用到索引：

mysql&gt; explain select name,author from b_book_info where has_d in(0,1) and d_update_time&gt;0 limit 1;
+----+-------------+-------------+-------+------------------+------------------+---------+------+--------+-------------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+-------------+-------------+-------+------------------+------------------+---------+------+--------+-------------+
| 1 | SIMPLE | b_book_info | range | ik_b_book_info_0 | ik_b_book_info_0 | 7 | NULL | 467536 | Using where |
+----+-------------+-------------+-------+------------------+------------------+---------+------+--------+-------------+
1 row in set

mysql&gt; explain select name,author from b_book_info where d_update_time&gt;0 limit 1;
+----+-------------+-------------+------+---------------+------+---------+------+--------+-------------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+-------------+-------------+------+---------------+------+---------+------+--------+-------------+
| 1 | SIMPLE | b_book_info | ALL | NULL | NULL | NULL | NULL | 935071 | Using where |
+----+-------------+-------------+------+---------------+------+---------+------+--------+-------------+
1 row in set

再次通过profile来验证，他们两个执行时间并无多大差别。我想可能是因为has_d的选择性太低，索引扫描会影响磁盘顺序扫描。

而且他们的执行结果也有差别，这个的原因可能是索引的排列顺序和物理列的排列顺序不同所导致的吧。

&nbsp;

&nbsp;

&nbsp;