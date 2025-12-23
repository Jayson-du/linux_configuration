#!/usr/bin/bash

# 判断当前机器的内存和交换分区大小，如果不足则创建一个32G的交换分区
memory_size=$(free -h | awk 'NR==2 {print $2}' | egrep -o '[0-9\.]+')
swap_size=$(free -h | awk 'NR==3 {print $2}' | cut -d'.' -f1)

if [ $swap_size -lt 32 ] && [ $memory_size -lt 64 ];then
  pushd $(pwd)

  # 进入根目录
  cd /

  # 1. 禁用当前 swap
  sudo swapoff /swapfile

  # 2. 删除旧文件
  sudo rm /swapfile

  # 3. 创建新的 32G swap 文件
  sudo fallocate -l 32G /swapfile

  # 4. 设置权限并启用
  sudo chmod 600 /swapfile

  # 5. 格式化为 swap 分区
  sudo mkswap /swapfile

  # 6. 启用 swap
  sudo swapon /swapfile

  popd
fi

path="$(cd $(dirname $0) && pwd)"

if [ -f "${path}/build/CMakeCache.txt" ]; then
    echo "del CMakeCache.txt"
    rm -f ${path}/build/CMakeCache.txt
fi

cmake -B build  \
      -S ./llvm \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                            \
      -DLLVM_ENABLE_PROJECTS="mlir;clang;openmp" \
      -DLLVM_TARGETS_TO_BUILD="host;RISCV;AMDGPU" \
      -DLLVM_ENABLE_ASSERTIONS=ON \
      -DLLVM_PARALLEL_COMPILE_JOBS=4 \
      -DLLVM_PARALLEL_LINK_JOBS=1 \
      -DOPENMP_ENABLE_LIBOMPTARGET=OFF \
      -DCMAKE_BUILD_TYPE=DEBUG \
      -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
      -DLLVM_USE_PREFIX_SYMBOLS=ON  \
      -DLLVM_INCLUDE_EXAMPLES=ON \
      -DPython3_EXECUTABLE=$(which python3)

pushd $path 1>/dev/null 2>/dev/null

cd build && make -j 4

popd 1>/dev/null 2>/dev/null

