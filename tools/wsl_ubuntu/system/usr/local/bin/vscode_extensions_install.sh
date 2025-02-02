#! /usr/bin/env bash

log() {
  printf "%s\n" "$*" >>~/.wsl_portable/vscode-extensions.log
}

main() {
  # Check if code is available, it should be available only while under VSCode terminal while connected to WSL
  ! type code 2>/dev/null | grep -q '.vscode-server' && return 1

  local lock_file=~/.wsl_portable/vscode-extensions.lock
  if (set -o noclobber && echo -e "DATE:$(date)\nUSER:$(whoami)\nPID:$$" >"$lock_file") 2>/dev/null; then
    trap "rm -f '$lock_file'; exit \$?" INT TERM HUP EXIT

    # Ensure log file does not grow too much
    [ "$(wc -l <~/.wsl_portable/vscode-extensions.log)" -ge 1000 ] &&
      tail -n +700 <~/.wsl_portable/vscode-extensions.log >~/.wsl_portable/vscode-extensions.log.tmp &&
      mv ~/.wsl_portable/vscode-extensions.log.tmp ~/.wsl_portable/vscode-extensions.log

    # Log the datetime
    log
    log "$(date +%Y_%m_%d-%H-%M)"

    [ ! -f ~/.wsl_portable/vscode-wished-extensions.txt ] && log "$HOME/.wsl_portable/vscode-wished-extensions.txt does not exist" && return 0
    if [ -f ~/.wsl_portable/vscode-extensions.txt ] && diff ~/.wsl_portable/vscode-extensions.txt ~/.wsl_portable/vscode-wished-extensions.txt &>/dev/null; then
      log "All extensions already installed"
      return 0
    fi

    code --list-extensions | tail -n +2 >~/.wsl_portable/vscode-installed-extensions.txt
    local installed_extensions

    # Retrieve installed extensions
    declare -A installed_extensions=()
    while read -r extension; do
      installed_extensions+=(["$extension"]="1")
    done <~/.wsl_portable/vscode-installed-extensions.txt

    # Check wished extension and install if needed
    : >~/.wsl_portable/vscode-extensions.txt
    while read -r extension; do
      if [[ -v installed_extensions["$extension"] ]]; then
        echo "$extension" >>~/.wsl_portable/vscode-extensions.txt
      else
        if log "$(code --install-extension "$extension" 2>&1)"; then
          echo "$extension" >>~/.wsl_portable/vscode-extensions.txt
        else
          log "Unable to install $extension"
        fi
      fi
    done <~/.wsl_portable/vscode-wished-extensions.txt
  else
    # If the lock is older than 5min, just remove it
    if [ -f "$lock_file" ] && [ "$(($(date +%s) - $(date -r "$lock_file" +%s)))" -ge 300 ]; then
      log "Lock older than 5 min, releasing lock '$lock_file'"
      rm -f "$lock_file"
    fi
  fi
}

main
