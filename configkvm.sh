#!/bin/bash
#ConfigKVMServer
adduser $1
echo $1":"$2 |chpasswd
groupadd libvirt
usermod -G libvirt -a $1
touch /etc/polkit-1/localauthority/50-local.d/50-libvirt-remote-access.pkla
echo -e "[Remote libvirt SSH access]\n
Identity=unix-user:"$1"\n
Action=org.libvirt.unix.manage\n
ResultAny=yes\n
ResultInactive=yes\n
ResultActive=yes" > /etc/polkit-1/localauthority/50-local.d/50-libvirt-remote-access.pkla
