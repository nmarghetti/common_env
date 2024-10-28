#! /bin/sh

# This script would automatically start the dockerd if it is not running

type dockerd >/dev/null 2>&1 || return 0
pgrep dockerd >/dev/null || sudo nohup dockerd 2>&1 | sudo tee /tmp/dockerd.log >/dev/null &
return 0
