#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpfcmd_upload_files () {
  local ARG= DEST_DIR='/' DEST_FN=
  while [ "$#" -ge 1 ]; do
    ARG="$1"; shift
    case "$ARG" in
      '>' ) DEST_FN="$1"; shift; continue;;
      '>'*/ ) DEST_DIR="${ARG:1}"; continue;;
      '>'* ) DEST_FN="${ARG:1}"; continue;;
      */* ) mpfcmd_upload_files__up_one "$ARG";;
      * ) mpfcmd_upload_files__up_one "$ARG";;
    esac
  done
  echo "D: no more commands."
}


function mpfcmd_upload_files__up_one () {
  local SRC_FN="$1"
  local DEST_ABS="${DEST_DIR}${DEST_FN:-$SRC_FN}"
  local DATA_B64="$(base64 --wrap=0 -- "$SRC_FN")"
  [ -n "$DATA_B64" ] || return 3$(
    echo "E: $FUNCNAME: failed to read source file: $SRC_FN" >&2)

  local DEST_PY="'$DEST_ABS'"
  case "$DEST_ABS" in
    *[^A-Za-z0-9_./-]* )
      DEST_PY="unb64('$(echo -n "$DEST_ABS" | base64 --wrap=0)')";;
  esac

  local MP_CODE="
    from ubinascii import a2b_base64 as unb64
    fh = open($DEST_PY, 'w')
    fh.write(unb64('$DATA_B64'))
    fh.flush()
    fh.close()
    "
  MP_CODE="$(<<<"$MP_CODE" sed -re 's~^\s+~~;/^$/d')"
  MP_CODE="${MP_CODE//$'\n'/; }"
  mpf_verify_tty_usage idle || return $?
  echo "D: upload $SRC_FN -> $DEST_ABS"
  <<<"$MP_CODE" mpf_communicate raw duplex || return $?
  DEST_FN=
}









[ "$1" == --lib ] && return 0; mpfcmd_setup_wifi "$@"; exit $?
