#! /usr/bin/env bash

function setup_windows_path() {
  if [ $(echo "$PATH" | grep 'PortableApps/PortableGit/bin' | grep -c 'PortableApps/home/.venv/') -eq 0 ]; then
    cp -vf "$SETUP_TOOLS_ROOT/windows_path/setup.ps1" "$HOME/"
    sed -ri -e "s#%WIN_APPS_ROOT%#$WIN_APPS_ROOT#g" -e "s#/#\\\\#g" "$HOME/setup.ps1"
    powershell.exe -ExecutionPolicy RemoteSigned -Command "$HOME/setup.ps1" || ("Error, unable to update the PATH" && return 1)
    rm -f "$HOME/setup.ps1"
  fi
}
