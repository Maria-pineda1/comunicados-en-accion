@echo off
setlocal

cd /d "%~dp0"

echo ============================================
echo   Actualizando Revista Digital en GitHub
echo ============================================
echo.

echo Optimizando imagenes (PNG a JPG liviano)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0optimizar-imagenes.ps1"

echo Sincronizando "Revista Digital.html" con "index.html"...
copy /Y "Revista Digital.html" "index.html" >nul

echo Generando lista de paginas (pages.js)...
powershell -NoProfile -Command "$n = Get-ChildItem -Filter '*.jpg' | Where-Object { $_.BaseName -match '^\d+$' } | ForEach-Object { [int]$_.BaseName } | Sort-Object; 'window.PAGES = [' + ($n -join ',') + '];' | Set-Content -Encoding ASCII pages.js"

findstr /C:"[]" pages.js >nul
if %errorlevel%==0 (
    echo.
    echo ERROR: no se encontraron imagenes numeradas ^(1.jpg, 2.jpg...^) en esta carpeta.
    echo No se subio nada para no dejar la revista vacia.
    echo.
    pause
    exit /b 1
)

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
