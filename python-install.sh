#!/bin/bash

####################################################################################################
###### REFERENCE: https://github.com/zokeber/terraform-ec2-centos7-docker/blob/HEAD/script.sh ######
####################################################################################################

sudo yum remove --assumeyes \
     python2                \
     python2-pip            ;

sudo yum remove --assumeyes \
     python3                \
     python3-pip            ;

sudo yum install --assumeyes \
     python2                 \
     python2-pip             ;

sudo yum install --assumeyes \
     python3                 \
     python3-pip             ;

alias pi="pip3";
alias py="python3";
alias py3="python3";
alias py2="python2";
