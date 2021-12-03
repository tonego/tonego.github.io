-- 《MySQL实战45讲》 -丁奇
 
 [原文](https://time.geekbang.org/column/intro/139) 
 
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
 
#### 2. update执行流程

  物理重做日志redo log: 引擎层, crash-safe, innodb_flush_log_at_trx_commit=1, WAL Write-Ahead Logging, 4x1G, 循环写: write_pos,checkpoint; 
  
  逻辑归档日志binlog: server层, sync_binlog=1, 追加写
  
  exec: 2PC; 执行器先找引擎取值(内存中取或磁盘读入内存)->执行器改数->引擎层写内存+redo log->执行器binlog写磁盘->引擎层redo log commit
  
  _非update v=v+1为何要先取数再改数而不能直接改？引擎api不支持吗还是说undo log要写整行？ 大概update v=2无需先取，因为change buffer机制存在_

#### 3. 事务隔离级别现象和实现

  ACID I; dirty/non-repeatable/phantom read;  transaction_isolation
  
  read uncommitted. 无需视图
  
  read committed. sql执行前视图
  
  repeatable read. 事务开始前视图。 适用数据校对应用场景。
  
  serializable. 锁实现
  
  s1.begin, s1.select, s2.begin, s2.select, s2.update, s1.select(read uncommitted), s2.commit, s1.select(read committed), s1.commit, s1.select(repeatable read);
  
  MVCC; undo log; read-view回滚实现; 长事务影响; 
  
  begin/start transaction; set autocommit=1; commit work and chain 省begin开销;
  
  查长事务。select * from information_schema.innodb_trx where TIME_TO_SEC(timediff(now(),trx_started))>60
  
  autocommit/MAX_EXECUTION_TIME; 监控 information_schema.Innodb_trx; Percona的pt-kill; 开general_log; innodb_undo_tablespaces=2(>5.6);

#### 4. 索引1
  
  哈希表、有序数组和搜索树; N叉树、跳表、LSM树;
  
  主键索引也被称为聚簇索引（clustered index）
  
  非主键索引也被称为二级索引（secondary index）
  
  树高3算法.  (Page16KB/(PK4B+Ptr6B+Oth6B=16B))^(No-leaf-High=2) *(16KB/100B=160) = 1.6亿
  
  索引维护. 页分裂; 数据页的利用率; 主键小普通索引就小; 无二级索引且值唯一的业务列可作主键; 
  
#### 5. 索引2
  
  覆盖索引无需回表. 
  
  最左前缀. like '张%'可用索引. 
  
  索引下推.index condition pushdown(>5.6). 减少回表次数. idx(name,age), where name like '张%' and age=10.
  
  重建索引：alter table T engine=InnoDB
  
#### 6. 全局锁表锁
  
  全局锁. Flush tables with read lock (FTWRL). 堵塞修改,整库只读. 全库逻辑备份. 不用 set global readonly=true
  
  mysqldump –single-transaction 使用MVCC视图方式避免全局锁. 仅限事务引擎. 
  
  表锁. lock tables … read/write;unlock tables;
  
  元数据锁（meta data lock，MDL). 非显式使用. >5.5.  对表增删改查先MDL读锁. 
  
  小表加字段也危险. 之前任何SQL持有着MDL读锁, 之后锁所有sql, cli重试, 线程打满, 雪崩. 用 DDL NOWAIT/WAIT n 语法(MariaDB)
  
  从库mysqldump过程中主库alter表. START TRANSACTION  WITH CONSISTENT SNAPSHOT; SAVEPOINT sp;  show create table `t1`;SELECT * FROM `t1`;ROLLBACK TO SAVEPOINT sp;
  
  _5.6不是已经有Online DDL了吗，为何还是MDL写锁呢，不应该是DML读锁吗？ 实际上有短暂的MDL写锁，数据拷贝过程已经降级为读锁_
  
#### 7. 行锁
  
  两阶段锁协议。事务提交后释放锁。 影响并发度的锁的申请时机尽量往后放, 影院余额扣减放最后
  
  死锁和死锁检测。 innodb_lock_wait_timeout=50s、innodb_deadlock_detect=on 
  
  检测吃CPU。关闭检测; 控制访问相同资源的并发事务量,对于相同行的更新，在进入引擎之前排队; 业务拆分处理，比如余额拆10个账户
  
  由热点行更新导致的性能问题：假设有1000个并发线程要同时更新同一行，那么死锁检测操作就是100万这个量级的。
  
  案例: 一个连接中循环执行多次limit更新操作更友好
  
