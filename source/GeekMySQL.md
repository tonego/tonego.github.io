-- 《MySQL实战45讲》 -丁奇

#### 1. SQL查询执行过程

 连接器(权限、连接) - 查询缓存 - 分析器（词法、语法）- 优化器 - 执行器 - 引擎层 
 
###### 连接器

 wait_timeout 8h, Lose connection to MySQL server during query
 
 长连接内存占用大
 * 定期断开
 * mysql_reset_connection (无需重连、权限验证)
 
###### 查询缓存
  
 往往弊大于利
 * 失效频繁，一个更新，全表失效。 适用于静态配置表
 * SET query_cache_type=DEMAND; SELECT SQL_CACHE * FROM table;
 * MySQL 8.0 已删
 
###### 执行器

 表权限校验

#### 13. 表数据空间优化（数据删除空间不变）

  表结构定义在.frm或系统数据表(>8.0)
  
  innodb_file_per_table OFF(系统共享表空间) 默认ON(.idb文件)
 
  数据页的复用和记录的复用，
  
  重建表 alter table A engine=InnoDB(<5.5,DDL非ONLINE)，Online DDL用row log实现
  
  Online DDL读锁，有一定性能开销，gh-ost开源库方案
  
  Online和inplace
  
  tmp_table在server层创建copy的过程，tmp_file是InnoDB内部的inplace操作。
  
  Online一定是inplace的；inplace（FULLTEXT index、SPATIAL index）会堵塞增删改，非Online
  
  Optimize（recreate+analyze）、analyze（MDL读锁、索引的重新统计）、alter（recreate，每个列留1/16预留更新）
  
  **varchar类型占用多大空间**
  
#### 14 count(*)的优化

  为什么InnoDB不能像MyISAM一样把count数存起来，因为有MVCC的实现
  
  通过选择小的索引树、减少扫描数据量优化count
  
  TABLE_ROWS的count有45±5%的误差
  
  性能 count(*) >= count(1) > count(id) > count(field_null_def)
  
#### 15 日志和索引一些问题

  1. binlog完整, statement有COMMIT, row有XID event
  2. redo log 和 binlog 通过XID关联
  3. redo log(pre)+binlog恢复。 binlog会被从库失败无法回滚，故只能提交redo log
  4. 两阶段提交。事务持久性问题。 若提交redo log->提交binlog， 回滚redo log会覆盖其他事务更新
  5. binlog不支持崩溃恢复。 没能力恢复"数据页"
  6. binlog还用于归档，主从等，生态能力是需要的
  7. redo log 4*1G
  8. buffer pool 进行最终数据落盘
  9. redo log buffer -> .ib_logfile4
  
  事务尽量先insert再update，避免行锁时间过长
  
  update set val=old_val, 0 rows affected 是真正去执行了的。
   
#### 16 order by的执行逻辑

  sort_buffer_size 不够用使用外部排序是用的归并排序，比如num_of_tmp_files=12,sort_mode~=packed_additional_fields表示对varchar做紧凑处理
  
  SET optimizer_trace='enabled=on';
  
  SET max_length_for_sort_data = xxx;
  
  setmode~=rowid排序多访问了一次主键索引, examined_rows+=limit
  
  优先选择全字段排序，当sort_buffer_size不够大或行数据大于max_length_for_sort_data 才选择 rowid排序
  
  MySQL的一个设计思想:如果内存够,就要多利用内存,尽量减少磁盘访问。
  
