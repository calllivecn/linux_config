#!/usr/bin/python
import subprocess
import json

def get_crypt_status():
    """ 
    检查所有 dm-crypt 设备的 allow_discards 状态
    """ 
    try:
        # 获取 dmsetup table 信息
        p = subprocess.run(['sudo', 'dmsetup', 'table'], text=True, check=True, capture_output=True)
        tables = p.stdout.strip().split('\n')
            
        print(f"{'Mapping Name':<20} | {'TRIM (Discard)':<15}")
        print("-" * 40) 
            
        for line in tables:
            parts = line.split()
            name = parts[0].strip(':')
            # 检查 table 中是否包含 allow_discards 标志
            has_discard = "✅ Enabled" if "allow_discards" in line else "❌ Disabled"
            print(f"{name:<20} | {has_discard}")
                
    except Exception as e:
        print(f"执行失败: {e}")

if __name__ == "__main__":
    get_crypt_status()
