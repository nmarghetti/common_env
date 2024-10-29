#! /usr/bin/env bash

# https://www.mongodb.com/docs/compass/current/settings/command-line-options/

function setup_mongodbcompass() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local compass="$APPS_ROOT/PortableApps/MongoDbCompass"
  local minimumVersion

  mkdir -p "$compass"

  # Check version
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get mongodbcompass.minimum-version || echo "1.44.5")
  if [ -f "$compass/mongodb-compass.exe" ] &&
    ! printf '%s\n%s\n' "$(powershell -Command "(Get-Item -path $WIN_APPS_ROOT/PortableApps/MongoDbCompass/mongodb-compass.exe).VersionInfo.ProductVersion")" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    rm -f "$compass/mongodb-compass.exe"
  fi

  # Download
  if [ ! -f "$compass/mongodb-compass.exe" ]; then
    download_tarball -o "$compass/mongodb-compass.exe" "https://downloads.mongodb.com/compass/mongodb-compass-${minimumVersion}-win32-x64.exe" || return "$ERROR"
  fi

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/mongodbcompass/MongoDbCompass" "$APPS_ROOT/PortableApps/"

  return 0
}
