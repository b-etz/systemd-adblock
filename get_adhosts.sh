#!/bin/bash
# /etc/cron.weekly/get_adhosts.sh
# Copyright 2024 (c) Brady Etz, https://github.com/b-etz/local-adblock_fedora
# Scrape and format ad hosting domains
#
# Produces a list at /etc/hosts of the format:
# 0.0.0.0 <FQDN>
# To complement the built-in /etc/hosts file

_tmp=$(mktemp)
_in="/etc/.hosts"
_out="/etc/hosts"
_logfile="/etc/systemd/logs.d/adhosts_log_$(date +"%Y-%m-%d_%H%M%S").log"

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
#	_src="https://www.stopforumspam.com/downloads/toxic_domains_whole_filtered_1000.txt"
	wget -a "$_logfile" -O - "$_src" | awk '{ print "0.0.0.0 " $1 }'
}

function adblockplus { # OISD is the AdBlock Plus filter list
	_src="https://big.oisd.nl/"
	wget -a "$_logfile" -O - "$_src" | \
		sed -nre 's/^\|\|([a-zA-Z0-9\_\-\.]+)\^$/0.0.0.0 \1/p'
}

# You can add many (b)ad host lists. Many are updated regularly on GitHub, etc.
cat "$_in" > "$_tmp"
# Comment out any lines you don't want, or add more below:
adguardhome >> "$_tmp"
stevenblack >> "$_tmp"
ublockorigin >> "$_tmp"
stopforumspam >> "$_tmp"
adblockplus >> "$_tmp"

# Clean up
grep -v "t.co\|\\\\" "$_tmp" | sort -u -o "$_tmp"
chmod 0644 "$_tmp"

# If there are different entries, update
diff -Nq "$_out" "$_tmp" 1>>"$_logfile"
case $? in
	0) rm "$_tmp" && exit 0;; # No changes
	1) mv -fu "$_tmp" "$_out";;
	*) echo "$0: something bad happened!"; exit 1;;
esac
exit 0
#EOF
