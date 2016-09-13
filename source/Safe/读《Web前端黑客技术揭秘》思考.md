title: 读《Web前端黑客技术揭秘》思考
date: 2016-06-08 11:40:27
tags:
---


以‘上有政策，下有对策’和各种防范措施的必要性的思路来考虑安全问题。

#### 做好单引号和双引号的过滤
   如果没做，可以组装sql进行inject或者通过盲注来猜解。也易闭合js语句实现xss。

#### 做好\的转义和int 型强制int
   如果遇到sql: "select * from table where name=\'{$arg}\'" 形式。
   如果遇到sql: 'select * from table where id={$id}'形式。
    

#### 隐藏目录细节,防止远程表单提交
    如果知道后台目录，开源程序后台有del.php?id=3或post请求的add.php的页面，容易造成csrf攻击
    有个人中心，根据cookie返回不同内容的服务也易造成crsf攻击。
    如果访问的b.com网页存在<img src="a.com/del.php?id=3" />或者js写的post请求，csrf防不胜防 
    
#### 设置X-Frame-Options
   防止iframe加载，即可防止界面操作劫持

#### 设置Access-Control-Allow-Origin:http://mi.com
    ajax跨域白名单

