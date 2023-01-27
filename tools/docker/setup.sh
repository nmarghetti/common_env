#! /usr/bin/env bash

function setup_docker() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local docker="$PROGRAMFILES/Docker/Docker/resources/bin/docker.exe"
  local dockerDesktop="$PROGRAMFILES/Docker/Docker/Docker Desktop.exe"
  local upgrade=0

  # Check for version upgrade
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get docker.minimum-version || echo "4.16.2")
  if [ -f "$dockerDesktop" ] &&
    ! printf '%s\n%s\n' "$(powershell -Command "(Get-Command '$dockerDesktop').Version -join \".\"")" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    upgrade=1
  fi

  # Install docker
  if ! type docker >/dev/null 2>&1 || [ "$upgrade" = "1" ]; then
    local tarball=docker_desktop_installer.exe
    download_tarball -o "$tarball" "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=header"
    ./"$tarball" install --quiet
    rm -f "$tarball"
  fi

  [ ! -f "$docker" ] && echo "Binary file not installed" && return "$ERROR"

  return 0
}
