# Ensure to have elevated rights
param([switch]$Elevated)
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)
{
  if ($elevated) {
    # tried to elevate, did not work, aborting
  } else {
    try {
    $process = Start-Process powershell.exe -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    [Environment]::Exit($process.ExitCode)
    }
    catch {
      Write-Host $_
    }
  }
  [Environment]::Exit(1)
}

# Command to run
# https://gist.github.com/pyther/b7c03579a5ea55fe431561b502ec1ba8
# Write-Output (Get-Location).Path
Write-Output "Current Cisco metric:"
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Get-NetIPInterface
Write-Output "`nSetting Cisco metric..."
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Set-NetIPInterface -InterfaceMetric 6000
Start-Sleep -Seconds 1
Write-Output "`nCurrent Cisco metric:"
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Get-NetIPInterface
Start-Sleep -Seconds 1
Write-Output ""
.\setDns.ps1
[Environment]::Exit(0)
