---
title: 关于nginx缓存配置指令用法详解
date: 2017-04-18 10:53:11
tags:
    - nginx
    - cache
categories:
    - nginx
---
## nginx简介
众所周知nginx近些年在服务器领域占据着很重要的作用，目前我主要接触的关于nginx是作为代理服务器来用的，至于再详细的，有兴趣的可以查阅相关文档[nginx](http://nginx.org/)，就不在这里赘述。本文主要讲述的是把nginx配置成一个缓存服务器组件来用，尽可能详细的把nginx关于缓存的指令解释清楚。

<!-- more -->

## 配置指令详解

* *** proxy_buffering *** on | off

> * 控制着缓存的总开关，如果设置off缓存就不会生效；设置on缓存相关的配置才会生效；
> * 缓存的开关也可以通过设置"X-Accel-Bufferinf"这个header为"yes" | "no"来控制；
> * "X-Accel-Buffering"这个header可以被proxy_ingore_headers指令忽略；
* *** proxy_cache ***  *zone* | off
> * 定义一个共享内存用于缓存，其中主要存一些缓存文件的主要信息，用于检索；
> * 同一个共享内存可以被用于不同的地方，* zone *可以支持配置变量；
> * off 的意思是禁用从上层继承的缓存配置；

* *** proxy_cache_background_update ***  on | off

> * 允许在后台发送子请求来更新过期的缓存文件；
> * 这个一般都不常用，一般一个请求过来判断一下缓存时间，如果 过期了再从后端取就行了；

* *** proxy_cache_bypass ***  string ...

> 如果配置的字符串传中有一个不为空并且不等于"0"，这时候这个请求的相应就不会从缓存中取，应该到后端去取数据；

* *** proxy_no_cache *** string ...

> 如果响应的数据中有任何一个满足让字符串中的值至少有一个不为空并且不等于"0"，那么这个响应就不会被缓存下来；

* *** proxy_cache_key *** string

> * 配置缓存的key，缓存相关的内容都是根据这个key来进行查找的；
> * key的配置很有灵活性，不同的配置可以达到不同的效果；

* *** proxy_cache_lock *** on | off

> 设置为on的时候，表示在同一时间如果请求同一个cache key的多个请求在没有缓存的情况下只有一个请求会通过后端取数据，其它的请求直接取上个请求的缓存，或者等到超时，直接也去后端去取数据；

* *** proxy_cache_lock_timeout *** time

> * 这个超时时间就是上面的超时时间，如果proxy_cache_lock打开的时候，同一时间同一资源只有一个请求会到后端取数据，其它的请求如果达到这个超时时间之后也会直接到后端取数据；
> * 过了超时时间之后去到后端取下来数据不会缓存下来；

* *** proxy_cache_lock_age *** time

> * 这个的意思是在time时间内一个请求还没有将数据完全从后端取下来并且缓存，那么下一个请求就会被发送到后端，并且这时候也要把数据缓存下来；
> * 这个lock age和上个lock timeout一直没有搞清楚根本的区别，这里只是简单的解释一下，我好像用的也不多，如果谁能够解释一下还望不吝赐教，谢谢0.0；

* *** proxy_cache_methods GET | HEAD | POST ...

> 如果客户端请求的方法在这个配置的方法列表中，这个请求才有可能被缓存，缓存还受其它的条件制约；

* *** proxy_cache_path *** path [一堆的可选参数]

> * proxy_cache_path /data/nginx/cachet levels=1:2 use_temp_path=off keys_zone=data:60m inactive=365d max_size=10m；
> * 上面是一个典型的配置，下面来解释一下每个的含义 ：
> > * /data/nginx/cachet : 这个表示缓存文件实际的存储路径；
> > * levels=1:2 : 这个表示缓存文件的分级存储，如果不这样设置的话所有的文件都在同一个文件夹下面，看着比较乱，如果配成这样，缓存文件在实际上大概像这样 *** /data/nginx/cache/c/29/b7f54b2df7773722d382f4809d65029c ***；
> > * ues_temp_path=off : 禁用缓存响应到临时目录，直接缓存到缓存目录；
> > * keys_zone=data:60m : 设置一个共享内存和大小，里面存储的是缓存文件的一些key信息，在测试的时候发现1m的共享内存大概能够存8k左右个key；
> > * inactive=365d : 设置缓存时间，这个也受其它的条件限制，比如说响应头有Cache-Control: max-age=10，这样只能缓存10s；
> > * max_size=10m; 设置这个缓存目录的总大小，大小要根据配置的共享内存进行合理的配置；如果超过这个大小会通过LRU算法进行淘汰；

* *** proxy_cache_valid *** [code ... ] time

> 设置特定的响应状态码缓存特定的时间；

## 后记
* 上面就是我平常用到的关于nginx缓存的配置，组合起来还是能够达到很多需求的；
* 这里只是介绍我平常接触到很多的指令，还可能有一些我没有接触过的关于缓存的配置指令，欢迎补充；
* 另外在配置缓存目录的时候通过proxy_cache_path和proxy_cahce配置多个来达到把不同的缓存存储到不同的目录，这个时候就涉及到负载均衡了，要不然不同的目录缓存的大小不一样；

## 参考链接
> http://nginx.org/en/docs/http/ngx_http_proxy_module.html

---

*** 如有疑问欢迎批评指正，谢谢！ ***
