-- 《etcd实战课》
 
## 开篇词｜为什么你需要学习业务建模？

业务建模首先是一个定义问题的方法，其次才是解决问题的方法。
如果没有搞清楚要解决什么问题，就可能需要各种奇技淫巧去弥补问题定义上的不足。
程序员为了逃避理解问题并给出定义，最后通常就会成为只会倒腾各种技术方案的架构师。
业务建模就是明确业务中的关键问题，使用易于实现的模型将业务问题表达出来。
业务建模真正的难点有两个：清晰地定义业务问题，并让所有干系人都接受你对业务问题的定义；在特定架构的约束下，将模型实现出来。
业务建模的方法： 着眼数据库设计的实体关系法（E-R Modeling），到面向对象分析与设计法（Object Oriented Analysis and Design），再到围绕知识消化的领域驱动设计（Domain Driven Design），不一而足。
定义业务问题，是指对业务问题的梳理和总结，明确对业务的影响及产出。挑战在于在于如何获取业务方的信任，并展开有效的讨论。
业务建模方法成了一种“所有人都在谈论它，但是没人知道具体怎么做；所有人都觉得其他人在使用它，于是只能声称自己也在用的东西”。
需要转移自己的关注点。不要太在意获得模型是否完美，是否在概念上足够抽象，是否使用了模式，等等。反而，我们更应该关注该如何围绕模型，建立有效的沟通与反馈机制。也就是说，该怎么将模型中蕴含的逻辑讲给别人听。并且还要让别人能听懂，能给出反馈。
理想的模型，需要是所有人都能懂的模型
对架构演化趋势保持足够的关注度。
领域驱动设计方法。领域驱动设计时至今日仍是绝大多数人进行业务建模的首要方法。作为一种建模方法，它并不是那么出色，然而在如何引领需求发掘，如何建立沟通反馈，如何与业务方共建模型等问题上，提供了一套出色的框架。
过去十五年“前云时代”： 催化剂法、角色 - 目标 - 实体法、事件风暴与四色法，以弥补领域设计在建模能力上的缺陷。
新约：“云时代”的业务建模： 微服务、中台、软件的 SaaS 化都是这一影响的体现。
8X Flow 法，用于解决以微服务、分布式事务为主导的架构风格中的业务建模问题。这个方法同样可以用于构建中台系统
SaaS 化业务建模的方法：魔球服务建模法（Magic Ball Offering Modeling）。它是一种从运营角度出发，构造 SaaS 化服务的方法。
字匠（Word Smith） 对于某个概念，可以寻找到极端贴切，而又饶有趣味的命名。
对定义问题的偏执，让他们获得了长久而成功的职业生涯。

## 旧约:“前云时代”的领域驱动设计
## 理解领域驱动设计
## 01领域驱动设计到底在讲什么?
### 领域模型对于业务系统是更好的选择
Eric 倡导的领域驱动设计是一种模型驱动的设计方法：通过领域模型（Domain Model）捕捉领域知识，使用领域模型构造更易维护的软件。

模型在领域驱动设计中，其实主要有三个用途：通过模型反映软件实现（Implementation）的结构；以模型为基础形成团队的统一语言（Ubiquitous Language）；把模型作为精粹的知识，以用于传递。

当开发人员谈论树的时候，它们不仅仅指代这种数据结构，还暗指了背后可能存在的算法与行为模式，以及这种行为与我们当前要解决的业务功能上存在什么样的关联。但业务方并不了解，那么在他们的头脑中也就无法直观地映射为业务的流程和功能。这种认知上的差异，会造成团队沟通的困难，从而破坏统一语言的形成，加剧知识传递的难度。

构造一种专用的模型（领域模型），将相关的业务流程与功能转化成模型的行为，就能避免开发人员与业务方的认知差异。

这一理念的转变开始于面向对象技术的出现，而最终的完成，则是以行业对 DDD 的采纳作为标志的。

在 DDD 中，Eric Evans 提倡了一种叫做知识消化（Knowledge Crunching）的方法帮助我们去提炼领域模型。这么多年过去了，也产生了很多新的提炼领域模型的方法，但它们在宏观上仍然遵从知识消化的步骤。

知识消化的五个步骤： 关联模型与软件实现；基于模型提取统一语言；开发富含知识的模型；精炼模型；头脑风暴与试验。

“两关联一循环”：“两关联”即：模型与软件实现关联；统一语言与模型关联；“一循环”即：提炼知识的循环。

### 模型与软件实现关联
比起模型的好坏（总是会改好的），关联模型与软件实现就变得更为重要了。

这种反直觉的选择，背后的原因有两个：一是知识消化所倡导的方法，它本质上是一种迭代改进的试错法；第二则是一些历史原因。

