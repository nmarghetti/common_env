#! /usr/bin/env bash

function setup_docker() {
  local ERROR=$SETUP_ERROR_CONTINUE

  # Install docker
  if ! type docker >/dev/null 2>&1; then
    local tarball=docker_desktop_installer.exe
    download_tarball -o "$tarball" "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=header"
    ./"$tarball" install --quiet
  fi
  [ ! -f "$PROGRAMFILES/Docker/Docker/resources/bin/docker.exe" ] && echo "Binary file not installed" && return "$ERROR"
  return 0
}
