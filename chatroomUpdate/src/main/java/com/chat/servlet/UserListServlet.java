package com.chat.servlet;

import com.chat.listener.UserSessionListener;
import com.chat.model.User;

import com.chat.util.JsonUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/userList")
public class UserListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // 必须改成 JSON，否则 jQuery 无法解析
        resp.setContentType("application/json;charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        String currentUser = (String) req.getSession().getAttribute("username");

        // 获取在线人数
        int onlineCount = UserSessionListener.getOnlineUserCount();

        // 获取所有用户
        List<User> allUsers = UserSessionListener.getAllUsers();

        // 不显示自己
        allUsers.removeIf(user -> user.getUsername().equals(currentUser));

        // 返回 JSON
        String json = JsonUtil.usersToJson(onlineCount, allUsers);
        resp.getWriter().write(json);
    }
}
