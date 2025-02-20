#! /usr/bin/env bash

function main() {
  # Install ca certificate if provided
  local cacert_script
  local cacert
  cacert_script=$(git --no-pager config -f "$HOME/.common_env.ini" --get install.cacert-script 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
  if [ -f "$cacert_script" ]; then
    "$cacert_script" || return $?
  fi
  cacert=$(git --no-pager config -f "$HOME/.common_env.ini" --get install.cacert 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
  if [ -f "$cacert" ]; then
    local bundle
    for bundle in /mingw64/ssl/certs/ca-bundle.crt /mingw64/etc/ssl/certs/ca-bundle.crt /usr/ssl/certs/ca-bundle.crt; do
      if [ ! -d "$(dirname "$bundle")" ]; then
        continue
      fi
      if [ ! -f "$bundle" ] || ! cmp --silent "$cacert" "$bundle"; then
        [[ -f "$bundle" && ! -f "$bundle.backup" ]] && mv "$bundle" "$bundle.backup"
        cp -vf "$cacert" "$bundle"
      fi
    done
    # touch "$HOME/.npmrc"
    # grep -Ee '^cafile=' "$HOME/.npmrc" || echo "cafile=/usr/ssl/certs/ca-bundle.crt" >>"$HOME/.npmrc"
  fi
}

main "$@"
