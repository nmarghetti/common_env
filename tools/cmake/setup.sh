#! /bin/bash

function setup_cmake() {
  cmake_path="$APPS_ROOT/PortableApps/CommonFiles/cmake"
  # Install cmake
  if [ ! -f "$cmake_path/bin/cmake.exe" ]; then
    tarball=cmake-3.16.3-win64-x64.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force https://github.com/Kitware/CMake/releases/download/v3.16.3/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    unzip $tarball -d "$APPS_ROOT/PortableApps/CommonFiles/" | awk 'BEGIN {ORS="."} {print "."}'
    mv "$APPS_ROOT/PortableApps/CommonFiles/$(basename $tarball .zip)" "$cmake_path"
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
    echo
    rm -f $tarball
  fi
}
