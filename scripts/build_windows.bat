@echo off
setlocal
echo ============================================
echo   Compilazione Stellina Desktop Pet (Windows)
echo ============================================

cd /d "%~dp0\.."

python -m pip install --quiet pyinstaller

echo [*] Generazione eseguibile Stellina.exe...
python -m PyInstaller ^
    --name Stellina ^
    --onefile ^
    --windowed ^
    --noconsole ^
    --add-data "%CD%\Assets Stellina;Assets Stellina" ^
    --distpath "%CD%\build\Stellina-Windows" ^
    --workpath "%CD%\build\temp" ^
    --specpath "%CD%\build" ^
    "Sources\Windows\main.py"

if %ERRORLEVEL% EQU 0 (
    echo ============================================
    echo [OK] Build completata con successo!
    echo Eseguibile disponibile in: build\Stellina-Windows\Stellina.exe
    echo ============================================
) else (
    echo [ERRORE] Compilazione fallita!
    exit /b %ERRORLEVEL%
)
