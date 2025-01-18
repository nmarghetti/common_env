#! /usr/bin/env bash

# https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
setup_terraform() {
  local ERROR=1
  if ! type terraform >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg |
      gpg --dearmor |
      sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
    gpg --no-default-keyring \
      --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
      --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
      sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt-get install terraform
    terraform -install-autocomplete
  fi
  ! type terraform >/dev/null 2>&1 && return $ERROR

  # Add terraform autocompletion
  grep -qE '^# terraform autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# terraform autocompletion
complete -C /usr/bin/terraform terraform

EOM
  grep -qE '^# terraform autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# terraform autocompletion
complete -C /usr/bin/terraform terraform

EOM

  return 0
}
