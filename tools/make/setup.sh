#! /usr/bin/env bash

function setup_make() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local make_path="$APPS_COMMON/make"

  # Install make
  if [[ ! -f "$make_path/bin/make.exe" ]]; then
    mkdir -vp "$make_path"
    download_tarball -e -o "make.zip" -d "$make_path" "http://gnuwin32.sourceforge.net/downlinks/make-bin-zip.php"
  fi
  [[ ! -f "$make_path/bin/make.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Install make dependencies
  if [ ! -f "$make_path/bin/libiconv2.dll" ]; then
    download_tarball -e -o "make_deps.zip" -d "$make_path" "http://gnuwin32.sourceforge.net/downlinks/make-dep-zip.php"
  fi
  [[ ! -f "$make_path/bin/libiconv2.dll" ]] && echo "Dll file not installed" && return $ERROR

  return 0
}
