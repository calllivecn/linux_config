# ~~ubuntu24.04测试，被nvidia-driver 驱动阻止，驱动有问题。~~
# swap hibernate 

### 在现代 Linux 系统中，尤其是使用 **systemd** 的系统，配置休眠（Hibernate）非常简单。休眠功能依赖于将内存中的内容保存到磁盘上的一个特定分区或文件中，然后在下次开机时从该位置恢复。

### 1\. 检查和配置 Swap 空间

休眠的关键是有一个足够大的 **swap** 空间。这个 swap 空间必须至少和你系统的 **RAM** 一样大。如果你有足够大的 swap 分区，你可以跳过这一步。如果没有，你需要调整你的 swap 空间。

#### 使用 Swap 分区

如果你的系统使用一个专门的 swap 分区，你需要确保它足够大。你可以用 `swapon -s` 或 `free -h` 来检查当前的 swap 大小。如果不够，你可能需要使用 `fdisk`、`gparted` 等工具来调整分区。

#### 使用 Swap 文件

如果你不想调整分区，使用 swap 文件是一种更灵活的方式。

```bash
# 创建一个 16GB 的 swap 文件 (以 1GB 为单位)
# 假设你的内存是 16GB，你需要一个同样大小的 swap 文件
sudo fallocate -l 16G /swapfile

# 设置文件权限
sudo chmod 600 /swapfile

# 格式化为 swap
sudo mkswap /swapfile

# 启用 swap 文件
sudo swapon /swapfile

# 检查是否成功
free -h
```

**持久化配置**

为了让 swap 文件在重启后依然生效，你需要编辑 `/etc/fstab`。

```bash
# 打开 fstab 文件
sudo vim /etc/fstab
```

在文件末尾添加以下一行：

```
/swapfile none swap sw 0 0
```

-----

### 2\. 获取休眠所需的 UUID 或设备路径

休眠恢复时，系统需要知道从哪个设备或文件恢复数据。

#### 如果你使用 Swap 分区

你需要找到你的 swap 分区的 **UUID**。

```bash
# 查看所有设备的 UUID
sudo blkid
```

找到你的 swap 分区的那一行，记下 `UUID="..."` 中的值。例如：`UUID="a1b2c3d4-e5f6-7890-a1b2-c3d4e5f67890"`。

#### 如果你使用 Swap 文件

你需要找到包含这个文件的 **根分区** 的 **UUID**，以及 swap 文件在该分区上的 **偏移量**。

1.  找到根分区的 UUID:

    ```bash
    sudo blkid /
    ```

    记下根分区的 UUID。

2.  找到 swap 文件的偏移量:

    ```bash
    sudo filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}'
    ```

    这个命令会输出偏移量，例如 `4096`。

-----

### 3\. 配置 Kernel 启动参数

现在，你需要告诉 **GRUB** 或 **systemd-boot** 在启动时使用哪个设备或文件进行休眠恢复。

```bash
# 打开 GRUB 配置文件
sudo vim /etc/default/grub
```

找到 `GRUB_CMDLINE_LINUX_DEFAULT` 这一行，并在双引号内添加休眠参数。

#### 如果使用 Swap 分区

在现有参数后添加 `resume=UUID=你的swap分区的UUID`。

例如：

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash resume=UUID=a1b2c3d4-e5f6-7890-a1b2-c3d4e5f67890"
```

#### 如果使用 Swap 文件

在现有参数后添加 `resume=UUID=你的根分区的UUID resume_offset=你的偏移量`。

例如：

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash resume=UUID=f7e8c9d0-a1b2-3456-7890-a1b2c3d4e5f6 resume_offset=4096"
```

修改完成后，更新 GRUB 配置：

```bash
sudo update-grub
```

-----

### 4\. 测试休眠功能

现在，所有的配置都已完成。重启你的系统，然后通过以下命令测试休眠：

```bash
sudo systemctl hibernate
```

如果一切正常，你的系统会关机。再次开机后，你将回到关机前的状态。

**如果休眠失败**

  * 检查你的 swap 空间是否足够大。
  * 确认 UUID 或偏移量是否正确。
  * 一些显卡驱动（尤其是闭源驱动）可能会导致休眠失败。如果你遇到问题，可以尝试更新驱动或在搜索引擎中查找特定的解决方案。

-----

### Python 脚本辅助