“富含知识的模型（Knowledge Rich Model）”。我们强调模型与实现关联，实际上也就在变相强调面向对象技术在表达领域模型上的优势。

### 从贫血模型到富含知识的模型
“贫血对象模型”（Anemic Model）的实现风格，即：对象仅仅对简单的数据进行封装，而关联关系和业务计算都散落在对象的范围之外。

“充血模型”，也就是与某个概念相关的主要行为与逻辑，都被封装到了对应的领域对象中。“充血模型”也就是 DDD 中强调的“富含知识的模型"。

Eric 在 DDD 中总结了构造“富含知识的模型”的一些关键元素：实体（Entity）与值对象（Value Object）对照、通过聚合（Aggregation）关系管理生命周期等等。

User（用户）是聚合根（Aggregation Root）；Subscription（订阅）是无法独立于用户存在的，而是被聚合到用户对象中。

### 通过聚合关系表达业务概念
在我们的概念里，与业务概念对应的不仅仅是单个对象。通过关联关系连接的一组对象，也可以表示业务概念，而一部分业务逻辑也只对这样的一组对象起效。但是在所有的关联关系中，聚合是最重要的一类。它表明了通过聚合关系连接在一起的对象，从概念上讲是一个整体。

“富含知识的模型”将我们头脑中的模型与软件实现完全对应在一起了——无论是结构还是行为。

这显然简化了理解代码的难度。只要我们在概念上理解了模型，就会大致理解代码的实现方法与结构。同样，也简化了我们实现业务逻辑的难度。通过模型可以解说的业务逻辑，大致也知道如何使用“富含知识的模型”在代码中实现它。

### 修改模型就是修改代码
如果不停下来等待，模型与软件间的割裂，就会将模型本身分裂为更接近业务的分析模型，以及更接近实现的设计模型（Design Model）。这个时候，分析模型就会逐渐退化成纯粹的沟通需求的工具，而一旦脱离了实现的约束，分析模型会变得天马行空，不着边际。




## 02统一语言是必要的吗?
### 统一语言是基于领域模型的共同语言
统一语言（Ubiquitous Language）是一种业务方与技术方共同使用的共同语言（Common Language），业务方与技术方通过共同语言描述业务规则与需求变动。可以说，共同语言为双方提供了协作与沟通的基础。

客户、产品、业务、业务分析师、解决方案架构师、用户体验设计师等等

共同语言也有很多种形式。比如，用户画像（User Persona）与相关的用户旅程（User Journey） ，就能从流程角度有效地构成共同语言。再比如，数据字典（Data Dictionary）在很长的时间里，也是从软件实现侧形成共同语言的依据。

不过领域驱动设计中的统一语言，特指根据领域模型构造的共同语言。这也是为什么要为它特意构造一个专有且生僻的词汇 Ubiquitous Language，来和我们一般意义上的共同语言作出区分。

业务方大多习惯从业务维度（Business Perspective），比如流程、交互、功能、规则、价值等出发去描述软件系统，这是业务方感知软件系统的主要途径。而模型则偏重于数据角度，描述了在不同业务维度下，数据将会如何改变，以及如何支撑对应的计算与统计。

模型是从已知需求中总结提炼的知识，这就意味着模型无法表达未知需求中尚未提炼的知识。

需要一种能与模型关联的共同语言，它既能让模型在核心位置扮演关键角色，又能弥合视角差异，并提供足够的缓冲

20 世纪末 21 世纪初的模型驱动架构（Model Driven Architecture），就建议业务人员直接使用模型描述需求，然而并没有取得成功。因为相对于模型的精确，统一语言的模糊反而更能满足人与人之间交流的需求。

### 修改代码就是改变统一语言

修改代码就是修改模型，改变模型就是改变统一语言，修改代码等于改变统一语言。这是一个强而有力的推论，因为它描述了这样一种可能的场景：不是因为需求变更，而是因为代码重组与重构引起的代码修改，最终会反映到统一语言中，反映到我们应该如何理解并沟通的需求上去

统一语言可以包含以下内容：源自领域模型的概念与逻辑；界限上下文（Bounded Context）；系统隐喻；职责的分层；模式（patterns）与惯用法。

统一语言是在使用中被确立的。


## 03我们要怎么理解领域驱动设计?

### 将提炼知识的循环看作开发流程

### 研发方与业务方的协同效应
知识消化以一种权责明确的方式，让业务方与技术方参与到对方的工作中。同时也在整体上，给予了业务方和技术方一种更好的协同方式。

软件开发的核心难度就在于处理隐藏在业务知识中的复杂度。

“领域驱动设计”至少可以指代一种建模法，一种协同工作方式和一种价值观，以及上述三种按照随意比例的混合。

