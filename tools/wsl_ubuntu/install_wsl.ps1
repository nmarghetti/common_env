# Ensure to have elevated rights
param(
  [switch]$elevated,
  [string]$ubuntuVersion = 'Ubuntu-24.04',
  [string]$installName = '',
  [string]$installPath = '',
  [string]$installUserHome = '',
  [int]$userHomeSize = 172,
  [string]$natNetwork = '',
  [string]$natGatewayIp = ''
)
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
function Print-Param {
  Write-Output ('Running {0}' -f "$myinvocation.MyCommand.Definition")
  Write-Output ('Elevated: {0}' -f "$elevated")
  Write-Output ('UbuntuVersion: {0}' -f "$ubuntuVersion")
  Write-Output ('InstallName: {0}' -f "$installName")
  Write-Output ('InstallPath: {0}' -f "$installPath")
  Write-Output ('InstallUserHome: {0}' -f "$installUserHome")
  Write-Output ('UserHomeSize: {0}' -f "$userHomeSize")
  Write-Output ('NatNetwork: {0}' -f "$natNetwork")
  Write-Output ('NatGatewayIp: {0}' -f "$natGatewayIp")
  Write-Output ('Args: {0}' -f ($args -join ' '))
}
# Print-Param
if ($installName -eq '') {
  $installName = $ubuntuVersion
}

function Create-User-VHD {
  # Create a virtual drive for the user home
  if ($installUserHome -ne '') {
    if (!(Test-Path $installUserHome -PathType leaf)) {
      Write-Output ('Creating wsl home virtual drive "{0}"...' -f $installUserHome)
      $disk = New-VHD -Path $installUserHome -Dynamic -SizeBytes (1GB * $userHomeSize)
      if (!(Test-Path $installUserHome -PathType leaf)) {
        Write-Output ('ERROR: Unable to create virtual drive "{0}"' -f $installUserHome)
        pauseError('File {0} does not exist' -f $installUserHome)
        [Environment]::Exit(1)
      }
      if (!$disk) {
        Write-Output ('ERROR: Unable to create virtual drive "{0}"' -f $installUserHome)
        pauseError('Disk is not created')
        [Environment]::Exit(1)
      }
    }
  }
}

function Mount-User-VHD {
  # Create a virtual drive for the user home
  if ($installUserHome -ne '') {
    if (Test-Path $installUserHome -PathType leaf) {
      wsl -d $installName --mount --vhd $installUserHome --bare > $null 2>&1
      # Mount-VHD -Path $disk.Path
      # $disk = Get-Disk | Where-Object { $_.Location -eq $disk.Path }
      # Initialize-Disk -Number $disk.Number -PartitionStyle MBR
      # # $disk | Format-List *
      # # Set-Disk -Number $disk.Number -FriendlyName 'WslPortableUserHome'
      # Dismount-VHD -Path $installUserHome
    }
  }
}

if ((Test-Admin) -eq $false) {
  if ($elevated) {
    # tried to elevate, did not work, aborting
    [Environment]::Exit(1)
  }
  else {
    try {
      # Create a virtual drive for the user home not as admin
      Create-User-VHD

      # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4
      # Ensure to have the rights to run script and run it
      $policy = 'Bypass'
      if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $policy) {
        $setPolicy = ('Write-Host "Temporary set execution policy to {0}"; Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy {0} -Force; ' -f $policy)
        $unblock = ('Unblock-File -Path {0}; ' -f $myinvocation.MyCommand.Definition)
        $script = ("{0} -elevated -ubuntuVersion '{1}' -installName '{2}' -installPath '{3}' -installUserHome '{4}' -userHomeSize {5} -natNetwork '{6}' -natGatewayIp '{7}' {8}" -f
          ($myinvocation.MyCommand.Definition, $ubuntuVersion, $installName, $installPath, $installUserHome, $userHomeSize, $natNetwork, $natGatewayIp, ($args -join ' ')))
        $process = Start-Process powershell -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -Command "{0}{1}{2}"' -f ($setPolicy, $unblock, $script))
      }
      else {
        # Simply run the script if the rights are there
        $process = Start-Process powershell -Wait -PassThru -Verb RunAs -ArgumentList
          ('-noprofile -noexit -file "{0}" -elevated -ubuntuVersion "{1}" -installName "{2}" -installPath "{3}" -installUserHome "{4}" -userHomeSize {5} -natNetwork "{6}" -natGatewayIp "{7}" {8}' -f
          ($myinvocation.MyCommand.Definition, $ubuntuVersion, $installName, $installPath, $installUserHome, $userHomeSize, $natNetwork, $natGatewayIp, ($args -join ' ')))
      }
      if ($process.ExitCode) {
        [Environment]::Exit($process.ExitCode)
      }
      [Environment]::Exit(0)
    }
    catch {
      Write-Host $_
    }
  }
  [Environment]::Exit(1)
}
else {
  # Set back script restrictions
  $policy = 'RemoteSigned'
  if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $policy) {
    Write-Output ('Set back execution policy to {0}' -f $policy)
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $policy -Force
  }
}

