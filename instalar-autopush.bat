@echo off
chcp 65001 >nul
setlocal

REM ===== CONFIGURACION =====
REM Cada cuantos minutos se suben los cambios a GitHub:
set INTERVALO=2
set TAREA=ArchvizAutoPush
REM =========================

set "CARPETA=%~dp0"
set "SCRIPT=%CARPETA%auto-push.ps1"

echo.
echo  Instalando autopush para el repo:
echo    %CARPETA%
echo  Subira los cambios cada %INTERVALO% minutos.
echo.

schtasks /Create ^
 /SC MINUTE /MO %INTERVALO% ^
 /TN "%TAREA%" ^
 /TR "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT%\"" ^
 /F /RL LIMITED

if %ERRORLEVEL%==0 (
  echo.
  echo  [OK] Tarea "%TAREA%" creada.
  echo  Ejecutando una vez ahora para verificar credenciales de GitHub...
  echo.
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
  echo.
  echo  Listo. Revisa auto-push.log si algo falla.
) else (
  echo.
  echo  [ERROR] No se pudo crear la tarea. Ejecuta este .bat como Administrador.
)

echo.
pause
