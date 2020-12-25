common_env_build_prompt() {
  local time="%(?.%{$fg[blue]%}.%{$fg[red]%})%*%{$reset_color%}"
  local user="%{$fg[green]%}%n%{$reset_color%}"
  local host="%{$fg[green]%}@%m%{$reset_color%}"
  local system="%{$fg[magenta]%}$OSTYPE-$ZSH_NAME@$ZSH_VERSION%{$reset_color%}"
  local gitversion="%{$fg[cyan]%}git@$(git --version | sed -re 's#^[^0-9]*([0-9\.]+).*#\1#' | cut -d. -f-3)%{$reset_color%}"
  local pwd="%{$fg[yellow]%}%~%{$reset_color%}"
  local git=$(git_prompt_info)
  local prompt="%(?.%{$fg[green]%}.%{$fg[red]%})%(!.#.$)%{$reset_color%}"
  [[ -n "$git" ]] && git="%{$fg[cyan]%}(${git}$(git_prompt_status))%{$reset_color%}"
  echo "${time} ${user}${host} ${system} ${gitversion} ${pwd} ${git}
$prompt "
}

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

PROMPT='%{%f%b%k%}$(common_env_build_prompt)'
RPROMPT=''
PS4='%F{cyan}+%e %30<..<%x%<<%F{magenta}#%F{cyan}%N%f:%F{yellow}%i%F{magenta}>%f'
