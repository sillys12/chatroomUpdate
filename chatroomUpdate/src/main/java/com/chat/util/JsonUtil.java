package com.chat.util;

import com.chat.model.Message;
import com.chat.model.User;
import java.util.List;

/**
 * 简易JSON工具类（无框架依赖，仅支持核心数据类型序列化）
 */
public class JsonUtil {
    // 消息列表转JSON字符串
    public static String messagesToJson(List<Message> messages) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < messages.size(); i++) {
            Message msg = messages.get(i);
            json.append("{")
                    .append("\"sender\":\"").append(escapeJson(msg.getSender())).append("\",")
                    .append("\"receiver\":\"").append(escapeJson(msg.getReceiver())).append("\",")
                    .append("\"content\":\"").append(escapeJson(msg.getContent())).append("\",")
                    .append("\"sendTime\":\"").append(escapeJson(msg.getSendTime())).append("\"")
                    .append("}");
            if (i < messages.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        return json.toString();
    }

    // 用户列表+在线人数转JSON字符串
    public static String usersToJson(int onlineCount, List<User> users) {
        StringBuilder json = new StringBuilder("{");
        // 在线人数
        json.append("\"onlineCount\":").append(onlineCount).append(",");
        // 用户列表
        json.append("\"userList\":[");
        for (int i = 0; i < users.size(); i++) {
            User user = users.get(i);
            json.append("{")
                    .append("\"username\":\"").append(escapeJson(user.getUsername())).append("\",")
                    .append("\"isOnline\":").append(user.isOnline())
                    .append("}");
            if (i < users.size() - 1) {
                json.append(",");
            }
        }
        json.append("]}");
        return json.toString();
    }

    // JSON特殊字符转义（避免格式错误）
    private static String escapeJson(String content) {
        if (content == null) return "";
        return content.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}