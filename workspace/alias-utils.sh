#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Git aliases.
# ----------------------------------------------------------------------------------------------------------------------------------------------------

###############################################
##### User specific aliases and functions #####
###############################################

# Clear Screen.
alias cs="clear; clear";
alias cls="clear; clear";
alias clr="clear; clear";
alias clrs="clear; clear";

# System Control Plane.
alias ctrl-enable="sudo systemctl enable";
alias ctrl-disable="sudo systemctl disable";
alias ctrl-status="sudo systemctl status";
alias ctrl-start="sudo systemctl start";
alias ctrl-stop="sudo systemctl stop";
alias ctrl-restart="sudo systemctl restart";
alias ctrl-reload="sudo systemctl reload";

# Alias [COMMAND] to Clear Screen & History;
alias clear-history="clear; clear && cat /dev/null > ~/.bash_history && history -c";

# Exit [COMMAND] [TERMINAL] with flushed Screen & History;
alias flush="clear; clear && cat /dev/null > ~/.bash_history && history -c && exit";

# Screen Manipulation.
alias sc="screen -ls";
# [COMMAND] > screen -rd <PID|SID>
alias rd="screen -rd";
# [COMMAND] > screen -S <NAME>
alias scr="screen -S";

# [COMMAND] > screen -L -Logfile <SESSION_NAME> -S <SESSION_NAME> [...OPTIONS]
function spawn_screens() {
  screen -h | grep Logfile &> /dev/null
  if [ $? == 0 ];
    then
      screen -L -Logfile "screen-$1.log" -S "$1";
    else
      screen -S "$@";
  fi
  unset -f spawn_screens;
  return 1;
};

# [COMMAND] > screen -X -S [...<PID|SID>] kill
function remove_screens() {
  for session in "$@"; do
    screen -X -S "${session}" quit;
  done;
  unset -f remove_screens;
  return 1;
};
