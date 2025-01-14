#! /usr/bin/env bash

setup_aws() {
  local ERROR=1

  ! type zip >/dev/null 2>&1 && sudo apt install -y zip
  if ! type aws >/dev/null 2>&1; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&
      unzip awscliv2.zip &&
      sudo ./aws/install &&
      rm -rf aws awscliv2.zip
  fi
  ! type aws >/dev/null 2>&1 && return $ERROR
  # Add aws autocompletion
  grep -qE '^# aws autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# aws autocompletion
complete -C '$(which aws_completer)' aws

EOM

  return 0
}
