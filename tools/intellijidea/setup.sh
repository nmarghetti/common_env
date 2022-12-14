#! /usr/bin/env bash

download_intellijidea() {
  mkdir -vp "$1"
  download_tarball -e -d "$1" "https://download.jetbrains.com/idea/ideaIC-2022.3.win.zip"
}

# https://www.jetbrains.com/help/idea/installation-guide.html#standalone
function setup_intellijidea() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local intellijidea_path="$APPS_ROOT/PortableApps/IntelliJIdea"

  # Check for version upgrade
  if [ -f "$intellijidea_path/bin/idea64.exe" ] &&
    ! printf '%s\n%s\n' "$(powershell -Command "(Get-Command $WIN_APPS_ROOT/PortableApps/IntelliJIdea/bin/idea64.exe).Version -join \".\"")" "2022.3.0.0" |
    sort -r --check=quiet --version-sort; then
    upgrade_intellijidea
  fi

  # Install IntelliJIdea
  if [ ! -f "$intellijidea_path/bin/idea64.exe" ]; then
    download_intellijidea "$intellijidea_path"
  fi
  [ ! -f "$intellijidea_path/bin/idea64.exe" ] && echo "Binary file not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/intellijidea/IntelliJIdea" "$APPS_ROOT/PortableApps/"
  return 0
}

upgrade_intellijidea() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local intellijidea_path="$APPS_ROOT/PortableApps/IntelliJIdea"
  local backup="$APPS_ROOT/PortableApps_backup"
  tasklist //FI "IMAGENAME eq idea64.exe" | grep -q idea64.exe && echo "Please close all instances of IntelliJ IDEA before upgrading it" && return "$ERROR"
  if [ -e "$backup/IntelliJIdea" ]; then
    rm -rf "$intellijidea_path"
  else
    mkdir -p "$backup"
    mv "$intellijidea_path" "$backup/"
  fi
  download_intellijidea "$intellijidea_path"
}
