#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpfcmd_setup_wifi () {
  [ -n "$MPF_PATH" ] || local MPF_PATH="$(readlink -m "$BASH_SOURCE"/..)"
  local SETUP_CMD="$(grep -Pe '^\s*\w' -- "$MPF_PATH"/setup_wifi.basic.py)"
  local SETUP_ARGS=( ssid psk ip snm dgw dns )

  local -A WIFI=()
  local OPT= VAL=
  while [ "$#" -ge 1 ]; do
    OPT="$1"; shift
    case "$OPT" in
      nm_cfg )
        VAL="$1"; shift
        "${FUNCNAME}__${OPT}" "$VAL" || return $?;;
      psk_file )
        VAL="$(grep -m 1 -Pe '\S' -- "$VAL")"
        [ -n "$VAL" ] || return 4$(
          echo "E: unable to read WiFi PSK from file '$1'" >&2)
        WIFI[psk]="$VAL";;
      ssid | snm | dgw | dns )
        WIFI["$OPT"]="$1"; shift;;
      ip )
        VAL="$1"; shift
        case "$VAL" in
          *[a-z]* )
            WIFI[hostname]="$VAL"
            VAL="$("$FUNCNAME"__host2ip "$VAL")" || return $?
            ;;
        esac
        WIFI[ip]="$VAL";;
      * )
        echo "E: $FUNCNAME: unsupported option '$OPT'" >&2
        return 3;;
    esac
  done

  case "${WIFI[snm]}" in
    *.* ) ;;
    [0-9] | [0-3][0-9] )
      WIFI[snm]="$(mpfcmd_setup_wifi__pfxlen2snm "${WIFI[snm]}"
        )" || return $?;;
  esac

  SETUP_CMD+=$'\n\nsetup_wifi_basic'"$(
    for OPT in "${SETUP_ARGS[@]}"; do
      echo "${WIFI[$OPT]}"
    done | python3 -c 'from sys import stdin; print(repr(tuple(
      [ln.rstrip() for ln in stdin])))'
    )"

  mpf_verify_tty_usage idle || return $?
  echo "D: setup instructions will now be sent."
  <<<"$SETUP_CMD" mpf_communicate raw duplex || return $?
  echo "D: setup instructions have been sent."
}


function mpfcmd_setup_wifi__pfxlen2snm () {
  local SNM= BITS= BYTE=
  printf -v BITS '% *s%0*g' "$1" '' 32 0 || return $?
  BITS="${BITS// /1}"
  for BYTE in "${BITS:0:8}" "${BITS:8:8}" "${BITS:16:8}" "${BITS:24:8}"; do
    let BYTE="2#$BYTE"
    SNM+="$BYTE."
  done
  echo "${SNM%.}"
}


function mpfcmd_setup_wifi__host2ip () {
  sed -nrf <(echo '/^[0-9]/{
    s~#.*$~~
    s~\s+|$~ # ~g
    p
    }') -- /etc/hosts | grep -Fe "# $1 #" -m 1 | grep -oPe '^[\d\.]+'
}


function mpfcmd_setup_wifi__nm_cfg () {
  exec < <(sed -nrf <(echo '
    /^(ssid|psk)=/p
    s~[;,]~ ~g
    s~ +$~~
    s~^address(es|)[0-9]*=([0-9.]+) ([0-9.]+) ([0-9.]+|$\
      )$~ip=\2\nsnm=\3\ndgw=\4~p
    s~^(dns)[0-9]*(=[0-9.]+)( .*|)$~\1\2~p
    ') -- "$1")
  local LN=
  while read -r LN; do
    [ -n "$LN" ] || continue
    WIFI["${LN%%=*}"]="${LN#*=}"
  done
}








[ "$1" == --lib ] && return 0; mpfcmd_setup_wifi "$@"; exit $?
