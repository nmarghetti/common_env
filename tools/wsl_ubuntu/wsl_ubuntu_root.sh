#! /usr/bin/env bash

WSL_WIN_SETUP_TOOLS_ROOT="$WSL_SETUP_TOOLS_ROOT"
export WSL_WIN_SETUP_TOOLS_ROOT
WSL_SETUP_TOOLS_ROOT="$(wslpath -u "$WSL_SETUP_TOOLS_ROOT")"
export WSL_SETUP_TOOLS_ROOT
WSL_APPS_ROOT="$(wslpath -u "$WSL_APPS_ROOT")"
export WSL_APPS_ROOT

echo_error() {
  echo "$*" >&2
}

echoColor() {
  color=$1
  shift
  echo -e "\033[${color}m$*\033[0m"
}

checkSystem() {
  local ERROR=1

  [ "$(git --no-pager config -f /etc/wsl.conf --get boot.systemd)" = 'true' ] || return $ERROR
  [ "$(git --no-pager config -f /etc/wsl.conf --get interop.enabled)" = 'true' ] || return $ERROR
  [ "$(git --no-pager config -f /etc/wsl.conf --get network.generateResolvConf)" = 'false' ] || return $ERROR
  [ "$(git --no-pager config -f /etc/wsl.conf --get user.default)" = "$WSL_USER" ] || return $ERROR

  return 0
}

initSystem() {
  local ERROR=1

  # Create the user if it does not exist
  if ! grep -qEe "^$WSL_USER:" /etc/passwd; then
    echo "The user '$WSL_USER' does not exist, lets create it first"
    adduser --disabled-password --gecos "" "$WSL_USER"
  fi

  # Ensure the user exist
  ! grep -qEe "^$WSL_USER:" /etc/passwd && echo_error "Unable to find user '$WSL_USER', please create it first" && return $ERROR

  # Set user as sudoer without asking password to call sudo command
  test ! -f /etc/sudoers.d/"$WSL_USER" && echo "create sudoer file" && echo "$WSL_USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/"$WSL_USER" && chmod 0440 /etc/sudoers.d/"$WSL_USER"

  # Set /run/user/ for user
  local user_id
  user_id=$(id -u "$WSL_USER")
  test ! -d /run/user/"$user_id" && mkdir -p /run/user/"$user_id" && chown "$user_id":"$(id -g "$WSL_USER")" /run/user/"$user_id"

  # Configure WSL
  git --no-pager config -f /etc/wsl.conf --replace-all boot.systemd true
  git --no-pager config -f /etc/wsl.conf --replace-all interop.enabled true
  git --no-pager config -f /etc/wsl.conf --replace-all network.generateResolvConf false
  git --no-pager config -f /etc/wsl.conf --replace-all user.default "$WSL_USER"

  return 0
}

createUserDisk() {
  "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/Ubuntu/App/setup.sh
}

fullInstall() {
  initSystem || return $?

  # Add ownership to /etc/resolv.conf and regenerate it if it is a link
  if [ -L /etc/resolv.conf ]; then
    rm -f /etc/resolv.conf
  fi
  touch /etc/resolv.conf
  chown "$WSL_USER":root /etc/resolv.conf

  # Add some scripts
  rsync -vau "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/system/opt /
  rsync -vau "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/system/usr/local/bin /usr/local/
  rsync -vau "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/system/etc/profile.d /etc/

  # Install certificates
  local ca_bundle
  ca_bundle="$(git config -f "$WSL_APPS_ROOT/setup.ini" install.cacert | sed -re 's#%APPS_ROOT%#'"$(echo "$WSL_APPS_ROOT" | sed -re 's#/#\\/#g')"'#')"
  if [ -f "$ca_bundle" ]; then
    local bundle_dir
    bundle_dir=$(dirname "$ca_bundle")
    if rsync -vaurm --exclude "ca-bundle.crt" --include "*/" --include "*.crt" --exclude "*" "$bundle_dir" /usr/local/share/ca-certificates/ | grep -qE '^.*\.crt$'; then
      update-ca-certificates -f
    fi
  else
    echo "Your certificate bundle does not exist: '$ca_bundle'"
  fi

  # Setup network if needed
  [ ! -f ~/.wsl_check_domain ] && echo "archive.ubuntu.com" >~/.wsl_check_domain
  if ! ping -c 1 -W 1 archive.ubuntu.com >/dev/null 2>&1; then
    /opt/wsl_dns.py
  fi

  # Upgrade the system if not done during the last 24h
  echo "Checking to upgrade the system..."
  if [ ! -f "/var/lib/apt/periodic/update-success-stamp" ] || [ "$(("$(date +%s)" - "$(date -r "/var/lib/apt/periodic/update-success-stamp" +%s)"))" -ge 86400 ]; then
    echo "Upgrading the system..."
    apt update -y
    apt upgrade -y
    touch /var/lib/apt/periodic/update-success-stamp
  fi

  createUserDisk || return $?

  return 0
}

main() {
  local ERROR=1

  test -z "$WSL_USER" && echo_error "No user given" && return $ERROR
  test -z "$WSL_ACTION" && echo_error "WSL_ACTION not set" && return $ERROR

  case "$WSL_ACTION" in
    "check")
      checkSystem || return $ERROR
      ;;
    "init")
      initSystem || return $ERROR
      ;;
    "full")
      fullInstall || return $ERROR
      ;;
    *)
      echo_error "Unknown action '$WSL_ACTION'"
      return $ERROR
      ;;
  esac

  return 0
}

main
