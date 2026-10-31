# Build the Flutter web bundle and publish it to the existing Vercel project.
#
# Usage:
#   pwsh scripts/deploy_vercel.ps1
#
# Requires the Vercel CLI to be authenticated (`npx vercel login`) and the
# project to already exist inside the owning team. This script never prints or
# stores account IDs, team IDs or tokens.
param(
  [string]$Scope = "suthara",
  [string]$Project = "pramaan",
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$flutterBin = "D:\Program Files\Flutter\sdk\flutter\bin"
$dartBin = "$flutterBin\cache\dart-sdk\bin"

if (-not $SkipBuild) {
  if (-not (Test-Path "$flutterBin\flutter.bat")) {
    Write-Host "Flutter not found at $flutterBin" -ForegroundColor Red
    exit 1
  }
  $env:Path = "$flutterBin;$dartBin;" + $env:Path

  Push-Location "$root\app"
  Write-Host "flutter pub get" -ForegroundColor Cyan
  flutter pub get
  Write-Host "flutter test" -ForegroundColor Cyan
  flutter test
  Write-Host "flutter build web --release" -ForegroundColor Cyan
  flutter build web --release

  # Override Flutter's cache-poisoning service worker with our clearing one
  # (Fixes "blank white on reload" - stale main.dart.js served from cache).
  $customSw = "$root\app\web\flutter_service_worker.js"
  if (Test-Path $customSw) {
    Write-Host "overriding flutter_service_worker.js" -ForegroundColor Cyan
    Copy-Item $customSw "$root\app\build\web\flutter_service_worker.js" -Force
  }

  Pop-Location
}

$web = "$root\app\build\web"
if (-not (Test-Path "$web\index.html")) {
  Write-Host "No web build found at $web" -ForegroundColor Red
  exit 1
}

Push-Location $web
try {
  Write-Host "vercel link" -ForegroundColor Cyan
  npx --yes vercel@latest link --yes --project $Project --scope $Scope

  Write-Host "vercel deploy --prod" -ForegroundColor Cyan
  npx --yes vercel@latest deploy --prod --yes --scope $Scope
}
finally {
  Pop-Location
}

Write-Host ""
Write-Host "Deployed. Production URL: https://$Project-$Scope.vercel.app" -ForegroundColor Green
