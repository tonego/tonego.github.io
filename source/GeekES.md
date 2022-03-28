-- 《86-Elasticsearch核心技术与实战》
 
### 写数据 https://segmentfault.com/a/1190000015256970
buffer - OS cache - segment file 
translog 类似redolog
segment的四个核心概念，refresh，flush，translog、merge



filesystem cache。 尽量让内存可以容纳所有的index segment file 索引数据文件
数据预热
冷热分离

document的模型设计
分页性能优化
### 01 | 课程介绍
### 02 | 内容综述及学习建议
### 03 | Elasticsearch简介及其发展历史
### 04 | Elastic Stack家族成员及其应用场景
### 05 | Elasticsearch的安装与简单配置
### 06 | Kibana的安装与界面快速浏览
### 07 | 在Docker容器中运行Elasticsearch Kibana和Cerebro
### 08 | Logstash安装与导入数据
### 09 | 基本概念：索引、文档和REST API
### 10 | 基本概念：节点、集群、分片及副本
### 11 | 文档的基本CRUD与批量操作
### 12 | 倒排索引介绍
### 13 | 通过Analyzer进行分词
### 14 | Search API概览
### 15 | URI Search详解
### 16 | Request Body与Query DSL简介
### 17 | Query String&Simple Query String查询
### 18 | Dynamic Mapping和常见字段类型
### 19 | 显式Mapping设置与常见参数介绍
### 20 | 多字段特性及Mapping中配置自定义Analyzer
### 21 | Index Template和Dynamic Template
### 22 | Elasticsearch聚合分析简介
### 23 | 第一部分总结
### 24 | 基于词项和基于全文的搜索
### 25 | 结构化搜索
### 26 | 搜索的相关性算分
### 27 | Query&Filtering与多字符串多字段查询
### 28 | 单字符串多字段查询：Dis Max Query
### 29 | 单字符串多字段查询：Multi Match
### 30 | 多语言及中文分词与检索
### 31 | Space Jam，一次全文搜索的实例
### 32 | 使用Search Template和Index Alias查询
### 33 | 综合排序：Function Score Query优化算分
### 34 | Term&Phrase Suggester
### 35 | 自动补全与基于上下文的提示
### 36 | 配置跨集群搜索
### 37 | 集群分布式模型及选主与脑裂问题
### 38 | 分片与集群的故障转移
### 39 | 文档分布式存储
### 40 | 分片及其生命周期
### 41 | 剖析分布式查询及相关性算分
### 42 | 排序及Doc Values&Fielddata
### 43 | 分页与遍历：From, Size, Search After & Scroll API
### 44 | 处理并发读写操作
### 45 | Bucket & Metric聚合分析及嵌套聚合
### 46 | Pipeline聚合分析
### 47 | 作用范围与排序
### 48 | 聚合分析的原理及精准度问题
### 49 | 对象及Nested对象
### 50 | 文档的父子关系
### 51 | Update By Query & Reindex API
### 52 | Ingest Pipeline & Painless Script
### 53 | Elasticsearch数据建模实例
### 54 | Elasticsearch数据建模最佳实践
### 55 | 第二部分总结回顾
### 56 | 集群身份认证与用户鉴权
### 57 | 集群内部安全通信
### 58 | 集群与外部间的安全通信
### 59 | 常见的集群部署方式
### 60 | Hot & Warm架构与Shard Filtering
### 61 | 分片设计及管理
### 62 | 如何对集群进行容量规划
### 63 | 在私有云上管理Elasticsearch集群的一些方法
### 64 | 在公有云上管理与部署Elasticsearch集群
### 65 | 生产环境常用配置与上线清单
### 66 | 监控Elasticsearch集群
### 67 | 诊断集群的潜在问题
### 68 | 解决集群Yellow与Red的问题
### 69 | 提升集群写性能
### 70 | 提升集群读性能
### 71 | 集群压力测试
### 72 | 段合并优化及注意事项
### 73 | 缓存及使用Breaker限制内存使用
### 74 | 一些运维的相关建议
### 75 | 使用Shrink与Rollover API有效管理时间序列索引
### 76 | 索引全生命周期管理及工具介绍
### 77 | Logstash入门及架构介绍
### 78 | 利用JDBC插件导入数据到Elasticsearch
### 79 | Beats介绍
### 80 | 使用Index Pattern配置数据
### 81 | 使用Kibana Discover探索数据
### 82 | 基本可视化组件介绍
### 83 | 构建Dashboard
### 84 | 用Monitoring和Alerting监控Elasticsearch集群
### 85 | 用APM进行程序性能监控
### 86 | 用机器学习实现时序数据的异常检测（上）
### 87 | 用机器学习实现时序数据的异常检测（下）
### 88 | 用ELK进行日志管理
### 89 | 用Canvas做数据演示
### 90 | 项目需求分析及架构设计
### 91 | 将电影数据导入Elasticsearch
### 92 | 搭建你的电影搜索服务
### 93 | 需求分析及架构设计
### 94 | 数据Extract & Enrichment
### 95 | 构建Insights Dashboard
### 96 | Elastic认证介绍
### 97 | 考点梳理
### 98 | 集群数据备份
### 99 | 基于Java和Elasticseach构建应用
### 100 | 结课测试&结束语