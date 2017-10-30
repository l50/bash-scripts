#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# clearHistory.sh
#
# Clear history for an OS running bash or zsh.
#
# Usage: bash clearHistory.sh
#
# Author: Jayson Grace, jayson.e.grace@gmail.com, 8/16/2017
# ----------------------------------------------------------------------------

checkShell()
{
  if [[ $# -eq 0 ]]; then
    echo "No shell type specified, try again."
    exit
  fi
}

if [[ $1 = "bash" ]]; then
  cat /dev/null > ~/.bash_history && history -c && exit
elif [[ $1 = "zsh" ]]; then
  rm $HISTFILE
fi
logout

checkShell
