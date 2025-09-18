@echo off
setlocal enabledelayedexpansion

:: Text file with TV IPs
set IP_LIST=tv_ips.txt

:: Root directory on PC
set ROOT_DIR=%cd%\TV_Files

:: Remote directory on TV USB
set REMOTE_DIR=/opt/media/USBDriveA1

:: Get today's date
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
    sdb -s !IP! shell "for f in %REMOTE_DIR%/*; do case \$(basename \"\$f\") in Coredump*.gz|log_dump*.gz) echo \$f ;; esac; done" > temp_files.txt

    for /f "tokens=* delims=" %%F in (temp_files.txt) do (
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
