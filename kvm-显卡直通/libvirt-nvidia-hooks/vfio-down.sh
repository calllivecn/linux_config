#!/usr/bin/bash

set -x

CWD=$(cd $(dirname "$0");pwd)
cd $CWD

# 加载配置
source vm.conf

sleep 10

modprobe -r vfio_pci
modprobe -r vfio
modprobe -r vfio_iommu_type1

# ubuntu24.04 没有这个
#modprobe -r vfio_virqfd

PCI_IDS_len=${#NVIDIA_PCI_IDS[@]}
for PCI_ID in $(seq 0 $PCI_IDS_len)
do
	virsh nodedev-reattach "${NVIDIA_PCI_IDS[$PCI_ID]}"
done


#echo 1 > /etc/class/vtconsole/vtcon0/bind
#echo 1 > /etc/class/vtconsole/vtcon1/bind

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

modprobe nvidia
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia_drm
modprobe drm_kms_helper
modprobe i2c_nvidia_gpu
modprobe drm

sleep 10

systemctl start "$DISPLAY_MANAGER"

