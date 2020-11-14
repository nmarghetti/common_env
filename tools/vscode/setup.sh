#! /bin/bash

function setup_vscode() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local VSCode="$APPS_ROOT/PortableApps/VSCode"
  local VSCodeData="$APPS_ROOT/PortableApps/VSCodeLauncher/data"
  local WinVSCodeData="$WIN_APPS_ROOT/PortableApps/VSCodeLauncher/data"

  # Install VSCode
  if [ ! -f "$VSCode/Code.exe" ]; then
    mkdir -vp "$VSCode"
    download_tarball -e -o "VSCode.zip" -d "$VSCode" "https://go.microsoft.com/fwlink/?Linkid=850641"
  fi

  [[ ! -f "$VSCode/Code.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Setup VSCode user settings
  local setting_path="$VSCodeData/user-data/User/settings.json"
  if [ ! -f "$setting_path" ]; then
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
  # Setup VSCode key bindings
  local keybindings_path="$VSCodeData/user-data/User/keybindings.json"
  [[ ! -f "$keybindings_path" ]] && cp -vf "$SETUP_TOOLS_ROOT/vscode/keybindings.json" "$keybindings_path"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/vscode/VSCodeLauncher" "$APPS_ROOT/PortableApps/"

  # Install extensions
  echo "Checking extensions..."
  local tmp_log=$(mktemp)
  # Get extensions already installed in VSCode
  local installed_extensions=$(cat <<<$("$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" --list-extensions))
  local extension
  # Get all default extensions
  declare -A extensions
  for extension in $(git --no-pager config -f "tools/setup.ini" --get-all vscode.extension | grep -vE '^-'); do
    extensions[$extension]=1
  done
  # Handle requested wanted/unwanted extensions
  for extension in $(git --no-pager config -f "$HOME/.common_env.ini" --get-all vscode.extension | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g"); do
    if [[ "$(echo "$extension" | cut -b 1)" == "-" ]]; then
      extension=$(echo "$extension" | cut -b 2-)
      extensions["$extension"]=0
    else
      [[ ! "${extensions["$extension"]}" == "0" ]] && extensions["$extension"]=1
    fi
  done

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
    echo ${installed_extensions[@]} | tr ' ' '\n' | grep -iE "^$extension_name$" &>/dev/null && continue
    if [ $certificate_error -eq 1 ]; then
      [ ! "$(echo "$extension" | tr '.' '\n' | tail -1 | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')" = "vsix" ] && echo "Skipping '$extension' due to certificate error" && continue
    fi
    (set -o pipefail && "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" --install-extension "$extension" 2>&1 | tee "$tmp_log")
    if [[ $? -ne 0 ]] && [[ "$extension_name" == "$extension" ]] && grep -c "unable to get local issuer certificate" "$tmp_log" &>/dev/null; then
      certificate_error=1
      if grep -c "http.proxyStrictSSL" "$setting_path" &>/dev/null; then
        sed -i -re 's/"http.proxyStrictSSL": true/"http.proxyStrictSSL": false/' "$setting_path" && changed_settings_ssl=1
        "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" --install-extension "$extension"
        [ $? -eq 0 ] && certificate_error=0 && continue
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
  installed_extensions=$(cat <<<$("$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WinVSCodeData/extensions" --user-data-dir "$WinVSCodeData/user-data" --list-extensions))
  # Always remember to double backslash anytime you manipulate the settings content: ... | sed -re 's#\\#\\\\#g'
  local settings_content="$("$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=content "$SETUP_TOOLS_ROOT/vscode/settings.json" | sed -re 's#\\#\\\\#g')"
  local extension_settings_content
  local lextension
  for extension in $installed_extensions; do
    echoColor 36 "Checking $extension..."
    lextension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    local extension_setting="$SETUP_TOOLS_ROOT/vscode/extensions_settings/$lextension.json"
    if [[ -f "$extension_setting" ]]; then
      extension_settings_content="$(sed '1d;$d' "$extension_setting" | sed -re 's#\\#\\\\#g'),"
      settings_content=$(echo -e "$settings_content\n\n  // $extension\n$extension_settings_content\n\n" | sed -re 's#\\#\\\\#g')
    fi
  done
  # Update settings
  local settings="$(cat "$setting_path")"
  echo "$settings" | "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v content="$settings_content" >|"$setting_path"
  sed -ri -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" "$setting_path"

  [ $changed_settings_ssl -eq 1 ] && sed -i -re 's/"http.proxyStrictSSL": false/"http.proxyStrictSSL": true/' "$setting_path"
  rm -f "$tmp_log"
}
