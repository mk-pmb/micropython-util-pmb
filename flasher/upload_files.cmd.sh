#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpfcmd_upload_files () {
  local REPL_LANG="${MPF_REPL_LANG:-py}"
  local REPL_MODE="${MPF_REPL_MODE:-raw}"

  local ARG= DEST_DIR='/' DEST_FN=
  case "$REPL_LANG" in
    lua ) DEST_DIR='/FLASH/';;
  esac

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
  echo -n "D: upload: $SRC_FN -> $DEST_ABS: prepare… "

  local DATA_WRAP=0
  case "$REPL_LANG" in
    lua )
      # @2020-08-22: REPL of firmware built from latest dev branch seems to
      #   have a limit of 255 bytes per input line.
      DATA_WRAP=248;;
  esac

  local DATA_B64="$(base64 --wrap=$DATA_WRAP -- "$SRC_FN")"
  [ -n "$DATA_B64" ] || return 3$(
    echo "E: $FUNCNAME: failed to read source file: $SRC_FN" >&2)

  local DEST_PY="'$DEST_ABS'"
  case "$DEST_ABS" in
    *[^A-Za-z0-9_./-]* )
      DEST_PY="unb64('$(echo -n "$DEST_ABS" | base64 --wrap=0)')";;
  esac

  local MP_CODE=
  case "$REPL_LANG" in
    py )
      MP_CODE="
        from ubinascii import a2b_base64 as unb64;
        fh = open($DEST_PY, 'w');
        fh.write(unb64('$DATA_B64'));
        fh.flush();
        fh.close();
        "
      ;;

    lua )
      MP_CODE="
        local unb64 = encoder.fromBase64;
        print(assert(file.putcontents($DEST_PY, unb64(
        ¶  '${DATA_B64//$'\n'/\'¶  ..\'}'¶  ))
          and ('file bytes: %s free + %s used
          = %s total'):format(file.fsinfo())));
        "
      ;;

    * )
      echo "E: unsupported REPL language: '$MPF_REPL_LANG'" >&2
      return 3;;
  esac
  MP_CODE="$(<<<"$MP_CODE" tr '\n' '\r' | sed -re 's~(^|\r)\s+~ ~g')"
  MP_CODE="${MP_CODE# }"
  MP_CODE="${MP_CODE% }"
  MP_CODE="${MP_CODE// ¶/$'\n'}"
  MP_CODE="${MP_CODE//¶/$'\n'}"

  if [ "$DBGLV" -ge 4 ]; then
    <<<"$MP_CODE" sed -re 's~^~‹~;s~$~›~' | nl -ba
    return 0
  fi

  mpf_verify_tty_usage idle || return $?
  echo 'send!'
  <<<"$MP_CODE" mpf_ersatz_slowcat \
    | mpf_communicate "$REPL_MODE" duplex || return $?
  DEST_FN=
}









[ "$1" == --lib ] && return 0; mpfcmd_setup_wifi "$@"; exit $?
