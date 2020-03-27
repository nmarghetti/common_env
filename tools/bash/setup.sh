#! /bin/bash

function setup_bash() {
  if [ ! -z "$HOME" ]; then
    mkdir -vp "$HOME"
  fi

  # Create template .bashrc if not there yet
  if [ ! -f "$HOME/.bashrc" ]; then
    echo "Create $HOME/.bashrc"
    cat > "$HOME/.bashrc" << EOM
#! /bin/bash

# BEGIN - GENERATED CONTENT, DO NOT EDIT !!!
# END - GENERATED CONTENT, DO NOT EDIT !!!

# Custom settings
EOM
  fi

  # Add content to .bashrc
  local content=$(cat <<-EOM
if [ ! "\$(basename "\${BASH_SOURCE[0]}")" = ".bashrc" ]; then
  echo "ERROR !!! Unable to find the path of .bashrc, not sourcing it, many things will probably not work !!!" >&2
else
  [ "\$COMMON_ENV_DEBUG" = "1" ] && echo "Sourcing \$(readlink -f "\${BASH_SOURCE[0]}") ..."
  # Ensure that \$HOME points to where is located the current file being sourced
  export HOME=\$(cd \$(dirname "\${BASH_SOURCE[0]}") && pwd)
  source "$(readlink -f "$SETUP_TOOLS_ROOT/bash/source/.bashrc")"
fi
EOM
)
  local bashrc="$(cat "$HOME/.bashrc")"
  echo "$bashrc" | awk -f "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v replace_append=1 \
  -v content="$(echo "$content" | sed -re 's#\\#\\\\#g')" >| "$HOME/.bashrc"
}
