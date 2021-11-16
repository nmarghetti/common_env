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
      # Ensure to have the right to run script
      if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
        Start-Process powershell.exe -Wait -PassThru -Verb RunAs -ArgumentList '-noprofile -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force"'
      }
      $process = Start-Process powershell.exe -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated {1}' -f ($myinvocation.MyCommand.Definition, ($args -join ' ')))
      [Environment]::Exit($process.ExitCode)
    }
    catch {
      Write-Host $_
    }
  }
  [Environment]::Exit(1)
}

# Set encoding for the current session as unicode
[System.Console]::OutputEncoding = [System.Text.Encoding]::Unicode

# List all Windows optional features
# Get-WindowsOptionalFeature -Online

# Ensure to activate needed features
Write-Output 'Ensure to have some features activated...'
$features = @('VirtualMachinePlatform', 'Microsoft-Hyper-V', 'Microsoft-Windows-Subsystem-Linux')
$featureInstalled = $false
foreach($feature in $features) {
  if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).State -ne 'Enabled') {
    Write-Output ('Activating optional feature {0}' -f ($feature))
    Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart -LogLevel 2 | out-null
    $featureInstalled = $true
  }
}

try {
  wsl.exe --help | out-null
} catch {
  if ($featureInstalled) {
    Write-Output 'Some features have been installed, please restart the computer to continue the installation.'
    [Environment]::Exit(1)
  }
  Write-Output 'ERROR: WSL is not available, you migth need to restart the computer.'
  [Environment]::Exit(1)
}

if (wsl.exe --set-default-version 2 | Select-String -Quiet -Encoding unicode 'requires an update to its kernel') {
  Write-Output 'Updating WSL kernel...'
  curl.exe -o wsl_update_x64.msi 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'
  if ((Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList ('/i', 'wsl_update_x64.msi', '/passive')).ExitCode -ne 0) {
    Write-Output 'ERROR: Unable to update WSL kernel, it will not be possible to take advantage of WSL 2 improvements'
  }
  wsl.exe --set-default-version 2
}

if (!(wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern '^Ubuntu-20.04$')) {
  Write-Output 'Installing Ubuntu-20.04...'
  curl.exe -Lo Ubuntu-20.04.appx https://aka.ms/wslubuntu2004
  Add-AppxPackage .\Ubuntu-20.04.appx
  ubuntu2004.exe install --root
}

if (!(wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern '^Ubuntu-20.04$')) {
  Write-Output 'ERROR: Unable to install Ubuntu-20.04'
  [Environment]::Exit(1)
} else {
  Write-Output 'Set Ubuntu-20.04 as default WSL distribution'
  wsl.exe --set-default 'Ubuntu-20.04'
}

# Set encoding for the current session as ASCII to communicate with wsl
[System.Console]::OutputEncoding = [System.Text.Encoding]::ASCII
if (wsl.exe -d Ubuntu-20.04 -u root sh -c 'uname -a' | Select-String -Pattern 'linux.*microsoft.*wsl2' -Quiet) {
  Write-Output 'Ubuntu-20.04 properly setup with WSL version 2'
} elseif (wsl.exe -d Ubuntu -u root sh -c 'uname -a' | Select-String -Pattern 'linux.*microsoft' -Quiet) {
  Write-Output 'Ubuntu-20.04 is setup with WSL version 1 only'
} else {
  Write-Output 'ERROR: Ubuntu-20.04 is not properly setup'
  [Environment]::Exit(1)
}

[Environment]::Exit(0)
