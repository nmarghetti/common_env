#! /usr/bin/env bash

download_lens() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local lens="$1"
  mkdir -vp "$lens"
  local version
  version="$(download_tarball -o - https://downloads.k8slens.dev/ | grep -oE '<Key>ide/Lens Setup [^<]+-latest.exe</Key>' | sed -re 's#^<Key>ide/Lens Setup (.+)-latest.exe</Key>$#\1#' | sort -r --version-sort | head -1)"
  if [ -z "$version" ]; then
    version="$(download_tarball -o - https://k8slens.dev/api/binaries/latest.json | "$APPS_ROOT"/PortableApps/PortableGit/bin/jq -r '.path' | sed -re 's#^Lens Setup (.+)-latest.exe$#\1#')"
  fi
  [ -z "$version" ] && echo "Unable to get Lens latest version" && return "$ERROR"

  # Can also be downloaded from there "https://api.k8slens.dev/binaries/Lens%20Setup%${version}-latest.exe"
  if ! download_tarball -o "$lens/LensSetup.exe" "https://downloads.k8slens.dev/ide/Lens%20Setup%20${version}-latest.exe"; then
    rm -f "$lens/LensSetup.exe"
    echo "Unable to get the installer" && return "$ERROR"
  fi
  "$lens/LensSetup.exe" --D="$WINDOWS_APPS_ROOT\\PortableApps\\Lens" //S
  rm -f "$lens/LensSetup.exe"
  [ -f "$lens/Lens.exe" ] && return 0
}

download_lens_old_ui() {
  local lens="$1"
  mkdir -vp "$lens"
  if ! download_tarball -o "$lens/LensSetup.exe" "https://downloads.k8slens.dev/ide/Lens%20Setup%202024.8.291605-latest.exe"; then
    rm -f "$lens/LensSetup.exe"
    echo "Unable to get the installer" && return "$ERROR"
  fi
  "$lens/LensSetup.exe" --D="$WINDOWS_APPS_ROOT\\PortableApps\\LensOldUI" //S
  rm -f "$lens/LensSetup.exe"
  [ -f "$lens/Lens.exe" ] && return 0
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
  rsync -vau "$SETUP_TOOLS_ROOT/lens/LensUpgrader" "$APPS_ROOT/PortableApps/"

  local old_ui
  old_ui=$(git --no-pager config -f "$HOME/.common_env.ini" --get lens.old-ui || echo "false")
  # Also install Lens with old UI
  if [ "$old_ui" = 'true' ]; then
    lens="$APPS_ROOT/PortableApps/LensOldUI"
    if [ ! -f "$lens/Lens.exe" ]; then
      ! download_lens_old_ui "$lens" && return "$ERROR"
    fi
    [ ! -f "$lens/Lens.exe" ] && echo "Error: binary for old Lens is not installed" && return "$ERROR"
    rsync -vau "$SETUP_TOOLS_ROOT/lens/LensOldUI" "$APPS_ROOT/PortableApps/"
  fi

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
  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/lens/Lens" "$APPS_ROOT/PortableApps/"
  return 0
}
