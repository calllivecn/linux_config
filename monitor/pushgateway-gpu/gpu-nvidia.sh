#!/bin/bash
# date 2022-01-09 06:26:25
# author calllivecn <calllivecn@outlook.com>



. "$(dirname ${0})/libfuncs.sh"

MY_JOB="gpu_nvidia"

pushgateway(){
	runtime_info=$(nvidia-smi |grep -A 1 "NVIDIA GeForce" |tail -n 1)
	temp=$(echo "$runtime_info" | awk '{print $3}')
	# 去掉温度符号
	temp=${temp%C}

	#功耗 
	power_usage=$(echo "$runtime_info" | awk '{print $5}')
	power_usage=${power_usage%W}

	power_cap=$(echo "$runtime_info" | awk '{print $7}')
	power_cap=${power_cap%W}
	
	memory_usage=$(echo "$runtime_info" | awk '{print $9}')
	memory_usage=${memory_usage%MiB}
	
	memory_total=$(echo "$runtime_info" | awk '{print $11}')
	memory_total=${memory_total%MiB}
	
	gpu_usage=$(echo "$runtime_info" | awk '{print $13}')
	gpu_usage=${gpu_usage%\%}
	
context="
gpu_nvidia_temp $temp
gpu_nvidia_power_usage $power_usage
gpu_nvidia_power_cap $power_cap
gpu_nvidia_memory_usage $memory_usage
gpu_nvidia_memory_total $memory_total
gpu_nvidia_usage $gpu_usage
"
	echo "$context" | curl -s --data-binary @- "${PUSHGATEWAY}/metrics/job/${MY_JOB}/nodename/${NODENAME}" || true
}

# drive version 530 需要修改下, 字段的位置改变了。
pushgateway530(){
	runtime_info=$(nvidia-smi |grep -A 1 "NVIDIA GeForce" |tail -n 1)
	temp=$(echo "$runtime_info" | awk '{print $3}')
	# 去掉温度符号
	temp=${temp%C}

	#功耗 
	power_usage=$(echo "$runtime_info" | awk '{print $5}')
	power_usage=${power_usage%W}

	power_cap=$(echo "$runtime_info" | awk '{print $7}')
	power_cap=${power_cap%|}
	power_cap=${power_cap%W}
	
	memory_usage=$(echo "$runtime_info" | awk '{print $8}')
	memory_usage=${memory_usage%MiB}
	
	memory_total=$(echo "$runtime_info" | awk '{print $10}')
	memory_total=${memory_total%MiB}
	
	gpu_usage=$(echo "$runtime_info" | awk '{print $12}')
	gpu_usage=${gpu_usage%\%}
	
context="
gpu_nvidia_temp $temp
gpu_nvidia_power_usage $power_usage
gpu_nvidia_power_cap $power_cap
gpu_nvidia_memory_usage $memory_usage
gpu_nvidia_memory_total $memory_total
gpu_nvidia_usage $gpu_usage
"
	echo "$context" | curl -s --data-binary @- "${PUSHGATEWAY}/metrics/job/${MY_JOB}/nodename/${NODENAME}" || true
}

#pushgateway;exit 0

while :
do
	pushgateway 
	if [ $? -eq 0 ];then
		#echo "$context"
		:
	else
		echo "出问题了..."
		break
	fi
	sleep 5
done
