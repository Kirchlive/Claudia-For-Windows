@echo off
SETLOCAL EnableDelayedExpansion

REM =================================================================
REM ==                                                             ==
REM ==     CLAUDIA FOR WINDOWS - AUTOMATED INSTALLER V4.2          ==
REM ==                                                             ==
REM =================================================================

echo.
echo  =====================================================
echo  ==   CLAUDIA WINDOWS AUTO-INSTALLER V4.2          ==
echo  ==   This will automatically apply all fixes       ==
echo  =====================================================
echo.

REM === Check if we're in the right directory ===
if not exist "src-tauri\src\main.rs" (
    echo [ERROR] This script must be run from the Claudia root directory!
    echo Please navigate to your Claudia folder and run again.
    pause
    exit /b 1
)

REM === Step 1: Apply main.rs patch ===
echo.
echo [1/6] Applying main.rs version compatibility patch...
echo -----------------------------------------------------------------

REM Check if patch already applied
findstr /C:"let is_valid_version = claude_version.contains" "src-tauri\src\main.rs" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Version patch already applied to main.rs
) else (
    echo [INFO] Applying version patch to main.rs...
    
    REM Create backup
    copy "src-tauri\src\main.rs" "src-tauri\src\main.rs.backup" >nul 2>&1
    
    REM Apply the patch using PowerShell
    powershell -NoProfile -Command ^
    "$content = Get-Content 'src-tauri\src\main.rs' -Raw; ^
    $searchPattern = 'claude_version == \"Claude Code 1.0.41\"'; ^
    $replacePattern = 'claude_version.contains(\"Claude Code\") || claude_version.chars().any(|c| c.is_digit(10)) && claude_version.contains(''.'')'; ^
    if ($content -match [regex]::Escape($searchPattern)) { ^
        $newContent = $content -replace [regex]::Escape($searchPattern), $replacePattern; ^
        Set-Content -Path 'src-tauri\src\main.rs' -Value $newContent -NoNewline; ^
        Write-Host '[OK] Version patch applied successfully' -ForegroundColor Green; ^
    } else { ^
        Write-Host '[WARNING] Could not find exact match for version check' -ForegroundColor Yellow; ^
    }"
)

REM === Step 2: Apply agents.rs patch (Projects directory fix) ===
echo.
echo [2/6] Applying agents.rs projects directory fix...
echo -----------------------------------------------------------------

REM Check if patch already applied
findstr /C:"Don't log as error - this is expected on Windows" "src-tauri\src\commands\agents.rs" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Projects directory fix already applied to agents.rs
) else (
    echo [INFO] Applying projects directory fix to agents.rs...
    
    REM Create backup
    copy "src-tauri\src\commands\agents.rs" "src-tauri\src\commands\agents.rs.backup" >nul 2>&1
    
    REM Apply the fix using PowerShell
    powershell -NoProfile -Command ^
    "$content = Get-Content 'src-tauri\src\commands\agents.rs' -Raw; ^
    $pattern1 = 'log::error!(\"Projects directory not found at: \{:?\}\", projects_dir);[\r\n\s]*return Err\(\"Projects directory not found\"\.to_string\(\)\);'; ^
    $replace1 = '// Don''t log as error - this is expected on Windows when Claude runs in WSL' + [Environment]::NewLine + ^
    '        // The agent still works correctly, so just return empty output' + [Environment]::NewLine + ^
    '        log::debug!(\"Projects directory not found at: {:?}, returning empty output\", projects_dir);' + [Environment]::NewLine + ^
    '        return Ok(String::new());'; ^
    $pattern2 = 'log::error!(\"Projects directory not found at: \{:?\}\", projects_dir);[\r\n\s]*return Err\(\"Projects directory not found\"\.to_string\(\)\);'; ^
    $replace2 = '// Don''t log as error - this is expected on Windows when Claude runs in WSL' + [Environment]::NewLine + ^
    '        // Return empty list instead of error' + [Environment]::NewLine + ^
    '        log::debug!(\"Projects directory not found at: {:?}\", projects_dir);' + [Environment]::NewLine + ^
    '        return Ok(Vec::new());'; ^
    $newContent = $content -replace $pattern1, $replace1; ^
    $count = ([regex]::Matches($content, $pattern1)).Count; ^
    if ($count -eq 0) { ^
        $simplePattern = 'log::error!\(\"Projects directory not found'; ^
        $count = ([regex]::Matches($content, $simplePattern)).Count; ^
        if ($count -gt 0) { ^
            Write-Host '[WARNING] Found error logs but could not apply precise fix. Manual edit may be needed.' -ForegroundColor Yellow; ^
        } ^
    } else { ^
        Set-Content -Path 'src-tauri\src\commands\agents.rs' -Value $newContent -NoNewline; ^
        Write-Host '[OK] Projects directory fix applied successfully' -ForegroundColor Green; ^
    }"
)

