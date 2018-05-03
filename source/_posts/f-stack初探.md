---
title: f-stack初探
tags:
  - f-stack
  - nginx
  - dpdk
categories:
  - dpdk
date: 2018-05-03 09:28:15
---

### 介绍
[f-stack](http://www.f-stack.org/)是基于[DPDK](https://dpdk.org)(Data Plante Development Kit)实现的一个用户态的协议栈；DPDK主要是操作系统内核数据平面，重载网卡驱动，减少内核中断，内存拷贝和上下文切换；在此之前Linux数据平面和控制平面混在一起，不适合处理大规模的网络数据包；f-stack是基于DPDK从FressBsd协议栈移植而来的用户态协议栈；详细解释何以看相关blog，论坛和官网文档；

<!-- more -->

### 编译
* 环境
> * Linux centos 4.16.5-1.el7.elrepo.x86_64 #1 SMP Thu Apr 26 09:54:55 EDT 2018 x86_64 x86_64 x86_64 GNU/Linux
> * 00:19.0 Ethernet controller: Intel Corporation Ethernet Connection (3) I218-LM (rev 03)

* 依赖
> `yum install kernel-devel kernel-headers  pciutils net-tools libpcap-devel numactl* gcc*`
> 主要就是kernel-devel和kernel-headers安装kernel对应的版本

* 编译
> * 下载
> > 可以直接从[github](https://github.com/F-Stack/f-stack)上clone
>
> * 编译DPDK
> > 1),`cd f-stack/dpdk`  # 进入dpdk文件夹
> > 2),`make config T=x86_64-native-linuxapp-gcc`   # 这里选择x86_64-native-linuxapp-gcc
> > 3),`make` # 编译，这里可能会出现一些错误，基本都是kernel版本和dpdk版本不匹配造成的，可以搜索相关的patch
>
> * 编译f-stack
> > 1),设置环境变量 `export FF_PATH=/data/f-stack`和`export FF_DPDK=/data/f-stack/dpdk/x86_64-native-linuxapp-gcc` `FF_PATH`是f-stack所在的目录，`FF_DPDK`是dpdk编译好的目录
> > 2),`cd f-stack/lib && make`
>
> * 编译nginx
> > 1),`cd f-stack/app/nginx-1.11.10` # 进入f-stack中nginx的目录
> > 2).`./configure --prefix=/data/nginx-fstack --with-ff_module && make && make install` # --prefix选择安装目录，--with-ff_module包含fstack nginx module

### 配置
1), 在配置之前要保存网卡的相关信息，包括ip地址，netmask子网掩码，gateway网关，broadcast广播地址
```bash
# 确认网卡名称，我这里是enp0s25
myip=`ip addr show enp0s25 | grep inet | grep -v ':'  | awk '{print $2}' | awk -F '/' '{print $1}'`
mybroadcast=`ip addr show enp0s25 | grep brd | grep -v ':' | awk '{print $4}'`
mynetmask=`ipcalc -m $(ip addr show enp0s25 | grep inet | grep -v ":"  | awk '{print $2}') | awk -F '=' '{print $2}'`
mygateway=`route -n | grep 0.0.0.0 | grep enp0s25 | grep UG | awk -F ' ' '{print $2}'`

# 替换配置文件中的相关配置
sed "s/addr=192.168.1.2/addr=${myip}/" -i f-stack/config.ini
sed "s/netmask=255.255.255.0/netmask=${mynetmask}/" -i f-stack/config.ini
sed "s/broadcast=192.168.1.255/broadcast=${mybroadcast}/" -i f-stack/config.ini
sed "s/gateway=192.168.1.1/gateway=${mygateway}/" -i f-stack/config.ini
```
2), 配置大页内存 set hugepage
```bash
# single-node system
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# NUMA
echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages

mkdir /mnt/huge
mount -t hugetlbfs nodev /mnt/huge
```
3), 安装DPDK驱动并绑定网卡
```bash
# 确保依赖，要不然安装的时候会出前错误，类似 unknow symbol in module
modinfo  f-stack/dpdk/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko | grep depends
modinfo  f-stack/dpdk/x86_64-native-linuxapp-gcc/kmod/rte_kni.ko | grep depends
modprobe uio # 我这里只有uio一个

# 安装
insmod f-stack/dpdk/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
insmod f-stack/dpdk/x86_64-native-linuxapp-gcc/kmod/rte_kni.ko

python f-stack/dpdk/tools/dpdk-devbind.py --status # 用于查看设备的状态

# 绑定网卡
ip link set enp0s25 down  # 绑定之前需要处于非激活状态
python f-stack/dpdk/tools/dpdk-devbind.py --bind=igb_uio enp0s25
```

### 测试
* 启动
```bash
cd /data/nginx-fstack && ./sbin/nginx && ps -ef | grep nginx
```
* 运行
```bash
curl -vo "http://192.168.55.177/" # 192.168.55.177是${myip},这里会看到nginx的响应,说名安装成功
```

### 后记
* 一些DPDK的详细概念，和f-stack的详细配置，可以参看相关文档；
* 这些都是在自己的机器上做的，在其它的机器上可能有一些会不一样，本文仅作参考；
* 对于性能还没有来得及测试，后续有机器可以补上；

### 参考连接
```
https://dpdk.org/
http://www.f-stack.org/
https://github.com/F-Stack/f-stack
https://www.jianshu.com/p/0ff8cb4deaef
https://cloud.tencent.com/developer/column/1275
```

---

*** 如有疑问欢迎批评指正，谢谢！ ***
