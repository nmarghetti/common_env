#! /usr/bin/env bash

# https://github.com/flux-subsystem-argo/flamingo?tab=readme-ov-file#install-clis
setup_flamingo() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-flamingo.version || echo "0.10.2")

  if ! type flamingo >/dev/null 2>&1 || [ ! "$(flux version --client -o json | jq -r '.flux' | sed -re 's/v?(.*)$/\1/')" = "$wishVersion" ]; then
    curl -sS https://fluxcd.io/install.sh | sudo FLUX_VERSION="$wishVersion" bash

  fi
  ! type flux >/dev/null 2>&1 && return $ERROR

  # Add flux autocompletion
  grep -qE '^# flux autocompletion$' ~/.bashrc || cat >>~/.bashrc <<EOM
# flux autocompletion
command -v flux >/dev/null && . <(flux completion bash)

EOM
  grep -qE '^# flux autocompletion$' ~/.zshrc || cat >>~/.zshrc <<'EOM'
# flux autocompletion
command -v flux >/dev/null && . <(flux completion zsh)

EOM

  return 0
}
