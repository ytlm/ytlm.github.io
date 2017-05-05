---
title: hexo travis github
date: 2017-03-25 22:16:48
tags:
    - hexo
    - travis
    - github
categories:
    - 总结
---

利用hexo, travis, github联合的方式进行博客的创建并且自动发布.

1,首先是在github创建对应的github pages, 网上有很多教程,这里就不再赘述.
2,安装hexo环境用于生成静态博客,这里简单的列举下自己遇到的坑:
> (1). yml格式的配置冒号(:)后必须要有一个空格.
> (2). hexo generate不生效的时候要用hexo clean清空缓存.
> (3). hexo deploy失败的时候注意git公私钥的配置和_config.yml中deploy的配置.
> (4). 选择hexo的主题next,对于next主题的配置可以根据官网说经进行合理的配置.

3,travis的使用
> (1). 在(yourself).github.io的git上建立一个hexo分支,
       master分支用于页面的显示,
       hexo分支用于hexo生成博客和配置,便于同步.
> (2). travis ci的登陆通过github帐号登陆,然后开启(yourself).github.io的travis;
       然后在hexo的分支上创建并提交.travis.yml文件,注意github token的生成和使用
> (3). 最后就是在hexo的分支上进行写博客和提交到hexo分支上,剩下的发布到master上通过travis自动发布.

<!-- more -->

[参考这里](http://lotabout.me/2016/Hexo-Auto-Deploy-to-Github/)
[还有这里](https://zespia.tw/blog/2015/01/21/continuous-deployment-to-github-with-travis/)

---

*** 如有疑问欢迎批评指正，谢谢！ ***
