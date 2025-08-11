# 要为 QEMU 8.2 和 libvirtd 10.0 环境下的虚拟机配置 HugePages，以下是几个必须的步骤。这些步骤确保了 HugePages 在宿主机上可用，并且虚拟机能够正确地使用它们。

### 1\. 宿主机 HugePages 准备

这是基础，没有这一步，后续的一切都无从谈起。你需要告诉内核预留多少 HugePages。

  * **配置内核参数**
    编辑 `/etc/sysctl.conf` 文件，添加或修改 `vm.nr_hugepages` 参数。例如，如果你想分配 8GB 的内存，使用 2MB 大小的 HugePages，你需要计算出所需数量：`8GB / 2MB = 4096`。

    ```bash
    # 告诉内核预留 4096 个 2MB 大小的 HugePages
    vm.nr_hugepages = 4096
    ```

    如果你希望使用 1GB 的 HugePages，则需要配置 `vm.nr_hugepages_mempolicy` 和 `vm.hugetlb_shm_group`。对于 2MB HugePages，通常不需要额外配置。

  * **使配置生效**
    保存文件后，运行 `sudo sysctl -p` 使配置立即生效。重启机器也可以。
    可能需要多运行几次，直到`grep -i huge /proc/meminfo` 输出中：
    **HugePages_Total:    8192 -> 为配置的 vm.nr_hugepages = 4096 **
    ```
    AnonHugePages:    133120 kB
    ShmemHugePages:        0 kB
    FileHugePages:         0 kB
    HugePages_Total:    8192
    HugePages_Free:        0
    HugePages_Rsvd:        0
    HugePages_Surp:        0
    Hugepagesize:       2048 kB
    Hugetlb:        16777216 kB
    ```

  * **创建挂载点**
    虽然 `libvirtd` 在某些情况下可以自动处理，但手动创建和挂载一个 HugePages 文件系统是最佳实践。

    ```bash
    # 创建挂载点
    sudo mkdir -p /dev/hugepages
    # 挂载 hugetlbfs 文件系统
    sudo mount -t hugetlbfs none /dev/hugepages
    ```

    为了让它在重启后自动挂载，你可以在 `/etc/fstab` 中添加一行：

    ```
    hugetlbfs /dev/hugepages hugetlbfs defaults 0 0
    ```

  * **检查 HugePages 状态**
    运行 `grep HugePages_ /proc/meminfo` 确认 HugePages 已经分配成功。你应该能看到 `HugePages_Total` 和 `Hugepagesize` 的值是你配置的。

-----

### 2\. 用户权限配置

`libvirtd` 进程通常以 `libvirt-qemu` 用户运行，它需要足够的权限来锁定内存（即使用 HugePages）。

  * **修改 `/etc/security/limits.conf`**
    编辑此文件，为 `libvirt-qemu` 用户设置 `memlock` 限制。这个值需要大于或等于你分配给虚拟机的 HugePages 内存总量（以 KB 为单位）。
    ```bash
    # 为 libvirt-qemu 用户设置内存锁定软硬限制
    # 假设你分配了 8GB = 8 * 1024 * 1024 KB = 8388608 KB
    libvirt-qemu soft memlock 8388608
    libvirt-qemu hard memlock 8388608
    ```
    为了让此配置生效，你可能需要重启 `libvirtd` 服务或整个机器。

-----

### 3\. libvirt XML 配置

