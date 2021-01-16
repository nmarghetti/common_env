#! /usr/bin/env bash

check_common_env() {
  . ./system.sh
  . ./path_windows.sh
  local current_shell="$(system_get_current_shell)"

  # case $current_shell in
  # bash) .path
  # esac
  echo ' * Env before'
  env | grep APPS | sort
  echo

  echo ' * Env'
  export APPS_ROOT="$(get_path_to_posix "$APPS_ROOT")"
  export APPS_COMMON="$APPS_ROOT/PortableApps/CommonFiles"
  export WIN_APPS_ROOT="$(get_path_to_windows "$APPS_ROOT")"
  export WIN_APPS_COMMON="$(get_path_to_windows "$APPS_COMMON")"
  export WINDOWS_APPS_ROOT="$(get_path_to_windows_back "$APPS_ROOT")"
  export WINDOWS_APPS_COMMON="$(get_path_to_windows_back "$APPS_COMMON")"
  env | grep APPS | sort
  echo

  local shell
  for shell in $current_shell posix; do
    echo " * $shell"
    echo
    for var in APPS_ROOT WIN_APPS_ROOT WINDOWS_APPS_ROOT; do
      if [ "$shell" = "bash" ]; then
        echo "echo $var: ${!var}"
        printf 'printf %s: %s\n' "$var" "${!var}"
      # Shell format does not seem to like zsh expansion
      elif [ "$shell" = "zsh" ]; then
        echo "$shell echo $var: ${(P)var}"
        printf '%s printf %s: %s\n' "$shell" "$var" "${(P)var}"
      elif [ "$shell" = "posix" ]; then
        echo "echo $var: $(eval 'printf "%s\n" "${'"$var"'}"')"
        printf 'printf %s: %s\n' "$var" "$(eval 'printf "%s\n" "${'"$var"'}"')"
      fi
    done
  done
}

# Run in a separate shell
(
  cd "$(dirname "$(readlink -f "$0")")"
  check_common_env
)
