system_get_os(){
  case "$(uname -s )" in
    Linux)
      SETUP_SYSTEM="Linux";
    ;;
    Darwin)
      SETUP_SYSTEM="Mac"
    ;;
    MSYS_NT*|MINGW64_NT*)
      SETUP_SYSTEM="Windows"
    ;;
    *)
      echo "Unknown"
      return 1
    ;;
  esac
  return 0
}

system_get_default_shell(){
  cat /etc/passwd | grep -E "^$USER" | cut -d: -f7
}

system_get_current_shell(){
  # sh -c 'ps -p $$ -o ppid=' | xargs -I'{}' readlink -f '/proc/{}/exe'
  echo "$(basename "$SHELL")"
}

system_get_shells(){
  cat /etc/shells | grep -E '^/'
}
