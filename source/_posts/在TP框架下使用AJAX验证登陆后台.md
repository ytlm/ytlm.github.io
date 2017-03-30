---
title: 在TP框架下使用AJAX验证登陆后台
date: 2016-07-23 19:34:34
tags: 
    - ThinkPHP
    - Jquery
    - AJAX
categories: 
    - 学习
---

### 在TP框架下使用AJAX验证登陆后台 ###
>主要分为前台页面，js，后台php的实现，代码如下

<!--more-->

##### *前台页面* #####
```html
<script type="text/javascript">var handleUrl = '{:U("Home/Login/handle", "", "")}';</script>

<form id="login"><table align="center"> 
<tr>  <th>帐号:</th><td><input type="username" name="username"/></td></tr>
<tr><th>密码:</th><td><input type="password" name="password"/></td></tr>
<tr><th>验证码:</th><td><input type="code" name="code"/> <img src="{:U('Home/Login/verify', '', '')}" id="code" onclick="javascript:change_code()" /></td></tr>
<tr><th><input type="reset" class='reset' value="重置" /></th>
	<td> <input type="submit" class="submit" value="登录"/></td>
</tr>
<tr><td colspan="2" ><div id="errM"></div></td></tr>
</table></form>
```

##### *JS* #####
```Jquery
$(function(){
  var username = $("input[name='username']");
  var password = $("input[name='password']");
  var code = $("input[name='code']");
  $("input[type='submit']").click(function(){
      event.preventDefault();//取消默认提交表单
      $.post(
            handleUrl,
            {username:username.val(), password:password.val(), code:code.val()},
            function(data){
                if(data.status == 1){
                    window.location.href = data.url;
                }
                $("#errM").html(data.info);
            }, "json");})
})
```

##### *TP后台实现* #####

```ThinkPHP
public function handle(){
	if(!IS_AJAX) $this->error("页面不存在。。。");
	$code     = I('code');
    $username = I('username');
    $pwd      = I('password', '', 'md5');
    $data = array(); 
    if ( !$this->checkCode($code) ) {
    	//检查验证码是否正确
        $data['info']   = "验证码错误,请检查重试。。。";
        $data['status'] = 0;
        $data['url']    = U('index');
    } else {
        //验证码正确
        $arrUser['username'] = $username;
        $User = M('user')->where($arrUser)->find();
        if( !$User ) {
            //检查用户是否存在
            $data['info']   = "用户不存在，请检查重试。。。";
            $data['status'] = 0;
            $data['url']    = U('index');
        } else {
            //用户存在检查密码是否正确
            if( $pwd != $User['password']) {
                $data['info']   = "密码错误，请检查重试。。。";
                $data['status'] = 0;
                $data['url']    = U('index');
            } else {
                //登陆通过，把相关内容写入session
                session('uid',      $User['userid']);
                session('username', $User['username']);
                session('role',     $User['role']);
                $data['info']   = "登陆成功,正在跳转。。。";
                $data['status'] = 1;
                $data['url']    = U('Home/Index/index');
            }
        }
    }
    $this->ajaxReturn($data, 'json');
}
```
---

>如有疑问欢迎批评指正，谢谢！
