#! /bin/bash

update=0
grep insecure ~/.curlrc &>/dev/null || {
  update=1
  echo insecure >>~/.curlrc
}
grep 'check-certificate = off' ~/.wgetrc &>/dev/null || {
  update=1
  echo 'check-certificate = off' >>~/.wgetrc
}
[[ $update -eq 1 ]] && echo "Allowing curl and wget to ignore SSL certifacte issue, be aware that it is security hole..."
