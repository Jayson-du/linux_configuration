#!/usr/bin/env bash

path="$(cd $(dirname $0) && pwd)"
source ${path}/../project
source ${project}/color/color_print.sh
color_print_sh_path="${project}/color/color_print.sh"

# 输出简单的脚本内容
message=$(cat << 'EOF'
#!/usr/bin/env bash
source "$color_print_sh_path"

path="$(cd $(dirname $0) && pwd)"

if [ ! -d "${path}/build" ]; then
    echo "del CMakeCache.txt"
    rm -f ${path}/build/CMakeCache.txt
fi

cmake -B build                            \
      -DCMAKE_BUILD_TYPE=Debug            \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON  \
      -S ./                               \
      -GNinja

cmake --build build
EOF
)

# 替换 $color_print_sh_path 为实际值
message="${message//\$color_print_sh_path/$color_print_sh_path}"

touch $1/exec_build.sh && chmod +x $1/exec_build.sh && echo "$message" > $1/exec_build.sh