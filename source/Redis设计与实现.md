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
