
### 概览
宽表排名第一。
DB排名第十。
百PB级别。几十TB 到 几十万TB。

### 写入
Cassandra 的删除都是修改，Cassandra 的修改都是写入，所以 Cassandra 只有写入和查询。
Tombstones删除，Timestamps修改，Compaction把墓碑数据真实移除，把时间戳比较老的数据移除，重新整理 SSTable 的存储文件等，类似DB2的REORG。

WAL->Memtables->Caches->SSTables->Hints
Cassandra在 Memtable 上纯粹的做追加写入，没有锁冲突、无需找上锁的记录。快的核心。
慢： INSERT IF NOT EXIST 或 WHERE IF Column = ‘*’ 

### 读取
受限的列存储数据库。不彻底在哪里？大部分的列存储数据库，都是为了 OLAP 而生的，它的优势在于，在某一列上做聚合的性能无语伦比。
在任何一列上做全列级的聚合，那简直是灾难性的。
在 OLTP 系统里，通过主键做单条记录的快速查询（Select by Key），这也正是 Cassandra 最为常见的 CQL 形态。
Select 语句，Where 条件里，一定要送 Partition Key（没有次索引的情况）。如果不送，则语法上必须要添加 ALLOW FILTERING。

Row Caches->Key Caches->Memtables->SSTables->Row Caches

SSTable
Filter.db 这是 SSTable 的 Bloom 过滤器
Summary.db，这里是索引的抽样，用来加速读取的。
Index.db，提供 Data.db 里的行列偏移量。
CompressionInfo.db 提供有关 Data.db 文件压缩的元数据。
Data.db 是存储实际数据的文件，是 Cassandra 备份机制保留的唯一文件。
Statistics.db 存储 nodetool tablehistograms 命令使用的有关 SSTable 的统计信息。
TOC.txt 列出此 SSTable 的文件组件。

Cassandra 的一个重要精华所在，那就是没有锁，或者叫没有资源上的冲突和争抢。通过 Timestamps 概念，解决数据可相同 Key 数据不要上锁的问题。

W+R>RF W—写一致性级别 R—读一致性级别 RF—副本数
损有余而补不足
数据的复制因子，是定义在 Keyspace，也就是在存储方面决定。而读取的一致性，是由客户端决定的。

### 优劣
没办法保证一条记录行级别的一致性。
还有一个缺点是 Cassandra 普遍适用的场景非常有限，Cassandra 虽然对于单行操作非常快，但是对于多行操作就会非常慢；而且不仅仅慢，很可能同时消耗的资源也会很高。
通常来说 Cassandra 应用的场景适合只访问单行记录的，但是在单行记录的时候却不能保证行级别的一致性。

### 参考
- https://www.infoq.cn/article/j0mfq1cntskbk5rbdpvl
