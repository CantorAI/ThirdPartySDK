@echo off
setlocal enabledelayedexpansion

echo ========================================
echo LibWebRTC Header File Extraction
echo ========================================
echo.

set "SOURCE_DIR=%~dp0src"
set "OUTPUT_DIR=%~dp0includes"

if not exist "%SOURCE_DIR%" (
    echo ERROR: Source directory not found: %SOURCE_DIR%
    echo Please make sure the 'src' folder exists in the same directory as this script.
    pause
    exit /b 1
)

echo Source Directory: %SOURCE_DIR%
echo Output Directory: %OUTPUT_DIR%
echo.

if exist "%OUTPUT_DIR%" (
    echo WARNING: Output directory already exists.
    set /p "CONFIRM=Do you want to overwrite? (Y/N): "
    if /i not "!CONFIRM!"=="Y" (
        echo Operation cancelled.
        pause
        exit /b 0
    )
    echo Cleaning output directory...
    rmdir /s /q "%OUTPUT_DIR%"
)

echo Creating output directory...
mkdir "%OUTPUT_DIR%"

echo.
echo Copying header files...
echo.

set "COUNT=0"

REM Copy .h files
echo Copying .h files...
for /r "%SOURCE_DIR%" %%f in (*.h) do (
    set "FILE=%%f"
    set "REL_PATH=!FILE:%SOURCE_DIR%=!"
    set "DEST_FILE=%OUTPUT_DIR%!REL_PATH!"
    set "DEST_DIR=!DEST_FILE:\%%~nxf=!"
    
    if not exist "!DEST_DIR!" mkdir "!DEST_DIR!"
    copy "%%f" "!DEST_FILE!" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a COUNT+=1
        if !COUNT! lss 10 echo   Copied: !REL_PATH!
    )
)

REM Copy .hpp files
echo Copying .hpp files...
for /r "%SOURCE_DIR%" %%f in (*.hpp) do (
    set "FILE=%%f"
    set "REL_PATH=!FILE:%SOURCE_DIR%=!"
    set "DEST_FILE=%OUTPUT_DIR%!REL_PATH!"
    set "DEST_DIR=!DEST_FILE:\%%~nxf=!"
    
    if not exist "!DEST_DIR!" mkdir "!DEST_DIR!"
    copy "%%f" "!DEST_FILE!" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a COUNT+=1
        if !COUNT! lss 10 echo   Copied: !REL_PATH!
    )
)

REM Copy .inc files
echo Copying .inc files...
for /r "%SOURCE_DIR%" %%f in (*.inc) do (
    set "FILE=%%f"
    set "REL_PATH=!FILE:%SOURCE_DIR%=!"
    set "DEST_FILE=%OUTPUT_DIR%!REL_PATH!"
    set "DEST_DIR=!DEST_FILE:\%%~nxf=!"
    
    if not exist "!DEST_DIR!" mkdir "!DEST_DIR!"
    copy "%%f" "!DEST_FILE!" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a COUNT+=1
        if !COUNT! lss 10 echo   Copied: !REL_PATH!
    )
)

echo.
echo ========================================
echo Extraction Complete!
echo Total files copied: %COUNT%
echo Output location: %OUTPUT_DIR%
echo ========================================
echo.

REM Generate a summary file
set "SUMMARY_FILE=%OUTPUT_DIR%\extraction_summary.txt"
echo LibWebRTC Header Extraction Summary > "%SUMMARY_FILE%"
echo ================================== >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo Date: %date% %time% >> "%SUMMARY_FILE%"
echo Source: %SOURCE_DIR% >> "%SUMMARY_FILE%"
echo Total