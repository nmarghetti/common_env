#! /bin/bash

function check_repo_update() {
  if [ ! -z "$1" ]; then
    cd "$1" || return
  fi
  echo "Checking for update on $PWD..." >&2
  git status &>/dev/null || return
  git fetch
  if [ $(git log --format=oneline HEAD..origin/$(git symbolic-ref --short HEAD) -1 | wc -l) -gt 0 ]; then
    git --no-pager lgr && echo
    echo "Do you want to update $PWD ? (y/N) "
    read -r answer
    if [[ "$answer" =~ ^[yY]$ ]]; then
      git pullr
      ret=$?
      case $ret in
      128)
        echo
        ;; # Unstaged changes
      1)
        echo
        echo "Rebase failed, aborting it..."
        git rba
        ;;
      esac
      if [ $ret -ne 0 ]; then
        echo "Do you want to hardly set it to remote (you would lose all local changes) ? (y/N) "
        read -r answer
        if [[ "$answer" =~ ^[yY]$ ]]; then
          git rsbo
        fi
      fi
    fi
  else
    echo "Up to date." >&2
  fi
}

function common_env_check_update() {
  (check_repo_update "$MAIN_BASHRC_ROOT/../../..")
}
