# Robo Copy — store source path for later Robo Paste
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path
)

$ErrorActionPreference = 'Stop'
$storeDir = Join-Path $env:LOCALAPPDATA 'RoboClipboard'
$storeFile = Join-Path $storeDir 'source.txt'
New-Item -ItemType Directory -Force -Path $storeDir | Out-Null

$item = Get-Item -LiteralPath $Path -ErrorAction Stop
$full = $item.FullName
Set-Content -LiteralPath $storeFile -Value $full -Encoding UTF8

Add-Type -AssemblyName System.Windows.Forms | Out-Null
[System.Windows.Forms.MessageBox]::Show(
  "Robo Copy ready:`n`n$full`n`nRight-click a destination folder (or empty space inside it) and choose Robo Paste.",
  'Robo Copy',
  [System.Windows.Forms.MessageBoxButtons]::OK,
  [System.Windows.Forms.MessageBoxIcon]::Information
) | Out-Null
