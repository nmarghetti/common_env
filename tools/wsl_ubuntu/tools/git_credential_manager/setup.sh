#! /usr/bin/env bash

# https://git-scm.com/docs/git-credential#IOFMT
# printf "url=https://github.com/some/project.git\n" | git credential fill
# check ~/.gcm/ for git-credential-manager credentials saved as plain text
# check ~/.gnupg got gpg keys
# check ~/.password-store for git-credential-manager credentials saved as gpg
setup_git_credential_manager() {
  local ERROR=1
  local wishVersion
  local store
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-git-credential-manager.version || echo "2.6.0")
  store=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-git-credential-manager.store || echo "text")

  if ! type git-credential-manager >/dev/null 2>&1; then
    wget -O ./gcm-linux_amd64.deb "https://github.com/git-ecosystem/git-credential-manager/releases/download/v${wishVersion}/gcm-linux_amd64.${wishVersion}.deb"
    sudo apt install -y gpg pass ./gcm-linux_amd64.deb
    rm -f ./gcm-linux_amd64.deb
  fi

  type git-credential-manager >/dev/null 2>&1 || return $ERROR

  if [ ! "$(basename "$(git config --global credential.helper)")" = "git-credential-manager" ]; then
    git-credential-manager configure
  fi

  if [ "$store" = "text" ]; then
    # Using plain text store
    git config --global credential.credentialStore plaintext
  elif [ "$store" = "gpg" ]; then
    # Generate GPG key if not already done
    if ! gpg --list-keys "$(git config user.email)" >/dev/null 2>&1; then
      cat >gen-key-script <<EOF
    %no-protection
    Key-Type: RSA
    Key-Length: 2048
    Subkey-Type: RSA
    Subkey-Length: 2048
    Name-Real: $USER
    Name-Email: $(git config user.email)
    Expire-Date: 0
    %commit
EOF
      gpg --batch --generate-key gen-key-script
      rm -f gen-key-script
    fi
    # Initialize pass if not already done
    if [ ! -d "$HOME/.password-store" ]; then
      pass init "$USER"
    fi

    # Using gpg store
    git config --global credential.credentialStore gpg
  fi

  return 0
}
