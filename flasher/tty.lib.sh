#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpf_verify_tty_usage () {
  local EXPECT="$1"
  local TTY="${CFG[tty]}"
  case "$TTY" in
    /dev/fd/* | \
    /dev/stdout | /dev/stderr ) return 0;;
  esac
  [ -c "$TTY" ] || return 4$(
    echo "E: selected serial port is not a character device: $TTY" >&2)
  case "$EXPECT" in
    idle )
      if fuser --verbose "$TTY" 2>&1; then
        echo "E: flinching: TTY seems to be in use: $TTY" >&2
        return 2
      else
        return 0
      fi;;
    watched )
      fuser --silent "$TTY" && return 0
      echo "E: flinching: TTY not in use, please watch it: $TTY" >&2
      return 2;;
  esac
  echo "E: $FUNCNAME: unsupported expectation: '$EXPECT'" >&2
  return 3
}


function mpf_communicate () {
  local REPL_MODE="$1"; shift
  local IO_MODE="$1"; shift
  local TTY="${CFG[tty]}"
  local SERIAL_CMD=(
    usb-serialport-socat
    --device="$TTY"
    --baud="${CFG[baudrate]}"
    --verbatim
    --devopt=crnl
  )

  [ "${CFG[baudrate]}" == - ] && SERIAL_CMD=( socat GOPEN:"$TTY" )

  case "$IO_MODE" in
    send ) IO_MODE=STDIN;;
    watch ) IO_MODE=STDOUT;;
    duplex ) IO_MODE=STDIO;;
    duplex+readline ) IO_MODE=READLINE;;
    * )
      echo "E: $FUNCNAME: unsupported communication mode: '$IO_MODE'" >&2
      return 3;;
  esac
  SERIAL_CMD+=( "$IO_MODE" )

  case "$REPL_MODE" in
    keep ) REPL_MODE=;;
    raw ) REPL_MODE=$'\x01';;  # Ctrl+A
    normal ) REPL_MODE=$'\x02';;  # Ctrl+B
    * )
      echo "E: $FUNCNAME: unsupported REPL mode: '$REPL_MODE'" >&2
      return 3;;
  esac
  if [ -n "$REPL_MODE" ]; then
    echo $'\r\n\r\n'"$REPL_MODE"$'\r' >>"$TTY" || return $?
    sleep 0.2s
  fi

  "${SERIAL_CMD[@]}" || return $?
}


function mpf_ersatz_slowcat () {
  local DELAY="${1:-0.2s}"
  local LN=
  while IFS= read -r LN; do
    echo "$LN"
    sleep "$DELAY" || return $?
    # last action should be a sleep, so we have
    # a chance to see a reply in duplex mode.
  done
}














return 0
