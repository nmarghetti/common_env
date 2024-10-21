#! /usr/bin/env bash

setup_helm() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-helm.version || echo "3.16.2")

  if ! type helm >/dev/null 2>&1 || [ ! "$(helm version --template='{{.Version}}' | sed -re 's/^v?(.*)$/\1/')" = "$wishVersion" ]; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 &&
      chmod +x get_helm.sh &&
      ./get_helm.sh --version "v$wishVersion" &&
      rm get_helm.sh
  fi
  ! type helm >/dev/null 2>&1 && return $ERROR

  # Add helm autocompletion
  grep -qE '^# helm autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# helm autocompletion
. <(helm completion bash)

EOM
  grep -qE '^# helm autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# helm autocompletion
[[ $commands[helm] ]] && source <(helm completion zsh)

EOM

  return 0
}
