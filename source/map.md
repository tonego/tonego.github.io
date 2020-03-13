## MAP

#### QA
```
Golang use K/V
1. Byte Alignment, if K is 1B. this is reason for buf=8
2. 结合两层hash，计算机局部性原理，多个K顺序比较, 
3. 
```

#### 查找算法 
 * Tree / SkipList / MidSearch / LSM / BF / 
 * 有序查找，
    几乎都是 二分的衍生，
    红黑树（Nginx的timer、Java的TreeMap，linux的完全公平调度器、高精度计时器、ext3文件系统，C++ STL的map、multimap、multiset等.）
    跳表（LevelDB和RocksDB、jave的ConcurrentSkipListMap）
    二叉树、2-3数，红黑树、B数、B+树(千叉树)、斐波那契  
 * 定值查找，hash、Bitmap、 
 * 概率查找，BloomFilter、HyperLogLog(误差0.81%，12K内存就能统计2^64)、 

#### skipList
  在redis类似四叉树
  #define ZSKIPLIST_MAXLEVEL 32 /* Should be enough for 2^32 elements */
  #define ZSKIPLIST_P 0.25      /* Skiplist P = 1/4 */
  bloom的动态生成multi layer bloom也类似这种分层思想，O(logN)

#### skiplist vs 红黑树
 * sl 并发性能好， 锁住的节点更少
 * sl 实现简单
 * 参考 https://stackoverflow.com/questions/256511/skip-list-vs-binary-search-tree/28270537
 
 
#### reference
https://github.com/developer-learning/night-reading-go/issues/393
https://mp.weixin.qq.com/s/2CDpE5wfoiNXm1agMAq4wA
https://github.com/cch123/golang-notes/blob/master/map.md
https://github.com/qcrao/Go-Questions/tree/master/map