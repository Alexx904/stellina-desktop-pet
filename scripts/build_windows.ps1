Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Compilazione Stellina Desktop Pet (Windows)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

Write-Host "[*] Verifica installazione PyInstaller..." -ForegroundColor Yellow
python -m pip install --quiet pyinstaller

$AssetsDir = Join-Path $RootDir "Assets Stellina"

Write-Host "[*] Generazione eseguibile Stellina.exe..." -ForegroundColor Yellow
python -m PyInstaller `
    --name Stellina `
    --onefile `
    --windowed `
    --noconsole `
    --add-data "${AssetsDir};Assets Stellina" `
    --distpath (Join-Path $RootDir "build\Stellina-Windows") `
    --workpath (Join-Path $RootDir "build\temp") `
    --specpath (Join-Path $RootDir "build") `
    (Join-Path $RootDir "Sources\Windows\main.py")

if ($LASTEXITCODE -eq 0) {
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "[OK] Build completata con successo!" -ForegroundColor Green
    Write-Host "Eseguibile creato in: build\Stellina-Windows\Stellina.exe" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Error "Compilazione fallita con codice $LASTEXITCODE"
}
