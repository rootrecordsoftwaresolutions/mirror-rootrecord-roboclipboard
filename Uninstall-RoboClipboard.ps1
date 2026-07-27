# Remove Robo Copy / Robo Paste Explorer context menus (current user)
$ErrorActionPreference = 'Stop'
$keys = @(
  'HKCU:\Software\Classes\Directory\shell\RoboCopy',
  'HKCU:\Software\Classes\Directory\shell\RoboPaste',
  'HKCU:\Software\Classes\Directory\Background\shell\RoboPaste'
)
foreach ($k in $keys) {
  if (Test-Path -LiteralPath $k) {
    Remove-Item -LiteralPath $k -Recurse -Force
    Write-Host "Removed $k"
  }
}
Write-Host "Uninstalled context menus. Scripts under %LOCALAPPDATA%\RoboClipboard were left in place."
