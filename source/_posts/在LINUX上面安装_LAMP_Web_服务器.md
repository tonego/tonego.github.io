title: 在LINUX上面安装 LAMP Web 服务器
id: 332
categories:
  - Linux
date: 2015-12-07 19:17:09
tags:
---

<div>

# 教程：安装 LAMP Web 服务器（在 Amazon Linux 上）

</div>
通过以下步骤，您可以将支持 PHP 和 MySQL 的 Apache Web 服务器（有时称为 LAMP Web 服务器或 LAMP 堆栈）安装到您 Amazon Linux 实例上。您可以使用此服务器来托管静态网站或部署能对数据库中的信息执行读写操作的动态 PHP 应用程序。

先决条件

本教程假定您已经启动具有可从 Internet 访问的公有 DNS 名称的实例。有关更多信息，请参阅[启动 Amazon EC2 实例](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-launch-instance_linux.html "启动 Amazon EC2 实例")。还必须将安全组配置为允许 `SSH`（端口 22）、`HTTP`（端口 80）和`HTTPS`（端口 443）连接。有关这些先决条件的更多信息，请参阅 [Amazon EC2 的设置](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html "Amazon EC2 的设置")。
<div>

Important

这些过程适用于 Amazon Linux。有关其他发布版本的更多信息，请参阅其具体文档。**如果您尝试在 Ubuntu 实例上设置 LAMP Web 服务器，则本教程不适合您。**有关 Ubuntu 上的 LAMP Web 服务器的信息，请转到 Ubuntu 社区文档[ApacheMySQLPHP](https://help.ubuntu.com/community/ApacheMySQLPHP) 主题。

</div>
<div><a name="d0e4372"></a>**安装和启动 LAMP Web 服务器（在 Amazon Linux 上）**

1.  [连接到您的实例](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-connect-to-instance-linux.html "连接到您的实例")。
2.  为确保您的所有软件包都处于最新状态，请对您的实例执行快速软件更新。此过程可能需要几分钟的时间，但必须确保您拥有最新的安全更新和缺陷修复。
<div>

Note

`-y` 选项安装更新时不提示确认。如果您希望在安装前检查更新，则可以忽略此选项。

</div>
<pre>`[ec2-user ~]$ **<code>sudo yum update -y`**</code></pre>

3.  您的实例处于最新状态后，便可以安装 Apache Web 服务器、MySQL 和 PHP 软件包。使用**yum install** 命令可同时安装多个软件包和所有相关依赖项。
<pre>`[ec2-user ~]$ **<code>sudo yum install -y httpd24 php56 mysql55-server php56-mysqlnd`**</code></pre>

4.  启动 Apache Web 服务器。
<pre>`[ec2-user ~]$ **<code>sudo service httpd start`** Starting httpd: [ OK ]</code></pre>

5.  使用 **chkconfig** 命令将 Apache Web 服务器配置为在每次系统启动时启动。
<pre>`[ec2-user ~]$ **<code>sudo chkconfig httpd on`**</code></pre>
<div>

Tip

当您成功启用服务时，**chkconfig** 命令不提供任何确认消息。您可以通过运行以下命令验证 **httpd** 是否已启用。

</div>
<pre>`[ec2-user ~]$ **<code>chkconfig --list httpd`** httpd 0:off 1:off 2:on 3:on 4:on 5:on 6:off</code></pre>
在运行级别 2、3、4 和 5 下，**httpd** 为 `on`（您希望看到的状态）。
6.  测试您的 Web 服务器。在 Web 浏览器中，输入您实例的公有 DNS 地址（或公有 IP 地址），您应该可以看到 Apache 测试页面。您可以使用 Amazon EC2 控制台获取实例的公有 DNS（勾选 Public DNS (公有 DNS) 列；如果此列处于隐藏状态，请单击 Show/Hide (显示/隐藏) 图标并选择 Public DNS (公有 DNS)）。
<div>

Tip

如果您未能看到 Apache 测试页面，请检查您使用的安全组是否包含允许`HTTP`（端口 80）流量的规则。有关将 `HTTP` 规则添加到您安全组的信息，请参阅 [向安全组添加规则](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/using-network-security.html#adding-security-group-rule "向安全组添加规则")。

</div>
<div>

Important

如果您使用的不是 Amazon Linux，则还可能需要在实例上配置防火墙才能允许这些连接。有关如何配置防火墙的更多信息，请参阅适用于特定分配的文档。

</div>
<div>![](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/images/apache_test_page2.4.png)</div>
<div>

Note

该测试页面仅在 `/var/www/html` 无内容时显示。将内容添加到文档根目录后，您的内容将显示在您实例的公有 DNS 地址中，而不显示在本测试页面。

</div>
</div>
Apache**httpd** 提供的文件保存在称为 Apache 文档根目录的目录中。Amazon Linux Apache 文档根目录是 `/var/www/html`，默认情况下归 `root` 所有。
<pre>`[ec2-user ~]$ **<code>ls -l /var/www`** total 16 drwxr-xr-x 2 root root 4096 Jul 12 01:00 cgi-bin drwxr-xr-x 3 root root 4096 Aug 7 00:02 error drwxr-xr-x 2 root root 4096 Jan 6 2012 html drwxr-xr-x 3 root root 4096 Aug 7 00:02 icons </code></pre>
要允许 `ec2-user` 操作此目录中的文件，您需修改其所有权和权限。有多种方法可以完成此任务；在本教程中，您可以将 `www` 组添加到您的实例，然后赋予该组 `/var/www` 目录的所有权并为该组添加写入权限。随后，该组的所有成员都将能够为 Web 服务器添加、删除和修改文件。
<div><a name="SettingFilePermissions"></a>**设置文件权限**

1.  将 `www` 组添加到您的实例。
<pre>`[ec2-user ~]$ **<code>sudo groupadd www`**</code></pre>

2.  将您的用户（这里指 `ec2-user`）添加到 `www`。
<pre>`[ec2-user ~]$ **<code>sudo usermod -a -G www _<code>ec2-user`_</code>**</code></pre>
<div>

Important

您必须先退出，再重新登录，然后才能接受新组。您可以使用 **exit** 命令，也可以关闭终端窗口。

</div>
3.  先退出，再重新登录，然后验证您是否为 `www` 组的成员。

    1.  退出。
<pre>`[ec2-user ~]$ **<code>exit`**</code></pre>

        2.  重新连接到实例，然后运行以下命令，以验证您是否为 `www` 组的成员。
<pre>`[ec2-user ~]$ **<code>groups`** ec2-user wheel www</code></pre>

4.  将 `/var/` 及其内容的组所有权更改到 `www`www 组。
<pre>`[ec2-user ~]$ **<code>sudo chown -R root:www /var/www`**</code></pre>

5.  更改 `/var/www` 及其子目录的目录权限，以添加组写入权限和设置未来子目录上的组 ID。
<pre>`[ec2-user ~]$ **<code>sudo chmod 2775 /var/www`** [ec2-user ~]$ **`find /var/www -type d -exec sudo chmod 2775 {} +`**</code></pre>

6.  递归更改 `/var/www` 及其子目录的文件权限，以添加组写入权限。
<pre>`[ec2-user ~]$ **<code>find /var/www -type f -exec sudo chmod 0664 {} +`**</code></pre>
</div>
现在，`ec2_user`（以及 `www` 组的任何未来成员）可以在 Apache 根目录中添加、删除和编辑文件。现在您已准备好添加内容，例如静态网站或 PHP 应用程序。
<div><a name="d0e4605"></a>**测试您的 LAMP Web 服务器**

如果您的服务器已安装并运行，且文件权限设置正确，则您的 `ec2-user` 账户应该能够在`/var/www/html` 目录（可从 Internet 访问）中创建一个简单的 PHP 文件。

1.  在 Apache 文档根目录中创建一个简单的 PHP 文件。
<pre>`[ec2-user ~]$ **<code>echo "&lt;?php phpinfo(); ?&gt;" &gt; /var/www/html/phpinfo.php`**</code></pre>
<div>

Tip

尝试运行此命令时，如果出现“`Permission denied`”错误，请尝试先退出，再重新登录，以接受您在 [设置文件权限](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/install-LAMP.html#SettingFilePermissions "设置文件权限") 中配置的适当组权限。

</div>
2.  在 Web 浏览器中，输入您刚刚创建的文件的 URL。此 URL 是实例的公用 DNS 地址，后接正斜杠和文件名。例如：
<pre>`http://_<code>my.public.dns.amazonaws.com`_/phpinfo.php</code></pre>
您应该可以看到 PHP 信息页面。
<div>![](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/images/phpinfo5.6.6.png)</div>
<div>

Note

如果您未看到此页面，请验证上一步中是否已正确创建`/var/www/html/phpinfo.php` 文件。您也可以使用以下命令验证是否安装了所有必需的程序包（第二列中的程序包版本不需要与此示例输出匹配）：
<pre>`[ec2-user ~]$ **<code>sudo yum list installed httpd24 php56 mysql55-server php56-mysqlnd`** Loaded plugins: priorities, update-motd, upgrade-helper 959 packages excluded due to repository priority protections Installed Packages httpd24.x86_64 2.4.16-1.62.amzn1 @amzn-main mysql55-server.x86_64 5.5.45-1.9.amzn1 @amzn-main php56.x86_64 5.6.13-1.118.amzn1 @amzn-main php56-mysqlnd.x86_64 5.6.13-1.118.amzn1 @amzn-main</code></pre>
如果输出中未列出任何必需的程序包，请使用 **sudo yum install _`package`_** 命令安装它们。

</div>
3.  删除 `phpinfo.php` 文件。尽管此信息可能对您很有用，但出于安全考虑，不应将其传播到 Internet。
<pre>`[ec2-user ~]$ **<code>rm /var/www/html/phpinfo.php`**</code></pre>
</div>
<div><a name="SecuringMySQLProcedure"></a>**保障 MySQL 服务器的安全**

MySQL 服务器的默认安装提供有多种功能，这些功能对于测试和开发都很有帮助，但对于产品服务器，应禁用或删除这些功能。**mysql_secure_installation** 命令可引导您设置根密码并删除安装中的不安全功能。即使您不打算使用 MySQL 服务器，执行此步骤也是一个不错的建议。

1.  启动 MySQL 服务器，以便运行 **mysql_secure_installation**。
<pre>`[ec2-user ~]$ **<code>sudo service mysqld start`** Initializing MySQL database: Installing MySQL system tables... OK Filling help tables... OK To start mysqld at boot time you have to copy support-files/mysql.server to the right place for your system PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER ! ... Starting mysqld: [ OK ] </code></pre>
。
2.  运行 **mysql_secure_installation**。
<pre>`[ec2-user ~]$ **<code>sudo mysql_secure_installation`**</code></pre>

    1.  在系统提示时，输入 `root` 账户的密码。

            1.  输入当前 `root` 密码。默认情况下，`root` 账户没有设置密码，因此按 **Enter**。
        2.  键入 **Y** 设置密码，然后输入两次安全密码。有关创建安全密码的更多信息，请转至 [http://www.pctools.com/guides/password/](http://www.pctools.com/guides/password/)。确保将此密码存储在安全位置。

        2.  键入 **Y** 删除匿名用户账户。
    3.  键入 **Y** 禁用远程 `root` 登录。
    4.  键入 **Y** 删除测试数据库。
    5.  键入 **Y** 重新加载权限表并保存您的更改。

3.  （可选）如果不打算立即使用 MySQL 服务器，请停止。您可以在需要时再次重新启动该服务器。
<pre>`[ec2-user ~]$ **<code>sudo service mysqld stop`** Stopping mysqld: [ OK ]</code></pre>

4.  （可选）如果您希望每次启动时 MySQL 服务器都启动，请输入以下命令。
<pre>`[ec2-user ~]$ **<code>sudo chkconfig mysqld on`**</code></pre>
</div>
现在，您应该有了一个功能完善的 LAMP Web 服务器。如果您将内容添加到位于`/var/www/html` 的 Apache 文档根目录，您应该能够在实例的公有 DNS 地址处看到这些内容。
<div><a name="d0e4777"></a>**（可选）安装 phpMyAdmin**

[phpMyAdmin](https://www.phpmyadmin.net/) 是一种基于 Web 的数据库管理工具，可用于在 EC2 实例上查看和编辑 MySQL 数据库。按照以下步骤操作可在您的 Amazon Linux 实例上安装和配置 phpMyAdmin。

1.  在您的实例上从 Fedora 项目启用 Extra Packages for Enterprise Linux (EPEL) 存储库。
<pre>`[ec2-user ~]$ **<code>sudo yum-config-manager --enable _<code>epel`_</code>**</code></pre>

2.  安装 `phpMyAdmin` 软件包。
<pre>`[ec2-user ~]$ **<code>sudo yum install -y phpMyAdmin`**</code></pre>
<div>

Note

在系统提示时，回答 `y` 以导入 EPEL 存储库的 GPG 密钥。

</div>
3.  将您的 `phpMyAdmin` 安装配置为允许从本地计算机进行访问。默认情况下，`phpMyAdmin`仅允许从其运行于的服务器进行访问，这不是很有用，因为 Amazon Linux 不包括 Web 浏览器。

    1.  通过访问服务（例如 [whatismyip.com](https://www.whatismyip.com/)）查找您的本地 IP 地址。
    2.  <a name="step-phpMyAdmin.conf"></a>编辑 `/etc/httpd/conf.d/phpMyAdmin.conf` 文件并使用以下命令将服务器 IP 地址 (127.0.0.1) 替换为您的本地 IP 地址，并将 _`your_ip_address`_ 替换为您在上一步中标识的本地 IP 地址。
<pre>`[ec2-user ~]$ **<code>sudo sed -i -e 's/127.0.0.1/_<code>your_ip_address`_/g' /etc/httpd/conf.d/phpMyAdmin.conf</code>**</code></pre>

4.  <a name="step-phpMyAdmin-restart-httpd"></a>重启 Apache Web 服务器，让新配置生效。
<pre>`[ec2-user ~]$ **<code>sudo service httpd restart`** Stopping httpd: [ OK ] Starting httpd: [ OK ]</code></pre>

5.  在 Web 浏览器中，输入 `phpMyAdmin` 安装的 URL。此 URL 是实例的公用 DNS 地址，后接正斜杠和 phpmyadmin。例如：
<pre>`http://_<code>my.public.dns.amazonaws.com`_/phpmyadmin</code></pre>
您应该可以看到 phpMyAdmin 登录页面。
<div>![](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/images/phpmyadmin_login.png)</div>
<div>

Note

如果您收到 `403 Forbidden` 错误，请验证您是否在`/etc/httpd/conf.d/phpMyAdmin.conf` 文件中设置了正确的 IP 地址。您可以使用以下命令查看 Apache 访问日志，以了解 Apache 服务器实际从哪个 IP 地址获取请求：
<pre>`[ec2-user ~]$ **<code>sudo tail -n 1 /var/log/httpd/access_log | awk '{ print $1 }'`** _`205.251.233.48`_</code></pre>
使用此处返回的 IP 地址重复[Step 3.b](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/install-LAMP.html#step-phpMyAdmin.conf "Step 3.b") 并通过[Step 4](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/install-LAMP.html#step-phpMyAdmin-restart-httpd "Step 4") 重启 `httpd` 服务。

</div>
6.  使用您先前创建的 `root` 用户名和 MySQL 根密码登录到 `phpMyAdmin` 安装。有关使用`phpMyAdmin` 的更多信息和帮助，请参阅 [`phpMyAdmin` 用户指南](http://docs.phpmyadmin.net/en/latest/user.html)。
</div>