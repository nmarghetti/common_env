#! /usr/bin/env bash

setup_kind() {
  local ERROR=1
  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-kind.minimum-version || echo "0.26.0")

  if ! type kind >/dev/null 2>&1 || ! printf '%s\n%s\n' "$(kind version | awk '{ print $2}' | sed -re 's/^[^0-9]+(.+)$/\1/')" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    curl -fsSLO "https://kind.sigs.k8s.io/dl/v${minimumVersion}/kind-linux-amd64" &&
      sudo install -m 555 kind-linux-amd64 /usr/local/bin/kind &&
      rm kind-linux-amd64
  fi
  ! type kind >/dev/null 2>&1 && return $ERROR

  # Add kind autocompletion
  grep -qE '^# kind autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# kind autocompletion
. <(kind completion bash)

EOM
  grep -qE '^# kind autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# kind autocompletion
[[ $commands[kind] ]] && source <(kind completion zsh)

EOM

  return 0
}
