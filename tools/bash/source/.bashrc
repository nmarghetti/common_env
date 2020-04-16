MAIN_BASHRC=${BASH_SOURCE[0]}
if [ -z "$MAIN_BASHRC" ] || [ "$MAIN_BASHRC" = "bash" ]; then
  MAIN_BASHRC=$0
fi
MAIN_BASHRC_ROOT=$(dirname "$(readlink -f "${MAIN_BASHRC}")")

[ "$COMMON_ENV_DEBUG" = "1" ] && echo "Sourcing '$MAIN_BASHRC' ..." >&2
export COMMON_ENV_DEBUG_CMD="[ \"\$COMMON_ENV_FULL_DEBUG\" = \"1\" ] && { system_trace_debug() { echo \"DEBUG: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; system_trace_error() { echo \"ERROR: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; trap 'system_trace_debug \"\$?\" \"\$BASH_COMMAND\" ' DEBUG;  trap 'system_trace_error \"\$?\" \"\$BASH_COMMAND\" ' ERR; }"
[ "$COMMON_ENV_FULL_DEBUG" = "1" ] && eval "$COMMON_ENV_DEBUG_CMD"

# Get some function to get some shell system information
source "${MAIN_BASHRC_ROOT}/system.sh"
current_shell="$(system_get_current_shell)"

# Check the shell used
if [ "$current_shell" = "bash" ] || [ "$current_shell" = "zsh" ]; then
  :
else
  echo "Unsupported shell '$current_shell', exiting." >&2
  return 1
fi

# If host system is Windows
if [ "$(system_get_os_host)" = "Windows" ]; then
  # Get some function to convert Windows path
  source "${MAIN_BASHRC_ROOT}/path_windows.sh"
  alias rrsource='COMMON_ENV_FORCE_CHECK=1 rsource'
fi

# Add some tools in ~/bin if not there yet
if [ ! -e "${HOME}/bin/toolupdatelink" ]; then
  mkdir -p "${HOME}/bin"
  source "${MAIN_BASHRC_ROOT}/../bin/sourcetool" "${HOME}/bin"
fi

# Setup basic config based on the shell
if [ "$current_shell" = "bash" ]; then
  shopt -s expand_aliases
  bind '"\e[5~"':history-search-backward # Page up to look backward in history
  bind '"\e[6~"':history-search-forward  # Page up to look forward in history

  source "${MAIN_BASHRC_ROOT}/path.sh"
elif [ "$current_shell" = "zsh" ]; then
  setopt aliases

  source "${MAIN_BASHRC_ROOT}/path_zsh.sh"
fi

# In case of bash is not recent enough
# pathPrepend "${HOME}/bin"
export PATH="${HOME}/bin:$PATH"

