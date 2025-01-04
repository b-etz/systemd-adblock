#!/bin/bash
# adhosts.sh
# scrape and format ad hosting domains
# Copyright 2024 (c) Brady Etz, https://github.com/b-etz/systemd-adblock
#
# Produces a list at /etc/hosts of the format:
# 0.0.0.0 <FQDN>
# To complement the built-in /etc/hosts file

_in="/etc/.hosts"
_tmp=$(mktemp)
_out="/etc/hosts"
_logfile="/etc/adhosts/logs/adhosts_log_$(date +"%Y-%m-%d_%H%M%S").log"
_test_ip="9.9.9.9"
_test_connectivity=true

function adguardhome { # Same lists as AdGuard
	_src="https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"
	wget -a "$_logfile" -O - "$_src" | \
		sed -nre 's/^\|\|([a-zA-Z0-9\_\-\.]+)\^$/0.0.0.0 \1/p'
}

function stevenblack { # Same lists as PiHole
	_src="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
	wget -a "$_logfile" -O - "$_src" | grep "^0.0.0.0"
}

function ublockorigin { # Same lists as uBlock Origin, but without browser plugin
	# Malicious domains
	_src="https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-hosts.txt"
	wget -a "$_logfile" -O - "$_src" | grep "^0.0.0.0"

	# Peter Lowe's list
	_src="https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts"
	wget -a "$_logfile" -O - "$_src" | \
		sed -nre 's/^127.0.0.1 ([a-zA-Z0-9\_\-\.]+)/0.0.0.0 \1/p'
}

function stopforumspam { # StopForumSpam list
	_src="https://www.stopforumspam.com/downloads/toxic_domains_whole.txt"
# To exclude top domains from this spam list, comment out the above line and uncomment below:
#	_src="https://www.stopforumspam.com/downloads/toxic_domains_whole_filtered_1000.txt"
	wget -a "$_logfile" -O - "$_src" | awk '{ print "0.0.0.0 " $1 }'
}

function adblockplus { # OISD is the AdBlock Plus filter list
	_src="https://big.oisd.nl/"
	wget -a "$_logfile" -O - "$_src" | \
		sed -nre 's/^\|\|([a-zA-Z0-9\_\-\.]+)\^$/0.0.0.0 \1/p'
}

if $_test_connectivity; then
	ping -q -w1 -c1 9.9.9.9 > /dev/null \
	&& echo "Internet connectivity test passed..." \
	|| (echo "Internet connectivity test failed!!"; exit 2) 
fi

# You can add many (b)ad host lists. Many are updated regularly on GitHub, etc.
echo "Creating temporary list..."
cp -f -v "$_in" "$_tmp"
# Comment out any lines you don't want, or add more below:
adguardhome   >> "$_tmp"
stevenblack   >> "$_tmp"
ublockorigin  >> "$_tmp"
stopforumspam >> "$_tmp"
adblockplus   >> "$_tmp"

# Clean up
echo "Pruning list and sorting..."
grep -v "t.co\|\\\\" "$_tmp" | sort -u -o "$_tmp"
chmod 0644 "$_tmp"

# If there are different entries, update
diff -Nq "$_out" "$_tmp" 1>> "$_logfile"
case $? in
	0) echo "No changes..."; rm -v "$_tmp";; # No changes
	1) echo "Updating /etc/hosts..."; cp -f -v "$_tmp" "$_out"; rm -v "$_tmp"; systemctl restart systemd-resolved;;
	*) echo "$0: something bad happened!"; exit 1;;
esac
exit 0
#EOF
