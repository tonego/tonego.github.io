-- 《etcd实战课》
 开篇词｜为什么你要学习etcd?
 我希望你能够用最低的学习成本，掌握etcd核心原理和最佳实践，让etcd为你所用。
 
### 01 | etcd的前世今生：为什么Kubernetes使用etcd？
https://blog.csdn.net/kuaipao19950507/article/details/119061784
 etcd 诞生背景， etcd v2 源自 CoreOS 团队遇到的服务协调问题。
 etcd 目标，我们通过实际业务场景分析，得到理想中的协调服务核心目标：高可用、数据一致性、Watch、良好的可维护性等。而在 CoreOS 团队看来，高可用、可维护性、适配云、简单的 API、良好的性能对他们而言是非常重要的，ZooKeeper 不支持通过 API 安全地变更成员，需要人工修改一个个节点的配置，并重启进程； java的部署繁琐；无法与curl互动。
 Paxos/ZAB/Raft.
 etcd为简单内存数、zk为ConcurrentHashMap.
 
 v2 基于目录的层级数据模型（参考zk）和 API。
 etcd v2问题：
   * 功能局限性（分页、范围查找、多key事务）；
   * Watch事件的可靠性（内存型、无key历史版本、事件丢失、触发client全量拉群出现雪崩）、
   * 性能（json序列化、http/1.x 轮询watch事件的大量长连接消耗server大量socket和内存资源、周期性刷新key的ttl）、
   * 内存开销。（数据量大、全量内存定时刷盘）
  etcd v3（16.06）解决：
   * 在内存开销、Watch 事件可靠性、功能局限上，它通过引入 B-tree、boltdb 实现一个 MVCC 数据库，数据模型从层次型目录结构改成扁平的 key-value，提供稳定可靠的事件通知，实现了事务，支持多 key 原子更新，同时基于 boltdb 的持久化存储，显著降低了 etcd 的内存占用、避免了 etcd v2 定期生成快照时的昂贵的资源开销。
   * 性能上， gRPC、protobuf、http/2.0多路复用、使用Lease优化TTL。
   
 CoreOS 团队未雨绸缪，从问题萌芽时期就开始构建下一代 etcd v3 存储模型，分别从性能、稳定性、功能上等成功解决了 Kubernetes 发展过程中遇到的瓶颈，也捍卫住了作为 Kubernetes 存储组件的地位。
 希望通过今天的介绍， 让你对 etcd 为什么有 v2 和 v3 两个大版本，etcd 如何从 HTTP/1.x API 到 gRPC API、单版本数据库到多版本数据库、内存树到 boltdb、TTL 到 Lease、单 key 原子更新到支持多 key 事务的演进过程有个清晰了解。希望你能有所收获，在后续的课程中我会和你深入讨论各个模块的细节。
 
