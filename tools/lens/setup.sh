#! /usr/bin/env bash

download_lens() {
  local lens="$1"
  mkdir -vp "$lens"
  # Can also be downloaded from there "https://api.k8slens.dev/binaries/Lens%20Setup%202023.1.110749-latest.exe"
  ! download_tarball -o "$lens/LensSetup.exe" "https://downloads.k8slens.dev/ide/Lens%20Setup%202023.1.110749-latest.exe" &&
    echo "Unable to get the installer" && return 1
  "$lens/LensSetup.exe" --D="$WINDOWS_APPS_ROOT\\PortableApps\\Lens" //S
}

function setup_lens() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local lens="$APPS_ROOT/PortableApps/Lens"

  # Check for version upgrade
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get lens.minimum-version || echo "2023.1.110749.0")
  if [ -f "$lens/Lens.exe" ] &&
    ! printf '%s\n%s\n' "$(powershell -Command "(Get-Item -path $WIN_APPS_ROOT/PortableApps/Lens/lens.exe).VersionInfo.ProductVersion")" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    upgrade_lens
  fi

  # Install Lens
  if [ ! -f "$lens/Lens.exe" ]; then
    ! download_lens "$lens" && return "$ERROR"
  fi

  [ ! -f "$lens/Lens.exe" ] && echo "Error: binary is not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/lens/Lens" "$APPS_ROOT/PortableApps/"

  return 0
}

upgrade_lens() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local lens="$APPS_ROOT/PortableApps/Lens"
  local backup="$APPS_ROOT/PortableApps_backup"
  tasklist //FI "IMAGENAME eq Lens.exe" | grep -q Lens.exe && echo "Please close all instances of Lens before upgrading it" && return "$ERROR"
  if [ -e "$backup/Lens" ]; then
    rm -rf "$lens"
  else
    mkdir -p "$backup"
    mv "$lens" "$backup/"
  fi
  ! download_lens "$lens" && return "$ERROR"
}
