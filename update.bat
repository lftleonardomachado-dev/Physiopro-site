@echo off
setlocal enabledelayedexpansion

echo ===============================
echo   PhysioPro Site Sync Script
echo ===============================
echo.

cd /d "%~dp0"

if not exist ".git" (
  echo ERROR: Not a git repo. Put this file inside the repo folder.
  pause
  exit /b 1
)

REM Detect if there are local changes (tracked files)
git diff --quiet
set HAS_CHANGES=%ERRORLEVEL%

REM Detect if there are untracked files
for /f %%A in ('git ls-files --others --exclude-standard ^| find /c /v ""') do set UNTRACKED=%%A

if NOT "%HAS_CHANGES%"=="0" (
  echo ---- Local changes detected. Stashing... ----
  git stash push -u -m "autostash before pull"
  if errorlevel 1 (
    echo ERROR: Stash failed.
    pause
    exit /b 1
  )
  set DID_STASH=1
) else (
  if NOT "%UNTRACKED%"=="0" (
    echo ---- Untracked files detected. Stashing... ----
    git stash push -u -m "autostash before pull"
    if errorlevel 1 (
      echo ERROR: Stash failed.
      pause
      exit /b 1
    )
    set DID_STASH=1
  ) else (
    set DID_STASH=0
  )
)

echo ---- Pulling latest (rebase) ----
git pull --rebase
if errorlevel 1 (
  echo.
  echo ERROR: Pull failed. You may have a conflict.
  echo Open VS Code, resolve conflicts, then run this again.
  pause
  exit /b 1
)

if "%DID_STASH%"=="1" (
  echo.
  echo ---- Re-applying stashed changes ----
  git stash pop
  if errorlevel 1 (
    echo.
    echo WARNING: Stash pop had conflicts.
    echo Resolve conflicts in VS Code, then:
    echo   git add -A
    echo   git rebase --continue  (if rebase is in progress)
    echo Then run update.bat again.
    pause
    exit /b 1
  )
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
  echo ERROR: Push failed (auth?). If needed:
  echo   git push --set-upstream origin main
  pause
  exit /b 1
)

echo.
echo Done.
pause