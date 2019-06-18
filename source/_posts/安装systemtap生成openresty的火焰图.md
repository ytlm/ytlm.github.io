---
title: 安装systemmap生成openresty的火焰图
date: 2017-04-27 18:50:32
tags:
    - nginx
    - openresty
    - systemmap
    - linux
categories:
    - nginx
---
## SystemTap
### 简单介绍
* [systemtap](https://sourceware.org/systemtap/)是一个诊断linux系统性能和功能问题的开源软件，并且允许开发人员编写和重用简单的脚本深入探查linux系统的活动，可以快速安全的提取过滤总结数据，以便能够诊断复杂的性能或功能问题。
* 基本思想是name events(命名事件)，并给它们处理程序。每当事件发生的时候，linux内核运行处理程序，就像一个子程序一样，之后恢复。处理程序是一系列的脚本语言，用于指定事件完成时要完成的工作，这种工作通常包括是提取数据，打印结果等。
* systemtap通过将脚本装换成C，运行系统的时候创建一个内核模块，当模块加在的时候，它通过挂载到内核的钩子来激活所有的探测事件。最后，这次事件结束的时候，挂载的钩子断开连接，移除模块。

<!-- more -->

> systemtap工具功能很强大，目前刚接触，在此仅仅通过[官网](https://sourceware.org/systemtap/tutorial/Introduction.html)做一些简单的介绍。

### 安装
* 环境 centos 7，直接用`yum install systemtap systemtap-runtime`安装，如果遇到依赖包的问题，安装所需要的依赖就好了；
* 另外需要注意一个重要的问题是需要安装kernel-debuginfo和kernel-debuginfo-common；可以直接用yum安装也可以[下载rpm](http://debuginfo.centos.org/)包安装；但是 ** 必须要和kernel版本一样 **
* 安装完成后可以用`stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'`测试，如果不出意外的话会正常输出的

> 表示在这里被坑了好久，全部安装好后运行的时候一直报错，累。。。

## Openresty
### 介绍
* [OpenResty](http://openresty.org/)是一个动态的基于nginx和lua的网络平台。把nginx和lua集成在一起，可以通过lua完成一些复杂的需求，而不用再去开发C层面的module了，同时性能也很理想。

> * 目前应该直接集成[LuaJIT](http://luajit.org/)了，简单来说LuaJIT是lua的一个更高性能的版本。

### 安装
* 直接到官网下载源码进行编译安装就行了，如果遇到一些依赖，就直接安装依赖就行了。

> 目前在做nginx的相关工作，所以对openresty了解的比较多一点，如有兴趣，欢迎共同交流。

## 火焰图
### 介绍
* [火焰图(Flame Graphs)](https://github.com/brendangregg/FlameGraph)是一个通过可视话堆栈的方法，可以直观的看出每个函数占用cpu的时间，内存，off-cpu等等，对于我们排查软件问题很有帮助。
* 显示的是，Y轴是堆栈的深度，X轴是样本数量。每个样本（函数）是一个矩形。鼠标点击可以看到一些详细的信息。通过这些可以看出那些需要调整优化。

> 对于火焰图也是最近才了解到的，有些解释可能很牵强，误怪，后面会慢慢的了解学习的。

### 生成
* openresty提供了一套完整的[工具](https://github.com/openresty/openresty-systemtap-toolkit)用于探测运行的状况。可以直接下载并根据介绍运行。
* 然后下载[FlameGraph](https://github.com/brendangregg/FlameGraph)火焰图生成工具，用于把前面采样到的信息绘制成火焰图。
* 然后在浏览器中打开进行观察分析。

> 在采样信息的时候需要让nginx在压力很大的情况下，这样得出的结果才会有更大的参考性。

### 分析火焰图
* 采样C层面的信息进行分析

> 1. sudo ./sample-bt -p 15507 -t 60 -u -a '-DMAXACTION=100000' > /tmp/nginx.bt
> > -p 表示nginx的worker的pid
> > -t 表示采样时间
> > -u 表示在用户空间
> > -a 传递一些参数，因为我自己的机器的原因所以需要传递这个参数，要不然会报错的
> 2. sudo ./stackcollapse-stap.pl /tmp/nginx.bt > /tmp/nginx.cbt
> 3. sudo ./flamegraph.pl /tmp/nginx.cbt > /tmp/nginx.svg
> 4. 用浏览器打开/tmp/nginx.svg

![openresty C层面的火焰图](https://drive.google.com/uc?export=view&id=1WxAEn4a10UGygSMhyc8sSQHgt4nwWg6c)
> 我用wrk给nginx的压力还不是很大大概CPU才20%左右，所以这个不是很准确的；但是也可以看出一些问题，比如看出在发送数据的时候还是有问题的，都在body_filter阶段，可能因为我用了很多的buffer的原因

* 采样lua层面的信息进行分析，在编译luaJIT的时候需要添加`CCDEBUG=-g`参数

> 1. sudo ./ngx-sample-lua-bt -a '-DMAXACTION=100000' -p 4790 --luajit20 -t 60 > /tmp/lua.bt
> > 各个参数的意思和上面的一样。
> 2. sudo ./fix-lua-bt /tmp/lua.bt > /tmp/lua-fix.bt
> 3. sudo ./stackcollapse-stap.pl /tmp/lua-fix.bt > /tmp/lua-fix.cbt
> 4. sudo ./flamegraph.pl /tmp/lua-fix.cbt > /tmp/lua-fix.svg
> 5. 浏览器打开/tmp/lua-fix.svg
> 图的话在这里就不再贴出来了

## 后记
* 上面用`sample-bt`生成的是on-cpu的相关数据，也可以用`sample-bt-off-cpu`生成off-cpu的相关分析数据，具体的区别可以到相关网站进行详细的了解；
* 首先呢，这个火焰图是一个很好的分析工具，相信可以为我们再排查问题的时候提供很大的帮助，目前我也是刚接触这个工具，还在慢慢摸索学习当中；
* 另外一个就是在安装遇到过很多的坑，也相当无语，但是都通过google慢慢的一个一个解决了，要有一颗永不放弃的心不是吗；

---

*** 如有疑问欢迎批评指正，谢谢！ ***
