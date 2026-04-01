@echo off
setlocal
echo ============================================================
echo  CONNECT - Claude Session Bridge
echo ============================================================
echo.

:: Auto-patch paths (safe to run every time)
echo Checking packages and patching paths...
set "CONNECT_DIR=%~dp0"
powershell -Command "(Get-Content '%~dp0SESSION_A.md') -replace '\{CONNECT_DIR\}', '%CONNECT_DIR%' | Set-Content '%~dp0SESSION_A.md'" >nul 2>&1
powershell -Command "(Get-Content '%~dp0SESSION_B.md') -replace '\{CONNECT_DIR\}', '%CONNECT_DIR%' | Set-Content '%~dp0SESSION_B.md'" >nul 2>&1
powershell -Command "(Get-Content '%~dp0SESSION_PROMPT.md') -replace '\{CONNECT_DIR\}', '%CONNECT_DIR%' | Set-Content '%~dp0SESSION_PROMPT.md'" >nul 2>&1

:: Install dependencies if node_modules missing
if not exist "%~dp0node_modules\robotjs" (
    echo Installing dependencies...
    cd /d "%~dp0"
    npm install --silent
    if errorlevel 1 (
        echo [ERROR] npm install failed. Make sure Python and Visual Studio Build Tools are installed.
        pause
        exit /b
    )
    echo Dependencies installed successfully.
    pause
)

echo IMPORTANT: Before continuing, open two SEPARATE terminal windows
echo (not tabs in the same window). Title each one exactly:
echo   Window 1: SessionA
echo   Window 2: SessionB
echo.
echo To rename: right-click the tab, select Rename, type SessionA or SessionB
echo.
pause

:: Clear all queue files
echo. > "%~dp0msg_a.txt"
echo. > "%~dp0msg_b.txt"
echo. > "%~dp0response_a.txt"
echo. > "%~dp0response_b.txt"

:: Ask for topic
set /p TOPIC="Enter starting topic: "

:: Write topic to msg_a.txt (kicks off Session A)
echo|set /p="%TOPIC%" > "%~dp0msg_a.txt"

:: Start conversation log
echo [START] Topic: %TOPIC% > "%~dp0conversation.txt"
echo. >> "%~dp0conversation.txt"

echo.
echo Topic written to msg_a.txt
echo Starting watcher...
echo.
echo Kill switch: Ctrl+C in the watcher window
echo ============================================================

:: Launch Node.js watcher in a new window
set "WATCHER=%~dp0watcher.js"
start "CONNECT Watcher" cmd /k "node "%WATCHER%""

:: Give watcher a moment to start, then trigger Session A
timeout /t 2 /nobreak >nul
powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).AppActivate('SessionA')"
timeout /t 1 /nobreak >nul
powershell -NoProfile -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys('go{ENTER}')"

echo Watcher launched. Sessions will now talk automatically.
echo.
pause
