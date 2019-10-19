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
 
#### 2. update执行流程

  物理重做日志redo log: 引擎层, crash-safe, innodb_flush_log_at_trx_commit=1, WAL Write-Ahead Logging, 4x1G, 循环写: write_pos,checkpoint; 
  
  逻辑归档日志binlog: server层, sync_binlog=1, 追加写
  
  exec: 2PC; 执行器先找引擎取值(内存中取或磁盘读入内存)->执行器改数->引擎层写内存+redo log->执行器binlog写磁盘->引擎层redo log commit
  
  _非update v=v+1, 为何要先取数再改数而不能直接改？引擎api不支持？_

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
  
#### 7. 行锁

  两阶段锁协议。事务提交后释放锁。 影响并发度的锁的申请时机尽量往后放, 影院余额扣减放最后
  
  死锁和死锁检测。 innodb_lock_wait_timeout=50s、innodb_deadlock_detect=on 
  
  检测吃CPU。关闭检测; 控制访问相同资源的并发事务量,对于相同行的更新，在进入引擎之前排队; 业务拆分处理，比如余额拆10个账户
  
  假设有1000个并发线程要同时更新同一行，那么死锁检测操作就是100万这个量级的。
  
  案例: 一个连接中循环执行多次limit更新操作更友好

#### 8. 事务隔离 ※ 

  视图: view(create view...) / consistent read view(RC/RR). 
  
  快照在MVCC: row trx_id=transaction id. 
  
  每个事务构造数组保存事务ID; 视图数组和高水位组成read view.
  
  数据版本的可见性: row trx_id对比一致性视图; *为何用数组？因为read view是整库的，黄区存在已提交的快事务。*
  
  当前读（current read）: 更新数据都是先读后写的，而这个读，只能读当前的值。

  表结构不支持“可重复读”？这是因为表结构在frm, 没有对应的行数据，也没有row trx_id，因此只能遵循当前读的逻辑。

  MVCC实现: DB_TRX_ID,DB_ROLL_PTR,DB_ROW_ID, undo log, Read View.undo log是链表，节点被purge线程清除。
  
  
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

  SELECT city,name,age WHERE city="x" ORDER BY name limit 1000; 
    * idx(city)->pk(id)->sort_buffer(city name age)-> sort_buffer(全字段排序)->resp
    * idx(city)->pk(id)->sort_buffer(name id)-> sort_buffer(order)->pk(rowid排序)->resp
    
  sort_buffer_size 不够用使用外部排序是用的归并排序，比如num_of_tmp_files=12,sort_mode~=packed_additional_fields表示对varchar做紧凑处理
  
  SET optimizer_trace='enabled=on';
  
  SET max_length_for_sort_data = xxx;
  
  setmode~=rowid排序多访问了一次主键索引, examined_rows+=limit
  
  优先选择全字段排序，当sort_buffer_size不够大或行数据大于max_length_for_sort_data 才选择 rowid排序
  
  MySQL的一个设计思想:如果内存够,就要多利用内存,尽量减少磁盘访问。
  
#### 17 order by rand()

  SELECT word ORDER BY rand() LIMIT 3; count(*)=1w
  内存临时表 engine=Memory, rowid排序, tmp_table_size=16M, 
    * table(id,word)->内存临时表(R,W),1w扫描->sort_buffer(R,pos),1w扫描->rowid排序(R,pos)->映射内存临时表(R,W)->结果集(word),3扫描
  磁盘临时表
    * internal_tmp_disk_storage_engine=InnoDB 
    * tmp_table_size/sort_buffer_size/max_length_for_sort_data 
    * 优先队列排序算法(>5.6) 
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
  
#### 20 幻读 ※

  WHERE d=5 for update; 当前读、
  
  幻读指的是一个事务在前后两次查询同一个范围的时候,后一次查询看到了前一次查询没有看到的行。仅指新插入行, 当前读非幻读。
  
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
     
