@echo off
cd /d "%~dp0"
if not exist "tmp\mail" mkdir "tmp\mail"
explorer "%~dp0tmp\mail"
