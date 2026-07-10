## 在 SSH 会话中执行 `secret-tool` 时弹出 GUI 密码框，**根本原因是你的 SSH 会话继承了图形桌面的 `DISPLAY` 或 `WAYLAND_DISPLAY` 环境变量**。

当 `libsecret`（`secret-tool` 的底层库）检测到这些变量时，它会认为你处于一个“有图形界面”的环境中。为了安全起见，它默认调用图形化的 Pinentry 程序来请求密码，而不是在终端里显示文本提示。由于你是通过 SSH 远程登录，这个 GUI 弹窗实际上是在服务器端的本地显示器上弹出的（或者因为 X11/Wayland 转发配置问题而卡住），导致你在 SSH 终端里看起来像是“卡死”了。

要强制在 SSH 终端中以纯文本方式解锁密钥环，请按以下步骤操作：

### 阻断图形接口检测
在执行任何密钥环命令前，先临时“欺骗”系统，让它以为没有图形界面可用。请在 SSH 终端中执行：

```bash
unset DISPLAY
unset WAYLAND_DISPLAY
```

- **原理**：移除这两个环境变量后，`secret-tool` 和 `gnome-keyring-daemon` 将无法找到图形显示服务器，从而自动回退到基于 ncurses 的 TTY（纯文本）交互模式。
- **注意**：这不会影响你当前 SSH 会话的其他功能，仅影响需要调用 GUI 的程序。

### 使用管道传递密码（推荐用于脚本或非交互场景）
如果你希望在 SSH 中完全自动化地解锁，避免任何交互式提示，可以使用 `--unlock` 参数配合管道：

```bash
# 将你的登录密码通过管道传给守护进程
echo "你的用户登录密码" | gnome-keyring-daemon --unlock --components=secrets
```

- **关键点**：必须加上 `--components=secrets`，否则它可能只启动 SSH agent 而不解锁密码存储区。
- **环境变量更新**：执行上述命令后，终端会输出新的 `GNOME_KEYRING_CONTROL` 路径。你需要再次执行 `eval $(...)` 来捕获它，或者确保之前的环境变量仍然指向正确的 socket 文件。

### 验证并设置 RDP 凭据
在屏蔽了 GUI 变量并解锁密钥环后，再次尝试设置凭据：

```bash
# 此时应该会直接在终端提示 "Password:"，而不是弹窗
grdctl rdp set-credentials zx
```

如果仍然没有反应，可以显式指定使用 TTY 模式（部分版本的 libsecret 支持）：

```bash
# 强制使用标准输入/输出进行交互
SECRET_TOOL_NO_GUI=1 grdctl rdp set-credentials zx
```

### 为什么之前会弹窗？
这是一个设计特性而非 Bug。GNOME Keyring 的设计哲学是：**只要有图形界面，就优先使用图形化密码输入框**。这是为了防止恶意程序在后台通过伪造终端提示来窃取密码（TTY 劫持风险）。但在 SSH 远程管理场景下，这种“安全机制”反而成了阻碍。通过 `unset DISPLAY` 手动降级为 TTY 模式是标准的运维处理方式。

### 总结
你不需要在服务器上安装任何新工具，只需在 SSH 会话中执行 `unset DISPLAY && unset WAYLAND_DISPLAY`，即可强制所有密钥环操作回归终端文本交互模式，解决“假死”问题。

---

既然你已经用 SSH 解决了这个问题，要不要我帮你写个一键脚本，以后登录直接运行就能自动解锁？
