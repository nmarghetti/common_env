#! /usr/bin/env bash

setup_liquibase() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-liquibase.version || echo "4.31.1")

  if [ ! -f /etc/apt/sources.list.d/liquibase.list ]; then
    wget -O- https://repo.liquibase.com/liquibase.asc | gpg --dearmor | sudo tee /usr/share/keyrings/liquibase-keyring.gpg >/dev/null &&
      echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/liquibase-keyring.gpg] https://repo.liquibase.com stable main' | sudo tee /etc/apt/sources.list.d/liquibase.list &&
      sudo apt-get update
  fi

  if ! type java >/dev/null 2>&1; then
    sudo apt install -y openjdk-21-jdk-headless
  fi

  if ! type liquibase >/dev/null 2>&1 || ! printf '%s\n%s\n' "$(liquibase --version | grep -i 'liquibase version' | cut -d: -f2 | awk '{ print $1 }')" "$wishVersion" |
    sort -r --check=quiet --version-sort; then
    sudo apt install -y liquibase="$wishVersion"
  fi

  ! type liquibase >/dev/null 2>&1 && return $ERROR

  return 0
}
