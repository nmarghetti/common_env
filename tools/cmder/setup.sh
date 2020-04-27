#! /bin/bash

function setup_cmder() {
  local ERROR=$SETUP_ERROR_CONTINUE

  cmder_path="$APPS_ROOT/PortableApps/cmder"
  # Install cmder
  if [ ! -f "$cmder_path/Cmder.exe" ]; then
    mkdir -vp "$cmder_path"
    tarball=cmder_mini.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force https://github.com/cmderdev/cmder/releases/download/v1.3.14/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return $ERROR
    fi
    unzip $tarball -d "$cmder_path" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return $ERROR
    echo
    rm -f $tarball
  fi
  if [ ! -f "$cmder_path/Cmder.exe" ]; then
    return $ERROR
  fi
  # Better add Cmder in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/cmder/CmderLauncher" "$APPS_ROOT/PortableApps/"
  if [ ! -f "$APPS_ROOT/PortableApps/CmderLauncher/App/AppInfo/appicon.ico" ]; then
    cp -vf "$APPS_ROOT/PortableApps/cmder/icons/cmder.ico" "$APPS_ROOT/PortableApps/CmderLauncher/App/AppInfo/appicon.ico"
  fi

  if [ ! -f "$APPS_ROOT/PortableApps/cmder/vendor/conemu-maximus5/ConEmu.xml" ]; then
    cp -vf "$SETUP_TOOLS_ROOT/cmder/ConEmu.xml" "$APPS_ROOT/PortableApps/cmder/config/user-ConEmu.xml"
    local remote_machine=$(powershell -Command "Get-ItemPropertyValue -path HKCU:\Software\SimonTatham\PuTTY\Sessions\remote -name HostName" 2>/dev/null)
    local machine_name=$remote_machine
    # keep only machine name if not IP
    [[ ! "$machine_name" =~ ^[0-9.]+$ ]] && machine_name=${machine_name%%.*}
    [[ $? -eq 0 ]] && sed -i -re "s/\{Ssh::remote machine1\}/\{Ssh $machine_name\}/" -e "s/\"label_machine1\"/\"$machine_name\"/" -e "s/ remote_machine1\"/ $remote_machine\"/" "$APPS_ROOT/PortableApps/cmder/config/user-ConEmu.xml"
  fi
}
