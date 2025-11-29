@echo off
REM Quick launcher for System Monitoring Solution
REM Arab Academy for Science, Technology & Maritime Transport - OS Project 12

echo =====================================
echo   System Monitoring Quick Launcher
echo   AASTMT - OS Project 12
echo =====================================
echo.

if "%1"=="" (
    echo Usage: run.bat [command]
    echo.
    echo Available Commands:
    echo   monitor     - Run full monitoring
    echo   report      - Generate report
    echo   cpu         - Monitor CPU
    echo   memory      - Monitor memory
    echo   disk        - Monitor disk
    echo   gpu         - Monitor GPU
    echo   network     - Monitor network
    echo   system      - Monitor system load
    echo   help        - Show help
    echo.
    echo Example: run.bat monitor
    echo.
    pause
    exit /b
)

echo Running monitoring with command: %1
echo.

wsl bash -c "./monitor.sh %1"

echo.
echo =====================================
echo Monitoring Complete!
echo =====================================
echo.
echo Check the following directories:
echo   logs\    - Log files
echo   reports\ - Generated reports
echo   data\    - CSV data files
echo.
pause
