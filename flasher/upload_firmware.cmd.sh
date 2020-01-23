#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpfcmd_upload_firmware () {
  local SRC_IMG="${1:-$MPF_FIRMWARE}"
  [ -f "$SRC_IMG" ] || return 4$(
    echo "E: selected image file seems to not be a file: '$SRC_IMG'" >&2)

  local FLASH_MODES_PRIO=(
    # docs: https://github.com/espressif/esptool/wiki/SPI-Flash-Modes
    qio    # fastest
    qout   # ~15% slower
    dio    # ~45% slower
    dout   # ~50% slower
    )
  local FLASH_SLOWER="${MPF_SLOWER:-0}"
  local FLASH_MODE="${FLASH_MODES_PRIO[$FLASH_SLOWER]}"
  [ -n "$FLASH_MODE" ] || return 4$(
    echo "E: can't flash that much slower: there are just" \
      "${#FLASH_MODES_PRIO[@]} known speeds" >&2)

  mpf_verify_tty_usage idle || return $?
  SECONDS=0
  local FLASH_OPTS=(
    --port "${CFG[tty]}"
    --baud "${CFG[baudrate]}"
    write_flash
    --flash_mode="$FLASH_MODE"
    --flash_size=detect
    # --verify # <-- deprecated. modern esptool always verifies.
    "${MPF_OFFSET_BYTES:-0}"
    "$SRC_IMG"
    )
  "${CFG[esptool_cmd]}" "${FLASH_OPTS[@]}"
  local FLASH_RV=$?
  echo "D: Flashing took about $SECONDS sec, rv=$FLASH_RV" >&2

  if [ "$FLASH_RV" == 0 ]; then
    sed -re '/\S/!d;s~^( ?) *~H: \1~' <<<"
      If the firmware doesn't work, try
        * (if serial port) checking your baud rate settings on both sides.
        * manually rebooting your dev board.
        * erasing the entire flash before uploading a new firmware.
        * a slower flash mode. (currently, FLASH_SLOWER=$FLASH_SLOWER
      "
  fi
  return "$FLASH_RV"
}



return 0