function pauseError($msg) {
  Write-Host -ForegroundColor Red "$msg";
  Write-Host -NoNewLine -ForegroundColor Yellow "Press any key to continue...";
  $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

function pauseInfo($msg) {
  Write-Host -ForegroundColor Green "$msg";
  Write-Host -NoNewLine -ForegroundColor Yellow "Press any key to continue...";
  $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

function writeInfo($msg) {
  Write-Host -ForegroundColor Yellow "$msg";
}

function Setup-WSL {
  # List all Windows optional features
  # Get-WindowsOptionalFeature -Online

  # Ensure to activate needed features
  Write-Output 'Ensure to have some features activated...'
  $features = @('VirtualMachinePlatform', 'Microsoft-Hyper-V', 'Microsoft-Windows-Subsystem-Linux')
  $featureInstalled = $false
  foreach ($feature in $features) {
    if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).State -ne 'Enabled') {
      Write-Output ('Activating optional feature {0}' -f ($feature))
      Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart -LogLevel 2 | out-null
      $featureInstalled = $true
    }
  }
  Write-Output ''

  try {
    wsl.exe --help | out-null
  }
  catch {
    if ($featureInstalled) {
      pauseError('Some features have been installed, please restart the computer to continue the installation.')
      [Environment]::Exit(1)
    }
    pauseError('ERROR: WSL is not available, you migth need to restart the computer.')
    [Environment]::Exit(1)
  }

  if (!((wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern '^Ubuntu') -and (wsl.exe --list --verbose | Select-String -Quiet -Encoding unicode -Pattern '2$'))) {
    Write-Output 'Updating WSL kernel...'
    Invoke-WebRequest -URI 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile wsl_update_x64.msi
    if ((Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList ('/i', 'wsl_update_x64.msi', '/passive')).ExitCode -ne 0) {
      Write-Output 'ERROR: Unable to update WSL kernel, it will not be possible to take advantage of WSL 2 improvements'
    }
    wsl.exe --set-default-version 2
    Write-Output ''
  }

  # Check Windows version
  $systemVersion = [System.Version](Get-CimInstance Win32_OperatingSystem).version
  if ($systemVersion -lt [System.Version]'10.0.19043') {
    Write-Output ("You Windows version ({0}) is too old to update wsl to its latest version, you might have issue" -f $systemVersion)
  }
  else {
    wsl --update
    wsl --version
    Write-Output ''
  }
}

