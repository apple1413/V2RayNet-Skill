# 🌐 V2Ray 代理配置助手

一键配置 V2Ray 代理，畅游 Google、GitHub 等国际网站。

## 功能
- 自动配置 V2Ray 代理
- 支持订阅链接一键导入
- 支持手动节点配置
- 自动设置代理环境变量

## 使用方法

### 方式一：订阅链接（推荐）

```bash
bash ~/.openclaw/workspace/skills/v2ray-proxy/setup.sh "你的订阅链接"
```

### 方式二：手动配置节点

```bash
bash ~/.openclaw/workspace/skills/v2ray-proxy/setup.sh --manual
```

然后按提示输入节点信息：
- 地址 (address)
- 端口 (port)
- 用户 ID (uuid)
- 额外 ID (alterId)

## 首次使用

1. **获取订阅链接**：
   - 访问 https://w1.v2ai.top/ 注册账号
   - 在个人中心获取「订阅链接」
   
2. **一键配置**：
   ```bash
   bash ~/.openclaw/workspace/skills/v2ray-proxy/setup.sh "https://xxx.sub"
   ```

3. **验证代理**：
   ```bash
   curl --socks5 127.0.0.1:10808 https://www.google.com
   ```

## 验证成功

能访问以下网站：
- Google (google.com)
- YouTube (youtube.com)
- GitHub (github.com)
- Twitter (twitter.com)

## 故障排查

```bash
# 查看 v2ray 状态
systemctl status v2ray

# 查看日志
journalctl -u v2ray -n 20

# 重启 v2ray
systemctl restart v2ray
```
