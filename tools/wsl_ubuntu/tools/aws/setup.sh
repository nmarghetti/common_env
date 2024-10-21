#! /usr/bin/env bash

setup_aws() {
  ! type zip >/dev/null 2>&1 && sudo apt install -y zip
  if ! type aws >/dev/null 2>&1; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&
      unzip awscliv2.zip &&
      sudo ./aws/install &&
      rm -rf aws awscliv2.zip
  fi

  return 0
}
