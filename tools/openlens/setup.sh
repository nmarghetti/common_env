#! /usr/bin/env bash

function setup_openlens() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local lens="$APPS_ROOT/PortableApps/OpenLens"
  local git_path="$APPS_ROOT/PortableApps/PortableGit"

  mkdir -p "$lens"

  # Install Lens
  if [ ! -f "$lens/OpenLens.exe" ]; then
    ! download_tarball -o "$lens/OpenLens.exe" "https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2-366/OpenLens.6.5.2-366.exe" &&
      echo "Unable to get the installer" && return 1
  fi

  [ ! -f "$lens/OpenLens.exe" ] && echo "Error: binary is not installed" && return "$ERROR"

  if [ ! -f "$git_path/bin/stern.exe" ]; then
    echoColor 36 "Adding stern..."
    download_tarball -e -d "$git_path/bin" "https://github.com/stern/stern/releases/download/v1.32.0/stern_1.32.0_windows_amd64.tar.gz"
  fi

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/openlens/OpenLens" "$APPS_ROOT/PortableApps/"

  return 0
}
