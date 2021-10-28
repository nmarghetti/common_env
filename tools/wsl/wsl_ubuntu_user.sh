#! /usr/bin/env bash

main() {
  ! sudo echo "" >/dev/null && echo "Error: '$WSL_USER' user is not sudoer" && return 1
  return 0
}

main
