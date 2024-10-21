#! /usr/bin/env bash

setup_kubectl() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-kubectl.version || echo "1.31.0")

  if ! type kubectl >/dev/null 2>&1 || [ ! "$(kubectl version --client=true -o json | jq -r '.clientVersion.gitVersion' | sed -re 's/^v?(.*)$/\1/')" = "$wishVersion" ]; then
    curl -LO "https://dl.k8s.io/release/v${wishVersion}/bin/linux/amd64/kubectl.sha256" &&
      curl -LO "https://dl.k8s.io/release/v${wishVersion}/bin/linux/amd64/kubectl" &&
      echo "$(cat kubectl.sha256) kubectl" | sha256sum --check &&
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&
      rm kubectl kubectl.sha256
  fi
  ! type kubectl >/dev/null 2>&1 && return $ERROR

  # Add kubectl autocompletion
  grep -qE '^# kubectl autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# kubectl autocompletion
. <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k

EOM
  grep -qE '^# kubectl autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# kubectl autocompletion
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

EOM

  return 0
}
