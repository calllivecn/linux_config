既然你已经成功完成了最难的 `route dns` 步骤，现在我为你整理一份完整的、适合资深用户的 **Cloudflare Tunnel + Nginx** 部署文档。

这份文档基于你目前的**本地配置模式 (CLI-managed)**，这种模式对开发者最友好，配置文件可版本化管理。

---

# Cloudflare Tunnel 部署与 Nginx 代理指南 (2026 版)

本指南适用于在 NAT 后（无公网 IP）的环境下，通过 Cloudflare Zero Trust 将本地 Nginx 服务安全地暴露至公网。

## 1. 基础安装与认证

作为高级用户，建议使用官方仓库安装以获取持续更新。

### 安装 cloudflared

```bash
# 下载并安装（以 Debian/Ubuntu x86_64 为例）
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb

```

### 身份认证

执行以下命令，点击链接登录 Cloudflare 账户并授权你的域名：

```bash
cloudflared tunnel login

```

* **结果**：此操作会在 `~/.cloudflared/` 下生成 `cert.pem` 证书文件。

---

## 2. 创建隧道 (Tunnel)

### 创建隧道实体

```bash
# 替换 my-web-tunnel 为你喜欢的名字
cloudflared tunnel create my-web-tunnel

```

* **记录 ID**：命令执行后会输出一个 **Tunnel ID** (UUID)。
* **凭证文件**：自动在 `~/.cloudflared/` 生成 `<Tunnel-ID>.json`。

---

## 3. 配置本地 Ingress 规则

这是最核心的步骤。编辑（或创建）配置文件：`vim ~/.cloudflared/config.yml`。

```yaml
# 1. 填写你的隧道 ID
tunnel: f7960808-32f4-4b37-bc17-e64e466f4535
# 2. 填写对应的凭证路径 (建议写绝对路径)
credentials-file: /root/.cloudflared/f7960808-32f4-4b37-bc17-e64e466f4535.json

# 3. 针对国内环境建议强制使用 http2 (TCP) 协议，减少 UDP QoS 干扰
protocol: http2

# 4. 配置 Ingress 路由规则
ingress:
  # 规则 A：匹配特定域名到本地 Nginx
  - hostname: web.yourdomain.com
    service: http://localhost:80
    
  # 规则 B：(可选) 匹配另一个服务
  # - hostname: api.yourdomain.com
  #   service: http://localhost:8080

  # 规则 C：最后必须有一个兜底规则，处理未匹配到的流量
  - service: http_status:404

```

---

## 4. 配置 DNS 路由

告诉 Cloudflare DNS 将流量指向该隧道：

```bash
# 语法：cloudflared tunnel route dns <隧道名> <完整域名>
cloudflared tunnel route dns my-web-tunnel web.yourdomain.com

```

* **验证**：前往 Cloudflare 控制台 -> DNS 记录，应看到一条指向 `[Tunnel-ID].cfargotunnel.com` 的 CNAME 记录。

---

## 5. 启动与持久化

### 测试运行

```bash
cloudflared tunnel --config ~/.cloudflared/config.yml run

```

### 注册为 Systemd 服务 (推荐)

```bash
# 将配置文件拷贝到系统目录
sudo cp ~/.cloudflared/config.yml /etc/cloudflared/
sudo cp ~/.cloudflared/<Tunnel-ID>.json /etc/cloudflared/

# 安装并启动服务
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared

```

---

## 6. 进阶调试与排查

| 现象 | 排查方案 |
| --- | --- |
| **dig 找不到记录** | 使用 `dig @1.1.1.1 web.yourdomain.com` 排除本地 DNS 污染。 |
| **访问报 502** | 检查 Nginx 是否启动，以及 `config.yml` 里的 `localhost:80` 是否可达。 |
| **访问报 1033** | 隧道未连接。检查 `systemctl status cloudflared` 日志。 |
| **连接频繁断开** | 确认已配置 `protocol: http2`。 |

---

## 7. Python 自动化脚本 (可选)

作为资深 Python 用户，你可以使用以下脚本监控隧道状态：

```python
import subprocess
import json
import time

# 隧道监控脚本
def check_tunnel_status():
    try:
        # 获取隧道列表及其状态
        result = subprocess.run(['cloudflared', 'tunnel', 'list', '--output', 'json'], 
                                capture_output=True, text=True)
        tunnels = json.loads(result.stdout)
        for t in tunnels:
            print(f"隧道: {t['name']} | 状态: {t['connections'][0]['status']}")
    except Exception as e:
        print(f"检测失败: {e}")

if __name__ == "__main__":
    while True:
        check_tunnel_status()
        time.sleep(60) # 每分钟检查一次

```

**下一步建议**：
如果你现在通过域名访问看到的是 Nginx 的欢迎页，那么恭喜你，NAT 穿透已经彻底成功！需要我帮你配置 Nginx 的 `proxy_set_header` 以便正确获取访客的真实 IP 吗？
