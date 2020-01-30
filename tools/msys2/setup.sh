#! /bin/sh

# Check documentation https://github.com/msys2/msys2/wiki/MSYS2-installation
# https://solarianprogrammer.com/2019/11/05/install-gcc-windows/
function setup_msys2() {
  # Install MSYS2
  msys2_path="$APPS_ROOT/PortableApps/CommonFiles/msys64"
  if [ ! -f "$msys2_path/msys2.exe" ]; then
    tarball=msys2-base-x86_64-20190524.tar.xz
    if [ ! -f $tarball ]; then
      wget --progress=bar:force http://repo.msys2.org/distrib/x86_64/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    tar -xvf $tarball -C "$APPS_ROOT/PortableApps/CommonFiles/" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
    echo
    rm -f $tarball
  fi
  
  # Install GCC
  if [ ! -f "$msys2_path/mingw64/bin/g++.exe" ]; then
    "$msys2_path/msys2_shell.cmd"
    echo "Wait for the terminal to finish its installation, close it and press enter."
    read
    
    for i in $(seq 5); do
      "$msys2_path/msys2_shell.cmd" -no-start -c 'pacman -Syuu'
      echo "$i/5 Wait for the terminal to finish its installation and press enter."
      read
    done
    
    echo "Installing gcc"
    echo "Press enter to select all and enter again to proceed with the installation"
    "$msys2_path/msys2_shell.cmd" -no-start -c 'pacman -S mingw-w64-x86_64-toolchain'
  fi
  
}
