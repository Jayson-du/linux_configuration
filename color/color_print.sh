#!/bin/bash
# -*- coding : utf-8 -*-

#====   Colorized variables  ====
if [[ -t 1 ]]; then # is terminal?
  BOLD="\e[1m";      DIM="\e[2m";
  RED="\e[0;31m";    RED_BOLD="\e[1;31m";
  YELLOW="\e[0;33m"; YELLOW_BOLD="\e[1;33m";
  GREEN="\e[0;32m";  GREEN_BOLD="\e[1;32m";
  BLUE="\e[0;34m";   BLUE_BOLD="\e[1;34m";
  GREY="\e[37m";     CYAN_BOLD="\e[1;36m";
  RESET="\e[0m";
fi

function title() { echo -e "${BLUE_BOLD}# ${1}${RESET}"; }

function start_log() { echo -e "\n${GREEN_BOLD} ${1} ${RESET}\n"; }

function finish() { echo -e "\n${GREEN_BOLD}# Finish!${RESET}\n"; exit 0; }

function userAbort() { echo -e "\n${YELLOW_BOLD}# Abort by user!${RESET}\n"; exit 0; }

function warn() { echo -e "${YELLOW_BOLD}  Warning: ${1} ${RESET}"; }

function success() { echo -e "${GREEN}  Success: ${1} ${RESET}"; }

function error() { echo -e "${RED_BOLD}  Error:   ${RED}$1${RESET}"; exit 1; }

function option() { echo -n -e "${GREEN_BOLD}${1}${Reset}"; }

function normal_log() { echo -e "${BLUE_BOLD}${1}${Reset}"; }

function fatal_log() { echo -e "${RED_BOLD}${1}${Reset}";  exit 0; }