#! /bin/sh

# This script would automatically start the dockerd if it is not running

type docker >/dev/null 2>&1 || return 0
if [ "$(docker info -f json 2>/dev/null | jq .ID | grep -v null | xargs echo | wc -w)" -eq 0 ]; then
  sudo nohup dockerd 2>&1 | sudo tee /tmp/dockerd.log >/dev/null &
fi
return 0
