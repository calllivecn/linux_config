
LOG_PATH="/var/log/libvirt/custom_hooks.log"

log(){
	echo "$@"| awk '{print strftime("%Y-%m-%d_%H:%M:%S:"),$0}' >> "$LOG_PATH"
}
