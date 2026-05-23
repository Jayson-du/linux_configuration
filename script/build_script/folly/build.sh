#!/usr/bin/bash
./build.sh --allow-system-packages   --extra-cmake-defines '{"CMAKE_EXE_LINKER_FLAGS":"-ltbb","CMAKE_EXPORT_COMPILE_COMMANDS":"ON"}'
