#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: [Kube 1.3] Set up multi-master Kubernetes cluster using Kubeadm.
# @see {@link https://github.com/justmeandopensource/kubernetes/blob/master/kubeadm-ha-multi-master/bootstrap.sh}
# @see {@link https://www.youtube.com/watch?v=c1SCdv2hYDc}
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication";
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config;
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config;
systemctl reload sshd;

# Set Root password
echo "[TASK 2] Set root password";
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1;
