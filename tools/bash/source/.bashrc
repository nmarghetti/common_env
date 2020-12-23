MAIN_BASHRC=${BASH_SOURCE[0]}
if [ -z "$MAIN_BASHRC" ] || [ "$MAIN_BASHRC" = "bash" ]; then
  MAIN_BASHRC=$0
fi
MAIN_BASHRC_ROOT=$(dirname "$(readlink -f "${MAIN_BASHRC}")")

common_env_log() {
  if [[ "$COMMON_ENV_DEBUG" = "1" ]]; then
    local now="$(date +%H:%M:%S)"
    tput sc
    printf "%*s" "$COLUMNS" "$now" >&2
    tput rc
    echo -e "$now $@" >&2
  fi
}

common_env_log "Sourcing '$MAIN_BASHRC'..."
# could check that also https://stackoverflow.com/questions/26067916/colored-xtrace-output
export COMMON_ENV_DEBUG_CMD="[ \"\$COMMON_ENV_FULL_DEBUG\" = \"1\" ] && { system_trace_debug() { echo \"DEBUG: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; system_trace_error() { echo \"ERROR: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; trap 'system_trace_debug \"\$?\" \"\$BASH_COMMAND\" ' DEBUG;  trap 'system_trace_error \"\$?\" \"\$BASH_COMMAND\" ' ERR; }"
[ "$COMMON_ENV_FULL_DEBUG" = "1" ] && eval "$COMMON_ENV_DEBUG_CMD"
# keep those in mind for debugging:
#   set -xeo pipefail
#   set +xeo pipefail

# bash setup info: http://aral.iut-rodez.fr/fr/sanchis/enseignement/bash/ch04s03.html
# set -o
# shopt

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

common_env_log "Setup common config"

# If host system is Windows
if [ "$(system_get_os_host)" = "Windows" ]; then
  # Get some function to convert Windows path
  source "${MAIN_BASHRC_ROOT}/path_windows.sh"
  alias rrsource='COMMON_ENV_FORCE_CHECK=1 rsource'
fi

# Setup basic config based on the shell
# BASH
if [ "$current_shell" = "bash" ]; then
  shopt -s expand_aliases
  # if shell is interactif
  if [[ $- == *i* ]]; then
    # showkey -a give the key pressed
    # check /etc/inputrc
    # check bind -pl
    bind '"\e[5~"':history-search-backward # Page Up to look backward in history
    bind '"\e[6~"':history-search-forward  # Page Down to look forward in history
    bind '"\e[1;5D"':backward-word         # Ctrl-Left
    bind '"\e[1;5C"':forward-word          # Ctrl-Right
    bind '"\e[1;3D"':backward-word         # Alt-Left
    bind '"\e[1;3C"':forward-word          # Alt-Right

    [[ ! "$OSTYPE" = "cygwin" ]] && export PS4=$'+ \t\t''\e[33m\s@\v ${BASH_SOURCE}#\e[35m${LINENO} \e[34m${FUNCNAME[0]:+${FUNCNAME[0]}() }''\e[36m\t\e[0m\n'
  fi

  source "${MAIN_BASHRC_ROOT}/path.sh"

  alias esource='echo "$HOME/.bashrc"'
  alias vsource='vi "$HOME/.bashrc"'
  alias rsource='source "$HOME/.bashrc"'
  alias csource='cat "$HOME/.bashrc"'
# ZSH
elif [ "$current_shell" = "zsh" ]; then
  # if shell is interactif
  if [[ -o login ]]; then
    setopt aliases

    # Do not do all the binding if oh-my-zsh is installed
    if [[ ! -e "$HOME/.oh-my-zsh" ]]; then
      bindkey '^[OD' backward-word      # Ctrl-Left
      bindkey '^[OC' forward-word       # Ctrl-Right
      bindkey '^[[1;5D' backward-word   # Ctrl-Left
      bindkey '^[[1;5C' forward-word    # Ctrl-Right
      bindkey '^[[1;3D' backward-word   # Alt-Left
      bindkey '^[[1;3C' forward-word    # Alt-Right
      bindkey '^[[1~' beginning-of-line # Home
      bindkey '^[[4~' end-of-line       # End
      # bindkey "^[[A" up-line-or-beginning-search   # Page-Up
      # bindkey "^[[B" down-line-or-beginning-search # Page-Down
    fi
  fi

  source "${MAIN_BASHRC_ROOT}/path_zsh.sh"

  alias vsource='vi "$HOME/.zshrc"'
  alias rsource='source "$HOME/.zshrc"'
  alias venv='vi "$HOME/.zshenv"'
  alias renv='source "$HOME/.zshenv"'
fi

