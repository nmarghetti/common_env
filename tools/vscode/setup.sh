#! /bin/bash

function setup_vscode() {
  VSCode="$APPS_ROOT/PortableApps/VSCode"
  # Install VSCode
  if [ ! -f "$VSCode/Code.exe" ]; then
    mkdir -vp "$VSCode"
    tarball=VSCode-win32-x64-1.43.2.zip
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
// To have some extension working, do not forget to update your system PATH:
// %APPS_ROOT%/PortableApps/PortableGit/bin;%APPS_ROOT%/home/.venv/3.1.0;%APPS_ROOT%/home/.venv/3.1.0/Scripts
{
  // BEGIN - GENERATED CONTENT, DO NOT EDIT !!!
  // END - GENERATED CONTENT, DO NOT EDIT !!!

}
EOM
  fi
  local content="$("$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=content "$SETUP_TOOLS_ROOT/vscode/settings.json" | sed -re 's#\\#\\\\#g')"
  local settings="$(cat "$setting_path")"
  echo "$settings" | "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v content="$content" >|"$setting_path"
  sed -ri -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" "$setting_path"

  # Better add VSCode in PortableApps menu
  if [ -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/rsync.exe" ]; then
    rsync -vau "$SETUP_TOOLS_ROOT/vscode/VSCodeLauncher" "$APPS_ROOT/PortableApps/"
  fi
  # Install extensions
  local installed_extensions=$(mktemp)
  "$APPS_ROOT/PortableApps/VSCode/bin/code" --list-extensions >"$installed_extensions"
  local ini_extensions=
  [ -f "$HOME/.common_env.ini" ] && ini_extensions="$(git config -f "$HOME/.common_env.ini" --get-all vscode.extension | tr '\n' ' ' | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")"
  if [ -n "$ini_extensions" ]; then
    for extension in $ini_extensions; do
      [ "$(grep -ciE "^$extension$" "$installed_extensions")" -eq 0 ] && "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WIN_APPS_COMMON/VSCode_data/extensions" --user-data-dir "$WIN_APPS_COMMON/VSCode_data/user-data" --install-extension $extension
    done
  else
    while IFS=: read -r extension extra; do
      extension=$(echo "$extension" | tr -d '[:space:]')
      [ -z "$extension" ] && continue
      [ "$(echo $extension | cut -b 1)" = "#" ] && continue
      [ "$(grep -ciE "^$extension$" "$installed_extensions")" -eq 0 ] && "$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WIN_APPS_COMMON/VSCode_data/extensions" --user-data-dir "$WIN_APPS_COMMON/VSCode_data/user-data" --install-extension $extension
    done <"$SETUP_TOOLS_ROOT/vscode/extensions.txt"
    #done <<< $(cat "$SETUP_TOOLS_ROOT/vscode/extensions.txt")
    #done < <(cat "$SETUP_TOOLS_ROOT/vscode/extensions.txt")
  fi
  rm -f "$installed_extensions"
}