#### 8. 事务隔离 ※ 
  
  视图: view(create view...) / consistent read view(RC/RR). 
  
  快照在MVCC: row trx_id=transaction id. 
  
  每个事务构造数组保存事务ID; 视图数组和高水位组成read view.
  
  数据版本的可见性: row trx_id对比一致性视图; *为何用数组？因为read view是整库的，黄区存在已提交的快事务。*
  
  当前读（current read）: 更新数据都是先读后写的，而这个读，只能读当前的值。读锁（S锁，共享锁，lock in share mode) 、写锁（X锁，排他锁，for update）

  表结构不支持“可重复读”？这是因为表结构在frm, 没有对应的行数据，也没有row trx_id，因此只能遵循当前读的逻辑。

  MVCC实现: DB_TRX_ID,DB_ROLL_PTR,DB_ROW_ID, undo log, Read View.undo log是链表，节点被purge线程清除。
  
  _低水位有误导性，小于当前trx_id的分已未提交的两类更易理解_
  
#### 9. 唯一索引  ※ 
  
  等值查询仅少扫描一行，16KB页读入内存，读下一行只需要一次指针寻找和一次计算
  
  将change buffer（insert buffer）中的操作应用到原数据页，得到最新结果的过程称为merge. purge.
  
  唯一索引的更新不能使用change buffer
  
  innodb_change_buffer_max_size=50, 占buffer pool的50%
  
  若记录要更新的目标页若在内存直接改pool buffer;若不在内存中，需要将数据页读入内存（高成本随机IO），判断冲突； 而普通索引直接更新change buffer； 
  
  适用于写多读少; 不适用写入之后马上查询的场景.
  
  对更新性能. redo log WAL主要节省的是随机写磁盘的IO消耗（转成顺序写），而change buffer主要节省的则是随机读磁盘的IO消耗。
  
  案例. insert一行内存数一行非内存数, 写入两次内存+一次磁盘. 内存/redo log(ib_log_fileX)/数据表空间(t.ibd)/系统表空间(ibdata1)
  
  数据以buffer pool为准，若没在内存，合并磁盘+change buffer数据.  
  
  merge过程: 磁盘读入内存; change buffer 记录应用; 写 redo log .  redo log包含了数据的变更和change buffer的变更
  
  主键都是唯一索引也都用不到change buffer. 只有普通索引才会用到.  _那是每个索引一个change buffer?  多索引数据怎么一致性的呢？_ 
  
  _先写的IBUFF后写的redo log pre吗？ commit或rollback再找到这个trx_id对应的记录进行操作？_
  
#### 10. 查询优化器 
  
  扫描行数. show index from t; cardinality; 
  
  采样. N个数据页的平均记录数*页面数. 数据行数超过1/M重新统计
  
  innodb_stats_persistent=on,n=20,m=10; off,n=8,m=16;
  
  扫描行数&是否回表&避免排序 影响优化器;analyze; force index; "order by b limit 1” 改成 “order by b,a limit 1”; 修改索引
  
  _为何 order by a,b 不能用索引?_
  
#### 11. 字符串索引

  前缀索引。 count(distinct email)， 节省空间、成本低；会增加扫描行数， 无法使用覆盖索引 。
  
  倒序。 hash列。
  
#### 12. 刷脏页, 抖一下
  
  场景: redo log 写满, 堵塞所有更新;  内存不足(常态); 系统空闲; 正常关闭shutdown
  
  因素: 脏页比例(innodb_max_dirty_pages_pct<=75%), 写盘速度(innodb_io_capacity).
  
  策略: {max(F1(100*M/innodb_max_dirty_pages_pct),F2(write_pos-checkpoint))}% 的写盘速度
  
  脏页比例M: Innodb_buffer_pool_pages_dirty/Innodb_buffer_pool_pages_total, <75%
  
  innodb_flush_neighbors=0(>8.0,SSD)
  
  double write: page16K fs4K dis512B, 解决16K部分失败的刷盘问题(redo也已损坏)
  
  _刷脏页是刷的change buffer吗？_
  
  
