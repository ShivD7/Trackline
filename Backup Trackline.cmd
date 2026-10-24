@echo off
cd /d "%~dp0"
ruby script/data.rb backup
pause
