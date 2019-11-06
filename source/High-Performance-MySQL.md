-- 《高性能MySQL》 -宁海元译

### 5. 索引
前缀索引, 更小更快，但无法做ORDER/GROUP/覆盖扫描,选择性问题, SELECT COUNT(DISNINCT LEFT(field,5))/COUNT(\*)
多列索引, 顺序问题,选择性高的列放前， 单列多索引>v5.0索引合并策略(OR/AND)说明索引没建好, Extra(Using union(idx_x1,idx_x2))
聚簇索引，大小问题. 叶子页中. 若无主键会隐式创建, 主键顺序插入否则optimize table
非聚簇索引（二级索引）保存指针，需要二次查询, InnoDB二级索引保存主键值,虽大但避免了行移动/页分裂造成的二级索引维护工作
覆盖索引,Extra(Using index); 子查询覆盖索引优化limit问题
压缩索引，
冗余重复索引, 应该移除
自适应哈希索引
where urlcrc=crc32("http://xxx.com") and url="http://xxx.com"
crc32() FNV64()
全文索引、覆盖索引、分形树索引、
索引优点：扫描数量；避免排序临时表；顺序IO
查询条件中索引列不能运算
Extra(Using Where)说明存储引擎返回了结果后再做的过滤
string类型字段若select按照int查询用不到索引
