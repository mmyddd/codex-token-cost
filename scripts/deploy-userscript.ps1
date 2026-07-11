param()

$ErrorActionPreference = "Stop"

if (-not $env:APPDATA) {
  throw "APPDATA is not set"
}

$source = Join-Path $PSScriptRoot "codex-live-token-cost.js"
$targetDir = Join-Path $env:APPDATA "Codex++\user_scripts"
$target = Join-Path $targetDir "market-codex-live-token-cost.js"

if (-not (Test-Path -LiteralPath $source)) {
  throw "Source script not found: $source"
}

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item -LiteralPath $source -Destination $target -Force

$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash.ToLowerInvariant()
$targetHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash.ToLowerInvariant()
$matched = $sourceHash -eq $targetHash

Write-Output "source=$source"
Write-Output "target=$target"
Write-Output "source_sha256=$sourceHash"
Write-Output "target_sha256=$targetHash"
Write-Output "match=$($matched.ToString().ToLowerInvariant())"

if (-not $matched) {
  exit 1
}
