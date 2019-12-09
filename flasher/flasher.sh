#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpf_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  # cd -- "$SELFPATH" || return $?
  local -A CFG=()
  local LIB=
  for LIB in "$SELFPATH"/mpf_*.sh; do
    source "$LIB" --lib || return $?
  done
  mpf_guess_config_basics || return $?
  source cmd."$1".sh || return $?
  mpfcmd_"$@" || return $?
}



mpf_main "$@"; exit $?
