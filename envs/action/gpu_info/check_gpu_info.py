#!/usr/bin/env python3
"""
显卡内存计算和监控脚本
用于计算 AMD Radeon RX 9070 XT (gfx1201) 的内存信息
"""

import torch
import psutil
import sys
from typing import Dict, Any

def format_bytes(bytes_value: int) -> str:
    """格式化字节数为人类可读的格式"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_value < 1024.0:
            return ".1f"
        bytes_value /= 1024.0
    return ".1f"

def get_gpu_memory_info(device_id: int) -> Dict[str, Any]:
    """获取指定GPU设备的内存信息"""
    try:
        props = torch.cuda.get_device_properties(device_id)
        total_memory = props.total_memory

        # 获取当前内存使用情况
        allocated = torch.cuda.memory_allocated(device_id)
        reserved = torch.cuda.memory_reserved(device_id)
        free_memory = total_memory - allocated

        # 获取L2缓存大小
        l2_cache = getattr(props, 'l2_cache_size', getattr(props, 'L2_cache_size', 0))

        return {
            'name': props.name,
            'total_memory': total_memory,
            'allocated': allocated,
            'reserved': reserved,
            'free_memory': free_memory,
            'l2_cache': l2_cache,
            'utilization': allocated / total_memory * 100 if total_memory > 0 else 0
        }
    except Exception as e:
        print(f"获取GPU {device_id} 信息失败: {e}")
        return None

def calculate_memory_breakdown(total_bytes: int) -> Dict[str, float]:
    """计算内存的各种单位表示"""
    return {
        'bytes': total_bytes,
        'kb': total_bytes / 1024,
        'mb': total_bytes / (1024 ** 2),
        'gb': total_bytes / (1024 ** 3)
    }

def main():
    print("=" * 60)
    print("显卡信息")
    print("=" * 60)

    # 检查CUDA是否可用
    if not torch.cuda.is_available():
        print("CUDA不可用, 无法获取显卡信息")
        sys.exit(1)

    device_count = torch.cuda.device_count()
    print(f"检测到 {device_count} 个CUDA设备\\n")

    # 显示每个GPU的详细信息
    for i in range(device_count):
        gpu_info = get_gpu_memory_info(i)
        if gpu_info is None:
            continue

        print(f"GPU {i}: {gpu_info['name']}")
        print("-" * 40)

        # 内存分解
        total_breakdown = calculate_memory_breakdown(gpu_info['total_memory'])
        allocated_breakdown = calculate_memory_breakdown(gpu_info['allocated'])
        free_breakdown = calculate_memory_breakdown(gpu_info['free_memory'])

        print(f"总内存: {total_breakdown['gb']:.2f} GB ({total_breakdown['bytes']:,} bytes)")
        print(f"已分配: {allocated_breakdown['mb']:.1f} MB ({allocated_breakdown['bytes']:,} bytes)")
        print(f"预留内存: {gpu_info['reserved'] / (1024**2):.1f} MB")
        print(f"可用内存: {free_breakdown['mb']:.1f} MB ({free_breakdown['bytes']:,} bytes)")
        print(f"内存利用率: {gpu_info['utilization']:.1f}%")

        if gpu_info['l2_cache'] > 0:
            l2_mb = gpu_info['l2_cache'] / (1024 ** 2)
            print(f"L2缓存: {l2_mb:.1f} MB")

        print()

    # 系统内存信息
    print("系统内存信息")
    print("-" * 20)
    system_memory = psutil.virtual_memory()
    print(f"系统总内存: {system_memory.total / (1024**3):.2f} GB")
    print(f"系统可用内存: {system_memory.available / (1024**3):.2f} GB")
    print(f"系统内存使用率: {system_memory.percent:.1f}%")

    # 计算建议
    print("\n内存使用建议:")
    print("-" * 20)
    for i in range(device_count):
        gpu_info = get_gpu_memory_info(i)
        if gpu_info and gpu_info['free_memory'] / gpu_info['total_memory'] < 0.1:
            print(f"警告: GPU {i} 可用内存不足10%")
        elif gpu_info and gpu_info['free_memory'] / gpu_info['total_memory'] > 0.8:
            print(f"GPU {i} 内存使用正常")

if __name__ == "__main__":
    main()