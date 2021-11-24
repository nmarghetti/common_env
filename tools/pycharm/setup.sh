#! /usr/bin/env bash

# https://www.jetbrains.com/help/pycharm/installation-guide.html#standalone
function setup_pycharm() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local pycharm_path="$APPS_ROOT/PortableApps/PyCharm"
  local win_pycharm_path=$(get_path_to_windows_back "$pycharm_path")

  # Install PyCharm
  if [[ ! -f "$pycharm_path/bin/pycharm64.exe" ]]; then
    mkdir -vp "$pycharm_path"
    local tarball=pycharm-community-2020.1.exe
    download_tarball "https://download.jetbrains.com/python/$tarball"
    [[ $? -ne 0 ]] && echo "Unable to get the installer" && return $ERROR
    $tarball //S /LOG=install.log /CONFIG=$WINDOWS_SETUP_TOOLS_ROOT\\pycharm\\edu_silent.config /D=$win_pycharm_path
    # rm -f $tarball
  fi
  [[ ! -f "$pycharm_path/bin/pycharm64.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/pycharm/PyCharmLauncher" "$APPS_ROOT/PortableApps/"

  # Setup relative path
  local idea_properties="$pycharm_path/bin/idea.properties"
  if ! grep PyCharmLauncher "$idea_properties"; then
    sed -i -re 's@^# idea.config.path=.*$@idea.config.path=${idea.home.path}/../PyCharmLauncher/PyCharmCE/config@' "$idea_properties"
    sed -i -re 's@^# idea.system.path=.*$@idea.system.path=${idea.home.path}/../PyCharmLauncher/PyCharmCE/system@' "$idea_properties"
    sed -i -re 's@^# idea.plugins.path=.*$@idea.plugins.path=${idea.home.path}/../PyCharmLauncher/PyCharmCE/plugins@' "$idea_properties"
    sed -i -re 's@^# idea.log.path=.*$@idea.log.path=${idea.home.path}/../PyCharmLauncher/PyCharmCE/log@' "$idea_properties"
  fi

  local terminal_option="$APPS_ROOT/PortableApps/PyCharmLauncher/PyCharmCE/config/options/terminal.xml"
  local jdktable_option="$APPS_ROOT/PortableApps/PyCharmLauncher/PyCharmCE/config/options/jdk.table.xml"
  # Add those file only if the folder already exist (PyCharm already started and initialized)
  # mkdir -vp "$(dirname "$terminal_option")"
  if [[ -d "$(dirname "$terminal_option")" ]]; then
    [[ ! -f "$terminal_option" ]] && sed -re "s#%APPS_ROOT%#$(echo "$WINDOWS_APPS_ROOT" | sed -re "s#\\\\#\\\\\\\\#g")#" "$SETUP_TOOLS_ROOT/pycharm/terminal.xml" >"$terminal_option"
    [[ ! -f "$jdktable_option" ]] && sed -re "s#%WINDOWS_APPS_ROOT%#$(echo "$WINDOWS_APPS_ROOT" | sed -re "s#\\\\#\\\\\\\\#g")#" -e "s#%WIN_APPS_ROOT%#$WIN_APPS_ROOT#" "$SETUP_TOOLS_ROOT/pycharm/jdk.table.xml" >"$jdktable_option"
  fi

  return 0
}
