#! /bin/bash

function setup_python2() {
  local ERROR=$SETUP_ERROR_CONTINUE

  local python_path="C:/Python27"
  # Install python 2.7
  if [ ! -f "$python_path/python.exe" ]; then
    local python_version="2.7.17"
    local tarball="python-${python_version}.amd64.msi"
    if [ ! -f $tarball ]; then
      wget --progress=bar:force "https://www.python.org/ftp/python/$python_version/$tarball"
      test $? -ne 0 && echo "Error, unable to retrieve the installer." && return $ERROR
    fi
    msiexec.exe -i $tarball -passive -l\* python2_log.txt
    test $? -ne 0 && echo -e "\nError while installing python $python_version, please check python2_log.txt" && return $ERROR
    rm -f $tarball
  fi
  if [ ! -f "$python_path/python.exe" ]; then
    return $ERROR
  fi
  if ! "$python_path/python.exe" -m pip --version &>/dev/null; then
    echo "No pip installed" >&2 && return $ERROR
  fi
  if [ $("$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" list | grep -E "^$python_version" | wc -l) -eq 0 ]; then
    "$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" create "$python_path/python.exe" || (echo "Error, unable to set python virtual env." && return $ERROR)
  fi
}
