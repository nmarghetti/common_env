#! /usr/bin/env bash

# Configure WSL not to automatically generate /etc/resolv.conf
cat >/etc/wsl.conf <<-EOF
[network]
generateResolvConf = false

EOF

rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" >/etc/resolv.conf
