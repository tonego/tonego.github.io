# labuladong的算法
labuladong.github.io
labuladong的算法秘籍V1.3.pdf

### 学习数据结构和算法的框架思维 
数据结构的存储方式只有两种：数组（顺序存储）和链表（链式存储）。
数组遍历框架，典型的线性迭代结构;
链表遍历框架，兼具迭代和递归结构.
N叉树的递归遍历方式和链表的递归遍历方式相似.
动规回溯分治等等技巧, 先刷二叉树，因为二叉树是最容易培养框架思维的，而且大部分算法技巧，本质上都是树的遍历问题。
124二叉树中最大路径和: 后序遍历。
105根据前序遍历和中序遍历的结果还原一棵二叉树：前序遍历
99恢复BST：中序遍历
只要涉及递归的问题，都是树的问题。
动态规划详解说过凑零钱问题，暴力解法就是遍历一棵 N 叉树：
回溯算法就是个 N 叉树的前后序遍历问题
数据结构的基本存储方式就是链式和顺序两种，基本操作就是增删查改，遍历方式无非迭代和递归。

### 我的刷题心得
算法的本质就是「穷举」。
难点在「如何穷举」呢？一般是递归类问题，最典型的就是动态规划系列问题。
- 动态规划类型的题目可以千奇百怪，找状态转移方程才是难点，所以才有了 动态规划设计方法：最长递增子序列 这篇文章，告诉你递归穷举的核心是数学归纳法，明确函数的定义，然后利用这个定义写递归函数，就可以穷举出所有可行解。
难点在「如何聪明地穷举」呢？一些耳熟能详的非递归算法技巧：
- Union Find 并查集算法详解 告诉你一种高效计算连通分量的技巧
- 贪心算法就是在题目中发现一些规律（专业点叫贪心选择性质），使得你不用完整穷举所有解就可以得出答案。
- 贪心算法解决跳跃游戏 中贪心算法的效率比动态规划还高
- KMP 算法的本质是聪明地缓存并复用一些信息，减少了冗余计算。

数组/单链表系列算法
- 双指针
- 二分搜索技巧
- 滑动窗口算法技巧。 最大子数组问题。
- 回文串相关技巧
- 前缀和技巧 
- 差分数组技巧

二叉树系列算法。 二叉树模型几乎是所有高级算法的基础。 回溯遍历、动规分解问题。
- 二叉树最大深度、全排列、凑零钱、
- 动归、回溯（DFS）、分治、BFS、
- 比如 图论基础 和 环判断和拓扑排序 就用到了 DFS 算法；再比如 Dijkstra 算法模板，就是改造版 BFS 算法加上一个类似 dp table 的数组。
- 本质都是穷举二（多）叉树，有机会的话通过剪枝或者备忘录的方式减少冗余计算。

## 数组&链表

### 小而美的算法技巧：前缀和数组
前缀和主要适用的场景是原始数组不会被修改的情况下，频繁查询某个区间的累加和。求区间 nums[i..j] 的累加和，只要计算 prefix[j+1] - prefix[i] 即可。
- 303. 区域和检索 - 数组不可变（简单）。 求数组从索引i到j的元素和： preSum[5] - preSum[1]。
- 304. 二维区域和检索 - 矩阵不可变（中等）。 求子矩阵的元素和。  预先计算所有原点为一点的所有矩阵的和；目标矩阵之和由四个相邻矩阵运算获得。
- 560. 和为K的子数组（中等）。求连续子数组个数。  用map存储前缀和出现次数,O(N);  双指针（待验证）。

### 小而美的算法技巧：差分数组
- 370. 区间加法（中等）。 求多个区间加法后的结果数组。
- 1109. 航班预订统计（中等）。 求每个航班预订座位数。
- 1094. 拼车（中等）。 已知公交车乘客行程，求能否把旅客运送完。
差分数组的主要适用场景是频繁对原始数组的某个区间的元素进行增减。构造差分数组 diff，就可以快速进行区间增减的操作。

### 双指针技巧总结
141. 环形链表（简单）。 快慢指针。
142. 环形链表II（简单）。 求环起始位置。
167. 两数之和 II - 输入有序数组（中等）。左右指针。
344. 反转字符串（简单）。
19. 删除链表倒数第 N 个元素（中等）。快慢指针找节点。
876. 链表的中间结点。快慢指针。

