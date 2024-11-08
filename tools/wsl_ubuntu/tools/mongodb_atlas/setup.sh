#! /usr/bin/env bash

setup_mongodb_atlas() {
  local ERROR=1

  if ! type atlas >/dev/null 2>&1; then
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc |
      sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    # keep jammy instead of $(lsb_release -cs)
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" |
      sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-atlas-cli
  fi
  ! type atlas >/dev/null 2>&1 && return $ERROR

  # Add atlas autocompletion
  grep -qE '^# atlas autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# atlas autocompletion
. <(atlas completion bash)

EOM
  grep -qE '^# atlas autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# atlas autocompletion
[[ $commands[atlas] ]] && source <(atlas completion zsh)

EOM

  return 0
}
