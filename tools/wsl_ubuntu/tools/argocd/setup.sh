#! /usr/bin/env bash

# https://argo-cd.readthedocs.io/en/stable/cli_installation/
setup_argocd() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-argocd.version || echo "2.13.3")

  if ! type argocd >/dev/null 2>&1 || [ ! "$(argocd version --client -o json | jq -r '.client.Version' | cut -d+ -f1 | sed -re 's/v?(.*)$/\1/')" = "$wishVersion" ]; then
    curl -sSL -o argocd-linux-amd64 "https://github.com/argoproj/argo-cd/releases/download/v$wishVersion/argocd-linux-amd64"
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

  fi
  ! type argocd >/dev/null 2>&1 && return $ERROR

  # Add argocd autocompletion
  grep -qE '^# argocd autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# argocd autocompletion
command -v argocd >/dev/null && . <(argocd completion bash)

EOM
  grep -qE '^# argocd autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# argocd autocompletion
command -v argocd >/dev/null && . <(argocd completion zsh)

EOM

  return 0
}
