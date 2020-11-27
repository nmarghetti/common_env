#! /usr/bin/env bash

function setup_gradle() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local gradle_path="$APPS_COMMON/gradle"

  # Install Gradle
  if [[ ! -f "$gradle_path/bin/gradle" ]]; then
    mkdir -vp "$gradle_path"
    download_tarball -e -d "$gradle_path" -m "gradle-6.7.1" "https://services.gradle.org/distributions/gradle-6.7.1-bin.zip"
  fi
  [[ ! -f "$gradle_path/bin/gradle" ]] && echo "Binary file not installed" && return $ERROR

  return 0
}
