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
      Write-Host $myinvocation.MyCommand.Definition
      $process = Start-Process powershell.exe -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated {1}' -f ($myinvocation.MyCommand.Definition, ($args -join ' ')))
      [Environment]::Exit($process.ExitCode)
    }
    catch {
      Write-Host $_
    }
  }
  [Environment]::Exit(1)
}

# CiscoMetric: 2039, 2041
# Dns: 2010, 2039, 2041, 2061
# 2039: successful connection
# 2010: deconnection

Write-Output ('Adding tasks for {0}\{1} in {2} from {3}' -f ($args[1], $args[2], $args[3], $args[0]))
Register-ScheduledTask -xml (Get-Content ('{0}\WSL_Admin_CiscoMetric_2039.xml' -f ($args[0])) | Out-String) -TaskName 'WSL_Admin_CiscoMetric_2039' -User ('{0}\{1}' -f ($args[1], $args[2])) -TaskPath $args[3] -Force
Register-ScheduledTask -xml (Get-Content ('{0}\WSL_Admin_CiscoMetric_2041.xml' -f ($args[0])) | Out-String) -TaskName 'WSL_Admin_CiscoMetric_2041' -User ('{0}\{1}' -f ($args[1], $args[2])) -TaskPath $args[3] -Force
Register-ScheduledTask -xml (Get-Content ('{0}\WSL_CiscoDns_2010.xml' -f ($args[0])) | Out-String) -TaskName 'WSL_CiscoDns_2010' -User ('{0}\{1}' -f ($args[1], $args[2])) -TaskPath $args[3] -Force
# Register-ScheduledTask -xml (Get-Content ('{0}\WSL_CiscoDns_2039.xml' -f ($args[0])) | Out-String) -TaskName 'WSL_CiscoDns_2039' -User ('{0}\{1}' -f ($args[1], $args[2])) -TaskPath $args[3] -Force
# Register-ScheduledTask -xml (Get-Content ('{0}\WSL_CiscoDns_2041.xml' -f ($args[0])) | Out-String) -TaskName 'WSL_CiscoDns_2041' -User ('{0}\{1}' -f ($args[1], $args[2])) -TaskPath $args[3] -Force
Register-ScheduledTask -xml (Get-Content ('{0}\WSL_CiscoDns_2061.xml' -f ($args[0])) | Out-String) -TaskName 'WSL_CiscoDns_2061' -User ('{0}\{1}' -f ($args[1], $args[2])) -TaskPath $args[3] -Force
Start-Sleep -Seconds 1
[Environment]::Exit(0)
