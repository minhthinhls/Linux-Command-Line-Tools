#!/bin/bash

############################################################################################
####################### HOW TO RUN THIS FILE: > `bash -x -v init.sh` #######################
############################################################################################

###########################################################
##### @description - Github Personal Access Token #########
##### @see {@link https://github.com/settings/tokens} #####
###########################################################
TOKEN=ghp_vxZTbKM4YHMBQhQGEXA9CABKUNWVKl42oE8S
PROJECT="Linux-Command-Line-Tools"

git clone "https://$TOKEN@github.com/minhthinhls/$PROJECT.git" "$HOME/$PROJECT";

git push --force --set-upstream origin master;

bash "$HOME"/"$PROJECT"/workspace/alias-create.sh;

source "$HOME"/.bashrc;
