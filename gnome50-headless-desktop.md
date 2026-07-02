
在 Ubuntu 26.04（默认搭载 GNOME 50）环境下，配置和使用**无头会话（Headless Session）** 的最佳实践是使用官方原生支持的 **GNOME Remote Desktop (GRD) 的 Headless 模式**。

由于 GNOME 50 已经**彻底移除了 X11 原生会话支持**，全面拥抱 Wayland，过去常用的 `xrdp + Xorg/Xvnc` 方案不仅容易黑屏闪退，而且无法享受 GNOME 50 的硬件加速和新特性。

以下是在 Ubuntu 26.04 无物理显示器（或服务器/虚拟机）环境下，配置 Wayland 无头远程桌面的完整实战指南：

### 🛠️ Step 1：确认并开启 Wayland
Ubuntu 26.04 默认使用 Wayland，但为了保险起见，请检查 GDM 配置确保没有被意外禁用。
```bash
sudo nano /etc/gdm3/custom.conf
```
确保 `WaylandEnable=false` 这一行被**注释掉**（或者直接改为 `WaylandEnable=true`）：
```ini
[daemon]
# WaylandEnable=false
```

### 🛠️ Step 2：配置 GDM 自动登录（解决无显示器无法登录的问题）
在没有物理显示器和键鼠的情况下，系统开机停留在登录界面会导致用户级服务无法启动。我们需要让系统开机自动进入你的用户会话。
在同一个 `/etc/gdm3/custom.conf` 文件中，添加或修改以下内容：
```ini
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=你的用户名
```
*(注意：将 `你的用户名` 替换为你实际的 Ubuntu 登录账号)*

### 🛠️ Step 3：配置 GNOME Remote Desktop (Headless 模式)
GNOME 50 的 `grdctl` 工具提供了专门的 `--headless` 参数，用于配置无头环境下的 RDP 服务。

在终端（可通过 SSH 或首次接显示器）执行以下命令：
```bash
# 1. 启用 headless RDP 模式
grdctl --headless rdp enable

# 2. 设置 RDP 连接的凭据（用户名和密码，用于远程连接时验证）
grdctl --headless rdp set-credentials 你的用户名 你的密码

# 3. 允许远程控制（关闭只读模式，否则你只能看不能操作）
grdctl --headless rdp disable-view-only

# 4. 设置端口（默认是 3389，如果与系统其他服务冲突可改为 3390 等）
grdctl --headless rdp set-port 3389

# 5. 确认配置状态
grdctl --headless status --show-credentials
```

### 🛠️ Step 4：避坑配置（极其重要！）
在无头环境下，**自动锁屏和休眠是导致 RDP 连接闪退或无法重连的“头号杀手”**。必须通过命令行彻底关闭它们：

```bash
# 禁用屏幕保护程序和自动锁屏
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

# 禁用插电状态下的自动休眠
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
```

### 🛠️ Step 5：重启并验证服务
完成上述配置后，重启系统：
```bash
sudo reboot
```
等待约 30 秒系统启动完毕后，通过 SSH 连入机器，验证无头会话和 RDP 端口是否正常：
```bash
# 检查 3389 端口是否被 gnome-remote-desktop 监听
ss -tlnp | grep 3389

# 检查 Wayland 用户会话是否成功启动
loginctl list-sessions
# 你应该能看到 Type=wayland 的会话
```

### 💻 Step 6：使用客户端连接
1. 打开 Windows 自带的 **“远程桌面连接” (mstsc.exe)** 或 macOS 的 Microsoft Remote Desktop。
2. 输入 Ubuntu 机器的 `IP地址:3389`。
3. 连接时可能会提示“证书不受信任”（因为 GRD 默认生成自签名证书），选择 **“继续/是”** 即可。
4. 输入你在 Step 3 中设置的 RDP 凭据，即可进入流畅的 GNOME 50 Wayland 桌面。

---

### 🌟 GNOME 50 无头会话的独家优势
在 Ubuntu 26.04 上使用这套方案，你将体验到 GNOME 50 底层重构带来的巨大提升：
1. **`gnome-headless-session` 服务**：GNOME 50 引入了专属的无头会话服务，系统会自动为你生成一个虚拟的显示输出，不再需要购买“显卡欺骗器（HDMI 假负载）”或配置复杂的虚拟 Xorg 驱动。
2. **Handover（握手交接）机制**：当你通过 RDP 连接时，底层的 `system-daemon` 会平滑地将连接交接给你的用户会话，大幅减少了连接时的黑屏和闪退概率。
3. **硬件加速与 HDR**：GNOME 50 的远程桌面支持基于 Vulkan/VA-API 的硬件编码加速，拖动窗口、看视频的延迟极低，甚至支持 HDR 元数据的远程映射。
4. **无缝的 HiDPI 缩放**：如果你使用 4K 显示器远程连接，GNOME 50 能够正确识别并应用分数缩放，界面不会发虚或过小。