#### 17 order by rand()

  SELECT city,name,age WHERE city="x" ORDER BY rand(); 
    * idx(city)->pk(id)->sort_buffer(city name age)-> sort_buffer(全字段排序)->resp
    * idx(city)->pk(id)->sort_buffer(name id)-> sort_buffer(order)->pk(rowid排序)->resp
  SELECT word ORDER BY rand() LIMIT 3; count(*)=1w
  内存临时表 engine=Memory, rowid排序, tmp_table_size=16M, 
    * table(id,word)->内存临时表(R,W),1w扫描->sort_buffer(R,pos),1w扫描->rowid排序(R,pos)->映射内存临时表(R,W)->结果集(word),3扫描
  磁盘临时表
    * internal_tmp_disk_storage_engine=InnoDB
    * tmp_table_size/sort_buffer_size/max_length_for_sort_data 
    * 优先队列排序算法(>5.6)。 
    * OPTIMIZER_TRACE.filesort_priority_queue_optimization.chosen=true,num_of_tmp_files=0,set_mode=rowid
    ** 磁盘临时表的执行流程是怎样的呢 ** 
  随机法： 表行数>limit randn,1;  where id>randn limit 1;  
  
  ** 为何limit 10000,100 要改为 limit 10100 **
  
#### 18 SQL的列计算

  条件字段函数操作(全索引扫描)，隐式类型转换，隐式编码转换(有join可能的表统一使用utf8mb4)
  
  WHERE id+1=11 不能被自动转换为 WHERE id=11-1
  
#### 19 SELECT慢的原因

  有MDL锁(Waiting for table metadata lock);
  
  等flush(Waiting for table flush);
  
  等行锁(lock in share mode)
  
  sys.schema_table_lock_waits, sys.innodb_lock_waits, information_schema.processlist, set long_query_time=0

  查询慢: undo log 过大;
  
#### 20 幻读

  WHERE d=5 for update; 当前读、
  
  幻读指的是一个事务在前后两次查询同一个范围的时候,后一次查询看到了前一次查询没有看到的行。当前读、新插入行。
  
  假设对d=5加行锁. 语义错误(未把d=5的行锁住)、数据一致性问题(UPDATE WHERE d=5之后其他事务新加的d=5在binlog会被错误的更新)
  
  ** 问题根本在于update并不是在最终commit时执行的，能否把binlog的执行时机改正确解决这个问题？ **
  
  假设对所有行加行锁. 由于不存在的行无法加锁，依旧存在单行加锁一样的问题。
  
  Gap间隙锁和行锁合称next-key lock,每个next-key lock是前开后闭区间, 执行先间隙锁再行锁。
  
  insert on duplicate key update 的事务实现，多个事务的间隙锁会造成死锁，间隙锁影响了并发度。
  
  读提交、binlog=row, 无幻读问题
  
#### 21  update的锁

###### 加锁总结

  1. 原则1:加锁的基本单位是next-key lock，前开后闭区间。
  2. 原则2:查找过程中访问到的对象才会加锁。
  3. 优化1:索引上的等值查询,给唯一索引加锁的时候,next-key lock退化为行锁。
  4. 优化2:索引上的等值查询,向右遍历时且最后一个值不满足等值条件的时候,next-key lock退化为间隙锁。
  5. 一个bug:唯一索引上的范围查询会访问到不满足条件的第一个值为止。
 
 
###### 加锁案例
  1. 等值查询间隙锁
  2. 非唯一索引等值锁。 锁是加在索引上的。 需避免lock in share mode只锁覆盖索引, for update 会给主键索引上加行锁
  3. 主键索引范围锁
  4. 非唯一索引范围锁
  5. 唯一索引范围锁bug
  6. 非唯一索引存在等值的例子
  7. limit语句加锁. 再删除数据的时候尽量加limit
  8. 一个死锁的例子
  
#### 22 临时提高性能
  1. timewait设短；show processlist -> information_schema.innodb_trx.trx_mysql_thread_id -> kill {id}
  2. -skip-grant-tables. 8.0自动加--skip-networking(只允许local连接)
  3. gh-ost Online DDL 加索引
  4. insert query_rewrite.rewrite_rules force_index; call query_rewrite.flush_rewrite_rules(); 
     开发阶段应set long_query_time=0查rows_examined是否预期， 查general log 
  5. IP白名单、user用户权限、query_rewrite 
     
