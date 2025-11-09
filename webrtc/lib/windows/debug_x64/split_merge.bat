@echo off
:: Usage:
::   split_merge.bat split webrtc.lib
::   split_merge.bat merge webrtc.lib

set MODE=%1
set FILE=%2

if "%MODE%"=="" (
  echo Usage: split_merge.bat [split|merge] filename
  exit /b 1
)

if "%FILE%"=="" (
  echo Missing filename
  exit /b 1
)

:: Call the PowerShell script
powershell -ExecutionPolicy Bypass -File split_merge.ps1 -Mode %MODE% -File %FILE%
