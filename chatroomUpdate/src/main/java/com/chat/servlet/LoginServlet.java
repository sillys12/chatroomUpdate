package com.chat.servlet;

import com.chat.listener.UserSessionListener;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    // 用户名正则：2-8个汉字或字母（不含特殊字符、空格）
    private static final String USERNAME_PATTERN = "^[a-zA-Z\u4e00-\u9fa5]{2,8}$";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String username = req.getParameter("username").trim();

        // 1. 验证用户名格式
        if (!Pattern.matches(USERNAME_PATTERN, username)) {
            req.setAttribute("errorMsg", "用户名必须是2-8个汉字或字母！");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // 2. 验证用户名是否重复
        if (!UserSessionListener.addUser(username)) {
            req.setAttribute("errorMsg", "该用户名已被占用，请重新输入！");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // 3. 登录成功，存储用户名到会话
        UserSessionListener.addUser(username);
        req.getSession().setAttribute("username", username);
        // 会话超时时间：30分钟（无操作则视为离线）
        req.getSession().setMaxInactiveInterval(30 * 60);
        // 重定向到聊天室
        resp.sendRedirect(req.getContextPath() + "/chat.jsp");
    }
}