#! /bin/bash

# https://portableapps.com/manuals/PortableApps.comLauncher/ref/launcher.ini/launch.html
# https://portableapps.com/manuals/PortableApps.comLauncher/ref/paf/appinfo.html
# https://portableapps.com/development/portableapps.com_format#appinfo
function setup_portableapps() {
  app_path="$APPS_ROOT/PortableApps/PortableApps.com"
  # Setup PortableApps
  [ ! -f "$app_path/PortableAppsPlatform.exe" ] && echo "Error: PortableApps not installed" && return 1

  # It can be done only at the beginning, git config does not support special character in section name
  if [ "$(grep -c '\[AppsHidden\]' "$app_path/Data/PortableAppsMenu.ini")" -eq 0 ]; then
    # Convert ini file to current encoding used
    local charset=$(file -i "$app_path/Data/PortableAppsMenu.ini" | cut -d';' -f2 | cut -d'=' -f2)
    [ "$charset" = "binary" ] && charset="utf-8"
    iconv -f utf-8 -t $charset "$SETUP_TOOLS_ROOT/portableapps/PortableAppsMenu.ini" >|"$app_path/Data/PortableAppsMenu.ini"
  fi

}
