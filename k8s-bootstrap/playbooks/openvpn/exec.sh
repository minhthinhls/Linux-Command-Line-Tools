#!/bin/bash

############################################################################################
####################### HOW TO RUN THIS FILE: > `bash -x -v exec.sh` #######################
############################################################################################

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
# shellcheck disable=SC2034
# ----------------------------------------------------------------------------------------------------------------------------------------------------
PROJECT_PATH="${FOLDER_PATH%/*}";

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Execute the Ansible Bootstrap Process via Bash Internal Process.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
sh <<EOF
cd $FOLDER_PATH ;
ansible-playbook --inventory hosts.yml index.yml ;
EOF
