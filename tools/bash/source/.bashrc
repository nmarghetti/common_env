MAIN_BASHRC=${BASH_SOURCE[0]}
if [ -z "$MAIN_BASHRC" ] || [ "$MAIN_BASHRC" = "bash" ]; then
  MAIN_BASHRC=$0
fi
MAIN_BASHRC_ROOT=$(dirname $(readlink -f "${MAIN_BASHRC}"))

[ "$COMMON_ENV_DEBUG" = "1" ] && echo "Sourcing $MAIN_BASHRC ..." >&2

# Get some function to get some shell system information
source "${MAIN_BASHRC_ROOT}/system.sh"
current_shell="$(system_get_current_shell)"

# If current shell is BASH
if [ "$current_shell" = "bash" ]; then
  source "${MAIN_BASHRC_ROOT}/path.sh"

  # ********** BEGIN - Specific for Windows platform with PortableApps **********
  export APPS_ROOT=$(cd && cd .. && pwd)
  if [ -d "$APPS_ROOT/PortableApps" ]; then
    if [ -z "$BASH_VERSION" ]; then
      echo "ERROR !!! You are are not sourcing with bash, you might encounter problem !!!" >&2
    fi

    export MSYS_SHELL=$APPS_ROOT/PortableApps/CommonFiles/msys64/msys2_shell.cmd

    pathAppend "${APPS_ROOT}/PortableApps/CommonFiles/msys64/mingw64/bin" 2>/dev/null
    # pathAppend "${APPS_ROOT}/PortableApps/CommonFiles/msys64/usr/bin" 2>/dev/null
    pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/cmake/bin" 2>/dev/null
    pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/make/bin" 2>/dev/null
    pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/node" 2>/dev/null
    pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/python/Scripts"
    pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/python"
    pathPrepend "${APPS_ROOT}/PortableApps/PortableGit/bin"
    pathPrepend "${HOME}/bin"

    if [ ! "$COMMON_ENV_GIT_PROMPT" = "0" ]; then
      # If shell is in interactive mode
      case $- in
        *i*)
          # Git Prompt
          # For more information; check thoses files:
          # ${APPS_ROOT}/PortableApps/PortableGit/etc/profile.d/git-prompt.sh
          # ${APPS_ROOT}/PortableApps/PortableGit/mingw64/share/git/completion/git-prompt.sh
          export GIT_PS1_SHOWDIRTYSTATE=1
          export GIT_PS1_SHOWSTASHSTATE=1
          export GIT_PS1_SHOWUPSTREAM="auto"
          if [ ! "$(type -t __git_ps1)" = "function" ]; then
            source "${APPS_ROOT}/PortableApps/PortableGit/etc/profile.d/git-prompt.sh"
          fi
        ;;
      esac
    fi

    alias tsource="source '${MAIN_BASHRC_ROOT}/../bin/sourcetool' '${HOME}/bin'"
    alias cddev="cd ${APPS_ROOT}/Documents/dev"

    # source pythonvenv set 3.8.1
  else
    unset APPS_ROOT
  fi
  # ********** END - Specific for Windows platform with PortableApps **********

  alias esource='echo "$HOME/.bashrc"'
  alias vsource='vi "$HOME/.bashrc"'
  alias rsource='source "$HOME/.bashrc"'
  alias csource='cat "$HOME/.bashrc"'
  alias setup_common_env="'${MAIN_BASHRC_ROOT}/../../../scripts/setup.sh'"

# If current shell is ZSH
elif [ "$current_shell" = "zsh" ]; then
  source "${MAIN_BASHRC_ROOT}/path_zsh.sh"
else
  echo "Unsupported shell '$current_shell', exiting." >&2
  return 1
fi

# Function to update git repo
source "${MAIN_BASHRC_ROOT}/check_update.sh"

# Ensure terminal output are UTF8 https://www.debian.org/doc/manuals/fr/debian-fr-howto/ch3.html
export LC_ALL=C.UTF-8
export LESSCHARSET=UTF-8

# Common alias
alias vvsource="vi '$MAIN_BASHRC_ROOT/.bashrc'"
alias vvgit="vi '$MAIN_BASHRC_ROOT/../../git/.gitconfig'"
alias vgit='vi "$HOME/.gitconfig"'
alias gitv='vi .git/config'
alias egit='echo "$HOME/.gitconfig"'
alias ugit="bash '${MAIN_BASHRC_ROOT}/../bin/update_git_config.sh'"
alias rgit="ugit -f"
alias ls='ls --color=auto'
alias la='ls -lhA'
alias ll='ls -lh'

# Python env management
alias pylist='pythonvenv list'
alias pycreate='pythonvenv create'
alias pyset='source pythonvenv set'
alias pyunset='deactivate 2>/dev/null'

# Do some checks only if not done since at least 24h
COMMON_ENV_LAST_CHECK="$HOME/.common_env_check"
if [ ! -f "$COMMON_ENV_LAST_CHECK" ] || [ $(expr $(date +%s) - $(date -r "$COMMON_ENV_LAST_CHECK" +%s)) -ge 86400 ]; then
  touch "$COMMON_ENV_LAST_CHECK"

  # Refresh tool links
  source "${MAIN_BASHRC_ROOT}/../bin/sourcetool" "${HOME}/bin"

  # Check for update if access to github
  pingopt="-c"
  if [ "$OSTYPE" = "msys" ]; then
    pingopt="-n"
  fi
  ping $pingopt 1 -w 1 github.com &>/dev/null && common_env_check_update

  # Update git config
  type rgit &>/dev/null && rgit
else
  export PATH=$PATH:$HOME/bin
fi

[ "$COMMON_ENV_DEBUG" = "1" ] && echo "$MAIN_BASHRC sourced"
