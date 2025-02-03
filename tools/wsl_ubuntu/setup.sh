#! /usr/bin/env bash

# Due to the fact WSL returns DOS EOL and that we want to log the output and display it in the terminal
# It is done like that to read each line and have the script run progressively
# That would buffer it all with dos2unix, tr, sed, awk, etc.
wsl_output() {
  while read -r line; do
    # Go back at the beggining of the line for the output to be displayed properly in the terminal
    tput cr
    printf "%s\n" "$line"
  done
}

function setup_wsl_ubuntu() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local ubuntuVersion
  local distribution
  local freshInstall=0
  local setupNatNetwork=0
  local natNetwork
  local natGatewayIp
  local wslUserHomeSize

  ubuntuVersion="$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl-ubuntu.distribution || echo 'Ubuntu-24.04')"
  wslUserHomeSize="$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl-ubuntu.home-size || echo '172')"
  distribution="$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl-ubuntu.name || echo "${ubuntuVersion}-portable")"
  natNetwork=$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl-ubuntu.nat-network 2>/dev/null)
  natGatewayIp=$(git --no-pager config -f "$HOME/.common_env.ini" --get wsl-ubuntu.gateway-ip-address 2>/dev/null)

  mkdir -p "$APPS_ROOT/PortableApps/$ubuntuVersion" || return "$ERROR"

  type wsl &>/dev/null || return "$ERROR"

  # Add the menu entry in PortableApps
  rsync -vau "$SETUP_TOOLS_ROOT/wsl_ubuntu/Ubuntu/App" "$APPS_ROOT/PortableApps/$ubuntuVersion"
  rsync -au "$APPS_ROOT/PortableApps/PortableApps.com/App/Graphics/AppIcons/CommandPromptPortable.ico" "$APPS_ROOT/PortableApps/$ubuntuVersion/App/AppInfo/appicon.ico"
  rsync -au "$APPS_ROOT/PortableApps/PortableApps.com/App/Graphics/AppIcons/CommandPromptPortable.ico" "$APPS_ROOT/PortableApps/$ubuntuVersion/App/AppInfo/appicon1.ico"
  # shellcheck disable=SC2016
  ubuntuVersion=$ubuntuVersion envsubst '${ubuntuVersion}' <"$SETUP_TOOLS_ROOT/wsl_ubuntu/Ubuntu/App/AppInfo/appinfo.ini" >"$APPS_ROOT/PortableApps/$ubuntuVersion/App/AppInfo/appinfo.ini"
  # shellcheck disable=SC2016
  appsRoot=$WINDOWS_APPS_ROOT ubuntuVersion=$ubuntuVersion distribution=$distribution wslUser=${USER:-$USERNAME} wslUserHomeSize=$wslUserHomeSize envsubst '${appsRoot},${ubuntuVersion},${distribution},${wslUser},${wslUserHomeSize}' <"$SETUP_TOOLS_ROOT/wsl_ubuntu/Ubuntu/launch.cmd" >"$APPS_ROOT/PortableApps/$ubuntuVersion/launch.cmd"

  # Ensure the network is well setup if needed
  if [ -n "$natNetwork" ] && [ -n "$natGatewayIp" ]; then
    currentNatNetwork="$(powershell -Command "Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork")"
    currentNatGatewayIp="$(powershell -Command "Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress")"
    if [ ! "$currentNatNetwork" = "$natNetwork" ] || [ ! "$currentNatGatewayIp" = "$natGatewayIp" ]; then
      setupNatNetwork=1
    fi
  fi

  # Install wsl
  if ! wsl --list --quiet | iconv -f utf-16le -t utf-8 2>&1 | dos2unix | grep -qE "^${distribution}\$" || [ ! -f "$APPS_ROOT/home/wsl.vhdx" ] || [ $setupNatNetwork -eq 1 ]; then
    echoColor 36 "Installing WSL $distribution..."
    freshInstall=1
    if ! powershell.exe "$(cygpath -w "$SETUP_TOOLS_ROOT/wsl_ubuntu/install_wsl.ps1")" -UbuntuVersion "$ubuntuVersion" -InstallName "$distribution" -InstallPath "$WINDOWS_APPS_ROOT\\PortableApps\\$ubuntuVersion" -InstallUserHome "$WINDOWS_APPS_ROOT\\home\\wsl.vhdx" -NatNetwork "'$natNetwork'" -NatGatewayIp "'$natGatewayIp'" -UserHomeSize "$wslUserHomeSize"; then
      echo "Unable to install $ubuntuVersion distribution"
      return "$ERROR"
    fi
  fi

  # Ensure to have wsl up to date
  wsl --update

  # Setup wsl
  if wsl --list --quiet | iconv -f utf-16le -t utf-8 2>&1 | dos2unix | grep -qE "^${distribution}\$"; then
    export WSL_USER="${USER:-${USERNAME}}" &&
      WSL_APPS_ROOT="$(cygpath -w "$APPS_ROOT")" &&
      export WSL_APPS_ROOT &&
      WSL_SETUP_TOOLS_ROOT="$(cygpath -w "$SETUP_TOOLS_ROOT")" &&
      export WSL_SETUP_TOOLS_ROOT &&
      export WSL_USER_HOME_SIZE=$wslUserHomeSize &&
      echoColor 36 "Configuring WSL $distribution..." && {

      # Remove pyenv from the path as it seems to conflict under WSL
      local path
      for path in "$HOME/.pyenv/pyenv-win/bin" "$HOME/.pyenv/pyenv-win/shims"; do
        if echo "$PATH" | tr ':' '\n' | grep -qFx "$path"; then
          PATH="$(echo "$PATH" | tr ':' '\n' | sed -e "/$(echo "$path" | sed -re 's#/#\\/#g')\$/d" | tr '\n' ':')"
        fi
      done

      # Configure WSL as root, ensuring to have sudoer user setup etc.
      echoColor 36 "Checking WSL system with '$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_root.sh' check"
      if ! (set -o pipefail && WSL_ACTION=check WSLENV=WSL_ACTION:WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:WSL_USER_HOME_SIZE:/p wsl -d "$distribution" -u root <"$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_root.sh" 2>&1 | wsl_output); then
        echoColor 36 "Initializing WSL system with '$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_root.sh' init"
        (set -o pipefail && WSL_ACTION=init WSLENV=WSL_ACTION:WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:WSL_USER_HOME_SIZE:/p wsl -d "$distribution" -u root <"$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_root.sh" 2>&1 | wsl_output) || return "$ERROR"
        wsl --terminate "$distribution"
      fi

      # Ensure to mount the user home disk
      if ! wsl -d "$distribution" -u root bash -c "lsblk | grep -q '${wslUserHomeSize}'"; then
        echoColor 36 "Mounting user home disk"
        ! powershell.exe "$(cygpath -w "$SETUP_TOOLS_ROOT/wsl_ubuntu/Ubuntu/App/setup.ps1")" -InstallName "$distribution" -InstallUserHome "$WINDOWS_APPS_ROOT\\home\\wsl.vhdx" && echo "Unable to mount the user home disk" && return "$ERROR"
        wsl --terminate "$distribution"
        ! wsl -d "$distribution" -u root bash -c "lsblk | grep -q '${wslUserHomeSize}'" && echo "Unable to mount the user home disk" && return "$ERROR"
      fi

      # Configure WSL as root, ensuring to have sudoer user setup etc.
      echoColor 36 "Configuring root with '$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_root.sh' full"
      (set -o pipefail && WSL_ACTION=full WSLENV=WSL_ACTION:WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:WSL_USER_HOME_SIZE:/p wsl -d "$distribution" -u root <"$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_root.sh" 2>&1 | wsl_output) || return "$ERROR"
      ! wsl -d "$distribution" -u root <<<"grep -qEe '^$WSL_USER:' /etc/passwd" && echo "$distribution user '$WSL_USER' not found" && return "$ERROR"

      # Restart the distribution for a fresh install
      if [ "$freshInstall" -eq 1 ]; then
        wsl --terminate "$distribution"
      fi

      # Check user is sudoer etc.
      echoColor 36 "Checking user '$WSL_USER' with '$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_user.sh'"
      (set -o pipefail && WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d "$distribution" -u "$WSL_USER" <"$SETUP_TOOLS_ROOT/wsl_ubuntu/wsl_ubuntu_user.sh" 2>&1 | wsl_output) || return "$ERROR"

      local custom_settings
      custom_settings=$(git --no-pager config -f "$HOME/.common_env.ini" --get-all wsl-ubuntu.settings 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
      # Run custom root script
      if test -f "$custom_settings/root.sh" &&
        echoColor 36 "Running custom root script '$custom_settings/root.sh'..."; then
        (set -o pipefail && WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d "$distribution" -u root <"$custom_settings/root.sh" 2>&1 | wsl_output) || return "$ERROR"
      fi
      # Run custom user script
      if test -f "$custom_settings/user.sh" &&
        echoColor 36 "Running custom user script '$custom_settings/user.sh'..."; then
        (set -o pipefail && WSLENV=WSL_USER:WSL_APPS_ROOT:WSL_SETUP_TOOLS_ROOT:/p wsl -d "$distribution" -u "$WSL_USER" <"$custom_settings/user.sh" 2>&1 | wsl_output) || return "$ERROR"
      fi

      # Add VSCode extensions to install under WSL
      if git config -f ~/.common_env.ini --get-all install.app | grep -qFx 'vscode'; then
        local extensions
        extensions="$(git config -f ~/.common_env.ini --get-all vscode-wsl-ubuntu.extension)"
        if [ -n "$extensions" ]; then
          echoColor 36 "Sending VSCode extensions to install under WSL"
          wsl -d "$distribution" -u "$WSL_USER" bash -c "echo '""$extensions""' > ~/.wsl_portable/vscode-wished-extensions.txt"
        fi
      fi
    }
  else
    echo "Unable to find $distribution distribution"
    return "$ERROR"
  fi

  return 0
}