#### 13. 表数据空间优化（数据删除空间不变）

  表结构定义在.frm或系统数据表(>8.0)
  
  innodb_file_per_table OFF(系统共享表空间) 默认ON(.idb文件)
  
  数据页的复用和记录的复用
  
  重建表 alter table A engine=InnoDB(<5.5,DDL非ONLINE)，Online DDL用row log实现
  
  Online DDL: create tmp_file -> table B+tree to tmp_file -> store modify to row log -> row log to tmp_file -> tmp_file replace table
  
  Online DDL MDL读锁，有一定性能开销，gh-ost开源库方案
  
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

  1. binlog完整, statement有COMMIT, row有XID event. binlog-checksum参数
  2. redo log 和 binlog 通过XID关联
  3. redo log(pre)+binlog恢复。 binlog会被从库失败无法回滚，故只能提交redo log
  4. 两阶段提交。事务持久性问题。 若提交redo log->提交binlog，回滚redo log会回滚已提交事务导致覆盖其他事务更新, 若binlog后提交又成为二阶段了。
  5. binlog不支持崩溃恢复。 没能力恢复"数据页"
  6. binlog还用于归档，主从等，生态能力是需要的
  7. redo log 4*1G
  8. buffer pool 进行最终数据落盘
  9. redo log buffer -> .ib_logfile4
  
  事务尽量先insert再update，避免行锁时间过长
  
  update set val=old_val, 0 rows affected 是真正去执行了的。
  
#### 16 order by的执行逻辑

  “Using filesort”表示的就是需要排序，MySQL会给每个线程分配一块内存用于排序，称为sort_buffer。

  SELECT city,name,age WHERE city="x" ORDER BY name limit 1000; 
    * idx(city)->pk(id)->sort_buffer(city name age)-> sort_buffer(全字段排序)->resp
    * idx(city)->pk(id)->sort_buffer(name id)-> sort_buffer(order)->pk(rowid排序)->resp
    
  sort_buffer用qsort，磁盘排序使用2路多路归并排序(同一文件偏移量区别分配，每MERGEBUFF (7)个分片做一个归并)，比如num_of_tmp_files=12
  
  SET optimizer_trace='enabled=on'; SELECT * FROM `information_schema`.`OPTIMIZER_TRACE`.number_of_tmp_files
  
  SET max_length_for_sort_data = xxx;
  
  setmode~=rowid排序多访问了一次主键索引, examined_rows+=limit
  
  优先选择全字段排序，当sort_buffer_size不够大或 排序的键值对大小>max_length_for_sort_data 才选择 rowid排序
  
  MySQL的一个设计思想:如果内存够,就要多利用内存,尽量减少磁盘访问。
  
  setmode: rowid(回表) / additional_fields(不回表) / packed_additional_fields(对varchar做紧凑处理)
  
  设置 sort_merge_passes 性能指标报警
  
#### 17 order by rand()

  SELECT word ORDER BY rand() LIMIT 3; count(*)=1w
  内存临时表 engine=Memory, rowid排序, tmp_table_size=16M, 
   * table(id,word)->内存临时表(R,W),1w扫描->sort_buffer(R,pos),1w扫描->rowid排序(R,pos)->映射内存临时表(R,W)->结果集(word),3扫描磁盘临时表
   * internal_tmp_disk_storage_engine=InnoDB 
   * tmp_table_size(16M,超过用磁盘)/sort_buffer_size(1MB,超过用磁盘)/max_length_for_sort_data(1024B,超过用rowid排序)
   * 优先队列排序算法(>5.6): 最大堆 
   * OPTIMIZER_TRACE.filesort_priority_queue_optimization.chosen=true,num_of_tmp_files=0,set_mode=rowid
   
    * 磁盘临时表的执行流程是怎样的呢 
    * 随机法： 表行数>limit randn,1;  where id>randn limit 1;  
    * 为何limit 10000,100 要改为 limit 10100 **
  
#### 18 SQL的列计算

  条件字段函数操作(全索引扫描)，隐式类型转换，隐式编码转换(有join可能的表统一使用utf8mb4)
  
  WHERE id+1=11 不能被自动转换为 WHERE id=11-1
  
#### 19 SELECT慢的原因

  有MDL锁(Waiting for table metadata lock);
  
  等flush(Waiting for table flush);
  
  等行锁(lock in share mode)
  
  sys.schema_table_lock_waits, sys.innodb_lock_waits, information_schema.processlist, set long_query_time=0

  查询慢: undo log 过大;
  
