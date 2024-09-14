# ubuntu24.04 kvm amdgpu + nvidia GPU 直通


## 0. 首先安装 qemu kvm virt-manager 相关工具。查看当前目录下的（virt-mamager.txt） 文件

- ~~1. 如果安装了 nvidia 驱动，需要先卸载。 sudo apt autoremove --purge nvidia-driver-550~~
- 新方法可以，启动直通机器时自动卸载(modprobe)nvidia驱动, 关机时，自动恢复nvidia驱动。


## 1. 开启IOMMU

-  在BIOS 里开启IOMMU功能 ? 一般就是 VT-d(intel cpu) VT-i(amd cpu)


- 在linux 系统内检查 
    - amd cpu: 
    ```
    dmesg |grep -i amd-vi
    # 输出有如下行就是
    pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
    AMD-Vi: Interrupt remapping enabled
    ```
    - intel cpu: 
    ```
    # 还没有检查 
    ```

## 2. 查看GPU PCI ID 

- lspci -nnk |grep -i nvidia

- 输出示例

```
07:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3080 Ti] [10de:2208] (rev a1)
        Kernel driver in use: nvidia
        Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia
07:00.1 Audio device [0403]: NVIDIA Corporation GA102 High Definition Audio Controller [10de:1aef] (rev a1)
```

- 这里加粗字段就是pci id了 NVIDIA Corporation GA102 [GeForce RTX 3080 Ti] **[10de:2208]** (rev a1)


## 3. 配置vfio 加载时的， nvidia pci id 参数

- vim /etc/modules-load.d/zx-kvm.conf

```
blacklist nouveau

options vfio-pci ids=10de:2208,10de:1aef disable_idle_d3=1 disable_idle_d3=1
```


## 4. 在 /etc/default/grub 里添加参数(在ubuntu24.04 vfio-pci.ids 这个好像可以不需要了)

- 添加或者修改: "GRUB\_CMDLINE\_LINUX\_DEFAULT="

```
GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 amd_iommu=on iommu=pt"
```

## 5. 这里先正常安装不直通的 win系统的虚拟机

- 开机。
- 正常安装完操作系统。
- 关机，为之后的直通做好准备。


## 6. 把libvirt-nvidia-hooks 下的脚本和配置复制到 /etc/libvirt/hooks/

- 修改配置文件 vm.conf

    ```shell
    # 你的显卡直通的虚拟机名 (virsh list --all)
    VM_NAME=
    
    # 你的显示管理器
    DISPLAY_MANAGER=gdm.service
    ```

- 把前面第4步找到的nvidia 的 pci 地址，**注意是行开头的地址** 记下，

    ```shell
    07:00.0 VGA compatible controller
    ```
    
    - 如这里的 07:00.0 对就修改就是 pci_0000_07_00_0
    - 如这里的 07:00.1 对就修改就是 pci_0000_07_00_1

- 修改vfio-startup.sh 和 vfio-down.sh

    - vfio-startup.sh

    ```shell
    virsh nodedev-detach pci_0000_07_00_0
    virsh nodedev-detach pci_0000_07_00_1
    ```

    - vfio-down.sh

    ```shell
    virsh nodedev-reattach pci_0000_07_00_0
    virsh nodedev-reattach pci_0000_07_00_1
    ```

- 然后在配置显卡直通后，在启动进入系统去安装 nvidia 显卡驱动。


## 7. 可以开启虚拟机去安装直通显卡驱动了。

- 在virt-manager 配置里，直通usb 键盘+鼠标。和PCI 的nvidia GPU。
- 开机开始安装nvidia驱动
- **注意**: 这时开机是会把宿主机的nvida 占用的。如果你只有一个显示器。宿主机的显示输出会黑掉。
- 过会后等虚拟机启动后。在开始安装 nvidia 驱动,完成后就可以正常使用了。

## **在安装驱动的时候，可能遇到: **

- ...

