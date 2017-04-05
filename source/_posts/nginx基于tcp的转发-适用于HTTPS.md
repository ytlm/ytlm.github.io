---
title: 'nginx基于tcp的转发,适用于HTTPS'
date: 2017-04-05 09:52:22
tags:
    - nginx
    - https
categories:
    - 学习
---
## nginx的主要功能
1，正向代理
2，反向代理
3，负载均衡
4，WEB服务器
>通常用nginx主要做反向代理，负载均衡配合反向代理可以做到很多事情；
>nginx做WEB服务器可以实现动静文件分离；
>nginx有很多可选的模块，可以对nginx的功能进行扩展；
>openresty是一个基于nginx与lua的高性能平台，用lua进行扩展；

<!-- more -->

## ssl简单介绍
1，主要的作用是为了互联网安全；
2，SSL是介于HTTP和TCP之间的一个可选层，对于TCP/IP协议来说；
3，SSL与TLS之间的关系是TLS(Transport Layer Security)继承并增强了SSL(Secure Socket Layer)协议；
>具体的协议交互过程就不再这里展开了，详见参考连接；
>这里主要说下客户端在SSL协商初期发送的Client Hello请求，其中有个扩展选项，里面有个server name这个可用于转发。

## 配置nginx转发tcp
1，版本，nginx version: nginx/1.11.12；我测试用的是这个版本。
2，编译，配置
```
./configure  --with-stream  --with-stream_ssl_preread_module --with-stream_ssl_module
```
最主要的使用这几个模块，有需要可以添加其它的模块；然后编译安装make && make install。
3，配置，具体配置命令参考[pread module](https://nginx.org/en/docs/stream/ngx_stream_ssl_preread_module.html)和[stream module](https://nginx.org/en/docs/stream/ngx_stream_core_module.html)，启动的时候指定下面的配置文件

```nginx
user  root;
worker_processes  auto;
error_log  logs/error.log;
pid        logs/nginx.pid;
worker_rlimit_core   2G;
worker_rlimit_nofile 65535;
events {
    worker_connections  81920;
}
stream {
    log_format  main  '$remote_addr - [$time_local] $connection '
                      '$status $proxy_protocol_addr $server_addr ';
    access_log  logs/access.log  main;
    resolver 114.114.114.114;
    resolver_timeout 60s;
    variables_hash_bucket_size 512;
    server {
        listen       443;
        ssl_preread on;
        proxy_pass $ssl_preread_server_name:443;
        #大致看了一下源码，这里为什么需要配置端口也没有研究明白，求解释？
    }
}
```
4，目前测试基本上都是可以的，在日志中会有一些错误，不会影响正常服务，还再研究中。

## 参考连接
>https://nginx.org/en/docs/
>https://github.com/openresty/lua-nginx-module
>http://www.ruanyifeng.com/blog/2014/02/ssl_tls.html
>http://www.wosign.com/faq/faq2016-0309-04.htm
>https://segmentfault.com/a/1190000002554673

***如有问题欢迎批评指正，谢谢。***
