#! /bin/bash

function setup_autohotkey() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local autohotkey_path="$APPS_ROOT/PortableApps/AutoHotkey"

  # Install AutoHotkey
  if [[ ! -f "$autohotkey/AutoHotkeyU64.exe" ]]; then
    mkdir -p "$autohotkey_path"
    download_tarball -e -d "$autohotkey_path" "https://www.autohotkey.com/download/ahk.zip"
  fi
  [[ ! -f "$autohotkey_path/AutoHotkeyU64.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/autohotkey/AutoHotkeyLauncher" "$APPS_ROOT/PortableApps/"

  return 0
}
