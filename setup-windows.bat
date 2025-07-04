@echo off
SETLOCAL

echo =================================================================
echo ==                                                             ==
echo ==         CLAUDIA FOR WINDOWS - SETUP SCRIPT V4.2             ==
echo ==                                                             ==
echo =================================================================
echo.
echo This script will configure the WSL bridge for Claudia.
echo It will:
echo  1. Create a 'claude.bat' wrapper in %APPDATA%\npm.
echo  2. Install/Update to the latest 'claude' CLI in WSL.
echo  3. Create the necessary '~/.claude' directory in WSL.
echo.
pause

REM === STEP 1: Create claude.bat bridge script ===
echo.
echo [INFO] Creating the 'claude.bat' bridge script in %APPDATA%\npm...

REM Ensure the npm directory exists
if not exist "%APPDATA%\npm" (
    mkdir "%APPDATA%\npm"
)

REM Create the claude.bat file with automatic version detection
(
echo @echo off
echo setlocal enabledelayedexpansion
echo.
echo REM This is a bridge script for Claudia on Windows.
echo REM It calls the 'claude' CLI within WSL and handles argument filtering.
echo.
echo REM --- Configuration ---
echo REM Enter the name of your WSL distribution here ^(e.g., "Ubuntu"^).
echo REM Leave empty to use the default distribution.
echo SET "WSL_DISTRO="
echo.
echo REM --- Argument Handling ---
echo.
echo REM ** IMPORTANT: Version check - get real version from WSL claude **
echo if /I "%%~1" == "--version" ^(
echo     REM Get the actual version from claude in WSL and format it correctly
echo     for /f "delims=" %%%%i in ^('wsl bash -lc "source ~/.bashrc ^&^& ~/.npm-global/bin/claude --version 2^>^/dev/null"'^) do set "CLAUDE_VERSION=%%%%i"
echo     
echo     REM If we got a version, output it in the format Claudia expects
echo     if defined CLAUDE_VERSION ^(
echo         echo ^^!CLAUDE_VERSION^^!
echo     ^) else ^(
echo         echo Claude Code 1.0.41
echo     ^)
echo     exit /b 0
echo ^)
echo.
echo REM Build command with all arguments EXCEPT --system-prompt and --no-color
echo set "CMD="
echo set "SKIP_NEXT=0"
echo.
echo :parse_args
echo if "%%~1"=="" goto :execute
echo.
echo if "^^!SKIP_NEXT^^!"=="1" ^(
echo     set "SKIP_NEXT=0"
echo     shift
echo     goto :parse_args
echo ^)
echo.
echo if "%%~1"=="--system-prompt" ^(
echo     set "SKIP_NEXT=1"
echo     shift
echo     goto :parse_args
echo ^)
echo.
echo if "%%~1"=="--no-color" ^(
echo     shift
echo     goto :parse_args
echo ^)
echo.
echo REM Add argument to command - handle quoted arguments properly
echo set "ARG=%%~1"
echo REM Escape quotes for bash
echo set "ARG=^^!ARG:"=\"^^!"
echo.
echo if defined CMD ^(
echo     set "CMD=^^!CMD^^! \"^^!ARG^^!\""
echo ^) else ^(
echo     set "CMD=\"^^!ARG^^!\""
echo ^)
echo.
echo shift
echo goto :parse_args
echo.
echo :execute
echo REM Execute with proper escaping using the correct path
echo if defined WSL_DISTRO ^(
echo     wsl -d "%%WSL_DISTRO%%" bash -lc "source ~/.bashrc ^&^& ~/.npm-global/bin/claude ^^!CMD^^!"
echo ^) else ^(
echo     wsl bash -lc "source ~/.bashrc ^&^& ~/.npm-global/bin/claude ^^!CMD^^!"
echo ^)
) > "%APPDATA%\npm\claude.bat"

if exist "%APPDATA%\npm\claude.bat" (
    echo [OK] 'claude.bat' created successfully.
) else (
    echo [ERROR] Failed to create 'claude.bat'.
    pause
    exit /b 1
)

REM === STEP 2: Install Claude CLI in WSL ===
echo.
echo =====================================================
echo    Installing/Updating Claude CLI in WSL...
echo =====================================================
echo.

REM Check if Node.js is installed in WSL
echo [INFO] Checking Node.js installation in WSL...
wsl bash -lc "node --version" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js is not installed in WSL.
    echo.
    echo Please install Node.js in WSL first by running these commands in Ubuntu:
    echo   sudo apt update
    echo   curl -fsSL https://deb.nodesource.com/setup_20.x ^| sudo -E bash -
    echo   sudo apt install -y nodejs
    echo.
    pause
    exit /b 1
)

echo [INFO] Configuring npm for WSL...
wsl bash -lc "npm config set prefix ~/.npm-global && npm config set os linux"

echo [INFO] Installing @anthropic-ai/claude-code using npm...
wsl bash -lc "npm install -g @anthropic-ai/claude-code"

if %ERRORLEVEL% EQU 0 (
    echo [OK] Claude CLI installed successfully.
) else (
    echo [ERROR] Failed to install Claude CLI.
    echo Please check your internet connection and WSL installation.
    pause
    exit /b 1
)

REM === STEP 3: Create ~/.claude directory ===
echo.
echo [INFO] Creating ~/.claude configuration directory in WSL...
wsl bash -lc "mkdir -p ~/.claude"

if %ERRORLEVEL% EQU 0 (
    echo [OK] Configuration directory created.
) else (
    echo [WARNING] Could not create ~/.claude directory.
)

REM === STEP 3.1: Create ~/.claude/projects directory ===
echo [INFO] Creating ~/.claude/projects directory in WSL...
wsl bash -lc "mkdir -p ~/.claude/projects"

if %ERRORLEVEL% EQU 0 (
    echo [OK] Projects directory created.
) else (
    echo [WARNING] Could not create ~/.claude/projects directory.
)

REM === STEP 4: Update PATH in .bashrc ===
echo.
echo [INFO] Updating PATH in WSL .bashrc...
wsl bash -lc "grep -q 'export PATH=\"\$HOME/.npm-global/bin:\$PATH\"' ~/.bashrc || echo 'export PATH=\"\$HOME/.npm-global/bin:\$PATH\"' >> ~/.bashrc"

if %ERRORLEVEL% EQU 0 (
    echo [OK] PATH updated in .bashrc.
) else (
    echo [WARNING] Could not update PATH in .bashrc.
)

echo.
echo =================================================================
echo ==                                                             ==
echo ==            SETUP COMPLETED SUCCESSFULLY!                    ==
echo ==                                                             ==
echo ==   You can now run Claudia using 'start-claudia.bat'        ==
echo ==                                                             ==
echo =================================================================
echo.
pause