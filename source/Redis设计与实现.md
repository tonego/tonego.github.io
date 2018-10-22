
###### 4.字典
```
typedef struct dict {
    dictType *type;
    void *privdata;
    dictht ht[2];
    in trehashidx; /* rehashing not in progress if rehashidx == -1 */
} dict;
typedef struct dictht {
    dictEntry **table;
    unsigned long size;
    unsigned long sizemask;     //哈希表大小掩码，用于计算索引值 //总是等于size-1
    unsigned long used;           // 该哈希表已有节点的数量
} dictht;
typedef struct dictEntry {
    void *key;
    union{
        void *val;
        uint64_tu64;
        int64_ts64;
    } v;
    struct dictEntry *next;
} dictEntry;
```
* Redis使用MurmurHash2算法来计算键的哈希值
* rehash。 ht[1]的大小为第一个大于等于ht[0].used x 2的2n（2的n次方幂）
* 自动扩展： 未执行BGSAVE|BGREWRITEAOF负载因子大于等于1。正在执行BGSAVE命令或者BGREWRITEAOF命令，并且哈希表的负载因子大于等于5。
* 负载因子= 哈希表已保存节点数量/ 哈希表大小。 load_factor = ht[0].used / ht[0].size
* 哈希表的负载因子小于0.1时，程序自动开始对哈希表执行收缩操作。
* 渐进式rehash：操作一个键的话，程序会先在ht[0]里面进行查找，如果没找到的话，就会继续到ht[1]里面进行查找
* 在rehash进行期间，每次对字典执行添加、删除、查找或者更新操作时，程序除了执行指定的操作以外，还会顺带将ht[0]哈希表在rehashidx索引上的所有键值对rehash到ht[1]，当rehash工作完成之后，程序将rehashidx属性的值增一
* 每次在进行SET/GET操作时，都会保证向前遍历旧数组1～10步，最终ht[0]将被遍历完，而ht[1]将越来越多

###### 7.压缩列表 ZIPLIST
```
zlbytes zltail zllen entry1 entry2{previous_entry_length encoding content} zlend
```
* 压缩列表是从表尾向表头遍历的，
* previous_entry_length 1字节或5字节； 如果前一节点的长度大于等于254字节，那么previ-ous_entry_length属性的长度为5字节：其中属性的第一字节会被设置为0xFE（十进制值254），而之后的四个字节则用于保存前一节点的长度。
* encoding 字节数组00开头1字节长，01 2， 10 5； 整数编码11开头1字节长
* 连锁更新。有多个连续的长度介于250字节到253字节之间的节点e1-eN，这些都只需1字节长的previous_entry_length，若e1增加长度便会引发连锁更新。这时最坏复杂度为O(N²)，出现的几率可以忽略

###### 8.对象
```
STRING: INT EMBSTR RAW
LIST: ZIPLIST LINKEDLIST
HASH: ZIPLIST HT
SET: INTSET HT
ZSET: ZIPLIST SKIPLIST
```

###### 18.发布与订阅
```
struct redisServer { dict *pubsub_channels;  list *pubsub_patterns;};
```
* 服务器状态在pubsub_channels字典保存了所有频道的订阅关系：SUBSCRIBE命令负责将客户端和被订阅的频道关联到这个字典里面，而UNSUBSCRIBE命令则负责解除客户端和被退订频道之间的关联。
* 服务器状态在pubsub_patterns链表保存了所有模式的订阅关系：PSUBSCRIBE命令负责将客户端和被订阅的模式记录到这个链表中，而PUNSUBSCRIBE命令则负责移除客户端和被退订模式在链表中的记录。
* PUBLISH命令通过访问pubsub_channels字典来向频道的所有订阅者发送消息，通过访问pubsub_patterns链表来向所有匹配频道的模式的订阅者发送消息。
* PUBSUB命令的三个子命令都是通过读取pubsub_chan-nels字典和pubsub_patterns链表中的信息来实现的。

###### 19.事务
```
typedef struct redisClient { multiState mstate;    /* MULTI/EXEC state */ }redisClient
typedef struct multiState {  // 事务队列，FIFO顺序  multiCmd *commands;  // 已入队命令计数  int count;} multiState;
typedef struct redisDb {dict *watched_keys;}
```
* 在事务执行期间，服务器不会中断事务而改去执行其他客户端的命令请求
* client.flags |= REDIS_MULTI
* 当一个客户端切换到事务状态之后, 如果客户端发送的命令为EXEC、DISCARD、WATCH、MULTI四个命令的其中一个，那么服务器立即执行这个命令
* WATCH命令是一个乐观锁（optimistic locking）
* 19.2.2　监视机制的触发: 所有对数据库进行修改的命令，比如SET、LPUSH、SADD、ZREM、DEL、FLUSHDB等等，在执行之后都会调用multi.c/touchWatchKey函数对watched_keys字典进行检查
* 19.2.3　判断事务是否安全: 当服务器接收到一个客户端发来的EXEC命令时，服务器会根据这个客户端是否打开了REDIS_DIRTY_CAS标识来决定是否执行事务
* ACID, 满足A,不支持回滚。 满足CI,不满足D

###### 24. 监视器
* 客户端可以通过执行MONITOR命令，将客户端转换成监视器，接收并打印服务器处理的每个命令请求的相关信息。
* 当一个客户端从普通客户端变为监视器时，该客户端的REDIS_MONITOR标识会被打开。
* 服务器将所有监视器都记录在monitors链表中。
* 每次处理命令请求时，服务器都会遍历monitors链表，将相关信息发送给监视器。