### 02 | 基础架构：etcd一个读请求是如何执行的？ 
Client层。包括 client v2 和 v3 两个大版本 API 客户端库，提供了简洁易用的 API，同时支持负载均衡、节点间故障自动转移，可极大降低业务使用 etcd 复杂度，提升开发效率、服务可用性。
API网络层。主要包括 client 访问 server 和 server 节点之间的通信协议。一方面，client 访问 etcd server 的 API 分为 v2 和 v3 两个大版本。v2 API 使用 HTTP/1.x 协议，v3 API 使用 gRPC 协议。同时 v3 通过 etcd grpc-gateway 组件也支持 HTTP/1.x 协议，便于各种语言的服务调用。另一方面，server 之间通信协议，是指节点间通过 Raft 算法实现数据复制和 Leader 选举等功能时使用的 HTTP 协议。
Raft算法层。实现了 Leader 选举、日志复制、ReadIndex 等核心算法特性，用于保障 etcd 多个节点间的数据一致性、提升服务可用性等，是 etcd 的基石和亮点。
功能逻辑层。etcd 核心特性实现层，如典型的 KVServer 模块、MVCC 模块、Auth 鉴权模块、Lease 租约模块、Compactor 压缩模块等，其中 MVCC 模块主要由 treeIndex 模块和 boltdb 模块组成。
存储层。存储层包含预写日志 (WAL) 模块、快照 (Snapshot) 模块、boltdb 模块。其中 WAL 可保障 etcd crash 后数据不丢失，boltdb 则保存了集群元数据和用户写入的数据。
KVServer。
拦截器：debug日志、metrics统计、Learner节点api和参数控制、要求操作前必须有leader防止脑裂、慢查询日志。
串行读：数据不一致、低延迟、高吞吐。 线性读：要leader的index，等待状态机追上leader进度。
MVCC。 从 treeIndex （b-tree）中获取 key hello 的版本号，再以版本号作为 boltdb 的 key，从 boltdb （b+tree）中获取其 value 信息。
小结。一个读请求从 client 通过 Round-robin 负载均衡算法，选择一个 etcd server 节点，发出 gRPC 请求，经过 etcd server 的 KVServer 模块、线性读模块、MVCC 的 treeIndex 和 boltdb 模块紧密协作，完成了一个读请求。
早期 etcd 线性读使用的 Raft log read，也就是说把读请求像写请求一样走一遍 Raft 的协议，基于 Raft 的日志的有序性，实现线性读。但此方案读涉及磁盘 IO 开销，性能较差，后来实现了 ReadIndex 读机制来提升读性能，满足了 Kubernetes 等业务的诉求。
 
### 03 | 基础架构：etcd一个写请求是如何执行的？
 ###### quota 
 默认配额2G，建议最大8G。 "etcdserver: mvcc: database space exceeded"错误
 ###### preflight check
 如果 Raft 模块已提交的日志索引（committed index）比已应用到状态机的日志索引（applied index）超过了 5000，那么它就返回一个"etcdserver: too many requests"错误
 ###### propose 
 向 Raft 模块发起提案后，KVServer 模块会等待此 put 请求，等待写入结果通过消息通知 channel 返回或者超时。etcd 默认超时时间是 7 秒（5 秒磁盘 IO 延时 +2*1 秒竞选超时时间），如果一个请求超时未返回结果，则可能会出现你熟悉的 etcdserver: request timed out 错误。
 ###### boltdb
 版本号作为key顺序写入提高B+tree性能。
 异步机制。定时（默认每隔 100ms）将批量事务一次性提交（pending 事务过多才会触发同步提交）。

### 04 | Raft协议：etcd如何实现高可用、数据强一致的？
在 etcd 3.4 中，etcd 引入了一个 PreVote 参数（默认 false），可以用来启用 PreCandidate 状态。 解决不停自增任期号发起选举影响稳定性。
通过 Leader 选举限制、Leader 完全特性、只附加原则、日志匹配等安全特性，Raft 就实现了一个可严格通过数学反证法、归纳法证明的高可用、一致性算法。
_若leader返回给client后宕机，followers如何判断这个未提交的信息是否有效？_
### 05 | 鉴权：如何保护你的数据安全？

