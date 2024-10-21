#! /usr/bin/env bash

echo_error() {
  echo "$*" >&2
}

main() {
  type parted >/dev/null 2>&1 || apt install -y parted
  [ -z "$WSL_USER_HOME_SIZE" ] && echo_error "Error: WSL_USER_HOME_SIZE is not set" && return 1
  [ -z "$WSL_USER" ] && echo_error "Error: WSL_USER is not set" && return 1
  device=$(lsblk | grep "${WSL_USER_HOME_SIZE}G" | grep 'disk' | head -1 | awk '{ print $1 }')
  [ -z "$device" ] && echo_error "No device matching given size '$WSL_USER_HOME_SIZE' found to create the /home/$WSL_USER partition" && return 1
  if [ "$(echo "$device" | wc -l)" -gt 1 ]; then
    echo "Multiple devices found for the given size '$WSL_USER_HOME_SIZE':"
    echo "$device"
    return 1
  fi
  device="/dev/$device"
  echo "Using the device $device for /home/$WSL_USER"
  parted "$device" print 2>&1 | grep -qi msdos || parted "$device" mklabel msdos
  parted "$device" print | grep -qi primary || parted -a optimal "$device" mkpart primary ext4 0% 100%
  parted "$device" print | grep -i primary | grep -qi ext4 || mkfs.ext4 "$device"1
  device="${device}1"
  [ ! -e "$device" ] && echo_error "Error: Unable to use device '$device' for the /home/$WSL_USER partition" && return 1
  # Ensure to add the device to /etc/fstab
  sed -i -re '/.* \/home\/'"$WSL_USER"' .*/d' /etc/fstab
  # echo "$(blkid | grep "$device" | awk '{ print $2 }' | tr -d '"') /home/$WSL_USER ext4 defaults 0 0" >>/etc/fstab
  echo "$device /home/$WSL_USER ext4 defaults 0 0" >>/etc/fstab

  if ! mount | grep -qEe "^$device on /home/$WSL_USER"; then
    echo "Mounting $device to /home/$WSL_USER"

    # backup user home if not empty
    if [ -n "$(ls -A "/home/$WSL_USER")" ]; then
      if [ ! -e "/home/$WSL_USER.bak" ]; then
        mv "/home/$WSL_USER" "/home/$WSL_USER".bak
      else
        mv "/home/$WSL_USER" "/home/$WSL_USER.$(date +%Y_%m_%d-%H_%M)".bak
      fi
    fi

    mkdir -p "/home/$WSL_USER"
    # systemctl daemon-reload
    if mount "$device" "/home/$WSL_USER"; then
      chown "$WSL_USER":"$WSL_USER" "/home/$WSL_USER"
      if [ ! -f "/home/$WSL_USER/.bashrc" ]; then
        rsync -vau "/home/$WSL_USER".bak/ "/home/$WSL_USER"
      fi
    else
      echo "Unable to mount $device to /home/$WSL_USER"
    fi
  fi
}

main
