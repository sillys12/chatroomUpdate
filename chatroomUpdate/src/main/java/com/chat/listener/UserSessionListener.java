package com.chat.listener;

import com.chat.model.User;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class UserSessionListener implements HttpSessionListener {

    // 全局存储：历史所有登录过的用户（内存存储，重启丢失）
    private static List<User> allUserList = new CopyOnWriteArrayList<>();
    // 全局存储：当前在线用户（内存存储，重启丢失）
    private static List<User> onlineUserList = new CopyOnWriteArrayList<>();

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // 会话创建时无需操作（登录时手动添加用户）
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        // 会话销毁（关闭浏览器、超时）→ 标记用户离线
        HttpSession session = se.getSession();
        String username = (String) session.getAttribute("username");
        if (username != null) {
            // 在线列表中移除，历史列表中标记离线
            for (User user : onlineUserList) {
                if (user.getUsername().equals(username)) {
                    onlineUserList.remove(user);
                    break;
                }
            }
            for (User user : allUserList) {
                if (user.getUsername().equals(username)) {
                    user.setOnline(false);
                    break;
                }
            }
        }
    }

    // 工具方法：添加新用户（登录时调用）
    public static boolean addUser(String username) {
        // 检查用户名是否已存在
        for (User user : allUserList) {
            if (user.getUsername().equals(username)) {
                // 如果已存在，直接设为在线并添加到在线列表
                if (!user.isOnline()) {
                    user.setOnline(true);
                    onlineUserList.add(user);
                }
                return true;
            }
        }
        User newUser = new User(username, true);
        allUserList.add(newUser);
        onlineUserList.add(newUser);
        return true;
    }

    // 工具方法：获取所有历史用户（在线在前，离线在后）
    public static List<User> getAllUsers() {
        List<User> sortedList = new ArrayList<>();
        // 先加在线用户
        sortedList.addAll(onlineUserList);
        // 再加离线用户
        for (User user : allUserList) {
            if (!user.isOnline()) {
                sortedList.add(user);
            }
        }
        return sortedList;
    }

    // 工具方法：获取在线用户数（公共聊天室实时人数）
    public static int getOnlineUserCount() {
        return onlineUserList.size();
    }

    // 工具方法：判断用户是否在线
    public static boolean isUserOnline(String username) {
        for (User user : onlineUserList) {
            if (user.getUsername().equals(username)) {
                return true;
            }
        }
        return false;
    }
}