#! /usr/bin/env bash

cd "$(dirname "$(readlink -f "$0")")" || exit 1

# mkdir -p tmp
# tmp_dir=$(cd tmp && pwd)
tmp_dir=$(mktemp -d) || exit 1

declare -A tasks=(
  ["WSL_Admin_CiscoMetric"]="2039 2041"
  ["WSL_CiscoDns"]="2010 2061"
)

for task in "${!tasks[@]}"; do
  for code in ${tasks[$task]}; do
    sed -r -e 's/encoding="UTF-8"/encoding="UTF-16"/' -e "s/%CISCO_CODE%/$code/g" -e "s/%DATE%/$(date +'%Y-%m-%dT%H:%M:%S.%N')/g" -e "s/%USERDOMAIN%/$USERDOMAIN/g" -e "s/%USERNAME%/$USERNAME/g" -e "s#%WINDOWS_APPS_ROOT%#$(echo "$WINDOWS_APPS_ROOT" | sed -re 's#\\#\\\\#g')#g" ./tasks/"$task".xml | unix2dos | iconv -f utf-8 -t utf-16 >|"$tmp_dir"/"$task"_"$code".xml
  done
done

powershell.exe -ExecutionPolicy RemoteSigned -Command ./import_tasks.ps1 "$tmp_dir" "$USERDOMAIN" "$USERNAME" "\\wsl\\"

rm -rf "$tmp_dir"
