# .bashrc

export SPLIT_LINE="------------------------------------------------------------------------------------------------------------------------------------------------------";

# @see {@link https://k21academy.com/docker-kubernetes/the-connection-to-the-server-localhost8080-was-refused}
export KUBECONFIG=/etc/kubernetes/admin.conf;

# Keep $ROOT Alias Command.
alias copy="cp";
alias remove="rm";
alias move="mv";

# User Specific Aliases and Functions;
alias cp="cp -i";
alias rm="rm -i";
alias mv="mv -i";

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Grab the [Public && Private] IP Addresses of the Virtual Machine Server.
# [COMMAND] > host-ipv4
# ----------------------------------------------------------------------------------------------------------------------------------------------------
alias host-ipv4='list_all_interface() {
  echo "----- INTERNAL NETWORK INTERFACES -----";
  hostname --all-ip-addresses;
  echo "----- EXTERNAL NETWORK INTERFACES -----";
  curl ifconfig.co --ipv4;
  unset -f list_all_interface;
  return 1;
}; list_all_interface';

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Display all Information from [Kernel Ports] of the Virtual Machine Server.
# @see: {@link https://www.tecmint.com/find-out-which-process-listening-on-a-particular-port/}
# [COMMAND] > port [number]
# ----------------------------------------------------------------------------------------------------------------------------------------------------
alias port='display_kernel_port_usage() {
  echo "----- FUSER INTERFACE -----";
  fuser "$1/tcp";
  echo "----- NETSTAT INTERFACE -----";
  netstat -ltnp | grep -w ":$1";
  echo "----- LIST OPEN FILE INTERFACE -----";
  lsof -i ":$1";
  unset -f display_kernel_port_usage;
  return 1;
}; display_kernel_port_usage';

# Alias [COMMAND] to Clear Screen & History;
alias clear-history="clear; clear && cat /dev/null > ~/.bash_history && history -c";

# Exit [COMMAND] [TERMINAL] with flushed Screen & History;
alias flush="clear; clear && cat /dev/null > ~/.bash_history && history -c && exit";

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc;
fi

# Node Version Manager.
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; # This loads nvm

# Docker & Docker Compose Alias.
alias docker="sudo docker";
alias docker-compose="sudo docker-compose";
alias docker="sudo docker";
alias docker-compose="sudo docker-compose";

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]];
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH";
fi
export PATH;

# Uncomment the following line if you don't like SystemCTL auto-paging feature:
# export SYSTEMD_PAGER=

###################################################
##### Virtual Machine / System Configuration ######
###################################################

# [COMMAND] > allow [path]
alias allow='root_permission() {
  sudo setfacl -R -m u:$(whoami):rwx "$@"
  unset -f root_permission;
  return 1;
}; root_permission';

# [COMMAND] > swap | > swap [ratio]
alias swap='func_swap() {
  if [ "$#" -eq 0 ]; then
    cat /proc/sys/vm/swappiness;
    return 1;
  fi
  for swappiness in "$@"; do
    sudo echo "${swappiness}" > /proc/sys/vm/swappiness;
  done;
  unset -f func_swap;
  return 1;
}; func_swap';

# [COMMAND] > pkg [YUM PACKAGE]
alias pkg='list_available_package() {
  sudo yum list available "$1" --showduplicates;
  unset -f list_available_package;
  return 1;
}; list_available_package';

# [COMMAND] > pkg-add [YUM PACKAGE]
alias pkg-add='install_yum_package() {
  sudo yum install "$@" -y;
  unset -f install_yum_package;
  return 1;
}; install_yum_package';

# [COMMAND] > pkg-info [YUM PACKAGE]
alias pkg-info='detail_yum_package() {
  sudo yum info "$@";
  sudo yum list "$@";
  unset -f detail_yum_package;
  return 1;
}; detail_yum_package';

# [COMMAND] > net-rm [NETWORK INTERFACE]
alias net-rm='remove_network_interface() {
  sudo ifconfig "$1" down;
  sudo ip link delete "$1";
  unset -f remove_network_interface;
  return 1;
}; remove_network_interface';

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