一类是「快慢指针」，链表中的问题，比如典型的判定链表中是否包含环；
一类是「左右指针」，数组（或者字符串）中的问题，比如二分查找、两数之和、反转数组、滑动窗口。
当快慢指针相遇时，让其中任一个指针指向头节点，然后让它俩以相同速度前进，再次相遇时所在的节点位置就是环开始的位置。
寻找链表中点的一个重要作用是对链表进行归并排序。

### 我写了首诗，把滑动窗口算法算法变成了默写题
76. 最小覆盖子串（困难）。在S中找出包含T所有字母的最小子串。
567. 字符串的排列（中等）。 s2是否包含s1的排列。
438. 找到字符串中所有字母异位词（中等）。在s中找到所有T的排列，返回起始索引。
3. 无重复字符的最长子串（中等）。
```
/* 滑动窗口算法框架 */
void slidingWindow(string s, string t) {
    unordered_map<char, int> need, window;
    for (char c : t) need[c]++;
    
    int left = 0, right = 0;
    int valid = 0; 
    while (right < s.size()) {
        // c 是将移入窗口的字符
        char c = s[right];
        // 右移窗口
        right++;
        // 进行窗口内数据的一系列更新
        ...

        /*** debug 输出的位置 ***/
        printf("window: [%d, %d)\n", left, right);
        /********************/
        
        // 判断左侧窗口是否要收缩
        while (window needs shrink) {
            // d 是将移出窗口的字符
            char d = s[left];
            // 左移窗口
            left++;
            // 进行窗口内数据的一系列更新
            ...
        }
    }
}
```

### 我写了首诗，让你闭着眼睛也能写对二分搜索
704. 二分查找（简单）。 while(left <= right) ；left = mid + 1，right = mid - 1；局限无法找边界。
34. 在排序数组中查找元素的第一个和最后一个位置（中等）。 while (left < right)；「搜索区间」是 [left, right) 左闭右开，left = mid + 1，right = mid；若是两端都闭的「搜索区间」需要检查出界。
总结
1、分析二分查找代码时，不要出现 else，全部展开成 else if 方便理解。
2、注意「搜索区间」和 while 的终止条件，如果存在漏掉的元素，记得在最后检查。
3、如需定义左闭右开的「搜索区间」搜索左右边界，只要在 nums[mid] == target 时做修改即可，搜索右侧时需要减一。
4、如果将「搜索区间」全都统一成两端都闭，好记，只要稍改 nums[mid] == target 条件处的代码和返回的逻辑即可，推荐拿小本本记下，作为二分搜索模板。
二分：
```
因为我们初始化 right = nums.length - 1
所以决定了我们的「搜索区间」是 [left, right]
所以决定了 while (left <= right)
同时也决定了 left = mid+1 和 right = mid-1

因为我们只需找到一个 target 的索引即可
所以当 nums[mid] == target 时可以立即返回
```
左边界
```
因为我们初始化 right = nums.length
所以决定了我们的「搜索区间」是 [left, right)
所以决定了 while (left < right)
同时也决定了 left = mid + 1 和 right = mid

因为我们需找到 target 的最左侧索引
所以当 nums[mid] == target 时不要立即返回
而要收紧右侧边界以锁定左侧边界
```
右边界
```
因为我们初始化 right = nums.length
所以决定了我们的「搜索区间」是 [left, right)
所以决定了 while (left < right)
同时也决定了 left = mid + 1 和 right = mid

因为我们需找到 target 的最右侧索引
所以当 nums[mid] == target 时不要立即返回
而要收紧左侧边界以锁定右侧边界

又因为收紧左侧边界时必须 left = mid + 1
所以最后无论返回 left 还是 right，必须减一
```

### 如何去除有序数组的重复元素
一文秒杀四道原地修改数组的算法题 https://labuladong.github.io/algo/2/21/68/
快慢指针：
26. 删除有序数组中的重复项（简单）。 快慢指针。
83. 删除排序链表中的重复元素（简单）
27. 移除元素（简单）。 原地移除val元素。
283. 移动零（简单）。

