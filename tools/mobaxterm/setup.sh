#! /bin/bash

function setup_mobaxterm() {
  local ERROR=$SETUP_ERROR_CONTINUE

  moba_path="$APPS_ROOT/PortableApps/MobaXterm"
  # Install MobaXterm
  if [[ ! -f "$moba_path/MobaXterm_Personal_20.2.exe" ]]; then
    mkdir -vp "$moba_path"
    download_tarball -o MobaXterm.zip -d "$moba_path" "https://download.mobatek.net/2022020030522248/MobaXterm_Portable_v20.2.zip"
  fi
  [[ ! -f "$moba_path/MobaXterm_Personal_20.2.exe" ]] && return $ERROR

  # Better add Cmder in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/mobaxterm/MobaXterm" "$APPS_ROOT/PortableApps/"

  [[ ! -f "$moba_path/MobaXterm.ini" ]] &&
    sed -re "s#%HOME%#$(echo "$WINDOWS_APPS_ROOT\\home" | sed -re "s#\\\\#\\\\\\\\#g")#" -e "s#%ROOT%#$(echo "$WINDOWS_APPS_ROOT\\PortableApps\\MobaXterm\\root" | sed -re "s#\\\\#\\\\\\\\#g")#" "$SETUP_TOOLS_ROOT/mobaxterm/MobaXterm.ini" >"$moba_path/MobaXterm.ini"

  return 0
}
