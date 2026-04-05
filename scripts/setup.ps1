param(
    [string]$BungeeRepo = "https://github.com/DeltaBuild/BungeeCord",
    [string]$TargetDir = "../BungeeCord"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TargetDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot $TargetDir))
$PatchesDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\patches"))

# Vérifie si Git est installé
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git n'est pas installé. Veuillez installer Git pour continuer."
    exit 1
}

# Clone le dépôt BungeeCord
Write-Host "Clonage du dépôt BungeeCord depuis $BungeeRepo vers le répertoire $TargetDir ..." -ForegroundColor Cyan

if (Test-Path $TargetDir) {
    Write-Host "Le répertoire $TargetDir existe déjà, ignore le clonage." -ForegroundColor Yellow
}
else {
    git clone $BungeeRepo $TargetDir
}

# Initialisation du dépôt Git interne
Write-Host "Initialisation du dépôt Git interne dans $TargetDir ..." -ForegroundColor Cyan

Push-Location $TargetDir
    git init
    git add -A

    $hasUser = git config user.name 2>$null
    if (-not $hasUser) {
        git config user.name "DeltaBuild"
        git config user.email "deltabuild@skhr.fr"
    }

    git commit -m "Upstream BungeeCord" --allow-empty
Pop-Location

# Crée le répertoire de correctifs s'il n'existe pas
if (-not (Test-Path $PatchesDir)) {
    New-Item -ItemType Directory -Path $PatchesDir | Out-Null
}


Write-Host "Setup terminé avec succès. Lance .\scripts\apply-patches.ps1 pour appliquer les correctifs." -ForegroundColor Green