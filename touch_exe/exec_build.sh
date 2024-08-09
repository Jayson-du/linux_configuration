#!/usr/bin/bash

source ~/env/color/color_print.sh

blue_log "create a simple build scription in ${1}"

touch $1/exec_build.sh && chmod +x $1/exec_build.sh

echo "#!/usr/bin/bash

path="$(cd $(dirname $0) && pwd)"

if [ -d "${path}/build" ]; then
    rm -f ${path}/build/CMakeCache.txt
fi

cmake -B build                    \\
      -DCMAKE_BUILD_TYPE=Debug    \\
      -S ./                       \\
      -GNinja

cmake --build build" > $1/exec_build.sh
