#! /usr/bin/env bash

function setup_python2() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local python_path="C:/Python27"

  # Install python 2.7
  if [[ ! -f "$python_path/python.exe" ]]; then
    local python_version="2.7.17"
    local tarball="python-${python_version}.amd64.msi"
    if [[ ! -f $tarball ]]; then
      download_tarball "https://www.python.org/ftp/python/$python_version/$tarball"
      [[ $? -ne 0 ]] && echo "Binary file not installed" && return $ERROR
    fi
    msiexec.exe -i $tarball -passive -l\* python2_log.txt
    test $? -ne 0 && echo -e "\nError while installing python $python_version, please check python2_log.txt" && return $ERROR
    rm -f $tarball
  fi
  [[ ! -f "$python_path/python.exe" ]] && echo "Binary file not installed" && return $ERROR
  if ! "$python_path/python.exe" -m pip --version &>/dev/null; then
    echo "No pip installed" >&2 && return $ERROR
  fi
  # to be checked why putting $python_version in grep does not work
  if [[ $("$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" list | grep -cE "^2.7.17$") -eq 0 ]]; then
    "$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" create "$python_path/python.exe" || (echo "Error, unable to set python virtual env." && return $ERROR)
  fi

  for py in "$python_path/python.exe" "$APPS_ROOT/home/.venv/$python_version/Scripts/python.exe"; do
    if [[ -f "$py" ]]; then
      "$py" -m pip install --upgrade wheel
      "$py" -m pip install --upgrade pip
      # Keep in mind the --user that can be used, eg. Python extension in VSCode
      "$py" -m pip install --upgrade pylint   #--user
      "$py" -m pip install --upgrade autopep8 #--user
    fi
  done
}