### 06 | 租约：如何检测你的客户端存活？
liveness两种方式：如redis sentinel的被动检测；leader主动上报。
lease 的ttl解决leader选举、k8s events自动淘汰、服务发现场景故障节点自动剔除。
$ etcdctl put node1 healthy --lease 32697c5ea692e832
$ etcdctl get node1 -w=json | python -m json.tool
grant lease - itemMap - boltdb.leaseBucket.leaseID
itemSet: 一个lease的多个key
etcd Lessor 主循环每隔 500ms 执行一次撤销 Lease 检查（RevokeExpiredLease），每次轮询堆顶的元素，若已过期则加入到待淘汰列表，直到堆顶的 Lease 过期时间大于当前，则结束本轮轮询。
通知follow节点删除：Lessor 模块会将已确认过期的 LeaseID，保存在一个名为 expiredC 的 channel 中，而 etcd server 的主循环会定期从 channel 中获取 LeaseID，发起 revoke 请求，通过 Raft Log 传递给 Follower 节点。
各个节点收到 revoke Lease 请求后，获取关联到此 Lease 上的 key 列表，从 boltdb 中删除 key，从 Lessor 的 Lease map 内存中删除此 Lease 对象，最后还需要从 boltdb 的 Lease bucket 中删除这个 Lease。
Lease 的 checkpoint 机制，它是为了解决 Leader 异常情况下 TTL 自动被续期，可能导致 Lease 永不淘汰的问题而诞生。
CheckPointScheduledLeases 定时将lease的ttl信息给follower节点
 Leader 节点收到 KeepAlive 请求的时候，它也会通过 checkpoint 机制把此 Lease 的剩余 TTL 重置，并同步给 Follower 节点，尽量确保续期后集群各个节点的 Lease 剩余 TTL 一致性。
 

### 07 | MVCC：如何实现多版本并发控制？
在一个度为 d 的 B-tree 中，节点保存的最大 key 数为 2d - 1，否则需要进行平衡、分裂操作。
在 etcd treeIndex 模块中，创建的是最大度 32 的 B-tree，也就是一个叶子节点最多可以保存 63 个 key。

### 08 | Watch：如何高效获取数据变化通知？
### 希望通过这节课，你能在实际业务中应用Watch特性，快速获取数据变更通知。

### 09 | 事务：如何安全地实现多key操作？
### 通过转账案例为你剖析etcd事务实现，让你了解etcd如何实现事务ACID特性，以及MVCC版本号在事务中的重要作用。

### 10 | boltdb：如何持久化存储你的key-value数据？
### 今天我将通过一个写请求在boltdb中执行的简要流程，分析其背后的boltdb的磁盘文件布局。

### 11 | 压缩：如何回收旧版本数据？
### 希望通过今天的这节课，能帮助你理解etcd压缩原理，在使用etcd过程中能根据自己的业务场景，选择适合的压缩策略。

### 12 | 一致性：为什么基于Raft实现的etcd还会出现数据不一致？
### 希望通过这节课，帮助你搞懂为什么基于Raft实现的etcd有可能出现数据不一致，以及我们应该如何提前规避、预防类似问题。

### 13 | db大小：为什么etcd社区建议db大小不超过8G？
### 我将通过一个大数据量的etcd集群为案例，为你剖析etcd db大小配额限制背后的设计思考和过大的db潜在隐患。

### 14 | 延时：为什么你的etcd请求会出现超时？
### 希望通过这节课，帮助你掌握etcd延时抖动、超时背后的常见原因和分析方法。

### 15 | 内存：为什么你的etcd内存占用那么高？
### 希望通过这节课，帮助你掌握etcd内存抖动、异常背后的常见原因和分析方法，当你遇到类似问题时，能独立定位、解决。

### 16 | 性能及稳定性（上）：如何优化及扩展etcd性能？
### 希望你通过本文当遇到读etcd性能问题时，能从请求执行链路去分析瓶颈，解决问题，让业务和etcd跑得更稳、更快。

### 17 | 性能及稳定性（下）：如何优化及扩展etcd性能?
### 这节课我将通过写性能分析链路图，为你从上至下分析影响写性能、稳定性的若干因素，为你总结出etcd写性能优化和扩展方法。

### 18 | 实战：如何基于Raft从0到1构建一个支持多存储引擎分布式KV服务？
### 希望通过metcd这个小小的实战项目，能够帮助你进一步理解etcd乃至分布式存储服务的核心架构、原理、典型问题解决方案。

### 19 | Kubernetes基础应用：创建一个Pod背后etcd发生了什么？
### 希望通过本节课，让你知道在Kubernetes集群中每一步操作的背后etcd会发生什么。

