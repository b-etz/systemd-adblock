#!/bin/bash
# install.sh
# Copyright 2024 (c) Brady Etz, https://github.com/b-etz/local-adblock_fedora
# Implement local ad blocking using systemd-resolved

# Update or create the drop-in for systemd-resolved
mkdir -p /etc/systemd/resolved.conf.d
cp -f 70-adblock.conf /etc/systemd/resolved.conf.d

# Create or replace the default hosts list (localhost)
mkdir -p /etc/systemd/logs.d/
cp -f .hosts /etc

# Create or replace the adblock list retrieval script
cp -f get_adhosts.sh /etc/cron.weekly
chmod +x /etc/cron.weekly/get_adhosts.sh

# Generate adhosts.block and check Unbound's configuration
/bin/bash /etc/cron.weekly/get_adhosts.sh

# Enable and restart systemd-resolved
systemctl enable systemd-resolved
systemctl restart systemd-resolved
exit 0
#EOF
