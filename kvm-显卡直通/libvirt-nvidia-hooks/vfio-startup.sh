#!/usr/bin/bash

set -x

CWD=$(cd $(dirname "$0");pwd)
cd $CWD

# 加载配置
source vm.conf


systemctl stop "$DISPLAY_MANAGER"

# 这是什么？没有这个路径呢
#echo 0 > /etc/class/vtconsole/vtcon0/bind
#echo 0 > /etc/class/vtconsole/vtcon1/bind

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

sleep 10

modprobe -r nvidia_drm
modprobe -r nvidia_uvm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm


PCI_IDS_len=${#NVIDIA_PCI_IDS[@]}
for PCI_ID in $(seq 0 $PCI_IDS_len)
do
	virsh nodedev-detach "${NVIDIA_PCI_IDS[$PCI_ID]}"
done

modprobe vfio_pci
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_virqfd

