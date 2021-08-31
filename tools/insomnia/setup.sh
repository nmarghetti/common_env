#! /usr/bin/env bash

function setup_insomnia() {
  local ERROR=$SETUP_ERROR_CONTINUE

  insomnia_path="$APPS_ROOT/PortableApps/Insomnia"
  # Install Insomnia
  if [[ ! -f "$insomnia_path/Insomnia.exe" ]]; then
    mkdir -vp "$insomnia_path"
    download_tarball -o "$insomnia_path/Insomnia.exe" "https://github.com/Kong/insomnia/releases/download/core%402021.5.0/Insomnia.Core-2021.5.0-portable.exe"
  fi
  [[ ! -f "$insomnia_path/Insomnia.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/insomnia/Insomnia" "$APPS_ROOT/PortableApps/"

  return 0
}