function Setup-NatNetwork {
  if ($natNetwork -eq '' -Or $natGatewayIp -eq '') {
    return # Nothing to do
  }
  Write-Output("Verifying NAT network is {0} and NAT gateway ip address is {1}..." -f ($natNetwork, $natGatewayIp))
  $currentNatNetwork = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork
  $currentNatGateway = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress
  Write-Output("Current NAT network is {0} and NAT gateway ip address is {1}..." -f ($currentNatNetwork, $currentNatGateway))
  if ($currentNatNetwork -eq $natNetwork -And $currentNatGateway -eq $natGatewayIp) {
    Write-Output("The configuration is already well set.")
  } else {
    Write-Output("Updating the configuration...")
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork -Value $natNetwork
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress -Value  $natGatewayIp
    $currentNatNetwork = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatNetwork
    $currentNatGateway = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name NatGatewayIpAddress
    Write-Output("Current NAT network is {0} and NAT gateway ip address is {1}..." -f ($currentNatNetwork, $currentNatGateway))
    Write-Output("")
    Write-Output("/!\ You need to restart the computer for the change to be taken into account /!\")
    Start-Sleep -Seconds 1
  }
  Write-Output ''
}

function Install-Standard-WSL {
  wsl --install --no-launch $ubuntuVersion
  $ubuntuExePath = ("{0}\Microsoft\WindowsApps\{1}" -f $env:LOCALAPPDATA, ('{0}.exe' -f ($ubuntuVersion.ToLower() -replace '[-.]', '')))
  if (!(Test-Path $ubuntuExePath -PathType leaf)) {
    Write-Output ('ERROR: Unable to install {0}' -f $ubuntuVersion)
    pauseError('File {0} does not exist' -f $ubuntuExePath)
    [Environment]::Exit(1)
  }
  $cmd = ("{0} install --root" -f $ubuntuExePath)
  Invoke-Expression "$cmd"
}

function Install-Custom-WSL {
  if ($ubuntuVersion -eq 'Ubuntu-24.04') {
    $url = 'https://cloud-images.ubuntu.com/daily/server/noble/current/noble-server-cloudimg-amd64-root.tar.xz'
  }
  else {
    if ($ubuntuVersion -eq 'Ubuntu-22.04') {
      $url = 'https://cloud-images.ubuntu.com/daily/server/jammy/current/jammy-server-cloudimg-amd64-root.tar.xz'
    }
    else {
      if ($ubuntuVersion -eq 'Ubuntu-20.04') {
        $url = 'https://cloud-images.ubuntu.com/daily/server/focal/current/focal-server-cloudimg-amd64-root.tar.xz'
      }
      else {
        if ($ubuntuVersion -eq 'Ubuntu-18.04') {
          $url = 'https://cloud-images.ubuntu.com/daily/server/bionic/current/bionic-server-cloudimg-amd64-root.tar.xz'
        }
        else {
          if ($ubuntuVersion -eq 'Ubuntu-16.04') {
            $url = 'https://cloud-images.ubuntu.com/daily/server/xenial/current/xenial-server-cloudimg-amd64-root.tar.xz'
          }
          else {
            pauseError('ERROR: Unsupported Ubuntu version "{0}"' -f $ubuntuVersion)
            [Environment]::Exit(1)
          }
        }
      }
    }
  }
  $tarFile = (Join-Path -Path $installPath -ChildPath 'server-cloudimg-amd64-root.tar.xz')
  if (!(Test-Path $tarFile -PathType leaf)) {
    Invoke-WebRequest -URI $url -OutFile $tarFile
    # curl.exe -k -o $tarFile $url
  }
  wsl --import $installName $installPath $tarFile --version 2
  # Remove-Item $tarFile
}

function Install-WSL {
  if ($ubuntuVersion -eq $installName) {
    Write-Host ('Installating {0}' -f $ubuntuVersion)
  }
  else {
    Write-Host ('Installating {0} as {1}' -f $ubuntuVersion, $installName)
  }
  if ($installPath -ne '') {
    Write-Host ('Installing under {0}' -f $installPath)
  }

  # If the version is not installed, lets installed it
  if (!(wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern ('^{0}$' -f $installName))) {
    Write-Output ('Installing {0}...' -f $installName)
    # For system installation
    if ($installPath -eq '') {
      Install-Standard-WSL
    }
    else {
      # For custom installation
      Install-Custom-WSL
    }
  }

  if (!(wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern ('^{0}$' -f $installName))) {
    Write-Output ('ERROR: Unable to install {0}' -f $installName)
    [Environment]::Exit(1)
  }
  else {
    Write-Output ('Set {0} as default WSL distribution' -f $installName)
    wsl.exe --set-default $installName
  }
}

function Check-WSL-Setup {
  if (wsl.exe -d $installName -u root sh -c 'uname -a' | Select-String -Pattern 'linux.*microsoft.*wsl2' -Quiet) {
    Write-Output ('{0} properly setup with WSL version 2' -f $installName)
  }
  elseif (wsl.exe -d $installName -u root sh -c 'uname -a' | Select-String -Pattern 'linux.*microsoft' -Quiet) {
    Write-Output ('{0} is setup with WSL version 1 only' -f $installName)
  }
  else {
    pauseError(('ERROR: {0} is not properly setup' -f $installName))
    [Environment]::Exit(1)
  }
}

# Set encoding for the current session as unicode
[System.Console]::OutputEncoding = [System.Text.Encoding]::Unicode

Setup-WSL
Setup-NatNetwork
Install-WSL
Mount-User-VHD

# Set encoding for the current session as ASCII to communicate with wsl
[System.Console]::OutputEncoding = [System.Text.Encoding]::ASCII

Check-WSL-Setup

[Environment]::Exit(0)