### 一文搞懂单链表的六大解题套路
21. 合并两个有序链表（简单）。 虚拟头dummy结点
23. 合并K个升序链表（困难）。 优先级队列（二叉堆）； O(Nlogk)
141. 环形链表（简单）
142. 环形链表 II（中等）
876. 链表的中间结点（简单）
19. 删除链表的倒数第 N 个结点（中等）
160. 相交链表（简单）。长度差；后向前；

### 递归反转链表的一部分
206. 反转链表（简单）。 递归法将「以 head 为起点」的链表反转，并返回反转之后的头结点。
92. 反转链表II（中等）。反转m-1到n-1. 递归1先Next到起点，递归2实现递归前n个节点。

### 如何 K 个一组反转链表
25. K个一组翻转链表（困难）
- 1、先反转以 head 开头的 k 个元素。
- 2、将第 k + 1 个元素作为 head 递归调用 reverseKGroup 函数。
- 3、将上述两个过程的结果连接起来。

### 如何判断回文链表
234. 回文链表（简单）
- 把原始链表反转存入一条新的链表，然后比较这两条链表是否相同。 时间和空间复杂度都是 O(N)。
- 正序打印链表中的 val 值，可以在前序遍历位置写代码；反之，如果想倒序遍历链表，就可以在后序遍历位置操作。 时间和空间复杂度都是 O(N)。
- 双指针找中点；反转后面链表； 时间O(N)，空间O(1)

寻找回文串是从中间向两端扩展，判断回文串是从两端向中间收缩。

### 给我常数时间，我可以删除/查找数组中的任意元素
380. 常数时间插入、删除和获取随机元素（中等）。 map无法随机； 数组+倒排索引； 
710. 黑名单中的随机数（困难）。数组+倒排索引；待删除元素换到最后；

## 队列/栈
### 队列实现栈以及栈实现队列
232. 用栈实现队列（简单）。 push/pop/peek/empty; 双栈实现。peek 操作从 s1 往 s2 搬移。均摊时间复杂度是 O(1)
225. 用队列实现栈（简单）。 pop()循环处理，O(N)。

### 如何解决括号相关的问题
20. 有效的括号（简单）。 栈。
921. 使括号有效的最小添加（中等）。 以左括号为基准，通过维护对右括号的需求数 need，来计算最小的插入次数。
1541. 平衡括号串的最少插入（中等）

### 单调栈结构解决三道算法题
496. 下一个更大元素I（简单）。 暴力解O(n^2)。 单调栈O(n)。倒序处理。
503. 下一个更大元素II（中等）。 环形数组，取余、数组长度翻倍。
739. 每日温度（中等）。等到更暖和的天气需要几天。 

单调栈用途不太广泛，只处理一种典型的问题，叫做 Next Greater Element

``` 
vector<int> nextGreaterElement(vector<int>& nums) {
    vector<int> res(nums.size()); // 存放答案的数组
    stack<int> s;
    // 倒着往栈里放
    for (int i = nums.size() - 1; i >= 0; i--) {
        // 判定个子高矮
        while (!s.empty() && s.top() <= nums[i]) {
            // 矮个起开，反正也被挡着了。。。
            s.pop();
        }
        // nums[i] 身后的 next great number
        res[i] = s.empty() ? -1 : s.top();
        s.push(nums[i]);
    }
    return res;
}
```

### 单调队列结构解决滑动窗口问题
239. 滑动窗口最大值（困难）。优于最大堆。O(N)，空间O(k)。
队列中的元素全都是单调递增（或递减）的。可以解决滑动窗口相关的问题。

每次MonotonicQueue的push通过遍历保证递减。push 方法依然在队尾添加元素，但是要把前面比自己小的元素都删掉。
                              
``` 
/* 单调队列的实现 */
class MonotonicQueue {
    LinkedList<Integer> q = new LinkedList<>();
    public void push(int n) {
        // 将小于 n 的元素全部删除
        while (!q.isEmpty() && q.getLast() < n) {
            q.pollLast();
        }
        // 然后将 n 加入尾部
        q.addLast(n);
    }
    
    public int max() {
        return q.getFirst();
    }
    
    public void pop(int n) {
        if (n == q.getFirst()) {
            q.pollFirst();
        }
    }
}
```

### 一道数组去重的算法题把我整不会了
https://mp.weixin.qq.com/s/Yq49ZBEW3DJx6nXk1fMusw

