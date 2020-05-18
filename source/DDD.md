
### 领域驱动设计 https://zhuanlan.zhihu.com/c_1208715969939640320

Domain-Driven Design

###### 1. started
"The Clean “Architecture” 即整洁架构
「六边形架构」(Hexagonal Architecture)，
「洋葱圈架构」(Onion Architecture) 

适用场景：
1. 涉及的节点非常多，且计算的逻辑牵涉到很多变量，且有很多的分支判断；
2. 牵涉到很多专业术语；

###### 2. 分层架构

application
    Clean Architecture 中的 Application Business Rule
    dto(Data Transfer Object),  service,  
domain
    bc1, Bounded Context(限界上下文)
        exception, model（充血模型）， repository， service，event(producer, handler)
facade
    rest, ws
infrastructure
    persistence, logging, datasource, db

问题
    三种类型数据对象 DTO Domain PO(Persistence Object). 引入 Model Mapper
    模糊的Module和BC,     
    事务问题
    架构复杂性， ci、code review、单测
    
###### 3. Entity, Value Object
    
