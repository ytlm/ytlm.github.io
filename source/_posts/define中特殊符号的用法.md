---
title: define中特殊符号的用法
tags:
  - C
  - define
categories:
  - C
date: 2018-02-07 15:06:22
---
在C语言中宏定义#define 是一个很有用处的一个特性，在看其它一些源码的时候宏定义#define中会出现一些特殊的符号，主要有`#` `##` `do{}while(0)`，这里记录以下这几种特殊符号的含义和用法

<!-- more -->

1，`#` 字符串化操作符
> 可以将宏定义中传入的参数转换成用一对双引号括起来的字符串

```C
#include <stdio.h>
#define STRING(str) #str
int main(int argv, char* argc[]) {
    char* str1 = STRING(test1);
    char* str2 = STRING( a bc    e);    // 参数中间出现空格，会将连续的空格替换成一个

    printf("str1 : %s\n", str1);        //结果 str1 : test1
    printf("str2 : %s\n", str2);        //结果 str2 : a bc e
    return 0;
}
```
2，`##`符号连接符
> 将宏定义中的多个参数连结成一个参数

```C
#include <stdio.h>
#define CONCAT(n) t##n
#define PRINT(n) printf("t" #n " = %d\n", t ## n)  // `##` 前后空格可有可无
int main(int argv, char* argc[]) {
    int CONCAT(1) = 10;         // int t1 = 10;
    int CONCAT(2) = 20;         // int t2 = 20;
    PRINT(1);                   // printf("t1 = %d\n", t1);
    PRINT(2);                   // printf("t2 = %d\n", t2);
    return 0;
}
```
3，`do{}while(0)`
* 不需要do{}while(0)的情况
```C
#define TEST(x) action1(x); \
                action2(x);
if (NULL == p)
    TEST(p);
// 在这种情况下会出现action1()会执行，action2()不会被执行的情况
```
* 仅仅使用{}的情况
```C
#define SWAP(x, y) {int tmp; tmp = x; x = y; y = tmp;}

if(x > y)
    SWAP(x y);
//这种情况下编译直接报错了，因为多了一个`;`
```

---

*** 如有疑问欢迎批评指正，谢谢！ ***
