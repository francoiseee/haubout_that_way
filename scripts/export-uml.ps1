param(
  [ValidateSet('png','svg')]
  [string]$Format = 'png',
  [double]$Scale = 2.0,
  [int]$Width,
  [string]$Config
)

# Ensure Mermaid CLI is installed
$mm = Get-Command mmdc -ErrorAction SilentlyContinue
if (-not $mm) {
  Write-Error "'mmdc' (Mermaid CLI) not found. Install with: npm install -g @mermaid-js/mermaid-cli"
  exit 1
}

# Resolve repo root (script is in scripts/)
$repoRoot = Split-Path $PSScriptRoot -Parent
$umlDir = Join-Path $repoRoot 'docs\uml'

if (-not $Config) {
  $defaultCfg = Join-Path $umlDir 'mermaid-config.json'
  if (Test-Path $defaultCfg) { $Config = $defaultCfg }
}

if (-not (Test-Path $umlDir)) {
  Write-Error "UML directory not found: $umlDir"
  exit 1
}

$files = Get-ChildItem -Path $umlDir -Filter *.mmd -File
if (-not $files) {
  Write-Warning "No .mmd files found in $umlDir"
  exit 0
}

foreach ($f in $files) {
  $ext = if ($Format -eq 'svg') { '.svg' } else { '.png' }
  $out = [System.IO.Path]::ChangeExtension($f.FullName, $ext)
  Write-Host "Exporting $($f.Name) -> $(Split-Path $out -Leaf) ($Format)" -ForegroundColor Cyan

  # Build argument list dynamically to include optional params
  $args = @('-i', $f.FullName, '-o', $out)
  if ($Format -eq 'svg') {
    $args += @('-F', 'svg')
  } else {
    # PNG tweaks for crispness
    if ($Scale -gt 0) { $args += @('-s', $Scale) }
    if ($Width) { $args += @('-w', $Width) }
    $args += @('-b', 'white')
  }
  if ($Config) { $args += @('-C', $Config) }

  & mmdc @args

  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to export $($f.Name)"
    exit $LASTEXITCODE
  }
}

Write-Host "All diagrams exported to: $umlDir" -ForegroundColor Green
