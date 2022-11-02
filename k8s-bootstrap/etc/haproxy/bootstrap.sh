#!/bin/bash
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @requirements: etckeeper, diffcolor
# @description: Dos2Unix when error ['\r' command not found] appear.
# @see {@link https://stackoverflow.com/questions/11616835/r-command-not-found-bashrc-bash-profile#11617204}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# dnf install --assumeyes epel-release dot2unix etckeeper colordiff ;
# dos2unix /root/Linux-Command-Line-Tools/k8s-bootstrap/etc/haproxy/bootstrap.sh ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description:
# @see {@link https://lazic.info/josip/post/splitting-haproxy-config/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# This script concatenates multiple files of haproxy configuration into
# one file, and than checks if monolithic config contains errors. If everything is
# OK with new config script will write new config to $CURR_CONFIG and reload haproxy
# Also, script will commit changes to etckeeper, if you don't use etckeeper you
# should start using it.
# Script assumes following directory structure:
# /etc/haproxy/conf.d/
# ├── 00-global.conf
# ├── 15-lazic.conf
# ├── 16-togs.conf
# ├── 17-svartberg.conf
# ├── 18-home1.conf.disabled
# └── 99-globalend.conf
# Every site has it's own file, so you can disable site by changing
# it's file extension, or appending .disabled, like I do.
# ----------------------------------------------------------------------------------------------------------------------------------------------------

export CURR_CONFIG=/etc/haproxy/haproxy.cfg ;
export NEXT_CONFIG=/tmp/haproxy.conf.tmp ;
export CONFIG_DIR=/etc/haproxy/conf.d ;

echo "Compiling *.conf files from $CONFIG_DIR" ;
ls $CONFIG_DIR/*.conf ;
cat $CONFIG_DIR/*.conf > $NEXT_CONFIG ;
echo "Differences between current and new config" ;
diff -s -U 3 $CURR_CONFIG $NEXT_CONFIG | colordiff ;
if [ $? -ne 0 ]; then
  echo "You should make some changes first :)" ;
  exit 1 ; # Exit if old and new configuration are the same
fi
echo -e "Checking if new config is valid..." ;
haproxy -c -f $NEXT_CONFIG ;

if [ $? -eq 0 ]; then
  echo "Check if there are some warnings in new configuration." ;
  read -p "Should I copy new configuration to $CURR_CONFIG and reload haproxy? [y/N]" -n 1 -r ;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo " " ;
    echo "Working..." ;
    cat /etc/haproxy/conf.d/*.conf > $CURR_CONFIG ;
    etckeeper commit -m "Updating haproxy configuration" ;
    echo "Reloading haproxy..." ;
    systemctl restart haproxy ;
  fi
else
  echo "There are errors in new configuration, please fix them and try again." ;
  exit 1 ;
fi
