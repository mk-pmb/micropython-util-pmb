#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpf_guess_config_basics () {
  CFG[baudrate]="${MPF_BAUD:-115200}"

  local DEST_TTY="${MPF_TTY:-0}"
  case "$DEST_TTY" in
    [0-9]* ) DEST_TTY="/dev/ttyUSB$DEST_TTY";;
    - )
      DEST_TTY='/dev/stdout'
      CFG[baudrate]=-
      ;;
  esac
  CFG[tty]="$DEST_TTY"

  CFG[esptool_cmd]="${MPF_ESPTOOL:-esptool.py}"
  which "${CFG[esptool_cmd]}" |& grep -qPe '^/' -m 1 || return 4$(
    echo "E: esptool.py not found. Try: sudo -E pip install --upgrade pip &&"\
      "sudo -E pip install esptool" >&2)
}


return 0
