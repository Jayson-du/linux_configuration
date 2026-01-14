#!/usr/bin/env bash

path=$(cd $(dirname $0)&& pwd)

pip3 show triton 2>/dev/null 1>/dev/null
if [ $? -eq 0 ]; then
    echo "Triton is already installed. Uninstalling..."
    pip3 uninstall -y triton
fi

export DEBUG=1
export MAX_JOBS=$(nproc)

# 新增这一行
export TRITON_BUILD_CMAKE_ARGS="-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

figlet -f big "BUILD TRITON" | lolcat | cowsay -n -f tux

pushd python
pip install -e $path/
popd

# echo "Searching for compile_commands.json..."
# find python/build -name "compile_commands.json" -exec ln -sf {} compile_commands.json \; -print -quit

# 在 triton 根目录下
mkdir -p build-debug
cd build-debug
cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DLLVM_DIR=/home/dute/github/LLVM/build/lib/cmake/llvm \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-13.1 \
    -DTRITON_BUILD_PYTHON_MODULE=ON \
    -Dpybind11_DIR=$PYBIND11_CMAKE_DIR \
    -DCUPTI_INCLUDE_DIR=/usr/local/cuda-13.1/extras/CUPTI/include \
    -DROCTRACER_INCLUDE_DIR="" \
    -DJSON_INCLUDE_DIR=/usr/include

# 将生成的 compile_commands.json 覆盖根目录那个
ln -sf $PWD/compile_commands.json ../compile_commands.json