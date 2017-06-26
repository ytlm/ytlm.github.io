---
title: lua学习之元表和元方法
date: 2017-06-26 15:14:05
tags: lua
categories:
    - lua
---

学习lua也有大概一年了，对lua的一些基本的语法很熟练了，也做了一些简单的业务，但是对于lua的高级特性还是不是很熟，最近有时间得以系统的学习学习。本文主要讲述的是lua高级特性之一的元表和元方法。
### 文字简述
* metatable(元表) 本质上来讲元表也是一个表，不过这个表是用来定义对lua的值进行自定义运算行为的地方。
* metamethod(元方法) 本质上来讲就是一个lua函数，不过这个函数是用来绑定lua中特定的值，这些特定的值可以称为事件。这个函数我们可以进行我们一些自定义的操作。
> 元表之中的事件其实是一些定义的值，这些值后面会讲到；
> 实际上我们只能对lua中table类型的值进行修改元表和元方法的操作，其它的一些例如number, string等都已经有自己内置的元表和元方法，且不可改变。

* 通过元表和元方法，我们可以实现lua的面向对象编程。

<!-- more -->

### 代码讲解
#### api 介绍
简单的介绍一下会用到的api。
> `setmetatable(table, metatable)` 设置table的元表为metatable并且返回这个table。不能为除table类型之外的值设置元表，如果metatable为nil，则将指定的元表移除 。如果存在`__metatable`，则会抛出一个错误。
> `getmetatable(obj)` 返回一个类型的元表，如果没有元表返回nil。如果存在`__metatable`，则返回这个域的值。
> `rawget(table, index)` 在不触发任何元方法的情况下获取table中的值。也就是跳过元表和元方法。
> `rawset(table, index, value)` 在不触发任何元方法的情况下设置table[index]的值为value，index不能是nil和NaN

#### 元方法介绍
我们都知道对于两个number型的值，我们可以进行加，减，乘，除等的元算，但是对于table我们是不能直接进行这些预定义的运算的。但是通过通过元表和元方法我们是可以实现的；首先介绍下有哪些特定的值被用于绑定元方法，也称为事件，如下：
``` lua
__index -- 用于取操作
__newindex -- 用于赋值操作
__metatable -- 限定元表操作
__call -- 用于把一个函数当成函数调用的操作
__add -- '+' 加
__sub -- '-' 减
__mul -- '*' 乘
__div -- '/' 除
__mod -- '%' 取余
__pow -- '^' 次方
__unm -- '-' 取反
__concat -- '..' 连接
__tostring -- 字符串序列话
__len -- '#' 取长
__eq -- '==’ 相等
__lt -- '<' 小于
__le -- '<=' 小于等于
```
> 对于不同的lua版本可能这些事件还有区别，具体详细的可以看lua对应版本的介绍，这里只列出了一些常用的。
> 对于一些特定的事件进行一些简单的介绍
> > * __index 当我们在取一个table中的不存在这个index的值的时候，如果有元表的话，会触发这个操作，会到元表中进行查询，并且返回这个值，元表中月不存在的时候返回nil。
> > * __newindex 当我们对一个table中的一个不存在的index赋值的时候，如果有元表的话，会触发这个操作，如果元表中有定义这个行为，就按照这个进行。
> > * __metatable 使用这个元方法的时候是保护元表，进值对元表中的成员进行获取或者修改
> > * __call 使用这个的时候我们可以吧table当成函数来进行调用。

#### 代码分析
##### 简单的元方法
``` lua
local t1 = {1, 2, 3}
local t2 = {5, 6, 7, 9}
local t = {
    __add = function(a, b)
        local tmp = {}
        for i = 1, #a do
            tmp[i] = a[i] + b[i]
        end
        for i = #tmp + 1, #b do
            tmp[i] = b[i]
        end
        return tmp
    end,
    __tostring = function(a)
        local str = ""
        local split = ""
        for i = 1, #a do
            str = str .. split .. a[i]
            split = "|"
        end
        return str
    end
}
setmetatable(t1, t)
print("t1 : ", t1)
print("t2 : ", t2)
local tmp = t1 + t2
print("tmp : ", tmp)
setmetatable(t2, t)
print(" - t2 : ", t2)
setmetatable(tmp, t)
print(" - tmp : ", tmp)
```
> 运行结果如下
```
t1 :    1|2|3
t2 :    table: 0x16984f0
tmp :   table: 0x16981c0
 - t2 :         5|6|7|9
 - tmp :        6|8|10|9
```
> 当对两个table进行加(+)的操作的时候，会查找元表中对应的元方法，然后按照元方法的行为去做。其它的一些算术运算都和这个例子大同小异，就不多做介绍了。

##### __index
``` lua
local t1 = {}
local t2 = {}
t2.a = 10
setmetatable(t1, {__index = t2})
print(t1.a)
```
> 运行结果如下
```
10
```
> 当访问t1中的a的时候，t1中并没有这个值，但是t1有元表，则会到元表中查询a，并返回；
__index 也可以是一个函数，用于自定义的一些行为。

##### __newindex
``` lua
local t1 = {}
t1.c = 30
local t2 = {}
t2.a = 10
t2.b = 20
setmetatable(t1, {__newindex = t2})
print(t1.a)
print(t2.a)
t1.a = "a10"
print(t1.a)
print(t2.a)
print(t1.c)
t1.c = "c10"
print(t1.c)
print(t2.c)
```
> 运行结果如下
```
nil
10
nil
a10
30
c10
nil
```
> 在对t1中的变量进行赋值的时候，如果存在则直接进行赋值，如果不存在则触发__newindex，设置元表中对应的值

