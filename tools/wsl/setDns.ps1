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
  wsl.exe -d $distro -u root sh -c "if [ -f /opt/wsl_dns.py ]; then /opt/wsl_dns.py; else echo '/opt/wsl_dns.py does not exist'; fi"
}

[System.Console]::OutputEncoding = [System.Text.Encoding]::Unicode
$distributions = (wsl.exe --list --quiet | Select-String -Encoding unicode -Pattern '^Ubuntu' | Out-String).Split("`n")
foreach($distribution in $distributions) {
  $distribution = $distribution.Trim()
  if ($distribution -match '^Ubuntu') {
    Write-Output ("`nSetting WSL {0} DNS..." -f $distribution)
    set-DnsWsl $distribution
  }
}
# set-DnsWsl Legacy
Start-Sleep -Seconds 1
[Environment]::Exit(0)
