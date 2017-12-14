---
title: linux命令学习 -- awk
tags:
  - linux
  - awk
categories:
  - linux
date: 2017-12-05 09:42:46
---

### 介绍

1，这个系列会一直进行下去，慢慢的积累用到的命令以及用法，需要用的时候可以方便查找，其实最简单的学习方法是man；
2，awk是一个文本处理工具，尤其是在分析大量日志的时候显得很重要，合理利用可以带来事半功倍的效果，下面结合几个简单的例子简单的分析说明；

<!-- more -->

### 用法
awk -F [field-separator] [filename] ...
> * field-separator 默认是空格
> * ... 可以是自定义表达式
> * 详细的用法可以查看man手册

### 详解

1， 过滤某字段
```shell
awk -F "|" filename '{print $1}'
# 表示按照竖线(|)分割filename文件中的每一行，
# 然后打印出第一列，{$NF}可以打印出最后一列，其中{NF}表示当前一共有多少列，$0表示整行
```
2， 统计某字段各种情况出现的次数
```shell
awk -F ":" filename '{a[$3]++}; END{for(i in a) print i, a[i]}'
# 表示按照分号(:)分割filename文件中的每一行，
# 然后统计第三列中每种情况出现的次数，最后END表示在结束的时候，通过for循环打印出这个hash数组，
# 打印的时候可以用print或者printf，其中printf的用法和C语言中printf的用法相似
```
1， 统计某字段的总和
```shell
awk -F "TEST" filename 'BEGIN{sum = 0}; {sum = sum + $5}; END{print sum}'
# 表示按照字符串"TEST"来分割filename文件中的每一行，
# 然后BEGIN表示在开始统计之前，这里可以做一些初始化的动作，本例中声明sum，并且为sum置初始值0，
# 接下来sum加上每行分割后的第五列的值，
# 最后END，打印出最终结果总和
```

### 后记

以上是我平时经常用到的几种方式，当然还有其它的使用方法和其它的参数，比如可以下awk的shell脚本处理文本等等

---

*** 如有疑问欢迎批评指正，谢谢！ ***
