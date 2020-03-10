## Raft

#### 大纲
* Leader Election / Log Replication
* Leader/candidate/Follows/ vote/term/Append Entries messages
* Two Timeout: election timeout (150-300ms) / heartbeat timeout

##### 关键点
* 同类 gossip/Paxos/Raft

##### QA

* 为何raft要异步跟随心跳 set value， 而不是同步进行 
* 为何rate要分两次set value, 先等majority确认，再返回，再跟下一次心跳set value   ---- 两阶段提交避免回滚
* 若第二阶段提交时commit失败，接下来怎么办的。 

##### reference
http://thesecretlivesofdata.com/raft/