要创建 **LUKS1** 和 **LUKS2 + PBKDF2** 的加密设备，可以使用 `cryptsetup` 工具。以下是详细说明和命令。

---

## 🔐 一、创建 LUKS1 加密设备

LUKS1 是较旧但广泛兼容的格式（GRUB2 原生仅支持 LUKS1）。

### ✅ 命令：

```bash
sudo cryptsetup luksFormat --type luks1 /dev/your_device
```

### 示例：

```bash
sudo cryptsetup luksFormat --type luks1 /dev/sdb1
```

> 💡 系统会提示你输入密码（至少 8 位），并确认是否覆盖设备。

### 🔍 验证：

```bash
sudo cryptsetup luksDump /dev/sdb1
```

输出中会显示：
```
Version:        1
Cipher name:    aes
Cipher mode:    xts-plain64
Hash spec:      sha256
...
```

---

## 🔐 二、创建 LUKS2 设备并强制使用 PBKDF2（而非默认的 Argon2）

LUKS2 默认使用 **Argon2** 作为密钥派生函数（KDF），但某些环境（如旧版 initramfs 或 GRUB）可能只支持 **PBKDF2**。

你可以显式指定使用 `pbkdf2`。

### ✅ 命令：

```bash
sudo cryptsetup luksFormat \
  --type luks2 \
  --pbkdf pbkdf2 \
  --hash sha256 \
  --iter-time 1000 \
  /dev/your_device
```

### 参数说明：

| 参数 | 说明 |
|------|------|
| `--type luks2` | 使用 LUKS2 格式 |
| `--pbkdf pbkdf2` | 强制使用 PBKDF2（而非默认的 argon2i/argon2id） |
| `--hash sha256` | PBKDF2 使用的哈希算法（可选 sha1, sha256, sha512） |
| `--iter-time 1000` | 迭代时间（毫秒），控制加密强度，默认 2000ms；值越小速度越快但安全性略低 |

> ⚠️ 注意：`--iter-time` 越小，解锁越快，适合嵌入式或低性能设备。

### 示例：

```bash
sudo cryptsetup luksFormat \
  --type luks2 \
  --pbkdf pbkdf2 \
  --hash sha256 \
  --iter-time 500 \
  /dev/sdc1
```

### 🔍 验证：

```bash
sudo cryptsetup luksDump /dev/sdc1
```

输出应包含：
```
Version:        2
PBKDF:          pbkdf2
Hash:           sha256
Time cost:      500
...
```

---

## 🛠 三、为什么使用 PBKDF2？

- **GRUB2 对 LUKS2 的支持有限**：截至 GRUB 2.06（2022 年发布），GRUB **仅支持 LUKS2 + PBKDF2**，**不支持 Argon2**。
- 如果你希望 **用 GRUB 直接解锁 LUKS2 根分区**，必须使用 `--pbkdf pbkdf2`。
- 否则，GRUB 会报错：`unknown pbkdf type` 或无法解锁。

> ✅ 所以：**GRUB + LUKS2 = 必须用 PBKDF2**

---

## 🔄 四、将现有 LUKS2（Argon2）转换为 PBKDF2（可选）

如果你已有 LUKS2 设备使用 Argon2，可以添加一个使用 PBKDF2 的新密钥槽：

```bash
sudo cryptsetup luksAddKey \
  --pbkdf pbkdf2 \
  --hash sha256 \
  --iter-time 1000 \
  /dev/your_device
```

然后删除旧的 Argon2 密钥槽（假设它在 slot 0）：

```bash
sudo cryptsetup luksKillSlot /dev/your_device 0
```

> ⚠️ 操作前务必备份数据！

---

## 📌 五、最佳实践建议

| 场景 | 推荐配置 |
|------|--------|
| 需要 GRUB 解锁（如加密 `/boot` 或 `/`） | **LUKS1** 或 **LUKS2 + `--pbkdf pbkdf2`** |
| 仅由 initramfs 解锁（系统启动后） | LUKS2 + Argon2（默认，更安全） |
| 兼容性优先（旧系统、救援盘） | LUKS1 |
| 安全性优先（现代系统） | LUKS2 + Argon2（但不能用于 GRUB） |

---

## ✅ 总结命令速查

```bash
# 创建 LUKS1
sudo cryptsetup luksFormat --type luks1 /dev/sdX1

# 创建 LUKS2 + PBKDF2（用于 GRUB）
sudo cryptsetup luksFormat --type luks2 --pbkdf pbkdf2 --hash sha256 --iter-time 1000 /dev/sdX1

# 查看 LUKS 信息
sudo cryptsetup luksDump /dev/sdX1
```

---

如果你正在配置 **全盘加密 + GRUB 自动解锁**，建议使用 **LUKS2 + PBKDF2**，并确保你的 GRUB 版本 ≥ 2.06（Ubuntu 22.04+、RHEL 9+、Fedora 36+ 均已支持）。

需要我帮你写一个完整的 GRUB + LUKS2 自动解锁配置示例吗？
