@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo ===============================
echo   PhysioPro Site Sync Script
echo ===============================
echo.

echo ---- Pulling latest (rebase + autostash) ----
git pull --rebase --autostash
if errorlevel 1 (
  echo ❌ Pull failed. Resolve conflicts, then rerun.
  pause
  exit /b 1
)

echo.
echo ---- Staging ----
git add -A

REM Build commit message safely from all args
set "MSG="
:loop
if "%~1"=="" goto done
set "MSG=!MSG!%~1 "
shift
goto loop
:done

REM Default message if none provided
if "!MSG!"=="" set "MSG=Update site"

echo.
echo ---- Committing: "!MSG!" ----
git commit -m "!MSG!" >nul 2>&1

echo.
echo ---- Pushing ----
git push
if errorlevel 1 (
  echo ❌ Push failed.
  pause
  exit /b 1
)

echo.
echo ✅ Done.
pause