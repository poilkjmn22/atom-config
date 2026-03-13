🚀 VPS 高阶上网与 AI 开发快速部署手册
一、 服务器基础准备 (Vultr/其他)
 * 购买服务器：推荐美西（洛杉矶/硅谷）或新加坡。
 * SSH 链接：使用终端或 SSH 工具连接。
 * 放行端口（重要，防止面板打不开）：
   # 彻底关闭防火墙（最快，适合调试）
systemctl stop firewalld; systemctl disable firewalld; ufw disable

二、 服务端核心安装 (3x-ui + WARP)
1. 安装 3x-ui 面板 (支持原生 Clash 订阅)
# 升级版面板，支持一键分流与订阅导出
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

 * 默认配置建议：
   * Port: 6300
   * User/Pwd: xrayFq / Fq2198@qc
2. 安装 Cloudflare WARP (解决 IP 被封锁/地区限制)
# 使用万能脚本安装 WARP 非全局 Proxy 模式
- wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
- bash <(curl -fsSL git.io/warp.sh) menu

 * 关键选择：选择 “安装 WARP 非全局网络接口 (Proxy 模式)”。
 * 记录端口：默认通常为 40000。
 * 验证：curl -x socks5://127.0.0.1:40000 https://www.cloudflare.com/cdn-cgi/trace (有warp=on)。
三、 面板配置与分流逻辑 (针对 Cursor/Anthropic)
1. 配置入站 (Inbound)
 * 协议：VLESS + Reality (目前最稳，推荐)。
 * 设置订阅 ID：在编辑界面填写 vultr-node（用于后续一键导出）。
2. 配置可视化分流 (Outbound & Routing)
在 3x-ui 【Xray 相关设置】 中添加：
    2.1 Outbounds (出站设置)
    这是定义流量“去哪里”。你需要确保有一个标签为 warp_out 的节点。
    [
      {
        "tag": "direct",
        "protocol": "freedom",
        "settings": {}
      },
      {
        "tag": "warp_out",
        "protocol": "socks",
        "settings": {
          "servers": [
            {
              "address": "127.0.0.1",
              "port": 40000 
            }
          ]
        }
      },
      {
        "tag": "blocked",
        "protocol": "blackhole",
        "settings": {}
      }
    ]
    2.2 Routing Rules (路由规则)
    这是定义“什么样的流量”走 WARP。请把这段放在 rules 数组的最顶部：
    [
      {
        "type": "field",
        "outboundTag": "warp_out",
        "domain": [
          "domain:console.anthropic.com",
          "domain:api.anthropic.com",
          "domain:anthropic.com",
          "domain:claude.ai",
          "domain:cursor.sh",
          "domain:cursor.com",
          "domain:openai.com",
          "domain:chatgpt.com",
          "domain:oaistatic.com",
          "domain:oaiusercontent.com",
          "domain:sentry.io",
          "domain:intercom.io"
        ]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "network": "tcp,udp"
      }
    ]

3. 获取订阅链接
 * 进入 【订阅管理】 -> 复制 Clash 链接。
四、 客户端配置 (Mac + Clash Verge Rev)
1. 导入配置
 * 打开 Clash Verge Rev -> Profiles -> 粘贴链接并 Import。
2. 开启致命杀手锏：TUN 模式
 * 安装服务：Settings -> Service Mode -> Install (显示绿色 Active)。
 * 开启 TUN：Settings -> Tun Mode 开关打开。
 * 内核选择：Mihomo (内核) + gVisor (堆栈)。
五、 Cursor 特殊优化 (必做)
为了防止 AI 厂商指纹识别：
 * 禁用 HTTP/2：Cursor Settings -> General -> 勾选 Disable HTTP/2。
 * 强制重启：修改配置后必须 Cmd + Q 彻底退出重开。
 * 手动补全模型：若看不到 Sonnet 4.x，在 Models 页面添加 claude-3-5-sonnet-latest。
六、 常用维护命令 (备忘)
 * 重启 3x-ui: x-ui restart
 * 查看 WARP 状态: warp-cli status
 * 测试 VPS 访问 Anthropic 是否走 WARP:
   curl -x socks5://127.0.0.1:40000 https://ipinfo.io
下次更换 VPS 后的操作流程：
 * 跑 3x-ui 脚本 -> 2. 跑 WARP 脚本 -> 3. 面板配置分流 -> 4. 复制链接到 Clash Verge -> 5. 开启 TUN -> 开写代码！

🏁 VPS 迁移后 3 分钟自检表
 * WARP 检查：运行 warp-cli status。如果没连上，执行 warp-cli connect。
 * 端口检查：确保 3x-ui 面板端口（如 6300）和节点端口（如 443/Reality 端口）在 Vultr 安全组中已放行。
 * 订阅同步：在 Mac 的 Clash Verge 中点击订阅旁边的 刷新图标，观察节点 IP 是否变更为新 VPS。
 * TUN 验证：在 Mac 终端执行 curl https://ipinfo.io。
   * 预期结果："org": "AS13335 Cloudflare, Inc."
   * 失败结果：显示 Vultr IP 或中国本地 IP（请检查服务模式是否为绿色 Active）。
