# V2RayNet-Skill 🌐

一键配置 V2Ray 代理，让大陆服务器轻松访问国际网络。

## 特性

- ✅ 订阅链接一键导入
- ✅ 手动节点配置
- ✅ 自动设置 SOCKS5 代理
- ✅ 支持 Google、GitHub、YouTube、Twitter 等国际网站

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/apple1413/V2RayNet-Skill.git
cd V2RayNet-Skill
```

### 2. 配置代理

**方式一：订阅链接（推荐）**

```bash
bash setup.sh "你的订阅链接"
```

示例：
```bash
bash setup.sh https://your-v2ray-provider.com/link/xxxxx
```

**方式二：手动节点配置**

```bash
bash setup.sh --manual
```

然后按提示输入：
- 节点地址 (address)
- 端口 (port)
- 用户 ID (uuid)
- 额外 ID (alterId，通常填 0)

### 3. 验证代理

```bash
bash setup.sh --test
```

或者手动测试：
```bash
curl --socks5 127.0.0.1:10808 https://www.google.com
```

## 使用场景

- 服务器需要安装国际软件
- 拉取 Docker 镜像（GitHub、Docker Hub）
- 访问国际 API
- 技术开发需求

## 常见问题

### 代理无法连接？

```bash
# 查看 v2ray 状态
systemctl status v2ray

# 查看日志
journalctl -u v2ray -n 20

# 重启 v2ray
systemctl restart v2ray
```

### 订阅链接无效？

部分订阅链接是加密格式，请使用手动模式配置：
```bash
bash setup.sh --manual
```

## 获取订阅链接

推荐服务商：
- [v2ai.top](https://v1.xdollar.top/)（需要注册）
- 其他 V2Ray 服务商

## 注意事项

⚠️ 请仅用于正当技术开发需求！

## 效果展示

配置成功后，可以访问：
- ✅ Google (google.com)
- ✅ GitHub (github.com)
- ✅ YouTube (youtube.com)
- ✅ Twitter (twitter.com)

## 依赖

- V2Ray（脚本自动安装）
- curl
- systemd

---

⭐ Star 支持一下：https://github.com/apple1413/V2RayNet-Skill
