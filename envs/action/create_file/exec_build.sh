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

build=${1:-all}

while [[ $# -gt 0 ]]; do
  case "${1:-}" in
    -i)
    build="inc"
    shift
    ;;
    -a)
    build="all"
    shift
    ;;
    *)
    shift
    ;;
  esac
done

if [ "$build" == "inc" ]; then
  if [ ! -d "${path}/build" ]; then
    error "Build directory does not exist"
  fi
elif [ "$build" == "all" ]; then
  if [ -d "${path}/build" ] && [ -f "${path}/build/CMakeCache.txt" ]; then
      echo "del CMakeCache.txt"
      rm -f ${path}/build/CMakeCache.txt
  fi

  git submodule update --init --recursive

  cmake -B build                            \
        -DCMAKE_BUILD_TYPE=Debug            \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON  \
        -S ./                               \
        -GNinja
fi

cmake --build build -j 32
EOF
)

# 替换 $color_print_sh_path 为实际值
message="${message//\$color_print_sh_path/$color_print_sh_path}"

touch $1/exec_build.sh && chmod +x $1/exec_build.sh && echo "$message" > $1/exec_build.sh