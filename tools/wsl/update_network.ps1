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

Write-Output("Verifying NAT network is {0} and NAT gateway ip address is {1}..." -f ($args[0], $args[1]))
$currentNatNetwork = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork
$currentNatGateway = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress
Write-Output("Current NAT network is {0} and NAT gateway ip address is {1}..." -f ($currentNatNetwork, $currentNatGateway))
if ($currentNatNetwork -eq $args[0] -And $currentNatGateway -eq $args[1]) {
  Write-Output("The configuration is already well set.")
} else {
  Write-Output("Updating the configuration...")
  Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork -Value $args[0]
  Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress -Value  $args[1]
  $currentNatNetwork = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork
  $currentNatGateway = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress
  Write-Output("Current NAT network is {0} and NAT gateway ip address is {1}..." -f ($currentNatNetwork, $currentNatGateway))
  Write-Output("")
  Write-Output("/!\ You need to restart the computer for the change to be taken into account /!\")
  Start-Sleep -Seconds 5
}

Start-Sleep -Seconds 1
[Environment]::Exit(0)
