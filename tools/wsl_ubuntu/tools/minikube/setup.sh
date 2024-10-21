#! /usr/bin/env bash

setup_minikube() {
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-minikube.minimum-version || echo "1.34.0")

  if ! type minikube >/dev/null 2>&1 || ! printf '%s\n%s\n' "$(minikube version --short | sed -re 's/^[^0-9]+(.+)$/\1/')" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 &&
      sudo install minikube-linux-amd64 /usr/local/bin/minikube &&
      rm minikube-linux-amd64
  fi

  return 0
}
