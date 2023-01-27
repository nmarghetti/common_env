#! /usr/bin/env bash

function setup_vcxsrv() {
  local ERROR=$SETUP_ERROR_CONTINUE

  # Install VcXsrv Windows X Server
  if [ ! -f "$PROGRAMFILES/VcXsrv/vcxsrv.exe" ]; then
    local tarball=vcxsrv_installer.exe
    download_tarball -o "$tarball" "https://sourceforge.net/projects/vcxsrv/files/latest/download"
    echo "Please leave the default installation path"
    echo "Press 'Enter' when the installation of VcXsrv is completed"
    START //B "$tarball"
    read -r
    rm -f "$tarball"
  fi
  [ ! -f "$PROGRAMFILES/VcXsrv/vcxsrv.exe" ] && echo "Binary file not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/vcxsrv/VcXsrvLauncher" "$APPS_ROOT/PortableApps/"
  [[ ! -f "$APPS_ROOT/PortableApps/VcXsrvLauncher/icon/xlaunch.exe" ]] &&
    mkdir -p "$APPS_ROOT/PortableApps/VcXsrvLauncher/icon" &&
    cp "$PROGRAMFILES/VcXsrv/xlaunch.exe" "$APPS_ROOT/PortableApps/VcXsrvLauncher/icon/"

  # https://www.zuut.com/wsl2-x11-server/
  local xauthority=~/.Xauthority
  local xauth="$PROGRAMFILES/VcXsrv/xauth.exe"
  test -f "$xauthority" || touch "$xauthority"
  if [ "$("$xauth" list | grep -c '/unix')" -eq 0 ]; then
    "$xauth" add "localhost:0" . "$(date | md5sum | awk '{ print $1 }')"
  fi
  sed -re "s#%WINDOWS_APPS_ROOT%#$(echo "$WINDOWS_APPS_ROOT" | sed -re 's#\\#\\\\#g')#g" "$SETUP_TOOLS_ROOT/vcxsrv/config.xlaunch" >"$APPS_ROOT/PortableApps/VcXsrvLauncher/config.xlaunch"

  return 0
}
