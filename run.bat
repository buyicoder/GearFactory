@echo off
REM GearFactory - Generate equipment textures
REM Usage: run.bat [palette_name]  (default: ruby)
set P=%1
if "%P%"=="" set P=ruby
powershell -ExecutionPolicy Bypass -File "forge.ps1" -PaletteName %P%
