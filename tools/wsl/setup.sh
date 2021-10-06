#! /usr/bin/env bash

function setup_wsl() {
  local ERROR=$SETUP_ERROR_CONTINUE

  type wsl &>/dev/null || return "$ERROR"

  # Setup wsl Ubuntu
  wsl --list | iconv -f utf-16le -t utf-8 | dos2unix | grep -qE '^Ubuntu$' &&
    export WSL_USER="${USER:-${USERNAME}}" &&
    export WSL_HOME="//mnt$(get_path_to_posix "$HOME")" &&
    export WSL_APPS_ROOT="//mnt$(get_path_to_posix "$APPS_ROOT")" &&
    export WSL_REMOTE_MACHINE="$remote_machine" &&
    echo "Configuring WSL Ubuntu..." && {
    WSLENV=WSL_USER:WSL_HOME:WSL_APPS_ROOT:WSL_REMOTE_MACHINE:/p wsl -d Ubuntu -u root <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_root.sh"
    START //B ubuntu config --default-user "${USER:-${USERNAME}}"
    WSLENV=WSL_USER:WSL_HOME:WSL_APPS_ROOT:WSL_REMOTE_MACHINE:/p wsl -d Ubuntu -u root <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_user.sh"
    if [ "$(powershell -Command 'Get-ScheduledTask -TaskPath "\wsl\"' | grep -c 'wsl')" -lt 4 ]; then
      "$SETUP_TOOLS_ROOT"/wsl/import_tasks.sh
    fi
    local custom_settings
    custom_settings=$(git --no-pager config -f "$HOME/.common_env.ini" --get-all wsl.settings 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
    test -f "$custom_settings/root.sh" && WSLENV=WSL_USER:WSL_HOME:WSL_APPS_ROOT:WSL_REMOTE_MACHINE:/p wsl -d Ubuntu -u root <"$custom_settings/root.sh"
    test -f "$custom_settings/user.sh" && WSLENV=WSL_USER:WSL_HOME:WSL_APPS_ROOT:WSL_REMOTE_MACHINE:/p wsl -d Ubuntu -u root <"$custom_settings/user.sh"
  }

  return 0
}
