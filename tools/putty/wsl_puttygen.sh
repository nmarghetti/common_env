#! /usr/bin/env bash

# https://gist.github.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95
setupVpn() {
  grep -q "$(hostname)" /etc/hosts || cat "127.0.0.1 $(hostname)" >>/etc/hosts

  if [[ ! -f /etc/init.d/dns-sync.sh ]]; then
    sudo curl -fL --compressed --progress-bar -o /etc/init.d/dns-sync.sh https://gist.github.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95/raw/b204a9faa2b4c8d58df283ddc356086333e43408/dns-sync.sh
    [[ ! -f /etc/init.d/dns-sync.sh && -f "$WSL_APPS_ROOT/dns-sync.sh" ]] &&
      sudo cp -vf "$WSL_APPS_ROOT/dns-sync.sh" /etc/init.d/dns-sync.sh
    sudo chmod +x /etc/init.d/dns-sync.sh
  fi
  [[ ! -f /etc/init.d/dns-sync.sh ]] && return 1

  # [[ -L /etc/resolv.conf ]] && unlink /etc/resolv.conf
  # [[ -f /etc/resolv.conf ]] && rm -f /etc/resolv.conf
  # To put it back, do this
  # ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
  if sudo service dns-sync.sh status 2>/dev/null | grep -q 'dns-sync is not running'; then
    sudo service dns-sync.sh start
  fi
}

createSshKey() {
  if [[ "$(type puttygen sshpass git 2>&1 >/dev/null | wc -l)" -ne 0 ]]; then
    sudo apt-get update
    sudo apt-get -qq install putty-tools sshpass git
  fi

  type puttygen >/dev/null || return 1

  local ssh_folder="$HOME/.ssh"
  [[ ! -d "$ssh_folder" ]] && {
    mkdir -p "$ssh_folder"
    chmod 700 "$ssh_folder"
  }
  # If ssh key already generated on WSL, just use a temporary folder
  if [[ -f "$HOME/.ssh/id_rsa" ]]; then
    ssh_folder=$(mktemp -d)
  fi
  [[ -z "$ssh_folder" || ! -d "$ssh_folder" ]] && return 1

  puttygen -t rsa -b 4096 -o "$ssh_folder/id_rsa.ppk" -O private --new-passphrase /dev/null
  puttygen "$ssh_folder/id_rsa.ppk" -o "$ssh_folder/id_rsa" -O private-openssh
  puttygen "$ssh_folder/id_rsa.ppk" -o "$ssh_folder/id_rsa.pub" -O public-openssh
  [[ -f "$ssh_folder/id_rsa.ppk" && -f "$ssh_folder/id_rsa" && -f "$ssh_folder/id_rsa.pub" ]] &&
    cp -f "$ssh_folder/id_rsa.ppk" "$ssh_folder/id_rsa" "$ssh_folder/id_rsa.pub" "$WSL_HOME/.ssh/"

  if [[ -n "$WSL_REMOTE_MACHINE" ]]; then
    # It might take some time for dns-sync.sh to be up
    local nb
    for nb in $(seq 4); do
      if ping -c 1 -w "$nb" "$WSL_REMOTE_MACHINE" >/dev/null 2>&1; then
        break
      fi
      echo "$WSL_REMOTE_MACHINE not reacheable"
      sleep "$nb"
    done
    if ping -c 1 -w 1 "$WSL_REMOTE_MACHINE"; then
      local pass_file
      pass_file=$(git --no-pager config -f "$WSL_HOME/.common_env.ini" --get putty.pass-file | sed -re "s#%APPS_ROOT%#$WSL_APPS_ROOT#g")
      local pass_size
      pass_size=$(stat -c%s "$pass_file" 2>/dev/null)
      [[ "${pass_size:-0}" -gt 0 ]] && sshpass -f "$pass_file" ssh-copy-id -i "$ssh_folder/id_rsa" -o StrictHostKeyChecking=no "$WSL_USER@$WSL_REMOTE_MACHINE"
    fi
  fi

  # Clean if temporary folder has been used
  [[ "$HOME/.ssh" != "$ssh_folder" ]] && rm -rf "$ssh_folder"
}

setupVpn
createSshKey

exit 0
