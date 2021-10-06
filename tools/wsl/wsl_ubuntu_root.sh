#! /usr/bin/env bash

export WSL_SETUP_TOOLS_ROOT
WSL_SETUP_TOOLS_ROOT="$(cd "$WSL_APPS_ROOT/Documents/dev/common_env/tools" && pwd)"
export WSL_WIN_SETUP_TOOLS_ROOT
WSL_WIN_SETUP_TOOLS_ROOT="$(wslpath -w "$WSL_SETUP_TOOLS_ROOT")"

# Set user as sudoer without asking password to call sudo command
echo "$WSL_USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/"$WSL_USER" && chmod 0440 /etc/sudoers.d/"$WSL_USER"
sudo chown "$WSL_USER":root /etc/resolv.conf

# Configure WSL not to automatically generate /etc/resolv.conf
cat >/etc/wsl.conf <<-EOF
[network]
generateResolvConf = false

EOF

# Ensure to setup Cisco VPN metrics if connected
# For some reason it is needed to call powershell from another bash process otherwise it just stops
bash <<EOF
if powershell.exe -ExecutionPolicy RemoteSigned -Command 'Get-NetAdapter | Where-Object {\$_.InterfaceDescription -Match "Cisco AnyConnect"}' | grep -i cisco | grep -qv Disabled &&
  powershell.exe -ExecutionPolicy RemoteSigned -Command 'Get-NetAdapter | Where-Object {\$_.InterfaceDescription -Match "Cisco AnyConnect"} | Get-NetIPInterface' | grep -i ethernet | grep -qv 6000; then
  powershell.exe -ExecutionPolicy RemoteSigned -Command "$WSL_WIN_SETUP_TOOLS_ROOT/wsl/setCiscoVpnMetric.ps1"
fi
EOF

# Generate /etc/resolv.conf
if [ ! -f /opt/wsl_dns.py ] || ! cmp --silent /opt/wsl_dns.py "$WSL_SETUP_TOOLS_ROOT"/wsl/wsl_dns.py; then
  cp -vf "$WSL_SETUP_TOOLS_ROOT"/wsl/wsl_dns.py /opt/
  chmod +x /opt/wsl_dns.py
fi
# For some reason it is needed to call powershell from another bash process otherwise it just stops
bash <<EOF
/opt/wsl_dns.py
EOF

apt-get update -y
apt-get upgrade -y
