#! /usr/bin/env bash

function setup_openlens() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local lens="$APPS_ROOT/PortableApps/OpenLens"

  mkdir -p "$lens"

  # Install Lens
  if [ ! -f "$lens/OpenLens.exe" ]; then
    ! download_tarball -o "$lens/OpenLens.exe" "https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2-366/OpenLens.6.5.2-366.exe" &&
      echo "Unable to get the installer" && return 1
  fi

  [ ! -f "$lens/OpenLens.exe" ] && echo "Error: binary is not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/openlens/OpenLens" "$APPS_ROOT/PortableApps/"

  return 0
}
