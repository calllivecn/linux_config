#!/usr/bin/bash

set -x

source log.sh

log "modprobe -r -a vfio vfio_iommu_type1 vfio_pci"
modprobe -r -a vfio vfio_iommu_type1 vfio_pci
# ubuntu24.04 没有这个
#modprobe -r vfio_virqfd

log "sleep 5"
sleep 5

for pci_id in ${NVIDIA_PCI_IDS[@]}
do
	log "virsh nodedev-reattach ${pci_id}"
	virsh nodedev-reattach "${pci_id}"
done

# update: 2024-12-29, 一次加载
log "modprobe -a nvidia nvidia_modeset nvidia_uvm nvidia_drm snd_hda_intel"
modprobe -a nvidia nvidia_modeset nvidia_uvm nvidia_drm snd_hda_intel

log "sleep 5"
sleep 5

log "systemctl start ${DISPLAY_MANAGER}"
systemctl start "$DISPLAY_MANAGER"