##### __metatable
``` lua
local t1 = {}
local t = {}
setmetatable(t1, t)
print(getmetatable(t1))
t.__metatable = "lock"
print(" metatable : ", getmetatable(t1))
setmetatable(t1, t)
```
> 运行结果如下
```
table: 0xe7f4f0
 metatable :    lock
lua: test.lua:11: cannot change a protected metatable
```
> 在设置完__metatable域的时候，就不能再对元表进行操作了，会报错。

##### __call
``` lua
local t1 = {}
setmetatable(t1, {
    __call = function(t, a, b, c, ...)
        local num = a + b + c
        print("__call str : ", num)
    end
})
t1(1, 2, 3)
```
> 运行结果如下
```
__call str :    6
```
> t1作为table，但是可以直接当成函数来进行调用，会查找__call元方法


##### rawget
``` lua
local t1 = {}
local t2 = {}
t2.a = 20
setmetatable(t1, {__index = t2})
print("t1 a : ", t1.a)
print("rawget t1 a : ", rawget(t1,a))
```
> 运行结果如下
```
t1 a :  20
rawget t1 a :   nil
```
> 设置完元表后可以取到t1中的a，从元表t2中，但是用rawget的时候会会忽略元表的存在

##### rawset
``` lua
local t1 = {}
local t2 = {}
t2.a = 20
setmetatable(t1, {__newindex = t2})
t1.b = "bbb"
print("t1 b : ", t1.b)
print("t2 b : ", t2.b)
rawset(t1, b, "ccc")
```
> 运行结果如下
```
t1 b :  nil
t2 b :  bbb
lua: table index is nil
```
> 正常的设置完元表并且设置\__newindex域之后，对t1中的不存在的b赋值的时候会触发\__newindex操作，但是如果用rawset的话就会报错，rawset(t1, b, "ccc")，会对t1中的b进行赋值，并不会触发\__newindex，而t1中也没有b这个值，所以报错了。

##### 系统代码
以一个之前写的例子结束这篇介绍
``` lua
--[[
    lua 5.1.5
    socket 2.0.2
]]--
local socket = require("socket")
local sub = string.sub
local byte = string.byte
local concat = table.concat
local tonumber = tonumber
local tostring = tostring
local _M = {
    _VERSION = "0.1",
}
local mt = { __index = _M }
function _M.new(self)
    local sock, err = socket.tcp()
    if not sock then
        return nil, err
    end
    return setmetatable({_sock = sock, _subscribed = false }, mt)
end
function _M.connect(self, ...)
    local args = {...}
    local sock = rawget(self, "_sock")
    if not sock then
        return nil, "not initialized"
    end
    self._subscribed = false
    return sock:connect(...)
end
function _M.close(self)
    local sock = rawget(self, "_sock")
    if not sock then
        return nil, "not initialized"
    end
    return sock:close()
end
local function _gen_req(args)
    local nargs = #args
    local req = ""
    req = req .. "*" .. nargs .. "\r\n"
    for i = 1, nargs do
        local arg = args[i]
        if type(arg) ~= "string" then arg = tostring(arg) end
        req = req .. "$"
        req = req .. #arg
        req = req .. "\r\n"
        req = req .. arg
        req = req .. "\r\n"
    end
-- print("req : ", req)
    return req
end
local function _read_reply(self, sock)
    local line, err = sock:receive()
    if not line then
        if err == "timeout" then
            sock:close()
        end
        return nil, err
    end
    local prefix = byte(line)
    if prefix == 42 then -- char "*"
        local n = tonumber(sub(line, 2))
        if n < 0 then return nil end
        local vals = {}
        local ind = 1
        for i = 1, n do
            local res, err = _read_reply(self, sock)
            if res then
                vals[ind] = res
                ind = ind + 1
            elseif not res then
                return nil, err
            end
        end
        return vals
    elseif prefix == 36 then -- char "$"
        local size = tonumber(sub(line, 2))
        if size < 0 then return nil, sub(line, 2) end
        local data, err = sock:receive(size)
        if not data then
            if err == "timeout" then
                sock:close()
            end
            return nil, err
        end
        local crlf, err = sock:receive(2)
        if not crlf then return nil, err end
        return data
    elseif prefix == 45 then -- char "-"
        return nil, sub(line, 2)
    elseif prefix == 43 then -- char "+"
        return sub(line, 2)
    elseif prefix == 58 then -- char ":"
        return tonumber(sub(line, 2))
    else
        return nil, "unknow prefix : \"" .. tostring(prefix) .. "\""
    end
end
local function _do_cmd(self, ...)
    local args = {...}
    local sock = rawget(self, "_sock")
    if not sock then
        return nil, "not initialized"
    end
    local req = _gen_req(args)
    local bytes, err = sock:send(req)
    if not bytes then
        return nil, err
    end
    return _read_reply(self, sock)
end
setmetatable( _M, { __index = function(self, cmd)
    local method = function (self, ...)
        return _do_cmd(self, cmd, ...)
    end
    _M[cmd] = method
    return method
end})
return _M
```
> 这是仿照lua-resty-redis，用luasocket实现的一个简单的lua redis客户端。
> 每次用的时候需要 require这个文件，并且调用new，设置相应元表，之后就可以进行简单的redis操作了。

### 后记
> * 本文代码部分比较多，尽可能的用代码来解释lua中元表和元方法的一些用法，如果理解起来还是不清楚可以查看lua官方文档，也可以联系我。

---

*** 如有疑问欢迎批评指正，谢谢！ ***
