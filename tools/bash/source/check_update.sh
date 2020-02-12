#! /bin/sh

function _check_update() {
  cd "$MAIN_BASHRC_ROOT" || return
  git fetch
  if [ $(echo "$(git lgr)" | wc -l) -gt 1 ]; then
    git lgr
    echo "Do you want to update the common env ? (y/N) "
    read answer
    if [[ "$answer" =~ ^[yY]$ ]]; then
      git pull --rebase
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
        read answer
        if [[ "$answer" =~ ^[yY]$ ]]; then
          git rsbo
        fi
      fi
    fi
  fi
}

function check_update() {
  (_check_update)
}

check_update
