#! /usr/bin/env bash

minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get gitbash.minimum-version || echo "2.43")
printf '%s\n%s\n' "$(git --version | cut -d' ' -f3)" "$minimumVersion" | sort -r --check=quiet --version-sort
exit $?
