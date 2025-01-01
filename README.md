# systemd-adblock
### **For Linux Mint, Fedora, or other workstations, including Linux machines with ``systemd-resolved`` that respect SELinux contexts
This is a configuration script for a local ``systemd-resolved`` DNS resolver with ad blocking functionality and DNS-over-TLS. ``systemd-resolved`` is the default DNS resolver that ships with current Debian derivatives and Fedora editions.

The installation script adds a drop-in configuration file for ``systemd-resolved`` that enforces DNS-over-TLS. It adds a daily ``systemd.timer`` and ``systemd.service`` to retrieve a list of ad hosts and malicious domains which should be blackholed. It runs the service once to get a valid ``/etc/hosts`` file, and restarts the resolver service.

<ins>__This configuration may not work for your use case!__</ins> It is designed for a single-user workstation. The only pruning done on the ad blocking list is to avoid blocking ``*.t.co`` links. It uses Quad9 and Cloudflare for forwarded DNS queries. It uses ``0.0.0.0`` for blackholed hostnames. Please see ``get_adhosts.sh`` and the configuration files included in this repository. Confirm they suit your needs. Please fork this repo or submit an issue if it does not suit your needs.

Please see the license file for this repository. Use scripts from the Internet at your own risk, and perform regular backups to avoid data loss.

### Usage Instructions
Navigate to a home directory, or wherever you keep local copies of repositories. For example:
```
$ cd
$ mkdir sources
$ cd sources
```

Copy this repository so it can be updated when things change:
```
$ git clone https://github.com/b-etz/systemd-adblock.git
$ cd systemd-adblock
$ sudo ./install.sh
```
Enter the sudo password and wait for the script to complete.

### Testing the Installation
Use net tools to check DNS resolution settings. Many distributions come with a ``dig`` command, or ``nslookup``. If not, you may need to install ``dnsutils`` or ``bind9-dnsutils``.
```
$ dig example.com
$ dig go.ad1data.com
```
This should use 127.0.0.53 to resolve the DNS query. The ad host (in this case, ``go.ad1data.com``) should return an empty response in 0 ms with no errors. If you run the same ``dig`` command a second time, it should resolve in 0 ms for the safe hostname, too.

If you check the status of ``systemd-resolved``, there should be no errors/failures from attempting to resolve these queries. There may be warnings from ``/etc/hosts`` contents that are formatted poorly, but these are ignored.
```
$ systemctl status systemd-resolved
```
Finally, the list of ``systemd.timer``s can be inspected with:
```
$ systemctl list-timers --all
```

### Update Instructions
If this tool has had a new revision and you want to adopt the changes:
```
$ cd ~/sources/systemd-adblock
$ git pull
$ sudo ./install.sh
```
Enter the sudo password and wait for the script to complete.