这是最后一步，也是最直接的一步。你需要在虚拟机的 XML 配置文件中明确告诉 `libvirt` 和 `QEMU` 使用 HugePages。

  * **编辑虚拟机 XML 文件**
    使用 `virsh edit <vm_name>` 命令编辑你的虚拟机配置。

  * **添加 `<memoryBacking>` 标签**
    在 `<domain>` 标签下，找到 `<memory>` 和 `<currentMemory>` 标签，并在它们后面添加 `<memoryBacking>` 块。

    ```xml
    <memory unit='KiB'>8388608</memory>
    <currentMemory unit='KiB'>8388608</currentMemory>
    <memoryBacking>
      <hugepages/>
      <locked/>
    </memoryBacking>
    ```

    这里的 `<hugepages/>` 标签是关键，它告诉 `libvirtd` 使用 HugePages。`<locked/>` 标签则确保 QEMU 进程使用的内存不会被换出（swapped out），这对于性能至关重要。

  * **保存并重启虚拟机**
    保存 XML 文件后，你需要重启虚拟机（`virsh shutdown <vm_name>` 然后 `virsh start <vm_name>`）以应用新的配置。

完成以上所有步骤后，你的虚拟机就会使用 HugePages 运行，从而获得更好的内存性能。




# 遇到的报错：

这个错误信息：`unable to map backing store for guest RAM: Cannot allocate memory`，通常表示 QEMU 进程无法锁定或分配其所需的 HugePages 内存。即使你在 `<memoryBacking>` 中没有明确配置 `<locked/>`，`libvirt` 在使用 HugePages 时默认会尝试锁定这部分内存。

要解决这个问题，你需要检查以下两个关键点。

### 1\. 检查 HugePages 的可用性

首先，确保你的宿主机上已经分配了足够数量的 HugePages。如果分配的 HugePages 不够，QEMU 无法启动。

  * **确认已分配的 HugePages 数量**
    运行以下命令检查当前系统的 HugePages 状态：

    ```bash
    grep HugePages_ /proc/meminfo
    ```

    请注意 `HugePages_Total` 的值。这个值必须大于或等于你为虚拟机分配的内存。例如，如果你的虚拟机需要 8GB 内存，并且你使用了 2MB 的 HugePages，那么 `HugePages_Total` 至少应为 4096。

  * **如果 HugePages 不足**
    如果发现 HugePages 不足，你需要增加 `vm.nr_hugepages` 的值。

    ```bash
    # 例如，需要将 2MB HugePages 数量增加到 4096
    echo 4096 | sudo tee /proc/sys/vm/nr_hugepages
    ```

    这只是临时修改，重启后会失效。如果需要永久配置，请修改 `/etc/sysctl.conf` 并运行 `sudo sysctl -p`。

-----

### 2\. 检查 `memlock` 权限

即使 HugePages 已经分配，`libvirt-qemu` 用户也必须有足够的权限来锁定这些内存。如果 `memlock` 限制设置得太低，QEMU 同样会因为无法锁定内存而失败。

  * **确认 `memlock` 限制**
    查看 `libvirt-qemu` 用户的 `memlock` 限制。你可以使用 `su` 切换到该用户，然后运行 `ulimit` 命令，但这有点麻烦。更直接的方法是检查 `/etc/security/limits.conf` 文件。

    ```bash
    cat /etc/security/limits.conf
    ```

    查找为 `libvirt-qemu` 用户设置的 `memlock` 硬限制（hard memlock）和软限制（soft memlock）。这个值必须大于你虚拟机内存的总量，以 KB 为单位。例如，8GB 内存需要 `8388608` KB 的限制。

  * **如果 `memlock` 限制太低**
    如果发现 `memlock` 限制低于虚拟机所需的内存，请编辑 `/etc/security/limits.conf` 文件，为 `libvirt-qemu` 用户增加限制。

    ```bash
    # 将限制设置为大于或等于虚拟机内存（例如 8GB = 8388608 KB）
    libvirt-qemu soft memlock 8388608
    libvirt-qemu hard memlock 8388608
    ```

    修改后，请**重启 `libvirtd` 服务**（`sudo systemctl restart libvirtd`）以确保新的限制生效。在某些系统上，你可能需要重启整个宿主机。

这个问题最常见的根源就是这**两个**配置之一不正确。请按照上述步骤仔细检查，特别是 **`memlock` 限制**，因为这是使用 HugePages 且无需手动 `mlock` 的情况下最容易被忽略的环节。
