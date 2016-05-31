title: 读《图解HTTP》
date: 2016-05-31 16:12:50
tags:
---

### [](#1-2-HTTP的诞生 "1.2 HTTP的诞生")1.2 HTTP的诞生

    1996.5 HTTP1.0
    1997.1 HTTP1.1
    `</pre>

    ### [](#1-3-TCP-IP "1.3 TCP/IP")1.3 TCP/IP
    <pre>`应用层: HTTP/DNS/FTP
    传输层: TCP/UDP +标记序号和端口号
    网络层: IP +MAC
    链路层
    `</pre>

    ### [](#1-4-IP-TCP-DNS "1.4 IP/TCP/DNS")1.4 IP/TCP/DNS
    <pre>`ARP: IP/MAC
    TCP: synchronize/acknowledgement
    DNS: HOST/IP
    `</pre>

    ## [](#2-简单的HTTP协议 "2 简单的HTTP协议")2 简单的HTTP协议

    ### [](#2-2-请求和响应 "2.2 请求和响应")2.2 请求和响应
    <pre>`req:
    GET /index.html HTTP/1.1
    HOST: mi.com
    resp:
    HTTP/1.1 200 OK
    Cotent-length: 353
    `</pre>

    ### [](#2-5-HTTP-METHOD "2.5 HTTP METHOD")2.5 HTTP METHOD
    <pre>`GET
    POST
    HEAD
    PUT
    DELETE
    OPTIONS
    TRACE
    CONNECT
    `</pre>

    ### [](#2-7-持久连接节省通信量 "2.7 持久连接节省通信量")2.7 持久连接节省通信量
    <pre>`HTTP/1.1 所有连接默认持久连接
    管线化
    `</pre>

    ### [](#2-8-使用COOKIE的状态管理 "2.8 使用COOKIE的状态管理")2.8 使用COOKIE的状态管理
    <pre>`* req:
        GET /index.php HTTP/1.1
        HOST: mi.com
    * resp:
        HTTP/1.1 200 OK
        Set-Cookie: sid=1006440989; path=/; domain=mi.com; expires:Wed, 10-Oct-12 07:12:20 GMT
    * req:
        GET /cart.php HTTP/1.1
        Cookie: sid=1006440989
    `</pre>

    ### [](#3-4-发送多种数据的多部分对象集合 "3.4 发送多种数据的多部分对象集合")3.4 发送多种数据的多部分对象集合
    <pre>`req:
        Content-Type: multipart/form-data; boundary=1006440989

        --1006440989
        Content-Disposition: form-data; name=&quot;field1&quot;

        wangtongphp
        --1006440998
        Content-Disposition: form-data; name=&quot;pics&quot;; file_name=&quot;file1.txt&quot;
        Content-Type: text/plain

        Hello World
        --1006440989--

    resp:
        HTTP/1.1 206 Partial Content
        Content-Type:multipart/byteranges; boundary=THIS_STRING_SEPARATES

        --THIS_STRING_SEPARATES
        Content-Type: application/pdf
        Content-Range: bytes 500-999/8000

        --THIS_STRING_SEPARATES--
    `</pre>

    ### [](#3-5-获取部分内容的范围请求 "3.5 获取部分内容的范围请求")3.5 获取部分内容的范围请求
    <pre>`req:
        Range: bytes=-3000, 5000-8000
        Range: bytes=5001-

    resp:
        HTTP/1.1 206 Partial Content
        Content-Type: mulitpart/byteranges
    `</pre>

    ## [](#4-返回结果的HTTP状态码 "4 返回结果的HTTP状态码")4 返回结果的HTTP状态码

    ### [](#4-2-2XX成功 "4.2 2XX成功")4.2 2XX成功
    <pre>`200 OK / 204 No Content / 206 Partial Content 
    `</pre>

    ### [](#4-3-3XX重定向 "4.3 3XX重定向")4.3 3XX重定向
    <pre>`301 Moved Permanently / 302 Found / 303 See Other / 304 Not Modified / 307 Temporary Redirect 
    `</pre>

    ### [](#4-4-4XX客户端错误 "4.4 4XX客户端错误")4.4 4XX客户端错误
    <pre>`400 Bad Request / 401 Unauthorized / 403 Forbidden / 404 Not Found
    `</pre>

    ### [](#4-5-5XX服务器错误 "4.5 5XX服务器错误")4.5 5XX服务器错误
    <pre>`500 Internal Server Error / 503 Service Unavailable / 504 Gateway Timeout
    `</pre>

    ### [](#5-2-通信数据转发程序-代理、网关、隧道 "5.2 通信数据转发程序:代理、网关、隧道")5.2 通信数据转发程序:代理、网关、隧道

    ## [](#6-HTTP-首部 "6 HTTP 首部")6 HTTP 首部

    ### [](#6-2-HTTP首部字段 "6.2 HTTP首部字段")6.2 HTTP首部字段
    <pre>`通用／请求／响应／实体　首部字段
    RFC2616定义了47种首部字段，除此外还有Cookie / Set-Cookie / Content-Disposition 
    Hop-by-hop Header: Connnection / Keep-Alive / Proxy-Authenticate / Proxy-Authorization / Trailer / TE / Transfer-Encoding / Upgrade 外都是End-to-end Header
    `</pre>

    ### [](#6-3-通用首部字段 "6.3 通用首部字段")6.3 通用首部字段
    <pre>`Cache-Control: no-cache, no-store, max-age=3600, no-transform, cache-extentsion,
        缓存请求指令：max-stale, min-fresh, only-if-cached, 
        缓存响应指令：public, private, must-revalidate, proxy-revalidate, s-maxage,  
    Connection / Date / Pargma / Trailer / Transfer-Encoding / Upgrade / Via / Warning
    `</pre>

    ### [](#6-4-请求首部字段 "6.4 请求首部字段")6.4 请求首部字段
    <pre>`Accept / Accept-Charset / Accept-Encoding / Accept-Language / Authorization / Expect / From / Host/ If-Match / If-Modified-Since / If-None-Match / If-Range / If-Unmodified-Since / Max-Forwards / Proxy-Authorization / Range / Referer / TE / User-Agent / 
    `</pre>

    ### [](#6-4-响应首部字段 "6.4 响应首部字段")6.4 响应首部字段
    <pre>`Accept-Ranges / Age / ETag / Location / Proxy-Authenticate / Retry-After / Server / Vary / WWW-Authenticate 
    `</pre>

    ### [](#6-5-实体首部字段 "6.5 实体首部字段")6.5 实体首部字段
    <pre>`Allow / Content-Encoding / Content-Length / Content-Language / Content-Location / Content-MD5 / Content-Range / Content-Type / Expires / Last-Modified 
    `</pre>

    ### [](#6-8-其他首部字段 "6.8 其他首部字段")6.8 其他首部字段
    <pre>`X-Frame-Options / X-XSS-Protection / DNT / P3P
    `</pre>

    ## [](#7-确保WEB安全的HTTPS "7 确保WEB安全的HTTPS")7 确保WEB安全的HTTPS

    ### [](#7-2-HTTPS-HTTP-加密-认证-完整性保护 "7.2 HTTPS = HTTP + 加密 + 认证 + 完整性保护")7.2 HTTPS = HTTP + 加密 + 认证 + 完整性保护
    <pre>`HTTPS是身披SSL外壳的HTTP
    证书用来证明公开密钥的正确性，关键在于浏览器内置了证书认证机构的公钥

    * 客户端发送Client Hello 报文开始SSL通信, 报文中包含客户端支持的SSL的指定版本／加密组件列表加密算法密钥长度
    * 服务器以Server Hello作为应答，报文中包含SSL和筛选后的加密组件
    * 服务器发送Certificate报文，公开密钥证书
    * 服务器发送Server Hello Done 报文，最初阶段SSL握手协商部分结束
    * 客户端以Client Key Exchange 作回应。报文中包含用公钥加密的Pre-master secret的随机密码串
    * 客户端发送 Change Cipher Spec 报文，告诉服务器，之后通信用Pre-master secret 密钥加密
    * 客户端发送 Finished　报文，包含连接至今全部报文的校验值，这次握手协商是否成功就看服务器能否正确解密此报文
    * 服务器发送 Change Cipher Spec 报文。
    * 服务器发送 Finished　报文.
    * 客户端发起HTTP请求。此处SSL连接建立完成，通信收到SSL的保护，从此处开始应用层HTTP协议的通信。包含MAC报文摘要
    * 服务器返回HTTP响应。
    * 客户端断开连接，发送close_notify报文，发送TCP FIN报文关闭与TCP的通信.

    SSL　通信慢消耗CPU和内存资源。
    购买证书一年要几千到一万元
    `</pre>

    ## [](#8-认证 "8 认证")8 认证

    ### [](#8-1-何为认证 "8.1 何为认证")8.1 何为认证
    <pre>`密码登录
    动态令牌
    数字证书
    指纹虹膜等生物认证
    IC卡
    HTTP/1.1认证：BASIC / DIGEST / SSL / FormBase
    `</pre>

    ## [](#9-基于HTTP的功能追加协议 "9 基于HTTP的功能追加协议")9 基于HTTP的功能追加协议

    ### [](#9-2-SPDY "9.2 SPDY")9.2 SPDY
    <pre>`Ajax 和 Comet技术
    SPDY : 多路复用流/请求优先级／压缩HTTP首部／推送功能／服务器提示功能
    `</pre>

    ### [](#9-3-使用浏览器进行全双工的WebSocket "9.3 使用浏览器进行全双工的WebSocket")9.3 使用浏览器进行全双工的WebSocket

    ### [](#9-4-HTTP-2-0 "9.4 HTTP/2.0")9.4 HTTP/2.0
    <pre>`SPDY的多路复用和流量控制、HTTP Speed+Mobility的TLS义务化／协商／客户端拉拽／服务器推送／WebSocket

### [](#9-5-Web服务器管理文件的WebDAV "9.5 Web服务器管理文件的WebDAV")9.5 Web服务器管理文件的WebDAV

