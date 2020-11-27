#! /usr/bin/env bash

function setup_xampp() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local xampp_path="$APPS_ROOT/PortableApps/XAMPP"

  # Install XAMPP
  if [[ ! -f "$xampp_path/xampp/setup_xampp.bat" ]]; then
    mkdir -vp "$xampp_path"
    local tarball=xampp-portable-windows-x64-7.4.2-0-VC15.zip
    download_tarball -e -o "$tarball" -d "$xampp_path" "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/7.4.2/$tarball/download"

    # Initialize
    [[ ! -f "$xampp_path/xampp/xampp_shell.bat" ]] && (cd "$xampp_path/xampp" && "./setup_xampp.bat")
  fi
  [[ ! -f "$xampp_path/xampp/setup_xampp.bat" ]] && echo "Setup file not installed" && return $ERROR

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/xampp/XAMPP" "$APPS_ROOT/PortableApps/"
}
