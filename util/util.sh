#!/usr/bin/env bash

# 组件脚本

# -* 安装软件函数 *-

# 获取当前脚本的路径
# project 表示linux_configuration项目路径
project=${1}

echo "project path: ${project}"

# 必须传入当前Configuration路径参数
if [ -z "$project" ]; then
  echo -e "\e[0;31m *** 未传入当前Configuration脚本路径参数 ***\e[1;31m "
  exit 1
fi

# -* 获取颜色输出 *-
source $project/color/color_print.sh

# data表示数据盘路径, 如/home/jayson
# 也有可能~不是数据盘地址
data=$(echo $project | awk -F 'jayson/linux' '{print $1}' | sed 's|/$||')

success "---- 当前数据盘目录为: ${data} ----"

# 检测应用是否安装
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

# -* 安装应用函数 *-
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

# -* 检测库是否安装 *-
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

# -* 安装库 *-
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
      sudo apt-get install ${lib} -y
    else
      normal_log "$lib is already installed, skipping..."
    fi
  done
}

# -* 安装miniconda *-
function install_miniconda() {
  # 安装miniconda到$data/apps/miniconda3， 一般要将miniconda安装到数据盘
  # 否则使用默认路径 ~/miniconda3
  local install_path=${data:-~/miniconda3}/apps
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -P ${install_path}/backup
  bash ${install_path}/backup/Miniconda3-latest-Linux-x86_64.sh -b -p "$install_path/miniconda3"

  ${install_path}/miniconda3/bin/conda init
  conda create --name dlc python=3.12.12 -y
  conda activate dlc
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
source '${project}/envs/action/action_alias'\
\
source '${project}/envs/path_alias/path_alias'\
\
source '${project}/envs/export/export'\
conda activate tgi_test
' ~/.bashrc

source ~/.bashrc
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

  local current_path=$project

  if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  fi

  # 检查是否为 Neovim
  if command -v nvim >/dev/null 2>&1; then
    normal_log "检测到 Neovim，使用 Neovim 配置"
    mkdir -p ~/.config/nvim
    cp ${current_path}/vimrc/vimrc.txt ~/.config/nvim/init.vim
    nvim +PluginInstall +qall
  else
    cp ${current_path}/vimrc/vimrc.txt ~/.vimrc
    vim +PluginInstall +qall
  fi

  normal_log "配置vim完成"
}

# -* 配置自定义别名 *-
function config_path_alias() {
  normal_log "配置自定义别名"

  if [ ! -d "$project/envs/path_alias" ]; then
    normal_log "创建路径 $project/envs/path_alias"
    mkdir -p $project/envs/path_alias
  fi

  if [ -f $project/envs/path_alias/path_alias ]; then
      rm -f $project/envs/path_alias/path_alias
  fi

  echo "alias github='cd $data/github && ls'
alias jayson='cd $data/jayson && ls'
alias summary='cd $data/summary'
alias apps='cd $data/apps'
alias clash='cd $data/apps/clash && $data/apps/clash/clash -f $data/apps/clash/config.yaml'
alias mesa='cd $data/github/mesa'
alias mesa_main='cd $data/github/mesa_main'
alias practice='cd $data/practice'
alias amd_rocm='cd $data/rocm-all-libs-build'
" >> $project/envs/path_alias/path_alias

  normal_log "配置自定义别名完成"
}

# -* 配置自定义Action *-
function config_action_alias() {
  normal_log "配置自定义**Action**别名"

  if [ ! -d "$project/envs/action" ]; then
    normal_log "创建路径 $project/envs/action"
    mkdir -p $project/envs/action
  fi

  if [ -f $project/envs/action/action_alias ]; then
      rm -f $project/envs/action/action_alias
  fi

  echo "alias buildscript='bash ${project}/envs/action/create_file/exec_build.sh \$1'
alias execscript='bash ${project}/envs/action/create_file/exec.sh \$1 \$2'
alias torch_v='bash ${project}/envs/action/torch/torch_v.sh'
alias create_swapfile='bash ${project}/envs/action/create_swapfile/create_swapfile.sh'
alias check_gpu_info='python3 ${project}/envs/action/gpu_info/check_gpu_info.py'
alias jfind='python3 ${project}/envs/action/find/jayson_find.py'
alias battery='bash ${project}/envs/action/battery_capacity/battery_capacity.sh'
" >> $project/envs/action/action_alias

  echo "project=${project}" >> $project/envs/action/project
  normal_log "配置自定义**Action**别名完成"
}

# -* 配置ssh *-
function config_ssh() {
  normal_log "配置ssh"

  sudo systemctl enable ssh
  sudo systemctl start ssh
}

# -* 配置自定义Action *-
function config_export() {
  normal_log "配置自定义**环境变量**"

  if [ ! -d "$project/envs/export" ]; then
    normal_log "创建路径 $project/envs/export"
    mkdir -p $project/envs/export
  fi

  echo "export JAYSON_PROJECT=${project}
" >> $project/envs/export/export

  normal_log "配置自定义**环境变量**完成"
}

# -* 配置ssh *-
function config_ssh() {
  normal_log "配置ssh"

  sudo systemctl enable ssh
  sudo systemctl start ssh
}

