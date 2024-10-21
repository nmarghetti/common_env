#! /bin/sh

# This script allow to check if the DNS resolution is working properly
# It would refresh DNS entries in /etc/resolv.conf if the DNS resolution is not working
# This is useful when the network is not stable or while you connect/disconnect from VPN

if [ -f /usr/local/bin/refresh-dns.sh ]; then
  /usr/local/bin/refresh-dns.sh &
fi
return 0
