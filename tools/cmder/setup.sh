#! /bin/bash

function setup_cmder() {
  local ERROR=$SETUP_ERROR_CONTINUE

  cmder_path="$APPS_ROOT/PortableApps/cmder"
  # Install cmder
  if [ ! -f "$cmder_path/Cmder.exe" ]; then
    mkdir -vp "$cmder_path"
    tarball=cmder_mini.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force https://github.com/cmderdev/cmder/releases/download/v1.3.14/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return $ERROR
    fi
    unzip $tarball -d "$cmder_path" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return $ERROR
    echo
    #rm -f $tarball
  fi
  if [ ! -f "$cmder_path/Cmder.exe" ]; then
    return $ERROR
  fi
  # Better add Cmder in PortableApps menu
  if [ -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/rsync.exe" ]; then
    rsync -vau "$SETUP_TOOLS_ROOT/cmder/CmderLauncher" "$APPS_ROOT/PortableApps/"
  fi
  if [ ! -f "$APPS_ROOT/PortableApps/CmderLauncher/App/AppInfo/appicon.ico" ]; then
    cp -vf "$APPS_ROOT/PortableApps/cmder/icons/cmder.ico" "$APPS_ROOT/PortableApps/CmderLauncher/App/AppInfo/appicon.ico"
  fi
  if [ ! -f "$APPS_ROOT/PortableApps/cmder/vendor/conemu-maximus5/ConEmu.xml" ]; then
    cp -vf "$SETUP_TOOLS_ROOT/cmder/ConEmu.xml" "$APPS_ROOT/PortableApps/cmder/config/user-ConEmu.xml"
  fi
}
