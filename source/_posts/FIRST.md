---
title: FIRST
date: 2016-06-04 23:16:53
tags: 
    - github
    - hexo
categories: 
    - 随笔
---
  我的第一个私人博客，之前也一直想要有一个私人的博客，想租个vps和域名，可是没有money，自己维护也很麻烦就一直搁置了。

  最近借助github平台和hexo工具实现了这个小小的愿望，终于有了一个自己的blog，哈哈哈。。。

  下面是大致的安装过程。

<!--more-->

**大致过程如下**

## github
>* 首先在github上创建自己的账号，然后创建一个以自己名字命名的仓库，可以自己搜索怎么建立。

## 安装hexo
>* 首先安装node.js，因为hexo是基于node.js开发的一个静态博客框架
>* 安装hexo，安装的过程中可能需要更换npm源

``` bash
npm install hexo -g
```

## 初始化自己的blog
>* 创建一个文件夹作为自己以后blog的根目录
>* 进入该blog目录，进行初始化配置
>* 配置根目录下的__config.yml文件

``` bash
mkdir blog
cd blog
hexo init
hexo install
hexo new "newAticle" //创建新的文章，执行完之后会在sources/_post/目录下会有newAticle.md文件，打开进行编辑
hexo clean //清除本地缓存
hexo generate //生成网站
hexo serve //开启本地服务，可以在http://localhost:4000/中进行本地预览
hexo deploy //部署到github上
```

***以后每次添加新文章就按照 / hexo clean / hexo new "" / hexo generate / hexo deploy / 的顺序就可以添加新文章***

## 选择hexo主题，next
>* 安装next主题
>* 启用next主题,根目录下配置文件_config.yml配置theme: next
>* 优化配置next主题,在next主题文件目录下的配置文件_config.yml

``` bash
git clone https://github.com/iissnan/hexo-theme-next themes/next
```
---

>如有疑问欢迎批评指正，谢谢！
