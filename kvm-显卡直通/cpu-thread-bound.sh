#!/bin/bash

# 定义一个关联数组来存储物理核心到逻辑CPU的映射
# declare -A 声明一个关联数组，需要Bash 4+版本
declare -A CORE_MAP

# 逐行读取 /proc/cpuinfo
while IFS= read -r line; do
    # 提取 processor ID
    if [[ $line =~ ^processor[[:space:]]+:[[:space:]]+([0-9]+)$ ]]; then
        processor_id=${BASH_REMATCH[1]}
    fi

    # 提取 core ID
    if [[ $line =~ ^core[[:space:]]+id[[:space:]]+:[[:space:]]+([0-9]+)$ ]]; then
        core_id=${BASH_REMATCH[1]}
        # 将当前的 processor ID 添加到对应 core ID 的列表中
        CORE_MAP["$core_id"]+=" $processor_id"
    fi

    # 当遇到空行时，表示一个CPU的描述结束，重置 processor_id 和 core_id
    # 这不是严格必要的，因为processor和core id会立即更新，但可以帮助理解解析流程
    # if [[ -z "$line" ]]; then
    #     processor_id=""
    #     core_id=""
    # fi

done < /proc/cpuinfo

echo "--- 物理核心与逻辑CPU对应关系 ---"

# 遍历关联数组，打印结果
for core_id in "${!CORE_MAP[@]}"; do
    # 对逻辑CPU ID进行排序，使其看起来更整洁
    sorted_processors=$(echo "${CORE_MAP["$core_id"]}" | tr ' ' '\n' | sort -n | tr '\n' ' ')
    echo "物理核心 ${core_id}: 逻辑CPU ${sorted_processors}"
done

echo "-----------------------------------"

