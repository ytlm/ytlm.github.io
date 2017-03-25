---
title: git 忽略一个目录
date: 2016-07-24 14:45:09
tags: [git]
categories: 学习
---
[原文链接](https://segmentfault.com/q/1010000000608238 "原文链接")
```git
git rm -r --cached **dir** //首先删除已经跟踪并添加过的目录
echo **dir/** >> .gitignore //添加忽略文件，并向忽略文件中添加需要忽略的目录
git add .gitignore //让git跟踪忽略文件
git commit -m 'ignore **dir** forever' //提交忽略文件
```
---

>如有疑问欢迎批评指正，谢谢！