#! /usr/bin/env bash

setup_lens() {
  if [ ! -f /usr/bin/lens ]; then
    wget "https://downloads.k8slens.dev/ide/$(curl -sL https://api.k8slens.dev/binaries/latest-linux.json | jq .path | xargs echo | sed 's/x86_64.AppImage/amd64.deb/')" -O lens.deb
    sudo apt install -y ./lens.deb
  fi

  return 0
}