#### 20 幻读 ※ 

  WHERE d=5 for update; 当前读、
  
  幻读指的是一个事务在前后两次查询同一个范围的时候,后一次查询看到了前一次查询没有看到的行。仅指新插入行, 当前读非幻读。
  
  假设对d=5加行锁. 语义错误(未把d=5的行锁住)、数据一致性问题(UPDATE WHERE d=5之后其他事务新加的d=5在binlog会被错误的更新)
  
  ** 问题根本在于update并不是在最终commit时执行的，能否把binlog的执行时机改正确解决这个问题？ **
  
  假设对所有行加行锁. 由于不存在的行无法加锁，依旧存在单行加锁一样的问题。
  
  Gap间隙锁和行锁合称next-key lock,每个next-key lock是前开后闭区间, 执行先间隙锁再行锁。
  
  跟间隙锁存在冲突关系的，是“往这个间隙中插入一个记录”这个操作。间隙锁之间都不存在冲突关系。
  
  insert on duplicate key update 的事务实现，多个事务的间隙锁会造成死锁，间隙锁影响了并发度。
  
  读提交、binlog=row, 无幻读问题
  
  _为何MVCC解决不了幻读问题，新插入的行不属于这个版本的不能走回滚日志吗？ 答案：是走回滚日志的，幻读在“当前读”下才会出现_
  _为何更新插入的行不能叫幻读之后又针对此情况进行了说明幻读的问题？我认为更新导致的也叫做幻读_
  _我认为忽略低位分三种情况理解更容易_
  
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
     
#### 23 binlog/relog可靠性。 怎么保证redo log和binlog是完整的 ※
  
  事务执行过程中，先把日志写到binlog cache/redo log buffer, commit写文件; 保证一次性写入
  
  binlog cache(thread) ->write binlog files(fs page cache) -> fsync disk
  
  binlog_cache_size/sync_binlog=1(fsync 0永不,1每次, 500±400重启丢失. IOPS++)
  
  redo log buffer -> write fs page cache -> fsync disk
  
  innodb_flush_log_at_trx_commit=1(fsync, 1disk 2pagecache 0buffer), 
   
  未提交事务也会落盘: bg thread write&fsync/per 1s; redo log buffer>=innodb_log_buffer_size/2; 并行事务提交顺带落盘;
  
  redolog 在prepare阶段持久化. 由于per1s刷盘&崩溃恢复逻辑，在commit不fsync，只会write到文件系统的page cache中就够了。
  
  双1配置: redo log pre fsync, commit write; binlog fsync
  
  group commit(IOPS<TPS*2): LSN+=redo log length, TPS<2*IOPS. 联想到TCP的seq滑动窗口、ack累计确认.
  
  redo log pre: write -> binlog: write -> redo log pre: fsync -> binlog: fsync -> redo log commit:write
  
  binlog_group_commit_sync_delay / binlog_group_commit_sync_no_delay_count 增加语句响应时间。 可作为临时提高性能使用。
  
  WAL: redolog和binlog都是顺序写、组提交降低磁盘的IOPS
  
  优化IO瓶颈： 组提交延迟、sync_binlog几百、innodb_flush_log_at_trx_commit=2
  
  一些问题
  *  update语句完成，hexdump打印的idb文件看不到改变，原因是 仅保证写完了 redo log 和 内存，未写到磁盘
  *  binlog cache 每线程自己维护, redo log buffer 全局共用。 原因是 binlog不能被打断
  *  虽然是顺序写，但MySQL的select查询也会争用磁盘吧？
 
#### 24 主备

  start -> undo log(mem) -> data(mem) -> redo log(prepare) -> bin log -> dump thread -> io thread -> relay log -> sql_thread->  data
  
  binlog_format: statement(delete limit 选错索引会不一致),  row(delete 10w占空间,恢复方便), mixed()
  
  now()被转换为set timestamp的statement语句； mysqlbinlog 的statement语句执行不能拷贝出来执行， 因为有上下文的存在。
  
  循环复制问题， log_slave_updates=on(relay log 后生成 binlog) 源server_id保存判断，类trace_id源头生成。 
  数据迁移时， 三节点复制场景， 会出现双M的循环复制
  
