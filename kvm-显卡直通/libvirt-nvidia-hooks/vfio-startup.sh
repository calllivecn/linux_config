#!/usr/bin/bash

set -x


systemctl stop "$DISPLAY_MANAGER"

sleep 10

echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

sleep 5

modprobe -r nvidia_uvm
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r nvidia
#modprobe -r drm_kms_helper
#modprobe -r i2c_nvidia_gpu
#modprobe -r drm

# N卡的声音驱动, 这里也是使用的intel的。lspci -nnk |grep -A 4 -i nvidia。 可以查看到当前使用的驱动。
modprobe -r snd_hda_intel

sleep 5

virsh nodedev-detach pci_0000_07_00_0
virsh nodedev-detach pci_0000_07_00_1

sleep 5

modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_pci
#modprobe vfio_virqfd

