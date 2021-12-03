## Caelus

#### Caelus -腾讯基于 Kubernetes 的全场景在线离线混部解决方案
陈东东 - 腾讯云数据平台部

#### CPU 利用率提升至 55%，网易轻舟基于 K8s 的业务混部署实践
- 张晓龙，网易技术委员会委员，网易数帆轻舟事业部技术总监

https://www.infoq.cn/article/pfmfpuxzbczronwdajpw

#### 高途-趣头条成本优化交流
许文君、王振华、邢皖甲...
###### 容器化
服务容器化切量
    快速回滚、预关机、可灰度、可监控。
巡检系统
    分析k8s的所有事件日志。分析报告、自动干预。
调度优化管理
    参考资源画像调度。 扩展的调度器，优化了node的负载均衡。
    case: 算法的pod负载高把node hang住io内核崩溃， 针对io的多快盘处理，数据盘独立。
资源管理
    req和limit两倍差距。比esc少一倍。
    inject。 超分一倍；针对使用率低的节点进行动态超分。
    超卖。-
    oversold-extender： 过滤CPU超80%的机器；单机器单服务副本数不能超一半；离线服务压制；CPU高服务打散；
    只针对CPU的超分。 虚报CPU核数。 内存超分容易OOM没有用。
常见问题-CNI插件
    20个多集群。
    Terway v1. VPC模式，NAT转换，redis等被调用方只能看到NodeIP
        单个VPN路由上限2k条。静态路由。
        每个node有一批的podIP段。类vxlan方式，fnl. 
        访问外部服务，需要进行一次SNAT操作，conntrack表，访问ClsterIP, 系统会做一次DNAT。五元组的IP重用的reset。
        conntrack被打满。后续建立连接超时。 dmesg -T: kernel: nf_contrack: table full, dropping packet.
        conntrack表插入有可能同步竞争，导致第二条插入失败，连接建立失败。conntrack -S: insert_failed xxx； iptables 1.6.2启用 --random-fully
        conntrack表记录未过期，复用记录导致连接超时， 特别服务升级过程中，发起方大量建连，conntrack的后端pod地址以及销毁。 
    Terway v2. ENI, 虚拟网卡对veth。 CPU消耗，可以看到PodIP。 会发现数据重传变多。
    高内核版本， ipvlan模式。 真实网卡分多子接口，不经过虚拟网卡对，少一次软中断。
网络抖动问题
    ping命令延时大。每10s延时增高一次。
        内核的slab dentry缓存过大，阿里旧版本云监控定时调用slabtop获取缓存信息；
        entry大是因为服务调用php使用了Http::servicePostWithABWithRAL方式， contentType Http::CONTENT_TYPE_UPLOAD,导致每次请求都会生成临时文件。
        解决方案： echo 2 > /proc/sys/vm/drop_caches && sync;  Content-Type: application/x-www-form-urlencoded
    7层SLB使用NodePort方式，timestamp差别大，连接异常。 后端TIME_WAIT接受到端口相同的SYN请求，server不回复SYN+ACK，而只回复的SYN。
    在算法的机器上ping k8s节点的机器发现ping延时相对比较严重，高达200ms?
        node机器规模104core * 24000+规则。 ipvs统计，2s一次，每条规则的metrics如pps/bandwidth等，导致网卡中断绑定。
        改统计方式，内核热修1h一次。 规模大，service多的场景。 
NodePort负载不均衡
    连接均衡非负载均衡； redis跨区；服务长连接 客户端请求量不均；   
HPA针对整个集群，而非单实例。有容忍值+时间。
环路问题。 访问端与被访问端处于同一主机。
ip rule规则过多。 terway v2早期版本bug，删除规则导致残留。aliyun已升级。 
感知宿主机CPU核数。 用GO_MAX_PROC注入环境变量,  JAVA高版本已解决。  lxcfs
容器发布过程中，sleep 15s。 
排查pod日志， 用sls。
容器中服务调用第三方服务作为子进程的时候出现僵尸进程， 如 截屏服务使用/usr/bin/google-chrome.
集群资源不够。 5-10扩node。 自动触发ess扩Node。 eci扩pod费用高比包年高3-4倍。 auto_scale组件。
docker runtime 遇到问题。
某些pod一直在terminating状态。可能是宿主机docker daemon异常。 使用systemctl daemon-reexec
nodeport负载不均衡。slb-nodePort(ipvs/iptables).  若是http或者ingress会好很多。
QA： 1-2到1-6， 1.0-1.5。    买1-2的机器， 混布1-4.  神农机网卡优化。 104core 484mem.
阿里云的k8s的master在自己手上。  
神农机3min加载资源， 5min起pod。 eci快。
分集群。合并资源池。 核心池+混布池。
k8s费用分摊。不同定价。一个集群4w pod。

###### 混布
实时+计算。隔离+调度技术。 
业内服务的CPU均值能做到50%， 混布27-35%， 分时调用。
路径： 1. 巡检req+limit  2. 离线混布  3. 离在线混布。
持续推进容器化比例。
在线资源，先找大数据资源，再找ess，再找eci。
大数据1:8，在线1:2。

     
#### reference
- https://cloud.tencent.com/developer/salon/live-1459
- https://docs.qq.com/pdf/DRWFCc0twdUhQWVhR
- 

