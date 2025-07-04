@echo off
SETLOCAL

REM =================================================================
REM ==                                                             ==
REM ==         CLAUDIA FOR WINDOWS - PRE-FLIGHT CHECK & LAUNCHER   ==
REM ==                           v4.2                               ==
REM =================================================================
echo.
echo  This script will verify your system configuration and then
echo  launch the Claudia application.
echo.
echo -----------------------------------------------------------------
echo  [1/6] Verifying System Prerequisites...
echo -----------------------------------------------------------------
echo.

REM --- CHECK 1: Is Bun installed? ---
echo Checking for 'bun'...
where bun >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Bun is not installed or not in your PATH.
    echo.
    echo Please install Bun from https://bun.sh/ and ensure
    echo it is added to your system's PATH variable.
    echo.
    pause
    exit /b 1
)
echo  -^> [OK] Bun found.
echo.

REM --- CHECK 2: Is WSL installed? ---
echo Checking for 'WSL'...
wsl --status >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Windows Subsystem for Linux ^(WSL^) is not installed.
    echo.
    echo Please open PowerShell as an Administrator and run:
    echo wsl --install
    echo Then, restart your computer.
    echo.
    pause
    exit /b 1
)
echo  -^> [OK] WSL is installed.
echo.

REM --- CHECK 3: Is the 'claude.bat' bridge script in PATH? ---
echo Checking for 'claude.bat' bridge...
where claude.bat >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] The 'claude.bat' bridge script was not found.
    echo.
    echo This means the setup script was not run correctly
    echo or %%APPDATA%%\npm is not in your system PATH.
    echo.
    echo Please run 'setup-windows.bat' again.
    echo.
    pause
    exit /b 1
)
echo  -^> [OK] 'claude.bat' bridge found.
echo.

REM --- CHECK 4: Is the 'claude' CLI tool installed in WSL? ---
echo Checking for 'claude' CLI in WSL...
wsl test -f ~/.npm-global/bin/claude
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] The 'claude' CLI tool was not found in your WSL distribution.
    echo.
    echo Please ensure you have run the 'setup-windows.bat' script
    echo to install the tool inside your WSL environment.
    echo.
    pause
    exit /b 1
)
echo  -^> [OK] 'claude' CLI found in WSL.
echo.

REM --- CHECK 5: Does the .claude config directory exist? ---
echo Checking for '~/.claude' config directory in WSL...
wsl test -d ~/.claude
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] The '~/.claude' directory is missing in WSL. Attempting to create it...
    wsl mkdir -p ~/.claude
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Could not create the directory. Please create it manually in WSL:
        echo mkdir -p ~/.claude
        pause
        exit /b 1
    )
    echo  -^> [OK] Directory created successfully.
) else (
    echo  -^> [OK] Config directory exists.
)
echo.

REM --- CHECK 6: Does the .claude/projects directory exist? ---
echo Checking for '~/.claude/projects' directory in WSL...
wsl test -d ~/.claude/projects
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] The '~/.claude/projects' directory is missing. Creating it...
    wsl mkdir -p ~/.claude/projects
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Could not create the projects directory. Please create it manually in WSL:
        echo mkdir -p ~/.claude/projects
        pause
        exit /b 1
    )
    echo  -^> [OK] Projects directory created successfully.
) else (
    echo  -^> [OK] Projects directory exists.
)
echo.

echo -----------------------------------------------------------------
echo  All checks passed! Launching Claudia...
echo -----------------------------------------------------------------
echo.

REM Change to the project directory (assumes the script is in the root)
cd /d "%~dp0"

echo Working Directory: %CD%
echo Frontend will be available at http://localhost:1420/
echo Press Ctrl+C in the console window to exit.
echo.

bun run tauri dev

pause