# Screen Manipulation.
alias sc="screen -ls";
# [COMMAND] > screen -rd <PID|SID>
alias rd="screen -rd";
# [COMMAND] > screen -S <NAME>
alias scr="screen -S";
# [COMMAND] > screen -L -Logfile <SESSION_NAME> -S <SESSION_NAME> [...OPTIONS]
alias scr='spawn_screens() {
  screen -h | grep Logfile &> /dev/null
  if [ $? == 0 ];
    then
      screen -L -Logfile "screen-$1.log" -S "$1";
    else
      screen -S "$@";
  fi
  unset -f spawn_screens;
  return 1;
}; spawn_screens';
# [COMMAND] > screen -X -S <PID|SID> kill
alias sc-rm='remove_screen() { screen -X -S "$@" kill; unset -f remove_screen; }; remove_screen';
# [COMMAND] > screen -X -S [...<PID|SID>] kill
alias sc-rm='remove_screens() {
  for session in "$@"; do
    screen -X -S "${session}" quit;
  done;
  unset -f remove_screens;
  return 1;
}; remove_screens';

# Mini-Kubernetes Display.
alias minikube-info="minikube status; minikube service list; kubectl cluster-info;";

# Kubernetes Controller.
alias k8="kubectl";
alias kc="kubectl";
alias k8d="kubectl describe";
alias kd="kubectl describe";
# ----------
# [COMMAND] > k8-all | > k8-all [NAMESPACE]
alias k8-all='__KubeController__() {
  local line="--------------------------------------------------------------------";
  if [ "$#" -eq 0 ]; then
    echo "$SPLIT_LINE"; echo "$line WORKER NODES $line"; echo "$SPLIT_LINE";
    kubectl get --all-namespaces Nodes --output=wide;
    echo "$SPLIT_LINE"; echo "$line     PODS     $line"; echo "$SPLIT_LINE";
    kubectl get --all-namespaces Pods --output=wide;
    echo "$SPLIT_LINE"; echo "$line REPLICA SETS $line"; echo "$SPLIT_LINE";
    kubectl get --all-namespaces ReplicaSets --output=wide;
    echo "$SPLIT_LINE"; echo "$line DEPLOYMENTS -$line"; echo "$SPLIT_LINE";
    kubectl get --all-namespaces Deployments --output=wide;
    echo "$SPLIT_LINE"; echo "$line DAEMON SETS -$line"; echo "$SPLIT_LINE";
    kubectl get --all-namespaces DaemonSets --output=wide;
    echo "$SPLIT_LINE"; echo "$line   SERVICES   $line"; echo "$SPLIT_LINE";
    kubectl get --all-namespaces Services --output=wide;
    echo "$SPLIT_LINE"; echo "$line  END POINTS  $line"; echo "$SPLIT_LINE";
    kubectl get --all-namespaces Endpoints --output=wide;
    return 1;
  fi
  echo "$SPLIT_LINE"; echo "$line WORKER NODES $line"; echo "$SPLIT_LINE";
  kubectl get --namespace "$1" Nodes --output=wide;
  echo "$SPLIT_LINE"; echo "$line     PODS     $line"; echo "$SPLIT_LINE";
  kubectl get --namespace "$1" Pods --output=wide;
  echo "$SPLIT_LINE"; echo "$line REPLICA SETS $line"; echo "$SPLIT_LINE";
  kubectl get --namespace "$1" ReplicaSets --output=wide;
  echo "$SPLIT_LINE"; echo "$line DEPLOYMENTS -$line"; echo "$SPLIT_LINE";
  kubectl get --namespace "$1" Deployments --output=wide;
  echo "$SPLIT_LINE"; echo "$line DAEMON SETS -$line"; echo "$SPLIT_LINE";
  kubectl get --namespace "$1" DaemonSets --output=wide;
  echo "$SPLIT_LINE"; echo "$line   SERVICES   $line"; echo "$SPLIT_LINE";
  kubectl get --namespace "$1" Services --output=wide;
  echo "$SPLIT_LINE"; echo "$line  END POINTS  $line"; echo "$SPLIT_LINE";
  kubectl get --namespace "$1" Endpoints --output=wide;
  unset -f __KubeController__;
  return 1;
}; __KubeController__';

