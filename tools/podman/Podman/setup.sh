#! /usr/bin/env bash

function setup_podman() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local distribution='podman-machine-portable'

  ! type podman &>/dev/null && echo "podman not installed, either installation failed, either you need to restart the computer first" && return "$ERROR"

  ! type wsl &>/dev/null && echo "WSL not installed" && return "$ERROR"

  # Install podman machine
  if ! wsl --list --quiet | iconv -f utf-16le -t utf-8 | dos2unix | grep -qE "^${distribution}\$"; then
    podman machine init --rootful --user-mode-networking --now $distribution
  fi

  if [ -z "$(podman machine info -f json | jq '.Host.MachineState' | xargs echo)" ]; then
    podman machine start $distribution
  fi

  if [ -z "$(podman machine info -f json | jq '.Host.MachineState' | xargs echo)" ]; then
    echo "Unable to start podman machine"
    return "$ERROR"
  fi

  local ca_bundle
  ca_bundle="$(git config -f "$APPS_ROOT/home/.common_env.ini" install.cacert | sed -re 's#%APPS_ROOT%#'"$(echo "$APPS_ROOT" | sed -re 's#/#\\/#g')"'#')"
  if [ -f "$ca_bundle" ]; then
    ca_bundle=$(cygpath -w "$ca_bundle")
  else
    ca_bundle=
  fi

  # Setup podman machine
  script=$(mktemp)
  cat >"$script" <<-EOF
#! /bin/bash
WSL_APPS_ROOT="$(cygpath -w "$APPS_ROOT")"
WSL_APPS_ROOT="\$(wslpath -u "\$WSL_APPS_ROOT")"
export WSL_APPS_ROOT
WSL_CA_BUNDLE='$ca_bundle'
[ -n "\$WSL_CA_BUNDLE" ] && WSL_CA_BUNDLE="\$(wslpath -u "\$WSL_CA_BUNDLE")"

$(cat "$APPS_ROOT/PortableApps/Podman/podman_setup.sh")
EOF
  podman machine ssh $distribution <"$script" || return "$ERROR"
  rm -f "$script"
  return 0
}

APPS_ROOT=$(cd "$APPS_ROOT" && pwd)
export APPS_ROOT
setup_podman
