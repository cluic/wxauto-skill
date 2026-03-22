@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo   wxauto Skill Installer
echo ========================================
echo.

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "SKILL_SOURCE=%SCRIPT_DIR%wxauto"
set "SKILL_TARGET=%USERPROFILE%\.openclaw\skills\wxauto"

:: Check source exists
if not exist "%SKILL_SOURCE%\SKILL.md" (
    echo [ERROR] Skill source not found: %SKILL_SOURCE%
    echo Please make sure this script is in the wxauto-skill folder.
    pause
    exit /b 1
)

:: Create target directory
echo [1/3] Creating target directory...
if not exist "%USERPROFILE%\.openclaw\skills" (
    mkdir "%USERPROFILE%\.openclaw\skills"
)

:: Remove old installation if exists
if exist "%SKILL_TARGET%" (
    echo [2/3] Removing old installation...
    rmdir /s /q "%SKILL_TARGET%"
) else (
    echo [2/3] Installing...
)

:: Copy skill files
echo [3/3] Copying skill files...
xcopy "%SKILL_SOURCE%" "%SKILL_TARGET%\" /e /i /q

:: Check result
if exist "%SKILL_TARGET%\SKILL.md" (
    echo.
    echo ========================================
    echo   Installation completed!
    echo ========================================
    echo.
    echo Skill installed to:
    echo   %SKILL_TARGET%
    echo.
    echo Next steps:
    echo   1. Deploy wxauto-restful-api service
    echo      https://github.com/cluic/wxauto-restful-api
    echo   2. Restart OpenClaw to load the skill
    echo.
) else (
    echo.
    echo [ERROR] Installation failed!
    echo Please check permissions and try again.
    echo.
)

pause
