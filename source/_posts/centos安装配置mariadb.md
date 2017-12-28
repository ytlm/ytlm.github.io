---
title: centos安装配置mariadb
tags:
  - mariadb
categories:
  - mariadb
  - linux
  - centos
date: 2017-12-28 09:44:42
---

这里简单介绍一下在centos环境下mariadb的安装和配置

<!-- more -->

### 环境

* CentOS 7.4.1708 Core
* Kernel 3.10.0-693.11.1.el7.x86_64

### 安装

`sudo yum install mariadb mariadb-server`
> 这里可能需要安装epel扩展源
> 只需要一行命令，就是那么任性0.0

### 配置
#### 命令
* `sudo systemctl start mariadb` 启动数据库
* `sudo systemctl enable` 开机自启
* `mysql -uroot -p'password'`  通过密码登陆
* `sudo systemctl restart mariadb` 重启数据库

#### 初始配置
`mysql_secure_installation` 初始配置，这里要先启动数据库
> Enter current password for root (enter for none): "初始运行，没有密码，直接回车"
> Set root password? [Y/n]  “是否设置密码，这里需要设置密码所以输入y，然后回车”
> New password: "输入密码"
> Re-enter new password: "再次输入密码确认"
> Remove anonymous users? [Y/n]  "是否删除匿名用户，这里输入y，然后回车"
> Disallow root login remotely? [Y/n] "是否禁止root远程登陆，因为可能需要远程登陆，所以这里输入n，然后回车"
> Remove test database and access to it? [Y/n]  "是否删除测试数据库，根据需要"
> Reload privilege tables now? [Y/n]  "是否重新加载权限，数据y，然后回车"
> 至此初始化配置已经完成，可以尝试登陆和学习

#### 字符集配置
* 打开 `/etc/my.cnf`,在[mysqld]下添加如下配置
> [mydqld]
> init_connect='SET collation_connection = utf8_unicode_ci'
> init_connect='SET NAMES utf8'
> character-set-server=utf8
> collation-server=utf8_unicode_ci
> skip-character-set-client-handshake

* 打开`/etc/my.cnf.d/client.cnf`,在[client]下添加如下配置
> [client]
> default-character-set=utf8

* 打开`/etc/my.cnf.d/mysql-clients.cnf`，在[mysql]下添加如下配置
> [mysql]
> default-character-set=utf8

* 重启数据库

### 权限配置

* 允许外网登陆
> `grant all privileges on *.* to root@'%' identified by 'password';`

* 授权用户可以授权
> `grant all privileges on *.* to root@'127.0.0.1' identified by 'password' with grant option;`

* 使这些配置生效，这里一定要执行
> `flush  privileges;`

* 外网登陆命令
> `mysql -h 'ip' -u 'root' -P 3306 -p'password'`
> -h `ip`为远程数据库ip地址，
> -P `3306`是数据库默认端口，
> -u root 登陆用户名，
> -p`password` 登陆用户对应的密码；
> * 外网登陆的时候可能会遇到防火墙的原因，导致连接失败，需要根据以下配置防火墙
> * `iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT`
> * `iptables-save > /etc/iptables/iptables.rules`
> * `systemctl reload iptables` || `iptables-restore < /etc/iptables/iptables.rules`

### 后记
* 之前装过一次，在本地登陆进去之后，创建数据库的时候一直有权限错误，在搜索之后并没有得到解决，所以就把这些全部删除，尤其是要把之前的数据库删除，一般默认位置是在`/var/lib/mysql`目录下面，然后重新安装配置一遍就正常了，这里简单的记录一下以后有问题可以来此查看。

---

*** 如有疑问欢迎批评指正，谢谢！ ***
