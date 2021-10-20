#! /usr/bin/env bash

WSL_WIN_SETUP_TOOLS_ROOT="$WSL_SETUP_TOOLS_ROOT"
export WSL_WIN_SETUP_TOOLS_ROOT
WSL_SETUP_TOOLS_ROOT="$(wslpath -u "$WSL_SETUP_TOOLS_ROOT")"
export WSL_SETUP_TOOLS_ROOT
WSL_APPS_ROOT="$(wslpath -u "$WSL_APPS_ROOT")"
export WSL_APPS_ROOT

exit_error() {
  echo "$*" >&2
  exit 1
}

echoColor() {
  color=$1
  shift
  echo -e "\033[${color}m$*\033[0m"
}

test -z "$WSL_USER" && exit_error "No user given"

# Create the user if it does not exist
if ! grep -qEe "^$WSL_USER:" /etc/passwd; then
  echo "The user '$WSL_USER' does not exist, lets create it first"
  adduser --disabled-password --gecos "" "$WSL_USER"
fi

# Ensure the user exist
grep -qEe "^$WSL_USER:" /etc/passwd || exit_error "Unable to find user '$WSL_USER', please create it first"

# Set user as sudoer without asking password to call sudo command
test ! -f /etc/sudoers.d/"$WSL_USER" && echo "create sudoer file" && echo "$WSL_USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/"$WSL_USER" && chmod 0440 /etc/sudoers.d/"$WSL_USER"

# Add ownership to /etc/resolv.conf and regenerate it if it is a link
if [ -L /etc/resolv.conf ]; then
  rm -f /etc/resolv.conf
  touch /etc/resolv.conf
fi
sudo chown "$WSL_USER":root /etc/resolv.conf

# Configure WSL not to automatically generate /etc/resolv.conf
cat >/etc/wsl.conf <<-EOF
[network]
generateResolvConf = false

EOF

if [ ! -f /opt/wsl_dns.py ] || ! cmp --silent /opt/wsl_dns.py "$WSL_SETUP_TOOLS_ROOT"/wsl/wsl_dns.py; then
  cp -vf "$WSL_SETUP_TOOLS_ROOT"/wsl/wsl_dns.py /opt/
  chmod +x /opt/wsl_dns.py
fi

# Setup network if needed
if ! ping -c 1 -W 1 archive.ubuntu.com >/dev/null 2>&1; then
  # Ensure to setup Cisco VPN metrics if connected
  # For some reason it is needed to call powershell from another bash process otherwise it just stops
  bash <<EOF
if powershell.exe -ExecutionPolicy RemoteSigned -Command '(Get-NetAdapter | Where-Object InterfaceDescription -Match "Cisco AnyConnect" | Where-Object Status -Match "Up" | Get-NetIPInterface).InterfaceMetric' | grep -qvEe '^6000\s$'; then
  echo "Configuring Cisco interface..."
  powershell.exe -ExecutionPolicy RemoteSigned -Command "$WSL_WIN_SETUP_TOOLS_ROOT/wsl/setCiscoVpnMetric.ps1"
fi
EOF

  # Generate /etc/resolv.conf
  # For some reason it is needed to call powershell from another bash process otherwise it just stops
  bash <<EOF
/opt/wsl_dns.py
EOF
fi

# Upgrade the system if not done during the last 24h
if [ ! -f "/var/lib/apt/periodic/update-success-stamp" ] || [ "$(("$(date +%s)" - "$(date -r "/var/lib/apt/periodic/update-success-stamp" +%s)"))" -ge 86400 ]; then
  echo "Upgrading the system..."
  apt-get update -y
  apt-get upgrade -y
fi
