#! /bin/bash

function setup_autohotkey() {
  local ERROR=$SETUP_ERROR_CONTINUE

  autohotkey="$APPS_ROOT/PortableApps/AutoHotkey"
  # Install AutoHotkey
  if [ ! -f "$autohotkey/AutoHotkeyU64.exe" ]; then
    mkdir -p "$autohotkey"
    tarball=ahk.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force -O "$tarball" https://www.autohotkey.com/download/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return $ERROR
    fi
    unzip $tarball -d "$autohotkey/" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return $ERROR
    echo
    rm -f $tarball
  fi
  [ ! -f "$autohotkey/AutoHotkeyU64.exe" ] && return $ERROR
  # Better add VSCode in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/autohotkey/AutoHotkeyLauncher" "$APPS_ROOT/PortableApps/"

  return 0
}
