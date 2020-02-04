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

  pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/msys64/mingw64/bin" 2>/dev/null
  pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/cmake/bin" 2>/dev/null
  pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/node" 2>/dev/null
  pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/python/Scripts"
  pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/python"
  pathPrepend "${APPS_ROOT}/PortableApps/PortableGit/bin"
  pathPrepend "${HOME}/bin"

  alias esource='echo ~/.bashrc'
  alias vsource='vi ~/.bashrc'
  alias rsource='source ~/.bashrc'
  alias csource='cat ~/.bashrc'
  alias tsource="source '${MAIN_BASHRC_ROOT}/../bin/sourcetool' '${HOME}/bin'"

  alias setup="'${MAIN_BASHRC_ROOT}/../../../scripts/setup.sh'"

  alias cddev="cd ${APPS_ROOT}/Documents/dev"

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

  source pythonvenv set 3.8.1
else
  unset APPS_ROOT
fi


alias vvsource="vi '$MAIN_BASHRC_ROOT/.bashrc'"
alias vvgit="vi '$MAIN_BASHRC_ROOT/../../git/.gitconfig'"
alias vgit='vi ~/.gitconfig'
alias gitv='vi .git/config'
alias egit='echo ~/.gitconfig'
alias rgit="content=\"\$(cat \"\$HOME/.gitconfig\")\" && echo \"\$content\" | \"${MAIN_BASHRC_ROOT}/../bin/generated_content.awk\" -v action=replace -v replace_append=1 -v content_file=\"${MAIN_BASHRC_ROOT}/../../git/.gitconfig\" >| \"\$HOME/.gitconfig\""
alias ls='ls --color=auto'
alias la='ls -lhA'
alias ll='ls -lh'

# Python env management
alias pylist='pythonvenv list'
alias pyset='source pythonvenv set'
alias pyunset='deactivate 2>/dev/null'

# Update git config
rgit
