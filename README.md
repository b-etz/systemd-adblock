# local-adblock_fedora
### **For Fedora workstations
This is a configuration script for a local ``systemd-resolved`` DNS resolver with ad blocking functionality and DNS-over-TLS. ``systemd-resolved`` is the default DNS resolver that ships with current Fedora editions.

The installation script adds a drop-in configuration file for ``systemd-resolved`` that enforces DNS-over-TLS. It adds a weekly cronjob to retrieve a list of ad/malicious domains which should be blackholed. It runs the cronjob once to get a valid ``/etc/hosts`` file, and restarts the resolver service.

<ins>__This configuration is opinionated:__</ins> it is designed for a single-user workstation. The only pruning done on the ad blocking list is to avoid blocking ``*.t.co`` links. It uses Quad9 and Cloudflare for forwarded DNS queries. Please see get_adhosts.sh and the configuration files included in this repository. Confirm they suit your needs. Fork if not desirable.

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
$ git clone https://github.com/b-etz/local-adblock_fedora.git
$ cd local-adblock_fedora
$ sudo ./install.sh
```
Enter the sudo password and wait for the script to complete.

### Testing the Installation
Use net tools to check DNS resolution settings. Many distributions come with a ``dig`` command, or ``nslookup``. If not, you may need to install ``dnsutils`` or ``bind9-dnsutils``.
```
$ dig example.com
```
This should use 127.0.0.53 to resolve the DNS query.
If you run the same ``dig`` command a second time, it should resolve in 0 ms.

### Update Instructions
If this tool has had a new revision and you want to adopt the changes:
```
$ cd ~/sources/local-adblock_fedora
$ git pull
$ sudo ./install.sh
```
Enter the sudo password and wait for the script to complete.
