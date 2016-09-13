title: 关于github.io博客框架的思考

 目前我用的hexo方案，缺点如下：
> 相比我用Jekyll搭建失败来比，hexo搭建倒是成功的，但也是很复杂的。
> 不能在线写博客，换个电脑都废了。
> 不够灵活，有些庞大,　有一定学习成本。

 我想有个github.io博客框架可以能这样:
> 支持MarkDown 语法，能用Vim写博客, 能在线写博客, 且博客内容为纯内容，不用手动加载js也没有一点html。
> 一定要保存.md源文件，方便更换程序。
> 轻量级的，框架和博客内容是分离的，结构清晰，目录就按照git库的目录。
> 直接在github.com的wangtongphp.github.io库编辑内容及目录,也可以vim编辑后push 
> 最好支持SEO。

方案如下:

一、不支持SEO的简单方案
 首页的内容可以用JS遍历博文目录及列表来生成分类列表和链接
 链接到某个可以将markdown转html的页面, 在用户浏览器端将markdown转换为html


二、将markdown生成html并push到用户的io库中,由于push需要权限
        1. github.com有提供api,可以做个网站提供服务,授权修改wangtongphp.github.io库
        2. 用户自行登录github，触发有push功能的js代码，在登录状态的浏览器下执行

    
