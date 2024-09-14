#!/usr/bin/bash

set -x

sleep 5

modprobe -r vfio
modprobe -r vfio_iommu_type1
modprobe -r vfio_pci
# ubuntu24.04 没有这个
#modprobe -r vfio_virqfd

#PCI_IDS_len=${#NVIDIA_PCI_IDS[@]}
#for PCI_ID in $(seq 0 $PCI_IDS_len)
#do
#	virsh nodedev-reattach "${NVIDIA_PCI_IDS[$PCI_ID]}"
#done

sleep 5

virsh nodedev-reattach pci_0000_07_00_0
virsh nodedev-reattach pci_0000_07_00_1

sleep 5

echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 1 > /sys/class/vtconsole/vtcon1/bind

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

sleep 5

# N卡的声音驱动, 这里也是使用的intel的。lspci -nnk |grep -A 4 -i nvidia。 可以查看到当前使用的驱动。
modprobe snd_hda_intel

modprobe nvidia
#modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia_drm
#modprobe drm_kms_helper
#modprobe i2c_nvidia_gpu
#modprobe drm

sleep 5

systemctl start "$DISPLAY_MANAGER"

