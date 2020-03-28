#! /bin/bash

system_get_os(){
  local os=
  case "$(uname -s )" in
    Linux)
      os="Linux";
    ;;
    Darwin)
      os="Mac"
    ;;
    MSYS_NT*|MINGW64_NT*)
      os="Windows"
    ;;
    *)
      echo "Unknown"
      return 1
    ;;
  esac
  echo $os
}

system_get_current_shell(){
  # sh -c 'ps -p $$ -o ppid=' | xargs -I'{}' readlink -f '/proc/{}/exe'
  echo "$(basename "$SHELL")"
}

system_get_default_shell(){
  if [ -f /etc/passwd ]; then
    cat /etc/passwd | grep -E "^$USER" | cut -d: -f7
  else
    echo $SHELL
  fi
}

system_display_shell_info(){
  case "$(basename "$SHELL")" in
    bash|zsh)
      if [ "$1" = "eval" ]; then
        for val in "$(set | grep -aE "^$(basename $SHELL | tr '[:lower:]' '[:upper:]')" | cut -d= -f1)"; do
          [ -n "$val" ] && echo "$val=${!val}"
        done
      else
        set | grep -aE "^$(basename $SHELL | tr '[:lower:]' '[:upper:]')"
      fi
    ;;
    *)
      echo "Unsupported shell: '$SHELL'"
    ;;
  esac
}

system_get_shells(){
  if [ -f /etc/shells ]; then
    cat /etc/shells | grep -E '^/'
  else
    echo "Unable to find shells installed"
  fi
}

