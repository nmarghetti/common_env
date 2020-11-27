#! /usr/bin/env bash

function setup_cygwin() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local cygwin_path="$APPS_ROOT/PortableApps/Cygwin"

  # Install Cygwin
  if [[ ! -f "$cygwin_path/cygwin-portable.cmd" ]]; then
    mkdir -vp "$cygwin_path"
    if [[ ! -f "$cygwin_path/cygwin-portable-installer.cmd" ]]; then
      download_tarball -o "$cygwin_path/cygwin-portable-installer.cmd" https://raw.githubusercontent.com/vegardit/cygwin-portable-installer/master/cygwin-portable-installer.cmd
    fi
    [[ ! -f "$cygwin_path/cygwin-portable-installer.cmd" ]] && echo "Unable to get the installer" && return $ERROR
    rsync -au "$SETUP_TOOLS_ROOT/cygwin/Cygwin/cygwin-portable-installer-config.cmd" "$APPS_ROOT/PortableApps/Cygwin/cygwin-portable-installer-config.cmd"
    "$cygwin_path/cygwin-portable-installer.cmd"
  fi
  [[ ! -f "$cygwin_path/cygwin-portable.cmd" ]] && echo "Binary file not installed" && return $ERROR

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/cygwin/Cygwin" "$APPS_ROOT/PortableApps/"
  rsync -au "$cygwin_path/cygwin/Cygwin.ico" "$cygwin_path/App/AppInfo/appicon.ico"

  return 0
}