作为一名高级 Python 用户，你可能会觉得手动操作有些繁琐。这里提供一个简单的 Python 脚本来自动化配置 swap 文件和 GRUB 参数的过程，仅供参考：

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
一个简单的 Python 脚本，用于在 Linux 上配置 swap 文件以支持休眠。
注意：本脚本需要 root 权限才能运行。
"""

import subprocess
import os
import re

def run_command(command):
    """
    运行 shell 命令并返回输出。
    """
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"命令执行失败: {command}\n错误: {e.stderr}")
        exit(1)

def main():
    """主函数"""
    if os.geteuid() != 0:
        print("此脚本需要 root 权限才能运行。请使用 sudo。")
        exit(1)

    print("开始配置 swap 文件以支持休眠...")
    
    # 1. 获取系统内存大小
    mem_info = run_command("free -b | grep Mem: | awk '{print $2}'")
    mem_size_bytes = int(mem_info)
    
    # 2. 创建 swap 文件
    swap_file_path = "/swapfile"
    print(f"正在创建大小为 {mem_size_bytes / 1024**3:.2f} GB 的 swap 文件...")
    run_command(f"fallocate -l {mem_size_bytes} {swap_file_path}")
    run_command(f"chmod 600 {swap_file_path}")
    run_command(f"mkswap {swap_file_path}")
    run_command(f"swapon {swap_file_path}")
    print("swap 文件创建并启用成功。")

    # 3. 获取根分区 UUID 和 swap 文件偏移量
    root_uuid = run_command("sudo blkid / | awk '{print $2}'").split('=')[1].strip('"')
    print(f"根分区 UUID: {root_uuid}")
    
    offset = run_command(f"filefrag -v {swap_file_path} | awk '{{if($1==\"0:\"){{print $4}}}}'")
    if not offset:
        print("未能获取 swap 文件偏移量，请手动检查。")
        exit(1)
    
    print(f"Swap 文件偏移量: {offset}")

    # 4. 配置 GRUB
    grub_config_path = "/etc/default/grub"
    grub_line_pattern = r'GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"'
    resume_params = f'resume=UUID={root_uuid} resume_offset={offset}'
    
    with open(grub_config_path, 'r') as f:
        grub_content = f.read()
    
    # 查找并替换 GRUB_CMDLINE_LINUX_DEFAULT 行
    match = re.search(grub_line_pattern, grub_content)
    if match:
        old_line = match.group(0)
        # 如果已经存在 resume 参数，则先移除
        new_params = re.sub(r'resume=[\S]+', '', old_line)
        new_params = re.sub(r'resume_offset=[\S]+', '', new_params)
        
        # 将新参数添加到行尾，并去除多余的空格
        new_line = new_params.replace('"', f' {resume_params}"').replace('  ', ' ')
        new_grub_content = grub_content.replace(old_line, new_line)
    else:
        print("未找到 GRUB_CMDLINE_LINUX_DEFAULT 行，请手动编辑。")
        exit(1)

    # 写入新的 GRUB 配置
    with open(grub_config_path, 'w') as f:
        f.write(new_grub_content)

    print("GRUB 配置文件已更新。")
    print("正在更新 GRUB 启动配置...")
    run_command("update-grub")
    print("GRUB 配置更新成功。")
    print("配置完成。请重启系统以使更改生效，然后可以使用 'sudo systemctl hibernate' 测试休眠。")

if __name__ == "__main__":
    main()
```

希望这些步骤对你有帮助。

---

## 如果使用 swap 文件，**它并不一定非要在根分区上**。你可以把它放在任何一个支持的文件系统上，例如一个独立的数据分区。但这样做会稍微增加配置的复杂性，因为你需要确保内核在恢复休眠时能正确地找到并挂载这个分区。

主要的挑战在于：

1.  **挂载时机**: 在休眠恢复时，内核需要能够在很早的启动阶段就找到并访问包含 swap 文件的分区。如果该分区需要额外的驱动或复杂的逻辑才能挂载，可能会导致恢复失败。
2.  **文件系统支持**: 并非所有文件系统都完全支持 swap 文件。Ext4、Btrfs 等常见的文件系统都没有问题，但一些特殊的文件系统可能不支持。
3.  **GRUB 配置**: 你的 `GRUB_CMDLINE_LINUX_DEFAULT` 参数需要同时指定包含 swap 文件的分区的 UUID，以及 swap 文件的偏移量。

### 配置步骤 (如果 swap 文件不在根分区)

假设你的 swap 文件位于一个名为 `/data` 的分区上：

1.  **准备 Swap 文件**: 按照之前的步骤，在 `/data` 分区上创建一个 swap 文件，例如 `/data/swapfile`。

    ```bash
    sudo fallocate -l 16G /data/swapfile
    sudo chmod 600 /data/swapfile
    sudo mkswap /data/swapfile
    sudo swapon /data/swapfile
    ```

2.  **获取 UUID 和偏移量**:

      - 获取包含 `/data` 目录的分区的 UUID：
        ```bash
        sudo blkid /data
        ```
      - 获取 swap 文件的偏移量：
        ```bash
        sudo filefrag -v /data/swapfile | awk '{if($1=="0:"){print $4}}'
        ```

3.  **修改 GRUB 配置**:
    编辑 `/etc/default/grub`，将 `GRUB_CMDLINE_LINUX_DEFAULT` 替换为以下格式：

    ```
    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash resume=UUID=你存放swap文件的分区的UUID resume_offset=你的偏移量"
    ```

    -----

    **注意**: 在这种情况下，`resume` 参数不再指向根分区，而是指向存放 swap 文件的分区。

4.  **更新 GRUB**:

    ```bash
    sudo update-grub
    ```

### 总结

虽然技术上可行，但将 swap 文件放在非根分区上会引入一些潜在的复杂性。对于大多数用户来说，**将 swap 文件直接放在根分区上是更简单、更可靠的做法**。因为它避免了处理额外分区挂载的启动时机问题，且配置参数更直观。

考虑到你是一个高级 Linux 用户，并且对命令非常熟悉，上述步骤对你来说应该不难。如果你追求更灵活的配置，可以尝试这种方式。但如果目标是快速、稳定地启用休眠功能，我还是推荐使用根分区的 swap 文件或者一个独立的 swap 分区。
