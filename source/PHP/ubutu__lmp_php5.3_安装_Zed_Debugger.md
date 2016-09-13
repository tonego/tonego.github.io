title: ubuntu  lnmp php5.3 安装 Zend Debugger
id: 319
categories:
  - Linux
  - PHP
  - 调试
date: 2015-05-21 21:01:59
tags:
---

ubuntu  lnmp php5.3 安装 Zend Debugger  ,花了一下午时间才搞好.

解决问题: http://stackoverflow.com/questions/7188149/php-5-3-5-with-zend-debugger

所以:  sudo apt-get install libssl0.9.8  ,才解决了问题 .

&nbsp;

配置如下:

[Zend Optimizer]
zend_extension=/usr/local/zend/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

[Zend Debugger]
;extension=/usr/local/php/lib/php/extensions/ZendDebugger.so;
;zend_extension_manager.debug_server_ts=/usr/local/php/lib/php/extensions/ ZendDebugger.so
;zend_extension=/usr/local/php/lib/php/extensions/ZendDebugger/php-5.5.x/ ZendDebugger.so
;zend_extension_ts=/usr/local/php/lib/php/extensions/ZendDebugger/5_3_x_comp/ ZendDebugger.so
zend_extension=/usr/local/php/lib/php/extensions/ZendDebugger/5_3_x_comp/ ZendDebugger.so