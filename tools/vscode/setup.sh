#! /usr/bin/env bash

download_vscode() {
  mkdir -vp "$1"
  download_tarball -e -o "VSCode.zip" -d "$1" "https://go.microsoft.com/fwlink/?Linkid=850641"
  # Check updates there https://code.visualstudio.com/updates
  # https://code.visualstudio.com/docs/supporting/faq#_previous-release-versions
  # Use this link and replace {version} for a specific version: https://update.code.visualstudio.com/{version}/win32-x64-archive/stable
}

setup_vscode() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local VSCode="$APPS_ROOT/PortableApps/VSCode"
  local VSCodeData="$APPS_ROOT/PortableApps/VSCodeLauncher/data"
  local WinVSCodeData="$WIN_APPS_ROOT/PortableApps/VSCodeLauncher/data"

  # Check for version upgrade
  if [ -f "$VSCode/Code.exe" ] &&
    ! printf '%s\n%s\n' "$(powershell -Command "(Get-Item -path $WIN_APPS_ROOT/PortableApps/VSCode/Code.exe).VersionInfo.ProductVersion")" "1.74" |
    sort -r --check=quiet --version-sort; then
    upgrade_vscode
  fi

  # Install VSCode
  if [ ! -f "$VSCode/Code.exe" ]; then
    download_vscode "$VSCode"
  fi

  [[ ! -f "$VSCode/Code.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  # Setup VSCode user settings
  local setting_path="$VSCodeData/user-data/User/settings.json"
  if [[ ! -f "$setting_path" || "$(wc -l <"$setting_path")" -le 3 ]]; then
    mkdir -vp "$VSCodeData/user-data/User" "$VSCodeData/extensions"
    echo "Create $setting_path"
    cat >"$setting_path" <<EOM
{
  // BEGIN - GENERATED CONTENT, DO NOT EDIT !!!
  // END - GENERATED CONTENT, DO NOT EDIT !!!

  // Custom settings
  "http.proxyStrictSSL": true
}
EOM
  fi
  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/vscode/VSCodeLauncher" "$APPS_ROOT/PortableApps/"
  rsync -vau "$SETUP_TOOLS_ROOT/vscode/VSCodeUpgrader" "$APPS_ROOT/PortableApps/"

  # Install extensions
  echo "Checking extensions..."
  local tmp_log
  tmp_log=$(mktemp)
  # Get extensions already installed in VSCode
  local installed_extensions
  installed_extensions="$("$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" --list-extensions)"
  local extension
  # Get all default extensions
  declare -A extensions
  for extension in $(git --no-pager config -f "tools/setup.ini" --get-all vscode.extension | grep -vE '^-'); do
    extensions[$extension]=1
  done
  # Handle requested wanted/unwanted extensions
  for extension in $(git --no-pager config -f "$HOME/.common_env.ini" --get-all vscode.extension); do
    extension=$(echo "$extension" | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
    if [[ "$(echo "$extension" | cut -b 1)" == "-" ]]; then
      extension=$(echo "$extension" | cut -b 2-)
      extensions["$extension"]=0
    else
      [[ ! "${extensions["$extension"]}" == "0" ]] && extensions["$extension"]=1
    fi
  done

  # for extension in "${!extensions[@]}"; do
  #   echo "$extension: ${extensions["$extension"]}"
  # done

  # Check extensions
  local certificate_error=0
  local changed_settings_ssl=0
  for extension in "${!extensions[@]}"; do
    [[ "${extensions["$extension"]}" == "0" ]] && continue
    local extension_name=$extension
    if [ "$(echo "$extension" | grep -c ':')" -ne 0 ]; then
      extension_name="$(echo "$extension" | cut -d':' -f2)"
      extension="$(echo "$extension" | cut -d':' -f1)"
    fi
    [ -z "$extension" ] && continue
    echoColor 36 "Checking extension $extension_name..."
    # Install extension if not already installed
    grep -qiE "^$extension_name$" <<<"$installed_extensions" && continue
    if [ $certificate_error -eq 1 ]; then
      [ ! "$(echo "$extension" | tr '.' '\n' | tail -1 | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')" = "vsix" ] &&
        echo "Skipping '$extension' due to certificate error" && continue
    fi
    if ! (set -o pipefail && "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" \
      --install-extension "$extension" 2>&1 | tee "$tmp_log") &&
      [[ "$extension_name" == "$extension" ]] &&
      grep -c -e "unable to get local issuer certificate" -e "self signed certificate in certificate chain" "$tmp_log" &>/dev/null; then
      certificate_error=1
      if grep -c "http.proxyStrictSSL" "$setting_path" &>/dev/null; then
        sed -i -re 's/"http.proxyStrictSSL": true/"http.proxyStrictSSL": false/' "$setting_path" && changed_settings_ssl=1
        "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" --install-extension "$extension" &&
          certificate_error=0 && continue
      fi
      echo "It seems that you have problems with your ssl certificate, you can try to temporarily set the VSCode settings http.proxyStrictSSL to false"
    fi
  done
  #done <<<$(git --no-pager config -f "$HOME/.common_env.ini" --get-all vscode.extension | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g" | grep -vE '^-')
  #done <<< $(cat "$extension_to_install")
  #done < <(cat "$extension_to_install")
  #done <"$extension_to_install"

  # Set VSCode settings with all installed extension
  echo "Configuring settings..."
  local custom_settings
  custom_settings=$(git --no-pager config -f "$HOME/.common_env.ini" --get-all vscode.extension-settings 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
  installed_extensions="$("$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" --list-extensions)"
  # Always remember to double backslash anytime you manipulate the settings content: ... | sed -re 's#\\#\\\\#g'
  local common_settings="$SETUP_TOOLS_ROOT/vscode/settings/settings.json"
  [[ -n "$custom_settings" ]] && [[ -f "$custom_settings/settings.json" ]] && common_settings="$custom_settings/settings.json"
  local settings_content
  settings_content="$(echo -e "\n  // VSCode")\n$(sed '1d;$d' "$common_settings" | sed -re 's#\\#\\\\#g'),"

  local lextension
  local extra_settings_content
  for extension in $installed_extensions; do
    echoColor 36 "Checking $extension..."
    lextension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    local extension_setting="$SETUP_TOOLS_ROOT/vscode/settings/$lextension.json"
    [[ -n "$custom_settings" ]] && [[ -f "$custom_settings/$lextension.json" ]] && extension_setting="$custom_settings/$lextension.json"
    if [[ -f "$extension_setting" ]]; then
      extra_settings_content="$(sed '1d;$d' "$extension_setting" | sed -re 's#\\#\\\\#g'),"
      settings_content=$(echo -e "$settings_content\n\n  // $extension\n$extra_settings_content\n\n" | sed -re 's#\\#\\\\#g')
    fi
  done
  # Update settings
  local settings
  settings="$(cat "$setting_path")"
  echo "$settings" | awk -f "$SETUP_TOOLS_ROOT/shell/bin/generated_content.awk" -v action=replace -v content="$settings_content" >|"$setting_path"
  sed -ri -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" -e "s#%WINDOWS_APPS_ROOT%#$(echo "$WINDOWS_APPS_ROOT" | sed -re 's#\\#\\\\\\\\#g')#g" "$setting_path"
  local remote_machine
  remote_machine="$(git --no-pager config -f "$HOME/.common_env.ini" --get putty.remote-machine 2>/dev/null)"
  [[ -z "$remote_machine" ]] && remote_machine="remote_machine"
  sed -ri -e "s#%REMOTE_MACHINE%#$remote_machine#g" "$setting_path"

  # Setup VSCode key bindings
  local keybindings_path="$VSCodeData/user-data/User/keybindings.json"
  local keybindings="$SETUP_TOOLS_ROOT/vscode/settings/keybindings.json"
  [[ -n "$custom_settings" ]] && [[ -f "$custom_settings/keybindings.json" ]] && keybindings="$custom_settings/keybindings.json"
  [[ ! -f "$keybindings_path" ]] && cp -vf "$keybindings" "$keybindings_path"

  [ $changed_settings_ssl -eq 1 ] && sed -i -re 's/"http.proxyStrictSSL": false/"http.proxyStrictSSL": true/' "$setting_path"
  rm -f "$tmp_log"
}

upgrade_vscode() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local VSCode="$APPS_ROOT/PortableApps/VSCode"
  local backup="$APPS_ROOT/PortableApps_backup"
  tasklist //FI "IMAGENAME eq Code.exe" | grep -q Code.exe && echo "Please close all instances of VSCode before upgrading it" && return "$ERROR"
  if [ -e "$backup/VSCode" ]; then
    rm -rf "$VSCode"
  else
    mkdir -p "$backup"
    mv "$VSCode" "$backup/"
  fi
  download_vscode "$VSCode"
}
