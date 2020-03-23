#! /bin/sh

SETUP_SILENT=$(echo "$@" | tr '[:space:]' '\n' | grep -cE '^(-s|--silent)$')

if [ ! "$(uname -s )" = "Darwin" ]; then
  echo "You are not running on Mac, nothing to do."
  exit 0
fi

type greadlink &>/dev/null
if [ $? -ne 0 ]; then
  if [ $SETUP_SILENT -ne 0 ]; then
    answer='y'
  else
    echo "Gnu readlink is not available, some components will be installed:"
    echo "  * brew install coreutils"
    echo "  * brew install gnu-sed"
    echo "  * brew install gawk"
    echo "Your shell profile will be update to export PATH as follow: export PATH=\"/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:$PATH\""
    echo "Do you want to proceed ? (Y/n) "
    read answer
  fi
  if [[ "$answer" =~ ^[yY]$ ]]; then
    brew install coreutils
    brew install gnu-sed
    brew install gawk
    if [ $? -ne 0 ]; then
      echo "Error, unable to install coreutils"
      exit 1
    fi
  else
    echo "Exit setup."
    exit 1
  fi
  export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  # Setup PATH in the shell profile
  shell_file="$HOME/.bashrc"
  if [ -f "$HOME/.zshenv" ]; then
    shell_file="$HOME/.zshenv"
  fi
  echo 'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:$PATH' >> "$shell_file"
  for prog in gawk; do
    for i in /usr/local/Cellar/$prog/*/bin; do
      echo 'export PATH="'$i':$PATH"' >> "$shell_file"
    done
  done
fi