# Add some tools in ~/bin if not there yet
if [ ! -e "${HOME}/bin/toolupdatelink" ]; then
  mkdir -p "${HOME}/bin"
  source "$(dirname "${MAIN_BASHRC_ROOT}")/bin/sourcetool" "${HOME}/bin"
fi

# In case of bash is not recent enough
# pathPrepend "${HOME}/bin"
export PATH="${HOME}/bin:$PATH"

alias setup_common_env="$(readlink -f "${MAIN_BASHRC_ROOT}/../../../scripts/setup.sh")"
alias common_env_debug='export COMMON_ENV_DEBUG=1'
alias common_env_nodebug='export COMMON_ENV_DEBUG=0'
alias common_env_debug_full='export COMMON_ENV_FULL_DEBUG=1'
alias common_env_nodebug_full='export COMMON_ENV_FULL_DEBUG=0'

# ********** BEGIN - Specific for Windows platform with PortableApps **********
if [ -z "$APPS_ROOT" ]; then
  export APPS_ROOT=$(cd && cd .. && pwd)
else
  export APPS_ROOT=$(cd "$APPS_ROOT" && pwd)
fi
if [ -d "$APPS_ROOT/PortableApps" ]; then
  common_env_log "Setup portable apps config"
  export APPS_COMMON="$APPS_ROOT/PortableApps/CommonFiles"
  export WIN_APPS_ROOT="$(get_path_to_windows "$APPS_ROOT")"
  export WIN_APPS_COMMON="$(get_path_to_windows "$APPS_COMMON")"
  export WINDOWS_APPS_ROOT="$(echo "$WIN_APPS_ROOT" | tr '/' '\\')"
  export WINDOWS_APPS_COMMON="$(echo "$WIN_APPS_COMMON" | tr '/' '\\')"
  # export MSYS_SHELL=$APPS_COMMON/msys64/msys2_shell.cmd

  # pathAppend "$APPS_COMMON/msys64/mingw64/bin" 2>/dev/null
  # pathAppend "$APPS_COMMON/msys64/usr/bin" 2>/dev/null
  pathAppend "/mingw64/bin" 2>/dev/null
  pathPrepend "$APPS_COMMON/cmake/bin" 2>/dev/null
  pathPrepend "$APPS_COMMON/make/bin" 2>/dev/null
  pathPrepend "$APPS_COMMON/node" 2>/dev/null
  pathPrepend "$APPS_COMMON/gradle/bin" 2>/dev/null
  [ -f "$WIN_APPS_COMMON/python/python.exe" ] && export PYTHONUSERBASE="$WINDOWS_APPS_COMMON\\python"
  pathPrepend "$APPS_COMMON/python/Python38/Scripts" 2>/dev/null
  pathPrepend "$APPS_COMMON/python/Scripts" 2>/dev/null
  pathPrepend "$APPS_COMMON/python" 2>/dev/null
  # Do not change bash or git in case of cygwin as it already has it
  if [[ ! "$OSTYPE" = "cygwin" ]]; then
    pathPrepend "${APPS_ROOT}/PortableApps/PortableGit/cmd"
    pathPrepend "${APPS_ROOT}/PortableApps/PortableGit/bin"
  fi
  pathPrepend "${HOME}/bin"

  # https://github.com/cypress-io/cypress/issues/1401#issuecomment-393591520
  export NODE_EXTRA_CA_CERTS=/mingw64/ssl/certs/ca-bundle.crt

  alias code='"$APPS_ROOT/PortableApps/VSCode/bin/code" --extensions-dir "$WIN_APPS_ROOT/PortableApps/VSCodeLauncher/data/extensions" --user-data-dir "$WIN_APPS_ROOT/PortableApps/VSCodeLauncher/data/user-data"'

  if [[ "$current_shell" = "bash" && ! -f "$HOME/.oh-my-bashrc" ]]; then
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
        common_env_log "Setup git prompt"
        source "${APPS_ROOT}/PortableApps/PortableGit/mingw64/share/git/completion/git-prompt.sh"
      fi
      common_env_build_prompt() {
        local prompt_color="32"
        [[ $? -ne 0 ]] && prompt="31"
        # echo '\[\e]0;${TITLEPREFIX:-$OSTYPE}:$PWD\a\]\[\e[34m\]\t \[\e[32m\]\u@\h \[\e[35m\]$OSTYPE-\s@\v \[\e[36m\]git@`git --version | sed -re "s#^[^0-9]*([0-9\.]+).*#\1#" | cut -d. -f-3` \[\e[33m\]\w\n\[\e[${prompt_color}m\]$ \[\e[0m\]'
        echo -e "\[\e]0;${TITLEPREFIX:-$OSTYPE}:$PWD\a\]\[\e[34m\]\t \[\e[32m\]\u@\h \[\e[35m\]$OSTYPE-\s@\v \[\e[36m\]git@$(git --version | sed -re "s#^[^0-9]*([0-9\.]+).*#\1#" | cut -d. -f-3) \[\e[33m\]\w\n\[\e[${prompt_color}m\]$ \[\e[0m\]"
      }
      export PS1='\[\e]0;${TITLEPREFIX:-$OSTYPE}:$PWD\a\]$(common_env_build_prompt)'
      # https://wiki.archlinux.org/index.php/Bash/Prompt_customization
      export PS1='\[\e]0;${TITLEPREFIX:-$OSTYPE}:$PWD\a\]\[`[[ $? -eq 0 ]] && echo "\e[34m" || echo "\e[31m"`\]\t \[\e[32m\]\u@\h \[\e[35m\]$OSTYPE-\s@\v \[\e[36m\]git@`git --version | sed -re "s#^[^0-9]*([0-9\.]+).*#\1#" | cut -d. -f-3` \[\e[33m\]\w\n\[\e[0m\]$ '
      export PS1_NO_GIT=$PS1
      export PS1=$(echo "$PS1" | sed -re 's#\\w\\n#\\w\\\[\\e\[36m\\\]`__git_ps1`\\n#')
      export PS1_GIT=$PS1
      ;;
    esac
    [[ "$COMMON_ENV_GIT_PROMPT" = "0" ]] && export PS1=$PS1_NO_GIT

    alias prompt_nogit='[[ -n "$PS1_NO_GIT" ]] && export PS1=$PS1_NO_GIT'
    alias prompt_git='[[ -n "$PS1_GIT" ]] && export PS1=$PS1_GIT'
  elif [[ "$current_shell" = "zsh" && ! -e "$HOME/.oh-my-zsh" ]]; then
    # if shell is interactif
    if [[ -o login ]]; then
      # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
      export PS1='%F{blue}%* %F{green}%n@%m %F{magenta}$OSTYPE-$ZSH_NAME@$ZSH_VERSION %F{yellow}%~
