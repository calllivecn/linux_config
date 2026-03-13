这是一份针对高级用户的 Linux LUKS + SSD TRIM 配置指南。你可以将其保存为 `LUKS_TRIM_Guide.md`。

---

# Linux LUKS 加密分区启用 SSD TRIM (fstrim) 指南

在 Linux 中，LUKS 加密层默认会禁用 **Discard (TRIM)** 请求，以防止通过磁盘空余空间分布泄露元数据信息。但在 SSD 上，禁用 TRIM 会导致写放大增加、写入性能下降及寿命缩短。

本指南介绍了如何检测、开启并验证 TRIM 穿透 LUKS 的配置。

## 1. 状态检测

### 1.1 查看块设备拓扑

使用 `lsblk -D` 查看 `DISC-MAX` 列。如果加密层（如 `root` 或 `home`）显示为 `0B`，说明 TRIM 被屏蔽。

```bash
lsblk -D

```

### 1.2 查看加密层标志

检查当前已挂载的加密设备是否带有 `discards` 标志：

```bash
# 替换 <name> 为你的映射名，如 root 或 cryptroot
sudo cryptsetup status <name>

```

* **预期输出**：`flags: discards`

---

## 2. 启用配置

### 2.1 临时开启（即时生效，重启失效）

如果你想立即测试而不重启系统，可以使用 `refresh` 命令：

```bash
# --allow-discards 允许 TRIM 请求穿透加密层
sudo cryptsetup refresh <name> --allow-discards

```

### 2.2 持久化配置 (systemd-cryptsetup)

修改 `/etc/crypttab` 文件，在对应分区的选项列添加 `discard` 参数。

```bash
# 编辑 /etc/crypttab
# <name>       <device>      <password>    <options>
luks-uuid      UUID=xxxx...  none          luks,discard

```

### 2.3 更新 Initramfs (关键步骤)

如果你的**根分区 (`/`)** 使用了加密，必须重新生成 initramfs，否则引导阶段的 `systemd-cryptsetup` 不会应用新选项。

```bash
# Debian/Ubuntu
sudo update-initramfs -u

# Arch Linux
sudo mkinitcpio -P

# Fedora/CentOS
sudo dracut -f

```

---

## 3. 验证与维护

### 3.1 手动触发 TRIM

配置完成后，运行以下命令手动回收空间：

```bash
# -v: verbose, -a: all mounted filesystems
sudo fstrim -va

```

* **成功标志**：输出类似 `/: 100 GiB (107374182400 bytes) trimmed`。

### 3.2 开启自动维护

建议启用 `systemd` 的定时任务，每周自动运行一次 `fstrim`。

```bash
sudo systemctl enable --now fstrim.timer

```

---

## 4. 自动化检测脚本 (Python)

你可以使用以下脚本快速检查系统中所有加密盘的 TRIM 穿透状态。

```python
import subprocess
import json

def get_crypt_status():
    """
    检查所有 dm-crypt 设备的 allow_discards 状态
    """
    try:
        # 获取 dmsetup table 信息
        tables = subprocess.check_output(['sudo', 'dmsetup', 'table'], text=True).strip().split('\n')
        
        print(f"{'Mapping Name':<20} | {'TRIM (Discard)':<15}")
        print("-" * 40)
        
        for line in tables:
            parts = line.split()
            name = parts[0].strip(':')
            # 检查 table 中是否包含 allow_discards 标志
            has_discard = "✅ Enabled" if "allow_discards" in line else "❌ Disabled"
            print(f"{name:<20} | {has_discard}")
            
    except Exception as e:
        print(f"执行失败: {e}")

if __name__ == "__main__":
    get_crypt_status()

```

---

## 5. 安全性警告

**信息泄露风险**：开启 TRIM 后，外部攻击者可以通过观察磁盘块的分配情况，推断出加密分区内文件系统的**已用空间大小**和**数据碎片分布**。如果你面临的是国家级水平的取证压力，请权衡此风险。对于普通开发者和日常使用，建议开启以优化 SSD 寿命。

---

需要我帮你把这个 Markdown 格式直接转换成 `.md` 文件供你下载，或者针对你的特定发行版调整 `update-initramfs` 的部分吗？