### 迭代式试错建模法
“知识消化是一个探索的过程，你不可能知道你将会在哪里停止。”其实后面还有他没直接说的一句话：“你可能还不知道当你停止时，得到的是垃圾还是宝藏。”这部分只能交给建模者的抽象能力，然后希冀一个好的结果。

哪个模型更好呢？不好说，要看在具体需求上哪一个能更好地应对变化。
### 具有协同效应的工作方式
为什么统一语言与提取知识的循环可以构成一种具有协同效应的工作方式。首先是权利与义务的对等构成了协同的基础。依赖于建模者的变革管理能力。行为改变，需要变革管理去推动。知识消化希望通过头脑风暴与试验的方法，简化这种变革。
### 价值观体系
领域驱动设计是一种模型驱动的设计方法：模型应处在核心；两关联一循环：业务与技术围绕着模型的协同。

使用“知识消化”来代替泛化的“领域驱动设计”

### 总结
“领域驱动设计”至少可以指代一种建模法，一种协同工作方式和一种价值观。作为建模法，领域驱动设计是迭代改进试错法。这是一种保底可行，但可能效率不高的建模方法。

缺点： 迭代试错效率真的不高；给了技术人员不去学习业务的借口；一旦无法形成真的统一语言，提炼知识的循环也就无法进行了；

知识消化法其实更适合敏捷团队。无论是通过统一语言协同交互，还是提炼知识的循环，都需要对这种跨工种协同以及渐进式改进方式有足够的认同。

领域驱动设计和知识消化法更多地被当作一种框架性方法来使用。
## 具体实现策略
## 04跨越现实的障碍(上):要性能还是要模型?
要么是一次性读入全部数据，避免 N + 1 问题；要么是引入 N+1 问题，变成钝刀子割肉。

分页查询的逻辑要放在哪个对象上，才能保持模型与软件实现的关联。

一种做法是为订阅（Subscription）构造一个独立的 Repository 对象，将逻辑放在里面（也是 Spring 推荐的做法） 导致逻辑泄露。非聚合根提供 Repository 是一种坏味道。

如果聚合到 User 上是可行的吗？其实也不行。因为这么做会将技术实现细节引入领域逻辑中，而无法保持领域逻辑的独立。

为什么在我们的概念中，我们会认为内存中的集合与数据库是等价的，是可以通过集合接口封装的呢？这就要从面向对象技术的开端——Smalltalk 系统说起

### Smalltalk 中集合与数据库是等价的

### 多层架构彻底割裂了集合与数据库
多层架构彻底割裂了对象集合与数据库，这对我们实现领域模型建模提出了挑战，对 Collection 逻辑的建模也就难以摆脱具体实现细节了。那就是我们必须明确哪些是持久化的数据，并对它的一些逻辑区别对待。

原味面向对象范型（Vanilla Object Oriented），在架构风格演化过程中遇到的挑战。

### 关联对象

关联对象，顾名思义，就是将对象间的关联关系直接建模出来，然后再通过接口与抽象的隔离，把具体技术实现细节封装到接口的实现中。这样既可以保证概念上的统一，又能够避免技术实现上的限制。

使用关联对象实现聚合关系

隔离技术实现细节与领域逻辑

关联对象就是对这一条建议自然的扩展：使用自定义关联对象，而不是集合类型来表示对象间的关联。

通过集体逻辑揭示意图

所谓集体逻辑，是指个体不具备，而成为一个集体之后才具备的能力。哪怕是同一群个体，组成了不同的集体，就会具有不同的逻辑。

关联对象实际上是通过将隐式的概念显式化建模来解决问题的，这是面向对象技术解决问题的通则：永远可以通过引入另一个对象解决问题。
## 05跨越现实的障碍(中):是富含知识还是代码坏味道?
上下文过载，就是指领域模型中的某个对象会在多个上下文中发挥重要作用，甚至是聚合根。

角色对象（Role Object）和上下文对象（Context Object）这两种。

一个对象中包含了不同的上下文，而这恰好是坏味道过大类（Large Class）的定义。

过大类导致 是模型僵硬。上下文的过载就变成了认知的过载（Cognitive Overloading），而认知过载就会造成维护的困难。通俗地讲，就是“看不懂、改不动”

过大类还容易滋生重复代码、引入偶然耦合造成意外的缺陷等编码上的问题。

### 逻辑汇聚于上下文还是实体？
原味面向对象范型（也是领域驱动设计的默认风格）的答案是汇聚于实体，但是缺少有效分离不同上下文的方式。而 DCI 范型（Data-Context-Interaction，数据 - 上下文 - 交互）要求汇聚于显式建模的上下文对象（Context Object），或者上下文中的角色对象（Role Object）上。

通过角色对象分离不同上下文中的逻辑

通过装饰器（Decorator），我们可以构造一系列角色对象（Role Object）作为 User 的装饰器：

