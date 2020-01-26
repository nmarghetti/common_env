MAIN_BASHRC_ROOT=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

if [ ! "$(basename "${BASH_SOURCE[0]}")" = ".bashrc" ]; then
  echo "ERROR !!! Unable source .bashrc, many things will probably not work !!!" >&2
  return
fi

export APPS_ROOT=$(cd && cd .. && pwd)
source "${MAIN_BASHRC_ROOT}/path.sh"
source "${MAIN_BASHRC_ROOT}/../bin/sourcetool" "${HOME}/bin"

pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/python3.8.1/Scripts"
pathPrepend "${APPS_ROOT}/PortableApps/CommonFiles/python3.8.1"
pathPrepend "${APPS_ROOT}/PortableApps/PortableGit/bin"
pathPrepend "${HOME}/bin"

alias vsource='vi ~/.bashrc'
alias rsource='source ~/.bashrc'
alias csource='cat ~/.bashrc'
alias tsource="source ${MAIN_BASHRC_ROOT}/tool/sourcetool ${MAIN_BASHRC_ROOT}/bin"
alias vgit='vi ~/.gitconfig'
alias ls='ls --color=auto'
alias la='ls -lhA'
alias ll='ls -lh'
alias cddev="cd ${APPS_ROOT}/Documents/dev"

# Python env management
alias pythonlist='pythonenv list'
alias pythonset='source pythonenv set'
alias pythonunset='deactivate 2>/dev/null'

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
