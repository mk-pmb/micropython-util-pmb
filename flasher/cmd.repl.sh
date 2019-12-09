#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpfcmd_repl () {
  local USS_OPTS=(
    --device="${CFG[tty]}"
    --baud="${CFG[baudrate]}"
    --verbatim
    --devopt=crnl
    READLINE
    )
  [ "$MPF_REPL_HINTS" == no ] || echo "H: If you don't see a propmpt,"\
    "try pressing enter. For the initial greeting, reboot your NodeMCU."
  usb-serialport-socat "${USS_OPTS[@]}" || return $?
}



return 0
