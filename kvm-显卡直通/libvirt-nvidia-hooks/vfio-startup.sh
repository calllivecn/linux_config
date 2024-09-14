#!/usr/bin/bash

set -x


systemctl stop "$DISPLAY_MANAGER"

echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

sleep 5

modprobe -r nvidia_drm
modprobe -r nvidia_uvm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm


#PCI_IDS_len=${#NVIDIA_PCI_IDS[@]}
#for PCI_ID in $(seq 0 $PCI_IDS_len)
#do
#	virsh nodedev-detach "${NVIDIA_PCI_IDS[$PCI_ID]}"
#done

sleep 5

virsh nodedev-detach pci_0000_07_00_0
virsh nodedev-detach pci_0000_07_00_1


sleep 5

modprobe vfio_pci
modprobe vfio
modprobe vfio_iommu_type1
#modprobe vfio_virqfd

