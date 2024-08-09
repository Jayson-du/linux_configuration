#!/bin/bash

file="CMakeLists.txt"
pattern="add_subdirectory("
debug="set(CMAKE_BUILD_TYPE Debug)"

# 使用 sed 插入新文本，并将结果保存到临时文件，然后替换原文件
# 0,/$pattern/ 限定范围为从文件开始到第一次匹配 pattern 的行;
# /pattern/i\ new_text 在匹配的行之前插入 new_text
# b 命令跳转到脚本的末尾，终止对后续匹配的处理
# ":a; n; ba"
#   :a 是定义一个标签
#   n 命令用于读取下一行
#   ba 命令跳转回标签 a，继续处理后续行
sed -e "0,/$pattern/ {/$pattern/i\\
$debug
b;}" -e ":a; n; ba" "$file" > "${file}".tmp && mv "${file}.tmp" "$file"


cmake -B build -S ./ -G "Ninja" && cmake --build ./build