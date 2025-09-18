@echo off
setlocal enabledelayedexpansion

:: File containing TV IPs (one per line)
set IP_LIST=tv_ips.txt

:: Root directory on PC where files will be stored
set ROOT_DIR=%cd%\TV_Files

:: Remote directory on TV USB (adjust if different)
set REMOTE_DIR=/opt/media/USBDriveA1

:: Get today’s date in YYYY-MM-DD format
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set TODAY=%%c-%%a-%%b
)

if not exist "%ROOT_DIR%" mkdir "%ROOT_DIR%"

for /f "tokens=* delims=" %%I in (%IP_LIST%) do (
    set IP=%%I
    echo -----------------------------------------------------
    echo Processing TV with IP: !IP!

    set TV_DIR=%ROOT_DIR%\!IP!\%TODAY%
    if not exist "!TV_DIR!" mkdir "!TV_DIR!"

    echo Connecting to !IP!...
    sdb connect !IP!

    echo Getting file list from !IP!...
    sdb -s !IP! shell "ls -1 %REMOTE_DIR% | grep -E '^Coredump.*\.gz$|^log_dump.*\.gz$' | sed 's|^|%REMOTE_DIR%/|'" > temp_files.txt

    for /f "usebackq tokens=* delims=" %%F in (`type temp_files.txt`) do (
        echo Pulling %%F
        sdb -s !IP! pull "%%F" "!TV_DIR!\"
    )

    del temp_files.txt

    echo Disconnecting from !IP!
    sdb disconnect !IP!
)

echo.
echo All done!
pause
