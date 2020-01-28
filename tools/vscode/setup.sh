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
  
  # Setup VSCode user settings
  if [ ! -f "$VSCode/data/user-data/User/settings.json" ]; then
    mkdir -vp "$VSCode/data/user-data/User"
    cp -vf "$SETUP_TOOLS_ROOT/vscode/settings.json" "$VSCode/data/user-data/User/"
    sed -ri -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" "$VSCode/data/user-data/User/settings.json"
  fi
  
  # Install extensions
  installed_extensions=$(mktemp)
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
