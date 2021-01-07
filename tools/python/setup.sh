#! /usr/bin/env bash

# Check documentation https://docs.python.org/3/using/windows.html#installing-without-ui
# pip install location https://pip.pypa.io/en/latest/user_guide/#user-installs

function setup_python() {
  local ERROR=$SETUP_ERROR_STOP
  # if there is already python >= 3.7, error would not stop the process
  type python &>/dev/null && python --version | cut -d' ' -f2 | cut -d'.' -f1,2 | grep -E '^3\.[7-9]' >/dev/null && ERROR=$SETUP_ERROR_CONTINUE

  local python_path="$APPS_ROOT/PortableApps/CommonFiles/python"
  local python_winpath="$(get_path_to_windows_back "$python_path")"
  local python_version="3.8.2"
  local python_bin="$python_path/python.exe"

  # if python and pip already locally installed
  if [[ -f '/usr/bin/python' && -f '/usr/bin/pip' ]]; then
    python_bin='/usr/bin/python'
  # if the current python version is present, but not installed in APPS_ROOT
  elif type python &>/dev/null &&
    [ "$(python --version | cut -d' ' -f2 | tr -d '[:space:]')" = "$python_version" ] &&
    [ "$(which python | grep -vE "$APPS_ROOT")" ]; then
    python_bin=$(which python)
  else
    export PYTHONUSERBASE="$python_winpath"
    export PATH="$PYTHONUSERBASE/Scripts:$PYTHONUSERBASE/Python38/Scripts:$PATH"
    unset PYTHONPATH
    unset PYTHONHOME
  fi

  # Install python 3.8
  if [[ ! -f "$python_bin" ]]; then
    mkdir -vp "$python_path"
    local tarball="python-${python_version}-amd64.exe"
    download_tarball "https://www.python.org/ftp/python/$python_version/$tarball"
    [[ $? -ne 0 ]] && echo "Unable to get the installer" && return "$ERROR"
    # Need to eval in case there is space character in the path, but the return code is always 0
    # Need to install for all user https://stackoverflow.com/questions/61641280/python3-8-venv-returned-exit-status-101/62207756#62207756
    local start=$(date +%s)
    eval "./$tarball -quiet -passive InstallAllUsers=0 TargetDir=\"$python_winpath\" AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0"
    local end=$(date +%s)
    # it the install took less than 3s, it probably has failed, ask for reinstall
    if [[ $(expr $end - $start) -le 3 ]]; then
      read -rp 'The python installation failed, maybe a previous installation needs to be removed first, do you want to try ? (Y/n)' answer
      if [[ -z "$answer" ]] || [[ "$answer" =~ ^[yY]$ ]]; then
        eval "./$tarball -uninstall InstallAllUsers=0 TargetDir=\"$python_winpath\" AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0"
        eval "./$tarball -quiet -passive InstallAllUsers=0 TargetDir=\"$python_winpath\" AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0"
      fi
    fi
    test ! -f "$python_bin" && echo -e "\nError while installing python $python_version" && return $ERROR
    rm -f $tarball
  fi
  [[ ! -f "$python_bin" ]] && echo "Error: python binary is not installed" && return $ERROR
  ! "$python_bin" -m pip --version &>/dev/null && echo "Error: pip is not installed" >&2 && return $ERROR

  # Create venv
  # to be checked why putting $python_version in grep does not work
  if [[ $("$SETUP_TOOLS_ROOT/shell/bin/pythonvenv.sh" list | grep -cE "^3.[7-9]") -eq 0 ]]; then
    "$SETUP_TOOLS_ROOT/shell/bin/pythonvenv.sh" create "$python_bin" || {
      echo "Error, unable to set python virtual env." && return "$ERROR"
    }
  fi

  local python_modules=$(git --no-pager config -f "$HOME/.common_env.ini" --get-all python.modules 2>/dev/null)
  for py in "$python_bin" "$APPS_ROOT/home/.venv/3/bin/python" "$APPS_ROOT/home/.venv/$python_version/Scripts/python.exe"; do
    if [[ -f "$py" ]]; then
      [[ "$py" = "/usr/bin/python" ]] && continue
      echoColor 36 "Checking $py..."
      # ! "$py" -m autopep8 --version &>/dev/null && "$py" -m pip install --upgrade wheel pip pylint autopep8
      "$py" -m pip install --upgrade wheel pip setuptools
      [[ -n "$python_modules" ]] && "$py" -m pip install --upgrade $(echo "$python_modules")

      # "$py" -m pip config set global.index-url "https://pypi.python.org/simple/"
      # "$py" -m pip config set global.find-links "https://pypi.python.org/simple/ https://pypi.org/simple/"
      # "$py" -m pip config set global.download-cache "$WINDOWS_APPS_ROOT\\PortableApps\\Common\\python\\cache" --> does not seem to be taken into account, more based on %APPDATA%

      # "$py" -m pip install --upgrade wheel
      # "$py" -m pip install --upgrade pip
      # # Keep in mind the --user that can be used, eg. Python extension in VSCode
      # "$py" -m pip install --upgrade pylint   #--user
      # "$py" -m pip install --upgrade autopep8 #--user
    fi
  done
  set +x
}
