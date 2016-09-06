title: '实现 PHP5.4中 json_encode($str, JSON_UNESCAPED_UNICODE)'
id: 325
categories:
  - PHP
date: 2015-10-16 19:52:53
tags:
---

/**
* 实现 PHP5.4中 json_encode($str, JSON_UNESCAPED_UNICODE)
*/
private function decodeUnicode($str)
{
return preg_replace_callback('/\\\\u([0-9a-f]{4})/i', create_function( '$matches', 'return mb_convert_encoding(pack("H*", $matches[1]), "UTF-8", "UCS-2BE");' ), $str);
}

&nbsp;

$data = array(
'header'=&gt;array(
'appid' =&gt; $appid,
'sign' =&gt; md5($appid.$this-&gt;decodeUnicode(json_encode($info)).$key),
),
'body'=&gt; $info,
);
//dump(json_encode($data));
$Http = new Http();
$res = $Http-&gt;curlPost($url,array('data'=&gt;base64_encode(json_encode($data))),'', false, 30);