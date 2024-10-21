#! /usr/bin/env bash

setup_yq() {
  local ERROR=1

  if ! type yq >/dev/null 2>&1; then
    sudo curl -L -o /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/bin/yq
  fi
  ! type yq >/dev/null 2>&1 && return $ERROR

  return 0
}
