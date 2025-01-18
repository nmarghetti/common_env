#! /usr/bin/env bash

setup_minikube() {
  local ERROR=1
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-minikube.minimum-version || echo "1.34.0")

  if ! type minikube >/dev/null 2>&1 || ! printf '%s\n%s\n' "$(minikube version --short | sed -re 's/^[^0-9]+(.+)$/\1/')" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    sudo curl -fsSLO "https://storage.googleapis.com/minikube/releases/v${minimumVersion}/minikube-linux-amd64" &&
      sudo install -m 555 minikube-linux-amd64 /usr/local/bin/minikube &&
      rm minikube-linux-amd64
  fi
  ! type minikube >/dev/null 2>&1 && return $ERROR

  # Add minikube autocompletion
  grep -qE '^# minikube autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# minikube autocompletion
. <(minikube completion bash)

EOM
  grep -qE '^# minikube autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# minikube autocompletion
[[ $commands[minikube] ]] && source <(minikube completion zsh)

EOM

  return 0
}
