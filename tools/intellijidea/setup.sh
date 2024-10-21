#! /usr/bin/env bash

download_intellijidea() {
  # Default to community edition
  local edition="ideaIC"
  if [ "$(git --no-pager config -f "$HOME/.common_env.ini" --get intellijidea.edition)" = "ultimate" ]; then
    edition="ideaIU"
  fi
  mkdir -vp "$1"
  download_tarball -e -d "$1" "https://download.jetbrains.com/idea/${edition}-2022.3.1.win.zip"
}

# https://www.jetbrains.com/help/idea/installation-guide.html#standalone
function setup_intellijidea() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local edition
  edition="$(git --no-pager config -f "$HOME/.common_env.ini" --get intellijidea.edition) || echo community"
  local intellijidea_path="$APPS_ROOT/PortableApps/IntelliJIdea"
  if [ "$edition" = "community" ]; then
    intellijidea_path="$APPS_ROOT/PortableApps/IntelliJIdeaCommunity"
  fi

  # Check for version upgrade
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get intellijidea.minimum-version || echo "2022.3.1.0")
  if [ -f "$intellijidea_path/bin/idea64.exe" ] &&
    ! printf '%s\n%s\n' "$(powershell -Command "(Get-Command $WIN_APPS_ROOT/PortableApps/IntelliJIdea/bin/idea64.exe).Version -join \".\"")" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    upgrade_intellijidea
  fi

  # Install IntelliJIdea
  if [ ! -f "$intellijidea_path/bin/idea64.exe" ]; then
    download_intellijidea "$intellijidea_path"
  fi
  [ ! -f "$intellijidea_path/bin/idea64.exe" ] && echo "Binary file not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  if [ "$edition" = "community" ]; then
    rsync -vau "$SETUP_TOOLS_ROOT/intellijidea/IntelliJIdeaCommunity" "$APPS_ROOT/PortableApps/"
  else
    rsync -vau "$SETUP_TOOLS_ROOT/intellijidea/IntelliJIdea" "$APPS_ROOT/PortableApps/"
  fi
  return 0
}

upgrade_intellijidea() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local edition
  edition="$(git --no-pager config -f "$HOME/.common_env.ini" --get intellijidea.edition) || echo community"
  local intellijidea_path="$APPS_ROOT/PortableApps/IntelliJIdea"
  if [ "$edition" = "community" ]; then
    intellijidea_path="$APPS_ROOT/PortableApps/IntelliJIdeaCommunity"
  fi
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
