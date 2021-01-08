#! /usr/bin/env bash

function setup_putty() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local putty_path="$APPS_ROOT/PortableApps/PuTTY"

  # Install PuTTY
  if [[ ! -f "$putty_path/PUTTY.EXE" ]]; then
    mkdir -vp "$putty_path"
    download_tarball -e -d "$putty_path" "https://the.earth.li/~sgtatham/putty/latest/w64/putty.zip"
  fi
  [[ ! -f "$putty_path/PUTTY.EXE" ]] && echo "Binary file not installed" && return $ERROR

  # Better add PuTTY and PuTTYgen in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/putty/PuTTY" "$APPS_ROOT/PortableApps/"
  rsync -vau "$SETUP_TOOLS_ROOT/putty/PuTTYgen" "$APPS_ROOT/PortableApps/"

  # if [ ! -f "$HOME/.ssh/id_rsa.ppk" ] && [ -f "$HOME/.ssh/id_rsa" ] && [ -f "$APPS_ROOT/PortableApps/Cygwin/cygwin/bin/puttygen.exe" ]; then
  #   "$APPS_ROOT/PortableApps/Cygwin/cygwin/bin/puttygen.exe" "$HOME/.ssh/id_rsa" -o "$HOME/.ssh/id_rsa.ppk"
  # fi

  local remote_machine
  if [[ ! -f "$putty_path/session.reg" ]]; then
    remote_machine="$(git --no-pager config -f "$HOME/.common_env.ini" --get putty.remote-machine 2>/dev/null)"
    echo
    local remote_machine_ok=0
    system_ping "$remote_machine" &>/dev/null && remote_machine_ok=1
    while [[ $remote_machine_ok -eq 0 ]]; do
      read -rep "Enter the remote machine to configure (full name with domain or IP address):" -i "$remote_machine" remote_machine
      if [[ -n "$remote_machine" ]]; then
        system_ping "$remote_machine" &>/dev/null && remote_machine_ok=1 || echo "Unable to connect to '$remote_machine'"
      else
        remote_machine_ok=1
      fi
    done
    [[ -z "$remote_machine" ]] && remote_machine="remote_machine"
    sed -re "s/%USERNAME%/${USER:-${USERNAME}}/" -e "s/remote_machine/$remote_machine/" -e "s#%HOME%#$(echo "$WINDOWS_APPS_ROOT\\home" | sed -re "s#\\\\#\\\\\\\\\\\\\\\\#g")#" "$SETUP_TOOLS_ROOT/putty/session.reg" >"$putty_path/session.reg"
    echo -e "\nAdding PyTTY session to Windows registry..."
    echo "Please answer yes to Windows UAC asking to allow Registry Editor to make change on your device "
    cmd //C regedit.exe //S "$WINDOWS_APPS_ROOT\\PortableApps\\PuTTY\\session.reg"

    [[ "$remote_machine" != "remote_machine" ]] && {
      echo -e "\nCreate and deploy the SSH key on machine '$remote_machine'..."

      # Try to generate the ssh key and ppk with WSL
      [[ ! -f "$putty_path/dns-sync.sh" ]] &&
        curl -sSfL -o "$putty_path/dns-sync.sh" 'https://gist.github.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95/raw/b204a9faa2b4c8d58df283ddc356086333e43408/dns-sync.sh'
      export WSL_USER="${USER:-${USERNAME}}" &&
        export WSL_HOME="//mnt$(get_path_to_posix "$HOME")" &&
        export WSL_APPS_ROOT="//mnt$(get_path_to_posix "$APPS_ROOT")" &&
        export WSL_REMOTE_MACHINE="$remote_machine" &&
        WSLENV=WSL_USER:WSL_HOME:WSL_APPS_ROOT:WSL_REMOTE_MACHINE:/p wsl <"$SETUP_TOOLS_ROOT/putty/wsl_puttygen.sh"

      # Try with sshpass
      local pass_file="$(git --no-pager config -f "$HOME/.common_env.ini" --get putty.pass-file 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")"
      local pass_size=$(stat -c%s "$pass_file" 2>/dev/null)
      [[ "${pass_size:-0}" -gt 0 ]] && type sshpass &>/dev/null && sshpass -vf "$pass_file" ssh-copy-id -i "$HOME/.ssh/id_rsa" -o StrictHostKeyChecking=no "$remote_machine"

      # ssh-keyscan $remote_machine 2>/dev/null >"$HOME/.ssh/known_hosts"
      ssh-copy-id -i "$HOME/.ssh/id_rsa" -o StrictHostKeyChecking=no "$remote_machine"
    }
  fi

  if [[ ! -f "$HOME/.ssh/id_rsa.ppk" ]] && [[ -f "$HOME/.ssh/id_rsa" ]]; then
    echo -e "\nPress OK for the PuTTYgen notice"
    echo "Click on 'Save private key' button"
    echo "Click 'Yes' when it asks if you want to save without a passphrase"
    echo "Save the key as '$WINDOWS_APPS_ROOT\\home\\.ssh\\id_rsa.ppk'"
    echo "Close the PuTTY Key Generator"
    "$putty_path/PUTTYGEN.EXE" "$HOME/.ssh/id_rsa"
  fi

  # create ssh config
  if [[ ! -f "$HOME/.ssh/config" ]]; then
    remote_machine=$(powershell -Command "Get-ItemPropertyValue -path HKCU:\Software\SimonTatham\PuTTY\Sessions\remote -name HostName" 2>/dev/null)
    [[ $? -eq 0 ]] && [[ -n "$remote_machine" ]] && {
      cat >"$HOME/.ssh/config" <<SSHCONFIG
Host $remote_machine
  HostName $remote_machine
  User ${USER:-${USERNAME}}
  IdentityFile "$WIN_APPS_ROOT/home/.ssh/id_rsa"
SSHCONFIG
    }
  fi

  return 0
}