%(?.%F{green}.%F{red})%(!.#.$)%f '
      export PS4='+%N:%i>'
    fi
  fi

  alias tsource="source '${MAIN_BASHRC_ROOT}/../bin/sourcetool' '${HOME}/bin'"
  alias cddev="cd '${APPS_ROOT}/Documents/dev'"
  alias cdenv="cd '${APPS_ROOT}/Documents/dev/common_env'"

  [[ ! "$OSTYPE" = "cygwin" && -n "$COMMON_ENV_PYTHON_VENV" && -d "$HOME/.venv/$COMMON_ENV_PYTHON_VENV" ]] && {
    common_env_log "Setup python venv"
    source pythonvenv set "$COMMON_ENV_PYTHON_VENV"
  }
else
  unset APPS_ROOT
fi
# ********** END - Specific for Windows platform with PortableApps **********

common_env_log "Adding some alias"

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
alias pyinfo='pythonvenv info'
alias pyunset='deactivate 2>/dev/null'

# Do some checks only if not done since at least 24h
COMMON_ENV_LAST_CHECK="$HOME/.common_env_check"
COMMON_ENV_CHANGED=0

if [ "$COMMON_ENV_FORCE_CHECK" = "1" ] || [ ! -f "$COMMON_ENV_LAST_CHECK" ] || [ $(expr $(date +%s) - $(date -r "$COMMON_ENV_LAST_CHECK" +%s)) -ge 86400 ]; then
  common_env_log "Checking for update"
  current_commit=$(cd "$MAIN_BASHRC_ROOT" && git log -1 --pretty=format:%H)
  # Things not needed to be checked just after a setup
  if [ -f "$COMMON_ENV_LAST_CHECK" ]; then
    # Check for update if access to github
    check_update=1
    system_ping github.com &>/dev/null || check_update=0
    if [ $check_update -eq 1 ]; then
      common_env_check_update
      [ ! "$current_commit" = "$(cd "$MAIN_BASHRC_ROOT" && git log -1 --pretty=format:%H)" ] && COMMON_ENV_CHANGED=1
    fi
  fi
  touch "$COMMON_ENV_LAST_CHECK"

  # Update git config
  type rgit &>/dev/null && rgit

  # Refresh tool links
  source "${MAIN_BASHRC_ROOT}/../bin/sourcetool" "${HOME}/bin"
fi

# If an update occured, refresh the setup if on Windows with APPS_ROOT
[ $COMMON_ENV_CHANGED -eq 1 ] && type setup_common_env &>/dev/null && setup_common_env

common_env_log "'$MAIN_BASHRC' sourced"
