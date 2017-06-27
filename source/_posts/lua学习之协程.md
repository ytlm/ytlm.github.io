---
title: lua学习之协程
date: 2017-06-27 11:01:27
tags:
    - lua
categories:
    - lua
---
lua中的另一个高级功能是coroutine(协程)，协同式多线程的意思，不同于线程和进程，协程仅在显示的调用一个让出(yield)函数时才会挂起当前的执行，同一时间内只有一个协程正在运行，非抢占式的。

<!-- more -->

### api介绍
> * `coroutine.create( fun )` *** 参数： *** 是一个函数，是这个协程的主体函数。*** 返回值： *** 返回一个新的协程，类型为"thread"。*** 作用： *** 创建一个新的协程。
> * `coroutine.yield( ... )` *** 参数： *** 任意变长参数。*** 返回值： *** 状态true或者false表示这个协程有没有挂起成功，然后返回传递的变长参数，全部返回给上次的coroutine.resume()调用。*** 作用： *** 挂起一个正在运行的协程，这个是有限制的，比如在调用C函数中和一些迭代器中是不能yield的。
> * `coroutine.resume( co, ... )` *** 参数： ***  一个协程，通过coroutine.create()创建的，加上自定义参数，这些自定义参数都会传递给协程的主函数。***
 返回值： *** 一个boolean型的值表示有没有正确执行，之后的返回值都是coroutine.yield()中的参数。如果第一个值是false，后面的是错误信息。*** 作用： *** 运行一个协程直到函数执行完或者函数调用coroutine.yield()主动退出。
> * `coroutine.wrap( fun )`，*** 参数： ***  一个函数。***  返回值： *** 和coroutinue.resume()相同，只不过没有boolean变量。*** 作用： *** 和coroutine.create()相似，只不过返回的是一个函数，每次调用这个函数就继续执行这个协程。传递给这个函数的参数都将作为coroutine.resume()额外的参数。
> * `coroutine.running( )` *** 参数： *** 无。*** 返回值： *** 返回正在运行的协程否则返回nil。
> * `coroutine.status( co )` *** 参数： *** 一个协程。*** 返回值： *** 返回这个协程当前的状态，主要有，* running * 表示正在运行；* suspended * 表示没有运行或者yield让出的状态；* normal * 表示协程是活的，但是并不在运行（正在延续其它的协程）；* dead * 表示协程执行完毕或者因错误停止。

### 代码
``` lua
local function test(a)
    print("test : ", a)
    return coroutine.yield(2 * a)
end
local co = coroutine.create( function(b, c)
    print("running : ", coroutine.running())
    print("co-body 1 : ", b, c)
    local r = test(b + 1)
    print("co-body 2 : ", r)
    local n, m = coroutine.yield(b - c, b + c)
    print("co-body 3 : ", n, m)
    return "begin", "end"
end)
print("test status 1 : ", coroutine.status(co))
print("main 1 : ", coroutine.resume(co, 1, 9))
print("main 2 : ", coroutine.resume(co, "r"))
print("main 3 : ", coroutine.resume(co, "n", "m"))
print("main 4 : ", coroutine.resume(co, "x", "y"))
print("test status 3 : ", coroutine.status(co))
```
> 结果如下
```
test status 1 :         suspended
running :       thread: 0x1e64df0
co-body 1 :     1       9
test :  2
main 1 :        true    4
co-body 2 :     r
main 2 :        true    -8      10
co-body 3 :     n       m
main 3 :        true    begin   end
main 4 :        false   cannot resume dead coroutine
test status 3 :         dead
```
结合上面的介绍和代码可以简单的理解各个函数的作用，并且对lua的协程有一个感性的认知。

### 示例
经典的生产者消费者问题，我们用lua协程的方式来实现一遍
``` lua
local function send(p)
    print("product send : ", p)
    coroutine.yield(p)
end
local product = coroutine.create(function()
    while(true) do
        local p = io.read()
        send(p)
    end
end)
local function receive(co)
    local ok, res = coroutine.resume(co)
    if ok then
        print("consumer received : ", res)
    else
        print("consumer receive failed : ", res)
    end
end
local function consumer(co)
    while (true) do
        receive(co)
    end
end
consumer(product)
```
> 运行结果
```
hello world
product send :  hello world
consumer received :     hello world
1234567890
product send :  1234567890
consumer received :     1234567890
1 + 1 = 2
product send :  1 + 1 = 2
consumer received :     1 + 1 = 2
```
大致的解释一遍，程序会创建一个product协程，然后consumer函数调用recieve的时候会唤醒生产者协程主函数，主函数会把得到的值yield出去，这一步做了两个事情，一个是把得到的值返回给消费者，另一个是挂起自己，等待下次被激活。

### 后记
* 通过lua的协程我们可以用同步的方式写出异步的程序。
* 当然本文只是简单的介绍lua的协程机制，具体到实际应用的话，还是会有很多变化的，[lua-resty-http](https://github.com/pintsized/lua-resty-http)是使用ngx_lua socket实现的一个http客户端，其中就有用到协程相关，有兴趣可以看看具体的实现。

---

*** 如有疑问欢迎批评指正，谢谢！ ***