316. 去除重复字母（中等）。 inStack这个布尔数组做到栈stk中不存在重复元素，单调栈配合计数器count不断 pop 掉不符合最小字典序的字符； 
1081. 不同字符的最小子序列（中等）


## 设计
### 设计朋友圈时间线功能
355. 设计推特（中等）
合并多个有序链表的算法和面向对象设计（OO design）结合

设计Twitter 和微博
4个api。 关注、取关、发表动态、动态列表
面向对象：Twitter{ user类、Tweet类 }
算法设计： 实现合并 k 个有序链表的算法需要用到优先级队列（Priority Queue），这种数据结构是「二叉堆」最重要的应用，你可以理解为它可以对插入的元素自动排序。合理的顶层设计

系统设计： https://github.com/donnemartin/system-design-primer/blob/master/solutions/system_design/twitter/README.md

### 算法就像搭乐高：带你手撸 LFU 算法
https://labuladong.github.io/algo/2/20/46/
LFUCache {
    // key 到 val 的映射，我们后文称为 KV 表
    HashMap<Integer, Integer> keyToVal;
    // key 到 freq 的映射，我们后文称为 KF 表
    HashMap<Integer, Integer> keyToFreq;
    // freq 到 key 列表的映射，我们后文称为 FK 表
    HashMap<Integer, LinkedHashSet<Integer>> freqToKeys;
    // 记录最小的频次
    int minFreq;
    // 记录 LFU 缓存的最大容量
    int cap;
}

### TWOSUM问题的核心思想
1. 两数之和（简单）. 用哈希表； 若有序双指针
170. 两数之和 III - 数据结构设计（简单）。 记录所有可能组成的和； 哈希集合


### 一个方法团灭 NSUM 问题
一个函数秒杀 2Sum 3Sum 4Sum 问题 https://mp.weixin.qq.com/s/fSyJVvggxHq28a0SdmZm6Q 

15. 三数之和（中等）
18. 四数之和（中等）

排序，双指针。
## 流
### 一道求中位数的算法题把我整不会了
https://mp.weixin.qq.com/s/oklQN_xjYy--_fbFkd9wMg
295. 数据流的中位数（困难）。两个优先级队列。维护large堆的元素大小整体大于small堆的元素。

## 二叉树

### 二叉堆详解实现优先级队列
二叉堆是完全二叉树，存储在数组。
最大堆的性质是：每个节点都大于等于它的两个子节点。arr[1] 一定是所有元素中最大的元素。
insert : 插末尾；swim；
delMax : 删arr[1]； arr[1]=arr[N]； 删arr[N]； sink;  
上浮 swim :  
```
    while (k > 1 && less(parent(k), k)) {
       // 如果第 k 个元素比上层大
       // 将 k 换上去
       exch(parent(k), k);
       k = parent(k);
   }
```
下沉 sink 
```
    // 如果沉到堆底，就沉不下去了
    while (left(k) <= N) {
        // 先假设左边节点较大
        int older = left(k);
        // 如果右边节点存在，比一下大小
        if (right(k) <= N && less(older, right(k)))
            older = right(k);
        // 结点 k 比俩孩子都大，就不必下沉了
        if (less(older, k)) break;
        // 否则，不符合最大堆的结构，下沉 k 结点
        exch(k, older);
        k = older;
    }
```

### 手把手带你刷二叉树（纲领篇）
104. 二叉树的最大深度（简单）。 前序位置depth++, 后序位置depth--；
543. 二叉树的直径（简单）。 任意两个结点之间的路径长度。 最大深度；后序位置
144. 二叉树的前序遍历（简单）。
节点层数。
节点总数。
层序遍历。上到下和左到右两层循环；用queue临时存储每层的节点。

思维用到 动态规划， 回溯算法， 分治算法， 图论算法中
单链表和数组可迭代可递归，二叉树无法迭代只能递归。
前中后序是遍历二叉树过程中处理每一个节点的三个特殊时间点

二叉树题目的递归解法可以分两类思路，第一类是遍历一遍二叉树得出答案，第二类是通过分解问题计算出答案，这两类思路分别对应着 回溯算法核心框架 和 动态规划核心框架。

