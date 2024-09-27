#! /usr/bin/env bash

function setup_wsl_ubuntu() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local distribution
  distribution="$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl-ubuntu.distribution || echo 'Ubuntu-20.04')"

  type wsl &>/dev/null || return "$ERROR"

  # Install wsl
  if wsl --list --quiet | iconv -f utf-16le -t utf-8 | dos2unix | grep -qE "^${distribution}\$"; then
    :
  else
    echoColor 36 "Installing WSL $distribution..."
    if ! powershell.exe "$(cygpath -w "$SETUP_TOOLS_ROOT/wsl/install_wsl.ps1")" "$distribution"; then
      echo "Unable to install $distribution distribution"
      return "$ERROR"
    fi
  fi

  # Ensure WSL does not generate /etc/resolv.conf
  if wsl -d "$distribution" -u root <<<"cat /etc/resolv.conf" | grep -q 'generateResolvConf'; then
    echoColor 36 "Updating /etc/wsl.conf and restarting distribution $distribution..."
    wsl -d "$distribution" -u root <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_config_network.sh"
    wsl --terminate "$distribution"
  fi

  # Ensure the network is well setup if needed
  natNetwork=$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl.nat-network 2>/dev/null)
  natGatewayIp=$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl.gateway-ip-address 2>/dev/null)
  if [ -n "$natNetwork" ] && [ -n "$natGatewayIp" ]; then
    currentNatNetwork="$(powershell -Command "Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork")"
    currentNatGatewayIp="$(powershell -Command "Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress")"
    if [ ! "$currentNatNetwork" = "$natNetwork" ] || [ ! "$currentNatGatewayIp" = "$natGatewayIp" ]; then
      powershell.exe -ExecutionPolicy RemoteSigned -Command "$WINDOWS_SETUP_TOOLS_ROOT/wsl/update_network.ps1" "$natNetwork" "$natGatewayIp"
    fi
  fi

  # Setup wsl
  if wsl --list --quiet | iconv -f utf-16le -t utf-8 | dos2unix | grep -qE "^${distribution}\$"; then
    export WSL_USER="${USER:-${USERNAME}}" &&
      WSL_APPS_ROOT="$(cygpath -w "$APPS_ROOT")" &&
      export WSL_APPS_ROOT &&
      WSL_SETUP_TOOLS_ROOT="$(cygpath -w "$SETUP_TOOLS_ROOT")" &&
      export WSL_SETUP_TOOLS_ROOT &&
      echoColor 36 "Configuring WSL $distribution..." && {

      # Remove pyenv from the path as it seems to conflict under WSL
      local path
      for path in "$HOME/.pyenv/pyenv-win/bin" "$HOME/.pyenv/pyenv-win/shims"; do
        if echo "$PATH" | tr ':' '\n' | grep -qFx "$path"; then
          PATH="$(echo "$PATH" | tr ':' '\n' | sed -e "/$(echo "$path" | sed -re 's#/#\\/#g')\$/d" | tr '\n' ':')"
        fi
      done

      # Configure WSL as root, ensuring to have sudoer user setup etc.
      WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d "$distribution" -u root <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_root.sh" || return "$ERROR"
      ! wsl -d "$distribution" -u root <<<"grep -qEe '^$WSL_USER:' /etc/passwd" && echo "$distribution user '$WSL_USER' not found" && return "$ERROR"
      # Check user is sudoer etc.
      echoColor 36 "Checking user '$WSL_USER'..."
      WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d "$distribution" -u "$WSL_USER" <"$SETUP_TOOLS_ROOT/wsl/wsl_ubuntu_user.sh" || return "$ERROR"
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
      if test -f "$custom_settings/root.sh" &&
        echoColor 36 "Running custom root script '$custom_settings/root.sh'..."; then
        WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d "$distribution" -u root <"$custom_settings/root.sh" || return "$ERROR"
      fi
      # Run custom user script
      if test -f "$custom_settings/user.sh" &&
        echoColor 36 "Running custom user script '$custom_settings/user.sh'..."; then
        WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d "$distribution" -u "$WSL_USER" <"$custom_settings/user.sh" || return "$ERROR"
      fi
    }
  else
    echo "Unable to find $distribution distribution"
    return "$ERROR"
  fi

  # Upgrade the distribution if needed
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl.minimum-version || echo "24.04")
  if ! printf '%s\n%s\n' "$(wsl -d "$distribution" bash -c 'lsb_release -sr')" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    echoColor 36 "Upgrading WSL Ubuntu..."
    wsl -d "$distribution" bash -c 'sudo apt update && sudo apt full-upgrade -y' &&
      wsl --terminate "$distribution" &&
      wsl -d "$distribution" bash -c 'sudo do-release-upgrade' &&
      wsl -d "$distribution" bash -c 'sudo apt autoremove -y'
  fi

  return 0
}
