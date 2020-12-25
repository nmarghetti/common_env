#! /bin/sh

system_get_os() {
  local os=
  case "$(uname -s)" in
  Linux)
    os="Linux"
    ;;
  Darwin)
    os="Mac"
    ;;
  MSYS_NT* | MINGW64_NT* | CYGWIN_NT*)
    os="Windows"
    ;;
  *)
    echo "Unknown"
    return 1
    ;;
  esac
  echo $os
}

system_get_os_host() {
  local os=$(system_get_os)
  # For Bash on Unbuntu on Windows
  [ "$os" = "Linux" ] && [ "$(uname -a | grep -ci 'Microsoft')" -ne 0 ] && os="Windows"
  echo "$os"
  [ "$os" = "Unknown" ] && return 1
}

system_get_current_shell_path() {
  [[ -e "/proc/$$/exe" ]] && readlink "/proc/$$/exe" && return 0
  ps -p $$ | tr '[:space:]' '\n' | grep 'sh' | head -1 && return 0
  echo "$SHELL"
}

system_get_current_shell() {
  echo "$(basename "$(system_get_current_shell_path)" .exe)"
}

system_get_default_shell() {
  if [ -f /etc/passwd ]; then
    grep -hE "^${USER:-${USERNAME}}" /etc/passwd | cut -d: -f7
  else
    echo "$SHELL"
  fi
}

system_display_shell_info() {
  local shell="$(system_get_current_shell)"
  case "$shell" in
  bash | zsh)
    if [ "$1" = "eval" ]; then
      for val in "$(set | grep -aE "^$(basename "$shell" | tr '[:lower:]' '[:upper:]')" | cut -d= -f1)"; do
        [ -n "$val" ] && echo "$val=${!val}"
      done
    else
      set | grep -aE "^$(basename "$shell" | tr '[:lower:]' '[:upper:]')"
    fi
    ;;
  *)
    echo "Unsupported shell: '$shell'"
    ;;
  esac
}

system_get_shells() {
  if [ -f /etc/shells ]; then
    grep -hE '^/' /etc/shells
  else
    echo "Unable to find shells installed"
  fi
}

system_ping() {
  local ping_option
  case "$(system_get_os_host)" in
  Windows) ping_option='-n 1 -w 1' ;;
  Linux) ping_option='-c 1 -w 1' ;;
  Mac) ping_option='-c 1 -t 1' ;;
  esac
  ping $ping_option "$@"
}
