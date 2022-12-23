#!/bin/bash

##################################################################################################
####################### HOW TO RUN THIS FILE: > `bash -x -v del-bridge.sh` #######################
##################################################################################################

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Firewall Daemon Configuration for OpenVPN Server Connections.
# @see {@link https://server-world.info/en/note?os=CentOS_Stream_8&p=openvpn}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Network Interface which can connect to Global Network (WAN).
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# ETH_INTERFACE=enp1s0
ETH_INTERFACE=eth0

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Interface that VPN Tunnel uses. Generally this param is [tun0].
# ----------------------------------------------------------------------------------------------------------------------------------------------------
VPN_INTERFACE=tun0

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Listening port of OpenVPN Server Daemon.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# PORT=1194
PORT=443

firewall-cmd --zone=public --remove-masquerade
firewall-cmd --direct --remove-rule ipv4 filter FORWARD 0 -i ${VPN_INTERFACE} -o ${ETH_INTERFACE} -j ACCEPT
firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -o ${ETH_INTERFACE} -j MASQUERADE
firewall-cmd --remove-port=${PORT}/tcp
firewall-cmd --remove-port=${PORT}/udp