# [COMMAND] > k8s-logs | > k8s-logs [DEPLOYMENT]
alias k8s-logs='__Deployment_Describe__() {
  if [ "$#" -eq 0 ]; then
    echo ">>> PLEASE SPECIFY [DEPLOYMENT] AS FIRST ARGUMENT <<<";
    return 1;
  fi
  local pods="$(kubectl get all --all-namespaces | grep --only-matching --perl-regexp "[\w_-]+[\s]+pod/($1(-\w+)*)")";
  local deployment="$(echo "$pods" | grep --only-matching --perl-regexp "pod/$1(-\w+)*")";
  local namespace="$(echo "$pods" | grep --only-matching --perl-regexp "^[-\w]+")";
  echo ">>> DEBUG -- [POD: $pods] -- [DEPLOYMENT: $deployment] -- [NAMESPACE: $namespace]";
  kubectl logs --namespace "$namespace" "$deployment";
  unset -f __Deployment_Describe__;
  return 1;
}; __Deployment_Describe__';

# [COMMAND] > k8s-exec | > k8s-exec [DEPLOYMENT]
alias k8s-exec='__Deployment_Execution__() {
  if [ "$#" -eq 0 ]; then
    echo ">>> PLEASE SPECIFY [DEPLOYMENT] AS FIRST ARGUMENT <<<";
    return 1;
  fi
  local pods="$(kubectl get all --all-namespaces | grep --only-matching --perl-regexp "[\w_-]+[\s]+pod/($1(-\w+)*)")";
  local deployment="$(echo "$pods" | grep --only-matching --perl-regexp "pod/$1(-\w+)*")";
  local namespace="$(echo "$pods" | grep --only-matching --perl-regexp "^[-\w]+")";
  echo ">>> DEBUG -- [POD: $pods] -- [DEPLOYMENT: $deployment] -- [NAMESPACE: $namespace]";
  kubectl exec --namespace "$namespace" -it "$deployment" -- /bin/bash;
  unset -f __Deployment_Execution__;
  return 1;
}; __Deployment_Execution__';

# [COMMAND] > k8s-watch | > k8s-watch [INTERVAL]
alias k8s-watch='__KubeMonitor__() {
  if [ "$#" -eq 0 ]; then
    echo "$SPLIT_LINE";
    watch "kubectl get --all-namespaces nodes,all,ingress,endpoints;";
    return 1;
  fi
  echo "$SPLIT_LINE";
  watch --interval "$1" "kubectl get --all-namespaces nodes,all,ingress,endpoints;";
  unset -f __KubeMonitor__;
  return 1;
}; __KubeMonitor__';

# Kubernetes Administrator.
alias ka="kubeadm";
alias kad="kubeadm";

# Alias Reloading [COMMAND] > rf-alias
alias rf-alias='refresh_alias() {
  sh ~/Linux-Command-Line-Tools/pull.sh;
  sh ~/Linux-Command-Line-Tools/workspace/alias-create.sh;
  cat ~/.bashrc
  source "$HOME"/.bashrc;
  unset -f refresh_alias;
  return 1; exit;
}; refresh_alias';

# Alias Reloading [COMMAND] > pull-alias
alias pull-alias='refresh_alias() {
  sudo cd ~/Linux-Command-Line-Tools/;
  rf-alias;
  unset -f refresh_alias;
  return 1;
}; refresh_alias';

# String Manipulation.
# @see {@link https://stackoverflow.com/questions/11245144/replace-whole-line-containing-a-string-using-sed}
# [COMMAND] > replace [PATTERN] [REPLACE] [FILE]
alias replace='replace() {
  sed -i "s/$1/$2/g" "$3";
  unset -f replace;
  return 1; exit;
}; replace';

# Extra [COMMAND] for further usage.

# @see {@link https://www.linode.com/docs/guides/how-to-install-python-on-centos-8/}
alias py="python3";
# @see {@link https://www.linode.com/docs/guides/installing-and-importing-modules-in-python-3/}
alias pip="pip3";