# If current shell is BASH
if [ "$current_shell" = "bash" ]; then

  # ********** BEGIN - Specific for Windows platform with PortableApps **********
  export APPS_ROOT=$(cd && cd .. && pwd)
  if [ -d "$APPS_ROOT/PortableApps" ]; then
    if [ -z "$BASH_VERSION" ]; then
      echo "ERROR !!! You are are not sourcing with bash, you might encounter problem !!!" >&2
    fi

    export APPS_COMMON="$APPS_ROOT/PortableApps/CommonFiles"
    export WIN_APPS_ROOT="$(get_path_to_windows "$APPS_ROOT")"
    export WIN_APPS_COMMON="$(get_path_to_windows "$APPS_COMMON")"
    export WINDOWS_APPS_ROOT="$(echo "$WIN_APPS_ROOT" | tr '/' '\\')"
    export WINDOWS_APPS_COMMON="$(echo "$WIN_APPS_COMMON" | tr '/' '\\')"
    export MSYS_SHELL=$APPS_COMMON/msys64/msys2_shell.cmd

    pathAppend "$APPS_COMMON/msys64/mingw64/bin" 2>/dev/null
    # pathAppend "$APPS_COMMON/msys64/usr/bin" 2>/dev/null
    pathPrepend "$APPS_COMMON/cmake/bin" 2>/dev/null
    pathPrepend "$APPS_COMMON/make/bin" 2>/dev/null
    pathPrepend "$APPS_COMMON/node" 2>/dev/null
    [ -f "$WIN_APPS_COMMON/python/python.exe" ] && export PYTHONUSERBASE="$WINDOWS_APPS_COMMON\\python"
    pathPrepend "$APPS_COMMON/python/Python38/Scripts" 2>/dev/null
    pathPrepend "$APPS_COMMON/python/Scripts" 2>/dev/null
    pathPrepend "$APPS_COMMON/python" 2>/dev/null
    pathPrepend "${APPS_ROOT}/PortableApps/PortableGit/cmd"
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
    alias cddev="cd '${APPS_ROOT}/Documents/dev'"
    alias cdenv="cd '${APPS_ROOT}/Documents/dev/common_env'"

    test -d "$HOME/.venv/3" && source pythonvenv set 3
  else
    unset APPS_ROOT
  fi
  # ********** END - Specific for Windows platform with PortableApps **********

  alias esource='echo "$HOME/.bashrc"'
  alias vsource='vi "$HOME/.bashrc"'
  alias rsource='source "$HOME/.bashrc"'
  alias csource='cat "$HOME/.bashrc"'
  alias setup_common_env="'${MAIN_BASHRC_ROOT}/../../../scripts/setup.sh'"
  alias common_env_debug='export COMMON_ENV_DEBUG=1'
  alias common_env_nodebug='export COMMON_ENV_DEBUG=0'
  alias common_env_debug_full='export COMMON_ENV_FULL_DEBUG=1'
  alias common_env_nodebug_full='export COMMON_ENV_FULL_DEBUG=0'

# If current shell is ZSH
elif [ "$current_shell" = "zsh" ]; then
  :
fi

# Function to update git repo
source "${MAIN_BASHRC_ROOT}/check_update.sh"

# Ensure terminal output are UTF8 https://www.debian.org/doc/manuals/fr/debian-fr-howto/ch3.html
export LC_ALL=C.UTF-8
export LESSCHARSET=UTF-8

# Common alias
alias common_env_outdate_check='touch -t "$(date --date="2 days ago" +%Y%m%d%H%M.%S)" "$HOME/.common_env_check"'
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
COMMON_ENV_CHANGED=0
if [ "$COMMON_ENV_FORCE_CHECK" = "1" ] || [ ! -f "$COMMON_ENV_LAST_CHECK" ] || [ $(expr $(date +%s) - $(date -r "$COMMON_ENV_LAST_CHECK" +%s)) -ge 86400 ]; then
  current_commit=$(cd "$MAIN_BASHRC_ROOT" && git log -1 --pretty=format:%H)
  # Things not needed to be checked just after a setup
  if [ -f "$COMMON_ENV_LAST_CHECK" ]; then
    # Check for update if access to github
    pingopt="-c"
    if [ "$OSTYPE" = "msys" ]; then
      pingopt="-n"
    fi
    ping $pingopt 1 -w 1 github.com &>/dev/null
    if [ $? -eq 0 ]; then
      common_env_check_update
      [ ! "$current_commit" = "$(cd "$MAIN_BASHRC_ROOT" && git log -1 --pretty=format:%H)" ] && COMMON_ENV_CHANGED=1
    fi

    # Update git config
    type rgit &>/dev/null && rgit
  fi
  touch "$COMMON_ENV_LAST_CHECK"

  # Refresh tool links
  source "${MAIN_BASHRC_ROOT}/../bin/sourcetool" "${HOME}/bin"
fi

# If an update occured, refresh the setup if on Windows with APPS_ROOT
[ $COMMON_ENV_CHANGED -eq 1 ] && type setup_common_env &>/dev/null && setup_common_env

[ "$COMMON_ENV_DEBUG" = "1" ] && echo "'$MAIN_BASHRC' sourced"
