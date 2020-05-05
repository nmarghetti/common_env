#! /bin/bash

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

  if [[ ! -f "$HOME/.ssh/id_rsa.ppk" ]] && [[ -f "$HOME/.ssh/id_rsa" ]]; then
    echo -e "\nPress OK for the PuTTYgen notice"
    echo "Click on 'Save private key' button and save it as '$HOME/.ssh/id_rsa.ppk'"
    "$putty_path/PUTTYGEN.EXE" "$HOME/.ssh/id_rsa"
  fi

  if [[ ! -f "$putty_path/session.reg" ]]; then
    local remote_machine
    echo
    read -rep "Enter the remote machine to configure (full name with domain or IP address):" remote_machine
    [[ -z "$remote_machine" ]] && remote_machine="remote_machine"
    sed -re "s/%USERNAME%/$USERNAME/" -e "s/remote_machine/$remote_machine/" -e "s#%HOME%#$(echo "$WINDOWS_APPS_ROOT\\home" | sed -re "s#\\\\#\\\\\\\\\\\\\\\\#g")#" "$SETUP_TOOLS_ROOT/putty/session.reg" >"$putty_path/session.reg"
    cmd //C regedit.exe //S "$WINDOWS_APPS_ROOT\\PortableApps\\PuTTY\\session.reg"

    [[ -n "$remote_machine" ]] && {
      echo -e "\nDeploying the SSH key on machine $remote_machine..."
      ssh-copy-id "$remote_machine"
    }
  fi

  return 0
}
