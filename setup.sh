#!/bin/bash

# ===== 只需要修改这里 =====
GITHUB_TOKEN="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"
# =========================

GITHUB_API="https://api.github.com/repos/fnos9527/back4app-Run/actions/workflows/redeploy.yml/dispatches"
INTERVAL=3900  # 65分钟

# 创建执行脚本
cat > /root/redeploy_loop.sh << EOF
#!/bin/bash
GITHUB_TOKEN="${GITHUB_TOKEN}"
GITHUB_API="${GITHUB_API}"
INTERVAL=${INTERVAL}

while true; do
  curl -s -X POST \\
    -H "Authorization: Bearer \${GITHUB_TOKEN}" \\
    -H "Content-Type: application/json" \\
    -H "Accept: application/vnd.github+json" \\
    -d '{"ref":"main"}' \\
    "\${GITHUB_API}"
  echo "\$(date): Triggered" >> /root/redeploy.log
  sleep \${INTERVAL}
done
EOF

chmod +x /root/redeploy_loop.sh

# 创建 systemd 服务，实现开机自启、宕机自动拉起
cat > /etc/systemd/system/redeploy.service << EOF
[Unit]
Description=Back4app Auto Redeploy
After=network.target

[Service]
Type=simple
ExecStart=/root/redeploy_loop.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable redeploy
systemctl start redeploy

echo "✅ 安装完成！"
echo "📋 查看运行日志：tail -f /root/redeploy.log"
echo "📋 查看服务状态：systemctl status redeploy"
