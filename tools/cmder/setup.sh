#! /bin/bash

function setup_cmder() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local cmder_path="$APPS_ROOT/PortableApps/cmder"

  # Install cmder
  if [[ ! -f "$cmder_path/Cmder.exe" ]]; then
    mkdir -vp "$cmder_path"
    download_tarball -e -d "$cmder_path" "https://github.com/cmderdev/cmder/releases/download/v1.3.14/cmder_mini.zip"
  fi
  [[ ! -f "$cmder_path/Cmder.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/cmder/CmderLauncher" "$APPS_ROOT/PortableApps/"
  if [[ ! -f "$APPS_ROOT/PortableApps/CmderLauncher/App/AppInfo/appicon.ico" ]]; then
    cp -vf "$APPS_ROOT/PortableApps/cmder/icons/cmder.ico" "$APPS_ROOT/PortableApps/CmderLauncher/App/AppInfo/appicon.ico"
  fi

  if [[ ! -f "$APPS_ROOT/PortableApps/cmder/vendor/conemu-maximus5/ConEmu.xml" ]]; then
    cp -vf "$SETUP_TOOLS_ROOT/cmder/ConEmu.xml" "$APPS_ROOT/PortableApps/cmder/config/user-ConEmu.xml"
    local remote_machine=$(powershell -Command "Get-ItemPropertyValue -path HKCU:\Software\SimonTatham\PuTTY\Sessions\remote -name HostName" 2>/dev/null)
    local machine_name=$remote_machine
    # Keep only machine name if not IP
    [[ ! "$machine_name" =~ ^[0-9.]+$ ]] && machine_name=${machine_name%%.*}
    [[ $? -eq 0 ]] && sed -i -re "s/\{Ssh::remote machine1\}/\{Ssh $machine_name\}/" -e "s/\"label_machine1\"/\"$machine_name\"/" -e "s/ remote_machine1\"/ $remote_machine\"/" "$APPS_ROOT/PortableApps/cmder/config/user-ConEmu.xml"
  fi
}
