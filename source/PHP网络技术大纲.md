title: PHP网络技术大纲
id: 149
categories:
  - HTTP
  - PHP
date: 2014-12-23 11:19:55
tags:
---

HTTP协议  SPDY协议 SMTP协议 HTTPS协议 FTP协议 TCP/IP协议
<div></div>
<div>请求/状态 行、消息报头、请求/响应 正文</div>
<div></div>
<div>报头详解：</div>
<div></div>
<div>**    Cache 头域： **If-Modified-Since、If-None-Match、ETag、Pragma: no-cache、Cache-Control、</div>
<div>                        Date、Expires、Vary: Accept-Encoding、</div>
<div>    **Client 头域：  **Accept、Accept-Encoding、Accept-Language、User-Agent、Accept-Charset</div>
<div>**    Cookie/Login 头域： **Cookie</div>
<div>                                    P3P、Set-Cookie、</div>
<div>    **Entity头域: **Content-Length、Content-Type</div>
<div>                        ETag、Last-Modified、Content-Type、Content-Length、Content-Encoding、Content-Language</div>
<div>    **Miscellaneous 头域： **Referer</div>
<div>                                    Server、X-AspNet-Version、X-Powered-By、</div>
<div>    **Transport 头域： **Connection、Host、</div>
<div>                                Content-Encoding: gzip、Transfer-Encoding: chunked</div>
<div>    **Location头域： **Location</div>
<div></div>
<div></div>
<div></div>
<div>PHP函数：get_headers() header() curl扩展 socket系列  file系列  stream_xxx系列</div>
<div></div>
<div>防灌水：IP限制、TOKEN和表单欺诈、验证码（短信验证）、人工审核、前端JS加密；</div>
<div></div>
<div>抓包工具：Fiddle、HttpWatch、IE Analyzer、Charles、IRIS、Wireshark、sniffer</div>
<div></div>
<div>Fiddle的断点调试：忽略JS校验、修改请求信息、修改响应体</div>
<div></div>
<div>应用：Socket、file、CURL、Snoopy 实现POST数据。</div>
<div></div>
<div>SMTP：用telnet发送邮件(open/helo/auth login/mail from/rcpt to/data)、用socket发送邮件</div>
<div></div>
<div>WebService： PHP如何调用java类、PHPRPC、SOAP、WSDL、non-WSDL、</div>
<div></div>
<div>Cookie：浏览器管理、setcookie(7)、IE最多50个存文本文件，Firefox150个存sqlite、cookie最大4097B、Flash Cookie受flash管理、SSO、CAS、cookie跨域P3P、html5 localStorage、Flash SharedObject、UserData</div>
<div></div>
<div>Session：use_trans_sid、save_path、gc_divisor、入库（db、memory table、apc、memcached、redis）、session_set_save_handler、Cookie劫持</div>
<div></div>
<div>WebSocket FlashSocket</div>
<div></div>
<div></div>
<div></div>
<div>参考资料：</div>
<div>UA详解： [http://www.cnblogs.com/pomp/archive/2010/09/19/1831305.html](http://www.cnblogs.com/pomp/archive/2010/09/19/1831305.html)</div>
<div>UA大全：[http://www.zytrax.com/tech/web/mobile_ids.html](http://www.zytrax.com/tech/web/mobile_ids.html)</div>
<div></div>
