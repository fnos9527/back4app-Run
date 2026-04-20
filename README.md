# back4app-Run

B4A_EMAIL         账号

B4A_PASSWORD       你的密码

B4A_APP_URL          https://containers.back4app.com/apps

GitHub Actions cron 本身的问题——官方文档明确说明高峰期调度任务可能延迟数小时，无法保证精确时间,解决方案,用外部定时服务来触发 GitHub Actions，而不是依赖 GitHub 自己的 cron

第一种方法:

获取 GitHub PAT Token

打开 github.com/settings/tokens

点击 Generate new token → Generate new token (classic)

Note 填写 cron-job

Expiration 选 No expiration

勾选 workflow

点击底部 Generate token

复制生成的 token（只显示一次，务必保存好）

2 配置 cron-job.org

注册并登录 cron-job.org

点击右上角 CREATE CRONJOB

按下图填写：

Title=起个名字

URL=https://api.github.com/repos/你的GitHub用户名/你的仓库名/actions/workflows/redeploy.yml/dispatches

Execution schedule  选 Every hour

展开 Advanced → Headers，添加：

Authorization=Bearer +你第1步复制的token

Content-Type=application/json

Accept=application/vnd.github+json

展开 Advanced → Request body，填写：
点击 Request method 下拉框
选择 POST
```
{"ref":"main"}
```
点击 CREATE 保存


第二种方法:(最推荐)

创建文件 setup.sh 上传到VPS运行即可.把下面内容复制进去，修改第4行的Token：
```
#!/bin/bash

# ===== 只需要修改这里 =====
GITHUB_TOKEN="你的GitHub_Token"
# =========================

GITHUB_API="https://api.github.com/repos/fnos9527/back4app-Run/actions/workflows/redeploy.yml/dispatches"
INTERVAL=4200  # 70分钟

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
```
上传到VPS后执行：chmod +x setup.sh && bash setup.sh

或者一键脚本运行
```
curl -sSL https://raw.githubusercontent.com/fnos9527/back4app-Run/main/setup.sh | bash
```
之后常用命令：
tail -f /root/redeploy.log查看触发日志

systemctl status redeploy查看服务状态

systemctl restart redeploy重启服务

systemctl stop redeploy停止服务








