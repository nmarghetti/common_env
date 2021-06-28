#! /usr/bin/env bash

function setup_java() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local java_path="$APPS_COMMON/java"

  # Install java
  if [[ ! -f "$java_path/bin/java.exe" ]]; then
    mkdir -vp "$java_path"
    # download_tarball -e -d "$java_path" -m "jdk-16.0.1" -k 'Cookie: oraclelicense=141' \
    #   "https://download.oracle.com/otn-pub/java/jdk/16.0.1+9/7147401fd7354114ac51ef3e1328291f/jdk-16.0.1_windows-x64_bin.zip"

    # Retrieve version to install
    local java_version
    java_version="$(git --no-pager config -f "$HOME/.common_env.ini" --get java.version || echo 16)"

    case "$java_version" in
      8)
        download_tarball -e -d "$java_path" -m "jdk8u292-b10" \
          "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_windows_hotspot_8u292b10.zip"
        ;;
      11)
        download_tarball -e -d "$java_path" -m "jdk-11.0.11+9" \
          "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_windows_hotspot_11.0.11_9.zip"
        ;;
      *)
        download_tarball -e -d "$java_path" -m "jdk-16.0.1+9" \
          "https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jdk_x64_windows_hotspot_16.0.1_9.zip"
        ;;
    esac
  fi
  [[ ! -f "$java_path/bin/java.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  return 0
}
