## LeetCode
#### 1. 两数之和
```
若非排序，一个map，Key=target-v, O(N),O(N), https://leetcode.com/submissions/detail/213429740/
暴力两层循环，O(N²/2), O(1)
```
#### 167. 两数之和（已排序）
```
头尾指针向中移动法，O(N),O(1), https://leetcode.com/submissions/detail/213705785/
暴力循环+二分查找，O(N),O(1), https://leetcode.com/submissions/detail/213704704/
```

## 《剑指offer》-何海涛

#### 3. 数组中找重复数字，n个数，范围0~n-1,
```
索引转换法, O(N), O(1)
map , O(N),O(N)
sort， O(N*LogN),O(1)
若readOnly, 二分统计法, O(N*LogN), O(1)
```
#### 4. 有序二维数组找数
```
右上角开始，>target往下，<target往左
```
#### 5. 替换字符串空格
```
从尾到头遍历 O(N)
```

#### 检查链表有环
1. 双指针，一步或二步跨度移动，类似双跑道，能追上就是有环。
2. hash表/bitmap/bloom另外的库 判断O(1)
