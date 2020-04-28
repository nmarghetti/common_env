#! /bin/bash

function setup_cygwin() {
  local ERROR=$SETUP_ERROR_CONTINUE

  cygwin_path="$APPS_ROOT/PortableApps/Cygwin"
  mkdir -vp "$cygwin_path"
  rsync -au "$SETUP_TOOLS_ROOT/cygwin/Cygwin/cygwin-portable-installer-config.cmd" "$APPS_ROOT/PortableApps/Cygwin/cygwin-portable-installer-config.cmd"
  # Install Cygwin
  if [ ! -f "$cygwin_path/cygwin-portable.cmd" ]; then
    if [ ! -f "$cygwin_path/cygwin-portable-installer.cmd" ]; then
      wget --progress=bar:force -O "$cygwin_path/cygwin-portable-installer.cmd" https://raw.githubusercontent.com/vegardit/cygwin-portable-installer/master/cygwin-portable-installer.cmd
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return $ERROR
    fi
    "$cygwin_path/cygwin-portable-installer.cmd"
  fi
  [ ! -f "$cygwin_path/cygwin-portable.cmd" ] && return $ERROR
  rsync -vau "$SETUP_TOOLS_ROOT/cygwin/Cygwin" "$APPS_ROOT/PortableApps/"
  rsync -au "$cygwin_path/cygwin/Cygwin.ico" "$cygwin_path/App/AppInfo/appicon.ico"

  return 0
}
