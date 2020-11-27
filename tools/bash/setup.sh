#! /usr/bin/env bash

# article about bash and zsh startup scripts https://tanguy.ortolo.eu/blog/article25/shrc

function setup_bash() {
  if [[ ! -z "$HOME" ]]; then
    mkdir -vp "$HOME"
  fi

  # Create template .bashrc and .zshrc if not there yet
  local shellrc
  for shellrc in .bashrc .zshrc; do
    if [[ ! -f "$HOME/$shellrc" ]]; then
      echo "Create $HOME/$shellrc"
      cat >"$HOME/$shellrc" <<EOM
#! /usr/bin/env bash

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
  if [[ -f "$setup_tool_root/bash/source/.bashrc" ]]; then
    source "$setup_tool_root/bash/source/.bashrc"
  elif [[ -f "/mnt$setup_tool_root/bash/source/.bashrc" ]]; then
    source "/mnt$setup_tool_root/bash/source/.bashrc"
  else
    echo "ERROR !!! Unable to find .bashrc"
  fi
fi
EOM
  )
  local bashrc="$(cat "$HOME/.bashrc")"
  echo "$bashrc" | awk -f "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v replace_append=1 \
    -v content="$(echo "$content" | sed -re 's#\\#\\\\#g')" >|"$HOME/.bashrc"

  # Add content to .zshrc
  content=$(
    cat <<-EOM
  $([ -n "$COMMON_ENV_SETUP_MAC_PATH" ] && echo -ne "$COMMON_ENV_SETUP_MAC_PATH\n  ")[ "\$COMMON_ENV_DEBUG" = "1" ] && echo "Sourcing '\$0' ..." >&2
  source "$(readlink -f "$SETUP_TOOLS_ROOT/bash/source/.bashrc")"
EOM
  )
  local zshrc="$(cat "$HOME/.zshrc")"
  echo "$zshrc" | awk -f "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v replace_append=1 \
    -v content="$(echo "$content" | sed -re 's#\\#\\\\#g')" >|"$HOME/.zshrc"
}
