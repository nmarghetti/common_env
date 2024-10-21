# Ensure to have elevated rights
param(
  [switch]$elevated,
  [string]$installName='',
  [string]$installUserHome=''
)
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false) {
  if ($elevated) {
    [Environment]::Exit(1)
  }
  else {
    try {
      $policy = 'Bypass'
      if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $policy) {
        $setPolicy = ('Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy {0} -Force; ' -f $policy)
        $unblock = ('Unblock-File -Path {0}; ' -f $myinvocation.MyCommand.Definition)
        $script = ("{0} -elevated -installName '{1}' -installUserHome '{2}'" -f
          ($myinvocation.MyCommand.Definition, $installName, $installUserHome))
        $process = Start-Process powershell -Wait -PassThru -Verb RunAs -ArgumentList ('-noprofile -noexit -Command "{0}{1}{2}"' -f ($setPolicy, $unblock, $script))
      }
      else {
        $process = Start-Process powershell -Wait -PassThru -Verb RunAs -ArgumentList
          ('-noprofile -noexit -file "{0}" -elevated -installName "{1}" -installUserHome "{2}"' -f
          ($myinvocation.MyCommand.Definition, $installName, $installUserHome))
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
  $policy = 'RemoteSigned'
  if ((Get-ExecutionPolicy -Scope CurrentUser) -ne $policy) {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $policy -Force
  }
}

if (Test-Path $Env:ProgramFiles\WSL -PathType Container) {
  Set-Location -Path $Env:ProgramFiles\WSL
}
if (Test-Path $Env:ProgramW6432\WSL -PathType Container) {
  Set-Location -Path $Env:ProgramW6432\WSL
}
.\wsl.exe -d $installName --mount --vhd $installUserHome --bare
[Environment]::Exit(0)
