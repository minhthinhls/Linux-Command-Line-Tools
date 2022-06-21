#!/bin/bash

####################################################################################################
###### REFERENCE: https://github.com/zokeber/terraform-ec2-centos7-docker/blob/HEAD/script.sh ######
####################################################################################################

####################################################################################################
########################### HOW TO RUN THIS FILE: > `bash -x -v pull.sh` ###########################
####################################################################################################

# Get Absolute Path of this file in Linux System.
FILE_PATH=$(readlink -f "$0");
# Get Project Directory of this file in Linux System
# REFERENCE: @see {@link https://unix.stackexchange.com/questions/351916/get-the-parent-directory-of-a-given-file}
PROJECT_PATH="${FILE_PATH%/*}";

# Force Pull
sudo git -C "$PROJECT_PATH" fetch;
sudo git -C "$PROJECT_PATH" checkout master;
sudo git -C "$PROJECT_PATH" reset --hard origin/master;
