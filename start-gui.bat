@echo off
REM GUI Launcher for System Monitoring Solution
REM Arab Academy for Science, Technology & Maritime Transport - OS Project 12

echo =====================================
echo   Starting System Monitor GUI
echo   AASTMT - OS Project 12
echo =====================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8 or higher
    pause
    exit /b 1
)

echo Python found!
echo Starting GUI application...
echo.

REM Run the GUI
python monitor_gui.py

if errorlevel 1 (
    echo.
    echo ERROR: Failed to start GUI
    echo Check the error messages above
    pause
)
