#! /bin/bash

echo "Setting up podman machine"

if [ -n "$WSL_CA_BUNDLE" ]; then
  bundle="/etc/pki/ca-trust/source/anchors/$(basename "$WSL_CA_BUNDLE")"
  if [ ! -f "$bundle" ] || ! cmp --silent "$WSL_CA_BUNDLE" "$bundle"; then
    sudo cp -vf "$WSL_CA_BUNDLE" "$bundle"
    sudo update-ca-trust
  fi
fi

if ! type podman-compose &>/dev/null; then
  sudo dnf update -y
  sudo dnf install -y git podman-compose
fi
