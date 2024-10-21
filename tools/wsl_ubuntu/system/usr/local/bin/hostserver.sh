#! /bin/bash

usage() {
  cat <<EOM
Usage: $0 [options]

Options:
  -a : check for all interfaces, do not stop at the first found
  -d : just display all interfaces ip and quit
  -p <port> : port to check
  -q : quiet mode, only print the ip address found
  -m <host> : start with the given host first
  -l : return localhost if available
  -f : fasten it by running checks in parallel
  -s <file> : save the host if found in the given file
  -v : verbose mode
  -h : display this help

It will try amoung all network interface to find a server running with the given port. If no port given it will just a machine accessible.
EOM
}

echoError() {
  echo "$*" >&2
}

exitError() {
  echoError "$*"
  exit 1
}

echoInfo() {
  if [ ! "$quiet" = "1" ]; then
    echoError "$*" >&2
  fi
}

port=
noStopFound=0
localhostOk=0
quiet=0
verbose=0
firstHost=
onlyDisplayIps=0
runInParallel=0
saveFile=
# reset getopts - check https://man.cx/getopts(1)
OPTIND=1
while getopts "hadflm:p:s:qv" opt; do
  case "$opt" in
    a) noStopFound=1 ;;
    d) onlyDisplayIps=1 ;;
    f) runInParallel=1 ;;
    l) localhostOk=1 ;;
    m) firstHost="$OPTARG" ;;
    p) port="$OPTARG" ;;
    s) saveFile="$OPTARG" ;;
    q) quiet=1 ;;
    v) verbose=1 ;;
    h)
      usage
      exit 0
      ;;
    \? | *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))
[ $# -ne 0 ] && {
  echo "Error: No argument accepted." >&2
  usage
  exit 1
}

# https://www.fosslinux.com/35730/5-ways-to-check-if-a-port-is-open-on-a-remote-linux-pc.htm

ping_host() {
  local host="$1"
  local count=1
  local timeout=2
  local ping_option
  case "$(uname -s | tr '[:upper:]' '[:lower:]')" in
    msys_nt* | mingw64_nt* | cygwin_nt*) ping_option="-n $count -w $timeout" ;;
    linux) ping_option="-c $count -W $timeout" ;;
    darwin) ping_option="-c $count -t $timeout" ;;
    *) ping_option="-c $count -W $timeout" ;;
  esac
  ping $ping_option "$@"
  return $?
}

get_ips() {
  ipconfig.exe | grep -Ei 'ipv4' | cut -d':' -f2 | tr '\n' '-' | tr -d '[:space:]' | tr '-' '\n'
}

check_ip() {
  local host="$1"
  local port="$2"
  echoInfo "Checking $host..."
  # Host not reachable
  if ! ping_host "$host" >/dev/null 2>&1; then
    # if ! ping_host "$host"; then
    echoError "Unable to reach $host"
    # Host not having route to
    if ! traceroute --tries 1 --max-hop 1 "$host" >/dev/null 2>&1; then
      # if ! traceroute --tries 2 --max-hop 1 "$host"; then
      echoError "Not even able to find a route to $host"
    fi
    echoInfo
    return 1
  fi
  if [ -n "$port" ]; then
    connected=0
    echoInfo "Checking port $port..."
    # telnet "$host" "$port"
    if type nc >/dev/null 2>&1; then
      if nc -zw 2 "$host" "$port"; then
        connected=1
      fi
    # if echo 2>/dev/null >/dev/tcp/"$host"/"$port"; then
    elif timeout 1 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
      connected=1
    fi
    if [ $connected -eq 0 ]; then
      echoError "Unable to connect to $host:$port"
      echoInfo
      return 1
    fi
  fi
  if [ "$host" = "127.0.0.1" ] && [ ! "$localhostOk" = "1" ]; then
    [ -n "$port" ] && echoInfo "Server running on localhost :D"
    echoInfo
    return 1
  fi
  echoInfo "Connection to $host${port:+:}$port succeeded"
  return 0
}

if [ "$verbose" = "1" ]; then
  echo "Checking among your network interfaces:"
  powershell.exe -ExecutionPolicy RemoteSigned -Command 'Get-NetAdapter  | Where-Object Status -Match "Up" | ForEach-Object -Process { Write-Output ("{0} [{1}] - IP: {2} - nameserver: {3}" -f ($_.InterfaceDescription, $_.InterfaceAlias, ($_ | Get-NetIPAddress -AddressFamily IPv4).IPAddress, ((($_ | Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses | Sort-Object | Get-Unique) -join ",") )) }'
  echo
fi

if [ "$onlyDisplayIps" -eq 1 ]; then
  if [ ! "$verbose" = "1" ]; then
    get_ips
  fi
  exit 0
fi

# Get the ip address of Cisco interface
ciscoIp="$(ciscoip.sh)"

hostFound=
declare -A host_ips=()
# for ip in $(powershell.exe -ExecutionPolicy RemoteSigned -Command '[System.Console]::OutputEncoding = [System.Text.Encoding]::ASCII; (Get-NetAdapter | Where-Object Status -Match "Up" | Where-Object { ($_.InterfaceDescription -Match "Cisco AnyConnect") -or ($_.InterfaceAlias -Match "WSL") } | Get-NetIPAddress -AddressFamily IPv4).IPAddress'); do
for ip in 127.0.0.1 "$firstHost" "$ciscoIp" $(get_ips | grep -vE -e '127.0.0.1' -e "^$firstHost\$" -e "^$ciscoIp\$"); do
  [ -z "$ip" ] && continue
  host="$(echo "$ip" | tr -d '[:space:]')"
  if [ "$runInParallel" -eq 1 ]; then
    check_ip "$host" "$port" &
    host_ips["$ip"]=$!
  else
    if check_ip "$host" "$port"; then
      hostFound="$host"
      if [ ! "$noStopFound" = "1" ]; then
        break
      fi
    fi
    echoInfo
  fi
done

if [ "$runInParallel" -eq 1 ]; then
  for ip in "${!host_ips[@]}"; do
    if wait "${host_ips[$ip]}"; then
      hostFound="$ip"
      if [ ! "$noStopFound" = "1" ]; then
        break
      fi
    fi
  done
fi

[ -z "$hostFound" ] && exit 1

echo "$hostFound"
[ -n "$saveFile" ] && echo "$hostFound" >"$saveFile"

exit 0
