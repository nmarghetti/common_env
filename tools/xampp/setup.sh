#! /bin/sh

function setup_xampp() {
  xampp_path="$APPS_ROOT/PortableApps/XAMPP/App/xampp"
  # Install NodeJs
  if [ ! -f "$xampp_path/setup_xampp.bat" ]; then
    tarball=xampp-portable-windows-x64-7.4.2-0-VC15.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force -O $tarball https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/7.4.2/$tarball/download
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    unzip $tarball -d "$APPS_ROOT/PortableApps/XAMPP/App/" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
    echo
    rm -f $tarball
  fi
  if [ ! -f "$xampp_path/setup_xampp.bat" ]; then
    return $SETUP_ERROR_CONTINUE
  fi
  if [ ! -f "$xampp_path/xampp_shell.bat" ]; then
    (cd "$xampp_path" && "./setup_xampp.bat")
  fi
}
