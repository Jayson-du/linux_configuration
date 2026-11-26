#!/usr/bin/bash

# 输出简单的脚本内容
message=$(
  cat <<'EOF'
##########################
# gdb debug scription
##########################

##########################
# debug file, for example:
# file ./build/bin/exec_file
##########################


##########################
# input parameters, for example:
# set args ./inputfile
##########################

##########################
# breakpoint, for example:
# set breakpoint pending on
# b test.c:10
##########################

##########################
# run, for example:
# run
##########################
EOF
)

touch $1/gdb.debug && echo "$message" >$1/gdb.debug
