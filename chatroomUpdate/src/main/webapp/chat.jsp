<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>在线聊天室</title>
    <style>
        /* 全局样式 */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Microsoft YaHei", sans-serif; }
        body { height: 100vh; overflow: hidden; }

        /* 三栏布局 */
        .chat-container { display: flex; height: 100vh; }

        /* 左侧栏：聊天室列表 */
        .left-panel { width: 220px; background: #2d3748; color: white; padding: 15px; overflow-y: auto; }
        .left-panel h3 { margin-bottom: 20px; font-size: 18px; color: #e2e8f0; }
        .chat-list { list-style: none; }
        .chat-item { padding: 10px 15px; margin-bottom: 8px; border-radius: 4px; cursor: pointer; transition: background 0.3s; }
        .chat-item.active { background: #4a5568; }
        .chat-item.private-chat { display: flex; justify-content: space-between; align-items: center; }
        .chat-item .close-btn { color: #cbd5e0; cursor: pointer; font-size: 14px; display: none; }
        .chat-item.private-chat:hover .close-btn { display: inline; }
        .chat-item:hover { background: #4a5568; }

        /* 中间栏：聊天区域 */
        .middle-panel { flex: 1; display: flex; flex-direction: column; border-left: 1px solid #e2e8f0; border-right: 1px solid #e2e8f0; }
        .chat-header { padding: 15px; border-bottom: 1px solid #e2e8f0; background: white; }
        .chat-header h3 { color: #333; font-size: 18px; }
        .chat-content { flex: 1; padding: 20px; overflow-y: auto; background: #f7fafc; }
        /* 消息样式 - 核心修复 */
        .my-msg { text-align: right; margin-bottom: 15px; }
        .other-msg { text-align: left; margin-bottom: 15px; }
        /* 发送者用户名样式：统一小字体 */
        .msg-sender { color: #718096; font-size: 12px; margin-bottom: 3px; display: block; }
        /* 消息气泡样式 */
        .msg-content {
            display: inline-block;
            padding: 10px 15px;
            border-radius: 18px;
            max-width: 70%;
            line-height: 1.4;
            word-break: break-word;   /* 长单词/长链接换行 */
            white-space: pre-wrap;    /* 保留用户的换行并自动折行 */
        }
        .my-msg .msg-content { background: #4299e1; color: white; }
        .other-msg .msg-content { background: white; border: 1px solid #e2e8f0; color: #333; }
        /* 时间样式 */
        .msg-time { color: #718096; font-size: 11px; margin-top: 5px; display: block; }

        .chat-input { padding: 15px; border-top: 1px solid #e2e8f0; background: white; }
        .chat-input form { display: flex; gap: 10px; }
        .chat-input textarea { flex: 1; padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; resize: none; height: 60px; }
        .chat-input button { padding: 0 20px; background: #4299e1; color: white; border: none; border-radius: 8px; cursor: pointer; }
        .chat-input button:hover { background: #3182ce; }

        /* 右侧栏：用户列表 */
        .right-panel { width: 250px; background: white; border-left: 1px solid #e2e8f0; padding: 15px; }
        .online-count { color: #333; font-size: 16px; margin-bottom: 15px; font-weight: 600; }
        .user-list { list-style: none; }
        .user-item { padding: 10px; margin-bottom: 8px; border-radius: 4px; cursor: pointer; display: flex; align-items: center; gap: 10px; }
        .user-item:hover { background: #f7fafc; }
        .online-icon { color: #48bb78; font-weight: bold; }
        .offline-icon { color: #cbd5e0; }
        .username { color: #333; }
    </style>
    <script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
</head>
<body>
<div class="chat-container">
    <!-- 左侧栏：聊天室列表 -->
    <div class="left-panel">
        <h3>聊天室</h3>
        <ul class="chat-list" id="chatList">
            <li class="chat-item active" data-chat="PUBLIC">公共聊天室</li>
        </ul>
    </div>

    <!-- 中间栏：聊天区域 -->
    <div class="middle-panel">
        <div class="chat-header">
            <h3 id="currentChatTitle">公共聊天室</h3>
        </div>
        <div class="chat-content" id="chatContent">
            <!-- 消息内容 -->
        </div>
        <div class="chat-input">
            <form id="msgForm">
                <textarea name="content" placeholder="请输入消息..." required></textarea>
                <button type="submit">发送</button>
            </form>
        </div>
    </div>

    <!-- 右侧栏：用户列表 -->
    <div class="right-panel">
        <div id="userListContainer">
            <!-- 用户列表 -->
        </div>
    </div>
</div>

<script>
    const ctxPath = "${pageContext.request.contextPath}";
    $(function() {
        const username = "${pageContext.session.getAttribute('username')}";
        let currentChat = "PUBLIC";

        // 页面关闭/刷新时通知后端注销，保证在线人数及时更新
        window.addEventListener("beforeunload", function() {
            // sendBeacon 在页面卸载时发送短请求，不阻塞关闭
            navigator.sendBeacon(ctxPath + "/logout");
        });

        // 定时拉取（修复：初始加载+5秒轮询）
        pullMessages();
        pullUserList();
        setInterval(pullMessages, 5000);
        setInterval(pullUserList, 5000);

        // 发送消息 - 核心修复：确保JSON解析正确
        $("#msgForm").submit(function(e) {
            e.preventDefault();
            const content = $("textarea[name='content']").val().trim();
            if (!content) return;

            $.ajax({
                url: ctxPath + "/chat",
                type: "POST",
                data: { receiver: currentChat, content: content },
                dataType: "json", // 强制JSON解析，避免手动parse出错
                success: function(res) {
                    if (res.code === 0) {
                        $("textarea[name='content']").val("");
                        pullMessages(); // 立即刷新消息
                        pullUserList(); // 立即刷新在线人数
                    } else {
                        alert(res.msg);
                    }
                },
                error: function(xhr) {
                    alert("发送失败：" + xhr.responseText);
                }
            });
        });

        // 切换聊天室
        $(document).on("click", ".chat-item", function() {
            const targetChat = $(this).data("chat");
            if (targetChat === currentChat) return;

            $(".chat-item").removeClass("active");
            $(this).addClass("active");
            currentChat = targetChat;
            $("#currentChatTitle").text(targetChat === "PUBLIC" ? "公共聊天室" : "私聊 - " + targetChat);
            $("textarea[name='content']").val("");
            pullMessages();
        });

        // 发起私聊
        $(document).on("click", ".user-item", function() {
            const targetUser = $(this).data("username");
            if (!targetUser || targetUser === username) return;

            // data-chat属性使用原始值（jQuery的data会自动处理），显示文本需要转义
            const escapedTargetUser = escapeHtml(targetUser);
            
            // 检查是否已存在该私聊
            const existingChat = $('.chat-item').filter(function() {
                return $(this).data("chat") === targetUser;
            });
            if (existingChat.length > 0) {
                existingChat.click();
                return;
            }

            // 创建私聊项：data-chat使用原始值，显示文本转义
            const privateChatHtml = '<li class="chat-item private-chat" data-chat="' +
                targetUser.replace(/"/g, '&quot;') + '">私聊 - ' + escapedTargetUser +
                '<span class="close-btn">×</span></li>';
            $("#chatList").append(privateChatHtml);
            $('.chat-item').filter(function() {
                return $(this).data("chat") === targetUser;
            }).click();
        });

        // 关闭私聊
        $(document).on("click", ".close-btn", function(e) {
            e.stopPropagation();
            const targetChat = $(this).closest(".chat-item").data("chat");

            $.post(ctxPath + "/closePrivateChat", function() {
                // 使用 data() 匹配，避免因编码/空格导致选择器不匹配
                $('.chat-item').filter(function() {
                    return $(this).data("chat") === targetChat;
                }).remove();
                if (targetChat === currentChat) {
                    $(".chat-item[data-chat='PUBLIC']").click();
                }
            });
        });

        // 拉取消息 - 核心修复：使用HTML转义确保内容正确显示
        function pullMessages() {
            $.ajax({
                url: ctxPath + "/chat",
                type: "GET",
                data: { targetChat: currentChat },
                dataType: "json",
                success: function(messages) {
                    console.log("拉取到的原始消息数据：", messages);
                    let html = "";
                    if (!messages || messages.length === 0) {
                        html = "<div style='text-align:center;color:#999;padding:20px;'>暂无消息</div>";
                    } else {
                        messages.forEach((msg) => {
                            if (!msg) return;
                            
                            // 获取并转义所有字段
                            const sender = escapeHtml(msg.sender || "未知用户");
                            const content = escapeHtml(msg.content || "");
                            const sendTime = escapeHtml(msg.sendTime || "未知时间");

                            // 判断是否是自己发送的消息
                            if (username === msg.sender) {
                                html += '<div class="my-msg">' +
                                    '<div class="msg-sender">我</div>' +
                                    '<div class="msg-content">' + content + '</div>' +
                                    '<div class="msg-time">' + sendTime + '</div>' +
                                    '</div>';
                            } else {
                                html += '<div class="other-msg">' +
                                    '<div class="msg-sender">' + sender + '</div>' +
                                    '<div class="msg-content">' + content + '</div>' +
                                    '<div class="msg-time">' + sendTime + '</div>' +
                                    '</div>';
                            }
                        });
                    }
                    $("#chatContent").html(html);
                    // 滚动到底部
                    const chatContentEl = $("#chatContent")[0];
                    if (chatContentEl) {
                        chatContentEl.scrollTop = chatContentEl.scrollHeight;
                    }
                },
                error: function(xhr) {
                    console.log("拉取消息失败：", xhr.status, xhr.responseText);
                    $("#chatContent").html("<div style='text-align:center;color:#e53e3e;padding:20px;'>加载消息失败</div>");
                }
            });
        }

        // 拉取用户列表 - 核心修复：确保onlineCount和用户名正确显示
        function pullUserList() {
            $.ajax({
                url: ctxPath + "/userList",
                type: "GET",
                dataType: "json",
                success: function(data) {
                    console.log("拉取到的用户数据：", data);

                    // 获取在线人数
                    let onlineCount = 0;
                    if (data && typeof data.onlineCount === 'number') {
                        onlineCount = data.onlineCount;
                    } else if (data && typeof data.onlineCount === 'string') {
                        onlineCount = parseInt(data.onlineCount) || 0;
                    }
                    
                    let onlineCountHtml = '<div class="online-count">公共聊天室在线人数：' + onlineCount + '</div>';

                    // 获取用户列表
                    let userListHtml = '<ul class="user-list">';
                    if (data && Array.isArray(data.userList) && data.userList.length > 0) {
                        data.userList.forEach(function(user) {
                            if (!user) return;

                            // 获取并转义用户名
                            let userName = "未知用户";
                            if (user.username) {
                                userName = escapeHtml(String(user.username).trim());
                            }
                            
                            // 判断在线状态
                            let onlineIcon = '<span class="offline-icon">✗</span>';
                            if (user.isOnline === true || user.isOnline === "true") {
                                onlineIcon = '<span class="online-icon">✓</span>';
                            }

                            // 拼接用户项HTML，使用转义后的用户名
                            userListHtml += '<li class="user-item" data-username="' + escapeHtml(userName) + '">' +
                                onlineIcon +
                                '<span class="username">' + userName + '</span>' +
                                '</li>';
                        });
                    } else {
                        userListHtml += '<li style="padding:10px; color:#999;">当前只有你在线</li>';
                    }
                    userListHtml += '</ul>';

                    // 渲染用户列表
                    $("#userListContainer").html(onlineCountHtml + userListHtml);
                },
                error: function(xhr) {
                    console.log("拉取用户列表失败：", xhr.status, xhr.responseText);
                    $("#userListContainer").html(
                        '<div class="online-count">公共聊天室在线人数：0</div>' +
                        '<ul class="user-list"><li style="padding:10px; color:#e53e3e;">加载用户失败</li></ul>'
                    );
                }
            });
        }

        // 防XSS - HTML转义函数（必须先转义&，否则会重复转义）
        function escapeHtml(content) {
            if (content == null || content === undefined) return "";
            const str = String(content);
            return str.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#39;");
        }

        // 回车发送
        $("textarea[name='content']").keydown(function(e) {
            if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                $("#msgForm").submit();
            }
        });
    });
</script>
</body>
</html>