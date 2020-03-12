MAIN_BASHRC=${BASH_SOURCE[0]}
if [ -z "$MAIN_BASHRC" ] || [ "$MAIN_BASHRC" = "bash" ]; then
  MAIN_BASHRC=$0
fi
MAIN_BASHRC_ROOT=$(dirname $(readlink -f "${MAIN_BASHRC}"))

if [ ! "$(basename "$MAIN_BASHRC")" = ".bashrc" ]; then
  echo "ERROR !!! Unable source .bashrc, many things will probably not work !!!" >&2
  return
fi

source "${MAIN_BASHRC_ROOT}/../bin/sourcetool" "${HOME}/bin"

export APPS_ROOT=$(cd && cd .. && pwd)
# Specific for Windows platform with PortableApps
if [ -d "$APPS_ROOT/PortableApps" ]; then
  if [ -z "$BASH_VERSION" ]; then
    echo "ERROR !!! You are are not sourcing with bash, you might encounter problem !!!" >&2
  fi
  
  source "${MAIN_BASHRC_ROOT}/path.sh"
  
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
  
  alias cddev="cd ${APPS_ROOT}/Documents/dev"
  
  # source pythonvenv set 3.8.1
else
  unset APPS_ROOT
fi

# Check for update if access to github
pingopt="-c"
if [ "$OSTYPE" = "msys" ]; then
  pingopt="-n"
fi
ping $pingopt 1 -w 1 github.com &>/dev/null && source "${MAIN_BASHRC_ROOT}/check_update.sh"

# Ensure terminal output are UTF8
export LC_ALL=C.UTF-8
export LESSCHARSET=UTF-8

# For env using bashrc
if [ -f "$HOME/.bashrc" ]; then
  alias esource='echo "$HOME/.bashrc"'
  alias vsource='vi "$HOME/.bashrc"'
  alias rsource='source "$HOME/.bashrc"'
  alias csource='cat "$HOME/.bashrc"'
  alias tsource="source '${MAIN_BASHRC_ROOT}/../bin/sourcetool' '${HOME}/bin'"
  alias setup="'${MAIN_BASHRC_ROOT}/../../../scripts/setup.sh'"
fi

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
alias pyset='source pythonvenv set'
alias pyunset='deactivate 2>/dev/null'

# Update git config
type rgit &>/dev/null && rgit
