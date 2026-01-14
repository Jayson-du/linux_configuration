#!/usr/bin/env bash

path=$(cd $(dirname $0)&& pwd)

pip3 show triton 2>&1 1>/dev/null
if [ $? -eq 0 ]; then
    echo "Triton is already installed. Uninstalling..."
    pip3 uninstall -y triton
fi

export DEBUG=1
export MAX_JOBS=$(nproc)

pushd python
pip install -e "$path/python"
popd
