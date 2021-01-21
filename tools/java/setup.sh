#! /usr/bin/env bash

function setup_java() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local java_path="$APPS_COMMON/java"

  # Install java
  if [[ ! -f "$java_path/bin/java.exe" ]]; then
    mkdir -vp "$java_path"
    download_tarball -e -d "$java_path" -m "jdk-15.0.2" -k 'Cookie: oraclelicense=141' \
      "https://download.oracle.com/otn-pub/java/jdk/15.0.2+7/0d1cfde4252546c6931946de8db48ee2/jdk-15.0.2_windows-x64_bin.zip"
  fi
  [[ ! -f "$java_path/bin/java.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  return 0
}
