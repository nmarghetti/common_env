#! /usr/bin/env bash

function setup_lens() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local lens="$APPS_ROOT/PortableApps/Lens"

  # Install Lens
  if [ ! -f "$lens/Lens.exe" ]; then
    mkdir -vp "$lens"
    ! download_tarball -o "$lens/LensSetup.exe" "https://api.k8slens.dev/binaries/Lens%20Setup%202022.9.280635-latest.exe" &&
      echo "Unable to get the installer" && return "$ERROR"
    "$lens/LensSetup.exe" --D="$WINDOWS_APPS_ROOT\\PortableApps\\Lens" //S
  fi

  [ ! -f "$lens/Lens.exe" ] && echo "Error: binary is not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/lens/Lens" "$APPS_ROOT/PortableApps/"

  return 0
}
