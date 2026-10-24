@echo off
cd /d "%~dp0"
if exist "config\local.cmd" call "config\local.cmd"
ruby script/data.rb backup
pause
