#!/usr/bin/bash

path=$(cd $(dirname $0)&& pwd)
source ${path}/../../color/color_print.sh

if [ $# -gt 0 ]; then
  path=$1

  if [ ! -d $path ]; then
    echo "Directory $path does not exist."
    exit
  fi

  shift 1
  name=$1
  if [ "$name" = "" ]; then
    name="exec"
  fi

  success "Creating executable script ${name}.sh in directory ${path}"
  touch ${path}/${name}.sh && chmod +x ${path}/${name}.sh && echo "#!/usr/bin/bash" >>${path}/${name}.sh
else
  error "No directory path provided."
fi