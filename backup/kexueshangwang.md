## [https://github.com/githubvpn007/V2Ray#VPS一键脚本搭建V2Ray]
1.购买一台境外服务器
2.使用 ssh 软件链接远程服务器
3.执行V2ray 安装命令
    3.1 bash <(curl -s -L https://git.io/v2ray.sh)
    3.2 测试连接是否畅通：[https://ping.sx/check-port]
    3.3 如果端口连接不上：
        二选一：
        3.3.1 sudo firewall-cmd --permanent --add-port=你的端口/tcp
         ;sudo firewall-cmd --reload
        3.3.2 systemctl stop firewalld; systemctl disable firewalld; ufw disable
4.配置客户端实现连接外网

## vultr
66.42.104.150
root
Vv4%VQya*iJQqj*X
### xray
xrayFq
Fq2198@qc
port: 6300
