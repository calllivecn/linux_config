# qemu-kvm-只安装virt-manager客户端

## 远程轻客户端少安装点
 - ~~apt install --no-install-recommends virt-manager libvirt-daemon-system ovmf qemu-system-x86~~


## 需要跑虚拟机的机器这样安装
- apt install virt-manager libvirt-daemon-system ovmf qemu-system-x86

- virtiofsd 宿主机共享目录到虚拟机: 需要在宿主机安装
- windows系列虚拟需要安装: virtio-win-guest-tools.exe


## 把当前用户添加到 libvirt, kvm

- sudo gpasswd -a zx libvirt
- sudo gpasswd -a zx kvm


## 虚拟化工具

- virt-manager


## libvirtd 虚拟机 UEFI 引导包

- ovmf


- virtio 驱动 https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html
- 新地址(手动下载)：https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
- 新地址直接下载ISO：https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso


## ISO内容 ISO用于在Windows guest虚拟机中安装半虚拟驱动程序。该virtio-win/*.iso包含在RPM包含以下位：

```
 NetKVM/ -Virtio网络驱动程序
 
 viostor/ -Virtio块驱动程序
 
 vioscsi/ -Virtio小型计算机系统接口（SCSI）驱动程序
 
 viorng/ -Virtio RNG驱动程序
 
 vioser/ -Virtio串行驱动程序
 
 Balloon/ -Virtio内存气球驱动程序
 
 qxl/-适用于Windows 7和更低版本的QXL图形驱动程序。（构建virtio-win-0.1.103-1及更高版本）
 
 qxldod/-适用于Windows 8和更高版本的QXL图形驱动程序。（构建virtio-win-0.1.103-2及更高版本）
 
 pvpanic/- QEMU pvpanic设备驱动程序（编译为Virtio-WIN-0.1.103-2及更高版本）
 
 guest-agent/ -QEMU Guest Agent 32位和64位MSI安装程序
 
 qemupciserial/- QEMU PCI串行设备驱动程序
 
 *.vfd 在Windows XP安装过程中使用的VFD软盘映像
```

## AI 的回答

```text
VirtIO-win 目录结构详解
virtio-win 目录是用于在 Windows 虚拟机中安装 VirtIO 驱动的资源集合。该目录下的子目录和文件对应着不同的 VirtIO 设备驱动。

目录结构解析
amd64、i386: 这两个目录分别包含了 64 位和 32 位平台的驱动程序。
Balloon: 虚拟内存气球驱动，用于动态调整虚拟机内存大小。
cert: 证书相关的文件，可能用于某些特定的安全功能。
data: 可能包含一些配置文件或数据文件。
fwcfg: 固件配置相关的文件。
guest-agent: 虚拟机客户机代理，用于提供虚拟机与宿主机之间的通信。
NetKVM: 网络驱动，提供虚拟网络设备。
pvpanic: 虚拟机崩溃时的内核转储相关。
qemufwcfg: QEMU 固件配置相关。
qemupciserial: QEMU PCI 串口相关。
qxl: QXL 显示驱动，用于图形显示。
qxldod: QXL 显示驱动相关的文件。
smbus: SMBus 总线驱动。
sriov: SR-IOV（Single Root I/O Virtualization）相关驱动。
viofs: VirtIO 文件系统驱动。
viogpudo: VirtIO GPU 驱动。
vioinput: VirtIO 输入设备驱动。
viomem: VirtIO 内存访问驱动。
viorng: VirtIO 随机数生成器驱动。
vioscsi: VirtIO SCSI 驱动。
vioserial: VirtIO 串口驱动。
viostor: VirtIO 存储驱动。
驱动功能概述
网络: NetKVM 提供虚拟网卡驱动。
存储: vioscsi 和 viostor 提供虚拟磁盘驱动。
显示: qxl 和 qxldod 提供虚拟显示驱动。
输入: vioinput 提供虚拟输入设备驱动（如鼠标、键盘）。
其他: 还有许多其他驱动，如虚拟内存气球驱动、虚拟串口驱动等，用于支持虚拟机中的各种硬件设备。
MSI 文件说明
virtio-win-gt-x64.msi、virtio-win-gt-x86.msi: 这是 Windows 安装程序，用于安装 VirtIO 驱动。
virtio-win-guest-tools.exe: 这是虚拟机客户机工具的安装程序，提供了额外的功能，如共享文件夹等。
安装方法
通常，你可以将 virtio-win 目录中的 ISO 镜像挂载到 Windows 虚拟机中，然后运行其中的安装程序。具体步骤可能因虚拟机软件和 Windows 版本而略有不同。
```


