Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SourceDir  = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\BungeeCord"))
$PatchesDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\patches"))

# Vérifie que la source à été initialisée
if (-not (Test-Path (Join-Path $SourceDir ".git"))) {
    Write-Error "BungeeCord non initialisé. Lance .\scripts\setup.ps1 avant d'appliquer les correctifs."
    exit 1
}

Push-Location $SourceDir
    $CurrentBranch = git rev-parse --abbrev-ref HEAD
    if ($CurrentBranch -ne "deltaproxy") {
        Write-Host "La branche n'est pas sur 'deltaproxy'. Veuillez appliquer les patches via .\scripts\apply-patches.ps1 avant de générer de nouveaux patches." -ForegroundColor Red
        Pop-Location
        exit 1
    }

    Write-Host "Nettoyage des anciens correctifs ..." -ForegroundColor Cyan
    Remove-Item "$PatchesDir\*.patch" -ErrorAction SilentlyContinue

    Write-Host "Génération des nouveaux correctifs ..." -ForegroundColor Cyan
    git format-patch main --output-directory $PatchesDir --no-stat

    if($LASTEXITCODE -ne 0) {
        Write-Host "Échec de la génération des correctifs." -ForegroundColor Red
        Pop-Location
        exit 1
    }

    $GeneratedPatches = Get-ChildItem -Path $PatchesDir -Filter "*.patch" | Sort-Object Name
    $PatchCount = ($GeneratedPatches | Measure-Object).Count
    Write-Host "Génération de $PatchCount correctifs terminée. Les correctifs sont disponibles dans le répertoire $PatchesDir." -ForegroundColor Green
    $GeneratedPatches | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor Gray }

Pop-Location