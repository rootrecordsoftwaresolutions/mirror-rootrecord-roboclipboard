# Robo Paste — robocopy stored source into destination folder
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Dest
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms | Out-Null

$storeFile = Join-Path $env:LOCALAPPDATA 'RoboClipboard\source.txt'
if (-not (Test-Path -LiteralPath $storeFile)) {
  [System.Windows.Forms.MessageBox]::Show(
    "Nothing stored yet.`n`nRight-click a folder and choose Robo Copy first.",
    'Robo Paste',
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Warning
  ) | Out-Null
  exit 1
}

$source = (Get-Content -LiteralPath $storeFile -Raw -Encoding UTF8).Trim()
if (-not $source -or -not (Test-Path -LiteralPath $source)) {
  [System.Windows.Forms.MessageBox]::Show(
    "Stored source is missing or invalid:`n`n$source",
    'Robo Paste',
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Error
  ) | Out-Null
  exit 1
}

$destRoot = (Get-Item -LiteralPath $Dest -ErrorAction Stop).FullName
$leaf = Split-Path -Leaf $source
$target = Join-Path $destRoot $leaf

if ((Resolve-Path -LiteralPath $source).Path -eq (Resolve-Path -LiteralPath $destRoot -ErrorAction SilentlyContinue).Path) {
  [System.Windows.Forms.MessageBox]::Show(
    "Source and destination are the same folder. Pick a different destination.",
    'Robo Paste',
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Warning
  ) | Out-Null
  exit 1
}

$confirm = [System.Windows.Forms.MessageBox]::Show(
  "Robocopy:`n`nFrom:`n$source`n`nTo:`n$target`n`nContinue?",
  'Robo Paste',
  [System.Windows.Forms.MessageBoxButtons]::YesNo,
  [System.Windows.Forms.MessageBoxIcon]::Question
)
if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { exit 0 }

New-Item -ItemType Directory -Force -Path $target | Out-Null

$log = Join-Path $env:TEMP ("robocopy-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))
$sw = [Diagnostics.Stopwatch]::StartNew()
& robocopy $source $target /E /COPY:DAT /R:1 /W:1 /MT:8 /TEE /LOG:$log | Out-Null
$code = $LASTEXITCODE
$sw.Stop()

$ok = ($code -ge 0 -and $code -le 7)
$icon = if ($ok) {
  [System.Windows.Forms.MessageBoxIcon]::Information
} else {
  [System.Windows.Forms.MessageBoxIcon]::Error
}
$title = if ($ok) { 'Robo Paste — done' } else { 'Robo Paste — failed' }
[System.Windows.Forms.MessageBox]::Show(
  "$title`n`nFrom: $source`nTo: $target`n`nRobocopy exit: $code (0-7 = OK)`nElapsed: $($sw.Elapsed)`n`nLog:`n$log",
  'Robo Paste',
  [System.Windows.Forms.MessageBoxButtons]::OK,
  $icon
) | Out-Null

if (-not $ok) { exit $code }
exit 0