最大深度:
``` 
void traverse(TreeNode root) {
	if (root == null) {
		// 到达叶子节点，更新最大深度
		res = Math.max(res, depth);
		return;
	}
	// 前序位置
	depth++;
	traverse(root.left);
	traverse(root.right);
	// 后序位置
	depth--;
}
int maxDepth(TreeNode root) {
	if (root == null) {
		return 0;
	}
	// 利用定义，计算左右子树的最大深度
	int leftMax = maxDepth(root.left);
	int rightMax = maxDepth(root.right);
	// 整棵树的最大深度等于左右子树的最大深度取最大值，
    // 然后再加上根节点自己
	int res = Math.max(leftMax, rightMax) + 1;

	return res;
}
```

一道二叉树的题目时的通用思考过程是：是否可以通过遍历一遍二叉树得到答案？如果不能的话，是否可以定义一个递归函数，通过子问题（子树）的答案推导出原问题的答案？
中序位置主要用在 BST 场景中，你完全可以把 BST 的中序遍历认为是遍历有序数组。
前序位置的代码只能从函数参数中获取父节点传递来的数据，而后序位置的代码不仅可以获取参数数据，还可以获取到子树通过函数返回值传递回来的数据。
题目和子树有关，那大概率要给函数设置合理的定义和返回值，在后序位置写代码

BFS 算法框架 就是从二叉树的层序遍历扩展出来的，常用于求无权图的最短路径问题。

### 手把手带你刷二叉树（第一期）
226. 翻转二叉树（简单）。前序位置。
114. 二叉树展开为链表（中等）。
116. 填充每个节点的下一个右侧节点指针（中等）。两个参数。

快速排序就是个二叉树的前序遍历，归并排序就是个二叉树的后序遍历。
```
void sort(int[] nums, int lo, int hi) {
    /****** 前序遍历位置 ******/
    // 通过交换元素构建分界点 p
    int p = partition(nums, lo, hi);
    /************************/

    sort(nums, lo, p - 1);
    sort(nums, p + 1, hi);
}
void sort(int[] nums, int lo, int hi) {
    int mid = (lo + hi) / 2;
    sort(nums, lo, mid);
    sort(nums, mid + 1, hi);

    /****** 后序遍历位置 ******/
    // 合并两个排好序的子数组
    merge(nums, lo, mid, hi);
    /************************/
}
```

### 手把手带你刷二叉树（第二期）
构造二叉树系列。
654. 最大二叉树（中等）。找到最大值；构造左右树。前序位置。
105. 从前序与中序遍历序列构造二叉树（中等）。 head[0]为root；找到inorder中的idx；找到preorder的左右树边界。 build(int[] preorder, int preStart, int preEnd,  int[] inorder, int inStart, int inEnd) 
106. 从中序与后序遍历序列构造二叉树（中等）
889. 根据前序和后序遍历构造二叉树（中等）。通过前序中序，或者后序中序遍历结果可以确定一棵原始二叉树，但是通过前序后序遍历结果无法确定原始二叉树。根preorder[0]；preorder[1]左树根；postorder找左树根的idx；

把题目的要求细化，搞清楚根节点应该做什么，然后剩下的事情抛给前/中/后序的遍历框架就行了，我们千万不要跳进递归的细节里，你的脑袋才能压几个栈呀。

### 手把手带你刷二叉树（第三期）
https://mp.weixin.qq.com/s/LJbpo49qppIeRs-FbgjsSQ
652. 寻找重复的子树（中等）。 后序；序列化描述以该节点为根的二叉树；HashMap记录子树；

### 二叉树的序列化，就那几个框架，枯燥至极
https://mp.weixin.qq.com/s/DVX2A1ha4xSecEXLxW_UsA

297. 二叉树的序列化和反序列化（困难）
用前序、中序、后序遍历、迭代式的层级遍历的方式来序列化和反序列化二叉树

```
/* 辅助函数，通过 nodes 列表构造二叉树 */
TreeNode deserialize(LinkedList<String> nodes) {
    if (nodes.isEmpty()) return null;

    /****** 前序遍历位置 ******/
    // 列表最左侧就是根节点
    String first = nodes.removeFirst();
    if (first.equals(NULL)) return null;
    TreeNode root = new TreeNode(Integer.parseInt(first));
    /***********************/

    root.left = deserialize(nodes);
    root.right = deserialize(nodes);

    return root;
}
```

