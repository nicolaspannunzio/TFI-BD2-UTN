@echo off
chcp 65001 > nul
title Script de Resguardo TFI - MongoDB Atlas

:: =====================================================================
:: TFI BASE DE DATOS II (PARTE 2) - UTN
:: Bloque 2: Mecanismo de Backups y Resguardo
:: Integrantes: Nicolas Pannunzio & Nicolas Olima
:: =====================================================================

echo ===================================================================
echo UTN - TFI Base de Datos II - PROCESO DE RESPALDO (BACKUP FULL)
echo ===================================================================

:: 1. Leer MONGO_URI del .env usando PowerShell (maneja caracteres especiales)
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "Get-Content .env | Where-Object { $_ -match '^MONGO_URI=' } | ForEach-Object { $_.Split('=',2)[1] }"`) do set MONGO_URI_BASE=%%A

:: 2. Extraer el usuario desde la URI con PowerShell
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$uri = '%MONGO_URI_BASE%'; ([regex]'mongodb\+srv://([^:]+):').Match($uri).Groups[1].Value"`) do set DB_USER=%%A

:: 3. Extraer la fecha limpia
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'dd-MM-yyyy'"`) do set FECHA_FORMATEADA=%%i

:: 4. Definir rutas relativas
set CARPETA_RAIZ=resguardos_tpi
set CARPETA_DESTINO=%CARPETA_RAIZ%\%FECHA_FORMATEADA%

echo Fecha de ejecucion: %FECHA_FORMATEADA%
echo Ruta relativa de resguardo: %CARPETA_DESTINO%
echo -------------------------------------------------------------------

:: 5. Solicitar la contraseña de forma interactiva (mecanismo seguro de CLI)
echo [SEGURIDAD] Para iniciar el resguardo, introduzca las credenciales.
echo [INFO] Usuario detectado desde .env: %DB_USER%
set /p DB_PASSWORD="Por favor, ingrese la contrasena de Atlas y presione Enter: "
echo.

:: 6. Construir URI final reemplazando el placeholder de contraseña con PowerShell
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$uri = '%MONGO_URI_BASE%'; $uri -replace '(mongodb\+srv://[^:]+:)[^@]+(@)', \"`$1%DB_PASSWORD%`$2\""`) do set ATLAS_URI=%%A

if not exist %CARPETA_DESTINO% (
    mkdir %CARPETA_DESTINO%
)

echo [PROCESO] Conectando de forma remota a MongoDB Atlas...
echo [PROCESO] Descargando base de datos completa (Backup Full)...
echo.

:: 7. Ejecucion del comando nativo de la catedra
mongodump --uri="%ATLAS_URI%" --out="%CARPETA_DESTINO%"

echo.
echo -------------------------------------------------------------------
echo [EXITO] Copia de seguridad finalizada correctamente!
echo [INFO] Resguardo disponible en: %CARPETA_DESTINO%
echo ===================================================================
pause