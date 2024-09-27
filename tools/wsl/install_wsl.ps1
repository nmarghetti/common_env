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
      # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4
      # Ensure to have the rights to run script and run it
      $policy='Bypass'
      if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $policy) {
        $setPolicy = ('Write-Host "Temporary set execution policy to {0}"; Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy {0} -Force; ' -f $policy)
        $unblock = ('Unblock-File -Path {0}; ' -f $myinvocation.MyCommand.Definition)
        $script = ('{0} {1}' -f ($myinvocation.MyCommand.Definition, ($args -join ' ')))
        Start-Process powershell.exe -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -Command "{0}{1}{2}"' -f ($setPolicy, $unblock, $script))
      } else {
        # Simply run the script if the rights are there
        $process = Start-Process powershell.exe -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated {1}' -f ($myinvocation.MyCommand.Definition, ($args -join ' ')))
      }
      [Environment]::Exit($process.ExitCode)
    }
    catch {
      Write-Host $_
    }
  }
  [Environment]::Exit(1)
} else {
  # Set back script restrictions
  $policy='RemoteSigned'
  if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $policy) {
    Write-Output ('Set back execution policy to {0}' -f $policy)
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $policy -Force
  }
}

$ubuntuVersion='Ubuntu-22.04'
if ($args[0]) {
  $ubuntuVersion=$args[0]
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
Write-Output ''

try {
  wsl.exe --help | out-null
} catch {
  if ($featureInstalled) {
    pauseError('Some features have been installed, please restart the computer to continue the installation.')
    [Environment]::Exit(1)
  }
  pauseError('ERROR: WSL is not available, you migth need to restart the computer.')
  [Environment]::Exit(1)
}

if (!((wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern '^Ubuntu') -and (wsl.exe --list --verbose | Select-String -Quiet -Encoding unicode -Pattern '2$'))) {
  Write-Output 'Updating WSL kernel...'
  curl.exe -o wsl_update_x64.msi 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'
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
} else {
  wsl --update
  wsl --version
  Write-Output ''
}


# If no version of Ubuntu is installed, lets installed it
if (!(wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern ('^{0}$' -f $ubuntuVersion))) {
  Write-Output ('Installing {0}...' -f $ubuntuVersion)
  wsl --install --no-launch $ubuntuVersion
  $ubuntuExePath = ("{0}\Microsoft\WindowsApps\{1}" -f $env:LOCALAPPDATA,('{0}.exe' -f ($ubuntuVersion.ToLower() -replace '[-.]', '')))
  if (!(Test-Path $ubuntuExePath -PathType leaf)) {
    Write-Output ('ERROR: Unable to install {0}' -f $ubuntuVersion)
    pauseError('File {0} does not exist' -f $ubuntuExePath)
    [Environment]::Exit(1)
  }
  $cmd = ("{0} install --root" -f $ubuntuExePath)
  Invoke-Expression "$cmd"

  if (!(wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern ('^{0}$' -f $ubuntuVersion))) {
    Write-Output ('ERROR: Unable to install {0}' -f $ubuntuVersion)
    [Environment]::Exit(1)
  } else {
    Write-Output ('Set {0} as default WSL distribution' -f $ubuntuVersion)
    wsl.exe --set-default $ubuntuVersion
  }
} else {
  # Check the right version installed
  if (!(wsl.exe --list --quiet | Select-String -Quiet -Encoding unicode -Pattern ('^{0}$' -f $ubuntuVersion))) {
    $ubuntuVersion='Ubuntu'
  }
}


# Set encoding for the current session as ASCII to communicate with wsl
[System.Console]::OutputEncoding = [System.Text.Encoding]::ASCII
if (wsl.exe -d $ubuntuVersion -u root sh -c 'uname -a' | Select-String -Pattern 'linux.*microsoft.*wsl2' -Quiet) {
  Write-Output ('{0} properly setup with WSL version 2' -f $ubuntuVersion)
} elseif (wsl.exe -d $ubuntuVersion -u root sh -c 'uname -a' | Select-String -Pattern 'linux.*microsoft' -Quiet) {
  Write-Output ('{0} is setup with WSL version 1 only' -f $ubuntuVersion)
} else {
  pauseError(('ERROR: {0} is not properly setup' -f $ubuntuVersion))
  [Environment]::Exit(1)
}

[Environment]::Exit(0)
