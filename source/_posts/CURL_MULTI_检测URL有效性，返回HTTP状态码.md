title: CURL_MULTI 检测URL有效性，返回HTTP状态码
id: 24
categories:
  - HTTP
  - PHP
date: 2014-11-08 09:13:24
tags:
---

&nbsp;

鉴于上一篇博文中提到的，linux 的 curl 速度太慢，所以考虑用PHP的多线程curl来实现。用PHP的CURL_MULTI系列函数实现一亿个URL的HTTP状态码检测。

代码如下：
&lt;?PHP
$mysqli = new mysqli('114.112.xx.xx','wxxxxxng','xxxxxxxxxxxxxxxxxxxxxxxxxxxxx','xxxx_book');
//var_dump($mysqli);
$res = $mysqli-&gt;query("select book_id, site_url from xxxx_d_site where 1 limit 30");
while($row = $res-&gt;fetch_assoc()){
$rows[] = $row ;

if ( count($rows) % 10 == 0 ) {

$mh = curl_multi_init();

foreach( $rows as $k=&gt;$v ) {
${ch.$k} = curl_init();
curl_setopt(${ch.$k},CURLOPT_URL,$row['site_url']);
curl_setopt(${ch.$k},CURLOPT_RETURNTRANSFER,1);
curl_multi_add_handle($mh,${ch.$k});
//$result = curl_exec(${ch.$i});
//$code = curl_getinfo(${ch.$i},CURLINFO_HTTP_CODE);
//if ( $code != 200 ) {
// echo $row['book_id']."\t".$row['site_url']."\t".$code.PHP_EOL;
//}
}

$active = null;
do{
$mrc = curl_multi_exec($mh,$active);
}while($mrc == CURLM_CALL_MULTI_PERFORM);

while ( $active &amp;&amp; $mrc == CURLM_OK ) {
if(curl_multi_select($mh) != -1){
do {
$mrc = curl_multi_exec($mh,$active);
}while( $mrc == CURLM_CALL_MULTI_PERFORM );
}
}

foreach( $rows as $k=&gt;$v ) {

//$html = curl_multi_getcontent(${ch.$k});
$code = curl_getinfo(${ch.$k},CURLINFO_HTTP_CODE);
file_put_contents('/home/wangtong/debug.txt', var_export($code,true).PHP_EOL,FILE_APPEND);
curl_multi_remove_handle($mh, ${ch.$k});
}

curl_multi_close($mh);

unset($rows);
}
}
//var_dump($rows);