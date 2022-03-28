## 分布式

#### 分布式锁
* redis setnx

###### 业务示例
* ibag, redis-lua, set uuid 0 -> set value -> set uuid 1. 
* 可用于一致性保证。失败的入队列，补单程序校验uuid是0是1
* 问题： 失败入队列失败再怎么办

#### 分布式一致性算法
* CAP 理论
* 2P (two phase commit) undo redo log
* 3P (can->prepare->commit) 所有数据结点list存储，循环执行操作，设立flag标记状态。根据flag状态，执行操作或回滚。
* BASE (basic available / soft state / Eventually consistent )
* Paxos 
* Raft 


#### 分布式
* 