#! /usr/bin/env bash

WSL_WIN_SETUP_TOOLS_ROOT="$WSL_SETUP_TOOLS_ROOT"
export WSL_WIN_SETUP_TOOLS_ROOT
WSL_SETUP_TOOLS_ROOT="$(wslpath -u "$WSL_SETUP_TOOLS_ROOT")"
export WSL_SETUP_TOOLS_ROOT
WSL_APPS_ROOT="$(wslpath -u "$WSL_APPS_ROOT")"
export WSL_APPS_ROOT

function logColor() {
  color=$1
  shift
  printf "\033[%sm%s\033[0m\n" "$color" "$*" >&2
}

function logError() {
  logColor 31 "$*"
}

main() {
  local ERROR=1

  ! sudo echo "" >/dev/null && echo "Error: '$WSL_USER' user is not sudoer" && return $ERROR

  [ ! -f ~/.wsl_check_domain ] && echo "archive.ubuntu.com" >~/.wsl_check_domain

  tmp=$(mktemp)
  apt list --installed >"$tmp"
  packages=
  for package in jq $(git config -f "$WSL_APPS_ROOT"/home/.common_env.ini wsl-ubuntu.apt-packages); do
    grep -qEe "^$package/" "$tmp" && continue
    packages="$packages $package"
  done
  if [ -n "$packages" ]; then
    logColor 36 "Install packages:$packages"
    # shellcheck disable=SC2086
    sudo apt install -y $packages
  fi

  for tool in $(git config -f "$WSL_APPS_ROOT"/home/.common_env.ini --get-all wsl-ubuntu.app); do
    logColor 36 "Setup wsl $tool"
    [ ! -f "$WSL_SETUP_TOOLS_ROOT/wsl_ubuntu/tools/$tool/setup.sh" ] && logError "Tool '$tool' setup is not supported" && return $ERROR
    # shellcheck disable=SC1090
    ! source "$WSL_SETUP_TOOLS_ROOT/wsl_ubuntu/tools/$tool/setup.sh" && logError "Error while loading '$tool' setup" && return $ERROR
    ! "setup_$tool" && logError "Setup for '$tool' failed" && return $ERROR
  done

  return 0
}

main