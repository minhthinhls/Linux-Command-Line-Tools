#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Git aliases.
# ----------------------------------------------------------------------------------------------------------------------------------------------------

alias gc="git checkout ";
alias gcm="git checkout master";
alias gs="git status";
alias gp="git pull";
alias gf="git fetch";
alias gfa="git fetch --all";
alias gfo="git fetch origin";
alias gpush="git push";
# alias gpushf="git push --force";
alias gd="git diff";
alias gds="git diff --stat";
alias ga="git add .";
alias gl="git log";
alias gb="git branch";
alias gbr="git branch remote";
alias gru="git remote update";
alias gbn="git checkout -B ";
alias grf="git reflog";
# alias grh="git reset HEAD~"; # last commit hard
alias gac="git add . && git commit -a -m ";
alias gpsu="git gpush --set-upstream origin ";
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches";
