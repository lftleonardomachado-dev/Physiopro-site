@echo off
setlocal

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

set MSG=%*
if "%MSG%"=="" set MSG=Update site

echo.
echo ---- Committing: "%MSG%" ----
git commit -m "%MSG%" >nul 2>&1

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