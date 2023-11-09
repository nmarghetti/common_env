# Ensure to have elevated rights
param([switch]$Elevated)
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false) {
  if ($elevated) {
    # tried to elevate, did not work, aborting
  } else {
    try {
      $process = Start-Process powershell.exe -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated {1}' -f ($myinvocation.MyCommand.Definition, ($args -join ' ')))
      [Environment]::Exit($process.ExitCode)
    }
    catch {
      Write-Host $_
    }
  }
  [Environment]::Exit(1)
}

# Go to the folder of the script
Set-Location $PSScriptRoot

[System.Console]::OutputEncoding = [System.Text.Encoding]::Unicode
$connected = $false
$distributions = (wsl.exe --list --quiet | Select-String -Encoding unicode -Pattern '^Ubuntu' | Out-String).Split("`n")
foreach($distribution in $distributions) {
  $distribution = $distribution.Trim()
  if ($distribution -match '^Ubuntu') {
    Write-Output ("`nChecking WSL {0} connectivity..." -f $distribution)
    if (wsl.exe -d $distribution -u root sh -c 'ping -c 2 -W 2 8.8.8.8') {
      $connected = $true
      Write-Output ("WSL {0} is connected" -f $distribution)
      break
    }
  }
}

if ($connected -eq $false) {
# Command to run
# https://gist.github.com/pyther/b7c03579a5ea55fe431561b502ec1ba8
  Write-Output "Current Cisco metric:"
  Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Get-NetIPInterface
  Write-Output "`nSetting Cisco metric..."
  Get-NetAdapter | Where-Object InterfaceDescription -Match "Cisco AnyConnect" | Set-NetIPInterface -InterfaceMetric 6000
  Start-Sleep -Seconds 1
  Write-Output "`nCurrent Cisco metric:"
  Get-NetAdapter | Where-Object InterfaceDescription -Match "Cisco AnyConnect" | Get-NetIPInterface
  Start-Sleep -Seconds 1
}

Write-Output ""
.\setDns.ps1

[Environment]::Exit(0)
