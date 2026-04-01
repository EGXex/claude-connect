@echo off
setlocal

echo [CONNECT] Setup starting...

:: Check Node.js
where node >nul 2>&1
if errorlevel 1 (
    echo Node.js not found. Downloading installer...
    curl -L -o "%TEMP%\node_installer.msi" "https://nodejs.org/dist/v20.14.0/node-v20.14.0-x64.msi"
    msiexec /i "%TEMP%\node_installer.msi" /quiet /norestart
    echo.
    echo Node.js installed. Please close this window and run setup.bat again.
    pause
    exit /b
)

:: Patch hardcoded paths in config files (safe to run multiple times)
echo Patching file paths...
set "CONNECT_DIR=%~dp0"
powershell -Command "(Get-Content '%~dp0SESSION_PROMPT.md') -replace '\{CONNECT_DIR\}', '%CONNECT_DIR%' | Set-Content '%~dp0SESSION_PROMPT.md'"
powershell -Command "(Get-Content '%~dp0SESSION_A.md') -replace '\{CONNECT_DIR\}', '%CONNECT_DIR%' | Set-Content '%~dp0SESSION_A.md'"
powershell -Command "(Get-Content '%~dp0watcher.js') -replace '\{CONNECT_DIR\}', '%CONNECT_DIR%' | Set-Content '%~dp0watcher.js'"
powershell -Command "(Get-Content '%~dp0SESSION_B.md') -replace '\{CONNECT_DIR\}', '%CONNECT_DIR%' | Set-Content '%~dp0SESSION_B.md'"

:: Create message files if they don't exist
if not exist "%~dp0msg_a.txt" echo. > "%~dp0msg_a.txt"
if not exist "%~dp0msg_b.txt" echo. > "%~dp0msg_b.txt"
if not exist "%~dp0response_a.txt" echo. > "%~dp0response_a.txt"
if not exist "%~dp0response_b.txt" echo. > "%~dp0response_b.txt"

:: Install dependencies (robotjs requires build tools)
echo Installing dependencies...
echo NOTE: robotjs requires build tools. If this fails, install:
echo   - Python 3: https://python.org
echo   - Visual Studio Build Tools: https://aka.ms/vs/17/release/vs_BuildTools.exe
echo   Then run setup.bat again.
echo.
cd /d "%~dp0"
npm install
if errorlevel 1 (
    echo.
    echo [ERROR] npm install failed. See note above about build tools.
    pause
    exit /b
)

:: Check Claude Code CLI
where claude >nul 2>&1
if errorlevel 1 (
    echo Installing Claude Code CLI...
    npm install -g @anthropic-ai/claude-code
)

echo.
echo [CONNECT] Setup complete.
echo.
echo HOW TO USE:
echo   Manual mode (one turn at a time):
echo     1. Open two terminals, paste prompts from SESSION_PROMPT.md into each
echo     2. Edit msg_a.txt with your opening message
echo     3. In terminal 1: type  go  — Session A replies to response_a.txt
echo     4. Copy response_a.txt content into msg_b.txt
echo     5. In terminal 2: type  go  — Session B replies to response_b.txt
echo     6. Repeat
echo.
echo   Auto mode (fully automatic loop):
echo     1. Open two SEPARATE terminal windows (not tabs in the same window)
echo        Right-click each tab, select Rename
echo        Title them exactly: SessionA and SessionB
echo     2. Paste prompts from SESSION_PROMPT.md into each
echo     3. Run start.bat — it will handle everything automatically
echo.
pause
