---
title: WampServer-localhost-图标不显示解决办法
date: 2016-07-24 15:28:29
tags: 
    - Wamp
categories: 
    - 软件
---

在用WampServer学习PHP的时候碰到，打开localhost的时候文件图标不显示，解决办法如下

<!--more-->

[原文链接](http://blog.warmcolor.net/2011/11/03/wampserver-localhost-%E5%9B%BE%E6%A0%87%E4%B8%8D%E6%98%BE%E7%A4%BA%E8%A7%A3%E5%86%B3%E5%8A%9E%E6%B3%95/ "原文链接")

1，在安装目录中找到
```html
\wamp\bin\apache\Apache2.2.17\conf\extra\httpd-autoindex.conf
```

2，打开进行修改,将以下
```html
Alias /icons/ “C:/Dev/Projets/WampServer2-64b/install_files_wampserver2/bin/apache/Apache2.2.17/icons/”
<Directory “C:/Dev/Projets/WampServer2- 64b/install_files_wampserver2/bin/apache/Apache2.2.17/icons”\>
	Options Indexes MultiViews
	AllowOverride None
	Order allow,deny
	Allow from all
</Directory>
```
修改为
```html
Alias /icons/ “icons/”
<Directory “icons”\>
	Options Indexes MultiViews
	AllowOverride None
	Order allow,deny
	Allow from all
</Directory>
```

3，上面用的相对目录,
> 因为在 httpd.conf 里面设置了
` ServerRoot “D:/wamp/bin/apache/apache2.2.17” `
或者用绝对目录也行.
` \wamp\bin\apache\Apache2.2.17\icons `

---

*** 如有疑问欢迎批评指正，谢谢！ ***
