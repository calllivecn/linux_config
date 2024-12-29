#!/usr/bin/bash

set -x

source log.sh

log "systemctl stop $DISPLAY_MANAGER"
systemctl stop "$DISPLAY_MANAGER"

log "sleep 5"
sleep 5

# kill 还在使用 /dev/nvidia0 的进程
for pid in $(lsof /dev/nvidia0 |awk '{print $2}' | tail -n +2)
do
    kill "$pid"
done

# 2024-12-29: 测试好像。。没有也行。
#echo 0 > /sys/class/vtconsole/vtcon0/bind
#echo 0 > /sys/class/vtconsole/vtcon1/bind
#echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

#modprobe -r nvidia_uvm
#modprobe -r nvidia_drm
#modprobe -r nvidia_modeset
#modprobe -r nvidia

#modprobe -r drm_kms_helper
#modprobe -r i2c_nvidia_gpu
#modprobe -r drm

while :
do
	log "modprobe -r -a nvidia nvidia_uvm nvidia_drm nvidia_modeset snd_hda_intel"
	# update: 2024-12-29 一次卸载所有的依赖
	modprobe -r -a nvidia nvidia_uvm nvidia_drm nvidia_modeset snd_hda_intel 2>&1 >> "$LOG_PATH"
	if [ $? -eq 0 ];then
		log "所有nvidia驱动卸载完成"
		break
	else
		log "nvidia驱动没有卸载完，sleep 1。"
		sleep 1
	fi
done

# N卡的声音驱动, 这里也是使用的intel的:snd_hda_intel 。lspci -nnk |grep -A 4 -i nvidia。 可以查看到当前使用的驱动。

log "sleep 5"
#sleep 5

log "virsh nodedev-detach pci_0000_07_00_0"
virsh nodedev-detach pci_0000_07_00_0
log "virsh nodedev-detach pci_0000_07_00_1"
virsh nodedev-detach pci_0000_07_00_1

log "sleep 5"
#sleep 5

#modprobe vfio
#modprobe vfio_iommu_type1
#modprobe vfio_pci
#modprobe vfio_virqfd

log "modprobe -a vfio_pci vfio vfio_iommu_type1"
# update: 2024-12-29, 这样可以确保所有必要的模块都以正确的顺序加载，避免潜在的问题。
modprobe -a vfio_pci vfio vfio_iommu_type1 2>&1 >> "$LOG_PATH"

