#! /usr/bin/env bash

function setup_springtoolsuite() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local sts="$APPS_ROOT/PortableApps/SpringToolSuite"

  # Install STS
  if [ ! -f "$sts/SpringToolSuite4.exe" ]; then
    mkdir -vp "$sts"
    download_tarball -e -o "sts.jar" -m 'sts-4.16.1.RELEASE' -d "$sts" "https://download.springsource.com/release/STS4/4.16.1.RELEASE/dist/e4.25/spring-tool-suite-4-4.16.1.RELEASE-e4.25.0-win32.win32.x86_64.self-extracting.jar"
  fi

  [ ! -f "$sts/SpringToolSuite4.exe" ] && echo "Error: binary is not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/springtoolsuite/SpringToolSuite" "$APPS_ROOT/PortableApps/"

  return 0
}
