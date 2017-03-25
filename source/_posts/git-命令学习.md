---
title: git 命令学习
date: 2016-07-24 14:52:07
tags: [git]
categories: 学习
---
下面是一些在平时学习git时经常需要用的一些命令
<!--more-->

* git stash
>把当前未提交的改动「复制」到另一个地方暂存起来，待要恢复的时候执行 git stash pop

* git commit --amend
>提交之后发现漏掉了某些文件,选择重新add后提交再次提交是不合理的，应该先add后执行git commit --amend

* git reset **filename**
>意外地把一个不需要的文件也 add 了，git reset **filename** 把这个文件重staging area位置移除出来，并且不会丢失任何数据

* git checkout **filename**
>快速扔掉该文件所有的变更，回到没有修改之前的状态

* git checkout -b xxx
>创建并且checkout到一个新的分支上

***未完待续，后续使用到 git 其他相关都会慢慢积累到这里***

---

>如有疑问欢迎批评指正，谢谢！