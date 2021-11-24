#! /usr/bin/env bash

# https://www.jetbrains.com/help/idea/installation-guide.html#standalone
function setup_intellijidea() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local intellijidea_path="$APPS_ROOT/PortableApps/IntelliJIdea"

  # Install IntelliJIdea
  if [[ ! -f "$intellijidea_path/bin/idea64.exe" ]]; then
    mkdir -vp "$intellijidea_path"
    download_tarball -e -d "$intellijidea_path" "https://download.jetbrains.com/idea/ideaIC-2021.2.3.win.zip"
  fi
  [[ ! -f "$intellijidea_path/bin/idea64.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/intellijidea/IntelliJIdea" "$APPS_ROOT/PortableApps/"
  return 0
}
