#!/bin/bash

####################################################################################################
############## REFERENCE: https://www.ibm.com/cloud/blog/8-kubernetes-tips-and-tricks ##############
####################################################################################################

####################################################################################################
####################### HOW TO RUN THIS FILE: > `bash -x -v alias-create.sh` #######################
####################################################################################################

# Make sure Login as Root [Super User]
sudo -s << HERE
  cd "$HOME";
HERE

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Get Absolute Path of this file in Linux System.
# @see {@link https://unix.stackexchange.com/questions/351916/get-the-parent-directory-of-a-given-file/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
FILE_PATH=$(readlink -f "$0");

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Get Parent Directory of this file in Linux System.
# @see {@link https://unix.stackexchange.com/questions/351916/get-the-parent-directory-of-a-given-file/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
FOLDER_PATH="${FILE_PATH%/*}";

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Get Project Directory of this file in Linux System.
# @see {@link https://unix.stackexchange.com/questions/351916/get-the-parent-directory-of-a-given-file/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
PROJECT_PATH="${FOLDER_PATH%/*}";

#################################################
######### Step 1: Setting System Alias ##########
#################################################

# Basic Linux Command.
sudo alias       \
     copy="cp"   ;

# Clear Screen.
sudo alias       \
     cs="clear"  \
     cls="clear" \
     clr="clear" \
     clrs="clear";

# Kubernetes Controller.
sudo alias        \
     k8="kubectl" \
     kc="kubectl" ;

# Kubernetes Administrator.
sudo alias         \
     ka="kubeadm"  \
     kad="kubeadm" ;

# @see {@link https://superuser.com/questions/303602/how-can-i-view-more-of-my-history-in-screen-on-linux}
cat << EOF > ~/.screenrc

# Set Logging as Default
deflog on

# Set maximum Buffer to 100.000 Bytes.
defscrollback 100000;

# Allow PuTTY and MobaXTerm to resolved console.
termcapinfo xterm* ti@:te@;

EOF

# Enable Ingress Layer within K8s Cluster System.
until cp -rf "$PROJECT_PATH"/workspace/.bashrc "$HOME"/.bashrc; do
  printf '.';
  sleep 1;
done;

# Dynamic Load Alias into Shell Session.
if [ -e "$HOME"/.bashrc ]; then
  source "$HOME"/.bashrc;
fi;
