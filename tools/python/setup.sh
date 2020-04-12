#! /bin/bash

# Check documentation https://docs.python.org/3/using/windows.html#installing-without-ui

function setup_python() {
  local ERROR=$SETUP_ERROR_CONTINUE

  local python_path="PortableApps/CommonFiles/python"
  local python_winpath="$(echo $WIN_APPS_ROOT/$python_path | tr '/' '\\')"
  python_path="$APPS_ROOT/$python_path"

  # Install python 3.8
  if [ ! -f "$python_path/python.exe" ]; then
    mkdir -vp "$python_path"
    local python_version="3.8.2"
    local tarball="python-${python_version}-amd64.exe"
    if [ ! -f $tarball ]; then
      wget --progress=bar:force https://www.python.org/ftp/python/$python_version/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the executable." && return $ERROR
    fi
    # Need to eval in case there is space character in the path, but the return code is always 0
    local start=$(date +%s)
    eval "./$tarball -quiet -passive InstallAllUsers=0 TargetDir=\"$python_winpath\" AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0"
    local end=$(date +%s)
    # it the install took less than 3s, it probably has failed, ask for reinstall
    if [ $(expr $end - $start) -le 3 ]; then
      read -p 'The python installation failed, maybe a previous installation needs to be removed first, do you want to try ? (Y/n)' answer
      if [ -z "$answer" ] || [[ "$answer" =~ ^[yY]$ ]]; then
        eval "./$tarball -uninstall InstallAllUsers=0 TargetDir=\"$python_winpath\" AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0"
        eval "./$tarball -quiet -passive InstallAllUsers=0 TargetDir=\"$python_winpath\" AssociateFiles=0 CompileAll=0 PrependPath=0 Shortcuts=0 Include_doc=0 Include_debug=0 Include_dev=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_lib=1 Include_pip=1 Include_symbols=0 Include_tcltk=0 Include_test=0 Include_tools=0"
      fi
    fi
    test ! -f "$python_path/python.exe" && echo -e "\nError while installing python $python_version" && return $ERROR
    rm -f $tarball
  fi
  if [ ! -f "$python_path/python.exe" ]; then
    return 1
  fi
  if ! "$python_path/python.exe" -m pip --version &>/dev/null; then
    echo "No pip installed" >&2 && return $ERROR
  fi
  if [ $("$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" list | grep -E "^$python_version" | wc -l) -eq 0 ]; then
    "$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" create "$python_path/python.exe" || (echo "Error, unable to set python virtual env." && return $ERROR)
  fi
}
