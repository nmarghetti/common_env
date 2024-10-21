#! /usr/bin/env bash

setup_gcloud() {
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-gcloud.minimum-version || echo "464.0.0")

  # Install Google Cloud SDK
  if [ ! -f /usr/bin/gcloud ]; then
    [ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ] && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update
    sudo apt-get install -y google-cloud-sdk
  fi
  if ! type gke-gcloud-auth-plugin >/dev/null 2>&1; then
    sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
  fi

  # Upgrade to the minimum required version
  if ! printf '%s\n%s\n' "$(gcloud --version | grep 'Google Cloud SDK' | sed -re 's/^[^0-9]+(.+)$/\1/')" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get -y --only-upgrade install google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
  fi

  return 0
}
