#!/bin/bash

vm_name="$1"

# event: choice: prepare、start、release、stopped
event="$2"

# sub_event: choice: 例如 migrate、restore 等
sub_event="$3"


case "$event" in
    prepare)
        echo "Preparing to start VM: $vm_name"
        # 在这里修改虚拟机的 XML 配置文件
        if [[ "$vm_name" == "myvm" ]]; then
          #使用 xmllint 修改xml文件
          xmllint --xpath 'string(//memory/@unit)' /etc/libvirt/qemu/$vm_name.xml
          xmllint --xpath 'string(//currentMemory/@unit)' /etc/libvirt/qemu/$vm_name.xml
          xmllint --xpath '/domain/memory' --set-attribute unit GiB /etc/libvirt/qemu/$vm_name.xml
          xmllint --xpath '/domain/currentMemory' --set-attribute unit GiB /etc/libvirt/qemu/$vm_name.xml
          virsh define /etc/libvirt/qemu/$vm_name.xml
        fi
        ;;
    start)
        echo "VM started: $vm_name"
        ;;
    release)
        echo "Preparing to stop VM: $vm_name"
        ;;
    stopped)
        echo "VM stopped: $vm_name"
        ;;
    *)
        echo "Unknown event: $event"
        exit 1
        ;;
esac

exit 0
