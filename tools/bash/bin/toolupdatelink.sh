#! /bin/bash

[ "$COMMON_ENV_FULL_DEBUG" = "1" ] && eval "$COMMON_ENV_DEBUG_CMD"

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_NAME=$(basename "${SCRIPT_PATH}")
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")

SAVE_FILE=~/.$(basename "${SCRIPT_NAME}" .sh)

function usage() {
  echo -e "Usage: $(basename $0) [destination_folder]
    Creates links of all .sh files in destination_folder without .sh extension.
    By default it goes in bin folder where $(basename $0) is located (${SCRIPT_DIR}/bin).
  If already ran and no destination_folder given, it uses the last path used (saved in ${SAVE_FILE})"
}

function exitMsg() {
  echo "$@"
  exit 1
}

if [ "$1" = "-h" ] || [ "$1" = "-?" ] || [ "$1" = "--help" ]; then
  usage
  exit
fi

LINK_PATH=${SCRIPT_DIR}
if [ ! -z "$1" ]; then
  DEST_DIR=$(cd "$1" 2>/dev/null && pwd)
  [[ ! -d "${DEST_DIR}" ]] && exitMsg "Destination directory '${1}' doest not exist"
  echo "last_dir=${DEST_DIR}" >| "${SAVE_FILE}"
  elif [ -f "${SAVE_FILE}" ]; then
  DEST_DIR=$(grep 'last_dir=' "${SAVE_FILE}" | head -1 | cut -d= -f2)
  [[ ! -d "${DEST_DIR}" ]] && exitMsg "Destination directory '${1}' taken from '${SAVE_FILE}' doest not exist"
else
  DEST_DIR=${SCRIPT_DIR}/bin
  LINK_PATH=..
  mkdir -p "${DEST_DIR}"
fi

cd "${SCRIPT_DIR}"
[[ $? -ne 0 ]] && exitMsg "Error: unable to go to '${SCRIPT_DIR}'"

[[ ! -d "${DEST_DIR}" ]] && exitMsg "Destination directory '${DEST_DIR}' doest not exist"

# Clean wrong link in destination directory
find -L "${DEST_DIR}" -maxdepth 1 -type l -exec rm -vf {} \;

for ext in awk sh pl py; do
  for i in $(ls *.${ext} 2>/dev/null); do
    ln -vsf "${LINK_PATH}/$i" "${DEST_DIR}/$(basename "$i" .${ext})" 2>/dev/null
  done
done

if ! echo $PATH | grep -E -q "(^|:)${DEST_DIR}(\$|:)"; then
  echo "Add '${DEST_DIR}' is in your path:"
  echo "export PATH=\$PATH:${DEST_DIR}"
fi

