#! /usr/bin/env bash

# https://docs.docker.com/engine/install/ubuntu/
setup_docker() {
  # Install docker
  if ! apt list --installed 2>/dev/null | grep -qE '^containerd.io/'; then
    # Remove old configuration of docker
    if [ -d ~/.docker ]; then
      mv -f ~/.docker ~/.docker.backup
    fi

    # Remove other dependencies that can conflict with docker
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
      sudo apt remove -y $pkg
    done

    # Add Docker's official GPG key:
    if [ ! -f "/etc/apt/keyrings/docker.gpg" ]; then
      sudo mkdir -p /etc/apt/keyrings
      sudo apt install -y ca-certificates curl gnupg
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    # Add the repository to Apt sources:
    if ! grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep 'https://download.docker.com/linux/ubuntu' | grep -q 'https://download.docker.com/linux/ubuntu'; then
      # shellcheck disable=SC1091
      echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
      sudo apt update
    fi

    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    /etc/profile.d/dockerd_autoload.sh
  fi

  # Ensure to be added to the docker group
  groups | tr '[:space:]' '\n' | grep -qFx docker || sudo usermod -aG docker "$USER"

  return 0
}