### 回溯算法解题套路框架
46. 全排列（中等）。track记录路径；递归选择列表（nums排除track）；O(N!)
51. N皇后（困难）。NxN棋盘，N个皇后不能相互攻击。isValid 函数剪枝。最坏O(N^(N+1))。 解数独。

回溯算法其实就是我们常说的 DFS 算法，本质上就是一种暴力穷举算法。
解决一个回溯问题，实际上就是一个决策树的遍历过程。
```
result = []
def backtrack(路径, 选择列表):
    if 满足结束条件:
        result.add(路径)
        return
    
    for 选择 in 选择列表:
        做选择
        backtrack(路径, 选择列表)
        撤销选择
```        
其核心就是 for 循环里面的递归，在递归调用之前「做选择」，在递归调用之后「撤销选择」，特别简单。
写 backtrack 函数时，需要维护走过的「路径」和当前可以做的「选择列表」，当触发「结束条件」时，将「路径」记入结果集。
动态规划的三个需要明确的点就是「状态」「选择」和「base case」，是不是就对应着走过的「路径」，当前的「选择列表」和「结束条件」？
动态规划的暴力求解阶段就是回溯算法。只是有的问题具有重叠子问题性质，可以用 dp table 或者备忘录优化，将递归树大幅剪枝，这就变成了动态规划。

### BFS算法解题套路框架
111. 二叉树的最小深度（简单）。
752. 打开转盘锁（中等）。 双向BFS。

BFS 算法都是用「队列」这种数据结构，每次将一个节点周围的所有节点加入队列。
BFS 相对 DFS 的最主要的区别是：BFS 找到的路径一定是最短的，但代价就是空间复杂度可能比 DFS 大很多
BFS最短路径： 走迷宫、单词替换字符、连连看。
``` 
// 计算从起点 start 到终点 target 的最近距离
int BFS(Node start, Node target) {
    Queue<Node> q; // 核心数据结构
    Set<Node> visited; // 避免走回头路
    
    q.offer(start); // 将起点加入队列
    visited.add(start);
    int step = 0; // 记录扩散的步数
    
    while (q not empty) {
        int sz = q.size();
        /* 将当前队列中的所有节点向四周扩散 */
        for (int i = 0; i < sz; i++) {
            Node cur = q.poll();
            /* 划重点：这里判断是否到达终点 */
            if (cur is target)
                return step;
            /* 将 cur 的相邻节点加入队列 */
            for (Node x : cur.adj()) {
                if (x not in visited) {
                    q.offer(x);
                    visited.add(x);
                }
            }
        }
        /* 划重点：更新步数在这里 */
        step++;
    }
}
```
DFS 是线，BFS 是面；DFS 是单打独斗，BFS 是集体行动。
DFS 空间O(N)
传统的 BFS 框架就是从起点开始向四周扩散，遇到终点时停止；而双向 BFS 则是从起点和终点同时开始扩散，当两边有交集的时候停止。
双向BFS使用HashSet代替队列快速判断交集。

### 动态规划解题套路框架
509. 斐波那契数（简单）。暴力递归；dptable去重；dp数组迭代递推解法；dptable改2；
322. 零钱兑换（中等）。

动态规划问题（Dynamic Programming）
动态规划问题的一般形式就是求最值。动态规划其实是运筹学的一种最优化方法，只不过在计算机问题上应用比较多，比如说让你求最长递增子序列呀，最小编辑距离呀等等。
求解动态规划的核心问题是穷举。存在「重叠子问题」，需要「备忘录」或者「DP table」来优化穷举过程。一定会具备「最优子结构」。列出正确的「状态转移方程」，才能正确地穷举。
重叠子问题、最优子结构（子问题没有相互制约）、状态转移方程就是动态规划三要素。 
明确 base case（终止条件） -> 明确「状态」（变量-参数）-> 明确「选择」 -> 定义 dp 数组/函数的含义。
``` 
# 初始化 base case
dp[0][0][...] = base
# 进行状态转移
for 状态1 in 状态1的所有取值：
    for 状态2 in 状态2的所有取值：
        for ...
            dp[状态1][状态2][...] = 求最值(选择1，选择2...)
```