## 一些问题
1. VNC协议鼠标不同步; 解决方案：
	```html
	1) virsh edit <vm name>
	2) 找到input <input type='mouse' bus='ps2'/>;
	修改为<input type='tablet' bus='usb'/>
	```

2. UEFI引导方式安装，虚拟机会无法使用快照。还没找到解决方案

3. wifi下的网络配置目前，只会使用NAT。但这样防火墙(nftables)就得开放了。
   不过使用有线桥接是可以的。


4. 手动导出一个虚拟机：
	1) virsh dumpxml <vm name> > <vm name>.xml
	2) vim <vm name>.xml 修改uuid。
	3) 在新机器导入的时候，修改相应的disk路径。

5. 导出虚拟机:
	1) virsh define --file /etc/libvirt/qemu/<vm name>.xml # 可能需要sudo
	2) 修改对应该的 网络，disk 路径，UEFI，等配置。



## 从virtualbox 迁移 win10 到 kvm, （不行还是启动不了）

1. 进行转换之前，您应该能够在Windows VM上运行sysprep。这告诉Windows在加载之前检查驱动程序，因为它们会更改。
	使用什么选项运行sysprep？
	注意：sysprep会删除计算机专用的ID，例如产品密钥和域成员身份。因此，sysprep主要用于克隆，但不适用于迁移。


## 显卡直通 查看当前目录下的(kvm-显卡直通.md)文件。

```shell
for d in /sys/kernel/iommu_groups/*/devices/*; do n=${d#*/iommu_groups/*}; n=${n%%/*}; printf 'IOMMU Group %s ' "$n"; lspci -nns "${d##*/}"; done;
```

1. virt-manager 操作 kvm虚拟机中鼠标不同步的问题
	在/etc/libvirt/qemu下找到对应的xml配置文件
	
	```html
	在<devices>标签下添加
	<input type='tablet' bus='usb'/>
	```


## 临时为正在运行的vm添加直通USB

- 1. 获取 U 盘的 vendor/product ID

```shell
lsusb
# 示例输出：Bus 002 Device 005: ID 0781:5581 SanDisk Corp. Ultra
记下 0781:5581（vendor:product）。
```

- 2. 创建一个临时 XML 片段（如 usb.xml）

```xml
<hostdev mode='subsystem' type='usb'>
  <source>
    <vendor id='0x0781'/>
    <product id='0x5581'/>
  </source>
</hostdev>
```
### 注意：0x 前缀是必须的。

- 3. 热插设备到运行中的虚拟机

```shell
virsh attach-device <虚拟机名称> usb.xml --live
# 例如：
virsh attach-device win10 usb.xml --live
# --live 表示只对当前运行的实例生效，不保存到配置。
```

- 4. 移除设备（热拔）

```shell
virsh detach-device <虚拟机名称> usb.xml --live
#注意：detach 时也需要提供相同的 XML 内容（或使用 --persistent 等选项）。
```

- 四、注意事项

    权限问题：确保 QEMU 进程有权限访问 USB 设备（通常需要将用户加入 plugdev 或 kvm 组，或通过 udev 规则授权）。
    设备独占：直通后宿主机将无法访问该 U 盘，直到虚拟机释放。
    稳定性：频繁热插拔可能在某些客户机 OS 中导致异常，建议安全弹出后再移除。
    替代方案：如果只是传文件，也可以考虑使用 virtio-serial、共享文件夹、或网络传输，避免 USB 直通复杂性。