#### 25 高可用

  主备延迟: 从库配置低、备库压力大、大事务、delete太多行、大表DDL、备库并行复制能力不足、主库并发高、主库TPS高。 seconds_behind_master(show slave status)。
  
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
  * 判断主备无延迟方案；slave status主备的 seconds_behind_master; 比对点位:File/Pos; GTID集合:Gtid_Set.
  * 配合semi-sync方案；半同步复制类似raft得到从库响应才算成功,依旧不支持多从和持续延迟问题。（aliyun rds默认）
  * 等主库位点方案。select master_pos_wait(file, pos[, timeout]);
  * 等GTID方案。select wait_for_executed_gtid_set(gtid_set, 1); master的GTID随事务返回(>=5.7.6);
  set session_track_gtids=OWN_GTID; mysql_session_track_get_first()
  
#### 29 健康检查
   
   把innodb_thread_concurrency设置为64~128之间的值
   
   在线程进入锁等待以后，并发线程的计数会减一，也就是说等行锁（也包括间隙锁）的线程是不算在128里面的。
   
   查表，select * from mysql.health_check; 更新，update mysql.health_check set t_modified=now();
   
   考虑主备，外包统计判定慢，insert into mysql.health_check(id, t_modified) values (@@server_id, now()) on duplicate key update t_modified=now();
   
   内部统计， 打开监控(所有监控开性能损10%)， mysql> update setup_instruments set ENABLED='YES', Timed='YES' where name like '%wait/io/file/innodb/innodb_log_file%';
   
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

  类Linux的Kill，非直接停止，而是发送信号

  逻辑：killed=THD::KILL_QUERY; 信号给线程; 程序判断埋点进行终止.

  kill无效: 线程没有执行到判断线程状态的逻辑(埋点读信号)、IO压力大; 终止逻辑耗时较长(大事务回滚的新数据版本回收、大查询回滚的临时文件、DDL最后阶段的临时文件); 
  
  停等协议，客户端Ctrl+C：自动新连接&kill query; 
  
  表多连接慢，是因为客户端在构建一个本地的哈希表并非连接慢（-A 关闭）
  
  –quick 客户端快。 用mysql_use_result非mysql_store_result； 无表明补全； 无本地历史
  
#### 33. buffer pool. 全表扫描对server和innodb的影响. 查大数据不会打爆内存 ※ 
  
  流程：mysql.data->mysql.net_buffer->server.socket send buffer->client.socket receive buffer
  
  net_buffer(net_buffer_length=16k)满 网络接口发; 清空重新写; 若socket send buffer(/proc/sys/net/core/wmem_default=256K)满(EAGAIN或WSAEWOULDBLOCK)等后发
  
  MySQL是“边读边发的”; 联想到TCP.WWS; 
  
  建议mysql_store_result 结果保存到本地内存; mysql_use_result导致的State: Sending to client网络栈写满或客户端处理慢会导致长事务。
  
  “Sending data”是正在执行，从查询语句进入执行阶段后开始，非“正在发送数据”
  
  innodb status -> Buffer pool hit rate > 99%
  
  innodb_buffer_pool_size 可用物理内存的60%~80%; LRU;
  
  LRU 5:3=young:old(类全表扫描不影响young): 数据页新进old,时段外多次访问进young(innodb_old_blocks_time=1000)。
  
  由于一个数据页多个记录，故1s内会多次访问数据页，故要设定innodb_old_blocks_time
  
  _buffer pool 用于LRU的空间有多大呢? 因为有一半空间给了change buffer。_
  
#### 34. join
  
  join需小于3张表： 优化器使用动态规划和贪心算法； 考虑分库扩展性。完全禁止是政治的部门利益一刀切.
  
  join性能更好；小表做驱动表；被驱动表2logM(2索引树)
  
  join_buffer_size=256k
  
  NLJ:Index Nested-Loop Join O(N+N*2*logM) / BNL:Block Nested-Loop Join 内存判断N*M,扫描N+((K=λ*N)*M) / 没用Simple Nested-Loop Join O(N*M)
  
  straight_join
  
  BLN若多次扫冷表
  
  join explain Extra 默认NLJ

  
