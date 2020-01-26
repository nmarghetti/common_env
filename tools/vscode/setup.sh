#! /bin/sh

function setup_vscode() {
  if [ $("$APPS_ROOT/PortableApps/VSCode/bin/code" --list-extensions 2>/dev/null | wc -l) -eq 0 ]; then
    tarball=VSCode-win32-x64-1.41.1.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force https://az764295.vo.msecnd.net/stable/26076a4de974ead31f97692a0d32f90d735645c0/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    VSCode="$APPS_ROOT/PortableApps/VSCode"
    if [ ! -d "$VSCode" ]; then
      mkdir -vp "$VSCode"
      unzip $tarball -d "$VSCode" | awk 'BEGIN {ORS="."} {print "."}'
      test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
      echo
    fi
    rm -f $tarball
    mkdir -vp "$VSCode/data/user-data/User"
    cp -vf "$SETUP_TOOLS_ROOT/vscode/settings.json" "$VSCode/data/user-data/User/"
    sed -ri -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" "$VSCode/data/user-data/User/settings.json"
    
    while IFS=: read -r extension; do
      "$APPS_ROOT/PortableApps/VSCode/bin/code" --install-extension $extension
    done < "$SETUP_TOOLS_ROOT/vscode/extensions.txt"
    #done <<< $(cat "$SCRIPT_ROOT/data/crypted_files.txt")
    #done < <(cat "$SCRIPT_ROOT/data/crypted_files.txt")
  fi
}
