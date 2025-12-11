<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>在线聊天室 - 登录</title>
    <style>
        body { font-family: "Microsoft YaHei", sans-serif; background: #f5f5f5; }
        .login-box { width: 350px; margin: 150px auto; padding: 30px; background: white; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .login-box h2 { text-align: center; color: #333; margin-bottom: 25px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #666; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .btn-login { width: 100%; padding: 12px; background: #4299e1; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        .btn-login:hover { background: #3182ce; }
        .error-msg { color: #e53e3e; text-align: center; margin-bottom: 15px; height: 20px; }
    </style>
</head>
<body>
<div class="login-box">
    <h2>在线聊天室</h2>
    <div class="error-msg">${errorMsg}</div>
    <form action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
            <label for="username">请输入用户名（2-8个汉字/字母）</label>
            <input type="text" id="username" name="username" class="form-control" required autofocus>
        </div>
        <button type="submit" class="btn-login">进入聊天室</button>
    </form>
</div>
</body>
</html>