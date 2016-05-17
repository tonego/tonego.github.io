title: 用PHP来实现hash算法与一致性hash算法
tags:
  - 滴滴打车面试题
  - 百度面试题
id: 299
categories:
  - PHP笔试题
  - 数据结构与算法
date: 2015-03-07 09:23:47
---

&nbsp;

hash算法与一致性hash算法的区别，以及用用PHP来实现hash算法与一致性hash算法

&nbsp;

hash算法：
Class ClassA{
private $buckets;
private $size=10;
public function __construct(){
$this-&gt;buckets = new SplFixedArray($this-&gt;size);
}
public static function instance(){
return new ClassA();
}
private function funcHash($key){
$str_len = strlen($key);
for($i=0;$i&lt;$str_len;$i++){
$hashval += ord($key{$i});
}
return $hashval % $this-&gt;size;
}
public function insert($key,$val){
$index = $this-&gt;funcHash($key);
$this-&gt;buckets[$index] = $val;
}
public function find($key){
$index = $this-&gt;funcHash($key);
return $this-&gt;buckets[$index];
}

}