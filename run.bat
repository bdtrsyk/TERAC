@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   LumenMAX: Discrete Ternary Cognitive Intelligence Platform
echo   Custom Zero-Gradient, Zero-Attention Cognitive Organism
echo   W in {-1, 0, +1} -- Custom Ternary SSM Core
echo ============================================================
echo.

REM -- Change to script directory --
cd /d "%~dp0"

REM -- Check for Python --
set "PYTHON_CMD=python"
where python >nul 2>&1
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
        set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    ) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
        set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    ) else if exist "%PROGRAMFILES%\Python312\python.exe" (
        set "PYTHON_CMD=%PROGRAMFILES%\Python312\python.exe"
    ) else (
        echo [ERROR] Python was not found in PATH or standard installation paths.
        echo Please install Python 3.10+ from https://www.python.org/
        pause
        exit /b 1
    )
)

for /f "tokens=*" %%i in ('"%PYTHON_CMD%" --version 2^>^&1') do set PY_VER=%%i
echo [OK] Using: %PY_VER%
echo [OK] Path:  %PYTHON_CMD%
echo.

REM -- Install Dependencies (PyQt6, numpy) --
echo [1/2] Verifying and installing required dependencies...
"%PYTHON_CMD%" -m pip install -r "%~dp0requirements.txt" --quiet --disable-pip-version-check
if errorlevel 1 (
    echo [!] Pip install returned a non-zero code, attempting user-level install...
    "%PYTHON_CMD%" -m pip install PyQt6 numpy --user --disable-pip-version-check
)
echo [OK] Dependencies verified.
echo.

REM -- Launch PyQt6 GUI Application --
echo [2/2] Starting LumenMAX PyQt6 Cognitive Platform...
echo.

"%PYTHON_CMD%" "%~dp0gui.py" %*

set EXIT_CODE=%ERRORLEVEL%
echo.
if %EXIT_CODE% equ 0 (
    echo [OK] LumenMAX GUI closed cleanly.
) else (
    echo [!] Process exited with code %EXIT_CODE%.
    pause
)

exit /b %EXIT_CODE%
