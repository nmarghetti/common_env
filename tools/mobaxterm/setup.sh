#! /usr/bin/env bash

function setup_mobaxterm() {
  local ERROR=$SETUP_ERROR_CONTINUE

  moba_path="$APPS_ROOT/PortableApps/MobaXterm"
  # Install MobaXterm
  # Move from previous installation
  [[ -f "$moba_path/MobaXterm_Personal_20.2.exe" ]] && mv "$moba_path/MobaXterm_Personal_20.2.exe" "$moba_path/MobaXterm_Personal.exe"
  if [[ ! -f "$moba_path/MobaXterm_Personal.exe" ]]; then
    mkdir -vp "$moba_path"
    download_tarball -e -o "MobaXterm.zip" -d "$moba_path" "https://download.mobatek.net/2022020030522248/MobaXterm_Portable_v20.6.zip"
    [[ "$?" -eq 0 ]] && mv "$moba_path/MobaXterm_Personal_20.6.exe" "$moba_path/MobaXterm_Personal.exe"
  fi
  [[ ! -f "$moba_path/MobaXterm_Personal.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/mobaxterm/MobaXterm" "$APPS_ROOT/PortableApps/"

  [[ ! -f "$moba_path/MobaXterm.ini" ]] &&
    sed -re "s#%HOME%#$(echo "$WINDOWS_APPS_ROOT\\home" | sed -re "s#\\\\#\\\\\\\\#g")#" -e "s#%ROOT%#$(echo "$WINDOWS_APPS_ROOT\\PortableApps\\MobaXterm\\root" | sed -re "s#\\\\#\\\\\\\\#g")#" "$SETUP_TOOLS_ROOT/mobaxterm/MobaXterm.ini" >"$moba_path/MobaXterm.ini"

  return 0
}
