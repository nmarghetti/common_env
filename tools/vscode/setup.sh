#! /bin/bash

function setup_vscode() {
  VSCode="$APPS_ROOT/PortableApps/VSCode"
  # Install VSCode
  if [ ! -f "$VSCode/Code.exe" ]; then
    mkdir -vp "$VSCode"
    tarball=VSCode-win32-x64-1.44.0.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force -O "$tarball" "https://go.microsoft.com/fwlink/?Linkid=850641"
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    unzip $tarball -d "$VSCode" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
    echo
    rm -f $tarball
  fi

  if [ ! -f "$VSCode/Code.exe" ]; then
    return $SETUP_ERROR_CONTINUE
  fi

  # Setup VSCode user settings
  local setting_path="$APPS_COMMON/VSCode_data/user-data/User/settings.json"
  if [ ! -f "$setting_path" ]; then
    mkdir -vp "$APPS_COMMON/VSCode_data/user-data/User" "$APPS_COMMON/VSCode_data/extensions"
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
  local content="$("$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=content "$SETUP_TOOLS_ROOT/vscode/settings.json" | sed -re 's#\\#\\\\#g')"
  local settings="$(cat "$setting_path")"
  echo "$settings" | "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v content="$content" >|"$setting_path"
  sed -ri -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" "$setting_path"

  # Better add VSCode in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/vscode/VSCodeLauncher" "$APPS_ROOT/PortableApps/"
  # Install extensions
  echo -n "Checking extensions"
  local installed_extensions=$(mktemp)
  local wished_extension=$(mktemp)
  local extension_to_install=$(mktemp)
  local tmp_log=$(mktemp)
  "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WIN_APPS_COMMON/VSCode_data/extensions" --user-data-dir "$WIN_APPS_COMMON/VSCode_data/user-data" --list-extensions >"$installed_extensions"
  # get list extension from ini or text file
  cat "$SETUP_TOOLS_ROOT/vscode/extensions.txt" | cut -d: -f1 | grep -vE '^#' | tr -d ' ' >|"$wished_extension"
  if [ -f "$HOME/.common_env.ini" ] && [ -n "$(git config -f "$HOME/.common_env.ini" --get vscode.extension)" ]; then
    git config -f "$HOME/.common_env.ini" --get-all vscode.extension | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g" >>"$wished_extension"
  fi
  # get list extension not alread installed
  while IFS= read -r extension; do
    echo -n "."
    local extension_name=$extension
    if [ "$(echo "$extension" | grep -c ':')" -ne 0 ]; then
      extension_name="$(echo "$extension" | cut -d':' -f2)"
      extension="$(echo "$extension" | cut -d':' -f1)"
    fi
    [ -z "$extension" ] && continue
    if [ "$(echo "$extension" | cut -b 1)" = "-" ]; then
      extension=$(echo "$extension" | cut -b 2-)
      sed -i -re "/^$extension$/d" "$extension_to_install"
    else
      [ "$(grep -ciE "^$extension_name$" "$installed_extensions")" -eq 0 ] && echo "$extension" >>"$extension_to_install"
    fi
  done <"$wished_extension"
  echo
  # Install new extension
  local certificate_error=0
  local changed_settings_ssl=0
  while IFS= read -r extension; do
    [ -z "$extension" ] && continue
    if [ $certificate_error -eq 1 ]; then
      [ ! "$(echo "$extension" | tr '.' '\n' | tail -1 | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')" = "vsix" ] && echo "Skipping '$extension' due to certificate error" && continue
    fi
    (set -o pipefail && "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WIN_APPS_COMMON/VSCode_data/extensions" --user-data-dir "$WIN_APPS_COMMON/VSCode_data/user-data" --install-extension "$extension" 2>&1 | tee "$tmp_log")
    if [ $? -ne 0 ] && [ ! "$extension_name" = "$extension" ] && grep -c "unable to get local issuer certificate" "$tmp_log" &>/dev/null; then
      certificate_error=1
      if grep -c "http.proxyStrictSSL" "$setting_path" &>/dev/null; then
        sed -i -re 's/"http.proxyStrictSSL": true/"http.proxyStrictSSL": false/' "$setting_path" && changed_settings_ssl=1
        "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WIN_APPS_COMMON/VSCode_data/extensions" --user-data-dir "$WIN_APPS_COMMON/VSCode_data/user-data" --install-extension "$extension"
        [ $? -eq 0 ] && certificate_error=0 && continue
      fi
      echo "It seems that you have problems with your ssl certificate, you can try to temporarily set the VSCode settings http.proxyStrictSSL to false"
    fi
  done <"$extension_to_install"
  [ $changed_settings_ssl -eq 1 ] && sed -i -re 's/"http.proxyStrictSSL": false/"http.proxyStrictSSL": true/' "$setting_path"
  #done <<< $(cat "$extension_to_install")
  #done < <(cat "$extension_to_install")
  rm -f "$installed_extensions"
  rm -f "$wished_extension"
  rm -f "$extension_to_install"
  rm -f "$tmp_log"
}
