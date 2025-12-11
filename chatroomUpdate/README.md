# Chatroom (Jakarta Servlet 6) 🗨️

一个基于 Java Servlet 的简易在线聊天室示例，包含公共聊天室与私聊、在线人数展示、前后端均为简单实现，数据存储于内存。

## 功能
- 登录：2-8 个汉字/字母用户名校验，重复名拒绝。
- 公共聊天室：发送/接收消息。
- 私聊：点击用户开始私聊，可关闭私聊标签。
- 用户列表：显示在线人数、用户在线/离线状态。
- 退出更新状态：关闭页签/浏览器时自动注销，在线人数与离线状态实时更新。
- 防护：基础 XSS 转义，输入空消息拦截。

## 技术栈
- Java 17
- Jakarta Servlet 6.1 (jakarta.servlet-api 6.1.0)
- JSP + jQuery 3.6
- 构建：Maven，打包类型 WAR
- 服务器：需兼容 Jakarta 规范的容器（Tomcat 10.1+ 等）

## 模块与代码位置
- Servlets：`src/main/java/com/chat/servlet/`
  - `LoginServlet` 登录校验与会话写入
  - `ChatServlet` 发送/拉取消息（公共/私聊）
  - `UserListServlet` 在线人数与用户列表
  - `ClosePrivateChatServlet` 关闭私聊占位接口
  - `LogoutServlet` 注销并触发会话销毁
- 监听器：`UserSessionListener`（会话销毁时更新在线列表）
- 过滤器：`LoginFilter`（保护受限路径）
- 模型：`User`、`Message`
- 前端页面：`src/main/webapp/login.jsp`、`src/main/webapp/chat.jsp`
- JSON 工具：`JsonUtil`（无第三方依赖，手动序列化）

## 数据存储说明
- 全部在内存（`CopyOnWriteArrayList`）：
  - 历史用户与在线用户列表：`UserSessionListener`
  - 消息列表：`ChatServlet` 静态列表
- 会话中的用户名：`HttpSession` 属性 `username`
- 无数据库/文件持久化，重启后数据清空。

## 快速运行
1) 环境：JDK 17，Maven，Tomcat 10.1+（或任意 Jakarta Servlet 10+ 兼容容器）。
2) 编译/打包：
   ```bash
   mvn clean package
   ```
3) 部署：
   - 将生成的 `target/chatroomUpdate-1.0-SNAPSHOT.war` 放到 Tomcat `webapps/`
   - 启动 Tomcat，访问 `http://localhost:8080/chatroomUpdate-1.0-SNAPSHOT/login.jsp`
   - 如在 IDE 中，可添加 Tomcat 10+ 本地运行，部署该 WAR，并将 context path 设为 `/chatroom` 或默认。

## 使用说明
- 登录页：输入 2-8 个汉字或字母的用户名后进入聊天室。
- 聊天：
  - 公共：默认频道 `PUBLIC`
  - 私聊：点击右侧用户列表的用户名创建私聊标签；点击标签右侧 “×” 关闭。
  - 回车发送：输入框内回车发送，Shift+Enter 换行（由浏览器默认行为）。
- 在线状态：
  - 关闭页签/浏览器时，前端 `sendBeacon` 请求 `/logout` 触发会话销毁，在线人数与离线状态更新。

## 接口速览
- `POST /login`：登录，写入 session
- `GET /chat`：拉取消息（参数 `targetChat` = `PUBLIC` 或用户名）
- `POST /chat`：发送消息（参数 `receiver`，`content`）
- `GET /userList`：在线人数与用户列表
- `POST /closePrivateChat`：关闭私聊（前端占位用）
- `POST /logout`：注销当前会话

## 已知限制 / 待改进
- 无持久化：重启即丢数据，可接入数据库/Redis。
- 无鉴权：仅用户名校验，未做密码/登录保护。
- 消息列表未做裁剪：长时间运行内存会增长，可增加历史清理或分页。
- 未使用 WebSocket：当前为轮询实现，可升级为 WebSocket 以降低延迟和带宽。

## 开发提示
- 如需兼容 Tomcat 9 或更低版本，需将 `jakarta.servlet-api` 降级为 `javax.servlet` 规范并调整包名。
- 前端已做基本 XSS 转义，若接入模板/富文本需额外校验和清洗。