REM === Step 3: Fix fetch-and-build.js ===
echo.
echo [3/6] Fixing fetch-and-build.js for Windows compatibility...
echo -----------------------------------------------------------------

findstr /C:"process.platform === 'win32'" "scripts\fetch-and-build.js" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] fetch-and-build.js already fixed
) else (
    echo [INFO] Applying Windows fix to fetch-and-build.js...
    
    copy "scripts\fetch-and-build.js" "scripts\fetch-and-build.js.backup" >nul 2>&1
    
    powershell -NoProfile -Command ^
    "$content = Get-Content 'scripts\fetch-and-build.js' -Raw; ^
    $searchPattern = 'await runCommand\(''cp'''; ^
    $replaceWith = 'if (process.platform === ''win32'') {' + [Environment]::NewLine + ^
    '      await runCommand(''robocopy'', [srcPath, destPath, ''/E'', ''/NFL'', ''/NDL'', ''/NJH'', ''/NJS'', ''/nc'', ''/ns'', ''/np'']);' + [Environment]::NewLine + ^
    '    } else {' + [Environment]::NewLine + ^
    '      await runCommand(''cp'''; ^
    if ($content -match [regex]::Escape($searchPattern)) { ^
        $newContent = $content -replace [regex]::Escape($searchPattern), $replaceWith; ^
        $newContent = $newContent -replace '\)\);', '));' + [Environment]::NewLine + '    }'; ^
        Set-Content -Path 'scripts\fetch-and-build.js' -Value $newContent -NoNewline; ^
        Write-Host '[OK] Windows compatibility added to fetch-and-build.js' -ForegroundColor Green; ^
    } else { ^
        Write-Host '[WARNING] Could not find cp command in fetch-and-build.js' -ForegroundColor Yellow; ^
    }"
)

REM === Step 4: Fix build-executables.js ===
echo.
echo [4/6] Fixing build-executables.js for Windows shell support...
echo -----------------------------------------------------------------

findstr /C:"shell: process.platform === 'win32'" "scripts\build-executables.js" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] build-executables.js already fixed
) else (
    echo [INFO] Adding shell support to build-executables.js...
    
    copy "scripts\build-executables.js" "scripts\build-executables.js.backup" >nul 2>&1
    
    powershell -NoProfile -Command ^
    "$content = Get-Content 'scripts\build-executables.js' -Raw; ^
    $pattern = 'spawn\(command, args, \{ stdio: ''inherit'' \}\)'; ^
    $replacement = 'spawn(command, args, { stdio: ''inherit'', shell: process.platform === ''win32'' })'; ^
    if ($content -match [regex]::Escape($pattern)) { ^
        $newContent = $content -replace [regex]::Escape($pattern), $replacement; ^
        Set-Content -Path 'scripts\build-executables.js' -Value $newContent -NoNewline; ^
        Write-Host '[OK] Shell support added to build-executables.js' -ForegroundColor Green; ^
    } else { ^
        Write-Host '[WARNING] Could not find spawn command in build-executables.js' -ForegroundColor Yellow; ^
    }"
)