#### 35. join 优化
 
  Multi-Range Read优化(MRR), 通过二级索引可避免随机读聚簇索引，使顺序读盘。read_rnd_buffer_size。 set optimizer_switch="mrr_cost_based=off"。 explain.Extra: Using MRR.
  
  Batched Key Acess(BKA)(>5.6), 优化NLJ。 set optimizer_switch='mrr=on,mrr_cost_based=off,batched_key_access=on';
  
  BNL大冷被驱动表影响Buffer Pool内存命中率/多次扫描被驱动表IO高/N*M内存判断CPU高
  
  BNL转BKA优化: 被驱动表关联字段索引、临时表方案、业务代码实现hash join优化; 
  
  优化 select * from t1 join t2 on(t1.a=t2.a) join t3 on (t2.b=t3.b) where t1.c>=X and t2.c>=Y and t3.c>=Z;
  
  _驱动表走索引就不会全表扫描了吧？ N应该会很小_
  
  _join_buffer是无序数组，若先排序，时间复杂度是 N*logN*M 反而更差？ 非N*M/2可能非唯一索引导致？_
  
#### 36. 临时表 
  
  分库分表场景的非聚合列查询(proxy聚合， 临时表异构解决)、create temporary table， .frm，前缀是“#sql{进程id}_{线程id}_序列号”， 临时文件表空间(>5.7)
  
  主备复制，row格式不记create， /* generated by server */代表语句被修改，
  
#### 37. 内存临时表Group优化 

  union 需临时表去重 / union all 无需临时表 / group by a 文件排序&临时表
  
  group by k order by null (若无order会默认order k) 
  
  内存临时表tmp_table_size=16M, 场景: 有中间结果需要额外内存保存; 需要二维表结构; 
  
  索引优化group。generated column机制(>5.7)。alter table t1 add column z int generated always as(id % 100), add index(z); 
  
  直接磁盘排序group。避免内存转磁盘临时表。sort_buffer有序数组获取每值出现次数，无Using temporary。select SQL_BIG_RESULT id%100 as m, count(*) as c from t1 group by m; 
  
  join_buffer是无序数组，sort_buffer是有序数组，临时表是二维表结构；
  
  group注意: order by null, explain 无 Using temporary 和 Using filesort, 调大tmp_table_size, SQL_BIG_RESULT使用排序算法
  
  _SQL_BIG_RESULT标识直接走sort_buffer本身不走磁盘？_
  
#### 38. Memory引擎 

  堆组织表，插入顺序排序，写快、hash索引、内存有限、varchar失效、表锁、线程内使用、重启丢失问题、主备同步问题 
  
#### 39. 自增主键

  自增主键id不连续：udx Duplicate key error、回滚、批量插入2n批量申请策略优化
  
  自增id锁并不是一个事务锁，而是每次申请完就马上释放，以便允许别的事务再申请(>5.1.22)
  
  innodb_autoinc_lock_mode=1(>5.1.22, 1数据一致性, 建议2)
  
  自增值记录内存，重启失效(<8.0)，保存到redo log(>8.0)

  并发插入数据性能; innodb_autoinc_lock_mode=2; binlog_format=row
  
  普通插入一次性申请id
  
#### 40. insert锁
  
  insert select 若不锁statement下主备数据不一致；会记录+间隙锁
  
  insert t select t循环写入，用临时表
  
  insert udx 共享的next-key lock(S锁)
  
  insert into … on duplicate key update, 排他的next-key lock（写锁）, affected rows返回的是2
  
#### 41. 复制表的方案

  物理拷贝:最快，适合大表，数据表恢复， 登录服务器，源表和目标表都是使用InnoDB
  
  mysqldump: 可用where，不能用join
  
  用select … into outfile 支持所有的SQL写法。每次只能导出一张表的数据，而且表结构也需要另外的语句单独备份。
  
  ```
  mysqldump -h$host -P$port -u$user --add-locks --no-create-info --single-transaction  --set-gtid-purged=OFF db1 t --where="a>900" --result-file=/client_tmp/t.sql
  –skip-extended-insert 每行insert
  mysql -h127.0.0.1 -P13000  -uroot db2 -e "source /client_tmp/t.sql"
  
  select * from db1.t where a>900 into outfile '/server_tmp/t.csv';
  mysqldump -h$host -P$port -u$user ---single-transaction  --set-gtid-purged=OFF db1 t --where="a>900" --tab=$secure_file_priv
  --tab=$secure_file_priv 同时导出表结构定义文件和csv数据文件
  load data (local) infile '/server_tmp/t.csv' into table db2.t;
  
  ```
  
#### 43. 分区表

  first访问所有分区；共用MDL锁
  
