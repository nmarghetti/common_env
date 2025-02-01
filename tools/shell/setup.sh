#! /usr/bin/env bash

# article about bash and zsh startup scripts https://tanguy.ortolo.eu/blog/article25/shrc

function setup_shell() {
  if [[ ! -z "$HOME" ]]; then
    mkdir -vp "$HOME"
  fi

  # Create .bash_profile
  if [[ ! -f "$HOME/.bash_profile" ]]; then
    cat >"$HOME/.bash_profile" <<EOM
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc
EOM
  fi

  # Create template .bashrc and .zshrc if not there yet
  local shellrc
  for shellrc in .bashrc .zshrc; do
    if [[ ! -f "$HOME/$shellrc" ]]; then
      echo "Create $HOME/$shellrc"
      cat >"$HOME/$shellrc" <<EOM
# Common env settings

# Set to 1 to have some debug information about what is being sourced
export COMMON_ENV_DEBUG=0
# Set to 0 to not have git information in the prompt, it would speed up its display
export COMMON_ENV_GIT_PROMPT=1
# Set it to whatever existing python venv to load, or empty to not load it
export COMMON_ENV_PYTHON_VENV=3


# BEGIN - GENERATED CONTENT, DO NOT EDIT !!!
# END - GENERATED CONTENT, DO NOT EDIT !!!

# Custom settings
EOM
    fi
  done

  # Add content to .bashrc
  local setup_tool_root=$(readlink -f "$SETUP_TOOLS_ROOT")
  [[ "$(echo "$setup_tool_root" | cut -b -4)" == "/mnt" ]] && setup_tool_root=$(echo "$setup_tool_root" | cut -b 5-)
  local content=$(
    cat <<-EOM
if [[ ! "\$(basename "\${BASH_SOURCE[0]}")" = ".bashrc" ]]; then
  echo "ERROR !!! It does not seem that you are sourcing .bashrc with bash, not sourcing common_env, many things will probably not work !!!" >&2
elif [[ "\$OSTYPE" == "cygwin" ]] && [[ "\$(basename "\${BASH_SOURCE[1]}")" == ".bash_profile" ]]; then
  : # Avoid sourcing twice for cygwin
else
  $([[ -n "$COMMON_ENV_SETUP_MAC_PATH" ]] && echo -ne "$COMMON_ENV_SETUP_MAC_PATH\n  ")[[ "\$COMMON_ENV_DEBUG" = "1" ]] && echo "Sourcing '\$(readlink -f "\${BASH_SOURCE[0]}")' ..." >&2
  # Ensure that \$HOME points to where is located the current file being sourced
  export HOME=\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)
  if [[ -f "$setup_tool_root/shell/source/shellrc.sh" ]]; then
    source "$setup_tool_root/shell/source/shellrc.sh"
  elif [[ -f "/mnt$setup_tool_root/shell/source/shellrc.sh" ]]; then
    source "/mnt$setup_tool_root/shell/source/shellrc.sh"
  else
    echo "ERROR !!! Unable to find shellrc.sh"
  fi
fi
EOM
  )
  local bashrc="$(cat "$HOME/.bashrc")"
  echo "$bashrc" | awk -f "$SETUP_TOOLS_ROOT/shell/bin/generated_content.awk" -v action=replace -v replace_append=1 \
    -v content="$(echo "$content" | sed -re 's#\\#\\\\#g')" >|"$HOME/.bashrc"

  # Add content to .zshrc
  content=$(
    cat <<-EOM
  $([ -n "$COMMON_ENV_SETUP_MAC_PATH" ] && echo -ne "$COMMON_ENV_SETUP_MAC_PATH\n  ")[ "\$COMMON_ENV_DEBUG" = "1" ] && echo "Sourcing '\$0' ..." >&2
  source "$(readlink -f "$SETUP_TOOLS_ROOT/shell/source/shellrc.sh")"
EOM
  )
  local zshrc="$(cat "$HOME/.zshrc")"
  echo "$zshrc" | awk -f "$SETUP_TOOLS_ROOT/shell/bin/generated_content.awk" -v action=replace -v replace_append=1 \
    -v content="$(echo "$content" | sed -re 's#\\#\\\\#g')" >|"$HOME/.zshrc"

  # Check oh-my-bash
  # if [[ ! -d "$HOME/.oh-my-bash" ]]; then
  #   local answer='n'
  #   read -rep "Do you want to install oh-my-bash (Y/n) ? " -i $answer answer
  #   if [[ "$answer" =~ ^[yY]?$ ]]; then
  #     OSH_REPOSITORY="https://github.com/nmarghetti/oh-my-bash.git" "$(system_get_current_shell_path)" -c "$("$SETUP_TOOLS_ROOT/shell/bin/download_tarball.sh" -o - "https://raw.githubusercontent.com/nmarghetti/oh-my-bash/master/tools/install.sh")"
  #     [[ $? -eq 0 && -f "$HOME/.bashrc.pre-oh-my-bash" ]] && {
  #       mv "$HOME/.bashrc" "$HOME/.oh-my-bashrc"
  #       mv "$HOME/.bashrc.pre-oh-my-bash" "$HOME/.bashrc"
  #     }
  #   fi
  # fi

  # For PortableApps on Windows
  if [[ -n "$APPS_ROOT" ]]; then
    # Install Bash-it
    if [[ "$(git --no-pager config -f "$HOME/.common_env.ini" --get shell.bash-it)" = "1" ]]; then
      if [[ ! -d "$HOME/.bash-it" ]]; then
        git clone 'https://github.com/Bash-it/bash-it.git' "$HOME/.bash-it"
        "$HOME/.bash-it/install.sh" --silent
        if [[ -f "$HOME/.bashrc.bak" ]]; then
          local bash_theme="$(git --no-pager config -f "$HOME/.common_env.ini" --get bash-it.theme)"
          # [[ -z "$bash_theme" ]] && bash_theme="common-env"
          echo >>"$HOME/.bashrc"
          cat "$HOME/.bashrc.bak" >>"$HOME/.bashrc" && rm -f "$HOME/.bashrc.bak"
          sed -ri \
            -e "s/^export BASH_IT_THEME=.*$/export BASH_IT_THEME=\"$bash_theme\"/" \
            -e 's#^source "\$BASH_IT".*$#[ "$OSTYPE" != "cygwin" ] \&\& source "$BASH_IT"/bash_it.sh#' \
            "$HOME/.bashrc"
        fi
      fi
      # if [[ -d "$HOME/.bash-it" ]]; then
      #   type bash-it &>/dev/null || source "$HOME/"
      # fi
    fi

    # Check zsh
    if [[ "$(git --no-pager config -f "$HOME/.common_env.ini" --get shell.oh-my-zsh)" = "1" ]]; then
      type zsh &>/dev/null && {
        # Install oh-my-zsh
        if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
          RUNZSH=no CHSH=no zsh -c "$("$SETUP_TOOLS_ROOT/shell/bin/download_tarball.sh" -o - "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh")"
          if [[ -f "$HOME/.zshrc.pre-oh-my-zsh" ]]; then
            # Update zshrc
            echo >>"$HOME/.zshrc"
            cat "$HOME/.zshrc.pre-oh-my-zsh" >>"$HOME/.zshrc" && rm -f "$HOME/.zshrc.pre-oh-my-zsh"
            # Set theme
            local zsh_theme="$(git --no-pager config -f "$HOME/.common_env.ini" --get oh-my-zsh.theme)"
            [[ -z "$zsh_theme" ]] && zsh_theme="common-env"
            sed -ri -e "s/^ZSH_THEME=.*$/ZSH_THEME=\"$zsh_theme\"/" "$HOME/.zshrc"
            # Set plugins
            local plugins="$(git --no-pager config -f "$HOME/.common_env.ini" --get oh-my-zsh.plugins)"
            sed -ri -e "s/^plugins=.*$/plugins=\($plugins\)/" "$HOME/.zshrc"
          fi
        fi

        if [[ -d "$HOME/.oh-my-zsh" ]]; then
          # Update common-env theme
          if [[ ! -f "$HOME/.oh-my-zsh/custom/themes/common-env.zsh-theme" ||
            "$SETUP_TOOLS_ROOT/shell/oh-my-zsh/custom/themes/common-env.zsh-theme" -nt "$HOME/.oh-my-zsh/custom/themes/common-env.zsh-theme" ]]; then
            cp -vf "$SETUP_TOOLS_ROOT/shell/oh-my-zsh/custom/themes/common-env.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/common-env.zsh-theme"
          fi
        fi
      }
    fi

    # Check tmux
    # https://github.com/rothgar/awesome-tmux
    # http://marklodato.github.io/2013/10/31/autostart-tmux-on-ssh.html
    # https://awesomeopensource.com/project/samoshkin/tmux-config
    if [[ "$(git --no-pager config -f "$HOME/.common_env.ini" --get shell.tmux)" = "1" ]]; then
      type tmux &>/dev/null && {
        # Install oh-my-tmux
        if [[ ! -d "$HOME/.oh-my-tmux" ]]; then
          git clone 'https://github.com/gpakosz/.tmux.git' "$HOME/.oh-my-tmux"
          ln -svf "$HOME/.oh-my-tmux/.tmux.conf" "$HOME/.tmux.conf"
          cp -vf "$HOME/.oh-my-tmux/.tmux.conf.local" "$HOME/"
        fi
      }
    fi
  fi

  return 0
}
