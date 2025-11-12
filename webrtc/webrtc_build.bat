@echo off
setlocal

set COPY_INCLUDES=0

REM Parse command line arguments
:parse_args
if "%~1"=="" goto end_parse
if /i "%~1"=="--copy-includes" set COPY_INCLUDES=1
if /i "%~1"=="-i" set COPY_INCLUDES=1
shift
goto parse_args
:end_parse

echo Building WebRTC for Windows...
echo.
if %COPY_INCLUDES%==1 (
    echo Copy includes: ENABLED
) else (
    echo Copy includes: DISABLED
    echo Use --copy-includes or -i flag to enable header copying
)
echo.
echo This script will temporarily bypass PowerShell execution policy.
echo Please ensure you trust the PowerShell script before proceeding.
echo.
pause

REM Run PowerShell script with execution policy bypass
if %COPY_INCLUDES%==1 (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0webrtc_build.ps1" -CopyIncludes
) else (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0webrtc_build.ps1"
)

if %errorLevel% neq 0 (
    echo.
    echo Error: Build script failed with error code %errorLevel%
    pause
    exit /b %errorLevel%
)

echo.
echo Build script completed.
pause

endlocal
