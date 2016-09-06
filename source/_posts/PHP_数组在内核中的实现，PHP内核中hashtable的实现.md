title: PHP 数组在内核中的实现，PHP内核中hashtable的实现
id: 139
categories:
  - PHP
date: 2014-12-15 10:17:17
tags:
---

&nbsp;

$arr  = array('a','b');

相对于$arr 来说，存放到下面的值中：

nTableSize   记录Bucket数组的大小；

nTableMask

nNumOfElements; 元素个数

nNextFreeElements; 下一个可用的bucket位置；

*pInternalPointer; 遍历数组；

*pListHead; 双链表表头

*pListTail; 双链表表尾

**arBuckets; Bucket数组

pDestructor;

persistent;

nAppleyCount;

bApplyProtection;

&nbsp;

而对于$arr[1] ,是如何存放的呢：

h  ①hash索引字符串之后的值，②整数 ；

nKeyLength; 如果索引是字符串，则是索引长度；如果索引是整数，则是0；

*pData;  指向malloc分配内存的值

*pDataPtr;  指针类型数据；

*pListNext; 双向链表下一个元素

*pListLast; 双向链表上一个元素；

*pNext;  相同hash值的下一个元素；

*pLast; 相同hash值的上一个元素；

arKey[1]; 索引的值；

&nbsp;