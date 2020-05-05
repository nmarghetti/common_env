#! /bin/bash

function setup_cmake() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local cmake_path="$APPS_COMMON/cmake"

  # Install cmake
  if [[ ! -f "$cmake_path/bin/cmake.exe" ]]; then
    mkdir -vp "$cmake_path"
    download_tarball -e -d "$cmake_path" -m cmake-3.16.3-win64-x64 "https://github.com/Kitware/CMake/releases/download/v3.16.3/cmake-3.16.3-win64-x64.zip"
  fi
  [[ ! -f "$cmake_path/bin/cmake.exe" ]] && echo "Binary file not installed" && return $ERROR

  return 0
}
