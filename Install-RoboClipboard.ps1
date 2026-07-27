# Install Explorer context menu: Robo Copy / Robo Paste (current user only)
# Run from this folder after clone, or from %LOCALAPPDATA%\RoboClipboard after copy.
$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot
$toolDir = Join-Path $env:LOCALAPPDATA 'RoboClipboard'
New-Item -ItemType Directory -Force -Path $toolDir | Out-Null

$needed = @('Robo-Copy.ps1', 'Robo-Paste.ps1')
foreach ($name in $needed) {
  $src = Join-Path $here $name
  if (-not (Test-Path -LiteralPath $src)) {
    throw "Missing script next to installer: $src"
  }
  Copy-Item -LiteralPath $src -Destination (Join-Path $toolDir $name) -Force
}

# Keep a copy of the installer in the tool dir too
Copy-Item -LiteralPath (Join-Path $here 'Install-RoboClipboard.ps1') -Destination (Join-Path $toolDir 'Install-RoboClipboard.ps1') -Force

$copyPs1 = Join-Path $toolDir 'Robo-Copy.ps1'
$pastePs1 = Join-Path $toolDir 'Robo-Paste.ps1'
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

function Set-ShellCommand {
  param(
    [string]$KeyPath,
    [string]$Label,
    [string]$Command,
    [string]$Icon = 'imageres.dll,-5302'
  )
  New-Item -Path $KeyPath -Force | Out-Null
  Set-ItemProperty -Path $KeyPath -Name '(default)' -Value $Label
  Set-ItemProperty -Path $KeyPath -Name 'Icon' -Value $Icon
  $cmdKey = Join-Path $KeyPath 'command'
  New-Item -Path $cmdKey -Force | Out-Null
  Set-ItemProperty -Path $cmdKey -Name '(default)' -Value $Command
}

Set-ShellCommand `
  -KeyPath 'HKCU:\Software\Classes\Directory\shell\RoboCopy' `
  -Label 'Robo Copy' `
  -Icon 'imageres.dll,-5302' `
  -Command "`"$ps`" -NoProfile -ExecutionPolicy Bypass -File `"$copyPs1`" `"%1`""

Set-ShellCommand `
  -KeyPath 'HKCU:\Software\Classes\Directory\shell\RoboPaste' `
  -Label 'Robo Paste' `
  -Icon 'imageres.dll,-5301' `
  -Command "`"$ps`" -NoProfile -ExecutionPolicy Bypass -File `"$pastePs1`" `"%1`""

Set-ShellCommand `
  -KeyPath 'HKCU:\Software\Classes\Directory\Background\shell\RoboPaste' `
  -Label 'Robo Paste' `
  -Icon 'imageres.dll,-5301' `
  -Command "`"$ps`" -NoProfile -ExecutionPolicy Bypass -File `"$pastePs1`" `"%V`""

Write-Host "Installed Robo Copy / Robo Paste for the current user."
Write-Host "Scripts: $toolDir"
Write-Host "Right-click a folder -> Robo Copy, then right-click destination -> Robo Paste."
Write-Host "If menus don't appear yet, open a new File Explorer window (or restart Explorer)."