### 20 | Kubernetes高级应用：如何优化业务场景使etcd能支撑上万节点集群？
### 当你遇到etcd性能瓶颈时，希望这节课介绍能让你获得启发，帮助你解决类似问题。

### 21 | 分布式锁：为什么基于etcd实现分布式锁比Redis锁更安全？
redis锁实现： setnx+ex用redis-lua原子性实现比较库存和扣减库存的操作，幂等操作。
若无ex，master宕机后若slave有key则可能死锁无key则会重复获取锁； 若有ex，业务超时容易导致把其他client锁释放的bug。
分布式锁的核心要素： 安全性、互斥性、活性、高可用、高性能。
Redis SET 命令创建分布式锁的安全性问题。单 Redis Master 节点存在单点故障，一主多备 Redis 实例又因为 Redis 主备异步复制，当 Master 节点发生 crash 时，可能会导致同时多个 client 持有分布式锁，违反了锁的安全性问题。
主备切换、脑裂是 Redis 分布式锁的两个典型不安全的因素，本质原因是 Redis 为了满足高性能，采用了主备异步复制协议，同时也与负责主备切换的 Redis Sentinel 服务是否合理部署有关。
为了优化以上问题，Redis 作者提出了 RedLock 分布式锁，它基于多个独立的 Redis Master 节点工作，只要一半以上节点存活就能正常工作，同时不依赖 Redis 主备异步复制，具有良好的安全性、高可用性。然而它的实现依赖于系统时间，当发生时钟跳变的时候，也会出现安全性问题。
为了帮助你简化分布式锁、分布式选举、分布式事务的实现，etcd 社区提供了一个名为 concurrency 包帮助你更简单、正确地使用分布式锁、分布式选举。
mutex.Lock实现：使用了我们上面介绍的事务和 Lease 特性，当 CreateRevision 为 0 时，它会创建一个 prefix 为 /my-lock 的 key（ /my-lock + LeaseID)，并获取到 /my-lock prefix 下面最早创建的一个 key（revision 最小），分布式锁最终是由写入此 key 的 client 获得，其他 client 则watch进入等待模式。

### 22 | 配置及服务发现：解析etcd在API Gateway开源项目中应用

### 23 | 选型：etcd/ZooKeeper/Consul等我们该如何选择？
主要分布式协调服务的基本原理和彼此之间的差异性。
http://120.79.233.255:8080/detail/65
从共识算法角度上看，etcd、Consul 是基于 Raft 算法实现的数据复制，ZooKeeper 则是基于 Zab 算法实现的。Raft 算法由 Leader 选举、日志同步、安全性组成，而 Zab 协议则由 Leader 选举、发现、同步、广播组成。
etcd 和 Consul 则提供了线性读，ZooKeeper 默认是非强一致性读
Consul 提供了原生的分布式锁、健康检查、服务发现机制支持，让业务可以更省心，不过 etcd 和 ZooKeeper 也都有相应的库，帮助你降低工作量。Consul 最大的亮点则是对多数据中心的支持
业务使用 Go 语言编写的，国内一般使用 etcd 较多，文档、书籍、最佳实践案例丰富。Consul 在国外应用比较多，中文文档及实践案例相比 etcd 较少。ZooKeeper 一般是 Java 业务使用较多，广泛应用在大数据领域。

### 24 | 运维：如何构建高可靠的etcd集群运维体系？
### 希望通过这节课，帮助你构建高可靠的etcd集群运维体系。

### 特别放送 | 成员变更：为什么集群看起来正常，移除节点却会失败呢？
### 受唐聪邀请，我将给你分享一个我前阵子遇到的有趣的故障案例，并通过这个案例来给你介绍下etcd的成员变更原理。

### 结课测试题｜这些相关etcd知识你都掌握了吗？
### 《etcd实战课》课程即将结课，来做一个小测试吧！

