#!/usr/bin/bash

set -x

source log.sh

# debug 查看参数是否正确
log "VM_NAME: $VM_NAME"
log "DISPLAY_MANAGER: $DISPLAY_MANAGER"
log "NVIDIA_PCI_IDS: ${NVIDIA_PCI_IDS[@]}"


log "systemctl stop $DISPLAY_MANAGER"
systemctl stop "$DISPLAY_MANAGER"

log "systemctl stop nvidia-persistenced.service"
systemctl stop nvidia-persistenced.service

log "sleep 5"
sleep 5

log "kill 还在使用 /dev/nvidia0 的进程"
for pid in $(lsof /dev/nvidia0 |tail -n +2 |awk '{PIDS[$2]++} END{for(pid in PIDS) {print pid}}')
do
    kill "$pid"
done

while :
do
	log "modprobe -r -a nvidia nvidia_uvm nvidia_drm nvidia_modeset snd_hda_intel"
	# N卡的声音驱动, 这里也是使用的intel的:snd_hda_intel 。lspci -nnk |grep -A 4 -i nvidia。 可以查看到当前使用的驱动。
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


log "sleep 5"
#sleep 5

# 我去。。这里根本没用上，但是也是可行的。。。
for pci_id in ${NVIDIA_PCI_IDS[@]}
do
	log "virsh nodedev-detach ${pci_id}"
	virsh nodedev-detach "${pci_id}"
done

log "sleep 5"
#sleep 5

# update: 2024-12-29, 这样可以确保所有必要的模块都以正确的顺序加载，避免潜在的问题。
log "modprobe -a vfio_pci vfio vfio_iommu_type1"
modprobe -a vfio_pci vfio vfio_iommu_type1 2>&1 >> "$LOG_PATH"

