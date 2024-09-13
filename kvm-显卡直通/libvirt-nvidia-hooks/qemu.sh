#!/usr/bin/bash


CWD=$(cd $(dirname "$0");pwd)
cd $CWD

# 加载配置
source vm.conf


OBJECT="$1"
OPERATION="$2"



if [[ $OBJECT == "$VM_NAME" ]]; then
	case "$OPERATION" in
        	"prepare")
                #systemctl start libvirt-nosleep@"$OBJECT"  2>&1 | tee -a /var/log/libvirt/custom_hooks.log
                bash vfio-startup.sh 2>&1 | tee -a /var/log/libvirt/custom_hooks.log
                ;;

            "release")
                #systemctl stop libvirt-nosleep@"$OBJECT"  2>&1 | tee -a /var/log/libvirt/custom_hooks.log  
                bash vfio-down.sh 2>&1 | tee -a /var/log/libvirt/custom_hooks.log
                ;;
	esac
fi

