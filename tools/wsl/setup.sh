#! /usr/bin/env bash

function setup_wsl() {
  local ERROR=$SETUP_ERROR_CONTINUE

  type wsl &>/dev/null || return "$ERROR"

  # Setup wsl Ubuntu
  if wsl --list | iconv -f utf-16le -t utf-8 | dos2unix | grep -qE '^Ubuntu$'; then
    export WSL_USER="${USER:-${USERNAME}}" &&
      WSL_APPS_ROOT="$(cygpath -w "$APPS_ROOT")" &&
      export WSL_APPS_ROOT &&
      WSL_SETUP_TOOLS_ROOT="$(cygpath -w "$SETUP_TOOLS_ROOT")" &&
      export WSL_SETUP_TOOLS_ROOT &&
      echo "Configuring WSL Ubuntu..." && {
      # Configure WSL as root, ensuring to have sudoer user setup etc.
      WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d Ubuntu -u root <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_root.sh" || return "$ERROR"
      ! wsl -d Ubuntu -u root <<<"grep -qEe '^$WSL_USER:' /etc/passwd" && echo "Ubuntu user '$WSL_USER' not found" && return "$ERROR"
      START //B ubuntu config --default-user "${USER:-${USERNAME}}"
      # Check user is sudoer etc.
      echo "Checking user '$WSL_USER'..."
      WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d Ubuntu -u "$WSL_USER" <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_user.sh" || return "$ERROR"
      # Add some scheduler tasks to ensure cisco network connectivity
      if tasklist //FI "IMAGENAME eq vpnui.exe" | grep -q vpnui.exe; then
        if [ "$(powershell -Command 'Get-ScheduledTask -TaskPath "\wsl\"' | grep -c 'wsl')" -lt 4 ]; then
          echo "Adding tasks to the scheduler to ensure network connectivity"
          "$SETUP_TOOLS_ROOT"/wsl/import_tasks.sh
        fi
      fi
      local custom_settings
      custom_settings=$(git --no-pager config -f "$HOME/.common_env.ini" --get-all wsl.settings 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
      # Run custom root script
      test -f "$custom_settings/root.sh" &&
        echo "Running custom root script '$custom_settings/root.sh'..." &&
        WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d Ubuntu -u root <"$custom_settings/root.sh"
      # Run custom user script
      test -f "$custom_settings/user.sh" &&
        echo "Running custom user script '$custom_settings/user.sh'..." &&
        WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d Ubuntu -u "$WSL_USER" <"$custom_settings/user.sh"
    }
  else
    echo "Unable to find Ubuntu distribution"
    return "$ERROR"
  fi

  return 0
}
