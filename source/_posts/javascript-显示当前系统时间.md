---
title: javascript 显示当前系统时间
date: 2016-07-24 15:00:15
tags: [javascript]
categories: 学习
---
学习js时候的一些简单的纪录，用js实现显示当前系统时间

>详细代码如下

<!--more-->

js实现
```javascript
	setInterval(function (){
		var date = new Date();
		var now = "现在时间是： ";

		now += date.getFullYear() + " 年 ";
		now += (date.getMonth()+1)+ " 月 ";
		now += date.getDate()     + " 日 ";
		now += date.getHours()    + " 时 ";
		now += date.getMinutes()  + " 分 ";
		now += date.getSeconds()  + " 秒 ";

		var week = new Array("日", "一", "二", "三", "四", "五", "六");
		var weekIndex = date.getDay();

		now += " 星期" + week[weekIndex];

		$("#time").html(now);
	}, 1000);
```
html代码
```html
<div id="time"></div>
```
结果截图

![显示时间样式](/images/jstime.png)

---

>如有疑问欢迎批评指正，谢谢！
