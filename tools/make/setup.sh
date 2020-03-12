#! /bin/bash

function setup_make() {
  make_path="$APPS_ROOT/PortableApps/CommonFiles/make"
  mkdir -p "$make_path"
  # Install make
  if [ ! -f "$make_path/bin/make.exe" ]; then
    tarball=make.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force -O $tarball http://gnuwin32.sourceforge.net/downlinks/make-bin-zip.php
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    unzip $tarball -d "$APPS_ROOT/PortableApps/CommonFiles/make" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
    echo
    rm -f $tarball
  fi
  # Install make dependencies
  if [ ! -f "$make_path/bin/libiconv2.dll" ]; then
    tarball=make_deps.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force -O $tarball http://gnuwin32.sourceforge.net/downlinks/make-dep-zip.php
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    unzip $tarball -d "$APPS_ROOT/PortableApps/CommonFiles/make" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
    echo
    rm -f $tarball
  fi
}
