title: 用CURL_MULTI的一次实例
id: 137
categories:
  - HTTP
  - PHP
date: 2014-12-10 16:56:34
tags:
---

用CURL_MULTI的一次实例

&lt;?PHP
/**
* @desc : 检测小说书的站点的死链 ,并更新数据库http_code
* @author : wangtong@cmcm.com
**/

date_default_timezone_set('Asia/Shanghai');
set_time_limit(0);

class mod_d_site_http_code
{

public static function update_http_code(){
$i=1;
//如果是周一，对全部约80w目标书籍站点资源进行httpcode的检测，如果非周一，只对状态码为0的资源进行重新检测
if(date('w') === 1 ){
$where = " http_code not in(900,904) ";
}else{
$where = " http_code=0 ";
}
$res = app_db::query("select book_id, site_url from b_book_d_site where ".$where);
//$res = $mysqli-&gt;query("select book_id, site_url from b_book_d_site where 1 limit $start,$num");

while($row = app_db::fetch_one($res)){
$rows[] = $row ;
if ( count($rows) % 100== 0 ) {

$mh = curl_multi_init();

//将一批url添加句柄到curl_mulit,用来批量执行
foreach( $rows as $k=&gt;$v ) {
${'ch'.$k} = curl_init();
curl_setopt(${'ch'.$k},CURLOPT_URL,$v['site_url']);
curl_setopt(${'ch'.$k},CURLOPT_RETURNTRANSFER,1);
curl_setopt(${'ch'.$k},CURLOPT_NOBODY,true);
curl_setopt(${'ch'.$k},CURLOPT_TIMEOUT,2);
curl_multi_add_handle($mh,${'ch'.$k});
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
//下面对一批URL状态码更新到数据库
foreach( $rows as $k=&gt;$v ) {
$code = curl_getinfo(${'ch'.$k},CURLINFO_HTTP_CODE);
if(!empty($v['book_id']) &amp;&amp; !empty($v['site_url'])){
$q_res = app_db::query("update b_book_d_site set http_code=".$code." where book_id=".$v['book_id']." and site_url='".$v['site_url']."'");
}
$out = $i++."\t".$v['book_id']."\t".$v['site_url']."\t".$code."\t".$q_res."\t".date("m-d H:i:s").PHP_EOL;
echo $out;
curl_multi_remove_handle($mh, ${'ch'.$k});

}

curl_multi_close($mh);

unset($rows);
}
}
//var_dump($rows);
echo 'end from '.$start.'+'.$i.PHP_EOL;

self::update_book_status_by_httpcode();
}

// 将  所有来源站点非200和900的书籍隐藏
public static function update_book_status_by_httpcode(){
$sql = "update b_book_info as a inner join (select z.id from b_book_info as z join (select book_id ,sum(http_code in (200,900)) as s from b_book_d_site group by book_id ) as d on z.d_id=d.book_id where d.s=0 and z.d_type=1) as b on a.id=b.id set a.is_show=0";
$res = app_db::query($sql);
echo '将 所有来源站点非200和900的书籍隐藏'.PHP_EOL;
}
}