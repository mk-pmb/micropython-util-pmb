#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpf_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local MPF_PATH="$(readlink -m "$BASH_SOURCE"/..)"
  # cd -- "$MPF_PATH" || return $?
  local -A CFG=()
  local LIB=
  for LIB in "$MPF_PATH"/*.lib.sh; do
    source "$LIB" --lib || return $?
  done
  mpf_guess_config_basics || return $?
  source "$MPF_PATH/${1%%__*}".cmd.sh --lib || return $?
  mpfcmd_"$@" || return $?
}



mpf_main "$@"; exit $?
