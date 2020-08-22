#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpf_esptool () {
  echo 'D: Verifying serial port…'
  mpf_verify_tty_usage idle || return $?
  local FLASH_OPTS=(
    --port "${CFG[tty]}"
    --baud "${CFG[baudrate]}"
    )
  SECONDS=0
  "${CFG[esptool_cmd]}" "${FLASH_OPTS[@]}" "$@"
  local FLASH_RV=$?
  echo "D: Flashing took about $SECONDS sec, rv=$FLASH_RV" >&2
  return "$FLASH_RV"
}



return 0
