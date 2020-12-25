#! /usr/bin/env bash

# Help function
read_secret_usage() {
  [[ -n "$1" ]] && echo -e "$1\n"

  cat <<'HELP'
Read secret:
  - print * while user is typing
  - echo the secret on stdout when user presses Enter

Usage: read_secret [option] [prompt]
  options:
    -c <character>: character to print instead of user input (default=*)
    -h: display this help message

Example:
  secret=$(read_secret -c '#' "Please enter your password:")
HELP
}

read_secret() {
  # Read input parameters
  local secret
  local prompt
  local hide_character='*'
  while getopts hc: opt; do
    case "$opt" in
    c)
      hide_character=$OPTARG
      [[ "${#hide_character}" -gt 1 ]] && {
        read_secret_usage "Error: the hidding character must be one character only: '$hide_character'."
        return 2
      }
      ;;
    h)
      read_secret_usage
      return 0
      ;;
    \? | *)
      read_secret_usage
      return 2
      ;;
    esac
  done
  shift $(expr $OPTIND - 1)
  [[ $# -gt 1 ]] && {
    read_secret_usage "Error: too many arguments given ($#)."
    return 2
  }
  declare prompt="$1"

  # Read secret
  while IFS= read -p "$prompt" -r -s -n 1 char; do
    # Enter - accept password
    if [[ $char == $'\0' ]]; then
      break
    fi
    # Backspace
    if [[ $char == $'\177' ]]; then
      # Do not do anything if secret is empty
      if [[ -z "$secret" ]]; then
        prompt=
      else
        prompt=$'\b \b'
        secret="${secret%?}"
      fi
    else
      prompt="$hide_character"
      secret="${secret}${char}"
    fi
  done
  echo >&2
  echo "$secret"
}

[[ "$0" == "$BASH_SOURCE" ]] && read_secret "$@"
