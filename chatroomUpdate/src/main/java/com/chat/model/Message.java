package com.chat.model;

import java.text.SimpleDateFormat;
import java.util.Date;

public class Message {
    private String sender;    // 发送者用户名
    private String receiver;  // 接收者（公共聊天室为"PUBLIC"，私聊为目标用户名）
    private String content;   // 消息内容
    private String sendTime;  // 发送时间

    public Message(String sender, String receiver, String content) {
        this.sender = sender;
        this.receiver = receiver;
        this.content = content;
        this.sendTime = new SimpleDateFormat("HH:mm:ss").format(new Date());
    }

    // getter/setter
    public String getSender() { return sender; }
    public String getReceiver() { return receiver; }
    public String getContent() { return content; }
    public String getSendTime() { return sendTime; }
}