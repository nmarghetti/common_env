common_env_git_prompt_status() {
  if type git_super_status &>/dev//null; then
    git_super_status
  else
    local git=$(git_prompt_info)
    [[ -n "$git" ]] && git="%{$fg[cyan]%}(${git}$(git_prompt_status))%{$reset_color%}"
    echo "$git"
  fi
}

common_env_build_prompt() {
  local time="%(?.%{$fg[blue]%}.%{$fg[red]%})%*%{$reset_color%}"
  local user="%{$fg[green]%}%n%{$reset_color%}"
  local host="%{$fg[green]%}@%m%{$reset_color%}"
  local system="%{$fg[magenta]%}$OSTYPE-$ZSH_NAME@$ZSH_VERSION%{$reset_color%}"
  local gitversion="%{$fg[cyan]%}git@$(git --version | sed -re 's#^[^0-9]*([0-9\.]+).*#\1#' | cut -d. -f-3)%{$reset_color%}"
  local pwd="%{$fg[yellow]%}%~%{$reset_color%}"
  local git=$(common_env_git_prompt_status)
  local prompt="%(?.%{$fg[green]%}.%{$fg[red]%})%(!.#.$)%{$reset_color%}"
  echo "${time} ${user}${host} ${system} ${gitversion} ${pwd} ${git}
$prompt "
}

if type git_super_status &>/dev//null; then
  ZSH_THEME_GIT_PROMPT_CACHE=1

  ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}("
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[cyan]%})%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_SEPARATOR=""
  ZSH_THEME_GIT_PROMPT_BRANCH=""
  ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[yellow]%}%{@%G%}"
  ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{x%G%}"
  ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[green]%}%{+%G%}"
  ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[cyan]%}%{↓%G%}"
  ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}%{↑%G%}"
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%}%{…%G%}"
  ZSH_THEME_GIT_PROMPT_CLEAN=""
else
  ZSH_THEME_GIT_PROMPT_PREFIX=""
  ZSH_THEME_GIT_PROMPT_SUFFIX=""
  ZSH_THEME_GIT_PROMPT_DIRTY=" "
  ZSH_THEME_GIT_PROMPT_CLEAN=""
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
  ZSH_THEME_GIT_PROMPT_ADDED="+"
  ZSH_THEME_GIT_PROMPT_MODIFIED="*"
  ZSH_THEME_GIT_PROMPT_RENAMED="~"
  ZSH_THEME_GIT_PROMPT_DELETED="!"
  ZSH_THEME_GIT_PROMPT_UNMERGED="?"
fi

PROMPT='%{%f%b%k%}$(common_env_build_prompt)'
RPROMPT=''
PS4='%F{cyan}+%e %30<..<%x%<<%F{magenta}#%F{cyan}%N%f:%F{yellow}%i%F{magenta}>%f'
