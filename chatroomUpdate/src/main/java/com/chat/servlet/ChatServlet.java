package com.chat.servlet;

import com.chat.model.Message;
import com.chat.util.JsonUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    // 全局存储消息
    private static final List<Message> messageList = new CopyOnWriteArrayList<>();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String sender = (String) req.getSession().getAttribute("username");
        String receiver = req.getParameter("receiver");    // PUBLIC 或具体用户名
        String content = req.getParameter("content");

        if (sender == null || sender.isEmpty()) {
            resp.getWriter().write("{\"code\":1,\"msg\":\"未登录用户无法发送消息\"}");
            return;
        }

        if (content == null || content.trim().isEmpty()) {
            resp.getWriter().write("{\"code\":1,\"msg\":\"消息不能为空\"}");
            return;
        }

        content = content.trim();

        // 保存消息
        messageList.add(new Message(sender, receiver, content));

        resp.getWriter().write("{\"code\":0,\"msg\":\"发送成功\"}");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String currentUser = (String) req.getSession().getAttribute("username");
        String targetChat = req.getParameter("targetChat");  // PUBLIC 或具体用户名

        if (currentUser == null) {
            resp.getWriter().write("[]");
            return;
        }

        List<Message> resultList = new ArrayList<>();

        for (Message msg : messageList) {
            if ("PUBLIC".equals(targetChat)) {
                if ("PUBLIC".equals(msg.getReceiver())) {
                    resultList.add(msg);
                }
            } else {
                // 私聊：双方互发
                if ((currentUser.equals(msg.getSender()) && targetChat.equals(msg.getReceiver()))
                        || (currentUser.equals(msg.getReceiver()) && targetChat.equals(msg.getSender()))) {
                    resultList.add(msg);
                }
            }
        }

        String json = JsonUtil.messagesToJson(resultList);
        resp.getWriter().write(json);
    }
}
