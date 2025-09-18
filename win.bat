@echo off
setlocal enabledelayedexpansion

:: Path to your text file containing TV IPs (one per line)
set IP_LIST=tv_ips.txt

:: Root directory on PC where files will be stored
set ROOT_DIR=%cd%\TV_Files

:: Remote directory on TV (adjust this path as needed)
set REMOTE_DIR=/media/usb/

:: Get today’s date in YYYY-MM-DD format
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set TODAY=%%c-%%a-%%b
)

echo Creating root folder: %ROOT_DIR%
if not exist "%ROOT_DIR%" mkdir "%ROOT_DIR%"

for /f "tokens=* delims=" %%I in (%IP_LIST%) do (
    set IP=%%I
    echo -----------------------------------------------------
    echo Processing TV with IP: !IP!

    set TV_DIR=%ROOT_DIR%\!IP!\%TODAY%
    if not exist "!TV_DIR!" mkdir "!TV_DIR!"

    echo Connecting to TV: !IP!
    sdb connect !IP!

    echo Pulling matching files from !IP!...
    sdb -s !IP! shell "ls %REMOTE_DIR% | grep -E '^(Coredump|log_dump).*\.gz$'" > temp_files.txt

    for /f "tokens=* delims=" %%F in (temp_files.txt) do (
        echo Pulling %%F from !IP!
        sdb -s !IP! pull "%REMOTE_DIR%%%F" "!TV_DIR!\%%F"
    )

    del temp_files.txt

    echo Disconnecting from !IP!
    sdb disconnect !IP!
)

echo.
echo All done!
pause
