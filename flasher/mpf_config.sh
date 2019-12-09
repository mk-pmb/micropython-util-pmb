#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpf_guess_config_basics () {
  CFG[baudrate]="${MPF_BAUD:-115200}"

  local DEST_TTY="${MPF_TTY:-0}"
  case "$DEST_TTY" in
    [0-9]* ) DEST_TTY="/dev/ttyUSB$DEST_TTY";;
  esac
  [ -c "$DEST_TTY" ] || return 4$(
    echo "E: selected serial port is not a character device: $DEST_TTY" >&2)
  CFG[tty]="$DEST_TTY"

  CFG[esptool_cmd]="${MPF_ESPTOOL:-esptool.py}"
  which "${CFG[esptool_cmd]}" |& grep -qPe '^/' -m 1 || return 4$(
    echo "E: esptool.py not found. Try: sudo -E pip install --upgrade pip &&"\
      "sudo -E pip install esptool" >&2)
}


function mpf_verify_tty_usage () {
  local EXPECT="$1"
  case "$EXPECT" in
    idle )
      if fuser --verbose "${CFG[tty]}" 2>&1; then
        echo "E: flinching: TTY seems to be in use: ${CFG[tty]}" >&2
        return 2
      else
        return 0
      fi;;
    watched )
      fuser --silent "${CFG[tty]}" && return 0
      echo "E: flinching: TTY not in use, please watch it: ${CFG[tty]}" >&2
      return 2;;
  esac
  echo "E: $FUNCNAME: unsupported expectation: '$EXPECT'" >&2
  return 3
}


return 0