#### 44. 答疑

  join on where。 left join 不能在where关联字段，否则会优化为join。 show warnings
  Simple Nested Loop Join 的性能差，因为影响buffer pool命中率、join_buffer数组遍历成本低
  distinct 和 group by的性能。 若无聚合函数性能相同，用的唯一索引临时表
  备库自增主键。statement下binlog会SET INSERT_ID=n解决数据不一致问题;
  
#### 45. 自增ID上限
  
  自增id. 表定义的自增主键达到上限后的逻辑是：再申请下一个id时，得到的值保持不变。主键冲突，影响可用性
  
  row_id. 无主键，dict_sys.row_id作为6字节的row_id，覆盖循环写入，影响数据可靠性
  
  Xid. global_query_id 内存存储，重启清0，同一binlog唯一。 上限2^64清0. Xid server层,InnoDB事务和server之间做关联。
  
  trx_id.  transaction id, max_trx_id, information_schema.innodb_trx, innodb_locks, 
  只读事务: 不分配trx_id, 指针地址+2^48, max_trx_id超限从0开始导致脏读。gdb测试
  
  thread_id. thread_id_counter，唯一数组存， 不会重复。
  
## 总结

##### 规范
6、【强制】必须创建主键，如无特殊要求使用INT/BIGINT UNSIGNED AUTO_INCREMENT类型；不建议使用类uuid()生成不规则的主键值。
1）使用int/bigint作为自增主键比uuid占用空间小。
2）大表中进行范围查询自增主键效率优于uuid。
3）在并发写入上面，自增ID主键顺序写入的效率是UUID主键的3到10倍，相差比较明显，特别是update小范围之内的数据上面。uuid由于随机性在大批量并发写入上会造成严重的叶分裂导致性能变差。
4）备份恢复上面自增id主键优于uuid。
9、【建议】对于金钱等涉及到精准数据的存储，推荐使用decimal或者bigint。避免使用float/double。
10、【建议】表中所有字段尽量都是NOT NULL属性，业务可以根据需要定义DEFAULT值。如varchar类型无DEFAULT值可以设置为“”。
说明：
1）null字段需要额外空间标识；
2）null无法进行值比较容易造成结果集异常,在程序层面需要额外处理。
12、【强制】禁止使用blob类字段存储二进制数据(视频，图片)在mysql数据库中，应该在字段中存储url链接指向外部存储。
说明：
1）text/blob字段在mysql中无法定义default值；
2）text/blob字段只能添加前缀索引；
3）text/blob字段在mysql中会使用额外的字节进行存储，存在页迁移的情况；
4）如果包含text/blob字段的结果集需要用到临时表，mysql通常会使用磁盘临时表取代内存临时表(原生mysql memory引擎不支持text/blob)造成效率低下；
5）对包含大字段的表进行频繁dml操作会放大binlog event造成io进程堵塞、从库延迟；
6）视频，图片可以存放在其他存储上，mysql只保留url；
7）尽量将text类型字段进行父子表分割，使用id主键进行关联查询。
15、【建议】需要精确到时间（年月日时分秒）的字段尽量使用DATETIME，除非需要用到TIMESTAMP时区的特性可以使用TIMESTAMP。
说明：TIMESTAMP可以节省空间，但是区间为'1970-01-01 00：00：01' UTC to '2038-01-19 03：14：07' UTC。
16、【强制】表中禁止时间类型默认值为0值，如defualt "0000-00-00", defualt "0000-00-00 00:00:00" ，建议设置为无意义含义，如 "1970-01-01 01:01:01"
18、【强制】相同功能的字段选择相同的数据类型、取值范围和排序类型。
说明：相同功能的字段通常表连接时会进行字段连接；选择相同的数据类型、取值范围和排序类型可以避免隐式转换导致无法用到索引匹配造成性能低下的情况发生。
19、【强制】禁止在生产环境在核心环境中使用分区表。
说明：
1）分区键必须包含主键，唯一索引；
2）分区键设计不灵活(mysql分区只有数值、范围、hash)；
3）5.6.7以前分区表最多支持1024分区；5.7分区表表最多支持8192分区；
4）多分区有文件句柄限制;
5）执行计划不走分区键时性能低效；
6）分区表限制：https：//dev.mysql.com/doc/refman/5.6/en/partitioning-limitations.html
20、【强制】禁止在生产环境使用enum和set类型，使用tinyint方式进行代替。
```
说明：
1）enum和set类型在做更改的时候需要alter表，5.6以前需要锁表；
2）枚举类型是按照内部存储的整数而不是定义的字符串进行排序的。一种是本身按照顺序来定义枚举；另一种使用field函数进行排序，这样的话就会导致无法利用索引排序。
```