#### 23 binlog/relog可靠性
  
  binlog cache(thread) ->write binlog files(fs page cache) -> fsync disk
  
  binlog_cache_size/sync_binlog=1(1fsync,500±400重启丢失,IOPS++)
  
  redo log buffer -> write fs page cache -> fsync disk
  
  innodb_flush_log_at_trx_commit=1(fsync), 
   
  未提交事务也会落盘: bg thread write&fsync/per 1s; buffer>=innodb_log_buffer_size/2; 并行事务提交顺带落盘;
  
  双1配置: redo log pre fsync, commit write; binlog fsync
  
  group commit: LSN+=length, TPS, IOPS
  
  redo log pre: write -> binlog: write -> redo log pre: fsync -> binlog: fsync -> redo log commit:write
  
  binlog_group_commit_sync_delay / binlog_group_commit_sync_no_delay_count 增加语句响应时间
  
  WAL: 顺序写、组提交
  
  一些问题
  *  update语句完成，hexdump打印的idb文件看不到改变，原因是 仅保证写完了 redo log 和 内存，未写到磁盘
  *  binlog cache 每线程自己维护, redo log buffer 全局共用。 原因是 binlog不能被打断
 
#### 24 主备

  start -> undo log(mem) -> data(mem) -> redo log(prepare) -> bin log -> dump thread -> io thread -> relay log -> sql_thread->  data
  
  binlog_format: statement(delete limit 选错索引会不一致),  row(delete 10w占空间,恢复方便), mixed()
  
  now()被转换为set timestamp的statement语句； mysqlbinlog 的statement语句执行不能拷贝出来执行， 因为有上下文的存在。
  
  循环复制问题， log_slave_updates=on(relay log 后生成 binlog) 源server_id保存判断，类trace_id源头生成。 
  数据迁移时， 三节点复制场景， 会出现双M的循环复制
  
#### 25 高可用

  主备延迟: 从库配置低、备库压力大、大事务、大表DDL。 seconds_behind_master(show slave status)。
  
  可靠性优先。 等备库seconds_behind_master足够小 -> 主库readonly=true -> 等备库seconds_behind_master变为0 -> 备库readonly=false -> 业务请求到B
  
  可用性优先。row格式报错(比如 duplicate key error), mixed/statement数据悄悄的不一致了
  
  
#### 26 备库并行复制

  并行复制 slave_parallel_workers = 12±4(32核CPU)
  
  原则： 一个事务、同一行的多个事务 必须在一个worker
  
  5.5按表。coordinator维护一个hash表(worker)复制的table，出现冲突进行转移。
  
  5.5按行。CPU内存占用大。 hashtable.key(db.table.idx.val), row格式、有PK、无FK，超行数阈值退化单线程
  
  5.6按库。 分库的好处之一。
  
  MariaDB按commit_id(group_commit)。 必须有序按照组提交顺序来，吞吐量不够，大事务资源浪费严重
  
  5.7 slave_parallel_type=LOGICAL_CLOCK(类组提交. 处于>=pre的多个事务可以并行; group_commit两参数使主库慢备库快)/DATABASE. 
  
  5.7.22 binlog-transaction-dependency-tracking=COMMIT_ORDER(LOGICAL_CLOCK)/WRITESET(按行，主库生成，binlog升级，备库不解，可非row)/WRITESET_SESSION
 
  主库单线程压力模型，从库设置WRITESET模式。因为无组提交commit_id每事务不同，其他模式都只能按序单线程
  
  
#### 27 主备切换

  位点。 MASTER_LOG_FILE/MASTER_LOG_POS, 
  
  找往前的. sql_slave_skip_counter, slave_skip_errors=1032,1062
  
  GTID(>=5.6). server_uuid:gno(source_id:transaction_id). gtid_mode=on, enforce_gtid_consistency=on
  
  gtid_next=automatic, SET @@SESSION.GTID_NEXT=‘server_uuid:gno’; set gtid_next='aaaaaaaa-cccc-dddd-eeee-ffffffffffff:10';
  
  GTID主备切换, master_auto_position=1, 集合差集
  
  GTID和Online DDL. 
  
 
