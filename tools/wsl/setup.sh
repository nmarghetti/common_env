#! /usr/bin/env bash

function setup_wsl() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local distribution='Ubuntu-20.04'
  local distribExe='ubuntu2004.exe'

  type wsl &>/dev/null || return "$ERROR"

  # Install wsl
  if wsl --list --quiet | iconv -f utf-16le -t utf-8 | dos2unix | grep -qE "^${distribution}\$"; then
    :
  else
    echoColor 36 "Installing WSL $distribution..."
    if ! powershell.exe "$(cygpath -w "$SETUP_TOOLS_ROOT/wsl/install_wsl.ps1")"; then
      echo "Unable to install $distribution distribution"
      return "$ERROR"
    fi
  fi

  # Ensure WSL does not generate /etc/resolv.conf
  if wsl -d $distribution -u root <<<"cat /etc/resolv.conf" | grep -q 'generateResolvConf'; then
    echoColor 36 "Updating /etc/wsl.conf and restarting distribution $distribution..."
    wsl -d $distribution -u root <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_config_network.sh"
    wsl --terminate $distribution
  fi

  # Setup wsl
  if wsl --list --quiet | iconv -f utf-16le -t utf-8 | dos2unix | grep -qE "^${distribution}\$"; then
    export WSL_USER="${USER:-${USERNAME}}" &&
      WSL_APPS_ROOT="$(cygpath -w "$APPS_ROOT")" &&
      export WSL_APPS_ROOT &&
      WSL_SETUP_TOOLS_ROOT="$(cygpath -w "$SETUP_TOOLS_ROOT")" &&
      export WSL_SETUP_TOOLS_ROOT &&
      echoColor 36 "Configuring WSL $distribution..." && {
      # Configure WSL as root, ensuring to have sudoer user setup etc.
      WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d $distribution -u root <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_root.sh" || return "$ERROR"
      ! wsl -d $distribution -u root <<<"grep -qEe '^$WSL_USER:' /etc/passwd" && echo "$distribution user '$WSL_USER' not found" && return "$ERROR"
      START //B "$distribExe" config --default-user "$WSL_USER"
      # Check user is sudoer etc.
      echoColor 36 "Checking user '$WSL_USER'..."
      WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d $distribution -u "$WSL_USER" <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_user.sh" || return "$ERROR"
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
        echoColor 36 "Running custom root script '$custom_settings/root.sh'..." &&
        WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d $distribution -u root <"$custom_settings/root.sh"
      # Run custom user script
      test -f "$custom_settings/user.sh" &&
        echoColor 36 "Running custom user script '$custom_settings/user.sh'..." &&
        WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d $distribution -u "$WSL_USER" <"$custom_settings/user.sh"
    }
  else
    echo "Unable to find $distribution distribution"
    return "$ERROR"
  fi

  return 0
}
