@echo off
chcp 65001 >nul
set TAREA=ArchvizAutoPush
echo Eliminando la tarea programada "%TAREA%"...
schtasks /Delete /TN "%TAREA%" /F
echo.
pause
