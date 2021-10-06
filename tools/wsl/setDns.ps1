# https://gist.github.com/pyther/b7c03579a5ea55fe431561b502ec1ba8

# $dnsServers = (Get-NetAdapter | Where-Object InterfaceDescription -like "Cisco AnyConnect*" | Get-DnsClientServerAddress).ServerAddresses -join ','
# $dnsServers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses -join ','
# $searchSuffix = (Get-DnsClientGlobalSetting).SuffixSearchList -join ','

function set-DnsWsl($distro) {
  # if ( $dnsServers ) {
  #   wsl.exe -d $distro -u root /opt/wsl_dns.py --servers $dnsServers --search $searchSuffix
  # }
  # else {
  #   wsl.exe -d $distro -u root /opt/wsl_dns.py
  # }
  wsl.exe -d $distro -u root /opt/wsl_dns.py
}

Write-Output "Setting WSL Ubuntu DNS..."
set-DnsWsl Ubuntu
# set-DnsWsl Legacy
Start-Sleep -Seconds 1
[Environment]::Exit(0)
