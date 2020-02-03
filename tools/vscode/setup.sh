#! /bin/sh

function setup_vscode() {
  VSCode="$APPS_ROOT/PortableApps/VSCode"
  # Install VSCode
  if [ ! -f "$VSCode/Code.exe" ]; then
    mkdir -vp "$VSCode"
    tarball=VSCode-win32-x64-1.41.1.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force https://az764295.vo.msecnd.net/stable/26076a4de974ead31f97692a0d32f90d735645c0/$tarball
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
  local setting_path="$VSCode/data/user-data/User/settings.json"
  if [ ! -f "$setting_path" ]; then
    mkdir -vp "$VSCode/data/user-data/User"
    echo "Create $setting_path"
    cat > "$setting_path" << EOM
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
  echo "$settings" | "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v content="$content" >| "$setting_path"
  sed -ri -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" "$setting_path"


  # Install extensions
  local installed_extensions=$(mktemp)
  "$APPS_ROOT/PortableApps/VSCode/bin/code" --list-extensions > "$installed_extensions"
  while IFS=: read -r extension extra; do
    extension=$(echo "$extension" | tr -d '[:space:]')
    if [ "$(grep -ciE "^$extension$" "$installed_extensions")" -eq 0 ]; then
      "$APPS_ROOT/PortableApps/VSCode/bin/code" --install-extension $extension
    fi
  done < "$SETUP_TOOLS_ROOT/vscode/extensions.txt"
  #done <<< $(cat "$SCRIPT_ROOT/data/crypted_files.txt")
  #done < <(cat "$SCRIPT_ROOT/data/crypted_files.txt")
  rm -f "$installed_extensions"
}
