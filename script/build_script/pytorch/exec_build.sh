#!/usr/bin/bash

# git clone https://github.com/ROCm/pytorch.git

# cd pytorch

# 获取项目路径
path=$(cd $(dirname "$0") && pwd)

# 获取项目名称
project_name=$(echo $path | awk -F '/' '{print $(NF)}')

git checkout v2.9.0-rc4

git submodule sync
git submodule update --init --recursive

export PYTORCH_ROCM_ARCH="gfx1201"

# 1. 设置 ROCm 根目录
export ROCM_PATH=/home/jayson/rocm-all-libs-build/rocm-install

export ROCM_PATH_BIN=/home/jayson/rocm-all-libs-build/rocm-install/bin

# 2. 更新 PATH 以包含 hipcc, rocminfo 等工具
export PATH=$ROCM_PATH_BIN:$PATH

# 3. 更新库路径 (运行时和链接时需要)
export LD_LIBRARY_PATH=$ROCM_PATH/lib:$LD_LIBRARY_PATH

# 4. 更新头文件路径 (编译时需要)
export CPLUS_INCLUDE_PATH=$ROCM_PATH/include/roctracer:$ROCM_PATH/include:$CPLUS_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$CPLUS_INCLUDE_PATH

# 5. 帮助 CMake 找到你的 ROCm 包
export CMAKE_PREFIX_PATH=$ROCM_PATH:$CMAKE_PREFIX_PATH

# 6. 显式告诉 PyTorch 使用 ROCm 构建
export USE_ROCM=1

export DEBUG=1 # 关闭调试模式以加快构建速度
export USE_LLD=1 # 使用 lld 链接器加速链接

pip install -r requirements.txt
pip install cmake ninja mkl mkl-include


# 判断是否需要清理
echo -n "是否需要完全清理上次构建的${project_name}(yes/no): "
read -r answer

case "$answer" in
    yes)
        echo "Cleaning..."
        echo "python setup.py clean"
        python setup.py clean
        ;;
    no)
        echo "Cancelled."
        ;;
    *)
        echo "Invalid input."
        ;;
esac

# 限制并行编译作业数，防止内存耗尽 (根据你的 CPU 核心和内存调整，例如 16 或 32)
export MAX_JOBS=4

# 开始安装
python setup.py install