21、【强制】禁止在生产环境使用存储过程、函数、视图、触发器。
```
说明：
1）存储过程、自定义函数通常包含复杂业务逻辑形成大事务；mysql做简单的dml效率要远远高于复杂逻辑。调用存储过程、函数时无法查看详细sql难于排查问题。
2）触发器容易导致db并发高时cpu飙升；开发人员交接容易遗忘，程序逻辑难于控制。
3）视图容易产生效率不高的执行计划。
```

22、【强制】禁止在生产环境使用外键，可以通过前端应用来做控制。
```
说明：
1）mysql在做完整性校验时会消耗一部分性能：通常在修改父表数据时会对子表多执行一次查询；如果外键列的选择性很低，即使外键强制创建索引查询效率也会很低；在子表中插入数据也会检查相应父表数据造成额外锁，往往会导致锁等待甚至锁超时、死锁的发生。
2）外键维护是逐行维护的，在批量删除、更新时效率会很低；
3）大数据量导入时非常耗时；
4）第三方工具有时不支持外键。
```




##### SQL性能提升
  * 调试方法：  explain; show warnings; profile; processlist; optimizer_trace; slow log; 云监控页面; prometheus;
  * explain: 索引; B+tree高; explain的extend衍生join/group算法分析; 
    join_buffer_size改大使BNL的分段数变少使时间复杂度变低。
    应用MRR/BKA减少随机扫描
    超过1s的查询对BP产生持续性影响。
  * 衍生SELECT及UPDATE执行流程: Query Cache; BP命中率; Change Buffer; WAL(redolog&binlog); semi-sync(repl); 
  * 事务: 大事务的undolog过大 
  * 锁: MDL、全局读锁、死锁检测、
  * 业务设置: 超时、连接池、store_result

##### 索引
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

##### 日志
  
  * 事务日志：重做日志redo和回滚日志undo
  * 中继日志：中继日志也是二进制日志，用来给slave 库恢复
  * 错误日志：记录出错信息，也记录一些警告信息或者正确的信息。
  * 查询日志：记录所有对数据库请求的信息，不论这些请求是否得到了正确的执行。
  * 慢查询日志：设置一个阈值，将运行时间超过该值的所有SQL语句都记录到慢查询的日志文件中。
  * 二进制日志：记录对数据库执行更改的所有操作。
  
##### 阿里云监控台
  
  https://rdsnext.console.aliyun.com/#/detail/rm-2ze3pb5rblpl094h7/diagnosis?region=cn-beijing
  
  _TPS为何比QPS小几倍? Com_select也是事务吧，为何不计入TPS?  QueryCache会记入Com_*吗？_
  
  QPS=(Questions() = (Com_select + Com_insert + Com_delete + Com_update + Oth(use/show/set...)) ) / Uptime ; 大;
  
  TPS=( Com_insert + Com_delete + Com_update )/ Uptime ; 非(Com_commit(非隐式) + Com_rollback) ; handler_commit
  
  show global status where variable_name in('com_select','com_insert','com_delete','com_update','com_commit','com_rollback','Questions');
  
## 练习
  * 单机数据可靠性 redo log  2, 15, 23。
  * 事务  3, 8, 20。各隔离级别case,读视图,undo log,当前读,幻读W/H/Q。
  * 锁  6, 7, 13, 19, 20, 21, 30, 39, 40
  * index 4, 5, 9, 10, 11
  * buffer 16, 17, 33, 34, 35, 36, 37, 38。 sort buffer, join buffer, tmp table
  * 多机(主从) 24, 25, 26, 27, 28, 29, 41。 
  
  
##### 马士兵 https://ke.qq.com/webcourse/index.html#cid=399017&term_id=100475965&taid=8662656978654889
原子性实现原理undo-log
  * 逻辑日志(修改一行，做sql记录) & 物理日志(修改一个页的某数据)
    一个页16KB有100条记录， 只改一条记录，其他记录不能修改。 锁粒度在记录。
持久性实现原理redo-log
  零拷贝(kafka:零拷贝和顺序写)
  进程内存(user space)-系统内存(kenel)-磁盘

零拷贝
    mmap让数据传输不需要经过user space
    
  