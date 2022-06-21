#!/bin/bash

####################################################################################################
############## REFERENCE: https://www.ibm.com/cloud/blog/8-kubernetes-tips-and-tricks ##############
####################################################################################################

####################################################################################################
######################## HOW TO RUN THIS FILE: > `bash -x -v alias-drop.sh` ########################
####################################################################################################

# Make sure Login as Root [Super User]
sudo -s << HERE
  cd "$HOME";
HERE

#################################################
########### Step 1: Drop System Alias ###########
#################################################

# Removing All Alias.
unalias -a;

# Clear Screen.
unalias "cs" "clr" "cls" "clrs";

# Kubernetes Controller.
unalias "k8" "kc";

# Kubernetes Administrator.
unalias "ka" "kad";

cat <<EOF > ~/.bashrc

# .bashrc

# User specific aliases and functions
alias rm="rm -i";
alias cp="cp -i";
alias mv="mv -i";

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like SystemCTL auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
source < (kubectl completion bash);

EOF

# Dynamic Load Alias into Shell Session.
if [ -e "$HOME"/.bashrc ]; then
  source "$HOME"/.bashrc;
fi
