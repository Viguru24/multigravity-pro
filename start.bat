@echo off
setlocal EnableDelayedExpansion
title Multigravity Pro Launcher

:: If launched directly without arguments (e.g. from CosmoLauncher or File Explorer),
:: ensure it runs inside an interactive, visible terminal window instead of a hidden process.
if "%~1"=="" (
    start "Multigravity Pro" cmd.exe /c call "%~f0" --menu
    exit /b 0
)

:: If internal menu flag is passed, jump straight to the interactive menu
if "%~1"=="--menu" goto menu

:: If arguments are provided, directly forward them to multigravity
call multigravity %*
exit /b %ERRORLEVEL%

:menu
cls
echo ======================================================
echo               MULTIGRAVITY PRO LAUNCHER              
echo ======================================================
echo.
echo Current Profiles:
call multigravity list
echo.
echo ------------------------------------------------------
echo   [1] Launch an existing profile
echo   [2] Create a new profile (Full isolation)
echo   [3] Create a new profile (Auth-only - recommended)
echo   [4] Check profile status and storage
echo   [5] Run environment diagnostics (Doctor)
echo   [6] Open profiles directory in File Explorer
echo   [Q] Quit
echo ------------------------------------------------------
echo.

choice /c 123456Q /n /m "Select an option (1-6 or Q): "
if errorlevel 7 goto end
if errorlevel 6 goto open_folder
if errorlevel 5 goto run_doctor
if errorlevel 4 goto check_status
if errorlevel 3 goto create_auth
if errorlevel 2 goto create_full
if errorlevel 1 goto launch_profile
goto menu

:launch_profile
cls
echo ======================================================
echo               SELECT A PROFILE TO LAUNCH             
echo ======================================================
echo.
set "PDIR=%USERPROFILE%\AntigravityProfiles"
if defined MULTIGRAVITY_HOME set "PDIR=%MULTIGRAVITY_HOME%"

set /a count=0
for /d %%D in ("%PDIR%\*") do (
    set "fname=%%~nxD"
    if not "!fname:~0,1!"=="." (
        set /a count+=1
        set "prof_!count!=!fname!"
        echo   [!count!] !fname!
    )
)

if %count%==0 (
    echo   No isolated profiles found in %PDIR%.
)

echo.
echo   [D] Default / Primary Antigravity (Original Account)
echo   [B] Back to Main Menu
echo.
set "pchoice="
set /p "pchoice=Select an option (1-%count%, D, or B): "
if not defined pchoice goto menu
if /i "!pchoice!"=="B" goto menu
if /i "!pchoice!"=="D" (
    cls
    echo Launching Default / Primary Antigravity...
    if exist "%LOCALAPPDATA%\Programs\Antigravity\Antigravity.exe" (
        start "" "%LOCALAPPDATA%\Programs\Antigravity\Antigravity.exe"
    ) else (
        start "" "antigravity"
    )
    goto end
)

:: If a number was entered, resolve to profile name
if defined prof_!pchoice! (
    set "pname=!prof_%pchoice%!"
) else (
    set "pname=!pchoice!"
)

cls
echo Launching profile "!pname!"...
call multigravity "!pname!"
if errorlevel 1 (
    echo.
    echo ------------------------------------------------------
    echo [ERROR] Could not launch profile "!pname!".
    echo Make sure the profile name matches an existing profile.
    echo ------------------------------------------------------
    echo.
    pause
    goto menu
)
goto end

:create_full
cls
echo ======================================================
echo               CREATE FULL PROFILE                    
echo ======================================================
echo Creates an isolated profile with its own extensions,
echo settings, and login credentials.
echo.
set "pname="
set /p "pname=Enter new profile name: "
if not defined pname goto menu
call multigravity new !pname!
echo.
choice /c YN /m "Launch profile '!pname!' now? "
if errorlevel 2 goto menu
if errorlevel 1 (
    cls
    echo Launching profile "!pname!"...
    call multigravity "!pname!"
    if errorlevel 1 (
        echo.
        echo [ERROR] Failed to launch profile "!pname!".
        pause
        goto menu
    )
    goto end
)
goto menu

:create_auth
cls
echo ======================================================
echo               CREATE AUTH-ONLY PROFILE               
echo ======================================================
echo Creates an isolated profile that shares your existing
echo extensions and settings, but isolates login credentials.
echo.
set "pname="
set /p "pname=Enter new profile name: "
if not defined pname goto menu
call multigravity new !pname! --auth-only
echo.
choice /c YN /m "Launch profile '!pname!' now? "
if errorlevel 2 goto menu
if errorlevel 1 (
    cls
    echo Launching profile "!pname!"...
    call multigravity "!pname!"
    if errorlevel 1 (
        echo.
        echo [ERROR] Failed to launch profile "!pname!".
        pause
        goto menu
    )
    goto end
)
goto menu

:check_status
cls
echo ======================================================
echo               PROFILE STATUS ^& STORAGE               
echo ======================================================
echo.
call multigravity status
echo.
call multigravity stats
echo.
pause
goto menu

:run_doctor
cls
echo ======================================================
echo               MULTIGRAVITY DOCTOR                    
echo ======================================================
echo.
call multigravity doctor
echo.
pause
goto menu

:open_folder
set "PDIR=%USERPROFILE%\AntigravityProfiles"
if defined MULTIGRAVITY_HOME set "PDIR=%MULTIGRAVITY_HOME%"
if not exist "%PDIR%" mkdir "%PDIR%"
start explorer "%PDIR%"
goto menu

:end
endlocal
