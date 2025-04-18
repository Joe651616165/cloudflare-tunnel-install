#!/bin/bash

set -e

echo "🌀 开始安装 cloudflared..."

# 安装 cloudflared
if ! command -v cloudflared &> /dev/null; then
  wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
  chmod +x /usr/local/bin/cloudflared
fi

echo "✅ cloudflared 安装完成"

# 登录 Cloudflare（用户需扫码）
echo "🔐 请使用浏览器扫码登录 Cloudflare 账户以授权 Tunnel"
cloudflared tunnel login

# 创建 tunnel
echo "📦 创建名为 myhome 的 tunnel"
cloudflared tunnel create myhome

# 生成配置文件目录
mkdir -p /root/.cloudflared

# 写入配置文件
cat <<EOF > /root/.cloudflared/config.yml
tunnel: myhome
credentials-file: /root/.cloudflared/$(ls /root/.cloudflared | grep json)

ingress:
  - hostname: esxi.deyoutdj.xyz
    service: https://192.168.2.11:443
  - hostname: nas.deyoutdj.xyz
    service: http://192.168.2.12:5000
  - hostname: op.deyoutdj.xyz
    service: http://192.168.2.1:80
  - service: http_status:404
EOF

echo "📡 启动 Cloudflare Tunnel..."
cloudflared tunnel run myhome
