package com.chat.model;

public class User {
    private String username;  // 用户名
    private boolean isOnline; // 在线状态

    public User(String username, boolean isOnline) {
        this.username = username;
        this.isOnline = isOnline;
    }

    // getter/setter
    public String getUsername() { return username; }
    public boolean isOnline() { return isOnline; }
    public void setOnline(boolean online) { isOnline = online; }
}