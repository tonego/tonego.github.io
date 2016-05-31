title: 关于continue写在函数中的题目
id: 50
categories:
  - PHP
  - PHP笔试题
date: 2014-11-18 17:24:21
tags:
---

$a = 4;

for($i = 0;$i&lt;$a; $i++){
echo $i."&lt;br&gt;";
for($ii=0;$ii&lt;$a;$ii++){
echo $ii.'22'."&lt;br&gt;";
fun();
}
}

function fun(){

continue;
}

&nbsp;

这个会输出：**Fatal error**: Cannot break/continue 1 level in **/home/wxxxxm/index.php** on line **16**