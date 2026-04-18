# back4app-Run

B4A_EMAIL         账号

B4A_PASSWORD       你的密码

B4A_APP_URL          https://containers.back4app.com/apps

GitHub Actions cron 本身的问题——官方文档明确说明高峰期调度任务可能延迟数小时，无法保证精确时间,解决方案,用外部定时服务来触发 GitHub Actions，而不是依赖 GitHub 自己的 cron

1 获取 GitHub PAT Token

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

Authorization=你第1步复制的token

Content-Type=application/json

Accept=application/vnd.github+json

展开 Advanced → Request body，填写：
点击 Request method 下拉框
选择 POST
```
{"ref":"main"}
```
点击 CREATE 保存