通过上下文对象分离不同上下文中的逻辑




## 06跨越现实的障碍 (下):架构分层就对了吗?
能力供应商（Capability Provider）模式。面向对象基础原则 SOLID 的综合应用。

将技术组件进行拟人化处理。转账的是出纳（Cashier），通知用户的是客服（Customer Service）。

从具体实现方法中寻找到一个抽象接口，然后将从对具体实现的依赖，转化为对接口的依赖（SOLID 中的里氏替换原则）。

通过从技术组件抽象具有业务含义的能力，我们就能将基础设施转变为具有这种能力的供应商。于是，我们就能帮助领域层实现了它希望的那种“不正当关系”，既使用了基础设施，又对它没有依赖：我们依赖的是领域层内的能力接口（SOLID 中的接口隔离原则），而不是基础设计的实现（SOLID 中的倒置依赖原则）。

我们可以将基础设施，看作对不同的层的扩展或贡献（SOLID 的开闭原则）

是否觉得能力供应商这个模式有点眼熟？没错儿，它就是关联对象、角色对象和上下文对象的元模式（Meta Pattern）

我个人建议分成三层：展示层、应用层与领域层。不仅要将基础设施作为能力供应商配合其他层来使用，同时通过能力供应商模式，来实现层与层之间的双向交互，这样就不用担心会带来额外的依赖了。

能力供应商模式是一个元模式，关联对象、角色对象和上下文对象可以看作它的具体应用。熟练掌握这个模式，你就可以根据需要发明自己的领域驱动实现模式了。

## 其他建模方法
## 07统一语言可以是领域模型本身吗?

业务方很难从领域模型中感受到业务维度（流程、交互、功能、规则、价值等），所以这也正是我们需要额外构造统一语言的原因。
业务方可以理解的领域模型称作业务友好与可读（Business friendly and readable）的模型： 催化剂建模法及其变体（Catalysis Modeling and its variants）；事件建模法（Event-based Modeling）。


催化剂建模法（以下均称“催化剂方法”）是一种尝试将流程视角引入对象建模的方法。共享词汇表（Shared Vocabulary）就是催化剂版本的统一语言。

催化剂方法更强调对模型本身的构造，而不是依赖一个试错的过程去逼近真相。当然，这也使它看起来更像一种重设计的方法（Big Upfront Design）。

催化剂方法最大的特点在于，将交互（interaction）显式地建模到对象模型中。

借由领域模型，双方能就需求的具体范围、风险和成本形成一定的共识，从而避免猜忌性施压与扯皮。

角色 - 目标 - 实体法（Role-Goal-Entity）
交互被直接建模到模型中了，那么我们要怎么关联模型与软件实现呢？我们是选择性地忽略交互与角色，还是将交互实现成某种特定的组件呢？
可以提高业务方对领域模型的认同感。
角色 - 目标 - 实体法更像一种共创方法，它由研发人员建立领域模型，然后再解释给业务方。
可以将角色 - 目标 - 实体法当作催化剂方法的简化版。

## 08能在讨论中自然形成统一语言的方法是什么?
事件建模法（Event-based modeling）。

实际操作的过程中，角色 - 目标 - 实体法仍然存在收集 - 建模 - 说服这三步。

有代表性的事件建模法，一种是目前 DDD 社区热捧的事件风暴法（Event Storming），另一种是我从 Peter Coad 的彩色建模中演化出的四色建模法。

事件建模法的基本原则（1）：通过事件表示交互

按照记叙文六要素去想：时间、地点、人物、起因、经过和结果。

事件建模法的基本原则（2）：通过时间线划分不同事件

## 09怎么才能更有效地获取事件流?

将事件建模与彩色建模法结合形成了四色建模法，用以获得更具业务含义的模型，以便直接使用模型作为统一语言。
头脑风暴法的不足：成功取决于收敛逻辑
事件风暴法变成了那种“一学就会，一用就废”的方法。
直接从收敛逻辑出发，通过引导 - 分析直接获取事件流
四色法的核心逻辑：从收入流与成本结构中寻找事件


## 10如何将模型实现为RESTfulAPl?
## 新约:云时代的业务建模
## 11云时代的挑战(上):弹性边界还是业务边界?
## 12云时代的挑战(下):如何保持弹性边界的独立性?
## 138X Flow(上):何为业务?何为领域?
## 148XFlow(中):如何通过模型发现业务系统的变化点?
## 158X Flow(下):案例讲解与分析
## 16中台建模(上):到底什么是中台?
## 17中台建模(中):如何寻找可复用的业务模式?
## 18中台建模(下):案例讲解与分析
## 19如何将模型实现为微服务?
## 20云时代的下一站:SaaS化与魔球建模法
## 结束语|制琴如何让我成为一名更好的程序员?