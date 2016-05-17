title: php实现IP地址转换为整型
tags:
  - 小米面试题
id: 307
categories:
  - PHP笔试题
  - 数据结构与算法
date: 2015-03-11 10:38:37
---

# php实现IP地址转换为整型数字实例

&nbsp;

【转换原理】：假设IP为：w.x.y.z，则IP地址转为整型数字的计算公式为：intIP = 256*256*256*w + 256*256*x + 256*y + z

【PHP的互转】：PHP的转换方式比较简单，它内置了两个函数

**int ip2long** ( string $ip_address ) //ip转换成整型数值
**string long2ip** ( string $proper_address ) // 整型数值转换成ip【MySQL的互转】：相对于MsSQL来说MySQL的转换方式比较简单，它和PHP一样也内置了两个函数

IP 转为整型:

[select](http://www.111cn.net/tags.php/select/) INET_ATON (IP地址)整型数值转换成IP

select INET_NTOA ( IP的整型数值 )
一个实例

1.手工自己的实现方法

&nbsp;

&nbsp;

&nbsp;

function ip2number($ip)
{

$t = [explode](http://www.111cn.net/tags.php/explode/)('.', $ip);
$x = 0;
for ($i = 0; $i &lt; 4; $i++)

{
$x = $x * 256 + $t[$i];

}
return $x;

}

function number2ip($num)

{
$t = $num;
$a = array();

for ($i = 0; $i &lt; 4; $i++)
{
$x = $t % 256;
if($x &lt; 0) $x += 256;
array_unshift($a, $x);
$t = intval($t / 256);
}
return implode('.', $a);
}