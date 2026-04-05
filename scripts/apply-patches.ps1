Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SourceDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\BungeeCord"))
$PatchesDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\patches"))

# Vérifie que la source à été initialisée
if (-not (Test-Path (Join-Path $SourceDir ".git"))) {
    Write-Error "BungeeCord non initialisé. Lance .\scripts\setup.ps1 avant d'appliquer les correctifs."
    exit 1
}

# Applique les correctifs
Push-Location $SourceDir
    Write-Host "Reset vers l'état initial du dépôt ..." -ForegroundColor Cyan
    git checkout main
    git branch -D deltaproxy 2>$null
    git checkout -b deltaproxy

    $Patches = Get-ChildItem -Path $PatchesDir -Filter "*.patch" | Sort-Object Name

    $PatchCount = ($Patches | Measure-Object).Count
    if ($PatchCount -eq 0) {
        Write-Host "Aucun correctif trouvé dans $PatchesDir" -ForegroundColor Yellow
        Pop-Location
        exit 0
    }

    Write-Host "Application de $PatchCount correctifs ..." -ForegroundColor Cyan

    foreach ($Patch in $Patches) {
        Write-Host "Application du correctif $($Patch.Name) ..." -ForegroundColor Cyan

        $UnixPath = $Patch.FullName -replace "\\", "/"

        git am --3way $UnixPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Échec de l'application du correctif $($Patch.Name). Résolution manuelle requise." -ForegroundColor Red
            Write-Host " Commandes utiles :" -ForegroundColor Yellow
            Write-Host "  git am --show-current-patch   # voir le patch en cours" -ForegroundColor Gray
            Write-Host "  git add .                     # après résolution" -ForegroundColor Gray
            Write-Host "  git am --continue             # continuer" -ForegroundColor Gray
            Write-Host "  git am --abort                # annuler l'application du patch en cours" -ForegroundColor Gray
            Pop-Location
            exit 1
        }
    }

    Write-Host "Tous les correctifs ont été appliqués avec succès sur la branche 'deltaproxy'." -ForegroundColor Green
Pop-Location