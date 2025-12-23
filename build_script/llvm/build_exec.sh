#!/usr/bin/bash

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

