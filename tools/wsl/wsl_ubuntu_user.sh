#! /usr/bin/env bash

export WSL_SETUP_TOOLS_ROOT
WSL_SETUP_TOOLS_ROOT="$(cd "$WSL_APPS_ROOT/Documents/dev/common_env/tools" && pwd)"
export WSL_WIN_SETUP_TOOLS_ROOT
WSL_WIN_SETUP_TOOLS_ROOT="$(wslpath -w "$WSL_SETUP_TOOLS_ROOT")"

sudo apt-get update -y
