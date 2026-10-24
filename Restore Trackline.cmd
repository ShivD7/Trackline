@echo off
cd /d "%~dp0"
if exist "config\local.cmd" call "config\local.cmd"
echo Stop Trackline first. A safety backup will be saved before restoring.
echo.
ruby script/data.rb list
echo.
set /p "TRACKLINE_RESTORE_FILE=Paste the full backup path (without quotes): "
if not defined TRACKLINE_RESTORE_FILE exit /b 1
set /p "TRACKLINE_RESTORE_CONFIRM=Type RESTORE to replace current data with that backup: "
if not "%TRACKLINE_RESTORE_CONFIRM%"=="RESTORE" exit /b 1
ruby script/data.rb restore "%TRACKLINE_RESTORE_FILE%" --confirm
pause