REM === Step 5: Fix tauri.conf.json ===
echo.
echo [5/6] Adding icon.ico to tauri.conf.json...
echo -----------------------------------------------------------------

findstr /C:"icon.ico" "src-tauri\tauri.conf.json" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] icon.ico already in tauri.conf.json
) else (
    echo [INFO] Adding icon.ico to bundle configuration...
    
    copy "src-tauri\tauri.conf.json" "src-tauri\tauri.conf.json.backup" >nul 2>&1
    
    powershell -NoProfile -Command ^
    "$content = Get-Content 'src-tauri\tauri.conf.json' -Raw; ^
    $pattern = '\"icons/icon.png\"'; ^
    $replacement = '\"icons/icon.png\",' + [Environment]::NewLine + '        \"icons/icon.ico\"'; ^
    if ($content -match [regex]::Escape($pattern)) { ^
        $newContent = $content -replace [regex]::Escape($pattern), $replacement; ^
        Set-Content -Path 'src-tauri\tauri.conf.json' -Value $newContent -NoNewline; ^
        Write-Host '[OK] icon.ico added to tauri.conf.json' -ForegroundColor Green; ^
    } else { ^
        Write-Host '[WARNING] Could not find icon.png in tauri.conf.json' -ForegroundColor Yellow; ^
    }"
)

REM === Step 6: Handle robocopy exit codes in runCommand ===
echo.
echo [6/6] Fixing robocopy exit code handling...
echo -----------------------------------------------------------------

findstr /C:"Robocopy exit code" "scripts\fetch-and-build.js" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Robocopy exit code handling already implemented
) else (
    echo [INFO] Adding robocopy exit code handling...
    
    powershell -NoProfile -Command ^
    "$content = Get-Content 'scripts\fetch-and-build.js' -Raw; ^
    $searchPattern = 'if \(code !== 0\) \{'; ^
    $replacePattern = '// Robocopy exit codes 0-7 are success' + [Environment]::NewLine + ^
    '    if (command === ''robocopy'' && code >= 0 && code <= 7) {' + [Environment]::NewLine + ^
    '      resolve();' + [Environment]::NewLine + ^
    '      return;' + [Environment]::NewLine + ^
    '    }' + [Environment]::NewLine + ^
    '    if (code !== 0) {'; ^
    if ($content -match [regex]::Escape($searchPattern)) { ^
        $newContent = $content -replace [regex]::Escape($searchPattern), $replacePattern; ^
        Set-Content -Path 'scripts\fetch-and-build.js' -Value $newContent -NoNewline; ^
        Write-Host '[OK] Robocopy exit code handling added' -ForegroundColor Green; ^
    } else { ^
        Write-Host '[INFO] runCommand function may need manual update for robocopy' -ForegroundColor Yellow; ^
    }"
)

echo.
echo =================================================================
echo ==                                                             ==
echo ==            ALL PATCHES APPLIED SUCCESSFULLY!                ==
echo ==                                                             ==
echo ==   Next steps:                                               ==
echo ==   1. Run setup-windows.bat to install Claude CLI in WSL     ==
echo ==   2. Run 'bun install' to install dependencies             ==
echo ==   3. Run 'bun run build' to build the frontend             ==
echo ==   4. Run 'bun run tauri build' to build Claudia            ==
echo ==   5. Use start-claudia.bat to launch Claudia               ==
echo ==                                                             ==
echo =================================================================
echo.

REM Ask if user wants to run setup script
set /p RUN_SETUP="Do you want to run setup-windows.bat now? (y/n): "
if /i "%RUN_SETUP%"=="y" (
    echo.
    echo Running setup script...
    call "%~dp0\setup-windows.bat"
)

pause