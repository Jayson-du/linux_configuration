#!/usr/bin/env bash
# -*- coding : utf-8 -*-

# 获取当前脚本的路径
current_path="$(cd $(dirname $0) && pwd)"

# 获取颜色输出
source $current_path/color/color_print.sh
source $current_path/util/util.sh

normal_log "\e[0;32m***自动化初始Linux开发环境***\e[1;32m"

check_network
if [ $? -eq 1 ]; then
  warn "网路连接断开"
  exit -1
fi

success "网络连接正常"

# 安装需要的软件
# 应用程序字典
declare -A APPS_DICT=(
  ["cmake"]="cmake"
  ["ctags"]="universal-ctags"
  ["cscope"]="cscope"
  ["gcc"]="gcc"
  ["g++"]="g++"
  ["gdb"]="gdb"
  ["ninja"]="ninja-build"
  ["git"]="git"
  ["tig"]="tig"
  ["ifconfig"]="net-tools"
  ["htop"]="htop"
  ["clang"]="clang"
  ["expect"]="expect"
  ["tmux"]="tmux"
  ["clangd"]="clangd"
  ["nvim"]="neovim"
)

# 包数组
LIB_ARRAY=(
  python3-dev
  default-jre
  default-jdk
  gcc-multilib
  g++-multilib
  graphviz
)

# 安装程序
install_app_dict APPS_DICT

# 安装包
install_lib_array "${LIB_ARRAY[@]}"

# 配置bashrc
config_bashrc

# install_miniconda