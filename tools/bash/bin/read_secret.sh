read_secret() {
  local secret
  prompt="$1"
  while IFS= read -p "$prompt" -r -s -n 1 char; do
    # Enter - accept password
    if [[ $char == $'\0' ]]; then
      break
    fi
    # Backspace
    if [[ $char == $'\177' ]]; then
      prompt=$'\b \b'
      secret="${secret%?}"
    else
      prompt='*'
      secret="${secret}${char}"
    fi
  done
  echo >&2
  echo "$secret"
}

read_secret "$@"
