---
title: 初识SystemTap
tags:
  - systemtap
categories:
  - systemtap
date: 2017-12-28 09:45:38
---
systemtap是一个诊断linux系统性能和功能问题的开源软件，并且允许开发人员编写和重用简单的脚本深入探查linux系统的活动，可以快速安全的提取过滤总结数据，以便能够诊断复杂的性能或功能问题。

<!-- more -->

### 环境
* Cenots 7.4.1708 Core
* Kernel 3.10.0-693.11.1.el7.x86_64

### 安装
* sudo yum install systemtap systemtap-runtime
* sudo yum install kernel-devel-`uname -r` kernel-debuginfo-`uname -r`
* stap -v -e 'probe vfs.read {printf("Hello World\n"); exit()}'

> 在安装kernel-devel kernel-debuginfo 的时候一定要安装和kernel版本一致的版本，否则是没用的
> 还可以直接下载rpm包安装[地址](http://debuginfo.centos.org/)
> 最后一个步骤是检查是否安装成功，如果正确的安装过后，会输出`Hello World`

### 流程
* 基本思想是name events(命名事件)，并给它们处理程序。每当事件发生的时候，linux内核运行处理程序，就像一个子程序一样，之后恢复。处理程序是一系列的脚本语言，用于指定事件完成时要完成的工作，这种工作通常包括是提取数据，打印结果等；
* systemtap通过stap将脚本装换成C源代码，运行系统的时候创建一个内核模块，当模块加在的时候，它通过挂载到内核的钩子来激活所有的探测事件。最后，这次事件结束的时候，挂载的钩子断开连接执行清楚进程，移除模块，退出所有相关的程序；

### 语法
从语法上来讲很多都是和C语言通用的，条件结构，顺序结构，循环结构，等等
#### 类型模式
* begin；在脚本开始的时触发
* end；在脚本结束时触发
* kernel.function("sys_sync")；在调用sys_sync时触发
* kernel.function("sys_sync").call；在调用sys_sync时触发
* kernel.function("sys_sync").return；在sys_sync返回时触发
* kernel.syscall.* ；在进行任何系统调用时触发
* kernel.function("*@kernel/fork.c:934")；在执行到fork.c的第934行时触发
* timer.ms(200)；每隔200毫秒触发一次
* timer.ms(200).randomize(50)；每隔200毫秒触发一次，带有线性分布的随机附加时间(-50到+50)
* timer.jiffies(1000)；每隔1000个内核[jiffy](http://man7.org/linux/man-pages/man7/time.7.html)触发一次

### 例子
```stap
#!/usr/bin/env stap
global syscalllist
probe begin {
    printf("start ... \n")
}
probe syscall.* {
    syscalllist[pid(), execname()]++
}
probe timer.s(5) {
    printf("-----------------------------\n")
    foreach ( [pid, cname] in syscalllist ) {
        printf("%s[%d] = %d\n", cname, pid, syscalllist[pid, cname])
    }
    delete syscalllist
    exit()
}
```
begin 开始的时候会打印出"start ... "
syscall.* 这里会统计所有的系统调用，并按照pid和name进程名称的方式存到syscalllist数组中
timer.s(5) 每隔5秒就会调用一次，这里遍历syscalllist数组，打印相关信息
这里只打印了当前5秒之内的系统调用，之后就exit()退出了
通过`stap call.stp`来执行call.stp这个脚本，下面是我这里运行的时候截取的一部分输出
> stapio[24669] = 93
> EMT-1[8464] = 11181
> EMT-0[8464] = 7126
> Chrome_IOThread[3595] = 4852
> Timer[8464] = 670
> chrome[3595] = 11339
> Chrome_ChildIOT[3818] = 2418
> Compositor[3818] = 1500
> chrome[4276] = 1624
> nginx[21997] = 3
> avahi-daemon[854] = 9888
> VirtualBox[8464] = 423
> X[1785] = 966
> gnome-shell[2557] = 1373
> VUsbPeriodFrm[8464] = 512
> INTNET-RECV[8464] = 611


### 后记
* 这里只是简单的接触和学习了一下SystemTap，想要把这个用到实际的项目中还需要继续深入的研究和学习。

### 参考连接
> https://www.ibm.com/developerworks/cn/linux/l-systemtap/index.html
> https://sourceware.org/systemtap/
> https://en.wikipedia.org/wiki/DTrace
> https://en.wikipedia.org/wiki/SystemTap

---

*** 如有疑问欢迎批评指正，谢谢！ ***
