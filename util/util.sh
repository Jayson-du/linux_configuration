#!/usr/bin/env bash

# 组件脚本

# -* 安装软件函数 *-

# 获取当前脚本的路径
project=${1}

# 获取颜色输出
source $project/color/color_print.sh

function check_apps_need_install() {
  local app_name=$1
  normal_log "check $app_name..."

  if command -v "$app_name" > /dev/null 2>&1; then
    normal_log "$app_name is already installed."
    return 0   # 已安装
  else
    normal_log "$app_name is not installed."
    return 1   # 未安装
  fi
}

function install_app_dict() {
  declare -n apps_dict=$1

  for app in "${!apps_dict[@]}"; do
    normal_log "checking ${app} has already installed..."
    check_apps_need_install $app
    result=$?
    if [ "${result}" = 1 ]; then
      normal_log "Proceeding with installation of $app..."
      # 安装需要的软件
      normal_log "sudo apt-get install -y $app"
      sudo apt-get install ${apps_dict[$app]} -y
    else
      normal_log "$app is already installed, skipping."
    fi
  done
}

function check_lib_need_installed() {
  local lib_array=("$@")

  for lib in "${lib_array[@]}"; do

    result=$(dpkg -l $lib 2>&1 | awk '{print $2, $3}')

    if [ "$result" = "no packages" ]; then
      return 1
    else
      return 0
    fi

  done
}

function install_lib_array() {
  local lib_array=("$@")

  for lib in "${lib_array[@]}"; do
    normal_log "check $lib has already installed ..."
    check_lib_need_installed ${lib}
    result=$?
    if [ "$result" = 1 ]; then
      normal_log "Proceeding with installation of $lib..."
      # 安装需要的软件
      normal_log "sudo apt-get install -y $lib"
      sudo apt-get install ${app} -y
    else
      normal_log "$lib is already installed, skipping..."
    fi
  done
}

function install_miniconda() {
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -P ~/apps/backup

  bash ~/apps/backup/Miniconda3-latest-Linux-x86_64.sh
}

# -* 检测网络 *-
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

# -* 创建常用目录 *-
function create_env_folder() {
  # 创建apps路径
  if [ ! -d "~/apps" ]; then
    mkdir ~/apps
  fi

  # 创建'github'路径
  if [ ! -d "~/github" ]; then
    mkdir ~/github
  fi

  # 创建'jayson'路径
  if [ ! -d "~/jayson" ]; then
    mkdir ~/jayson
  fi
}

# -* 配置bashrc *-
function config_bashrc() {
  # 查看是否已经设置过bashrc了
  if ( egrep -Hnir "# jayson custom config" ~/.bashrc ); then
    normal_log "has configed bashrc"
    return
  fi

  # 使PS1只显示当前路径
  sed -i '/PS1/s/\\w/\\W/g' ~/.bashrc

  sed -i '$a\
\
# jayson custom config\
alias buildscript="bash /home/jayson/jayson/linux_configuration/envs/touch_exe/exec_build.sh \$1"\
alias execscript="bash /home/jayson/jayson/linux_configuration/envs/touch_exe/exec.sh \$1 \$2"\
\
source /home/jayson/jayson/linux_configuration/envs/path_alias/path_alias
' ~/.bashrc
}

# -* 配置git *-
function config_git() {

  normal_log "配置git"

  git_config_name=$(git config --list | grep name | awk -F [=] '{printf $2}')
  git_config_email=$(git config --list | grep email | awk -F [=] '{printf $2}')
  git_config_editor=$(git config --list | grep editor | awk -F [=] '{printf $2}')

  if [ ! "$git_config_name" = "jayson" ]; then
    git config --global user.name "jayson"
  fi

  if [ ! "$git_config_email" = "315843093@qq.com" ]; then
    git config --global user.email "315843093@qq.com"
  fi

  if [ ! "$git_config_editor" = "vim" ]; then
    git config --global core.editor "vim"
  fi

  normal_log "配置git完成"
}

# -* 配置vim *-
function config_vim() {
  normal_log "配置vim"

  if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  fi

  cp ${current_path}/vimrc/vimrc.txt ~/.vimrc
  vim +PluginInstall +qall
  normal_log "配置vim完成"
}
