@echo off
setlocal

cd /d "%~dp0"

echo ============================================
echo   Actualizando Revista Digital en GitHub
echo ============================================
echo.

echo Sincronizando "Revista Digital.html" con "index.html"...
copy /Y "Revista Digital.html" "index.html" >nul

echo Generando lista de paginas (pages.js)...
powershell -NoProfile -Command "$n = Get-ChildItem -Filter '*.png' | Where-Object { $_.BaseName -match '^\d+$' } | ForEach-Object { [int]$_.BaseName } | Sort-Object; 'window.PAGES = [' + ($n -join ',') + '];' | Set-Content -Encoding ASCII pages.js"

echo Revisando cambios...
git add -A

git diff --cached --quiet
if %errorlevel%==0 (
    echo.
    echo No hay paginas nuevas ni cambios que subir.
    echo.
    pause
    exit /b 0
)

echo.
echo Creando commit...
git commit -m "Actualizacion semanal - %date% %time%"

echo.
echo Subiendo cambios a GitHub...
git push

echo.
echo ============================================
echo   Listo. El link se actualizara en 1-2 minutos.
echo ============================================
echo.
pause
