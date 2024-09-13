# ubuntu24.04 kvm amdgpu + nvidia GPU 直通


## 0. 首先安装 qemu kvm virt-manager 相关工具。查看当前目录下的（virt-mamager.txt） 文件

- 1. 如果安装了 nvidia 驱动，需要先卸载。 sudo apt autoremove --purge nvidia-driver-550

## 开启IOMMU

- 1. 在BIOS 里开启IOMMU功能 ? 一般就是 VT-d(intel cpu) VT-i(amd cpu)


- 在linux 系统内检查 
    - amd cpu: 
    ```
    dmesg |grep -i amdivi
    # 输出有如下行就是
    pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
    AMD-Vi: Interrupt remapping enabled
    ```
    - intel cpu: 
    ```
    # 还没有检查 
    ```

## 2. 在host禁用nvidia 驱动

- vim /etc/modprobe.d/zx-kvm.conf

```
# A卡GPU
blacklist amdgpu
blacklist pcieport
blacklist snd_hda_intel

# N卡GPU
blacklist nvidia
blacklist nouveau
blacklist snd_hda_intel
```

## 2. 开启vfio

- vim /etc/modules-load.d/zx-kvm.conf

```
# 这个可以让vfio驱动优先加载
softdep snd_hda_intel pre:vfio vfio_pci
softdep amdgpu pre:vfio vfio_pci

#kvm 显卡直通
vfio_pci
vfio
vfio_iommu_type1
```

## 3. 查看GPU PCI ID 

- lspci -nnk |grep -i nvidia

- 输出示例

```
07:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3080 Ti] [10de:2208] (rev a1)
        Kernel driver in use: nvidia
        Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia
07:00.1 Audio device [0403]: NVIDIA Corporation GA102 High Definition Audio Controller [10de:1aef] (rev a1)
```

- 这里加粗字段就是pci id了 NVIDIA Corporation GA102 [GeForce RTX 3080 Ti] **[10de:2208]** (rev a1)



## 4. 在 /etc/default/grub 里添加参数(在ubuntu24.04 vfio-pci.ids 这个好像可以不需要了)

- 添加或者修改: "GRUB\_CMDLINE\_LINUX\_DEFAULT="

```
GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on iommu=pt vfio-pci.ids=<10de:2208,10de:1aef>"
```

- vfio-pci.ids= 为上面查询到的GPU PCI id


## 5. 在已经安装好的win 系统的虚拟上，直通usb 键盘+鼠标。和PCI 的nvidia GPU。

- 开机。


