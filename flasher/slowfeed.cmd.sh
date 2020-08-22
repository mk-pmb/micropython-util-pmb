#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpfcmd_slowfeed () {
  local REPL_MODE="$1"; shift
  local IO_MODE="$1"; shift
  cat -- "$@" | mpf_ersatz_slowcat "$MPF_LINE_DELAY" \
    | mpf_communicate "$REPL_MODE" "$IO_MODE" || return $?
}



return 0
