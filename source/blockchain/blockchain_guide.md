
## Blockchain https://yeasy.gitbooks.io/blockchain_guide/content/

## 思想
基于算力的共识机制被称为 Proof of Work（PoW）
根据参与者的不同，可以分为公开（Public）链、联盟（Consortium）链和私有（Private）链

## 价值、挑战
Hyperledger 和 Ethereum ，基于区块链再做一层平台层，让别人基于平台开发应用变得更简单。

## 应用场景
金融、征信与权属管理、资源共享、投资管理、物联网与供应链
BitMessage GemHealth Storj Tierion Twister

## 分布式系统问题
随着摩尔定律碰到瓶颈，越来越多的系统要依靠分布式集群架构来实现海量数据处理和可扩展计算能力。
#### 一致性问题
理想的分布式系统一致性应该满足：可终止性（Termination） 共识性（Consensus）合法性（Validity）
强一致性（Strong Consistency）主要包括下面两类：顺序一致性（Sequential Consistency） 线性一致性（Linearizability Consistency）
#### 共识算法
共识算法解决的是对某个提案（Proposal），大家达成一致意见的过程。
把故障（不响应）的情况称为“非拜占庭错误”，恶意响应的情况称为“拜占庭错误”（对应节点为拜占庭节点）
针对非拜占庭错误的情况，一般包括 Paxos、Raft 及其变种。
针对拜占庭错误的情况，一般包括 PBFT 系列、PoW 系列算法等
#### FLP 不可能原理
FLP 不可能原理：在网络可靠，存在节点失效（即便只有一个）的最小化异步模型系统中，不存在一个可以解决一致性问题的确定性算法。
#### CAP 原理
分布式计算系统不可能同时确保一致性（Consistency）、可用性（Availablity）和分区容忍性（Partition）
弱化一致性： CouchDB、Cassandra
弱化可用性： MongoDB、Redis。 Paxos、Raft 等算法，主要处理这种情况
弱化分区容忍性： MySQL
#### ACID
 Atomicity（原子性）、Consistency（一致性）、Isolation（隔离性）、Durability（持久性）
 与之相对的原则是 BASE（Basic Availiability，Soft state，Eventually Consistency）
#### Paxos 与 Raft
 Paxos 共识算法，在工程角度实现了一种最大化保障分布式系统一致性（存在极小的概率无法实现一致）的机制。
 Raft 算法是Paxos 算法的一种简化实现。

## 密码学技术
HASH算法：MD5 SHA 
加解密算法：DES RSA  
数字签名：HMAC 盲签名主要是为了实现防止追踪（unlinkability） 多重签名  群签名  环签名
数字证书：数字证书内容可能包括版本、序列号、签名算法类型、签发者信息、有效期、被签发人、签发的公开密钥、CA 数字签名、其它信息等等
PKI 体系：解决了十分核心的证书管理问题， 用户通过 RA 登记申请证书，CA 完成证书的制造，颁发给用户。用户需要撤销证书则向 CA 发出申请。
    密钥有两种类型：用于签名和用于加解密，对应称为 签名密钥对 和 加密密钥对
Merkle 树， 默克尔树，底层数据的任何变动，都会传递到其父亲节点，一直到树根。典型应用场景包括：快速比较大量数据，快速定位修改，零知识证明
同态加密（Homomorphic Encryption）代数同态+* 算数同态+-*/ 
    仅满足加法同态的算法包括 Paillier 和 Benaloh 算法；仅满足乘法同态的算法包括 RSA 和 ElGamal 算法。
    已知的同态加密技术需要消耗大量的计算时间，还远达不到实用的水平。
函数加密 保护的是处理函数本身
零知识证明（zero knowledge validation）:证明者在不向验证者提供任何有用的信息的前提下，使验证者相信某个论断是正确的。

## 比特币项目
大量类似数字货币（超过 700 种）纷纷出现，被称为“山寨币”，比较出名的包括以太币和瑞波（Ripple）币
https://blockchain.info/
#### 原理和设计
未经使用的交易的输出（ Unspent Transaction Outputs，UTXO）可以被新的交易引用作为合法的输入。
1聪＝ 0.00000001 BTC ＝ 0.00001 mBTC ＝ 0.01 uBTC
比特币的账户地址其实就是用户公钥经过一系列 hash及编码运算后生成的20 字节的字符串。
可以从 blockchain.info 网站查看实时的交易信息。
脚本（Script） 是保障交易完成（主要用于检验交易是否合法）的核心机制
一般每个交易都会包括两个脚本：输出脚本（scriptPubKey）和认领脚本（scriptSig）。
输出脚本目前支持两种类型：P2PKH：Pay-To-Public-Key-Hash，0x00； P2SH：Pay-To-Script-Hash，0x05；
P2PKH scriptPubKey: OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
scriptSig: <sig> <pubKey>
比特币脚本支持的指令集十分简单，非图灵完备
经济博弈原理避免作恶 切蛋糕的人后选  算力消耗拿到新区块
负反馈调节  矿工越多，系统就越稳定，比特币价值就越高，但挖到矿的概率会降低。 比特币的价格理论上恰好达到矿工的收益预期 。 每个区块的比特币奖励每隔 4 年减半，之后将完全依靠交易的服务费来鼓励矿工对网络的维护。
共识机制 被推翻的可能性随着时间而指数级的下降 通过进行 PoW 限制合法提案的个数，提高网络的稳定性
#### 挖矿
算力一般以每秒进行多少次 hash 计算为单位，记为 h/s。
2013 年初，目前单片算力已达每秒数百亿次 Hash 计算。 有人提出用所谓的 PoS（Proof of Stake）和 DPoS。
#### 共识机制
最长的一条队伍是合法的
Pos, 权益证明，Proof of Stake
#### 闪电网络
全网每秒 7 笔的交易速度 等待 6 个块的可信确认导致约 1 个小时的最终确认时间
闪电网络 将大量交易放到比特币区块链之外进行
RSMC（Recoverable Sequence Maturity Contract）解决了链下交易的确认问题  HTLC（Hashed Timelock Contract）解决了支付通道的问题。
RSMC 可撤销的顺序成熟度合同, 类似准备金机制. 
HTLC 哈希的带时钟的合约, 限时转账
#### 侧链
允许资产在比特币区块链和其它链之间互转。降低核心的区块链上发生交易的次数。
Blockstream 基于侧链技术探索更多功能，已发布商业化应用 Liquid，并与普华永道进行相关合作

## Ethereum - 以太坊
以太坊项目进一步扩展了区块链网络的能力，从交易延伸为智能合约（Smart Contract）。
其官网首页为 ethereum.org。
智能合约开发者可以在其上使用官方提供的工具来开发支持以太坊区块链协议的应用（即所谓的 DAPP）。
提供对以太坊网络的数据查看，包括 EthStats.net、EtherNodes.com 

## Hyperledger - 超级账本项目
以比特币为代表的货币区块链技术为 1.0，以以太坊为代表的合同区块链技术为 2.0，那么实现了完备的权限控制和安全保障的 Hyperledger 项目毫无疑问代表着 3.0 时代的到来。
账本平台项目：Fabric SawToothLake Iroha 其它项目：Blockchain Explorer / Cello
