#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function mpfcmd_repl () {
  [ "$MPF_REPL_HINTS" == no ] || echo "H: If you don't see a propmpt,"\
    "try pressing enter. For the initial greeting, reboot your NodeMCU."
  mpf_communicate normal duplex+readline || return $?
}



return 0