#### 28 读写分离过期读
 
  客户端直连方案(基于zk/eted); proxy方案
 
  过期读。
  * 强制走主库方案；
  * sleep方案(由前端ajax延迟实现)；
  * 判断主备无延迟方案；slave status主备的 seconds_behind_master; 点位:File/Pos; GTID集合:Gtid_Set.
  * 配合semi-sync方案；半同步复制类似raft得到从库响应才算成功,依旧不支持多从和持续延迟问题
  * 等主库位点方案。select master_pos_wait(file, pos[, timeout]);
  * 等GTID方案。select wait_for_executed_gtid_set(gtid_set, 1); master的GTID随事务返回(>=5.7.6);
  set session_track_gtids=OWN_GTID; mysql_session_track_get_first()
  
   
#### 29 健康检查
 
   把innodb_thread_concurrency设置为64~128之间的值
   
   在线程进入锁等待以后，并发线程的计数会减一，也就是说等行锁（也包括间隙锁）的线程是不算在128里面的。
   
   查表，select * from mysql.health_check; 更新，update mysql.health_check set t_modified=now();
   
   考虑主备，外包统计判定慢，insert into mysql.health_check(id, t_modified) values (@@server_id, now()) on duplicate key update t_modified=now();
   
   内部统计， 打开监控， mysql> update setup_instruments set ENABLED='YES', Timed='YES' where name like '%wait/io/file/innodb/innodb_log_file%';
   
   查异常(皮秒)，mysql> select event_name,MAX_TIMER_WAIT  FROM performance_schema.file_summary_by_event_name 
     where event_name in ('wait/io/file/innodb/innodb_log_file','wait/io/file/sql/binlog') and MAX_TIMER_WAIT>200*1000000000;
     
#### 30 动态观点看锁,21章补充
   
   死锁现场: show engine innodb status, LATESTDETECTED DEADLOCK  
   
   所谓“间隙”，其实根本就是由“这个间隙右边的那个记录”定义的
   
#### 31 误删数据处理

  sql_safe_updates=on, 无where/非idx条件报错
  
  delete可以用Flashback(确保binlog_format=row 和 binlog_row_image=FULL)来恢复
  
  延迟复制备库(>5.6). CHANGE MASTER TO MASTER_DELAY = N
  
  预防： 账号权限； 先改表名加后缀（_to_be_deleted)，
  
#### 32. kill query/connection

  逻辑：killed=THD::KILL_QUERY; 信号给线程; 程序判断埋点进行终止.

  kill无效: 线程没有执行到判断线程状态的逻辑(埋点读信号); 终止逻辑耗时较长; 
  
  停等协议，客户端Ctrl+C自动有新连接kill query; 
  
  表多连接慢，是因为客户端在构建一个本地的哈希表并非连接慢（-A 关闭）
  
  –quick 客户端快。 用mysql_use_result非mysql_store_result； 无表明补全； 无本地历史
  
#### 33. buffer pool

  流程：net_buffer;满了网络发; 清空重新写, 若socket send buffer满(EAGAIN或WSAEWOULDBLOCK)等后发
  
  MySQL是“边读边发的”， (net_buffer_length=16k) /proc/sys/net/core/wmem_default Sending to client
  
  查询的返回结果不会很多的话，我都建议你使用mysql_store_result这个接口，直接把查询结果保存到本地内存
  
  “Sending data”是正在执行，从查询语句进入执行阶段后开始，非“正在发送数据”
  
  innodb status -> Buffer pool hit rate > 99%
  
  innodb_buffer_pool_size 可用物理内存的60%~80%; LRU; 
  
  5:3=young:old(类全表扫描不影响young): 新进old,时段内多次访问进young(innodb_old_blocks_time=1000)
  
  
  