#### 23 binlog/relog可靠性 ※
  
  事务执行过程中，先把日志写到binlog cache/redo log buffer, commit写文件; 保证一次性写入
  
  binlog cache(thread) ->write binlog files(fs page cache) -> fsync disk
  
  binlog_cache_size/sync_binlog=1(1fsync,500±400重启丢失,IOPS++)
  
  redo log buffer -> write fs page cache -> fsync disk
  
  innodb_flush_log_at_trx_commit=1(fsync), 
   
  未提交事务也会落盘: bg thread write&fsync/per 1s; buffer>=innodb_log_buffer_size/2; 并行事务提交顺带落盘;
  
  双1配置: redo log pre fsync, commit write; binlog fsync
  
  group commit: LSN+=redo log length, TPS<2*IOPS. 联想到TCP的seq滑动窗口.
  
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
  
  _ buffer pool 用于LRU的空间有多大呢? 因为有一半空间给了change buffer。_
  
#### 34. join
  
  join需小于3张表： 优化器使用动态规划和贪心算法； 考虑分库扩展性。完全禁止是政治的部门利益一刀切.
  
  join性能更好；小表做驱动表；被驱动表2logM(2索引树)
  
  join_buffer_size=256k
  
  NLJ:Index Nested-Loop Join O(N+N*2*logM) / BNL:Block Nested-Loop Join 内存判断N*M,扫描N+((K=λ*N)*M) / 没用Simple Nested-Loop Join O(N*M)
  
  straight_join
  
  BLN若多次扫冷表
  
  join explain Extra 默认NLJ
  
  
#### 35. join 优化
 
  Multi-Range Read优化(MRR) 顺序读盘。read_rnd_buffer_size。 set optimizer_switch="mrr_cost_based=off"
  
  Batched Key Acess(BKA)(>5.6), 优化NLJ。 set optimizer_switch='mrr=on,mrr_cost_based=off,batched_key_access=on';
  
  BNL大冷被驱动表影响Buffer Pool内存命中率/多次扫描被驱动表IO高/N*M内存判断CPU高
  
  BNL转BKA优化: 被驱动表关联字段索引、临时表方案、业务代码实现hash join优化; 
  
  优化 select * from t1 join t2 on(t1.a=t2.a) join t3 on (t2.b=t3.b) where t1.c>=X and t2.c>=Y and t3.c>=Z;
  
  _驱动表走索引就不会全表扫描了吧？ N应该会很小
  _join_buffer是有序数组，为何内存判断是N*M呢? 不应该是N*M/2或LogN*M吗_
  
#### 36. 临时表

  分库分表场景下常用、create temporary table， .frm，前缀是“#sql{进程id}_{线程id}_序列号”， 临时文件表空间(>5.7)
  
  主备复制，row格式不记create， /* generated by server */代表语句被修改，
 
  
#### 37. 内存临时表Group优化

  union (非union all)/ group by 
  
  group by k order by null (若无order会默认order k)
  
  内存临时表tmp_table_size=16M 
  
  索引优化group。generated column机制(>5.7)。 alter table t1 add column z int generated always as(id % 100), add index(z);
  
  直接排序。避免内存转磁盘临时表。sort_buffer有序数组获取每值出现次数。select SQL_BIG_RESULT id%100 as m, count(*) as c from t1 group by m;
  
#### 38. Memory引擎

  堆组织表，插入顺序排序，写快、hash索引、内存有限、varchar失效、表锁、线程内使用、重启丢失问题、主备同步问题
  
#### 39. 自增主键

  自增主键id不连续：udx Duplicate key error、回滚、批量插入2n批量申请策略优化
  
  自增id锁并不是一个事务锁，而是每次申请完就马上释放，以便允许别的事务再申请(>5.1.22)
  
  innodb_autoinc_lock_mode=1(>5.1.22, 1数据一致性, 建议2，)
  
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
  
  mysqldump: 可用用where，不能用join
  
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
  
  
  
  
  
  
  
  
  
  
  
  