# Verify everything that does not need an Android SDK.
# Usage: pwsh scripts/verify.ps1   (or: ./scripts/verify.ps1)
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$flutterBin = "D:\Program Files\Flutter\sdk\flutter\bin"
$dartBin = "$flutterBin\cache\dart-sdk\bin"

if (-not (Test-Path "$flutterBin\flutter.bat")) {
  Write-Host "Flutter not found at $flutterBin — is it installed?" -ForegroundColor Red
  exit 1
}
$env:Path = "$flutterBin;$dartBin;" + $env:Path

function Step($name, $script) {
  Write-Host ""
  Write-Host "── $name ──" -ForegroundColor Cyan
  & $script
  if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED: $name" -ForegroundColor Red
    exit 1
  }
  Write-Host "OK: $name" -ForegroundColor Green
}

Push-Location "$root\packages\scam_engine"
Step "Engine: dart pub get" { dart pub get }
Step "Engine: dart format"   { dart format --output=none --set-exit-if-changed . }
Step "Engine: dart analyze"  { dart analyze --fatal-infos }
Step "Engine: dart test"     { dart test }
Pop-Location

Push-Location "$root\app"
Step "App: flutter pub get" { flutter pub get }
Step "App: dart format"     { dart format --output=none --set-exit-if-changed lib test }
Step "App: flutter analyze" { flutter analyze --fatal-infos }
Step "App: flutter test"    { flutter test }
Step "App: web build"       { flutter build web --release }
Pop-Location

Write-Host ""
Write-Host "All checks passed. Pramaan is green." -ForegroundColor Green
