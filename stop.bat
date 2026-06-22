@echo off
title Friend Diagnostics - stop tunnel
echo.
echo Stopping any running cloudflared tunnel...
taskkill /F /IM cloudflared.exe 2>nul
if errorlevel 1 (
    echo No cloudflared process was running.
) else (
    echo Tunnel stopped.
)
echo.
pause
