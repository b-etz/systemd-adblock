#!/bin/bash
# install.sh
# Copyright 2024 (c) Brady Etz, https://github.com/b-etz/local-adblock_fedora
# Implement local ad blocking using systemd-resolved

_conf_dst="/etc/systemd/resolved.conf.d"
_logs_dst="/etc/adhosts/logs"
_sh_dst="/usr/local/bin"
_serv_dst="/etc/systemd/system"
_timer_dst="/etc/systemd/system"

# Update or create the drop-in for systemd-resolved
mkdir -p "$_conf_dst"
cp -f 70-adblock.conf "$_conf_dst"

# Create or replace the default hosts list (localhost)
mkdir -p "$_logs_dst"
cp -f .hosts /etc

# Create or replace the adblock list retrieval script
mkdir -p "$_sh_dst"
cp -f adhosts.sh "$_sh_dst"
chmod 0744 "${_sh_dst}/adhosts.sh"
mkdir -p "$_timer_dst"
cp -f adhosts.timer "$_timer_dst"
mkdir -p "$_serv_dst"
cp -f adhosts.service "$_serv_dst"

# Generate ad hosting domains in /etc/hosts immediately
systemctl daemon-reload
systemctl start adhosts.service

# Enable and restart systemd-resolved and the daily systemd.timer
systemctl enable --now adhosts.timer
systemctl enable systemd-resolved
systemctl restart systemd-resolved

exit 0
#EOF
