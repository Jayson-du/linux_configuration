#!/usr/bin/bash
# -*- coding : utf-8 -*-

echo -e "\e[0;32m***自动化初始Linux开发环境***\e[1;32m"

curr_path="$(cd $(dirname $0) && pwd)"

# 创建env目录, 用于存放常用脚本
function create_env_folder() {
  if [ ! -d "~/env" ]; then
    mkdir ~/env/ && mkdir ~/env/color
  fi

  if [ ! -f "~/env/color/color_print.sh" ]; then
    cp ${curr_path}/color_print.sh ~/env/shell_script/
  fi

  source ~/env/shell_script/color_print.sh
}

# 检测网络
function check_network() {
  # 超时时间
  local timeout=1

  # 目标网站
  local target=www.baidu.com

  # 获取响应状态码
  ret_code=$(curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1)

  if [ "x$ret_code" = "x200" ]; then
    # 网络连接正常
    return 0
  else
    # 网络连接断开
    return -1
  fi

  return -1
}

create_env_folder

check_network
if [ $? -eq 1 ]; then
  warn "网路连接断开"
  exit -1
fi

success "网络连接正常"

# 安装需要的软件
APPS_ARRAY=(cmake
  universal-ctags
  cscope
  gcc
  g++
  gcc-multilib
  g++-multilib
  gdb
  ninja-build
  graphviz
  git
  tig
  net-tools
  default-jre
  default-jdk
  htop
  clang
  expect
  python3-dev
  tmux
)

for i in ${APPS_ARRAY[@]}; do
  sudo apt-get install $i -y
done

# 配置git
normal_log "配置git"
git config --global user.name "jayson"
git config --global user.email "315843093@qq.com"
git config --global core.editor "vim"
normal_log "配置git完成"

# 配置vim插件
normal_log "配置vim"
cp ${curr_path}/vimrc/vimrc.txt ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qll
normal_log "配置vim完成"