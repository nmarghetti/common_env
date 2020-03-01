#! /bin/sh

function check_repo_update() {
  if [ ! -z "$1" ]; then
    cd "$1" || return
  fi
  git st &>/dev/null || return
  git f 2>/dev/null
  if [ $(echo "$(git lgr 2>/dev/null)" | wc -l) -gt 1 ]; then
    GIT_PAGER=cat git lgr 2>/dev/null && echo
    echo "Do you want to update $PWD ? (y/N) "
    read answer
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
        read answer
        if [[ "$answer" =~ ^[yY]$ ]]; then
          git rsbo
        fi
      fi
    fi
  fi
}

function check_update() {
  (check_repo_update "$MAIN_BASHRC_ROOT/../../..")
}

check_update