常见的动态规划代码是「自底向上」进行「递推」求解。一般都脱离了递归，而是由循环迭代完成计算。

### BASE CASE 和备忘录的初始值怎么定？



### 最优子结构原理和 DP 数组遍历方向

### 提高刷题幸福感的小技巧
递归调试：
``` 
 var recurCnt int
 func printIndent(n int){
 	for i:=0;i<n;i++{
 		fmt.Print("	")
 	}
 }
```
在递归函数的开头，调用 recurCnt++; printIndent(recurCnt); fmt.Println(head.Val) 
在return 语句之前调用 printIndent(recurCnt); recurCnt--; fmt.Println(last.Val) 


### 如何寻找最长回文子串
5. 最长回文子串（中等）。  O(N^2)
``` 
public String longestPalindrome(String s) {
    String res = "";
    for (int i = 0; i < s.length(); i++) {
        // 以 s[i] 为中心的最长回文子串
        String s1 = palindrome(s, i, i);
        // 以 s[i] 和 s[i+1] 为中心的最长回文子串
        String s2 = palindrome(s, i, i + 1);
        // res = longest(res, s1, s2)
        res = res.length() > s1.length() ? res : s1;
        res = res.length() > s2.length() ? res : s2;
    }
    return res;
}
String palindrome(String s, int l, int r) {
    // 防止索引越界
    while (l >= 0 && r < s.length()
            && s.charAt(l) == s.charAt(r)) {
        // 向两边展开
        l--; r++;
    }
    // 返回以 s[l] 和 s[r] 为中心的最长回文串
    return s.substring(l + 1, r);
    }
```
dp 空间复杂度至少要 O(N^2)， 这道题是少有的动态规划非最优解法的问题。
Manacher’s Algorithm（马拉车算法） O(N)

### 图论基础
797. 所有可能的路径（中等）

多叉树而已，适用于树的 DFS/BFS 遍历算法，全部适用于图。
很少用这个 Vertex 类实现图，而是用常说的邻接表和邻接矩阵来实现。

邻接表： 空间少、无法快速判断两个节点是否相邻
邻接矩阵
常规的算法题中，邻接表的使用会更频繁一些。
度（degree）的概念，在无向图中，「度」就是每个节点相连的边的条数。入度、出度。
有向无权图、加权图matrix[x][y]存储int值、无向图把matrix[x][y] 和 matrix[y][x] 都变成 true。
比如 二分图判定， 环检测和拓扑排序（编译器循环引用检测就是类似的算法）， 最小生成树， Dijkstra 最短路径算法 等等

``` 
// 记录被遍历过的节点
boolean[] visited;
// 记录从起点到当前节点的路径
boolean[] onPath;

/* 图遍历框架 */
void traverse(Graph graph, int s) {
    if (visited[s]) return;
    // 经过节点 s，标记为已遍历
    visited[s] = true;
    // 做选择：标记节点 s 在路径上
    onPath[s] = true;
    for (int neighbor : graph.neighbors(s)) {
        traverse(graph, neighbor);
    }
    // 撤销选择：节点 s 离开路径
    onPath[s] = false;
}
```

### 一文秒杀所有岛屿题目
200. 岛屿数量（中等）
1254. 统计封闭岛屿的数目（中等）
1020. 飞地的数量（中等）
695. 岛屿的最大面积（中等）
1905. 统计子岛屿（中等）
694. 不同的岛屿数量（中等）

岛屿系列题目的核心考点就是用 DFS/BFS 算法遍历二维数组。

### 一个方法团灭 LEETCODE 股票买卖问题
121. 买卖股票的最佳时机（简单）
122. 买卖股票的最佳时机 II（简单）
123. 买卖股票的最佳时机 III（困难）
188. 买卖股票的最佳时机 IV（困难）
309. 最佳买卖股票时机含冷冻期（中等）
714. 买卖股票的最佳时机含手续费（中等）

### 一个方法团灭 LEETCODE 打家劫舍问题
https://mp.weixin.qq.com/s/z44hk0MW14_mAQd7988mfw

198. 打家劫舍（简单）
213. 打家劫舍II（中等）
337. 打家劫舍III（中等）

## 资料
- https://labuladong.github.io/algo/1/3/

todo: leetcode 1/2/3/5/206/15/25/46/146/42/70/31
