@echo off
cd /d "%~dp0"
where ruby >nul 2>nul
if errorlevel 1 (
  echo Ruby is missing from PATH. Install RubyInstaller with Devkit, then reopen this file.
  pause
  exit /b 1
)
if exist "config\local.cmd" call "config\local.cmd"
ruby script/start.rb
if errorlevel 1 pause
