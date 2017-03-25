---
title: Wamp更改web根目录
date: 2016-07-24 15:44:08
tags: [Wamp]
categories: 软件
---

[原文链接](http://blog.csdn.net/xia777xia/article/details/6282346)
Wampserver安装好后，“www目录”默认为X:/wamp/www，（这里的X是盘符）也就是wampserver安装目录下的www文件夹。实际使用中，默认设置往往不是我们想要的，可能改成其他文件夹更适合我们。

比如e:/xx 或者 d:/php等等。

下面以原来的默认目录为d:/wamp/www改为e:/xx为例。

<!--more-->

1,

>打开wamp/scripts/config.inc.php
第47行，$wwwDir = $c_installDir.’/www’;
修改为：$wwwDir = ‘e:/xx’;即可。
但这时新问题来了，Apache默认根目录还没改过来！继续看第2步！

2,

>修改Apache默认根目录
打开wamp/bin/apache/apache2.2.11/conf/httpd.conf,修改DocumentRoot后面双引号中的值为你所要的。
比如将DocumentRoot “D:/wamp/www/”
改成DocumentRoot “e:/xx/”
同时将<Directory “D:/wamp/www/“>
改成<Directory “e:/xx/“>

3,
>重启wampserver即可生效。

---

>如有疑问欢迎批评指正，谢谢！