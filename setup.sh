#!/bin/bash
# V2Ray 代理一键配置脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 显示欢迎信息
show_banner() {
    echo "========================================"
    echo "  🌐 V2Ray 代理配置助手"
    echo "========================================"
    echo ""
}

# 检查 v2ray 是否安装
check_v2ray() {
    if ! command -v v2ray &> /dev/null; then
        echo_info "正在安装 V2Ray..."
        apt-get update && apt-get install -y v2ray
    else
        echo_info "V2Ray 已安装 ✓"
    fi
}

# 配置订阅链接
config_subscription() {
    local sub_url="$1"
    
    if [ -z "$sub_url" ]; then
        echo_error "请提供订阅链接！"
        echo ""
        echo "使用方法："
        echo "  $0 <订阅链接>"
        echo ""
        echo "示例："
        echo "  $0 https://xxx.v2ray.top/xxx"
        exit 1
    fi
    
    echo_info "获取订阅内容..."
    
    # 创建配置目录
    mkdir -p /etc/v2ray
    
    # 下载订阅内容（尝试直连和代理）
    local sub_content=""
    sub_content=$(curl -s "$sub_url" 2>/dev/null) || \
    sub_content=$(curl -s --socks5 127.0.0.1:10808 "$sub_url" 2>/dev/null) || {
        echo_error "无法获取订阅内容，请检查链接是否正确"
        exit 1
    }
    
    # 解码订阅内容（Base64）
    local decoded=$(echo "$sub_content" | base64 -d 2>/dev/null || echo "$sub_content")
    
    # 检查是否是有效的 v2ray 订阅
    if ! echo "$decoded" | grep -q '"v"'; then
        echo_error "订阅内容无效，请检查链接是否正确"
        exit 1
    fi
    
    # 转换为 v2ray 配置
    # 这里简单处理，实际应该用 v2ray import 命令
    echo "$decoded" > /tmp/v2ray_subscription.json
    
    # 生成简单的客户端配置
    cat > /etc/v2ray/config.json << 'EOF'
{
  "inbounds": [
    {
      "port": 10808,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vmess",
      "settings": {
        "vnext": []
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "outboundTag": "direct",
        "domain": ["geosite:cn", "geosite:category-ads-cn"]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "ip": ["geoip:cn", "geoip:private"]
      }
    ]
  }
}
EOF
    
    echo_warn "订阅配置较复杂，建议使用可视化客户端导入"
    echo ""
    echo "请手动配置或使用以下信息："
    echo "  订阅链接: $sub_url"
}

# 配置手动节点
config_manual() {
    echo ""
    echo "=== 手动配置节点 ==="
    echo ""
    
    read -p "请输入节点地址 (address): " address
    read -p "请输入端口 (port): " port
    read -p "请输入用户 ID (uuid): " uuid
    read -p "请输入额外 ID (alterId，默认为0): " alterId
    
    alterId=${alterId:-0}
    
    cat > /etc/v2ray/config.json << EOF
{
  "inbounds": [
    {
      "port": 10808,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$address",
            "port": $port,
            "users": [
              {
                "id": "$uuid",
                "alterId": $alterId
              }
            ]
          }
        ]
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
    
    echo_info "配置已保存"
}

# 启动 v2ray
start_v2ray() {
    echo_info "启动 V2Ray..."
    systemctl restart v2ray
    systemctl enable v2ray
    
    sleep 2
    
    if systemctl is-active --quiet v2ray; then
        echo_info "V2Ray 启动成功 ✓"
    else
        echo_error "V2Ray 启动失败，请查看日志"
        journalctl -u v2ray -n 10
        exit 1
    fi
}

# 验证代理
verify_proxy() {
    echo ""
    echo_info "验证代理连接..."
    
    if curl -s --socks5 127.0.0.1:10808 https://www.google.com -m 10 | grep -q "Google"; then
        echo_info "代理连接成功！✓ Google 可访问"
    elif curl -s --socks5 127.0.0.1:10808 https://github.com -m 10 | grep -q "GitHub"; then
        echo_info "代理连接成功！✓ GitHub 可访问"
    else
        echo_warn "代理可能未正常工作，但服务已启动"
        echo "请手动测试：curl --socks5 127.0.0.1:10808 https://www.google.com"
    fi
    
    echo ""
    echo "========================================"
    echo "  🎉 配置完成！"
    echo "========================================"
    echo ""
    echo "代理地址: 127.0.0.1:10808"
    echo "协议: SOCKS5"
    echo ""
    echo "在浏览器或命令行中使用此代理即可访问 Google、GitHub 等网站"
}

# 显示帮助
show_help() {
    show_banner
    echo "使用方法："
    echo ""
    echo "  $0 <订阅链接>"
    echo "      使用订阅链接一键配置"
    echo ""
    echo "  $0 --manual"
    echo "      手动输入节点信息"
    echo ""
    echo "  $0 --test"
    echo "      测试代理连接"
    echo ""
    echo "示例："
    echo "  $0 https://w1.v2ai.top/link/xxxxx"
    echo ""
}

# 测试模式
test_proxy() {
    check_v2ray
    
    if ! systemctl is-active --quiet v2ray; then
        echo_warn "V2Ray 未运行，正在启动..."
        start_v2ray
    fi
    
    verify_proxy
}

# 主函数
main() {
    show_banner
    
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        --manual)
            check_v2ray
            config_manual
            start_v2ray
            verify_proxy
            ;;
        --test)
            test_proxy
            ;;
        "")
            show_help
            echo_warn "请提供订阅链接或使用 --manual 手动配置"
            echo ""
            echo "首次使用？请先访问 https://w1.v2ai.top/ 注册账号获取订阅链接"
            exit 0
            ;;
        *)
            check_v2ray
            config_subscription "$1"
            start_v2ray
            verify_proxy
            ;;
    esac
}

main "$@"
