#! /bin/bash
# https://portableapps.com/manuals/PortableApps.comLauncher/ref/paf/appinfo.html
function setup_portableapps() {

  app_path="$APPS_ROOT/PortableApps/PortableApps.com"
  # Setup PortableApps
  [ ! -f "$app_path/PortableAppsPlatform.exe" ] && echo "Error: PortableApps not installed" && return 1

  # Convert ini file to the encoding used by PortableApps
  local charset=$(file -i "$app_path/Data/PortableAppsMenu.ini" | cut -d';' -f2 | cut -d'=' -f2)
  [ "$charset" = "binary" ] && charset="utf-8"
  if [ "$(grep -c '\[AppsHidden\]' "$app_path/Data/PortableAppsMenu.ini")" -eq 0 ]; then
    iconv -f utf-8 -t $charset "$SETUP_TOOLS_ROOT/portableapps/PortableAppsMenu.ini" >|"$app_path/Data/PortableAppsMenu.ini"
    cat "$SETUP_TOOLS_ROOT/portableapps/AppsHidden.ini" | iconv -f utf-8 -t $charset >>"$app_path/Data/PortableAppsMenu.ini"
  else
    local begin=$(grep -n AppsHidden "$APPS_ROOT/PortableApps/PortableApps.com/Data/PortableAppsMenu.ini" | head -1 | cut -d':' -f1)
    local end=$(tail -n +$(expr $begin + 1) "$APPS_ROOT/PortableApps/PortableApps.com/Data/PortableAppsMenu.ini" | grep -nE '^\[' | head -1 | cut -d':' -f1)
    local nend=$end
    if [ -n "$nend" ]; then
      nend=$(expr $nend - 1)
    else
      nend=$(tail -n +$(expr $begin + 1) "$APPS_ROOT/PortableApps/PortableApps.com/Data/PortableAppsMenu.ini" | wc -l)
    fi
    local tmp_file=$(mktemp --suffix=.ini)
    local tmp_hidden=$(mktemp --suffix=.ini)
    head -$begin "$APPS_ROOT/PortableApps/PortableApps.com/Data/PortableAppsMenu.ini" >|"$tmp_file"
    tail -n +$(expr $begin + 1) "$APPS_ROOT/PortableApps/PortableApps.com/Data/PortableAppsMenu.ini" | head -$nend | tr -d '\r' >|"$tmp_hidden"
    tail -n +2 "$SETUP_TOOLS_ROOT/portableapps/AppsHidden.ini" >>"$tmp_hidden"
    cat "$tmp_hidden" | sort | uniq | sed -re 's/^(.*)$/\1\r/' >>"$tmp_file"
    [ -n "$end" ] && tail -n +$(expr $begin + $end) "$APPS_ROOT/PortableApps/PortableApps.com/Data/PortableAppsMenu.ini" >>"$tmp_file"
    cat "$tmp_file" >|"$APPS_ROOT/PortableApps/PortableApps.com/Data/PortableAppsMenu.ini"
    rm -f "$tmp_hidden"
    rm -f "$tmp_file"
  fi

  return 0
}
