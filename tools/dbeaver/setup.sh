#! /usr/bin/env bash

# https://dbeaver.io/download/
function setup_dbeaver() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local dbeaver_path="$APPS_ROOT/PortableApps/DBeaver"

  # Install DBeaver
  if [[ ! -f "$dbeaver_path/dbeaver.exe" ]]; then
    mkdir -vp "$dbeaver_path"
    download_tarball -e -d "$dbeaver_path" -m dbeaver "https://dbeaver.io/files/dbeaver-ce-latest-win32.win32.x86_64.zip"
  fi
  [[ ! -f "$dbeaver_path/dbeaver.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/dbeaver/DBeaver" "$APPS_ROOT/PortableApps/"
  return 0
}
